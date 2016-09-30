unit OC_Button;

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
  Windows, SysUtils, Classes, Controls, ExtCtrls, Graphics, Messages;

type
  TButtonState = (bsNormal, bsEnter, bsDown);

  TZMSBtn = class(TGraphicControl)
  private
    fSkin: TBitmap;
    fStateBuff: TBitmap;
    fBuffer: TBitmap;
    fDynam: TBitmap;
    fTimer: TTimer;

    fFading: boolean;
    fMouseFocus: boolean;
    fMouseDown: boolean;
    fState: TButtonState;

    fCounter: Integer;

    procedure OnTimer(Sender: TObject);
    procedure SetSkin(Value: TBitmap);
    procedure SetState(Value: TButtonState);
    procedure Morphing(Bm1, Bm2: TBitmap; Progress: Integer);

    procedure SetFading(Value: boolean);
    procedure SetInterval(Value: Integer);
    function GetInterval: Integer;

    procedure SubRender;
    procedure Render;
    procedure FadingProc;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Click; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Bitmap: TBitmap read fSkin write SetSkin;
    property SmoothEnable: boolean read fFading write SetFading default True;
    property Interval: Integer read GetInterval write SetInterval default 15;
    property MouseLDown: boolean read fMouseDown;
    property FocusMouse: boolean read fMouseFocus;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnClick;
    property OnDblClick;
    property PopupMenu;

    property Cursor default crHandPoint;
    property Hint;
    property ShowHint;
    property Anchors;
    property Color;
    property Visible;
  end;

procedure Register;

implementation

const
  dynamEnter = 30;
  dynamLeave = 2;

procedure TZMSBtn.Click;
begin
  inherited;
  SetState(bsNormal);
  Render;
  fMouseDown := False;
end;

procedure TZMSBtn.FadingProc;
begin
  if fFading then
  begin
    fTimer.Enabled := True;
    fCounter := 100;
  end
  else
    Render;
end;

procedure TZMSBtn.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button <> mbLeft then
    Exit;

  fMouseDown := True;
  SetState(bsDown);

  Render;
end;

procedure TZMSBtn.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if fMouseFocus then
  begin
    SetState(bsEnter);
    if { not } fMouseDown then
      SetState(bsNormal);
  end;
  Render;
  fMouseDown := False;
end;

procedure TZMSBtn.CMMouseEnter(var Message: TMessage);
begin
  fMouseFocus := True;
  SetState(bsEnter);

  FadingProc;
end;

procedure TZMSBtn.CMMouseLeave(var Message: TMessage);
begin
  fMouseFocus := False;

  if fMouseDown then
    SetState(bsDown)
  else
    SetState(bsNormal);

  FadingProc;
end;

procedure TZMSBtn.SubRender;
begin
  if fState = bsNormal then
  begin
    if not fSkin.Empty then
    begin
      BitBlt(fStateBuff.Canvas.Handle, 0, 0, fSkin.Width div 3, fSkin.Height, fSkin.Canvas.Handle,
        0, 0, SRCCOPY);
    end;
  end
  else if fState = bsEnter then
  begin
    if not fSkin.Empty then
    begin
      BitBlt(fStateBuff.Canvas.Handle, 0, 0, fSkin.Width div 3, fSkin.Height, fSkin.Canvas.Handle,
        (fSkin.Width div 3), 0, SRCCOPY);
    end;
  end
  else if fState = bsDown then
  begin
    if not fSkin.Empty then
    begin
      BitBlt(fStateBuff.Canvas.Handle, 0, 0, fSkin.Width div 3, fSkin.Height, fSkin.Canvas.Handle,
        (fSkin.Width div 3) * 2, 0, SRCCOPY);
    end;
  end;
end;

procedure TZMSBtn.Paint;
begin
  inherited;

  SetState(fState);
  Render;
end;

procedure TZMSBtn.Render;
begin
  fDynam.Width := Width;
  fDynam.Height := Height;
  fStateBuff.Width := Width;
  fStateBuff.Height := Height;
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  if fFading then
  begin
    if fCounter < 100 then
    begin
      fDynam.Canvas.Draw(0, 0, fBuffer);
      SubRender;
      Morphing(fDynam, fStateBuff, fCounter);
    end
    else
    begin
      SubRender;
      fDynam.Canvas.Draw(0, 0, fStateBuff);
    end;
  end
  else
  begin
    SubRender;
    fDynam.Canvas.Draw(0, 0, fStateBuff);
  end;

  if fSkin.Empty then
  begin
    fDynam.Canvas.Pen.Color := clBlack;
    fDynam.Canvas.Brush.Color := clBlack;
    fDynam.Canvas.FillRect(Rect(0, 0, Width, Height));
  end;

  Canvas.Draw(0, 0, fDynam);
