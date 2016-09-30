unit SC_CheckButton;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSCheckBtn: Компонент с расширенными     |
  |               свойствами кнопки и состояния|
  ********************************************* }

interface

uses
  Windows, SysUtils, Messages, Classes, Controls, Graphics, Math, ExtCtrls;

type
  TOnChecked = procedure(Sender: TObject; var Checked: Boolean) of object;
  TMoveState = (msNone, msEnter, msLeave);
  TMouseFocus = (mfUp, mfDown, mfLeave, mfEnter);

  TZMSCheckBtn = class(TGraphicControl)
  private
    fLoadBitmap: TBitmap;
    fTmpBitmap: TBitmap;
    fBuffer: TBitmap;

    fPushEnter: TBitmap;
    fPushExit: TBitmap;
    fPushDown: TBitmap;
    fUnPushEnter: TBitmap;
    fUnPushExit: TBitmap;
    fUnPushDown: TBitmap;

    fSize: integer;
    fMode: TMouseFocus;
    fMouseClick: Boolean;
    fPushed: Boolean;

    fInterval: integer;
    fMovePos: TMoveState;
    fMorphEnable: Boolean;

    fOnPushed: TOnChecked;
    fTimer: TTimer;
    fMorphPos: integer;

    procedure SetMorph(Active: Boolean);
    procedure SetPushed(Active: Boolean);
    procedure SetLoadBmp(Bmp: TBitmap);
    procedure SetInterval(Value: integer);

    procedure OnDrawExit(Sender: TObject);
    procedure Morphing(Bm1, Bm2: TBitmap; progress: integer);
    procedure ReDrawPic(pos: integer);
    procedure UpdatePicture;
    procedure from126;
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
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    { Protected declarations }
  published
    property Checked: Boolean read fPushed write SetPushed default false;
    property Interval: integer read fInterval write SetInterval default 50;
    property SmoothEnable: Boolean read fMorphEnable write SetMorph
      default true;
    property Bitmap: TBitmap read fLoadBitmap write SetLoadBmp;
    property OnChecked: TOnChecked read fOnPushed write fOnPushed;

    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Enabled;

    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    { Published declarations }
  end;

procedure Register;

implementation

procedure TZMSCheckBtn.Click;
begin
  if fLoadBitmap.Empty then
    exit;

  fPushed := not fPushed;
  if Assigned(fOnPushed) then
    fOnPushed(self, fPushed);
  inherited;
end;

procedure TZMSCheckBtn.MouseDown;
begin
  if (fLoadBitmap.Empty) or (Button <> mbLeft) then
    exit;

  fTimer.Enabled := fMorphEnable;
  fMode := mfDown;
  inherited;
  fMouseClick := true;
  fMovePos := msNone;
  if not fPushed then
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fPushDown.Canvas.Handle, 0, 0, SRCCOPY)
  else
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fUnPushDown.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TZMSCheckBtn.MouseUp;
begin
  if (fLoadBitmap.Empty) or (Button <> mbLeft) then
    exit;

  fTimer.Enabled := fMorphEnable;
  fMode := mfUp;
  inherited;
  fMouseClick := false;
  fMovePos := msNone;
  if not fPushed then
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fPushExit.Canvas.Handle, 0, 0, SRCCOPY)
  else
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fUnPushExit.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TZMSCheckBtn.MouseEnter;
begin
  if fLoadBitmap.Empty then
    exit;

  if fMouseClick then
    exit;
  fMode := mfEnter;
  inherited;
  if fMorphEnable then
  begin
    fTimer.Enabled := fMorphEnable;
    fMovePos := msEnter;
  end
  else
  begin
    if not fPushed then
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fPushEnter.Canvas.Handle, 0, 0, SRCCOPY)
    else
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fUnPushEnter.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

procedure TZMSCheckBtn.MouseExit;
begin
  if fLoadBitmap.Empty then
    exit;

  if fMouseClick then
    exit;

  fMode := mfLeave;
  inherited;
  if fMorphEnable then
  begin
    fTimer.Enabled := fMorphEnable;
    fMovePos := msLeave;
  end
  else
  begin
    if (not fPushed) then
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fPushExit.Canvas.Handle, 0, 0, SRCCOPY)
    else
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fUnPushExit.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

