unit OC_Link;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSLink: ссылка/почта/обзор               |
  |           автоматичски определяет нужное   |
  |           действие по введеному тексту в   |
  |           в поле _Link                     |
  ********************************************* }

interface

uses
  Windows, Messages, Classes, Controls, Graphics, ShellAPI;

type
  TZMSLink = class(TGraphicControl)
  private
    fCaption: TCaption;
    fLinkText: string;
    fEnterfont: TFont;
    fLeavefont: TFont;
    fLeave: boolean;
    fAutoSize: boolean;
    { Private declarations }
    procedure SetLeavefont(Value: TFont);
    procedure SetEnterfont(Value: TFont);
    procedure SetCaption(Value: TCaption);
  protected
    { Protected declarations }
    procedure MouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure MouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure SetAutoSize(Value: boolean); override;
    procedure Paint; override;
    procedure Resize; override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    { Published declarations }
    property AutoSize: boolean read fAutoSize write SetAutoSize default false;
    property Caption: TCaption read fCaption write SetCaption;
    property Link: string read fLinkText write fLinkText;
    property LeaveFont: TFont read fLeavefont write SetLeavefont;
    property EnterFont: TFont read fEnterfont write SetEnterfont;

    property Hint;
    property Color;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Align;

    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

procedure Register;

implementation

procedure TZMSLink.Paint;
begin
  inherited;
  if fLeave then
    Canvas.font := fLeavefont
  else
    Canvas.font := fEnterfont;

  if fAutoSize then
  begin
    Width := Canvas.TextWidth(fCaption) + 1;
    Height := Canvas.TextHeight(fCaption) + 1;
  end;

  Canvas.Brush.Color := Color;
  Canvas.fillRect(Canvas.ClipRect);

  Canvas.Brush.Style := bsClear;
  SetBkMode(Canvas.Handle, TRANSPARENT);
  Canvas.TextOut(0, 0, fCaption);
end;

procedure TZMSLink.Resize;
begin
  if (not fAutoSize) and (fCaption <> '') then
    inherited
  else
  begin
    Width := Canvas.TextWidth(fCaption) + 1;
    Height := Canvas.TextHeight(fCaption) + 1;
  end;
end;

procedure TZMSLink.MouseEnter;
begin
  if csDesigning in ComponentState then
    exit;
  inherited;
  fLeave := false;
  Paint;
end;

procedure TZMSLink.MouseLeave;
begin
  inherited;
  fLeave := true;
  Paint;
end;

procedure TZMSLink.Click;
begin
  inherited;
  if Pos('@', fLinkText) > 0 then
    ShellExecute(Parent.Handle, nil, Pointer('mailto:' + fLinkText), nil,
      nil, SW_SHOW)
  else
    ShellExecute(Parent.Handle, nil, Pointer(fLinkText), nil, nil, SW_SHOW);
end;

constructor TZMSLink.Create(aOwner: TComponent);
begin
  inherited;
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  ControlStyle := ControlStyle + [csOpaque];
  fEnterfont := TFont.Create;
  fLeavefont := TFont.Create;

  fLeave := true;
  fAutoSize := false;

  Parent := TWinControl(aOwner);
  ParentColor := false;

  Width := 100;
  Height := 20;
  fCaption := 'link';
end;

destructor TZMSLink.Destroy;
begin
  fEnterfont.free;
  fLeavefont.free;

  fEnterfont := nil;
  fLeavefont := nil;
  inherited;
end;

procedure TZMSLink.SetLeavefont(Value: TFont);
begin
  fLeavefont.Assign(Value);
  Paint;
end;

procedure TZMSLink.SetEnterfont(Value: TFont);
begin
  fEnterfont.Assign(Value);
  Paint;
end;

procedure TZMSLink.SetCaption(Value: TCaption);
begin
  if fCaption <> Value then
    fCaption := Value;
  Invalidate;
end;

procedure TZMSLink.SetAutoSize(Value: boolean);
begin
  if fAutoSize <> Value then
    fAutoSize := Value;
  Resize;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSLink]);
end;

end.
