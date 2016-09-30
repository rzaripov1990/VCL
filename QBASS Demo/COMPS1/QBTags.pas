unit QBTags;

{$WARNINGS OFF}
{$HINTS OFF}
{$I-}
{$O-}
{$A-}
(* *********************************************
  |  author: Zaripov Ravil aka ZuBy            |
  | contact:                                   |
  |          mail: rzaripov1990@gmail.com      |
  |          web : http://zuby.ucoz.kz         |
  |          Kazakhstan, Semey, © 2010         |
  |--------------------------------------------|
  |  author: SalasAndriy                       |
  | contact: icq : 258-21-52                   |
  |          mail: life-program@yandex.ru      |
  |          web : http://gs-team.3dn.ru/      |
  |          Ukraine, Copyright GS-Team © 2010 |
  |--------------------------------------------|
  |-        for Delphi 2009+ (UNICODE)        -|
  |-   Read tags from bass and bass add-ons   -|
  |-    available to bass.dll version 2.4+    -|
  ******************************************** *)

interface

uses
  Windows, SysUtils, Classes, StrUtils, BASS, QBCommon;

const
  // copied from bass headers
  BASS_TAG_ID3 = 0;               // MP1, MP2, MP3, AAC, WV
  BASS_TAG_ID3V2 = 1;             // MP1, MP2, MP3, AAC, WV
  BASS_TAG_OGG = 2;               // OGG, FLAC
  BASS_TAG_HTTP = 3;              // HTTP headers
  BASS_TAG_ICY = 4;               // ICY headers
  BASS_TAG_APE = 6;               // APE, MPC, MP+, MPP, OFR, OFS, WV
  BASS_TAG_MP4 = 7;               // MP4, M4A, AIFF
  BASS_TAG_WMA = 8;               // WMA
  BASS_TAG_VENDOR = 9;            // OGG, FLAC
  BASS_TAG_LYRICS = 10;           // Lyric3v2
  BASS_TAG_MUSIC_NAME = $10000;   // MO3, IT, XM, S3M, MTM, MOD, UMX
  BASS_TAG_FLAC_PICTURE = $12000; // FLAC Picture
  // NOTE: BASS_TAG_FLAC_PICTURE + index #

  { Cover MIME extensions }
  QBASS_EXT_GIF = '/gif';
  QBASS_EXT_JPG = '/jp'; // jpeg, jpg
  QBASS_EXT_PNG = '/png';
  QBASS_EXT_ICO = '/ico';
  QBASS_EXT_BMP = '/bmp';
  QBASS_EXT_WMF = '/wmf';
  QBASS_EXT_EMF = '/emf';

  { Cover Type }
  QBASS_CoverType: array [0 .. 20] of AnsiString = ('Other', '32x32 pixels '#39'file icon'#39' (PNG only)',
    'Other file icon', 'Cover (front)', 'Cover (back)', 'Leaflet page', 'Media (e.g. lable side of CD)',
    'Lead artist/lead performer/soloist', 'Artist/performer', 'Conductor', 'Band/Orchestra', 'Composer',
    'Lyricist/text writer', 'Recording Location', 'During recording', 'During performance',
    'Movie/video screen capture', 'A bright coloured fish', 'Illustration', 'Band/artist logotype',
    'Publisher/Studio logotype');

type
  // ------ picture structure -------
  QBASSPictureInfo = record
    apic: DWORD;     // ID3v2 "APIC" picture type
    mime: PAnsiChar; // mime type
    desc: PAnsiChar; // description
  end;

  // Read tags from bass and bass add-ons
function QBass_ReadTags(const Channel: DWORD; var Item: QBASSTagItem): boolean;
function QBass_ReadNetTags(const Channel: DWORD; var Item: QBASSTagItem): boolean;
function QBass_ReadCover(const Channel: DWORD; var Info: QBASSPictureInfo; var Image: TBytesStream): boolean;

implementation