procedure TZMSCheckBtn.OnDrawExit(Sender: TObject);
begin
  if fMovePos = msNone then
    exit;
  if (fMovePos = msEnter) then
  begin
    fMorphPos := 100;
    if fMouseClick then
      exit;
    /// !!!

    if not fPushed then
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fPushEnter.Canvas.Handle, 0, 0, SRCCOPY)
    else
      BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
        fUnPushEnter.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else if (fMovePos = msLeave) then
  begin
    if (fMorphPos >= 0) then
    begin
      fMorphPos := fMorphPos - 10;
      if (fMorphPos <= 0) then
        fMovePos := msNone;
      if (fMorphPos < 0) then
        fMorphPos := 0;
      ReDrawPic(fMorphPos);
    end
    else
      fMovePos := msNone;
  end;
  if fMorphPos = 0 then
    fTimer.Enabled := false;
end;

procedure TZMSCheckBtn.ReDrawPic(pos: integer);
begin
  if not fPushed then
  begin
    fBuffer.Canvas.CopyRect(ClientRect, fPushExit.Canvas, ClientRect);
    Morphing(fBuffer, fPushEnter, pos);
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else
  begin
    fBuffer.Canvas.CopyRect(ClientRect, fUnPushExit.Canvas, ClientRect);
    Morphing(fBuffer, fUnPushEnter, pos);
    BitBlt(Canvas.Handle, 0, 0, fSize, fLoadBitmap.Height,
      fBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

procedure TZMSCheckBtn.Paint;
begin
  inherited;

  if fLoadBitmap.Empty then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Style := psDashDot;
    Canvas.Rectangle(ClientRect);
  end
  else
  begin
    UpdatePicture;
    Render;
  end;
end;

procedure TZMSCheckBtn.Render;
begin
  if not fPushed then
    Canvas.Draw(0, 0, fPushExit)
  else
    Canvas.Draw(0, 0, fUnPushExit);
end;

procedure TZMSCheckBtn.Resize;
begin
  if not(fLoadBitmap.Empty) then
  begin
    fSize := fLoadBitmap.Width div 6;
    if Width <> fSize then
      Width := fSize;
    if Height <> fLoadBitmap.Height then
      Height := fLoadBitmap.Height;

    fBuffer.Width := fSize;
    fBuffer.Height := Height;
  end;
end;

procedure TZMSCheckBtn.UpdatePicture;
begin
  fTmpBitmap.Assign(fLoadBitmap);
  Resize;
  from126;
end;

procedure TZMSCheckBtn.from126;
var
  tRct: TRect;
  tBit: TBitmap;
begin
  if (fLoadBitmap.Width mod 6) <> 0 then
    exit;

  fPushExit.Width := fSize;
  fPushEnter.Width := fSize;
  fPushDown.Width := fSize;
  fUnPushEnter.Width := fSize;
  fUnPushExit.Width := fSize;
  fUnPushDown.Width := fSize;

  fPushExit.Height := fLoadBitmap.Height;
  fPushEnter.Height := fLoadBitmap.Height;
  fPushDown.Height := fLoadBitmap.Height;
  fUnPushEnter.Height := fLoadBitmap.Height;
  fUnPushExit.Height := fLoadBitmap.Height;
  fUnPushDown.Height := fLoadBitmap.Height;

  tBit := TBitmap.Create; // создание

  tBit.Height := fLoadBitmap.Height; // принятие
  tBit.Width := fLoadBitmap.Width; // Width Height

  try
    (* PushExit *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, 0, 0, fSize, fTmpBitmap.Height);
    fPushExit.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* PushExit end *)

    (* PushDown *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, fSize + fSize, 0, fSize + fSize + fSize, fTmpBitmap.Height);
    fPushDown.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* PushDown end *)

    (* PushEnter *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, fSize, 0, fSize + fSize, fTmpBitmap.Height);
    fPushEnter.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* PushEnter end *)

    (* UnPushExit *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, fSize + fSize + fSize, 0, fSize + fSize + fSize + fSize,
      fTmpBitmap.Height);
    fUnPushExit.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* UnPushExit end *)

    (* UnPushEnter *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, fSize + fSize + fSize + fSize, 0, fSize + fSize + fSize +
      fSize + fSize, fTmpBitmap.Height);
    fUnPushEnter.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* UnPushEnter end *)

    (* UnPushDown *)
    tBit.Canvas.Draw(0, 0, fTmpBitmap);
    SetRect(tRct, fSize + fSize + fSize + fSize + fSize, 0,
      fSize + fSize + fSize + fSize + fSize + fSize, fTmpBitmap.Height);
    fUnPushDown.Canvas.CopyRect(Rect(0, 0, fSize, fTmpBitmap.Height),
      tBit.Canvas, tRct);
    (* UnPushDown end *)

  finally
    FreeAndNil(tBit); // освобождаем
    Render;
  end;
