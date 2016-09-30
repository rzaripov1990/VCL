unit QBVis;

{ *********************************************
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby90@mail.ru            |
  |            mail: support@zubymplayer.com   |
  |            web : http://zubymplayer.com    |
  |            Kazakhstan, Semey, 2010         |
  ********************************************* }

interface

uses
  WinApi.Windows, System.SysUtils, Vcl.Graphics, Types, QBCommon, SLCanvas32,
  Bass;

const
  // sonique visual 2.0
  QBASS_VIS_NO_EFFECTS = 0;
  QBASS_VIS_ALL_EFFECTS = 1;
  QBASS_VIS_FADING_ONLY = 2;

  // Sonique Visualization support
procedure QBass_VisUnload;
function QBass_VisLoad(PluginName: PChar): bool;
procedure QBass_VisResize(aWidth, aHeight: integer);
procedure QBass_VisRender(const Channel: DWORD; DC: Cardinal);
function QBass_VisActive: bool;
procedure QBass_VisPluginsLoad(Path: PChar; var FileNames, Titles: QBArrString);
procedure QBass_VisSetOptions(const Flag: Cardinal);
function QBass_VisGetOptions: Cardinal;
function QBass_VisClicked(const x, y, button: integer): bool;
procedure QBass_VisConfigFile(FileName: AnsiString);

var
  VisBuffer: TBitmap;
  Drawer: TacSLCanvas32;

implementation

const
  // sonique
  VI_WAVEFORM = $0001;
  VI_SPECTRUM = $0002;
  SONIQUEVISPROC = $0004;

type
  TWaveData8 = array [0 .. 1023] of Byte; // Wave 8 bit
  TWaveData16 = array [0 .. 1023] of Cardinal; // Wave 16 bit
  TWaveData32 = array [0 .. 2047] of Single; // Wave 32 bit
  TFFTData = array [0 .. 1023] of Single; // FFT 32 bit

  // =========== SONIQUE =============

  TWaveDataMatrix = array [0 .. 1, 0 .. 512 - 1] of ShortInt;
  TSpectrumMatrix = array [0 .. 1, 0 .. 256 - 1] of Byte;
  PVisData = ^TVisData;

  TVisData = record
    MillSec: Cardinal;
    WaveForm: TWaveDataMatrix;
    Spectrum: TSpectrumMatrix;
  end;

  PVisInfo = ^TVisInfo;

  TVisInfo = record
    Version: Cardinal;
    PluginName: PAnsiChar;
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

var
  LoadPlugin: Boolean = false;
  DllHandle: Cardinal = Cardinal(-1);

  Clicked: Boolean = false;
  Effects: Boolean = false;
  WAVEData: Boolean = false;
  FFTData: Boolean = false;

  UseEffects: Boolean = false;
  UseFading: Boolean = false;

  PluginConfig: PAnsiChar = nil;

  SoniqVisInfo: PVisInfo;
  SoniqVisData: TVisData;
  Soniq_QueryModule: function: PVisInfo; stdcall;

  // ------------------------------------------------------------------------------

function Min(const A, B: integer): integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: integer): integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

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

procedure QBass_VisUnload;
begin
  if DllHandle <> 0 then
  begin
    if Assigned(SoniqVisInfo) then
    begin
      if PluginConfig <> nil then
        SoniqVisInfo^.SaveSettings(PAnsiChar(PluginConfig));
      if Clicked then
        SoniqVisInfo^.Deinit;
    end;
    FreeLibrary(DllHandle);
    SoniqVisInfo := nil;
    Soniq_QueryModule := nil;
    DllHandle := 0;
    LoadPlugin := false;
    Clicked := false;
    Effects := false;
    WAVEData := false;
    FFTData := false;
  end;
end;

// ------------------------------------------------------------------------------

procedure DataNull;
var
  I: integer;
begin
  if Drawer.LoadedMemory then
    Drawer.SetAllPixels(0, 0, 0, 255);
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
  // SoniqVisData.TimeStamp := 0;
  // SoniqVisData.SongTitle := '';
  // SoniqVisData.InputSource := 0;
end;

// ------------------------------------------------------------------------------

function QBass_VisLoad(PluginName: PChar): bool;
var
  tempDll: Cardinal;
