{ *******************************************************************************

  Version: 1.1
  TPFolderDialogWCB - delphi component, extention of TPFolderDialog, where
  title is replaced by checkbox.
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

  ******************************************************************************* }

unit PFolderDialogWCB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShlObj, FolderDialog;

type
  TFolderDialogEx = class(TFolderDialog)
  private
    { Private declarations }
    FCheckBoxHandle: THandle;
    FTitleHandle: THandle;
    FDialogFont: Integer;
    FCheckOnInit: boolean;
    FChecked: boolean;
    function GetTitleRect: TRect;
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); override;
    function CallbackProc(Wnd: THandle; Msg: Cardinal; LParam: Longint)
      : Integer; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property CheckOnInit: boolean read FCheckOnInit write FCheckOnInit;
    property Checked: boolean read FChecked;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TFolderDialogEx]);
end;

{ TFolderDialogEx }

constructor TFolderDialogEx.Create(AOwner: TComponent);
begin
  inherited;
  FCheckBoxHandle := 0;
  FTitleHandle := 0;
  FDialogFont := 0;
  FCheckOnInit := false;
end;

function TFolderDialogEx.CallbackProc(Wnd: THandle; Msg: Cardinal;
  LParam: Integer): Integer;
const
  CheckedParam: array [boolean] of DWORD = (BST_UNCHECKED, BST_CHECKED);
var
  TitleRect: TRect;
begin
  Result := inherited CallbackProc(Wnd, Msg, LParam);
  case Msg of
    BFFM_INITIALIZED:
      begin
        FTitleHandle := GetDlgItem(Handle, $3742);
        ShowWindow(FTitleHandle, SW_HIDE);
        FCheckBoxHandle := CreateWindow('BUTTON', PChar(''),
          WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX or BS_TOP or BS_MULTILINE,
          0, 0, 0, 0, Handle, 0, HInstance, nil);
        SendMessage(FCheckBoxHandle, BM_SETCHECK,
          CheckedParam[FCheckOnInit], 0);
        FDialogFont := SendMessage(Handle, WM_GETFONT, 0, 0);
        SendMessage(FCheckBoxHandle, WM_SETFONT, FDialogFont, 0);
        TitleRect := GetTitleRect;
        MoveWindow(FCheckBoxHandle, TitleRect.Left, TitleRect.Top,
          TitleRect.Right - TitleRect.Left, TitleRect.Bottom -
          TitleRect.Top, true);
      end;
  end;
end;

procedure TFolderDialogEx.WndProc(var Message: TMessage);
var
  TitleRect: TRect;
begin
  inherited;
  case Message.Msg of
    WM_SIZE:
      begin
        TitleRect := GetTitleRect;
        MoveWindow(FCheckBoxHandle, TitleRect.Left, TitleRect.Top,
          TitleRect.Right - TitleRect.Left, TitleRect.Bottom -
          TitleRect.Top, true);
      end;
    WM_DESTROY:
      FChecked := SendMessage(FCheckBoxHandle, BM_GETCHECK, 0, 0) = BST_CHECKED;
  end;
end;

function TFolderDialogEx.GetTitleRect: TRect;
begin
  if (Handle <> 0) and (FTitleHandle <> 0) then
  begin
    GetWindowRect(FTitleHandle, Result);
    MapWindowPoints(0, Handle, Result, 2);
  end;
end;

end.
