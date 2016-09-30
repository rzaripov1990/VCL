unit SC_RunString;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSRunStr: Компонент бегущая строка       |
  ********************************************* }

interface

uses
  Windows, SysUtils, Messages, Classes, Controls, Graphics, Math, ExtCtrls;

type
  TZMSRunString = class(TGraphicControl)
  private
    fMouseDown: boolean;
    fFading, fNowFading: boolean;
    fDrawCaption: boolean;
    fLoadBitmap: TBitmap;
    fBuffer: TBitmap;
    fPosX, fDownPosX: integer;
    fCounter: integer;

    fTimer: TTimer;
    fCaption: TCaption;
    fCaption2: TCaption;

    procedure SetLoadBmp(Bmp: TBitmap);
    procedure SetCaption(Value: TCaption);
    procedure SetCaption2(Value: TCaption);
    procedure SetFading(Value: boolean);
    procedure SetDraw(Value: boolean);

    procedure Morphing(Bm1, Bm2: TBitmap; progress: integer);
    procedure Rendering(Sender: TObject);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure Resize; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: TCaption read fCaption write SetCaption;
    property Caption2: TCaption read fCaption2 write SetCaption2;
    property Bitmap: TBitmap read fLoadBitmap write SetLoadBmp;
    property SmoothEnable: boolean read fFading write SetFading default true;
    property DrawCaption2: boolean read fDrawCaption write SetDraw
      default false;

    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Font;
    property Color;
    property Enabled;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    { Published declarations }
  end;

procedure Register;

implementation

procedure TZMSRunString.Morphing(Bm1, Bm2: TBitmap; progress: integer);
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
      Inc(rgbRed, (Weight * (srcPixel^.rgbRed - rgbRed)) shr 8);
      Inc(rgbGreen, (Weight * (srcPixel^.rgbGreen - rgbGreen)) shr 8);
      Inc(rgbBlue, (Weight * (srcPixel^.rgbBlue - rgbBlue)) shr 8);
    end;
    Inc(srcPixel);
    Inc(dstPixel);
  end;
end;

procedure TZMSRunString.Rendering;
var
  fAlpha, fAlphaBack: TBitmap;
  px, X, Y: integer;
  ARect: TRect;
begin
  Resize;
  if fLoadBitmap.Empty then
  begin
    fBuffer.Canvas.Brush.Color := Color;
    fBuffer.Canvas.Pen.Color := Color;
    fBuffer.Canvas.FillRect(ClientRect);
  end
  else
    fBuffer.Canvas.Draw(0, 0, fLoadBitmap);

  fBuffer.Canvas.Font := Font;
  Y := (fBuffer.Height - fBuffer.Canvas.TextHeight('Hg')) div 2;

  if not fDrawCaption then
    X := fBuffer.Canvas.TextWidth(fCaption)
  else
    X := fBuffer.Canvas.TextWidth(fCaption2);

  if (X <= fBuffer.Width) then
    fPosX := (fBuffer.Width - X) div 2
  else if (fPosX + X <= fBuffer.Width) then
    fPosX := fBuffer.Width - X
  else if (fPosX >= 0) then
    fPosX := 0;

  SetBkMode(fBuffer.Canvas.Handle, TRANSPARENT);
  if not fDrawCaption then
    fBuffer.Canvas.TextOut(fPosX, Y, fCaption)
  else
    fBuffer.Canvas.TextOut(fPosX, Y, fCaption2);

  if fFading then
  begin
    fAlpha := TBitmap.Create;
    fAlphaBack := TBitmap.Create;
    fAlpha.PixelFormat := pf32bit;
    fAlphaBack.PixelFormat := pf32bit;
    try
      fAlpha.Width := 1;
      fAlpha.Height := fBuffer.Height;
      fAlphaBack.Width := 1;
      fAlphaBack.Height := fBuffer.Height;
      // left ..
      px := 0;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 10); // 1px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 1;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 20); // 2px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 2;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 30); // 3px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 3;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 40); // 4px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 4;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 50); // 5px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 5;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 60); // 6px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 6;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 70); // 7px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 7;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 80); // 8px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := 8;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 90); // 9px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      // .. left

      // right ..
      px := fBuffer.Width - 0;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 10); // 1px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 1;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 20); // 2px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 2;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 30); // 3px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 3;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 40); // 4px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 4;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 50); // 5px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 5;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 60); // 6px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 6;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 70); // 7px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 7;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 80); // 8px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);

      px := fBuffer.Width - 8;
      SetRect(ARect, px, 0, px + 1, fBuffer.Height);
      fAlpha.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fBuffer.Canvas, ARect);
      fAlphaBack.Canvas.CopyRect(Rect(0, 0, 1, fBuffer.Height),
        fLoadBitmap.Canvas, ARect);
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      Morphing(fAlphaBack, fAlpha, 90); // 9px
      fBuffer.Canvas.Draw(px, 0, fAlphaBack);
      // .. right
    finally
      FreeAndNil(fAlpha);
      FreeAndNil(fAlphaBack);
    end;
  end;

  if fNowFading and fTimer.Enabled then
  begin
    fAlpha := TBitmap.Create;
    fAlpha.Width := fBuffer.Width;
    fAlpha.Height := fBuffer.Height;

    dec(fCounter, 5);
    fAlpha.Canvas.Draw(0, 0, fLoadBitmap);
    Morphing(fBuffer, fAlpha, fCounter);
    Canvas.Draw(0, 0, fBuffer);

    FreeAndNil(fAlpha);
    if fCounter <= 0 then
    begin
      fNowFading := false;
      fTimer.Enabled := fNowFading;
    end;
  end
  else
    Canvas.Draw(0, 0, fBuffer);
