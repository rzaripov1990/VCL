unit OC_RichEditViewer;

{ TRichEditViewer v1.11 by Jordan Russell

  Known problem:
  If, after assigning rich text to a TRichEditViewer component, you change
  a property that causes the component's handle to be recreated, all text
  formatting will be lost. In the interests of code size, I do not intend
  to work around this.

  Rich Edit 2.0 and > 64 kb support added by Martijn Laan for My Inno Setup Extensions
  See http://isx.wintax.nl/ for more information

  $jrsoftware: issrc/Components/RichEditViewer.pas,v 1.11 2009/03/25 18:14:24 mlaan Exp $
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TZMRichView = class(TMemo)
  private
    FUseRichEdit: Boolean;
    FRichEditLoaded: Boolean;
    procedure SetRTFTextProp(const Value: AnsiString);
    procedure SetUseRichEdit(Value: Boolean);
    procedure UpdateBackgroundColor;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function SetRTFText(const Value: AnsiString): Integer;
    property RTFText: AnsiString write SetRTFTextProp;
  published
    property UseRichEdit: Boolean read FUseRichEdit write SetUseRichEdit default True;
  end;

procedure Register;

implementation

uses
  RichEdit, ShellApi;

const
  { Note: There is no 'W' 1.0 class }
  RICHEDIT_CLASS10A = 'RICHEDIT';
  RICHEDIT_CLASSA = 'RichEdit20A';
  RICHEDIT_CLASSW = 'RichEdit20W';
  EM_AUTOURLDETECT = WM_USER + 91;
  ENM_LINK = $04000000;
  EN_LINK = $070B;

type
  PEnLink = ^TEnLink;

  TEnLink = record
    nmhdr: TNMHdr;
    msg: UINT;
    wParam: wParam;
    lParam: lParam;
    chrg: TCharRange;
  end;

  TTextRange = record
    chrg: TCharRange;
    lpstrText: {$IFDEF UNICODE} PWideChar {$ELSE} PAnsiChar {$ENDIF};
  end;

var
  RichEditModule: HMODULE;
  RichEditUseCount: Integer = 0;
  RichEditVersion: Integer;

procedure LoadRichEdit;
begin
  if RichEditUseCount = 0 then
  begin
    RichEditVersion := 2;
    RichEditModule := LoadLibrary('RICHED20.DLL');
{$IFNDEF UNICODE}
    if RichEditModule = 0 then
    begin
      RichEditVersion := 1;
      RichEditModule := LoadLibrary('RICHED32.DLL');
    end;
{$ENDIF}
  end;
  Inc(RichEditUseCount);
end;

procedure UnloadRichEdit;
begin
  if RichEditUseCount > 0 then
  begin
    Dec(RichEditUseCount);
    if RichEditUseCount = 0 then
    begin
      FreeLibrary(RichEditModule);
      RichEditModule := 0;
    end;
  end;
end;

{ TZMRichView }

constructor TZMRichView.Create(AOwner: TComponent);
begin
  inherited;
  FUseRichEdit := True;
end;

destructor TZMRichView.Destroy;
begin
  inherited;
  { First do all other deinitialization, then decrement the DLL use count }
  if FRichEditLoaded then
  begin
    FRichEditLoaded := False;
    UnloadRichEdit;
  end;
end;

procedure TZMRichView.CreateParams(var Params: TCreateParams);
{ Based on code from TCustomRichEdit.CreateParams }
begin
  if UseRichEdit and not FRichEditLoaded then
  begin
    { Increment the DLL use count when UseRichEdit is True, load the DLL }
    FRichEditLoaded := True;
    LoadRichEdit;
  end;
  inherited;
  if UseRichEdit then
  begin
{$IFDEF UNICODE}
    CreateSubClass(Params, RICHEDIT_CLASSW);
{$ELSE}
    if RichEditVersion = 2 then
      CreateSubClass(Params, RICHEDIT_CLASSA)
    else
      CreateSubClass(Params, RICHEDIT_CLASS10A);
{$ENDIF}
  end
  else
    { Inherited handler creates a subclass of 'EDIT'.
      Must have a unique class name since it uses two different classes
      depending on the setting of the UseRichEdit property. }
    StrCat(Params.WinClassName, '/Text'); { don't localize! }
end;

procedure TZMRichView.CreateWnd;
var
  Mask: LongInt;
begin
  inherited;
  UpdateBackgroundColor;
  if FUseRichEdit and (RichEditVersion = 2) then
  begin
    Mask := ENM_LINK or SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
    SendMessage(Handle, EM_SETEVENTMASK, 0, lParam(Mask));
    SendMessage(Handle, EM_AUTOURLDETECT, wParam(True), 0);
  end;
end;

procedure TZMRichView.UpdateBackgroundColor;
begin
  if FUseRichEdit and HandleAllocated then
    SendMessage(Handle, EM_SETBKGNDCOLOR, 0, ColorToRGB(Color));
end;

procedure TZMRichView.SetUseRichEdit(Value: Boolean);
begin
  if FUseRichEdit <> Value then
  begin
    FUseRichEdit := Value;
    RecreateWnd;
    if not Value and FRichEditLoaded then
    begin
      { Decrement the DLL use count when UseRichEdit is set to False }
      FRichEditLoaded := False;
      UnloadRichEdit;
    end;
  end;
end;

type
  PStreamLoadData = ^TStreamLoadData;

  TStreamLoadData = record
    Buf: PByte;
    BytesLeft: Integer;
  end;

function StreamLoad(dwCookie: LongInt; pbBuff: PByte; cb: LongInt; var pcb: LongInt): LongInt; stdcall;
begin
  Result := 0;
  with PStreamLoadData(dwCookie)^ do
  begin
    if cb > BytesLeft then
      cb := BytesLeft;
    Move(Buf^, pbBuff^, cb);
    Inc(Buf, cb);
    Dec(BytesLeft, cb);
    pcb := cb;
  end;
end;

function TZMRichView.SetRTFText(const Value: AnsiString): Integer;

  function StreamIn(AFormat: wParam): Integer;
{$IFDEF DELPHI2}
  const
    SF_UNICODE = $0010;
{$ENDIF}
  var
    Data: TStreamLoadData;
    EditStream: TEditStream;
  begin
    Data.Buf := @Value[1];
    Data.BytesLeft := Length(Value);
    { Check for UTF-16 BOM }
    if (AFormat and SF_TEXT <> 0) and (Data.BytesLeft >= 2) and (PWord(Pointer(Value))^ = $FEFF) then
    begin
      AFormat := AFormat or SF_UNICODE;
      Inc(Data.Buf, 2);
      Dec(Data.BytesLeft, 2);
    end;
    EditStream.dwCookie := LongInt(@Data);
    EditStream.dwError := 0;
    EditStream.pfnCallback := @StreamLoad;
    SendMessage(Handle, EM_STREAMIN, AFormat, lParam(@EditStream));
    Result := EditStream.dwError;
  end;

begin
  if not FUseRichEdit then
  begin
    Text := String(Value);
    Result := 0;
  end
  else
  begin
    SendMessage(Handle, EM_EXLIMITTEXT, 0, lParam($7FFFFFFE));
    Result := StreamIn(SF_RTF);
    if Result <> 0 then
      Result := StreamIn(SF_TEXT);
  end;
end;

procedure TZMRichView.SetRTFTextProp(const Value: AnsiString);
begin
  SetRTFText(Value);
end;

procedure TZMRichView.CMColorChanged(var Message: TMessage);
begin
  inherited;
  UpdateBackgroundColor;
end;

procedure TZMRichView.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  UpdateBackgroundColor;
end;

procedure TZMRichView.CNNotify(var Message: TWMNotify);
var
  EnLink: PEnLink;
  CharRange: TCharRange;
  TextRange: TTextRange;
  Len: Integer;
  URL: String;
begin
  case Message.nmhdr^.code of
    EN_LINK:
      begin
        EnLink := PEnLink(Message.nmhdr);
        if EnLink.msg = WM_LBUTTONUP then
        begin
          CharRange := EnLink.chrg;
          if (CharRange.cpMin >= 0) and (CharRange.cpMax > CharRange.cpMin) then
          begin
            Len := CharRange.cpMax - CharRange.cpMin;
            Inc(Len); { for null terminator }
            if Len > 1 then
            begin
              SetLength(URL, Len);
              TextRange.chrg := CharRange;
              TextRange.lpstrText := PChar(URL);
              SetLength(URL, SendMessage(Handle, EM_GETTEXTRANGE, 0, lParam(@TextRange)));
              if URL <> '' then
                ShellExecute(Handle, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
            end;
          end;
        end;
      end;
  end;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMRichView]);
end;

end.
