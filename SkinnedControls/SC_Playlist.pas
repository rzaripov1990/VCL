unit SC_Playlist;

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
  Windows, Messages, SysUtils, Classes, Controls, Forms, Graphics, ExtCtrls,
  IniFiles, ShellAPI, SHDocVw, ShlObj, Types, IOUtils,
  ComObj, ActiveX, List_Class, {tag_reader,} FolderDialog,
  FlacTagLibrary, ID3v1library, ID3v2Library, MP4TagLibrary, APEv2Library,
  OggVorbisAndOpusTagLibrary, WMATagLibrary;

type
  TInt = 1..100;
  TOnScroll = procedure(Sender: TObject; const ScrollCount, ScrollPos: Integer)
    of object;
  TOnEmptyXY = procedure(Sender: TObject; const X, Y, Index: Integer;
    const Empty: boolean) of object;
  TOnSave = procedure(Sender: TObject; out ChannelPos, Status: Integer)
    of object;
  TOnLoad = procedure(Sender: TObject; const ChannelPos, Status: Integer)
    of object;
  TOnTracking = procedure(Sender: TObject; Index: Integer;
    const DataItem: TPLItem) of object;
  TOnTimerProc = procedure(Sender: TObject; var DataItem: TPLItem;
    const Index: Integer) of object;

  TZMSAdvPlayList = class(TCustomControl)
  private
    { Private declarations }
    fList: TPLDynamicList; // глвный список
    fTimer: TTimer; // обработка/обновление пунктов

    fHistory: TStringList; // список истории
    fHistoryUse: boolean; // использовать историю
    fHistoryCnt: Integer; // величина списка истории
    fHistoryID: Integer; // текущий индекс
    fHistoryIDChange: boolean; // изменение ID

    fBuffer: TBitmap; // буффер
    fSwitchOn: TBitmap; // вкл
    fSwitchOff: TBitmap; // выкл

    fRepeatList: boolean; // флаг отвечающии за повторение листа
    fRandom: boolean; // флаг отвечающии за случайный порядок воспроизведения
    fAutoScan: boolean; // флаг отвечающии за автоматическое сканирование треков
    fAccessDrop: boolean; // флаг для Drag'n'Drop
    fAutoScroll: boolean; // флаг для авто прокрутки
    fDropInsertPos: boolean; // флаг для перекидывания в определенную позицию
    fIsItemMoving: boolean; // флаг для перемещения пунктов
    fDesigned: boolean; // отвечает за отрисовку в режиме дизайна
    fReadTags: boolean; // Чтение тегов при добавлении

    fDrawDuration: boolean; // отрисовка времени/радио
    fDrawNumeric: boolean; // отрисовка нумерации
    fDrawSwitches: boolean; // отрисовка свитчей

    fInTimeRect_Temp: boolean;
    // флаг определяет находится ли мышь в области время (MouseDown)
    fChanged: boolean;
    // флаг который запрещает обрабатывать пока не буедт "false"
    fMoving: boolean; // флаг разрешающии обмен пунктов местами
    fDoSplittCue: boolean; // флаг разрешающии разбитие cue

    fFilter: string; // фильтр для муз файлов
    fIgnoreFilter: string; // игнор фильтр для муз файлов
    fPLSFilter: string; // фильтр для плейлистов
    fInfoFormat: string; // шаблон для вывода строк в плейлисте

    fWheel: TInt; // при прокрутки увеличивается на шаг
    fWheelShift: TInt; // при прокрутки с зажатым Shift'ом увеличивается на шаг

    fItemHeight: Integer; // высота одного пункта
    fTimeWidth: Integer; // ширина времени/радио
    fSwitchWidth: Integer; // ширина свитчей
    fLastIndex: Integer; // последнии ID
    fLastRandomID: Integer; // последнее случайное число
    fTopIndex: Integer; // значение для прокрутки

    fSelectBackClr: TColor;
    fSelectTextClr: TColor;
    fNormalBackClr: TColor;
    fNormalTextClr: TColor;
    fTrackingBackClr: TColor;
    fTrackingTextClr: TColor;
    fErrorBackClr: TColor;
    fErrorTextClr: TColor;
    fFindBackClr: TColor;
    fFindTextClr: TColor;

    fOnTracking: TOnTracking;
    fOnUpdateProc: TOnTimerProc;
    fOnTimerProc: TOnTimerProc;
    fOnScroll: TOnScroll;
    fOnEmptyXY: TOnEmptyXY;
    fOnFocused: TNotifyEvent;
    fOnSave: TOnSave;
    fOnLoad: TOnLoad;

    procedure SetFilter(Value: string);
    procedure SetIgnoreFilter(Value: string);
    procedure SetHistoryCount(Value: Integer);
    procedure ResetItemData(var temp: TPLItem);
    procedure SetInfoFormat(Value: string);

    procedure SetSwitchOn(Value: TBitmap);
    procedure SetSwitchOff(Value: TBitmap);
    procedure SetSelectBackClr(Value: TColor);
    procedure SetSelectTextClr(Value: TColor);
    procedure SetNormalBacktClr(Value: TColor);
    procedure SetNormalTextClr(Value: TColor);
    procedure SetTrackingBackClr(Value: TColor);
    procedure SetTrackingTextClr(Value: TColor);
    procedure SetErrorBackClr(Value: TColor);
    procedure SetErrorTextClr(Value: TColor);
    procedure SetFindBackClr(Value: TColor);
    procedure SetFindTextClr(Value: TColor);

    procedure SetAutoScroll(Value: boolean);
    procedure SetAccessDrop(Value: boolean);
    procedure SetDropItemPos(Value: boolean);
    procedure SetItemMoving(Value: boolean);

    function GetCount: Integer;
    function GetItemTracking: Integer;
    procedure SetItemTracking(Value: Integer);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Index: Integer);

    procedure SetItemHeight(Value: Integer);
    procedure SetItemTop(Value: Integer);

    procedure SetDrawSwitches(Value: boolean);
    procedure SetDrawDuration(Value: boolean);
    procedure SetDrawNumeric(Value: boolean);
    procedure SetDesignMode(Value: boolean);

    function CutStr(Text: string; FixWidth: Integer): string;

    function GetVisibleItems: Integer;

    function IsSwitchRect(X, Y: Integer): boolean;
    function IsTimeRect(X, Y: Integer): boolean;
    function IsItemVisible(const Value: Integer): boolean;
    function IsVisibleItems: boolean;

    function FromRelativeToReal(const fRelative, fM3UPath: string;
      out RealName: string): boolean;

    procedure Scroll(var ScrollPos: Integer);
    procedure TimerProc(Sender: TObject);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Resize; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint)
      : boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint)
      : boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMDropFiles(var Message: TWMDropFiles); message WM_DROPFILES;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DblClick; override;

    property Items: TPLDynamicList read fList write fList;

    procedure UpdateScrollBar;
    function IsPlayList(X, Y: Integer): boolean;

    function IsNetString(Url: string): boolean;
    function InFilter(const fname: string): boolean;
    function ItemAtPos(X, Y: Integer): Integer;
    function FormatTime(const Sec: Integer; const IsURL: boolean): string;
    function BytesToStr(const Size: Int64): string;

    procedure Add(const FileName: string);
    procedure Insert(Pos: Integer; const FileName: string);
    procedure AddItem(Index: Integer; var Value: TPLItem);
    procedure AddAuto(const FileName: string; DropIndex: Integer = -1);
    procedure AddFromDir(StartDir: string; DropID: Integer;
      SubDirs: boolean = true);
    procedure SelectDirectory(var InitialRoot: string);

    procedure ReadFrom(Index: Integer; out Data: TPLItem);
    procedure WriteTo(Index: Integer; var Data: TPLItem);

    function ShowFileInDirectory(Path: string): boolean;
    procedure ShowSelectedFileInDirectory;
    procedure CurrentTracking;

    procedure LoadCue(const fname: string); overload;
    procedure LoadCue(const fname, fdata: string;
      const ID: Integer = -1); overload;
    procedure LoadM3U_8(const fname: string; loadUnicode: boolean = false);
    procedure LoadPLS(const fname: string);
    procedure LoadPLSEx(const fname: string);
    procedure SavePLS(const fname: string);
    procedure SavePLSEx(const fname: string);
    procedure SaveM3U_8(const fname: string; saveUnicode: boolean = false);

    function GetTotalInfo: string;
    procedure TrackForward(const off: Integer = -1;
      const jumpto: boolean = false);
    procedure TrackPrevious(const jumpto: boolean = false);

    procedure HistoryClear;
    procedure Clear;
    procedure Delete(Index: Integer);
    function DeleteSelected: boolean;
    procedure ClearFind;
    procedure DeleteErrors;
    procedure ClearError;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure SelectAll;
    procedure SelectedInvert;
    procedure UnSelectAll;

    procedure ItemsInvert;
    procedure ItemsMix;
    procedure ItemsOn;
    procedure ItemsOff;

    procedure SortBy(mode: TPLSortType);

    procedure Find(const S: string; mode: TPLFindType);
  published
    { Published declarations }
    property Align;
    property Font;
    property Hint;
    property Color;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Enabled;

    property SupportExt: string read fFilter write SetFilter;
    property IgnoreExt: string read fIgnoreFilter write SetIgnoreFilter;
    property ItemFormatStr: string read fInfoFormat write SetInfoFormat;

    property TopIndex: Integer read fTopIndex write SetItemTop default 0;
    property Count: Integer read GetCount;

    property SwitchOn: TBitmap read fSwitchOn write SetSwitchOn;
    property SwitchOff: TBitmap read fSwitchOff write SetSwitchOff;

    property Wheel: TInt read fWheel write fWheel default 1;
    property WheelShift: TInt read fWheelShift write fWheelShift default 5;

    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property ItemHeight: Integer read fItemHeight write SetItemHeight
      default 17;

    property SplitterCue: boolean read fDoSplittCue write fDoSplittCue
      default true;
    property AutoScanItems: boolean read fAutoScan write fAutoScan default true;
    property RepeatPL: boolean read fRepeatList write fRepeatList default true;
    property ActiveDropFiles: boolean read fAccessDrop write SetAccessDrop
      default true;
    property AutoScroll: boolean read fAutoScroll write SetAutoScroll
      default false;
    property ActiveDropFilesToPos: boolean read fDropInsertPos
      write SetDropItemPos default true;
    property ActiveMovingItems: boolean read fIsItemMoving write SetItemMoving
      default true;
    property TrackIndex: Integer read GetItemTracking write SetItemTracking
      default -1;
    property ReadTagsFromFiles: boolean read fReadTags write fReadTags
      default true;

    property RandomPL: boolean read fRandom write fRandom default false;
    property HistoryUse: boolean read fHistoryUse write fHistoryUse
      default true;
    property HistoryCount: Integer read fHistoryCnt write SetHistoryCount
      default 20;

    property _DesignMode: boolean read fDesigned write SetDesignMode
      default false;
    property DrawDuration: boolean read fDrawDuration write SetDrawDuration
      default true;
    property DrawNumeric: boolean read fDrawNumeric write SetDrawNumeric
      default true;
    property DrawSwitches: boolean read fDrawSwitches write SetDrawSwitches
      default true;

    property ClrSelectedBack: TColor read fSelectBackClr write SetSelectBackClr;
    property ClrSelectedText: TColor read fSelectTextClr write SetSelectTextClr;
    property ClrNormalBack: TColor read fNormalBackClr write SetNormalBacktClr;
    property ClrNormalText: TColor read fNormalTextClr write SetNormalTextClr;
    property ClrTrackingBack: TColor read fTrackingBackClr
      write SetTrackingBackClr;
    property ClrTrackingText: TColor read fTrackingTextClr
      write SetTrackingTextClr;
    property ClrErrorBack: TColor read fErrorBackClr write SetErrorBackClr;
    property ClrErrorText: TColor read fErrorTextClr write SetErrorTextClr;
    property ClrFindBack: TColor read fFindBackClr write SetFindBackClr;
    property ClrFindText: TColor read fFindTextClr write SetFindTextClr;

    property OnTrack: TOnTracking read fOnTracking write fOnTracking;
    property OnUpdateProc: TOnTimerProc read fOnUpdateProc write fOnUpdateProc;
    property OnTimerProc: TOnTimerProc read fOnTimerProc write fOnTimerProc;
    property OnScroll: TOnScroll read fOnScroll write fOnScroll;
    property OnEmptyXY: TOnEmptyXY read fOnEmptyXY write fOnEmptyXY;
    property OnFocused: TNotifyEvent read fOnFocused write fOnFocused;
    property OnSave: TOnSave read fOnSave write fOnSave;
    property OnLoad: TOnLoad read fOnLoad write fOnLoad;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyUp;
    property OnKeyDown;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
  end;

