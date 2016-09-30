unit OC_TaskBar;

interface

uses
  ShlObj, SysUtils, Messages, Classes, Forms, Controls, StdCtrls,
  Windows, Math, ActiveX, Graphics, Dialogs, AppEvnts;

const
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11d0-958A-006097C9A090}';
  TaskBarVer = 'TTaskbar v.1.31';
  DateBuild = '08.02.2011';

type
  TProgressState = (TBPF_NOPROGRESS, TBPF_INDETERMINATE, TBPF_NORMAL,
    TBPF_ERROR, TBPF_PAUSED);

  TUpdateBarProcedure = procedure of object;

  TThumbnailClip = class(TPersistent)
  private
    fClip: TRect;
    FControl: TControl;
    FOnChange: TUpdateBarProcedure;
    procedure SetClips(Index: Integer; Value: LongInt);
    procedure SetClip(const Value: TRect);
  protected
    procedure Change; virtual;
    procedure AssignTo(Dest: TPersistent); override;
    property Control: TControl read FControl;
  public
    constructor Create(Control: TControl); virtual;
    property OnChange: TUpdateBarProcedure read FOnChange write FOnChange;
    property Clip: TRect read fClip write SetClip;
  published
    property Left: LongInt index 0 read fClip.Left write SetClips default 0;
    property Top: LongInt index 1 read fClip.Top write SetClips default 0;
    property Right: LongInt index 2 read fClip.Right write SetClips default 0;
    property Bottom: LongInt index 3 read fClip.Bottom write SetClips default 0;
  end;

  TTaskButton = class(TComponent)
  private
    fCaption: string;
    fOnClick: TNotifyEvent;
    UpdateBar: TUpdateBarProcedure;
    fEnabled: Boolean;
    fVisible: Boolean;
    fId: Integer;
    fIconId: Integer;
    fBackGround: Boolean;
    fDismiss: Boolean;
    fInteractive: Boolean;
    // function GetCaption: string;
    procedure SetCaption(const Value: string);
    procedure SetEnabled(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetIconId(const Value: Integer);
    procedure SetDismiss(const Value: Boolean);
    procedure SetBackGround(const Value: Boolean);
    procedure SetInteractive(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: string read fCaption write SetCaption;
    property OnClick: TNotifyEvent read fOnClick write fOnClick;
    property Visible: Boolean read fVisible write SetVisible default False;
    property Enabled: Boolean read fEnabled write SetEnabled default True;
    property Id: Integer read fId;
    property IconId: Integer read fIconId write SetIconId default -1;
    property Dismiss: Boolean read fDismiss write SetDismiss default False;
    property BackGround: Boolean read fBackGround write SetBackGround
      default True;
    property Interactive: Boolean read fInteractive write SetInteractive
      default True;
  end;

  TTaskButtonList = class(TComponent)
  private
    fButton1: TTaskButton;
    fButton6: TTaskButton;
    fButton7: TTaskButton;
    fButton4: TTaskButton;
    fButton5: TTaskButton;
    fButton2: TTaskButton;
    fButton3: TTaskButton;
    fThumbButtons: array [0 .. 6] of TThumbButton;
    UpdateBar: TUpdateBarProcedure;
    function Get(Index: Integer): TTaskButton;
    procedure Put(Index: Integer; const B: TTaskButton);
    // function GetMainForm: TForm;
    function GetCount: Integer;
    function GetActive: Boolean;
    property TaskButtons[Index: Integer]: TTaskButton read Get
      write Put; default;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // property MainForm: TForm read GetMainForm;
  published
    property Active: Boolean read GetActive;
    property Count: Integer read GetCount;
    property TaskButton1: TTaskButton read fButton1;
    property TaskButton2: TTaskButton read fButton2;
    property TaskButton3: TTaskButton read fButton3;
    property TaskButton4: TTaskButton read fButton4;
    property TaskButton5: TTaskButton read fButton5;
    property TaskButton6: TTaskButton read fButton6;
    property TaskButton7: TTaskButton read fButton7;
  end;

  TTaskBar = class(TComponent)
  private
    fButtons: TTaskButtonList;
    fOIconID: Integer;
    fOIconDescription: string;
    fImageList: TImageList;
    fTaskBarButton: Boolean;
    fTaskBarButton_old: Boolean;
    fProgressValue: Integer;
    fProgressMax: Integer;
    fProgressState: TProgressState;
    fThumbnailTooltip: string;
    fThumbnailClip: TThumbnailClip;
    fClip: TRect;
    fThumbnailClipEnabled: Boolean;
    FAppEvents: TApplicationEvents;
    procedure AppMessage(var Message: TMsg; var Handled: Boolean);
    // function GetMainForm: TForm;
    procedure setOIconDescription(const Value: string);
    procedure setOIconID(const Value: Integer);
    procedure seTTaskBarButton(const Value: Boolean);
    procedure setProgressValue(const Value: Integer);
    procedure setProgressMax(const Value: Integer);
    procedure setProgressState(const Value: TProgressState);
    procedure SetThumbnailTooltip(const Value: string);
    procedure SetThumbnailClip(const Value: TThumbnailClip);
    procedure SetThumbnailClipEnabled(const Value: Boolean);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateBar;
    // property MainForm: TForm read GetMainForm;
  published
    property ImageList: TImageList read fImageList write fImageList;
    property Buttons: TTaskButtonList read fButtons;
    property OIconID: Integer read fOIconID write setOIconID default -1;
    property OIconDescription: string read fOIconDescription
      write setOIconDescription;
    property TaskBarButton: Boolean read fTaskBarButton write seTTaskBarButton
      default True;
    property ProgressValue: Integer read fProgressValue write setProgressValue
      default 0;
    property ProgressMax: Integer read fProgressMax write setProgressMax
      default 100;
    property ProgressState: TProgressState read fProgressState
      write setProgressState default TBPF_NOPROGRESS;
    property ThumbnailTooltip: string read fThumbnailTooltip
      write SetThumbnailTooltip;
    property ThumbnailClip: TThumbnailClip read fThumbnailClip
      write SetThumbnailClip;
    property ThumbnailClipEnabled: Boolean read fThumbnailClipEnabled
      write SetThumbnailClipEnabled;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TTaskBar]); //
