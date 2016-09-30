unit SC_MultiDisplay;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  ********************************************* }

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Math, ExtCtrls,
  SLCanvas32;

type
  TDisplayKind = (dkSkin, dkVisual, dkCover);

  TWaveData8 = array[0..1023] of Byte; // Wave 8 bit
  TWaveData16 = array[0..1023] of DWORD; // Wave 16 bit
  TWaveData32 = array[0..2047 { 4095 }] of Single; // Wave 32 bit
  TFFTData = array[0..1023] of Single; // FFT 32 bit

  // =========== SONIQUE =============

type
  TWaveDataMatrix = array[0..1, 0..512 - 1] of ShortInt;
  TSpectrumMatrix = array[0..1, 0..256 - 1] of Byte;
  PVisData = ^TVisData;

  TVisData = record
    // TimeStamp: Cardinal;
    MillSec: Cardinal;
    WaveForm: TWaveDataMatrix;
    Spectrum: TSpectrumMatrix;
    // SongTitle: PChar;      // title of song
    // InputSource: Cardinal; // source of song (0=HD, 1=CD 2=Stream)
  end;

  PVisInfo = ^TVisInfo;

  TVisInfo = record
    Version: Cardinal;
    PluginName: PChar;
    lRequired: integer;
    Initialize: procedure; cdecl;
    Render: function(Video: Pointer; Width, Heigth, Pitch: integer;
      pVD: PVisData): Boolean; cdecl;
    SaveSettings: function(FileName: PAnsiChar): Boolean; cdecl;
    OpenSettings: function(FileName: PAnsiChar): Boolean; cdecl;
    Deinit: function: Boolean; cdecl;
    Clicked: function(x, y, Buttons: integer): Boolean; cdecl;
    ReceiveQueryInterface: function(qInterface: Pointer): Boolean; cdecl;
  end;

  // ------------------------------------------------------------------------------
  // ------------------------------------------------------------------------------

  TZMSDisplay = class(TGraphicControl)
  private
    fSkin, fSkinCover, fCover, fBuffer: TBitmap;
    fDrawer: TacSLCanvas32;

    SoniqVisInfo: PVisInfo;
    SoniqVisData: TVisData;
    Soniq_QueryModule: function: PVisInfo; stdcall;

    fLoadPlugin: Boolean;
    fDllhandle: Cardinal;
    Saved8087CW: Word;

    fWAVEData, fFFTData, fClicked, fEffects: Boolean;
    fSupportClick: Boolean;

    fKind: TDisplayKind;

    fPluginConfig: ansistring;
    fUseEffects: Boolean;
    fUseFading: Boolean;
    { Private declarations }
    procedure SetCover(value: TBitmap);
    procedure SetSkin(value: TBitmap);
    procedure SetSkinCover(value: TBitmap);
    procedure SetKind(value: TDisplayKind);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Render;
    procedure DataNull;
    procedure PluginUnload;
    procedure PluginLoad(PluginName: string);
    procedure PluginData(const FFTData: TFFTData; MillSec: Cardinal;
      Stereo, Played: Boolean); overload;
    procedure PluginData(WaveData8: TWaveData8; MillSec: Cardinal;
      Stereo, Played: Boolean); overload;
    procedure PluginData(WaveData16: TWaveData16; MillSec: Cardinal;
      Stereo, Played: Boolean); overload;
    procedure PluginData(WaveData32: TWaveData32; MillSec: Cardinal;
      Stereo, Played: Boolean); overload;
    { Public declarations }
    procedure ModuleClick(Button: TMouseButton; Shift: TShiftState; x: integer;
      y: integer);
  published
    { Published declarations }
    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Enabled;

    property OnMouseDown;
    property OnMouseUp;

    property Kind: TDisplayKind read fKind write SetKind default dkSkin;
    property Skin: TBitmap read fSkin write SetSkin;
    property Cover: TBitmap read fCover write SetCover;
    property SkinCover: TBitmap read fSkinCover write SetSkinCover;
    property UseEffects: Boolean read fUseEffects write fUseEffects
      default true;
    property SmoothEnable: Boolean read fUseFading write fUseFading
      default false;
    property PluginConfig: ansistring read fPluginConfig write fPluginConfig;
    property ClickSupport: Boolean read fSupportClick write fSupportClick default true;
    property Clicked: Boolean read fClicked;
    property FFTData: Boolean read fFFTData;
    property WAVEDAta: Boolean read fWAVEData;
    property Effects: Boolean read fEffects;
  end;

