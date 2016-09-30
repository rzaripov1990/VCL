unit MC_MediaButton;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Winapi.Messages, Types, Vcl.Graphics;

type
  TMediaButtonType = (mbtNone, mbtPlay, mbtPause, mbtStop, mbtPrevious, mbtNext, mbtOpen);
  TMediaButtonState = (mbsNormal, mbsHot, mbsDown);
  TMediaButtonBorder = (mbbNone, mbbRectangle, mbbRound, mbbCircle);

  TOnClickEx = procedure(Sender: TObject; const Button: TMediaButtonType; const State: TMediaButtonState) of object;

  TZMSMediaButton = class(TGraphicControl)
  private
    fBuffer: TBitmap;

    fButton: TMediaButtonType;
    fState: TMediaButtonState;
    fBorder: TMediaButtonBorder;
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

    procedure SetMediaButton(const Value: TMediaButtonType);
    procedure SetBkgrColor(const Value: TColor);
    procedure SetBrushColor(const Value: TColor);
    procedure SetPenColor(const Value: TColor);
    procedure SetIndent(const Value: Byte);
    procedure SetButtonState(const Value: TMediaButtonState);
    procedure SetHotBrushColor(const Value: TColor);
    procedure SetHotPenColor(const Value: TColor);
    procedure SetDownBrushColor(const Value: TColor);
    procedure SetDownPenColor(const Value: TColor);
    procedure SetTransparent(const Value: Boolean);
    procedure SetTranparentColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderType(const Value: TMediaButtonBorder);

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

    property MediaButton: TMediaButtonType read fButton write SetMediaButton default mbtNone;
    property ButtonState: TMediaButtonState read fState write SetButtonState default mbsNormal;
    property BorderType: TMediaButtonBorder read fBorder write SetBorderType default mbbNone;

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
  RegisterComponents('ZMSystem', [TZMSMediaButton]);
end;

{ TZMSMediaButton }

procedure TZMSMediaButton.Click;
begin
  if not Enabled then
    exit;

  inherited;
  if Assigned(fOnClickEx) then
    fOnClickEx(Self, fButton, fState);
end;