type
  // -------------- FLAC ----------------
  PFLACPicture = ^FLACPicture;

  { Flac picture header data }
  FLACPicture = record
    apic: DWORD;     // ID3v2 "APIC" picture type
    mime: PAnsiChar; // mime type
    desc: PAnsiChar; // description
    width: DWORD;
    height: DWORD;
    depth: DWORD;
    colors: DWORD;
    length: DWORD; // data length
    data: Pointer;
  end;

const
  UNICODE_ID = #1;

  ID3V1_ID = 'TAG'; { ID3v1 tag ID }
  ID3V2_ID = 'ID3'; { ID3v2 tag ID }

  TAG_VERSION_2_2 = 2; { Code for ID3v2.2.x tag }
  TAG_VERSION_2_3 = 3; { Code for ID3v2.3.x tag }
  TAG_VERSION_2_4 = 4; { Code for ID3v2.4.x tag }

  MAX_MUSIC_GENRES = 148; { Max. number of music genres }
  GENRE_TABLE: array [0 .. MAX_MUSIC_GENRES - 1] of AnsiString = ('Blues', 'Classic Rock', 'Country', 'Dance', 'Disco',
    'Funk', 'Grunge', 'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B', 'Rap', 'Reggae', 'Rock',
    'Techno', 'Industrial', 'Alternative', 'Ska', 'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient',
    'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental', 'Acid', 'House', 'Game',
    'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative', 'Instrumental Pop',
    'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk', 'Eurodance',
    'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta', 'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle',
    'Native American', 'Cabaret', 'New Wave', 'Psychadelic', 'Rave', 'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal',
    'Acid Punk', 'Acid Jazz', 'Polka', 'Retro', 'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock',
    'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival', 'Celtic', 'Bluegrass', 'Avantgarde',
    'Gothic Rock', 'Progressive Rock', 'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band', 'Chorus',
    'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony',
    'Booty Bass', 'Primus', 'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba', 'Folklore', 'Ballad',
    'Power Ballad', 'Rhythmic Soul', 'Freestyle', 'Duet', 'Punk Rock', 'Drum Solo', 'A capella', 'Euro-House',
    'Dance Hall', 'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie', 'BritPop', 'Negerpunk',
    'Polsk Punk', 'Beat', 'Christian Gangsta Rap', 'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian',
    'Christian Rock', 'Merengue', 'Salsa', 'Thrash Metal', 'Anime', 'JPop', 'Synthpop');

  ID3V2_FRAME_COUNT = 11;
  WMA_FRAME_COUNT = 8;
  GEN_FRAME_COUNT = 7;

  // id3v2.2
  ID3V2_2: array [1 .. ID3V2_FRAME_COUNT] of AnsiString = ('TT2', 'TP1', 'TCO', 'TOA', 'TT1', 'TYE', 'TOR', 'COM',
    'TAL', 'TOA', '');

  // id3v2.3, id3v2.4
  ID3V2_34: array [1 .. ID3V2_FRAME_COUNT] of AnsiString = ('TIT2', 'TPE1', 'TCON', 'TOPE', 'TIT1', 'TYER', 'TDRC',
    'COMM', 'TALB', 'TOAL', 'APIC');

  // table for OGG, APE, OFR, MPC, AAC, FLAC
  GEN_NAME: array [0 .. GEN_FRAME_COUNT] of AnsiString = ('ARTIST=', 'TITLE=', 'ALBUM=', 'GENRE=', 'DATE=', 'COMMENT=',
    'LYRICS=', 'CUESHEET=');

  // wma version <= 2.3
  WMA_23: array [0 .. WMA_FRAME_COUNT] of AnsiString = ('Author:', 'Title:', 'WM/AlbumTitle:', 'WM/Genre:', 'WM/Year:',
    'Description:', 'WM/Author:', 'WM/Title:', 'WM/LYRICS:');

  // wma version >= 2.4
  WMA_24: array [0 .. WMA_FRAME_COUNT] of AnsiString = ('Author=', 'Title=', 'WM/AlbumTitle=', 'WM/Genre=', 'WM/Year=',
    'Description=', 'WM/Author=', 'WM/Title=', 'WM/LYRICS=');

  ID3files = 'MP1, MP2, MP3, AAC, MPC';
  WMAfiles = 'WMA';
  APEfiles = 'APE, MPC, MPP, MP+, OFR, OFS';
  OGGfiles = 'OGG, FLAC, FLA';
  MP4files = ' MP4, ALAC, M4A, AIFF';
  TRCfiles = 'MO3, IT, XM, S3M, MTM, MOD, UMX';
  TTAfiles = 'TTA';
  SPXfiles = 'SPX';
  WVfiles = 'WV';

  { ------------------------------------------------------------------------------ }

