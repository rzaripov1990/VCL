unit OC_Playlist;

// ******************************************************************************
// author:  Zaripov Ravil aka ZuBy
// contacts:  icq : 400-464-936
// mail: zuby90@mail.ru
// mail: support@zubymplayer.com
// web : http://zubymplayer.com
// Kazakhstan, Semey, 2010
// ****************************** TZMSPlayList **********************************
// **************************** added in ver 0.1 ********************************
// + Управление через собсвенный скрол-бар
// + Встроенная поддержка Drag'n'Drop
// + Удобная обработка добавляемых файлов
// + Добавлены два списка типа TStringList
// 1-ый для "Артист - Заголовок", если строка не заполнена добавляется имя
// файла без расширения
// 2-ой для хранения общего времени трека в виде строки " 00:00" (6 символов)
// + Добавление файлов по маске
// + Возможность выбирать собственные цвета для покраски элементов
// + Обрабатывается событие при клике в пустое место, для показа PopupMenu (ПКМ)
// + Добавлено событие которое будет вызываться при "начале проигрывания",
// т.е. реагирует на DblClick, Enter.
// + Встроенная обработка "бытовых" клавиш.
// + Для более читаемого вида длинные строки обрезаються и добавляется "..."
// + Есть возможность отключения отрисовки "нумерации" и "общего времени"
// **************************** added in ver 0.2 ********************************
// + Есть возможность перемещать, менять элементы местами при помощи мыши
// + Автопокрутка при добавлении
// + Не добавляються уже существующие файлы это сделано для того чтобы "играющий"
// элемент не потерял фокус, если пути к файлам одинаковые
// + Встроенная прокрутка колесиком мышью
// + Настройка шага для покрутки плейлиста
// + Настройка шага для покрутки плейлиста с нажатой кнопкой Shift
// + Добавлено событие отвечающее за показ/скрытие собственного скрол-бара
// + Есть возможность отключения встроенного Drag'n'Drop
// + Если добавляется интернет адрес, то автоматически в строке времени, будет
// указано "Radio" (можно изменить см. своиство _RadioURL)
// **************************** added in ver 0.3 ********************************
// + При добавлении через Drag'n'Drop приложение не зависает
// + Добавлены функции _BeginUpdate, _EndUpdate
// + При уданении из листа, выделенный элемент не теряется
// + Добавлен список типа TStringList, предназначен для хранения состояния
// + Нажатием на колесико мыши (СКМ), можно изменять состояние элемента
// + При смене шрифта фокус с выделенного элемента не сбрасывается
// + Кнопка Space(пробел) отвечает за смену состояния элемента
// **************************** added in ver 0.4 ********************************
// + Прокрутка плейлиста доработана
// + Чтение 13 видов плейлистов:
// m3u, m3u8 - winamp,
// pls       - standart,
// asx, wpl  - windows media player,
// asx       - gom player,
// aap       - apollo player,
// xspf      - vlc media player,
// zpl       - zoom player,
// plz       - zubymplayer,
// plc       - aimp
// kpl       - kmplayer
// mpcpl     - media player classic  (only utf-8)
// lap       - light alloy
// + Сохранение плейлистов m3u, m3u8, pls, plz форматов
// + При загрузке плейлистов приложение не зависает
// + Добавлен флаг отвечающий за автоматическое обновление при добавлении файлов
// + При начале проигрывания элемент обновляется
// **************************** added in ver 0.5 ********************************
// + Исправлено чтение XSPF плейлиста
// + Добавлена функция _FormatTime, для правильного добавления времени в плейлист
// + Добавлено сохранение времени в плейлисты
// ******************************************************************************
// - Плейлист основан на TCustomListBox
// - Мерцание сильно заметно при скроллинге клавиатурой и при обработке MouseMove
// ******************************************************************************
// НЕ ИСПОЛЬЗОВАТЬ СТАНДАРТНЫЕ ФУНКЦИИ ITEMS.ADD/INSERT.
// ******************************************************************************

interface

{$T-,H+,X+}

uses
  Windows, Messages, SysUtils, Classes, VCl.Forms,
  VCl.Graphics, VCl.Controls, VCl.StdCtrls, winapi.ShellAPI;

