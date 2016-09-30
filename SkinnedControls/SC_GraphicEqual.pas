unit SC_GraphicEqual;

interface

uses
  Windows, SysUtils, Messages, Classes, Controls, Graphics;

type
  TEQPreset = array [0 .. 17] of integer;

  TEQItems = array of Single;
  TEQType = (emBands, emPreAMP);
  TEQChange = procedure(Sender: TObject; const ID: integer;
    const Position: Single; const SetPosition: boolean) of object;

  TZMSGraphicEQ = class(TGraphicControl)
  private
    { Private declarations }
    fBuffer: TBitmap;
    fSkin: TBitmap;

    fCurveClr: TColor;
    fMiddle: TColor;

    fBandCount: integer;

    fMouseFocus: boolean;
    fType: TEQType;
    fEnabled: boolean;
    fEQItems: TEQItems;
    fPreamp: Single;
    fMax: Single;
    fOnEQChange: TEQChange;
    fOnStart: TNotifyEvent;
    fOnEnd: TNotifyEvent;
    fDrawPreAmp: boolean;

    function CalcNumID(X: integer): integer;
    function CalcBandValue(Y: integer): Single;
    function CalcBandPosY(Value: Single): Single;
    function CalcBandPosX(NumID: integer): Single;

    procedure SetBandValue(NumID: integer; Value: Single);

    procedure SetSkin(Value: TBitmap);
    procedure SetCurveClr(Value: TColor);
    procedure SetMiddleLineColor(Value: TColor);
    procedure SetPreamp(Value: Single);
    procedure SetMax(Value: Single);
    procedure SetEnable(Value: boolean);
    procedure SetDrawPreAmp(Value: boolean);
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
    procedure Resize; override;
    procedure Renderer;
  public
    { Public declarations }
    procedure BandEQValue(ID: integer; Value: Single);
    function GetBandValue(ID: integer): Single;
    procedure SetPresetID(ID: integer);
    procedure SetPreset(Value: TEQPreset);
    procedure ResetEQ;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }

    property MaxBandValue: Single read fMax write SetMax;
    property PreAmpValue: Single read fPreamp write SetPreamp;
    property ClrCurve: TColor read fCurveClr write SetCurveClr default clWhite;
    property ClrMiddle: TColor read fMiddle write SetMiddleLineColor
      default clYellow;
    property Enabled: boolean read fEnabled write SetEnable default True;
    property DrawPreAmp: boolean read fDrawPreAmp write SetDrawPreAmp
      default True;
    property OnEQChange: TEQChange read fOnEQChange write fOnEQChange;
    property OnStart: TNotifyEvent read fOnStart write fOnStart;
    property OnEnd: TNotifyEvent read fOnEnd write fOnEnd;

    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Color default clBtnFace;
  end;

procedure Register;

implementation

const
  TEQNone: TEQPreset = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  TEQBallad: TEQPreset = (-5, -3, 2, 2, 4, 3, 5, 5, 5, 3, 2, 2, 0, -2, -2,
    -3, 2, -5);
  TEQClassic: TEQPreset = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3, -6, -6, -6,
    -6, -6, -8);
  TEQClub: TEQPreset = (0, 0, 0, 2, 3, 5, 5, 5, 5, 5, 5, 4, 2, 2, 1, 0, 0, 0);
  TEQDance: TEQPreset = (7, 6, 5, 2, 1, 0, 0, -1, -3, -4, -5, -5, -6, -6, -6,
    -6, 0, 0);
  TEQFullBass: TEQPreset = (7, 7, 7, 7, 6, 5, 1, 0, -1, -2, -4, -5, -7, -7, -8,
    -8, -9, -9);
  TEQFullBassTreble: TEQPreset = (5, 5, 5, 0, -3, -6, -4, -3, -2, -1, 1, 4, 6,
    7, 8, 8, 9, 9);
  TEQFullTreble: TEQPreset = (-8, -8, -8, -8, -6, -4, 2, 4, 5, 7, 8, 10, 12, 12,
    12, 12, 12, 13);
  TEQHeavyMetal: TEQPreset = (-2, 3, 5, 3, 2, -3, -4, -6, -6, -6, -6, -3, -2, 2,
    3, 5, 5, 2);
  TEQJazz: TEQPreset = (3, 7, 6, 5, 2, 1, -5, -7, -5, -2, 2, 5, 0, -2, -4,
    -2, 0, 2);
  TEQLive: TEQPreset = (-4, -2, 0, 3, 3, 4, 5, 5, 5, 5, 5, 4, 3, 3, 2, 2, 2, 2);
  TEQParty: TEQPreset = (5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5);
  TEQPop: TEQPreset = (-2, 1, 3, 5, 5, 6, 4, 3, 2, 0, -1, -2, -2, -2, -2,
    -2, -2, -2);
  TEQRap: TEQPreset = (-2, 3, 5, 3, 2, -3, -5, -3, -2, 2, -2, -6, -2, 2,
    4, 5, 4, 2);
  TEQRock: TEQPreset = (6, 5, 3, -5, -6, -7, -3, -2, 0, 1, 3, 5, 7, 7,
    8, 8, 8, 8);
  TEQSoft: TEQPreset = (3, 2, 1, -1, -2, -2, -1, 0, 1, 2, 3, 5, 6, 7,
    7, 7, 8, 9);
  TEQSoftRock: TEQPreset = (3, 3, 3, 2, 0, -1, -4, -4, -4, -4, -5, -4, -3, -3,
    -2, -1, 2, 7);
  TEQVocal: TEQPreset = (-7, -6, -4, -3, -2, 0, 5, 7, 5, 5, 3, 2, 0, 0, -2,
    -2, -4, -6);
  TEQZigZag: TEQPreset = (-15, 15, -15, 15, -15, 15, -15, 15, -15, 15, -15, 15,
    -15, 15, -15, 15, -15, 15);

  // ******************************************************************************