procedure Register;

function InternetGetConnectedState(lpdwFlags: LPDWORD; dwReserved: DWORD): BOOL;
stdcall; external 'wininet.dll' name 'InternetGetConnectedState';

implementation

uses
  StrUtils, WideStrUtils;

const
  vid = '0,1z';
  noe = 'NumberOfEntries';
  psn = 'Position';
  sts = 'Status';
  tpi = 'TopIndex';
  vrs = 'Version';
  pls = 'playlist';
  fil = 'File%d';
  lng = 'Length%d';
  art = 'Artist%d';
  tit = 'Title%d';
  bit = 'Bitrate%d';
  frq = 'Frequency%d';
  siz = 'FileSize%d';
  gnr = 'Genre%d';
  alb = 'Album%d';
  yer = 'Year%d';
  inf = 'TrackInfo%d';

  // ------------------------------ OTHER FUNCTION --------------------------------

procedure QBass_ReadTags(var info: TPLItem; out CueSheetData: string);
const
  ID3files = 'MP1, MP2, MP3, MP4';
  AACfiles = 'AAC';
  AC3files = 'AC3';
  TTAfiles = 'TTA';
  WMAfiles = 'WMA';
  APEfiles = 'APE';
  MP_files = 'MPC, MPP, MP+';
  OF_files = 'OFR, OFS';
  OGGfiles = 'OGG, OPUS';
  FLAfiles = 'FLAC, FLA';
  // MP4files = ' MP4, ALAC, M4A, AIFF';
  TRCfiles = 'MO3, IT, XM, S3M, MTM, MOD, UMX';
  SPXfiles = 'SPX';
  WVfiles = 'WV';
  WAVfiles = 'WAV';

var
  i: Integer;
begin
  if info.plType = WMAfiles then
  begin
    with TWMATag.Create do
    begin
      if LoadFromFile(info.plFile) = 0 then
      begin
        info.plArtist := ReadFrameByNameAsText(g_wszWMAuthor);
        info.plTitle := ReadFrameByNameAsText(g_wszWMTitle);
        info.plAlbum := ReadFrameByNameAsText(g_wszWMAlbumTitle);
        info.plYear := ReadFrameByNameAsText(g_wszWMYear);
        info.plGenre := ReadFrameByNameAsText(g_wszWMGenre);
      end;
      Free;
    end;
  end
  else if info.plType = APEfiles then
  begin
    with TAPEv2Tag.Create do
    begin
      if LoadFromFile(info.plFile) = 0 then
      begin
        for i := 0 to FrameCount - 1 do
        begin
          if lowercase(Frames[i].Name) = 'artist' then
            info.plArtist := Frames[i].GetAsText;
          if lowercase(Frames[i].Name) = 'title' then
            info.plTitle := Frames[i].GetAsText;
          if lowercase(Frames[i].Name) = 'album' then
            info.plAlbum := Frames[i].GetAsText;
          if lowercase(Frames[i].Name) = 'year' then
            info.plYear := Frames[i].GetAsText;
          if lowercase(Frames[i].Name) = 'genre' then
            info.plGenre := Frames[i].GetAsText;
        end;
      end;
      Free;
    end;
  end
  else if Pos(info.plType, FLAfiles) > 0 then
  begin
    with TFlacTag.Create do
    begin
      if LoadFromFile(info.plFile) = 0 then
      begin
        info.plArtist := ReadFrameByNameAsText('ARTIST');
        info.plTitle := ReadFrameByNameAsText('TITLE');
        info.plAlbum := ReadFrameByNameAsText('ALBUM');
        info.plYear := ReadFrameByNameAsText('DATE');
        info.plGenre := ReadFrameByNameAsText('GENRE');
      end;
      Free;
    end;
  end
  else if Pos(info.plType, OGGfiles) > 0 then
  begin
    with TOpusTag.Create do
    begin
      if LoadFromFile(info.plFile) = 0 then
      begin
        info.plArtist := ReadFrameByNameAsText('ARTIST');
        info.plTitle := ReadFrameByNameAsText('TITLE');
        info.plAlbum := ReadFrameByNameAsText('ALBUM');
        info.plYear := ReadFrameByNameAsText('DATE');
        info.plGenre := ReadFrameByNameAsText('GENRE');
      end;
      Free;
    end;
  end
  else
  begin
    with TID3v2Tag.Create do
    begin
      if LoadFromFile(info.plFile) = 0 then
      begin
        if Unsynchronised then
          RemoveUnsynchronisationOnAllFrames;

        info.plArtist := GetUnicodeText('TPE1');
        info.plTitle := GetUnicodeText('TIT2');
        info.plAlbum := GetUnicodeText('TALB');
        info.plYear := GetUnicodeText('TYER');
        info.plGenre := GetUnicodeText('TCON');
      end;
      Free;
    end;
  end;
end;

// ******************************************************************************

function Online: boolean;
var
  dwTypes: DWORD;
begin
  dwTypes := 7;
  Result := InternetGetConnectedState(@dwTypes, 0);
end;

// ******************************************************************************

function ProcessMessages: boolean;
// begin
// Application.HandleMessage;
const
  WM_QUIT = $0012;
var
  Msg: TMsg;
begin
  Result := false;
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.Message = WM_QUIT then
    begin
      Exit
    end
    else
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;
  Result := true;
end;
// ******************************************************************************

