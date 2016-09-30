{*******************************************************************************

    Version: 1.1
    TPFolderDialog - delphi component, displays a browse for folder dialog
    Copyright (C) 2006 Pelesh Yaroslav Vladimirovich
    mailto:yaroslav@pelesh.in.ua
    http://pelesh.in.ua

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*******************************************************************************}

unit PFolderDialog;

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
  TSpecialFolder = (sfRecycleBin, sfControlPanel, sfDesktop, sfDesktopDirectory, 
    sfMyComputer, sfFontsDirectory, sfNetHood, sfNetworkNeighborhood, sfMyDocuments,
    sfPrinters, sfPrograms, sfRecent, sfSendTo, sfStartMenu, sfStartup,
    sfTemplates);
  TBrowseOption = (boOnlyComputers, boOnlyPrinters, boDontGobeLowDomain,
    boOnlyFileSystemAncestors, boOnlyDirectories, boShowStatusArea, boNewStyle,
    boIncludeFiles, boShowEditBox, boNoNewFolderButton, boNoTranslateTargets,
    boShowUsageHint);
  TBrowseOptions = set of TBrowseOption;
  TAdvancedOptions = set of (aoStandardStatusText, aoStandardOkButtonText,
    aoStandardCancelButtonText, aoStandardCaption, aoCenterWindow);
  TSelectionChangedEvent = procedure(Sender: TObject; const NewFolder: string) of object;
  TValidateFailedEvent = procedure(Sender: TObject; const InvalidName: string;
    var CanClose: boolean) of object;
  TIUnknownEvent = procedure(Sender: TObject; const IUnknownPtr: IUnknown) of object;

  TPFolderDialog = class(TComponent)
  private
    { Private declarations }
    FTitle: string;
    FBrowseOptions: TBrowseOptions;
    FAdvancedOptions: TAdvancedOptions;
    FFolderName: string;
    FFolderDisplayName: string;
    FRootFolder: TSpecialFolder;
    FCustomRootFolder: string;
    FSelectedFolder: string;
    FOkButtonEnabled: boolean;
    FStatusText: string;
    FOkButtonText: string;
    FCancelButtonText: string;
    FExpandedFolder: string;
    FCaption: string;
    FCurrentFolder: string;
    FHandle: THandle;
    FObjectInstance: Pointer;
    FOldWndProc: Pointer;
    FFirstShow: boolean; // for CenterWindow
    FOnIUnknown: TIUnknownEvent;
    FOnInitialized: TNotifyEvent;
    FOnSelectionChanged: TSelectionChangedEvent;
    FOnValidateFailed: TValidateFailedEvent;
    FOnResize: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnMessage: TWndMethod;
    function GetCurrentFolder: string;
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); virtual;
    function CallbackProc(Wnd: THandle; Msg: Cardinal;
      LParam: Longint): Integer; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property FolderName: string read FFolderName;
    property FolderDisplayName: string read FFolderDisplayName;
    property Handle: THandle read FHandle;
    property CurrentFolder: string read GetCurrentFolder;
    function Execute: boolean; overload;
    function Execute(OwnerHandle: THandle): boolean; overload;
    function IsInitialized: boolean;
    procedure SelectFolder(const Folder: string);
    procedure EnableOkButton(Enable: boolean);
    procedure SetStatusText(const Text: string);
    procedure SetOkButtonText(const Text: string);
    procedure SetCancelButtonText(const Text: string);
    procedure SetCaption(const Text: string);
    procedure ExpandFolder(const Folder: string);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
    function GetBounds: TRect;
    procedure CenterWindow;
  published
    { Published declarations }
    property RootFolder: TSpecialFolder read FRootFolder write FRootFolder;
    property CustomRootFolder: string read FCustomRootFolder write FCustomRootFolder;
    property BrowseOptions: TBrowseOptions read FBrowseOptions write FBrowseOptions;
    property AdvancedOptions: TAdvancedOptions read FAdvancedOptions write FAdvancedOptions;
    property Title: string read FTitle write FTitle;
    property SelectedFolder: string read FSelectedFolder write FSelectedFolder;
    property OkButtonEnabled: boolean read FOkButtonEnabled write FOkButtonEnabled;
    property StatusText: string read FStatusText write FStatusText;
    property OkButtonText: string read FOkButtonText write FOkButtonText;
    property CancelButtonText: string read FCancelButtonText write FCancelButtonText;
    property ExpandedFolder: string read FExpandedFolder write FExpandedFolder;
    property Caption: string read FCaption write FCaption;
    property OnIUnknown: TIUnknownEvent read FOnIUnknown write FOnIUnknown;
    property OnInitialized: TNotifyEvent read FOnInitialized write FOnInitialized;
    property OnSelectionChanged: TSelectionChangedEvent read FOnSelectionChanged
      write FOnSelectionChanged;
    property OnValidateFailed: TValidateFailedEvent read FOnValidateFailed
      write FOnValidateFailed;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnMessage: TWndMethod read FOnMessage write FOnMessage;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Pelesh', [TPFolderDialog]);
