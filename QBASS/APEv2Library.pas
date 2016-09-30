// ********************************************************************************************************************************
// *                                                                                                                              *
// *     APEv2 Library 1.0.1.1 © 3delite 2012-2013                                                                                *
// *     See APEv2 Library Readme.txt for details                                                                                 *
// *                                                                                                                              *
// * Two licenses are available for commercial usage of this component:                                                           *
// * Shareware License: 25 Euros                                                                                                  *
// * Commercial License: 100 Euros                                                                                                *
// *                                                                                                                              *
// *     http://www.shareit.com/product.html?productid=300517941                                                                  *
// *                                                                                                                              *
// * Using the component in free programs is free.                                                                                *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/APEv2Library.html                                          *
// *                                                                                                                              *
// * There is also an ID3v2 Library available at:                                                                                 *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/id3v2library.html                                          *
// *                                                                                                                              *
// * and also an MP4 Tag Library available at:                                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/MP4TagLibrary.html                                         *
// *                                                                                                                              *
// * and also an Ogg Vorbis and Opus Tag Library available at:                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/OpusTagLibrary.html                                        *
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

unit APEv2Library;

{$OPTIMIZATION Off}

interface

uses
  Classes;

const
  APEv2LIBRARY_VERSION = $01000101;

const
  APEV2LIBRARY_SUCCESS = 0;
  APEV2LIBRARY_ERROR = $FFFF;
  APEV2LIBRARY_ERROR_NO_TAG_FOUND = 1;
  APEV2LIBRARY_ERROR_EMPTY_TAG = 2;
  APEV2LIBRARY_ERROR_EMPTY_FRAMES = 3;
  APEV2LIBRARY_ERROR_OPENING_FILE = 4;
  APEV2LIBRARY_ERROR_READING_FILE = 5;
  APEV2LIBRARY_ERROR_WRITING_FILE = 6;
  APEV2LIBRARY_ERROR_CORRUPT = 7;
  APEV2LIBRARY_ERROR_NOT_SUPPORTED_VERSION = 8;
  APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT = 9;

type
  TAPEv2ID = array[1..8] of AnsiChar;
  TID3v1ID = array[0..2] of AnsiChar;

type
  TAPEv2Header = packed record
    Version: Cardinal;
    TagSize: Cardinal;
    ItemCount: Cardinal;
    Flags: Cardinal;
    Reserved: Int64;
  end;

type
  TAPEv2PictureFormat = (pfUnknown, pfJPEG, pfPNG, pfBMP, pfGIF);

type
  TAPEv2FrameFormat = (ffUnknown, ffText, ffBinary);

type
  TAPEv2Frame = class
  private
  public
    Name: string;
    Format: TAPEv2FrameFormat;
    Stream: TMemoryStream;
    Flags: Word;
    constructor Create;
    destructor Destroy; override;
    function GetAsText: string;
    function SetAsText(Text: string): Boolean;
    function GetAsList(var List: TStrings): Boolean;
    function SetAsList(List: TStrings): Boolean;
    function IsCoverArt: Boolean;
    procedure Clear;
    function Assign(APEv2Frame: TAPEv2Frame): Boolean;
  end;

type
  TAPEv2Tag = class
  private
  public
    FileName: string;
    Loaded: Boolean;
    Version: Cardinal;
    Flags: Cardinal;
    Size: Cardinal;
    Frames: array of TAPEv2Frame;
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(FileName: string): Integer;
    function LoadFromStream(TagStream: TStream): Integer;
    function SaveToFile(FileName: string): Integer;
    // function SaveToStream(var TagStream: TStream): Integer;
    function AddFrame(Name: string): TAPEv2Frame;
    function DeleteFrame(FrameIndex: Integer): Boolean;
    procedure DeleteAllFrames;
    procedure Clear;
    function FrameCount: Integer;
    function FrameExists(Name: string): Integer; overload;
    function FrameTypeCount(Name: string): Integer;
    function CalculateTotalFramesSize: Integer;
    function CalculateTagSize: Integer;
    procedure AddTextFrame(Name: string; Text: string);
    procedure AddBinaryFrame(Name: string; BinaryStream: TStream; Size: Integer);
    procedure SetTextFrameText(Name: string; Text: string);
    procedure SetListFrameText(Name: string; List: TStrings);
    function ReadFrameByNameAsText(Name: string): string;
    function ReadFrameByNameAsList(Name: string; var List: TStrings): Boolean;
    procedure RemoveEmptyFrames;
    function AddPictureFrame(Name: string; PictureStream: TStream; Description: string): Boolean;
    function SetPictureFrame(Index: Integer; PictureStream: TStream; Description: string): Boolean;
    function GetPictureFromFrame(Index: Integer; PictureStream: TStream; var PictureFormat:
      TAPEv2PictureFormat;
      var Description: string): Boolean;
    function DeleteFrameByName(Name: string): Boolean;
    function Assign(Source: TAPEv2Tag): Boolean;
  end;

