unit MC_MediaSlider;

interface

uses
  // Windows, SysUtils, Classes, Controls, Messages, Graphics;
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls,
  Winapi.Messages, Types, Vcl.Graphics;

type
  TTrackingPos = procedure(Sender: TObject; const Position: Single; const SetPosition: boolean) of object;
  TMediaSliderType = (mstSlider, mstProgress);
  TMediaSliderKind = (mskHorizontal, mskVertical);
  TMediaRenderMode = (mrmNormal, mrmRevers, mrmCenter, mrmCenterRevers);
  TMediaSliderBorder = (msbNone, msbRectangle, msbRound);

  TZMSMediaSlider = class(TGraphicControl)
  private
    { Private declarations }
    fBuffer: TBitmap;

    fMouseinClient: boolean;
    fMouseDown: boolean;

    fBkgrColor: TColor;
    fBorderColor: TColor;
    fPenColor: TColor;
    fBrushColor: TColor;

    fHotBrushColor: TColor;
    fHotPenColor: TColor;

    fRenderer: TMediaRenderMode;
    fBorderType: TMediaSliderBorder;
    fSliderThumb: TMediaSliderType;
    fSliderKind: TMediaSliderKind;

    fTransparent: boolean;
    fTransparentColor: TColor;

    fIndent: Integer;

    fThumbSize: Single;
    fLength: Single;
    fPosInLen: Single;

    fMax: Single;
    fMin: Single;
    fPosition: Single;

    fOnEnd: TNotifyEvent;
    fOnRightClick: TNotifyEvent;
    fOnTracking: TTrackingPos;
    fOnStartTracking: TTrackingPos;
    fOnEndTracking: TTrackingPos;

    fCenterPos: Single;
    fCenterStop: boolean;

    fSnapActive: boolean;
    fSnapPosition: Single;
    fSnapBuffer: Single;
    fSnapPosInLen: Single;

    fWorkingArea: Single;
    fDrawPos: Single;
    fWorkingAreaCentre: Single;

    procedure CalculateLen;
    procedure CalculatePos(BufPos: Single);

    procedure SetRenderer(Value: TMediaRenderMode);

    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(Value: TColor);

    procedure SetSnapActive(Value: boolean);
    procedure SetSnapPosition(Value: Single);
    procedure SetSnapBuffer(Value: Single);

    procedure SetSliderKind(Value: TMediaSliderKind);
    procedure SetSliderThumb(Value: TMediaSliderType);

    procedure SetMax(Value: Single);
    procedure SetMin(Value: Single);
    procedure SetPosition(Value: Single);
    procedure SetBkgrColor(const Value: TColor);
    procedure SetBrushColor(const Value: TColor);
    procedure SetHotBrushColor(const Value: TColor);
    procedure SetHotPenColor(const Value: TColor);
    procedure SetPenColor(const Value: TColor);
    procedure SetBorderType(const Value: TMediaSliderBorder);
    procedure SetBorderColor(const Value: TColor);
    procedure SetIndent(const Value: Integer);
    procedure SetThumbsize(const Value: Single);
  protected
    { Protected declarations }

    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PaintTo(DC: TCanvas; X, Y: Integer);
  published
    { Published declarations }
    property Anchors;

    property BkgrColor: TColor read fBkgrColor write SetBkgrColor default clBtnFace;
    property BorderColor: TColor read fBorderColor write SetBorderColor default clGray;
    property BorderType: TMediaSliderBorder read fBorderType write SetBorderType default msbNone;

    property BrushColor: TColor read fBrushColor write SetBrushColor default clGray;
    property PenColor: TColor read fPenColor write SetPenColor default clLtGray;

    property HotBrushColor: TColor read fHotBrushColor write SetHotBrushColor;
    property HotPenColor: TColor read fHotPenColor write SetHotPenColor;

    property Max: Single read fMax write SetMax;
    property Min: Single read fMin write SetMin;
    property Position: Single read fPosition write SetPosition;

    property Indent: Integer read fIndent write SetIndent default 0;
    property ThumbSize: Single read fThumbSize write SetThumbsize;

    property CenterPos: Single read fCenterPos write fCenterPos;
    property CenterStop: boolean read fCenterStop write fCenterStop default false;

    property SnapActive: boolean read fSnapActive write SetSnapActive default false;
    property SnapPosition: Single read fSnapPosition write SetSnapPosition;
    property SnapBuffer: Single read fSnapBuffer write SetSnapBuffer;

    property SliderKind: TMediaSliderKind read fSliderKind write SetSliderKind default mskHorizontal;
    property SliderThumb: TMediaSliderType read fSliderThumb write SetSliderThumb default mstSlider;

    property RenderMode: TMediaRenderMode read fRenderer write SetRenderer default mrmNormal;

    property Transparent: boolean read fTransparent write SetTransparent default false;
    property TransparentColor: TColor read fTransparentColor write SetTransparentColor default clfuchsia;

    property OnTracking: TTrackingPos read fOnTracking write fOnTracking;
    property OnStartTracking: TTrackingPos read fOnStartTracking write fOnStartTracking;
    property OnEndTracking: TTrackingPos read fOnEndTracking write fOnEndTracking;
    property OnEnd: TNotifyEvent read fOnEnd write fOnEnd;
    property OnRightClick: TNotifyEvent read fOnRightClick write fOnRightClick;

    property MouseInClient: boolean read fMouseinClient;
    property MouseLBDown: boolean read fMouseDown;

    property Enabled;

    property Hint;
    property ShowHint;
    property Color default clWhite;
    property Cursor default crHandPoint;
    property Visible;
    property PopupMenu;
  end;

