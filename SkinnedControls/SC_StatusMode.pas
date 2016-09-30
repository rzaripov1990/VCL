unit SC_StatusMode;

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
  Windows, SysUtils, Messages, Classes, Controls, Graphics, ExtCtrls;

type
  TStatusKind = (skStopped, skPaused, skPlayed);
  TOnStatus = procedure(Sender: TObject; const Mode: TStatusKind) of object;

  TZMSStatusMode = class(TGraphicControl)
  private
    fSkin: TBitmap;

    fPlay: TBitmap;
    fPause: TBitmap;
    fStop: TBitmap;

    fSize: integer;
    fDoFading: boolean;
    fFading: boolean;
    fCounter: integer;
    fMode: TStatusKind;
    fOnStatus: TOnStatus;
    fTimer: TTimer;

    procedure SetStatus(Mode: TStatusKind);
    procedure SetSkin(Value: TBitmap);
    procedure TimerProc(Sender: TObject);

    procedure SplitBitmap;
    procedure Morphing(Bm1, Bm2: TBitmap; progress: integer);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Status: TStatusKind read fMode write SetStatus default skStopped;
    property Bitmap: TBitmap read fSkin write SetSkin;
    property SmoothEnable: boolean read fFading write fFading default true;
    property OnStatus: TOnStatus read fOnStatus write fOnStatus;

    property Color;
    property Anchors;
    property Cursor default crHandPoint;
    property ParentShowHint;
    property Visible;
    property PopupMenu;
    property Hint;
    property ShowHint;
    property Enabled;

    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    { Published declarations }
  end;

procedure Register;

implementation

const
  DynamCnt = 2;

  // ------------------------------------------------------------------------------
procedure TZMSStatusMode.TimerProc;
var
  DynamBmp: TBitmap;
begin
  case fMode of
    skStopped:
      begin
        if (fFading and fDoFading) then
        begin
          DynamBmp := TBitmap.Create;
          DynamBmp.Width := fSize;
          DynamBmp.Height := fSkin.Height;
          BitBlt(DynamBmp.Canvas.Handle, 0, 0, fSize, fSkin.Height,
            Canvas.Handle, 0, 0, SRCCOPY);

          inc(fCounter, DynamCnt);
          Morphing(DynamBmp, fStop, fCounter);
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height,
            DynamBmp.Canvas.Handle, 0, 0, SRCCOPY);
          FreeAndNil(DynamBmp);
        end
        else
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height, fStop.Canvas.Handle,
            0, 0, SRCCOPY);
      end;

    skPaused:
      begin
        if (fFading and fDoFading) then
        begin
          DynamBmp := TBitmap.Create;
          DynamBmp.Width := fSize;
          DynamBmp.Height := fSkin.Height;
          BitBlt(DynamBmp.Canvas.Handle, 0, 0, fSize, fSkin.Height,
            Canvas.Handle, 0, 0, SRCCOPY);

          inc(fCounter, DynamCnt);
          Morphing(DynamBmp, fPause, fCounter);
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height,
            DynamBmp.Canvas.Handle, 0, 0, SRCCOPY);
          FreeAndNil(DynamBmp);
        end
        else
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height, fPause.Canvas.Handle,
            0, 0, SRCCOPY);
      end;

    skPlayed:
      begin
        if (fFading and fDoFading) then
        begin
          DynamBmp := TBitmap.Create;
          DynamBmp.Width := fSize;
          DynamBmp.Height := fSkin.Height;
          BitBlt(DynamBmp.Canvas.Handle, 0, 0, fSize, fSkin.Height,
            Canvas.Handle, 0, 0, SRCCOPY);

          inc(fCounter, DynamCnt);
          Morphing(DynamBmp, fPlay, fCounter);
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height,
            DynamBmp.Canvas.Handle, 0, 0, SRCCOPY);
          FreeAndNil(DynamBmp);
        end
        else
          BitBlt(Canvas.Handle, 0, 0, fSize, fSkin.Height, fPlay.Canvas.Handle,
            0, 0, SRCCOPY);
      end;
  end;
  if fCounter > 100 then
  begin
    fDoFading := false;
    fTimer.Enabled := fDoFading;
    fCounter := 0;
  end;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.Paint;
begin
  inherited;
  // SplitBitmap;
  if (fSkin.Empty) then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Style := psDashDot;
    Canvas.Rectangle(ClientRect);
  end
  else
  begin
    if not fTimer.Enabled then
      TimerProc(nil);
  end;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.Loaded;