type
  // -------------- ID3v1 ----------------
  PTagID3 = ^TagID3;

  { ID3 header data }
  TagID3 = record
    id: array [0 .. 2] of AnsiChar;       { Always "TAG" }
    Title: array [0 .. 29] of AnsiChar;   { Title info }
    Artist: array [0 .. 29] of AnsiChar;  { Artist info }
    Album: array [0 .. 29] of AnsiChar;   { Album info }
    Year: array [0 .. 3] of AnsiChar;     { Year info }
    Comment: array [0 .. 29] of AnsiChar; { Comment info }
    Genre: Byte;                          { Genre ID }
  end;

  // -------------- ID3v2 ----------------
  { Frame header (ID3v2.3.x & ID3v2.4.x) }
  FrameHeaderNew = record
    id: array [1 .. 4] of AnsiChar; { Frame ID }
    Size: Integer;                  { Size excluding header }
    Flags: Word;                    { Flags }
  end;

  { Frame header (ID3v2.2.x) }
  FrameHeaderOld = record
    id: array [1 .. 3] of AnsiChar; { Frame ID }
    Size: array [1 .. 3] of Byte;   { Size excluding header }
  end;

  PTagID3v2 = ^TagID3v2;

  { ID3v2 header data - for internal use }
  TagID3v2 = record
    { Real structure of ID3v2 header }
    id: array [1 .. 3] of AnsiChar; { Always "ID3" }
    Version: Byte;                  { Version number }
    Revision: Byte;                 { Revision number }
    Flags: Byte;                    { Flags of tag }
    Size: array [1 .. 4] of Byte;   { Tag size excluding header }
    { Extended data }
    FileSize: Integer;                                   { File size (bytes) }
    Frame: array [1 .. ID3V2_FRAME_COUNT] of AnsiString; { Information from frames }
    NeedRewrite: boolean;                                { Tag should be rewritten }
    PaddingSize: Integer;                                { Padding size (bytes) }
  end;

  { ------------------------------------------------------------------------------ }

function IsUTF8String(const aChar: AnsiChar): boolean;
begin
  Result := (((Byte(aChar) <= $7F) or (($C2 <= Byte(aChar)) and (Byte(aChar) <= $FD))) or ($80 <= Byte(aChar)) and
    (Byte(aChar) <= $BF));
end;

{ --------------------------------------------------------------------------- }

function GetANSI(const Source: AnsiString): String;
var
  Index: Integer;
  FirstByte, SecondByte: Byte;
  UnicodeChar: WideChar;
begin
  Result := Source;
  if (length(Source) = 0) then
    exit;

  if (Source[1] = UNICODE_ID) then
  begin
    Result := '';
    for Index := 2 to ((length(Source) - 1) div 2) do
    begin
      FirstByte := Ord(Source[Index * 2]);
      SecondByte := Ord(Source[Index * 2 + 1]);
      UnicodeChar := WideChar(FirstByte or (SecondByte shl 8));
      if UnicodeChar = #0 then
        break;
      if FirstByte < $FF then
        Result := Result + UnicodeChar;
    end;
    Result := Trim(Result);
  end
  else if IsUTF8String(Source[1]) then
    Result := Trim({$IFDEF UNICODE}UTF8ToString(RawByteString(Source))){$ELSE}Utf8ToAnsi(Source)){$ENDIF};
