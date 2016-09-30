unit MC_MediaGraphicEQ;

interface

uses
  // Windows, SysUtils, Messages, Classes, Controls, Graphics;
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls,
  Winapi.Messages, Types, Vcl.Graphics, slcanvas32;

type
  TBandCount = 1 .. maxInt;
  TMediaEQBorder = (mebNone, mebRectangle, mebRound);
  TMediaEQItems = array of Single;
  TEQChange = procedure(Sender: TObject; const ID: integer;
    const Position: Single; const SetPosition: boolean) of object;

  TZMSMediaGraphicEQ = class(TGraphicControl)
  private
    { Private declarations }
    fBuffer: TBitmap;

    fCurveClr: TColor;
    fMiddle: TColor;
    fBorderColor: TColor;

    fBandCount: TBandCount;
    fBorderType: TMediaEQBorder;

    fMouseInClient: boolean;
    fEQItems: TMediaEQItems;
    fPreamp: Single;
    fMax: Single;
    fOnEQChange: TEQChange;
    fOnStart: TNotifyEvent;
    fOnEnd: TNotifyEvent;
    fDrawPreAmp: boolean;
    fPreAmpMax: Single;

    function CalcNumID(X: integer): integer;
    function CalcBandValue(Y: integer): Single;
    function CalcPreAmpValue(Y: integer): Single;
    function CalcBandPosY(Value: Single): Single;
    function CalcBandPosX(NumID: integer): Single;

    procedure SetBandValue(NumID: integer; Value: Single);

    procedure SetCurveClr(Value: TColor);
    procedure SetMiddleLineColor(Value: TColor);
    procedure SetPreamp(Value: Single);
    procedure SetMax(Value: Single);
    procedure SetDrawPreAmp(Value: boolean);
    procedure SetBandCount(const Value: TBandCount);
    procedure SetPreampMax(const Value: Single);
    function CalcPreAmpPosY(Value: Single): Single;
    procedure SetBorderType(const Value: TMediaEQBorder);
    procedure SetborderColor(const Value: TColor);
  protected
    { Protected declarations }
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure Paint; override;
    procedure SetEnabled(Value: boolean); override;
  public
    { Public declarations }
    procedure BandEQValue(ID: integer; Value: Single);
    function GetBandValue(ID: integer): Single;
    procedure ResetEQ;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PaintTo(DC: TCanvas; X, Y: integer);
  published
    { Published declarations }
    property Anchors;

    property MaxBandValue: Single read fMax write SetMax;
    property PreAmpMax: Single read fPreAmpMax write SetPreampMax;
    property PreAmp: Single read fPreamp write SetPreamp;
    property BandCount: TBandCount read fBandCount write SetBandCount
      default 10;

    property BorderType: TMediaEQBorder read fBorderType write SetBorderType
      default mebNone;
    property BorderColor: TColor read fBorderColor write SetborderColor
      default clGray;

    property CurveColor: TColor read fCurveClr write SetCurveClr
      default clWhite;
    property MiddleColor: TColor read fMiddle write SetMiddleLineColor
      default clYellow;
    property DrawPreAmp: boolean read fDrawPreAmp write SetDrawPreAmp
      default True;
    property OnEQChange: TEQChange read fOnEQChange write fOnEQChange;
    property OnStart: TNotifyEvent read fOnStart write fOnStart;
    property OnEnd: TNotifyEvent read fOnEnd write fOnEnd;

    property MouseInClient: boolean read fMouseInClient;

    property Enabled;
    property Hint;
    property Cursor;
    property ShowHint;
    property Color default clBtnFace;
    property Visible;
    property PopupMenu;
  end;

procedure Register;

implementation

// ******************************************************************************
function TZMSMediaGraphicEQ.GetBandValue(ID: integer): Single;
begin
  if (ID >= 0) and (ID < fBandCount) then
    Result := fEQItems[ID];
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.BandEQValue(ID: integer; Value: Single);
var
  Vol: Single;
begin
  if (ID >= 0) and (ID < fBandCount) then
  begin
    if (Value < ((fMax / 2) - fMax)) then
      Vol := (fMax / 2) - fMax
    else if Value > (fMax / 2) then
      Vol := (fMax / 2)
    else
      Vol := Value;

    fEQItems[ID] := Vol;
    if Assigned(fOnEQChange) then
      fOnEQChange(Self, ID, Vol, True);
  end;
  Paint;
