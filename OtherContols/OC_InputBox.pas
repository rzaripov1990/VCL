unit OC_InputBox;

interface

uses
  Classes, Controls, Forms, StdCtrls, ExtCtrls, Buttons;

// Разбор полученного результата
procedure InputBoxExResult(const Result: string; var Value1, Value2: string);

// Диалог типа Логин-Пароль
function InputBoxEx(const ATitle, ACaption1, ACaption2: string;
  const ADefault1: string = ''; const ADefault2: string = '';
  const PasswordChar: Char = #0): string;

implementation

const
  Delim = '|';
  DelimLength = Length(Delim);

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

procedure InputBoxExResult(const Result: string; var Value1, Value2: string);
var
  p: Integer;
begin
  Value1 := '';
  Value2 := '';
  if Pos(Delim, Result) > 0 then
  begin
    p := Pos(Delim, Result);
    Value1 := Copy(Result, 1, p - 1);
    Value2 := Copy(Result, p + DelimLength, Length(Result));
  end;
end;

function InputBoxEx(const ATitle, ACaption1, ACaption2: string;
  const ADefault1: string = ''; const ADefault2: string = '';
  const PasswordChar: Char = #0): string;
var
  Dialog: TForm;
  ButtonOK, ButtonCancel: TBitBtn;
  Caption1, Caption2: TLabel;
  Edit1, Edit2: TEdit;
  Panel: TPanel;
  Wdth, Hght: Integer;
begin
  Result := ADefault1 + Delim + ADefault2;
  Dialog := TForm.Create(Application);
  Dialog.Position := poScreenCenter;
  Dialog.BorderStyle := bsSingle;
  Dialog.BorderIcons := [biSystemMenu];
  Dialog.Font.Name := 'Courier New';
  Dialog.Font.Size := 8;
  Dialog.Caption := ATitle;

  ButtonOK := TBitBtn.Create(Dialog);
  ButtonOK.Parent := Dialog;
  ButtonOK.Caption := 'OK';
  ButtonOK.ModalResult := mrOk;
  ButtonOK.Default := true;

  ButtonCancel := TBitBtn.Create(Dialog);
  ButtonCancel.Parent := Dialog;
  ButtonCancel.Caption := 'Отмена';
  ButtonCancel.ModalResult := mrCancel;

  Panel := TPanel.Create(Dialog);
  Panel.Parent := Dialog;
  Panel.Anchors := [akLeft, akTop, akRight, akBottom];
  Panel.Width := Dialog.ClientWidth;
  Panel.Height := (Dialog.ClientHeight - ButtonOK.Height) - 6;
  Panel.Ctl3D := false;
  Panel.Color := 16777215; // clWhite;
  Panel.FullRepaint := true;
  Panel.ParentColor := false;
  Panel.ParentBackground := false;

  ButtonCancel.Top := Panel.Height + 4;
  ButtonCancel.Left := (Dialog.ClientWidth - ButtonCancel.Width) - 3;
  ButtonCancel.Anchors := [akRight, akBottom];
  ButtonCancel.Font.Name := 'Tahoma';
  ButtonCancel.Font.Size := 8;

  ButtonOK.Top := ButtonCancel.Top;
  ButtonOK.Left := (ButtonCancel.Left - ButtonCancel.Width) - 3;
  ButtonOK.Anchors := [akRight, akBottom];
  ButtonOK.Font.Name := 'Tahoma';
  ButtonOK.Font.Size := 8;

  Caption1 := TLabel.Create(Panel);
  Caption1.Parent := Panel;
  Caption1.Anchors := [akLeft, akTop];
  Caption1.Alignment := taLeftJustify;
  Caption1.Caption := ACaption1;
  Caption1.ParentColor := false;
  Caption1.Color := 16777215; // clWhite;
  Caption1.Top := 10;
  Caption1.Left := 10;
  Caption1.AutoSize := true;
  Caption1.Transparent := false;

  Caption2 := TLabel.Create(Panel);
  Caption2.Parent := Panel;
  Caption2.Anchors := [akLeft, akTop];
  Caption2.Alignment := taLeftJustify;
  Caption2.Caption := ACaption2;
  Caption2.ParentColor := false;
  Caption2.Color := 16777215; // clWhite;
  Caption2.Top := Caption1.Top + Caption1.Height + 15;
  Caption2.Left := Caption1.Left;
  Caption2.AutoSize := true;
  Caption2.Transparent := false;

  Edit1 := TEdit.Create(Dialog);
  Edit1.Parent := Dialog;
  Edit1.Text := ADefault1;
  Edit1.Left := Max((Caption2.Left + Caption2.Width + 10),
    (Caption1.Left + Caption1.Width + 10));
  Edit1.Top := Caption1.Top - 2;

  Edit2 := TEdit.Create(Dialog);
  Edit2.Parent := Dialog;
  Edit2.Text := ADefault2;
  Edit2.PasswordChar := PasswordChar;
  Edit2.Left := Max((Caption2.Left + Caption2.Width + 10),
    (Caption1.Left + Caption1.Width + 10));
  Edit2.Top := Caption2.Top - 2;

  Wdth := Edit1.Left + Edit1.Width;
  Hght := Caption2.Top + Caption2.Height;

  Dialog.ClientWidth := Wdth + 15;
  Dialog.ClientHeight := Hght + ((Dialog.ClientHeight - Panel.Height) + 15);

  if Dialog.ShowModal = mrOk then
    Result := Edit1.Text + Delim + Edit2.Text;

  FreeAndNil(Caption1);
  FreeAndNil(Caption2);
  FreeAndNil(Edit1);
  FreeAndNil(Edit2);
  FreeAndNil(ButtonOK);
  FreeAndNil(ButtonCancel);
  FreeAndNil(Panel);
  FreeAndNil(Dialog);
end;

end.