type
  TOnAddString = procedure(Sender: TObject; const FileName: string;
    var Title, Time: string) of object;
  TOnEmptyXY = procedure(Sender: TObject; const X, Y, Index: integer;
    const Empty: boolean) of object;
  TOnScrollMax = procedure(Sender: TObject; Max: integer) of object;
  TOnScrollPos = procedure(Sender: TObject; Pos: integer) of object;
  TOnScrollVisible = procedure(Sender: TObject; Visible: boolean) of object;
  TOnTracking = procedure(Sender: TObject; const Index: integer;
    const FileName, Info, Time: string; const Disabled: boolean) of object;

  TInt = 1 .. 1000;
  TPLSType = (ptUnknown, ptM3U, ptM3U8, ptPLS, ptPLZ, ptASX, ptWPL, ptAAP,
    ptZPL, ptPLC, ptKPL, ptXSPF, ptMPCPL, ptLAP);
  TPLSSave = (psM3U, psM3U8, psPLS, psPLZ);

  TZMSPlayList = class(TCustomListBox)
  private
    fOnScrollPos: TOnScrollPos;
    fOnScrollMax: TOnScrollMax;
    fOnAddFile: TOnAddString;
    fOnTracking: TOnTracking;
    fOnEmptyXY: TOnEmptyXY;
    fOnScrollVis: TOnScrollVisible;

    fLastID: integer; // последнее выбранное ID (для перемещения)

    fBuffer: TBitmap; // буфер отрисовки

    fSelected, fSelText: TColor; // выделенный элемент
    fTracking, fTrackText: TColor; // проигрываемый элемент
    fNormalText: TColor; // остальные элементы
    fDisabled, fDisabledText: TColor; // неактивные элементы

    fTrackID: integer; // номер проигрываемого элемента
    fTrackIDStr: string; // текст проигрываемого элемента

    fFilter: string; // фильтр (маска) по которой добавляються файлы
    fPLSFilter: string; // фильтр (маска) для плейлистов
    fRadioUrl: string; // строка для URL/Radio

    fDragRct: TRect; // используеться для отрисовки при перемещении элементов
    fDraging: boolean; // флаг отвечающий за перемещение

    fWheel: integer;
    fWheelStep: TInt; // шаг для обычной прокрутки
    fWheelStepShift: TInt; // шаг для прокрутки с зажатой кнопкой Shift

    fActiveDrop: boolean; // активировать перемещение элементов внутри листа
    fActiveDragD: boolean; // активировать принятие файлов из проводника
    fAutoScroll: boolean;
    // активировать автоматическую прокрутку при добавлении файлов
    fActiveDisabled: boolean; // активировать возможность отключать элементы
    fAutoUpdate: boolean;
    // флаг отвечающий за автоматическое обновление при добавлении файлов
    fCheckExist: boolean; // активирует проверку добавляемых файлов

    fDrawNumber: boolean; // отрисовка нумерации
    fDrawTime: boolean; // отрисовка времени/радио

    fFileTag: TStringList; // используется для хранения тегов
    fTime: TStringList; // используется для хранения времени
    fSwitch: TStringList; // используеться для хранения состояния элементов

    procedure SetTrackID(Value: integer);
    procedure SetDrawNums(Value: boolean);
    procedure SetDrawTime(Value: boolean);
    procedure SetDropMode(Value: boolean);
    procedure SetDragNDropMode(Value: boolean);
    procedure SetDisabledMode(Value: boolean);

    function InFilter(const FileName: string): boolean;
    function IsNetString(Url: string): boolean;

    function GetVisibleItems: integer;
    procedure Exchange(Index1, Index2: integer; Value: boolean = false);
    procedure ExchangeItems(Index1, Index2: integer; Value: boolean);

    procedure AddStrings(const FileName: string; const SelfAdd: boolean = false;
      const Disabled: boolean = false);
    procedure InsertStrings(const FileName: string; const ID: integer;
      const SelfAdd: boolean = false; const Disabled: boolean = false);

    procedure UpdateScroll(Value: integer; Default: boolean = true);
    function CutStr(Text: string; FixWidth: integer): string;

    function GetPLSType(FileName: string): TPLSType;
    procedure ReadM3U(FileName: string);
    procedure ReadM3U8(FileName: string);
    procedure ReadPLS(FileName: string);
    procedure ReadAAP(FileName: string);
    procedure ReadXSPF(FileName: string);
    procedure ReadZPL(FileName: string);
    procedure ReadASX(FileName: string);
    procedure ReadWPL(FileName: string);
    procedure ReadPLZ(FileName: string);
    procedure ReadPLC(FileName: string);
    procedure ReadKPL(FileName: string);
    procedure ReadLAP(FileName: string);
    procedure ReadMPCPL(FileName: string);

    procedure SaveM3U(FileName: string);
    procedure SaveM3U8(FileName: string);
    procedure SavePLS(FileName: string);
    procedure SavePLZ(FileName: string);

  const
    nulltime = ' 00:00';
  protected
    // procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure WndProc(var Message: TMessage); override;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure MouseUP(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure DrawItem(Index: integer; Rect: TRect;
      State: TOwnerDrawState); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure DblClick; override;
    procedure Clear; override;
    procedure DeleteSelected; override;
    procedure CreateParams(var Params: TCreateParams); override;
    // procedure DragDrop(Source: TObject; X, Y: Integer); override;

    function GetArtistTitle(Index: integer): string;
    function GetTime(Index: integer): string;
    function GetFileName(Index: integer): string;
    function Disabled(Index: integer): boolean;
    procedure SetArtistTitle(Index: integer; New: string);
    procedure SetTime(Index: integer; New: string);
    procedure SetDisabled(Index: integer; Value: boolean);

    procedure AddString(const Str: string);
    procedure InsertString(const Index: integer; const Str: string);
    procedure ScanDir(StartDir: string; SubDirs: boolean = true);

    procedure OpenPLSFile(const FileName: string);
    procedure SavePLSFile(const FileName: string; const PLSType: TPLSSave);

    function FormatTime(const Sec: integer): string;

    procedure UnSelectedAll;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property clSelected: TColor read fSelected write fSelected
      default $001300AF;
    property clSelText: TColor read fSelText write fSelText default clWhite;
    property clTracking: TColor read fTracking write fTracking
      default $00615EFC;
    property clTrackText: TColor read fTrackText write fTrackText
      default clBlack;
    property Color;
    property clNormalText: TColor read fNormalText write fNormalText
      default clBlack;
    property clDisabled: TColor read fDisabled write fDisabled
      default $001900FF;
    property clDisabledText: TColor read fDisabledText write fDisabledText
      default $00615EFC;

    property MusicMask: string read fFilter write fFilter;
    property PLSMask: string read fPLSFilter;
    property RadioURL: string read fRadioUrl write fRadioUrl;

    property DrawNumbers: boolean read fDrawNumber write SetDrawNums
      default true;
    property DrawTime: boolean read fDrawTime write SetDrawTime default true;

    property TrackID: integer read fTrackID write SetTrackID;

    property ActiveDrop: boolean read fActiveDrop write SetDropMode
      default true;
    property ActiveDisabled: boolean read fActiveDisabled write SetDisabledMode
      default true;
    property ActiveDragAndDrop: boolean read fActiveDragD write SetDragNDropMode
      default true;
    property AutoScroll: boolean read fAutoScroll write fAutoScroll
      default false;
    property AutoUpdate: boolean read fAutoUpdate write fAutoUpdate
      default true;
    property CheckExist: boolean read fCheckExist write fCheckExist
      default true;

    property WheelStep: TInt read fWheelStep write fWheelStep default 1;
    property WheelStepShift: TInt read fWheelStepShift write fWheelStepShift
      default 10;

    property OnAddFile: TOnAddString read fOnAddFile write fOnAddFile;
    property OnScrollPos: TOnScrollPos read fOnScrollPos write fOnScrollPos;
    property OnScrollMax: TOnScrollMax read fOnScrollMax write fOnScrollMax;
    property OnScrollVisible: TOnScrollVisible read fOnScrollVis
      write fOnScrollVis;
    property OnTracking: TOnTracking read fOnTracking write fOnTracking;
    property OnEmpty: TOnEmptyXY read fOnEmptyXY write fOnEmptyXY;

    property Align;
    property Visible;
    property Enabled;
    property Font;
    property Anchors;
    property ItemIndex;
    property PopupMenu;
    property TabStop default false;
    property MultiSelect default true;
    property OnClick;
    property OnMouseLeave;
    property OnMouseEnter;
  end;

procedure Register;

implementation

// ******************************************************************************

procedure TZMSPlayList.WndProc(var Message: TMessage);
var
  nCount, i: integer;
  fName: array [0 .. 254] of Char;
begin
  inherited;
  case Message.Msg of

    LB_ADDSTRING:
      begin
        if Assigned(fOnAddFile) then
        begin
          AddStrings(PChar(Message.LParam));
          UpdateScroll(TopIndex);
        end;
      end;

    LB_INSERTSTRING:
      begin
        if Assigned(fOnAddFile) then
        begin
          InsertStrings(PChar(Message.LParam), Message.WParam);
          UpdateScroll(TopIndex);
        end;
      end;

    CM_FONTCHANGED:
      begin
        Canvas.Font := Font;
        if (fsBold in Font.Style) then
          ItemHeight := Canvas.TextHeight('H') + 7
        else
          ItemHeight := Canvas.TextHeight('H') + 5;
        UpdateScroll(TopIndex);
        if ItemIndex <> -1 then
          Selected[ItemIndex] := true;
      end;

    WM_KEYDOWN:
      begin
        case Message.WParam of
          VK_RETURN:
            SetTrackID(ItemIndex);
          VK_SPACE:
            SetDisabled(ItemIndex, not Disabled(ItemIndex));

          VK_DELETE:
            DeleteSelected;
          VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
            UpdateScroll(TopIndex);
        end;
      end;

    WM_DROPFILES:
      begin
        DragQueryFile(Message.WParam, 0, fName, SizeOf(fName));
        if (Pos(ExtractFileExt(fName), fPLSFilter) > 0) then
          OpenPLSFile(fName)
        else if DirectoryExists(fName) then
          ScanDir(fName)
        else
        begin
          nCount := DragQueryFile(Message.WParam, $FFFFFFFF, fName,
            SizeOf(fName));
          for i := 0 to nCount - 1 do
          begin
            Application.ProcessMessages;
            DragQueryFile(Message.WParam, i, fName, SizeOf(fName));
            AddStrings(fName, true);
            UpdateScroll(TopIndex);
          end;
        end;
        DragFinish(Message.WParam);
      end;

  end; // case .. of