function Max(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;
// ******************************************************************************

function GetFileNameFromLink(LinkFileName: string): string;
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile;
  FileInfo: TWin32FINDDATA;
  WidePath: array[0..MAX_PATH] of Char;
  Buff: array[0..MAX_PATH] of Char;
begin
  CoInitialize(nil);
  Result := '';
  MyObject := CreateComObject(CLSID_ShellLink);
  MyPFile := (MyObject as IPersistFile);
  MySLink := (MyObject as IShellLink);
  StringToWideChar(LinkFileName, WidePath, SizeOf(WidePath));
  MyPFile.Load(WidePath, STGM_READ);
  MySLink.GetPath(Buff, MAX_PATH, FileInfo, SLGP_UNCPRIORITY);
  Result := Buff;
  CoUninitialize;
end;
// ******************************************************************************

function TimeFormatLong(const Value: Int64): string;
var
  D, H, M, S: Integer;
  dur: Integer;
const
  divD = 60 * 60 * 24;
  divH = 60 * 60;
begin
  try
    dur := Value;
    D := Trunc(dur / divD);
    H := Trunc((dur / divH) - (D * 24));
    M := Trunc((dur / 60) - (H * 60) - (D * 24 * 60));
    S := Trunc((dur - (M * 60) - (H * divH) - (D * 24 * divH)));

    Result := format('%2.2d:%2.2d:%2.2d:%2.2d', [D, H, M, S]);
  except
    Result := '00:00:00:00';
  end;
end;
// ----------------------------- OVERRIDE METHODS -------------------------------

constructor TZMSAdvPlayList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if (csOpaque in ControlStyle) then
    ControlStyle := ControlStyle - [csOpaque];
  TabStop := false;

  fBuffer := TBitmap.Create;
  fSwitchOn := TBitmap.Create;
  fSwitchOff := TBitmap.Create;

  fList := TPLDynamicList.Create;

  fHistory := TStringList.Create;
  fHistoryUse := true;
  fHistoryCnt := 20;
  fHistoryID := -1;
  fHistoryIDChange := true;

  fTimer := TTimer.Create(Self);
  fTimer.Interval := 10;
  fTimer.Enabled := false;
  fTimer.OnTimer := TimerProc;
  Caption := 'default.pls';

  Randomize;
  fRandom := false;
  fRepeatList := true;
  fAutoScan := true;
  fDoSplittCue := true;
  fAutoScroll := false;
  fAccessDrop := true;
  fDropInsertPos := true;
  fMoving := false;
  fIsItemMoving := true;
  fDrawDuration := true;
  fDrawNumeric := true;
  fDrawSwitches := true;
  fInTimeRect_Temp := false;
  fChanged := true;
  fDesigned := false;
  fReadTags := true;

  // fUpdatePos := -1;
  fItemHeight := 17;
  fTimeWidth := 30;
  fSwitchWidth := 16;
  fLastIndex := -1;
  fLastRandomID := -1;
  fTopIndex := 0;
  // SetItemIndex(-1); // потеря парента !!!!
  // SetItemTracking(-1);

  fWheel := 1;
  fWheelShift := 5;

  fFilter :=
    '*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif;*.wma;*.wv;*.tta;*.spx;*.mpc;*.mp+;' +
    '*.mpp*.oga;*.flac;*.ape;*.mac;*.m4a;*.ac3;*.mp4;*.aac';
  fIgnoreFilter := '&';
  fPLSFilter :=
    '*.m3u;*.m3u8;*.pls;*.asx;*.wpl;*.aap;*.xspf;*.kpl;*.zpl;*.plz;*.plc;*.mpcpl;*.lap;';

  fSelectBackClr := $00615EFC;
  fSelectTextClr := clWhite;
  fNormalBackClr := $001300AA;
  fNormalTextClr := $00615EFC;
  fTrackingBackClr := $001700D3;
  fTrackingTextClr := clWhite;
  fErrorBackClr := $001300AA;
  fErrorTextClr := $00818181;
  fFindBackClr := $001300AA;
  fFindTextClr := clYellow;

  Color := fNormalBackClr;
end;
// ******************************************************************************

destructor TZMSAdvPlayList.Destroy;
begin
  FreeAndNil(fList);
  FreeAndNil(fHistory);
  FreeAndNil(fTimer);
  FreeAndNil(fBuffer);
  FreeAndNil(fSwitchOn);
  FreeAndNil(fSwitchOff);
  inherited Destroy;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN;
    if fAccessDrop then
      ExStyle := ExStyle or WS_EX_CONTROLPARENT or WS_EX_ACCEPTFILES
    else
      ExStyle := ExStyle or WS_EX_CONTROLPARENT;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Resize;
var
  Size: TRect;
  Shift: TShiftState;
begin
  Size := BoundsRect;
  inherited;

  if Size.Bottom > BoundsRect.Bottom then
    DoMouseWheelDown(Shift, Point(0, 0))
  else
    DoMouseWheelUp(Shift, Point(0, 0));

  UpdateScrollBar;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Paint;

  function CorrectTime(Index: Integer; withDot: boolean): string;
  var
    Return: string;
    first, last: string;
    ch1: Integer;
  begin
    if withDot then
    begin
      first := IntToStr(Index + 1);
      last := IntToStr(fTopIndex + GetVisibleItems);
      ch1 := length(last) - length(first);
      case ch1 of
        0:
          Return := IntToStr(Index + 1);
        1:
          Return := '  ' + IntToStr(Index + 1);
      end;
    end
    else
      Return := '';
    if withDot then
      Result := Return + '. '
    else
      Result := Return;
  end;

  procedure DrawItem(ScrollIndex, Index: Integer);
  var
    Y: Integer;
    sClr: TColor;
    sRct: TRect;
    sOut: string;
  begin
    if (fList.Selected[ScrollIndex]) or (fList.Multi[ScrollIndex]) then
    begin
      fBuffer.Canvas.Brush.Color := fSelectBackClr;
      fBuffer.Canvas.Font.Color := fSelectTextClr;
    end
    else if (fList.Find[ScrollIndex]) then
    begin
      fBuffer.Canvas.Brush.Color := fFindBackClr;
      fBuffer.Canvas.Font.Color := fFindTextClr;
    end
    else if (fList.Tracking[ScrollIndex]) then
    begin
      fBuffer.Canvas.Brush.Color := fTrackingBackClr;
      fBuffer.Canvas.Font.Color := fTrackingTextClr;
    end
    else if (fList.Error[ScrollIndex]) then
    begin
      fBuffer.Canvas.Brush.Color := fErrorBackClr;
      fBuffer.Canvas.Font.Color := fErrorTextClr;
    end
    else
    begin
      fBuffer.Canvas.Brush.Color := fNormalBackClr;
      fBuffer.Canvas.Font.Color := fNormalTextClr;
    end;

    if fDrawSwitches then
    begin
      fSwitchWidth := fSwitchOn.Width; // !!!
      sClr := fBuffer.Canvas.Brush.Color;
      fBuffer.Canvas.Brush.Color := fNormalBackClr;
      fBuffer.Canvas.FillRect(Rect(0, (Index * fItemHeight), fSwitchWidth,
        ((Index + 1) * fItemHeight)));
      fBuffer.Canvas.Brush.Color := sClr;
      if (not fSwitchOn.Empty) or (not fSwitchOff.Empty) then
      begin
        Y := (fItemHeight - fSwitchOff.Height) div 2;

        case fList.Switch[ScrollIndex] of
          false:
            fBuffer.Canvas.Draw(2, (Index * fItemHeight) + Y, fSwitchOff);
          true:
            fBuffer.Canvas.Draw(2, (Index * fItemHeight) + Y, fSwitchOn);
        end;
      end;
    end
    else
      fSwitchWidth := 0;

    Y := (fItemHeight - fBuffer.Canvas.TextHeight('Hg')) div 2;

    if fDrawDuration then
    begin
      if fList.Cue[ScrollIndex] then
        sOut := FormatTime(fList.CueDuration[ScrollIndex],
          fList.Url[ScrollIndex])
      else
        sOut := FormatTime(fList.Duration[ScrollIndex], fList.Url[ScrollIndex]);
      fTimeWidth := fBuffer.Canvas.TextWidth(sOut);
      sRct := Rect((Width - fTimeWidth - 8), (Index * fItemHeight), Width,
        (Index + 1) * fItemHeight);
      fBuffer.Canvas.TextRect(sRct, (Width - fTimeWidth - 4),
        (Index * fItemHeight) + Y, sOut);
    end
    else
      fTimeWidth := -8;

    sRct := Rect(fSwitchWidth + 4, (Index * fItemHeight),
      (Width - fTimeWidth - 8), ((Index + 1) * fItemHeight));
    sOut := CutStr(CorrectTime(ScrollIndex, fDrawNumeric) +
      fList.BuildPaintString(ScrollIndex, fInfoFormat),
      (Width - fTimeWidth - (12 + fSwitchWidth)));
    fBuffer.Canvas.TextRect(sRct, fSwitchWidth + 4, (Index * fItemHeight)
      + Y, sOut);
  end;

var
  i: Integer;
  doClear: boolean;

  dClr: TColor;
  dY: Integer;
  dOut: string;
  dRct: TRect;
begin
  // inherited Paint;

  fBuffer.Width := Width;
  fBuffer.Height := Height;
  fBuffer.Canvas.Font := Font;

  if GetCount > 0 then
  begin
    if doClear then // обновление оболасти
    begin
      fBuffer.Canvas.Brush.Color := fNormalBackClr;
      fBuffer.Canvas.FillRect(ClientRect);
      doClear := false;
    end;

    for i := 0 to GetVisibleItems do
    begin
      if ((i + 1) + fTopIndex) <= fList.Count then
        DrawItem(i + fTopIndex, i);
    end;

    fBuffer.Canvas.Brush.Style := bsSolid;
    fBuffer.Canvas.Brush.Color := fNormalBackClr;
    if IsVisibleItems then
      fBuffer.Canvas.FillRect(Rect(fSwitchWidth + 2,
        (GetVisibleItems * fItemHeight), Width, Height))
    else // область которую не красят "видимые пункты"
      fBuffer.Canvas.FillRect(Rect(0, (GetVisibleItems * fItemHeight),
        Width, Height));

    fBuffer.Canvas.Brush.Color := fNormalBackClr;
    fBuffer.Canvas.Font.Color := fNormalTextClr;
    fBuffer.Canvas.TextOut(0, (Height - fItemHeight), GetTotalInfo);
  end
  else
  begin
    doClear := true;
    fBuffer.Canvas.Brush.Color := fNormalBackClr;
    fBuffer.Canvas.FillRect(ClientRect);

    if (csDesigning in ComponentState) or (fDesigned) then
      // отрисовка в режиме дизайна
    begin
      for i := 0 to 3 do // типа count
      begin

        fBuffer.Canvas.Font := Font;
        if i = 0 then
        begin
          fBuffer.Canvas.Brush.Color := fSelectBackClr;
          fBuffer.Canvas.Font.Color := fSelectTextClr;
        end
        else if i = 3 then
        begin
          fBuffer.Canvas.Brush.Color := fFindBackClr;
          fBuffer.Canvas.Font.Color := fFindTextClr;
        end
        else if (i = 1) then
        begin
          fBuffer.Canvas.Brush.Color := fTrackingBackClr;
          fBuffer.Canvas.Font.Color := fTrackingTextClr;
        end
        else if (1 = 2) then
        begin
          fBuffer.Canvas.Brush.Color := fErrorBackClr;
          fBuffer.Canvas.Font.Color := fErrorTextClr;
        end
        else
        begin
          fBuffer.Canvas.Brush.Color := fNormalBackClr;
          fBuffer.Canvas.Font.Color := fNormalTextClr;
        end;

        if fDrawSwitches then
        begin
          fSwitchWidth := fSwitchOn.Width; // !!!
          dClr := fBuffer.Canvas.Brush.Color;
          fBuffer.Canvas.Brush.Color := fNormalBackClr;
          fBuffer.Canvas.FillRect(Rect(0, (i * fItemHeight), fSwitchWidth,
            ((i + 1) * fItemHeight)));
          fBuffer.Canvas.Brush.Color := dClr;
          dY := (fItemHeight - fSwitchOff.Height) div 2;

          if i = 0 then
            fBuffer.Canvas.Draw(2, (i * fItemHeight) + dY, fSwitchOff)
          else
            fBuffer.Canvas.Draw(2, (i * fItemHeight) + dY, fSwitchOn);
        end
        else
          fSwitchWidth := 0;

        dY := (fItemHeight - fBuffer.Canvas.TextHeight('Hg')) div 2;

        if fDrawDuration then
        begin
          dOut := FormatTime(random(500) + 100, false);
          fTimeWidth := fBuffer.Canvas.TextWidth(dOut);
          dRct := Rect((Width - fTimeWidth - 8), (i * fItemHeight), Width,
            (i + 1) * fItemHeight);
          fBuffer.Canvas.TextRect(dRct, (Width - fTimeWidth - 4),
            (i * fItemHeight) + dY, dOut);
        end
        else
          fTimeWidth := -8;

        dRct := Rect(fSwitchWidth + 4, (i * fItemHeight),
          (Width - fTimeWidth - 8), ((i + 1) * fItemHeight));
        if fDrawNumeric then
          dOut := CutStr(IntToStr(i + 1) + '. Artist - Title',
            (Width - fTimeWidth - (12 + fSwitchWidth)))
        else
          dOut := CutStr('Artist - Title',
            (Width - fTimeWidth - (12 + fSwitchWidth)));
        fBuffer.Canvas.TextRect(dRct, fSwitchWidth + 4,
          (i * fItemHeight) + dY, dOut);

      end; // for i := 0 ...
    end; // режим дизайна ...
  end;

  Canvas.Draw(0, 0, fBuffer);
end;
// ------------------------------ MESSAGE EVENTS --------------------------------

procedure TZMSAdvPlayList.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTTAB + DLGC_WANTALLKEYS;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.WMDropFiles(var Message: TWMDropFiles);
var
  FileName: array[0..MAX_PATH] of Char;
  FileCnt, i: Integer;
  DropIndex: Integer;
  Pos: TPoint;
begin
  inherited;

  DropIndex := -1;
  if DragQueryPoint(Message.Drop, Pos) then
  begin
    if fDropInsertPos and IsPlayList(Pos.X, Pos.Y) then
      DropIndex := ItemAtPos(Pos.X, Pos.Y);
  end;

  BeginUpdate;
  FileCnt := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0);
  try
    for i := 0 to Pred(FileCnt) do
    begin
      // if (I mod 2 = 0) then
      // ProcessMessages;
      DragQueryFile(Message.Drop, i, FileName, SizeOf(FileName));
      AddAuto(FileName, DropIndex);
      if (i = 0) and (DirectoryExists(FileName)) then
        break;
    end;
  finally
    Message.Result := 0;
    DragFinish(Message.Drop);
    EndUpdate;
    UpdateScrollBar;
  end;
end;
// ******************************************************************************

function TZMSAdvPlayList.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): boolean;
begin
  Result := false;
  if fTopIndex + GetVisibleItems < GetCount then
  begin
    if (ssShift in Shift) then
      TopIndex := fTopIndex + fWheelShift
    else
      TopIndex := fTopIndex + fWheel;

    Scroll(fTopIndex);
    Result := true;
  end;