procedure Register;

implementation

function vMin(const A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function vMax(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

// ******************************************************************************
procedure TZMSMediaSlider.CalculateLen;
begin
  if fPosition < fMin then
    fPosition := fMin
  else if fPosition > fMax then
    fPosition := fMax;

  if fSnapPosition < fMin then
    fSnapPosition := fMin
  else if fSnapPosition > fMax then
    fSnapPosition := fMax;

  if fSliderKind = mskHorizontal then
  begin
    if fSliderThumb = mstSlider then
      fWorkingArea := Width - fThumbSize
    else
      fWorkingArea := Width;
  end
  else
  begin
    if fSliderThumb = mstSlider then
      fWorkingArea := Height - fThumbSize
    else
      fWorkingArea := Height;
  end;

  if (fMin = 0) and (fMax = 0) then
  begin
    fLength := 0;
    fPosInLen := 0;
    fSnapPosInLen := 0;
  end
  else if (fMin < 0) and (fMax < 0) and (fMax > fMin) then
  begin
    fLength := ABS(fMin) - ABS(fMax);
    fPosInLen := ABS(fMin) - ABS(fPosition);
    fSnapPosInLen := ABS(fMin) - ABS(fSnapPosition);
  end
  else if (fMin < 0) and (fMax >= 0) then
  begin
    fLength := ABS(fMin) + fMax;

    if fPosition < 0 then
      fPosInLen := fLength - (ABS(fPosition) + fMax)
    else
      fPosInLen := ABS(fMin) + fPosition;

    if fSnapPosition < 0 then
      fSnapPosInLen := fLength - (ABS(fSnapPosition) + fMax)
    else
      fSnapPosInLen := ABS(fMin) + fSnapPosition;
  end
  else if (fMin >= 0) and (fMax > fMin) then
  begin
    fLength := fMax - fMin;
    fPosInLen := ABS(fMin - fPosition);
    fSnapPosInLen := ABS(fMin - fSnapPosition);
  end;

  if fWorkingArea > 0 then
  begin
    fWorkingAreaCentre := MulDiv(Trunc(fWorkingArea), Trunc(fSnapPosInLen), Trunc(fLength));
    fDrawPos := MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen), Trunc(fLength));
  end
  else
  begin
    fDrawPos := 0;
    fWorkingAreaCentre := 0;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.CalculatePos(BufPos: Single);
var
  PosBufferNew: Single;
begin
  CalculateLen;

  if BufPos < 0 then
    PosBufferNew := 0
  else if BufPos > fWorkingArea then
    PosBufferNew := fWorkingArea
  else
    PosBufferNew := BufPos;

  fPosInLen := MulDiv(Trunc(fLength), Trunc(PosBufferNew), Trunc(fWorkingArea));

  if (fRenderer <> mrmNormal) and (fRenderer <> mrmCenter) then
    fPosition := (fMin + fMax) - (fMin + fPosInLen)
  else
    fPosition := fMin + fPosInLen;

  if fWorkingArea > 0 then
    fDrawPos := MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen), Trunc(fLength))
  else
    fDrawPos := 0;

  if fSnapActive then
  begin
    if (fPosition < (fSnapPosition + fSnapBuffer)) and (fPosition > (fSnapPosition - fSnapBuffer)) then
    begin
      fPosition := fSnapPosition;
      CalculateLen;
    end;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  fMouseinClient := True;
  Invalidate;
