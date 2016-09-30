// ********************************************************************************************************************************
// *                                                                                                                              *
// *     Flac Tag Library 2.0.6.22 © 3delite 2013                                                                                 *
// *     See Flac Tag Library Readme.txt for details                                                                              *
// *                                                                                                                              *
// * This unit is based on ATL's FlacFile class but many new features were added, specially full support for managing cover arts  *
// * and support of Ogg Flac files.                                                                                               *
// * As the original unit is LGPL licensed you are entitled to use it for free given the LGPL license terms.                      *
// * If you are using the cover art managing functions (read and/or write) and/or Ogg Flac functions you can use it for free for  *
// * free programs/projects but for shareware or commerical programs you need one of the following licenses:                      *
// * Shareware License: 25 Euros                                                                                                  *
// * Commercial License: 100 Euros                                                                                                *
// *                                                                                                                              *
// *     http://www.shareit.com/product.html?productid=300576722                                                                  *
// *                                                                                                                              *
// * Using the component in free programs is free.                                                                                *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/FlacTagLibrary.html                                        *
// *                                                                                                                              *
// * There is also an ID3v2 Library available at:                                                                                 *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/id3v2library.html                                          *
// *                                                                                                                              *
// * an APEv2 Library available at:                                                                                               *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/APEv2Library.html                                          *
// *                                                                                                                              *
// * an MP4 Tag Library available at:                                                                                             *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/MP4TagLibrary.html                                         *
// *                                                                                                                              *
// * and also an Ogg Vorbis and Opus Tag Library available at:                                                                    *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/OpusTagLibrary.html                                        *
// *                                                                                                                              *
// * and also a WMA Tag Library available at:                                                                                     *
// *                                                                                                                              *
// *     http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/WMATagLibrary.html                                         *
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

