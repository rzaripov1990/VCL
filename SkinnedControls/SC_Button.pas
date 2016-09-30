unit SC_Button;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby90@mail.ru            |
  |            mail: support@zubymplayer.com   |
  |            web : http://zubymplayer.com    |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSButton:  омпонент с расширенными       |
  |             свойствами кнопки              |
  ********************************************* }

interface

uses
  Windows, SysUtils, Messages, Classes, Controls,
  Graphics, Types, ExtCtrls;

type
  TMoveState = (msNone, msEnter, msLeave);
  TMouseFocus = (mfDown, mfLeave, mfEnter);
  TPopupEventXY = procedure(Sender: TObject; const X, Y: integer) of object;

  TZMSButton = class(TCustomControl)
  private
    fSkin: TBitmap;
    fBuffer: TBitmap;

    fMouseEnter: TBitmap;
    fMouseExit: TBitmap;
    fMouseDown: TBitmap;

    fPopup: TPopupEventXY;
    fSize: integer;
    fMode: TMouseFocus;
    fMouseClick: boolean;
    fMouseInClient: boolean;

    fInterval: integer;
    fMovePos: TMoveState;
    fMorphEnable: boolean;

    fTimer: TTimer;
    fMorphPos: integer;

    fTransparent: boolean;
    fTransparentColor: TColor;

    procedure SetMorph(Active: boolean);
    procedure SetLoadBmp(Value: TBitmap);
    procedure SetInterval(Value: integer);
    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(Value: TColor);

    procedure DrawBitmap(cnv: TCanvas; bmp: TBitmap);
    procedure OnDrawExit(Sender: TObject);
    procedure Morphing(Bm1, Bm2: TBitmap);
    procedure UpdatePicture;
    procedure SplitBitmap;
    procedure Render;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseExit(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure Click; override;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Protected declarations }
  published
    property Bitmap: TBitmap read fSkin write SetLoadBmp;
    property Interval: integer read fInterval write SetInterval default 50;
    property SmoothEnable: boolean read fMorphEnable write SetMorph
      default true;
    property Transparent: boolean read fTransparent write SetTransparent
      default false;
    property TransparentColor: TColor read fTransparentColor
      write SetTransparentColor default clFuchsia;
    property OnPopupXY: TPopupEventXY read fPopup write fPopup;

    property Hint;
    property Color;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Align;
    property Enabled;

    property OnClick;
    property OnDblClick;
    // property OnMouseEnter;
    // property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    { Published declarations }
  end;

procedure Register;

implementation

// ******************************************************************************
procedure TZMSButton.DrawBitmap(cnv: TCanvas; bmp: TBitmap);
var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  try
    bmpAND := TBitmap.Create;
    bmpAND.Width := bmp.Width;
    bmpAND.Height := bmp.Height;
    bmpAND.Monochrome := true;
    oldcol := SetBkColor(bmp.Canvas.Handle, ColorToRGB(fTransparentColor));
    BitBlt(bmpAND.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    SetBkColor(bmp.Canvas.Handle, oldcol);

    bmpINVAND := TBitmap.Create;
    bmpINVAND.Width := bmp.Width;
    bmpINVAND.Height := bmp.Height;
    bmpINVAND.Monochrome := true;
    BitBlt(bmpINVAND.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, NOTSRCCOPY);

    bmpXOR := TBitmap.Create;
    bmpXOR.Width := bmp.Width;
    bmpXOR.Height := bmp.Height;
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpINVAND.Canvas.Handle, 0, 0, SRCAND);

    bmpTarget := TBitmap.Create;
    bmpTarget.Width := bmp.Width;
    bmpTarget.Height := bmp.Height;
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, cnv.Handle, 0,
      0, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    BitBlt(cnv.Handle, 0, 0, bmp.Width, bmp.Height, bmpTarget.Canvas.Handle, 0,
      0, SRCCOPY);
  finally
    freeAndNil(bmpAND);
    freeAndNil(bmpINVAND);
    freeAndNil(bmpXOR);
    freeAndNil(bmpTarget);
  end;
end;

// ******************************************************************************
procedure TZMSButton.Render;
var
  Buff: TBitmap;