end;

// ******************************************************************************
function TZMSMediaGraphicEQ.CalcBandPosX(NumID: integer): Single;
begin
  if (NumID >= 0) and (NumID < fBandCount) then
    Result := MulDiv(Width, NumID, fBandCount - 1)
  else
    Result := 0;
end;

// ******************************************************************************
function TZMSMediaGraphicEQ.CalcBandPosY(Value: Single): Single;
var
  YPos: Single;
begin
  YPos := (fMax / 2) + Value;
  YPos := fMax - YPos;
  Result := MulDiv((Height - 1), Trunc(YPos), Trunc(fMax));
end;

// ******************************************************************************
function TZMSMediaGraphicEQ.CalcBandValue(Y: integer): Single;
begin
  Result := ((fMax / 2) - MulDiv(Trunc(fMax), Y, (Height - 1)));
end;

// ******************************************************************************
function TZMSMediaGraphicEQ.CalcNumID(X: integer): integer;
var
  XPos: integer;
begin
  XPos := X - ((Width div fBandCount) div 2);
  if XPos < 0 then
    XPos := 1;
  if XPos > Width then
    XPos := Width;
  Result := MulDiv(fBandCount, XPos, Width);
end;
// ******************************************************************************

function TZMSMediaGraphicEQ.CalcPreAmpValue(Y: integer): Single;
begin
  Result := ((fPreAmpMax / 2) - MulDiv(Trunc(fPreAmpMax), Y, (Height - 1)));
end;
// ******************************************************************************

function TZMSMediaGraphicEQ.CalcPreAmpPosY(Value: Single): Single;
var
  YPos: Single;
begin
  YPos := (fPreAmpMax / 2) + Value;
  if Height mod 2 = 0 then
    Result := Height - MulDiv(Height, Trunc(YPos), Trunc(fPreAmpMax))
  else
    Result := (Height - 1) - MulDiv(Height - 1, Trunc(YPos), Trunc(fPreAmpMax));
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  fMouseInClient := True;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  fMouseInClient := False;
end;

// ******************************************************************************
constructor TZMSMediaGraphicEQ.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited;
  fBuffer := TBitmap.Create;
  // fBuffer.PixelFormat := pf32bit;
  Color := clBtnFace;

  fBandCount := 1;
  SetBandCount(10);

  Constraints.MinWidth := fBandCount;
  Constraints.MinHeight := 6;

  fCurveClr := clWhite;
  fMiddle := clYellow;
  fBorderColor := clGray;

  fBorderType := mebNone;

  fPreamp := 0;
  fPreAmpMax := 20;
  fMax := 30;
  fDrawPreAmp := True;
end;

// ******************************************************************************
destructor TZMSMediaGraphicEQ.Destroy;
begin
  FreeAndNil(fBuffer);
  inherited;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  Off: integer;
begin
  inherited;

  if Enabled then
  begin
    if Y < 0 then
      Off := 0
    else if Y > Height - 1 then
      Off := Height - 1
    else
      Off := Y;

    if (ssLeft in Shift) then
    begin
      if Assigned(fOnStart) then
        fOnStart(Self);
      SetBandValue(CalcNumID(X), CalcBandValue(Off));
    end
    else if (ssRight in Shift) and (fDrawPreAmp) then
      fPreamp := CalcPreAmpValue(Off)
    else if (ssMiddle in Shift) then
    begin
      ResetEQ;
      exit;
    end;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.MouseMove(Shift: TShiftState; X, Y: integer);
var
  Off: integer;
begin
  inherited;

  if Enabled then
  begin
    if Y < 0 then
      Off := 0
    else if Y > Height - 1 then
      Off := Height - 1
    else
      Off := Y;

    if (ssLeft in Shift) then
      SetBandValue(CalcNumID(X), CalcBandValue(Off))
    else if (ssRight in Shift) then
      fPreamp := CalcPreAmpValue(Off);
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited;
  if Assigned(fOnEnd) then
    fOnEnd(Self);
  Paint;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.Paint;
var
  i: integer;
