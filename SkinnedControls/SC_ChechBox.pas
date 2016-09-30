unit SC_ChechBox;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSCheckBox: Компонент проверки состояния |
  ********************************************* }

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics;

type
  TOnChecked = procedure(Sender: TObject; Value: boolean) of object;
  TOrientRender = (orLeft, orRight);

  TZMSCheckBox = class(TCustomControl)
  private
    { Private declarations }
    fAutoSize: boolean;
    fAutoCheck: boolean;
    fCaption: string;
    fBuffer: TBitmap;
    fChecked: boolean;
    fRect: array [0 .. 2] of TRect;
    fOnChecked: TOnChecked;
    fOrientRender: TOrientRender;

    procedure SetBitmap(Value: TBitmap);
    procedure SetText(Value: string);
    procedure SetCheck(Value: boolean);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
  public
    { Public declarations }
    constructor Create(aowner: tcomponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    { Published declarations }
    property Caption: string read fCaption write SetText;
    property AutoSize: boolean read fAutoSize write fAutoSize default true;
    property AutoCheck: boolean read fAutoCheck write fAutoCheck default true;
    property Checked: boolean read fChecked write SetCheck default false;
    property Bitmap: TBitmap read fBuffer write SetBitmap;
    property Orientation: TOrientRender read fOrientRender write fOrientRender
      default orLeft;
    property OnCheck: TOnChecked read fOnChecked write fOnChecked;

    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Enabled;

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

procedure TZMSCheckBox.Click;
begin
  inherited;
  if fAutoCheck then
  begin
    fChecked := not fChecked;
    if Assigned(fOnChecked) then
      fOnChecked(self, fChecked);
  end;
  Invalidate;
end;

procedure TZMSCheckBox.SetCheck(Value: boolean);
begin
  if fChecked <> Value then
    fChecked := Value;
  if Assigned(fOnChecked) then
    fOnChecked(self, fChecked);
  Invalidate;
end;

procedure TZMSCheckBox.Resize;
begin
  inherited;
  SetRect(fRect[0], 0, 0, fBuffer.Width div 2, fBuffer.Height);
  SetRect(fRect[1], fBuffer.Width div 2, 0, fBuffer.Width, fBuffer.Height);
  SetRect(fRect[2], Width - fBuffer.Width div 2, 0, Width, fBuffer.Height);

  if fAutoSize then
  begin
    if (Length(fCaption) > 0) then
      Width := fRect[0].Right + Canvas.TextWidth(fCaption) + 2
    else
      Width := fRect[0].Right;
    Height := fRect[0].Bottom;
  end;
end;

procedure TZMSCheckBox.Paint;
var
  Y: integer;
begin
  inherited;
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := Color;
  Canvas.FillRect(Canvas.ClipRect);
  Canvas.Font := Font;
  Resize;

  if not fChecked then
  begin
    case fOrientRender of
      orLeft:
        Canvas.CopyRect(fRect[0], fBuffer.Canvas, fRect[0]);
      orRight:
        Canvas.CopyRect(fRect[2], fBuffer.Canvas, fRect[0]);
    end;
  end
  else
  begin
    case fOrientRender of
      orLeft:
        Canvas.CopyRect(fRect[0], fBuffer.Canvas, fRect[1]);
      orRight:
        Canvas.CopyRect(fRect[2], fBuffer.Canvas, fRect[1]);
    end;
  end;

  Y := (fBuffer.Height div 2) - (Canvas.TextHeight('Hg') div 2) - 1;
  SetBkMode(Canvas.Handle, TRANSPARENT);
  case fOrientRender of
    orLeft:
      begin
        if (Length(fCaption) > 0) then
          Canvas.TextOut(fRect[1].Left + 2, Y, fCaption);
      end;
    orRight:
      begin
        if (Length(fCaption) > 0) then
          Canvas.TextOut(2, Y, fCaption);
      end;
  end;
end;

procedure TZMSCheckBox.SetText(Value: string);
begin
  if fCaption <> Value then
  begin
    fCaption := Value;
    Resize;
    Invalidate;
  end;
end;

procedure TZMSCheckBox.SetBitmap(Value: TBitmap);
begin
  if not Assigned(Value) then
  begin
    fBuffer.Width := 30;
    fBuffer.Height := Height;
    PatBlt(fBuffer.Canvas.Handle, 0, 0, (fBuffer.Width div 2), Height,
      BLACKNESS);
    PatBlt(fBuffer.Canvas.Handle, (fBuffer.Width div 2), 0, Width, Height,
      WHITENESS);
  end
  else
  begin
    fBuffer.Assign(Value);
    fBuffer.Width := Value.Width;
    fBuffer.Height := Value.Height;
    Height := Value.Height;
  end;
  Resize;
  Invalidate;
end;

constructor TZMSCheckBox.Create(aowner: tcomponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque];
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  fAutoCheck := true;
  fAutoSize := true;
  fChecked := false;
  fOrientRender := orLeft;
  fCaption := '';

  Width := 120;
  Height := 20;

  fBuffer := TBitmap.Create;
  fBuffer.Width := 30;
  fBuffer.Height := Height;

  PatBlt(fBuffer.Canvas.Handle, 0, 0, (fBuffer.Width div 2), Height, BLACKNESS);
  PatBlt(fBuffer.Canvas.Handle, (fBuffer.Width div 2), 0, Width, Height,
    WHITENESS);
end;

destructor TZMSCheckBox.Destroy;
begin
  fBuffer.Free;
  fBuffer := nil;
  inherited;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSCheckBox]);
end;

end.