end;

procedure TZMSCheckBtn.SetLoadBmp(Bmp: TBitmap);
begin
  if not(Assigned(Bmp)) then
  begin
    fLoadBitmap.Handle := 0;
    fTmpBitmap.Handle := 0;

    fPushEnter.Handle := 0;
    fPushExit.Handle := 0;
    fPushDown.Handle := 0;
    fUnPushEnter.Handle := 0;
    fUnPushExit.Handle := 0;
    fUnPushDown.Handle := 0;

    Invalidate;
    exit;
  end;

  if (Bmp.Width mod 6) = 0 then
  begin
    fSize := Bmp.Width div 6;
    fLoadBitmap.Assign(Bmp);
    fTmpBitmap.Assign(Bmp);

    Invalidate; // !!!
    UpdatePicture;
  end;
end;

procedure TZMSCheckBtn.SetInterval(Value: integer);
begin
  if Round(fTimer.Interval) <> Value then
    fTimer.Interval := Value;
  fInterval := fTimer.Interval;
end;

procedure TZMSCheckBtn.SetMorph(Active: Boolean);
begin
  if fMorphEnable <> Active then
  begin
    fMorphEnable := Active;
    fTimer.Enabled := Active;
  end;
end;

procedure TZMSCheckBtn.SetPushed(Active: Boolean);
begin
  if fPushed <> Active then
    fPushed := Active;

  if Assigned(fOnPushed) then
    fOnPushed(self, fPushed);
  Invalidate;
end;

constructor TZMSCheckBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  fLoadBitmap := TBitmap.Create;
  fTmpBitmap := TBitmap.Create;
  fBuffer := TBitmap.Create;

  fPushEnter := TBitmap.Create;
  fPushExit := TBitmap.Create;
  fPushDown := TBitmap.Create;
  fUnPushEnter := TBitmap.Create;
  fUnPushExit := TBitmap.Create;
  fUnPushDown := TBitmap.Create;

  fBuffer.Pixelformat := pf32bit;
  fPushEnter.Pixelformat := pf32bit;
  fPushExit.Pixelformat := pf32bit;
  fPushDown.Pixelformat := pf32bit;
  fUnPushEnter.Pixelformat := pf32bit;
  fUnPushExit.Pixelformat := pf32bit;
  fUnPushDown.Pixelformat := pf32bit;

  fMorphEnable := true;
  fPushed := false;
  ControlStyle := ControlStyle + [csOpaque];
  ParentColor := false;

  fTimer := TTimer.Create(nil);
  fTimer.OnTimer := OnDrawExit;
  fTimer.Enabled := false;
  fInterval := 50;
  fTimer.Interval := fInterval;

  fMorphPos := 0;
  fMovePos := msNone;

  Height := 40;
  Width := 40;

  fMode := mfUp;
  fMouseClick := false;
end;

destructor TZMSCheckBtn.Destroy;
begin
  fTimer.free;
  fBuffer.free;
  fLoadBitmap.free;
  fTmpBitmap.free;
  fPushEnter.free;
  fPushExit.free;
  fPushDown.free;
  fUnPushEnter.free;
  fUnPushExit.free;
  fUnPushDown.free;

  fTimer := nil;
  fBuffer := nil;
  fLoadBitmap := nil;
  fTmpBitmap := nil;
  fPushEnter := nil;
  fPushExit := nil;
  fPushDown := nil;
  fUnPushEnter := nil;
  fUnPushExit := nil;
  fUnPushDown := nil;
  inherited;
end;

procedure TZMSCheckBtn.Morphing(Bm1, Bm2: TBitmap; progress: integer);
var
  dstPixel, srcPixel: PRGBQuad;
  Weight, I: integer;
begin
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

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSCheckBtn]);
end;

end.
