unit List_Class;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TPLItem: модуль для TZMSAdvPlayList        |
  ********************************************* }

interface

uses
  Windows, SysUtils, Classes;

type
  TPLSortType = (stTitle, stArtist, stAlbum, stGenres, stComment, stYear,
    stTime, stFolder, stSwitch, stError, stUrl, stFind);
  TPLFindType = (fdAll, fdTitle, fdArtist, fdFileName);
  TCueInfo = (ciArtist, ciTitle, ciDate, ciGenre, ciComment);

  TPLCue = record
    Count, ID, Now, Next: integer;
  end;

  TPLDynamicList = class;
  PPLDataItem = ^TPLItem;

  TPLItem = record
    plFile: string;
    plType: string;
    plTitle: string;
    plArtist: string;
    plGenre: string;
    plAlbum: string;
    plYear: string;
    plComment: string;
    plDuration: integer;
    plSize: integer;
    plBitrate: integer;
    plSampleRate: integer;
    plCueInfo: TPLCue;
    plSelected: boolean;
    plTracking: boolean;
    plCue: boolean;
    plUrl: boolean;
    plMulti: boolean;
    plFind: boolean;
    plError: boolean;
    plUpdated: boolean;
    plSwitch: boolean;
  end;

  PPLDataItemList = ^TPLItemList;
  TPLItemList = array [0 .. MaxInt div SizeOf(TPLItem) - 1] of TPLItem;
  TPLCompare = function(List: TPLDynamicList; Index1, Index2: integer): integer;

  TPLDynamicList = class
  private
    fCount: integer;
    fCapacity: integer;
    fPlayList: PPLDataItemList;
    fUpdateCount: integer;

    fOnChange: TNotifyEvent;
    fOnChanging: TNotifyEvent;

    procedure Grow;
    function GetCount: integer;

    procedure ExchangeItems(Index1, Index2: integer; Value: boolean);
    procedure QuickSort(L, R: integer; SCompare: TPLCompare);

    function GetTitle(Index: integer): string;
    function GetArtist(Index: integer): string;
    function GetAlbum(Index: integer): string;
    function GetGenre(Index: integer): string;
    function GetComment(Index: integer): string;
    function GetYear(Index: integer): string;
    function GetFileName(Index: integer): string;
    function GetFileType(Index: integer): string;
    function GetDuration(Index: integer): integer;
    function GetCueDuration(Index: integer): integer;
    function GetSampleRate(Index: integer): integer;
    function GetSize(Index: integer): integer;
    function GetBitrate(Index: integer): integer;
    function GetCueCount(Index: integer): integer;
    function GetCueID(Index: integer): integer;
    function GetCueNextID(Index: integer): integer;
    function GetCueNowID(Index: integer): integer;

    function GetSelectedIndex: integer;
    function GetTrackingIndex: integer;
    function GetUpdatedIndex: integer;

    function GetTotalDuration: Int64;
    function GetTotalSize: Int64;
    function GetItemInfo(Index: integer): string;
    function GetSwitchIndex(Index: integer): boolean;

    procedure SetTitle(Index: integer; Value: string);
    procedure SetArtist(Index: integer; Value: string);
    procedure SetAlbum(Index: integer; Value: string);
    procedure SetGenre(Index: integer; Value: string);
    procedure SetComment(Index: integer; Value: string);
    procedure SetYear(Index: integer; Value: string);
    procedure SetFileName(Index: integer; Value: string);
    procedure SetFileType(Index: integer; Value: string);
    procedure SetDuration(Index: integer; Value: integer);
    procedure SetSampleRate(Index: integer; Value: integer);
    procedure SetSize(Index: integer; Value: integer);
    procedure SetBitrate(Index: integer; Value: integer);

    procedure SetSelectedIndex(Index: integer);
    procedure SetTrackingIndex(Index: integer);
    procedure SetUpdatedIndex(Index: integer);

    procedure SetSelected(Index: integer; Value: boolean);
    procedure SetTracking(Index: integer; Value: boolean);
    procedure SetUpdated(Index: integer; Value: boolean);
    procedure SetCue(Index: integer; Value: boolean);
    procedure SetURL(Index: integer; Value: boolean);
    procedure SetMultiSelect(Index: integer; Value: boolean);
    procedure SetFindSelect(Index: integer; Value: boolean);
    procedure SetErrorSelect(Index: integer; Value: boolean);
    procedure SetSwitchIndex(Index: integer; Value: boolean);

    function IsSelected(Index: integer): boolean;
    function IsTracking(Index: integer): boolean;
    function IsMultiSelect(Index: integer): boolean;
    function IsFindSelect(Index: integer): boolean;
    function IsErrorSelect(Index: integer): boolean;
    function IsURLSelect(Index: integer): boolean;
    function IsUpdated(Index: integer): boolean;
    function IsCue(Index: integer): boolean;
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;

    function GetCapacity: integer;
    procedure SetCapacity(NewCapacity: integer);

    procedure SetUpdateState(Updating: boolean);
    property UpdateCount: integer read fUpdateCount;

    function CompareStrings(const S1, S2: string): integer;
  public
    constructor Create;
    destructor Destroy; override;

    function SwitchCount: boolean;

    property Title[Index: integer]: string read GetTitle write SetTitle;
    property Artist[Index: integer]: string read GetArtist write SetArtist;
    property Album[Index: integer]: string read GetAlbum write SetAlbum;
    property Genre[Index: integer]: string read GetGenre write SetGenre;
    property Comment[Index: integer]: string read GetComment write SetComment;
    property Year[Index: integer]: string read GetYear write SetYear;
    property FileName[Index: integer]: string read GetFileName
      write SetFileName;
    property FileType[Index: integer]: string read GetFileType
      write SetFileType;
    property Duration[Index: integer]: integer read GetDuration
      write SetDuration;
    property CueDuration[Index: integer]: integer read GetCueDuration;
    property CueCount[Index: integer]: integer read GetCueCount;
    property CueID[Index: integer]: integer read GetCueID;
    property CueNextID[Index: integer]: integer read GetCueNextID;
    property CueNowID[Index: integer]: integer read GetCueNowID;
    property SampleRate[Index: integer]: integer read GetSampleRate
      write SetSampleRate;
    property Size[Index: integer]: integer read GetSize write SetSize;
    property Bitrate[Index: integer]: integer read GetBitrate write SetBitrate;

    property Selected[Index: integer]: boolean read IsSelected
      write SetSelected;
    property Tracking[Index: integer]: boolean read IsTracking
      write SetTracking;
    property URL[Index: integer]: boolean read IsURLSelect write SetURL;
    property Multi[Index: integer]: boolean read IsMultiSelect
      write SetMultiSelect;
    property Find[Index: integer]: boolean read IsFindSelect
      write SetFindSelect;
    property Error[Index: integer]: boolean read IsErrorSelect
      write SetErrorSelect;
    property Switch[Index: integer]: boolean read GetSwitchIndex
      write SetSwitchIndex;
    property Updated[Index: integer]: boolean read IsUpdated write SetUpdated;
    property Cue[Index: integer]: boolean read IsCue write SetCue;

    property SelectedID: integer read GetSelectedIndex write SetSelectedIndex
      default -1;
    property TrackingID: integer read GetTrackingIndex write SetTrackingIndex
      default -1;
    property UpdatedID: integer read GetUpdatedIndex write SetUpdatedIndex
      default 0;

    property Count: integer read GetCount;
    property Capacity: integer read GetCapacity write SetCapacity;

    procedure Clear;
    procedure Delete(Index: integer);

    procedure InsertItem(Index: integer; Item: TPLItem); overload;
    procedure InsertItem(Index: integer; fName: string); overload;

    function BuildPaintString(Index: integer; Format: string): string;
    procedure ReadDataFrom(Index: integer; out Data: TPLItem);
    procedure WriteDataTo(Index: integer; var Data: TPLItem;
      const IsCue: boolean = false);

    function ItemAsString(Index: integer): string;
    procedure StringAsItem(Value: string; var Item: TPLItem);

    property TotalDuration: Int64 read GetTotalDuration default 0;
    property TotalSize: Int64 read GetTotalSize default 0;
    property ItemInfo[Index: integer]: string read GetItemInfo;

    function QuickFind(const S: string; Index: integer;
      Mode: TPLFindType): boolean;
    procedure Exchange(Index1, Index2: integer; Value: boolean = false);
    procedure Sort(SortType: TPLSortType); virtual;
    procedure CustomSort(Compare: TPLCompare); virtual;
    function SelectedAllItems: boolean;

    procedure EndUpdate;
    procedure BeginUpdate;
    procedure Checking;
    procedure UnChecking;

    procedure ClearSelected;
    procedure ClearTracking;
    procedure ClearMultiSelect;

    property OnChange: TNotifyEvent read fOnChange write fOnChange;
    property OnChanging: TNotifyEvent read fOnChanging write fOnChanging;
  end;

