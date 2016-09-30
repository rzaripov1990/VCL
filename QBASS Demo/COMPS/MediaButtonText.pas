unit MediaButtonText;

interface

uses
//  Windows, SysUtils, Classes, Controls, Messages, Types, Graphics;
    Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Winapi.Messages, Types, Vcl.Graphics;

type
  TMediaButtonState = (mbsNormal, mbsHot, mbsDown);
  TMediaButtonMode = (mbmNormal, mbmChecked);
  TMediaButtonBorder = (mbbNone, mbbRectangle, mbbRound, mbbCircle);

  TOnClickEx = procedure(Sender: TObject; const Checked: boolean; const State: TMediaButtonState) of object;

  TZMSMediaButtonText = class(TGraphicControl)
  private
    fBuffer: TBitmap;

    fState: TMediaButtonState;
    fMode: TMediaButtonMode;
    fBorder: TMediaButtonBorder;

    fAlignment: TAlignment;

    fChecked: boolean;

    fOnClickEx: TOnClickEx;

    fBkgrColor: TColor;
    fBorderColor: TColor;

    fNormalFont: TFont;
    fHotFont: TFont;
    fDownFont: TFont;
    fCheckedFont: TFont;

    fMouseInClient: boolean;

    fTransparent: boolean;

    procedure SetButtonState(const Value: TMediaButtonState);
    procedure SetTransparent(const Value: boolean);
    procedure SetBkgrColor(const Value: TColor);
    procedure SetDownFont(const Value: TFont);
    procedure SetHotFont(const Value: TFont);
    procedure SetNormalFont(const Value: TFont);

    procedure FontChanged(Sender: TObject);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetChecked(const Value: boolean);
    procedure SetCheckedFont(const Value: TFont);
    procedure SetButtonMode(const Value: TMediaButtonMode);
    procedure SetBorderType(const Value: TMediaButtonBorder);
    procedure SetBorderColor(const Value: TColor);
    { Private declarations }
  protected
    procedure Paint; override;
    procedure Resize; override;

    procedure CMMouseenter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseleave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure Click; override;
    procedure SetEnabled(Value: boolean); override;
    procedure SetAutoSize(Value: boolean); override;
    procedure CMTextchanged(var Message: TMessage); message CM_TEXTCHANGED;

    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Public declarations }
    procedure PaintTo(DC: TCanvas; X, Y: Integer);
  published
    { Published declarations }

    property Caption;
        property Anchors;

    property Alignment: TAlignment read fAlignment write SetAlignment default taLeftJustify;

    property ButtonState: TMediaButtonState read fState write SetButtonState default mbsNormal;
    property ButtonMode: TMediaButtonMode read fMode write SetButtonMode default mbmNormal;
    property BorderType: TMediaButtonBorder read fBorder write SetBorderType default mbbNone;

    property BkgrColor: TColor read fBkgrColor write SetBkgrColor default clBtnFace;
    property BorderColor: TColor read fBorderColor write SetBorderColor default clGray;

    property Transparent: boolean read fTransparent write SetTransparent default true;

    property OnClickEx: TOnClickEx read fOnClickEx write fOnClickEx;

    property Checked: boolean read fChecked write SetChecked default false;

    property NormalFont: TFont read fNormalFont write SetNormalFont;
    property HotFont: TFont read fHotFont write SetHotFont;
    property DownFont: TFont read fDownFont write SetDownFont;
    property CheckedFont: TFont read fCheckedFont write SetCheckedFont;

    property Enabled;
    property AutoSize;

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
  RegisterComponents('ZMSystem', [TZMSMediaButtonText]);
end;

{ TZMSMediaButtonText }

procedure TZMSMediaButtonText.Click;
begin
  if not Enabled then
    exit;

  fChecked := not fChecked;
  inherited;
  if Assigned(fOnClickEx) then
    fOnClickEx(Self, fChecked, fState);
end;