end;

{ ------------------------------------------------------------------------------ }

function IFV(const Str1, Str2: AnsiString): String;
var
  Res: String;
begin
  Res := GetANSI(Str1);
  if (Res = '') then
    Res := GetANSI(Str2);
  Result := Res;
end;

{ ------------------------------------------------------------------------------ }

function ParseStr(var Str: AnsiString; const sBegin, sEnd: AnsiString; FindDelete: boolean = false): AnsiString;
// парсер строк
const
  endStr = '*^*';
var
  Return: AnsiString;
  x, y, e: Integer;
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
    x := AnsiPos(AnsiLowerCase(sBegin), AnsiLowerCase(Return));

  y := PosEx(AnsiLowerCase(endStr), AnsiLowerCase(Return), x);
  if y = 0 then
    y := PosEx(LowerCase(sEnd), LowerCase(Return), x);
  if (x > 0) and (y > 0) then
  begin
    x := x + length(sBegin);
    y := (y - e) - (x - e);
    Result := Trim(copy(Return, x, y));
    if FindDelete then
      Delete(Str, x, y + 1);
  end;
end;

{ ------------------------------------------------------------------------------ }
function tag_find(tag: PAnsiChar; fmt: AnsiString): AnsiString;
var
  Return: AnsiString;
  p: Integer;
