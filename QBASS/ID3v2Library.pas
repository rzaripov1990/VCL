// ********************************************************************************************************************************
// *                                                                                                                              *
// *     ID3v2 Library 2.0.22.52 © 3delite 2010-2013                                                                              *
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

unit ID3v2Library;

{$OPTIMIZATION Off}

interface

uses
  Classes;

const
  ID3V2LIBRARY_VERSION = $02002252;

type
  DWord = Cardinal;

type
  TID3v2ID = array[0..2] of AnsiChar;
  TFrameID = array[0..3] of AnsiChar;
  TLanguageID = array[0..2] of AnsiChar;
  TRIFFID = array[0..3] of AnsiChar;
  TRIFFChunkID = array[0..3] of AnsiChar;
  TAIFFID = array[0..3] of AnsiChar;
  TAIFFChunkID = array[0..3] of AnsiChar;

const
  ID3V2LIBRARY_SUCCESS = 0;
  ID3V2LIBRARY_ERROR = $FFFF;
  ID3V2LIBRARY_ERROR_NO_TAG_FOUND = 1;
  ID3V2LIBRARY_ERROR_EMPTY_TAG = 2;
  ID3V2LIBRARY_ERROR_EMPTY_FRAMES = 3;
  ID3V2LIBRARY_ERROR_OPENING_FILE = 4;
  ID3V2LIBRARY_ERROR_READING_FILE = 5;
  ID3V2LIBRARY_ERROR_WRITING_FILE = 6;
  ID3V2LIBRARY_ERROR_DOESNT_FIT = 7;
  ID3V2LIBRARY_ERROR_NOT_SUPPORTED_VERSION = 8;
  ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT = 9;
  ID3V2LIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS = 10;

const
  ID3V2LIBRARY_DEFAULT_PADDING_SIZE = 4096;

const
  ID3V2LIBRARY_SESC_ID = $55555555;
  ID3V2LIBRARY_SESC_VERSION2: Byte = $02;

type
  TWaveds64 = record
    ds64Size: DWord;
    RIFFSizeLow: DWord;
    RIFFSizeHigh: DWord;
    DataSizeLow: DWord;
    DataSizeHigh: DWord;
    SampleCountLow: DWord;
    SampleCountHigh: DWord;
    TableLength: DWord;
  end;

type
  TID3v2ExtendedHeader3 = class
    Size: DWord;
    CodedSize: Cardinal;
    Data: TMemoryStream;
    Flags: Word;
    CRCPresent: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure DecodeExtendedHeaderSize;
    procedure DecodeExtendedHeaderFlags;
  end;

type
  TID3v2ExtendedHeader4TagSizeRestriction =
    (NoMoreThan128FramesAnd1MBTotalTagSize,
    NoMoreThan64FramesAnd128KBTotalTagSize,
    NoMoreThan32FramesAnd40KBTotalTagSize,
    NoMoreThan32FramesAnd4KBTotalTagSize);

type
  TID3v2ExtendedHeader4TextEncodingRestriction = (NoTextEncodingRestrictions,
    OnlyEncodedWithISO88591OrUTF8);

type
  TID3v2ExtendedHeader4TextFieldsSizeRestriction =
    (NoTextFieldsSizeRestrictions, NoStringIsLongerThan1024Characters,
    NoStringIsLongerThan128Characters, NoStringIsLongerThan30Characters);

type
  TID3v2ExtendedHeader4ImageEncodingRestriction = (NoImageEncodingRestrictions,
    ImagesAreEncodedOnlyWithPNGOrJPEG);

type
  TID3v2ExtendedHeader4ImageSizeRestriction = (NoImageSizeRestrictions,
    AllImagesAre256x256PixelsOrSmaller,
    AllImagesAre64x64PixelsOrSmaller,
    AllImagesAreExactly64x64PixelsUnlessRequiredOtherwise);

type
  TID3v2ExtendedHeader4 = class
    Size: DWord;
    CodedSize: Cardinal;
    FlagBytes: Byte;
    Flags: Byte;
    ExtendedFlagsDataSize: Cardinal;
    ExtendedFlagsData: array of Byte;
    TagIsAnUpdate: Boolean;
    CRCPresent: Boolean;
    TagRestrictions: Boolean;
    TagRestrictionsData: TID3v2ExtendedHeader4TagSizeRestriction;
    TextEncodingRestrictions: TID3v2ExtendedHeader4TextEncodingRestriction;
    TextFieldsSizeRestriction: TID3v2ExtendedHeader4TextFieldsSizeRestriction;
    ImageEncodingRestriction: TID3v2ExtendedHeader4ImageEncodingRestriction;
    ImageSizeRestriction: TID3v2ExtendedHeader4ImageSizeRestriction;
    constructor Create;
    destructor Destroy; override;
    procedure DecodeExtendedHeaderSize;
    procedure DecodeExtendedHeaderFlags;
    procedure CalculateExtendedFlagsDataSize;
    procedure DecodeExtendedHeaderFlagData;
  end;

type
  TID3v2SampleCache = array of Byte;

type
  TID3v2Frame = class
  private
  public
    ID: TFrameID;
    Size: Cardinal;
    CodedSize: Cardinal;
    Stream: TMemoryStream;
    Flags: Word;
    TagAlterPreservation: Boolean;
    FileAlterPreservation: Boolean;
      ReadOnly: Boolean;
    Compressed: Boolean;
    Encrypted: Boolean;
    GroupingIdentity: Boolean;
    Unsynchronised: Boolean;
    DataLengthIndicator: Boolean;
    GroupIdentifier: Byte;
    EncryptionMethod: Byte;
    DataLengthIndicatorValue: Cardinal;
    constructor Create;
    destructor Destroy; override;
    procedure DecodeFlags3;
    procedure EncodeFlags3;
    procedure DecodeFlags4;
    procedure EncodeFlags4;
    function Compress: Boolean;
    function DeCompress: Boolean;
    function RemoveUnsynchronisation: Boolean;
    function ApplyUnsynchronisation: Boolean;
    function Assign(ID3v2Frame: TID3v2Frame): Boolean;
    procedure Clear;
  end;