end;

{ TTaskBar }

procedure TTaskBar.UpdateBar;
// fixed "MainForm.handle -> Application.Handle" (ZuBy)
var
  i, j: Integer;
  TaskBar: ITaskBarList3;
  pfList: IUnknown;
  hr: HRESULT;
  OIcon: TIcon;
  progress: Integer;
  // r: TRect;
begin
  if csDesigning in ComponentState then
    Exit;
  if not(CheckWin32Version(6, 1)) then
    Exit;
  CoInitialize(nil);
  try
    hr := CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER or
      CLSCTX_LOCAL_SERVER, IUnknown, pfList);
    if (hr = S_OK) then
    begin
      TaskBar := pfList as ITaskBarList3;
      if (TaskBar.HrInit = S_OK) then
      begin
        if TaskBarButton <> fTaskBarButton_old then
          if TaskBarButton then
            TaskBar.AddTab(Application.Handle)
          else
          begin
            TaskBar.DeleteTab(Application.Handle);
            Exit;
          end;
        TaskBar.SetThumbnailTooltip(Application.Handle,
          pWideChar(ThumbnailTooltip));
        if ThumbnailClipEnabled then
        begin
          fClip := ThumbnailClip.Clip;
          TaskBar.SetThumbnailClip(Application.Handle, fClip);
        end;
        progress := ord(ProgressState);
        case ProgressState of
          TBPF_NOPROGRESS .. TBPF_NORMAL:
            progress := ord(ProgressState);
          TBPF_ERROR:
            progress := 4;
          TBPF_PAUSED:
            progress := 8;
        end;
        TaskBar.setProgressState(Application.Handle, progress);
        if (ProgressState <> TBPF_NOPROGRESS) and
          (ProgressState <> TBPF_INDETERMINATE) then
          TaskBar.setProgressValue(Application.Handle, ProgressValue,
            ProgressMax);
        if Assigned(ImageList) then
        begin
          OIcon := TIcon.Create;
          try
            ImageList.GetIcon(OIconID, OIcon);
            TaskBar.SetOverlayIcon(Application.Handle, OIcon.Handle,
              PChar(OIconDescription));
          finally
            OIcon.Free;
          end;
        end;
        if TaskBarButton <> fTaskBarButton_old then
          TaskBar.ActivateTab(Application.Handle);
        for i := 0 to 6 do
        begin
          Buttons.fThumbButtons[i].iId := i;
          Buttons.fThumbButtons[i].iBitmap := Buttons[i].IconId;
          Buttons.fThumbButtons[i].dwFlags := THBF_ENABLED;
          if not(Buttons[i].Enabled) then
            Inc(Buttons.fThumbButtons[i].dwFlags, THBF_DISABLED);
          if not(Buttons[i].Visible) then
            Inc(Buttons.fThumbButtons[i].dwFlags, THBF_HIDDEN);
          if not(Buttons[i].BackGround) then
            Inc(Buttons.fThumbButtons[i].dwFlags, THBF_NOBACKGROUND);
          if Buttons[i].Dismiss then
            Inc(Buttons.fThumbButtons[i].dwFlags, THBF_DISMISSONCLICK);
          if not(Buttons[i].Interactive) then
            Inc(Buttons.fThumbButtons[i].dwFlags, THBF_NONINTERACTIVE);
          Buttons.fThumbButtons[i].dwMask := THB_BITMAP + THB_TOOLTIP +
            THB_FLAGS;
          for j := 0 to Min(Length(Buttons[i].Caption), 260) - 1 do
            Buttons.fThumbButtons[i].szTip[j] := Buttons[i].Caption[j + 1];
        end;
        if Assigned(ImageList) then
          TaskBar.ThumbBarSetImageList(Application.Handle, ImageList.Handle);
        TaskBar.ThumbBarAddButtons(Application.Handle, 7,
          @(Buttons.fThumbButtons));
        TaskBar.ThumbBarUpdateButtons(Application.Handle, 7,
          @(Buttons.fThumbButtons));
      end;
    end;
  Finally
    TaskBar := Nil;
    pfList := Nil;
    CoUninitialize;
    fTaskBarButton_old := TaskBarButton;
  end;