procedure TZMSGraphicEQ.SetPreset(Value: TEQPreset);
var
  i: integer;
begin
  for i := 0 to fBandCount do
    BandEQValue(i, Value[i]);
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetPresetID(ID: integer);
begin
  case ID of
    0:
      SetPreset(TEQNone);
    1:
      SetPreset(TEQBallad);
    2:
      SetPreset(TEQClassic);
    3:
      SetPreset(TEQClub);
    4:
      SetPreset(TEQDance);
    5:
      SetPreset(TEQFullBass);
    6:
      SetPreset(TEQFullBassTreble);
    7:
      SetPreset(TEQFullTreble);
    8:
      SetPreset(TEQHeavyMetal);
    9:
      SetPreset(TEQJazz);
    10:
      SetPreset(TEQLive);
    11:
      SetPreset(TEQParty);
    12:
      SetPreset(TEQPop);
    13:
      SetPreset(TEQRap);
    14:
      SetPreset(TEQRock);
    15:
      SetPreset(TEQSoft);
    16:
      SetPreset(TEQSoftRock);
    17:
      SetPreset(TEQVocal);
    18:
      SetPreset(TEQZigZag);
  end;
end;

// ******************************************************************************
function TZMSGraphicEQ.GetBandValue(ID: integer): Single;
begin
  if (ID >= 0) and (ID < 18) then
    Result := fEQItems[ID];
end;

// ******************************************************************************
procedure TZMSGraphicEQ.BandEQValue(ID: integer; Value: Single);
var
  Vol: Single;
begin
  if (ID >= 0) and (ID < 18) then
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
  Renderer;
end;

// ******************************************************************************
function TZMSGraphicEQ.CalcBandPosX(NumID: integer): Single;
begin
  if (NumID >= 0) and (NumID < 18) then
    Result := MulDiv(Width, NumID, 17)
  else
    Result := 0;
end;

// ******************************************************************************
function TZMSGraphicEQ.CalcBandPosY(Value: Single): Single;
var
  YPos: Single;
begin
  YPos := (fMax / 2) + Value;
  YPos := fMax - YPos;
  Result := MulDiv((Height - 1), Trunc(YPos), Trunc(fMax));
end;

// ******************************************************************************
function TZMSGraphicEQ.CalcBandValue(Y: integer): Single;
begin
  Result := ((fMax / 2) - MulDiv(Trunc(fMax), Y, (Height - 1)));
end;

// ******************************************************************************
function TZMSGraphicEQ.CalcNumID(X: integer): integer;
var
  XPos: integer;
begin
  XPos := X - ((Width div 18) div 2);
  if XPos < 0 then
    XPos := 1;
  if XPos > Width then
    XPos := Width;
  Result := MulDiv(18, XPos, Width);
end;

// ******************************************************************************
procedure TZMSGraphicEQ.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  fMouseFocus := True;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  fMouseFocus := False;
end;

// ******************************************************************************
constructor TZMSGraphicEQ.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited;
  fBuffer := TBitmap.Create;
  fSkin := TBitmap.Create;
  Color := clBlack;
  fEnabled := True;
  Constraints.MinWidth := 18;
  Constraints.MinHeight := 6;
  for i := 0 to 17 do
    fEQItems[i] := 0;
  fCurveClr := clWhite;
  fType := emBands;
  fMiddle := clYellow;
  fPreamp := 0;
  fMax := 30;
  fDrawPreAmp := True;
end;

// ******************************************************************************
destructor TZMSGraphicEQ.Destroy;
begin
  FreeAndNil(fBuffer);
  FreeAndNil(fSkin);
  inherited;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  Off: integer;