end;
// ******************************************************************************

function TZMSAdvPlayList.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): boolean;
begin
  Result := false;
  if fTopIndex > 0 then
  begin
    if (ssShift in Shift) then
      TopIndex := fTopIndex - fWheelShift
    else
      TopIndex := fTopIndex - fWheel;
    Scroll(fTopIndex);
    Result := true;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
  fStateIndex: Integer;
  f_ItemXY: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Button = mbLeft) and Enabled then
  begin
    if not (csDesigning in ComponentState) then
    begin
      SetFocus;
      if Assigned(fOnFocused) then
        fOnFocused(Self);
    end;

    f_ItemXY := ItemAtPos(X, Y);

    if IsSwitchRect(X, Y) then
      // если координаты совподают с областью включателей
    begin
      fStateIndex := (Y div fItemHeight) + fTopIndex;
      fList.Switch[fStateIndex] := not fList.Switch[fStateIndex];
      Paint;
    end
    else if IsTimeRect(X, Y) then
      // если координаты совподают с областью времени
    begin
      fInTimeRect_Temp := true;

      if IsVisibleItems then
        // если видимых ячеек больше чем кол-ва, то разрешаем прокрутку
      begin
        fLastIndex := f_ItemXY; // _ItemAtPos(X, Y);
        if fLastIndex < 0 then
          fLastIndex := 0
        else
        begin
          if fLastIndex >= GetCount then
            fLastIndex := GetCount - 1;
        end;

        if fInTimeRect_Temp then
        begin
          if (fTopIndex > fLastIndex) then
            fTopIndex := fLastIndex;
          if ((GetVisibleItems + Pred(fTopIndex)) < fLastIndex) then
            fTopIndex := Abs(GetVisibleItems - (fLastIndex + 1));
          Scroll(fTopIndex);
          // Paint;
        end;
        fMoving := true;
      end;
    end
    else if not (ssCtrl in Shift) and not (ssShift in Shift) then
      // при клике по артист - заголовок
    begin
      if not fInTimeRect_Temp then
        // если НЕ включатель, то с выделением ничего не делаем
      begin
        fList.ClearMultiSelect;
        SetItemIndex(f_ItemXY);

        if f_ItemXY <> -1 then
        begin
          fMoving := true;
          fList.Multi[GetItemIndex] := true;
        end
        else
          // если  = -1 то будем искать "играющий" трек
        begin
          if GetItemTracking >= 0 then
            SetItemTop(GetItemTracking);
        end;
      end;
    end
    else if (ssCtrl in Shift) and not (ssShift in Shift) then // зажат ctrl
    begin
      if f_ItemXY <> -1 then
      begin
        SetItemIndex(f_ItemXY);
        fList.Multi[GetItemIndex] := not fList.Multi[GetItemIndex];
      end;
    end
    else if not (ssCtrl in Shift) and (ssShift in Shift) then // зажат shift
    begin
      if f_ItemXY = -1 then
        Exit; // !!!

      if GetItemIndex = -1 then
        SetItemIndex(f_ItemXY);
      fList.ClearMultiSelect;
      fLastIndex := f_ItemXY;

      if fLastIndex <> -1 then
      begin
        if GetItemIndex <> fLastIndex then
        begin
          if fLastIndex > GetItemIndex then
            for i := GetItemIndex to fLastIndex do
              fList.Multi[i] := true;

          if fLastIndex < GetItemIndex then
            for i := GetItemIndex downto fLastIndex do
              fList.Multi[i] := true;
        end
        else
          fList.Multi[fLastIndex] := true;
      end;
    end;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);

  fLastIndex := (Y + fTopIndex * fItemHeight) div fItemHeight;
  if fLastIndex < 0 then
    fLastIndex := 0
  else
  begin
    if fLastIndex >= fList.Count then
      fLastIndex := fList.Count - 1;
  end;

  if ShowHint then
  begin
    Hint := fList.ItemInfo[fLastIndex];
    if ItemAtPos(X, Y) >= 0 then
      Application.ActivateHint(ClientToScreen(Point(X, Y)))
    else
      Application.CancelHint;
  end;

  if fInTimeRect_Temp then
  begin
    if (fTopIndex > fLastIndex) then
      fTopIndex := fLastIndex;
    if ((GetVisibleItems + Pred(fTopIndex)) < fLastIndex) then
      fTopIndex := Abs(GetVisibleItems - (fLastIndex + 1));
    Scroll(fTopIndex);
    Paint;
  end
  else if (fMoving and fIsItemMoving) and (not fInTimeRect_Temp) then
  begin
    if (GetItemIndex <> fLastIndex) and (fLastIndex >= 0) or
      (fLastIndex <= Pred(fList.Count)) then
    begin
      if (fTopIndex > fLastIndex) then
        fTopIndex := fLastIndex;
      if ((GetVisibleItems + Pred(fTopIndex)) < fLastIndex) then
        fTopIndex := Abs(GetVisibleItems - (fLastIndex + 1));
      Scroll(fTopIndex);

      fList.Exchange(GetItemIndex, fLastIndex);
      SetItemIndex(fLastIndex);
      fList.ClearMultiSelect;
      fList.Multi[fLastIndex] := true;
      Paint;
    end;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  f_ItemXY: Integer;
begin
  fInTimeRect_Temp := false;
  fMoving := false;
  fLastIndex := -1; // !!!

  if (Button = mbRight) then
  begin
    f_ItemXY := ItemAtPos(X, Y);
    if f_ItemXY >= 0 then
    begin
      SetItemIndex(f_ItemXY);
      if not fList.Multi[f_ItemXY] then
      begin
        fList.ClearMultiSelect;
        fList.Multi[GetItemIndex] := true;
      end;
    end;
    Paint;
    if Assigned(fOnEmptyXY) then
      fOnEmptyXY(Self, Mouse.CursorPos.X, Mouse.CursorPos.Y, f_ItemXY,
        (f_ItemXY = -1));
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.KeyDown(var Key: Word; Shift: TShiftState);

  procedure KeyScroll(TopID, ItemID: Integer; step_down: boolean = false);
  begin
    fList.ClearMultiSelect;
    if ItemID <= 0 then
      TopID := 0; // если не выделен элемент

    if ItemID > GetCount then
      ItemID := GetCount - 1
    else if ItemID < 0 then
      ItemID := 0;

    if (step_down) then
      SetItemTop(TopID) // page down/up
    else if (not IsItemVisible(ItemID)) then
      SetItemTop(TopID);
    // SetItemTop(TopID); // если эл не виден делаем прокрутку

    SetItemIndex(ItemID);
  end;

begin
  inherited;
  case Key of
    VK_HOME:
      KeyScroll(0, 0);
    VK_END:
      KeyScroll(GetCount - GetVisibleItems, GetCount - 1);
    VK_PRIOR:
      KeyScroll(fTopIndex - GetVisibleItems, fTopIndex - GetVisibleItems, true);
    VK_NEXT:
      KeyScroll(fTopIndex + GetVisibleItems, fTopIndex + GetVisibleItems +
        (GetVisibleItems - 1), true);
    VK_DOWN:
      KeyScroll(fTopIndex + 1, GetItemIndex + 1);
    VK_UP:
      KeyScroll(fTopIndex - 1, GetItemIndex - 1);
    VK_Delete:
      { if fList.SelectedAllItems then
        Clear
        else }
      DeleteSelected;
    VK_RETURN:
      SetItemTracking(GetItemIndex);
    VK_ADD:
      begin
        fLastIndex := GetItemIndex + 1;
        if fLastIndex <= 0 then
          fLastIndex := 0
        else if fLastIndex >= GetCount then
          fLastIndex := GetCount - 1;

        if (GetItemIndex <> fLastIndex) and (fLastIndex >= 0) or
          (fLastIndex <= Pred(GetCount)) then
        begin
          if (fTopIndex > fLastIndex) then
            fTopIndex := fLastIndex;
          if ((GetVisibleItems + Pred(fTopIndex)) < fLastIndex) then
            fTopIndex := Abs(GetVisibleItems - (fLastIndex + 1));
          Scroll(fTopIndex);

          fList.Exchange(GetItemIndex, fLastIndex);
          SetItemIndex(fLastIndex);
          fList.ClearMultiSelect;
          fList.Multi[fLastIndex] := true;
          Paint;
        end;
      end;
    VK_SUBTRACT:
      begin
        fLastIndex := GetItemIndex - 1;
        if fLastIndex <= 0 then
          fLastIndex := 0
        else if fLastIndex >= GetCount then
          fLastIndex := GetCount - 1;
        if (GetItemIndex <> fLastIndex) and (fLastIndex >= 0) or
          (fLastIndex <= Pred(fList.Count)) then
        begin
          if (fTopIndex > fLastIndex) then
            fTopIndex := fLastIndex;
          if ((GetVisibleItems + Pred(fTopIndex)) < fLastIndex) then
            fTopIndex := Abs(GetVisibleItems - (fLastIndex + 1));
          Scroll(fTopIndex);

          fList.Exchange(GetItemIndex, fLastIndex);
          SetItemIndex(fLastIndex);
          fList.ClearMultiSelect;
          fList.Multi[fLastIndex] := true;
          Paint;
        end;
      end;
  end;

  if (ssCtrl in Shift) and (Key = ord('A')) or (Key = ord('a')) then
    SelectAll;
  if (ssCtrl in Shift) and (Key = ord('I')) or (Key = ord('i')) then
    SelectedInvert;
end;
// ******************************************************************************

function BuildTagItem(var Item: TPLItem; const FileName: string;
  const IsCueFile: boolean = false): boolean;
begin
  Result := true;
  FillChar(Item, SizeOf(Item), 0);

  Item.plFile := FileName; // записываем имя файла ( обязательно! )
  // Item.plTitle := ChangeFileExt(ExtractFileName(FileName), '');
  Item.plType := UpperCase(Copy(ExtractFileExt(FileName), 2,
    length(ExtractFileExt(FileName))));
  Item.plCue := IsCueFile;
  Item.plSwitch := true;
  Item.plDuration := -1;
  Item.plError := (not FileExists(FileName)) and (not IsCueFile);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.DblClick;
begin
  inherited;
  if (GetItemIndex = -1) or (fInTimeRect_Temp) then
    Exit;
  SetItemTracking(GetItemIndex);
end;
// ------------------------------ DATA PROCCESING -------------------------------

procedure TZMSAdvPlayList.Add(const FileName: string);
begin
  Insert(-1, FileName);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Insert(Pos: Integer; const FileName: string);
var
  Item: TPLItem;
  CueSheetsData: string;