function APEv2ValidTag(TagStream: TStream): Boolean;
function RemoveAPEv2FromFile(FileName: string): Integer;

var
  APEv2ID: TAPEv2ID;
  ID3v1ID: TID3v1ID;

implementation

uses
  SysUtils,
  Windows;

constructor TAPEv2Frame.Create;
begin
  inherited;
  Name := '';
  Flags := 0;
  Stream := TMemoryStream.Create;
  Format := ffUnknown;
end;

destructor TAPEv2Frame.Destroy;
begin
  FreeAndNil(Stream);
  inherited;
end;

function TAPEv2Frame.GetAsText: string;
var
  i: Integer;
  Data: Byte;
  AnsiStr: AnsiString;
begin
  Result := '';
  if Format <> ffText then
  begin
    Exit;
  end;
  Stream.Seek(0, soBeginning);
  for i := 0 to Stream.Size - 1 do
  begin
    Stream.Read(Data, 1);
    AnsiStr := AnsiStr + AnsiChar(Data);
  end;
  Stream.Seek(0, soBeginning);
  Result := UTF8Decode(AnsiStr);
end;

function TAPEv2Frame.SetAsText(Text: string): Boolean;
var
  i: Integer;
  AnsiStr: AnsiString;
begin
  Result := False;
  AnsiStr := UTF8Encode(Text);
  Stream.Clear;
  Stream.Write(Pointer(AnsiStr)^, Length(AnsiStr));
  Stream.Seek(0, soBeginning);
  Format := ffText;
  Result := True;
end;

function TAPEv2Frame.SetAsList(List: TStrings): Boolean;
var
  i: Integer;
  Data: Byte;
  AnsiStr: AnsiString;
  Name: AnsiString;
  Value: AnsiString;
begin
  Result := False;
  // if Format <> ffText then begin
  // Exit;
  // end;
  Stream.Clear;
  for i := 0 to List.Count - 1 do
  begin
    Name := UTF8Encode(List.Names[i]);
    Value := UTF8Encode(List.ValueFromIndex[i]);
    Stream.Write(Pointer(Name)^, Length(Name));
    Data := $0D;
    Stream.Write(Data, 1);
    Data := $0A;
    Stream.Write(Data, 1);
    Stream.Write(Pointer(Value)^, Length(Value));
    Data := $0D;
    Stream.Write(Data, 1);
    Data := $0A;
    Stream.Write(Data, 1);
  end;
  Stream.Seek(0, soBeginning);
  Result := True;
end;

function TAPEv2Frame.GetAsList(var List: TStrings): Boolean;
var
  i: Integer;
  Data: Byte;
  AnsiStr: AnsiString;
  Name: string;
  Value: string;
begin
  Result := False;
  List.Clear;
  if Format <> ffText then
  begin
    Exit;
  end;
  Stream.Seek(0, soBeginning);
  while Stream.Position < Stream.Size do
  begin
    AnsiStr := '';
    repeat
      Stream.Read(Data, 1);
      if Data = $0D then
      begin
        Stream.Read(Data, 1);
        if Data = $0A then
        begin
          Break;
        end;
      end;
      AnsiStr := AnsiStr + AnsiChar(Data);
    until Stream.Position >= Stream.Size;
    Name := UTF8Decode(AnsiStr);
    AnsiStr := '';
    repeat
      Stream.Read(Data, 1);
      if Data = $0D then
      begin
        Stream.Read(Data, 1);
        if Data = $0A then
        begin
          Break;
        end;
      end;
      AnsiStr := AnsiStr + AnsiChar(Data);
    until Stream.Position >= Stream.Size;
    Value := UTF8Decode(AnsiStr);
    List.Append(Name + '=' + Value);
    Result := True;
  end;
  Stream.Seek(0, soBeginning);
end;

function TAPEv2Frame.IsCoverArt: Boolean;
var
  Description: string;
  PData: PANSIChar;
  DataSize: Cardinal;
  PPicture: PByte;
  Offset: Integer;