begin
  inherited;

  if fEnabled then
  begin
    if (ssLeft in Shift) then
    begin
      if Assigned(fOnStart) then
        fOnStart(Self);
      fType := emBands;
      if Y < 0 then
        Off := 0
      else if Y > Height - 1 then
        Off := Height - 1
      else
        Off := Y;
      SetBandValue(CalcNumID(X), CalcBandValue(Off));
    end
    else if (ssRight in Shift) and (fDrawPreAmp) then
    begin
      fType := emPreAMP;
      if Y < 0 then
        Off := 1
      else if Y > Height - 1 then
        Off := Height + 1
      else
        Off := Y;
      fPreamp := CalcBandValue(Height - Off);
    end
    else if (ssMiddle in Shift) then
      ResetEQ;
    Renderer;
  end;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.MouseMove(Shift: TShiftState; X, Y: integer);
var
  Off: integer;
begin
  inherited;

  if fEnabled then
  begin
    if (fType = emBands) and (ssLeft in Shift) then
    begin
      if Y < 0 then
        Off := 0
      else if Y > Height - 1 then
        Off := Height - 1
      else
        Off := Y;
      SetBandValue(CalcNumID(X), CalcBandValue(Off));
    end
    else if (fType = emPreAMP) and (ssRight in Shift) then
    begin
      if Y < 0 then
        Off := 0
      else if Y > Height - 1 then
        Off := Height - 1
      else
        Off := Y;
      fPreamp := CalcBandValue(Height - Off);
    end;
    Renderer;
  end;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited;
  if Assigned(fOnEnd) then
    fOnEnd(Self);
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.Paint;
begin
  inherited;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.Renderer;
var
  i: integer;
begin
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  if fSkin.Empty then
  begin
    fBuffer.Canvas.Brush.Style := bsClear;
    fBuffer.Canvas.Pen.Color := Color;
    fBuffer.Canvas.Brush.Color := Color;
    fBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  end;

  if fEnabled then
  begin
    if not fSkin.Empty then
    begin
      fBuffer.Canvas.Draw(0, 0, fSkin);
      if fDrawPreAmp then
      begin
        fBuffer.Canvas.Pen.Color := fMiddle;
        fBuffer.Canvas.Brush.Style := bsClear;
        fBuffer.Canvas.Pen.Style := psDot;
        fBuffer.Canvas.MoveTo(0, (Height - 1) - Trunc(CalcBandPosY(fPreamp)));
        fBuffer.Canvas.LineTo(Width,
          (Height - 1) - Trunc(CalcBandPosY(fPreamp)));
        fBuffer.Canvas.Pen.Style := psSolid;
        fBuffer.Canvas.Brush.Style := bsSolid;
      end;
      fBuffer.Canvas.Pen.Color := fCurveClr;

      fBuffer.Canvas.MoveTo(0, Trunc(CalcBandPosY(fEQItems[0])));
      for i := 0 to 17 do
      begin
        fBuffer.Canvas.LineTo(Trunc(CalcBandPosX(i)),
          Trunc(CalcBandPosY(fEQItems[i])));
      end;
    end;
  end
  else
  begin
    if not fSkin.Empty then
      fBuffer.Canvas.Draw(0, 0, fSkin);
  end;

  Canvas.Draw(0, 0, fBuffer);
end;

// ******************************************************************************
procedure TZMSGraphicEQ.ResetEQ;
var
  i: integer;
begin
  for i := 0 to 17 do
    SetBandValue(i, 0);
  fPreamp := 0;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.Resize;
begin
  inherited;

  if not fSkin.Empty then
  begin
    Width := fSkin.Width;
    Height := fSkin.Height;
  end;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetBandValue(NumID: integer; Value: Single);
begin
  if (NumID < 18) and (NumID >= 0) then
  begin
    fEQItems[NumID] := Value;
    if Assigned(fOnEQChange) then
      fOnEQChange(Self, NumID, Value, False);
  end;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetCurveClr(Value: TColor);
begin
  fCurveClr := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetEnable(Value: boolean);
begin
  fEnabled := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetDrawPreAmp(Value: boolean);
begin
  fDrawPreAmp := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetMax(Value: Single);
begin
  fMax := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetMiddleLineColor(Value: TColor);
begin
  fMiddle := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetPreamp(Value: Single);
begin
  if fPreamp < ((fMax / 2) - fMax) then
    fPreamp := ((fMax / 2) - fMax)
  else if fPreamp > (fMax / 2) then
    fPreamp := (fMax / 2)
  else
    fPreamp := Value;

  Renderer;
end;

// ******************************************************************************
procedure TZMSGraphicEQ.SetSkin(Value: TBitmap);
begin
  if Assigned(Value) then
    fSkin.Assign(Value)
  else
  begin
    fSkin.Width := 0;
    fSkin.Height := 0;
  end;

  Resize;
  Renderer;
end;

// ******************************************************************************
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSGraphicEQ]);
end;

end.
