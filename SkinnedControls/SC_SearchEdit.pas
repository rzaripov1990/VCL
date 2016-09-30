unit SC_SearchEdit;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSEdit: Компонент с не фокусной          |
  |           отрисовкой собственного текста   |
  ********************************************* }

interface

uses
  Windows, SysUtils, Messages, Classes, Controls,
  StdCtrls, Graphics, Forms;

type
  TZMSEdit = class(TCustomEdit)
  private
    fTitle: string;
    Canvas: TControlCanvas;
    fOnText: TNotifyEvent;
    fDrawTitle: boolean;
    procedure AdjustHeight;
    procedure SetDrawTitle(value: boolean);
    { Private declarations }
  protected
    procedure CreateWnd; override;
    procedure FONTCHANGED(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMEnter(var Message: TCMEnter); message WM_SETFOCUS;
    procedure CMExit(var Message: TCMLostFocus); message WM_KILLFOCUS;
    procedure DrawControl;
    procedure KeyPress(var Key: Char); override;
    { Protected declarations }
  public
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    { Public declarations }
  published
    { Published declarations }
    property OnText: TNotifyEvent read fOnText write fOnText;
    property Align;
    property Anchors;
    property Alignment;
    property Hint;
    property ShowHint;
    property Visible;
    property Enabled;
    property Cursor default crHandPoint;
    property OnChange;
    property OnKeyUp;
    property OnKeyDown;
    property Font;
    property Color;
    property Text;
    property DrawTitle: boolean read fDrawTitle write SetDrawTitle default true;
    property Title: string read fTitle write fTitle;
  end;

procedure Register;

implementation

procedure TZMSEdit.KeyPress(var Key: Char);
begin
  if Key = #13 then
  begin
    if Assigned(fOnText) then
      fOnText(Self);
  end;
end;

procedure TZMSEdit.DrawControl;
begin
  inherited Refresh;
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := Color;
  Canvas.FillRect(ClientRect);
  Canvas.Font := Font;
  SetBkMode(Canvas.Handle, TRANSPARENT);

  // and (not (csDesigning in ComponentState))
  if (not Focused) and (fDrawTitle) then
    Canvas.TextOut(0, 0, fTitle)
  else
    Canvas.TextOut(0, 0, Text);
end;

procedure TZMSEdit.CreateWnd;
const
  style = [csFramed] + [csOpaque] - [csFixedHeight];
begin
  inherited;
  Ctl3D := false;
  BorderStyle := bsNone;
  fDrawTitle := true;
  Canvas := TControlCanvas.Create;
  Canvas.Handle := GetDC(Handle);
  ControlStyle := ControlStyle - style;
  HideSelection := true;
  AutoSelect := false;
  AdjustHeight;
  DrawControl;
end;

constructor TZMSEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fDrawTitle := true;
end;

destructor TZMSEdit.Destroy;
begin
  FreeAndNil(Canvas);
  inherited Destroy;
end;

procedure TZMSEdit.SetDrawTitle(value: boolean);
begin
  if fDrawTitle <> value then
  begin
    fDrawTitle := value;
    if fDrawTitle then
      Text := '';
    // DrawControl;
  end;
end;

procedure TZMSEdit.AdjustHeight;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
    SaveFont := 0;
  end;
  Height := Metrics.tmHeight { + 2 };
end;

procedure TZMSEdit.CMExit(var Message: TCMLostFocus);
begin
  inherited;
  if fDrawTitle then
    Text := '';
  DrawControl;
end;

procedure TZMSEdit.CMEnter(var Message: TCMEnter);
begin
  if fDrawTitle then
    Text := '';
  inherited;
  DrawControl;
end;

procedure TZMSEdit.FONTCHANGED(var Msg: TMessage);
begin
  inherited;
  AdjustHeight;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSEdit]);
end;

end.