begin
  case fMovePos of

    msNone: // mousedown, mouseup
      begin
        if (fMode = mfDown) then // down
        begin
          Buff := TBitmap.Create;
          Buff.Width := fSize;
          Buff.Height := Height;
          Buff.Canvas.Draw(0, 0, fMouseDown);
          fBuffer.Canvas.Draw(0, 0, Buff);
          freeAndNil(Buff);

          if fTransparent then
            DrawBitmap(Canvas, fBuffer)
          else
            Canvas.Draw(0, 0, fBuffer);
        end
        else if (fMode = mfLeave) then // up
        begin
          if fMouseInClient then
          begin
            Buff := TBitmap.Create;
            Buff.Width := fSize;
            Buff.Height := Height;
            Buff.Canvas.Draw(0, 0, fMouseEnter);
            fBuffer.Canvas.Draw(0, 0, Buff);
            freeAndNil(Buff);

            if fTransparent then
              DrawBitmap(Canvas, fBuffer)
            else
              Canvas.Draw(0, 0, fBuffer);
          end
          else
          begin
            Buff := TBitmap.Create;
            Buff.Width := fSize;
            Buff.Height := Height;
            Buff.Canvas.Draw(0, 0, fMouseExit);
            fBuffer.Canvas.Draw(0, 0, Buff);
            freeAndNil(Buff);

            if fTransparent then
              DrawBitmap(Canvas, fBuffer)
            else
              Canvas.Draw(0, 0, fBuffer);
          end;
        end;
      end;

    msEnter: // mouseenter
      begin
        if fMorphEnable then
          fTimer.Enabled := true
        else
        begin
          Buff := TBitmap.Create;
          Buff.Width := fSize;
          Buff.Height := Height;
          Buff.Canvas.Draw(0, 0, fMouseEnter);
          fBuffer.Canvas.Draw(0, 0, Buff);
          freeAndNil(Buff);

          if fTransparent then
            DrawBitmap(Canvas, fBuffer)
          else
            Canvas.Draw(0, 0, fBuffer);
        end;
      end;

    msLeave: // mouseleave
      begin
        if fMorphEnable then
          fTimer.Enabled := true
        else
        begin
          Buff := TBitmap.Create;
          Buff.Width := fSize;
          Buff.Height := Height;
          Buff.Canvas.Draw(0, 0, fMouseExit);
          fBuffer.Canvas.Draw(0, 0, Buff);
          freeAndNil(Buff);

          if fTransparent then
            DrawBitmap(Canvas, fBuffer)
          else
            Canvas.Draw(0, 0, fBuffer);
        end;
      end;
  end;
end;

// ******************************************************************************
procedure TZMSButton.Click;
begin
  inherited;
  if Assigned(fPopup) then
    fPopup(Self, Mouse.CursorPos.X, Mouse.CursorPos.Y);

  fMouseInClient := false;
  fMovePos := msNone;
  Render;
end;

// ******************************************************************************
procedure TZMSButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  if (csDesigning in componentstate) then
    exit;
  if (fSkin.Empty) or (Button <> mbLeft) then
    exit;

  fMode := mfDown;
  fMovePos := msNone;
  fMouseClick := true;
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  if (csDesigning in componentstate) then
    exit;
  if (fSkin.Empty) then
    exit;

  fMode := mfLeave;
  fMovePos := msNone;
  fMouseClick := false;
  fMouseInClient := PtInRect(ClientRect, Point(X, Y));
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSButton.MouseEnter(var Message: TMessage);
begin
  if (csDesigning in componentstate) then
    exit;
  if fSkin.Empty then
    exit;
  if fMouseClick then
    exit;

  fMode := mfEnter;
  fMovePos := msEnter;
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSButton.MouseExit(var Message: TMessage);
begin
  if (csDesigning in componentstate) then
    exit;
  if fSkin.Empty then
    exit;
  if fMouseClick then
    exit;

  fMode := mfLeave;
  fMovePos := msLeave;
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSButton.SetTransparent(Value: boolean);
begin
  if fTransparent <> Value then
  begin
    ParentBackground := Value;
    fTransparent := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSButton.SetTransparentColor(Value: TColor);