begin
  inherited;

  fBuffer.Width := Width;
  fBuffer.Height := Height;

  fBuffer.Canvas.Brush.Style := bsSolid;
  fBuffer.Canvas.Pen.Color := Color;
  fBuffer.Canvas.Brush.Color := Color;
  fBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  fBuffer.Canvas.Brush.Style := bsClear;

  case fBorderType of
    mebNone:
      ;
    mebRectangle:
      begin
        fBuffer.Canvas.Pen.Color := fBorderColor;
        fBuffer.Canvas.Rectangle(Rect(0, 0, Width, Height));
      end;
    mebRound:
      begin
        fBuffer.Canvas.Pen.Color := fBorderColor;
        fBuffer.Canvas.RoundRect(0, 0, Width, Height, 5, 5);
      end;
  end;
  fBuffer.Canvas.Brush.Style := bsSolid;

  if Enabled then
  begin
    if fDrawPreAmp then
    begin
      fBuffer.Canvas.Pen.Color := fMiddle;
      fBuffer.Canvas.Brush.Style := bsSolid;
      fBuffer.Canvas.Pen.Style := psDot;

      fBuffer.Canvas.MoveTo(0, Trunc(CalcPreAmpPosY(fPreamp)));
      fBuffer.Canvas.LineTo(Width, Trunc(CalcPreAmpPosY(fPreamp)));

      fBuffer.Canvas.Pen.Style := psSolid;
      fBuffer.Canvas.Brush.Style := bsSolid;
    end;
    fBuffer.Canvas.Pen.Color := fCurveClr;

    fBuffer.Canvas.MoveTo(0, Trunc(CalcBandPosY(fEQItems[0])));
    for i := 0 to fBandCount - 1 do
      fBuffer.Canvas.LineTo(Trunc(CalcBandPosX(i)),
        Trunc(CalcBandPosY(fEQItems[i])));
  end;

  Canvas.Draw(0, 0, fBuffer);
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.PaintTo(DC: TCanvas; X, Y: integer);
begin
  DC.Draw(X, Y, fBuffer);
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.ResetEQ;
var
  i: integer;
begin
  for i := 0 to fBandCount - 1 do
    SetBandValue(i, 0);
  fPreamp := 0;
  Paint;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetBandCount(const Value: TBandCount);
begin
  if fBandCount <> Value then
  begin
    fBandCount := Value;
    SetLength(fEQItems, fBandCount);
    ResetEQ;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetBandValue(NumID: integer; Value: Single);
begin
  if (NumID < fBandCount) and (NumID >= 0) then
  begin
    fEQItems[NumID] := Value;
    if Assigned(fOnEQChange) then
      fOnEQChange(Self, NumID, Value, False);
  end;
end;

procedure TZMSMediaGraphicEQ.SetborderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetBorderType(const Value: TMediaEQBorder);
begin
  if fBorderType <> Value then
  begin
    fBorderType := Value;
    Invalidate;
  end;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.SetCurveClr(Value: TColor);
begin
  if fCurveClr <> Value then
  begin
    fCurveClr := Value;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.SetEnabled(Value: boolean);
begin
  inherited;
  Paint;
end;

// ******************************************************************************
procedure TZMSMediaGraphicEQ.SetDrawPreAmp(Value: boolean);
begin
  if fDrawPreAmp <> Value then
  begin
    fDrawPreAmp := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetMax(Value: Single);
begin
  if fMax <> Value then
  begin
    fMax := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetMiddleLineColor(Value: TColor);
begin
  if fMiddle <> Value then
  begin
    fMiddle := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetPreamp(Value: Single);
begin
  if fPreamp <> Value then
  begin
    if fPreamp < ((fPreAmpMax / 2) - fPreAmpMax) then
      fPreamp := ((fPreAmpMax / 2) - fPreAmpMax)
    else if fPreamp > (fPreAmpMax / 2) then
      fPreamp := (fPreAmpMax / 2)
    else
      fPreamp := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSMediaGraphicEQ.SetPreampMax(const Value: Single);
begin
  if fPreAmpMax <> Value then
  begin
    fPreAmpMax := Value;
    Paint;
  end;
end;

// ******************************************************************************
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSMediaGraphicEQ]);
end;

end.