end;
// ******************************************************************************

procedure TZMSMediaSlider.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  fMouseinClient := false;
  Invalidate;
end;
// ******************************************************************************

constructor TZMSMediaSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fTransparent := false;
  fTransparentColor := clfuchsia;
  Cursor := crHandPoint;

  fCenterPos := 0;
  fCenterStop := false;

  fWorkingAreaCentre := 0;

  fBkgrColor := clBtnFace;
  fBorderColor := clGray;

  fPenColor := clLtGray;
  fBrushColor := clGray;

  fHotBrushColor := clLtGray;
  fHotPenColor := clWhite;

  fBuffer := TBitmap.Create;

  fThumbSize := 10;
  fMax := 0;
  fMin := 0;
  fPosition := 0;
  fIndent := 0;

  fRenderer := mrmNormal;
  fBorderType := msbNone;

  fLength := 100;
  fPosInLen := 0;

  fSnapActive := false;
  fSnapPosition := 0;
  fSnapBuffer := 3;
  fSnapPosInLen := 0;

  fSliderThumb := mstSlider;
  fSliderKind := mskHorizontal;

  Resize;
end;
// ******************************************************************************

destructor TZMSMediaSlider.Destroy;
begin
  freeAndNil(fBuffer);
  inherited;
end;
// ******************************************************************************

procedure TZMSMediaSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Button = mbRight then
  begin
    if (fCenterStop) then
    begin
      Position := fCenterPos;
      if Assigned(fOnRightClick) then
        fOnRightClick(self);
    end;
    Invalidate;
    exit;
  end
  else
  begin
    if Button <> mbLeft then
      exit;
  end;

  fMouseDown := True;

  if Enabled then
  begin
    if fSliderKind = mskHorizontal then
    begin
      if fSliderThumb = mstSlider then
      begin
        CalculatePos(X - (fThumbSize / 2));
        if Assigned(fOnStartTracking) then
          fOnStartTracking(self, fPosition, false);
      end
      else
      begin
        CalculatePos(X);
        if Assigned(fOnStartTracking) then
          fOnStartTracking(self, fPosition, false);
      end;
    end
    else // Vertical ------------------------------------------------------
    begin
      if fSliderThumb = mstSlider then
      begin
        CalculatePos(Y - (fThumbSize / 2));
        if Assigned(fOnStartTracking) then
          fOnStartTracking(self, fPosition, false);
      end
      else
      begin
        CalculatePos(Y);
        if Assigned(fOnStartTracking) then
          fOnStartTracking(self, fPosition, false);
      end;
    end;
  end;

  Invalidate;
end;
// ******************************************************************************

procedure TZMSMediaSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Enabled then
  begin
    if fMouseDown then
    begin
      if fSliderKind = mskHorizontal then
      begin
        if fSliderThumb = mstSlider then
        begin
          CalculatePos(X - (fThumbSize / 2));
          if Assigned(fOnTracking) then
            fOnTracking(self, fPosition, false)
        end
        else
        begin
          CalculatePos(X);
          if Assigned(fOnTracking) then
            fOnTracking(self, fPosition, false)
        end;
      end
      else // Vertical -----------------------
      begin
        if fSliderThumb = mstSlider then
        begin
          CalculatePos(Y - (fThumbSize / 2));
          if Assigned(fOnTracking) then
            fOnTracking(self, fPosition, false);
        end
        else
        begin
          CalculatePos(Y);
          if Assigned(fOnTracking) then
            fOnTracking(self, fPosition, false);
        end;
      end
    end;
  end;

  Invalidate;
end;
// ******************************************************************************

procedure TZMSMediaSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Button <> mbLeft then
    exit;
  if fMouseDown then
    fMouseDown := false
  else
    exit;

  if Enabled then
  begin
    if fSliderKind = mskHorizontal then
    begin
      if fSliderThumb = mstSlider then
        CalculatePos(X - (fThumbSize / 2))
      else
        CalculatePos(X);
    end
    else
    begin
      if fSliderThumb = mstSlider then
        CalculatePos(Y - (fThumbSize / 2))
      else
        CalculatePos(Y);
    end;

    if Assigned(fOnEndTracking) then
      fOnEndTracking(self, fPosition, false);
  end;

  Invalidate;
end;
// ******************************************************************************