begin
  Result := False;
  if Format <> ffBinary then
  begin
    Exit;
  end;
  try
    try
      Offset := 0;
      DataSize := Stream.Size;
      PPicture := Stream.Memory;
      while Offset < DataSize do
      begin
        if Description = '' then
        begin
          while (PPicture^ <> 0) and (Offset < DataSize) do
          begin
            Description := Description + AnsiChar(PPicture^);
            Inc(PPicture);
            Inc(Offset);
          end;
        end;
        // * JPEG
        if PPicture^ = $FF then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $D8 then
          begin
            // PictureFormat := pfJPEG;
            Dec(PPicture);
            Dec(Offset);
            Result := True;
            Break;
          end;
        end;
        // * PNG 89 50 4E 47 0D 0A 1A 0A
        if PPicture^ = $89 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $50 then
          begin
            Inc(PPicture);
            Inc(Offset);
            if PPicture^ = $4E then
            begin
              Inc(PPicture);
              Inc(Offset);
              if PPicture^ = $47 then
              begin
                Inc(PPicture);
                Inc(Offset);
                if PPicture^ = $0D then
                begin
                  Inc(PPicture);
                  Inc(Offset);
                  if PPicture^ = $0A then
                  begin
                    Inc(PPicture);
                    Inc(Offset);
                    if PPicture^ = $1A then
                    begin
                      Inc(PPicture);
                      Inc(Offset);
                      if PPicture^ = $0A then
                      begin
                        // PictureFormat := pfPNG;
                        Dec(PPicture, 7);
                        Dec(Offset, 7);
                        Result := True;
                        Break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        // * GIF 47 49 46 38
        if PPicture^ = $47 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $49 then
          begin
            Inc(PPicture);
            Inc(Offset);
            if PPicture^ = $46 then
            begin
              Inc(PPicture);
              Inc(Offset);
              if PPicture^ = $38 then
              begin
                // PictureFormat := pfGIF;
                Dec(PPicture, 3);
                Dec(Offset, 3);
                Result := True;
                Break;
              end;
            end;
          end;
        end;
        // * BMP 42 4D
        if PPicture^ = $42 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $4D then
          begin
            // PictureFormat := pfBMP;
            Dec(PPicture);
            Dec(Offset);
            Result := True;
            Break;
          end;
        end;
        Inc(PPicture);
        Inc(Offset);
      end;
      Description := UTF8Decode(Description);
      if not Result then
        Description := '';
    finally
      // *
    end;
  except
    Result := False;
  end;
end;

procedure TAPEv2Frame.Clear;
begin
  Format := ffUnknown;
  Flags := 0;
  Stream.Clear;
end;

function TAPEv2Frame.Assign(APEv2Frame: TAPEv2Frame): Boolean;
begin
  Result := False;
  Self.Clear;
  if APEv2Frame <> nil then
  begin
    Format := APEv2Frame.Format;
    Flags := APEv2Frame.Flags;
    APEv2Frame.Stream.Seek(0, soBeginning);
    Stream.CopyFrom(APEv2Frame.Stream, APEv2Frame.Stream.Size);
    Stream.Seek(0, soBeginning);
    APEv2Frame.Stream.Seek(0, soBeginning);
  end;
  Result := True;
end;

constructor TAPEv2Tag.Create;
begin
  inherited;
  Clear;
end;

destructor TAPEv2Tag.Destroy;
begin
  Clear;
  inherited;
end;

procedure TAPEv2Tag.DeleteAllFrames;
var
  i: Integer;
begin
  for i := 0 to Length(Frames) - 1 do
  begin
    FreeAndNil(Frames[i]);
  end;
  SetLength(Frames, 0);
end;

function TAPEv2Tag.LoadFromStream(TagStream: TStream): Integer;
var
  PreviousPosition: Int64;
  ReadID3v1ID: TID3v1ID;
  APEv2Header: TAPEv2Header;
  i: Integer;
  DataSize: Cardinal;
  DataFlags: Cardinal;
  Data: Byte;
  FrameName: AnsiString;
