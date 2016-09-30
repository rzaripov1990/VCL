unit MC_ArrowButton;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Winapi.Messages, Types, Vcl.Graphics;

type
  TArrowButtonType = (abtNone, abtLeft, abtTop, abtRight, abtBottom);
  TArrowButtonState = (absNormal, absHot, absDown);
  TArrowButtonBorder = (abbNone, abbRectangle, abbRound, abbCircle);

  TOnClickEx = procedure(Sender: TObject; const Button: TArrowButtonType; const State: TArrowButtonState) of object;

  TZMSArrowButton = class(TGraphicControl)
  private
    fBuffer: TBitmap;

    fButton: TArrowButtonType;
    fState: TArrowButtonState;
    fBorder: TArrowButtonBorder;
    fIndent: Byte;

    fOnClickEx: TOnClickEx;

    fBkgrColor: TColor;
    fBorderColor: TColor;
    fPenColor: TColor;
    fBrushColor: TColor;

    fHotBrushColor: TColor;
    fHotPenColor: TColor;

    fDownPenColor: TColor;
    fDownBrushColor: TColor;

    fMouseInClient: Boolean;

    fTransparent: Boolean;
    fTranparentColor: TColor;

    procedure SetMediaButton(const Value: TArrowButtonType);
    procedure SetBkgrColor(const Value: TColor);
    procedure SetBrushColor(const Value: TColor);
    procedure SetPenColor(const Value: TColor);
    procedure SetIndent(const Value: Byte);
    procedure SetButtonState(const Value: TArrowButtonState);
    procedure SetHotBrushColor(const Value: TColor);
    procedure SetHotPenColor(const Value: TColor);
    procedure SetDownBrushColor(const Value: TColor);
    procedure SetDownPenColor(const Value: TColor);
    procedure SetTransparent(const Value: Boolean);
    procedure SetTranparentColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderType(const Value: TArrowButtonBorder);

    { Private declarations }
  protected
    procedure Paint; override;
    procedure Resize; override;

    procedure CMMouseenter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseleave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure Click; override;
    procedure SetEnabled(Value: Boolean); override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Public declarations }
    procedure PaintTo(DC: TCanvas; X, Y: Integer);
  published
    { Published declarations }
    property Anchors;

    property ArrowButton: TArrowButtonType read fButton write SetMediaButton default abtNone;
    property ButtonState: TArrowButtonState read fState write SetButtonState default absNormal;
    property BorderType: TArrowButtonBorder read fBorder write SetBorderType default abbNone;

    property BkgrColor: TColor read fBkgrColor write SetBkgrColor default clBtnFace;
    property BorderColor: TColor read fBorderColor write SetBorderColor default clGray;

    property BrushColor: TColor read fBrushColor write SetBrushColor default clGray;
    property PenColor: TColor read fPenColor write SetPenColor default clLtGray;

    property HotBrushColor: TColor read fHotBrushColor write SetHotBrushColor;
    property HotPenColor: TColor read fHotPenColor write SetHotPenColor;

    property DownBrushColor: TColor read fDownBrushColor write SetDownBrushColor;
    property DownPenColor: TColor read fDownPenColor write SetDownPenColor;

    property Indent: Byte read fIndent write SetIndent default 3;

    property Transparent: Boolean read fTransparent write SetTransparent default true;
    property TransparentColor: TColor read fTranparentColor write SetTranparentColor default clFuchsia;

    property OnClickEx: TOnClickEx read fOnClickEx write fOnClickEx;

    property MouseInClient: Boolean read fMouseInClient;

    property Enabled;

    property OnClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSArrowButton]);
end;

{ TZMSArrowButton }

procedure TZMSArrowButton.Click;
begin
  if not Enabled then
    exit;

  inherited;
  if Assigned(fOnClickEx) then
    fOnClickEx(Self, fButton, fState);
end;