function ParseStr(var Str: string; const sBegin, sEnd: string;
  FindDelete: boolean = false): string;
function GetSizeFile(fName: string): LongInt;

// ............................................ external's cue_reader function
function Cue_GetAudioFile(const cuefile, struct: string; out audiofile: string;
  const loadinfo: boolean = true): boolean;
// получаем имя музыкального файла из cue листа

function Cue_GetCueFile(audiofile: string): string;
// получаем имя cue листа, если оно найдено рядом с файлом
function Cue_IsCorrectFile(const fName: string): boolean;
// возвращает true если найдоно 2 файла

function Cue_GetInfo(const cuefile: string; var struct: string;
  out audiofile, Artist, Title, Genre, Comment, Year: string;
  out Count: integer; const loadinfo: boolean = true): boolean;
// получение основной информации

function Cue_GetIDInfo(const cuefile, struct: string; const ID: byte;
  out Artist, Title: string; out Duration: integer;
  const loadinfo: boolean = true): boolean;
// получение информации по его номеру

function Cue_GetIDDuration(const struct: string; const ID: byte): integer;
// получение позиции трека по номеру трека

function Cue_IFV(Value1, Value2: string): string;
// если 1 значение пусто, то возвращает 2 значение
function Cue_Time2Duration(time: string): integer;
// преобразование строкового времени в длинну трека

var
  cue_data, cue_artist, cue_title, cue_audiofile: string;
  cue_count: integer;
  // ............................................... end of cue_reader functions

implementation

uses
  StrUtils;

// ******************************************************************************

// function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
/// / copied from uses "StrUtils.pas"
// var
// I, X: Integer;
// Len, LenSubStr: Integer;
// begin
// if Offset = 1 then
// Result := Pos(SubStr, S)
// else begin
// I := Offset;
// LenSubStr := Length(SubStr);
// Len := Length(S) - LenSubStr + 1;
// while I <= Len do
// begin
// if S[I] = SubStr[1] then
// begin
// X := 1;
// while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do Inc(X);
// if (X = LenSubStr) then
// begin
// Result := I;
// exit;
// end;
// end;
// Inc(I);
// end;
// Result := 0;
// end;
// end;

// ******************************************************************************
function FormattedStr(fmt: string; const Info: TPLItem;
  TimeToMS: boolean): string;
const
  tim = '#tim#'; // time
  art = '#art#'; // artist
  tit = '#tit#'; // title
  bit = '#bit#'; // bitrate
  frq = '#frq#'; // frequency
  siz = '#siz#'; // file size
  ext = '#ext#'; // ext
  gnr = '#gnr#'; // genre
  ifv = '#ifv#'; // automatic (artist - title | artist | title)
  alb = '#alb#'; // album
  yer = '#yer#'; // year

  // chn = '#chn#'; // channel mode {mono, stereo}
  // cnt = '#cnt#'; // playlist items count
  // idn = '#idn#'; // playlist itemindex

  fil = '#fil#'; // file name
  dir = '#dir#'; // file dir
  pth = '#pth#'; // file path

  function ExtractDir(const FileName: string): string;
  var
    I: integer;
  begin
    Result := ExtractFileDir(FileName);
    I := LastDelimiter(PathDelim + DriveDelim, Result) + 1;
    Result := Copy(Result, I, length(Result));
  end;

  function FormatTime(const Sec: integer): string;
  var
    H, M, S: integer;
  begin
    H := Sec div 3600;
    S := Sec mod 3600;
    M := S div 60;
    M := M + (H * 60);
    S := (S mod 60);
    if M > 99 then
      Result := Format('%3d:%2.2d', [M, S])
    else
      Result := Format('%2.2d:%2.2d', [M, S]);
  end;

  function getValue(const subfmt: string; fmt: string;
    const subInfo: string): string;
  begin
    if (Pos(subfmt, LowerCase(fmt)) > 0) then
    begin
      fmt := StringReplace(fmt, subfmt, '%s', [rfIgnoreCase, rfReplaceAll]);
      Result := Format(fmt, [subInfo]);
    end
    else
      Result := fmt;
  end;

  function getFull(const a, b: string): string;
  begin
    if (length(a) > 1) and (length(b) > 1) then
      Result := a + ' - ' + b
    else if (length(a) > 1) then
      Result := a
    else if (length(b) > 1) then
      Result := b;
  end;

var
  Return: string;