end;

procedure TZMSBtn.Morphing(Bm1, Bm2: TBitmap; Progress: Integer);
var
  dstPixel, srcPixel: PRGBQuad;
  Weight: Integer;
  I: Integer;
begin
  if (Assigned(Bm1) and Assigned(Bm2)) then
  begin
    Bm1.PixelFormat := pf32bit;
    Bm2.PixelFormat := pf32bit;
    srcPixel := Bm2.ScanLine[Bm2.Height - 1];
    dstPixel := Bm1.ScanLine[Bm1.Height - 1];
    Progress := 100 - Progress;
    Weight := MulDiv(256, Progress, 100);
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

procedure TZMSBtn.OnTimer(Sender: TObject);
begin
  if fCounter > 0 then
  begin
    if fState = bsEnter then
      fCounter := fCounter - dynamEnter
    else if fState = bsNormal then
      fCounter := fCounter - dynamLeave;
    if fCounter < 0 then
      fCounter := 0;
  end
  else
  begin
    fCounter := 100;
    fTimer.Enabled := False;
  end;

  Render;
end;

procedure TZMSBtn.Resize;
begin
  if not fSkin.Empty then
  begin
    Width := fSkin.Width div 3;
    Height := fSkin.Height;
  end
  else
    inherited;
end;

constructor TZMSBtn.Create(AOwner: TComponent);
begin
  inherited;

  fFading := True;
  fCounter := 100;
  fState := bsNormal;

  Cursor := crHandPoint;

  fTimer := TTimer.Create(self);
  fTimer.Interval := 15;
  fTimer.Enabled := False;
  fTimer.OnTimer := OnTimer;

  fDynam := TBitmap.Create;
  fDynam.Width := Width;
  fDynam.Height := Height;

  fDynam.Canvas.Pen.Color := clBlack;
  fDynam.Canvas.Brush.Color := clBlack;
  fDynam.Canvas.FillRect(Rect(0, 0, Width, Height));

  fStateBuff := TBitmap.Create;
  fStateBuff.Width := Width;
  fStateBuff.Height := Height;

  fStateBuff.Canvas.Pen.Color := clBlack;
  fStateBuff.Canvas.Brush.Color := clBlack;
  fStateBuff.Canvas.FillRect(Rect(0, 0, Width, Height));

  fSkin := TBitmap.Create;
  fSkin.Width := 0;
  fSkin.Height := 0;

  fBuffer := TBitmap.Create;
  fBuffer.Width := 0;
  fBuffer.Height := 0;

  fBuffer.Canvas.Pen.Color := clBlack;
  fBuffer.Canvas.Brush.Color := clBlack;
  fBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
end;

destructor TZMSBtn.Destroy;
begin
  FreeAndNil(fTimer);
  FreeAndNil(fDynam);
  FreeAndNil(fStateBuff);
  FreeAndNil(fSkin);
  FreeAndNil(fBuffer);

  inherited;
end;

function TZMSBtn.GetInterval: Integer;
begin
  Result := fTimer.Interval;
end;

procedure TZMSBtn.SetFading(Value: boolean);
begin
  if fFading <> Value then
  begin
    fFading := Value;
    Render;
  end;
end;

procedure TZMSBtn.SetInterval(Value: Integer);
begin
  if Value > 0 then
  begin
    fTimer.Interval := Value;
    if fTimer.Enabled then
      fTimer.Enabled := fFading;
  end
end;

procedure TZMSBtn.SetState(Value: TButtonState);
begin
  if fState <> Value then
  begin
    fState := Value;
    fBuffer.Canvas.Draw(0, 0, fDynam);
    SubRender;
  end;
end;

procedure TZMSBtn.SetSkin(Value: TBitmap);
begin
  fSkin.Assign(Value);
  SetState(fState);

  Resize;
  Render;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSBtn]);
end;

end.