end;

constructor TTaskBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fThumbnailClip := TThumbnailClip.Create(TControl(Self));
  fThumbnailClip.OnChange := UpdateBar;
  // fThumbnailClip.SetSubComponent(True);
  // fThumbnailClip.Name := 'Clip';
  fButtons := TTaskButtonList.Create(Self);
  fButtons.Name := 'Buttons';
  fButtons.SetSubComponent(True);
  fButtons.UpdateBar := UpdateBar;
  fOIconID := -1;
  fTaskBarButton := True;
  fProgressState := TBPF_NOPROGRESS;
  fProgressValue := 0;
  fProgressMax := 100;
  FAppEvents := TApplicationEvents.Create(Self);
  FAppEvents.OnMessage := AppMessage;
end;

destructor TTaskBar.Destroy;
begin
  Buttons.Free;
  fThumbnailClip.Free;
  inherited Destroy;
end;

// function TTaskBar.GetMainForm: TForm;
// begin
// Result := Application.MainForm; //TForm(Owner);
// end;

procedure TTaskBar.setOIconDescription(const Value: string);
begin
  fOIconDescription := Value;
  UpdateBar;
end;

procedure TTaskBar.setOIconID(const Value: Integer);
begin
  fOIconID := Value;
  UpdateBar;
end;

procedure TTaskBar.setProgressMax(const Value: Integer);
begin
  fProgressMax := Value;
  UpdateBar;
end;

procedure TTaskBar.setProgressState(const Value: TProgressState);
begin
  fProgressState := Value;
  UpdateBar;
end;

procedure TTaskBar.setProgressValue(const Value: Integer);
begin
  fProgressValue := Value;
  UpdateBar;
end;

procedure TTaskBar.seTTaskBarButton(const Value: Boolean);
begin
  fTaskBarButton_old := fTaskBarButton;
  fTaskBarButton := Value;
  UpdateBar;
end;

procedure TTaskBar.SetThumbnailClip(const Value: TThumbnailClip);
begin
  fThumbnailClip := Value;
  UpdateBar;
end;

procedure TTaskBar.SetThumbnailClipEnabled(const Value: Boolean);
begin
  fThumbnailClipEnabled := Value;
  UpdateBar;
end;

procedure TTaskBar.SetThumbnailTooltip(const Value: string);
begin
  fThumbnailTooltip := Value;
  UpdateBar;
end;

procedure TTaskBar.AppMessage(var Message: TMsg; var Handled: Boolean);
begin
  case Message.Message of
    WM_COMMAND:
      if HiWord(Message.WParam) = THBN_CLICKED then
      begin
        Handled := True;
        if Assigned(Buttons.TaskButtons[LoWord(Message.WParam)].OnClick) then
          Buttons.TaskButtons[LoWord(Message.WParam)
            ].OnClick(Buttons.TaskButtons[LoWord(Message.WParam)]);
      end;
    WM_ACTIVATE:
      UpdateBar;
  end;
end;

