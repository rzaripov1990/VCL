unit OC_AppRunStr;

{ *********************************************
  | zmsystem:  audio player (open source v0.1) |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSAppRunStr: Компонент для прокрутки     |
  |                текста на панели задач      |
  ********************************************* }

interface

uses
  Windows, SysUtils, Classes, Controls, ExtCtrls, Forms;

type
  TInt = 100 .. 1000;

  TZMSAppRunStr = class(TComponent)
  private
    fInterval: TInt;
    fShowOnTaskBar: boolean;
    fShowStatic: boolean;
    fCaption: string;
    fTmpCaption: string;

    fTimer: TTimer;
    procedure fTimerEvent(Sender: TObject);

    procedure SetCaption(Value: string);
    procedure SetInterval(Value: TInt);
    procedure SetShow(Value: boolean);
    { Private declarations }
  protected
    { Protected declarations }
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    property Show: boolean read fShowOnTaskBar write SetShow default true;
    property Static: boolean read fShowStatic write fShowStatic default false;
    property Title: string read fTmpCaption write SetCaption;
    property Interval: TInt read fInterval write SetInterval;
    { Published declarations }
  end;

procedure Register;

implementation

function IsWinXP: boolean;
begin
  Result := (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion = 5)
    and (Win32MinorVersion = 1);
end;

procedure TZMSAppRunStr.fTimerEvent(Sender: TObject);
var
  i: integer;
begin
  if (csDesigning in ComponentState) then
    exit;

  if { (IsWinXP) and } (not fShowOnTaskBar) then
    ShowWindow(Application.Handle, SW_HIDE);

  if (fShowStatic) or (fCaption = '') then
    Application.Title := fTmpCaption
  else
  begin
    for i := 1 to Length(fCaption) - 1 do
      fCaption[i] := Application.Title[i + 1];
    fCaption[Length(fCaption)] := Application.Title[1];
    Application.Title := fCaption;
  end;
end;

procedure TZMSAppRunStr.SetShow(Value: boolean);
begin
  if fShowOnTaskBar <> Value then
  begin
    fShowOnTaskBar := Value;

    if fShowOnTaskBar then
      ShowWindow(Application.Handle, SW_SHOW)
    else
      ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TZMSAppRunStr.SetCaption(Value: string);
begin
  // if fCaption <> Value then
  // begin
  // if (Value[1] <> ' ') or (Value[Length(Value)] <> ' ') then
  fTmpCaption := Value + '  ***  ';
  fCaption := fTmpCaption;
  // if (csDesigning in ComponentState) then exit;
  Application.Title := fTmpCaption;
  // end;
end;

procedure TZMSAppRunStr.SetInterval(Value: TInt);
begin
  if fInterval <> Value then
  begin
    fInterval := Value;
    fTimer.Interval := Value;
  end;
end;

constructor TZMSAppRunStr.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  fShowOnTaskBar := true;
  fShowStatic := false;

  fCaption := '';
  fTmpCaption := '';

  fInterval := 250;
  fTimer := TTimer.Create(nil);
  fTimer.Interval := fInterval;
  fTimer.OnTimer := fTimerEvent;
  fTimer.Enabled := true;
end;

destructor TZMSAppRunStr.Destroy;
begin
  FreeAndNil(fTimer);

  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSAppRunStr]);
end;

end.