type
  TID3v2Tag = class
  private
    CodedSize: Cardinal;
    procedure DecodeFlags;
    procedure EncodeFlags;
    procedure DecodeSize;
    procedure EncodeSize;
    function ReadExtendedHeader(TagStream: TStream): Boolean;
    // function WriteExtendedHeader(TagStream: TStream): Boolean;
    function RemoveUnsynchronisationOnExtendedHeaderSize: Boolean;
    function ApplyUnsynchronisationOnExtendedHeaderSize: Boolean;
    function RemoveUnsynchronisationOnExtendedHeaderData: Boolean;
    function ApplyUnsynchronisationOnExtendedHeaderData: Boolean;
    function LoadFrame(TagStream: TStream): Boolean;
    procedure LoadFrameData(TagStream: TStream; FrameIndex: Integer);
    procedure CompactFrameList;
    function WriteAllFrames(var TagStream: TStream): Integer;
    function WriteAllHeaders(var TagStream: TStream): Integer;
    function Convertv2Tov3(FrameIndex: Integer): Boolean;
    function Convertv2PICtoAPIC(FrameIndex: Integer): Boolean;
  public
    FileName: string;
    Loaded: Boolean;
    MajorVersion: Byte;
    MinorVersion: Byte;
    Flags: Byte;
    Unsynchronised: Boolean;
    Compressed: Boolean;
    ExtendedHeader: Boolean;
    Experimental: Boolean;
    FooterPresent: Boolean;
    Size: Cardinal;
    Frames: array of TID3v2Frame;
    FrameCount: Integer;
    ExtendedHeader3: TID3v2ExtendedHeader3;
    ExtendedHeader4: TID3v2ExtendedHeader4;
    PaddingSize: Cardinal;
    PaddingToWrite: Cardinal;
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(FileName: string): Integer;
    function LoadFromStream(TagStream: TStream): Integer;
    function SaveToFile(FileName: string): Integer;
    function SaveToStream(var TagStream: TStream; PaddingSizeToWrite: Integer =
      0): Integer;
    function AddFrame(FrameID: TFrameID): Integer; overload;
    function AddFrame(FrameID: AnsiString): Integer; overload;
    function InsertFrame(FrameID: TFrameID; Position: Integer): Integer;
      overload;
    function InsertFrame(FrameID: AnsiString; Position: Integer): Integer;
      overload;
    function DeleteFrame(FrameIndex: Integer): Boolean; overload;
    function DeleteFrame(FrameID: TFrameID): Boolean; overload;
    function DeleteFrame(FrameID: AnsiString): Boolean; overload;
    procedure DeleteAllFrames;
    procedure Clear;
    procedure Assign(ID3v2Tag: TID3v2Tag);
    function RemoveUnsynchronisationOnAllFrames: Boolean;
    function ApplyUnsynchronisationOnAllFrames: Boolean;
    function FrameExists(FrameID: TFrameID): Integer; overload;
    function FrameExists(FrameID: AnsiString): Integer; overload;
    function FrameTypeCount(FrameID: TFrameID): Integer;
    function CalculateTotalFramesSize: Integer;
    function CalculateTagSize(PaddingSize: Integer): Integer;
    function FullFrameSize(FrameIndex: Cardinal): Cardinal;
    function CalculateTagCRC32: Cardinal;
    function GetUnicodeText(FrameIndex: Integer; ReturnNativeText: Boolean =
      False): string; overload;
    function GetUnicodeText(FrameID: AnsiString; ReturnNativeText: Boolean =
      False): string; overload;
    function SetUnicodeText(FrameIndex: Integer; Text: string): Boolean;
      overload;
    function SetUnicodeText(FrameID: AnsiString; Text: string): Boolean;
      overload;
    function GetUnicodeTextMultiple(FrameIndex: Integer; List: TStrings):
      Boolean; overload;
    function GetUnicodeTextMultiple(FrameID: AnsiString; List: TStrings):
      Boolean; overload;
    function SetUnicodeTextMultiple(FrameIndex: Integer; List: TStrings):
      Boolean; overload;
    function SetUnicodeTextMultiple(FrameID: AnsiString; List: TStrings):
      Boolean; overload;
    function SetText(FrameID: AnsiString; Text: AnsiString): Boolean; overload;
    function SetText(FrameIndex: Integer; Text: AnsiString): Boolean; overload;
    function SetUTF8Text(FrameID: AnsiString; Text: string): Boolean; overload;
    function SetUTF8Text(FrameIndex: Integer; Text: string): Boolean; overload;
    function SetRawText(FrameIndex: Integer; Text: AnsiString): Boolean;
      overload;
    function SetRawText(FrameID: AnsiString; Text: AnsiString): Boolean;
      overload;
    function GetUnicodeContent(FrameIndex: Integer; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function GetUnicodeContent(FrameID: AnsiString; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function SetContent(FrameIndex: Integer; Content: AnsiString; LanguageID:
      TLanguageID; Description: AnsiString)
      : Boolean; overload;
    function SetContent(FrameID: AnsiString; Content: AnsiString; LanguageID:
      TLanguageID; Description: AnsiString)
      : Boolean; overload;
    function SetUTF8Content(FrameIndex: Integer; Content: string; LanguageID:
      TLanguageID; Description: string): Boolean;
      overload;
    function SetUTF8Content(FrameID: AnsiString; Content: string; LanguageID:
      TLanguageID; Description: string): Boolean;
      overload;
    function SetUnicodeContent(FrameIndex: Integer; Content: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function SetUnicodeContent(FrameID: AnsiString; Content: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function GetUnicodeComment(FrameIndex: Integer; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function GetUnicodeComment(FrameID: AnsiString; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function FindUnicodeCommentByDescription(Description: string; var
      LanguageID: TLanguageID; var Comment: string): Integer;
    function SetUnicodeComment(FrameIndex: Integer; Comment: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function SetUnicodeComment(FrameID: AnsiString; Comment: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function SetUnicodeCommentByDescription(Description: string; LanguageID:
      TLanguageID; Comment: string): Boolean;
    function GetUnicodeLyrics(FrameIndex: Integer; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function GetUnicodeLyrics(FrameID: AnsiString; var LanguageID: TLanguageID;
      var Description: string): string; overload;
    function SetUnicodeLyrics(FrameIndex: Integer; Lyrics: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function SetUnicodeLyrics(FrameID: AnsiString; Lyrics: string; LanguageID:
      TLanguageID; Description: string)
      : Boolean; overload;
    function GetUnicodeCoverPictureStream(FrameIndex: Integer; PictureStream:
      TStream; var MIMEType: AnsiString; var Description: string;
      var CoverType: Integer): Boolean; overload;
    function GetUnicodeCoverPictureStream(FrameID: AnsiString; var
      PictureStream: TStream; var MIMEType: AnsiString;
      var Description: string; var CoverType: Integer): Boolean; overload;
    function GetUnicodeCoverPictureInfo(FrameIndex: Integer; var MIMEType:
      AnsiString; var Description: string;
      var CoverType: Integer): Boolean; overload;
    function GetUnicodeCoverPictureInfo(FrameID: AnsiString; var MIMEType:
      AnsiString; var Description: string;
      var CoverType: Integer): Boolean; overload;
    function SetUnicodeCoverPictureFromStream(FrameIndex: Integer; Description:
      string; PictureStream: TStream;
      MIMEType: AnsiString; CoverType: Integer): Boolean; overload;
    function SetUnicodeCoverPictureFromStream(FrameID: AnsiString; Description:
      string; PictureStream: TStream;
      MIMEType: AnsiString; CoverType: Integer): Boolean; overload;
    function SetUnicodeCoverPictureFromFile(FrameIndex: Integer; Description:
      string; PictureFileName: string;
      MIMEType: AnsiString; CoverType: Integer): Boolean; overload;
    function SetUnicodeCoverPictureFromFile(FrameID: AnsiString; Description:
      string; PictureFileName: string;
      MIMEType: AnsiString; CoverType: Integer): Boolean; overload;
    function GetURL(FrameIndex: Integer): AnsiString; overload;
    function GetURL(FrameID: AnsiString): AnsiString; overload;
    function SetURL(FrameIndex: Integer; URL: AnsiString): Boolean; overload;
    function SetURL(FrameID: AnsiString; URL: AnsiString): Boolean; overload;
    function GetUnicodeUserDefinedURLLink(FrameIndex: Integer; var Description:
      string): AnsiString; overload;
    function GetUnicodeUserDefinedURLLink(FrameID: AnsiString; var Description:
      string): AnsiString; overload;
    function FindUnicodeUserDefinedURLLinkByDescription(Description: string; var
      URL: AnsiString): Integer;
    function SetUserDefinedURLLink(FrameIndex: Integer; URL: AnsiString;
      Description: AnsiString): Boolean; overload;
    function SetUserDefinedURLLink(FrameID: AnsiString; URL: AnsiString;
      Description: AnsiString): Boolean; overload;
    function SetUTF8UserDefinedURLLink(FrameIndex: Integer; URL: AnsiString;
      Description: string): Boolean; overload;
    function SetUTF8UserDefinedURLLink(FrameID: AnsiString; URL: AnsiString;
      Description: string): Boolean; overload;
    function SetUnicodeUserDefinedURLLink(FrameIndex: Integer; URL: AnsiString;
      Description: string): Boolean; overload;
    function SetUnicodeUserDefinedURLLink(FrameID: AnsiString; URL: AnsiString;
      Description: string): Boolean; overload;
    function SetUnicodeUserDefinedURLLinkByDescription(Description: string; URL:
      AnsiString): Boolean;
    function GetTime(FrameIndex: Integer): TDateTime; overload;
    function GetTime(FrameID: AnsiString): TDateTime; overload;
    function SetTime(FrameIndex: Integer; DateTime: TDateTime): Boolean;
      overload;
    function SetTime(FrameID: AnsiString; DateTime: TDateTime): Boolean;
      overload;
    function GetSEBR(FrameIndex: Integer):
{$IFDEF CPUX64}Double{$ELSE}Extended{$ENDIF}; overload;
    function GetSEBR(FrameID: AnsiString):
{$IFDEF CPUX64}Double{$ELSE}Extended{$ENDIF}; overload;
    function GetSEBRString(FrameIndex: Integer): AnsiString;
    function SetSEBR(FrameIndex: Integer; BitRate: AnsiString): Boolean;
      overload;
    function SetSEBR(FrameID: AnsiString; BitRate: AnsiString): Boolean;
      overload;
{$IFNDEF CPUX64}
    function SetSEBR(FrameIndex: Integer; BitRate: Extended): Boolean; overload;
    function SetSEBR(FrameID: AnsiString; BitRate: Extended): Boolean; overload;
{$ENDIF}
    function GetSampleCache(FrameIndex: Integer; ForceDecompression: Boolean; var
      Version: Byte; var Channels: Integer)
      : TID3v2SampleCache;
    function SetSampleCache(FrameIndex: Integer; SESC: TID3v2SampleCache;
      Channels: Integer): Boolean;
    function GetSEFC(FrameIndex: Integer): Int64;
    function SetSEFC(FrameIndex: Integer; SEFC: Int64): Boolean;
    function SetAlbumColors(FrameIndex: Integer; TitleColor, TextColor:
      Cardinal): Boolean; overload;
    function SetAlbumColors(FrameID: AnsiString; TitleColor, TextColor:
      Cardinal): Boolean; overload;
    function GetAlbumColors(FrameIndex: Integer; var TitleColor, TextColor:
      Cardinal): Boolean; overload;
    function GetAlbumColors(FrameID: AnsiString; var TitleColor, TextColor:
      Cardinal): Boolean; overload;
    function SetTLEN(FrameIndex: Integer; TLEN: Integer): Boolean; overload;
    function SetTLEN(FrameID: AnsiString; TLEN: Integer): Boolean; overload;
    function GetPlayCount(FrameIndex: Integer): Cardinal; overload;
    function GetPlayCount(FrameID: AnsiString): Cardinal; overload;
    function SetPlayCount(FrameIndex: Integer; PlayCount: Cardinal): Boolean;
      overload;
    function SetPlayCount(FrameID: AnsiString; PlayCount: Cardinal): Boolean;
      overload;
    function FindCustomFrame(FrameID: AnsiString; Description: string): Integer;
    function GetUnicodeUserDefinedTextInformation(FrameIndex: Integer; var
      Description: string): string;
    function SetUserDefinedTextInformation(FrameIndex: Integer; Description:
      AnsiString; Text: AnsiString): Boolean; overload;
    function SetUserDefinedTextInformation(FrameID: AnsiString; Description:
      AnsiString; Text: AnsiString): Boolean; overload;
    function SetUnicodeUserDefinedTextInformationMultiple(FrameIndex: Integer;
      Description: string; List: TStrings)
      : Boolean; overload;
    function SetUnicodeUserDefinedTextInformationMultiple(FrameID: AnsiString;
      Description: string; List: TStrings)
      : Boolean; overload;
    function GetUnicodeUserDefinedTextInformationMultiple(FrameIndex: Integer;
      var Description: string; List: TStrings)
      : Boolean; overload;
    function GetUnicodeUserDefinedTextInformationMultiple(FrameID: AnsiString;
      var Description: string; List: TStrings)
      : Boolean; overload;
    function SetUTF8UserDefinedTextInformation(FrameIndex: Integer; Description:
      string; Text: string): Boolean; overload;
    function SetUTF8UserDefinedTextInformation(FrameID: AnsiString; Description:
      string; Text: string): Boolean; overload;
    function SetUnicodeUserDefinedTextInformation(FrameIndex: Integer;
      Description: string; Text: string): Boolean; overload;
    function SetUnicodeUserDefinedTextInformation(FrameID: AnsiString;
      Description: string; Text: string): Boolean; overload;
    function GetPopularimeter(FrameIndex: Integer; var Email: AnsiString; var
      Rating: Byte; var PlayCounter: Cardinal): Boolean;
    function FindPopularimeter(Email: AnsiString; var Rating: Byte; var
      PlayCounter: Cardinal): Integer;
    function SetPopularimeterByEmail(Email: AnsiString; Rating: Byte;
      PlayCounter: Cardinal = 0): Boolean;
    function SetPopularimeter(FrameIndex: Integer; Email: AnsiString; Rating:
      Byte; PlayCounter: Cardinal): Boolean;
    function FindTXXXByDescription(Description: string; var Text: string):
      Integer; overload;
    function FindTXXXByDescriptionMultiple(Description: string; List: TStrings):
      Integer; overload;
    // function GetUnicodeTXXX(FrameIndex: Integer; var Description: String): String;
    function SetUnicodeTXXXByDescription(Description: string; Text: string):
      Boolean;
    function SetUnicodeTXXXByDescriptionMultiple(Description: string; List:
      TStrings): Boolean;
    function SetUnicodeTXXX(Index: Integer; Description: string; Text: string):
      Boolean;
    function GetUnicodeListFrame(FrameID: AnsiString; var List: TStrings):
      Boolean; overload;
    function GetUnicodeListFrame(FrameIndex: Integer; var List: TStrings):
      Boolean; overload;
    function SetUnicodeListFrame(FrameID: AnsiString; List: TStrings): Boolean;
      overload;
    function SetUnicodeListFrame(Index: Integer; List: TStrings): Boolean;
      overload;
    function GetUFID(FrameIndex: Integer; var OwnerIdentifier: AnsiString):
      AnsiString; overload;
    function GetUFID(FrameID: AnsiString; var OwnerIdentifier: AnsiString):
      AnsiString; overload;
    function FindUFIDByOwnerIdentifier(OwnerIdentifier: AnsiString; var
      Identifier: AnsiString): Integer;
    function SetUFID(FrameIndex: Integer; OwnerIdentifier: AnsiString;
      Identifier: AnsiString): Boolean; overload;
    function SetUFID(FrameID: AnsiString; OwnerIdentifier: AnsiString;
      Identifier: AnsiString): Boolean; overload;
    function SetUFIDByOwnerIdentifier(OwnerIdentifier: AnsiString; Identifier:
      AnsiString): Boolean;
  end;

type
  TID3v2FrameType = (ftUnknown, ftText, ftTextWithDescription,
    ftTextWithDescriptionAndLangugageID, ftTextList, ftURL,
    ftUserDefinedURL);

  // The constants here are for the CRC-32 generator
  // polynomial, as defined in the Microsoft
  // Systems Journal, March 1995, pp. 107-108
const
  CRC32Table: array[0..255] of DWord = ($00000000, $77073096, $EE0E612C,
    $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3,
    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07,
    $90BF1D91, $1DB71064, $6AB020F2, $F3B97148,
    $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856, $646BA8C0,
    $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1,
    $4B04D447, $D20D85FD, $A50AB56B, $35B5A8FA,
    $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2,
    $B10BE924, $2F6F7C87, $58684C11, $C1611DAB,
    $B6662D3D,

    $76DC4190, $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5,
    $E8B8D433, $7807C9A2, $0F00F934, $9609A88E,
    $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01, $6B6B51F4, $1C6C6162,
    $856530D8, $F262004E, $6C0695ED, $1B01A57B,
    $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF,
    $15DA2D49, $8CD37CF3, $FBD44C65, $4DB26158,
    $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010,
    $C90C2086, $5768B525, $206F85B3, $B966D409,
    $CE61E49F, $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81,
    $B7BD5C3B, $C0BA6CAD,

    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615,
    $73DC1683, $E3630B12, $94643B84, $0D6D6A3E,
    $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344, $8708A3D2,
    $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F,
    $8EBEEFF9, $17B7BE43, $60B08ED5, $D6D6A3E8,
    $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, $CB61B38C, $BC66831A, $256FD2A0,
    $5268E236, $CC0C7795, $BB0B4703, $220216B9,
    $5505262F, $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31,
    $2CD99E8B, $5BDEAE1D,

    $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785,
    $05005713, $95BF4A82, $E2B87A14, $7BB12BAE,
    $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B,
    $6FB077E1, $18B74777, $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF,
    $F862AE69, $616BFFD3, $166CCF45, $A00AE278,
    $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9, $BDBDF21C, $CABAC28A, $53B39330,
    $24B4A3A6, $BAD03605, $CDD70693, $54DE5729,
    $23D967BF, $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1,
    $5A05DF1B, $2D02EF8D);

procedure UnSyncSafe(var Source; const SourceSize: Integer; var Dest: Cardinal);
procedure SyncSafe(Source: Cardinal; var Dest; const DestSize: Integer);

function Min(const B1, B2: Integer): Integer; inline;
function Max(const B1, B2: Integer): Integer; inline;

function ReverseBytes(Value: Cardinal): Cardinal; overload;
function Swap16(ASmallInt: SmallInt): SmallInt; register;

function RemoveUnsynchronisationScheme(Source, Dest: TStream; BytesToRead:
  Integer): Boolean;
function ApplyUnsynchronisationScheme(Source, Dest: TStream; BytesToRead:
  Integer): Boolean;

function RemoveUnsynchronisationOnStream(Stream: TMemoryStream): Boolean;
function ApplyUnsynchronisationOnStream(Stream: TMemoryStream): Boolean;

function ID3v2EncodeTime(DateTime: TDateTime): string;
function ID3v2DecodeTime(ID3v2DateTime: string): TDateTime;
function ID3v2DecodeTimeToNumbers(ID3v2DateTime: string; var Year, Month, Day,
  Hour, Minute, Second: Integer): Boolean;

function ValidID3v2FrameID(FrameID: TFrameID): Boolean;
function ValidID3v2FrameID2(FrameID: TFrameID): Boolean;
function LanguageIDtoString(LangageId: TLanguageID): string;
procedure AnsiStringToPAnsiChar(const Source: AnsiString; Dest: PAnsiChar; const
  MaxLength: Integer);
procedure StringToLanguageID(const Source: string; var Dest: TLanguageID);

function APICType2Str(PictureType: Integer): string;
function APICTypeStr2No(PictureType: string): Integer;

function ID3v2ValidTag(TagStream: TStream): Boolean;
function CheckRIFF(TagStream: TStream): Boolean;
function SeekRIFF(TagStream: TStream): Integer;
function CheckAIFF(TagStream: TStream): Boolean;
function SeekAIFF(TagStream: TStream): Integer;
function CheckRF64(TagStream: TStream): Boolean;
function SeekRF64(TagStream: TStream): Integer;
function ID3v2RemoveTag(FileName: string): Integer;

procedure CalcCRC32(P: Pointer; ByteCount: DWord; var CRCValue: DWord);
function CalculateStreamCRC32(Stream: TStream; var CRCValue: DWord): Boolean;

function RIFFCreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
function RIFFUpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;

function AIFFCreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
function AIFFUpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;

function RF64CreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
function RF64UpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;

function WritePadding(var TagStream: TStream; PaddingSize: Integer): Integer;

function RemoveRIFFID3v2(FileName: string): Integer;
function RemoveAIFFID3v2(FileName: string): Integer;
function RemoveRF64ID3v2(FileName: string): Integer;

function ID3v2TagErrorCode2String(ErrorCode: Integer): string;

function MakeInt64(LowDWord, HiDWord: DWord): Int64;
function LowDWordOfInt64(Value: Int64): Cardinal;
function HighDWordOfInt64(Value: Int64): Cardinal;

function GetID3v2FrameType(FrameID: TFrameID): TID3v2FrameType;

var
  ID3v2ID: TID3v2ID;
  RIFFID: TRIFFID;
  RF64ID: TRIFFID;
  RIFFWAVEID: TRIFFChunkID;
  RIFFID3v2ID: TRIFFChunkID;
  AIFFID: TAIFFID;
  AIFFChunkID: TAIFFChunkID;
  AIFCChunkID: TAIFFChunkID;
  AIFFID3v2ID: TAIFFChunkID;

implementation

uses
  SysUtils,
  // Dialogs,
  // ZLibEx,
  ZLib;

function MakeInt64(LowDWord, HiDWord: DWord): Int64;
begin
  Result := LowDWord or (Int64(HiDWord) shl 32);
end;

function LowDWordOfInt64(Value: Int64): Cardinal;
begin
  Result := (Value shl 32) shr 32;
end;

function HighDWordOfInt64(Value: Int64): Cardinal;
begin
  Result := Value shr 32;
end;

constructor TID3v2ExtendedHeader3.Create;
begin
  inherited;
  Flags := 0;
  Size := 0;
  // SizeData := TMemoryStream.Create;
  Data := TMemoryStream.Create;
end;

destructor TID3v2ExtendedHeader3.Destroy;
begin
  // FreeAndNil(SizeData);
  FreeAndNil(Data);
  inherited;
end;

procedure TID3v2ExtendedHeader3.DecodeExtendedHeaderSize;
begin
  UnSyncSafe(CodedSize, 4, Size);
end;

procedure TID3v2ExtendedHeader3.DecodeExtendedHeaderFlags;
var
  Bit: Byte;
begin
  Flags := Swap16(Flags);
  Bit := Flags shr 15;
  CRCPresent := Boolean(Bit);
end;

constructor TID3v2ExtendedHeader4.Create;
begin
  inherited;
  TagIsAnUpdate := False;
  CRCPresent := False;
  TagRestrictions := False;
  TagRestrictionsData := NoMoreThan128FramesAnd1MBTotalTagSize;
  TextEncodingRestrictions := NoTextEncodingRestrictions;
  TextFieldsSizeRestriction := NoTextFieldsSizeRestrictions;
  ImageEncodingRestriction := NoImageEncodingRestrictions;
  ImageSizeRestriction := NoImageSizeRestrictions;
end;

destructor TID3v2ExtendedHeader4.Destroy;
begin
  inherited;
end;

procedure TID3v2ExtendedHeader4.DecodeExtendedHeaderSize;
begin
  UnSyncSafe(CodedSize, 4, Size);
end;

procedure TID3v2ExtendedHeader4.DecodeExtendedHeaderFlags;
var
  Bit: Byte;
begin
  Bit := Flags shl 1;
  Bit := Bit shr 7;
  TagIsAnUpdate := Boolean(Bit);
  Bit := Flags shl 2;
  Bit := Bit shr 7;
  CRCPresent := Boolean(Bit);
  Bit := Flags shl 3;
  Bit := Bit shr 7;
  TagRestrictions := Boolean(Bit);
end;

procedure TID3v2ExtendedHeader4.CalculateExtendedFlagsDataSize;
begin
  ExtendedFlagsDataSize := 0;
  if TagIsAnUpdate then
  begin
    // * No flag data
  end;
  if CRCPresent then
  begin
    ExtendedFlagsDataSize := ExtendedFlagsDataSize + 5;
  end;
  if TagRestrictions then
  begin
    ExtendedFlagsDataSize := ExtendedFlagsDataSize + 1;
  end;
end;

procedure TID3v2ExtendedHeader4.DecodeExtendedHeaderFlagData;
begin
  // * Not yet implemented
end;

constructor TID3v2Frame.Create;
begin
  inherited;
  ID := '';
  Flags := 0;
  TagAlterPreservation := False;
  FileAlterPreservation := False;
  ReadOnly := False;
  Compressed := False;
  Encrypted := False;
  GroupingIdentity := False;
  Unsynchronised := False;
  DataLengthIndicator := False;
  Stream := TMemoryStream.Create;
  Unsynchronised := False;
  DataLengthIndicatorValue := 0;
  GroupIdentifier := 0;
  EncryptionMethod := 0;
end;

destructor TID3v2Frame.Destroy;
begin
  ID := #0#0#0#0;
  FreeAndNil(Stream);
  inherited;
end;

procedure TID3v2Frame.DecodeFlags3;
var
  Bit: Word;
begin
  Bit := Flags shr 15;
  TagAlterPreservation := Boolean(Bit);
  Bit := Flags shl 1;
  Bit := Bit shr 15;
  FileAlterPreservation := Boolean(Bit);
  Bit := Flags shl 2;
  Bit := Bit shr 15;
  ReadOnly := Boolean(Bit);
  Bit := Flags shl 8;
  Bit := Bit shr 15;
  Compressed := Boolean(Bit);
  Bit := Flags shl 9;
  Bit := Bit shr 15;
  Encrypted := Boolean(Bit);
  Bit := Flags shl 10;
  Bit := Bit shr 15;
  GroupingIdentity := Boolean(Bit);
end;

procedure TID3v2Frame.EncodeFlags3;
var
  EncodedFlags: Word;
  Bit: Word;
begin
  EncodedFlags := 0;
  if TagAlterPreservation then
  begin
    Bit := 1 shl 7;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if FileAlterPreservation then
  begin
    Bit := 1 shl 6;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if ReadOnly then
  begin
    Bit := 1 shl 5;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if Compressed then
  begin
    Bit := 1 shl 15;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if Encrypted then
  begin
    Bit := 1 shl 14;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if GroupingIdentity then
  begin
    Bit := 1 shl 13;
    EncodedFlags := EncodedFlags or Bit;
  end;
  Flags := EncodedFlags;
end;

procedure TID3v2Frame.DecodeFlags4;
var
  Bit: Word;
begin
  Bit := Flags shr 14;
  TagAlterPreservation := Boolean(Bit);
  Bit := Flags shl 1;
  Bit := Bit shr 14;
  FileAlterPreservation := Boolean(Bit);
  Bit := Flags shl 2;
  Bit := Bit shr 14;
  ReadOnly := Boolean(Bit);
  Bit := Flags shl 9;
  Bit := Bit shr 15;
  GroupingIdentity := Boolean(Bit);
  Bit := Flags shl 12;
  Bit := Bit shr 15;
  Compressed := Boolean(Bit);
  Bit := Flags shl 13;
  Bit := Bit shr 15;
  Encrypted := Boolean(Bit);
  Bit := Flags shl 14;
  Bit := Bit shr 15;
  Unsynchronised := Unsynchronised or Boolean(Bit);
  Bit := Flags shl 15;
  Bit := Bit shr 15;
  DataLengthIndicator := Boolean(Bit);
end;

procedure TID3v2Frame.EncodeFlags4;
var
  EncodedFlags: Word;
  Bit: Word;
begin
  EncodedFlags := 0;
  if TagAlterPreservation then
  begin
    Bit := 1 shl 14;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if FileAlterPreservation then
  begin
    Bit := 1 shl 13;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if ReadOnly then
  begin
    Bit := 1 shl 12;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if GroupingIdentity then
  begin
    Bit := 1 shl 6;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if Compressed then
  begin
    Bit := 1 shl 3;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if Encrypted then
  begin
    Bit := 1 shl 2;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if Unsynchronised then
  begin
    Bit := 1 shl 1;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if DataLengthIndicator then
  begin
    Bit := 1;
    EncodedFlags := EncodedFlags or Bit;
  end;
  Flags := EncodedFlags;
end;

function TID3v2Frame.Compress: Boolean;
var
  CompressionStream: TZCompressionStream;
  CompressedStream: TStream;
  UnCompressedSize: DWord;
  SyncSafeSize: DWord;
begin
  Result := False;
  if Stream.Size = 0 then
  begin
    Exit;
  end;
  CompressionStream := nil;
  CompressedStream := nil;
  try
    try
      CompressedStream := TMemoryStream.Create;
      // * TZCompressionStream constructor has changed
{$IF CompilerVersion >= 22}
      CompressionStream := TZCompressionStream.Create(clMax, CompressedStream);
{$ELSE}
      CompressionStream := TZCompressionStream.Create(CompressedStream, zcMax);
{$IFEND}
      Stream.Seek(0, soBeginning);
      CompressionStream.CopyFrom(Stream, Stream.Size);
      // * Needed to flush the buffer
      FreeAndNil(CompressionStream);
      if CompressedStream.Size > 0 then
      begin
        UnCompressedSize := Stream.Size;
        SyncSafe(UnCompressedSize, SyncSafeSize, 4);
        Stream.Clear;
        // Stream.Write(SyncSafeSize, 4);
        DataLengthIndicatorValue := SyncSafeSize;
        CompressedStream.Seek(0, soBeginning);
        Stream.CopyFrom(CompressedStream, CompressedStream.Size);
        Compressed := True;
        DataLengthIndicator := True;
        Result := True;
      end;
    except
      // *
    end;
  finally
    if Assigned(CompressionStream) then
    begin
      FreeAndNil(CompressionStream);
    end;
    if Assigned(CompressedStream) then
    begin
      FreeAndNil(CompressedStream);
    end;
  end;
end;

function TID3v2Frame.DeCompress: Boolean;
var
  DeCompressionStream: TZDeCompressionStream;
  UnCompressedStream: TMemoryStream;
begin
  Result := False;
  if Stream.Size <= 4 then
  begin
    Exit;
  end;
  DeCompressionStream := nil;
  UnCompressedStream := nil;
  try
    try
      UnCompressedStream := TMemoryStream.Create;
      Stream.Seek(0, soBeginning);
      DeCompressionStream := TZDeCompressionStream.Create(Stream);

      DeCompressionStream.Seek(0, soBeginning);

      UnCompressedStream.CopyFrom(DeCompressionStream, 0);
      Stream.Clear;
      Stream.CopyFrom(UnCompressedStream, 0);
      Stream.Seek(0, soBeginning);
      Compressed := False;
      DataLengthIndicator := False;
      Result := True;
    except
      // *
    end;
  finally
    if Assigned(DeCompressionStream) then
    begin
      FreeAndNil(DeCompressionStream);
    end;
    if Assigned(UnCompressedStream) then
    begin
      FreeAndNil(UnCompressedStream);
    end;
  end;
end;

function TID3v2Frame.RemoveUnsynchronisation: Boolean;
begin
  Result := RemoveUnsynchronisationOnStream(Stream);
  if Result then
  begin
    Unsynchronised := False;
  end;
end;

function TID3v2Frame.ApplyUnsynchronisation: Boolean;
begin
  Result := ApplyUnsynchronisationOnStream(Stream);
  if Result then
  begin
    Unsynchronised := True;
  end;
end;

function TID3v2Frame.Assign(ID3v2Frame: TID3v2Frame): Boolean;
begin
  Result := False;
  Clear;
  if ID3v2Frame <> nil then
  begin
    ID := ID3v2Frame.ID;
    Size := ID3v2Frame.Size;
    Flags := ID3v2Frame.Flags;
    TagAlterPreservation := ID3v2Frame.TagAlterPreservation;
    FileAlterPreservation := ID3v2Frame.FileAlterPreservation;
    ReadOnly := ID3v2Frame.ReadOnly;
    Compressed := ID3v2Frame.Compressed;
    Encrypted := ID3v2Frame.Encrypted;
    GroupingIdentity := ID3v2Frame.GroupingIdentity;
    Unsynchronised := ID3v2Frame.Unsynchronised;
    DataLengthIndicator := ID3v2Frame.DataLengthIndicator;
    GroupIdentifier := ID3v2Frame.GroupIdentifier;
    EncryptionMethod := ID3v2Frame.EncryptionMethod;
    ID3v2Frame.Stream.Seek(0, soBeginning);
    Stream.CopyFrom(ID3v2Frame.Stream, ID3v2Frame.Stream.Size);
    ID3v2Frame.Stream.Seek(0, soBeginning);
  end;
end;

procedure TID3v2Frame.Clear;
begin
  ID := '';
  Size := 0;
  Flags := 0;
  TagAlterPreservation := False;
  FileAlterPreservation := False;
  ReadOnly := False;
  Compressed := False;
  Encrypted := False;
  GroupingIdentity := False;
  Unsynchronised := False;
  DataLengthIndicator := False;
  GroupIdentifier := 0;
  EncryptionMethod := 0;
  Stream.Clear;
end;

constructor TID3v2Tag.Create;
begin
  inherited;
  ExtendedHeader3 := TID3v2ExtendedHeader3.Create;
  ExtendedHeader4 := TID3v2ExtendedHeader4.Create;
  Clear;
end;

destructor TID3v2Tag.Destroy;
begin
  Clear;
  FreeAndNil(ExtendedHeader3);
  FreeAndNil(ExtendedHeader4);
  inherited;
end;

procedure TID3v2Tag.DeleteAllFrames;
var
  i: Integer;
begin
  for i := 0 to Length(Frames) - 1 do
  begin
    FreeAndNil(Frames[i]);
  end;
  SetLength(Frames, 0);
  FrameCount := 0;
end;

function TID3v2Tag.LoadFromStream(TagStream: TStream): Integer;
var
  ValidFrameLoaded: Boolean;
  PreviousPosition: Int64;
  TagPosition: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  Loaded := False;
  Clear;
  PreviousPosition := TagStream.Position;
  if not ID3v2ValidTag(TagStream) then
  begin
    TagStream.Seek(PreviousPosition, soBeginning);
    // * WAV
    if CheckRIFF(TagStream) then
    begin
      if SeekRIFF(TagStream) = 0 then
      begin
        Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
        Exit;
      end;
    end
    else
    begin
      // * WAV64
      TagStream.Seek(PreviousPosition, soBeginning);
      if CheckRF64(TagStream) then
      begin
        if SeekRF64(TagStream) = 0 then
        begin
          Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
          Exit;
        end;
      end
      else
      begin
        // * AIFF
        TagStream.Seek(PreviousPosition, soBeginning);
        if CheckAIFF(TagStream) then
        begin
          if SeekAIFF(TagStream) = 0 then
          begin
            Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
            Exit;
          end;
        end;
      end;
    end;
    if not ID3v2ValidTag(TagStream) then
    begin
      Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
      Exit;
    end;
  end;
  try
    TagStream.Read(MajorVersion, 1);
    TagStream.Read(MinorVersion, 1);
  except
    Exit;
  end;
  if (MajorVersion > 4) or (MajorVersion < 2) then
  begin
    Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_VERSION;
    Exit;
  end;
  try
    TagStream.Read(Flags, 1);
    DecodeFlags;
  except
    Exit;
  end;
  try
    TagStream.Read(CodedSize, 4);
    DecodeSize;
  except
    Exit;
  end;
  TagPosition := TagStream.Position;
  if ExtendedHeader then
  begin
    // Showmessage('Extended header found!');
    ReadExtendedHeader(TagStream);
  end;
  repeat
    ValidFrameLoaded := LoadFrame(TagStream);
    // * TODO seek back 3 bytes for compatibility for corrupt tags and try again
  until not ValidFrameLoaded or (TagStream.Position >= TagPosition + Self.Size);
  Result := ID3V2LIBRARY_SUCCESS;
  Loaded := True;
end;

function TID3v2Tag.LoadFromFile(FileName: string): Integer;
var
  FileStream: TFileStream;
begin
  Result := ID3V2LIBRARY_ERROR;
  Clear;
  Loaded := False;
  if not FileExists(FileName) then
  begin
    Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  except
    Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    Result := LoadFromStream(FileStream);
    if (Result = ID3V2LIBRARY_SUCCESS) or (Result =
      ID3V2LIBRARY_ERROR_NOT_SUPPORTED_VERSION) then
    begin
      Self.FileName := FileName;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

procedure TID3v2Tag.DecodeFlags;
var
  Bit: Byte;
begin
  if MajorVersion = 2 then
  begin
    Bit := Flags shr 7;
    Unsynchronised := Boolean(Bit);
    Bit := Flags shl 1;
    Bit := Bit shr 7;
    Compressed := Boolean(Bit);
  end
  else
  begin
    Bit := Flags shr 7;
    Unsynchronised := Boolean(Bit);
    Bit := Flags shl 1;
    Bit := Bit shr 7;
    ExtendedHeader := Boolean(Bit);
    Bit := Flags shl 2;
    Bit := Bit shr 7;
    Experimental := Boolean(Bit);
    Bit := Flags shl 3;
    Bit := Bit shr 7;
    FooterPresent := Boolean(Bit);
  end;
end;

procedure TID3v2Tag.EncodeFlags;
var
  EncodedFlags: Byte;
  Bit: Byte;
begin
  EncodedFlags := 0;
  if Unsynchronised then
  begin
    Bit := 1 shl 7;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if ExtendedHeader then
  begin
    // * Extended header writing is not supported
    // Bit := 1 SHL 6;
    // EncodedFlags := EncodedFlags OR Bit;
  end;
  if Experimental then
  begin
    Bit := 1 shl 5;
    EncodedFlags := EncodedFlags or Bit;
  end;
  if FooterPresent then
  begin
    // * Footer writing is not supported
    // Bit := 1 SHL 6;
    // EncodedFlags := EncodedFlags OR Bit;
  end;
  Flags := EncodedFlags;
end;

procedure TID3v2Tag.DecodeSize;
begin
  UnSyncSafe(CodedSize, 4, Size);
  Size := Size + 10;
end;

function TID3v2Tag.ReadExtendedHeader(TagStream: TStream): Boolean;
var
  ExtendedFrameID: TFrameID;
begin
  Result := False;
  try
    TagStream.Read(ExtendedFrameID[0], 4);
    // * Support for bad Tags that report an extended header but don't have one
    if not ValidID3v2FrameID(ExtendedFrameID) then
    begin
      TagStream.Seek(-4, soCurrent);
      // * v3
      if MajorVersion = 3 then
      begin
        with ExtendedHeader3 do
        begin
          // * If extended header is unsynchronised needed to remove it
          // SizeData.CopyFrom(TagStream, 4);
          // if Unsynchronised then begin
          // RemoveUnsynchronisationOnExtendedHeaderSize;
          // end;
          // SizeData.Seek(0, soBeginning);
          // SizeData.Read(CodedExtendedHeaderSize3, 4);
          // SizeData.Seek(0, soBeginning);
          TagStream.Read(CodedSize, 4);
          DecodeExtendedHeaderSize;

          // * Read extended header flags
          TagStream.Read(ExtendedHeader3.Flags, 2);
          DecodeExtendedHeaderFlags;

          Data.CopyFrom(TagStream, Size - 2);
          if Unsynchronised then
          begin
            RemoveUnsynchronisationOnExtendedHeaderData;
          end;
        end;
      end;
      // * v4
      if MajorVersion = 4 then
      begin
        with ExtendedHeader4 do
        begin
          TagStream.Read(CodedSize, 4);
          DecodeExtendedHeaderSize;
          TagStream.Read(FlagBytes, 1);
          TagStream.Read(Flags, 1);
          DecodeExtendedHeaderFlags;
          CalculateExtendedFlagsDataSize;
          SetLength(ExtendedFlagsData, ExtendedFlagsDataSize);
          TagStream.Read(ExtendedFlagsData[0], ExtendedFlagsDataSize);
          DecodeExtendedHeaderFlagData;
        end;
      end;
    end
    else
    begin
      ExtendedHeader := False;
      TagStream.Seek(-4, soCurrent);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

procedure UnSyncSafe(var Source; const SourceSize: Integer; var Dest: Cardinal);
type
  TBytes = array[0..MaxInt - 1] of Byte;
var
  i: Byte;
begin
  { Test : Source = $01 $80 -> Dest = 255
    Source = $02 $00 -> Dest = 256
    Source = $02 $01 -> Dest = 257 etc.
  }
  Dest := 0;
  for i := 0 to SourceSize - 1 do
  begin
    Dest := Dest shl 7;
    Dest := Dest or (TBytes(Source)[i] and $7F); // $7F = %01111111
  end;
end;

procedure SyncSafe(Source: Cardinal; var Dest; const DestSize: Integer);
type
  TBytes = array[0..MaxInt - 1] of Byte;
var
  i: Byte;
begin
  { Test : Source = 255 -> Dest = $01 $80
    Source = 256 -> Dest = $02 $00
    Source = 257 -> Dest = $02 $01 etc.
  }
  for i := DestSize - 1 downto 0 do
  begin
    TBytes(Dest)[i] := Source and $7F; // $7F = %01111111
    Source := Source shr 7;
  end;
end;

function TID3v2Tag.LoadFrame(TagStream: TStream): Boolean;
var
  FrameID: TFrameID;
  FrameIndex: Integer;
  ValidFrame: Boolean;
begin
  Result := False;
  FrameID := #0#0#0#0;
  try
    if Self.MajorVersion = 2 then
    begin
      TagStream.Read(FrameID[0], 3);
      ValidFrame := ValidID3v2FrameID2(FrameID);
    end
    else
    begin
      TagStream.Read(FrameID[0], 4);
      ValidFrame := ValidID3v2FrameID(FrameID);
    end;
    // * Workaround for buggy DataLengthIndicator
    if not ValidFrame then
    begin
      TagStream.Read(FrameID[0], 4);
      ValidFrame := ValidID3v2FrameID(FrameID);
    end;
    if ValidFrame then
    begin
      FrameIndex := AddFrame(FrameID);
      if FrameIndex > -1 then
      begin
        LoadFrameData(TagStream, FrameIndex);
        Result := True;
      end;
    end;
  except

  end;
end;

procedure TID3v2Tag.LoadFrameData(TagStream: TStream; FrameIndex: Integer);
var
  Size: DWord;
  Flags: Word;
  ReversedFlags: Cardinal;
  DecodedSize: Cardinal;
  CopySize: Cardinal;
  DataLengthIndicatorValueCoded: Cardinal;
begin
  try
    if MajorVersion = 2 then
    begin
      Size := 0;
      Flags := 0;
      TagStream.Read(Size, 3);
      Frames[FrameIndex].Size := ReverseBytes(Size shl 8);
      if (Frames[FrameIndex].Size < 1) or (Frames[FrameIndex].Size > Self.Size) then
      begin
        Exit;
      end;
      Frames[FrameIndex].Unsynchronised := Unsynchronised;
      Frames[FrameIndex].Stream.CopyFrom(TagStream, Frames[FrameIndex].Size);
      Convertv2Tov3(FrameIndex);
    end;
    if MajorVersion = 3 then
    begin
      TagStream.Read(Size, 4);
      TagStream.Read(Flags, 2);
      Frames[FrameIndex].Size := ReverseBytes(Size);
      if (Frames[FrameIndex].Size < 1) or (Frames[FrameIndex].Size > Self.Size) then
      begin
        Exit;
      end;
      Frames[FrameIndex].Flags := Swap16(Flags);
      Frames[FrameIndex].DecodeFlags3;
      Frames[FrameIndex].Unsynchronised := Unsynchronised;
      if Frames[FrameIndex].Compressed then
      begin
        TagStream.Read(DataLengthIndicatorValueCoded, 4);
        UnSyncSafe(DataLengthIndicatorValueCoded, 4,
          Frames[FrameIndex].DataLengthIndicatorValue);
        Frames[FrameIndex].DataLengthIndicator := True;
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 4;
      end;
      if Frames[FrameIndex].Encrypted then
      begin
        TagStream.Read(Frames[FrameIndex].EncryptionMethod, 1);
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 1;
      end;
      if Frames[FrameIndex].GroupingIdentity then
      begin
        TagStream.Read(Frames[FrameIndex].GroupIdentifier, 1);
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 1;
      end;
      Frames[FrameIndex].Stream.CopyFrom(TagStream, Frames[FrameIndex].Size);
    end;
    if MajorVersion > 3 then
    begin
      TagStream.Read(Size, 4);
      TagStream.Read(Flags, 2);
      UnSyncSafe(Size, 4, Frames[FrameIndex].Size);
      if (Frames[FrameIndex].Size < 1) or (Frames[FrameIndex].Size > Self.Size) then
      begin
        Exit;
      end;
      Frames[FrameIndex].Flags := Swap16(Flags);
      Frames[FrameIndex].DecodeFlags4;
      if Frames[FrameIndex].GroupingIdentity then
      begin
        TagStream.Read(Frames[FrameIndex].GroupIdentifier, 1);
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 1;
      end;
      if Frames[FrameIndex].Encrypted then
      begin
        TagStream.Read(Frames[FrameIndex].EncryptionMethod, 1);
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 1;
      end;
      if Frames[FrameIndex].DataLengthIndicator then
      begin
        TagStream.Read(DataLengthIndicatorValueCoded, 4);
        UnSyncSafe(DataLengthIndicatorValueCoded, 4,
          Frames[FrameIndex].DataLengthIndicatorValue);
        Frames[FrameIndex].Size := Frames[FrameIndex].Size - 4;
      end;
      Frames[FrameIndex].Stream.CopyFrom(TagStream, Frames[FrameIndex].Size);
    end;
  except
    // *
  end;
end;

function TID3v2Tag.AddFrame(FrameID: TFrameID): Integer;
begin
  Result := -1;
  try
    SetLength(Frames, Length(Frames) + 1);
    Frames[Length(Frames) - 1] := TID3v2Frame.Create;
    Frames[Length(Frames) - 1].ID := FrameID;
    Result := Length(Frames) - 1;
    Inc(FrameCount);
  except
    // *
  end;
end;

function TID3v2Tag.AddFrame(FrameID: AnsiString): Integer;
var
  ID: TFrameID;
begin
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Result := AddFrame(ID);
end;

function TID3v2Tag.InsertFrame(FrameID: TFrameID; Position: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  try
    SetLength(Frames, Length(Frames) + 1);
    if Position > Length(Frames) - 1 then
    begin
      Position := Length(Frames) - 1;
    end;
    for i := Length(Frames) - 2 downto Position do
    begin
      Frames[i + 1] := Frames[i];
    end;
    Frames[Position] := TID3v2Frame.Create;
    Frames[Position].ID := FrameID;
    Result := Position;
    Inc(FrameCount);
  except
    // *
  end;
end;

function TID3v2Tag.InsertFrame(FrameID: AnsiString; Position: Integer): Integer;
var
  ID: TFrameID;
begin
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Result := InsertFrame(ID, Position);
end;

function TID3v2Tag.DeleteFrame(FrameIndex: Integer): Boolean;
begin
  Result := False;
  if (FrameIndex >= Length(Frames)) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  FreeAndNil(Frames[FrameIndex]);
  CompactFrameList;
  Dec(FrameCount);
  Result := True;
end;

function TID3v2Tag.DeleteFrame(FrameID: TFrameID): Boolean;
var
  Index: Integer;
begin
  Result := False;
  Index := FrameExists(FrameID);
  if (Index >= Length(Frames)) or (Index < 0) then
  begin
    Exit;
  end;
  Result := DeleteFrame(Index);
end;

function TID3v2Tag.DeleteFrame(FrameID: AnsiString): Boolean;
var
  ID: TFrameID;
begin
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Result := DeleteFrame(ID);
end;

procedure TID3v2Tag.CompactFrameList;
var
  i: Integer;
  Compacted: Boolean;
begin
  Compacted := False;
  if Frames[FrameCount - 1] = nil then
  begin
    Compacted := True;
  end
  else
  begin
    for i := 0 to FrameCount - 2 do
    begin
      if Frames[i] = nil then
      begin
        Frames[i] := Frames[i + 1];
        Frames[i + 1] := nil;
        Compacted := True;
      end;
    end;
  end;
  if Compacted then
  begin
    SetLength(Frames, Length(Frames) - 1);
  end;
end;

function TID3v2Tag.Convertv2PICtoAPIC(FrameIndex: Integer): Boolean;
var
  StrMimeType: AnsiString;
  Data: Byte;
  TextEncoding: Integer;
  StrASCIIDescription: AnsiString;
  StrUDescription: string;
  UData: Word;
  PUDescription: PWideChar;
  MIMEType: AnsiString;
  Description: string;
  CoverType: Byte;
  PictureStream: TStream;
  i: Integer;
begin
  Result := False;
  MIMEType := '';
  Description := '';
  CoverType := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);

    PictureStream := TMemoryStream.Create;

    try
      // * Get text encoding
      Frames[FrameIndex].Stream.Read(Data, 1);
      TextEncoding := Data;

      // * Get MIME type
      StrMimeType := '';
      for i := 0 to 2 do
      begin
        Frames[FrameIndex].Stream.Read(Data, 1);
        if Data <> 0 then
        begin
          StrMimeType := StrMimeType + AnsiChar(Data);
        end;
      end;

      // * Get picture type
      Frames[FrameIndex].Stream.Read(Data, 1);
      CoverType := Data;

      // * Get description
      // * ASCII format ISO-8859-1
      case TextEncoding of
        0:
          begin
            StrASCIIDescription := '';
            repeat
              Frames[FrameIndex].Stream.Read(Data, 1);
              if Data <> $0 then
              begin
                StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
              end;
            until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            StrUDescription := StrASCIIDescription;
          end;
        // * Unicode format UTF-16 with BOM
        1:
          begin
            StrUDescription := '';
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                StrUDescription := StrUDescription + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            StrUDescription := Copy(StrUDescription, 2,
              Length(StrUDescription));
          end;
        // * Unicode format UTF-16BE without BOM
        2:
          begin
            StrUDescription := '';
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                StrUDescription := StrUDescription + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
          end;
        // * Unicode format UTF-8
        3:
          begin
            StrASCIIDescription := '';
            repeat
              Frames[FrameIndex].Stream.Read(Data, 1);
              if Data <> $0 then
              begin
                StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
              end;
            until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
            Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
              PAnsiChar(StrASCIIDescription),
              Length(StrASCIIDescription));
            StrUDescription := PUDescription;
            FreeMem(PUDescription);
          end;
      end;

      // * Get binary picture data
      PictureStream.Seek(0, soBeginning);
      try
        PictureStream.CopyFrom(Frames[FrameIndex].Stream,
          Frames[FrameIndex].Stream.Size - Frames[FrameIndex].Stream.Position);
        PictureStream.Seek(0, soFromBeginning);
      except

      end;

      // * Set results
      MIMEType := StrMimeType;
      Description := StrUDescription;

      MIMEType := UpperCase(MIMEType);
      if MIMEType = 'JPG' then
      begin
        MIMEType := 'image/jpeg';
      end;
      if MIMEType = 'PNG' then
      begin
        MIMEType := 'image/png';
      end;
      if MIMEType = 'GIF' then
      begin
        MIMEType := 'image/gif';
      end;
      if MIMEType = 'BMP' then
      begin
        MIMEType := 'image/bmp';
      end;

      Result := SetUnicodeCoverPictureFromStream(FrameIndex, Description,
        PictureStream, MIMEType, CoverType);

    finally
      FreeAndNil(PictureStream);
    end;

  except
    // *
  end;
end;

function TID3v2Tag.Convertv2Tov3(FrameIndex: Integer): Boolean;
var
  V2FrameID: AnsiString;
begin
  Result := False;
  V2FrameID := Copy(Frames[FrameIndex].ID, 1, 3);
  if V2FrameID = 'PIC' then
  begin
    Frames[FrameIndex].ID := 'APIC';
    Convertv2PICtoAPIC(FrameIndex);
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TYE' then
  begin
    Frames[FrameIndex].ID := 'TYER';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TCO' then
  begin
    Frames[FrameIndex].ID := 'TCON';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'BUF' then
  begin
    Frames[FrameIndex].ID := 'RBUF';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'CNT' then
  begin
    Frames[FrameIndex].ID := 'PCNT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'COM' then
  begin
    Frames[FrameIndex].ID := 'COMM';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'CRA' then
  begin
    Frames[FrameIndex].ID := 'ENCR';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'CRM' then
  begin
    Frames[FrameIndex].ID := 'AENC';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'ETC' then
  begin
    Frames[FrameIndex].ID := 'ETCO';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'EQU' then
  begin
    Frames[FrameIndex].ID := 'EQUA';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'GEO' then
  begin
    Frames[FrameIndex].ID := 'GEOB';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'IPL' then
  begin
    Frames[FrameIndex].ID := 'TIPL';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'LNK' then
  begin
    Frames[FrameIndex].ID := 'LINK';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'MCI' then
  begin
    Frames[FrameIndex].ID := 'MCDI';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'MLL' then
  begin
    Frames[FrameIndex].ID := 'MLLT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'POP' then
  begin
    Frames[FrameIndex].ID := 'POPM';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'REV' then
  begin
    Frames[FrameIndex].ID := 'RVRB';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'RVA' then
  begin
    Frames[FrameIndex].ID := 'RVAD';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'SLT' then
  begin
    Frames[FrameIndex].ID := 'SYLT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'STC' then
  begin
    Frames[FrameIndex].ID := 'SYTC';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TAL' then
  begin
    Frames[FrameIndex].ID := 'TALB';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TBP' then
  begin
    Frames[FrameIndex].ID := 'TBPM';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TCM' then
  begin
    Frames[FrameIndex].ID := 'TCOM';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TCO' then
  begin
    Frames[FrameIndex].ID := 'TCON';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TCR' then
  begin
    Frames[FrameIndex].ID := 'TCOP';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TDA' then
  begin
    Frames[FrameIndex].ID := 'TDAT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TDY' then
  begin
    Frames[FrameIndex].ID := 'TDLY';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TEN' then
  begin
    Frames[FrameIndex].ID := 'TENC';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TFT' then
  begin
    Frames[FrameIndex].ID := 'TFLT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TIM' then
  begin
    Frames[FrameIndex].ID := 'TIME';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TKE' then
  begin
    Frames[FrameIndex].ID := 'TKEY';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TLA' then
  begin
    Frames[FrameIndex].ID := 'TLAN';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TLE' then
  begin
    Frames[FrameIndex].ID := 'TLEN';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TMT' then
  begin
    Frames[FrameIndex].ID := 'TMED';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TOA' then
  begin
    Frames[FrameIndex].ID := 'TOPE';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TOF' then
  begin
    Frames[FrameIndex].ID := 'TOFN';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TOL' then
  begin
    Frames[FrameIndex].ID := 'TOLY';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TOR' then
  begin
    Frames[FrameIndex].ID := 'TORY';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TOT' then
  begin
    Frames[FrameIndex].ID := 'TOAL';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TDR' then
  begin
    Frames[FrameIndex].ID := 'TRDA';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TP1' then
  begin
    Frames[FrameIndex].ID := 'TPE1';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TP2' then
  begin
    Frames[FrameIndex].ID := 'TPE2';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TP3' then
  begin
    Frames[FrameIndex].ID := 'TPE3';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TP4' then
  begin
    Frames[FrameIndex].ID := 'TPE4';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TPA' then
  begin
    Frames[FrameIndex].ID := 'TPOS';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TPB' then
  begin
    Frames[FrameIndex].ID := 'TPUB';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TRC' then
  begin
    Frames[FrameIndex].ID := 'TSRC';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TRD' then
  begin
    Frames[FrameIndex].ID := 'TRDA';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TRK' then
  begin
    Frames[FrameIndex].ID := 'TRCK';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TSI' then
  begin
    Frames[FrameIndex].ID := 'TSIZ';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TSS' then
  begin
    Frames[FrameIndex].ID := 'TSSE';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TT1' then
  begin
    Frames[FrameIndex].ID := 'TIT1';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TT2' then
  begin
    Frames[FrameIndex].ID := 'TIT2';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TT3' then
  begin
    Frames[FrameIndex].ID := 'TIT3';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TXT' then
  begin
    Frames[FrameIndex].ID := 'TEXT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TXX' then
  begin
    Frames[FrameIndex].ID := 'TXXX';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'TYE' then
  begin
    Frames[FrameIndex].ID := 'TYER';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'UFI' then
  begin
    Frames[FrameIndex].ID := 'UFID';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'ULT' then
  begin
    Frames[FrameIndex].ID := 'USLT';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WAF' then
  begin
    Frames[FrameIndex].ID := 'WOAF';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WAR' then
  begin
    Frames[FrameIndex].ID := 'WOAR';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WAS' then
  begin
    Frames[FrameIndex].ID := 'WOAS';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WCM' then
  begin
    Frames[FrameIndex].ID := 'WCOM';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WCP' then
  begin
    Frames[FrameIndex].ID := 'WCOP';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WPB' then
  begin
    Frames[FrameIndex].ID := 'WPUB';
    Result := True;
    Exit;
  end;
  if V2FrameID = 'WXX' then
  begin
    Frames[FrameIndex].ID := 'WXXX';
    Result := True;
    Exit;
  end;
end;

function TID3v2Tag.FrameExists(FrameID: TFrameID): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FrameCount - 1 do
  begin
    if FrameID = Frames[i].ID then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TID3v2Tag.FrameExists(FrameID: AnsiString): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FrameCount - 1 do
  begin
    if FrameID = Frames[i].ID then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TID3v2Tag.FrameTypeCount(FrameID: TFrameID): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FrameCount - 1 do
  begin
    if FrameID = Frames[i].ID then
    begin
      Inc(Result);
    end;
  end;
end;

function TID3v2Tag.SaveToStream(var TagStream: TStream; PaddingSizeToWrite:
  Integer = 0): Integer;
var
  UnCodedSize: Cardinal;
begin
  Result := ID3V2LIBRARY_ERROR;
  try
    if MajorVersion = 2 then
    begin
      MajorVersion := 3;
    end;
    if (MajorVersion < 3) or (MajorVersion > 4) then
    begin
      Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_VERSION;
      Exit;
    end;
    PaddingSize := PaddingSizeToWrite;
    EncodeSize;
    EncodeFlags;
    // * EncodeExtendedHeader;
    Result := WriteAllHeaders(TagStream);
    if Result <> ID3V2LIBRARY_SUCCESS then
    begin
      Exit;
    end;
    Result := WriteAllFrames(TagStream);
    if Result <> ID3V2LIBRARY_SUCCESS then
    begin
      Exit;
    end;
    Result := WritePadding(TagStream, PaddingSize);
    if Result <> ID3V2LIBRARY_SUCCESS then
    begin
      Exit;
    end;
    Result := ID3V2LIBRARY_SUCCESS;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function TID3v2Tag.SaveToFile(FileName: string): Integer;
var
  TagStream: TStream;
  NewTagStream: TStream;
  TagSizeInExistingStream: Cardinal;
  TagCodedSizeInExistingStream: Cardinal;
  WriteTagTotalSize: Integer;
  NeedToCopyExistingStream: Boolean;
  PaddingNeededToWrite: Integer;
  NewFile: Boolean;
  ExclusiveAccess: Boolean;

  function CheckTag: Boolean;
  var
    PreviousPosition: Int64;
  begin
    PreviousPosition := TagStream.Position;
    if ID3v2ValidTag(TagStream) then
    begin
      // * Skip version data and flags
      TagStream.Seek(3, soCurrent);
      TagStream.Read(TagCodedSizeInExistingStream, 4);
      UnSyncSafe(TagCodedSizeInExistingStream, 4, TagSizeInExistingStream);
      // * Add header size to size
      TagSizeInExistingStream := TagSizeInExistingStream + 10;
      if WriteTagTotalSize > TagSizeInExistingStream then
      begin
        NeedToCopyExistingStream := True;
        NewFile := True;
      end;
      TagStream.Seek(PreviousPosition, soBeginning);
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  end;

begin
  Result := ID3V2LIBRARY_ERROR;
  TagStream := nil;
  NewTagStream := nil;
  NewFile := False;
  try
    try
      if FrameCount = 0 then
      begin
        Result := ID3V2LIBRARY_ERROR_EMPTY_TAG;
        Exit;
      end;
      if MajorVersion = 2 then
      begin
        MajorVersion := 3;
      end;
      if CalculateTotalFramesSize = 0 then
      begin
        Result := ID3V2LIBRARY_ERROR_EMPTY_FRAMES;
        Exit;
      end;
      if not FileExists(FileName) then
      begin
        TagStream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
        ExclusiveAccess := True;
      end
      else
      begin
        try
          TagStream := TFileStream.Create(FileName, fmOpenReadWrite or
            fmShareExclusive);
          ExclusiveAccess := True;
          FreeAndNil(TagStream);
        except
          ExclusiveAccess := False;
        end;
        try
          TagStream := TFileStream.Create(FileName, fmOpenReadWrite or
            fmShareDenyWrite);
        except
          Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
          Exit;
        end;
      end;
      NeedToCopyExistingStream := False;
      WriteTagTotalSize := CalculateTagSize(0);
      try
        if CheckRIFF(TagStream) then
        begin
          if SeekRIFF(TagStream) > 0 then
          begin
            if CheckTag then
            begin
              if WriteTagTotalSize > TagSizeInExistingStream then
              begin
                TagStream.Seek(0, soBeginning);
                // * Update size datas
                Result := RIFFUpdateID3v2(FileName, TagStream,
                  WriteTagTotalSize, TagSizeInExistingStream, PaddingToWrite);
                if Result = ID3V2LIBRARY_SUCCESS then
                begin
                  Result := SaveToStream(TagStream, PaddingToWrite);
                end;
                Exit;
              end
              else
              begin
                PaddingNeededToWrite := TagSizeInExistingStream -
                  WriteTagTotalSize;
                // * Just write it
                Result := SaveToStream(TagStream, PaddingNeededToWrite);
                Exit;
              end;
              // * Need to create new Tag
            end
            else
            begin
              TagStream.Seek(0, soBeginning);
              Result := RIFFCreateID3v2(FileName, TagStream, WriteTagTotalSize,
                PaddingToWrite);
              if Result = ID3V2LIBRARY_SUCCESS then
              begin
                Result := SaveToStream(TagStream, PaddingToWrite);
              end;
              Exit;
            end;
            // * Need to create new Tag
          end
          else
          begin
            TagStream.Seek(0, soBeginning);
            Result := RIFFCreateID3v2(FileName, TagStream, WriteTagTotalSize,
              PaddingToWrite);
            if Result = ID3V2LIBRARY_SUCCESS then
            begin
              Result := SaveToStream(TagStream, PaddingToWrite);
            end;
            Exit;
          end;
        end
        else
        begin
          TagStream.Seek(0, soBeginning);
          if CheckAIFF(TagStream) then
          begin
            if SeekAIFF(TagStream) > 0 then
            begin
              if CheckTag then
              begin
                if WriteTagTotalSize > TagSizeInExistingStream then
                begin
                  TagStream.Seek(0, soBeginning);
                  // * Update size datas
                  Result := AIFFUpdateID3v2(FileName, TagStream,
                    WriteTagTotalSize, TagSizeInExistingStream, PaddingToWrite);
                  if Result = ID3V2LIBRARY_SUCCESS then
                  begin
                    Result := SaveToStream(TagStream, PaddingToWrite);
                  end;
                  Exit;
                end
                else
                begin
                  PaddingNeededToWrite := TagSizeInExistingStream -
                    WriteTagTotalSize;
                  // * Just write it
                  Result := SaveToStream(TagStream, PaddingNeededToWrite);
                  Exit;
                end;
                // * Need to create new Tag
              end
              else
              begin
                TagStream.Seek(0, soBeginning);
                Result := AIFFCreateID3v2(FileName, TagStream,
                  WriteTagTotalSize, PaddingToWrite);
                if Result = ID3V2LIBRARY_SUCCESS then
                begin
                  Result := SaveToStream(TagStream, PaddingToWrite);
                end;
                Exit;
              end;
            end
            else
            begin
              TagStream.Seek(0, soBeginning);
              Result := AIFFCreateID3v2(FileName, TagStream, WriteTagTotalSize,
                PaddingToWrite);
              if Result = ID3V2LIBRARY_SUCCESS then
              begin
                Result := SaveToStream(TagStream, PaddingToWrite);
              end;
              Exit;
            end;
          end
          else
          begin
            TagStream.Seek(0, soBeginning);
            if CheckRF64(TagStream) then
            begin
              if SeekRF64(TagStream) > 0 then
              begin
                if CheckTag then
                begin
                  if WriteTagTotalSize > TagSizeInExistingStream then
                  begin
                    TagStream.Seek(0, soBeginning);
                    // * Update size datas
                    Result := RF64UpdateID3v2(FileName, TagStream,
                      WriteTagTotalSize, TagSizeInExistingStream,
                      PaddingToWrite);
                    if Result = ID3V2LIBRARY_SUCCESS then
                    begin
                      Result := SaveToStream(TagStream, PaddingToWrite);
                    end;
                    Exit;
                  end
                  else
                  begin
                    PaddingNeededToWrite := TagSizeInExistingStream -
                      WriteTagTotalSize;
                    // * Just write it
                    Result := SaveToStream(TagStream, PaddingNeededToWrite);
                    Exit;
                  end;
                  // * Need to create new Tag
                end
                else
                begin
                  TagStream.Seek(0, soBeginning);
                  Result := RF64CreateID3v2(FileName, TagStream,
                    WriteTagTotalSize, PaddingToWrite);
                  if Result = ID3V2LIBRARY_SUCCESS then
                  begin
                    Result := SaveToStream(TagStream, PaddingToWrite);
                  end;
                  Exit;
                end;
              end
              else
              begin
                TagStream.Seek(0, soBeginning);
                Result := RF64CreateID3v2(FileName, TagStream,
                  WriteTagTotalSize, PaddingToWrite);
                if Result = ID3V2LIBRARY_SUCCESS then
                begin
                  Result := SaveToStream(TagStream, PaddingToWrite);
                end;
                Exit;
              end;
            end
            else
            begin
              // * Normal file (MP3) - tag at start
              TagStream.Seek(0, soBeginning);
              if not CheckTag then
              begin
                TagSizeInExistingStream := 0;
                NeedToCopyExistingStream := True;
                NewFile := True;
              end;
            end;
          end;
        end;
      except
        Result := ID3V2LIBRARY_ERROR_READING_FILE;
        Exit;
      end;

      if TagSizeInExistingStream = 0 then
      begin
        PaddingNeededToWrite := PaddingToWrite;
      end
      else
      begin
        // * Calculate padding here
        PaddingNeededToWrite := TagSizeInExistingStream - WriteTagTotalSize;
        if PaddingNeededToWrite < 0 then
        begin
          PaddingNeededToWrite := PaddingToWrite;
        end;
      end;

      if NewFile then
      begin
        if not ExclusiveAccess then
        begin
          Result := ID3V2LIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS;
          Exit;
        end;
        NewTagStream := TFileStream.Create(FileName + '.tmp', fmCreate or
          fmShareExclusive);
        try
          Result := SaveToStream(NewTagStream, PaddingNeededToWrite);
          TagStream.Seek(TagSizeInExistingStream, soBeginning);
          NewTagStream.CopyFrom(TagStream, TagStream.Size -
            TagSizeInExistingStream);
          if Assigned(TagStream) then
          begin
            FreeAndNil(TagStream);
          end;
          if Assigned(NewTagStream) then
          begin
            FreeAndNil(NewTagStream);
          end;
          if DeleteFile(FileName) then
          begin
            if RenameFile(FileName + '.tmp', FileName) then
            begin
              Result := ID3V2LIBRARY_SUCCESS;
              Exit;
            end;
          end
          else
          begin
            DeleteFile(FileName + '.tmp');
            Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          end;
        except
          Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
      end
      else
      begin
        try
          Result := SaveToStream(TagStream, PaddingNeededToWrite);
        except
          Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
      end;

    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
      if Assigned(NewTagStream) then
      begin
        FreeAndNil(NewTagStream);
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function TID3v2Tag.GetUnicodeText(FrameID: AnsiString; ReturnNativeText: Boolean
  = False): string;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeText(Index, ReturnNativeText);
end;

function TID3v2Tag.GetUnicodeText(FrameIndex: Integer; ReturnNativeText: Boolean
  = False): string;
var
  AnsiText: AnsiString;
  DataByte: Byte;
  DataWord: Word;
begin
  Result := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Frames[FrameIndex].Stream.Read(DataByte, 1);

    if DataByte > 3 then
    begin
      DataByte := 0;
      Frames[FrameIndex].Stream.Seek(0, soBeginning);
    end;

    case DataByte of
      // * ISO-8859-1
      0:
        begin
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if (DataByte = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              AnsiText := AnsiText + #13#10;
            end
            else
            begin
              if DataByte <> 0 then
              begin
                AnsiText := AnsiText + AnsiChar(DataByte);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
          Result := AnsiText;
        end;
      // * UTF-16
      1:
        begin
          Frames[FrameIndex].Stream.Read(DataByte, 1);
          if DataByte = $FF then
          begin
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte = $FE then
            begin
              repeat
                Frames[FrameIndex].Stream.Read(DataWord, 2);
                if (DataWord = 0) and (Frames[FrameIndex].Stream.Position <>
                  Frames[FrameIndex].Stream.Size) then
                begin
                  Result := Result + #13#10;
                end
                else
                begin
                  if DataWord <> 0 then
                  begin
                    Result := Result + Char(DataWord);
                  end;
                end;
              until Frames[FrameIndex].Stream.Position >=
                Frames[FrameIndex].Stream.Size;
            end;
          end;
        end;
      // * UTF-16BE
      2:
        begin
          repeat
            Frames[FrameIndex].Stream.Read(DataWord, 2);
            if (DataWord = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              Result := Result + #13#10;
            end
            else
            begin
              if DataWord <> 0 then
              begin
                Result := Result + Char(DataWord);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
        end;
      // * UTF-8
      3:
        begin
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if (DataByte = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              AnsiText := AnsiText + #13#10;
            end
            else
            begin
              if DataByte <> 0 then
              begin
                AnsiText := AnsiText + AnsiChar(DataByte);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
          if ReturnNativeText then
          begin
            Result := AnsiText;
          end
          else
          begin
            Result := UTF8Decode(AnsiText);
          end;
        end;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeText(FrameID: AnsiString; Text: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeText(Index, Text);
end;

function TID3v2Tag.SetUnicodeText(FrameIndex: Integer; Text: string): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * 2);
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeTextMultiple(FrameIndex: Integer; List: TStrings):
  Boolean;
begin
  Result := False;
  List.Clear;
  List.Text := GetUnicodeText(FrameIndex);
  Result := List.Text <> '';
end;

function TID3v2Tag.GetUnicodeTextMultiple(FrameID: AnsiString; List: TStrings):
  Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  List.Clear;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeTextMultiple(Index, List);
end;

function TID3v2Tag.SetUnicodeTextMultiple(FrameIndex: Integer; List: TStrings):
  Boolean;
var
  DataByte: Byte;
  i: Integer;
  Text: string;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);

    for i := 0 to List.Count - 1 do
    begin
      Text := List[i];
      Frames[FrameIndex].Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * 2);
    end;

    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeTextMultiple(FrameID: AnsiString; List: TStrings):
  Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeTextMultiple(Index, List);
end;

function TID3v2Tag.SetText(FrameID: AnsiString; Text: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetText(Index, Text);
end;

function TID3v2Tag.SetText(FrameIndex: Integer; Text: AnsiString): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    DataByte := $00;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PAnsiChar(Text)^, Length(Text));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUTF8Text(FrameID: AnsiString; Text: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUTF8Text(Index, Text);
end;

function TID3v2Tag.SetUTF8Text(FrameIndex: Integer; Text: string): Boolean;
var
  DataByte: Byte;
  UTF8EncodedText: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    DataByte := $03;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    UTF8EncodedText := UTF8Encode(Text);
    Frames[FrameIndex].Stream.Write(PAnsiChar(UTF8EncodedText)^,
      Length(UTF8EncodedText));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetRawText(FrameID: AnsiString; Text: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetRawText(Index, Text);
end;

function TID3v2Tag.SetRawText(FrameIndex: Integer; Text: AnsiString): Boolean;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    Frames[FrameIndex].Stream.Write(PAnsiChar(Text)^, Length(Text));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeComment(FrameID: AnsiString; var LanguageID:
  TLanguageID; var Description: string): string;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  LanguageID := '';
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeComment(Index, LanguageID, Description);
end;

function TID3v2Tag.FindUnicodeCommentByDescription(Description: string; var
  LanguageID: TLanguageID; var Comment: string)
  : Integer;
var
  FrameID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := -1;
  FrameID := 'COMM';
  GetLanguageID := '';
  GetDescription := '';
  Comment := '';
  for i := 0 to FrameCount - 1 do
  begin
    if FrameID = Frames[i].ID then
    begin
      GetContent := GetUnicodeComment(i, GetLanguageID, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        Comment := GetContent;
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.SetUnicodeCommentByDescription(Description: string;
  LanguageID: TLanguageID; Comment: string): Boolean;
var
  Index: Integer;
  FrameID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := False;
  Index := -1;
  FrameID := 'COMM';
  GetLanguageID := '';
  GetDescription := '';
  for i := 0 to FrameCount - 1 do
  begin
    if FrameID = Frames[i].ID then
    begin
      GetContent := GetUnicodeComment(i, GetLanguageID, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        Index := i;
        Break;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame('COMM');
  end;
  Result := SetUnicodeComment(Index, Comment, LanguageID, Description);
end;

function TID3v2Tag.GetUnicodeComment(FrameIndex: Integer; var LanguageID:
  TLanguageID; var Description: string): string;
begin
  Result := GetUnicodeContent(FrameIndex, LanguageID, Description);
end;

function TID3v2Tag.GetUnicodeContent(FrameID: AnsiString; var LanguageID:
  TLanguageID; var Description: string): string;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  LanguageID := '';
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeComment(Index, LanguageID, Description);
end;

function TID3v2Tag.GetUnicodeContent(FrameIndex: Integer; var LanguageID:
  TLanguageID; var Description: string): string;
var
  DataByte: Byte;
  UData: Word;
  ASCIIText: PAnsiChar;
  StrASCIIDescription: AnsiString;
  StrUDescription: string;
  PUDescription: PWideChar;
  EncodingFormat: Byte;
  UContent: PWideChar;
  StrAnsi: AnsiString;
begin
  Result := '';
  LanguageID := '';
  Description := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get encoding format
    Frames[FrameIndex].Stream.Read(EncodingFormat, 1);
    // * Get language ID
    Frames[FrameIndex].Stream.Read(LanguageID[0], 3);
    // * Get decription and content
    case EncodingFormat of
      0:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := StrASCIIDescription;
          // * Get the content
          ASCIIText := AllocMem(Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position + 1);
          Frames[FrameIndex].Stream.Read(ASCIIText^,
            Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position);
          Result := ASCIIText;
          FreeMem(ASCIIText);
        end;
      1:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := Copy(StrUDescription, 2, Length(StrUDescription));
          // * Get the content
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte = $FF then
            begin
              Frames[FrameIndex].Stream.Read(DataByte, 1);
              if DataByte = $FE then
              begin
                Break;
              end;
            end;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          UContent := AllocMem(Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position + 1);
          Frames[FrameIndex].Stream.Read(UContent^,
            Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position);
          Result := UContent;
          FreeMem(UContent);
        end;
      2:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          // * Get the content
          UContent := AllocMem(Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position + 1);
          Frames[FrameIndex].Stream.Read(UContent^,
            Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position);
          Result := UContent;
          FreeMem(UContent);
        end;
      3:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
          Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
            PAnsiChar(StrASCIIDescription),
            Length(StrASCIIDescription));
          Description := PUDescription;
          FreeMem(PUDescription);
          // * Get the content
          ASCIIText := AllocMem(Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position + 2);
          Frames[FrameIndex].Stream.Read(ASCIIText^,
            Frames[FrameIndex].Stream.Size -
            Frames[FrameIndex].Stream.Position);
          StrAnsi := ASCIIText;
          UContent := AllocMem((Length(StrAnsi) + 1) * 2);
          Utf8ToUnicode(UContent, Length(StrAnsi) * 2, PAnsiChar(StrAnsi),
            Length(StrAnsi));
          Result := UContent;
          FreeMem(ASCIIText);
        end;
    end;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeComment(FrameID: AnsiString; Comment: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeComment(Index, Comment, LanguageID, Description);
end;

function TID3v2Tag.SetUnicodeComment(FrameIndex: Integer; Comment: string;
  LanguageID: TLanguageID; Description: string): Boolean;
begin
  Result := SetUnicodeContent(FrameIndex, Comment, LanguageID, Description);
end;

function TID3v2Tag.SetContent(FrameID: AnsiString; Content: AnsiString;
  LanguageID: TLanguageID; Description: AnsiString)
  : Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetContent(Index, Content, LanguageID, Description);
end;

function TID3v2Tag.SetContent(FrameIndex: Integer; Content: AnsiString;
  LanguageID: TLanguageID; Description: AnsiString)
  : Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $00;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the language
    Frames[FrameIndex].Stream.Write(LanguageID[0], 3);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(Description)^, Length(Description)
      + 1);
    // * Write the content with
    Frames[FrameIndex].Stream.Write(PAnsiChar(Content)^, Length(Content));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUTF8Content(FrameID: AnsiString; Content: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUTF8Content(Index, Content, LanguageID, Description);
end;

function TID3v2Tag.SetUTF8Content(FrameIndex: Integer; Content: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  DataByte: Byte;
  ContentAnsi: AnsiString;
  DescriptionAnsi: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    ContentAnsi := UTF8Encode(Content);
    DescriptionAnsi := UTF8Encode(Description);
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $03;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the language
    Frames[FrameIndex].Stream.Write(LanguageID[0], 3);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(DescriptionAnsi)^,
      Length(DescriptionAnsi) + 1);
    // * Write the content
    Frames[FrameIndex].Stream.Write(PAnsiChar(ContentAnsi)^,
      Length(ContentAnsi));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeContent(FrameID: AnsiString; Content: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeContent(Index, Content, LanguageID, Description);
end;

function TID3v2Tag.SetUnicodeContent(FrameIndex: Integer; Content: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the language
    Frames[FrameIndex].Stream.Write(LanguageID[0], 3);
    // * Set the description
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PWideChar(Description)^, (Length(Description)
      + 1) * 2);
    // * Write the content with BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PWideChar(Content)^, (Length(Content) + 1) *
      2);
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeLyrics(FrameID: AnsiString; var LanguageID:
  TLanguageID; var Description: string): string;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  LanguageID := '';
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeLyrics(Index, LanguageID, Description);
end;

function TID3v2Tag.GetUnicodeLyrics(FrameIndex: Integer; var LanguageID:
  TLanguageID; var Description: string): string;
begin
  Result := GetUnicodeContent(FrameIndex, LanguageID, Description);
end;

function TID3v2Tag.SetUnicodeLyrics(FrameID: AnsiString; Lyrics: string;
  LanguageID: TLanguageID; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeContent(Index, Lyrics, LanguageID, Description);
end;

function TID3v2Tag.SetUnicodeLyrics(FrameIndex: Integer; Lyrics: string;
  LanguageID: TLanguageID; Description: string): Boolean;
begin
  Result := SetUnicodeContent(FrameIndex, Lyrics, LanguageID, Description);
end;

function TID3v2Tag.GetUnicodeCoverPictureStream(FrameID: AnsiString; var
  PictureStream: TStream; var MIMEType: AnsiString;
  var Description: string; var CoverType: Integer): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  MIMEType := '';
  Description := '';
  CoverType := 0;
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeCoverPictureStream(Index, PictureStream, MIMEType,
    Description, CoverType);
end;

function TID3v2Tag.GetUnicodeCoverPictureStream(FrameIndex: Integer;
  PictureStream: TStream; var MIMEType: AnsiString;
  var Description: string; var CoverType: Integer): Boolean;
var
  StrMimeType: AnsiString;
  Data: Byte;
  TextEncoding: Integer;
  StrASCIIDescription: AnsiString;
  StrUDescription: string;
  UData: Word;
  PUDescription: PWideChar;
begin
  Result := False;
  MIMEType := '';
  Description := '';
  CoverType := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
    Exit;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
      Exit;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);

    // * Get text encoding
    Frames[FrameIndex].Stream.Read(Data, 1);
    TextEncoding := Data;

    // * Get MIME type
    StrMimeType := '';
    repeat
      Frames[FrameIndex].Stream.Read(Data, 1);
      if Data <> 0 then
        StrMimeType := StrMimeType + AnsiChar(Data);
    until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
      Frames[FrameIndex].Stream.Size);

    // * Get picture type
    Frames[FrameIndex].Stream.Read(Data, 1);
    CoverType := Data;

    // * Get description
    // * ASCII format ISO-8859-1
    case TextEncoding of
      0:
        begin
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(Data, 1);
            if Data <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
            end;
          until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          StrUDescription := StrASCIIDescription;
        end;
      // * Unicode format UTF-16 with BOM
      1:
        begin
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          StrUDescription := Copy(StrUDescription, 2, Length(StrUDescription));
        end;
      // * Unicode format UTF-16BE without BOM
      2:
        begin
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      // * Unicode format UTF-8
      3:
        begin
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(Data, 1);
            if Data <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
            end;
          until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
          Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
            PAnsiChar(StrASCIIDescription),
            Length(StrASCIIDescription));
          StrUDescription := PUDescription;
          FreeMem(PUDescription);
        end;
    end;

    // * Get binary picture data
    PictureStream.Seek(0, soBeginning);
    try
      PictureStream.CopyFrom(Frames[FrameIndex].Stream,
        Frames[FrameIndex].Stream.Size - Frames[FrameIndex].Stream.Position);
      PictureStream.Seek(0, soFromBeginning);
    except

    end;

    // * Set results
    MIMEType := StrMimeType;
    Description := StrUDescription;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeCoverPictureInfo(FrameID: AnsiString; var MIMEType:
  AnsiString; var Description: string;
  var CoverType: Integer): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  MIMEType := '';
  Description := '';
  CoverType := 0;
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeCoverPictureInfo(Index, MIMEType, Description, CoverType);
end;

function TID3v2Tag.GetUnicodeCoverPictureInfo(FrameIndex: Integer; var MIMEType:
  AnsiString; var Description: string;
  var CoverType: Integer): Boolean;
var
  StrMimeType: AnsiString;
  Data: Byte;
  TextEncoding: Integer;
  StrASCIIDescription: AnsiString;
  StrUDescription: string;
  UData: Word;
  PUDescription: PWideChar;
begin
  Result := False;
  MIMEType := '';
  Description := '';
  CoverType := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);

    // * Get text encoding
    Frames[FrameIndex].Stream.Read(Data, 1);
    TextEncoding := Data;

    // * Get MIME type
    StrMimeType := '';
    repeat
      Frames[FrameIndex].Stream.Read(Data, 1);
      if Data <> 0 then
      begin
        StrMimeType := StrMimeType + AnsiChar(Data);
      end;
    until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
      Frames[FrameIndex].Stream.Size);

    // * Get picture type
    Frames[FrameIndex].Stream.Read(Data, 1);
    CoverType := Data;

    // * Get description
    // * ASCII format ISO-8859-1
    case TextEncoding of
      0:
        begin
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(Data, 1);
            if Data <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
            end;
          until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          StrUDescription := StrASCIIDescription;
        end;
      // * Unicode format UTF-16 with BOM
      1:
        begin
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          StrUDescription := Copy(StrUDescription, 2, Length(StrUDescription));
        end;
      // * Unicode format UTF-16BE without BOM
      2:
        begin
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      // * Unicode format UTF-8
      3:
        begin
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(Data, 1);
            if Data <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(Data);
            end;
          until (Data = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
          Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
            PAnsiChar(StrASCIIDescription),
            Length(StrASCIIDescription));
          StrUDescription := PUDescription;
          FreeMem(PUDescription);
        end;
    end;
    // * Set results
    MIMEType := StrMimeType;
    Description := StrUDescription;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeCoverPictureFromStream(FrameID: AnsiString;
  Description: string; PictureStream: TStream;
  MIMEType: AnsiString; CoverType: Integer): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeCoverPictureFromStream(Index, Description, PictureStream,
    MIMEType, CoverType);
end;

function TID3v2Tag.SetUnicodeCoverPictureFromStream(FrameIndex: Integer;
  Description: string; PictureStream: TStream;
  MIMEType: AnsiString; CoverType: Integer): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    /// * Set data is unicode
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the MIME type
    Frames[FrameIndex].Stream.Write(PAnsiChar(MIMEType)^, Length(MIMEType) + 1);
    /// * Set picture type
    DataByte := CoverType;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Write the description with BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PWideChar(Description)^, (Length(Description)
      + 1) * 2);
    // * Set picture data
    PictureStream.Seek(0, soBeginning);
    Frames[FrameIndex].Stream.CopyFrom(PictureStream, PictureStream.Size);
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeCoverPictureFromFile(FrameID: AnsiString;
  Description: string; PictureFileName: string;
  MIMEType: AnsiString; CoverType: Integer): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeCoverPictureFromFile(Index, Description, PictureFileName,
    MIMEType, CoverType);
end;

function TID3v2Tag.SetUnicodeCoverPictureFromFile(FrameIndex: Integer;
  Description: string; PictureFileName: string;
  MIMEType: AnsiString; CoverType: Integer): Boolean;
var
  PictureStream: TFileStream;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    PictureStream := nil;
    try
      PictureStream := TFileStream.Create(PictureFileName, fmOpenRead);
      Result := SetUnicodeCoverPictureFromStream(FrameIndex, Description,
        PictureStream, MIMEType, CoverType);
    finally
      if Assigned(PictureStream) then
      begin
        FreeAndNil(PictureStream);
      end;
    end;
  except
    // *
  end;
end;

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

function Max(const B1, B2: Integer): Integer;
begin
  if B1 > B2 then
  begin
    Result := B1
  end
  else
  begin
    Result := B2;
  end;
end;

function ReverseBytes(Value: Cardinal): Cardinal;
begin
  Result := (Value shr 24) or (Value shl 24) or ((Value and $00FF0000) shr 8) or
    ((Value and $0000FF00) shl 8);
end;

(*
  asm
  {$IFDEF CPU32}
  // --> EAX Value
  // <-- EAX Value
  BSWAP  EAX
  {$ENDIF CPU32}
  {$IFDEF CPU64}
  // --> ECX Value
  // <-- EAX Value
  MOV    EAX, ECX
  BSWAP  EAX
  {$ENDIF CPU64}
  end;
*)

function RemoveUnsynchronisationScheme(Source, Dest: TStream; BytesToRead:
  Integer): Boolean;
const
  MaxBufSize = $F000;
var
  LastWasFF: Boolean;
  BytesRead: Integer;
  SourcePtr, DestPtr: Integer;
  SourceBuf, DestBuf: array[0..MaxBufSize - 1] of Byte;
begin
  Result := False;

  { Replace $FF 00 with $FF }

  LastWasFF := False;
  while BytesToRead > 0 do
  begin
    { Read at max CBufferSize bytes from the stream }
    BytesRead := Source.Read(SourceBuf[0], Min(MaxBufSize, BytesToRead));
    // if BytesRead = 0 then
    // ID3Error(RsECouldNotReadData);

    Dec(BytesToRead, BytesRead);

    DestPtr := 0;
    SourcePtr := 0;

    while SourcePtr < BytesRead do
    begin
      { If previous was $FF and current is $00 then skip.. }
      if not LastWasFF or (SourceBuf[SourcePtr] <> $00) then
      begin
        { ..otherwise copy }
        DestBuf[DestPtr] := SourceBuf[SourcePtr];
        Inc(DestPtr);
      end;

      LastWasFF := SourceBuf[SourcePtr] = $FF;
      Inc(SourcePtr);
    end;
    Dest.Write(DestBuf[0], DestPtr);
  end;
  Result := True;
end;

function ApplyUnsynchronisationScheme(Source, Dest: TStream; BytesToRead:
  Integer): Boolean;
const
  MaxBufSize = $F000;
var
  LastWasFF: Boolean;
  BytesRead: Integer;
  SourcePtr, DestPtr: Integer;
  SourceBuf, DestBuf: PAnsiChar;
begin
  Result := False;
  { Replace $FF 00         with  $FF 00 00
    Replace $FF %111xxxxx  with  $FF 00 %111xxxxx (%11100000 = $E0 = 224 }

  GetMem(SourceBuf, Min(MaxBufSize div 2, BytesToRead));
  GetMem(DestBuf, 2 * Min(MaxBufSize div 2, BytesToRead));
  try
    LastWasFF := False;
    while BytesToRead > 0 do
    begin
      { Read at max CBufferSize div 2 bytes from the stream }
      BytesRead := Source.Read(SourceBuf^, Min(MaxBufSize div 2, BytesToRead));
      // if BytesRead = 0 then
      // ID3Error(RsECouldNotReadData);

      Dec(BytesToRead, BytesRead);

      DestPtr := 0;
      SourcePtr := 0;

      while SourcePtr < BytesRead do
      begin
        { If previous was $FF and current is $00 or >=$E0 then add space.. }
        if LastWasFF and ((SourceBuf[SourcePtr] = #$00) or
          (Byte(SourceBuf[SourcePtr]) and $E0 > 0)) then
        begin
          DestBuf[DestPtr] := #$00;
          Inc(DestPtr);
        end;

        { Copy }
        DestBuf[DestPtr] := SourceBuf[SourcePtr];
        Inc(DestPtr);

        LastWasFF := SourceBuf[SourcePtr] = #$FF;
        Inc(SourcePtr);
      end;
      Dest.Write(DestBuf^, DestPtr);
    end;
  finally
    FreeMem(SourceBuf);
    FreeMem(DestBuf);
  end;
  Result := True;
end;

function TID3v2Tag.GetURL(FrameID: AnsiString): AnsiString;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetURL(Index);
end;

function TID3v2Tag.GetUnicodeUserDefinedURLLink(FrameID: AnsiString; var
  Description: string): AnsiString;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  Description := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeUserDefinedURLLink(Index, Description);
end;

function TID3v2Tag.FindUnicodeUserDefinedURLLinkByDescription(Description:
  string; var URL: AnsiString): Integer;
var
  FrameID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetURL: AnsiString;
begin
  Result := -1;
  Description := '';
  FrameID := 'WXXX';
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = FrameID then
    begin
      GetURL := GetUnicodeUserDefinedURLLink(i, GetDescription);
      if GetDescription = Description then
      begin
        Result := i;
        URL := GetURL;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.SetUnicodeUserDefinedURLLinkByDescription(Description:
  string; URL: AnsiString): Boolean;
var
  FrameID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetURL: AnsiString;
  Index: Integer;
begin
  Result := False;
  Index := -1;
  FrameID := 'WXXX';
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = FrameID then
    begin
      GetURL := GetUnicodeUserDefinedURLLink(i, GetDescription);
      if GetDescription = Description then
      begin
        Index := i;
        Break;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame(FrameID);
  end;
  Result := SetUnicodeUserDefinedURLLink(Index, URL, Description);
end;

function TID3v2Tag.GetUnicodeUserDefinedURLLink(FrameIndex: Integer; var
  Description: string): AnsiString;
var
  DataByte: Byte;
  UData: Word;
  ASCIIText: PAnsiChar;
  StrASCIIDescription: AnsiString;
  StrUDescription: string;
  PUDescription: PWideChar;
  EncodingFormat: Byte;
begin
  Result := '';
  Description := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get encoding format
    Frames[FrameIndex].Stream.Read(EncodingFormat, 1);
    // * Get decription and content
    case EncodingFormat of
      0:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := StrASCIIDescription;
        end;
      1:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := Copy(StrUDescription, 2, Length(StrUDescription));
        end;
      2:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      3:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
          Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
            PAnsiChar(StrASCIIDescription),
            Length(StrASCIIDescription));
          Description := PUDescription;
          FreeMem(PUDescription);
        end;
    end;
    // * Get the URL
    ASCIIText := AllocMem(Frames[FrameIndex].Stream.Size -
      Frames[FrameIndex].Stream.Position + 1);
    Frames[FrameIndex].Stream.Read(ASCIIText^, Frames[FrameIndex].Stream.Size -
      Frames[FrameIndex].Stream.Position);
    Result := ASCIIText;
    FreeMem(ASCIIText);
  except
    // *
  end;
end;

function TID3v2Tag.SetUserDefinedURLLink(FrameID: AnsiString; URL: AnsiString;
  Description: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUserDefinedURLLink(Index, URL, Description);
end;

function TID3v2Tag.SetUserDefinedURLLink(FrameIndex: Integer; URL: AnsiString;
  Description: AnsiString): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $00;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(Description)^, Length(Description)
      + 1);
    // * Write the URL
    Frames[FrameIndex].Stream.Write(PAnsiChar(URL)^, (Length(URL)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUTF8UserDefinedURLLink(FrameID: AnsiString; URL:
  AnsiString; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUTF8UserDefinedURLLink(Index, URL, Description);
end;

function TID3v2Tag.SetUTF8UserDefinedURLLink(FrameIndex: Integer; URL:
  AnsiString; Description: string): Boolean;
var
  DataByte: Byte;
  DescriptionAnsi: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    DescriptionAnsi := UTF8Encode(Description);
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $03;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(DescriptionAnsi)^,
      Length(DescriptionAnsi) + 1);
    // * Write the URL
    Frames[FrameIndex].Stream.Write(PAnsiChar(URL)^, (Length(URL)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeUserDefinedURLLink(FrameID: AnsiString; URL:
  AnsiString; Description: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeUserDefinedURLLink(Index, URL, Description);
end;

function TID3v2Tag.SetUnicodeUserDefinedURLLink(FrameIndex: Integer; URL:
  AnsiString; Description: string): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    Frames[FrameIndex].Stream.Write(PWideChar(Description)^, (Length(Description)
      + 1) * 2);
    // * Write the URL
    Frames[FrameIndex].Stream.Write(PAnsiChar(URL)^, (Length(URL)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetURL(FrameIndex: Integer): AnsiString;
var
  ASCIIText: PAnsiChar;
begin
  Result := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get the URL
    ASCIIText := AllocMem(Frames[FrameIndex].Stream.Size -
      Frames[FrameIndex].Stream.Position + 1);
    Frames[FrameIndex].Stream.Read(ASCIIText^, Frames[FrameIndex].Stream.Size -
      Frames[FrameIndex].Stream.Position);
    Result := ASCIIText;
    FreeMem(ASCIIText);
  except
    // *
  end;
end;

function TID3v2Tag.SetURL(FrameID: AnsiString; URL: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetURL(Index, URL);
end;

function TID3v2Tag.SetURL(FrameIndex: Integer; URL: AnsiString): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Write the URL
    Frames[FrameIndex].Stream.Write(PAnsiChar(URL)^, (Length(URL)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function ID3v2EncodeTime(DateTime: TDateTime): string;
var
  Year: Word;
  Month: Word;
  Day: Word;
  Hour: Word;
  Minute: Word;
  Second: Word;
  MSec: Word;
  StrYear: string;
  StrMonth: string;
  StrDay: string;
  StrHour: string;
  StrMinute: string;
  StrSecond: string;
begin
  DecodeTime(DateTime, Hour, Minute, Second, MSec);
  DecodeDate(DateTime, Year, Month, Day);
  StrYear := IntToStr(Year);
  if Length(StrYear) = 1 then
  begin
    StrYear := '0' + StrYear;
  end;
  StrMonth := IntToStr(Month);
  if Length(StrMonth) = 1 then
  begin
    StrMonth := '0' + StrMonth;
  end;
  StrDay := IntToStr(Day);
  if Length(StrDay) = 1 then
  begin
    StrDay := '0' + StrDay;
  end;
  StrHour := IntToStr(Hour);
  if Length(StrHour) = 1 then
  begin
    StrHour := '0' + StrHour;
  end;
  StrMinute := IntToStr(Minute);
  if Length(StrMinute) = 1 then
  begin
    StrMinute := '0' + StrMinute;
  end;
  StrSecond := IntToStr(Second);
  if Length(StrSecond) = 1 then
  begin
    StrSecond := '0' + StrSecond;
  end;
  // * yyyy-MM-ddTHH:mm:ss
  Result := StrYear + '-' + StrMonth + '-' + StrDay + 'T' + StrHour + ':' +
    StrMinute + ':' + StrSecond;
end;

function ID3v2DecodeTime(ID3v2DateTime: string): TDateTime;
var
  Year: Word;
  Month: Word;
  Day: Word;
  Hour: Word;
  Minute: Word;
  Second: Word;
  MSec: Word;
  StrYear: string;
  StrMonth: string;
  StrDay: string;
  StrHour: string;
  StrMinute: string;
  StrSecond: string;
  Date: TDateTime;
  Time: TDateTime;
begin
  // * yyyy-MM-ddTHH:mm:ss
  StrYear := Copy(ID3v2DateTime, 1, 4);
  StrMonth := Copy(ID3v2DateTime, 6, 2);
  StrDay := Copy(ID3v2DateTime, 9, 2);
  StrHour := Copy(ID3v2DateTime, 12, 2);
  StrMinute := Copy(ID3v2DateTime, 15, 2);
  StrSecond := Copy(ID3v2DateTime, 18, 2);
  Year := StrToIntDef(StrYear, 0);
  Month := StrToIntDef(StrMonth, 0);
  Day := StrToIntDef(StrDay, 0);
  Hour := StrToIntDef(StrHour, 0);
  Minute := StrToIntDef(StrMinute, 0);
  Second := StrToIntDef(StrSecond, 0);
  MSec := 0;
  if Year = 0 then
  begin
    Year := 2000;
  end;
  if Month = 0 then
  begin
    Month := 1;
  end;
  if Day = 0 then
  begin
    Day := 1;
  end;
  Time := EncodeTime(Hour, Minute, Second, MSec);
  Date := EncodeDate(Year, Month, Day);
  Result := Date + Time;
end;

function ID3v2DecodeTimeToNumbers(ID3v2DateTime: string; var Year, Month, Day,
  Hour, Minute, Second: Integer): Boolean;
var
  StrYear: string;
  StrMonth: string;
  StrDay: string;
  StrHour: string;
  StrMinute: string;
  StrSecond: string;
  Date: TDateTime;
  Time: TDateTime;
begin
  Result := False;
  // * yyyy-MM-ddTHH:mm:ss
  StrYear := Copy(ID3v2DateTime, 1, 4);
  StrMonth := Copy(ID3v2DateTime, 6, 2);
  StrDay := Copy(ID3v2DateTime, 9, 2);
  StrHour := Copy(ID3v2DateTime, 12, 2);
  StrMinute := Copy(ID3v2DateTime, 15, 2);
  StrSecond := Copy(ID3v2DateTime, 18, 2);
  Year := StrToIntDef(StrYear, 0);
  Month := StrToIntDef(StrMonth, 0);
  Day := StrToIntDef(StrDay, 0);
  Hour := StrToIntDef(StrHour, -1);
  Minute := StrToIntDef(StrMinute, -1);
  Second := StrToIntDef(StrSecond, -1);
  Result := True;
end;

function TID3v2Tag.GetTime(FrameID: AnsiString): TDateTime;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := 0;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetTime(Index);
end;

function TID3v2Tag.GetTime(FrameIndex: Integer): TDateTime;
var
  TDRCValueANSI: PAnsiChar;
  TDRCValueUnicode: PWideChar;
  TDRCDateTime: string;
  Data: Byte;
  ReadAmount: Integer;
begin
  Result := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    ReadAmount := Frames[FrameIndex].Stream.Size;

    Frames[FrameIndex].Stream.Read(Data, 1);

    case Data of
      0:
        begin
          Frames[FrameIndex].Stream.Seek(1, soBeginning);
          ReadAmount := Frames[FrameIndex].Stream.Size - 1;
          TDRCValueANSI := AllocMem(ReadAmount);
          Frames[FrameIndex].Stream.Read(TDRCValueANSI^, ReadAmount);
          TDRCDateTime := TDRCValueANSI;
          FreeMem(TDRCValueANSI);
        end;
      1:
        begin
          Frames[FrameIndex].Stream.Seek(3, soBeginning);
          ReadAmount := Frames[FrameIndex].Stream.Size - 3;
          TDRCValueUnicode := AllocMem(ReadAmount);
          Frames[FrameIndex].Stream.Read(TDRCValueUnicode^, ReadAmount);
          TDRCDateTime := TDRCValueUnicode;
          FreeMem(TDRCValueUnicode);
        end;
      2:
        begin
          Frames[FrameIndex].Stream.Seek(1, soBeginning);
          ReadAmount := Frames[FrameIndex].Stream.Size - 1;
          TDRCValueUnicode := AllocMem(ReadAmount);
          Frames[FrameIndex].Stream.Read(TDRCValueUnicode^, ReadAmount);
          TDRCDateTime := TDRCValueUnicode;
          FreeMem(TDRCValueUnicode);
        end;
      3:
        begin
          Frames[FrameIndex].Stream.Seek(1, soBeginning);
          ReadAmount := Frames[FrameIndex].Stream.Size - 1;
          TDRCValueANSI := AllocMem(ReadAmount);
          Frames[FrameIndex].Stream.Read(TDRCValueANSI^, ReadAmount);
          TDRCDateTime := UTF8Decode(TDRCValueANSI);
          FreeMem(TDRCValueANSI);
        end;
    else
      begin
        Frames[FrameIndex].Stream.Seek(0, soBeginning);
        ReadAmount := Frames[FrameIndex].Stream.Size;
        TDRCValueANSI := AllocMem(ReadAmount);
        Frames[FrameIndex].Stream.Read(TDRCValueANSI^, ReadAmount);
        TDRCDateTime := TDRCValueANSI;
        FreeMem(TDRCValueANSI);
      end;
    end;

    Result := ID3v2DecodeTime(TDRCDateTime);
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
  except
    // *
  end;
end;

function TID3v2Tag.SetTime(FrameID: AnsiString; DateTime: TDateTime): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetTime(Index, DateTime);
end;

function TID3v2Tag.SetTime(FrameIndex: Integer; DateTime: TDateTime): Boolean;
var
  TDRCDateTime: AnsiString;
  Data: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    TDRCDateTime := ID3v2EncodeTime(DateTime);
    Data := 0;
    Frames[FrameIndex].Stream.Write(Data, 1);
    // * Set the date time
    Frames[FrameIndex].Stream.Write(PAnsiChar(TDRCDateTime)^,
      (Length(TDRCDateTime)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.CalculateTagSize(PaddingSize: Integer): Integer;
var
  TotalTagSize: Integer;
  i: Integer;
begin
  // * TODO: Ext header size
  TotalTagSize := 10 { + ExtendedHeaderSize3 };
  if MajorVersion = 3 then
  begin
    for i := 0 to FrameCount - 1 do
    begin
      if (Frames[i].Stream.Size = 0) or (not ValidID3v2FrameID(Frames[i].ID)) then
      begin
        Continue;
      end;
      TotalTagSize := TotalTagSize + Frames[i].Stream.Size + 10;
      if Frames[i].DataLengthIndicator or Frames[i].Compressed then
      begin
        TotalTagSize := TotalTagSize + 4;
      end;
    end;
  end;
  if MajorVersion > 3 then
  begin
    for i := 0 to FrameCount - 1 do
    begin
      if (Frames[i].Stream.Size = 0) or (not ValidID3v2FrameID(Frames[i].ID)) then
      begin
        Continue;
      end;
      TotalTagSize := TotalTagSize + 10;
      TotalTagSize := TotalTagSize + Frames[i].Stream.Size;
      if Frames[i].GroupingIdentity then
      begin
        TotalTagSize := TotalTagSize + 1;
      end;
      if Frames[i].Encrypted then
      begin
        TotalTagSize := TotalTagSize + 1;
      end;
      if Frames[i].DataLengthIndicator then
      begin
        TotalTagSize := TotalTagSize + 4;
      end;
    end;
  end;
  TotalTagSize := TotalTagSize + PaddingSize;
  Result := TotalTagSize;
end;

function TID3v2Tag.CalculateTotalFramesSize: Integer;
var
  TotalFramesSize: Integer;
  i: Integer;
begin
  TotalFramesSize := 0;
  for i := 0 to FrameCount - 1 do
  begin
    if ValidID3v2FrameID(Frames[i].ID) then
    begin
      TotalFramesSize := TotalFramesSize + Frames[i].Stream.Size;
    end;
  end;
  Result := TotalFramesSize;
end;

function TID3v2Tag.FullFrameSize(FrameIndex: Cardinal): Cardinal;
begin
  if MajorVersion = 2 then
  begin
    Result := Frames[FrameIndex].Stream.Size;
  end;
  if MajorVersion = 3 then
  begin
    Result := Frames[FrameIndex].Stream.Size;
    if Frames[FrameIndex].Compressed or Frames[FrameIndex].DataLengthIndicator then
    begin
      Result := Result + 4;
    end;
    if Frames[FrameIndex].Encrypted then
    begin
      Result := Result + 1;
    end;
    if Frames[FrameIndex].GroupingIdentity then
    begin
      Result := Result + 1;
    end;
  end;
  if MajorVersion > 3 then
  begin
    Result := Frames[FrameIndex].Stream.Size;
    if Frames[FrameIndex].GroupingIdentity then
    begin
      Result := Result + 1;
    end;
    if Frames[FrameIndex].Encrypted then
    begin
      Result := Result + 1;
    end;
    if Frames[FrameIndex].DataLengthIndicator then
    begin
      Result := Result + 4;
    end;
  end;
end;

procedure TID3v2Tag.Clear;
begin
  Self.DeleteAllFrames;
  FileName := '';
  Loaded := False;
  MajorVersion := 3;
  MinorVersion := 0;
  Flags := 0;
  Unsynchronised := False;
  Compressed := False;
  ExtendedHeader := False;
  Experimental := False;
  Size := 0;
  CodedSize := 0;
  PaddingSize := 0;
  PaddingToWrite := ID3V2LIBRARY_DEFAULT_PADDING_SIZE;
  if Assigned(ExtendedHeader3) then
  begin
    FreeAndNil(ExtendedHeader3);
  end;
  ExtendedHeader3 := TID3v2ExtendedHeader3.Create;
  if Assigned(ExtendedHeader4) then
  begin
    FreeAndNil(ExtendedHeader4);
  end;
  ExtendedHeader4 := TID3v2ExtendedHeader4.Create;
end;

function TID3v2Tag.WriteAllFrames(var TagStream: TStream): Integer;
var
  i: Integer;
  UnCodedSize: Cardinal;
  ReversedFlags: Word;
  CodedUncompressedSize: Cardinal;
begin
  Result := ID3V2LIBRARY_ERROR;
  try
    for i := 0 to FrameCount - 1 do
    begin
      if (not ValidID3v2FrameID(Frames[i].ID)) or (Frames[i].Stream.Size = 0) then
      begin
        Continue;
      end;
      TagStream.Write(Frames[i].ID, 4);
      UnCodedSize := FullFrameSize(i);
      if MajorVersion = 3 then
      begin
        CodedSize := ReverseBytes(UnCodedSize);
        TagStream.Write(CodedSize, 4);
        Frames[i].EncodeFlags3;
        TagStream.Write(Frames[i].Flags, 2);
        if Frames[i].Compressed or Frames[i].DataLengthIndicator then
        begin
          TagStream.Write(Frames[i].DataLengthIndicatorValue, 4);
        end;
        if Frames[i].Encrypted then
        begin
          TagStream.Write(Frames[i].EncryptionMethod, 1);
        end;
        if Frames[i].GroupingIdentity then
        begin
          TagStream.Write(Frames[i].GroupIdentifier, 1);
        end;
      end;
      if MajorVersion = 4 then
      begin
        UnCodedSize := FullFrameSize(i);
        SyncSafe(UnCodedSize, CodedSize, 4);
        TagStream.Write(CodedSize, 4);
        Frames[i].EncodeFlags4;
        ReversedFlags := Swap16(Frames[i].Flags);
        TagStream.Write(ReversedFlags, 2);
        if Frames[i].GroupingIdentity then
        begin
          TagStream.Write(Frames[i].GroupIdentifier, 1);
        end;
        if Frames[i].Encrypted then
        begin
          TagStream.Write(Frames[i].EncryptionMethod, 1);
        end;
        if Frames[i].DataLengthIndicator then
        begin
          TagStream.Write(Frames[i].DataLengthIndicatorValue, 4);
        end;
      end;
      TagStream.CopyFrom(Frames[i].Stream, 0);
    end;
    Result := ID3V2LIBRARY_SUCCESS;
  except
    Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
  end;
end;

function TID3v2Tag.WriteAllHeaders(var TagStream: TStream): Integer;
begin
  Result := ID3V2LIBRARY_ERROR;
  try
    TagStream.Write(ID3v2ID, 3);
    TagStream.Write(MajorVersion, 1);
    TagStream.Write(MinorVersion, 1);
    if MajorVersion = 3 then
    begin
      TagStream.Write(Flags, 1);
      TagStream.Write(CodedSize, 4);
    end;
    if MajorVersion = 4 then
    begin
      TagStream.Write(Flags, 1);
      TagStream.Write(CodedSize, 4);
    end;
    if ExtendedHeader then
    begin
      // * TODO
      if MajorVersion = 3 then
      begin

      end;
      if MajorVersion >= 4 then
      begin

      end;
    end;
    Result := ID3V2LIBRARY_SUCCESS;
  except
    Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
  end;
end;

function WritePadding(var TagStream: TStream; PaddingSize: Integer): Integer;
var
  i: Integer;
  Data: Byte;
begin
  Result := ID3V2LIBRARY_ERROR;
  try
    Data := $00;
    for i := 0 to PaddingSize - 1 do
    begin
      TagStream.Write(Data, 1);
    end;
    Result := ID3V2LIBRARY_SUCCESS;
  except
    Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
  end;
end;

function LanguageIDtoString(LangageId: TLanguageID): string;
var
  i: Integer;
begin
  Result := '';
  for i := low(TLanguageID) to high(TLanguageID) do
  begin
    if LangageId[i] <> #0 then
    begin
      Result := Result + LangageId[i];
    end;
  end;
end;

procedure TID3v2Tag.EncodeSize;
var
  UnCodedSize: Cardinal;
begin
  UnCodedSize := CalculateTagSize(PaddingSize) - 10;
  SyncSafe(UnCodedSize, CodedSize, 4);
end;

function TID3v2Tag.RemoveUnsynchronisationOnExtendedHeaderSize: Boolean;
begin
  // Result := RemoveUnsynchronisationOnStream(ExtendedHeader3.SizeData);
end;

function TID3v2Tag.ApplyUnsynchronisationOnExtendedHeaderSize: Boolean;
begin
  // Result := ApplyUnsynchronisationOnStream(ExtendedHeader3.SizeData);
end;

function TID3v2Tag.RemoveUnsynchronisationOnExtendedHeaderData: Boolean;
begin
  Result := RemoveUnsynchronisationOnStream(ExtendedHeader3.Data);
end;

function TID3v2Tag.ApplyUnsynchronisationOnExtendedHeaderData: Boolean;
begin
  Result := ApplyUnsynchronisationOnStream(ExtendedHeader3.Data);
end;

function RemoveUnsynchronisationOnStream(Stream: TMemoryStream): Boolean;
var
  UnUnsyncronisedStream: TMemoryStream;
  Success: Boolean;
begin
  Result := False;
  UnUnsyncronisedStream := nil;
  try
    UnUnsyncronisedStream := TMemoryStream.Create;
    Stream.Seek(0, soBeginning);
    Success := RemoveUnsynchronisationScheme(Stream, UnUnsyncronisedStream,
      Stream.Size);
    if Success then
    begin
      Stream.Clear;
      UnUnsyncronisedStream.Seek(0, soBeginning);
      Stream.CopyFrom(UnUnsyncronisedStream, 0);
      Result := True;
    end;
  finally
    if Assigned(UnUnsyncronisedStream) then
    begin
      FreeAndNil(UnUnsyncronisedStream);
    end;
  end;
end;

function ApplyUnsynchronisationOnStream(Stream: TMemoryStream): Boolean;
var
  UnsyncronisedStream: TMemoryStream;
  Success: Boolean;
begin
  Result := False;
  UnsyncronisedStream := nil;
  try
    UnsyncronisedStream := TMemoryStream.Create;
    Stream.Seek(0, soBeginning);
    Success := ApplyUnsynchronisationScheme(Stream, UnsyncronisedStream,
      Stream.Size);
    if Success then
    begin
      Stream.Clear;
      UnsyncronisedStream.Seek(0, soBeginning);
      Stream.CopyFrom(UnsyncronisedStream, 0);
      Result := True;
    end;
  finally
    if Assigned(UnsyncronisedStream) then
    begin
      FreeAndNil(UnsyncronisedStream);
    end;
  end;
end;

// CPUX64

function TID3v2Tag.GetSEBR(FrameID: AnsiString):
{$IFDEF CPUX64}Double{$ELSE}Extended{$ENDIF};
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := 0;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetSEBR(Index);
end;

function TID3v2Tag.GetSEBR(FrameIndex: Integer):
{$IFDEF CPUX64}Double{$ELSE}Extended{$ENDIF};
var
  SEBR: {$IFDEF CPUX64}Double{$ELSE}Extended{$ENDIF};
  SEBRStr: AnsiString;
begin
  Result := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
{$IFDEF CPUX64}
  SEBRStr := GetSEBRString(FrameIndex);
  if Copy(SEBRStr, 1, 1) = '~' then
  begin
    Result := StrToFloatDef(Copy(SEBRStr, 2, Length(SEBRStr)), 0);
  end;
{$ELSE}
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  Frames[FrameIndex].Stream.Seek(0, soBeginning);
  try
    SEBR := 0;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Frames[FrameIndex].Stream.Read(SEBR, 10);
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Result := SEBR;
  except
    // *
  end;
  if SEBR = 0 then
  begin
    SEBRStr := GetSEBRString(FrameIndex);
    if Copy(SEBRStr, 1, 1) = '~' then
    begin
      Result := StrToFloatDef(Copy(SEBRStr, 2, Length(SEBRStr)), 0);
    end;
  end;
{$ENDIF}
end;

function TID3v2Tag.GetSEBRString(FrameIndex: Integer): AnsiString;
var
  SEBR: AnsiString;
  Data: Byte;
begin
  Result := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  Frames[FrameIndex].Stream.Seek(10, soBeginning);
  try
    SEBR := '';
    Data := 0;
    repeat
      Frames[FrameIndex].Stream.Read(Data, 1);
      if Data <> 0 then
      begin
        SEBR := SEBR + AnsiChar(Data);
      end;
    until Frames[FrameIndex].Stream.Position >= Frames[FrameIndex].Stream.Size;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Result := SEBR;
  except
    // *
  end;
end;

function TID3v2Tag.SetSEBR(FrameID: AnsiString; BitRate: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetSEBR(Index, BitRate);
end;

function TID3v2Tag.SetSEBR(FrameIndex: Integer; BitRate: AnsiString): Boolean;
var
  Data: Byte;
  i: Integer;
  SEBR: Extended;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  Frames[FrameIndex].Stream.Clear;
  try
{$IFDEF CPUX64}
    Data := 0;
    for i := 0 to 9 do
    begin
      Frames[FrameIndex].Stream.Write(Data, 1);
    end;
{$ELSE}
    if Copy(BitRate, 1, 1) = '~' then
    begin
      SEBR := StrToFloatDef(Copy(BitRate, 2, Length(BitRate)), 0);
    end;
    Frames[FrameIndex].Stream.Write(SEBR, 10);
{$ENDIF}
    Frames[FrameIndex].Stream.Write(PAnsiChar(BitRate)^, Length(BitRate));
    Result := True;
  except
    // *
  end;
end;

{$IFNDEF CPUX64}

function TID3v2Tag.SetSEBR(FrameID: AnsiString; BitRate: Extended): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetSEBR(Index, BitRate);
end;

function TID3v2Tag.SetSEBR(FrameIndex: Integer; BitRate: Extended): Boolean;
var
  StrSEBR: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  Frames[FrameIndex].Stream.Clear;
  try
    Frames[FrameIndex].Stream.Write(BitRate, 10);
    StrSEBR := FloatToStr(BitRate);
    Frames[FrameIndex].Stream.Write(Pointer(StrSEBR)^, Length(StrSEBR));
    Result := True;
  except
    // *
  end;
end;

{$ENDIF}

function TID3v2Tag.GetSampleCache(FrameIndex: Integer; ForceDecompression:
  Boolean; var Version: Byte; var Channels: Integer)
  : TID3v2SampleCache;
var
  ID: Integer;
  SESCHeaderSize: Cardinal;
  ReportedChannels: Integer;
  DataVersion: Byte;
  SeekPosition: Integer;
begin
  SetLength(Result, 0);
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  Version := 1;
  Channels := 2;
  if Frames[FrameIndex].Unsynchronised then
  begin
    Frames[FrameIndex].RemoveUnsynchronisation;
  end;
  if Frames[FrameIndex].Compressed or ForceDecompression then
  begin
    Frames[FrameIndex].DeCompress;
  end;
  Frames[FrameIndex].Stream.Seek(0, soBeginning);
  try
    Frames[FrameIndex].Stream.Read(ID, 4);
    if ID = ID3V2LIBRARY_SESC_ID then
    begin
      Frames[FrameIndex].Stream.Read(DataVersion, 1);
      Frames[FrameIndex].Stream.Read(SESCHeaderSize, 4);
      Version := DataVersion;
      if DataVersion = ID3V2LIBRARY_SESC_VERSION2 then
      begin
        if SESCHeaderSize >= 4 then
        begin
          Frames[FrameIndex].Stream.Read(ReportedChannels, 4);
          SeekPosition := SESCHeaderSize - 4;
          Frames[FrameIndex].Stream.Seek(SeekPosition, soCurrent);
        end;
      end;
    end
    else
    begin
      Frames[FrameIndex].Stream.Seek(-4, soCurrent);
    end;
    SetLength(Result, Frames[FrameIndex].Stream.Size -
      Frames[FrameIndex].Stream.Position);
    Frames[FrameIndex].Stream.Read(Pointer(Result)^,
      Frames[FrameIndex].Stream.Size - Frames[FrameIndex].Stream.Position);
  except
    // *
  end;
  Frames[FrameIndex].Stream.Seek(0, soBeginning);
end;

function TID3v2Tag.SetSampleCache(FrameIndex: Integer; SESC: TID3v2SampleCache;
  Channels: Integer): Boolean;
var
  SESCHeaderSize: Cardinal;
  SESCID: Integer;
  DataVersion: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    SESCID := ID3V2LIBRARY_SESC_ID;
    Frames[FrameIndex].Stream.Write(SESCID, 4);
    DataVersion := ID3V2LIBRARY_SESC_VERSION2;
    Frames[FrameIndex].Stream.Write(DataVersion, 1);
    SESCHeaderSize := 4;
    Frames[FrameIndex].Stream.Write(SESCHeaderSize, 4);
    Frames[FrameIndex].Stream.Write(Channels, 4);
    Frames[FrameIndex].Stream.Write(Pointer(SESC)^, Length(SESC));
    Frames[FrameIndex].Compress;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetSEFC(FrameIndex: Integer): Int64;
var
  PSEFC: PAnsiChar;
  SEFC: AnsiString;
  Data: Byte;
begin
  Result := -1;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  Frames[FrameIndex].Stream.Seek(0, soBeginning);
  PSEFC := AllocMem(Frames[FrameIndex].Stream.Size);
  try
    try
      Frames[FrameIndex].Stream.Read(Data, 1);
      if Data = $01 then
      begin
        Frames[FrameIndex].Stream.Read(PSEFC, Frames[FrameIndex].Stream.Size);
        SEFC := PSEFC;
        Result := StrToIntDef(SEFC, 0);
      end;
    except
      // *
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
  finally
    FreeMem(PSEFC);
  end;
end;

function TID3v2Tag.SetSEFC(FrameIndex: Integer; SEFC: Int64): Boolean;
var
  StrSEFC: AnsiString;
  Data: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    StrSEFC := IntToStr(SEFC);
    Data := $00;
    Frames[FrameIndex].Stream.Write(Data, 1);
    Frames[FrameIndex].Stream.Write(PAnsiChar(StrSEFC)^, Length(StrSEFC));
    Result := True;
  except
    // *
  end;
end;

procedure AnsiStringToPAnsiChar(const Source: AnsiString; Dest: PAnsiChar; const
  MaxLength: Integer);
begin
  Move(PAnsiChar(Source)^, Dest^, Min(MaxLength, Length(Source)));
end;

procedure StringToLanguageID(const Source: string; var Dest: TLanguageID);
var
  AnsiStr: AnsiString;
begin
  AnsiStr := Source;
  AnsiStringToPAnsiChar(AnsiStr, Dest, 3);
end;

function TID3v2Tag.SetAlbumColors(FrameIndex: Integer; TitleColor, TextColor:
  Cardinal): Boolean;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    Frames[FrameIndex].Stream.Write(TitleColor, 4);
    Frames[FrameIndex].Stream.Write(TextColor, 4);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetAlbumColors(FrameID: AnsiString; TitleColor, TextColor:
  Cardinal): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetAlbumColors(Index, TitleColor, TextColor);
end;

function TID3v2Tag.GetAlbumColors(FrameID: AnsiString; var TitleColor,
  TextColor: Cardinal): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := GetAlbumColors(Index, TitleColor, TextColor);
end;

function TID3v2Tag.GetAlbumColors(FrameIndex: Integer; var TitleColor,
  TextColor: Cardinal): Boolean;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Frames[FrameIndex].Stream.Read(TitleColor, 4);
    Frames[FrameIndex].Stream.Read(TextColor, 4);
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetTLEN(FrameID: AnsiString; TLEN: Integer): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetTLEN(Index, TLEN);
end;

function TID3v2Tag.SetTLEN(FrameIndex: Integer; TLEN: Integer): Boolean;
var
  TLENString: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    TLENString := #0 + IntToStr(TLEN);
    Frames[FrameIndex].Stream.Write(TLENString[1], System.Length(TLENString));
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetPlayCount(FrameID: AnsiString): Cardinal;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := 0;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := GetPlayCount(Index);
end;

function TID3v2Tag.GetPlayCount(FrameIndex: Integer): Cardinal;
var
  Data: Byte;
  i: Integer;
  Value: Cardinal;
begin
  Result := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  if Frames[FrameIndex].Stream.Size = 0 then
  begin
    Exit;
  end;
  try
    Value := 0;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    for i := 0 to Frames[FrameIndex].Stream.Size - 1 do
    begin
      Value := Value shl 8;
      Frames[FrameIndex].Stream.Read(Data, 1);
      Value := Value + Data;
    end;
    Result := Value;
  except
    // *
  end;
end;

function TID3v2Tag.SetPlayCount(FrameID: AnsiString; PlayCount: Cardinal):
  Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetPlayCount(Index, PlayCount);
end;

function TID3v2Tag.SetPlayCount(FrameIndex: Integer; PlayCount: Cardinal):
  Boolean;
var
  Data: Byte;
  Value: Cardinal;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    Value := PlayCount shr 24;
    Data := Value;
    Frames[FrameIndex].Stream.Write(Data, 1);
    Value := PlayCount shl 8;
    Value := Value shr 24;
    Data := Value;
    Frames[FrameIndex].Stream.Write(Data, 1);
    Value := PlayCount shl 16;
    Value := Value shr 24;
    Data := Value;
    Frames[FrameIndex].Stream.Write(Data, 1);
    Value := PlayCount shl 24;
    Value := Value shr 24;
    Data := Value;
    Frames[FrameIndex].Stream.Write(Data, 1);
    Result := True;
  except
    // *
  end;
end;

function Swap16(ASmallInt: SmallInt): SmallInt; register;
{
  asm
  xchg al,ah
}
begin
  Result := Swap(ASmallInt);
end;

function TID3v2Tag.RemoveUnsynchronisationOnAllFrames: Boolean;
var
  i: Integer;
begin
  Result := False;
  try
    if MajorVersion = 3 then
    begin
      if Unsynchronised then
      begin
        for i := 0 to FrameCount - 1 do
        begin
          Frames[i].RemoveUnsynchronisation;
        end;
        Unsynchronised := False;
      end;
    end;
    if MajorVersion = 4 then
    begin
      for i := 0 to FrameCount - 1 do
      begin
        if Frames[i].Unsynchronised then
        begin
          Frames[i].RemoveUnsynchronisation;
        end;
      end;
      Unsynchronised := False;
    end;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.ApplyUnsynchronisationOnAllFrames: Boolean;
var
  i: Integer;
begin
  Result := False;
  try
    if MajorVersion = 3 then
    begin
      for i := 0 to FrameCount - 1 do
      begin
        Frames[i].ApplyUnsynchronisation;
      end;
      Unsynchronised := True;
    end;
    if MajorVersion = 4 then
    begin
      for i := 0 to FrameCount - 1 do
      begin
        if not Frames[i].Unsynchronised then
        begin
          Frames[i].ApplyUnsynchronisation;
        end;
      end;
      Unsynchronised := True;
    end;
    Result := True;
  except
    // *
  end;
end;

function APICType2Str(PictureType: Integer): string;
begin
  Result := 'Other';
  if PictureType = $00 then
  begin
    Result := 'Other';
    Exit;
  end;
  if PictureType = $01 then
  begin
    Result := '32x32 pixels ''file icon'' (PNG only)';
    Exit;
  end;
  if PictureType = $02 then
  begin
    Result := 'Other file icon';
    Exit;
  end;
  if PictureType = $03 then
  begin
    Result := 'Cover (front)';
    Exit;
  end;
  if PictureType = $04 then
  begin
    Result := 'Cover (back)';
    Exit;
  end;
  if PictureType = $05 then
  begin
    Result := 'Leaflet page';
    Exit;
  end;
  if PictureType = $06 then
  begin
    Result := 'Media (e.g. label side of CD)';
    Exit;
  end;
  if PictureType = $07 then
  begin
    Result := 'Lead artist/lead performer/soloist';
    Exit;
  end;
  if PictureType = $08 then
  begin
    Result := 'Artist/performer';
    Exit;
  end;
  if PictureType = $09 then
  begin
    Result := 'Conductor';
    Exit;
  end;
  if PictureType = $0A then
  begin
    Result := 'Band/Orchestra';
    Exit;
  end;
  if PictureType = $0B then
  begin
    Result := 'Composer';
  end;
  if PictureType = $0C then
  begin
    Result := 'Lyricist/text writer';
    Exit;
  end;
  if PictureType = $0D then
  begin
    Result := 'Recording Location';
    Exit;
  end;
  if PictureType = $0E then
  begin
    Result := 'During recording';
    Exit;
  end;
  if PictureType = $0F then
  begin
    Result := 'During performance';
    Exit;
  end;
  if PictureType = $10 then
  begin
    Result := 'Movie/video screen capture';
    Exit;
  end;
  if PictureType = $11 then
  begin
    Result := 'A bright coloured fish';
    Exit;
  end;
  if PictureType = $12 then
  begin
    Result := 'Illustration';
    Exit;
  end;
  if PictureType = $13 then
  begin
    Result := 'Band/artist logotype';
    Exit;
  end;
  if PictureType = $14 then
  begin
    Result := 'Publisher/Studio logotype';
    Exit;
  end;
end;

function APICTypeStr2No(PictureType: string): Integer;
begin
  Result := $00;
  if PictureType = 'Other' then
  begin
    Result := $00;
    Exit;
  end;
  if PictureType = '32x32 pixels ''file icon'' (PNG only)' then
  begin
    Result := $01;
    Exit;
  end;
  if PictureType = 'Other file icon' then
  begin
    Result := $02;
    Exit;
  end;
  if PictureType = 'Cover (front)' then
  begin
    Result := $03;
    Exit;
  end;
  if PictureType = 'Cover (back)' then
  begin
    Result := $04;
    Exit;
  end;
  if PictureType = 'Leaflet page' then
  begin
    Result := $05;
    Exit;
  end;
  if PictureType = 'Media (e.g. label side of CD)' then
  begin
    Result := $06;
    Exit;
  end;
  if PictureType = 'Lead artist/lead performer/soloist' then
  begin
    Result := $07;
    Exit;
  end;
  if PictureType = 'Artist/performer' then
  begin
    Result := $08;
    Exit;
  end;
  if PictureType = 'Conductor' then
  begin
    Result := $09;
    Exit;
  end;
  if PictureType = 'Band/Orchestra' then
  begin
    Result := $0A;
    Exit;
  end;
  if PictureType = 'Composer' then
  begin
    Result := $0B;
  end;
  if PictureType = 'Lyricist/text writer' then
  begin
    Result := $0C;
    Exit;
  end;
  if PictureType = 'Recording Location' then
  begin
    Result := $0D;
    Exit;
  end;
  if PictureType = 'During recording' then
  begin
    Result := $0E;
    Exit;
  end;
  if PictureType = 'During performance' then
  begin
    Result := $0F;
    Exit;
  end;
  if PictureType = 'Movie/video screen capture' then
  begin
    Result := $10;
    Exit;
  end;
  if PictureType = 'A bright coloured fish' then
  begin
    Result := $11;
    Exit;
  end;
  if PictureType = 'Illustration' then
  begin
    Result := $12;
    Exit;
  end;
  if PictureType = 'Band/artist logotype' then
  begin
    Result := $13;
    Exit;
  end;
  if PictureType = 'Publisher/Studio logotype' then
  begin
    Result := $14;
    Exit;
  end;
end;

function ID3v2RemoveTag(FileName: string): Integer;
var
  AudioFileName: string;
  AudioFile: TFileStream;
  OutputFileName: string;
  OutputFile: TFileStream;
  ID3v2Size: Integer;
  TagCodedSizeInExistingStream: Cardinal;
  TagSizeInExistingStream: Cardinal;
begin
  Result := ID3V2LIBRARY_ERROR;
  AudioFile := nil;
  if not FileExists(FileName) then
  begin
    Exit;
  end;
  ID3v2Size := 0;
  try
    Result := ID3V2LIBRARY_ERROR_EMPTY_TAG;
    AudioFileName := FileName;
    try
      try
        AudioFile := TFileStream.Create(AudioFileName, fmOpenRead);
      except
        Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
        Exit;
      end;
      if ID3v2ValidTag(AudioFile) then
      begin
        // * Skip version data and flags
        AudioFile.Seek(3, soCurrent);
        AudioFile.Read(TagCodedSizeInExistingStream, 4);
        UnSyncSafe(TagCodedSizeInExistingStream, 4, TagSizeInExistingStream);
        // * Add header size to size
        ID3v2Size := TagSizeInExistingStream + 10;
      end
      else
      begin
        AudioFile.Seek(0, soBeginning);
        if CheckRIFF(AudioFile) then
        begin
          if SeekRIFF(AudioFile) > 0 then
          begin
            FreeAndNil(AudioFile);
            Result := RemoveRIFFID3v2(FileName);
            Exit;
          end
          else
          begin
            Exit;
          end;
        end
        else
        begin
          AudioFile.Seek(0, soBeginning);
          if CheckRF64(AudioFile) then
          begin
            if SeekRF64(AudioFile) > 0 then
            begin
              FreeAndNil(AudioFile);
              Result := RemoveRF64ID3v2(FileName);
              Exit;
            end
            else
            begin
              Exit;
            end;
          end
          else
          begin
            AudioFile.Seek(0, soBeginning);
            if CheckAIFF(AudioFile) then
            begin
              if SeekAIFF(AudioFile) > 0 then
              begin
                FreeAndNil(AudioFile);
                Result := RemoveAIFFID3v2(FileName);
                Exit;
              end
              else
              begin
                Exit;
              end;
            end;
          end;
        end;
      end;
    finally
      if Assigned(AudioFile) then
      begin
        FreeAndNil(AudioFile);
      end;
    end;
    // ID3v2Size := Size + 10;
    if ID3v2Size > 0 then
    begin
      try
        AudioFile := TFileStream.Create(AudioFileName, fmOpenRead);
      except
        Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
        Exit;
      end;
      OutputFileName := ChangeFileExt(AudioFileName, '.tmp');
      try
        OutputFile := TFileStream.Create(OutputFileName, fmCreate or
          fmOpenReadWrite);
      except
        Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
        Exit;
      end;
      AudioFile.Seek(ID3v2Size, soBeginning);
      OutputFile.CopyFrom(AudioFile, AudioFile.Size - ID3v2Size);
      FreeAndNil(AudioFile);
      FreeAndNil(OutputFile);
      if not DeleteFile(AudioFileName) then
      begin
        Result := GetLastError;
        DeleteFile(OutputFileName);
      end
      else
      begin
        RenameFile(OutputFileName, AudioFileName);
        Result := ID3V2LIBRARY_SUCCESS;
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function ID3v2ValidTag(TagStream: TStream): Boolean;
var
  Identification: TID3v2ID;
begin
  Result := False;
  try
    Identification := #0#0#0;
    TagStream.Read(Identification[0], 3);
    if Identification = ID3v2ID then
    begin
      Result := True;
    end;
  except
    // *
  end;
end;

function CheckRIFF(TagStream: TStream): Boolean;
var
  Identification: TRIFFID;
begin
  Result := False;
  try
    Identification := #0#0#0#0;
    TagStream.Read(Identification[0], 4);
    if Identification = RIFFID then
    begin
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function SeekRIFF(TagStream: TStream): Integer;
var
  RIFFChunkSize: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
begin
  Result := 0;
  try
    // * Find ID3v2
    TagStream.Read(RIFFChunkSize, 4);
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        if ChunkID = RIFFID3v2ID then
        begin
          Result := ChunkSize;
          Exit;
        end
        else
        begin
          TagStream.Seek(ChunkSize, soCurrent);
        end;
      end;
    end;
  except
    Result := 0;
  end;
end;

function CheckAIFF(TagStream: TStream): Boolean;
var
  Identification: TAIFFID;
begin
  Result := False;
  try
    Identification := #0#0#0#0;
    TagStream.Read(Identification[0], 4);
    if Identification = AIFFID then
    begin
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function SeekAIFF(TagStream: TStream): Integer;
var
  AIFFChunkSize: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
begin
  Result := 0;
  try
    // * Find ID3v2
    TagStream.Read(AIFFChunkSize, 4);
    AIFFChunkSize := ReverseBytes(AIFFChunkSize);
    TagStream.Read(ChunkID, 4);
    if (ChunkID = AIFFChunkID) or (ChunkID = AIFCChunkID) then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        ChunkSize := ReverseBytes(ChunkSize);
        if ChunkID = AIFFID3v2ID then
        begin
          Result := ChunkSize;
          Exit;
        end
        else
        begin
          TagStream.Seek(ChunkSize, soCurrent);
        end;
      end;
    end;
  except
    Result := 0;
  end;
end;

function CheckRF64(TagStream: TStream): Boolean;
var
  Identification: TRIFFID;
begin
  Result := False;
  try
    Identification := #0#0#0#0;
    TagStream.Read(Identification[0], 4);
    if Identification = RF64ID then
    begin
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function SeekRF64(TagStream: TStream): Integer;
var
  RIFFChunkSize: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeLow: DWord;
  ChunkSizeHigh: DWord;
  ds64DataSize: Int64;
  Waveds64: TWaveds64;
begin
  Result := 0;
  try
    // * Find ID3v2
    TagStream.Read(RIFFChunkSize, 4);
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        if ChunkID = 'ds64' then
        begin
          TagStream.Read(Waveds64, SizeOf(TWaveds64));
          TagStream.Seek(Waveds64.ds64Size - SizeOf(TWaveds64) + 4 { table? },
            soCurrent);
          Continue;
        end;
        TagStream.Read(ChunkSize, 4);
        if ChunkID = RIFFID3v2ID then
        begin
          Result := ChunkSize;
          Exit;
        end
        else
        begin
          if (ChunkID = 'data') and (ChunkSize = $FFFFFFFF) then
          begin
            ds64DataSize := MakeInt64(Waveds64.DataSizeLow,
              Waveds64.DataSizeHigh);
            TagStream.Seek(ds64DataSize, soCurrent);
          end
          else
          begin
            TagStream.Seek(ChunkSize, soCurrent);
          end;
        end;
      end;
    end;
  except
    Result := 0;
  end;
end;

// Use CalcCRC32 as a procedure so CRCValue can be passed in but
// also returned. This allows multiple calls to CalcCRC32 for
// the "same" CRC-32 calculation.

procedure CalcCRC32(P: Pointer; ByteCount: DWord; var CRCValue: DWord);
// The following is a little cryptic (but executes very quickly).
// The algorithm is as follows:
// 1. exclusive-or the input byte with the low-order byte of
// the CRC register to get an INDEX
// 2. shift the CRC register eight bits to the right
// 3. exclusive-or the CRC register with the contents of Table[INDEX]
// 4. repeat steps 1 through 3 for all bytes
var
  i: DWord;
  q: ^Byte;
begin
  q := P;
  for i := 0 to ByteCount - 1 do
  begin
    CRCValue := (CRCValue shr 8) xor CRC32Table[q^ xor (CRCValue and
      $000000FF)];
    Inc(q)
  end;
end;

function CalculateStreamCRC32(Stream: TStream; var CRCValue: DWord): Boolean;
var
  MemoryStream: TMemoryStream;
begin
  Result := False;
  CRCValue := $FFFFFFFF;
  MemoryStream := TMemoryStream(Stream);
  try
    MemoryStream.Seek(0, soBeginning);
    if MemoryStream.Size > 0 then
    begin
      CalcCRC32(MemoryStream.Memory, MemoryStream.Size, CRCValue);
      Result := True;
    end;
  except
    Result := False;
  end;
  CRCValue := not CRCValue;
end;

function TID3v2Tag.CalculateTagCRC32: Cardinal;
var
  CRC32: Cardinal;
  TagsStream: TStream;
  Error: Integer;
  ReUnsynchronise: Boolean;
begin
  Result := 0;
  TagsStream := TMemoryStream.Create;
  try
    ReUnsynchronise := Unsynchronised;
    if ReUnsynchronise then
    begin
      RemoveUnsynchronisationOnAllFrames;
    end;
    Error := WriteAllFrames(TagsStream);
    if Error <> ID3V2LIBRARY_SUCCESS then
    begin
      Exit;
    end;
    CalculateStreamCRC32(TagsStream, CRC32);
    Result := CRC32;
  finally
    FreeAndNil(TagsStream);
    if ReUnsynchronise then
    begin
      ApplyUnsynchronisationOnAllFrames;
    end;
  end;
end;

function RIFFCreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TotalSize: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(RIFFChunkSize, 4);
    TagStream.Seek(-4, soCurrent);
    TotalSize := RIFFChunkSize + WriteTagTotalSize + PaddingToWrite + 8;
    if Odd(TotalSize) then
    begin
      Inc(TotalSize);
    end;
    if TotalSize > $FFFFFFFF then
    begin
      Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
      Exit;
    end;
    RIFFChunkSizeNew := TotalSize;
    TagStream.Write(RIFFChunkSizeNew, 4);
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      while TagStream.Position + 8 < RIFFChunkSize do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        TagStream.Seek(ChunkSize, soCurrent);
      end;
      if TagStream.Position < TagStream.Size then
      begin
        PreviousPosition := TagStream.Position;
        try
          TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
            fmCreate);
        except
          Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
        TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
        TagStream.Seek(PreviousPosition, soBeginning);
      end;
      TagStream.Write(RIFFID3v2ID[0], 4);
      ChunkSize := WriteTagTotalSize + PaddingToWrite;
      if Odd(ChunkSize) then
      begin
        Inc(ChunkSize);
      end;
      TagStream.Write(ChunkSize, 4);
      PreviousPosition := TagStream.Position;
      WritePadding(TagStream, ChunkSize);
      if Assigned(TempStream) then
      begin
        TempStream.Seek(0, soBeginning);
        TagStream.CopyFrom(TempStream, TempStream.Size);
        FreeAndNil(TempStream);
        DeleteFile(ChangeFileExt(FileName, '.tmp'));
      end;
      TagStream.Seek(PreviousPosition, soBeginning);
      Result := ID3V2LIBRARY_SUCCESS;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RIFFUpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TotalSize: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(RIFFChunkSize, 4);
    TagStream.Seek(-4, soCurrent);
    TotalSize := RIFFChunkSize - PreviousTagSize + WriteTagTotalSize +
      PaddingToWrite;
    if Odd(TotalSize) then
    begin
      Inc(TotalSize);
    end;
    if TotalSize > $FFFFFFFF then
    begin
      Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
      Exit;
    end;
    RIFFChunkSizeNew := TotalSize;
    TagStream.Write(RIFFChunkSizeNew, 4);
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        if ChunkID = RIFFID3v2ID then
        begin
          TagStream.Seek(-4, soCurrent);
          PreviousPosition := TagStream.Position;
          TagStream.Seek(ChunkSize + 4, soCurrent);
          if TagStream.Position < TagStream.Size then
          begin
            try
              TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
                fmCreate);
            except
              Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
              Exit;
            end;
            TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
          end;
          TagStream.Seek(PreviousPosition, soBeginning);
          ChunkSize := ChunkSize - PreviousTagSize + WriteTagTotalSize +
            PaddingToWrite;
          if Odd(ChunkSize) then
          begin
            Inc(ChunkSize);
          end;
          TagStream.Write(ChunkSize, 4);
          WritePadding(TagStream, ChunkSize);
          if Assigned(TempStream) then
          begin
            TempStream.Seek(0, soBeginning);
            TagStream.CopyFrom(TempStream, TempStream.Size);
            FreeAndNil(TempStream);
            DeleteFile(ChangeFileExt(FileName, '.tmp'));
          end;
          TagStream.Seek(PreviousPosition + 4, soBeginning);
          Result := ID3V2LIBRARY_SUCCESS;
          Exit;
        end
        else
        begin
          TagStream.Seek(ChunkSize, soCurrent);
        end;
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function AIFFCreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
var
  AIFFChunkSize: DWord;
  AIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeNew: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  ZeroByte: Byte;
  TotalSize: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(AIFFChunkSize, 4);
    AIFFChunkSize := ReverseBytes(AIFFChunkSize);
    TagStream.Seek(-4, soCurrent);
    TotalSize := AIFFChunkSize + WriteTagTotalSize + PaddingToWrite + 8;
    if Odd(TotalSize) then
    begin
      Inc(TotalSize);
    end;
    if TotalSize > $FFFFFFFF then
    begin
      Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
      Exit;
    end;
    AIFFChunkSizeNew := TotalSize;
    AIFFChunkSizeNew := ReverseBytes(AIFFChunkSizeNew);
    TagStream.Write(AIFFChunkSizeNew, 4);
    TagStream.Read(ChunkID, 4);
    if (ChunkID = AIFFChunkID) or (ChunkID = AIFCChunkID) then
    begin
      while (TagStream.Position + 8 < AIFFChunkSize) and (TagStream.Position + 8
        < TagStream.Size) do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        ChunkSize := ReverseBytes(ChunkSize);
        TagStream.Seek(ChunkSize, soCurrent);
      end;
      if TagStream.Position < TagStream.Size then
      begin
        PreviousPosition := TagStream.Position;
        try
          TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
            fmCreate);
        except
          Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
        TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
        TagStream.Seek(PreviousPosition, soBeginning);
      end;
      if Odd(TagStream.Position) then
      begin
        ZeroByte := 0;
        TagStream.Write(ZeroByte, 1);
      end;
      TagStream.Write(AIFFID3v2ID[0], 4);
      ChunkSize := WriteTagTotalSize + PaddingToWrite;
      if Odd(ChunkSize) then
      begin
        Inc(ChunkSize);
      end;
      ChunkSizeNew := ReverseBytes(ChunkSize);
      TagStream.Write(ChunkSizeNew, 4);
      PreviousPosition := TagStream.Position;
      WritePadding(TagStream, ChunkSize);
      if Assigned(TempStream) then
      begin
        TempStream.Seek(0, soBeginning);
        TagStream.CopyFrom(TempStream, TempStream.Size);
        FreeAndNil(TempStream);
        DeleteFile(ChangeFileExt(FileName, '.tmp'));
      end;
      TagStream.Seek(PreviousPosition, soBeginning);
      Result := ID3V2LIBRARY_SUCCESS;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function AIFFUpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;
var
  AIFFChunkSize: DWord;
  AIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeNew: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TotalSize: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(AIFFChunkSize, 4);
    AIFFChunkSize := ReverseBytes(AIFFChunkSize);
    TagStream.Seek(-4, soCurrent);
    TotalSize := AIFFChunkSize - PreviousTagSize + WriteTagTotalSize +
      PaddingToWrite;
    if Odd(TotalSize) then
    begin
      Inc(TotalSize);
    end;
    if TotalSize > $FFFFFFFF then
    begin
      Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
      Exit;
    end;
    AIFFChunkSizeNew := TotalSize;
    AIFFChunkSizeNew := ReverseBytes(AIFFChunkSizeNew);
    TagStream.Write(AIFFChunkSizeNew, 4);
    TagStream.Read(ChunkID, 4);
    if (ChunkID = AIFFChunkID) or (ChunkID = AIFCChunkID) then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        ChunkSize := ReverseBytes(ChunkSize);
        if ChunkID = AIFFID3v2ID then
        begin
          TagStream.Seek(-4, soCurrent);
          PreviousPosition := TagStream.Position;
          TagStream.Seek(ChunkSize + 4, soCurrent);
          if TagStream.Position < TagStream.Size then
          begin
            try
              TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
                fmCreate);
            except
              Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
              Exit;
            end;
            TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
          end;
          TagStream.Seek(PreviousPosition, soBeginning);
          ChunkSize := ChunkSize - PreviousTagSize + WriteTagTotalSize +
            PaddingToWrite;
          if Odd(ChunkSize) then
          begin
            Inc(ChunkSize);
          end;
          ChunkSizeNew := ReverseBytes(ChunkSize);
          TagStream.Write(ChunkSizeNew, 4);
          WritePadding(TagStream, ChunkSize);
          if Assigned(TempStream) then
          begin
            TempStream.Seek(0, soBeginning);
            TagStream.CopyFrom(TempStream, TempStream.Size);
            FreeAndNil(TempStream);
            DeleteFile(ChangeFileExt(FileName, '.tmp'));
          end;
          TagStream.Seek(PreviousPosition + 4, soBeginning);
          Result := ID3V2LIBRARY_SUCCESS;
          Exit;
        end
        else
        begin
          TagStream.Seek(ChunkSize, soCurrent);
        end;
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RF64CreateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PaddingToWrite: Integer): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TotalSize: Int64;
  Waveds64: TWaveds64;
  Data: DWord;
  DataSize: Int64;
  RF64Size: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(RIFFChunkSize, 4);
    if RIFFChunkSize = $FFFFFFFF then
    begin
      TagStream.Read(ChunkID, 4);
      if ChunkID <> 'WAVE' then
      begin
        Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      TagStream.Read(ChunkID, 4);
      if ChunkID = 'ds64' then
      begin
        TagStream.Read(Waveds64, SizeOf(TWaveds64));
        RF64Size := MakeInt64(Waveds64.RIFFSizeLow, Waveds64.RIFFSizeHigh);
        TotalSize := RF64Size + WriteTagTotalSize + PaddingToWrite + 8;
        if Odd(TotalSize) then
        begin
          Inc(TotalSize);
        end;
        // * Set new RF64 size
        TagStream.Position := 20;
        Data := LowDWordOfInt64(TotalSize);
        TagStream.Write(Data, 4);
        Data := HighDWordOfInt64(TotalSize);
        TagStream.Write(Data, 4);
        TagStream.Seek(8, soBeginning);
      end;
    end
    else
    begin
      RF64Size := RIFFChunkSize;
      TagStream.Seek(-4, soCurrent);
      TotalSize := RIFFChunkSize + WriteTagTotalSize + PaddingToWrite + 8;
      if Odd(TotalSize) then
      begin
        Inc(TotalSize);
      end;
      if TotalSize > $FFFFFFFF then
      begin
        Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
        Exit;
      end;
      RIFFChunkSizeNew := TotalSize;
      TagStream.Write(RIFFChunkSizeNew, 4);
    end;
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      while TagStream.Position + 8 < RF64Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        if (ChunkID = 'data') and (ChunkSize = $FFFFFFFF) then
        begin
          TagStream.Seek(MakeInt64(Waveds64.DataSizeLow, Waveds64.DataSizeHigh),
            soCurrent);
        end
        else
        begin
          TagStream.Seek(ChunkSize, soCurrent);
        end;
      end;
      if TagStream.Position < TagStream.Size then
      begin
        PreviousPosition := TagStream.Position;
        try
          TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
            fmCreate);
        except
          Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
          Exit;
        end;
        TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
        TagStream.Seek(PreviousPosition, soBeginning);
      end;
      TagStream.Write(RIFFID3v2ID[0], 4);
      ChunkSize := WriteTagTotalSize + PaddingToWrite;
      if Odd(ChunkSize) then
      begin
        Inc(ChunkSize);
      end;
      TagStream.Write(ChunkSize, 4);
      PreviousPosition := TagStream.Position;
      WritePadding(TagStream, ChunkSize);
      if Assigned(TempStream) then
      begin
        TempStream.Seek(0, soBeginning);
        TagStream.CopyFrom(TempStream, TempStream.Size);
        FreeAndNil(TempStream);
        DeleteFile(ChangeFileExt(FileName, '.tmp'));
      end;
      TagStream.Seek(PreviousPosition, soBeginning);
      Result := ID3V2LIBRARY_SUCCESS;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RF64UpdateID3v2(FileName: string; TagStream: TStream;
  WriteTagTotalSize: Integer; PreviousTagSize: Integer;
  PaddingToWrite: Integer): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TotalSize: Int64;
  Waveds64: TWaveds64;
  RF64Size: Int64;
  Data: DWord;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream.Seek(4, soCurrent);
    TagStream.Read(RIFFChunkSize, 4);
    if RIFFChunkSize = $FFFFFFFF then
    begin
      TagStream.Read(ChunkID, 4);
      if ChunkID <> 'WAVE' then
      begin
        Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      TagStream.Read(ChunkID, 4);
      if ChunkID = 'ds64' then
      begin
        TagStream.Read(Waveds64, SizeOf(TWaveds64));
        RF64Size := MakeInt64(Waveds64.RIFFSizeLow, Waveds64.RIFFSizeHigh);
        TotalSize := RF64Size - PreviousTagSize + WriteTagTotalSize +
          PaddingToWrite + 8;
        if Odd(TotalSize) then
        begin
          Inc(TotalSize);
        end;
        // * Set new RF64 size
        TagStream.Position := 20;
        Data := LowDWordOfInt64(TotalSize);
        TagStream.Write(Data, 4);
        Data := HighDWordOfInt64(TotalSize);
        TagStream.Write(Data, 4);
        TagStream.Seek(8, soBeginning);
      end;
    end
    else
    begin
      RF64Size := RIFFChunkSize;
      TagStream.Seek(-4, soCurrent);
      TotalSize := RIFFChunkSize - PreviousTagSize + WriteTagTotalSize +
        PaddingToWrite + 8;
      if Odd(TotalSize) then
      begin
        Inc(TotalSize);
      end;
      if TotalSize > $FFFFFFFF then
      begin
        Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
        Exit;
      end;
      RIFFChunkSizeNew := TotalSize;
      TagStream.Write(RIFFChunkSizeNew, 4);
    end;
    TagStream.Read(ChunkID, 4);
    if ChunkID = RIFFWAVEID then
    begin
      ChunkSize := 0;
      while TagStream.Position + 8 < TagStream.Size do
      begin
        TagStream.Read(ChunkID, 4);
        TagStream.Read(ChunkSize, 4);
        if ChunkID = RIFFID3v2ID then
        begin
          TagStream.Seek(-4, soCurrent);
          PreviousPosition := TagStream.Position;
          TagStream.Seek(ChunkSize + 4, soCurrent);
          if TagStream.Position < TagStream.Size then
          begin
            try
              TempStream := TFileStream.Create(ChangeFileExt(FileName, '.tmp'),
                fmCreate);
            except
              Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
              Exit;
            end;
            TempStream.CopyFrom(TagStream, TagStream.Size - TagStream.Position);
          end;
          TagStream.Seek(PreviousPosition, soBeginning);
          ChunkSize := ChunkSize - PreviousTagSize + WriteTagTotalSize +
            PaddingToWrite;
          if Odd(ChunkSize) then
          begin
            Inc(ChunkSize);
          end;
          TagStream.Write(ChunkSize, 4);
          WritePadding(TagStream, ChunkSize);
          if Assigned(TempStream) then
          begin
            TempStream.Seek(0, soBeginning);
            TagStream.CopyFrom(TempStream, TempStream.Size);
            FreeAndNil(TempStream);
            DeleteFile(ChangeFileExt(FileName, '.tmp'));
          end;
          TagStream.Seek(PreviousPosition + 4, soBeginning);
          Result := ID3V2LIBRARY_SUCCESS;
          Exit;
        end
        else
        begin
          if (ChunkID = 'data') and (ChunkSize = $FFFFFFFF) then
          begin
            TagStream.Seek(MakeInt64(Waveds64.DataSizeLow,
              Waveds64.DataSizeHigh), soCurrent);
          end
          else
          begin
            TagStream.Seek(ChunkSize, soCurrent);
          end;
        end;
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RemoveRIFFID3v2(FileName: string): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeNew: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TagStream: TFileStream;
  TagSize: DWord;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream := TFileStream.Create(FileName, fmOpenReadWrite);
  except
    Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    try
      if CheckRIFF(TagStream) then
      begin
        TagSize := SeekRIFF(TagStream);
        if TagSize = 0 then
        begin
          Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
          Exit;
        end;
      end
      else
      begin
        Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      TagStream.Seek(4, soBeginning);
      TagStream.Read(RIFFChunkSize, 4);
      TagStream.Seek(-4, soCurrent);
      RIFFChunkSizeNew := RIFFChunkSize - TagSize - 8;
      TagStream.Write(RIFFChunkSizeNew, 4);
      TagStream.Read(ChunkID, 4);
      if ChunkID = RIFFWAVEID then
      begin
        ChunkSize := 0;
        while TagStream.Position + 8 < TagStream.Size do
        begin
          TagStream.Read(ChunkID, 4);
          TagStream.Read(ChunkSize, 4);
          if ChunkID = RIFFID3v2ID then
          begin
            TagStream.Seek(-8, soCurrent);
            PreviousPosition := TagStream.Position;
            TagStream.Seek(ChunkSize + 8, soCurrent);
            if TagStream.Position + 8 + ChunkSize < TagStream.Size then
            begin
              try
                TempStream := TFileStream.Create(ChangeFileExt(FileName,
                  '.tmp'), fmCreate);
              except
                Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
                Exit;
              end;
              TempStream.CopyFrom(TagStream, TagStream.Size -
                TagStream.Position);
            end;
            TagStream.Seek(PreviousPosition, soBeginning);
            THandleStream(TagStream).Size := TagStream.Position;
            if Assigned(TempStream) then
            begin
              TempStream.Seek(0, soBeginning);
              TagStream.CopyFrom(TempStream, TempStream.Size);
              FreeAndNil(TempStream);
              DeleteFile(ChangeFileExt(FileName, '.tmp'));
            end;
            Result := ID3V2LIBRARY_SUCCESS;
            Exit;
          end
          else
          begin
            TagStream.Seek(ChunkSize, soCurrent);
          end;
        end;
      end;
    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RemoveAIFFID3v2(FileName: string): Integer;
var
  AIFFChunkSize: DWord;
  AIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeNew: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TagStream: TFileStream;
  TagSize: DWord;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream := TFileStream.Create(FileName, fmOpenReadWrite);
  except
    Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    try
      if CheckAIFF(TagStream) then
      begin
        TagSize := SeekAIFF(TagStream);
        if TagSize = 0 then
        begin
          Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
          Exit;
        end;
      end
      else
      begin
        Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      TagStream.Seek(4, soBeginning);
      TagStream.Read(AIFFChunkSize, 4);
      AIFFChunkSize := ReverseBytes(AIFFChunkSize);
      TagStream.Seek(-4, soCurrent);
      AIFFChunkSizeNew := AIFFChunkSize - TagSize - 8;
      AIFFChunkSizeNew := ReverseBytes(AIFFChunkSizeNew);
      TagStream.Write(AIFFChunkSizeNew, 4);
      TagStream.Read(ChunkID, 4);
      if (ChunkID = AIFFChunkID) or (ChunkID = AIFCChunkID) then
      begin
        ChunkSize := 0;
        while TagStream.Position + 8 < TagStream.Size do
        begin
          TagStream.Read(ChunkID, 4);
          TagStream.Read(ChunkSize, 4);
          ChunkSize := ReverseBytes(ChunkSize);
          if ChunkID = AIFFID3v2ID then
          begin
            TagStream.Seek(-8, soCurrent);
            PreviousPosition := TagStream.Position;
            TagStream.Seek(ChunkSize + 8, soCurrent);
            if TagStream.Position + 8 + ChunkSize < TagStream.Size then
            begin
              try
                TempStream := TFileStream.Create(ChangeFileExt(FileName,
                  '.tmp'), fmCreate);
              except
                Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
                Exit;
              end;
              TempStream.CopyFrom(TagStream, TagStream.Size -
                TagStream.Position);
            end;
            TagStream.Seek(PreviousPosition, soBeginning);
            THandleStream(TagStream).Size := TagStream.Position;
            if Assigned(TempStream) then
            begin
              TempStream.Seek(0, soBeginning);
              TagStream.CopyFrom(TempStream, TempStream.Size);
              FreeAndNil(TempStream);
              DeleteFile(ChangeFileExt(FileName, '.tmp'));
            end;
            Result := ID3V2LIBRARY_SUCCESS;
            Exit;
          end
          else
          begin
            TagStream.Seek(ChunkSize, soCurrent);
          end;
        end;
      end;
    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function RemoveRF64ID3v2(FileName: string): Integer;
var
  RIFFChunkSize: DWord;
  RIFFChunkSizeNew: DWord;
  ChunkID: TFrameID;
  ChunkSize: DWord;
  ChunkSizeNew: DWord;
  PreviousPosition: Int64;
  TempStream: TFileStream;
  TagStream: TFileStream;
  TagSize: DWord;
  Waveds64: TWaveds64;
  RF64Size: Int64;
  Data: DWord;
  TotalSize: Int64;
begin
  Result := ID3V2LIBRARY_ERROR;
  TempStream := nil;
  try
    TagStream := TFileStream.Create(FileName, fmOpenReadWrite);
  except
    Result := ID3V2LIBRARY_ERROR_OPENING_FILE;
    Exit;
  end;
  try
    try
      if CheckRF64(TagStream) then
      begin
        TagSize := SeekRF64(TagStream);
        if TagSize = 0 then
        begin
          Result := ID3V2LIBRARY_ERROR_NO_TAG_FOUND;
          Exit;
        end;
      end
      else
      begin
        Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
        Exit;
      end;
      TagStream.Seek(4, soBeginning);
      TagStream.Read(RIFFChunkSize, 4);
      if RIFFChunkSize = $FFFFFFFF then
      begin
        TagStream.Read(ChunkID, 4);
        if ChunkID <> 'WAVE' then
        begin
          Result := ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT;
          Exit;
        end;
        TagStream.Read(ChunkID, 4);
        if ChunkID = 'ds64' then
        begin
          TagStream.Read(Waveds64, SizeOf(TWaveds64));
          RF64Size := MakeInt64(Waveds64.RIFFSizeLow, Waveds64.RIFFSizeHigh);
          TotalSize := RF64Size - TagSize - 8;
          if Odd(TotalSize) then
          begin
            Inc(TotalSize);
          end;
          // * Set new RF64 size
          TagStream.Position := 20;
          Data := LowDWordOfInt64(TotalSize);
          TagStream.Write(Data, 4);
          Data := HighDWordOfInt64(TotalSize);
          TagStream.Write(Data, 4);
          TagStream.Seek(8, soBeginning);
        end;
      end
      else
      begin
        RF64Size := RIFFChunkSize;
        TagStream.Seek(-4, soCurrent);
        TotalSize := RF64Size - TagSize - 8;
        // * Should not happen
        {
          if Odd(TotalSize) then begin
          Inc(TotalSize);
          end;
        }
        if TotalSize > $FFFFFFFF then
        begin
          Result := ID3V2LIBRARY_ERROR_DOESNT_FIT;
          Exit;
        end;
        RIFFChunkSizeNew := TotalSize;
        TagStream.Write(RIFFChunkSizeNew, 4);
      end;
      TagStream.Read(ChunkID, 4);
      if ChunkID = RIFFWAVEID then
      begin
        ChunkSize := 0;
        while TagStream.Position + 8 < TagStream.Size do
        begin
          TagStream.Read(ChunkID, 4);
          TagStream.Read(ChunkSize, 4);
          if ChunkID = RIFFID3v2ID then
          begin
            TagStream.Seek(-8, soCurrent);
            PreviousPosition := TagStream.Position;
            TagStream.Seek(ChunkSize + 8, soCurrent);
            if TagStream.Position + 8 + ChunkSize < TagStream.Size then
            begin
              try
                TempStream := TFileStream.Create(ChangeFileExt(FileName,
                  '.tmp'), fmCreate);
              except
                Result := ID3V2LIBRARY_ERROR_WRITING_FILE;
                Exit;
              end;
              TempStream.CopyFrom(TagStream, TagStream.Size -
                TagStream.Position);
            end;
            TagStream.Seek(PreviousPosition, soBeginning);
            THandleStream(TagStream).Size := TagStream.Position;
            if Assigned(TempStream) then
            begin
              TempStream.Seek(0, soBeginning);
              TagStream.CopyFrom(TempStream, TempStream.Size);
              FreeAndNil(TempStream);
              DeleteFile(ChangeFileExt(FileName, '.tmp'));
            end;
            Result := ID3V2LIBRARY_SUCCESS;
            Exit;
          end
          else
          begin
            if (ChunkID = 'data') and (ChunkSize = $FFFFFFFF) then
            begin
              TagStream.Seek(MakeInt64(Waveds64.DataSizeLow,
                Waveds64.DataSizeHigh), soCurrent);
            end
            else
            begin
              TagStream.Seek(ChunkSize, soCurrent);
            end;
          end;
        end;
      end;
    finally
      if Assigned(TagStream) then
      begin
        FreeAndNil(TagStream);
      end;
    end;
  except
    Result := ID3V2LIBRARY_ERROR;
  end;
end;

function TID3v2Tag.FindCustomFrame(FrameID: AnsiString; Description: string):
  Integer;
var
  Index: Integer;
  ID: TFrameID;
  FrameDescription: string;
  i: Integer;
begin
  Result := -1;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  for i := 0 to FrameCount - 1 do
  begin
    if ID = Frames[i].ID then
    begin
      GetUnicodeUserDefinedTextInformation(i, FrameDescription);
      if FrameDescription = Description then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.GetUnicodeUserDefinedTextInformation(FrameIndex: Integer; var
  Description: string): string;
var
  DataByte: Byte;
  DataWord: Word;
  UData: Word;
  ASCIIText: PAnsiChar;
  StrASCIIDescription: AnsiString;
  AnsiText: AnsiString;
  StrUDescription: string;
  PUDescription: PWideChar;
  EncodingFormat: Byte;
  UContent: PWideChar;
  StrAnsi: AnsiString;
begin
  Result := '';
  Description := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get encoding format
    Frames[FrameIndex].Stream.Read(EncodingFormat, 1);
    // * Get decription and content
    case EncodingFormat of
      0:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := StrASCIIDescription;
          // * Get the content
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if (DataByte = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              Result := Result + #13#10;
            end
            else
            begin
              if DataByte <> 0 then
              begin
                Result := Result + Char(DataByte);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
        end;
      1:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          Description := Copy(StrUDescription, 2, Length(StrUDescription));
          // * Get the content
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte = $FF then
            begin
              Frames[FrameIndex].Stream.Read(DataByte, 1);
              if DataByte = $FE then
              begin
                repeat
                  Frames[FrameIndex].Stream.Read(DataWord, 2);
                  if (DataWord = 0) and (Frames[FrameIndex].Stream.Position <>
                    Frames[FrameIndex].Stream.Size) then
                  begin
                    Result := Result + #13#10;
                  end
                  else
                  begin
                    if DataWord <> 0 then
                    begin
                      Result := Result + Char(DataWord);
                    end;
                  end;
                until Frames[FrameIndex].Stream.Position =
                  Frames[FrameIndex].Stream.Size;
              end;
            end;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      2:
        begin
          // * Get description
          StrUDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(UData, 2);
            if UData <> $0 then
            begin
              StrUDescription := StrUDescription + Char(UData);
            end;
          until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          // * Get the content
          repeat
            Frames[FrameIndex].Stream.Read(DataWord, 2);
            if (DataWord = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              Result := Result + #13#10;
            end
            else
            begin
              if DataWord <> 0 then
              begin
                Result := Result + Char(DataWord);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
        end;
      3:
        begin
          // * Get description
          StrASCIIDescription := '';
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if DataByte <> $0 then
            begin
              StrASCIIDescription := StrASCIIDescription + AnsiChar(DataByte);
            end;
          until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
          PUDescription := AllocMem((Length(StrASCIIDescription) + 1) * 2);
          Utf8ToUnicode(PUDescription, Length(StrASCIIDescription) * 2,
            PAnsiChar(StrASCIIDescription),
            Length(StrASCIIDescription));
          Description := PUDescription;
          FreeMem(PUDescription);
          // * Get the content
          repeat
            Frames[FrameIndex].Stream.Read(DataByte, 1);
            if (DataWord = 0) and (Frames[FrameIndex].Stream.Position <>
              Frames[FrameIndex].Stream.Size) then
            begin
              AnsiText := AnsiText + #13#10;
            end
            else
            begin
              if DataByte <> 0 then
              begin
                AnsiText := AnsiText + AnsiChar(DataByte);
              end;
            end;
          until Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size;
          Result := AnsiText;
        end;
    end;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeUserDefinedTextInformationMultiple(FrameIndex:
  Integer; var Description: string;
  List: TStrings): Boolean;
var
  Text: string;
begin
  Result := False;
  List.Clear;
  Text := GetUnicodeUserDefinedTextInformation(FrameIndex, Description);
  List.Text := Text;
  Result := List.Text <> '';
end;

function TID3v2Tag.GetUnicodeUserDefinedTextInformationMultiple(FrameID:
  AnsiString; var Description: string;
  List: TStrings): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  List.Clear;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeUserDefinedTextInformationMultiple(Index, Description,
    List);
end;

function TID3v2Tag.SetUserDefinedTextInformation(FrameID: AnsiString;
  Description: AnsiString; Text: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUserDefinedTextInformation(Index, Description, Text);
end;

function TID3v2Tag.SetUserDefinedTextInformation(FrameIndex: Integer;
  Description: AnsiString; Text: AnsiString): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set UTF-8 flag
    DataByte := $00;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(Description)^, Length(Description)
      + 1);
    // * Write the user defined text
    Frames[FrameIndex].Stream.Write(PAnsiChar(Text)^, Length(Text));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeUserDefinedTextInformationMultiple(FrameIndex:
  Integer; Description: string; List: TStrings)
  : Boolean;
var
  DataByte: Byte;
  Text: string;
  i: Integer;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PWideChar(Description)^, (Length(Description)
      + 1) * 2);
    // * BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Write the user defined text
    for i := 0 to List.Count - 1 do
    begin
      Text := List[i];
      Frames[FrameIndex].Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * 2);
    end;
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeUserDefinedTextInformationMultiple(FrameID:
  AnsiString; Description: string; List: TStrings)
  : Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeUserDefinedTextInformationMultiple(Index, Description,
    List);
end;

function TID3v2Tag.SetUTF8UserDefinedTextInformation(FrameID: AnsiString;
  Description: string; Text: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUTF8UserDefinedTextInformation(Index, Description, Text);
end;

function TID3v2Tag.SetUTF8UserDefinedTextInformation(FrameIndex: Integer;
  Description: string; Text: string): Boolean;
var
  DataByte: Byte;
  DescriptionAnsi: AnsiString;
  TextAnsi: AnsiString;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    DescriptionAnsi := UTF8Encode(Description);
    TextAnsi := UTF8Encode(Text);
    Frames[FrameIndex].Stream.Clear;
    // * Set UTF-8 flag
    DataByte := $03;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PAnsiChar(DescriptionAnsi)^,
      Length(DescriptionAnsi) + 1);
    // * Write the user defined text
    Frames[FrameIndex].Stream.Write(PAnsiChar(TextAnsi)^, Length(TextAnsi));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeUserDefinedTextInformation(FrameID: AnsiString;
  Description: string; Text: string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Description := '';
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUnicodeUserDefinedTextInformation(Index, Description, Text);
end;

function TID3v2Tag.SetUnicodeUserDefinedTextInformation(FrameIndex: Integer;
  Description: string; Text: string): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Set unicode flag
    DataByte := $01;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Set the description
    Frames[FrameIndex].Stream.Write(PWideChar(Description)^, (Length(Description)
      + 1) * 2);
    // * BOM
    DataByte := $FF;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[FrameIndex].Stream.Write(DataByte, 1);
    // * Write the user defined text
    Frames[FrameIndex].Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * 2);
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetPopularimeter(FrameIndex: Integer; var Email: AnsiString;
  var Rating: Byte;
  var PlayCounter: Cardinal): Boolean;
var
  DataByte: Byte;
  i: Integer;
begin
  Result := False;
  Email := '';
  Rating := 0;
  PlayCounter := 0;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get e-mail
    repeat
      Frames[FrameIndex].Stream.Read(DataByte, 1);
      if DataByte <> $0 then
      begin
        Email := Email + AnsiChar(DataByte);
      end;
    until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
      Frames[FrameIndex].Stream.Size);
    // * Get rating
    Frames[FrameIndex].Stream.Read(DataByte, 1);
    Rating := DataByte;
    // * Get playcount
    if Frames[FrameIndex].Stream.Position < Frames[FrameIndex].Stream.Size then
    begin
      for i := 0 to 3 do
      begin
        PlayCounter := PlayCounter shl 8;
        Frames[FrameIndex].Stream.Read(DataByte, 1);
        PlayCounter := PlayCounter + DataByte;
      end;
    end;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.FindPopularimeter(Email: AnsiString; var Rating: Byte; var
  PlayCounter: Cardinal): Integer;
var
  i: Integer;
  FrameEmail: AnsiString;
begin
  Result := -1;
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = 'POPM' then
    begin
      if GetPopularimeter(i, FrameEmail, Rating, PlayCounter) then
      begin
        if FrameEmail = Email then
        begin
          Result := i;
          Break;
        end
        else
        begin
          Rating := 0;
          PlayCounter := 0;
        end;
      end;
    end;
  end;
end;

function TID3v2Tag.SetPopularimeterByEmail(Email: AnsiString; Rating: Byte;
  PlayCounter: Cardinal = 0): Boolean;
var
  i: Integer;
  GetEmail: AnsiString;
  GetRating: Byte;
  GetPlayCounter: Cardinal;
  Index: Integer;
begin
  Result := False;
  Index := -1;
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = 'POPM' then
    begin
      if GetPopularimeter(i, GetEmail, GetRating, GetPlayCounter) then
      begin
        if GetEmail = Email then
        begin
          Index := i;
          Break;
        end;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame('POPM');
  end;
  Result := SetPopularimeter(Index, Email, Rating, PlayCounter);
end;

function TID3v2Tag.SetPopularimeter(FrameIndex: Integer; Email: AnsiString;
  Rating: Byte; PlayCounter: Cardinal): Boolean;
var
  DataByte: Byte;
  Value: Cardinal;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Write e-mail
    Frames[FrameIndex].Stream.Write(PAnsiChar(Email)^, (Length(Email) + 1));
    // * Write rating
    Frames[FrameIndex].Stream.Write(Rating, 1);
    // * Write playcount
    if PlayCounter > 0 then
    begin
      Value := PlayCounter shr 24;
      DataByte := Value;
      Frames[FrameIndex].Stream.Write(DataByte, 1);
      Value := PlayCounter shl 8;
      Value := Value shr 24;
      DataByte := Value;
      Frames[FrameIndex].Stream.Write(DataByte, 1);
      Value := PlayCounter shl 16;
      Value := Value shr 24;
      DataByte := Value;
      Frames[FrameIndex].Stream.Write(DataByte, 1);
      Value := PlayCounter shl 24;
      Value := Value shr 24;
      DataByte := Value;
      Frames[FrameIndex].Stream.Write(DataByte, 1);
    end;
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.FindTXXXByDescription(Description: string; var Text: string):
  Integer;
var
  ID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := -1;
  ID := 'TXXX';
  GetLanguageID := '';
  GetDescription := '';
  Text := '';
  for i := 0 to FrameCount - 1 do
  begin
    if ID = Frames[i].ID then
    begin
      GetContent := GetUnicodeUserDefinedTextInformation(i, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        Text := GetContent;
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.FindTXXXByDescriptionMultiple(Description: string; List:
  TStrings): Integer;
var
  ID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := -1;
  List.Clear;
  ID := 'TXXX';
  GetLanguageID := '';
  GetDescription := '';
  for i := 0 to FrameCount - 1 do
  begin
    if ID = Frames[i].ID then
    begin
      GetContent := GetUnicodeUserDefinedTextInformation(i, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        List.Text := GetContent;
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.SetUnicodeTXXXByDescription(Description: string; Text:
  string): Boolean;
var
  Index: Integer;
  ID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := False;
  Index := -1;
  ID := 'TXXX';
  GetLanguageID := '';
  GetDescription := '';
  for i := 0 to FrameCount - 1 do
  begin
    if ID = Frames[i].ID then
    begin
      GetContent := GetUnicodeUserDefinedTextInformation(i, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        Index := i;
        Break;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame('TXXX');
  end;
  Result := SetUnicodeTXXX(Index, Description, Text);
end;

function TID3v2Tag.SetUnicodeTXXXByDescriptionMultiple(Description: string;
  List: TStrings): Boolean;
var
  Index: Integer;
  ID: TFrameID;
  i: Integer;
  GetDescription: string;
  GetLanguageID: TLanguageID;
  GetContent: string;
begin
  Result := False;
  Index := -1;
  ID := 'TXXX';
  GetLanguageID := '';
  GetDescription := '';
  for i := 0 to FrameCount - 1 do
  begin
    if ID = Frames[i].ID then
    begin
      GetContent := GetUnicodeUserDefinedTextInformation(i, GetDescription);
      if WideUpperCase(GetDescription) = WideUpperCase(Description) then
      begin
        Index := i;
        Break;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame('TXXX');
  end;
  Result := SetUnicodeUserDefinedTextInformationMultiple(Index, Description,
    List);
end;

function TID3v2Tag.SetUnicodeTXXX(Index: Integer; Description: string; Text:
  string): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (Index >= FrameCount) or (Index < 0) then
  begin
    Exit;
  end;
  try
    Frames[Index].Stream.Clear;
    DataByte := $01;
    Frames[Index].Stream.Write(DataByte, 1);
    DataByte := $FF;
    Frames[Index].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[Index].Stream.Write(DataByte, 1);
    Frames[Index].Stream.Write(PWideChar(Description)^, (Length(Description) + 1)
      * 2);
    DataByte := $FF;
    Frames[Index].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[Index].Stream.Write(DataByte, 1);
    Frames[Index].Stream.Write(PWideChar(Text)^, (Length(Text) + 1) * 2);
    Frames[Index].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function TID3v2Tag.GetUnicodeListFrame(FrameID: AnsiString; var List: TStrings):
  Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUnicodeListFrame(Index, List);
end;

function TID3v2Tag.GetUnicodeListFrame(FrameIndex: Integer; var List: TStrings):
  Boolean;
var
  DataByte: Byte;
  UData: Word;
  AnsiStr: AnsiString;
  Name: string;
  Value: string;
  EncodingFormat: Byte;
begin
  Result := False;
  List.Clear;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    // * Get encoding format
    Frames[FrameIndex].Stream.Read(EncodingFormat, 1);
    // * Get decription and content
    case EncodingFormat of
      0:
        begin
          repeat
            Name := '';
            Value := '';
            repeat
              Frames[FrameIndex].Stream.Read(DataByte, 2);
              if DataByte <> $0 then
              begin
                Name := Name + AnsiChar(DataByte);
              end;
            until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            repeat
              Frames[FrameIndex].Stream.Read(DataByte, 2);
              if DataByte <> $0 then
              begin
                Value := Value + AnsiChar(DataByte);
              end;
            until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            List.Append(Name + '=' + Value);
            Result := True;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      1:
        begin
          Frames[FrameIndex].Stream.Seek(2, soCurrent);
          repeat
            Name := '';
            Value := '';
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                Name := Name + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                Value := Value + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            List.Append(Name + '=' + Value);
            Result := True;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      2:
        begin
          repeat
            Name := '';
            Value := '';
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                Name := Name + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            repeat
              Frames[FrameIndex].Stream.Read(UData, 2);
              if UData <> $0 then
              begin
                Value := Value + Char(UData);
              end;
            until (UData = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            List.Append(Name + '=' + Value);
            Result := True;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
      3:
        begin
          repeat
            Name := '';
            Value := '';
            AnsiStr := '';
            repeat
              Frames[FrameIndex].Stream.Read(DataByte, 2);
              if DataByte <> $0 then
              begin
                AnsiStr := AnsiStr + AnsiChar(DataByte);
              end;
            until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            Name := UTF8Decode(AnsiStr);
            AnsiStr := '';
            repeat
              Frames[FrameIndex].Stream.Read(DataByte, 2);
              if DataByte <> $0 then
              begin
                AnsiStr := AnsiStr + AnsiChar(DataByte);
              end;
            until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
              Frames[FrameIndex].Stream.Size);
            Value := UTF8Decode(AnsiStr);
            List.Append(Name + '=' + Value);
            Result := True;
          until (Frames[FrameIndex].Stream.Position >=
            Frames[FrameIndex].Stream.Size);
        end;
    end;
  except
    // *
  end;
end;

function TID3v2Tag.SetUnicodeListFrame(FrameID: AnsiString; List: TStrings):
  Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(FrameID);
  end;
  Result := SetUnicodeListFrame(Index, List);
end;

function TID3v2Tag.SetUnicodeListFrame(Index: Integer; List: TStrings): Boolean;
var
  DataByte: Byte;
  i: Integer;
  Name: string;
  Value: string;
begin
  Result := False;
  if (Index >= FrameCount) or (Index < 0) then
  begin
    Exit;
  end;
  try
    Frames[Index].Stream.Clear;
    DataByte := $01;
    Frames[Index].Stream.Write(DataByte, 1);
    DataByte := $FF;
    Frames[Index].Stream.Write(DataByte, 1);
    DataByte := $FE;
    Frames[Index].Stream.Write(DataByte, 1);
    for i := 0 to List.Count - 1 do
    begin
      Name := List.Names[i];
      Value := List.ValueFromIndex[i];
      Frames[Index].Stream.Write(PWideChar(Name)^, (Length(Name) + 1) * 2);
      Frames[Index].Stream.Write(PWideChar(Value)^, (Length(Value) + 1) * 2);
    end;
    Frames[Index].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

procedure TID3v2Tag.Assign(ID3v2Tag: TID3v2Tag);
var
  i: Integer;
  Index: Integer;
begin
  Clear;
  FileName := ID3v2Tag.FileName;
  Loaded := ID3v2Tag.Loaded;
  MajorVersion := ID3v2Tag.MajorVersion;
  MinorVersion := ID3v2Tag.MinorVersion;
  Flags := ID3v2Tag.Flags;
  Unsynchronised := ID3v2Tag.Unsynchronised;
  ExtendedHeader := ID3v2Tag.ExtendedHeader;
  Experimental := ID3v2Tag.Experimental;
  FooterPresent := ID3v2Tag.FooterPresent;
  Size := ID3v2Tag.Size;
  PaddingSize := ID3v2Tag.PaddingSize;
  PaddingToWrite := ID3v2Tag.PaddingToWrite;
  for i := 0 to ID3v2Tag.FrameCount - 1 do
  begin
    Index := AddFrame(ID3v2Tag.Frames[i].ID);
    Frames[Index].Assign(ID3v2Tag.Frames[i]);
  end;
end;

function TID3v2Tag.GetUFID(FrameID: AnsiString; var OwnerIdentifier:
  AnsiString): AnsiString;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := '';
  OwnerIdentifier := '';
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Exit;
  end;
  Result := GetUFID(Index, OwnerIdentifier);
end;

function TID3v2Tag.FindUFIDByOwnerIdentifier(OwnerIdentifier: AnsiString; var
  Identifier: AnsiString): Integer;
var
  FrameID: TFrameID;
  i: Integer;
  GetOwnerIdentifier: AnsiString;
  GetIdentifier: AnsiString;
begin
  Result := -1;
  Identifier := '';
  FrameID := 'UFID';
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = FrameID then
    begin
      GetIdentifier := GetUFID(i, GetOwnerIdentifier);
      if UpperCase(GetOwnerIdentifier) = UpperCase(OwnerIdentifier) then
      begin
        Result := i;
        Identifier := GetIdentifier;
        Break;
      end;
    end;
  end;
end;

function TID3v2Tag.SetUFIDByOwnerIdentifier(OwnerIdentifier: AnsiString;
  Identifier: AnsiString): Boolean;
var
  FrameID: TFrameID;
  i: Integer;
  GetOwnerIdentifier: AnsiString;
  GetIdentifier: AnsiString;
  Index: Integer;
begin
  Result := False;
  Index := -1;
  FrameID := 'UFID';
  for i := 0 to FrameCount - 1 do
  begin
    if Frames[i].ID = FrameID then
    begin
      GetIdentifier := GetUFID(i, GetOwnerIdentifier);
      if UpperCase(GetOwnerIdentifier) = UpperCase(OwnerIdentifier) then
      begin
        Index := i;
        Break;
      end;
    end;
  end;
  if Index = -1 then
  begin
    Index := AddFrame(FrameID);
  end;
  Result := SetUFID(Index, OwnerIdentifier, Identifier);
end;

function TID3v2Tag.GetUFID(FrameIndex: Integer; var OwnerIdentifier:
  AnsiString): AnsiString;
var
  DataByte: Byte;
begin
  Result := '';
  OwnerIdentifier := '';
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    if Frames[FrameIndex].Stream.Size = 0 then
    begin
      Exit;
    end;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
    repeat
      Frames[FrameIndex].Stream.Read(DataByte, 1);
      if DataByte <> $0 then
      begin
        OwnerIdentifier := OwnerIdentifier + AnsiChar(DataByte);
      end;
    until (DataByte = 0) or (Frames[FrameIndex].Stream.Position >=
      Frames[FrameIndex].Stream.Size);
    repeat
      Frames[FrameIndex].Stream.Read(DataByte, 1);
      if DataByte <> $0 then
      begin
        Result := Result + AnsiChar(DataByte);
      end;
    until Frames[FrameIndex].Stream.Position >= Frames[FrameIndex].Stream.Size;
    Frames[FrameIndex].Stream.Seek(0, soBeginning);
  except
    // *
  end;
end;

function TID3v2Tag.SetUFID(FrameID: AnsiString; OwnerIdentifier: AnsiString;
  Identifier: AnsiString): Boolean;
var
  Index: Integer;
  ID: TFrameID;
begin
  Result := False;
  AnsiStringToPAnsiChar(FrameID, @ID, 4);
  Index := FrameExists(ID);
  if Index < 0 then
  begin
    Index := AddFrame(ID);
    if Index < 0 then
    begin
      Exit;
    end;
  end;
  Result := SetUFID(Index, OwnerIdentifier, Identifier);
end;

function TID3v2Tag.SetUFID(FrameIndex: Integer; OwnerIdentifier: AnsiString;
  Identifier: AnsiString): Boolean;
var
  DataByte: Byte;
begin
  Result := False;
  if (FrameIndex >= FrameCount) or (FrameIndex < 0) then
  begin
    Exit;
  end;
  try
    Frames[FrameIndex].Stream.Clear;
    // * Write the Owner Identifier
    Frames[FrameIndex].Stream.Write(PAnsiChar(OwnerIdentifier)^,
      Length(OwnerIdentifier) + 1);
    // * Write the Identifier
    Frames[FrameIndex].Stream.Write(PAnsiChar(Identifier)^,
      (Length(Identifier)));
    Frames[FrameIndex].Stream.Seek(0, soFromBeginning);
    Result := True;
  except
    // *
  end;
end;

function ID3v2TagErrorCode2String(ErrorCode: Integer): string;
begin
  Result := 'Unknown error code.';
  case ErrorCode of
    ID3V2LIBRARY_SUCCESS:
      Result := 'Success.';
    ID3V2LIBRARY_ERROR:
      Result := 'Unknown error occured.';
    ID3V2LIBRARY_ERROR_NO_TAG_FOUND:
      Result := 'No ID3v2 tag found.';
    ID3V2LIBRARY_ERROR_EMPTY_TAG:
      Result := 'ID3v2 tag is empty.';
    ID3V2LIBRARY_ERROR_EMPTY_FRAMES:
      Result := 'ID3v2 tag contains only empty frames.';
    ID3V2LIBRARY_ERROR_OPENING_FILE:
      Result := 'Error opening file.';
    ID3V2LIBRARY_ERROR_READING_FILE:
      Result := 'Error reading file.';
    ID3V2LIBRARY_ERROR_WRITING_FILE:
      Result := 'Error writing file.';
    ID3V2LIBRARY_ERROR_DOESNT_FIT:
      Result := 'Error: ID3v2 tag doesn''t fit into the file.';
    ID3V2LIBRARY_ERROR_NOT_SUPPORTED_VERSION:
      Result := 'Error: not supported ID3v2 version.';
    ID3V2LIBRARY_ERROR_NOT_SUPPORTED_FORMAT:
      Result := 'Error not supported file format.';
    ID3V2LIBRARY_ERROR_NEED_EXCLUSIVE_ACCESS:
      Result :=
        'Error: file is locked. Need exclusive access to write ID3v2 tag to this file.';
  end;
end;

function ValidID3v2FrameID(FrameID: TFrameID): Boolean;
var
  FrameIDChar: AnsiChar;
  i: Integer;
begin
  Result := True;
  for i := 0 to 3 do
  begin
    FrameIDChar := FrameID[i];
    if not (FrameIDChar in ['A'..'Z'] + ['0'..'9']) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function ValidID3v2FrameID2(FrameID: TFrameID): Boolean;
var
  FrameIDChar: AnsiChar;
  i: Integer;
begin
  Result := True;
  for i := 0 to 2 do
  begin
    FrameIDChar := FrameID[i];
    if not (FrameIDChar in ['A'..'Z'] + ['0'..'9']) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function GetID3v2FrameType(FrameID: TFrameID): TID3v2FrameType;
begin
  Result := ftUnknown;

  if FrameID[0] = 'T' then
  begin
    Result := ftText;
  end;

  if (FrameID = 'TXXX')
    {// * TODO: all specified frames}then
  begin
    Result := ftTextWithDescription;
  end;

  if (FrameID = 'COMM') or (FrameID = 'USLT') then
  begin
    Result := ftTextWithDescriptionAndLangugageID;
  end;

  if (FrameID = 'TIPL') or (FrameID = 'TMCL') then
  begin
    Result := ftTextList;
  end;

  if FrameID[0] = 'W' then
  begin
    Result := ftURL;
  end;

  if (FrameID = 'WXXX') then
  begin
    Result := ftUserDefinedURL;
  end;
end;

initialization

  ID3v2ID := 'ID3';
  RIFFID := 'RIFF';
  RF64ID := 'RF64';
  RIFFWAVEID := 'WAVE';
  RIFFID3v2ID := 'id3 ';
  AIFFID := 'FORM';
  AIFFChunkID := 'AIFF';
  AIFCChunkID := 'AIFC';
  AIFFID3v2ID := 'ID3 ';

end.