begin
  if Pos = -1 then
    Pos := GetCount
  else if Pos < -1 then
    Pos := 0
  else if Pos > GetCount then
    Pos := GetCount;

  if IsNetString(FileName) then
    fList.InsertItem(Pos, FileName)
  else if InFilter(FileName) then
  begin

    if fReadTags then
    begin
      if BuildTagItem(Item, FileName) then
      begin
        QBass_ReadTags(Item, CueSheetsData);

        if (Item.plCue) and (CueSheetsData <> '') then
          LoadCue(FileName, CueSheetsData, Pos)
        else
        begin

          with Item do
          begin
            plUpdated := (plSampleRate > 0) and (plBitrate > 0) and
              (plDuration > 0) and (plSize > 0) and (plArtist <> plTitle);
            { if empty }

            if ((plArtist = '') and (plTitle = '')) or
              ((plArtist <> '') and (plTitle = '')) then
              plTitle := ChangeFileExt(ExtractFileName(FileName), '');
          end;

          fList.InsertItem(Pos, Item);
        end;
      end;
    end
    else
      fList.InsertItem(Pos, FileName);
  end;

  UpdateScrollBar;
  // Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.AddItem(Index: Integer; var Value: TPLItem);
begin
  if Index = -1 then
    Index := GetCount
  else if Index < -1 then
    Index := 0
  else if Index > GetCount then
    Index := GetCount;

  fList.InsertItem(Index, Value);

  UpdateScrollBar;
  // Paint;
end;

// ******************************************************************************

procedure TZMSAdvPlayList.AddAuto(const FileName: string;
  DropIndex: Integer = -1);
var
  infile: string;
begin
  infile := FileName;
  if (Pos('.lnk', lowercase(ExtractFileExt(infile))) > 0) then
    infile := GetFileNameFromLink(FileName);

  if fDoSplittCue and Cue_IsCorrectFile(infile) then
    LoadCue(infile)
  else if Pos('.m3u8;', lowercase(infile + ';')) > 0 then
    LoadM3U_8(infile, true)
  else if Pos('.m3u;', lowercase(infile + ';')) > 0 then
    LoadM3U_8(infile)
  else if Pos('.pls;', lowercase(infile + ';')) > 0 then
    LoadPLSEx(infile)
  else if FileExists(infile) then
    Insert(DropIndex, infile)
  else if DirectoryExists(infile) then
    AddFromDir(infile, DropIndex);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ReadFrom(Index: Integer; out Data: TPLItem);
begin
  fList.ReadDataFrom(Index, Data);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.WriteTo(Index: Integer; var Data: TPLItem);
begin
  fList.WriteDataTo(Index, Data);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.CurrentTracking;
begin
  if GetItemTracking >= 0 then
    SetItemTop(GetItemTracking);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ShowSelectedFileInDirectory;
begin
  if fList.SelectedID >= 0 then
    ShowFileInDirectory(fList.FileName[fList.SelectedID]);
end;
// ******************************************************************************

function TZMSAdvPlayList.ShowFileInDirectory(Path: string): boolean;

  function ParceURLName(const Value: string): string;
  const
    scFilePath: array[0..7] of Char = ('f', 'i', 'l', 'e', ':', '/',
      '/', '/');
  begin
    if CompareMem(@scFilePath[0], @Value[1], 8) then
    begin
      Result := Copy(Value, 9, length(Value));
      Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
      Result := StringReplace(Result, '%20', ' ', [rfReplaceAll]);
      Result := IncludeTrailingBackslash(Result);
    end
    else
      Result := Value;
  end;

var
  iShellWindow: IShellWindows;
  iWB: IWebBrowserApp;
  spDisp: IDispatch;
  i: Integer;
  S, FilePath, FileName: string;
begin
  Result := FileExists(Path);
  if not Result then
    Exit;
  FilePath := UpperCase(ExtractFilePath(Path));
  FileName := ExtractFileName(Path);
  iShellWindow := CoShellWindows.Create;
  for i := 0 to iShellWindow.Count - 1 do
  begin
    spDisp := iShellWindow.Item(i);
    if spDisp = nil then
      Continue;
    spDisp.QueryInterface(IWebBrowserApp, iWB);
    if iWB <> nil then
    begin
      S := ParceURLName(iWB.LocationURL);
      if UpperCase(S) = FilePath then
      begin
        SendMessage(iWB.HWND, WM_SYSCOMMAND, SC_CLOSE, 0);
        break;
      end;
    end;
  end;
  ShellExecute(0, 'open', 'explorer.exe', pchar('/select, ' + FileName),
    pchar(FilePath), SW_SHOWNORMAL);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SelectDirectory(var InitialRoot: string);
var
  fFolderDialog: TFolderDialog;
  // диалог выбора папок
begin
  if not DirectoryExists(InitialRoot) then
    InitialRoot := 'C:\';
  fFolderDialog := TFolderDialog.Create(nil);
  try

    fFolderDialog.ExpandedFolder := InitialRoot;
    fFolderDialog.CheckOnInit := true;
    if fFolderDialog.Execute then
    begin
      BeginUpdate;
      InitialRoot := fFolderDialog.FolderName;
      if DirectoryExists(InitialRoot) then
        AddFromDir(InitialRoot, -1, fFolderDialog.Checked);
      EndUpdate;
    end;
  finally
    FreeAndNil(fFolderDialog);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.AddFromDir(StartDir: string; DropID: Integer;
  SubDirs: boolean = true);
var
  //  SearchRec: TSearchRec;
  FileArr: TStringDynArray;
  Str, Pred: string;
  I: Integer;