begin
  Result := APEV2LIBRARY_ERROR;
  Loaded := False;
  Clear;
  try
    PreviousPosition := TagStream.Position;
    try
      // if NOT APEv2ValidTag(TagStream) then begin
      TagStream.Seek(-128, soEnd);
      TagStream.Read(ReadID3v1ID, 3);
      if ReadID3v1ID = ID3v1ID then
      begin
        TagStream.Seek(-32 - 128, soEnd);
      end
      else
      begin
        TagStream.Seek(-32, soEnd);
      end;
      if not APEv2ValidTag(TagStream) then
      begin
        Result := APEV2LIBRARY_ERROR_NO_TAG_FOUND;
        Exit;
      end;
      // end;
      if TagStream.Read(APEv2Header, SizeOf(TAPEv2Header)) <> SizeOf(TAPEv2Header) then
      begin
        Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      Version := APEv2Header.Version;
      Flags := APEv2Header.Flags;
      Size := APEv2Header.TagSize;
      {
        if APEv2Header.Reserved <> 0 then begin
        Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
        end;
      }
      if (APEv2Header.Version <> 2000) then
      begin
        if (APEv2Header.Version <> 1000) then
        begin
          Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_VERSION;
          Exit;
        end;
      end;
      if APEv2Header.Flags and not $80000001 <> 0 then
      begin
        Result := APEV2LIBRARY_ERROR_CORRUPT;
        Exit;
      end;
      TagStream.Seek(-APEv2Header.TagSize, soCurrent);
      for i := 0 to APEv2Header.ItemCount - 1 do
      begin
        FrameName := '';
        TagStream.Read(DataSize, 4);
        TagStream.Read(DataFlags, 4);
        if DataFlags and not $7 <> 0 then
        begin
          Result := APEV2LIBRARY_ERROR_CORRUPT;
          // Exit;
        end;
        if DataSize > Size then
        begin
          Result := APEV2LIBRARY_ERROR_CORRUPT;
          Exit;
        end;
        repeat
          TagStream.Read(Data, 1);
          if Data <> 0 then
          begin
            FrameName := FrameName + AnsiChar(Data);
          end;
        until Data = 0;
        case (DataFlags and $6) shr 1 of
          0:
            begin
              with AddFrame(UTF8Decode(FrameName)) do
              begin
                Stream.CopyFrom(TagStream, DataSize);
                Format := ffText;
              end;
            end;
          1:
            begin
              with AddFrame(UTF8Decode(FrameName)) do
              begin
                Stream.CopyFrom(TagStream, DataSize);
                Format := ffBinary;
              end;
            end;
          // 2: unsupported feature
          3:
            begin
              Result := APEV2LIBRARY_ERROR_CORRUPT;
            end;
        end;
        Loaded := True;
      end;
    finally
      TagStream.Seek(PreviousPosition, soBeginning);
    end;
    Result := APEV2LIBRARY_SUCCESS;
  except
    Result := APEV2LIBRARY_ERROR;
  end;
end;

function TAPEv2Tag.LoadFromFile(FileName: string): Integer;
var
  FileStream: TFileStream;
begin
  Result := APEV2LIBRARY_ERROR;
  Clear;
  Loaded := False;
  if not FileExists(FileName) then
  begin
    Result := APEV2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  except
    Result := APEV2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    Result := LoadFromStream(FileStream);
    if (Result = APEV2LIBRARY_SUCCESS) or (Result = APEV2LIBRARY_ERROR_NOT_SUPPORTED_VERSION) then
    begin
      Self.FileName := FileName;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

function TAPEv2Tag.AddFrame(Name: string): TAPEv2Frame;
begin
  Result := nil;
  try
    SetLength(Frames, Length(Frames) + 1);
    Frames[Length(Frames) - 1] := TAPEv2Frame.Create;
    Frames[Length(Frames) - 1].Name := Name;
    Result := Frames[Length(Frames) - 1];
  except
    // *
  end;
end;

function TAPEv2Tag.DeleteFrame(FrameIndex: Integer): Boolean;
var
  i: Integer;
  l: Integer;
  j: Integer;
begin
  Result := False;
  if (FrameIndex >= Length(Frames)) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  FreeAndNil(Frames[FrameIndex]);
  i := 0;
  j := 0;
  while i <= Length(Frames) - 1 do
  begin
    if Frames[i] <> nil then
    begin
      Frames[j] := Frames[i];
      Inc(j);
    end;
    Inc(i);
  end;
  SetLength(Frames, j);
  Result := True;
end;