end;

procedure TZMSRunString.Paint;
begin
  inherited;
  if not fTimer.Enabled then
    Rendering(nil);
end;

procedure TZMSRunString.Resize;
begin
  if not fLoadBitmap.Empty then
  begin
    Width := fLoadBitmap.Width;
    Height := fLoadBitmap.Height;
  end
  else
    inherited;

  fBuffer.Width := Width;
  fBuffer.Height := Height;
end;

procedure TZMSRunString.MouseDown;
begin
  if (Button = mbLeft) then
  begin
    fDownPosX := X - fPosX;
    fMouseDown := true;
    Rendering(nil);
  end;
  inherited;
end;

procedure TZMSRunString.MouseMove;
var
  O: integer;
begin
  if (fMouseDown) then
  begin
    O := fDownPosX + Width - X;
    fPosX := Width - O;
    Rendering(nil);
  end;
  inherited;
end;

procedure TZMSRunString.MouseUp;
begin
  fMouseDown := false;
  inherited;
  Rendering(nil);
end;

procedure TZMSRunString.SetLoadBmp(Bmp: TBitmap);
begin
  fLoadBitmap.Assign(Bmp);
  Rendering(nil);
end;

procedure TZMSRunString.SetCaption(Value: TCaption);
begin
  if fCaption <> Value then
  begin
    fCaption := Value;
    fCounter := 100;
    fNowFading := true;
    fTimer.Enabled := fNowFading and fFading;
    Rendering(nil);
  end;
end;

procedure TZMSRunString.SetCaption2(Value: TCaption);
begin
  if fCaption2 <> Value then
  begin
    fCaption2 := Value;
    Rendering(nil);
  end;
end;

procedure TZMSRunString.SetDraw(Value: boolean);
begin
  if fDrawCaption <> Value then
  begin
    fDrawCaption := Value;
    fCaption2 := '';
    Rendering(nil);
  end;
end;

procedure TZMSRunString.SetFading(Value: boolean);
begin
  if fFading <> Value then
  begin
    fFading := Value;
    Rendering(nil);
  end;
end;

constructor TZMSRunString.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fLoadBitmap := TBitmap.Create;
  fBuffer := TBitmap.Create;

  ControlStyle := ControlStyle + [csOpaque];
  // ParentColor := false;
  // Color := clBlack;
  Cursor := crHandPoint;

  fCounter := 100;
  fTimer := TTimer.Create(nil);
  fTimer.Interval := 50;
  fTimer.Enabled := false;
  fTimer.OnTimer := Rendering;

  fFading := true;
  fMouseDown := false;
  fNowFading := false;
  fDrawCaption := false;

  fCaption := '';
  fCaption2 := '';
  fPosX := 0;
end;

destructor TZMSRunString.Destroy;
begin
  FreeAndNil(fLoadBitmap);
  FreeAndNil(fBuffer);
  FreeAndNil(fTimer);
  inherited;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSRunString]);
end;

end.