begin
  Result := '';
  if Assigned(tag) then
  begin
    while true do
    begin
      if (tag^ = #0) then
        Return := Return + '^|^';
      if (tag^ <> #0) then
        Return := Return + tag^
      else if ((tag + 1)^ = #0) then
        break;
      Inc(tag);
    end;

    Result := GetANSI(ParseStr(Return, fmt, '^|^'));
  end;
end;

// .......................... REALIZATION (ID3v1) ........................... //

function DetectID3v1(struct: PAnsiChar; var Item: QBASSTagItem): boolean;
var
  tag: PTagID3 absolute struct;
begin
  Result := false;
  if Item.Cue then
    exit;
  try
    if (Assigned(tag)) then
    begin
      if (tag^.id = ID3V1_ID) then
      begin
        Result := true;
        Item.Artist := Trim(tag^.Artist);
        Item.Title := Trim(tag^.Title);
        Item.Album := Trim(tag^.Album);
        Item.Comment := Trim(tag^.Comment);
        Item.Year := Trim(tag^.Year);
        if tag^.Genre > 147 then
          tag^.Genre := 12;
        Item.Genre := GENRE_TABLE[tag^.Genre];
        tag := nil;
      end;
    end;
  except
    Result := false;
  end;
end;

// .......................... REALIZATION (ID3v2) ........................... //

function ID3GetTagSize(const tag: TagID3v2): Integer;
begin
  Result := tag.Size[1] * $200000 + tag.Size[2] * $4000 + tag.Size[3] * $80 + tag.Size[4] + 10;
  if tag.Flags and $10 = $10 then
    Inc(Result, 10);
  if Result > tag.FileSize then
    Result := 0;
end;

{ ------------------------------------------------------------------------------ }

function ID3GetFrameSize(data: PAnsiChar): Integer;
begin
  try
    Result := (Ord((data)^) shl 24) + (Ord((data + 1)^) shl 16) + (Ord((data + 2)^) shl 8) + (Ord((data + 3)^));
  except
    Result := 0;
  end;
end;

{ ------------------------------------------------------------------------------ }

function ID3FindFrame(data: PAnsiChar; FrameName: String; var tag: TagID3v2): PAnsiChar;
var
  DataTemp: PAnsiChar;
  tagsize, cnt, len: Integer;
begin
  Result := nil;
  try
    len := length(FrameName);
    DataTemp := data;
    cnt := 1;

    tagsize := ID3GetTagSize(tag) + 1;
    while tagsize <> cnt do
    begin
      if copy(DataTemp, cnt, len) = FrameName then
      begin
        Inc(DataTemp, len);
        Result := DataTemp;
        break;
      end;
      Inc(cnt);
      Inc(DataTemp);
    end;
    DataTemp := nil;
  except
    Result := nil;
  end;
end;

{ ------------------------------------------------------------------------------ }

function frame_reader(data: PAnsiChar; fmt: String; var tag: TagID3v2): AnsiString;
var
  temp: PAnsiChar;
  siz: Integer;
begin
  Result := '';
  temp := ID3FindFrame(data, fmt, tag);
  if temp <> nil then
  begin
    siz := ID3GetFrameSize(temp);
    Inc(temp, 6);
    Move(temp^, Result[1], siz);
    Result := GetANSI(Result);
    temp := nil;
  end;
end;

{ ------------------------------------------------------------------------------ }

function genre_reader(data: PAnsiChar; fmt: String; var tag: TagID3v2): AnsiString;
begin
  Result := frame_reader(data, fmt, tag);
  if Pos(')', Result) > 0 then
    Delete(Result, 1, LastDelimiter(')', Result));
end;

{ ------------------------------------------------------------------------------ }

function year_reader(data: PAnsiChar; var tag: TagID3v2): AnsiString;
begin
  Result := Trim(frame_reader(data, ID3V2_34[6], tag));
  if Result = '' then
  begin
    Result := Trim(frame_reader(data, ID3V2_34[7], tag));
    Result := copy(Result, 1, 4);
  end;
end;

{ ------------------------------------------------------------------------------ }

function comment_reader(data: PAnsiChar; fmt: String; var tag: TagID3v2): AnsiString;
var
  temp: PAnsiChar;
  siz, I: Integer;
  enc: AnsiChar;
  src: AnsiString;
begin
  Result := '';
  temp := ID3FindFrame(data, fmt, tag);
  if temp <> nil then
  begin
    siz := ID3GetFrameSize(temp);
    Inc(temp, 4);

    src := temp;
    enc := AnsiChar(src[1]);
    Result := GetANSI(enc + src);
    temp := nil;
  end;
end;

{ ------------------------------------------------------------------------------ }

function DetectID3v2(struct: PAnsiChar; var Item: QBASSTagItem): boolean;
var
  tag: TagID3v2;
  data: PAnsiChar absolute struct;
begin
  Result := false;
  if Item.Cue then
    exit;

  try
    FillChar(tag, SizeOf(tag), 0);
    Move(Pointer(struct)^, tag, 10);

    if (tag.id = ID3V2_ID) then
    begin
      if FileExists(Item.FileName) then
      begin
        with TFileStream.Create(Item.FileName, fmOpenRead or fmShareDenyWrite) do
        begin
          tag.FileSize := Size;
          Free;
        end;
      end
      else
        tag.FileSize := ID3GetTagSize(tag) + 1; // fake! for net streams

      if tag.Version >= TAG_VERSION_2_3 then
      begin
        Result := true;
        Item.Artist := IFV(frame_reader(data, ID3V2_34[2], tag), frame_reader(data, ID3V2_34[4], tag));
        Item.Title := IFV(frame_reader(data, ID3V2_34[1], tag), frame_reader(data, ID3V2_34[5], tag));
        Item.Album := IFV(frame_reader(data, ID3V2_34[9], tag), frame_reader(data, ID3V2_34[10], tag));
        Item.Comment := comment_reader(data, ID3V2_34[8], tag);
        Item.Year := year_reader(data, tag);
        Item.Genre := genre_reader(data, ID3V2_34[3], tag);
      end;
    end;
    data := nil;
  except
    Result := false;
  end;
end;

// ......................... REALIZATION (COVER) ............................ //

function IsCoverFrame(data: PAnsiChar): boolean;
begin
  Result := false;
  try
    if data <> nil then
      Result := (data)^ + (data + 1)^ + (data + 2)^ + (data + 3)^ = Utf8ToAnsi(ID3V2_34[11]);
  except
    Result := false;
  end;
end;

{ ------------------------------------------------------------------------------ }

function FindCoverFrame(data: PAnsiChar): PAnsiChar;
var
  tag: PTagID3v2 absolute data;
  DataTemp: PAnsiChar;
  tagsize: Integer;
  cnt: Integer;
begin
  Result := nil;
  cnt := 0;
  DataTemp := data;
  try
    tagsize := ID3GetTagSize(tag^) + 1;
    if tagsize > 0 then
    begin
      while tagsize <> cnt do
      begin
        if IsCoverFrame(DataTemp) then
        begin
          Inc(DataTemp, 4);
          Result := DataTemp;
          break;
        end;
        Inc(cnt);
        Inc(DataTemp);
      end;
    end;
    tag := nil;
    DataTemp := nil;
  except
    Result := nil;
    tag := nil;
    DataTemp := nil;
  end;
end;

{ ------------------------------------------------------------------------------ }

function DetectID3V2Cover(struct: Pointer; var Info: QBASSPictureInfo; var Image: TBytesStream): boolean;
var
  id3: TagID3v2;
  temp: PAnsiChar;
  FrameSize, Count, I: Integer;
  enc: AnsiChar;
  buf: Byte;
begin
  Result := false;
  try
    if Assigned(struct) then
    begin
      FillChar(id3, SizeOf(id3), 0);
      Move(Pointer(struct)^, id3, 10);

      if (id3.id = ID3V2_ID) then
      begin
        temp := FindCoverFrame(struct);

        if temp <> nil then
        begin
          Count := 0;
          FrameSize := ID3GetFrameSize(temp);
          if FrameSize <= 0 then
            exit;

          Result := true;

          Inc(temp, 6);
          enc := AnsiChar(temp^); // encoding
          Inc(temp);
          Count := 7;

          while (temp^ <> #00) do
          begin
            Info.mime := PAnsiChar(Info.mime + temp^);
            Inc(Count);
            Inc(temp);
          end;

          Inc(temp);
          Info.apic := Byte(temp^);
          Inc(temp);
          Inc(Count, 2);

          I := 1;
          while I < 65 do
          begin
            if enc = UNICODE_ID then
            begin
              if (temp^ = #00) and ((temp + 1)^ = #00) then
                break;
            end
            else if (temp^ = #00) then
              break;

            Info.desc := PAnsiChar(Info.desc + temp^);
            Inc(I);
            Inc(Count);
            Inc(temp);
          end;
          Inc(temp);
          dec(Count, 4);

          while (Count <= FrameSize) do
          begin
            buf := Byte(temp^);
            Image.WriteBuffer(buf, 1);
            Inc(Count);
            Inc(temp);
          end;
          Image.Position := 0;
        end;
      end;
    end;
    FillChar(id3, SizeOf(id3), 0);
  except
    Result := false;
  end;
end;

function DetectFLACCover(struct: PAnsiChar; var Info: QBASSPictureInfo; var Image: TBytesStream): boolean;
var
  flac: PFLACPicture absolute struct;
  buf: PAnsiChar;
begin
  Result := false;
  try
    if Assigned(struct) then
    begin
      Result := true;

      Info.apic := flac^.apic;
      Info.mime := flac^.mime;
      Info.desc := flac^.desc;
      buf := Pointer(flac^.data);

      Image.WriteBuffer(buf[0], flac^.length);
      Image.Position := 0;
      buf := nil;
    end;
    flac := nil;
  except
    Result := false;
  end;
end;

// ........................ REALIZATION (LYRICS 3) .......................... //

function DetectLyrics3(struct: AnsiString; var Item: QBASSTagItem): boolean;
const
  lyr_beg = 'LYRICSBEGININD0000210LYR000';
  lyr_end = 17;
var
  Str: AnsiString;
begin
  Result := false;
  if Item.Cue then
    exit;
  try
    if Assigned(Pointer(struct)) then
    begin
      Result := true;
      Str := ParseStr(struct, lyr_beg, '');
      Item.Lyrics := copy(Str, 3, length(Str) - lyr_end);
    end;
  except
    Result := false;
  end;
end;

// ............. REALIZATION (MO3, IT, XM, S3M, MTM, MOD, UMX) .............. //

function DetectTitle(struct: AnsiString; var Item: QBASSTagItem): boolean;
begin
  Result := false;
  if Item.Cue then
    exit;
  try
    if Assigned(Pointer(struct)) then
    begin
      Result := true;
      Item.Title := struct;
    end;
  except
    Result := false;
  end;
end;

// .............. REALIZATION (OGG, FLAC, APE, OFR, MPC, AAC) ............... //

function DetectGeneral(struct: PAnsiChar; var Item: QBASSTagItem): boolean;
begin
  Result := false;
  try
    if Assigned(struct) then
    begin
      Result := true;
      Item.Artist := tag_find(struct, GEN_NAME[0]);
      Item.Title := tag_find(struct, GEN_NAME[1]);
      Item.Album := tag_find(struct, GEN_NAME[2]);
      Item.Genre := tag_find(struct, GEN_NAME[3]);
      Item.Year := tag_find(struct, GEN_NAME[4]);
      Item.Comment := tag_find(struct, GEN_NAME[5]);
      Item.Lyrics := tag_find(struct, GEN_NAME[6]);
      Item.CueSheet := tag_find(struct, GEN_NAME[7]);
      Item.Cue := Item.CueSheet <> '';
    end;
  except
    Result := false;
  end;
end;

// .......................... REALIZATION (WMA) ............................. //

function DetectWMA(struct: PAnsiChar; var Item: QBASSTagItem): boolean;
var
  t, a: AnsiString;
begin
  Result := false;
  if Item.Cue then
    exit;
  try
    if Assigned(struct) then
    begin
      Result := true;
      a := IFV(tag_find(struct, WMA_23[0]), tag_find(struct, WMA_23[6]));
      if a = '' then
        a := IFV(tag_find(struct, WMA_24[0]), tag_find(struct, WMA_24[6]));
      Item.Artist := a;
      t := IFV(tag_find(struct, WMA_23[1]), tag_find(struct, WMA_23[7]));
      if t = '' then
        t := IFV(tag_find(struct, WMA_24[1]), tag_find(struct, WMA_24[7]));
      Item.Title := t;
      Item.Album := IFV(tag_find(struct, WMA_23[2]), tag_find(struct, WMA_24[2]));
      Item.Genre := IFV(tag_find(struct, WMA_23[3]), tag_find(struct, WMA_24[3]));
      Item.Year := IFV(tag_find(struct, WMA_23[4]), tag_find(struct, WMA_24[4]));
      Item.Comment := IFV(tag_find(struct, WMA_23[5]), tag_find(struct, WMA_24[5]));
      Item.Lyrics := IFV(tag_find(struct, WMA_23[8]), tag_find(struct, WMA_24[8]));
    end;
  except
    Result := false;
  end;
end;

// ........................... REALIZATION (ICY) ............................ //

function DetectICY(struct: PAnsiChar; var Item: QBASSTagItem): boolean;
var
  s: string;
begin
  Result := false;
  if Assigned(struct) then
  begin
    Result := true;

    while struct^ <> #0 do
    begin
      try
        s := String(struct);

        if copy(s, 1, 9) = 'icy-name:' then
          Item.Title := copy(s, 10, MaxInt)
        else if copy(s, 1, 10) = 'icy-genre:' then
          Item.Genre := copy(s, 11, MaxInt)
        else if copy(s, 1, 8) = 'icy-url:' then
          Item.FileName := copy(s, 9, MaxInt)
        else if copy(s, 1, 7) = 'icy-br:' then
          Item.Comment := copy(s, 8, MaxInt);

        Inc(struct, length(struct) + 1);
      except
      end;
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }

function QBass_ReadNetTags(const Channel: DWORD; var Item: QBASSTagItem): boolean;
begin
  Result := false;
  if not InitDLL then
    exit;

  if Channel > 0 then
  begin
    if UpperCase(Item.Ext) = 'MP3' then
    begin
      Result := DetectID3v2(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2), Item);
      if not Result then
        Result := DetectID3v1(BASS_ChannelGetTags(Channel, BASS_TAG_ID3), Item);
    end
    else if UpperCase(Item.Ext) = 'OGG' then
      Result := DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_OGG), Item)
    else if UpperCase(Item.Ext) = 'WMA' then
      Result := DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_WMA), Item)
    else
    begin
      Result := DetectICY(BASS_ChannelGetTags(Channel, BASS_TAG_ICY), Item);
      if not Result then
        Result := DetectICY(BASS_ChannelGetTags(Channel, BASS_TAG_HTTP), Item);
    end;
  end;
  Item.Ext := 'URL';