procedure TZMSMediaSlider.Paint;
begin
  inherited;
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  CalculateLen;

  with fBuffer.Canvas do
  begin
    Brush.Color := BkgrColor;
    Pen.Color := fBkgrColor;
    FillRect(ClientRect);

    Brush.Style := bsClear;
    case fBorderType of
      msbNone:
        ;
      msbRectangle:
        begin
          Pen.Color := fBorderColor;
          Rectangle(ClientRect);
        end;
      msbRound:
        begin
          Pen.Color := fBorderColor;
          RoundRect(0, 0, Width, Height, 5, 5);
        end;
    end;
    Brush.Style := bsSolid;
  end;

  case fSliderKind of
    mskHorizontal:
      case fSliderThumb of
        mstSlider:
          begin
            with fBuffer.Canvas do
            begin
              if not fMouseinClient then
              begin
                Brush.Color := fBrushColor;
                Pen.Color := fPenColor;
              end
              else
              begin
                Brush.Color := fHotBrushColor;
                Pen.Color := fHotPenColor;
              end;

              MoveTo(Trunc(fThumbSize / 2), (fBuffer.Height) div 2);
              LineTo(Width - Trunc(fThumbSize / 2), (fBuffer.Height) div 2);

              if Enabled then
              begin
                case fRenderer of
                  mrmNormal, mrmCenter:
                    RoundRect(Trunc(fDrawPos) + fIndent, fIndent, Trunc(fDrawPos + fThumbSize) - fIndent,
                      Height - fIndent, 10, 10);
                else
                  RoundRect(Width - Trunc(fDrawPos) - fIndent, fIndent, Width - Trunc(fDrawPos + fThumbSize) + fIndent,
                    Height - fIndent, 10, 10);
                end;
              end;
            end;
          end;

        mstProgress:
          begin
            with fBuffer.Canvas do
            begin
              if not fMouseinClient then
              begin
                Brush.Color := fBrushColor;
                Pen.Color := fPenColor;
              end
              else
              begin
                Brush.Color := fHotBrushColor;
                Pen.Color := fHotPenColor;
              end;

              if Enabled then
              begin
                case fRenderer of
                  mrmNormal:
                    RoundRect(fIndent, fIndent, vMax(fIndent, Trunc(fDrawPos) - fIndent), Height - fIndent, 10, 10);
                  mrmRevers:
                    RoundRect(Trunc(fWorkingArea) - fIndent, fIndent,
                      vMax(fIndent, Trunc(fWorkingArea - fDrawPos) - fIndent), Height - fIndent, 10, 10);
                  mrmCenter:
                    RoundRect(Trunc(fWorkingAreaCentre) - fIndent, fIndent, vMax(fIndent, Trunc(fDrawPos) - fIndent),
                      Height - fIndent, 10, 10);
                  mrmCenterRevers:
                    RoundRect(Trunc(fWorkingAreaCentre) - fIndent, fIndent,
                      vMax(fIndent, Trunc(fWorkingArea - fDrawPos) - fIndent), Height - fIndent, 10, 10);
                end;
              end;
            end;
          end;
      end;

    mskVertical:
      case fSliderThumb of
        mstSlider:
          begin
            with fBuffer.Canvas do
            begin
              if not fMouseinClient then
              begin
                Brush.Color := fBrushColor;
                Pen.Color := fPenColor;
              end
              else
              begin
                Brush.Color := fHotBrushColor;
                Pen.Color := fHotPenColor;
              end;

              MoveTo((fBuffer.Width) div 2, Trunc(fThumbSize / 2));
              LineTo((fBuffer.Width) div 2, Height - Trunc(fThumbSize / 2));

              if Enabled then
              begin
                case fRenderer of
                  mrmNormal, mrmCenter:
                    RoundRect(fIndent, Trunc(fDrawPos) + fIndent, Width - fIndent,
                      Trunc((fDrawPos + fThumbSize)) - fIndent, 10, 10);
                else
                  RoundRect(fIndent, Trunc(Height - fDrawPos) - fIndent, Width - fIndent,
                    (Height - Trunc(fDrawPos + fThumbSize)) + fIndent, 10, 10);
                end;
              end;
            end;
          end;

        mstProgress:
          begin
            with fBuffer.Canvas do
            begin
              if not fMouseinClient then
              begin
                Brush.Color := fBrushColor;
                Pen.Color := fPenColor;
              end
              else
              begin
                Brush.Color := fHotBrushColor;
                Pen.Color := fHotPenColor;
              end;

              if Enabled then
              begin
                case fRenderer of
                  mrmNormal:
                    RoundRect(fIndent, fIndent, Width - fIndent, vMax(fIndent, Trunc(fDrawPos - fIndent)), 10, 10);
                  mrmRevers:
                    RoundRect(fIndent, Trunc(Height - fIndent), Width - fIndent,
                      vMin(Trunc(fWorkingArea - fIndent), Trunc(Height - (fDrawPos - fIndent))), 10, 10);
                  mrmCenter:
                    RoundRect(fIndent, Trunc(fWorkingAreaCentre + fIndent), Width - fIndent,
                      vMax(fIndent, Trunc(fDrawPos - fIndent)), 10, 10);
                  mrmCenterRevers:
                    RoundRect(fIndent, Trunc(fWorkingAreaCentre + fIndent), Width - fIndent,
                      vMax(fIndent, Trunc(fWorkingArea - fDrawPos) - fIndent), 10, 10);
                end;
              end;
            end;
          end;
      end;
  end;

  if Transparent then
  begin
    fBuffer.TransparentColor := fBkgrColor;
    fBuffer.Transparent := True;
    Canvas.Brush.Style := bsClear;
  end
  else
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := fBkgrColor;
    Canvas.FillRect(ClientRect);
  end;

  Canvas.Draw(0, 0, fBuffer);
