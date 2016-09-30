unit OC_BalloonHint;

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
  Windows, SysUtils, Classes, Controls, Graphics, Forms, Messages;

type
  TZMSHintWindow = class(THintWindow)
    constructor Create(AOwner: TComponent); override;
  private
    FActivating: Boolean;
    FLastActive: Cardinal;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  public
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ActivateHint(Rect: TRect; const AHint: string); reintroduce;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
      reintroduce;
  protected
    procedure Paint; override;
  published
    property Caption;
  end;

implementation

{ function SetBlend(hWin: HWND; AlphaBlend: byte): LongBool;
  const
  LMA_ALPHA = $00000002;
  var
  old: longint;
  User32: HMODULE;
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
  begin
  Result := false;
  User32 := LoadLibrary('user32.dll');
  if (User32 <> 0) then
  begin
  old := GetWindowLong(hWin, GWL_EXSTYLE);
  SetWindowLong(hWin, GWL_EXSTYLE, old or $80000);
  SetLayeredWindowAttributes := GetProcAddress(User32, 'SetLayeredWindowAttributes');
  if Assigned(SetLayeredWindowAttributes) then
  SetLayeredWindowAttributes(hWin, 0, AlphaBlend, LMA_ALPHA);
  Result := true;
  FreeLibrary(User32);
  end;
  end; }

procedure DrawGradient(ACanvas: TCanvas; Rect: TRect; Colors: array of TColor);
type
  RGBArray = array [0 .. 2] of Byte;
var
  X, Y, z, stelle, mx, bis, faColorsh, mass: Integer;
  Faktor: double;
  A: RGBArray;
  B: array of RGBArray;
  merkw: Integer;
  merks: TPenStyle;
  merkp: TColor;
begin
  mx := High(Colors);
  if mx > 0 then
  begin
    mass := Rect.Bottom - Rect.Top;
    SetLength(B, mx + 1);
    for X := 0 to mx do
    begin
      Colors[X] := ColorToRGB(Colors[X]);
      B[X][0] := GetRValue(Colors[X]);
      B[X][1] := GetGValue(Colors[X]);
      B[X][2] := GetBValue(Colors[X]);
    end;
    merkw := ACanvas.Pen.Width;
    merks := ACanvas.Pen.Style;
    merkp := ACanvas.Pen.Color;
    ACanvas.Pen.Width := 1;
    ACanvas.Pen.Style := psSolid;
    faColorsh := Round(mass / mx);
    for Y := 0 to mx - 1 do
    begin
      if Y = mx - 1 then
        bis := mass - Y * faColorsh - 1
      else
        bis := faColorsh;
      for X := 0 to bis do
      begin
        stelle := X + Y * faColorsh;
        Faktor := X / bis;
        for z := 0 to 3 do
          A[z] := Trunc(B[Y][z] + ((B[Y + 1][z] - B[Y][z]) * Faktor));
        ACanvas.Pen.Color := RGB(A[0], A[1], A[2]);
        ACanvas.MoveTo(Rect.Left, Rect.Top + stelle);
        ACanvas.LineTo(Rect.Right, Rect.Top + stelle);
      end;
    end;
    B := nil;
    ACanvas.Pen.Width := merkw;
    ACanvas.Pen.Style := merks;
    ACanvas.Pen.Color := merkp;
  end;
end;

constructor TZMSHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := false;
  Color := RGB(195, 195, 195);
  Application.HintColor := Color;
  ControlStyle := ControlStyle + [csReplicatable];

  Canvas.Font.Color := clblack;
  Canvas.Font.Name := 'Verdana';
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [];
  DoubleBuffered := true;
end;

procedure TZMSHintWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    if CheckWin32Version(5, 1) then
      WindowClass.Style := WindowClass.Style - CS_DROPSHADOW;
    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
end;

procedure TZMSHintWindow.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if FActivating then
  begin
    Update;
    Paint;
    Exit;
  end;
  Width := Canvas.TextWidth(Caption) + 6;
  Height := Canvas.TextHeight(Caption) + 4;
  Update;
  Paint;
end;

procedure TZMSHintWindow.Paint;
var
  sl: TStringList;
  i: Integer;
begin
  if not(csDesigning in ComponentState) then
  begin
    Canvas.Lock;
    sl := TStringList.Create;
    DrawGradient(Canvas, ClientRect, [RGB(245, 245, 245), RGB(195, 195, 195)]);
    sl.Text := Caption;
    for i := 0 to sl.Count - 1 do
      Canvas.TextOut(1, (i * Canvas.TextHeight(sl.Strings[i]) + 2), sl.Strings[i]);
    FreeAndNil(sl);
    Canvas.Unlock;
  end;
end;

procedure TZMSHintWindow.ActivateHint(Rect: TRect; const AHint: string);
type
  TAnimationStyle = (atSlideNeg, atSlidePos, atBlend);
const
  AnimationStyle: array [TAnimationStyle] of Integer = (AW_VER_NEGATIVE, AW_VER_POSITIVE, AW_BLEND);
var
  Animate: BOOL;
  Style: TAnimationStyle;
  Monitor: TMonitor;
begin
  FActivating := true;
  try
    Animate := true;
    Caption := AHint;
    Inc(Rect.Bottom, 4);
    UpdateBoundsRect(Rect);
    Monitor := Screen.MonitorFromPoint(Point(Rect.Left, Rect.Top));
    if Width > Monitor.Width then
      Width := Monitor.Width;
    if Height > Monitor.Height then
      Height := Monitor.Height;
    if Rect.Top + Height > Monitor.Top + Monitor.Height then
      Rect.Top := (Monitor.Top + Monitor.Height) - Height;
    if Rect.Left + Width > Monitor.Left + Monitor.Width then
      Rect.Left := (Monitor.Left + Monitor.Width) - Width;
    if Rect.Left < Monitor.Left then
      Rect.Left := Monitor.Left;
    if Rect.Bottom < Monitor.Top then
      Rect.Top := Monitor.Top;

    ParentWindow := Application.Handle;
    SetWindowPos(Handle, HWND_TOPMOST, Rect.Left, Rect.Top, Width, Height, SWP_NOACTIVATE);
    if (GetTickCount - FLastActive > 250) and (Length(AHint) < 100) and
      Assigned(AnimateWindowProc) then
    begin
      // SystemParametersInfo(SPI_GETTOOLTIPANIMATION, 0, {$IFNDEF CLR}@{$ENDIF}Animate, 0);
      if Animate then
      begin
        // SystemParametersInfo(SPI_GETTOOLTIPFADE, 0, {$IFNDEF CLR}@{$ENDIF}Animate, 0);
        if Animate then
          Style := atBlend
        else if Mouse.CursorPos.Y > Rect.Top then
          Style := atSlideNeg
        else
          Style := atSlidePos;
        AnimateWindowProc(Handle, 500, AnimationStyle[Style] { or AW_SLIDE } );
      end;
    end;
    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    Paint;
  finally
    FLastActive := GetTickCount;
    FActivating := false;
  end;
end;
// var
// SaveActivating: Boolean;
// begin
// if (csDesigning in ComponentState) then
// Exit;
// SaveActivating := FActivating;
// try
// FActivating := true;
// Caption := AHint;
/// /    AnimateWindow(Handle, 500, AW_SLIDE);
// inherited ActivateHint(Rect, AHint);
// finally
// FActivating := SaveActivating;
// end;
// Paint;
// end;

function TZMSHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
begin
  Result := Rect(0, 0, MaxWidth, 0);
  Inc(Result.Right, 6);
  Inc(Result.Bottom, 2);
end;

end.