function TAPEv2Tag.FrameExists(Name: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(Frames) - 1 do
  begin
    if Name = Frames[i].Name then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TAPEv2Tag.FrameTypeCount(Name: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(Frames) - 1 do
  begin
    if WideUpperCase(Name) = WideUpperCase(Frames[i].Name) then
    begin
      Inc(Result);
    end;
  end;
end;

function TAPEv2Tag.SaveToFile(FileName: string): Integer;
var
  TagStream: TStream;
  ReadID3v1ID: TID3v1ID;
  APEv2Header: TAPEv2Header;
  ID3v1Stream: TMemoryStream;
  APEv2TagExists: Boolean;
  i: Integer;
  AnsiFrameName: AnsiString;
  FrameSize: Cardinal;
  FrameFlags: Cardinal;
  Data: Byte;
begin
  Result := APEV2LIBRARY_ERROR;
  APEv2TagExists := False;
  TagStream := nil;
  try
    try
      RemoveEmptyFrames;
      if Length(Frames) = 0 then
      begin
        Result := APEV2LIBRARY_ERROR_EMPTY_TAG;
        Exit;
      end;
      if CalculateTotalFramesSize = 0 then
      begin
        Result := APEV2LIBRARY_ERROR_EMPTY_FRAMES;
        Exit;
      end;
      if not FileExists(FileName) then
      begin
        TagStream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
      end
      else
      begin
        TagStream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
      end;
      ID3v1Stream := TMemoryStream.Create;
      TagStream.Seek(-128, soEnd);
      TagStream.Read(ReadID3v1ID, 3);
      if ReadID3v1ID = ID3v1ID then
      begin
        TagStream.Seek(-128, soEnd);
        ID3v1Stream.CopyFrom(TagStream, 128);
        ID3v1Stream.Seek(0, soBeginning);
        TagStream.Seek(-32 - 128, soEnd);
      end
      else
      begin
        TagStream.Seek(-32, soEnd);
      end;
      if APEv2ValidTag(TagStream) then
      begin
        APEv2TagExists := True;
      end;
      if not APEv2TagExists then
      begin
        if ID3v1Stream.Size <> 0 then
        begin
          TagStream.Seek(-128, soEnd);
        end
        else
        begin
          TagStream.Seek(0, soEnd);
        end;
      end
      else
      begin
        if ID3v1Stream.Size <> 0 then
        begin
          TagStream.Seek(-24 - 128, soEnd);
        end
        else
        begin
          TagStream.Seek(-24, soEnd);
        end;
        if TagStream.Read(APEv2Header, SizeOf(TAPEv2Header)) <> SizeOf(TAPEv2Header) then
        begin
          Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
          Exit;
        end;
        if APEv2Header.Reserved <> 0 then
        begin
          Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
          Exit;
        end;
        if (APEv2Header.Version <> 2000) then
        begin
          if (APEv2Header.Version <> 1000) then
          begin
            Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_VERSION;
            Exit;
          end;
        end;
        if APEv2Header.Flags and not $80000001 <> 0 then
        begin
          Result := APEV2LIBRARY_ERROR_CORRUPT;
          Exit;
        end;
        TagStream.Seek(-APEv2Header.TagSize, soCurrent);
        TagStream.Seek(-32, soCurrent);
      end;
      // * Do the write
      APEv2Header.Version := 2000;
      APEv2Header.TagSize := CalculateTagSize;
      APEv2Header.ItemCount := Length(Frames);
      APEv2Header.Flags := $A0000000;
      APEv2Header.Reserved := 0;
      TagStream.Write(APEv2ID, 8);
      TagStream.Write(APEv2Header, SizeOf(TAPEv2Header));
      for i := 0 to Length(Frames) - 1 do
      begin
        AnsiFrameName := UTF8Encode(Frames[i].Name);
        case Frames[i].Format of
          ffText:
            begin
              FrameFlags := 0;
            end;
          ffBinary:
            begin
              FrameFlags := $2;
            end;
        end;
        FrameSize := Frames[i].Stream.Size;
        TagStream.Write(FrameSize, 4);
        TagStream.Write(FrameFlags, 4);
        TagStream.Write(Pointer(AnsiFrameName)^, Length(AnsiFrameName));
        Data := $0;
        TagStream.Write(Data, 1);
        Frames[i].Stream.Seek(0, soBeginning);
        TagStream.CopyFrom(Frames[i].Stream, Frames[i].Stream.Size);
      end;
      TagStream.Write(APEv2ID, 8);
      APEv2Header.Flags := $A0000000 and not $20000000;
      TagStream.Write(APEv2Header, SizeOf(TAPEv2Header));
      TagStream.CopyFrom(ID3v1Stream, ID3v1Stream.Size);
      TFileStream(TagStream).Size := TagStream.Position;
      Result := APEV2LIBRARY_SUCCESS;
    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
      if Assigned(ID3v1Stream) then
      begin
        FreeAndNil(ID3v1Stream);
      end;
    end;
  except
    Result := APEV2LIBRARY_ERROR;
  end;
end;

function TAPEv2Tag.CalculateTagSize: Integer;
var
  TotalTagSize: Integer;
  i: Integer;
begin
  TotalTagSize := CalculateTotalFramesSize;
  TotalTagSize := TotalTagSize + 8 + SizeOf(TAPEv2Header);
  Result := TotalTagSize;
end;

function TAPEv2Tag.CalculateTotalFramesSize: Integer;
var
  TotalFramesSize: Integer;
  i: Integer;
  AnsiStr: AnsiString;
begin
  TotalFramesSize := 0;
  for i := 0 to Length(Frames) - 1 do
  begin
    AnsiStr := UTF8Encode(Frames[i].Name);
    TotalFramesSize := TotalFramesSize + Frames[i].Stream.Size + Length(AnsiStr) + 1 + 4 + 4;
  end;
  Result := TotalFramesSize;
end;

procedure TAPEv2Tag.Clear;
begin
  DeleteAllFrames;
  FileName := '';
  Loaded := False;
  Version := 0;
  Flags := 0;
  Size := 0;
end;

function TAPEv2Tag.FrameCount: Integer;
begin
  Result := Length(Frames);
end;

procedure TAPEv2Tag.AddTextFrame(Name: string; Text: string);
begin
  AddFrame(Name).SetAsText(Text);
end;

procedure TAPEv2Tag.AddBinaryFrame(Name: string; BinaryStream: TStream; Size: Integer);
var
  PreviousPosition: Int64;
begin
  with AddFrame(Name) do
  begin
    PreviousPosition := BinaryStream.Position;
    Stream.CopyFrom(BinaryStream, Size);
    Format := ffBinary;
    BinaryStream.Seek(PreviousPosition, soBeginning);
  end;
end;

procedure TAPEv2Tag.SetTextFrameText(Name: string; Text: string);
var
  i: Integer;
  l: Integer;
begin
  i := 0;
  l := Length(Frames);
  while (i < l) and (WideUpperCase(Frames[i].Name) <> WideUpperCase(Name)) do
  begin
    Inc(i);
  end;
  if i = l then
  begin
    AddTextFrame(Name, Text);
  end
  else
  begin
    Frames[i].SetAsText(Text);
  end;
end;

procedure TAPEv2Tag.SetListFrameText(Name: string; List: TStrings);
var
  i: Integer;
  l: Integer;
begin
  i := 0;
  l := Length(Frames);
  while (i < l) and (WideUpperCase(Frames[i].Name) <> WideUpperCase(Name)) do
  begin
    Inc(i);
  end;
  if i = l then
  begin
    AddFrame(Name).SetAsList(List);
  end
  else
  begin
    Frames[i].SetAsList(List);
  end;
end;

function TAPEv2Tag.ReadFrameByNameAsText(Name: string): string;
var
  i: Integer;
  l: Integer;
begin
  Result := '';
  l := Length(Frames);
  i := 0;
  while (i <> l) and (WideUpperCase(Frames[i].Name) <> WideUpperCase(Name)) do
  begin
    Inc(i);
  end;
  if i = l then
  begin
    Result := '';
  end
  else
  begin
    if Frames[i].Format = ffText then
    begin
      Result := Frames[i].GetAsText;
    end;
  end;
end;

function TAPEv2Tag.ReadFrameByNameAsList(Name: string; var List: TStrings): Boolean;
var
  i: Integer;
  l: Integer;
begin
  Result := False;
  l := Length(Frames);
  i := 0;
  while (i <> l) and (WideUpperCase(Frames[i].Name) <> WideUpperCase(Name)) do
  begin
    Inc(i);
  end;
  if i = l then
  begin
    Result := False;
  end
  else
  begin
    if Frames[i].Format = ffText then
    begin
      Result := Frames[i].GetAsList(List);
    end;
  end;
end;

procedure TAPEv2Tag.RemoveEmptyFrames;
var
  i: Integer;
begin
  for i := Length(Frames) - 1 downto 0 do
  begin
    if Frames[i].Stream.Size = 0 then
    begin
      DeleteFrame(i);
    end;
  end;
end;

function TAPEv2Tag.AddPictureFrame(Name: string; PictureStream: TStream; Description: string): Boolean;
var
  Data: TMemoryStream;
  ZeroByte: Byte;
  UTF8FileName: UTF8String;
begin
  Result := False;
  ZeroByte := 0;
  Data := TMemoryStream.Create;
  try
    UTF8FileName := UTF8Encode(Description);
    Data.Write(Pointer(UTF8FileName)^, Length(UTF8FileName));
    Data.Write(ZeroByte, 1);
    PictureStream.Seek(0, soBeginning);
    Data.CopyFrom(PictureStream, PictureStream.Size);
    Data.Seek(0, soBeginning);
    AddBinaryFrame(Name, Data, Data.Size);
    PictureStream.Seek(0, soBeginning);
    Result := True;
  finally
    FreeAndNil(Data);
  end;
end;

function TAPEv2Tag.SetPictureFrame(Index: Integer; PictureStream: TStream; Description: string): Boolean;
var
  Data: TMemoryStream;
  ZeroByte: Byte;
  UTF8FileName: UTF8String;
begin
  Result := False;
  if (Index >= Length(Frames)) or (Index < 0) then
  begin
    Exit;
  end;
  ZeroByte := 0;
  Data := TMemoryStream.Create;
  try
    UTF8FileName := UTF8Encode(Description);
    Data.Write(Pointer(UTF8FileName)^, Length(UTF8FileName));
    Data.Write(ZeroByte, 1);
    PictureStream.Seek(0, soBeginning);
    Data.CopyFrom(PictureStream, PictureStream.Size);
    Data.Seek(0, soBeginning);
    Frames[Index].Stream.Clear;
    Frames[Index].Stream.CopyFrom(Data, Data.Size);
    PictureStream.Seek(0, soBeginning);
    Result := True;
  finally
    FreeAndNil(Data);
  end;
end;

function TAPEv2Tag.GetPictureFromFrame(Index: Integer; PictureStream: TStream; var PictureFormat:
  TAPEv2PictureFormat;
  var Description: string): Boolean;
var
  i: Integer;
  BinaryStream: TMemoryStream;
  PData: PANSIChar;
  DataSize: Cardinal;
  PPicture: PByte;
  Offset: Integer;
begin
  Result := False;
  Description := '';
  PictureFormat := pfUnknown;
  if (Index >= Length(Frames)) or (Index < 0) then
  begin
    Exit;
  end;
  try
    BinaryStream := TMemoryStream.Create;
    try
      Offset := 0;
      DataSize := Frames[Index].Stream.Size;
      PPicture := Frames[Index].Stream.Memory;
      while Offset < DataSize do
      begin
        if Description = '' then
        begin
          while (PPicture^ <> 0) and (Offset < DataSize) do
          begin
            Description := Description + AnsiChar(PPicture^);
            Inc(PPicture);
            Inc(Offset);
          end;
        end;
        // * JPEG
        if PPicture^ = $FF then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $D8 then
          begin
            PictureFormat := pfJPEG;
            Dec(PPicture);
            Dec(Offset);
            Result := True;
            Break;
          end;
        end;
        // * PNG 89 50 4E 47 0D 0A 1A 0A
        if PPicture^ = $89 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $50 then
          begin
            Inc(PPicture);
            Inc(Offset);
            if PPicture^ = $4E then
            begin
              Inc(PPicture);
              Inc(Offset);
              if PPicture^ = $47 then
              begin
                Inc(PPicture);
                Inc(Offset);
                if PPicture^ = $0D then
                begin
                  Inc(PPicture);
                  Inc(Offset);
                  if PPicture^ = $0A then
                  begin
                    Inc(PPicture);
                    Inc(Offset);
                    if PPicture^ = $1A then
                    begin
                      Inc(PPicture);
                      Inc(Offset);
                      if PPicture^ = $0A then
                      begin
                        PictureFormat := pfPNG;
                        Dec(PPicture, 7);
                        Dec(Offset, 7);
                        Result := True;
                        Break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        // * GIF 47 49 46 38
        if PPicture^ = $47 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $49 then
          begin
            Inc(PPicture);
            Inc(Offset);
            if PPicture^ = $46 then
            begin
              Inc(PPicture);
              Inc(Offset);
              if PPicture^ = $38 then
              begin
                PictureFormat := pfGIF;
                Dec(PPicture, 3);
                Dec(Offset, 3);
                Result := True;
                Break;
              end;
            end;
          end;
        end;
        // * BMP 42 4D
        if PPicture^ = $42 then
        begin
          Inc(PPicture);
          Inc(Offset);
          if PPicture^ = $4D then
          begin
            PictureFormat := pfBMP;
            Dec(PPicture);
            Dec(Offset);
            Result := True;
            Break;
          end;
        end;
        Inc(PPicture);
        Inc(Offset);
      end;
      BinaryStream.Write(PPicture^, DataSize - Offset);
      BinaryStream.Seek(0, soBeginning);
      PictureStream.CopyFrom(BinaryStream, PictureStream.Size);
      PictureStream.Seek(0, soBeginning);
      Description := UTF8Decode(Description);
      if not Result then
        Description := '';
    finally
      FreeAndNil(BinaryStream);
    end;
  except
    Result := False;
  end;
end;

function TAPEv2Tag.DeleteFrameByName(Name: string): Boolean;
var
  i: Integer;
  l: Integer;
  j: Integer;
begin
  Result := False;
  l := Length(Frames);
  i := 0;
  while (i <> l) and (WideUpperCase(Frames[i].Name) <> WideUpperCase(Name)) do
  begin
    Inc(i);
  end;
  if i = l then
  begin
    Result := False;
    Exit;
  end;
  FreeAndNil(Frames[i]);
  i := 0;
  j := 0;
  while i <= l - 1 do
  begin
    if Frames[i] <> nil then
    begin
      Frames[j] := Frames[i];
      Inc(j);
    end;
    Inc(i);
  end;
  SetLength(Frames, j);
  Result := True;
end;

function TAPEv2Tag.Assign(Source: TAPEv2Tag): Boolean;
var
  i: Integer;
  PData: PANSIChar;
  DataSize: Cardinal;
begin
  Clear;
  FileName := Source.FileName;
  Loaded := Source.Loaded;
  Version := Source.Version;
  Flags := Source.Flags;
  Size := Source.Size;
  for i := 0 to Length(Source.Frames) - 1 do
  begin
    case Source.Frames[i].Format of
      ffText:
        begin
          SetTextFrameText(Source.Frames[i].Name, Source.Frames[i].GetAsText);
        end;
      ffBinary:
        begin
          Source.Frames[i].Stream.Seek(0, soBeginning);
          AddBinaryFrame(Source.Frames[i].Name, Source.Frames[i].Stream, Source.Frames[i].Stream.Size);
        end;
    end;
  end;
end;

function APEv2ValidTag(TagStream: TStream): Boolean;
var
  Identification: TAPEv2ID;
begin
  Result := False;
  try
    Identification := #0#0#0#0#0#0#0#0;
    TagStream.Read(Identification[1], 8);
    if Identification = APEv2ID then
    begin
      Result := True;
    end;
  except
    // *
  end;
end;

function RemoveAPEv2FromFile(FileName: string): Integer;
var
  TagStream: TStream;
  ReadID3v1ID: TID3v1ID;
  APEv2Header: TAPEv2Header;
  ID3v1Stream: TMemoryStream;
  APEv2TagExists: Boolean;
begin
  Result := APEV2LIBRARY_ERROR;
  APEv2TagExists := False;
  TagStream := nil;
  try
    try
      if not FileExists(FileName) then
      begin
        TagStream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
      end
      else
      begin
        TagStream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
      end;
      ID3v1Stream := TMemoryStream.Create;
      TagStream.Seek(-128, soEnd);
      TagStream.Read(ReadID3v1ID, 3);
      if ReadID3v1ID = ID3v1ID then
      begin
        TagStream.Seek(-128, soEnd);
        ID3v1Stream.CopyFrom(TagStream, 128);
        ID3v1Stream.Seek(0, soBeginning);
        TagStream.Seek(-32 - 128, soEnd);
      end
      else
      begin
        TagStream.Seek(-32, soEnd);
      end;
      if not APEv2ValidTag(TagStream) then
      begin
        Result := APEV2LIBRARY_ERROR_NO_TAG_FOUND;
        Exit;
      end;
      if ID3v1Stream.Size <> 0 then
      begin
        TagStream.Seek(-24 - 128, soEnd);
      end
      else
      begin
        TagStream.Seek(-24, soEnd);
      end;
      if TagStream.Read(APEv2Header, SizeOf(TAPEv2Header)) <> SizeOf(TAPEv2Header) then
      begin
        Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      if APEv2Header.Reserved <> 0 then
      begin
        Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      if (APEv2Header.Version <> 2000) then
      begin
        if (APEv2Header.Version <> 1000) then
        begin
          Result := APEV2LIBRARY_ERROR_NOT_SUPPORTED_VERSION;
          Exit;
        end;
      end;
      if APEv2Header.Flags and not $80000001 <> 0 then
      begin
        Result := APEV2LIBRARY_ERROR_CORRUPT;
        Exit;
      end;
      TagStream.Seek(-APEv2Header.TagSize, soCurrent);
      TagStream.Seek(-32, soCurrent);
      TFileStream(TagStream).Size := TagStream.Position;
      TagStream.CopyFrom(ID3v1Stream, ID3v1Stream.Size);
      Result := APEV2LIBRARY_SUCCESS;
    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
      if Assigned(ID3v1Stream) then
      begin
        FreeAndNil(ID3v1Stream);
      end;
    end;
  except
    Result := APEV2LIBRARY_ERROR;
  end;
end;

initialization

  APEv2ID := 'APETAGEX';
  ID3v1ID := 'TAG';

end.

