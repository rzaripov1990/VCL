// ********************************************************************************************************************************
// *                                                                                                                              *
// *     ID3v1 Library 2.0.17.39 © 3delite 2010-2013                                                                              *
// *     See ID3v2 Library 2.0 ReadMe.txt for details                                                                             *
// *                                                                                                                              *
// * Two licenses are available for commercial usage of this component:                                                           *
// * Shareware License: 50 Euros                                                                                                  *
// * Commercial License: 250 Euros                                                                                                *
// *                                                                                                                              *
// *     http://www.shareit.com/product.html?productid=300294127                                                                  *
// *                                                                                                                              *
// * Using the component in free programs is free.                                                                                *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/id3v2library.html                                          *
// *                                                                                                                              *
// * There is also an APEv2 Library available at:                                                                                 *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/APEv2Library.html                                          *
// *                                                                                                                              *
// * and also an MP4 Tag Library available at:                                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/MP4TagLibrary.html                                         *
// *                                                                                                                              *
// * and also an Ogg Vorbis and Opus Tag Library available at:                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/OpusTagLibrary.html                                        *
// *                                                                                                                              *
// * and also a Flac Tag Library available at:                                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/FlacTagLibrary.html                                        *
// *                                                                                                                              *
// * and also a WMA Tag Library available at:                                                                                     *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/WMATagLibrary.html                                        *
// *                                                                                                                              *
// * For other Delphi components see the home page:                                                                               *
// *                                                                                                                              *
// *     http://www.3delite.hu/                                                                                                   *
// *                                                                                                                              *
// * If you have any questions or enquiries please mail: 3delite@3delite.hu                                                       *
// *                                                                                                                              *
// * Good coding! :)                                                                                                              *
// * 3delite                                                                                                                      *
// ********************************************************************************************************************************

unit ID3v1Library;

{$Optimization Off}

interface

Uses
  Classes;

const
  ID3V1TAGSIZE = 128;

const
  ID3V1TAGID: AnsiString = 'TAG';
  ID3LYRICSTAGIDSTART: AnsiString = 'LYRICSBEGIN';
  ID3LYRICSTAGIDEND: AnsiString = 'LYRICS200';

const
  ID3V1LIBRARY_SUCCESS = 0;
  ID3V1LIBRARY_ERROR = $FFFF;
  ID3V1LIBRARY_ERROR_OPENING_FILE = 3;
  ID3V1LIBRARY_ERROR_READING_FILE = 4;
  ID3V1LIBRARY_ERROR_WRITING_FILE = 5;

type
  TID3v1TagData = packed record
    Identifier: Array [0 .. 2] of AnsiChar;
    Title: Array [0 .. 29] of AnsiChar;
    Artist: Array [0 .. 29] of AnsiChar;
    Album: Array [0 .. 29] of AnsiChar;
    Year: Array [0 .. 3] of AnsiChar;
    Comment: Array [0 .. 29] of AnsiChar;
    Genre: Byte;
  end;

type
  TID3LyricsTagIDStart = Array [1 .. 11] of AnsiChar;
  TID3LyricsTagIDEnd = Array [1 .. 9] of AnsiChar;
  TID3LyricsTagSize = Array [1 .. 6] of AnsiChar;
  TID3LyricsFieldSize = Array [1 .. 5] of AnsiChar;

const
  ID3Genres: Array [0 .. 147] of PAnsiChar = (
    { The following genres are defined in ID3v1 }
    'Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge', 'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies',
    'Other', { <= 12 Default }
    'Pop', 'R&B', 'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska', 'Death Metal', 'Pranks', 'Soundtrack',
    'Euro-Techno', 'Ambient', 'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental', 'Acid', 'House',
    'Game', 'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative', 'Instrumental Pop',
    'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk', 'Eurodance', 'Dream',
    'Southern Rock', 'Comedy', 'Cult', 'Gangsta', 'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American', 'Cabaret',
    'New Wave', 'Psychedelic', // = 'Psychadelic' in ID3 docs, 'Psychedelic' in winamp.
    'Rave', 'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro', 'Musical', 'Rock & Roll',
    'Hard Rock',
    { The following genres are Winamp extensions }
    'Folk', 'Folk-Rock', 'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival', 'Celtic', 'Bluegrass',
    'Avantgarde', 'Gothic Rock', 'Progressive Rock', 'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band', 'Chorus',
    'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass',
    'Primus', 'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba', 'Folklore', 'Ballad', 'Power Ballad',
    'Rhythmic Soul', 'Freestyle', 'Duet', 'Punk Rock', 'Drum Solo', 'A capella', // A Capella
    'Euro-House', 'Dance Hall',
    { winamp ?? genres }
    'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie', 'BritPop', 'Negerpunk', 'Polsk Punk', 'Beat',
    'Christian Gangsta Rap', 'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian', 'Christian Rock',
    { winamp 1.91 genres }
    'Merengue', 'Salsa', 'Trash Metal',
    { winamp 1.92 genres }
    'Anime', 'JPop', 'SynthPop');