begin
  if fTransparentColor <> Value then
  begin
    fTransparentColor := Value;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSButton.OnDrawExit(Sender: TObject);
var
  Buff: TBitmap;
begin
  if (csDesigning in componentstate) then
    exit;
  if (csDestroying in componentstate) then
  begin
    fTimer.Enabled := false;
    exit;
  end;

  if fMovePos = msNone then
    exit;
  if (fMovePos = msEnter) then
  begin
    fMorphPos := 100;
    if fMode = mfEnter then
    begin
      Buff := TBitmap.Create;
      Buff.Width := fSize;
      Buff.Height := Height;
      Buff.Canvas.Draw(0, 0, fMouseEnter);
      fBuffer.Canvas.Draw(0, 0, Buff);
      freeAndNil(Buff);

      if fTransparent then
        DrawBitmap(Canvas, fBuffer)
      else
        Canvas.Draw(0, 0, fBuffer);
    end;
  end
  else if (fMovePos = msLeave) then
  begin
    if (fMorphPos >= 0) then
    begin
      Dec(fMorphPos, 10);
      if (fMorphPos <= 0) then
      begin
        fMovePos := msNone;
        fMorphPos := 0;
      end;

      Buff := TBitmap.Create;
      Buff.Width := fSize;
      Buff.Height := Height;
      Buff.Canvas.Draw(0, 0, fMouseExit);
      Morphing(Buff, fMouseEnter);
      fBuffer.Canvas.Draw(0, 0, Buff);
      freeAndNil(Buff);

      if fTransparent then
        DrawBitmap(Canvas, fBuffer)
      else
        Canvas.Draw(0, 0, fBuffer);
    end
    else
    begin
      fMovePos := msNone;
      Render; // !!!!!!!!!!
    end;
  end;
  if fMorphPos = 0 then
    fTimer.Enabled := false;
end;

// ******************************************************************************
procedure TZMSButton.Paint;
begin
  inherited;

  if (fSkin.Empty) then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Style := psDashDot;
    Canvas.Rectangle(ClientRect);
  end
  else
    Render;
end;

// ******************************************************************************
procedure TZMSButton.Loaded;
begin
  inherited;
  UpdatePicture;
end;

// ******************************************************************************
procedure TZMSButton.Resize;
begin
  if not(fSkin.Empty) then
  begin
    fSize := fSkin.Width div 3;
    if Width <> fSize then
      Width := fSize;
    if Height <> fSkin.Height then
      Height := fSkin.Height;
    fBuffer.Width := fSize;
    fBuffer.Height := Height;
  end;
end;

// ******************************************************************************
procedure TZMSButton.UpdatePicture;
begin
  if fSkin.Empty then
    exit;
  Resize;
  SplitBitmap;
end;

// ******************************************************************************
procedure TZMSButton.SplitBitmap;
var
  tRct: TRect;
  tBit: TBitmap;
begin
  if (fSkin.Width mod 3 <> 0) then
    exit;

  fMouseExit.Width := fSize; // ширина
  fMouseEnter.Width := fSize; // картинки равна ширине
  fMouseDown.Width := fSize; // 1 кадра

  fMouseExit.Height := fSkin.Height; // чтобы красиво
  fMouseEnter.Height := fSkin.Height; // смотрелись картинки, нужно установить
  fMouseDown.Height := fSkin.Height; // высоту равную оригиналу

  tBit := TBitmap.Create; // создание

  tBit.Height := fSkin.Height; // прин€тие
  tBit.Width := fSkin.Width; // Width Height

  try
    (* MouseExit *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, 0, 0, fSize, fSkin.Height);
    fMouseExit.Canvas.CopyRect(Rect(0, 0, fSize, fSkin.Height),
      tBit.Canvas, tRct);
    (* MouseExit end *)

    (* MouseEnter *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, fSize, 0, fSize + fSize, fSkin.Height);
    fMouseEnter.Canvas.CopyRect(Rect(0, 0, fSize, fSkin.Height),
      tBit.Canvas, tRct);
    (* MouseEnter end *)

    (* MouseDown *)
    tBit.Canvas.Draw(0, 0, fSkin);
    SetRect(tRct, fSize + fSize, 0, fSize + fSize + fSize, fSkin.Height);
    fMouseDown.Canvas.CopyRect(Rect(0, 0, fSize, fSkin.Height),
      tBit.Canvas, tRct);
    (* MouseDown end *)
  finally
    freeAndNil(tBit);
    Render;
  end;