begin
  if StartDir[length(StartDir)] <> '\' then
    StartDir := StartDir + '\';

  FileArr := TDirectory.GetFiles(StartDir, '*.*', TSearchOption.soAllDirectories);

  for I := Low(FileArr) to High(FileArr) do
  begin
    Str := FileArr[i];
    if fDoSplittCue and Cue_IsCorrectFile(Str) then
    begin
      if (ChangeFileExt(Str, '') <> Pred) then
      begin
        Pred := ChangeFileExt(Str, '');
        LoadCue(Str);
      end;
    end
    else
      Insert(DropID, filearr[i]);
  end;

  {if FindFirst(StartDir + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory) <> faDirectory then
      begin
        ProcessMessages;
        // Application.HandleMessage;
        Str := StartDir + SearchRec.Name;
        if fDoSplittCue and Cue_IsCorrectFile(Str) then
        begin
          if (ChangeFileExt(Str, '') <> Pred) then
          begin
            Pred := ChangeFileExt(Str, '');
            LoadCue(Str);
          end;
        end
        else
          Insert(DropID, StartDir + SearchRec.Name);
      end
      else if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') and (SubDirs) then
        AddFromDir(StartDir + SearchRec.Name + '\', DropID);
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;}
end;
// ******************************************************************************

procedure TZMSAdvPlayList.TimerProc(Sender: TObject);
var
  Item: TPLItem;
  i: Integer;

  procedure Processing(Value: Integer);
  begin
    Item.plCue := fList.Cue[Value];
    if (not Item.plCue) and (not Item.plUpdated) then
      ResetItemData(Item);

    fList.ReadDataFrom(Value, Item);

    if Assigned(fOnTimerProc) then
      fOnTimerProc(Self, Item, Value);

    fList.WriteDataTo(Value, Item, Item.plCue);
  end;

begin
  if (fChanged) or (GetCount = 0) then
  begin
    fTimer.Enabled := false;
    Exit;
  end;

  i := fTopIndex;
  // for I := fTopIndex to fTopIndex + GetVisibleItems do
  while i < (fTopIndex + GetVisibleItems) do
  begin
    if (not fList.Updated[i]) then
    begin
      // if I mod 2 = 0 then
      Application.ProcessMessages;
      Processing(i);
    end;
    inc(i);
  end;
  fTimer.Enabled := false;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.HistoryClear;
begin
  fHistory.Clear;
  fHistoryID := -1;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Clear;
begin
  fList.BeginUpdate;
  fChanged := true;
  fTimer.Enabled := false;
  fList.Clear;
  SetItemIndex(-1);
  fLastIndex := -1;
  SetItemTracking(-1);
  fTopIndex := 0;
  Scroll(fTopIndex);
  fList.EndUpdate;
  HistoryClear;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.BeginUpdate;
begin
  fChanged := true;
  fList.BeginUpdate;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.EndUpdate;
begin
  fList.EndUpdate;
  fChanged := false;

  if fAutoScan then
    fTimer.Enabled := true
  else
    Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Delete(Index: Integer);
var
  Shift: TShiftState;
begin
  if GetItemIndex = Index then
  begin
    SetItemIndex(Index + 1);
    fList.Multi[GetItemIndex] := true;
  end;
  if GetItemTracking = Index then
    SetItemTracking(-1);
  fList.Delete(Index);

  if GetCount = 0 then
  begin
    fTopIndex := 0;
    SetItemIndex(-1);
    DoMouseWheelDown(Shift, Point(0, 0));
  end
  else
  begin
    if fTopIndex > GetCount - GetVisibleItems then
      fTopIndex := GetCount - GetVisibleItems;
    UpdateScrollBar;
  end;

  fLastIndex := -1;
  Paint;
end;
// ******************************************************************************

function TZMSAdvPlayList.DeleteSelected: boolean;
var
  i: Integer;
  Shift: TShiftState;
  tru: boolean;
  ID, c: Integer;
begin
  fChanged := true;
  Result := false;
  ID := -1;
  i := Pred(GetCount); // c

  while i >= 0 do
  begin
    // for I := c downto 0 do
    // begin
    if fList.Multi[i] then
    begin
      // if c mod 1000 = 0 then
      // ProcessMessages;
      if GetItemIndex = i then
      begin
        Result := true;
        ID := i;
        tru := not IsItemVisible(ID + 1);
      end;
      if GetItemTracking = i then
        SetItemTracking(-1);
      fList.Delete(i);
      if tru then
        SetItemIndex(ID - 2)
      else
        SetItemIndex(ID); // чтобы и сверху и снизу удалялось правильно
    end;
    dec(i);
  end;

  if (tru and Result) then
    SetItemIndex(GetCount - 1);
  fList.Multi[GetItemIndex] := true;

  if GetCount = 0 then
  begin
    fTopIndex := 0;
    SetItemIndex(-1);
    DoMouseWheelDown(Shift, Point(0, 0));
  end
  else
  begin
    if fTopIndex > GetCount - GetVisibleItems then
      fTopIndex := GetCount - GetVisibleItems;
    UpdateScrollBar;
  end;
  fLastIndex := -1;
  fChanged := false;
  Paint;
end;
// ******************************************************************************

function TZMSAdvPlayList.GetTotalInfo: string;
const
  infofmt = '  %s     %d      %s';
var
  Duration: Int64;
  fs: string;
begin
  if fChanged then
  begin
    Duration := 0;
    fs := '0 b';
  end
  else
  begin
    Duration := fList.TotalDuration;
    fs := BytesToStr(fList.TotalSize);
  end;

  Result := format(infofmt, [TimeFormatLong(Duration), GetCount, fs]);
end;

// ******************************************************************************

procedure TZMSAdvPlayList.TrackForward(const off: Integer = -1;
  const jumpto: boolean = false);

  function FindNextSwitch(const v: Integer): Integer;
  var
    p, c: Integer;
  begin
    Result := -1;
    c := 0;
    if not fList.SwitchCount then
      Exit;
    p := Max(v, off);
    while (not fList.Switch[p]) or (fList.Error[p]) do
    begin
      inc(p);
      inc(c);

      if fRepeatList then
      begin
        if p > GetCount then
          p := 0;
      end
      else
        break;

      if c > GetCount then
      begin
        break;
        p := -1;
        c := 0;
      end;
    end;

    if (fList.Switch[p]) and (not fList.Error[p]) then
      Result := p
    else
      Result := -1;
  end;

var
  Return, c: Integer;
begin
  if (GetCount >= 0) then
  begin
    if (GetItemTracking < 0) then // ItemTracking -1
    begin
      if GetItemIndex < 0 then // ItemIndex -1
      begin
        if fRandom then
        begin
          if fList.SwitchCount then
          begin
            repeat
              Return := random(Count);
            until fList.Switch[Return];
          end
          else
            Return := -1;
        end
        else
          Return := FindNextSwitch(0);
      end
      else
      begin
        if fRandom then
        begin
          if fList.SwitchCount then
          begin
            repeat
              Return := random(Count);
            until fList.Switch[Return];
          end
          else
            Return := -1;
        end
        else
          Return := FindNextSwitch(GetItemIndex);
      end;
    end
    else
    begin
      if fRandom then
      begin
        if fList.SwitchCount then
        begin
          repeat
            Return := random(Count);
          until fList.Switch[Return];
        end
        else
          Return := -1;
      end
      else
        Return := FindNextSwitch(GetItemTracking + 1);
    end;

    if Return > 0 then
    begin
      if fRandom then
      begin
        c := 0;
        if fList.SwitchCount then
        begin
          repeat
            inc(c);
            Return := random(Count);
            if (c >= fHistoryCnt) then
              break;
          until (fList.Switch[Return]) and
            (fHistory.IndexOf(IntToStr(Return) + '|' + fList.FileName
            [Return]) = -1);
        end
        else
          Return := -1;
      end;

      if Return = fLastRandomID then
      begin
        Randomize;
        if fList.SwitchCount then
        begin
          repeat
            Return := random(Count);
          until fList.Switch[Return];
        end
        else
          Return := -1;
      end;

      fLastRandomID := Return;

      if fList.Switch[Return] then
      begin
        SetItemTracking(Return);
        if (jumpto) and (not IsItemVisible(Return)) then
          SetItemTop(Return);
      end;
    end
    else if Return = 0 then
    begin
      fLastIndex := 0;

      if fList.Switch[Return] then
      begin
        SetItemTracking(Return);
        if (jumpto) and (not IsItemVisible(Return)) then
          SetItemTop(Return);
      end;
    end;

  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.TrackPrevious(const jumpto: boolean = false);

  function FindPredSwitch(const v: Integer): Integer;
  var
    p: Integer;
  begin
    Result := -1;
    if not fList.SwitchCount then
      Exit;
    p := v;
    while (not fList.Switch[p]) or (fList.Error[p]) do
    begin
      dec(p);
      if fRepeatList then
      begin
        if p < 0 then
          p := GetCount;
      end
      else
        break;
    end;
    if (fList.Switch[p]) and (not fList.Error[p]) then
      Result := p
    else
      Result := -1;
  end;

var
  Return, c, FindID: Integer;
  hStr: string;
begin
  if (GetCount >= 0) and (GetItemTracking >= 0) then
  begin
    if (fRandom) and (fHistoryUse) then
    begin
      Return := -1;
      if fHistory.Count >= 0 then
      begin
        dec(fHistoryID);
        if fHistoryID >= 0 then
        begin
          hStr := fHistory.Strings[fHistoryID];
          FindID := StrToInt(Copy(hStr, 1, Pos('|', hStr) - 1));
          System.Delete(hStr, 1, Pos('|', hStr));

          if fList.FileName[FindID] = hStr then
            Return := FindID;
        end;
      end;
    end
    else if fRandom and (not fHistoryUse) then
    begin
      Return := random(Count);
      if Return >= 0 then
      begin
        c := 0;
        while (fHistory.IndexOf(fList.FileName[Return]) <> -1) do
        begin
          inc(c);
          Return := random(Count);
          if c >= fHistoryCnt then
            break;
        end;
      end;
    end
    else
      Return := FindPredSwitch(GetItemTracking - 1);

    if Return >= 0 then
    begin
      fHistoryIDChange := false;
      SetItemTracking(Return);
      fHistoryIDChange := true;
      if (jumpto) and (not IsItemVisible(Return)) then
        SetItemTop(Return);
    end;

  end;
end;
// -------------------------------- LIST FUNCTIONS ------------------------------

function TZMSAdvPlayList.ItemAtPos(X, Y: Integer): Integer;
begin
  Result := -1;
  if IsPlayList(X, Y) then
    Result := (Y div fItemHeight) + fTopIndex;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Scroll(var ScrollPos: Integer);
var
  cnt: Integer;
begin
  if not Assigned(fOnScroll) then
    Exit;
  cnt := GetCount - GetVisibleItems;
  if (cnt <= 0) then
    fOnScroll(Self, 0, 0)
  else
    fOnScroll(Self, cnt, ScrollPos);

  fTimer.Enabled := fAutoScan;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.UpdateScrollBar;
begin
  if (not fChanged) then
    Scroll(fTopIndex);
end;
// ******************************************************************************

function TZMSAdvPlayList.GetVisibleItems: Integer;
var
  FVisibleIndex: Integer;
begin
  try
    FVisibleIndex := (Height div fItemHeight);
  except
    FVisibleIndex := 0;
  end;

  if FVisibleIndex = 0 then
    Result := 0
  else if FVisibleIndex > fList.Count then
    Result := fList.Count
  else
    Result := FVisibleIndex - 1;
end;
// ******************************************************************************

function TZMSAdvPlayList.IsNetString(Url: string): boolean;
begin
  Result := false;
  if (Copy(lowercase(Url), 1, 7) = 'http://') or
    (Copy(lowercase(Url), 1, 6) = 'ftp://') or
    (Copy(lowercase(Url), 1, 6) = 'mms://') then
    Result := true;
end;
// ******************************************************************************

function TZMSAdvPlayList.InFilter(const fname: string): boolean;
var
  ext: string;
begin
  Result := false;
  ext := lowercase(ExtractFileExt(fname)) + ';';
  if ext = ';' then
    Exit;
  Result := (Pos(ext, fFilter) > 0) and
    (Pos(Copy(ext, 2, length(ext) - 2), fIgnoreFilter) = 0);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SelectAll;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Multi[i] := true;

  SetItemIndex(-1);
  fLastIndex := -1;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SelectedInvert;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Multi[i] := not fList.Multi[i];

  SetItemIndex(-1);
  fLastIndex := -1;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.UnSelectAll;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Multi[i] := false;

  SetItemIndex(-1);
  fLastIndex := -1;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ItemsInvert;
var
  i, J, c: Integer;
begin
  J := Pred(fList.Count);
  c := fList.Count div 2 - 1;
  try
    for i := 0 to c do
      fList.Exchange(i, J - i, true);
  finally
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ItemsMix;
var
  i, J, K, c: Integer;
begin
  try
    c := fList.Count div 2;
    Randomize;
    for i := 0 to c do
    begin
      J := random(fList.Count);
      K := random(fList.Count);
      fList.Exchange(J, K, true);
    end;
  finally
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SortBy(mode: TPLSortType);
begin
  fList.Sort(mode);
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.Find(const S: string; mode: TPLFindType);
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Find[i] := fList.QuickFind(lowercase(S), i, mode);
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ClearFind;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Find[i] := false;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ItemsOn;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
  begin
    if fList.Multi[i] then
      fList.Switch[i] := true;
  end;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ItemsOff;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
  begin
    if fList.Multi[i] then
      fList.Switch[i] := false;
  end;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.DeleteErrors;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := c downto 0 do
  begin
    if fList.Error[i] then
      Delete(i);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ClearError;
var
  i, c: Integer;
begin
  c := Pred(fList.Count);
  for i := 0 to c do
    fList.Error[i] := false;
  Paint;
end;
// ******************************************************************************

function TZMSAdvPlayList.GetCount: Integer;
begin
  Result := fList.Count;
end;
// ------------------------------ COMPONENT EVENTS ------------------------------

function TZMSAdvPlayList.IsPlayList(X, Y: Integer): boolean;
begin
  if fDrawSwitches then
    Result := PtInRect(Rect(fSwitchWidth, 0, Width,
      GetVisibleItems * fItemHeight), Point(X, Y))
  else
    Result := PtInRect(Rect(0, 0, Width, GetVisibleItems * fItemHeight),
      Point(X, Y));
end;
// ******************************************************************************

function TZMSAdvPlayList.IsTimeRect(X, Y: Integer): boolean;
var
  R: TRect;
begin
  R := Rect(Width - fTimeWidth, (Y div fItemHeight) * fItemHeight, Width,
    ((Y div fItemHeight) + 1) * fItemHeight);
  Result := PtInRect(R, Point(X, Y));
end;
// ******************************************************************************

function TZMSAdvPlayList.IsVisibleItems: boolean;
begin
  Result := (GetVisibleItems > GetCount);
end;
// ******************************************************************************

function TZMSAdvPlayList.IsItemVisible(const Value: Integer): boolean;
begin
  Result := false;
  if (Value >= fTopIndex) and (Value < fTopIndex + GetVisibleItems) then
    Result := true;
end;
// ******************************************************************************

function TZMSAdvPlayList.IsSwitchRect(X, Y: Integer): boolean;
var
  R: TRect;
begin
  R := Rect(0, (Y div fItemHeight) * fItemHeight, fSwitchWidth,
    ((Y div fItemHeight) + 1) * fItemHeight);
  Result := PtInRect(R, Point(X, Y));
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetItemTop(Value: Integer);
begin
  if GetCount > 0 then
  begin
    if Value <= 0 then
      Value := 0
    else if Value > (GetCount - GetVisibleItems) then
      Value := GetCount - GetVisibleItems;
    if fTopIndex <> Value then
    begin
      fTopIndex := Value;
      Scroll(fTopIndex);
      Paint;
    end;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.ResetItemData(var temp: TPLItem);
begin
  FillChar(temp, SizeOf(TPLItem), 0);
  temp.plDuration := 0;
  temp.plSwitch := true;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetItemHeight(Value: Integer);
begin
  if (fItemHeight <> Value) and (Value >= 17) then
  begin
    fItemHeight := Value;
    UpdateScrollBar;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetAutoScroll(Value: boolean);
begin
  if fAutoScroll <> Value then
  begin
    fAutoScroll := Value;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetAccessDrop(Value: boolean);
begin
  if fAccessDrop <> Value then
  begin
    fAccessDrop := Value;
    DragAcceptFiles(Handle, fAccessDrop);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetDropItemPos(Value: boolean);
begin
  if fDropInsertPos <> Value then
    fDropInsertPos := Value;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetItemMoving(Value: boolean);
begin
  if fIsItemMoving <> Value then
    fIsItemMoving := Value;
end;
// ******************************************************************************

function TZMSAdvPlayList.GetItemTracking: Integer;
begin
  Result := fList.TrackingID;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetItemTracking(Value: Integer);

  procedure HistoryMaker;
  var
    indof: Integer;
  begin
    if (fRandom) and (fHistoryUse) then
    begin
      indof := fHistory.IndexOf(IntToStr(Value) + '|' + fList.FileName[Value]);
      if indof >= 0 then
        fHistory.Exchange(indof, fHistory.Count - 1)
          // перемещаем в конец, если пункт уже найден
      else // если нет, добавляем в список
      begin
        if fHistory.Count >= fHistoryCnt then
          fHistory.Delete(0); // удаляем 1-ый, чтобы втолкнуть новый
        fHistory.Add(IntToStr(Value) + '|' + fList.FileName[Value]);

        if fHistoryIDChange then
          fHistoryID := fHistory.Count - 1;
      end;
    end;
  end;

var
  Item: TPLItem;
begin
  if (GetCount = 0) or (Value = -1) then
    fList.ClearTracking
  else if (Value >= 0) and (Value < GetCount) then
  begin
    if Assigned(fOnTracking) then
    begin
      fList.Updated[Value] := false;
      ResetItemData(Item);

      fList.ReadDataFrom(Value, Item);
      Item.plError := false;
      Item.plSwitch := true;

      if Assigned(fOnUpdateProc) then
        fOnUpdateProc(Self, Item, Value);

      fList.WriteDataTo(Value, Item);
      Item.plUpdated := true;

      if (not Item.plError) then
      begin
        fOnTracking(Self, Value, Item);
        fList.ClearTracking;
        fList.Tracking[Value] := true;
        HistoryMaker;
      end
      else
      begin
        if (GetCount > 0) and (Value > 0) then
          TrackForward(Value);
      end;
    end;
  end;
  Paint;
end;
// ******************************************************************************

function TZMSAdvPlayList.GetItemIndex: Integer;
begin
  Result := fList.SelectedID;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetItemIndex(Index: Integer);
begin
  if GetCount > 0 then
  begin
    if (Index <> fList.SelectedID) then
      fList.SelectedID := Index;
  end
  else
    fList.SelectedID := -1;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetFilter(Value: string);
begin
  if fFilter <> Value then
    fFilter := Value;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetIgnoreFilter(Value: string);
begin
  if fIgnoreFilter <> Value then
    fIgnoreFilter := Value;
  if fIgnoreFilter = '' then
    fIgnoreFilter := '&';
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetHistoryCount(Value: Integer);
begin
  if fHistoryCnt <> Value then
  begin
    fHistoryCnt := Value;
    if fHistory.Count > fHistoryCnt then
    begin
      repeat
        fHistory.Delete(fHistory.Count);
      until (fHistory.Count = fHistoryCnt);
    end;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetInfoFormat(Value: string);
begin
  if fInfoFormat <> Value then
  begin
    fInfoFormat := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetDrawDuration(Value: boolean);
begin
  if fDrawDuration <> Value then
  begin
    fDrawDuration := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetDrawSwitches(Value: boolean);
begin
  if fDrawSwitches <> Value then
  begin
    fDrawSwitches := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetDrawNumeric(Value: boolean);
begin
  if fDrawNumeric <> Value then
  begin
    fDrawNumeric := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetDesignMode(Value: boolean);
begin
  if fDesigned <> Value then
  begin
    fDesigned := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetSwitchOn(Value: TBitmap);
begin
  fSwitchOn.Assign(Value);
  if Assigned(Value) then
    fSwitchWidth := fSwitchOn.Width
  else
    fSwitchWidth := 0;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetSwitchOff(Value: TBitmap);
begin
  fSwitchOff.Assign(Value);
  if Assigned(Value) then
    fSwitchWidth := fSwitchOff.Width
  else
    fSwitchWidth := 0;
  Paint;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetSelectBackClr(Value: TColor);
begin
  if fSelectBackClr <> Value then
  begin
    fSelectBackClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetSelectTextClr(Value: TColor);
begin
  if fSelectTextClr <> Value then
  begin
    fSelectTextClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetNormalBacktClr(Value: TColor);
begin
  if fNormalBackClr <> Value then
  begin
    fNormalBackClr := Value;
    Color := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetNormalTextClr(Value: TColor);
begin
  if fNormalTextClr <> Value then
  begin
    fNormalTextClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetTrackingBackClr(Value: TColor);
begin
  if fTrackingBackClr <> Value then
  begin
    fTrackingBackClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetTrackingTextClr(Value: TColor);
begin
  if fTrackingTextClr <> Value then
  begin
    fTrackingTextClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetErrorBackClr(Value: TColor);
begin
  if fErrorBackClr <> Value then
  begin
    fErrorBackClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetErrorTextClr(Value: TColor);
begin
  if fErrorTextClr <> Value then
  begin
    fErrorTextClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetFindBackClr(Value: TColor);
begin
  if fFindBackClr <> Value then
  begin
    fFindBackClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SetFindTextClr(Value: TColor);
begin
  if fFindTextClr <> Value then
  begin
    fFindTextClr := Value;
    Paint;
  end;
end;
// ******************************************************************************

function TZMSAdvPlayList.FormatTime(const Sec: Integer;
  const IsURL: boolean): string;
(* ******************************************
  * RESULT: " 99:99" | "999:99" * | " Radio" *
  ****************************************** *)
const
  time = ' 00:00';
  radio = ' Radio';
var
  H, M, S: Integer;
  Return: string;
begin
  if IsURL then
    Return := radio
  else if Sec <= 0 then
    Return := time
  else
  begin
    H := Sec div 3600;
    S := Sec mod 3600;
    M := S div 60;
    M := M + (H * 60);
    S := (S mod 60);
    if M > 99 then
      Return := format('%3d:%2.2d', [M, S])
    else
      Return := format('%2.2d:%2.2d', [M, S]);
  end;

  if (length(Return) = 5) then
    Result := ' ' + Return
  else
    Result := Return;
end;
// ******************************************************************************

function TZMSAdvPlayList.BytesToStr(const Size: Int64): string;
const
  i64TB = 1099511627776; // 1024 * 1024 * 1024 * 1024;
  i64GB = 1073741824; // 1024 * 1024 * 1024;
  i64MB = 1048576; // 1024 * 1024;
  i64KB = 1024;
begin
  if Size div i64TB > 0 then
    Result := format('%.2f Tb', [Size / i64TB])
  else if Size div i64GB > 0 then
    Result := format('%.2f Gb', [Size / i64GB])
  else if Size div i64MB > 0 then
    Result := format('%.2f Mb', [Size / i64MB])
  else if Size div i64KB > 0 then
    Result := format('%.2f Kb', [Size / i64KB])
  else
    Result := IntToStr(Size) + ' b';
end;
// ******************************************************************************

function TZMSAdvPlayList.CutStr(Text: string; FixWidth: Integer): string;
var
  ReturnText: string;
begin
  Result := '';
  if fBuffer.Canvas.TextWidth(Text) > FixWidth then
  begin
    ReturnText := Text;
    while (fBuffer.Canvas.TextWidth(ReturnText + '...') > FixWidth) do
    begin
      if length(ReturnText) > 1 then
        System.Delete(ReturnText, length(ReturnText), 1)
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

function TZMSAdvPlayList.FromRelativeToReal(const fRelative, fM3UPath: string;
  out RealName: string): boolean;
begin
  Result := false;
  RealName := '';
  if (fRelative = '') or (fM3UPath = '') then
    Exit;
  if FileExists(fRelative) or IsNetString(fRelative) then
  begin
    RealName := fRelative;
    Result := true;
    Exit;
  end;
  if not IsNetString(fRelative) then
  begin
    RealName := ExtractFilePath(fM3UPath);
    if RealName[length(RealName)] <> '\' then
      RealName := RealName + '\';
    RealName := RealName + fRelative;
    Result := FileExists(RealName);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.LoadM3U_8(const fname: string;
  loadUnicode: boolean = false);
const
  aHeader = '#EXTM3U';
  aTag = '#EXTINF:';
var
  i, c, D: Integer;
  ansis: ansichar;
  S, ext, A: string;
  fl: TStringList;
  Item: TPLItem;
  enc: TEncoding;
  added: boolean;
begin
  fl := TStringList.Create;

  if loadUnicode then
    fl.LoadFromFile(fname, enc.UTF8)
  else
    fl.LoadFromFile(fname);

  if fl.Count <= 0 then
  begin
    FreeAndNil(fl);
    Exit;
  end;

  try
    S := fl.Strings[0];
    if (UpperCase(S) = aHeader) or (FileExists(S)) or (IsNetString(S)) then
    begin
      BeginUpdate;
      c := fl.Count;
      D := 0;
      if S = aHeader then
        D := 1;

      for i := D to c - 1 do
      begin
        // if (I mod 30 = 0) then
        // ProcessMessages;

        if added then
        begin
          added := false;
          Continue;
        end;

        S := fl.Strings[i];
        ResetItemData(Item);

        if IsNetString(S) then
        begin
          added := false;

          Item.plTitle := S;
          Item.plFile := S;
          Item.plUpdated := true;
          Item.plUrl := true;

          AddItem(-1, Item);
        end
        else if (Pos(aTag, UpperCase(S)) > 0) then
        begin
          Item.plDuration := StrToInt(ParseStr(S, aTag, ','));
          A := ParseStr(S, ',', ' - ');
          if A = '' then
            A := ParseStr(S, ',', '');
          Item.plArtist := A;
          Item.plTitle := ParseStr(S, ' - ', '');

          FromRelativeToReal(fl.Strings[i + 1], fname, S);
          if InFilter(S) or IsNetString(S) then
          begin
            if Item.plTitle = '' then
              Item.plTitle := ChangeFileExt(ExtractFileName(S), '');
            Item.plFile := S;
            if not IsNetString(S) then
            begin
              ext := UpperCase(ExtractFileExt(S));
              Item.plType := Copy(ext, 2, length(ext));
              Item.plSize := GetSizeFile(S);
              if not FileExists(S) then
              begin
                Item.plError := true;
                Item.plSwitch := false;
              end;
            end
            else
              Item.plUrl := true;
            Item.plUpdated := true;

            AddItem(-1, Item);
            added := true;
          end;
        end
        else if FileExists(S) then
        begin
          Item.plTitle := ChangeFileExt(ExtractFileName(S), '');
          FromRelativeToReal(fl.Strings[i], fname, S);
          if InFilter(S) then
          begin
            Item.plFile := S;
            ext := UpperCase(ExtractFileExt(S));
            Item.plType := Copy(ext, 2, length(ext));
            Item.plSize := GetSizeFile(S);
            Item.plUpdated := false;

            AddItem(-1, Item);
          end;
        end;
        // Inc(I);
      end; // for..to..do
    end;
  finally
    EndUpdate;
    fl.Clear;
    FreeAndNil(fl);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.LoadPLSEx(const fname: string);

  function s2b(const S: string): boolean;
  begin
    Result := S = '1';
  end;

var
  ini: TMemIniFile;
  Item: TPLItem;
  cnt, i, S, p: Integer;
  Str: string;
begin
  ini := TMemIniFile.Create(fname);
  try
    if ini.ReadString(pls, vrs, '0') <> vid then
    begin
      LoadPLS(fname);
      FreeAndNil(ini);
      Exit;
    end;

    cnt := ini.ReadInteger(pls, noe, 0);
    if cnt > 0 then
    begin
      BeginUpdate;
      i := 1;

      while i <= cnt do
      begin
        Str := ini.ReadString(pls, format(inf, [i]), '');
        if (Str = '') then
          Continue;

        ResetItemData(Item);
        Item.plFile := ini.ReadString(pls, format(fil, [i]), '');
        Item.plType := UpperCase(Copy(ExtractFileExt(Item.plFile), 2,
          length(ExtractFileExt(Item.plFile))));
        Item.plTitle := ini.ReadString(pls, format(tit, [i]), '');
        Item.plArtist := ini.ReadString(pls, format(art, [i]), '');
        Item.plGenre := ini.ReadString(pls, format(gnr, [i]), '');
        Item.plAlbum := ini.ReadString(pls, format(alb, [i]), '');
        Item.plYear := ini.ReadString(pls, format(yer, [i]), '');

        Item.plDuration := StrToInt(ini.ReadString(pls, format(lng, [i]), ''));
        Item.plSize := StrToInt(ini.ReadString(pls, format(siz, [i]), ''));
        Item.plBitrate := StrToInt(ini.ReadString(pls, format(bit, [i]), ''));
        Item.plSampleRate :=
          StrToInt(ini.ReadString(pls, format(frq, [i]), ''));

        fList.StringAsItem(Str, Item);

        if (not FileExists(Item.plFile)) and (not Item.plUrl) then
        begin
          Item.plError := true;
          Item.plSwitch := false;
        end;

        AddItem(-1, Item);

        if Item.plTracking then
        begin
          if Assigned(fOnLoad) then
          begin
            p := ini.ReadInteger(pls, psn, 0);
            S := ini.ReadInteger(pls, sts, 0);
            if (p <> 0) and (S <> 0) then
              fOnLoad(Self, p, S);
          end;
        end;

        inc(i);
      end;

      SetItemTop(ini.ReadInteger(pls, tpi, 0));
    end;
  finally
    EndUpdate;
    FreeAndNil(ini);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.LoadPLS(const fname: string);
var
  S, A, ext: string;
  cnt, i: Integer;
  Item: TPLItem;
  ini: TMemIniFile;
begin

  ini := TMemIniFile.Create(fname);
  try
    cnt := ini.ReadInteger(pls, noe, 0);
    if cnt > 0 then
    begin
      BeginUpdate;

      i := 1;
      while i <= cnt do
      begin
        ResetItemData(Item);
        S := ini.ReadString(pls, format(fil, [i]), '');
        if InFilter(S) or IsNetString(S) then
        begin
          if FromRelativeToReal(S, fname, A) then
            Item.plFile := A
          else
            Item.plFile := S;
          S := Item.plFile;
          if not IsNetString(S) then
          begin
            Item.plTitle := ini.ReadString(pls, format(tit, [i]), '');
            Item.plDuration := ini.ReadInteger(pls, format(lng, [i]), -1);

            if not FileExists(S) then
            begin
              Item.plError := true;
              Item.plSwitch := false;
            end;

            ext := UpperCase(ExtractFileExt(S));
            Item.plType := Copy(ext, 2, length(ext));
            Item.plSize := GetSizeFile(S);
          end
          else
          begin
            Item.plTitle := S;
            Item.plUrl := true;
          end;
          Item.plUpdated := (Item.plDuration <> -1);
          AddItem(-1, Item);
        end;
        inc(i);
      end;
    end;
  finally
    EndUpdate;
    FreeAndNil(ini);
  end;
end;
// ******************************************************************************

procedure TZMSAdvPlayList.LoadCue(const fname, fdata: string;
  const ID: Integer = -1);
var
  Item: TPLItem;
  A, t, g, c, Y, ext: string;
  i, D: Integer;
  addID: Integer;
begin
  cue_data := fdata;
  ext := ExtractFileExt(fname);
  addID := ID;
  if Cue_GetInfo(fname, cue_data, cue_audiofile, cue_artist, cue_title, g, c, Y,
    cue_count, false) then
  begin
    BeginUpdate;
    for i := 1 to cue_count do
    begin
      if Cue_GetIDInfo(fname, cue_data, i, A, t, D, false) then
      begin
        ResetItemData(Item);
        Item.plCue := true;
        Item.plFile := cue_audiofile;
        Item.plType := Copy(ext, 2, length(ext));
        Item.plTitle := Cue_IFV(t, cue_title);
        Item.plArtist := Cue_IFV(A, cue_artist);
        Item.plComment := c;
        Item.plYear := Y;
        Item.plGenre := g;
        Item.plDuration := -1;
        Item.plSize := 0;
        Item.plCueInfo.Count := cue_count;
        Item.plCueInfo.ID := i;
        Item.plCueInfo.Now := D;
        Item.plCueInfo.Next := Cue_GetIDDuration(cue_data, i + 1);
        AddItem(addID, Item);
        inc(addID);
      end; // Cue_GetIDInfo
    end; // for i:=1 to cue_count do
    EndUpdate;
  end; // Cue_GetInfo
end;
// ******************************************************************************

procedure TZMSAdvPlayList.LoadCue(const fname: string);
var
  i, D: Integer;
  Item: TPLItem;
  ext, cuefile: string;
  A, t, g, c, Y: string;
begin
  if Pos('.cue;', fname + ';') > 0 then
  begin
    cuefile := fname;
    Cue_GetAudioFile(cuefile, cue_data, cue_audiofile);
  end
  else
  begin
    cuefile := Cue_GetCueFile(fname);
    cue_audiofile := fname;
  end;
  if not InFilter(cue_audiofile) then
    Exit;

  if not Cue_GetInfo(cuefile, cue_data, cue_audiofile, cue_artist, cue_title, g,
    c, Y, cue_count) then
    Exit;
  if cue_count = 0 then
    Exit;

  try
    BeginUpdate;
    ext := UpperCase(ExtractFileExt(cue_audiofile));

    for i := 1 to cue_count do
    begin
      if Cue_GetIDInfo(cuefile, cue_data, i, A, t, D, false) then
      begin
        ResetItemData(Item);
        Item.plCue := true;
        Item.plFile := cue_audiofile;
        Item.plType := Copy(ext, 2, length(ext));
        Item.plTitle := Cue_IFV(t, cue_title);
        Item.plArtist := Cue_IFV(A, cue_artist);
        ;
        Item.plComment := c;
        Item.plYear := Y;
        Item.plGenre := g;
        Item.plDuration := -1;
        Item.plSize := 0;
        Item.plCueInfo.Count := cue_count;
        Item.plCueInfo.ID := i;
        Item.plCueInfo.Now := D;
        Item.plCueInfo.Next := Cue_GetIDDuration(cue_data, i + 1);
        AddItem(-1, Item);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

// ******************************************************************************

procedure TZMSAdvPlayList.SavePLSEx(const fname: string);

const
  del = '=';
  noe = 'NumberOfEntries';
  psn = 'Position';
  sts = 'Status';
  tpi = 'TopIndex';
  vrs = 'Version=0,1z';
  pls = '[playlist]';
  fil = 'File';
  lng = 'Length';
  art = 'Artist';
  tit = 'Title';
  bit = 'Bitrate';
  frq = 'Frequency';
  siz = 'FileSize';
  gnr = 'Genre';
  alb = 'Album';
  yer = 'Year';
  inf = 'TrackInfo';

var
  i, p, S, c: Integer;
  fIni: TStringList;
begin
  if FileExists(fname) then
    DeleteFile(fname);
  c := Count;
  if c <= 0 then
    Exit;

  fIni := TStringList.Create;

  fIni.Add(pls);
  fIni.Add(vrs);
  fIni.Add(tpi + del + IntToStr(fTopIndex));

  if Assigned(fOnSave) then
  begin
    fOnSave(Self, p, S);
    fIni.Add(sts + del + IntToStr(S));
    fIni.Add(psn + del + IntToStr(p));
  end;

  fIni.Add(' ');
  fIni.Add(noe + del + IntToStr(c));
  fIni.Add(' ');

  i := 0;
  while i < c do
  begin
    fIni.Add(fil + IntToStr(i + 1) + del + fList.FileName[i]);
    fIni.Add(lng + IntToStr(i + 1) + del + IntToStr(fList.Duration[i]));
    fIni.Add(art + IntToStr(i + 1) + del + fList.Artist[i]);
    fIni.Add(tit + IntToStr(i + 1) + del + fList.Title[i]);
    fIni.Add(alb + IntToStr(i + 1) + del + fList.Album[i]);
    fIni.Add(gnr + IntToStr(i + 1) + del + fList.Genre[i]);
    fIni.Add(yer + IntToStr(i + 1) + del + fList.Year[i]);
    fIni.Add(bit + IntToStr(i + 1) + del + IntToStr(fList.Bitrate[i]));
    fIni.Add(frq + IntToStr(i + 1) + del + IntToStr(fList.SampleRate[i]));
    fIni.Add(siz + IntToStr(i + 1) + del + IntToStr(fList.Size[i]));
    fIni.Add(inf + IntToStr(i + 1) + del + fList.ItemAsString(i));

    fIni.Add(' ');
    inc(i);
  end;

  fIni.SaveToFile(fname);
  FreeAndNil(fIni);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SavePLS(const fname: string);

const
  del = '=';
  noe = 'NumberOfEntries';
  tpi = 'TopIndex';
  pls = '[playlist]';
  fil = 'File';
  lng = 'Length';
  tit = 'Title';

var
  i, p, S, c: Integer;
  fIni: TStringList;
begin
  if FileExists(fname) then
    DeleteFile(fname);
  c := Count;
  if c <= 0 then
    Exit;

  fIni := TStringList.Create;

  fIni.Add(pls);

  fIni.Add(' ');
  fIni.Add(noe + del + IntToStr(c));
  fIni.Add(' ');

  i := 0;
  while i < c do
  begin
    fIni.Add(fil + IntToStr(i + 1) + del + fList.FileName[i]);
    fIni.Add(lng + IntToStr(i + 1) + del + IntToStr(fList.Duration[i]));
    fIni.Add(tit + IntToStr(i + 1) + del + fList.Title[i]);

    fIni.Add(' ');
    inc(i);
  end;

  fIni.SaveToFile(fname);
  FreeAndNil(fIni);
end;
// ******************************************************************************

procedure TZMSAdvPlayList.SaveM3U_8(const fname: string;
  saveUnicode: boolean = false);
const
  aHeader = '#EXTM3U';
  aTag = '#EXTINF:';
var
  i, c: Integer;
  fl: TStringList;
  enc: TEncoding;
begin
  if FileExists(fname) then
    DeleteFile(fname);

  c := Count;
  if c <= 0 then
    Exit;

  i := 0;
  BeginUpdate;
  fl := TStringList.Create;
  try
    fl.Add(aHeader);

    while i < c do
    begin
      fl.Add(aTag + IntToStr(fList.Duration[i]) + ',' + fList.Title[i]);
      fl.Add(fList.FileName[i]);
      inc(i);
    end;

  finally
    EndUpdate;

    if saveUnicode then
      fl.SaveToFile(fname, enc.UTF8)
    else
      fl.SaveToFile(fname);

    FreeAndNil(fl);
  end;
end;
// ******************************************************************************

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSAdvPlayList]);
end;
// ******************************************************************************

end.