begin
  inherited;
  SplitBitmap;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.Resize;
begin
  if not(fSkin.Empty) then
  begin
    fSize := fSkin.Width div 3;
    Width := fSize;
    Height := fSkin.Height;
  end
  else
    inherited;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.SplitBitmap;
var
  tRct: TRect;
  tBit: TBitmap;
begin
  Resize;
  if ((fSkin.Width mod 3) <> 0) then
    exit;
  fSize := fSkin.Width div 3;

  fPlay.Width := fSize; // ширина
  fPause.Width := fSize; // картинки
  fStop.Width := fSize; // равна ширине

  fPlay.Height := fSkin.Height; // чтобы красиво
  fPause.Height := fSkin.Height; // смотрелись картинки,
  fStop.Height := fSkin.Height; // нужно установить

  tBit := TBitmap.Create; // создание
  tBit.Height := fSkin.Height; // принятие
  tBit.Width := fSkin.Width; // Width Height

  try
    (* Stop *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, 0, 0, fSize, fSkin.Height);
    fStop.Canvas.CopyRect(ClientRect, tBit.Canvas, tRct);
    (* Stop end *)

    (* Play *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, fSize, 0, fSize + fSize, fSkin.Height);
    fPlay.Canvas.CopyRect(Rect(0, 0, fSize, fSkin.Height), tBit.Canvas, tRct);
    (* Play end *)

    (* Pause *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, fSize + fSize, 0, fSize + fSize + fSize, fSkin.Height);
    fPause.Canvas.CopyRect(ClientRect, tBit.Canvas, tRct);
    (* Pause end *)
  finally
    FreeAndNil(tBit); // освобождаем
  end;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.SetSkin(Value: TBitmap);
begin
  fSkin.Assign(Value);
  SplitBitmap;
  Invalidate;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.SetStatus(Mode: TStatusKind);
begin
  if fMode <> Mode then
  begin
    fMode := Mode;
    if Assigned(fOnStatus) then
      fOnStatus(self, Mode);

    fCounter := 0;
    fDoFading := true;
    fTimer.Enabled := fDoFading and fFading;
    SplitBitmap;
    Paint;
  end;
end;

// ------------------------------------------------------------------------------
constructor TZMSStatusMode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  fSkin := TBitmap.Create;
  fStop := TBitmap.Create;
  fPlay := TBitmap.Create;
  fPause := TBitmap.Create;

  fTimer := TTimer.Create(nil);
  fTimer.Interval := 25;
  fTimer.Enabled := false;
  fTimer.OnTimer := TimerProc;

  ControlStyle := ControlStyle + [csOpaque];
  fFading := true;
  fDoFading := false;
  fCounter := 0;

  Height := 15;
  Width := 15;

  fMode := skStopped;
end;

// ------------------------------------------------------------------------------
destructor TZMSStatusMode.Destroy;
begin
  FreeAndNil(fSkin);
  FreeAndNil(fPlay);
  FreeAndNil(fPause);
  FreeAndNil(fStop);
  FreeAndNil(fTimer);

  inherited;
end;

// ------------------------------------------------------------------------------
procedure TZMSStatusMode.Morphing(Bm1, Bm2: TBitmap; progress: integer);
var
  dstPixel, srcPixel: PRGBQuad;
  Weight, I: integer;
begin
  if Bm1.PixelFormat <> pf32bit then
    Bm1.PixelFormat := pf32bit;
  if Bm2.PixelFormat <> pf32bit then
    Bm2.PixelFormat := pf32bit;

  srcPixel := Bm2.ScanLine[Bm2.Height - 1];
  dstPixel := Bm1.ScanLine[Bm1.Height - 1];
  Weight := MulDiv(256, progress, 100);
  for I := (Bm1.Width * Bm1.Height) - 1 downto 0 do
  begin
    with dstPixel^ do
    begin
      inc(rgbRed, (Weight * (srcPixel^.rgbRed - rgbRed)) shr 8);
      inc(rgbGreen, (Weight * (srcPixel^.rgbGreen - rgbGreen)) shr 8);
      inc(rgbBlue, (Weight * (srcPixel^.rgbBlue - rgbBlue)) shr 8);
    end;
    inc(srcPixel);
    inc(dstPixel);
  end;
end;

// ------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSStatusMode]);
end;

end.