end;

// ******************************************************************************
procedure TZMSButton.SetLoadBmp(Value: TBitmap);
begin
  fSkin.Assign(Value);
  fBuffer.Assign(Value);
  fMouseEnter.Assign(Value);
  fMouseExit.Assign(Value);
  fMouseDown.Assign(Value);

  UpdatePicture;
  Invalidate;
end;

// ******************************************************************************
procedure TZMSButton.SetInterval(Value: integer);
begin
  if fTimer.Interval <> Value then
    fTimer.Interval := Value;
  fInterval := fTimer.Interval;
end;

// ******************************************************************************
procedure TZMSButton.SetMorph(Active: boolean);
begin
  if fMorphEnable <> Active then
    fMorphEnable := Active;
end;

// ******************************************************************************
constructor TZMSButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  fSkin := TBitmap.Create;
  fBuffer := TBitmap.Create;
  fMouseEnter := TBitmap.Create;
  fMouseExit := TBitmap.Create;
  fMouseDown := TBitmap.Create;

  fMorphEnable := true;
  fMouseInClient := false;
  // ControlStyle := ControlStyle + [csOpaque];

  fInterval := 50;
  fTimer := TTimer.Create(Self);
  fTimer.Enabled := false;
  fTimer.Interval := fInterval;
  fTimer.OnTimer := OnDrawExit;

  fMorphPos := 0;
  fMovePos := msNone;

  Height := 40;
  Width := 40;

  fMode := mfLeave;
  fMouseClick := false;

  fTransparent := false;
  fTransparentColor := clFuchsia;
end;

// ******************************************************************************
destructor TZMSButton.Destroy;
begin
  freeAndNil(fTimer);
  freeAndNil(fBuffer);
  freeAndNil(fSkin);
  freeAndNil(fMouseEnter);
  freeAndNil(fMouseExit);
  freeAndNil(fMouseDown);

  inherited;
end;

// ******************************************************************************
procedure TZMSButton.Morphing(Bm1, Bm2: TBitmap);
var
  dstPixel, srcPixel: PRGBQuad;
  Weight: integer;
  I: integer;
  R, G, B: Byte;
begin
  if (Assigned(Bm1) and Assigned(Bm2)) then
  begin
    if Bm1.PixelFormat <> pf32bit then
      Bm1.PixelFormat := pf32bit;
    if Bm2.PixelFormat <> pf32bit then
      Bm2.PixelFormat := pf32bit;

    srcPixel := Bm2.ScanLine[Bm2.Height - 1];
    dstPixel := Bm1.ScanLine[Bm1.Height - 1];
    Weight := MulDiv(256, fMorphPos, 100);
    if fTransparent then
    begin
      R := GetRValue(fTransparentColor);
      G := GetGValue(fTransparentColor);
      B := GetBValue(fTransparentColor);

      for I := (Bm1.Width * Bm1.Height) - 1 downto 0 do
      begin
        with dstPixel^ do
        begin
          if not(((R = srcPixel^.rgbRed) and (G = srcPixel^.rgbGreen)) and
            (B = srcPixel^.rgbBlue)) then
          begin
            Inc(rgbRed, (Weight * (srcPixel^.rgbRed - rgbRed)) shr 8);
            Inc(rgbGreen, (Weight * (srcPixel^.rgbGreen - rgbGreen)) shr 8);
            Inc(rgbBlue, (Weight * (srcPixel^.rgbBlue - rgbBlue)) shr 8);
          end;
        end;
        Inc(srcPixel);
        Inc(dstPixel);
      end
    end
    else
    begin
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
  end;
end;

// ******************************************************************************
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSButton]);
end;

end.