type
  TID3LyricsFrameID = Array [0 .. 2] of AnsiChar;

type
  TID3LyricsFrame = class
    ID: TID3LyricsFrameID;
    Data: AnsiString;
  end;

type
  TID3v1Tag = class
  private
  public
    FileName: String;
    Loaded: Boolean;
    Revision1: Boolean;
    Title: AnsiString;
    Artist: AnsiString;
    Album: AnsiString;
    Year: AnsiString;
    Comment: AnsiString;
    Track: Byte;
    Genre: AnsiString;
    LyricsFrames: Array of TID3LyricsFrame;
    LyricsHasTimeStamp: Boolean;
    InhibitTracksForRandomSelection: Boolean;
    Constructor Create;
    Destructor Destroy; override;
    function LoadFromFile(FileName: String): Integer;
    function LoadFromStream(TagStream: TStream): Integer;
    function SaveToFile(FileName: String; WriteLyricsTag: Boolean = False): Integer;
    function SaveToStream(var TagStream: TStream): Integer;
    function LoadLyricsTag(TagStream: TStream): Integer;
    function LyricsTagSaveToStream(TagStream: TStream): Integer;
    procedure Clear;
    function AddLyricsFrame(ID: TID3LyricsFrameID): TID3LyricsFrame;
    function DeleteLyricsFrame(Index: Integer): Boolean;
    function GetLyrics: AnsiString;
    procedure SetLyrics(Text: AnsiString);
    function FindLyricsFrame(ID: TID3LyricsFrameID): TID3LyricsFrame;
  published
    property Lyrics: AnsiString read GetLyrics write SetLyrics;
  end;

function Min(const B1, B2: Integer): Integer;

procedure AnsiStringToPAnsiChar(const Source: AnsiString; Dest: PAnsiChar; const MaxLength: Integer);
function PAnsiCharToAnsiString(P: PAnsiChar; MaxLength: Integer): AnsiString;

function ID3GenreDataToString(GenreIndex: Byte): AnsiString;
function ID3GenreStringToData(Genre: AnsiString): Byte;

function ID3v1RemoveTag(FileName: String): Integer;

implementation

Uses
  SysUtils;

function Min(const B1, B2: Integer): Integer;
begin
  if B1 < B2 then
  begin
    Result := B1
  end
  else
  begin
    Result := B2;
  end;
end;

procedure AnsiStringToPAnsiChar(const Source: AnsiString; Dest: PAnsiChar; const MaxLength: Integer);
begin
  Move(PAnsiChar(Source)^, Dest^, Min(MaxLength, Length(Source)));
end;

function PAnsiCharToAnsiString(P: PAnsiChar; MaxLength: Integer): AnsiString;
var
  Q: PAnsiChar;