procedure TZMSArrowButton.CMMouseenter(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := true;
  fState := absHot;
  Paint;
  inherited;
end;

procedure TZMSArrowButton.CMMouseleave(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := false;
  fState := absNormal;
  Paint;
  inherited;
end;

constructor TZMSArrowButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 30;
  Height := 30;

  fBuffer := TBitmap.Create;
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  fIndent := 3;

  fButton := abtNone;
  fState := absNormal;
  fBorder := abbNone;

  fMouseInClient := false;

  fBkgrColor := clBtnFace;
  fBorderColor := clGray;

  fPenColor := clLtGray;
  fBrushColor := clGray;

  fHotBrushColor := clLtGray;
  fHotPenColor := clWhite;

  fDownBrushColor := clGray;
  fDownPenColor := clBlack;

  fTransparent := true;
  fTranparentColor := clFuchsia;
end;

destructor TZMSArrowButton.Destroy;
begin
  FreeAndNil(fBuffer);
  inherited;
end;

procedure TZMSArrowButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  fState := absDown;
  Paint;
  inherited;
end;

procedure TZMSArrowButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  inherited;

  if fMouseInClient then
    fState := absHot
  else
    fState := absNormal;
  Paint;
end;

procedure TZMSArrowButton.Paint;
var
  pnt1: array [0 .. 2] of TPoint;
begin
  inherited;

  fBuffer.Width := Width;
  fBuffer.Height := Height;

  with fBuffer.Canvas do
  begin
    Brush.Color := BkgrColor;
    Pen.Color := fBkgrColor;
    FillRect(ClientRect);

    Brush.Style := bsClear;
    case fBorder of
      abbNone:
        ;
      abbRectangle:
        begin
          Pen.Color := fBorderColor;
          Rectangle(ClientRect);
        end;
      abbRound:
        begin
          Pen.Color := fBorderColor;
          RoundRect(0, 0, Width, Height, 10, 10);
        end;
      abbCircle:
        begin
          Pen.Color := fBorderColor;
          Ellipse(0, 0, Width, Height);
        end;
    end;
    Brush.Style := bsSolid;
  end;

  case fButton of

    abtNone:
      ;

    abtLeft:
      begin
        with fBuffer.Canvas do
        begin
          pnt1[0].X := Width - (Width div 3) - fIndent * 2;
          pnt1[0].Y := Height - fIndent * 2;

          pnt1[1].X := fIndent * 2;
          pnt1[1].Y := Height div 2;

          pnt1[2].X := Width - (Width div 3) - fIndent * 2;
          pnt1[2].Y := fIndent * 2;

          case fState of
            absNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            absHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            absDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Rectangle(Width div 2, Height div 3, Width, Height - (Height div 3));
          Polygon(pnt1);

          case fState of
            absNormal:
              Pen.Color := Brush.Color;
            absHot:
              Pen.Color := Brush.Color;
            absDown:
              Pen.Color := Brush.Color;
          end;

          MoveTo(Width - (Width div 3) - fIndent * 2, Height div 3);
          LineTo(Width - (Width div 3) - fIndent * 2, Height - (Height div 3));
        end;
      end;

    abtRight:
      begin
        with fBuffer.Canvas do
        begin
          pnt1[0].X := (Width div 3) + fIndent * 2;
          pnt1[0].Y := fIndent * 2;

          pnt1[1].X := Width - (fIndent * 2);
          pnt1[1].Y := Height div 2;

          pnt1[2].X := (Width div 3) + (fIndent * 2);
          pnt1[2].Y := Width - (fIndent * 2);

          case fState of
            absNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            absHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            absDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Rectangle(0, (Height div 3), Width div 2, Height - (Height div 3));
          Polygon(pnt1);

          case fState of
            absNormal:
              Pen.Color := Brush.Color;
            absHot:
              Pen.Color := Brush.Color;
            absDown:
              Pen.Color := Brush.Color;
          end;

          MoveTo((Width div 3) + fIndent * 2, Height div 3);
          LineTo((Width div 3) + fIndent * 2, Height - (Height div 3));
        end;

      end;
  end;

  if Transparent then
  begin
    fBuffer.TransparentColor := fTranparentColor;
    fBuffer.Transparent := true;
    Canvas.Brush.Style := bsClear;
  end
  else
  begin
    fBuffer.Transparent := false;
    Canvas.Brush.Style := bsSolid;
  end;

  Canvas.Draw(0, 0, fBuffer);
end;

procedure TZMSArrowButton.PaintTo(DC: TCanvas; X, Y: Integer);
begin
  DC.Draw(X, Y, fBuffer);
end;

procedure TZMSArrowButton.Resize;
begin
  inherited;
  if Width <> Height then
    Height := Width;
end;

procedure TZMSArrowButton.SetBkgrColor(const Value: TColor);
begin
  if fBkgrColor <> Value then
  begin
    fBkgrColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetBorderType(const Value: TArrowButtonBorder);
begin
  if fBorder <> Value then
  begin
    fBorder := Value;
    Invalidate;
  end;
end;

procedure TZMSArrowButton.SetBrushColor(const Value: TColor);
begin
  if fBrushColor <> Value then
  begin
    fBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetButtonState(const Value: TArrowButtonState);
begin
  if fState <> Value then
  begin
    fState := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetDownBrushColor(const Value: TColor);
begin
  if fDownBrushColor <> Value then
  begin
    fDownBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetDownPenColor(const Value: TColor);
begin
  if fDownPenColor <> Value then
  begin
    fDownPenColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetEnabled(Value: Boolean);
begin
  inherited;
  fState := absNormal;
  Paint;
end;

procedure TZMSArrowButton.SetHotBrushColor(const Value: TColor);
begin
  if fHotBrushColor <> Value then
  begin
    fHotBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetHotPenColor(const Value: TColor);
begin
  if fHotPenColor <> Value then
  begin
    fHotPenColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetIndent(const Value: Byte);
begin
  if fIndent <> Value then
  begin
    fIndent := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetPenColor(const Value: TColor);
begin
  if fPenColor <> Value then
  begin
    fPenColor := Value;
    Paint
  end;
end;

procedure TZMSArrowButton.SetTranparentColor(const Value: TColor);
begin
  if fTranparentColor <> Value then
  begin
    fTranparentColor := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetTransparent(const Value: Boolean);
begin
  if fTransparent <> Value then
  begin
    fTransparent := Value;
    Paint;
  end;
end;

procedure TZMSArrowButton.SetMediaButton(const Value: TArrowButtonType);
begin
  if fButton <> Value then
  begin
    fButton := Value;
    Invalidate;
  end;
end;

end.