end;
// ******************************************************************************

procedure TZMSPlayList.CMMouseWheel(var Message: TCMMouseWheel);
var
  IsNeg: boolean;
  ScrollPos: integer;
begin
  with Message do
  begin
    Inc(fWheel, WheelDelta);
    while Abs(fWheel) >= WHEEL_DELTA do
    begin
      IsNeg := fWheel < 0;
      fWheel := Abs(fWheel) - WHEEL_DELTA;
      if (IsNeg) then
      begin
        if fWheel <> 0 then
          fWheel := -fWheel;
        if TopIndex = -1 then
          exit;
        ScrollPos := TopIndex;

        if (ssShift in ShiftState) then
          Inc(ScrollPos, fWheelStepShift)
        else
          Inc(ScrollPos, fWheelStep);

        if ScrollPos > Count - 1 then
          ScrollPos := Count - 1;
        UpdateScroll(ScrollPos, false);
      end
      else
      begin
        if TopIndex = -1 then
          exit;
        ScrollPos := TopIndex;

        if (ssShift in ShiftState) then
          Dec(ScrollPos, fWheelStepShift)
        else
          Dec(ScrollPos, fWheelStep);

        if ScrollPos < 0 then
          ScrollPos := 0;
        UpdateScroll(ScrollPos, false);
      end;
    end; // while ... do
    Refresh;
  end; // message
end;
// ******************************************************************************

