unit OC_CreditsViewX;

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
  Windows, SysUtils, Classes, Controls, Messages, Types, ExtCtrls, Graphics;

type
  TZMSCreditViewFX = class(TGraphicControl)
  private
    fBuffer: TBitmap;
    fTimer: TTimer;
    fInterval: Integer;
    fUseEffects: boolean;
    fList: TStringList;
    // fSaved: boolean;
    fPaused: boolean;

    Index, Count, ScrollPos: Integer;
    { Private declarations }

    procedure SetInterval(Value: Integer);
    procedure SetScrollPos(Value: Integer);
    procedure SetUseEffects(Value: boolean);
    procedure SetList(Value: TStringList);
    function GetScrollMax: Integer;

    procedure TimerProc(Sender: TObject);
    procedure FontEvent(Sender: TObject);
    procedure DrawContent(y, x, h: Integer; const s: string);

    procedure Render;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    procedure Start(ID: Integer = 0);
  published
    { Published declarations }
    property Interval: Integer read fInterval write SetInterval default 10;
    property UseEffects: boolean read fUseEffects write SetUseEffects
      default true;
    property Lines: TStringList read fList write SetList;
    property ScrollingMax: Integer read GetScrollMax;
    property ScrollingPos: Integer read ScrollPos write SetScrollPos default 0;

    property Color;
    property Font;
    property Align;
    property Anchors;
    property OnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSCreditViewFX]);
end;

{ TZMSCreditViewFX }

procedure TZMSCreditViewFX.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  // fSaved := fUseEffects;
  fPaused := true;
  // fUseEffects := false;
end;

procedure TZMSCreditViewFX.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  fPaused := false;
  // fUseEffects := fSaved;
end;

constructor TZMSCreditViewFX.Create(Owner: TComponent);
begin
  inherited Create(Owner);

  fBuffer := TBitmap.Create;
  fList := TStringList.Create;

  Index := -1;
  Count := -1;
  ScrollPos := 0;
  fInterval := 10;
  fUseEffects := true;
  fPaused := false;
  // fSaved := fUseEffects;

  fTimer := TTimer.Create(Self);
  fTimer.Enabled := false;
  fTimer.Interval := fInterval;
  fTimer.OnTimer := TimerProc;

  Font.OnChange := FontEvent;
end;

destructor TZMSCreditViewFX.Destroy;
begin
  FreeAndNil(fList);
  FreeAndNil(fBuffer);
  FreeAndNil(fTimer);

  inherited Destroy;
end;

procedure TZMSCreditViewFX.FontEvent(Sender: TObject);
begin
  fBuffer.Canvas.Font := Font;
end;

procedure TZMSCreditViewFX.Loaded;
begin
  inherited;
  Resize;
end;

procedure TZMSCreditViewFX.Paint;
begin
  inherited;
  if not fPaused then
    Render;
end;

procedure TZMSCreditViewFX.DrawContent(y, x, h: Integer; const s: string);
begin
  for y := ScrollPos to Index - 1 do
    fBuffer.Canvas.TextOut(1, (y - ScrollPos) * h, fList.Strings[y]);

  fBuffer.Canvas.TextOut(x, (Index - ScrollPos) * h, s);

  Canvas.Draw(0, 0, fBuffer);
end;

procedure TZMSCreditViewFX.Render;
var
  x, y, h: Integer;
  s: string;
begin
  if not((Count >= 0) and (Index >= 0)) then
  begin
    Canvas.Draw(0, 0, fBuffer);
    exit;
  end;

  s := Trim(fList.Strings[Index]);
  if s <> '' then
  begin
    fBuffer.Canvas.Brush.Color := Color;
    SetBkColor(fBuffer.Canvas.Handle, ColorToRGB(Color));
    h := fBuffer.Canvas.TextHeight(s);
    x := -fBuffer.Canvas.TextWidth(s);

    fBuffer.Canvas.FillRect(ClientRect);

    if (fUseEffects) and (not fPaused) then
    begin
      while x < 1 do
      begin
        DrawContent(y, x, h, s);
        inc(x);
      end;
    end
    else
      DrawContent(y, 1, h, s);
  end;
end;

procedure TZMSCreditViewFX.Resize;
begin
  inherited;
  fBuffer.SetSize(Width, Height);
  fBuffer.Canvas.Brush.Color := Color;
  fBuffer.Canvas.FillRect(ClientRect);
  if ScrollPos > 0 then
  begin
    if GetScrollMax <> -1 then
      ScrollPos := 0;
  end;
  Render;
end;

procedure TZMSCreditViewFX.SetInterval(Value: Integer);
begin
  fInterval := Value;
  fTimer.Interval := fInterval;
end;

procedure TZMSCreditViewFX.SetList(Value: TStringList);
begin
  fList.Assign(Value);
end;

function TZMSCreditViewFX.GetScrollMax: Integer;
var
  ScrollMax: Integer;
begin
  if Count = 0 then
  begin
    Result := 0;
    exit;
  end;

  try
    ScrollMax := Count - (Height div (fBuffer.Canvas.TextHeight('Hg'))) + 1;
  except
    ScrollMax := -1;
  end;

  if ScrollMax < -1 then
    ScrollMax := -1;

  Result := ScrollMax;
end;

procedure TZMSCreditViewFX.SetScrollPos(Value: Integer);
begin
  if ScrollPos <> Value then
  begin
    if (Value >= 0) and (Value <= GetScrollMax) then
    begin
      ScrollPos := Value;
      Render;
    end;
  end;
end;

procedure TZMSCreditViewFX.SetUseEffects(Value: boolean);
begin
  fUseEffects := Value;
  Render;
end;

procedure TZMSCreditViewFX.Start(ID: Integer);
begin
  Count := fList.Count - 1;
  if (ID >= 0) and (Index <> ID) and (ID <= Count) then
  begin
    Index := ID;
    fTimer.Enabled := true;
  end;
end;

procedure TZMSCreditViewFX.TimerProc(Sender: TObject);
begin
  if fPaused then
    exit;

  if Index < Count then
    inc(Index)
  else
    fTimer.Enabled := false;

  Render;
end;

end.
