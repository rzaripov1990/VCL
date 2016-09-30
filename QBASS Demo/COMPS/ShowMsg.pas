unit ShowMsg;

  |---------------------------------------------
  |  author: Zaripov Ravil aka ZuBy            |
  | contact:                                   |
  |          mail: rzaripov1990@gmail.com      |
  |          web : http://zuby.ucoz.kz         |
  |          Kazakhstan, Semey, © 2013         |
  |--------------------------------------------|

interface

uses
  Classes, Controls, Forms, StdCtrls, ExtCtrls, Buttons;

procedure ShowMessageEx(Title, Text: string);

implementation

procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;

function Max(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

procedure ShowMessageEx(Title, Text: string);
var
  Dialog: TForm;
  Button: TBitBtn;
  Caption: TLabel;
  Panel: TPanel;
  List: TStringList;
  Wdth, Hght, I: Integer;
begin
  Dialog := TForm.Create(Application);
  Dialog.Position := poScreenCenter;
  Dialog.BorderStyle := bsSingle;
  Dialog.BorderIcons := [biSystemMenu];
  Dialog.Font.Name := 'Courier New';
  Dialog.Font.Size := 8;
  Dialog.Caption := Title;

  Button := TBitBtn.Create(Dialog);
  Button.Parent := Dialog;
  Button.Caption := 'OK';
  Button.ModalResult := mrOk;

  Panel := TPanel.Create(Dialog);
  Panel.Parent := Dialog;
  Panel.Anchors := [akLeft, akTop, akRight, akBottom];
  Panel.Width := Dialog.ClientWidth;
  Panel.Height := (Dialog.ClientHeight - Button.Height) - 6;
  Panel.Ctl3D := false;
  Panel.Color := 16777215; // clWhite;
  Panel.FullRepaint := true;
  Panel.ParentColor := false;
  Panel.ParentBackground := false;

  Button.Top := Panel.Height + 4;
  Button.Left := (Dialog.ClientWidth - Button.Width) - 3;
  Button.Anchors := [akRight, akBottom];
  Button.Font.Name := 'Tahoma';
  Button.Font.Size := 8;

  List := TStringList.Create;
  List.Text := Text;

  Caption := TLabel.Create(Panel);
  Caption.Parent := Panel;
  Caption.Anchors := [akLeft, akTop, akRight, akBottom];
  Caption.Alignment := taLeftJustify;
  Caption.WordWrap := true;
  Caption.Caption := List.Text;
  Caption.ParentColor := false;
  Caption.Color := 16777215; // clWhite;
  Caption.Top := 5;
  Caption.Left := 5;
  Caption.Width := Panel.ClientWidth - 10;
  Caption.Height := Panel.ClientHeight - 10;
  Caption.Transparent := false;

  Wdth := 0;
  Hght := 0;
  if List.Count >= 0 then
  begin
    for I := 0 to List.Count - 1 do
      Wdth := Max(Wdth, Caption.Canvas.TextWidth(List.Strings[I]));

    Hght := Caption.Canvas.TextHeight('Hg') * List.Count - 1;
  end;

  Dialog.ClientWidth := Wdth + 10;
  Dialog.ClientHeight := Hght + ((Dialog.ClientHeight - Panel.Height) + 15);

  Dialog.ShowModal;

  FreeAndNil(List);
  FreeAndNil(Caption);
  FreeAndNil(Button);
  FreeAndNil(Panel);
  FreeAndNil(Dialog);
end;

end.
