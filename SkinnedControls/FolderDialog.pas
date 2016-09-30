unit FolderDialog;

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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShlObj, ComObj, ActiveX;

const
  BFFM_SETOKTEXT = WM_USER + 105;
  BFFM_SETEXPANDED = WM_USER + 106;
  BFFM_IUNKNOWN = 5;
  BIF_NEWDIALOGSTYLE = $0040;
  BIF_NONEWFOLDERBUTTON = $0200;
  BIF_NOTRANSLATETARGETS = $0400;
  BIF_UAHINT = $0100;

type
  // TSpecialFolder = (sfRecycleBin, sfControlPanel, sfDesktop, sfDesktopDirectory, sfMyComputer, sfFontsDirectory,
  // sfNetHood, sfNetworkNeighborhood, sfMyDocuments, sfPrinters, sfPrograms, sfRecent, sfSendTo, sfStartMenu, sfStartup,
  // sfTemplates);
  TBrowseOption = (boOnlyComputers, boOnlyPrinters, boDontGobeLowDomain,
    boOnlyFileSystemAncestors, boOnlyDirectories, boShowStatusArea, boNewStyle,
    boIncludeFiles, boShowEditBox, boNoNewFolderButton, boNoTranslateTargets,
    boShowUsageHint);
  TBrowseOptions = set of TBrowseOption;

  TFolderDialog = class(TComponent)
  private
    { Private declarations }
    FFolderName: string;
    FExpandedFolder: string;

    FHandle: THandle;
    FObjectInstance: Pointer;
    FOldWndProc: Pointer;
    FFirstShow: boolean; // for CenterWindow

    FOnInitialized: TNotifyEvent;
    FOnResize: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnMessage: TWndMethod;

    FCheckBoxHandle: THandle;
    FTitleHandle: THandle;
    FDialogFont: Integer;
    FCheckOnInit: boolean;
    FChecked: boolean;

    function IsInitialized: boolean;
    procedure ExpandFolder(const Folder: string);

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
    function GetBounds: TRect;
    procedure CenterWindow;
    function GetTitleRect: TRect;
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); virtual;
    function CallbackProc(Wnd: THandle; Msg: Cardinal; LParam: Longint)
      : Integer; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Handle: THandle read FHandle;
    function Execute: boolean; overload;
    function Execute(OwnerHandle: THandle): boolean; overload;
  published
    { Published declarations }
    // property BrowseOptions: TBrowseOptions read FBrowseOptions write FBrowseOptions;
    property FolderName: string read FFolderName;
    property ExpandedFolder: string read FExpandedFolder write FExpandedFolder;
    property Checked: boolean read FChecked;
    property CheckOnInit: boolean read FCheckOnInit write FCheckOnInit;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TFolderDialog]);
end;

{ TFolderDialog }

constructor TFolderDialog.Create(AOwner: TComponent);
begin
  inherited;
  FHandle := 0;
  FObjectInstance := MakeObjectInstance(WndProc);
end;

destructor TFolderDialog.Destroy;
begin
  FreeObjectInstance(FObjectInstance);
  inherited;
end;

function TFolderDialog.GetTitleRect: TRect;
begin
  if (Handle <> 0) and (FTitleHandle <> 0) then
  begin
    GetWindowRect(FTitleHandle, Result);
    MapWindowPoints(0, Handle, Result, 2);
  end;
end;

procedure TFolderDialog.WndProc(var Message: TMessage);
var
  TitleRect: TRect;
begin
  if Assigned(FOnMessage) then
    FOnMessage(Message);

  with Message do
  begin
    case Msg of
      WM_SIZE:
        begin
          if Assigned(FOnResize) then
            FOnResize(Self);
          TitleRect := GetTitleRect;
          MoveWindow(FCheckBoxHandle, TitleRect.Left, TitleRect.Top,
            TitleRect.Right - TitleRect.Left,
            TitleRect.Bottom - TitleRect.Top, true);
        end;
      WM_DESTROY:
        begin
          FChecked := SendMessage(FCheckBoxHandle, BM_GETCHECK, 0, 0)
            = BST_CHECKED;
          if Assigned(FOnDestroy) then
            FOnDestroy(Self);
        end;
      WM_SHOWWINDOW:
        if FFirstShow and (wParam = 1) then
        begin
          FFirstShow := false;
          CenterWindow;
        end;
    end;
    Result := CallWindowProc(FOldWndProc, FHandle, Msg, wParam, LParam);
  end;
end;

function BrowseCallbackProc(Wnd: HWND; uMsg: UINT; LParam, lpData: LParam)
  : Integer stdcall;
begin
  Result := TFolderDialog(lpData).CallbackProc(Wnd, uMsg, LParam);
end;

function TFolderDialog.CallbackProc(Wnd: THandle; Msg: Cardinal;
  LParam: Longint): Integer;