begin
  Result := false;
  LoadPlugin := false;

  if not InitDLL then
    Exit;

  if not FileExists(PluginName) then
    Exit;

  tempDll := LoadLibrary(PluginName);
  if (tempDll = 0) then
    Exit;
  FreeLibrary(tempDll);

  QBass_VisUnload;
  DllHandle := LoadLibrary(PluginName);
  if (DllHandle = 0) then
    Exit;

  try
    Soniq_QueryModule := nil;
    @Soniq_QueryModule := GetProcAddress(DllHandle, 'QueryModule');

    if (@Soniq_QueryModule = nil) then
      @Soniq_QueryModule := GetProcAddress(DllHandle,
        '?QueryModule@@YAPAUUltraVisInfo@@XZ');

    if (@Soniq_QueryModule <> nil) then
    begin
      SoniqVisInfo := Soniq_QueryModule;
      if Assigned(SoniqVisInfo) then
      begin
        SoniqVisInfo^.Initialize;
        if FileExists(PluginConfig) then
          SoniqVisInfo^.OpenSettings(PluginConfig);

        Clicked := (SoniqVisInfo^.Version >= 1);
        Effects := ((SoniqVisInfo^.lRequired and SONIQUEVISPROC)
          = SONIQUEVISPROC);
        WAVEData := ((SoniqVisInfo^.lRequired and VI_WAVEFORM) = VI_WAVEFORM);
        FFTData := ((SoniqVisInfo^.lRequired and VI_SPECTRUM) = VI_SPECTRUM);

        LoadPlugin := true;
        Result := true;
      end
      else
        QBass_VisUnload;
    end;
  except
    QBass_VisUnload;
    Result := false;
  end;
end;

// ------------------------------------------------------------------------------

procedure VisWave8(WaveData8: TWaveData8; Stereo: Boolean);
var
  I: integer;
begin
  if not InitDLL then
    Exit;
  try
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
  except
    QBass_VisUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure VisWave16(WaveData16: TWaveData16; Stereo: Boolean);
var
  I: integer;
  Sample: Smallint;
begin
  if not InitDLL then
    Exit;
  try
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
  except
    QBass_VisUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure VisWave32(WaveData32: TWaveData32; Stereo: Boolean);
var
  I: integer;
  Sample: Smallint;
begin
  if not InitDLL then
    Exit;
  try
    for I := 0 to 511 do
    begin
      if not Stereo then
      begin
        Sample := MulDiv(128, ConvertSamples_32BitTo16(WaveData32[I]), 32768);
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
  except
    QBass_VisUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure VisFFT(FFTData: TFFTData; Stereo: Boolean);
var
  I: integer;
begin
  if not InitDLL then
    Exit;
  try
    for I := 0 to 255 do
    begin
      if not Stereo then
      begin
        SoniqVisData.Spectrum[0, I] := Min(255, Trunc(FFTData[I]) * 1024);
        SoniqVisData.Spectrum[1, I] := SoniqVisData.Spectrum[0, I];
      end
      else
      begin
        SoniqVisData.Spectrum[0, I] := Min(255, Trunc(FFTData[I * 2] * 1024));
        SoniqVisData.Spectrum[1, I] :=
          Min(255, Trunc(FFTData[I * 2 + 1] * 1024));
      end;
    end;
  except
    QBass_VisUnload;
  end;
end;

// ------------------------------------------------------------------------------

procedure QBass_VisResize(aWidth, aHeight: integer);
begin
  if not InitDLL then
    Exit;

  if (Drawer.Width <> aWidth) or (Drawer.Height <> aHeight) then
  begin
    VisBuffer.Width := aWidth;
    VisBuffer.Height := aHeight;

    if not Drawer.AttachTo(VisBuffer.ScanLine[0], aWidth, aHeight, -aWidth) then
      QBass_VisUnload
    else
      Drawer.SetAllPixels(0, 0, 0, 255);
  end;
end;

// ------------------------------------------------------------------------------

procedure QBass_VisRender(const Channel: DWORD; DC: Cardinal);
var
  w8: TWaveData8;
  w16: TWaveData16;
  w32: TWaveData32;
  fft: TFFTData;
  chan: BASS_CHANNELINFO;

const
  GetDataWave: array [Boolean] of DWORD = (2048, 4096);
  GetDataFFT: array [Boolean] of DWORD = (BASS_DATA_FFT2048 or
    BASS_DATA_FFT_INDIVIDUAL, BASS_DATA_FFT2048);