end;
// ******************************************************************************

procedure TZMSMediaSlider.PaintTo(DC: TCanvas; X, Y: Integer);
begin
  DC.Draw(X, Y, fBuffer);
end;
// ******************************************************************************

procedure TZMSMediaSlider.Loaded;
begin
  inherited;
  Resize;
end;
// ******************************************************************************

procedure TZMSMediaSlider.Resize;
begin
  inherited;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetBkgrColor(const Value: TColor);
begin
  if fBkgrColor <> Value then
  begin
    fBkgrColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetBorderType(const Value: TMediaSliderBorder);
begin
  if fBorderType <> Value then
  begin
    fBorderType := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetBrushColor(const Value: TColor);
begin
  if fBrushColor <> Value then
  begin
    fBrushColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetHotBrushColor(const Value: TColor);
begin
  if fHotBrushColor <> Value then
  begin
    fHotBrushColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetHotPenColor(const Value: TColor);
begin
  if fHotPenColor <> Value then
  begin
    fHotPenColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetIndent(const Value: Integer);
begin
  if fIndent <> Value then
  begin
    fIndent := Value;
    Invalidate;
  end;
end;

// ******************************************************************************

procedure TZMSMediaSlider.SetMax(Value: Single);
begin
  if fMax <> Value then
  begin
    if Value >= fMin then
      fMax := Value
    else if Value < fMin then
    begin
      fMin := Value - 1;
      fMax := Value;
    end;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetMin(Value: Single);
begin
  if fMin <> Value then
  begin
    if Value <= fMax then
      fMin := Value
    else if Value > fMax then
    begin
      fMax := Value + 1;
      fMin := Value;
    end;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetPenColor(const Value: TColor);
begin
  if fPenColor <> Value then
  begin
    fPenColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetPosition(Value: Single);
begin
  fPosition := Value;
  Invalidate;

  if Assigned(fOnEnd) then
  begin
    if ((fMax <> 0) and (fPosition <> 0)) and (fPosition >= fMax) then
    begin
      fOnEnd(self);
      exit;
    end;
  end;

  if Assigned(fOnEndTracking) then // fOnTracking
    fOnEndTracking(self, fPosition, True);
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetRenderer(Value: TMediaRenderMode);
begin
  if fRenderer <> Value then
  begin
    fRenderer := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetSnapActive(Value: boolean);
begin
  fSnapActive := Value;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetSnapBuffer(Value: Single);
begin
  fSnapBuffer := Value;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetSnapPosition(Value: Single);
begin
  fSnapPosition := Value;
  CalculateLen;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetSliderKind(Value: TMediaSliderKind);
begin
  if fSliderKind <> Value then
  begin
    fSliderKind := Value;
    Bounds(Left, Top, Height, Width);
    Resize;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetSliderThumb(Value: TMediaSliderType);
begin
  fSliderThumb := Value;
  CalculateLen;
  Invalidate;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetThumbsize(const Value: Single);
begin
  if fThumbSize <> Value then
  begin
    fThumbSize := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetTransparent(Value: boolean);
begin
  if fTransparent <> Value then
  begin
    fTransparent := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure TZMSMediaSlider.SetTransparentColor(Value: TColor);
begin
  if fTransparentColor <> Value then
  begin
    fTransparentColor := Value;
    Invalidate;
  end;
end;
// ******************************************************************************

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSMediaSlider]);
end;
// ******************************************************************************

end.