procedure Register;

implementation

const
  MCW_EM = DWORD($133F);

  // sonique
  VI_WAVEFORM = $0001;
  VI_SPECTRUM = $0002;
  SONIQUEVISPROC = $0004;

  // ------------------------------------------------------------------------------

procedure ZoomEffect(ABitmap: TBitmap; Scale: DWORD);
var
  BufferHScale, BufferVScale: DWORD;
begin
  if Assigned(ABitmap) then
  begin
    BufferHScale := Scale * ABitmap.Width div 100;
    BufferVScale := Scale * ABitmap.Height div 100;

    ABitmap.Canvas.CopyRect(Rect(0, 0, ABitmap.Width, ABitmap.Height),
      ABitmap.Canvas, Rect(BufferHScale, BufferVScale,
      ABitmap.Width - BufferHScale, ABitmap.Height - BufferVScale));
  end
end;

procedure Darkening(Bmp: TBitmap; Weight: integer);
var
  dstPixel: PRGBQuad;
  x, y: integer;
begin
  if not Assigned(Bmp) then
    Exit;

  for y := 0 to Bmp.Height - 1 do
  begin
    dstPixel := Bmp.ScanLine[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      with dstPixel^ do
      begin
        rgbRed := (Weight) * rgbRed div 100;
        rgbGreen := (Weight) * rgbGreen div 100;
        rgbBlue := (Weight) * rgbBlue div 100;
      end;
      Inc(dstPixel);
    end;
  end;
end;

// ------------------------------------------------------------------------------

function Get8087CW: Word;
asm
  PUSH    0
  FNSTCW  [ESP].Word
  POP     EAX
end;

// ------------------------------------------------------------------------------

function ConvertSamples_32BitTo16(InputSample: Single): Smallint;
var
  SaveValue: integer;
begin
  SaveValue := Trunc(InputSample * 32768);
  if SaveValue > 32768 then
    SaveValue := 32768;
  if SaveValue < -32767 then
    SaveValue := -32767;
  Result := SaveValue;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.Render;
begin
  if (fKind = dkSkin) then
  begin
    if not fSkin.Empty then
      Canvas.Draw(0, 0, fSkin);
  end
  else if fKind = dkVisual then
  begin
    try
      if (fBuffer.Width <> (Width + 1)) or (fBuffer.Height <> (Height + 1)) then
      begin
        if fDrawer.LoadedMemory then
          fDrawer.DetachMemory;

        fBuffer.Width := Width + 1;
        fBuffer.Height := Height + 1;

        if fDrawer.AttachTo(fBuffer.ScanLine[0], Width + 1, Height + 1,
          -(Width + 1)) then
        begin
          if not fSkin.Empty then
            Canvas.Draw(0, 0, fSkin);
          PluginUnload;
          Exit;
        end;
      end;

      if (csDesigning in ComponentState) or (not fLoadPlugin) then
      begin
        if not fSkin.Empty then
          Canvas.Draw(0, 0, fSkin);
      end;

      if fEffects then
      begin
        if (fDrawer.LoadedMemory) then
        begin
          if (fUseEffects) then
          begin
            if (fUseFading) then
            begin
              Darkening(fBuffer, 80);
            end
            else
            begin
              ZoomEffect(fBuffer, 4);
              SplitBlur(fDrawer, 1);
              Darkening(fBuffer, 90);
            end;
          end
          else
            fDrawer.SetAllPixels(0, 0, 0, 255);
        end;
      end;

      if not fLoadPlugin then
        Exit;

      if not SoniqVisInfo^.Render(fBuffer.ScanLine[0], Width + 1, Height + 1,
        -(Width + 1), @SoniqVisData) then
      begin
        asm
          FNCLEX  // Clear exceptions
        end;
        if not fSkin.Empty then
          Canvas.Draw(0, 0, fSkin);
        PluginUnload;
      end;

      Canvas.Draw(0, 0, fBuffer);
    except
      PluginUnload;
    end;
  end
  else if fKind = dkCover then
  begin
    if fCover.Empty then
    begin
      if not fSkinCover.Empty then
        fCover.Assign(fSkinCover);
    end;
    Canvas.StretchDraw(ClientRect, fCover);
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.DataNull;
var
  I: integer;
begin
  if fDrawer.LoadedMemory then
    fDrawer.SetAllPixels(0, 0, 0, 255);
  for I := 0 to 511 do
  begin
    SoniqVisData.WaveForm[0, I] := 0;
    SoniqVisData.WaveForm[1, I] := 0;

    if I <= 255 then
    begin
      SoniqVisData.Spectrum[0, I] := 0;
      SoniqVisData.Spectrum[1, I] := 0;
    end;
  end;
  SoniqVisData.MillSec := 0;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginData(const FFTData: TFFTData; MillSec: Cardinal;
  Stereo, Played: Boolean);
var
  I: integer;
begin
  try
    if fLoadPlugin then
    begin
      if Played then
      begin
        for I := 0 to 255 do
        begin
          if not Stereo then
          begin
            SoniqVisData.Spectrum[0, I] := Min(255, Round(FFTData[I]) * 1024);
            SoniqVisData.Spectrum[1, I] := SoniqVisData.Spectrum[0, I];
          end
          else
          begin
            SoniqVisData.Spectrum[0, I] :=
              Min(255, Round(FFTData[I * 2] * 1024));
            SoniqVisData.Spectrum[1, I] :=
              Min(255, Round(FFTData[I * 2 + 1] * 1024));
          end;
        end;
        SoniqVisData.MillSec := MillSec;

        // SoniqVisData.TimeStamp := 100;
        // SoniqVisData.SongTitle := 'ZuByMPlayer';
        // SoniqVisData.InputSource := 0;

      end
      else
        DataNull;
    end;
  except
    PluginUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginData(WaveData8: TWaveData8; MillSec: Cardinal;
  Stereo, Played: Boolean);
var
  I: integer;
begin
  try
    if fLoadPlugin then
    begin
      if Played then
      begin
        for I := 0 to 511 do
        begin
          if not Stereo then
          begin
            SoniqVisData.WaveForm[0, I] := WaveData8[I] - 128;
            SoniqVisData.WaveForm[1, I] := WaveData8[I] - 128;
          end
          else
          begin
            SoniqVisData.WaveForm[0, I] := WaveData8[I * 2] - 128;
            SoniqVisData.WaveForm[1, I] := WaveData8[I * 2 + 1] - 128;
          end;
        end;
        SoniqVisData.MillSec := MillSec;

        // SoniqVisData.TimeStamp := 100;
        // SoniqVisData.SongTitle := 'ZuByMPlayer';
        // SoniqVisData.InputSource := 0;
      end
      else
        DataNull;
    end;
  except
    PluginUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginData(WaveData16: TWaveData16; MillSec: Cardinal;
  Stereo, Played: Boolean);
var
  I: integer;
  Sample: Smallint;
begin
  try
    if fLoadPlugin then
    begin
      if Played then
      begin
        for I := 0 to 511 do
        begin
          if not Stereo then
          begin
            Sample := MulDiv(128, Smallint(LOWORD(WaveData16[I])), 32768);
            if Sample < Low(ShortInt) then
              Sample := Low(ShortInt)
            else if Sample > High(ShortInt) then
              Sample := High(ShortInt);

            SoniqVisData.WaveForm[0, I] := Sample;
            SoniqVisData.WaveForm[1, I] := SoniqVisData.WaveForm[0, I];
          end
          else
          begin
            Sample := MulDiv(128, Smallint(LOWORD(WaveData16[I])), 32768);
            if Sample < Low(ShortInt) then
              Sample := Low(ShortInt)
            else if Sample > High(ShortInt) then
              Sample := High(ShortInt);
            SoniqVisData.WaveForm[0, I] := Sample;

            Sample := MulDiv(128, Smallint(HIWORD(WaveData16[I])), 32768);
            if Sample < Low(ShortInt) then
              Sample := Low(ShortInt)
            else if Sample > High(ShortInt) then
              Sample := High(ShortInt);

            SoniqVisData.WaveForm[1, I] := Sample;
          end;
        end;
        SoniqVisData.MillSec := MillSec;

        // SoniqVisData.TimeStamp := 100;
        // SoniqVisData.SongTitle := 'ZuByMPlayer';
        // SoniqVisData.InputSource := 0;
      end
      else
        DataNull;
    end;
  except
    PluginUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginData(WaveData32: TWaveData32; MillSec: Cardinal;
  Stereo, Played: Boolean);
var
  I: integer;
  Sample: Smallint;
begin
  try
    if fLoadPlugin then
    begin
      if Played then
      begin
        for I := 0 to 511 do
        begin
          if not Stereo then
          begin
            Sample := MulDiv(128,
              ConvertSamples_32BitTo16(WaveData32[I]), 32768);
            if Sample < Low(ShortInt) then
              Sample := Low(ShortInt)
            else if Sample > High(ShortInt) then
              Sample := High(ShortInt);

            SoniqVisData.WaveForm[0, I] := Sample;
            SoniqVisData.WaveForm[1, I] := SoniqVisData.WaveForm[0, I];
          end
          else
          begin
            Sample := MulDiv(128,
              ConvertSamples_32BitTo16(WaveData32[I * 2]), 32768);
            SoniqVisData.WaveForm[0, I] := Sample;

            Sample := MulDiv(128,
              ConvertSamples_32BitTo16(WaveData32[I * 2 + 1]), 32768);
            SoniqVisData.WaveForm[1, I] := Sample;
          end;
        end;
        SoniqVisData.MillSec := MillSec;

        // SoniqVisData.TimeStamp := 100;
        // SoniqVisData.SongTitle := 'ZuByMPlayer';
        // SoniqVisData.InputSource := 0;
      end
      else
        DataNull;
    end;
  except
    PluginUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginUnload;
begin
  if fDllhandle <> 0 then
  begin
    if Assigned(SoniqVisInfo) then
    begin
      if fPluginConfig <> '' then
        SoniqVisInfo^.SaveSettings(PAnsiChar(fPluginConfig));
      if fClicked then
        SoniqVisInfo^.Deinit;
    end;
    FreeLibrary(fDllhandle);
    SoniqVisInfo := nil;
    Soniq_QueryModule := nil;
    fDllhandle := 0;
    fLoadPlugin := false;
    fClicked := false;
    fEffects := false;
    fWAVEData := false;
    fFFTData := false;

    if fDrawer.LoadedMemory then
      fDrawer.SetAllPixels(0, 0, 0, 255);

    if not (csDestroying in ComponentState) then
    begin
      if not fSkin.Empty then
        Canvas.Draw(0, 0, fSkin);
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.PluginLoad(PluginName: string);
var
  tempDll: Cardinal;
begin
  if not FileExists(PluginName) then
    Exit;

  tempDll := LoadLibrary(PChar(PluginName));
  if (tempDll = 0) then
    Exit;
  FreeLibrary(tempDll);

  PluginUnload;
  fDllhandle := LoadLibrary(PChar(PluginName));
  if (fDllhandle = 0) then
    Exit;

  try
    Soniq_QueryModule := nil;
    @Soniq_QueryModule := GetProcAddress(fDllhandle, 'QueryModule');

    if (@Soniq_QueryModule = nil) then
      @Soniq_QueryModule := GetProcAddress(fDllhandle,
        '?QueryModule@@YAPAUUltraVisInfo@@XZ');

    if (@Soniq_QueryModule <> nil) then
    begin
      SoniqVisInfo := Soniq_QueryModule;
      if Assigned(SoniqVisInfo) then
      begin
        SoniqVisInfo^.Initialize;
        if FileExists(fPluginConfig) then
          SoniqVisInfo^.OpenSettings(PAnsiChar(fPluginConfig));
        fLoadPlugin := true;

        fClicked := (SoniqVisInfo^.Version >= 1);
        fEffects := ((SoniqVisInfo^.lRequired and SONIQUEVISPROC)
          = SONIQUEVISPROC);
        fWAVEData := ((SoniqVisInfo^.lRequired and VI_WAVEFORM) = VI_WAVEFORM);
        fFFTData := ((SoniqVisInfo^.lRequired and VI_SPECTRUM) = VI_SPECTRUM);

        PatBlt(Canvas.Handle, 0, 0, Width, Height, BLACKNESS);

        if fDrawer.LoadedMemory then
          fDrawer.SetAllPixels(0, 0, 0, 255);
      end
      else
        PluginUnload;
    end;
  except
    fLoadPlugin := false;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.SetSkin;
begin
  fSkin.Assign(value);
  Resize;
  Render;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.SetCover;
begin
  fCover.Assign(value);
  Invalidate;
  Resize;
  Render;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.SetSkinCover;
begin
  fSkinCover.Assign(value);
  Resize;
  Render;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.SetKind;
begin
  if fKind <> value then
  begin
    fKind := value;
    Render;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.Resize;
begin
  inherited;
  if not fSkin.Empty then
  begin
    Width := fSkin.Width;
    Height := fSkin.Height;

    if fDrawer.LoadedMemory then
      fDrawer.DetachMemory;

    fBuffer.Width := Width;
    fBuffer.Height := Height;

    fDrawer.AttachTo(fBuffer.ScanLine[0], Width, Height, -Width);
    if fDrawer.LoadedMemory then
      fDrawer.SetAllPixels(0, 0, 0, 255);

    fCover.Width := Width;
    fCover.Height := Height;

    fSkinCover.Width := Width;
    fSkinCover.Height := Height;
  end;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.Loaded;
begin
  inherited;
  DataNull;
  Render;
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.ModuleClick(Button: TMouseButton; Shift: TShiftState;
  x, y: integer);
begin
  if fLoadPlugin and fClicked and fSupportClick then
    SoniqVisInfo^.Clicked(x, y, integer(Button));
end;

// ------------------------------------------------------------------------------

procedure TZMSDisplay.Paint;
begin
  inherited;
  Render;
end;

// ------------------------------------------------------------------------------

constructor TZMSDisplay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Cursor := crHandPoint;
  fSkin := TBitmap.Create;
  fSkinCover := TBitmap.Create;
  fCover := TBitmap.Create;
  fBuffer := TBitmap.Create;
  fBuffer.PixelFormat := pf32bit;

  fDrawer := TacSLCanvas32.Create(fBuffer);
  fDrawer.SetAllPixels(0, 0, 0, 255);

  fDllhandle := 0;
  SoniqVisInfo := nil;
  Soniq_QueryModule := nil;
  fWAVEData := false;
  fFFTData := false;
  fLoadPlugin := false;
  fPluginConfig := '';
  fUseEffects := true;
  fUseFading := false;
  fKind := dkSkin;
  fSupportClick := true;

  Saved8087CW := Get8087CW;
  Set8087CW(MCW_EM);
end;

// ------------------------------------------------------------------------------

destructor TZMSDisplay.Destroy;
begin
  PluginUnload;
  Set8087CW(Saved8087CW);

  if fDrawer.LoadedMemory then
    fDrawer.DetachMemory;
  freeandnil(fDrawer);

  freeandnil(fSkinCover);
  freeandnil(fBuffer);
  freeandnil(fCover);
  freeandnil(fSkin);
  inherited;
end;

// ------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSDisplay]);
end;

end.