const
  CheckedParam: array [boolean] of DWORD = (BST_UNCHECKED, BST_CHECKED);
var
  NewFolderBuf: array [0 .. MAX_PATH] of char;
  TitleRect: TRect;
begin
  Result := 0;
  case Msg of
    BFFM_INITIALIZED:
      begin
        FOldWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
          Cardinal(FObjectInstance)));
        FHandle := Wnd;
        FFirstShow := true;
        FChecked := false;

        // SendMessage(FHandle, BFFM_ENABLEOK, 0, Integer(true));

        ExpandFolder(FExpandedFolder);

        if Assigned(FOnInitialized) then
          FOnInitialized(Self);

        FTitleHandle := GetDlgItem(Handle, $3742);
        ShowWindow(FTitleHandle, SW_HIDE);
        FCheckBoxHandle := CreateWindow('BUTTON', PChar('With subfolders'),
          WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX or BS_TOP, 0, 0, 0, 0,
          Handle, 0, HInstance, nil);
        SendMessage(FCheckBoxHandle, BM_SETCHECK,
          CheckedParam[FCheckOnInit], 0);
        FDialogFont := SendMessage(Handle, WM_GETFONT, 0, 0);
        SendMessage(FCheckBoxHandle, WM_SETFONT, FDialogFont, 0);
        TitleRect := GetTitleRect;
        MoveWindow(FCheckBoxHandle, TitleRect.Left, TitleRect.Top,
          TitleRect.Right - TitleRect.Left, TitleRect.Bottom -
          TitleRect.Top, true);
      end;
    BFFM_SELCHANGED:
      SHGetPathFromIDList(PItemIDList(LParam), NewFolderBuf);
    // BFFM_VALIDATEFAILED:
    // begin
    // CanClose := true;
    // if not CanClose then
    // Result := 1;
    // end;
  end;
end;

function TFolderDialog.Execute: boolean;
begin
  Result := Self.Execute(Application.Handle);
end;

function TFolderDialog.Execute(OwnerHandle: THandle): boolean;
var
  bi: TBrowseInfo;
  PIDLSelected: PItemIDList;
  FolderNameBuf: array [0 .. MAX_PATH] of char;
  ShellMalloc: IMalloc;
begin
  Result := false;

  CoInitialize(nil);
  try
    if (SHGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
    begin
      FillChar(bi, SizeOf(bi), 0);
      bi.hwndOwner := OwnerHandle;
      bi.pszDisplayName := FolderNameBuf;
      bi.lpszTitle := PChar('Select Folders');
      bi.ulFlags := BIF_VALIDATE or
        BIF_NONEWFOLDERBUTTON { or BIF_NEWDIALOGSTYLE } or BIF_RETURNONLYFSDIRS;
      bi.lpfn := BrowseCallbackProc;
      bi.LParam := Integer(Self);
      bi.iImage := 0;

      ShGetSpecialFolderLocation(OwnerHandle, CSIDL_DESKTOP, bi.pidlRoot);

      try
        SHGetPathFromIDList(bi.pidlRoot, FolderNameBuf);
        PIDLSelected := SHBrowseForFolder(bi);
        FHandle := 0;
      finally
        ShellMalloc.Free(bi.pidlRoot);
      end;

      if PIDLSelected <> nil then
      begin
        try
          SHGetPathFromIDList(PIDLSelected, FolderNameBuf);
          FFolderName := FolderNameBuf;
        finally
          ShellMalloc.Free(PIDLSelected);
        end;
        Result := true;
      end;

      ShellMalloc._Release;
    end;
  finally
    CoUnInitialize;
  end;
end;

function TFolderDialog.IsInitialized: boolean;
begin
  Result := FHandle <> 0;
end;

procedure TFolderDialog.ExpandFolder(const Folder: string);
begin
  if (Folder <> '') and IsInitialized then
  begin
    SendMessage(FHandle, BFFM_SETSELECTION, 1, Integer(PChar(Folder)));
    SendMessage(FHandle, BFFM_SETEXPANDED, 1, Integer(PChar(Folder)));
  end;
end;

procedure TFolderDialog.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if IsInitialized then
    MoveWindow(FHandle, ALeft, ATop, AWidth, AHeight, true);
end;

function TFolderDialog.GetBounds: TRect;
begin
  if IsInitialized then
    GetWindowRect(FHandle, Result);
end;

procedure TFolderDialog.CenterWindow;
var
  BoundsRect: TRect;
  Width, Height: Integer;
begin
  if IsInitialized then
  begin
    BoundsRect := GetBounds;
    Width := BoundsRect.Right - BoundsRect.Left;
    Height := BoundsRect.Bottom - BoundsRect.Top;
    SetBounds((Screen.Width - Width) div 2, (Screen.Height - Height) div 2,
      Width, Height);
  end;
end;

end.