end;

{ TPFolderDialog }

constructor TPFolderDialog.Create(AOwner: TComponent);
begin
  inherited;
  FHandle := 0;
  FOkButtonEnabled := true;
  FRootFolder := sfDesktop;
  FBrowseOptions := [boOnlyDirectories, boNewStyle, boOnlyFileSystemAncestors];
  FAdvancedOptions := [aoStandardStatusText, aoStandardOkButtonText,
    aoStandardCancelButtonText, aoStandardCaption];
  FObjectInstance := MakeObjectInstance(WndProc);
end;

destructor TPFolderDialog.Destroy;
begin
  FreeObjectInstance(FObjectInstance);
  inherited;
end;

procedure TPFolderDialog.WndProc(var Message: TMessage);
begin
  if Assigned(FOnMessage) then
    FOnMessage(Message);

  with Message do
  begin
    case Msg of
      WM_SIZE:
        if Assigned(FOnResize) then
          FOnResize(Self);
      WM_DESTROY:
        if Assigned(FOnDestroy) then
          FOnDestroy(Self);
      WM_SHOWWINDOW:
        if FFirstShow and (wParam = 1) and (aoCenterWindow in FAdvancedOptions) then
        begin
          FFirstShow := false;
          CenterWindow;
        end;
    end;
    Result := CallWindowProc(FOldWndProc, FHandle, Msg, WParam, LParam);
  end;
end;

function BrowseCallbackProc(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  Result := TPFolderDialog(lpData).CallbackProc(Wnd, uMsg, lParam);
end;

function TPFolderDialog.CallbackProc(Wnd: THandle; Msg: Cardinal;
  LParam: Longint): Integer;
var
  NewFolderBuf: array[0..MAX_PATH] of char;
  CanClose: boolean;
begin
  Result := 0;
  case Msg of
    BFFM_INITIALIZED:
    begin
      FOldWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
        Cardinal(FObjectInstance)));
      FHandle := Wnd;
      FFirstShow := true;
      SelectFolder(FSelectedFolder);
      EnableOkButton(FOkButtonEnabled);
      if not (aoStandardStatusText in FAdvancedOptions) then
        SetStatusText(FStatusText);
      if not (aoStandardOkButtonText in FAdvancedOptions) then
        SetOkButtonText(FOkButtonText);
      if not (aoStandardCancelButtonText in FAdvancedOptions) then
        SetCancelButtonText(FCancelButtonText);
      if not (aoStandardCaption in FAdvancedOptions) then
        SetCaption(FCaption);
      ExpandFolder(FExpandedFolder);
      if Assigned(FOnInitialized) then
        FOnInitialized(Self);
    end;
    BFFM_SELCHANGED:
      if Assigned(OnSelectionChanged) then
      begin
        SHGetPathFromIDList(PItemIDList(lParam), NewFolderBuf);
        FOnSelectionChanged(Self, NewFolderBuf);
        FCurrentFolder := NewFolderBuf;
      end;
    BFFM_VALIDATEFAILED:
      if Assigned(FOnValidateFailed) then
      begin
        CanClose := true;
        FOnValidateFailed(Self, PChar(lParam), CanClose);
        if not CanClose then
          Result := 1;
      end;
    BFFM_IUNKNOWN:
      if Assigned(FOnIUnknown) then
        FOnIUnknown(Self, IUnknown(lParam));
  end;
end;

function TPFolderDialog.Execute: boolean;
begin
  Result := Self.Execute(Application.Handle);
end;

function TPFolderDialog.Execute(OwnerHandle: THandle): boolean;
const
  SpecialFolder: array[TSpecialFolder] of DWORD = (CSIDL_BITBUCKET,
    CSIDL_CONTROLS, CSIDL_DESKTOP, CSIDL_DESKTOPDIRECTORY, CSIDL_DRIVES,
    CSIDL_FONTS, CSIDL_NETHOOD, CSIDL_NETWORK, CSIDL_PERSONAL, CSIDL_PRINTERS,
    CSIDL_PROGRAMS, CSIDL_RECENT, CSIDL_SENDTO, CSIDL_STARTMENU, CSIDL_STARTUP,
    CSIDL_TEMPLATES);
  BrowseOption: array[TBrowseOption] of DWORD = (BIF_BROWSEFORCOMPUTER,
    BIF_BROWSEFORPRINTER, BIF_DONTGOBELOWDOMAIN, BIF_RETURNFSANCESTORS,
    BIF_RETURNONLYFSDIRS, BIF_STATUSTEXT, BIF_NEWDIALOGSTYLE,
    BIF_BROWSEINCLUDEFILES, BIF_EDITBOX, BIF_NONEWFOLDERBUTTON,
    BIF_NOTRANSLATETARGETS, BIF_UAHINT);