end;

function QBass_ReadTags(const Channel: DWORD; var Item: QBASSTagItem): boolean;
begin
  Result := false;
  if not InitDLL then
    exit;

  if Channel > 0 then
  begin
    Result := true;
    if Pos(UpperCase(Item.Ext), ID3files) > 0 then
    begin
      if not DetectID3v2(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2), Item) then
        DetectID3v1(BASS_ChannelGetTags(Channel, BASS_TAG_ID3), Item);
    end
    else if Pos(UpperCase(Item.Ext), WMAfiles) > 0 then
      DetectWMA(BASS_ChannelGetTags(Channel, BASS_TAG_WMA), Item)
    else if Pos(UpperCase(Item.Ext), APEfiles) > 0 then
      DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_APE), Item)
    else if Pos(UpperCase(Item.Ext), OGGfiles) > 0 then
    begin
      if not DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_OGG), Item) then
        DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_VENDOR), Item);
    end
    else if Pos(UpperCase(Item.Ext), MP4files) > 0 then
      DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_MP4), Item)
    else if Pos(UpperCase(Item.Ext), TRCfiles) > 0 then
      DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_MUSIC_NAME), Item)
    else if Pos(UpperCase(Item.Ext), SPXfiles) > 0 then
    begin
      if not DetectID3v2(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2), Item) then
        if not DetectID3v1(BASS_ChannelGetTags(Channel, BASS_TAG_ID3), Item) then
          if not DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_APE), Item) then
            DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_OGG), Item);
    end
    else if Pos(UpperCase(Item.Ext), WVfiles) > 0 then
    begin
      if not DetectID3v2(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2), Item) then
        if not DetectID3v1(BASS_ChannelGetTags(Channel, BASS_TAG_ID3), Item) then
          DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_APE), Item);
    end
    else if Pos(UpperCase(Item.Ext), TTAfiles) > 0 then
    begin
      if not DetectID3v2(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2), Item) then
        if not DetectID3v1(BASS_ChannelGetTags(Channel, BASS_TAG_ID3), Item) then
          DetectGeneral(BASS_ChannelGetTags(Channel, BASS_TAG_APE), Item);
    end
    else
      Result := false;
  end;
end;

function QBass_ReadCover(const Channel: DWORD; var Info: QBASSPictureInfo; var Image: TBytesStream): boolean;
begin
  Result := false;
  if not InitDLL then
    exit;

  if Channel > 0 then
  begin
    Result := DetectID3V2Cover(Pointer(BASS_ChannelGetTags(Channel, BASS_TAG_ID3V2)), Info, Image);
    if not Result then
      Result := DetectFLACCover(BASS_ChannelGetTags(Channel, BASS_TAG_FLAC_PICTURE), Info, Image);
  end;
end;

end.