begin
  Q := P;
  while (P - Q < MaxLength) AND (P^ <> #0) do
  begin
    Inc(P);
  end;
  { [Q..P) is valid }
  SetString(Result, Q, P - Q);
end;

Constructor TID3v1Tag.Create;
begin
  Inherited;
  Clear;
end;

function TID3v1Tag.DeleteLyricsFrame(Index: Integer): Boolean;
var
  i: Integer;
  l: Integer;
  j: Integer;
begin
  Result := False;
  if (Index >= Length(LyricsFrames)) OR (Index < 0) then
  begin
    Exit;
  end;
  FreeAndNil(LyricsFrames[Index]);
  i := 0;
  j := 0;
  while i <= Length(LyricsFrames) - 1 do
  begin
    if LyricsFrames[i] <> nil then
    begin
      LyricsFrames[j] := LyricsFrames[i];
      Inc(j);
    end;
    Inc(i);
  end;
  SetLength(LyricsFrames, j);
  Result := True;
end;

Destructor TID3v1Tag.Destroy;
begin
  Inherited;
end;

function TID3v1Tag.FindLyricsFrame(ID: TID3LyricsFrameID): TID3LyricsFrame;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Length(LyricsFrames) - 1 do
  begin
    if LyricsFrames[i].ID = ID then
    begin
      Result := LyricsFrames[i];
      Exit;
    end;
  end;
end;

function TID3v1Tag.AddLyricsFrame(ID: TID3LyricsFrameID): TID3LyricsFrame;
begin
  Result := nil;
  try
    SetLength(LyricsFrames, Length(LyricsFrames) + 1);
    LyricsFrames[Length(LyricsFrames) - 1] := TID3LyricsFrame.Create;
    LyricsFrames[Length(LyricsFrames) - 1].ID := ID;
    Result := LyricsFrames[Length(LyricsFrames) - 1];
  except
    // *
  end;
end;

procedure TID3v1Tag.Clear;
var
  i: Integer;
begin
  FileName := '';
  Loaded := False;
  Revision1 := False;
  Title := '';
  Artist := '';
  Album := '';
  Year := '';
  Comment := '';
  Genre := '';
  for i := Length(LyricsFrames) - 1 downto 0 do
  begin
    FreeAndNil(LyricsFrames[i]);
  end;
  SetLength(LyricsFrames, 0);
end;

function TID3v1Tag.LoadFromFile(FileName: String): Integer;
var
  FileStream: TFileStream;
begin
  Result := ID3V1LIBRARY_ERROR;
  Clear;
  Loaded := False;
  if NOT FileExists(FileName) then
  begin
    Result := ID3V1LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  FileStream := TFileStream.Create(FileName, fmOpenRead OR fmShareDenyWrite);
  try
    FileStream.Seek(-ID3V1TAGSIZE, soEnd);
    Result := LoadFromStream(FileStream);
    if Result = ID3V1LIBRARY_SUCCESS then
    begin
      Self.FileName := FileName;
    end;
    LoadLyricsTag(FileStream);
  finally
    FreeAndNil(FileStream);
  end;
end;

function TID3v1Tag.LoadFromStream(TagStream: TStream): Integer;
var
  TagData: TID3v1TagData;
begin
  Result := ID3V1LIBRARY_ERROR;
  Loaded := False;
  FillChar(TagData, SizeOf(TID3v1TagData), #0);
  try
    TagStream.Read(TagData, ID3V1TAGSIZE);
    if TagData.Identifier <> ID3V1TAGID then
    begin
      Exit;
    end;
    Title := PAnsiCharToAnsiString(@TagData.Title, 30);
    Artist := PAnsiCharToAnsiString(@TagData.Artist, 30);
    Album := PAnsiCharToAnsiString(@TagData.Album, 30);
    Year := PAnsiCharToAnsiString(@TagData.Year, 4);
    Comment := PAnsiCharToAnsiString(@TagData.Comment, 30);
    Genre := ID3GenreDataToString(TagData.Genre);
    if TagData.Comment[28] = #0 then
    begin
      Track := Byte(TagData.Comment[29]);
      Revision1 := True;
    end
    else
    begin
      Track := 0;
      Revision1 := False;
    end;
    Loaded := True;
    Result := ID3V1LIBRARY_SUCCESS;
  except
    Clear;
    Result := ID3V1LIBRARY_ERROR_READING_FILE;
  end;
end;

function TID3v1Tag.LoadLyricsTag(TagStream: TStream): Integer;
var
  LyricsTagIDStart: TID3LyricsTagIDStart;
  LyricsTagIDEnd: TID3LyricsTagIDEnd;
  LyricsTagSize: TID3LyricsTagSize;
  TagSize: Cardinal;
  FieldID: TID3LyricsFrameID;
  LyricsFieldSize: TID3LyricsFieldSize;
  FieldSize: Cardinal;
  LyricsFrame: TID3LyricsFrame;
  i: Integer;
  Data: Byte;
begin
  Result := ID3V1LIBRARY_ERROR;
  TagStream.Seek(-(128 + 9), soFromEnd);
  TagStream.Read(LyricsTagIDEnd, SizeOf(TID3LyricsTagIDEnd));
  if LyricsTagIDEnd = ID3LYRICSTAGIDEND then
  begin
    TagStream.Seek(-(128 + 9 + 6), soFromEnd);
    TagStream.Read(LyricsTagSize, SizeOf(TID3LyricsTagSize));
    TagSize := StrToInt(LyricsTagSize);
    TagStream.Seek(-(128 + 9 + 6 + TagSize), soFromEnd);
    TagStream.Read(LyricsTagIDStart, SizeOf(TID3LyricsTagIDStart));
    if LyricsTagIDStart = ID3LYRICSTAGIDSTART then
    begin
      repeat
        TagStream.Read(FieldID, SizeOf(TID3LyricsFrameID));
        TagStream.Read(LyricsFieldSize, SizeOf(TID3LyricsFieldSize));
        FieldSize := StrToInt(LyricsFieldSize);
        LyricsFrame := AddLyricsFrame(FieldID);
        for i := 0 to FieldSize - 1 do
        begin
          TagStream.Read(Data, 1);
          LyricsFrame.Data := LyricsFrame.Data + AnsiChar(Data);
        end;
        if FieldID = 'IND' then
        begin
          LyricsHasTimeStamp := Copy(LyricsFrame.Data, 2, 1) = '1';
          InhibitTracksForRandomSelection := Copy(LyricsFrame.Data, 3, 1) = '1';
        end;
        if FieldID = 'EAL' then
        begin
          if Pos(Album, LyricsFrame.Data) > 0 then
          begin
            Album := LyricsFrame.Data;
          end;
        end;
        if FieldID = 'EAR' then
        begin
          if Pos(Artist, LyricsFrame.Data) > 0 then
          begin
            Artist := LyricsFrame.Data;
          end;
        end;
        if FieldID = 'ETT' then
        begin
          if Pos(Title, LyricsFrame.Data) > 0 then
          begin
            Title := LyricsFrame.Data;
          end;
        end;
        Result := ID3V1LIBRARY_SUCCESS;
      until TagStream.Position >= TagStream.Size - (128 + 9 + 6);
    end;
  end;
end;

function TID3v1Tag.LyricsTagSaveToStream(TagStream: TStream): Integer;

  function NumberToFieldSize(Value: Cardinal): TID3LyricsFieldSize;
  var
    Text: AnsiString;
  begin
    Text := IntToStr(Value);
    while Length(Text) < 5 do
    begin
      Text := '0' + Text;
    end;
    AnsiStringToPAnsiChar(Text, @Result, 5);
  end;

  function NumberToTagSize(Value: Cardinal): TID3LyricsTagSize;
  var
    Text: AnsiString;
  begin
    Text := IntToStr(Value);
    while Length(Text) < 6 do
    begin
      Text := '0' + Text;
    end;
    AnsiStringToPAnsiChar(Text, @Result, 6);
  end;

var
  LyricsTagIDStart: TID3LyricsTagIDStart;
  LyricsTagIDEnd: TID3LyricsTagIDEnd;
  LyricsTagSize: TID3LyricsTagSize;
  TagSize: Cardinal;
  FieldID: TID3LyricsFrameID;
  LyricsFieldSize: TID3LyricsFieldSize;
  FieldSize: Cardinal;
  LyricsFrame: TID3LyricsFrame;
  i: Integer;
  Data: Byte;
  INDFieldID: Array [1 .. 8] of AnsiChar;
begin
  Result := ID3V1LIBRARY_ERROR;
  TagStream.Seek(-9, soFromEnd);
  TagStream.Read(LyricsTagIDEnd, SizeOf(TID3LyricsTagIDEnd));
  if LyricsTagIDEnd = ID3LYRICSTAGIDEND then
  begin
    TagStream.Seek(-(9 + 6), soFromEnd);
    TagStream.Read(LyricsTagSize, SizeOf(TID3LyricsTagSize));
    TagSize := StrToInt(LyricsTagSize);
    TagStream.Seek(-(9 + 6 + TagSize), soFromEnd);
    TagStream.Read(LyricsTagIDStart, SizeOf(TID3LyricsTagIDStart));
    if LyricsTagIDStart = ID3LYRICSTAGIDSTART then
    begin
      TagStream.Size := TagStream.Position - SizeOf(TID3LyricsTagIDStart);
    end;
  end;
  TagStream.Seek(0, soFromEnd);
  TagSize := 0;
  AnsiStringToPAnsiChar(ID3LYRICSTAGIDSTART, @LyricsTagIDStart, Length(ID3LYRICSTAGIDSTART));
  TagSize := TagSize + TagStream.Write(LyricsTagIDStart, Length(LyricsTagIDStart));
  INDFieldID := 'IND00003';
  TagSize := TagSize + TagStream.Write(INDFieldID, 8);
  if FindLyricsFrame('LYR') <> nil then
  begin
    Data := Ord('1');
  end
  else
  begin
    Data := Ord('0');
  end;
  TagSize := TagSize + TagStream.Write(Data, 1);
  if LyricsHasTimeStamp then
  begin
    Data := Ord('1');
  end
  else
  begin
    Data := Ord('0');
  end;
  TagSize := TagSize + TagStream.Write(Data, 1);
  if InhibitTracksForRandomSelection then
  begin
    Data := Ord('1');
  end
  else
  begin
    Data := Ord('0');
  end;
  TagSize := TagSize + TagStream.Write(Data, 1);
  for i := 0 to Length(LyricsFrames) - 1 do
  begin
    if Length(LyricsFrames[i].Data) = 0 then
    begin
      Continue;
    end;
    if LyricsFrames[i].ID = 'IND' then
    begin
      Continue;
    end;
    TagSize := TagSize + TagStream.Write(LyricsFrames[i].ID, 3);
    if LyricsFrames[i].ID = 'EAL' then
    begin
      LyricsFieldSize := NumberToFieldSize(Length(Album));
      TagSize := TagSize + TagStream.Write(LyricsFieldSize, 5);
      TagSize := TagSize + TagStream.Write(Pointer(Album)^, Length(Album));
      Continue;
    end;
    if LyricsFrames[i].ID = 'EAR' then
    begin
      LyricsFieldSize := NumberToFieldSize(Length(Artist));
      TagSize := TagSize + TagStream.Write(LyricsFieldSize, 5);
      TagSize := TagSize + TagStream.Write(Pointer(Artist)^, Length(Artist));
      Continue;
    end;
    if LyricsFrames[i].ID = 'ETT' then
    begin
      LyricsFieldSize := NumberToFieldSize(Length(Title));
      TagSize := TagSize + TagStream.Write(LyricsFieldSize, 5);
      TagSize := TagSize + TagStream.Write(Pointer(Title)^, Length(Title));
      Continue;
    end;
    LyricsFieldSize := NumberToFieldSize(Length(LyricsFrames[i].Data));
    TagSize := TagSize + TagStream.Write(LyricsFieldSize, 5);
    TagSize := TagSize + TagStream.Write(Pointer(LyricsFrames[i].Data)^, Length(LyricsFrames[i].Data));
  end;
  LyricsTagSize := NumberToTagSize(TagSize);
  TagStream.Write(LyricsTagSize, 6);
  AnsiStringToPAnsiChar(ID3LYRICSTAGIDEND, @LyricsTagIDEnd, Length(ID3LYRICSTAGIDEND));
  TagStream.Write(LyricsTagIDEnd, Length(LyricsTagIDEnd));
  Result := ID3V1LIBRARY_SUCCESS;
end;

function TID3v1Tag.GetLyrics: AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(LyricsFrames) - 1 do
  begin
    if LyricsFrames[i].ID = 'LYR' then
    begin
      Result := LyricsFrames[i].Data;
    end;
  end;
end;

procedure TID3v1Tag.SetLyrics(Text: AnsiString);
var
  i: Integer;
begin
  for i := 0 to Length(LyricsFrames) - 1 do
  begin
    if LyricsFrames[i].ID = 'LYR' then
    begin
      if Text <> '' then
      begin
        LyricsFrames[i].Data := Text;
      end
      else
      begin
        DeleteLyricsFrame(i);
      end;
      Exit;
    end;
  end;
  if Text <> '' then
  begin
    AddLyricsFrame('LYR').Data := Text;
  end;
end;

function TID3v1Tag.SaveToFile(FileName: String; WriteLyricsTag: Boolean = False): Integer;
var
  FileStream: TStream;
begin
  Result := ID3V1LIBRARY_ERROR;
  try
    if WriteLyricsTag then
    begin
      ID3v1RemoveTag(FileName);
    end;
    if FileExists(FileName) then
    begin
      FileStream := TFileStream.Create(FileName, fmOpenReadWrite OR fmShareDenyWrite);
    end
    else
    begin
      FileStream := TFileStream.Create(FileName, fmCreate OR fmShareDenyWrite);
    end;
  except
    Result := ID3V1LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    if WriteLyricsTag then
    begin
      LyricsTagSaveToStream(FileStream);
    end;
    FileStream.Seek(-ID3V1TAGSIZE, soEnd);
    Result := SaveToStream(FileStream);
    if Result = ID3V1LIBRARY_SUCCESS then
    begin
      Self.FileName := FileName;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

function TID3v1Tag.SaveToStream(var TagStream: TStream): Integer;
var
  TagData: TID3v1TagData;
begin
  Result := ID3V1LIBRARY_ERROR;
  FillChar(TagData, SizeOf(TID3v1TagData), #0);
  try
    TagStream.Read(TagData, ID3V1TAGSIZE);
  except
    Result := ID3V1LIBRARY_ERROR_READING_FILE;
    Exit;
  end;
  try
    if TagData.Identifier = ID3V1TAGID then
    begin
      TagStream.Seek(-ID3V1TAGSIZE, soCurrent);
    end
    else
    begin
      TagStream.Seek(0, soEnd);
    end;
    FillChar(TagData, SizeOf(TID3v1TagData), #0);
    Move(Pointer(ID3V1TAGID)^, TagData.Identifier[0], 3);
    AnsiStringToPAnsiChar(Title, @TagData.Title, 30);
    AnsiStringToPAnsiChar(Artist, @TagData.Artist, 30);
    AnsiStringToPAnsiChar(Album, @TagData.Album, 30);
    AnsiStringToPAnsiChar(Year, @TagData.Year, 4);
    AnsiStringToPAnsiChar(Comment, @TagData.Comment, 30);
    TagData.Genre := ID3GenreStringToData(Genre);
    if TagData.Comment[28] = #0 then
    begin
      TagData.Comment[29] := AnsiChar(Track);
    end;
    TagStream.Write(TagData, ID3V1TAGSIZE);
    Result := ID3V1LIBRARY_SUCCESS;
  except
    Result := ID3V1LIBRARY_ERROR_WRITING_FILE;
  end;
end;

function ID3GenreDataToString(GenreIndex: Byte): AnsiString;
begin
  if GenreIndex < 148 then
  begin
    Result := ID3Genres[GenreIndex];
  end
  else
  begin
    Result := ID3Genres[12];
  end;
end;

function ID3GenreStringToData(Genre: AnsiString): Byte;
var
  i: Integer;
  GenreString: AnsiString;
begin
  Result := 12;
  GenreString := Genre;
  if GenreString = 'Psychadelic' then
  begin
    GenreString := 'Psychedelic';
  end;
  for i := 0 to Length(ID3Genres) - 1 do
  begin
    if GenreString = ID3Genres[i] then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function ID3v1RemoveTag(FileName: String): Integer;
var
  AudioFile: TFileStream;
  DataByte: Byte;
  LyricsTagIDStart: TID3LyricsTagIDStart;
  LyricsTagIDEnd: TID3LyricsTagIDEnd;
  LyricsTagSize: TID3LyricsTagSize;
  TagSize: Integer;
begin
  Result := ID3V1LIBRARY_ERROR;
  if NOT FileExists(FileName) then
  begin
    Exit;
  end;
  try
    try
      AudioFile := TFileStream.Create(FileName, fmOpenReadWrite OR fmShareDenyWrite);
    except
      Result := ID3V1LIBRARY_ERROR_OPENING_FILE;
      Exit;
    end;
    AudioFile.Seek(-ID3V1TAGSIZE, soEnd);
    AudioFile.Read(DataByte, 1);
    if DataByte = Ord('T') then
    begin
      AudioFile.Read(DataByte, 1);
      if DataByte = Ord('A') then
      begin
        AudioFile.Read(DataByte, 1);
        if DataByte = Ord('G') then
        begin
          AudioFile.Seek(-(128 + 9), soFromEnd);
          AudioFile.Read(LyricsTagIDEnd, SizeOf(TID3LyricsTagIDEnd));
          if LyricsTagIDEnd = ID3LYRICSTAGIDEND then
          begin
            AudioFile.Seek(-(128 + 9 + 6), soFromEnd);
            AudioFile.Read(LyricsTagSize, SizeOf(TID3LyricsTagSize));
            TagSize := StrToInt(LyricsTagSize);
            AudioFile.Seek(-(128 + 9 + 6 + TagSize), soFromEnd);
            AudioFile.Read(LyricsTagIDStart, SizeOf(TID3LyricsTagIDStart));
            if LyricsTagIDStart = ID3LYRICSTAGIDSTART then
            begin
              AudioFile.Seek(-(128 + 9 + 6 + TagSize), soFromEnd);
              AudioFile.Size := AudioFile.Position;
            end;
          end
          else
          begin
            AudioFile.Seek(-ID3V1TAGSIZE, soEnd);
            AudioFile.Size := AudioFile.Position;
          end;
          Result := ID3V1LIBRARY_SUCCESS;
        end;
      end;
    end;
    if AudioFile <> nil then
    begin
      FreeAndNil(AudioFile);
    end;
  except
    Result := ID3V1LIBRARY_ERROR;
  end;
end;

end.