begin
  Return := '';

  try

    Return := getValue(art, fmt, Info.plArtist);
    Return := getValue(tit, Return, Info.plTitle);

    if TimeToMS then
      Return := getValue(tim, Return, FormatTime(Info.plDuration))
    else
      Return := getValue(tim, Return, IntToStr(Info.plDuration));

    Return := getValue(bit, Return, IntToStr(Info.plBitrate));
    Return := getValue(frq, Return, IntToStr(Info.plSampleRate));
    Return := getValue(siz, Return, IntToStr(Info.plSize));
    Return := getValue(ext, Return, Info.plType);
    Return := getValue(gnr, Return, Info.plGenre);
    Return := getValue(ifv, Return, getFull(Info.plArtist, Info.plTitle));
    Return := getValue(alb, Return, Info.plAlbum);
    Return := getValue(yer, Return, Info.plYear);

    Return := getValue(fil, Return,
      ChangeFileExt(ExtractFileName(Info.plFile), ''));
    Return := getValue(pth, Return, ExtractFilePath(Info.plFile));
    Return := getValue(dir, Return, ExtractDir(Info.plFile));

    // Return := getValue(chn, Return, Info.Channel);
    // Return := getValue(cnt, Return, Info.Count);
    // Return := getValue(idn, Return, Info.Index);

  finally
    Result := Return;
  end
end;
// ******************************************************************************

function ParseStr(var Str: string; const sBegin, sEnd: string;
  FindDelete: boolean = false): string;
// парсер строк
const
  endStr = '*^*';
var
  Return: string;
  x, y, e: integer;
begin
  Result := '';
  if Str = '' then
    exit;
  Return := Trim(Str);
  x := 1;

  if (sEnd = '') then
  begin
    Return := Return + endStr;
    e := length(endStr);
  end
  else
    e := length(sEnd);

  if (sBegin <> '') then
    x := Pos(LowerCase(sBegin), LowerCase(Return));

  y := PosEx(LowerCase(endStr), LowerCase(Return), x);
  if y = 0 then
    y := PosEx(LowerCase(sEnd), LowerCase(Return), x);

  if (x > 0) and (y > 0) then
  begin
    x := x + length(sBegin);
    y := (y - e) - (x - e);
    Result := TrimLeft(Copy(Return, x, y));
    if FindDelete then
      Delete(Str, x, y + e);
  end;

  if Result = 'nil' then
    Result := '';
end;

// ******************************************************************************

function ProcessMessages: boolean;
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
      exit
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

function GetSizeFile(fName: string): LongInt;
var
  InfoFile: TSearchRec;
  AttrFile: integer;
  ErrorReturn: integer;
begin
  Result := 0;
  AttrFile := $0000003F;
  ErrorReturn := FindFirst(fName, AttrFile, InfoFile);
  try
    if ErrorReturn = 0 then
      Result := InfoFile.Size;
  finally
    FindClose(InfoFile);
  end;
end;
// ******************************************************************************

function IsNetString(URL: string): boolean;
begin
  Result := false;
  if (Copy(LowerCase(URL), 1, 7) = 'http://') or
    (Copy(LowerCase(URL), 1, 6) = 'ftp://') or
    (Copy(LowerCase(URL), 1, 6) = 'mms://') then
    Result := true;
end;
// ******************************************************************************

function ExtractName(const FileName: TFileName): string;
begin
  Result := ExtractFileName(ChangeFileExt(FileName, ''));
end;
// ******************************************************************************

constructor TPLDynamicList.Create;
begin
  inherited;
end;
// ******************************************************************************

destructor TPLDynamicList.Destroy;
begin
  fOnChange := nil;
  fOnChanging := nil;
  inherited Destroy;
  if fCount <> 0 then
    Finalize(fPlayList^[0], fCount);
  fCount := 0;
  SetCapacity(0);
end;
// ******************************************************************************

function TPLDynamicList.GetCapacity: integer;
begin
  Result := fCapacity;
end;
// ******************************************************************************

procedure TPLDynamicList.SetCapacity(NewCapacity: integer);
begin
  ReallocMem(fPlayList, NewCapacity * SizeOf(TPLItem));
  fCapacity := NewCapacity;
end;
// ******************************************************************************

procedure TPLDynamicList.Grow;
var
  Delta: integer;
begin
  if fCapacity > 64 then
    Delta := fCapacity div 4
  else if fCapacity > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(fCapacity + Delta);
end;
// ******************************************************************************

function TPLDynamicList.GetCount: integer;
begin
  Result := fCount;
end;
// ******************************************************************************

procedure TPLDynamicList.BeginUpdate;
begin
  if fUpdateCount = 0 then
    SetUpdateState(true);
  Inc(fUpdateCount);
end;
// ******************************************************************************

procedure TPLDynamicList.EndUpdate;
begin
  Dec(fUpdateCount);
  if fUpdateCount = 0 then
    SetUpdateState(false);
end;
// ******************************************************************************

procedure TPLDynamicList.Changed;
begin
  if (fUpdateCount = 0) and Assigned(fOnChange) then
    fOnChange(Self);
end;
// ******************************************************************************

procedure TPLDynamicList.Changing;
begin
  if (fUpdateCount = 0) and Assigned(fOnChanging) then
    fOnChanging(Self);
end;
// ******************************************************************************

procedure TPLDynamicList.InsertItem(Index: integer; fName: string);
begin
{$O-}
  Changing;
  if fCount = fCapacity then
    Grow;
  if Index < fCount then
    System.Move(fPlayList^[Index], fPlayList^[Index + 1],
      (fCount - Index) * SizeOf(TPLItem));

  with fPlayList^[Index] do
  begin
    Pointer(plFile) := nil;
    Pointer(plType) := nil;
    Pointer(plTitle) := nil;
    Pointer(plArtist) := nil;
    Pointer(plGenre) := nil;
    Pointer(plAlbum) := nil;
    Pointer(plYear) := nil;
    Pointer(plComment) := nil;
    plFile := fName;
    plCue := false;
    plCueInfo.Count := 0;
    plCueInfo.ID := 0;
    plCueInfo.Now := 0;
    plCueInfo.Next := 0;
    plUrl := IsNetString(fName);
    if plUrl then
      plTitle := fName
    else
      plTitle := ExtractName(fName);
    plDuration := -1;
    plSize := 0;
    plBitrate := 0;
    plSampleRate := 0;
    plTracking := false;
    plSelected := false;
    plMulti := false;
    plFind := false;
    plError := false;
    plUpdated := false;
    plSwitch := true;
  end;

  Inc(fCount);
  Changed;
{$O+}
end;
// ******************************************************************************

procedure TPLDynamicList.InsertItem(Index: integer; Item: TPLItem);
begin
{$O-}
  Changing;
  if fCount = fCapacity then
    Grow;
  if Index < fCount then
    System.Move(fPlayList^[Index], fPlayList^[Index + 1],
      (fCount - Index) * SizeOf(TPLItem));

  with fPlayList^[Index] do
  begin
    Pointer(plFile) := nil;
    plFile := Item.plFile;
    Pointer(plType) := nil;
    plType := Item.plType;
    Pointer(plTitle) := nil;
    plTitle := Item.plTitle;
    Pointer(plArtist) := nil;
    plArtist := Item.plArtist;
    Pointer(plGenre) := nil;
    plGenre := Item.plGenre;
    Pointer(plAlbum) := nil;
    plAlbum := Item.plAlbum;
    Pointer(plComment) := nil;
    plComment := Item.plComment;
    Pointer(plYear) := nil;
    plYear := Item.plYear;
    plDuration := Item.plDuration;
    plSize := Item.plSize;
    plBitrate := Item.plBitrate;
    plSampleRate := Item.plSampleRate;
    plCue := Item.plCue;
    plCueInfo.Count := Item.plCueInfo.Count;
    plCueInfo.ID := Item.plCueInfo.ID;
    plCueInfo.Now := Item.plCueInfo.Now;
    plCueInfo.Next := Item.plCueInfo.Next;
    plUrl := Item.plUrl;
    plTracking := Item.plTracking; // false;
    plSelected := Item.plSelected; // false;
    plMulti := Item.plMulti; // false;
    plFind := Item.plFind; // false;
    plError := Item.plError;
    plUpdated := Item.plUpdated;
    plSwitch := Item.plSwitch;
  end;

  Inc(fCount);
  Changed;
{$O+}
end;
// ******************************************************************************