procedure TZMSMediaButton.CMMouseenter(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := true;
  fState := mbsHot;
  Paint;
  inherited;
end;

procedure TZMSMediaButton.CMMouseleave(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := false;
  fState := mbsNormal;
  Paint;
  inherited;
end;

constructor TZMSMediaButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 30;
  Height := 30;

  fBuffer := TBitmap.Create;
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  fIndent := 3;

  fButton := mbtNone;
  fState := mbsNormal;
  fBorder := mbbNone;

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

destructor TZMSMediaButton.Destroy;
begin
  FreeAndNil(fBuffer);
  inherited;
end;

procedure TZMSMediaButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  fState := mbsDown;
  Paint;
  inherited;
end;

procedure TZMSMediaButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  inherited;

  if fMouseInClient then
    fState := mbsHot
  else
    fState := mbsNormal;
  Paint;
end;

procedure TZMSMediaButton.Paint;
var
  pnt1, pnt2: array [0 .. 2] of TPoint;
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
      mbbNone:
        ;
      mbbRectangle:
        begin
          Pen.Color := fBorderColor;
          Rectangle(ClientRect);
        end;
      mbbRound:
        begin
          Pen.Color := fBorderColor;
          RoundRect(0, 0, Width, Height, 10, 10);
        end;
      mbbCircle:
        begin
          Pen.Color := fBorderColor;
          Ellipse(0, 0, Width, Height);
        end;
    end;
    Brush.Style := bsSolid;
  end;

  case fButton of

    mbtNone:
      ;

    mbtPlay:
      begin
        with fBuffer.Canvas do
        begin
          pnt1[0].X := fIndent;
          pnt1[0].Y := fIndent;

          pnt1[1].X := Width - fIndent;
          pnt1[1].Y := Height div 2;

          pnt1[2].X := fIndent;
          pnt1[2].Y := Height - fIndent;

          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Polygon(pnt1);
        end;
      end;

    mbtPause:
      begin
        with fBuffer.Canvas do
        begin
          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Rectangle(Rect((Width div 2) - fIndent, fIndent, fIndent, Height - fIndent));
          Rectangle(Rect(Width - fIndent, fIndent, (Width div 2) + fIndent, Height - fIndent));
        end;
      end;

    mbtStop:
      begin
        with fBuffer.Canvas do
        begin
          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Rectangle(Rect(fIndent, fIndent, Width - fIndent, Height - fIndent));
        end;
      end;

    mbtPrevious:
      begin
        pnt1[0].X := Width - fIndent;
        pnt1[0].Y := Height - fIndent;

        pnt1[1].X := fIndent;
        pnt1[1].Y := Height div 2;

        pnt1[2].X := Width - fIndent;
        pnt1[2].Y := fIndent;

        pnt2[0].X := Width - (Width div 3);
        pnt2[0].Y := Height - fIndent;

        pnt2[1].X := fIndent;
        pnt2[1].Y := Height div 2;

        pnt2[2].X := Width - (Width div 3);
        pnt2[2].Y := fIndent;

        with fBuffer.Canvas do
        begin
          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Polygon(pnt1);
          Polygon(pnt2);

          case fState of
            mbsNormal:
              Pen.Color := fBrushColor;
            mbsHot:
              Pen.Color := fHotBrushColor;
            mbsDown:
              Pen.Color := fDownBrushColor;
          end;

          MoveTo(Width - (Width div 3), (Height div 2) - (Height div 3));
          LineTo(Width - (Width div 3), Height - ((Height div 2) - (Height div 3)));
        end;

      end;

    mbtNext:
      begin
        pnt1[0].X := fIndent;
        pnt1[0].Y := fIndent;

        pnt1[1].X := Width - fIndent;
        pnt1[1].Y := Height div 2;

        pnt1[2].X := fIndent;
        pnt1[2].Y := Width - fIndent;

        pnt2[0].X := Width div 3;
        pnt2[0].Y := fIndent;

        pnt2[1].X := Width - fIndent;
        pnt2[1].Y := Height div 2;

        pnt2[2].X := Width div 3;
        pnt2[2].Y := Width - fIndent;

        with fBuffer.Canvas do
        begin
          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Polygon(pnt1);
          Polygon(pnt2);

          case fState of
            mbsNormal:
              Pen.Color := fBrushColor;
            mbsHot:
              Pen.Color := fHotBrushColor;
            mbsDown:
              Pen.Color := fDownBrushColor;
          end;

          MoveTo(Width div 3, (Height div 2) - (Height div 3));
          LineTo(Width div 3, Height - ((Height div 2) - (Height div 3)));
        end;
      end;

    mbtOpen:
      begin
        pnt1[0].X := fIndent;
        pnt1[0].Y := Height - (Height div 3);

        pnt1[1].X := Width div 2;
        pnt1[1].Y := fIndent;

        pnt1[2].X := Width - fIndent;
        pnt1[2].Y := Height - (Height div 3);

        with fBuffer.Canvas do
        begin
          case fState of
            mbsNormal:
              begin
                Brush.Color := BrushColor;
                Pen.Color := fPenColor;
              end;
            mbsHot:
              begin
                Brush.Color := HotBrushColor;
                Pen.Color := fHotPenColor;
              end;
            mbsDown:
              begin
                Brush.Color := DownBrushColor;
                Pen.Color := fDownPenColor;
              end;
          end;

          Polygon(pnt1);
          Rectangle(Rect(fIndent, Height - (Height div 3) + fIndent, Width - (fIndent - 1), Height - fIndent));
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

procedure TZMSMediaButton.PaintTo(DC: TCanvas; X, Y: Integer);
begin
  DC.Draw(X, Y, fBuffer);
end;

procedure TZMSMediaButton.Resize;
begin
  inherited;
  if Width <> Height then
    Height := Width;
end;

procedure TZMSMediaButton.SetBkgrColor(const Value: TColor);
begin
  if fBkgrColor <> Value then
  begin
    fBkgrColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetBorderType(const Value: TMediaButtonBorder);
begin
  if fBorder <> Value then
  begin
    fBorder := Value;
    Invalidate;
  end;
end;

procedure TZMSMediaButton.SetBrushColor(const Value: TColor);
begin
  if fBrushColor <> Value then
  begin
    fBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetButtonState(const Value: TMediaButtonState);
begin
  if fState <> Value then
  begin
    fState := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetDownBrushColor(const Value: TColor);
begin
  if fDownBrushColor <> Value then
  begin
    fDownBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetDownPenColor(const Value: TColor);
begin
  if fDownPenColor <> Value then
  begin
    fDownPenColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetEnabled(Value: Boolean);
begin
  inherited;
  fState := mbsNormal;
  Paint;
end;

procedure TZMSMediaButton.SetHotBrushColor(const Value: TColor);
begin
  if fHotBrushColor <> Value then
  begin
    fHotBrushColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetHotPenColor(const Value: TColor);
begin
  if fHotPenColor <> Value then
  begin
    fHotPenColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetIndent(const Value: Byte);
begin
  if fIndent <> Value then
  begin
    fIndent := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetPenColor(const Value: TColor);
begin
  if fPenColor <> Value then
  begin
    fPenColor := Value;
    Paint
  end;
end;

procedure TZMSMediaButton.SetTranparentColor(const Value: TColor);
begin
  if fTranparentColor <> Value then
  begin
    fTranparentColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetTransparent(const Value: Boolean);
begin
  if fTransparent <> Value then
  begin
    fTransparent := Value;
    Paint;
  end;
end;

procedure TZMSMediaButton.SetMediaButton(const Value: TMediaButtonType);
begin
  if fButton <> Value then
  begin
    fButton := Value;
    Invalidate;
  end;
end;

end.