var
  bi: TBrowseInfo;
  PIDLSelected: PItemIDList;
  RootFolderNameBuf, FolderDisplayNameBuf, FolderNameBuf: array[0..MAX_PATH] of char;
  Option: TBrowseOption;
  ShellMalloc: IMalloc;
  DesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
begin
  Result := false;

  CoInitialize(nil);
  try
    if (SHGetMalloc(ShellMalloc)= S_OK) and (ShellMalloc <> nil) then
    begin
      FillChar(bi, SizeOf(bi), 0);
      bi.hwndOwner := OwnerHandle;
      bi.pszDisplayName := FolderDisplayNameBuf;
      bi.lpszTitle := PAnsiChar(FTitle);
      bi.ulFlags := BIF_VALIDATE;
      for Option := Low(Option) to High(Option) do
        if Option in FBrowseOptions then
          bi.ulFlags := bi.ulFlags or BrowseOption[Option];
      bi.lpfn := BrowseCallbackProc;
      bi.lParam := Integer(Self);

      if FCustomRootFolder <> '' then
      begin
        SHGetDesktopFolder(DesktopFolder);
        DesktopFolder.ParseDisplayName(OwnerHandle, nil,
          StringToLPOLESTR(IncludeTrailingBackslash(FCustomRootFolder)),
          Eaten, bi.pidlRoot, Flags);
        DesktopFolder._Release;
      end
      else
        ShGetSpecialFolderLocation(OwnerHandle, SpecialFolder[FRootFolder],
          bi.pidlRoot);

      try
        ShGetPathFromIDList(bi.pidlRoot, RootFolderNameBuf);
        FCurrentFolder := RootFolderNameBuf;
        PIDLSelected := SHBrowseForFolder(bi);
        FHandle := 0;
      finally
        ShellMalloc.Free(bi.pidlRoot);
      end;

      if PIDLSelected <> nil then
      begin
        try
          ShGetPathFromIDList(PIDLSelected, FolderNameBuf);
          FFolderName := FolderNameBuf;
          FFolderDisplayName := FolderDisplayNameBuf;
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

function TPFolderDialog.IsInitialized: boolean;
begin
  Result := FHandle <> 0;
end;

procedure TPFolderDialog.EnableOkButton(Enable: boolean);
begin
  if IsInitialized then
    SendMessage(FHandle, BFFM_ENABLEOK, 0, Integer(Enable));
end;

procedure TPFolderDialog.SelectFolder(const Folder: string);
begin
  if (Folder <> '') and IsInitialized then
    SendMessage(FHandle, BFFM_SETSELECTION, 1, Integer(PChar(Folder)));
end;

procedure TPFolderDialog.ExpandFolder(const Folder: string);
begin
  if (Folder <> '') and IsInitialized then
    SendMessage(FHandle, BFFM_SETEXPANDED, 1, Integer(PChar(Folder)));
end;

procedure TPFolderDialog.SetStatusText(const Text: string);
begin
  if IsInitialized then
    SendMessage(FHandle, BFFM_SETSTATUSTEXT, 0, Integer(PChar(Text)));
end;

procedure TPFolderDialog.SetOkButtonText(const Text: string);
begin
  if IsInitialized then
    SetDlgItemText(FHandle, ID_OK, PChar(Text));
end;

procedure TPFolderDialog.SetCancelButtonText(const Text: string);
begin
  if IsInitialized then
    SetDlgItemText(FHandle, ID_CANCEL, PChar(Text));
end;

procedure TPFolderDialog.SetCaption(const Text: string);
begin
  if IsInitialized then
    SendMessage(FHandle, WM_SETTEXT, 0, Integer(PChar(Text)));
end;

procedure TPFolderDialog.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if IsInitialized then
    MoveWindow(FHandle, ALeft, ATop, AWidth, AHeight, true);
end;

function TPFolderDialog.GetBounds: TRect;
begin
  if IsInitialized then
    GetWindowRect(FHandle, Result);
end;

procedure TPFolderDialog.CenterWindow;
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

function TPFolderDialog.GetCurrentFolder: string;
begin
  if IsInitialized then
    Result := FCurrentFolder
  else
    Result := '';
end;

end.