function TPLDynamicList.ItemAsString(Index: integer): string;
//
// function SafeS(const S: string): string;
// begin
// if S = '' then
// Result := 'nil'
// else
// Result := S;
// end;
//
// const
// GetInt: array [boolean] of string = ('0', '1');
// var
// Item: TPLItem;
// begin
// Result := '';
// if (Index < 0) or (Index >= fCount) then
// exit;
//
// ReadDataFrom(Index, Item);

const
  GetInt: array [boolean] of string = ('0', '1');
begin
  Result := '';
  if (Index < 0) or (Index >= fCount) then
    exit;

  Result := GetInt[Cue[Index]] + '|' + IntToStr(CueCount[Index]) + '|' +
    IntToStr(CueID[Index]) + '|' + IntToStr(CueNowID[Index]) + '|' +
    IntToStr(CueNextID[Index]) + '|' + GetInt[URL[Index]] + '|' +
    GetInt[Tracking[Index]] + '|' + GetInt[Selected[Index]] + '|' +
    GetInt[Multi[Index]] + '|' + GetInt[Find[Index]] + '|' + GetInt[Error[Index]
    ] + '|' + GetInt[Updated[Index]] + '|' + GetInt[Switch[Index]];

  // with Item do
  // begin
  // if tagswrite then
  // begin
  // Result := SafeS(plType) + '|' + SafeS(plArtist) + '|' + SafeS(plTitle) + '|' + SafeS(plGenre) + '|' +
  // SafeS(plAlbum) + '|' + SafeS(plYear) + '|' + SafeS(plComment);
  // end
  // else
  // begin
  // Result := IntToStr(plDuration) + '|' + IntToStr(plSize) + '|' + IntToStr(plBitrate) + '|' + IntToStr(plSampleRate)
  // + '|' + GetInt[plCue] + '|' + IntToStr(plCueInfo.Count) + '|' + IntToStr(plCueInfo.ID) + '|' +
  // IntToStr(plCueInfo.Now) + '|' + IntToStr(plCueInfo.Next) + '|' + GetInt[plUrl] + '|' + GetInt[plTracking] + '|'
  // + GetInt[plSelected] + '|' + GetInt[plMulti] + '|' + GetInt[plFind] + '|' + GetInt[plError] + '|' +
  // GetInt[plUpdated] + '|' + GetInt[plSwitch];
  // end;
  // end;
end;
// ******************************************************************************

procedure TPLDynamicList.StringAsItem(Value: string; var Item: TPLItem);

  function s2b(const S: string): boolean;
  begin
    Result := S[1] = '1';
  end;

var
  Str: string;
begin
  Str := Value;

  with Item do
  begin
    plCue := s2b(ParseStr(Str, '', '|', true));
    if plCue then
      plType := UpperCase(Copy(ExtractFileExt(plFile), 2,
        length(ExtractFileExt(plFile))));

    plCueInfo.Count := StrToInt(ParseStr(Str, '', '|', true));
    plCueInfo.ID := StrToInt(ParseStr(Str, '', '|', true));
    plCueInfo.Now := StrToInt(ParseStr(Str, '', '|', true));
    plCueInfo.Next := StrToInt(ParseStr(Str, '', '|', true));
    plUrl := s2b(ParseStr(Str, '', '|', true));
    plTracking := s2b(ParseStr(Str, '', '|', true));
    plSelected := s2b(ParseStr(Str, '', '|', true));
    plMulti := s2b(ParseStr(Str, '', '|', true));
    plFind := s2b(ParseStr(Str, '', '|', true));
    plError := s2b(ParseStr(Str, '', '|', true));
    plUpdated := s2b(ParseStr(Str, '', '|', true));
    plSwitch := s2b(ParseStr(Str, '', '', true));
  end;
end;
// ******************************************************************************

function TPLDynamicList.BuildPaintString(Index: integer;
  Format: string): string;
var
  Item: TPLItem;
begin
  Result := '';
  if (Index < 0) or (Index >= fCount) then
    exit;

  ReadDataFrom(Index, Item);
  if Format = '' then
  begin
    with Item do
    begin
      if (plArtist <> '') and (plTitle <> '') then
        Result := plArtist + ' - ' + plTitle
      else if plArtist <> '' then
        Result := plArtist
      else if plTitle <> '' then
        Result := plTitle;
    end;
    exit;
  end
  else
    Result := FormattedStr(Format, Item, true);
end;
// ******************************************************************************

procedure TPLDynamicList.ReadDataFrom(Index: integer; out Data: TPLItem);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Data.plFile := fPlayList^[Index].plFile;
  Data.plType := fPlayList^[Index].plType;
  Data.plTitle := fPlayList^[Index].plTitle;
  Data.plArtist := fPlayList^[Index].plArtist;
  Data.plGenre := fPlayList^[Index].plGenre;
  Data.plAlbum := fPlayList^[Index].plAlbum;
  Data.plYear := fPlayList^[Index].plYear;
  Data.plComment := fPlayList^[Index].plComment;
  Data.plDuration := fPlayList^[Index].plDuration;
  Data.plSampleRate := fPlayList^[Index].plSampleRate;
  Data.plBitrate := fPlayList^[Index].plBitrate;
  Data.plSize := fPlayList^[Index].plSize;
  Data.plCue := fPlayList^[Index].plCue;
  Data.plUrl := fPlayList^[Index].plUrl;
  Data.plSwitch := fPlayList^[Index].plSwitch;
  Data.plError := fPlayList^[Index].plError;
  Data.plUpdated := fPlayList^[Index].plUpdated;
  Data.plCueInfo := fPlayList^[Index].plCueInfo;
end;
// ******************************************************************************