begin
  try
    if not InitDLL then
      Exit;

    if LoadPlugin then
    begin
      if (Channel > 0) then
      begin
        FillChar(chan, sizeof(BASS_CHANNELINFO), 0);
        BASS_ChannelGetInfo(Channel, chan);

        if BASS_ChannelGetData(Channel, @fft, GetDataFFT[chan.chans >= 2]) > 0
        then
          VisFFT(fft, chan.chans >= 2)
        else
          DataNull;

        if ((chan.flags and BASS_SAMPLE_FLOAT) = BASS_SAMPLE_FLOAT) then
        begin
          if BASS_ChannelGetData(Channel, @w32, GetDataWave[chan.chans >= 2]) > 0
          then
            VisWave32(w32, chan.chans >= 2)
          else
            DataNull;
        end
        else if ((chan.flags and BASS_SAMPLE_8BITS) = BASS_SAMPLE_8BITS) then
        begin
          if BASS_ChannelGetData(Channel, @w8, GetDataWave[chan.chans >= 2]) > 0
          then
            VisWave8(w8, chan.chans >= 2)
          else
            DataNull;
        end
        else
        begin
          if BASS_ChannelGetData(Channel, @w16, GetDataWave[chan.chans >= 2]) > 0
          then
            VisWave16(w16, chan.chans >= 2)
          else
            DataNull;
        end;
      end
      else
        DataNull;
    end
    else
      DataNull;

    if Effects then
    begin
      if (Drawer.LoadedMemory) then
      begin
        if (UseEffects) then
        begin
          if (UseFading) then
            Darkening(VisBuffer, 80)
          else
          begin
            ZoomEffect(VisBuffer, 4);
            SplitBlur(Drawer, 1);
            Darkening(VisBuffer, 90);
          end;
        end
        else
          Drawer.SetAllPixels(0, 0, 0, 255);
      end;
    end;

    // SoniqVisData.TimeStamp := BASS_ChannelSeconds2Bytes(Channel, BASS_ChannelGetPosition(Channel, BASS_POS_BYTE)) * 1000;
    // SoniqVisData.SongTitle := 'qbass add-on';
    // SoniqVisData.InputSource := 0;
    SoniqVisData.MillSec := BASS_ChannelSeconds2Bytes(Channel,
      BASS_ChannelGetPosition(Channel, BASS_POS_BYTE)) * 1000;

    if not SoniqVisInfo^.Render(VisBuffer.ScanLine[0], VisBuffer.Width,
      VisBuffer.Height, -VisBuffer.Width, @SoniqVisData) then
    begin
      QBass_VisUnload;
      asm
        FNCLEX  // Clear exceptions
      end;
    end
    else
      BitBlt(DC, 0, 0, VisBuffer.Width, VisBuffer.Height,
        VisBuffer.Canvas.Handle, 0, 0, SRCCOPY);

  except
    QBass_VisUnload;
  end;
end;

// ------------------------------------------------------------------------------

function QBass_VisActive: bool;
begin
  Result := false;
  if not InitDLL then
    Exit;
  Result := LoadPlugin;
end;

// ------------------------------------------------------------------------------

procedure QBass_VisPluginsLoad(Path: PChar; var FileNames, Titles: QBArrString);
var
  SearchRec: TSearchRec;
  Count: Cardinal;

  procedure TempVisLoadPlugin(FileName: PChar);
  var
    dll: THandle;
    tempVisInfo: PVisInfo;
    temp_QueryModule: function: PVisInfo;
  begin
    tempVisInfo := nil;
    temp_QueryModule := nil;
    dll := LoadLibrary(FileName);
    if (dll = 0) then
      Exit;

    @temp_QueryModule := GetProcAddress(dll, 'QueryModule');

    if (@temp_QueryModule = nil) then
      @temp_QueryModule := GetProcAddress(dll,
        '?QueryModule@@YAPAUUltraVisInfo@@XZ');

    if (@temp_QueryModule <> nil) then
    begin
      tempVisInfo := temp_QueryModule;
      if Assigned(tempVisInfo) then
      begin
        SetLength(FileNames, Count + 1);
        SetLength(Titles, Count + 1);

        FileNames[Count] := FileName;
        Titles[Count] := StringReplace(tempVisInfo^.PluginName, '&', '',
          [rfReplaceAll]);
        Inc(Count);

        tempVisInfo := nil;
        temp_QueryModule := nil;
      end;
    end;
    FreeLibrary(dll);
  end;

begin
  if not InitDLL then
    Exit;

  if Path[length(Path)] <> '\' then
    Path := PChar(Path + '\');
  Count := 0;
  if FindFirst(Path + '*.svp', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory) <> faDirectory then
        TempVisLoadPlugin(PChar(Path + SearchRec.Name));
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

// ------------------------------------------------------------------------------

procedure QBass_VisSetOptions(const Flag: Cardinal);
begin
  case Flag of
    QBASS_VIS_NO_EFFECTS:
      begin
        UseEffects := false;
        UseFading := false;
      end;

    QBASS_VIS_ALL_EFFECTS:
      begin
        UseEffects := true;
        UseFading := false;
      end;

    QBASS_VIS_FADING_ONLY:
      begin
        UseEffects := true;
        UseFading := true;
      end;
  end;
end;

// ------------------------------------------------------------------------------

function QBass_VisGetOptions: Cardinal;
begin
  Result := 0;
  if (not UseEffects) and (not UseFading) then
    Result := QBASS_VIS_NO_EFFECTS
  else if (UseEffects) and (not UseFading) then
    Result := QBASS_VIS_ALL_EFFECTS
  else if (UseEffects and UseFading) then
    Result := QBASS_VIS_FADING_ONLY;
end;

// ------------------------------------------------------------------------------

function QBass_VisClicked(const x, y, button: integer): bool;
begin
  Result := false;
  if not InitDLL then
    Exit;

  if LoadPlugin then
  begin
    if SoniqVisInfo^.Version >= 1 then
      Result := SoniqVisInfo^.Clicked(x, y, button);
  end;
end;

// ------------------------------------------------------------------------------

procedure QBass_VisConfigFile(FileName: AnsiString);
begin
  if not InitDLL then
    Exit;

  PluginConfig := PAnsiChar(FileName);
end;

// ------------------------------------------------------------------------------

end.