{ TTaskButton }

constructor TTaskButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fDismiss := False;
  fBackGround := True;
  fEnabled := True;
  fVisible := False;
  fInteractive := True;
end;

destructor TTaskButton.Destroy;
begin
  inherited Destroy;
end;

{ function TTaskButton.GetCaption: string;
  begin
  Result := fCaption;
  end; }

procedure TTaskButton.SetBackGround(const Value: Boolean);
begin
  fBackGround := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetCaption(const Value: string);
begin
  fCaption := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetDismiss(const Value: Boolean);
begin
  fDismiss := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetEnabled(const Value: Boolean);
begin
  fEnabled := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetIconId(const Value: Integer);
begin
  fIconId := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetInteractive(const Value: Boolean);
begin
  fInteractive := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

procedure TTaskButton.SetVisible(const Value: Boolean);
begin
  fVisible := Value;
  if Assigned(UpdateBar) then
    UpdateBar;
end;

{ TTaskButtonList }

constructor TTaskButtonList.Create(AOwner: TComponent);

  procedure CreateButton(var Button: TTaskButton; const AOwner: TComponent;
    const Name: string; Id: Integer);
  begin
    Button := TTaskButton.Create(AOwner);
    Button.SetSubComponent(True);
    Button.Name := Name;
    Button.Caption := Name;
    Button.UpdateBar := TTaskBar(AOwner.Owner).UpdateBar;
    Button.fId := Id;
    Button.fIconId := Id;
  end;

begin
  inherited Create(AOwner);
  CreateButton(fButton1, Self, 'Button1', 0);
  CreateButton(fButton2, Self, 'Button2', 1);
  CreateButton(fButton3, Self, 'Button3', 2);
  CreateButton(fButton4, Self, 'Button4', 3);
  CreateButton(fButton5, Self, 'Button5', 4);
  CreateButton(fButton6, Self, 'Button6', 5);
  CreateButton(fButton7, Self, 'Button7', 6);
end;

destructor TTaskButtonList.Destroy;
begin
  TaskButton1.Free;
  TaskButton2.Free;
  TaskButton3.Free;
  TaskButton4.Free;
  TaskButton5.Free;
  TaskButton6.Free;
  TaskButton7.Free;
  inherited;
end;

// function TTaskButtonList.GetMainForm: TForm;
// begin
// Result := TForm(Owner.Owner);
// end;

function TTaskButtonList.Get(Index: Integer): TTaskButton;
begin
  case Index of
    0:
      Result := TaskButton1;
    1:
      Result := TaskButton2;
    2:
      Result := TaskButton3;
    3:
      Result := TaskButton4;
    4:
      Result := TaskButton5;
    5:
      Result := TaskButton6;
    6:
      Result := TaskButton7;
  else
    Result := nil;
  end;
end;

function TTaskButtonList.GetActive: Boolean;
begin
  Result := Count > 0;
end;

function TTaskButtonList.GetCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to 6 do
    if TaskButtons[i].Visible then
      Inc(Result);
end;

procedure TTaskButtonList.Put(Index: Integer; const B: TTaskButton);
begin
  case Index of
    0:
      fButton1 := B;
    1:
      fButton2 := B;
    2:
      fButton3 := B;
    3:
      fButton4 := B;
    4:
      fButton5 := B;
    5:
      fButton6 := B;
    6:
      fButton7 := B;
  else
    Exit;
  end;
end;

{ TThumbnailClip }

procedure TThumbnailClip.AssignTo(Dest: TPersistent);
begin
  inherited;

end;

procedure TThumbnailClip.Change;
begin
  if Assigned(FOnChange) then
    FOnChange;
end;

constructor TThumbnailClip.Create(Control: TControl);
begin
  inherited Create;
  FControl := Control;
end;

procedure TThumbnailClip.SetClip(const Value: TRect);
begin
  fClip := Value;
  Change;
end;

procedure TThumbnailClip.SetClips(Index: Integer; Value: LongInt);
begin
  case Index of
    0:
      if Value <> fClip.Left then
      begin
        fClip.Left := Value;
        Change;
      end;
    1:
      if Value <> fClip.Top then
      begin
        fClip.Top := Value;
        Change;
      end;
    2:
      if Value <> fClip.Right then
      begin
        fClip.Right := Value;
        Change;
      end;
    3:
      if Value <> fClip.Bottom then
      begin
        fClip.Bottom := Value;
        Change;
      end;
  end;
end;

end.