procedure TPLDynamicList.WriteDataTo(Index: integer; var Data: TPLItem;
  const IsCue: boolean = false);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;

  if not IsCue then
  begin
    fPlayList^[Index].plType := Data.plType;
    fPlayList^[Index].plTitle := Data.plTitle;
    fPlayList^[Index].plArtist := Data.plArtist;
    fPlayList^[Index].plUrl := Data.plUrl;
  end;
  fPlayList^[Index].plFile := Data.plFile;
  fPlayList^[Index].plGenre := Data.plGenre;
  fPlayList^[Index].plAlbum := Data.plAlbum;
  fPlayList^[Index].plYear := Data.plYear;
  fPlayList^[Index].plComment := Data.plComment;
  fPlayList^[Index].plDuration := Data.plDuration;
  fPlayList^[Index].plSampleRate := Data.plSampleRate;
  fPlayList^[Index].plBitrate := Data.plBitrate;
  fPlayList^[Index].plSize := Data.plSize;
  fPlayList^[Index].plCue := Data.plCue;
  fPlayList^[Index].plSwitch := Data.plSwitch;
  fPlayList^[Index].plError := Data.plError;
  fPlayList^[Index].plUpdated := Data.plUpdated;
  fPlayList^[Index].plCueInfo := Data.plCueInfo;
end;
// ******************************************************************************

procedure TPLDynamicList.Clear;
begin
  if fCount <> 0 then
  begin
    Changing;
    // ProcessMessages;
    Finalize(fPlayList^[0], fCount);
    fCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;
// ******************************************************************************