procedure TZMSMediaButtonText.CMMouseenter(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := true;
  fState := mbsHot;
  Invalidate;
  Resize;
  inherited;
end;

procedure TZMSMediaButtonText.CMMouseleave(var Message: TMessage);
begin
  if not Enabled then
    exit;
  fMouseInClient := false;
  fState := mbsNormal;
  Invalidate;
  Resize;
  inherited;
end;

procedure TZMSMediaButtonText.CMTextchanged(var Message: TMessage);
begin
  Resize;
  Invalidate;
  inherited;
end;

constructor TZMSMediaButtonText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fAlignment := taLeftJustify;

  fChecked := false;

  fNormalFont := TFont.Create;
  fNormalFont.Color := clBlack;
  fNormalFont.OnChange := FontChanged;

  fHotFont := TFont.Create;
  fHotFont.Style := [fsBold];
  fHotFont.Color := clGray;
  fHotFont.OnChange := FontChanged;

  fDownFont := TFont.Create;
  fDownFont.Color := clSilver;
  fDownFont.OnChange := FontChanged;

  fCheckedFont := TFont.Create;
  fCheckedFont.Color := clBlack;
  fCheckedFont.Style := [fsBold, fsUnderline];
  fCheckedFont.OnChange := FontChanged;

  Width := 40;
  Height := 15;

  fBuffer := TBitmap.Create;
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  fState := mbsNormal;
  fMode := mbmNormal;
  fBorder := mbbNone;

  fMouseInClient := false;

  fBkgrColor := clBtnFace;
  fBorderColor := clGray;

  fTransparent := true;
end;

destructor TZMSMediaButtonText.Destroy;
begin
  FreeAndNil(fNormalFont);
  FreeAndNil(fHotFont);
  FreeAndNil(fDownFont);
  FreeAndNil(fCheckedFont);

  FreeAndNil(fBuffer);
  inherited;
end;

procedure TZMSMediaButtonText.FontChanged(Sender: TObject);
begin
  Invalidate;
  Resize;
end;

procedure TZMSMediaButtonText.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  fState := mbsDown;
  Invalidate;
  Resize;
  inherited;
end;

procedure TZMSMediaButtonText.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then
    exit;
  inherited;

  if fMouseInClient then
    fState := mbsHot
  else
    fState := mbsNormal;
  Invalidate;
  Resize;
end;

procedure TZMSMediaButtonText.Paint;
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

  with fBuffer.Canvas do
  begin
    case fState of
      mbsNormal:
        begin
          if fChecked and (fMode = mbmChecked) then
            Font := fCheckedFont
          else
            Font := fNormalFont;
        end;
      mbsHot:
        Font := fHotFont;
      mbsDown:
        Font := fDownFont;
    end;

    // Brush.Style := bsSolid;
    // Brush.Color := fBkgrColor;
    // FillRect(ClientRect);

    if Transparent then
      SetBkMode(Handle, 1);

    case fAlignment of
      taLeftJustify:
        TextOut(0, (Height - TextHeight(Caption)) div 2, Caption);
      taRightJustify:
        TextOut(Width - TextWidth(Caption), (Height - TextHeight(Caption)) div 2, Caption);
      taCenter:
        TextOut((Width - TextWidth(Caption)) div 2, (Height - TextHeight(Caption)) div 2, Caption);
    end;
  end;

  if Transparent then
  begin
    fBuffer.TransparentColor := fBkgrColor;
    fBuffer.Transparent := true;
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

procedure TZMSMediaButtonText.PaintTo(DC: TCanvas; X, Y: Integer);
begin
  DC.Draw(X, Y, fBuffer);
end;

procedure TZMSMediaButtonText.Resize;
begin
  if AutoSize then
  begin
    with fBuffer.Canvas do
    begin
      case fState of
        mbsNormal:
          begin
            if fChecked and (fMode = mbmChecked) then
              Font := fCheckedFont
            else
              Font := fNormalFont;
          end;
        mbsHot:
          Font := fHotFont;
        mbsDown:
          Font := fDownFont;
      end;
      Width := TextWidth(Caption);
      Height := TextHeight(Caption);
    end;
  end
  else
    inherited;
end;

procedure TZMSMediaButtonText.SetAlignment(const Value: TAlignment);
begin
  if fAlignment <> Value then
  begin
    fAlignment := Value;
    Invalidate;
    Resize;
  end;
end;

procedure TZMSMediaButtonText.SetAutoSize(Value: boolean);
begin
  inherited;
  Resize;
end;

procedure TZMSMediaButtonText.SetBkgrColor(const Value: TColor);
begin
  if fBkgrColor <> Value then
  begin
    fBkgrColor := Value;
    Paint;
  end;
end;

procedure TZMSMediaButtonText.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    Invalidate;
  end;
end;

procedure TZMSMediaButtonText.SetBorderType(const Value: TMediaButtonBorder);
begin
  if fBorder <> Value then
  begin
    fBorder := Value;
    Invalidate;
  end;
end;

procedure TZMSMediaButtonText.SetButtonMode(const Value: TMediaButtonMode);
begin
  if fMode <> Value then
  begin
    fMode := Value;
    Invalidate;
  end;
end;

procedure TZMSMediaButtonText.SetButtonState(const Value: TMediaButtonState);
begin
  if fState <> Value then
  begin
    fState := Value;
    Paint;
  end;
end;

procedure TZMSMediaButtonText.SetChecked(const Value: boolean);
begin
  if fChecked <> Value then
  begin
    fChecked := Value;
    Invalidate;
  end;
end;

procedure TZMSMediaButtonText.SetCheckedFont(const Value: TFont);
begin
  fCheckedFont := Value;
  Invalidate;
end;

procedure TZMSMediaButtonText.SetEnabled(Value: boolean);
begin
  inherited;
  fState := mbsNormal;
  Paint;
end;

procedure TZMSMediaButtonText.SetDownFont(const Value: TFont);
begin
  fDownFont := Value;
  Invalidate;
end;

procedure TZMSMediaButtonText.SetHotFont(const Value: TFont);
begin
  fHotFont := Value;
  Invalidate;
end;

procedure TZMSMediaButtonText.SetNormalFont(const Value: TFont);
begin
  fNormalFont := Value;
  Invalidate;
end;

procedure TZMSMediaButtonText.SetTransparent(const Value: boolean);
begin
  if fTransparent <> Value then
  begin
    fTransparent := Value;
    Invalidate;
  end;
end;

end.