procedure TZMSPlayList.DrawItem(Index: integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Y, W: integer;
  Drawtxt: string;
begin
  if Index < Items.Count then
  begin
    SetBkMode(Canvas.Handle, TRANSPARENT);
    Y := (ItemHeight div 2) - (Canvas.TextHeight('Hh') div 2) - 1;

    if fDrawNumber then
      Drawtxt := IntToStr(Index + 1) + '. ' + fFileTag.Strings[Index]
    else
      Drawtxt := fFileTag.Strings[Index];

    if fDrawTime then
    begin
      W := ClientWidth - Canvas.TextWidth(fTime.Strings[Index]);
      Canvas.TextOut(W - 4, Rect.Top + Y, fTime.Strings[Index]);
    end
    else
      W := Width;

    Canvas.TextOut(Rect.Left + 4, Rect.Top + Y, CutStr(Drawtxt, W - 12));
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    State := TOwnerDrawState(LoWord(itemState));
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Color := Self.Color;

    if (integer(itemID) >= 0) and ((integer(itemID) >= TopIndex) and
      (integer(itemID) <= (TopIndex + GetVisibleItems))) then
    // отрисовка только видимых элементов
    begin

      if (State = [odFocused, odSelected]) or (State = [odSelected]) then
      begin
        Canvas.Brush.Color := fSelected;
        Canvas.Pen.Color := fSelected;
        Canvas.Font.Color := fSelText;
      end
      else if (integer(itemID) = Items.IndexOf(fTrackIDStr)) then
      begin
        Canvas.Brush.Color := fTracking;
        Canvas.Pen.Color := fTracking;
        Canvas.Font.Color := fTrackText;
      end
      else if Disabled(integer(itemID)) and (fActiveDisabled) then
      begin
        Canvas.Brush.Color := fDisabled;
        Canvas.Pen.Color := fDisabled;
        Canvas.Font.Color := fDisabledText;
      end
      else
      begin
        Color := Self.Color;
        Canvas.Brush.Color := Self.Color;
        Canvas.Pen.Color := Self.Color;
        Canvas.Font.Color := fNormalText;
      end;
      Canvas.RoundRect(rcItem.Left, rcItem.Top, rcItem.Right,
        rcItem.Bottom, 0, 0);
      DrawItem(itemID, rcItem, State);
    end
    else
    begin
      Color := Self.Color;
      Canvas.Brush.Color := Self.Color;
      Canvas.Pen.Color := Self.Color;
      Canvas.Font.Color := fNormalText;
      Canvas.FrameRect(rcItem);
    end;

    Canvas.Handle := 0;
  end;
end;
// ******************************************************************************

(* procedure TZMSPlayList.DragDrop(Source: TObject; X, Y: Integer);
  var
  Old, New: integer;
  begin
  Old := ItemIndex;
  New := ItemAtPos(Point(X, Y), true);
  if (Count = 0) then
  begin
  Refresh;
  exit;
  end;

  if (New = Count) {or (New = -1)} then
  begin
  Items.Add(Items[Old]);
  fFileTag.Add(fFileTag[Old]);
  fTime.Add(fTime[Old]);
  Items.Delete(Old);
  fFileTag.Delete(Old);
  fTime.Delete(Old);
  UpdateScroll(New, false);
  _UnSelectedAll;
  Selected[New] := true;
  end else
  if (New >= 0) and (New < Old) then
  begin
  Items.Move(Old, New);
  fFileTag.Move(Old, New);
  fTime.Move(Old, New);
  UpdateScroll(New, false);
  _UnSelectedAll;
  Selected[New] := true;
  end else
  if (New >= 0) and (New >= Old) then
  begin
  Items.Move(Old, New - 1);
  fFileTag.Move(Old, New - 1);
  fTime.Move(Old, New - 1);
  UpdateScroll(New, false);
  _UnSelectedAll;
  Selected[New-1] := true;
  end;
  Refresh;
  end;
  //******************************************************************************

  procedure TZMSPlayList.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
  var
  I: integer;
  R: TRect;
  begin
  I := ItemAtPos(Point(X, Y), true);
  Accept := (Source = Self) and (I <> ItemIndex) and (fActiveDrop);
  if Accept then
  begin
  if (Y < 5) or ((ClientHeight - Y) <= 5) then
  begin
  if Y < 5 then
  begin
  Perform(WM_VSCROLL, SB_LINEUP, 0);
  Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
  Refresh;
  end else
  if (ClientHeight - Y) <= 5 then
  begin
  Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
  Refresh;
  end;
  end;

  with Canvas do
  begin
  Pen.Width := 1;
  Pen.Color := clNavy;
  Pen.Style := psSolid;
  Pen.Mode := pmNotXor;

  if fDraging then
  begin
  MoveTo(fDragRct.Left, fDragRct.Top);
  LineTo(fDragRct.Right, fDragRct.Top);
  end;

  if (I < Count)  then
  begin
  R := ItemRect(I);
  end else
  begin
  R := ItemRect(I - 1);
  R.Top := R.Bottom;
  end;

  MoveTo(R.Left, R.Top);
  LineTo(R.Right, R.Top);
  fDragRct := R;
  fDraging := true;
  end;
  end else
  begin
  Refresh;
  fDraging := false;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  end;
  end; *)
// ******************************************************************************

procedure TZMSPlayList.DeleteSelected;
var
  i: integer;
begin
  if Items.Count = -1 then
    exit;
  if MultiSelect then
  begin
    for i := Items.Count - 1 downto 0 do
    begin
      if Selected[i] then
      begin
        if i = fTrackID then
          SetTrackID(-1);
        if Disabled(i) then
          fSwitch.Delete(fSwitch.IndexOf(Items[i]));
        Items.Delete(i);
        fFileTag.Delete(i);
        fTime.Delete(i);
      end;
    end;
  end
  else if ItemIndex <> -1 then
  begin
    Items.Delete(ItemIndex);
    fFileTag.Delete(ItemIndex);
    fTime.Delete(ItemIndex);
    if ItemIndex = fTrackID then
      SetTrackID(-1);
    if Disabled(ItemIndex) then
      fSwitch.Delete(fSwitch.IndexOf(Items[ItemIndex]));
  end;

  if (ItemIndex < Count) then
  begin
    ItemIndex := ItemIndex + 1;
    Selected[ItemIndex] := true;
  end;

  UpdateScroll(TopIndex);
  // Refresh;
  Repaint;
end;
// ******************************************************************************

procedure TZMSPlayList.Clear;
begin
  inherited Clear;
  fFileTag.Clear;
  fTime.Clear;
  fSwitch.Clear;
  SetTrackID(-1);
  UpdateScroll(TopIndex);
end;
// ******************************************************************************

procedure TZMSPlayList.AddStrings(const FileName: string;
  const SelfAdd: boolean = false; const Disabled: boolean = false);
var
  Ext, Name: string;
  aFile, aTime: string;
begin
  if (Items.IndexOf(FileName) <> -1) then
    exit;

  if IsNetString(FileName) then
  begin
    if SelfAdd then
      Items.Add(FileName);
    fFileTag.Add(FileName);
    fTime.Add(fRadioUrl);
    if Disabled then
      fSwitch.Add(FileName);
  end
  else if InFilter(FileName) then
  begin
    if (not FileExists(FileName)) and (fCheckExist) then
      exit;

    Ext := ExtractFileExt(FileName);
    Name := ExtractFileName(FileName);

    if SelfAdd then
      Items.Add(FileName);
    if Disabled then
      fSwitch.Add(FileName);

    aFile := '';
    aTime := '';
    if Assigned(fOnAddFile) and (fAutoUpdate) then
      fOnAddFile(Self, FileName, aFile, aTime);

    if (Length(aFile) = 0) then
      aFile := Copy(Name, 1, Length(Name) - Length(Ext));
    if (Length(aTime) < 6) or (Length(aTime) > 6) then
      aTime := nulltime;

    fFileTag.Add(aFile);
    fTime.Add(aTime);
  end;
  if fAutoScroll then
    ItemIndex := Items.Count - 1;
end;
// ******************************************************************************

procedure TZMSPlayList.InsertStrings(const FileName: string; const ID: integer;
  const SelfAdd: boolean = false; const Disabled: boolean = false);
var
  Ext, Name: string;
  aFile, aTime: string;
begin
  if Items.IndexOf(FileName) <> -1 then
    exit;

  if IsNetString(FileName) then
  begin
    if SelfAdd then
      Items.Insert(ID, FileName);
    fFileTag.Insert(ID, FileName);
    fTime.Insert(ID, fRadioUrl);
    if Disabled then
      fSwitch.Add(FileName);
  end
  else if InFilter(FileName) then
  begin
    if (not FileExists(FileName)) and (fCheckExist) then
      exit;

    Ext := ExtractFileExt(FileName);
    Name := ExtractFileName(FileName);

    if SelfAdd then
      Items.Insert(ID, FileName);
    if Disabled then
      fSwitch.Add(FileName);

    aFile := '';
    aTime := '';
    if Assigned(fOnAddFile) and (fAutoUpdate) then
      fOnAddFile(Self, FileName, aFile, aTime);

    if (Length(aFile) = 0) then
      aFile := Copy(Name, 1, Length(Name) - Length(Ext));
    if (Length(aTime) < 6) or (Length(aTime) > 6) then
      aTime := nulltime;
    fFileTag.Insert(ID, aFile);
    fTime.Insert(ID, aTime);
  end;
  if fAutoScroll then
    ItemIndex := ID;
end;
// ******************************************************************************

procedure TZMSPlayList.ScanDir(StartDir: string; SubDirs: boolean = true);
var
  SearchRec: TSearchRec;
begin
  if StartDir[Length(StartDir)] <> '\' then
    StartDir := StartDir + '\';
  if FindFirst(StartDir + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      Application.ProcessMessages;
      if (SearchRec.Attr and faDirectory) <> faDirectory then
        AddStrings(StartDir + SearchRec.Name, true)
      else if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') and (SubDirs)
      then
        ScanDir(StartDir + SearchRec.Name + '\');
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;
// ******************************************************************************

function TZMSPlayList.CutStr(Text: string; FixWidth: integer): string;
var
  ReturnText: string;
begin
  Result := '';
  if Canvas.TextWidth(Text) > FixWidth then
  begin
    ReturnText := Text;
    while (Canvas.TextWidth(ReturnText + '...') > FixWidth) do
    begin
      if Length(ReturnText) > 1 then
        System.Delete(ReturnText, Length(ReturnText), 1)
      else
      begin
        ReturnText := '';
        break;
      end;
    end;
    ReturnText := ReturnText + '...';
  end
  else
    ReturnText := Text;
  Result := ReturnText;
end;
// ******************************************************************************

function TZMSPlayList.GetVisibleItems: integer;
var
  viscnt: integer;
begin
  try
    viscnt := Height div ItemHeight;
  except
    viscnt := 0;
  end;
  Result := viscnt;
end;
// ******************************************************************************

procedure TZMSPlayList.Exchange(Index1, Index2: integer;
  Value: boolean = false);
begin
  if Index1 = Index2 then
    exit;
  if (Index1 < 0) or (Index1 >= Count) then
    exit;
  if (Index2 < 0) or (Index2 >= Count) then
    exit;
  // ExchangeItems(Index1, Index2, Value);
end;
// ******************************************************************************

procedure TZMSPlayList.ExchangeItems(Index1, Index2: integer; Value: boolean);
var
  tmp1, tmp2, tmp3: string;
  i: integer;
begin
  if Value then
  begin
    tmp1 := Items[Index1];
    tmp2 := fFileTag.Strings[Index1];
    tmp3 := fTime.Strings[Index1];

    Items[Index1] := Items[Index2];
    fFileTag.Strings[Index1] := fFileTag.Strings[Index2];
    fTime.Strings[Index1] := fTime.Strings[Index2];

    Items[Index2] := tmp1;
    fFileTag.Strings[Index2] := tmp2;
    fTime.Strings[Index2] := tmp3;
  end
  else
  begin
    if Index1 > Index2 then
    begin
      for i := Index1 - 1 downto Index2 do
      begin
        tmp1 := Items[i + 1];
        tmp2 := fFileTag.Strings[i + 1];
        tmp3 := fTime.Strings[i + 1];

        Items[i + 1] := Items[i];
        fFileTag.Strings[i + 1] := fFileTag.Strings[i];
        fTime.Strings[i + 1] := fTime.Strings[i];

        Items[i] := tmp1;
        fFileTag.Strings[i] := tmp2;
        fTime.Strings[i] := tmp3;
      end;
    end
    else
    begin
      for i := Index1 + 1 to Index2 do
      begin
        tmp1 := Items[i - 1];
        tmp2 := fFileTag.Strings[i - 1];
        tmp3 := fTime.Strings[i - 1];

        Items[i - 1] := Items[i];
        fFileTag.Strings[i - 1] := fFileTag.Strings[i];
        fTime.Strings[i - 1] := fTime.Strings[i];

        Items[i] := tmp1;
        fFileTag.Strings[i] := tmp2;
        fTime.Strings[i] := tmp3;
      end;
    end;
  end;
end;
// ******************************************************************************

function TZMSPlayList.IsNetString(Url: string): boolean;
begin
  Result := false;
  if (Copy(LowerCase(Url), 1, 7) = 'http://') or
    (Copy(LowerCase(Url), 1, 6) = 'ftp://') or
    (Copy(LowerCase(Url), 1, 6) = 'mms://') then
    Result := true;
end;
// ******************************************************************************

function TZMSPlayList.InFilter(const FileName: string): boolean;
var
  Ext: string;
begin
  Result := false;
  Ext := ExtractFileExt(FileName);
  if Pos(Ext, fFilter) > 0 then
    Result := true;
end;
// ******************************************************************************

procedure TZMSPlayList.UpdateScroll(Value: integer; Default: boolean = true);
var
  ScrollPos: integer;
  // VisCnt: integer;
begin
  // VisCnt := ClientHeight div ItemHeight;
  if (Assigned(fOnScrollMax)) then
  begin
    if (Items.Count <= 1) or (Count - GetVisibleItems <= 0) then
      fOnScrollMax(Self, 100)
    else
      fOnScrollMax(Self, (Count - GetVisibleItems));
  end;

  if TopIndex = -1 then
    ScrollPos := 0
  else if not Default then
  begin
    ScrollPos := Value;
    TopIndex := ScrollPos;
  end
  else
    ScrollPos := TopIndex;

  if (Assigned(fOnScrollPos)) then
    fOnScrollPos(Self, ScrollPos);

  if Assigned(fOnScrollVis) then
    fOnScrollVis(Self, ((Count * ItemHeight) >= ClientHeight));

  if fTrackID <> -1 then
    fTrackID := Items.IndexOf(fTrackIDStr);
end;
// ******************************************************************************

procedure TZMSPlayList.SetTrackID(Value: integer);
var
  aFile, aTime, Ext: string;
begin
  if (Value > -2) and (Value < Count) then
  begin
    fTrackID := Value;
    if fTrackID = -1 then
    begin
      fTrackIDStr := '';
      Refresh;
      exit;
    end;
    fTrackIDStr := Items[fTrackID];
    UpdateScroll(TopIndex);
    // Refresh;
    Repaint;

    if Assigned(fOnAddFile) then
    begin
      Ext := ExtractFileExt(fTrackIDStr);
      aFile := '';
      aTime := '';
      fOnAddFile(Self, fTrackIDStr, aFile, aTime);

      if (Length(aFile) = 0) then
        aFile := Copy(Name, 1, Length(Name) - Length(Ext));
      if (Length(aTime) < 6) or (Length(aTime) > 6) then
      begin
        if IsNetString(fTrackIDStr) then
          aTime := fRadioUrl
        else
          aTime := nulltime;
      end;

      fFileTag.Strings[fTrackID] := aFile;
      fTime.Strings[fTrackID] := aTime;
    end;

    if Assigned(fOnTracking) then
      fOnTracking(Self, fTrackID, GetFileName(fTrackID),
        GetArtistTitle(fTrackID), GetTime(fTrackID), Disabled(fTrackID));
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDrawNums(Value: boolean);
begin
  if Value <> fDrawNumber then
  begin
    fDrawNumber := Value;
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDrawTime(Value: boolean);
begin
  if Value <> fDrawTime then
  begin
    fDrawTime := Value;
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDropMode(Value: boolean);
begin
  if Value <> fActiveDrop then
  begin
    fActiveDrop := Value;
    { if fActiveDrop then
      DragMode := dmAutomatic
      else }
    DragMode := dmManual;
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDragNDropMode(Value: boolean);
begin
  if Value <> fActiveDragD then
  begin
    fActiveDragD := Value;
    DragAcceptFiles(Handle, fActiveDragD);
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDisabledMode(Value: boolean);
begin
  if fActiveDisabled <> Value then
  begin
    fActiveDisabled := Value;
    if not fActiveDisabled then
      fSwitch.Clear;
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

function TZMSPlayList.GetArtistTitle(Index: integer): string;
begin
  Result := '';
  if (Index > -1) and (Index < Count) then
    Result := fFileTag.Strings[Index];
end;
// ******************************************************************************

function TZMSPlayList.GetTime(Index: integer): string;
begin
  Result := '';
  if (Index > -1) and (Index < Count) then
    Result := fTime.Strings[Index];
end;
// ******************************************************************************

function TZMSPlayList.GetFileName(Index: integer): string;
begin
  Result := '';
  if (Index > -1) and (Index < Count) then
    Result := Items[Index];
end;
// ******************************************************************************

function TZMSPlayList.Disabled(Index: integer): boolean;
begin
  Result := fSwitch.IndexOf(Items[Index]) <> -1;
end;
// ******************************************************************************

procedure TZMSPlayList.SetArtistTitle(Index: integer; New: string);
begin
  if (Index > -1) and (Index < Count) and (New <> '') then
    fFileTag.Strings[Index] := New;
end;
// ******************************************************************************

procedure TZMSPlayList.SetTime(Index: integer; New: string);
begin
  if (Index > -1) and (Index < Count) and (New <> '') then
    fTime.Strings[Index] := New;
end;
// ******************************************************************************

procedure TZMSPlayList.SetDisabled(Index: integer; Value: boolean);
begin
  if (Index > -1) and (Index < Count) then
  begin
    if (fSwitch.IndexOf(Items[Index]) = -1) and (Value) then
      fSwitch.Add(Items[Index])
    else if (fSwitch.IndexOf(Items[Index]) <> -1) and (not Value) then
      fSwitch.Delete(fSwitch.IndexOf(Items[Index]));
    Repaint;
    // Refresh;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.AddString(const Str: string);
begin
  AddStrings(Str, true);
  UpdateScroll(TopIndex);
end;
// ******************************************************************************

procedure TZMSPlayList.InsertString(const Index: integer; const Str: string);
begin
  InsertStrings(Str, index, true);
  UpdateScroll(TopIndex);
end;
// ******************************************************************************

procedure TZMSPlayList.OpenPLSFile(const FileName: string);
var
  tp: TPLSType;
begin
  tp := GetPLSType(FileName);
  if tp = ptUnknown then
    exit;
  Clear;
  case tp of
    ptM3U:
      ReadM3U(FileName);
    ptM3U8:
      ReadM3U8(FileName);
    ptPLS:
      ReadPLS(FileName);
    ptPLZ:
      ReadPLZ(FileName);
    ptASX:
      ReadASX(FileName);
    ptWPL:
      ReadWPL(FileName);
    ptAAP:
      ReadAAP(FileName);
    ptXSPF:
      ReadXSPF(FileName);
    ptZPL:
      ReadZPL(FileName);
    ptPLC:
      ReadPLC(FileName);
    ptKPL:
      ReadKPL(FileName);
    ptMPCPL:
      ReadMPCPL(FileName);
    ptLAP:
      ReadLAP(FileName);
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.SavePLSFile(const FileName: string;
  const PLSType: TPLSSave);
begin
  case PLSType of
    psM3U:
      SaveM3U(FileName);
    psM3U8:
      SaveM3U8(FileName);
    psPLS:
      SavePLS(FileName);
    psPLZ:
      SavePLZ(FileName);
  end;
end;
// ******************************************************************************

function TZMSPlayList.FormatTime(const Sec: integer): string;
var
  H, M, S: integer;
  Return: string;
begin
  H := Sec div 3600;
  S := Sec mod 3600;
  M := S div 60;
  M := M + (H * 60);
  S := (S mod 60);
  Return := Format('%2.2d:%2.2d', [M, S]);
  if (Length(Return) = 5) then
    Result := ' ' + Return;
  // ' 00:00' - 6 chars
end;
// ******************************************************************************

procedure TZMSPlayList.UnSelectedAll;
var
  i: integer;
begin
  for i := Items.Count - 1 downto 0 do
  begin
    if Selected[i] then
      Selected[i] := false;
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.BeginUpdate;
begin
  Items.BeginUpdate;
  fFileTag.BeginUpdate;
  fTime.BeginUpdate;
end;
// ******************************************************************************

procedure TZMSPlayList.EndUpdate;
begin
  Items.EndUpdate;
  fFileTag.EndUpdate;
  fTime.EndUpdate;
end;
// ******************************************************************************

constructor TZMSPlayList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fBuffer := TBitmap.Create;

  fFileTag := TStringList.Create;
  fTime := TStringList.Create;
  fSwitch := TStringList.Create;

  fFilter := '*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif;' +
    '*.wma;*.wv;*.tta;*.spx;*.mpc;*.mp+;' +
    '*.mpp*.oga;*.flac;*.ape;*.mac;*.m4a;' + '*.ac3;*.mp4;*.aac';

  fPLSFilter := '*.m3u;*.m3u8;*.pls;*.asx;*.wpl;*.aap;*.xspf;' +
    '*.kpl;*.zpl;*.plz;*.plc;*.mpcpl;*.lap;';

  fRadioUrl := 'Radio';

  ItemHeight := 20;
  fTrackID := -1;
  fTrackIDStr := '';

  fDrawNumber := true;
  fDrawTime := true;

  BorderStyle := bsNone;
  BorderWidth := 0;

  MultiSelect := true;
  TabStop := false;
  DoubleBuffered := true;
  AutoComplete := false;

  // ControlStyle := ControlStyle - [csOpaque] - [csDisplayDragImage];
  // DragMode := dmAutomatic;
  // DragCursor := crHandPoint;

  Color := $001900FF;
  ParentColor := false;

  fActiveDrop := true;
  fActiveDragD := true;
  fAutoScroll := false;
  fActiveDisabled := true;
  fAutoUpdate := true;
  fCheckExist := true;

  fWheel := 0;
  fWheelStep := 1;
  fWheelStepShift := 10;

  fSelected := $001300AF;
  fSelText := clWhite;
  fTracking := $00615EFC;
  fTrackText := clBlack;
  fNormalText := clWhite;
  fDisabled := $001900FF;
  fDisabledText := $00615EFC;

  Screen.Cursors[crHandPoint] := LoadCursor(0, IDC_HAND);
end;
// ******************************************************************************

destructor TZMSPlayList.Destroy;
begin
  fFileTag.Free;
  fSwitch.Free;
  fTime.Free;
  fBuffer.Free;

  fFileTag := nil;
  fSwitch := nil;
  fTime := nil;
  fBuffer := nil;

  inherited Destroy;
end;
// ******************************************************************************

procedure TZMSPlayList.DblClick;
begin
  if (Count = -1) then
    exit;
  inherited;
  SetTrackID(ItemIndex);
end;
// ******************************************************************************

procedure TZMSPlayList.Click;
var
  pnt: TPoint;
begin
  pnt := ScreenToClient(Mouse.CursorPos);

  fDraging := false;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  Repaint;
  // Refresh;
  if (Count = -1) and (ItemAtPos(pnt, true) = -1) then
    exit;
  inherited;
end;
// ******************************************************************************

procedure TZMSPlayList.Resize;
begin
  inherited;
  UpdateScroll(TopIndex);
end;
// ******************************************************************************

procedure TZMSPlayList.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  ID: integer;
  fnd: string;
begin
  ID := ItemAtPos(Point(X, Y), true);
  fLastID := ID;

  if (Button = mbMiddle) then
  begin
    if ID = -1 then
      exit;
    ItemIndex := ID;
    fnd := Items[ID];
    SetDisabled(ID, fSwitch.IndexOf(fnd) = -1);
  end;

  if Button <> mbRight then
    exit;
  if Assigned(fOnEmptyXY) then
    fOnEmptyXY(Self, X, Y, ID, (ID = -1));
end;
// ******************************************************************************

procedure TZMSPlayList.MouseMove(Shift: TShiftState; X, Y: integer);
begin
  if (ssLeft in Shift) then
  begin
    { //fLastID := ItemAtPos(Point(X,Y), true);
      if fLastID = -1 then exit;

      if fLastID < 0 then fLastID := 0
      else begin
      if fLastID >= Count then fLastID := Count - 1;
      end;

      if (ItemIndex <> fLastID) and (fActiveDrop) and
      (fLastID >= 0) or (fLastID <= Pred(Count)) then
      begin
      if (TopIndex > fLastID) then TopIndex := fLastID;
      if ((GetVisibleItems + Pred(TopIndex)) < fLastID) then
      TopIndex := Abs(GetVisibleItems - (fLastID + 1));

      Exchange(ItemIndex, fLastID);
      ItemIndex := fLastID;
      fLastID := Items.IndexOf(Items[ItemIndex]);
      UpdateScroll(TopIndex);
      end else }
    UpdateScroll(TopIndex);
  end;
end;
// ******************************************************************************

procedure TZMSPlayList.MouseUP(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  fLastID := -1;
end;
// ******************************************************************************

procedure TZMSPlayList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style xor WS_VSCROLL or LBS_OWNERDRAWVARIABLE or
    LBS_HASSTRINGS;
  Params.ExStyle := Params.ExStyle or WS_EX_ACCEPTFILES;
end;
// ******************************************************************************

function IniReadString(const FFileName, Section, Ident,
  Default: string): string;
var
  Buffer: array [0 .. 1023] of Char;
begin
  SetString(Result, Buffer, GetPrivateProfileStringW(PChar(Section),
    PChar(Ident), PChar(Default), Buffer, SizeOf(Buffer), PChar(FFileName)));
end;
// ******************************************************************************

function IniReadInteger(const FFileName, Section, Ident: string;
  Default: Longint): Longint;
var
  IntStr: string;
begin
  IntStr := IniReadString(PChar(FFileName), Section, Ident, '');
  if (Length(IntStr) > 2) and (IntStr[1] = '0') and
    ((IntStr[2] = 'X') or (IntStr[2] = 'x')) then
    IntStr := '$' + Copy(IntStr, 3, Maxint);
  Result := StrToIntDef(IntStr, Default);
end;
// ******************************************************************************

function URLDecode(const S: AnsiString): AnsiString;

  function DigitToHex(Digit: integer): AnsiChar;
  begin
    case Digit of
      0 .. 9:
        Result := AnsiChar(Chr(Digit + Ord('0')));
      10 .. 15:
        Result := AnsiChar(Chr(Digit - 10 + Ord('A')));
    else
      Result := '0';
    end;
  end;

  function WebHexToInt(HexChar: AnsiChar): integer;
  begin
    if HexChar < '0' then
      Result := Ord(HexChar) + 256 - Ord('0')
    else if HexChar <= Chr(Ord('A') - 1) then
      Result := Ord(HexChar) - Ord('0')
    else if HexChar <= Chr(Ord('a') - 1) then
      Result := Ord(HexChar) - Ord('A') + 10
    else
      Result := Ord(HexChar) - Ord('a') + 10;
  end;

var
  i, idx, len, n_coded: integer;
begin
  len := 0;
  n_coded := 0;

  for i := 1 to Length(S) do
  begin
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
        n_coded := 0;
    end
    else
    begin
      len := len + 1;
      if S[i] = '%' then
        n_coded := 1;
    end;
  end;

  SetLength(Result, len);
  idx := 0;
  n_coded := 0;

  for i := 1 to Length(S) do
  begin
    if n_coded >= 1 then
    begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then
      begin
        Result[idx] :=
          AnsiChar(Chr((WebHexToInt(S[i - 1]) * 16 + WebHexToInt(S[i]))
          mod 256));
        n_coded := 0;
      end;
    end
    else
    begin
      idx := idx + 1;
      if S[i] = '%' then
        n_coded := 1;
      if S[i] = '+' then
        Result[idx] := ' '
      else
        Result[idx] := S[i];
    end;
  end;
end;
// ******************************************************************************

function DecodeTime(Time: string): string;
const
  define = ' 0123456789:';
var
  i, L, R: integer;
  breaked: boolean;
begin
  breaked := false;
  Result := '0';
  for i := 1 to Length(Time) do
  begin
    if (Pos(Time[i], define) = 0) then
    begin
      breaked := true;
      break;
    end;
  end;

  if (not breaked) and (Length(Time) = 6) then
  begin
    L := StrToInt(Copy(Time, 2, 2));
    R := StrToInt(Copy(Time, 5, 7));
    Result := IntToStr(L * 60 + R);
  end;
end;
// ******************************************************************************

function TZMSPlayList.GetPLSType(FileName: string): TPLSType;
var
  TypeStr: TPLSType;
  Ext: string;
begin
  TypeStr := ptUnknown;
  if FileExists(FileName) then
  begin
    Ext := LowerCase(ExtractFileExt(FileName));
    if (Pos('.m3u', Ext) > 0) then
      TypeStr := ptM3U
    else if (Pos('.m3u8', Ext) > 0) then
      TypeStr := ptM3U8
    else if Pos('.asx', Ext) > 0 then
      TypeStr := ptASX
    else if Pos('.wpl', Ext) > 0 then
      TypeStr := ptWPL
    else if Pos('.aap', Ext) > 0 then
      TypeStr := ptAAP
    else if Pos('.xspf', Ext) > 0 then
      TypeStr := ptXSPF
    else if Pos('.zpl', Ext) > 0 then
      TypeStr := ptZPL
    else if Pos('.plz', Ext) > 0 then
      TypeStr := ptPLZ
    else if Pos('.plc', Ext) > 0 then
      TypeStr := ptPLC
    else if Pos('.pls', Ext) > 0 then
      TypeStr := ptPLS
    else if Pos('.mpcpl', Ext) > 0 then
      TypeStr := ptMPCPL
    else if Pos('.kpl', Ext) > 0 then
      TypeStr := ptKPL
    else if Pos('.lap', Ext) > 0 then
      TypeStr := ptLAP;
  end;
  Result := TypeStr;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadM3U(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName);
  if UpperCase(fl.Strings[0]) = '#EXTM3U' then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (Pos('#EXTINF:', UpperCase(S)) = 0) then
      begin
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(S, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadM3U8(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.UTF8);
  if UpperCase(fl.Strings[0]) = '#EXTM3U' then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (Pos('#EXTINF:', UpperCase(S)) = 0) then
      begin
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(S, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadPLZ(FileName: string);
var
  i: integer;
  S: string;
  Dis: boolean;
  fl: TStringList;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.UTF8);
  if (fl.Strings[0] = '[ZuByMPlayer_List]') then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (S[2] = '0') or (S[2] = '1') then
        Dis := (S[2] = '0')
      else
        AddStrings(S, true, Dis);
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadPLC(FileName: string);
var
  i: integer;
  S, RealFile: string;
  fl: TStringList;
  Dis: boolean;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.Unicode);
  S := fl.Strings[0];
  if (S[1] = '<') and (S[Length(S)] = '>') then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (S[1] = '0') or (S[1] = '1') then
      begin
        RealFile := Copy(S, 3, Pos('|', Copy(S, 3, Length(S))) - 1);
        Dis := (S[1] = '0');
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(RealFile, true, Dis);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadPLS(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
  cnt, c: integer;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.UTF8);
  c := 1;
  cnt := IniReadInteger(FileName, 'playlist', 'NumberOfEntries', 0);
  if cnt <> 0 then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := LowerCase(fl.Strings[i]);
      if Pos('file', S) > 0 then
      begin
        S := IniReadString(FileName, 'playlist', 'File' + IntToStr(c), '');
        Inc(c);
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(S, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadKPL(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
  cnt, c: integer;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.Unicode);
  c := 1;
  cnt := IniReadInteger(FileName, 'playlist', 'NumberOfEntries', 0);
  if cnt <> 0 then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := LowerCase(fl.Strings[i]);
      if Pos('file', S) > 0 then
      begin
        S := IniReadString(FileName, 'playlist', 'File' + IntToStr(c), '');
        Inc(c);
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(S, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadZPL(FileName: string);
const
  nm = 'nm=';
  lnm = Length(nm);
var
  i: integer;
  S: string;
  fl: TStringList;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.Unicode);
  for i := 0 to fl.Count - 1 do
  begin
    Application.ProcessMessages;
    S := fl.Strings[i];
    if Pos(nm, LowerCase(S)) > 0 then
    begin
      S := Copy(S, lnm + 1, Length(S));
      if (Length(S) > 3) and (Pos('.cue', S) = 0) then
        AddStrings(S, true);
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadAAP(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
  cnt, c: integer;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName);
  c := 1;
  if fl.Strings[0] <> '[Apollo Advanced Playlist]' then
  begin
    fl.Free;
    exit;
  end;
  cnt := IniReadInteger(FileName, 'Entries', 'NumberOfEntries', 0);
  if cnt <> 0 then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if Pos('entry', LowerCase(S)) > 0 then
      begin
        S := IniReadString(FileName, 'Entries', 'Entry' + IntToStr(c), '');
        Inc(c);
        if (Length(S) > 3) and (Pos('.cue', S) = 0) then
          AddStrings(S, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadXSPF(FileName: string);
const
  BeginTag = '<location>file:///';
  EndTag = '</location>';
  Len1 = Length(BeginTag) + 3;
  Len2 = Length(EndTag);
var
  i: integer;
  S: string;
  RealFile: AnsiString;
  fl: TStringList;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName);
  if (Pos('<playlist version=', fl.Strings[1]) > 0) then
  begin
    for i := 2 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (Pos(BeginTag, S) > 0) and (Pos(EndTag, S) > 0) then
      begin
        RealFile := URLDecode(Copy(S, Len1 + 1, Length(S) - Len1 - Len2));
        if (Length(RealFile) > 3) and (Pos('.cue', RealFile) = 0) then
          AddStrings(AnsiToUtf8(RealFile), true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;

// ******************************************************************************

procedure TZMSPlayList.ReadASX(FileName: string);
const
  BeginTag = '<ref href = "';
  EndTag = '"/>';
  EndTag2 = '" />';
  Len1 = Length(BeginTag);
  Len2 = Length(EndTag);
  Len3 = Length(EndTag2);
var
  i: integer;
  S, RealFile: string;
  fl: TStringList;
  bp, ep: integer;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName);
  if (Pos('<asx version', LowerCase(fl.Strings[0])) > 0) then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (Pos(BeginTag, LowerCase(S)) > 0) and
        ((Pos(EndTag, S) > 0) or (Pos(EndTag2, S) > 0)) then
      begin
        bp := Pos(BeginTag, LowerCase(S));
        ep := Pos(EndTag, S);
        if ep = 0 then
          ep := Pos(EndTag2, S);

        RealFile := Copy(S, bp + Len1, ep - bp - Len1);
        if (Length(RealFile) > 3) and (Pos('.cue', RealFile) = 0) then
          AddStrings(RealFile, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadWPL(FileName: string);
const
  BeginTag = '<media src="';
  EndTag = '" tid="';
  EndTag2 = '"/>';
  Len1 = Length(BeginTag);
  Len2 = Length(EndTag);
  Len3 = Length(EndTag2);
var
  i, bp, ep: integer;
  S, RealFile: string;
  fl: TStringList;
  enc: TEncoding;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.UTF8);
  if (Pos('<?wpl version=', fl.Strings[0]) > 0) then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      if (Pos(BeginTag, S) > 0) and
        ((Pos(EndTag, S) > 0) or (Pos(EndTag2, S) > 0)) then
      begin
        bp := Pos(BeginTag, S);
        ep := Pos(EndTag, S);
        if ep = 0 then
          ep := Pos(EndTag2, S);

        RealFile := Copy(S, bp + Len1, ep - bp - Len1);
        if (Length(RealFile) > 3) and (Pos('.cue', RealFile) = 0) then
          AddStrings(RealFile, true);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadMPCPL(FileName: string);
const
  BeginTag = ',filename,';
  Len1 = Length(BeginTag);
var
  i: integer;
  S: string;
  Dis: boolean;
  fl: TStringList;
  RealFile: string;
  enc: TEncoding;
  bp: integer;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName, enc.UTF8);
  if (UpperCase(fl.Strings[0]) = 'MPCPLAYLIST') then
  begin
    for i := 1 to fl.Count - 1 do
    begin
      Application.ProcessMessages;
      S := fl.Strings[i];
      bp := Pos(BeginTag, LowerCase(S));
      if (bp > 0) then
      begin
        RealFile := Copy(S, bp + Len1, Length(S) - Len1);
        AddStrings(RealFile, true, Dis);
      end;
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.ReadLAP(FileName: string);
var
  i: integer;
  S: string;
  fl: TStringList;
begin
  fl := TStringList.Create;
  fl.LoadFromFile(FileName);
  for i := 0 to fl.Count - 1 do
  begin
    Application.ProcessMessages;
    S := fl.Strings[i];
    if (Pos('>N', UpperCase(S)) = 0) then
    begin
      if (Length(S) > 3) and (Pos('.cue', S) = 0) then
        AddStrings(S, true);
    end;
  end;
  fl.Clear;
  fl.Free;
end;
// ******************************************************************************

procedure TZMSPlayList.SaveM3U(FileName: string);
var
  sv: TStringList;
  i: integer;
begin
  if Items.Count > 0 then
  begin
    sv := TStringList.Create;
    sv.Add('#EXTM3U');
    for i := 0 to Items.Count - 1 do
    begin
      sv.Add('#EXTINF: ' + DecodeTime(fTime[i]) + ',' + fFileTag.Strings[i]);
      sv.Add(Items[i]);
    end;
    sv.SaveToFile(ChangeFileExt(FileName, '.m3u'));
    sv.Free;
  end
  else if FileExists(ChangeFileExt(FileName, '.m3u')) then
    DeleteFile(ChangeFileExt(FileName, '.m3u'));
end;
// ******************************************************************************

procedure TZMSPlayList.SaveM3U8(FileName: string);
var
  sv: TStringList;
  i: integer;
  enc: TEncoding;
begin
  if Items.Count > 0 then
  begin
    sv := TStringList.Create;
    sv.Add('#EXTM3U');
    for i := 0 to Items.Count - 1 do
    begin
      sv.Add('#EXTINF: ' + DecodeTime(fTime[i]) + ',' + fFileTag.Strings[i]);
      sv.Add(Items[i]);
    end;
    sv.SaveToFile(ChangeFileExt(FileName, '.m3u8'), enc.UTF8);
    sv.Free;
  end
  else if FileExists(ChangeFileExt(FileName, '.m3u8')) then
    DeleteFile(ChangeFileExt(FileName, '.m3u8'));
end;
// ******************************************************************************

procedure TZMSPlayList.SavePLZ(FileName: string);
const
  cmd = '[%d], %s, (%s)';
var
  sv: TStringList;
  i: integer;
  enc: TEncoding;
begin
  if Items.Count > 0 then
  begin
    sv := TStringList.Create;
    sv.Add('[ZuByMPlayer_List]');
    for i := 0 to Items.Count - 1 do
    begin
      sv.Add(Format(cmd, [integer(not Disabled(i)), fFileTag.Strings[i],
        DecodeTime(fTime[i])]));
      sv.Add(Items[i]);
    end;
    sv.SaveToFile(ChangeFileExt(FileName, '.plz'), enc.UTF8);
    sv.Free;
  end
  else if FileExists(ChangeFileExt(FileName, '.plz')) then
    DeleteFile(ChangeFileExt(FileName, '.plz'));
end;
// ******************************************************************************

procedure TZMSPlayList.SavePLS(FileName: string);
const
  cmdf = 'File%s=%s';
  cmdt = 'Title%s=%s';
  cmdl = 'Length%s=%s';
var
  sv: TStringList;
  i: integer;
begin
  if Items.Count > 0 then
  begin
    sv := TStringList.Create;
    sv.Add('[playlist]');
    for i := 0 to Items.Count - 1 do
    begin
      sv.Add(Format(cmdf, [IntToStr(i + 1), Items[i]]));
      sv.Add(Format(cmdt, [IntToStr(i + 1), fFileTag.Strings[i]]));
      sv.Add(Format(cmdl, [IntToStr(i + 1), DecodeTime(fTime[i])]));
    end;
    sv.Add('NumberOfEntries=' + IntToStr(Items.Count));
    sv.SaveToFile(ChangeFileExt(FileName, '.pls'));
    sv.Free;
  end
  else if FileExists(ChangeFileExt(FileName, '.pls')) then
    DeleteFile(ChangeFileExt(FileName, '.pls'));
end;
// ******************************************************************************

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSPlayList]);
end;

end.