procedure TPLDynamicList.Delete(Index: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  Finalize(fPlayList^[Index]);
  Dec(fCount);
  if Index < fCount then
    System.Move(fPlayList^[Index + 1], fPlayList^[Index],
      (fCount - Index) * SizeOf(TPLItem));
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.Exchange(Index1, Index2: integer;
  Value: boolean = false);
begin
  if Index1 = Index2 then
    exit;
  if (Index1 < 0) or (Index1 >= fCount) then
    exit;
  if (Index2 < 0) or (Index2 >= fCount) then
    exit;
  Changing;
  ExchangeItems(Index1, Index2, Value);
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.ExchangeItems(Index1, Index2: integer; Value: boolean);
var
  Temp: TPLItem;
  I: integer;
begin
  if Value then
  begin
    Temp := fPlayList^[Index1];
    fPlayList^[Index1] := fPlayList^[Index2];
    fPlayList^[Index2] := Temp
  end
  else
  begin
    if Index1 > Index2 then
    begin
      for I := Index1 - 1 downto Index2 do
      begin
        Temp := fPlayList^[I + 1];
        fPlayList^[I + 1] := fPlayList^[I];
        fPlayList^[I] := Temp
      end;
    end
    else
    begin
      for I := Index1 + 1 to Index2 do
      begin
        Temp := fPlayList^[I - 1];
        fPlayList^[I - 1] := fPlayList^[I];
        fPlayList^[I] := Temp
      end;
    end;
  end;
end;
// ******************************************************************************

function TPLDynamicList.QuickFind(const S: string; Index: integer;
  Mode: TPLFindType): boolean;
var
  S1: string;
begin
  Result := false;
  if (fCount > 0) and (S <> '') and (Index > -1) then
  begin
    S1 := '';
    { if (Mode in [fdAll, fdTitle]) then S1 := S1 + fPlayList^[Index].plTitle;
      if (Mode in [fdAll, fdArtist]) then S1 := S1 + fPlayList^[Index].plArtist;
      if (Mode in [fdAll, fdFileName]) then S1 := S1 + fPlayList^[Index].plFile; }
    S1 := LowerCase(fPlayList^[Index].plArtist + ' ' + fPlayList^
      [Index].plTitle);
    Result := Pos(S, S1) > 0;
    S1 := '';
  end;
end;
// ******************************************************************************

procedure TPLDynamicList.SetUpdateState(Updating: boolean);
begin
  if Updating then
    Changing
  else
    Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.QuickSort(L, R: integer; SCompare: TPLCompare);
var
  I, J, P: integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do
        Inc(I);
      while SCompare(Self, J, P) > 0 do
        Dec(J);
      if I <= J then
      begin
        Exchange(J, I, true);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;
// ******************************************************************************

function CompareTitle(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plTitle,
    List.fPlayList^[Index2].plTitle);
end;
// ******************************************************************************

function CompareArtist(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plArtist,
    List.fPlayList^[Index2].plArtist);
end;
// ******************************************************************************

function CompareAlbum(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plAlbum,
    List.fPlayList^[Index2].plAlbum);
end;
// ******************************************************************************

function CompareYear(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plYear,
    List.fPlayList^[Index2].plYear);
end;
// ******************************************************************************

function CompareComment(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plComment,
    List.fPlayList^[Index2].plComment);
end;
// ******************************************************************************

function CompareGenres(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(List.fPlayList^[Index1].plGenre,
    List.fPlayList^[Index2].plGenre);
end;
// ******************************************************************************

function CompareFolders(List: TPLDynamicList; Index1, Index2: integer): integer;
begin
  Result := List.CompareStrings(ExtractFilePath(List.fPlayList^[Index1].plFile),
    ExtractFilePath(List.fPlayList^[Index2].plFile));
end;
// ******************************************************************************

function CompareTime(List: TPLDynamicList; Index1, Index2: integer): integer;
var
  Int1, Int2: integer;
begin
  if List.fPlayList^[Index1].plCue then
    Int1 := List.CueDuration[Index1]
  else
    Int1 := List.fPlayList^[Index1].plDuration;

  if List.fPlayList^[Index2].plCue then
    Int2 := List.CueDuration[Index2]
  else
    Int2 := List.fPlayList^[Index2].plDuration;

  if Int1 > Int2 then
    Result := 1
  else if Int1 = Int2 then
    Result := 0
  else
    Result := -1;
end;
// ******************************************************************************

function CompareSwitch(List: TPLDynamicList; Index1, Index2: integer): integer;
var
  Int1, Int2: integer;
begin
  Int1 := integer(List.fPlayList^[Index1].plSwitch);
  Int2 := integer(List.fPlayList^[Index2].plSwitch);

  if Int1 > Int2 then
    Result := 1
  else if Int1 = Int2 then
    Result := 0
  else
    Result := -1;
end;
// ******************************************************************************

function CompareError(List: TPLDynamicList; Index1, Index2: integer): integer;
var
  Int1, Int2: integer;
begin
  Int1 := integer(List.fPlayList^[Index1].plError);
  Int2 := integer(List.fPlayList^[Index2].plError);

  if Int1 > Int2 then
    Result := 1
  else if Int1 = Int2 then
    Result := 0
  else
    Result := -1;
end;
// ******************************************************************************

function CompareUrl(List: TPLDynamicList; Index1, Index2: integer): integer;
var
  Int1, Int2: integer;
begin
  Int1 := integer(List.fPlayList^[Index1].plUrl);
  Int2 := integer(List.fPlayList^[Index2].plUrl);

  if Int1 < Int2 then
    Result := 1
  else if Int1 = Int2 then
    Result := 0
  else
    Result := -1;
end;
// ******************************************************************************

function CompareFind(List: TPLDynamicList; Index1, Index2: integer): integer;
var
  Int1, Int2: integer;
begin
  Int1 := integer(List.fPlayList^[Index1].plFind);
  Int2 := integer(List.fPlayList^[Index2].plFind);

  if Int1 < Int2 then
    Result := 1
  else if Int1 = Int2 then
    Result := 0
  else
    Result := -1;
end;
// ******************************************************************************

procedure TPLDynamicList.Sort(SortType: TPLSortType);
begin
  case SortType of
    stTitle:
      CustomSort(CompareTitle);
    stArtist:
      CustomSort(CompareArtist);
    stAlbum:
      CustomSort(CompareAlbum);
    stGenres:
      CustomSort(CompareGenres);
    stComment:
      CustomSort(CompareComment);
    stYear:
      CustomSort(CompareYear);
    stTime:
      CustomSort(CompareTime);
    stFolder:
      CustomSort(CompareFolders);
    stSwitch:
      CustomSort(CompareSwitch);
    stError:
      CustomSort(CompareError);
    stUrl:
      CustomSort(CompareUrl);
    stFind:
      CustomSort(CompareFind);
  end;
end;
// ******************************************************************************

procedure TPLDynamicList.CustomSort(Compare: TPLCompare);
begin
  if (fCount > 1) then
  begin
    Changing;
    QuickSort(0, fCount - 1, Compare);
    Changed;
  end;
end;
// ******************************************************************************

function TPLDynamicList.CompareStrings(const S1, S2: string): integer;
begin
  Result := CompareText(S1, S2);
end;
// ******************************************************************************

function TPLDynamicList.GetTitle(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plTitle;
end;
// ******************************************************************************

procedure TPLDynamicList.SetTitle(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plTitle := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetArtist(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plArtist;
end;
// ******************************************************************************

procedure TPLDynamicList.SetArtist(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plArtist := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetAlbum(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plAlbum;
end;
// ******************************************************************************

procedure TPLDynamicList.SetAlbum(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plAlbum := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetGenre(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plGenre;
end;
// ******************************************************************************

procedure TPLDynamicList.SetGenre(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plGenre := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetComment(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plComment;
end;
// ******************************************************************************

procedure TPLDynamicList.SetComment(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plComment := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetYear(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plYear;
end;
// ******************************************************************************

procedure TPLDynamicList.SetYear(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plYear := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetFileName(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plFile;
end;
// ******************************************************************************

procedure TPLDynamicList.SetFileName(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plFile := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetFileType(Index: integer): string;
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plType;
end;
// ******************************************************************************

procedure TPLDynamicList.SetFileType(Index: integer; Value: string);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plType := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetDuration(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plDuration;
end;
// ******************************************************************************

function TPLDynamicList.GetCueDuration(Index: integer): integer;
var
  I, c: integer;
  Return: integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  I := fPlayList^[Index].plCueInfo.ID;
  c := fPlayList^[Index].plCueInfo.Count;
  if I <> c then
    Return := (fPlayList^[Index].plCueInfo.Next - fPlayList^[Index]
      .plCueInfo.Now)
  else
    Return := (fPlayList^[Index].plDuration - fPlayList^[Index].plCueInfo.Now);

  if Return <= 0 then
    Return := -1;
  Result := Return; // !!!
end;
// ******************************************************************************

function TPLDynamicList.GetSampleRate(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plSampleRate;
end;
// ******************************************************************************

function TPLDynamicList.GetSize(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plSize;
end;
// ******************************************************************************

function TPLDynamicList.GetBitrate(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plBitrate;
end;
// ******************************************************************************

function TPLDynamicList.GetCueCount(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plCueInfo.Count;
end;
// ******************************************************************************

function TPLDynamicList.GetCueID(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plCueInfo.ID;
end;
// ******************************************************************************

function TPLDynamicList.GetCueNextID(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plCueInfo.Next;
end;
// ******************************************************************************

function TPLDynamicList.GetCueNowID(Index: integer): integer;
begin
  Result := 0;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plCueInfo.Now;
end;
// ******************************************************************************

procedure TPLDynamicList.SetDuration(Index: integer; Value: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plDuration := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetSampleRate(Index: integer; Value: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plSampleRate := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetSize(Index: integer; Value: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plSize := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetBitrate(Index: integer; Value: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plBitrate := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.IsSelected(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plSelected;
end;
// ******************************************************************************

function TPLDynamicList.IsTracking(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plTracking;
end;
// ******************************************************************************

procedure TPLDynamicList.SetSelected(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plSelected := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetUpdated(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plUpdated := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetCue(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plCue := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetTracking(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plTracking := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetURL(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plUrl := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.IsMultiSelect(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plMulti;
end;
// ******************************************************************************

procedure TPLDynamicList.SetMultiSelect(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plMulti := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.ClearMultiSelect;
var
  I: integer;
begin
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    fPlayList^[I].plMulti := false;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.IsFindSelect(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plFind;
end;
// ******************************************************************************

procedure TPLDynamicList.SetFindSelect(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plFind := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.IsErrorSelect(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plError;
end;
// ******************************************************************************

function TPLDynamicList.IsURLSelect(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plUrl;
end;
// ******************************************************************************

function TPLDynamicList.IsUpdated(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plUpdated;
end;
// ******************************************************************************

function TPLDynamicList.IsCue(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plCue;
end;
// ******************************************************************************

procedure TPLDynamicList.SetErrorSelect(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plError := Value;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetSwitchIndex(Index: integer): boolean;
begin
  Result := false;
  if (Index < 0) or (Index >= fCount) then
    exit;
  Result := fPlayList^[Index].plSwitch;
end;
// ******************************************************************************

procedure TPLDynamicList.SetSwitchIndex(Index: integer; Value: boolean);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plSwitch := Value;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.Checking;
var
  I: integer;
begin
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    fPlayList^[I].plSwitch := true;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.UnChecking;
var
  I: integer;
begin
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    fPlayList^[I].plSwitch := false;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetSelectedIndex: integer;
var
  I: integer;
begin
  Result := -1;
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    if fPlayList^[I].plSelected then
    begin
      Result := I;
      Break;
    end;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetSelectedIndex(Index: integer);
begin
  if (Index < -1) or (Index >= fCount) then
    exit;
  Changing;
  ClearSelected;
  if Index >= 0 then
    fPlayList^[Index].plSelected := true;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetTrackingIndex: integer;
var
  I: integer;
begin
  Result := -1;
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    if fPlayList^[I].plTracking then
    begin
      Result := I;
      Break;
    end;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetTrackingIndex(Index: integer);
begin
  if (Index < 0) or (Index >= fCount) then
    exit;
  Changing;
  ClearTracking;
  fPlayList^[Index].plTracking := true;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetUpdatedIndex: integer;
var
  I: integer;
begin
  Result := -1;
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    if not fPlayList^[I].plUpdated then
    begin
      Result := I;
      Break;
    end;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.SwitchCount: boolean;
var
  I: integer;
begin
  Result := false;
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
  begin
    if fPlayList^[I].plSwitch then
    begin
      Result := true;
      Break;
    end;
  end;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.SelectedAllItems: boolean;
var
  I: integer;
begin
  Result := false;
  if (fCount < 0) then
    exit;
  Result := true;
  Changing;

  // for I := 0 to Pred(fCount) do
  I := 0;
  while I <= Pred(Count) do
  begin
    if not fPlayList^[I].plSelected then
    begin
      Result := false;
      Break;
    end;
    Inc(I);
  end;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.SetUpdatedIndex(Index: integer);
begin
  if (Index < -1) or (Index >= fCount) then
    exit;
  Changing;
  fPlayList^[Index].plUpdated := true;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.ClearSelected;
var
  I: integer;
begin
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    fPlayList^[I].plSelected := false;
  Changed;
end;
// ******************************************************************************

procedure TPLDynamicList.ClearTracking;
var
  I: integer;
begin
  if (fCount < 0) then
    exit;
  Changing;
  for I := 0 to Pred(fCount) do
    fPlayList^[I].plTracking := false;
  TrackingID := -1;
  Changed;
end;
// ******************************************************************************

function TPLDynamicList.GetTotalDuration: Int64;
var
  I, c: integer;
begin
  Result := 0;
  if (fCount < 0) then
    exit;
  for I := 0 to Pred(fCount) do
  begin
    c := GetCueDuration(I);
    if c > 0 then
      Inc(Result, c);
  end;
end;
// ******************************************************************************

function TPLDynamicList.GetTotalSize: Int64;
var
  I: integer;
begin
  Result := 0;
  if (fCount < 0) then
    exit;
  for I := 0 to Pred(fCount) do
    Inc(Result, fPlayList^[I].plSize);
end;
// ******************************************************************************

function TPLDynamicList.GetItemInfo(Index: integer): string;
begin
  Result := 'Untitled'; // !!!
  if (Index < 0) or (Index >= fCount) then
    exit;

  with fPlayList^[Index] do
  begin
    if (plArtist <> '') and (plTitle <> '') then
      Result := plArtist + ' - ' + plTitle
    else if plArtist <> '' then
      Result := plArtist
    else if plTitle <> '' then
      Result := plTitle;
  end;
end;
// ..................................................... >> begin of cue_reader

const
  c_char = '"';
  c_filebegin = 'FILE "';
  c_filewave = '" WAVE';
  c_filemp3 = '" MP3';
  c_fileaiff = '" AIFF';
  c_performer = 'PERFORMER "';
  c_title = 'TITLE "';
  c_comment = 'REM COMMENT "';
  c_date = 'REM DATE ';
  c_genre = 'REM GENRE ';
  c_track = 'TRACK %2.2d AUDIO'; // 01..99
  c_index01 = 'INDEX 01 '; // NOTE: Время начала трека всегда лежит в INDEX 01

  c_ignore_index = 'INDEX';
  c_ignore_catalog = 'CATALOG';
  c_ignore_cdtextfile = 'CDTEXTFILE';
  c_ignore_flags = 'FLAGS';
  c_ignore_isrc = 'ISRC';
  c_ignore_postgap = 'POSTGAP';
  c_ignore_pregap = 'PREGAP';
  c_ignore_songwriter = 'SONGWRITER';

  { -------------------------------------------------------------------------- }

function Cue_IgnoreChecker(const Data: string): boolean;
begin
  Result := (Pos(c_ignore_catalog, Data) > 0) or
    (Pos(c_ignore_cdtextfile, Data) > 0) or (Pos(c_ignore_flags, Data) > 0) or
    (Pos(c_ignore_isrc, Data) > 0) or (Pos(c_ignore_postgap, Data) > 0) or
    (Pos(c_ignore_pregap, Data) > 0) or (Pos(c_ignore_songwriter, Data) > 0) or
    (Pos(c_ignore_index, Data) > 0);
  if Result then
    Result := (Pos(c_index01, Data) = 0);
end;

{ -------------------------------------------------------------------------- }

function Cue_IFV(Value1, Value2: string): string;
begin
  if Value1 = '' then
    Result := Value2
  else
    Result := Value1
end;

{ -------------------------------------------------------------------------- }

function Cue_Time2Duration(time: string): integer;
// преобразование строкового времени в длинну трека
// формат [mm:ss] 00:00
const
  define = '0123456789:';
var
  I, L, R: integer;
  breaked: boolean;
  lng, posb, pose: integer;
begin
  Result := 0;
  breaked := false;
  lng := length(time);
  if (lng < 5) then
    exit;

  for I := 1 to lng - 1 do
  begin
    if (Pos(time[I], define) = 0) then
    begin
      breaked := true;
      Break;
    end;
  end;

  if (not breaked) then
  begin
    if lng = 5 then
      time := time + ':';

    posb := Pos(':', time);
    pose := PosEx(':', time, posb);
    if (posb > 0) and (pose > 0) then
    begin
      L := StrToInt(Copy(time, 1, posb - 1));
      R := StrToInt(Copy(time, posb + 1, pose - 1));
      Result := (L * 60) + R;
    end;
  end;
end;

{ -------------------------------------------------------------------------- }

function Cue_GetCueFile(audiofile: string): string;
// поиск .cue файла рядом с музыкальным
var
  Return: string;
begin
  Result := '';
  if (not FileExists(audiofile)) then
    exit;
  Return := ChangeFileExt(audiofile, '.cue');
  if FileExists(Return) then
    Result := Return;
end;

{ -------------------------------------------------------------------------- }

function Cue_GetAudioFile(const cuefile, struct: string; out audiofile: string;
  const loadinfo: boolean = true): boolean;
// ищем в тексте название аудио файла, если аудио файл существует
// результатом будет истина
// note:
// если флаг loadinfo = true, то передается cue файл,
// если false, то имя аудио файла и переменная struct
// должна содержать данные cue листа
var
  src: TStringList;
  Str: string;
begin
  Result := false;
  if not FileExists(cuefile) then
    exit;
  try
    src := TStringList.Create;
    try
      if loadinfo then
      begin
        src.LoadFromFile(cuefile);
        Str := src.Text;
        // заносим в переменную, для удобства
      end
      else
        Str := struct;

      if src.Count < 0 then
      begin
        FreeAndNil(src);
        exit;
      end;

      audiofile := ParseStr(Str, c_filebegin, c_filewave);
      if audiofile = '' then
        audiofile := ParseStr(Str, c_filebegin, c_filemp3);
      if audiofile = '' then
        audiofile := ParseStr(Str, c_filebegin, c_fileaiff);
      Result := audiofile <> '';
      if Result then
        audiofile := ExtractFilePath(cuefile) + audiofile;
    finally
      FreeAndNil(src);
    end;
  except
    Result := false;
  end;
end;

{ -------------------------------------------------------------------------- }

function Cue_IsCorrectFile(const fName: string): boolean;
// возвращает истину, если найдены 2 файла (аудио файл и cue лист)
var
  ext: string;
begin
  Result := false;
  if not FileExists(fName) then
    exit;
  ext := LowerCase(ExtractFileExt(fName));
  if Pos('.cue', ext) > 0 then
    Result := Cue_GetAudioFile(fName, ext, ext)
  else
    Result := FileExists(Cue_GetCueFile(fName));
end;

{ -------------------------------------------------------------------------- }

function Cue_GetInfo(const cuefile: string; var struct: string;
  out audiofile, Artist, Title, Genre, Comment, Year: string;
  out Count: integer; const loadinfo: boolean = true): boolean;
// ф-ия вернет истину, если найдет в папке указанный в cue листе аудио файл
// также передается основная информация (до описания треков)
// note:
// если флаг loadinfo = true, то передается cue файл,
// если false, то имя аудио файла и переменная struct
// должна содержать данные cue листа
var
  src: TStringList;
  I, cnt, q: integer;
  Str: string;
begin
  Result := false;
  if not FileExists(cuefile) then
    exit;
  try
    src := TStringList.Create;
    try
      // ------ управляем данными -------
      if loadinfo then
      begin
        src.LoadFromFile(cuefile);
        struct := src.Text; // заносим в переменную, для удобства
      end
      else
        src.Text := struct;
      cnt := src.Count;
      // --------------------------------

      if cnt < 0 then
      begin
        FreeAndNil(src);
        exit;
      end;

      for I := cnt - 1 downto 0 do
      begin
        if Cue_IgnoreChecker(src.Strings[I]) then
        begin
          src.Delete(I);
          Dec(cnt);
        end;
      end;

      // -------- ищем в тексте название аудио файла --------
      Result := Cue_GetAudioFile(cuefile, struct, audiofile, false);
      if not Result then
      begin
        FreeAndNil(src);
        exit;
        // не нашли, выходим
      end;
      // ----------------------------------------------------

      Count := 1;
      q := cnt - 1;

      for I := 0 to 10 do
      begin
        if Pos(Format(c_track, [1]), src.Strings[I]) > 0 then
        begin
          q := I;
          Break;
        end;
      end;

      for I := 0 to cnt - 1 do
      begin
        // ----------- считываем основную информаию -----------
        Str := src.Strings[I];
        if I < q then
        begin
          if Str[length(Str)] = '"' then
            Str := Copy(Str, 1, length(Str) - 1);

          if Comment = '' then
            Comment := ParseStr(Str, c_comment, '');
          if Artist = '' then
            Artist := ParseStr(Str, c_performer, '');
          if Title = '' then
            Title := ParseStr(Str, c_title, '');
          if Genre = '' then
            Genre := ParseStr(Str, c_genre, '');
          if Year = '' then
            Year := ParseStr(Str, c_date, '');
        end;

        if Pos(Format(c_track, [Count]), Str) > 0 then
          Inc(Count); // считаем кол-во треков
      end;
      // ----------------------------------------------------
      Dec(Count); // Count-1 т.к. изначально стартовали с 1
    finally
      FreeAndNil(src);
    end;
  except
    Result := false;
  end;
end;

{ -------------------------------------------------------------------------- }

function Cue_GetIDInfo(const cuefile, struct: string; const ID: byte;
  out Artist, Title: string; out Duration: integer;
  const loadinfo: boolean = true): boolean;
// ф-ия вернет истину, если найдет указаный # в cue листе
// и передает информацию о треке (артист, заголовок, позицию начала)
// note:
// если флаг loadinfo = true, то передается cue файл,
// если false, то имя аудио файла и переменная struct
// должна содержать данные cue листа
var
  src: TStringList;
  I, J, cnt: integer;
  Str, dur: string;
begin
  Result := false;
  if not FileExists(cuefile) then
    exit;
  try
    src := TStringList.Create;
    try
      // ------ управляем данными -------
      if loadinfo then
        src.LoadFromFile(cuefile)
      else
        src.Text := struct;
      cnt := src.Count;
      // --------------------------------

      if cnt < 0 then
      begin
        FreeAndNil(src);
        exit;
      end;

      for I := cnt - 1 downto 0 do
      begin
        if Cue_IgnoreChecker(src.Strings[I]) then
        begin
          src.Delete(I);
          Dec(cnt);
        end;
      end;

      dur := '';
      // ------------ считываем информаию по ID -------------
      for I := 0 to cnt - 1 do
      begin
        Str := src.Strings[I];
        if Pos(Format(c_track, [ID]), Str) > 0 then
        begin
          Result := true;
          for J := 1 to 3 do
          begin
            if (I + J >= cnt) then
              exit;
            Str := src.Strings[I + J];
            if Str[length(Str)] = '"' then
              Str := Copy(Str, 1, length(Str) - 1);

            if Artist = '' then
              Artist := ParseStr(Str, c_performer, '');
            if Title = '' then
              Title := ParseStr(Str, c_title, '');
            if dur = '' then
              dur := ParseStr(Str, c_index01, '');
          end; // for j:=1 to 3 do ...
          if dur <> '' then
            Duration := Cue_Time2Duration(dur);
          Break;
        end; // pos ...
        // end;
      end;
      // ----------------------------------------------------
    finally
      FreeAndNil(src);
    end;
  except
    Result := false;
  end;
end;

{ -------------------------------------------------------------------------- }

function Cue_GetIDDuration(const struct: string; const ID: byte): integer;
// ф-ия вернет истину, если найдет указаный # в cue листе
// и передает позицию начала о трека
var
  src: TStringList;
  I, J, cnt: integer;
  Str, dur: string;
begin
  Result := 0;
  try
    src := TStringList.Create;
    try
      // ------ управляем данными -------
      src.Text := struct;
      cnt := src.Count;
      // --------------------------------

      if cnt < 0 then
      begin
        FreeAndNil(src);
        exit;
      end;

      for I := cnt - 1 downto 0 do
      begin
        if Cue_IgnoreChecker(src.Strings[I]) then
        begin
          src.Delete(I);
          Dec(cnt);
        end;
      end;

      dur := '';
      // ------------ считываем информаию по ID -------------
      for I := 0 to cnt - 1 do
      begin
        Str := src.Strings[I];
        if Pos(Format(c_track, [ID]), Str) > 0 then
        begin
          for J := 1 to 3 do
          begin
            if (I + J >= cnt) then
              exit;
            Str := src.Strings[I + J];
            if Str[length(Str)] = '"' then
              Str := Copy(Str, 1, length(Str) - 1);

            if dur = '' then
              dur := ParseStr(Str, c_index01, '');
          end; // for j:=1 to 3 do ...
          if dur <> '' then
            Result := Cue_Time2Duration(dur);
          Break;
        end; // pos ...
      end;
      // end;
      // ----------------------------------------------------
    finally
      FreeAndNil(src);
    end;
  except
    Result := 0;
  end;
end;
// ................................................... end of cue_reader <<

initialization

cue_data := '';
cue_artist := '';
cue_title := '';
cue_audiofile := '';
cue_count := 0;

end.