{ *************************************************************************** }
{ }
{ Audio Tools Library }
{ Class TFLACfile - for manipulating with FLAC file information }
{ }
{ http://mac.sourceforge.net/atl/ }
{ e-mail: macteam@users.sourceforge.net }
{ }
{ Copyright (c) 2000-2002 by Jurgen Faul }
{ Copyright (c) 2003-2005 by The MAC Team }
{ Copyright (c) 2013 by 3delite }
{ }
{ Version 2.0 (February 2013) by 3delite }
{ - removed TNT and ATLCommon dependency (now the unit is stand alone) }
{ - fixed writing to files with ID3v2 tags }
{ - converted program logic to handle all tags easily }
{ - added full support for managing cover arts }
{ - support for Win64 and OSX build mode }
{ }
{ Version 1.4 (April 2005) by Gambit }
{ - updated to unicode file access }
{ }
{ Version 1.3 (13 August 2004) by jtclipper }
{ - unit rewritten, VorbisComment is obsolete now }
{ }
{ Version 1.2 (23 June 2004) by sundance }
{ - Check for ID3 tags (although not supported) }
{ - Don't parse for other FLAC metablocks if FLAC header is missing }
{ }
{ Version 1.1 (6 July 2003) by Erik }
{ - Class: Vorbis comments (native comment to FLAC files) added }
{ }
{ Version 1.0 (13 August 2002) }
{ - Info: channels, sample rate, bits/sample, file size, duration, ratio }
{ - Class TID3v1: reading & writing support for ID3v1 tags }
{ - Class TID3v2: reading & writing support for ID3v2 tags }
{ }
{ This library is free software; you can redistribute it and/or }
{ modify it under the terms of the GNU Lesser General Public }
{ License as published by the Free Software Foundation; either }
{ version 2.1 of the License, or (at your option) any later version. }
{ }
{ This library is distributed in the hope that it will be useful, }
{ but WITHOUT ANY WARRANTY; without even the implied warranty of }
{ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU }
{ Lesser General Public License for more details. }
{ }
{ You should have received a copy of the GNU Lesser General Public }
{ License along with this library; if not, write to the Free Software }
{ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA }
{ }
{ *************************************************************************** }

unit FlacTagLibrary;

interface

uses
  Classes,
  SysUtils,
  StrUtils;

const
  FLACTAGLIBRARY_SUCCESS = 0;
  FLACTAGLIBRARY_ERROR = $FFFF;
  FLACTAGLIBRARY_ERROR_NO_TAG_FOUND = 1;
  FLACTAGLIBRARY_ERROR_EMPTY_TAG = 2;
  FLACTAGLIBRARY_ERROR_EMPTY_FRAMES = 3;
  FLACTAGLIBRARY_ERROR_OPENING_FILE = 4;
  FLACTAGLIBRARY_ERROR_READING_FILE = 5;
  FLACTAGLIBRARY_ERROR_WRITING_FILE = 6;
  FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_VERSION = 7;
  FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_FORMAT = 8;
  FLACTAGLIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS = 9;

const
  META_STREAMINFO = 0;
  META_PADDING = 1;
  META_APPLICATION = 2;
  META_SEEKTABLE = 3;
  META_VORBIS_COMMENT = 4;
  META_CUESHEET = 5;
  META_COVER_ART = 6;

const
  DEFAULT_PADDING_SIZE = 4096 - 4;

const
  OGG_PAGE_SEGMENT_SIZE = 17;

type
  TMetaDataBlockHeader = array[1..4] of Byte;

  TFlacHeader = record
    StreamMarker: array[1..4] of ANSIChar; // should always be 'fLaC'
    MetaDataBlockHeader: array[1..4] of Byte;
    Info: array[1..18] of Byte;
    MD5Sum: array[1..16] of Byte;
  end;

  TMetaData = record
    MetaDataBlockHeader: TMetaDataBlockHeader; // array[1..4] of Byte;
    Data: TMemoryStream;
    BlockType: Integer;
  end;

  // Ogg page header
  TOggHeader = packed record
    ID: array[1..4] of ANSIChar; { Always "OggS" }
    StreamVersion: Byte; { Stream structure version }
    TypeFlag: Byte; { Header type flag }
    AbsolutePosition: Int64; { Absolute granule position }
    Serial: Integer; { Stream serial number }
    PageNumber: Integer; { Page sequence number }
    Checksum: Cardinal; { Page checksum }
    Segments: Byte; { Number of page segments }
    LacingValues: array[1..$FF] of Byte; { Lacing values - segment sizes }
  end;

  TOggFlacHeader = packed record
    PacketType: Byte;
    Signature: array[1..4] of ANSIChar; // should always be 'FLAC'
    MajorVersion: Byte;
    MinorVersion: Byte;
    NumberOfHeaderPackets: Word;
    StreamInfo: TFlacHeader;
  end;

type
  TVorbisCommentFormat = (vcfUnknown, vcfText, { vcfCoverArt, } vcfBinary);

type
  TFlacTagCoverArtInfo = record
    PictureType: Cardinal;
    MIMEType: AnsiString;
    Description: string;
    Width: Cardinal;
    Height: Cardinal;
    ColorDepth: Cardinal;
    NoOfColors: Cardinal;
    SizeOfPictureData: Cardinal;
  end;

type
  TFlacStreamType = (fstUnknown, fstNativeFlac, fstOggFlac);

type
  TOGGStream = class
    FStream: TStream;
    LastPageQueried: Int64;
    FirstOGGHeader: TOggHeader;
    constructor Create(SourceStream: TStream);
  public
    function GetNextPageHeader(var Header: TOggHeader): Boolean;
    function GetPage(PageNumber: Int64; Stream: TStream): Boolean;
    function GetPageData(PageNumber: Int64; Stream: TStream): Boolean;
    function GetNextPage(Stream: TStream): Boolean;
    function GetNextPageData(Stream: TStream): Boolean;
    function CreateTagStream(TagStream: TStream; OutputOGGStream: TStream): Integer;
    function CalculateWrappedStreamSize(InputDataSize: Integer): Integer;
    function ReNumberPages(StartPageNumber: Int64; EndingPageNumber: Int64; Destination: TStream): Boolean;
  end;

type
  TFlacTag = class;

  TVorbisComment = class
  private
  public
    Name: AnsiString;
    Format: TVorbisCommentFormat;
    Stream: TMemoryStream;
      Index: Integer;
    Parent: TFlacTag;
    constructor Create;
    destructor Destroy; override;
    function GetAsText: string;
    function SetAsText(Text: string): Boolean;
    function GetAsList(var List: TStrings): Boolean;
    function SetAsList(List: TStrings): Boolean;
    procedure Clear;
    function Assign(VorbisComment: TVorbisComment): Boolean;
    function CalculateTotalFrameSize: Integer;
    function Delete: Boolean;
  end;

  TFlacTag = class(TObject)
  private
    FHeader: TFlacHeader;
    OggFlacHeader: TOggFlacHeader;
    FPaddingIndex: Integer;
    FPaddingLast: Boolean;
    FPaddingFragments: Boolean;
    FVorbisIndex: Integer;
    FPadding: Integer;
    FVCOffset: Integer;
    FAudioOffset: Integer;
    FChannels: Byte;
    FSampleRate: Integer;
    FBitsPerSample: Byte;
    FBitrate: Integer;
    FFileLength: Integer;
    FSamples: Int64;
    FTagSize: Integer;
    FMetaBlocksSize: Integer;
    FExists: Boolean;
    function FIsValid: Boolean;
    function FGetDuration: Double;
    function FGetRatio: Double;
    function FGetChannelMode: string;
    function GetInfo(FileName: string; SetTags: Boolean): Integer;
    procedure ReadTag(Source: TStream; SetTagFields: Boolean);
    function RebuildFile(const FileName: string; VorbisBlock: TStringStream): Integer;
    function RebuildOggFile(const FileName: string; VorbisBlock: TStringStream): Integer;
  public
    FileName: string;
    Tags: array of TVorbisComment;
    VendorString: AnsiString;
    Loaded: Boolean;
    MetaBlocksCoverArts: array of TMetaData;
    aMetaBlockOther: array of TMetaData;
    bTAG_PreserveDate: Boolean;
    PaddingSizeToWrite: Cardinal;
    ForceReWrite: Boolean;
    StreamType: TFlacStreamType;
    constructor Create;
    destructor Destroy; override;
    procedure ResetData(const bHeaderInfo, bTagFields: Boolean);
    function LoadFromFile(const FileName: string): Integer;
    function SaveToFile(const FileName: string): Integer;
    function AddMetaDataCoverArt({ aMetaHeader: array of Byte; }Stream: TStream; const Blocklength: Integer):
      Integer;
    function AddMetaDataOther(aMetaHeader: array of Byte; Stream: TStream; const Blocklength: Integer;
      BlockType: Integer): Integer;
    procedure Clear;
    function Count: Integer;
    function CoverArtCount: Integer;
    function AddTag(Name: AnsiString): TVorbisComment;
    function DeleteFrame(FrameIndex: Integer): Boolean;
    procedure DeleteAllFrames;
    function FrameExists(Name: AnsiString): Integer;
    procedure AddTextTag(Name: AnsiString; Text: string);
    function ReadFrameByNameAsText(Name: AnsiString): string;
    function ReadFrameByNameAsList(Name: AnsiString; var List: TStrings): Boolean;
    procedure SetTextFrameText(Name: AnsiString; Text: string);
    procedure SetListFrameText(Name: AnsiString; List: TStrings);
    function DeleteFrameByName(Name: AnsiString): Boolean;
    function GetCoverArt(Index: Integer; PictureStream: TStream; var FlacTagCoverArtInfo:
      TFlacTagCoverArtInfo): Boolean;
    function GetCoverArtInfo(Index: Integer; var FlacTagCoverArtInfo: TFlacTagCoverArtInfo): Boolean;
    function SetCoverArt(Index: Integer; PictureStream: TStream; FlacTagCoverArtInfo: TFlacTagCoverArtInfo):
      Boolean;
    function DeleteCoverArt(Index: Integer): Boolean;
    function CalculateVorbisCommentsSize: Integer;
    function CalculateMetaBlocksSize(IncludePadding: Boolean): Integer;
    function CalculateTagSize(IncludePadding: Boolean): Integer;
    function Assign(FlacTag: TFlacTag): Boolean;
    property Channels: Byte read FChannels; // Number of channels
    property SampleRate: Integer read FSampleRate; // Sample rate (hz)
    property BitsPerSample: Byte read FBitsPerSample; // Bits per sample
    property FileLength: Integer read FFileLength; // File length (bytes)
    property Samples: Int64 read FSamples; // Number of samples
    property Valid: Boolean read FIsValid; // True if header valid
    property Duration: Double read FGetDuration; // Duration (seconds)
    property Ratio: Double read FGetRatio; // Compression ratio (%)
    property Bitrate: Integer read FBitrate;
    property ChannelMode: string read FGetChannelMode;
    property Exists: Boolean read FExists;
    property AudioOffset: Integer read FAudioOffset; // offset of audio data
    property VCOffset: Integer read FVCOffset;
  end;

function RemoveFlacTagFromFile(const FileName: string): Integer;
function FlacTagErrorCode2String(ErrorCode: Integer): string;

const
  // CRC table for checksum calculating
  CRC_TABLE: array[0..$FF] of Cardinal = ($00000000, $04C11DB7, $09823B6E, $0D4326D9, $130476DC, $17C56B6B,
    $1A864DB2,
    $1E475005, $2608EDB8, $22C9F00F, $2F8AD6D6, $2B4BCB61, $350C9B64, $31CD86D3, $3C8EA00A, $384FBDBD,
    $4C11DB70, $48D0C6C7,
    $4593E01E, $4152FDA9, $5F15ADAC, $5BD4B01B, $569796C2, $52568B75, $6A1936C8, $6ED82B7F, $639B0DA6,
    $675A1011, $791D4014,
    $7DDC5DA3, $709F7B7A, $745E66CD, $9823B6E0, $9CE2AB57, $91A18D8E, $95609039, $8B27C03C, $8FE6DD8B,
    $82A5FB52, $8664E6E5,
    $BE2B5B58, $BAEA46EF, $B7A96036, $B3687D81, $AD2F2D84, $A9EE3033, $A4AD16EA, $A06C0B5D, $D4326D90,
    $D0F37027, $DDB056FE,
    $D9714B49, $C7361B4C, $C3F706FB, $CEB42022, $CA753D95, $F23A8028, $F6FB9D9F, $FBB8BB46, $FF79A6F1,
    $E13EF6F4, $E5FFEB43,
    $E8BCCD9A, $EC7DD02D, $34867077, $30476DC0, $3D044B19, $39C556AE, $278206AB, $23431B1C, $2E003DC5,
    $2AC12072, $128E9DCF,
    $164F8078, $1B0CA6A1, $1FCDBB16, $018AEB13, $054BF6A4, $0808D07D, $0CC9CDCA, $7897AB07, $7C56B6B0,
    $71159069, $75D48DDE,
    $6B93DDDB, $6F52C06C, $6211E6B5, $66D0FB02, $5E9F46BF, $5A5E5B08, $571D7DD1, $53DC6066, $4D9B3063,
    $495A2DD4, $44190B0D,
    $40D816BA, $ACA5C697, $A864DB20, $A527FDF9, $A1E6E04E, $BFA1B04B, $BB60ADFC, $B6238B25, $B2E29692,
    $8AAD2B2F, $8E6C3698,
    $832F1041, $87EE0DF6, $99A95DF3, $9D684044, $902B669D, $94EA7B2A, $E0B41DE7, $E4750050, $E9362689,
    $EDF73B3E, $F3B06B3B,
    $F771768C, $FA325055, $FEF34DE2, $C6BCF05F, $C27DEDE8, $CF3ECB31, $CBFFD686, $D5B88683, $D1799B34,
    $DC3ABDED, $D8FBA05A,
    $690CE0EE, $6DCDFD59, $608EDB80, $644FC637, $7A089632, $7EC98B85, $738AAD5C, $774BB0EB, $4F040D56,
    $4BC510E1, $46863638,
    $42472B8F, $5C007B8A, $58C1663D, $558240E4, $51435D53, $251D3B9E, $21DC2629, $2C9F00F0, $285E1D47,
    $36194D42, $32D850F5,
    $3F9B762C, $3B5A6B9B, $0315D626, $07D4CB91, $0A97ED48, $0E56F0FF, $1011A0FA, $14D0BD4D, $19939B94,
    $1D528623, $F12F560E,
    $F5EE4BB9, $F8AD6D60, $FC6C70D7, $E22B20D2, $E6EA3D65, $EBA91BBC, $EF68060B, $D727BBB6, $D3E6A601,
    $DEA580D8, $DA649D6F,
    $C423CD6A, $C0E2D0DD, $CDA1F604, $C960EBB3, $BD3E8D7E, $B9FF90C9, $B4BCB610, $B07DABA7, $AE3AFBA2,
    $AAFBE615, $A7B8C0CC,
    $A379DD7B, $9B3660C6, $9FF77D71, $92B45BA8, $9675461F, $8832161A, $8CF30BAD, $81B02D74, $857130C3,
    $5D8A9099, $594B8D2E,
    $5408ABF7, $50C9B640, $4E8EE645, $4A4FFBF2, $470CDD2B, $43CDC09C, $7B827D21, $7F436096, $7200464F,
    $76C15BF8, $68860BFD,
    $6C47164A, $61043093, $65C52D24, $119B4BE9, $155A565E, $18197087, $1CD86D30, $029F3D35, $065E2082,
    $0B1D065B, $0FDC1BEC,
    $3793A651, $3352BBE6, $3E119D3F, $3AD08088, $2497D08D, $2056CD3A, $2D15EBE3, $29D4F654, $C5A92679,
    $C1683BCE, $CC2B1D17,
    $C8EA00A0, $D6AD50A5, $D26C4D12, $DF2F6BCB, $DBEE767C, $E3A1CBC1, $E760D676, $EA23F0AF, $EEE2ED18,
    $F0A5BD1D, $F464A0AA,
    $F9278673, $FDE69BC4, $89B8FD09, $8D79E0BE, $803AC667, $84FBDBD0, $9ABC8BD5, $9E7D9662, $933EB0BB,
    $97FFAD0C, $AFB010B1,
    $AB710D06, $A6322BDF, $A2F33668, $BCB4666D, $B8757BDA, $B5365D03, $B1F740B4);

var
  FlacTagLibraryDefaultPaddingSizeToWrite: Cardinal = DEFAULT_PADDING_SIZE;

implementation

function ReverseBytes(Value: Cardinal): Cardinal;
begin
  Result := (Value shr 24) or (Value shl 24) or ((Value and $00FF0000) shr 8) or ((Value and $0000FF00) shl
    8);
end;

procedure UnSyncSafe(var Source; const SourceSize: Integer; var Dest: Cardinal);
type
  TBytes = array[0..MaxInt - 1] of Byte;
var
  I: Byte;
begin
  { Test : Source = $01 $80 -> Dest = 255
    Source = $02 $00 -> Dest = 256
    Source = $02 $01 -> Dest = 257 etc.
  }
  Dest := 0;
  for I := 0 to SourceSize - 1 do
  begin
    Dest := Dest shl 7;
    Dest := Dest or (TBytes(Source)[I] and $7F); // $7F = %01111111
  end;
end;

function GetID3v2Size(const Source: TStream): Cardinal;
type
  ID3v2Header = packed record
    ID: array[1..3] of ANSIChar;
    Version: Byte;
    Revision: Byte;
    Flags: Byte;
    Size: Cardinal;
  end;
var
  Header: ID3v2Header;
begin
  // Get ID3v2 tag size (if exists)
  Result := 0;
  Source.Seek(0, soFromBeginning);
  Source.Read(Header, SizeOf(ID3v2Header));
  if Header.ID = 'ID3' then
  begin
    UnSyncSafe(Header.Size, 4, Result);
    Inc(Result, 10);
    if Result > Source.Size then
    begin
      Result := 0;
    end;
  end;
end;

{
  procedure SetBlockSizeHeader(MetaDataBlockHeader: TMetaDataBlockHeader; BlockSize: Integer);
  begin
  MetaDataBlockHeader[2] := Byte((BlockSize SHR 16 ) AND 255 );
  MetaDataBlockHeader[3] := Byte((BlockSize SHR 8 ) AND 255 );
  MetaDataBlockHeader[4] := Byte(BlockSize AND 255 );
  end;
}

(* -------------------------------------------------------------------------- *)

procedure CalculateCRC(var CRC: Cardinal; const Data; Size: Cardinal);
var
  Buffer: ^Byte;
  Index: Cardinal;
begin
  // Calculate CRC through data
  Buffer := Addr(Data);
  for Index := 1 to Size do
  begin
    CRC := (CRC shl 8) xor CRC_TABLE[((CRC shr 24) and $FF) xor Buffer^];
    Inc(Buffer);
  end;
end;

function SetCRC(const Destination: TStream; Header: TOggHeader): Boolean;
var
  Index: Integer;
  Value: Cardinal;
  Data: array[1..$FF] of Byte;
begin
  // Calculate and set checksum for OGG frame
  Result := False;
  Value := 0;
  CalculateCRC(Value, Header, Header.Segments + 27);
  Destination.Seek(Header.Segments + 27, soFromBeginning);
  for Index := 1 to Header.Segments do
  begin
    if Header.LacingValues[Index] > 0 then
    begin
      Destination.Read(Data, Header.LacingValues[Index]);
      CalculateCRC(Value, Data, Header.LacingValues[Index]);
    end;
  end;
  Destination.Seek(22, soFromBeginning);
  Destination.Write(Value, SizeOf(Value));
  Result := True;
end;

constructor TOGGStream.Create(SourceStream: TStream);
var
  PreviousPosition: Int64;
begin
  FStream := SourceStream;
  try
    if Assigned(SourceStream) then
    begin
      PreviousPosition := FStream.Position;
      FStream.Read(FirstOGGHeader, SizeOf(TOggHeader));
      FStream.Seek(PreviousPosition, soBeginning);
    end;
  except
    // *
  end;
end;

function GetPageDataSize(Header: TOggHeader): Integer;
var
  I: Integer;
begin
  Result := 0;
  I := 1;
  repeat
    Result := Result + Header.LacingValues[I];
    Inc(I);
  until I > Header.Segments;
end;

function GetPageHeaderSize(Header: TOggHeader): Integer;
begin
  Result := 27 + Header.Segments;
end;

function GetPageSize(Header: TOggHeader): Integer;
begin
  Result := GetPageHeaderSize(Header) + GetPageDataSize(Header);
end;

function TOGGStream.GetPage(PageNumber: Int64; Stream: TStream): Boolean;
var
  Header: TOggHeader;
  PageCounter: Int64;
  DataSize: Integer;
  PageSize: Integer;
  // PageHeaderSize: Integer;
begin
  Result := False;
  try
    LastPageQueried := PageNumber;
    PageCounter := 0;
    FStream.Seek(0, soBeginning);
    repeat
      FillChar(Header, SizeOf(TOggHeader), 0);
      FStream.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
      FStream.Read(Header.LacingValues, Header.Segments);
      PageSize := GetPageSize(Header);
      // PageHeaderSize := GetPageHeaderSize(Header);
      DataSize := GetPageDataSize(Header);
      Inc(PageCounter);
      if PageCounter = PageNumber then
      begin
        FStream.Seek(-(SizeOf(TOggHeader) - SizeOf(Header.LacingValues)) - Header.Segments, soCurrent);
        Stream.CopyFrom(FStream, PageSize);
        Result := True;
        Break;
      end
      else
      begin
        FStream.Seek(DataSize, soCurrent);
      end;
    until FStream.Position = FStream.Size;
  except
    Result := False;
  end;
end;

function TOGGStream.GetPageData(PageNumber: Int64; Stream: TStream): Boolean;
var
  Header: TOggHeader;
  PageCounter: Int64;
  DataSize: Integer;
  // PageHeaderSize: Integer;
begin
  Result := False;
  try
    LastPageQueried := PageNumber;
    PageCounter := 0;
    FStream.Seek(0, soBeginning);
    repeat
      FillChar(Header, SizeOf(TOggHeader), 0);
      FStream.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
      FStream.Read(Header.LacingValues, Header.Segments);
      DataSize := GetPageDataSize(Header);
      // PageHeaderSize := GetPageHeaderSize(Header);
      Inc(PageCounter);
      if PageCounter = PageNumber then
      begin
        Stream.CopyFrom(FStream, DataSize);
        Result := True;
        Break;
      end
      else
      begin
        FStream.Seek(DataSize, soCurrent);
      end;
    until FStream.Position = FStream.Size;
  except
    Result := False;
  end;
end;

function TOGGStream.GetNextPageHeader(var Header: TOggHeader): Boolean;
var
  // DataSize: Integer;
  PageSize: Integer;
  // PageHeaderSize: Integer;
begin
  try
    FillChar(Header, SizeOf(TOggHeader), 0);
    FStream.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
    FStream.Read(Header.LacingValues, Header.Segments);
    PageSize := GetPageSize(Header);
    // PageHeaderSize := GetPageHeaderSize(Header);
    // DataSize := GetPageDataSize(Header);
    FStream.Seek(-(SizeOf(TOggHeader) - SizeOf(Header.LacingValues)) - Header.Segments, soCurrent);
    FStream.Seek(PageSize, soCurrent);
    Inc(LastPageQueried);
    Result := True;
  except
    Result := False;
  end;
end;

function TOGGStream.GetNextPage(Stream: TStream): Boolean;
var
  Header: TOggHeader;
  // DataSize: Integer;
  PageSize: Integer;
  // PageHeaderSize: Integer;
begin
  try
    FillChar(Header, SizeOf(TOggHeader), 0);
    FStream.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
    FStream.Read(Header.LacingValues, Header.Segments);
    PageSize := GetPageSize(Header);
    // PageHeaderSize := GetPageHeaderSize(Header);
    // DataSize := GetPageDataSize(Header);
    FStream.Seek(-(SizeOf(TOggHeader) - SizeOf(Header.LacingValues)) - Header.Segments, soCurrent);
    Stream.CopyFrom(FStream, PageSize);
    Inc(LastPageQueried);
    Result := True;
  except
    Result := False;
  end;
end;

function TOGGStream.GetNextPageData(Stream: TStream): Boolean;
var
  Header: TOggHeader;
  DataSize: Integer;
  // PageHeaderSize: Integer;
begin
  try
    FillChar(Header, SizeOf(TOggHeader), 0);
    FStream.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
    FStream.Read(Header.LacingValues, Header.Segments);
    DataSize := GetPageDataSize(Header);
    // PageHeaderSize := GetPageHeaderSize(Header);
    Stream.CopyFrom(FStream, DataSize);
    Inc(LastPageQueried);
    Result := True;
  except
    Result := False;
  end;
end;

function TOGGStream.CreateTagStream(TagStream: TStream; OutputOGGStream: TStream): Integer;
var
  Header: TOggHeader;
  DataSize: Integer;
  I: Integer;
  OGGPage: TMemoryStream;
begin
  try
    Result := 0;
    Header := FirstOGGHeader;
    Header.TypeFlag := 0;
    Header.AbsolutePosition := 0 { - 1 };
    Header.PageNumber := 1;
    Header.Checksum := 0;
    OGGPage := TMemoryStream.Create;
    try
      while TagStream.Position < TagStream.Size do
      begin
        FillChar(Header.LacingValues, SizeOf(Header.LacingValues), 0);
        if TagStream.Size - TagStream.Position > OGG_PAGE_SEGMENT_SIZE * High(Byte) then
        begin
          DataSize := OGG_PAGE_SEGMENT_SIZE * High(Byte);
          Header.Segments := OGG_PAGE_SEGMENT_SIZE;
          for I := 1 to High(Header.LacingValues) do
          begin
            Header.LacingValues[I] := $FF;
          end;
        end
        else
        begin
          DataSize := TagStream.Size - TagStream.Position;
          if DataSize mod $FF = 0 then
          begin
            Header.Segments := DataSize div $FF;
          end
          else
          begin
            Header.Segments := (DataSize div $FF) + 1;
          end;
          for I := 1 to Header.Segments do
          begin
            Header.LacingValues[I] := $FF;
          end;
          if DataSize mod $FF <> 0 then
          begin
            Header.LacingValues[Header.Segments] := (DataSize mod $FF);
          end;
        end;
        OGGPage.Clear;
        OGGPage.Write(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
        OGGPage.Write(Header.LacingValues, Header.Segments);
        OGGPage.CopyFrom(TagStream, DataSize);
        OGGPage.Seek(0, soBeginning);
        SetCRC(OGGPage, Header);
        OGGPage.Seek(0, soBeginning);
        OutputOGGStream.CopyFrom(OGGPage, OGGPage.Size);
        Header.TypeFlag := 1;
        Header.Checksum := 0;
        Inc(Header.PageNumber);
        Inc(Result);
      end;
    finally
      FreeAndNil(OGGPage);
    end;
  except
    Result := 0;
  end;
end;

function TOGGStream.CalculateWrappedStreamSize(InputDataSize: Integer): Integer;
var
  Header: TOggHeader;
  DataSize: Integer;
  I: Integer;
  DataLeft: Integer;
begin
  try
    Result := 0;
    DataLeft := InputDataSize;
    while DataLeft > 0 do
    begin
      if DataLeft > OGG_PAGE_SEGMENT_SIZE * High(Byte) then
      begin
        DataSize := OGG_PAGE_SEGMENT_SIZE * High(Byte);
        Header.Segments := OGG_PAGE_SEGMENT_SIZE;
      end
      else
      begin
        DataSize := DataLeft;
        if DataSize mod $FF = 0 then
        begin
          Header.Segments := DataSize div $FF;
        end
        else
        begin
          Header.Segments := (DataSize div $FF) + 1;
        end;
      end;
      Inc(Result, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
      Inc(Result, Header.Segments);
      Inc(Result, DataSize);
      Dec(DataLeft, DataSize);
    end;
  except
    Result := 0;
  end;
end;

function TOGGStream.ReNumberPages(StartPageNumber: Int64; EndingPageNumber: Int64; Destination: TStream):
  Boolean;
var
  Header: TOggHeader;
  OGGPage: TMemoryStream;
  PageCounter: Int64;
  DestinationPosition: Int64;
begin
  try
    Result := False;
    FillChar(Header, SizeOf(TOggHeader), 0);
    PageCounter := StartPageNumber;
    OGGPage := TMemoryStream.Create;
    try
      while (Destination.Position < Destination.Size) or (FStream.Position < FStream.Size) do
      begin
        DestinationPosition := Destination.Position;
        OGGPage.Clear;
        GetNextPage(OGGPage);
        OGGPage.Seek(0, soBeginning);
        OGGPage.Read(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
        OGGPage.Read(Header.LacingValues, Header.Segments);
        OGGPage.Seek(0, soBeginning);
        Header.PageNumber := PageCounter;
        Header.Checksum := 0;
        OGGPage.Write(Header, SizeOf(TOggHeader) - SizeOf(Header.LacingValues));
        OGGPage.Seek(0, soBeginning);
        SetCRC(OGGPage, Header);
        OGGPage.Seek(0, soBeginning);
        Destination.Seek(DestinationPosition, soBeginning);
        Destination.CopyFrom(OGGPage, OGGPage.Size);
        Inc(PageCounter);
        if EndingPageNumber <> -1 then
        begin
          if PageCounter > EndingPageNumber then
          begin
            Break;
          end;
        end;
      end;
      Result := True;
    finally
      FreeAndNil(OGGPage);
    end;
  except
    Result := False;
  end;
end;

(* -------------------------------------------------------------------------- *)

constructor TVorbisComment.Create;
begin
  inherited;
  Name := '';
  Format := vcfUnknown;
  Stream := TMemoryStream.Create;
end;

function TVorbisComment.Delete: Boolean;
begin
  Result := Parent.DeleteFrame(Index);
end;

destructor TVorbisComment.Destroy;
begin
  FreeAndNil(Stream);
  inherited;
end;

function TVorbisComment.GetAsText: string;
var
  I: Integer;
  Data: Byte;
  AnsiStr: AnsiString;
begin
  Result := '';
  if Format <> vcfText then
  begin
    Exit;
  end;
  Stream.Seek(0, soBeginning);
  for I := 0 to Stream.Size - 1 do
  begin
    Stream.Read(Data, 1);
    if Data <> 0 then
    begin
      AnsiStr := AnsiStr + ANSIChar(Data);
    end;
  end;
  Stream.Seek(0, soBeginning);
  Result := UTF8Decode(AnsiStr);
end;

function TVorbisComment.SetAsText(Text: string): Boolean;
var
  AnsiStr: AnsiString;
begin
  Result := False;
  if Text <> '' then
  begin
    AnsiStr := UTF8Encode(Text);
    Stream.Clear;
    Stream.Write(Pointer(AnsiStr)^, Length(AnsiStr));
    Stream.Seek(0, soBeginning);
    Format := vcfText;
    Result := True;
  end
  else
  begin
    Result := Delete;
  end;
end;

function TVorbisComment.SetAsList(List: TStrings): Boolean;
var
  I: Integer;
  Data: Byte;
  Name: AnsiString;
  Value: AnsiString;
begin
  Result := False;
  Stream.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Name := UTF8Encode(List.Names[I]);
    Value := UTF8Encode(List.ValueFromIndex[I]);
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
  Format := vcfText;
  Result := True;
end;

function TVorbisComment.GetAsList(var List: TStrings): Boolean;
var
  Data: Byte;
  AnsiStr: AnsiString;
  Name: string;
  Value: string;
begin
  Result := False;
  List.Clear;
  if Format <> vcfText then
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
      AnsiStr := AnsiStr + ANSIChar(Data);
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
      AnsiStr := AnsiStr + ANSIChar(Data);
    until Stream.Position >= Stream.Size;
    Value := UTF8Decode(AnsiStr);
    List.Append(Name + '=' + Value);
    Result := True;
  end;
  Stream.Seek(0, soBeginning);
end;

procedure TVorbisComment.Clear;
begin
  Format := vcfUnknown;
  Stream.Clear;
end;

function TVorbisComment.CalculateTotalFrameSize: Integer;
begin
  Result := Length(Name) + 1 + Stream.Size;
end;

function TVorbisComment.Assign(VorbisComment: TVorbisComment): Boolean;
begin
  Result := False;
  Clear;
  if VorbisComment <> nil then
  begin
    Name := VorbisComment.Name;
    Format := VorbisComment.Format;
    VorbisComment.Stream.Seek(0, soBeginning);
    Stream.CopyFrom(VorbisComment.Stream, VorbisComment.Stream.Size);
    Stream.Seek(0, soBeginning);
    VorbisComment.Stream.Seek(0, soBeginning);
  end;
  Result := True;
end;

(* -------------------------------------------------------------------------- *)

procedure TFlacTag.ResetData(const bHeaderInfo, bTagFields: Boolean);
var
  I: Integer;
begin
  if bHeaderInfo then
  begin
    FillChar(OggFlacHeader, SizeOf(TOggFlacHeader), #0);
    FileName := '';
    FPadding := 0;
    FPaddingLast := False;
    FPaddingFragments := False;
    // ForceReWrite := False;
    FChannels := 0;
    FSampleRate := 0;
    FBitsPerSample := 0;
    FFileLength := 0;
    FSamples := 0;
    FVorbisIndex := 0;
    FPaddingIndex := 0;
    FVCOffset := 0;
    FAudioOffset := 0;
    FMetaBlocksSize := 0;
    StreamType := fstUnknown;
    for I := 0 to Length(aMetaBlockOther) - 1 do
    begin
      if Assigned(aMetaBlockOther[I].Data) then
      begin
        FreeAndNil(aMetaBlockOther[I].Data);
      end;
    end;
    SetLength(aMetaBlockOther, 0);
  end;
  // tag data
  if bTagFields then
  begin
    VendorString := '';
    FTagSize := 0;
    FExists := False;
    DeleteAllFrames;
    for I := 0 to Length(MetaBlocksCoverArts) - 1 do
    begin
      if Assigned(MetaBlocksCoverArts[I].Data) then
      begin
        FreeAndNil(MetaBlocksCoverArts[I].Data);
      end;
    end;
    SetLength(MetaBlocksCoverArts, 0);
  end;
end;

(* -------------------------------------------------------------------------- *)
// Check for right FLAC file data

function TFlacTag.FIsValid: Boolean;
begin
  Result := False;
  if StreamType = fstNativeFlac then
  begin
    Result := (FHeader.StreamMarker = 'fLaC') and (FChannels > 0) and (FSampleRate > 0) and (FBitsPerSample >
      0) and
      (FSamples > 0);
  end;
  if StreamType = fstOggFlac then
  begin
    Result := (OggFlacHeader.StreamInfo.StreamMarker = 'fLaC') and (FChannels > 0) and (FSampleRate > 0) and
      (FBitsPerSample > 0)
      and (FSamples > 0);
  end;
end;

function TFlacTag.FrameExists(Name: AnsiString): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Tags) - 1 do
  begin
    if Name = Tags[I].Name then
    begin
      Result := I;
      Break;
    end;
  end;
end;

(* -------------------------------------------------------------------------- *)

function TFlacTag.FGetDuration: Double;
begin
  if (FIsValid) and (FSampleRate > 0) then
  begin
    Result := FSamples / FSampleRate;
  end
  else
  begin
    Result := 0;
  end;
end;

(* -------------------------------------------------------------------------- *)
// Get compression ratio

function TFlacTag.FGetRatio: Double;
begin
  if FIsValid then
  begin
    Result := FFileLength / (FSamples * FChannels * FBitsPerSample / 8) * 100
  end
  else
  begin
    Result := 0;
  end;
end;

(* -------------------------------------------------------------------------- *)
// Get channel mode

function TFlacTag.FGetChannelMode: string;
begin
  if FIsValid then
  begin
    case FChannels of
      1:
        Result := 'Mono';
      2:
        Result := 'Stereo';
    else
      Result := 'Multi Channel';
    end;
  end
  else
  begin
    Result := '';
  end;
end;

(* -------------------------------------------------------------------------- *)

procedure TFlacTag.Clear;
begin
  ResetData(True, True);
  FileName := '';
  Loaded := False;
  VendorString := '';
end;

function TFlacTag.Count: Integer;
begin
  Result := Length(Tags);
end;

constructor TFlacTag.Create;
begin
  inherited;
  ResetData(True, True);
  PaddingSizeToWrite := FlacTagLibraryDefaultPaddingSizeToWrite;
end;

procedure TFlacTag.DeleteAllFrames;
var
  I: Integer;
begin
  for I := 0 to Length(Tags) - 1 do
  begin
    FreeAndNil(Tags[I]);
  end;
  SetLength(Tags, 0);
end;

function TFlacTag.DeleteFrame(FrameIndex: Integer): Boolean;
var
  I: Integer;
  j: Integer;
begin
  Result := False;
  if (FrameIndex >= Length(Tags)) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  FreeAndNil(Tags[FrameIndex]);
  I := 0;
  j := 0;
  while I <= Length(Tags) - 1 do
  begin
    if Tags[I] <> nil then
    begin
      Tags[j] := Tags[I];
      Tags[j].Index := I;
      Inc(j);
    end;
    Inc(I);
  end;
  SetLength(Tags, j);
  Result := True;
end;

destructor TFlacTag.Destroy;
begin
  ResetData(True, True);
  inherited;
end;

(* -------------------------------------------------------------------------- *)

function TFlacTag.ReadFrameByNameAsList(Name: AnsiString; var List: TStrings): Boolean;
var
  I: Integer;
  l: Integer;
begin
  Result := False;
  l := Length(Tags);
  I := 0;
  while (I <> l) and (WideUpperCase(Tags[I].Name) <> WideUpperCase(Name)) do
  begin
    Inc(I);
  end;
  if I = l then
  begin
    Result := False;
  end
  else
  begin
    if Tags[I].Format = vcfText then
    begin
      Result := Tags[I].GetAsList(List);
    end;
  end;
end;

function TFlacTag.ReadFrameByNameAsText(Name: AnsiString): string;
var
  I: Integer;
  l: Integer;
begin
  Result := '';
  l := Length(Tags);
  I := 0;
  while (I <> l) and (WideUpperCase(Tags[I].Name) <> WideUpperCase(Name)) do
  begin
    Inc(I);
  end;
  if I = l then
  begin
    Result := '';
  end
  else
  begin
    if Tags[I].Format = vcfText then
    begin
      Result := Tags[I].GetAsText;
    end;
  end;
end;

function TFlacTag.LoadFromFile(const FileName: string): Integer;
begin
  // FResetData(False, True);
  Clear;
  Result := GetInfo(FileName, True);
end;

(* -------------------------------------------------------------------------- *)

function TFlacTag.GetCoverArt(Index: Integer; PictureStream: TStream; var FlacTagCoverArtInfo:
  TFlacTagCoverArtInfo): Boolean;
var
  I: Integer;
  MetaType: Byte;
  CoverIndexCounter: Integer;
  Stream: TStream;
  MIMETypeLength: Cardinal;
  DataByte: Byte;
  DescriptionUTF8: AnsiString;
  DescriptionLength: Cardinal;
  LengthOfPictureData: Cardinal;
begin
  Result := False;
  with FlacTagCoverArtInfo do
  begin
    PictureType := 0;
    MIMEType := '';
    Description := '';
    Width := 0;
    Height := 0;
    ColorDepth := 0;
    NoOfColors := 0;
    SizeOfPictureData := 0;
  end;
  if (Index < 0) or (Index >= Length(MetaBlocksCoverArts)) then
  begin
    Exit;
  end;
  Stream := MetaBlocksCoverArts[Index].Data;
  Stream.Seek(0, soBeginning);
  with FlacTagCoverArtInfo do
  begin
    Stream.Read(PictureType, 4);
    PictureType := ReverseBytes(PictureType);
    Stream.Read(MIMETypeLength, 4);
    MIMETypeLength := ReverseBytes(MIMETypeLength);
    for I := 0 to MIMETypeLength - 1 do
    begin
      Stream.Read(DataByte, 1);
      MIMEType := MIMEType + ANSIChar(DataByte);
    end;
    Stream.Read(DescriptionLength, 4);
    DescriptionLength := ReverseBytes(DescriptionLength);
    for I := 0 to DescriptionLength - 1 do
    begin
      Stream.Read(DataByte, 1);
      DescriptionUTF8 := DescriptionUTF8 + ANSIChar(DataByte);
    end;
    Description := UTF8Decode(DescriptionUTF8);
    Stream.Read(Width, 4);
    Width := ReverseBytes(Width);
    Stream.Read(Height, 4);
    Height := ReverseBytes(Height);
    Stream.Read(ColorDepth, 4);
    ColorDepth := ReverseBytes(ColorDepth);
    Stream.Read(NoOfColors, 4);
    NoOfColors := ReverseBytes(NoOfColors);
    Stream.Read(LengthOfPictureData, 4);
    LengthOfPictureData := ReverseBytes(LengthOfPictureData);
    SizeOfPictureData := LengthOfPictureData;
    PictureStream.CopyFrom(Stream, LengthOfPictureData);
    PictureStream.Seek(0, soBeginning);
  end;
  Result := True;
end;

function TFlacTag.GetCoverArtInfo(Index: Integer; var FlacTagCoverArtInfo: TFlacTagCoverArtInfo): Boolean;
var
  I: Integer;
  MetaType: Byte;
  CoverIndexCounter: Integer;
  Stream: TStream;
  MIMETypeLength: Cardinal;
  DataByte: Byte;
  DescriptionUTF8: AnsiString;
  DescriptionLength: Cardinal;
begin
  Result := False;
  with FlacTagCoverArtInfo do
  begin
    PictureType := 0;
    MIMEType := '';
    Description := '';
    Width := 0;
    Height := 0;
    ColorDepth := 0;
    NoOfColors := 0;
    SizeOfPictureData := 0;
  end;
  if (Index < 0) or (Index >= Length(MetaBlocksCoverArts)) then
  begin
    Exit;
  end;
  with FlacTagCoverArtInfo do
  begin
    Stream := MetaBlocksCoverArts[Index].Data;
    Stream.Seek(0, soBeginning);
    Stream.Read(PictureType, 4);
    PictureType := ReverseBytes(PictureType);
    Stream.Read(MIMETypeLength, 4);
    MIMETypeLength := ReverseBytes(MIMETypeLength);
    for I := 0 to MIMETypeLength - 1 do
    begin
      Stream.Read(DataByte, 1);
      MIMEType := MIMEType + ANSIChar(DataByte);
    end;
    Stream.Read(DescriptionLength, 4);
    DescriptionLength := ReverseBytes(DescriptionLength);
    for I := 0 to DescriptionLength - 1 do
    begin
      Stream.Read(DataByte, 1);
      DescriptionUTF8 := DescriptionUTF8 + ANSIChar(DataByte);
    end;
    Description := UTF8Decode(DescriptionUTF8);
    Stream.Read(Width, 4);
    Width := ReverseBytes(Width);
    Stream.Read(Height, 4);
    Height := ReverseBytes(Height);
    Stream.Read(ColorDepth, 4);
    ColorDepth := ReverseBytes(ColorDepth);
    Stream.Read(NoOfColors, 4);
    NoOfColors := ReverseBytes(NoOfColors);
    Stream.Read(SizeOfPictureData, 4);
    SizeOfPictureData := ReverseBytes(SizeOfPictureData);
  end;
  Result := True;
end;

function TFlacTag.SetCoverArt(Index: Integer; PictureStream: TStream; FlacTagCoverArtInfo:
  TFlacTagCoverArtInfo): Boolean;
var
  I: Integer;
  MetaType: Byte;
  Stream: TMemoryStream;
  MIMETypeLength: Cardinal;
  DataByte: Byte;
  DescriptionUTF8: AnsiString;
  DescriptionLength: Cardinal;
  LengthOfPictureData: Cardinal;
begin
  Result := False;
  if (Index < 0) or (Index >= Length(MetaBlocksCoverArts)) then
  begin
    Exit;
  end;
  Stream := MetaBlocksCoverArts[Index].Data;
  Stream.Clear;
  Stream.Seek(0, soBeginning);
  with FlacTagCoverArtInfo do
  begin
    PictureType := ReverseBytes(PictureType);
    Stream.Write(PictureType, 4);
    MIMETypeLength := Length(MIMEType);
    MIMETypeLength := ReverseBytes(MIMETypeLength);
    Stream.Write(MIMETypeLength, 4);
    Stream.Write(Pointer(MIMEType)^, Length(MIMEType));
    DescriptionUTF8 := UTF8Encode(Description);
    DescriptionLength := Length(DescriptionUTF8);
    DescriptionLength := ReverseBytes(DescriptionLength);
    Stream.Write(DescriptionLength, 4);
    Stream.Write(Pointer(DescriptionUTF8)^, Length(DescriptionUTF8));
    Width := ReverseBytes(Width);
    Stream.Write(Width, 4);
    Height := ReverseBytes(Height);
    Stream.Write(Height, 4);
    ColorDepth := ReverseBytes(ColorDepth);
    Stream.Write(ColorDepth, 4);
    NoOfColors := ReverseBytes(NoOfColors);
    Stream.Write(NoOfColors, 4);
    LengthOfPictureData := PictureStream.Size;
    LengthOfPictureData := ReverseBytes(LengthOfPictureData);
    Stream.Write(LengthOfPictureData, 4);
    PictureStream.Seek(0, soBeginning);
    Stream.CopyFrom(PictureStream, PictureStream.Size);
    PictureStream.Seek(0, soBeginning);
  end;
  with MetaBlocksCoverArts[Index] do
  begin
    MetaDataBlockHeader[1] := META_COVER_ART;
    MetaDataBlockHeader[2] := Byte((Data.Size shr 16) and 255);
    MetaDataBlockHeader[3] := Byte((Data.Size shr 8) and 255);
    MetaDataBlockHeader[4] := Byte(Data.Size and 255);
  end;
  Result := True;
end;

function TFlacTag.DeleteCoverArt(Index: Integer): Boolean;
var
  I: Integer;
  j: Integer;
begin
  Result := False;
  if (Index >= Length(MetaBlocksCoverArts)) or (Index < 0) then
  begin
    Exit;
  end;
  if Assigned(MetaBlocksCoverArts[Index].Data) then
  begin
    FreeAndNil(MetaBlocksCoverArts[Index].Data);
  end;
  I := 0;
  j := 0;
  while I <= Length(MetaBlocksCoverArts) - 1 do
  begin
    if MetaBlocksCoverArts[I].Data <> nil then
    begin
      MetaBlocksCoverArts[j] := MetaBlocksCoverArts[I];
      // MetaBlocksCoverArts[j].Index := i;
      Inc(j);
    end;
    Inc(I);
  end;
  SetLength(MetaBlocksCoverArts, j);
  Result := True;
end;

function TFlacTag.GetInfo(FileName: string; SetTags: Boolean): Integer;
var
  SourceFile: TFileStream;
  aMetaDataBlockHeader: array[1..4] of Byte;
  iBlockLength, iMetaType, iIndex: Integer;
  bPaddingFound: Boolean;
  ID3v2Size: Integer;
  OggHeader: TOggHeader;
  Data: TMemoryStream;
  PreviousPosition: Int64;
  OGGStream: TOGGStream;
begin
  Result := FLACTAGLIBRARY_ERROR;
  SourceFile := nil;
  bPaddingFound := False;
  ResetData(True, False);
  try
    // Set read-access and open file
    try
      SourceFile := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    except
      Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
      Exit;
    end;
    FFileLength := SourceFile.Size;
    FileName := FileName;
    { Seek past the ID3v2 tag, if there is one }
    ID3v2Size := GetID3v2Size(SourceFile);
    SourceFile.Seek(ID3v2Size, soFromBeginning);
    // Read header data
    FillChar(FHeader, SizeOf(FHeader), 0);
    SourceFile.Read(FHeader, SizeOf(FHeader));
    // Process data if loaded and header valid
    if FHeader.StreamMarker = 'fLaC' then
    begin
      StreamType := fstNativeFlac;
      with FHeader do
      begin
        FChannels := (Info[13] shr 1 and $7 + 1);
        FSampleRate := (Info[11] shl 12 or Info[12] shl 4 or Info[13] shr 4);
        FBitsPerSample := (Info[13] and 1 shl 4 or Info[14] shr 4 + 1);
        FSamples := (Info[15] shl 24 or Info[16] shl 16 or Info[17] shl 8 or Info[18]);
      end;
      if (FHeader.MetaDataBlockHeader[1] and $80) <> 0 then
      begin
        Result := FLACTAGLIBRARY_ERROR_NO_TAG_FOUND;
        Exit; // no metadata blocks exist
      end;
      iIndex := 0;
      repeat // read more metadata blocks if available
        SourceFile.Read(aMetaDataBlockHeader, 4);
        Inc(iIndex); // metadatablock index
        iBlockLength := (aMetaDataBlockHeader[2] shl 16 or aMetaDataBlockHeader[3] shl 8 or
          aMetaDataBlockHeader[4]);
        // decode length
        if iBlockLength <= 0 then
        begin
          FMetaBlocksSize := FMetaBlocksSize + 4;
          Continue;
        end;
        iMetaType := (aMetaDataBlockHeader[1] and $7F); // decode metablock type
        if iMetaType = META_VORBIS_COMMENT then
        begin // read vorbis block
          FVCOffset := SourceFile.Position;
          FTagSize := iBlockLength;
          FVorbisIndex := iIndex;
          ReadTag(SourceFile, SetTags); // set up fields
        end
        else if (iMetaType = META_PADDING) and not bPaddingFound then
        begin // we have padding block
          FPadding := iBlockLength; // if we find more skip & put them in metablock array
          FPaddingLast := ((aMetaDataBlockHeader[1] and $80) <> 0);
          FPaddingIndex := iIndex;
          bPaddingFound := True;
          SourceFile.Seek(FPadding, soCurrent); // advance into file till next block or audio data start
        end
        else
        begin // all other
          if iMetaType <= 6 then
          begin // is it a valid metablock ?
            if (iMetaType = META_PADDING) then
            begin // set flag for fragmented padding blocks
              FPaddingFragments := True;
            end;
            if iMetaType = META_COVER_ART then
            begin
              if SetTags then
              begin
                AddMetaDataCoverArt({ aMetaDataBlockHeader, }SourceFile, iBlockLength { , iIndex });
              end
              else
              begin
                SourceFile.Seek(iBlockLength, soCurrent);
              end;
            end
            else
            begin
              AddMetaDataOther(aMetaDataBlockHeader, SourceFile, iBlockLength, iMetaType);
            end;
            FMetaBlocksSize := FMetaBlocksSize + iBlockLength + 4;
          end
          else
          begin
            FSamples := 0; // ops...
            Result := FLACTAGLIBRARY_SUCCESS;
            Exit;
          end;
        end;
      until ((aMetaDataBlockHeader[1] and $80) <> 0); // until is last flag ( first bit = 1 )
      Loaded := True;
      Result := FLACTAGLIBRARY_SUCCESS;
    end
    else
    begin
      FillChar(OggHeader, SizeOf(TOggHeader), #0);
      SourceFile.Seek(ID3v2Size, soFromBeginning);
      SourceFile.Read(OggHeader, SizeOf(TOggHeader));
      if OggHeader.ID = 'OggS' then
      begin
        SourceFile.Seek(ID3v2Size + $1C, soFromBeginning);
        SourceFile.Read(OggFlacHeader, SizeOf(TOggFlacHeader));
        if (OggFlacHeader.PacketType = $7F) and (OggFlacHeader.Signature = 'FLAC') and
          (OggFlacHeader.MajorVersion = 1) and
          (OggFlacHeader.StreamInfo.StreamMarker = 'fLaC') then
        begin
          StreamType := fstOggFlac;
          with OggFlacHeader.StreamInfo do
          begin
            FChannels := (Info[13] shr 1 and $7 + 1);
            FSampleRate := (Info[11] shl 12 or Info[12] shl 4 or Info[13] shr 4);
            FBitsPerSample := (Info[13] and 1 shl 4 or Info[14] shr 4 + 1);
            FSamples := (Info[15] shl 24 or Info[16] shl 16 or Info[17] shl 8 or Info[18]);
          end;
          if (OggFlacHeader.StreamInfo.MetaDataBlockHeader[1] and $80) <> 0 then
          begin
            Result := FLACTAGLIBRARY_ERROR_NO_TAG_FOUND;
            Exit; // no metadata blocks exist
          end;
          OGGStream := TOGGStream.Create(SourceFile);
          Data := TMemoryStream.Create;
          try
            OGGStream.GetNextPageData(Data);
            Data.Seek(0, soBeginning);
            iIndex := 0;
            repeat // read more metadata blocks if available
              // * Query more data if needed
              PreviousPosition := Data.Position;
              while Data.Position + 4 > Data.Size do
              begin
                Data.Seek(0, soEnd);
                OGGStream.GetNextPageData(Data);
                Data.Seek(PreviousPosition, soBeginning);
              end;
              Data.Read(aMetaDataBlockHeader, 4);
              Inc(iIndex); // metadatablock index
              iBlockLength := (aMetaDataBlockHeader[2] shl 16 or aMetaDataBlockHeader[3] shl 8 or
                aMetaDataBlockHeader[4]);
              // decode length
              if iBlockLength <= 0 then
              begin
                FMetaBlocksSize := FMetaBlocksSize + 4;
                Continue;
              end;
              iMetaType := (aMetaDataBlockHeader[1] and $7F); // decode metablock type
              if iMetaType = META_VORBIS_COMMENT then
              begin // read vorbis block
                FVCOffset := Data.Position;
                FTagSize := iBlockLength;
                FVorbisIndex := iIndex;
                // * Query more data if needed
                PreviousPosition := Data.Position;
                while Data.Position + iBlockLength > Data.Size do
                begin
                  Data.Seek(0, soEnd);
                  OGGStream.GetNextPageData(Data);
                  Data.Seek(PreviousPosition, soBeginning);
                end;
                ReadTag(Data, SetTags); // set up fields
              end
              else if (iMetaType = META_PADDING) and not bPaddingFound then
              begin // we have padding block
                FPadding := iBlockLength; // if we find more skip & put them in metablock array
                FPaddingLast := ((aMetaDataBlockHeader[1] and $80) <> 0);
                FPaddingIndex := iIndex;
                bPaddingFound := True;
                // * Query more data if needed
                PreviousPosition := Data.Position;
                while Data.Position + FPadding > Data.Size do
                begin
                  Data.Seek(0, soEnd);
                  OGGStream.GetNextPageData(Data);
                  Data.Seek(PreviousPosition, soBeginning);
                end;
                Data.Seek(FPadding, soCurrent); // advance into file till next block or audio data start
              end
              else
              begin // all other
                if iMetaType <= 6 then
                begin // is it a valid metablock ?
                  if (iMetaType = META_PADDING) then
                  begin // set flag for fragmented padding blocks
                    FPaddingFragments := True;
                  end;
                  // * Query more data if needed
                  PreviousPosition := Data.Position;
                  while Data.Position + iBlockLength > Data.Size do
                  begin
                    Data.Seek(0, soEnd);
                    OGGStream.GetNextPageData(Data);
                    Data.Seek(PreviousPosition, soBeginning);
                  end;
                  if iMetaType = META_COVER_ART then
                  begin
                    if SetTags then
                    begin
                      AddMetaDataCoverArt({ aMetaDataBlockHeader, }Data, iBlockLength { , iIndex });
                    end
                    else
                    begin
                      Data.Seek(iBlockLength, soCurrent);
                    end;
                  end
                  else
                  begin
                    AddMetaDataOther(aMetaDataBlockHeader, Data, iBlockLength, iMetaType);
                  end;
                  FMetaBlocksSize := FMetaBlocksSize + iBlockLength + 4;
                end
                else
                begin
                  FSamples := 0; // ops...
                  Result := FLACTAGLIBRARY_SUCCESS;
                  Exit;
                end;
              end;
            until ((aMetaDataBlockHeader[1] and $80) <> 0); // until is last flag ( first bit = 1 )
            Loaded := True;
            Result := FLACTAGLIBRARY_SUCCESS;
          finally
            FreeAndNil(OGGStream);
            FreeAndNil(Data);
          end;
        end
        else
        begin
          if OggFlacHeader.MajorVersion <> 1 then
          begin
            Result := FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_VERSION;
          end
          else
          begin
            Result := FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
          end;
          Exit;
        end;
      end
      else
      begin
        Result := FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
    end;
  finally
    if FIsValid then
    begin
      FAudioOffset := SourceFile.Position; // we need that to rebuild the file if nedeed
      FBitrate := Round(((FFileLength - FAudioOffset) / 1000) * 8 / FGetDuration);
      // time to calculate average bitrate
    end
    else
    begin
      if Result = FLACTAGLIBRARY_ERROR then
      begin
        Result := FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
      end;
    end;
    if Assigned(SourceFile) then
    begin
      FreeAndNil(SourceFile);
    end;
  end;
end;

(* -------------------------------------------------------------------------- *)

function TFlacTag.AddTag(Name: AnsiString): TVorbisComment;
begin
  Result := nil;
  try
    SetLength(Tags, Length(Tags) + 1);
    Tags[Length(Tags) - 1] := TVorbisComment.Create;
    Tags[Length(Tags) - 1].Name := Name;
    Tags[Length(Tags) - 1].Index := Length(Tags) - 1;
    Tags[Length(Tags) - 1].Parent := Self;
    Result := Tags[Length(Tags) - 1];
  except
    // *
  end;
end;

procedure TFlacTag.AddTextTag(Name: AnsiString; Text: string);
begin
  AddTag(Name).SetAsText(Text);
end;

function TFlacTag.CoverArtCount: Integer;
begin
  Result := Length(MetaBlocksCoverArts);
end;

function TFlacTag.AddMetaDataCoverArt({ aMetaHeader: array of Byte; }Stream: TStream; const Blocklength:
  Integer): Integer;
var
  iMetaLen: Integer;
begin
  // enlarge array
  iMetaLen := Length(MetaBlocksCoverArts) + 1;
  SetLength(MetaBlocksCoverArts, iMetaLen);
  // save header
  MetaBlocksCoverArts[iMetaLen - 1].MetaDataBlockHeader[1] := META_COVER_ART; // aMetaHeader[0];
  // MetaBlocksCoverArts[iMetaLen - 1].MetaDataBlockHeader[2] := aMetaHeader[1];
  // MetaBlocksCoverArts[iMetaLen - 1].MetaDataBlockHeader[3] := aMetaHeader[2];
  // MetaBlocksCoverArts[iMetaLen - 1].MetaDataBlockHeader[4] := aMetaHeader[3];
  // save content in a stream
  MetaBlocksCoverArts[iMetaLen - 1].Data := TMemoryStream.Create;
  // MetaBlocksCoverArts[iMetaLen - 1].Data.Position := 0;
  if Assigned(Stream) then
  begin
    MetaBlocksCoverArts[iMetaLen - 1].Data.CopyFrom(Stream, Blocklength);
  end;
  Result := iMetaLen - 1;
end;

function TFlacTag.AddMetaDataOther(aMetaHeader: array of Byte; Stream: TStream; const Blocklength: Integer;
  BlockType: Integer): Integer;
var
  iMetaLen: Integer;
begin
  // enlarge array
  iMetaLen := Length(aMetaBlockOther) + 1;
  SetLength(aMetaBlockOther, iMetaLen);
  // save header
  aMetaBlockOther[iMetaLen - 1].MetaDataBlockHeader[1] := aMetaHeader[0];
  aMetaBlockOther[iMetaLen - 1].MetaDataBlockHeader[2] := aMetaHeader[1];
  aMetaBlockOther[iMetaLen - 1].MetaDataBlockHeader[3] := aMetaHeader[2];
  aMetaBlockOther[iMetaLen - 1].MetaDataBlockHeader[4] := aMetaHeader[3];
  // * Store type
  aMetaBlockOther[iMetaLen - 1].BlockType := BlockType;
  // save content in a stream
  aMetaBlockOther[iMetaLen - 1].Data := TMemoryStream.Create;
  aMetaBlockOther[iMetaLen - 1].Data.Position := 0;
  if Assigned(Stream) then
  begin
    aMetaBlockOther[iMetaLen - 1].Data.CopyFrom(Stream, Blocklength);
  end;
  Result := iMetaLen - 1;
end;

(* -------------------------------------------------------------------------- *)

function AnsiPos(const Substr, S: AnsiString): Integer;
var
  P: PANSIChar;
begin
  Result := 0;
  P := AnsiStrPos(PANSIChar(S), PANSIChar(Substr));
  if P <> nil then
    Result := (IntPtr(P) - IntPtr(PANSIChar(S))) div SizeOf(ANSIChar) + 1;
end;

procedure TFlacTag.ReadTag(Source: TStream; SetTagFields: Boolean);
var
  I, TagCount, DataSize, SeparatorPos: Integer;
  // Data: array [0..8192 * 4] of ANSIChar;
  Data: TMemoryStream;
  FieldName, FieldData: string;
  ZeroByte: Byte;
begin
  ZeroByte := 0;
  TagCount := 0;
  DataSize := 0;
  Data := TMemoryStream.Create;
  try
    Source.Read(DataSize, SizeOf(DataSize)); // vendor
    if DataSize > 0 then
    begin
      Data.CopyFrom(Source, DataSize);
      Data.Seek(0, soEnd);
      Data.Write(ZeroByte, 1);
      VendorString := PANSIChar(Data.Memory);
    end;
    Source.Read(TagCount, SizeOf(TagCount)); // fieldcount
    FExists := (TagCount > 0);
    for I := 0 to TagCount - 1 do
    begin
      Source.Read(DataSize, SizeOf(DataSize));
      if DataSize <= 0 then
      begin
        Continue;
      end;
      Data.Clear;
      Data.CopyFrom(Source, DataSize);
      Data.Seek(0, soEnd);
      Data.Write(ZeroByte, 1);
      if not SetTagFields then
      begin
        Continue; // if we don't want to re asign fields we skip
      end;
      SeparatorPos := AnsiPos('=', AnsiString(PANSIChar(Data.Memory)));
      if SeparatorPos > 0 then
      begin
        FieldName := UpperCase(Copy(AnsiString(PANSIChar(Data.Memory)), 1, SeparatorPos - 1));
        Data.Seek(SeparatorPos, soBeginning);
        with AddTag(FieldName) do
        begin
          Stream.CopyFrom(Data, Data.Size - SeparatorPos - 1);
          Stream.Seek(0, soBeginning);
          Format := vcfText;
        end;

      end;
    end;
  finally
    FreeAndNil(Data);
  end;
end;

(* -------------------------------------------------------------------------- *)

function TFlacTag.SaveToFile(const FileName: string): Integer;
var
  I, iFieldCount, iSize: Integer;
  VorbisBlock, Tag: TStringStream;

  procedure _WriteTagBuff(sID: AnsiString; sData: string);
  var
    sTmp: AnsiString;
    iTmp: Integer;
  begin
    if sData <> '' then
    begin
      sTmp := sID + '=' + UTF8Encode(sData);
      iTmp := Length(sTmp);
      Tag.Write(iTmp, SizeOf(iTmp));
      Tag.WriteString(sTmp);
      Inc(iFieldCount);
    end;
  end;

begin

  try
    Result := FLACTAGLIBRARY_ERROR;
    Tag := TStringStream.Create('');
    VorbisBlock := TStringStream.Create('');
    if GetInfo(FileName, False) <> FLACTAGLIBRARY_SUCCESS then
    begin
      Exit; // reload all except tag fields
    end;
    iFieldCount := 0;
    for I := 0 to Length(Tags) - 1 do
    begin
      _WriteTagBuff(Tags[I].Name, Tags[I].GetAsText);
    end;
    // Write vendor info and number of fields
    with VorbisBlock do
    begin
      if VendorString = '' then
      begin
        VendorString := 'reference libFLAC 1.1.0 20030126'; // guess it
      end;
      iSize := Length(VendorString);
      Write(iSize, SizeOf(iSize));
      WriteString(VendorString);
      Write(iFieldCount, SizeOf(iFieldCount));
    end;
    VorbisBlock.CopyFrom(Tag, 0); // All tag data is here now
    VorbisBlock.Position := 0;

    if StreamType = fstNativeFlac then
    begin
      Result := RebuildFile(FileName, VorbisBlock);
    end;
    if StreamType = fstOggFlac then
    begin
      Result := RebuildOggFile(FileName, VorbisBlock);
    end;

    FExists := (Result = FLACTAGLIBRARY_SUCCESS) and (Tag.Size > 0);
  finally
    FreeAndNil(Tag);
    FreeAndNil(VorbisBlock);
  end;
end;

procedure TFlacTag.SetListFrameText(Name: AnsiString; List: TStrings);
var
  I: Integer;
  l: Integer;
begin
  I := 0;
  l := Length(Tags);
  while (I < l) and (WideUpperCase(Tags[I].Name) <> WideUpperCase(Name)) do
  begin
    Inc(I);
  end;
  if I = l then
  begin
    AddTag(Name).SetAsList(List);
  end
  else
  begin
    Tags[I].SetAsList(List);
  end;
end;

procedure TFlacTag.SetTextFrameText(Name: AnsiString; Text: string);
var
  I: Integer;
  l: Integer;
begin
  I := 0;
  l := Length(Tags);
  while (I < l) and (WideUpperCase(Tags[I].Name) <> WideUpperCase(Name)) do
  begin
    Inc(I);
  end;
  if I = l then
  begin
    if Text <> '' then
    begin
      AddTextTag(Name, Text);
    end;
  end
  else
  begin
    Tags[I].SetAsText(Text);
  end;
end;

function TFlacTag.DeleteFrameByName(Name: AnsiString): Boolean;
var
  I: Integer;
  l: Integer;
  j: Integer;
begin
  Result := False;
  l := Length(Tags);
  I := 0;
  while (I <> l) and (WideUpperCase(Tags[I].Name) <> WideUpperCase(Name)) do
  begin
    Inc(I);
  end;
  if I = l then
  begin
    Result := False;
    Exit;
  end;
  FreeAndNil(Tags[I]);
  I := 0;
  j := 0;
  while I <= l - 1 do
  begin
    if Tags[I] <> nil then
    begin
      Tags[j] := Tags[I];
      Inc(j);
    end;
    Inc(I);
  end;
  SetLength(Tags, j);
  Result := True;
end;

(* -------------------------------------------------------------------------- *)
// saves metablocks back to the file
// always tries to rebuild header so padding exists after comment block and no more than 1 padding block exists

function TFlacTag.RebuildFile(const FileName: string; VorbisBlock: TStringStream): Integer;
var
  Source, Destination: TFileStream;
  I, iFileAge, iNewPadding, iMetaCount, iExtraPadding: Integer;
  BufferName: string;
  sTmp: AnsiString;
  MetaDataBlockHeader: array[1..4] of Byte;
  oldHeader: TFlacHeader;
  MetaBlocks: TMemoryStream;
  bRebuild, bRearange: Boolean;
  ID3v2Size: Integer;
  NewMetaBlocksSize: Integer;
begin
  Result := FLACTAGLIBRARY_ERROR;
  bRearange := False;
  iExtraPadding := 0;
  if (not FileExists(FileName))
{$IFDEF MSWINDOWS}
  or (FileSetAttr(FileName, 0) <> 0)
{$ENDIF} then
  begin
    Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    iFileAge := 0;
    if bTAG_PreserveDate then
    begin
      iFileAge := FileAge(FileName);
    end;
    NewMetaBlocksSize := CalculateMetaBlocksSize(True);

    // re arrange other metadata in case of
    // 1. padding block is not aligned after vorbis comment
    // 2. insufficient padding - rearange upon file rebuild
    // 3. fragmented padding blocks
    iMetaCount := Length(aMetaBlockOther);
    if (FPaddingIndex <> FVorbisIndex + 1) or (FPadding <= VorbisBlock.Size - FTagSize) or (FMetaBlocksSize
      <> NewMetaBlocksSize)
      or FPaddingFragments or ForceReWrite then
    begin
      MetaBlocks := TMemoryStream.Create;
      for I := 0 to Length(MetaBlocksCoverArts) - 1 do
      begin
        MetaBlocksCoverArts[I].MetaDataBlockHeader[1] := (MetaBlocksCoverArts[I].MetaDataBlockHeader[1] and
          $7F); // not last
        MetaBlocksCoverArts[I].MetaDataBlockHeader[2] := Byte((MetaBlocksCoverArts[I].Data.Size shr 16) and
          255);
        MetaBlocksCoverArts[I].MetaDataBlockHeader[3] := Byte((MetaBlocksCoverArts[I].Data.Size shr 8) and
          255);
        MetaBlocksCoverArts[I].MetaDataBlockHeader[4] := Byte(MetaBlocksCoverArts[I].Data.Size and 255);
        // SetBlockSizeHeader(MetaBlocksCoverArts[i].MetaDataBlockHeader, MetaBlocksCoverArts[i].Data.Size);
        MetaBlocksCoverArts[I].Data.Position := 0;
        MetaBlocks.Write(MetaBlocksCoverArts[I].MetaDataBlockHeader[1], 4);
        MetaBlocks.CopyFrom(MetaBlocksCoverArts[I].Data, 0);
      end;
      for I := 0 to iMetaCount - 1 do
      begin
        aMetaBlockOther[I].MetaDataBlockHeader[1] := (aMetaBlockOther[I].MetaDataBlockHeader[1] and $7F);
        // not last
        if aMetaBlockOther[I].MetaDataBlockHeader[1] = META_PADDING then
        begin
          iExtraPadding := iExtraPadding + aMetaBlockOther[I].Data.Size + 4;
          // add padding size plus 4 bytes of header block
        end
        else
        begin
          aMetaBlockOther[I].MetaDataBlockHeader[2] := Byte((aMetaBlockOther[I].Data.Size shr 16) and 255);
          aMetaBlockOther[I].MetaDataBlockHeader[3] := Byte((aMetaBlockOther[I].Data.Size shr 8) and 255);
          aMetaBlockOther[I].MetaDataBlockHeader[4] := Byte(aMetaBlockOther[I].Data.Size and 255);
          // SetBlockSizeHeader(aMetaBlockOther[i].MetaDataBlockHeader, aMetaBlockOther[i].Data.Size);
          aMetaBlockOther[I].Data.Position := 0;
          MetaBlocks.Write(aMetaBlockOther[I].MetaDataBlockHeader[1], 4);
          MetaBlocks.CopyFrom(aMetaBlockOther[I].Data, 0);
        end;
      end;
      MetaBlocks.Position := 0;
      bRearange := True;
    end;
    // set up file
    if (FPadding <= VorbisBlock.Size - FTagSize) or (FMetaBlocksSize <> NewMetaBlocksSize) then
    begin // no room rebuild the file from scratch
      bRebuild := True;
      BufferName := FileName + '~';
      try
        try
          Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
        except
          Result := FLACTAGLIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS;
          Exit;
        end;
      finally
        FreeAndNil(Source);
      end;
      try
        Source := TFileStream.Create(FileName, fmOpenRead); // Set read-only and open old file, and create new
      except
        Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
        Exit;
      end;
      try
        Destination := TFileStream.Create(BufferName, fmCreate);
      except
        Result := FLACTAGLIBRARY_ERROR_WRITING_FILE;
        Exit;
      end;
      ID3v2Size := GetID3v2Size(Source);
      Source.Seek(0, soFromBeginning);
      if ID3v2Size > 0 then
      begin
        Destination.CopyFrom(Source, ID3v2Size);
      end;
      Source.Read(oldHeader, SizeOf(oldHeader));
      oldHeader.MetaDataBlockHeader[1] := (oldHeader.MetaDataBlockHeader[1] and $7F);
      // just in case no metadata existed
      Destination.Write(oldHeader, SizeOf(oldHeader));
      Destination.CopyFrom(MetaBlocks, 0);
    end
    else
    begin
      bRebuild := False;
      Source := nil;
      try
        Destination := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
        // Set write-access and open file
      except
        Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
        Exit;
      end;
      if bRearange then
      begin
        ID3v2Size := GetID3v2Size(Destination);
        Destination.Seek(ID3v2Size, soFromBeginning);
        Destination.Seek(SizeOf(FHeader), soCurrent);
        Destination.CopyFrom(MetaBlocks, 0);
      end
      else
      begin
        Destination.Seek(FVCOffset - 4, soFromBeginning);
      end;
    end;
    // finally write vorbis block
    MetaDataBlockHeader[1] := META_VORBIS_COMMENT;
    MetaDataBlockHeader[2] := Byte((VorbisBlock.Size shr 16) and 255);
    MetaDataBlockHeader[3] := Byte((VorbisBlock.Size shr 8) and 255);
    MetaDataBlockHeader[4] := Byte(VorbisBlock.Size and 255);
    Destination.Write(MetaDataBlockHeader[1], SizeOf(MetaDataBlockHeader));
    Destination.CopyFrom(VorbisBlock, VorbisBlock.Size);
    // and add padding
    if FPaddingLast or bRearange then
    begin
      MetaDataBlockHeader[1] := META_PADDING or $80;
    end
    else
    begin
      MetaDataBlockHeader[1] := META_PADDING;
    end;
    if bRebuild then
    begin
      iNewPadding := PaddingSizeToWrite; // why not...
    end
    else
    begin
      // * TODO: check this when deleting a cover art block (FMetaBlocksSize < NewMetaBlocksSize)
      if (FTagSize + FMetaBlocksSize) > (VorbisBlock.Size + NewMetaBlocksSize) then
      begin // tag got smaller increase padding
        iNewPadding := (FPadding + (FTagSize + FMetaBlocksSize) - (VorbisBlock.Size + NewMetaBlocksSize)) +
          iExtraPadding;
      end
      else
      begin // tag got bigger shrink padding
        iNewPadding := (FPadding - (VorbisBlock.Size + NewMetaBlocksSize) + (FTagSize + FMetaBlocksSize)) +
          iExtraPadding;
      end;
    end;
    MetaDataBlockHeader[2] := Byte((iNewPadding shr 16) and 255);
    MetaDataBlockHeader[3] := Byte((iNewPadding shr 8) and 255);
    MetaDataBlockHeader[4] := Byte(iNewPadding and 255);
    Destination.Write(MetaDataBlockHeader[1], 4);
    if (FPadding <> iNewPadding) or bRearange then
    begin // fill the block with zeros
      sTmp := DupeString(#0, iNewPadding);
      Destination.Write(sTmp[1], iNewPadding);
    end;
    // finish
    if bRebuild then
    begin // time to put back the audio data...
      Source.Seek(FAudioOffset, soFromBeginning);
      Destination.CopyFrom(Source, Source.Size - FAudioOffset);
      Source.Free;
      Destination.Free;
      if (DeleteFile(FileName)) and (RenameFile(BufferName, FileName)) then
      begin // Replace old file and delete temporary file
        Result := FLACTAGLIBRARY_SUCCESS;
      end
      else
      begin
        Result := FLACTAGLIBRARY_SUCCESS;
        raise Exception.Create('');
      end;
    end
    else
    begin
      Result := FLACTAGLIBRARY_SUCCESS;
      Destination.Free;
    end;
    // post save tasks
    if bTAG_PreserveDate then
    begin
      FileSetDate(FileName, iFileAge);
    end;
    if bRearange then
    begin
      FreeAndNil(MetaBlocks);
    end;
  except
    // Access error
    if FileExists(BufferName) then
    begin
      DeleteFile(BufferName);
    end;
  end;
end;

// saves metablocks back to the file
// always tries to rebuild header so padding exists after comment block and no more than 1 padding block exists

function TFlacTag.RebuildOggFile(const FileName: string; VorbisBlock: TStringStream): Integer;
var
  Source, Destination: TFileStream;
  I, iFileAge, iNewPadding, iMetaCount: Integer;
  BufferName: string;
  sTmp: AnsiString;
  MetaDataBlockHeader: TMetaDataBlockHeader; // array[1..4] of Byte;
  oldHeader: TFlacHeader;
  MetaBlock: TMemoryStream;
  // MetaBlocks: TMemoryStream;
  Rebuild: Boolean;
  ID3v2Size: Integer;
  NewMetaBlocksSize: Integer;
  OGGStream: TOGGStream;
  OggPageCount: Integer;
  UnWrappedVorbisBlock: TStream;
  NewOGGStream: TOGGStream;
  HeaderPacketCountBE: Word;
  SourceOggStream: TFileStream;
  AvailableSpace: Int64;
  WrappedBlocks: TStream;
  WrappedPaddingSize: Int64;
  UnWrappedPaddingStream: TStream;
  OggPageHeader: TOggHeader;

  procedure AddPadding(PaddingSize: Integer);
  begin
    UnWrappedPaddingStream := TMemoryStream.Create;
    try
      // if MetaBlocks.Size = 0 then begin
      MetaDataBlockHeader[1] := META_PADDING or $80;
      // end else begin
      // MetaDataBlockHeader[1] := META_PADDING;
      // end;
      // *SetBlockSizeHeader(MetaDataBlockHeader, PaddingSize);
      MetaDataBlockHeader[2] := Byte((PaddingSize shr 16) and 255);
      MetaDataBlockHeader[3] := Byte((PaddingSize shr 8) and 255);
      MetaDataBlockHeader[4] := Byte(PaddingSize and 255);
      UnWrappedPaddingStream.Write(MetaDataBlockHeader[1], 4);
      sTmp := DupeString(#0, PaddingSize);
      UnWrappedPaddingStream.Write(sTmp[1], PaddingSize);
      UnWrappedPaddingStream.Seek(0, soBeginning);
      OggPageCount := OggPageCount + OGGStream.CreateTagStream(UnWrappedPaddingStream, WrappedBlocks);
    finally
      FreeAndNil(UnWrappedPaddingStream);
    end;
  end;

begin
  Result := FLACTAGLIBRARY_ERROR;
  Rebuild := False;
  OggPageCount := 0;
  if (not FileExists(FileName))
{$IFDEF MSWINDOWS}
  or (FileSetAttr(FileName, 0) <> 0)
{$ENDIF} then
  begin
    Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    iFileAge := 0;
    if bTAG_PreserveDate then
    begin
      iFileAge := FileAge(FileName);
    end;
    NewMetaBlocksSize := CalculateMetaBlocksSize(True);

    AvailableSpace := FAudioOffset - $4F;

    // * Create an Ogg wrapper class with the Ogg stream infos from the source file
    try
      SourceOggStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      OGGStream := TOGGStream.Create(SourceOggStream);
      FreeAndNil(SourceOggStream);
    except
      Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
      Exit;
    end;

    WrappedBlocks := TMemoryStream.Create;
    // * Set and wrap the vorbis comments block into Ogg conteiner
    UnWrappedVorbisBlock := TMemoryStream.Create;
    try
      MetaDataBlockHeader[1] := META_VORBIS_COMMENT;
      // SetBlockSizeHeader(MetaDataBlockHeader, VorbisBlock.Size);
      MetaDataBlockHeader[2] := Byte((VorbisBlock.Size shr 16) and 255);
      MetaDataBlockHeader[3] := Byte((VorbisBlock.Size shr 8) and 255);
      MetaDataBlockHeader[4] := Byte(VorbisBlock.Size and 255);
      UnWrappedVorbisBlock.Write(MetaDataBlockHeader[1], SizeOf(MetaDataBlockHeader));
      UnWrappedVorbisBlock.CopyFrom(VorbisBlock, VorbisBlock.Size);

      UnWrappedVorbisBlock.Seek(0, soBeginning);
      OggPageCount := OggPageCount + OGGStream.CreateTagStream(UnWrappedVorbisBlock, WrappedBlocks);

    finally
      FreeAndNil(UnWrappedVorbisBlock);
    end;
    // * Set and wrap cover art blocks and meta blocks into Ogg conteiner
    try
      iMetaCount := Length(aMetaBlockOther);
      MetaBlock := TMemoryStream.Create;
      try
        for I := 0 to Length(MetaBlocksCoverArts) - 1 do
        begin
          MetaBlock.Clear;
          // if (i = Length(MetaBlocksCoverArts) - 1)
          // AND (iMetaCount = 0)
          // then begin
          // MetaBlocksCoverArts[i].MetaDataBlockHeader[1] := (MetaBlocksCoverArts[i].MetaDataBlockHeader[1] OR $80); // last
          // end else begin
          MetaBlocksCoverArts[I].MetaDataBlockHeader[1] := (MetaBlocksCoverArts[I].MetaDataBlockHeader[1] and
            $7F); // not last
          // end;
          MetaBlocksCoverArts[I].MetaDataBlockHeader[2] := Byte((MetaBlocksCoverArts[I].Data.Size shr 16) and
            255);
          MetaBlocksCoverArts[I].MetaDataBlockHeader[3] := Byte((MetaBlocksCoverArts[I].Data.Size shr 8) and
            255);
          MetaBlocksCoverArts[I].MetaDataBlockHeader[4] := Byte(MetaBlocksCoverArts[I].Data.Size and 255);
          // SetBlockSizeHeader(MetaBlocksCoverArts[i].MetaDataBlockHeader, MetaBlocksCoverArts[i].Data.Size);
          MetaBlocksCoverArts[I].Data.Position := 0;
          MetaBlock.Write(MetaBlocksCoverArts[I].MetaDataBlockHeader[1], 4);
          MetaBlock.CopyFrom(MetaBlocksCoverArts[I].Data, 0);
          MetaBlock.Seek(0, soBeginning);
          OggPageCount := OggPageCount + OGGStream.CreateTagStream(MetaBlock, WrappedBlocks);
        end;
        for I := 0 to iMetaCount - 1 do
        begin
          MetaBlock.Clear;
          // if i = iMetaCount - 1 then begin
          // aMetaBlockOther[i].MetaDataBlockHeader[1] := (aMetaBlockOther[i].MetaDataBlockHeader[1] OR $80); // last
          // end else begin
          aMetaBlockOther[I].MetaDataBlockHeader[1] := (aMetaBlockOther[I].MetaDataBlockHeader[1] and $7F);
          // not last
        // end;
          if aMetaBlockOther[I].BlockType = META_PADDING then
          begin
            Continue;
          end
          else
          begin
            aMetaBlockOther[I].MetaDataBlockHeader[2] := Byte((aMetaBlockOther[I].Data.Size shr 16) and 255);
            aMetaBlockOther[I].MetaDataBlockHeader[3] := Byte((aMetaBlockOther[I].Data.Size shr 8) and 255);
            aMetaBlockOther[I].MetaDataBlockHeader[4] := Byte(aMetaBlockOther[I].Data.Size and 255);
            // SetBlockSizeHeader(aMetaBlockOther[i].MetaDataBlockHeader, aMetaBlockOther[i].Data.Size);
            aMetaBlockOther[I].Data.Position := 0;
            MetaBlock.Write(aMetaBlockOther[I].MetaDataBlockHeader[1], 4);
            MetaBlock.CopyFrom(aMetaBlockOther[I].Data, 0);
            MetaBlock.Seek(0, soBeginning);
            OggPageCount := OggPageCount + OGGStream.CreateTagStream(MetaBlock, WrappedBlocks);
          end;
        end;
      finally
        FreeAndNil(MetaBlock);
      end;

      // * Calculate size of padding
      if WrappedBlocks.Size + OGGStream.CalculateWrappedStreamSize(5) <> AvailableSpace then
      begin
        // * Add padding
        if WrappedBlocks.Size + OGGStream.CalculateWrappedStreamSize(5) < AvailableSpace then
        begin
          iNewPadding := 4;
          repeat
            Inc(iNewPadding);
            WrappedPaddingSize := OGGStream.CalculateWrappedStreamSize(iNewPadding);
          until (WrappedBlocks.Size + WrappedPaddingSize >= AvailableSpace) or (iNewPadding >
            PaddingSizeToWrite);
          if WrappedBlocks.Size + WrappedPaddingSize <> AvailableSpace then
          begin
            Rebuild := True;
          end
          else
          begin
            AddPadding(iNewPadding - 4);
          end;
          // * Re-write is needed
        end
        else
        begin
          Rebuild := True;
        end;
      end;

      // * Create a new file
      if Rebuild then
      begin
        // * Create a new padding with default size
        AddPadding(PaddingSizeToWrite);
        // * Check if the existing file can be deleted
        BufferName := FileName + '~';
        try
          try
            Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
          except
            Result := FLACTAGLIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS;
            Exit;
          end;
        finally
          FreeAndNil(Source);
        end;
        // * Open source file
        try
          Source := TFileStream.Create(FileName, fmOpenRead);
          // Set read-only and open old file, and create new
        except
          Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
          Exit;
        end;
        // * Create new destination file
        try
          Destination := TFileStream.Create(BufferName, fmCreate);
        except
          Result := FLACTAGLIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
        // * Copy ID3v2 if theres one
        ID3v2Size := GetID3v2Size(Source);
        Source.Seek(0, soFromBeginning);
        if ID3v2Size > 0 then
        begin
          Destination.CopyFrom(Source, ID3v2Size);
        end;
        // * Copy STREAMINFO block (wrapped in Ogg)
        Destination.CopyFrom(Source, $4F);

        // * Use the existing file
      end
      else
      begin

        Source := nil;
        try
          Destination := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
          // Set write-access and open file
        except
          Result := FLACTAGLIBRARY_ERROR_OPENING_FILE;
          Exit;
        end;
        ID3v2Size := GetID3v2Size(Destination);

      end;

      // * Set STREAMINFO block
      Destination.Seek(ID3v2Size + $1C, soFromBeginning);
      Destination.Read(OggFlacHeader, SizeOf(TOggFlacHeader));
      OggFlacHeader.StreamInfo.MetaDataBlockHeader[1] := (OggFlacHeader.StreamInfo.MetaDataBlockHeader[1] and
        $7F);
      // just in case no metadata existed
      OggFlacHeader.NumberOfHeaderPackets := Swap(OggPageCount);
      Destination.Seek(ID3v2Size + $1C, soFromBeginning);
      Destination.Write(OggFlacHeader, SizeOf(TOggFlacHeader));

      // * Copy the new meta data block pack
      Destination.CopyFrom(WrappedBlocks, 0);

      // * Re-number the meta data block Ogg headers
      Destination.Seek(ID3v2Size, soBeginning);
      NewOGGStream := TOGGStream.Create(Destination);
      NewOGGStream.ReNumberPages(0, OggPageCount, Destination);
      NewOGGStream.Free;

      // * Re-number remaining (audio) pages if needed
      if Rebuild then
      begin
        Source.Seek(FAudioOffset, soBeginning);
        NewOGGStream := TOGGStream.Create(Source);
        NewOGGStream.ReNumberPages(OggPageCount + 1, -1, Destination);
        NewOGGStream.Free;
      end
      else
      begin
        Destination.Seek(ID3v2Size, soBeginning);
        NewOGGStream := TOGGStream.Create(Destination);
        Destination.Seek(ID3v2Size + $4F + WrappedBlocks.Size, soFromBeginning);
        NewOGGStream.GetNextPageHeader(OggPageHeader);
        if (OggPageHeader.PageNumber <> OggPageCount + 1) then
        begin
          Destination.Seek(ID3v2Size + $4F + WrappedBlocks.Size, soFromBeginning);
          NewOGGStream.ReNumberPages(OggPageCount + 1, -1, Destination);
        end;
        NewOGGStream.Free;
      end;

      if Assigned(Source) then
      begin
        FreeAndNil(Source);
      end;
      if Assigned(Destination) then
      begin
        FreeAndNil(Destination);
      end;

      Result := FLACTAGLIBRARY_SUCCESS;

    finally
      FreeAndNil(OGGStream);
      FreeAndNil(WrappedBlocks);
    end;

    if Rebuild then
    begin
      if not DeleteFile(FileName) then
      begin
        // Replace old file and delete temporary file
        raise Exception.Create('Error deleting existing file: ' + FileName);
      end;
      RenameFile(BufferName, FileName);
    end;

    // post save tasks
    if bTAG_PreserveDate then
    begin
      FileSetDate(FileName, iFileAge);
    end;
  except
    // Access error
    if FileExists(BufferName) then
    begin
      DeleteFile(BufferName);
    end;
  end;
end;

function TFlacTag.CalculateVorbisCommentsSize: Integer;
var
  I, iFieldCount, iSize: Integer;
  VorbisBlock, Tag: TStringStream;

  procedure _WriteTagBuff(sID: AnsiString; sData: string);
  var
    sTmp: AnsiString;
    iTmp: Integer;
  begin
    if sData <> '' then
    begin
      sTmp := sID + '=' + UTF8Encode(sData);
      iTmp := Length(sTmp);
      Tag.Write(iTmp, SizeOf(iTmp));
      Tag.WriteString(sTmp);
      Inc(iFieldCount);
    end;
  end;

begin

  try
    Result := 0;
    Tag := TStringStream.Create('');
    VorbisBlock := TStringStream.Create('');
    iFieldCount := 0;
    for I := 0 to Length(Tags) - 1 do
    begin
      _WriteTagBuff(Tags[I].Name, Tags[I].GetAsText);
    end;
    // Write vendor info and number of fields
    with VorbisBlock do
    begin
      if VendorString = '' then
      begin
        VendorString := 'reference libFLAC 1.1.0 20030126'; // guess it
      end;
      iSize := Length(VendorString);
      Write(iSize, SizeOf(iSize));
      WriteString(VendorString);
      Write(iFieldCount, SizeOf(iFieldCount));
    end;
    VorbisBlock.CopyFrom(Tag, 0); // All tag data is here now
    VorbisBlock.Position := 0;
    Result := VorbisBlock.Size;
  finally
    FreeAndNil(Tag);
    FreeAndNil(VorbisBlock);
  end;
end;

function TFlacTag.CalculateMetaBlocksSize(IncludePadding: Boolean): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(aMetaBlockOther) - 1 do
  begin
    if ((aMetaBlockOther[I].MetaDataBlockHeader[1] and $7F) = META_PADDING) then
    begin
      if IncludePadding then
      begin
        Result := Result + aMetaBlockOther[I].Data.Size + 4;
      end;
    end
    else
    begin
      Result := Result + aMetaBlockOther[I].Data.Size + 4;
    end;
  end;
  for I := 0 to Length(MetaBlocksCoverArts) - 1 do
  begin
    Result := Result + MetaBlocksCoverArts[I].Data.Size + 4;
  end;
end;

function TFlacTag.CalculateTagSize(IncludePadding: Boolean): Integer;
begin
  Result := CalculateVorbisCommentsSize + CalculateMetaBlocksSize(IncludePadding);
  if IncludePadding then
  begin
    Result := Result + FPadding;
  end;
end;

function TFlacTag.Assign(FlacTag: TFlacTag): Boolean;
var
  I: Integer;
begin
  Clear;
  FileName := FlacTag.FileName;
  for I := 0 to Length(FlacTag.Tags) - 1 do
  begin
    Self.AddTag('').Assign(FlacTag.Tags[I]);
  end;
  for I := 0 to Length(FlacTag.MetaBlocksCoverArts) - 1 do
  begin
    FlacTag.MetaBlocksCoverArts[I].Data.Seek(0, soBeginning);
    Self.AddMetaDataCoverArt({ FlacTag.MetaBlocksCoverArts[i].MetaDataBlockHeader, }FlacTag.MetaBlocksCoverArts[I].Data,
      FlacTag.MetaBlocksCoverArts[I].Data.Size);
  end;
end;

(* -------------------------------------------------------------------------- *)

function RemoveFlacTagFromFile(const FileName: string): Integer;
var
  FlacTag: TFlacTag;
begin
  FlacTag := TFlacTag.Create;
  try
    FlacTag.ResetData(False, True);
    Result := FlacTag.SaveToFile(FileName);
  finally
    FreeAndNil(FlacTag);
  end;
end;

function FlacTagErrorCode2String(ErrorCode: Integer): string;
begin
  Result := 'Unknown error code.';
  case ErrorCode of
    FLACTAGLIBRARY_SUCCESS:
      Result := 'Success.';
    FLACTAGLIBRARY_ERROR:
      Result := 'Unknown error occured.';
    FLACTAGLIBRARY_ERROR_NO_TAG_FOUND:
      Result := 'No Flac tag found.';
    FLACTAGLIBRARY_ERROR_EMPTY_TAG:
      Result := 'Flac tag is empty.';
    FLACTAGLIBRARY_ERROR_EMPTY_FRAMES:
      Result := 'Flac tag contains only empty frames.';
    FLACTAGLIBRARY_ERROR_OPENING_FILE:
      Result := 'Error opening file.';
    FLACTAGLIBRARY_ERROR_READING_FILE:
      Result := 'Error reading file.';
    FLACTAGLIBRARY_ERROR_WRITING_FILE:
      Result := 'Error writing file.';
    FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_VERSION:
      Result := 'Error: not supported Flac tag version.';
    FLACTAGLIBRARY_ERROR_NOT_SUPPORTED_FORMAT:
      Result := 'Error not supported file format.';
    FLACTAGLIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS:
      Result := 'Error: file is locked. Need exclusive access to write Flac tag to this file.';
  end;
end;

end.

