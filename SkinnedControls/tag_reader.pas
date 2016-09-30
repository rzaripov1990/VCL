unit tag_reader;
{$WARNINGS OFF}
{$HINTS OFF}
{ ----------------------------------------------
  |  ATL: Audio Tools Library                  |
  |       http://mac.sourceforge.net/atl/      |
  | mail: macteam@users.sourceforge.net        |
  |                                            |
  | Copyright (c) 2000-2002 by Jurgen Faul     |
  | Copyright (c) 2003-2005 by The MAC Team    |
  |********************************************|
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |--------------------------------------------|
  |-    adapted for Delphi 2009+ (UNICODE)    -|
  ---------------------------------------------- }

interface

uses
  Windows, SysUtils, Classes, Math, List_Class;

// type
// TPLItem = record
// fName: string;
// fType: string;
// fTitle: string;
// fArtist: string;
// fGenre: string;
// fAlbum: string;
// fYear: string;
// fComment: string;
// fDuration: integer;
// fSampleRate: integer;
// fBitrate: integer;
// fSize: integer;
// fCue: boolean;
// fError: boolean;
// end;

function BuildTagItem(var Item: TPLItem; const FileName: string;
  const IsCueFile: boolean = false): boolean;

function DetectMPEG(var Item: TPLItem): boolean;
function DetectID3v1(var Item: TPLItem): boolean; overload;
function DetectID3v1(struct: Pointer; var Item: TPLItem): boolean; overload;
// for bass.dll
function DetectID3v2(var Item: TPLItem): boolean; overload;
function DetectID3v2(struct: Pointer; var Item: TPLItem): boolean; overload;
// for bass.dll
function DetectWMA(var Item: TPLItem): boolean;
function DetectTrack(struct: string; var Item: TPLItem): boolean;
// for bass.dll
function DetectWAV(var Item: TPLItem): boolean;
function DetectAC3(var Item: TPLItem): boolean;
function DetectLyrics3(var Item: TPLItem): boolean; overload; // incorrect
function DetectLyrics3(struct: string; var Item: TPLItem): boolean; overload;
// for bass.dll
function DetectAPE(var Item: TPLItem): boolean;
function DetectAAC(var Item: TPLItem): boolean;
function DetectFLAC(var Item: TPLItem; out CueSheetData: string): boolean;
function DetectOGG(var Item: TPLItem): boolean;
function DetectSPX(var Item: TPLItem): boolean;
function DetectMAC(var Item: TPLItem): boolean;
function DetectTTA(var Item: TPLItem): boolean;
function DetectWV(var Item: TPLItem): boolean;
function DetectMPP(var Item: TPLItem): boolean;

implementation

const
  // -------------------------------------

  { tag fields count }
  FIELD_COUNT = 6;
  FIELD_COUNT_EX = 9;

  { Names of supported tag fields }
  FIELD_NAMES: array [1 .. FIELD_COUNT_EX] of string = ('TITLE', 'ARTIST',
    'ALBUM', 'YEAR', 'GENRE', 'COMMENT', 'PERFORMER', 'DESCRIPTION',
    'CUESHEET');

  { Unicode ID }
  UNICODE_ID = #1;

  // -------------- ID3v1 ----------------
  { ID3v1 tag ID }
  ID3V1_ID = 'TAG';

  { ID3v1 tag Size }
  ID3V1_SIZE = 128;

  { Used with Version property }
  TAG_VERSION_1_0 = 1; { Index for ID3v1.0 tag }
  TAG_VERSION_1_1 = 2; { Index for ID3v1.1 tag }

  MAX_MUSIC_GENRES = 148; { Max. number of music genres }

  GENRE_TABLE: array [0 .. MAX_MUSIC_GENRES - 1] of string = ('Blues',
    'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge', 'Hip-Hop',
    'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B', 'Rap',
    'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska',
    'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient', 'Trip-Hop',
    'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental',
    'Acid', 'House', 'Game', 'Sound Clip', 'Gospel', 'Noise', 'AlternRock',
    'Bass', 'Soul', 'Punk', 'Space', 'Meditative', 'Instrumental Pop',
    'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave', 'Techno-Industrial',
    'Electronic', 'Pop-Folk', 'Eurodance', 'Dream', 'Southern Rock', 'Comedy',
    'Cult', 'Gangsta', 'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle',
    'Native American', 'Cabaret', 'New Wave', 'Psychadelic', 'Rave',
    'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz',
    'Polka', 'Retro', 'Musical', 'Rock & Roll', 'Hard Rock', 'Folk',
    'Folk-Rock', 'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin',
    'Revival', 'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock',
    'Progressive Rock', 'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock',
    'Big Band', 'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech',
    'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass',
    'Primus', 'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba',
    'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle', 'Duet',
    'Punk Rock', 'Drum Solo', 'A capella', 'Euro-House', 'Dance Hall', 'Goa',
    'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie', 'BritPop',
    'Negerpunk', 'Polsk Punk', 'Beat', 'Christian Gangsta Rap', 'Heavy Metal',
    'Black Metal', 'Crossover', 'Contemporary Christian', 'Christian Rock',
    'Merengue', 'Salsa', 'Thrash Metal', 'Anime', 'JPop', 'Synthpop');

  // -------------- LYRICS ---------------
  { LYRICS ID }
  LYR_200 = 'LYRICS200';
  LYR_BEGIN = 'LYRICSBEGIN';
  LYR_IND = 'IND';
  LYR = 'LYR';
  LYR_INF = 'INF';
  LYR_AUT = 'AUT';
  LYR_EAL = 'EAL';
  LYR_EAR = 'EAR';
  LYR_ETT = 'ETT';

  // -------------- ID3v2 ----------------
  { Used with Version property }
  TAG_VERSION_2_2 = 2; { Code for ID3v2.2.x tag }
  TAG_VERSION_2_3 = 3; { Code for ID3v2.3.x tag }
  TAG_VERSION_2_4 = 4; { Code for ID3v2.4.x tag }

  { ID3v2 tag ID }
  ID3V2_ID = 'ID3';

  { Max. number of supported tag frames }
  ID3V2_FRAME_COUNT = 10;

  { Names of supported tag frames (ID3v2.3.x & ID3v2.4.x) }
  ID3V2_FRAME_NEW: array [1 .. ID3V2_FRAME_COUNT] of string = ('TIT2', 'TPE1',
    'TCON', 'TOPE', 'TIT1', 'TYER', 'TDRC', 'COMM', 'TALB', 'TOAL');

  { Names of supported tag frames (ID3v2.2.x) }
  ID3V2_FRAME_OLD: array [1 .. ID3V2_FRAME_COUNT] of string = ('TT2', 'TP1',
    'TCO', 'TOA', 'TT1', 'TYE', 'TOR', 'COM', 'TAL', 'TOA');

  { Max. tag size for saving }
  ID3V2_MAX_SIZE = 4096;

  // -------------- WMA ----------------
  { Object IDs }
  WMA_HEADER_ID = #48#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;
  WMA_FILE_PROPERTIES_ID =
    #161#220#171#140#71#169#207#17#142#228#0#192#12#32#83#101;
  WMA_STREAM_PROPERTIES_ID =
    #145#7#220#183#183#169#207#17#142#230#0#192#12#32#83#101;
  WMA_CONTENT_DESCRIPTION_ID =
    #51#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;
  WMA_EXTENDED_CONTENT_DESCRIPTION_ID =
    #64#164#208#210#7#227#210#17#151#240#0#160#201#94#168#80;

  { Names of supported comment fields }
  WMA_FIELD_NAME: array [1 .. FIELD_COUNT] of string = ('WM/TITLE', 'WM/AUTHOR',
    'WM/ALBUMTITLE', 'WM/YEAR', 'WM/GENRE', 'WM/DESCRIPTION');

  { Max. number of characters in tag field }
  WMA_MAX_STRING_SIZE = 250;

  // -------------- WAV ----------------
  WAV_CHUNK = 'data'; { Data chunk ID }
  WAV_RIFF_ID = 'RIFF'; { RIFF ID }
  WAV_WAVE_ID = 'WAVE'; { WAVE ID }
  WAV_FMT_ID = 'fmt '; { FMT  ID }
  WAV_PACK_ID = 'wvpk'; { WAVE PACK }

  // -------------- AC3 ----------------
  { AC3 ID }
  AC3_ID = 30475;

  AC3_BIRATES: array [0 .. 18] of integer = { Bitrates }
    (32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 448,
    512, 576, 640);

  // -------------- APE ----------------
  { APE ID }
  APE_ID = 'APETAGEX'; { APE }

  { Size constants }
  APE_TAG_FOOTER_SIZE = 32; { APE tag footer }
  APE_TAG_HEADER_SIZE = 32; { APE tag header }

  { First version of APE tag }
  APE_VERSION_1_0 = 1000;

  // -------------- AAC ----------------
  { ADIF ID }
  ADIF_ID = 'ADIF';

  { Header type codes }
  AAC_HEADER_TYPE_UNKNOWN = 0; { Unknown }
  AAC_HEADER_TYPE_ADIF = 1; { ADIF }
  AAC_HEADER_TYPE_ADTS = 2; { ADTS }

  { MPEG version codes }
  AAC_MPEG_VERSION_UNKNOWN = 0; { Unknown }
  AAC_MPEG_VERSION_2 = 1; { MPEG-2 }
  AAC_MPEG_VERSION_4 = 2; { MPEG-4 }

  { Bit rate type codes }
  AAC_BITRATE_TYPE_UNKNOWN = 0; { Unknown }
  AAC_BITRATE_TYPE_CBR = 1; { CBR }
  AAC_BITRATE_TYPE_VBR = 2; { VBR }

  { Sample rate values }
  AACSAMPLE_RATE: array [0 .. 15] of integer = (96000, 88200, 64000, 48000,
    44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 0, 0, 0, 0);

  // -------------- FLAC ---------------
  { FLAC ID }
  FLAC_ID = 'fLaC';

  { block types }
  FLAC_STREAM_INFO = 0;
  FLAC_VORBIS_COMMENT = 4;

  // ------------ Vorbis ---------------
  { OGG ID }
  OGG_ID = 'OggS';

  { Vorbis parameter frame ID }
  VORBIS_PARAMETERS_ID = #1 + 'vorbis';
  SPEEX_PARAMETERS_ID = 'Speex   ';

  { Vorbis tag frame ID }
  VORBIS_TAG_ID = #3 + 'vorbis';

  { Ogg structure size }
  OGG_HEADER_SIZE = 27;

  // -------------- MAC ----------------
  { MAC ID }
  MAC_ID = 'MAC ';

  // -------------- TAA ----------------
  { TTA ID }
  TTA_ID = 'TTA1';

  // --------------- WV ----------------
  { Wave Pack }
  SampleRates: array [0 .. 14] of integer = (6000, 8000, 9600, 11025, 12000,
    16000, 22050, 24000, 32000, 44100, 48000, 64000, 88200, 96000, 192000);

  // -------------- MP+ ----------------
  { ID code for stream version 7 and 7.1 }
  MPP_VERSION_7_ID = 120279117; { 120279117 = 'MP+' + #7 }
  MPP_VERSION_71_ID = 388714573; { 388714573 = 'MP+' + #23 }

  MPP_SampleRates: array [0 .. 3] of integer = (44100, 48000, 37800, 32000);

  // ---------- MPEG Audio ------------
  { Table for bit rates }
  MPEG_BIT_RATE: array [0 .. 3, 0 .. 3, 0 .. 15] of Word = (
    { For MPEG 2.5 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), (0, 8, 16, 24, 32, 40,
    48, 56, 64, 80, 96, 112, 128, 144, 160, 0), (0, 8, 16, 24, 32, 40, 48, 56,
    64, 80, 96, 112, 128, 144, 160, 0), (0, 32, 48, 56, 64, 80, 96, 112, 128,
    144, 160, 176, 192, 224, 256, 0)),
    { Reserved }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), (0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0), (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)),
    { For MPEG 2 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), (0, 8, 16, 24, 32, 40,
    48, 56, 64, 80, 96, 112, 128, 144, 160, 0), (0, 8, 16, 24, 32, 40, 48, 56,
    64, 80, 96, 112, 128, 144, 160, 0), (0, 32, 48, 56, 64, 80, 96, 112, 128,
    144, 160, 176, 192, 224, 256, 0)),
    { For MPEG 1 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), (0, 32, 40, 48, 56, 64,
    80, 96, 112, 128, 160, 192, 224, 256, 320, 0), (0, 32, 48, 56, 64, 80, 96,
    112, 128, 160, 192, 224, 256, 320, 384, 0), (0, 32, 64, 96, 128, 160, 192,
    224, 256, 288, 320, 352, 384, 416, 448, 0)));

  { Sample rate codes }
  MPEG_SAMPLE_RATE_LEVEL_3 = 0; { Level 3 }
  MPEG_SAMPLE_RATE_LEVEL_2 = 1; { Level 2 }
  MPEG_SAMPLE_RATE_LEVEL_1 = 2; { Level 1 }
  MPEG_SAMPLE_RATE_UNKNOWN = 3; { Unknown value }

  { Table for sample rates }
  MPEG_SAMPLE_RATE: array [0 .. 3, 0 .. 3] of Word = ((11025, 12000, 8000, 0),
    { For MPEG 2.5 }
    (0, 0, 0, 0), { Reserved }
    (22050, 24000, 16000, 0), { For MPEG 2 }
    (44100, 48000, 32000, 0) { For MPEG 1 }
    );

  { MPEG version codes }
  MPEG_VERSION_2_5 = 0; { MPEG 2.5 }
  MPEG_VERSION_UNKNOWN = 1; { Unknown version }
  MPEG_VERSION_2 = 2; { MPEG 2 }
  MPEG_VERSION_1 = 3; { MPEG 1 }

  { MPEG layer codes }
  MPEG_LAYER_UNKNOWN = 0; { Unknown layer }
  MPEG_LAYER_III = 1; { Layer III }
  MPEG_LAYER_II = 2; { Layer II }
  MPEG_LAYER_I = 3; { Layer I }

  { Limitation constants }
  MAX_MPEG_FRAME_LENGTH = 1729; { Max. MPEG frame length }
  MIN_MPEG_BIT_RATE = 8; { Min. bit rate value }
  MAX_MPEG_BIT_RATE = 448; { Max. bit rate value }

  { VBR header ID for Xing/FhG }
  VBR_ID_XING = 'Xing'; { Xing VBR ID }
  VBR_ID_FHG = 'VBRI'; { FhG VBR ID }

type
  // -------------- ID3v1 ----------------
  { ID3 header data }
  PTagID3 = ^TagID3;

  TagID3 = record
    ID: array [0 .. 2] of AnsiChar; { Always "TAG" }
    Title: array [0 .. 29] of AnsiChar; { Title info }
    Artist: array [0 .. 29] of AnsiChar; { Artist info }
    Album: array [0 .. 29] of AnsiChar; { Album info }
    Year: array [0 .. 3] of AnsiChar; { Year info }
    Comment: array [0 .. 29] of AnsiChar; { Comment info }
    Genre: Byte; { Genre ID }
  end;

  // ------------- LYRICS 3 --------------
  Lyr2Mark = record
    Size: array [1 .. 6] of AnsiChar;
    Mark: array [1 .. 9] of AnsiChar;
  end;

  Lyr2Field = record
    ID: array [1 .. 3] of AnsiChar;
    Size: array [1 .. 5] of AnsiChar;
  end;

  // -------------- ID3v2 ----------------
  { Frame header (ID3v2.3.x & ID3v2.4.x) }
  FrameHeaderNew = record
    ID: array [1 .. 4] of AnsiChar; { Frame ID }
    Size: integer; { Size excluding header }
    Flags: Word; { Flags }
  end;

  { Frame header (ID3v2.2.x) }
  FrameHeaderOld = record
    ID: array [1 .. 3] of AnsiChar; { Frame ID }
    Size: array [1 .. 3] of Byte; { Size excluding header }
  end;

  { ID3v2 header data - for internal use }
  TagID3v2 = record
    { Real structure of ID3v2 header }
    ID: array [1 .. 3] of AnsiChar; { Always "ID3" }
    Version: Byte; { Version number }
    Revision: Byte; { Revision number }
    Flags: Byte; { Flags of tag }
    Size: array [1 .. 4] of Byte; { Tag size excluding header }
    { Extended data }
    FileSize: integer; { File size (bytes) }
    Frame: array [1 .. ID3V2_FRAME_COUNT] of Ansistring;
    { Information from frames }
    NeedRewrite: boolean; { Tag should be rewritten }
    PaddingSize: integer; { Padding size (bytes) }
  end;

  // -------------- WMA ----------------
  { Object ID }
  WMAObjectID = array [1 .. 16] of AnsiChar;

  { Tag data }
  TagWMAData = array [1 .. FIELD_COUNT] of string;

  { File data - for internal use }
  TagWMA = record
    FileSize: integer; { File size (bytes) }
    MaxBitRate: integer; { Max. bit rate (bps) }
    Channels: Word; { Number of channels }
    SampleRate: integer; { Sample rate (hz) }
    ByteRate: integer; { Byte rate }
    Tag: TagWMAData; { WMA tag information }
  end;

  // -------------- WAV ----------------
  { WAV file header data }
  TagWAV = record
    { RIFF file header }
    RIFFHeader: array [1 .. 4] of AnsiChar; { Must be "RIFF" }
    FileSize: integer; { Must be "RealFileSize - 8" }
    WAVEHeader: array [1 .. 4] of AnsiChar; { Must be "WAVE" }
    { Format information }
    FormatHeader: array [1 .. 4] of AnsiChar; { Must be "fmt " }
    FormatSize: integer; { Format size }
    FormatID: Word; { Format type code }
    ChannelNumber: Word; { Number of channels }
    SampleRate: integer; { Sample rate (hz) }
    BytesPerSecond: integer; { Bytes/second }
    BlockAlign: Word; { Block alignment }
    BitsPerSample: Word; { Bits/sample }
    DataHeader: array [1 .. 4] of AnsiChar; { Can be "data" }
    SampleNumber: integer; { Number of samples (optional) }
  end;

  // -------------- APE ----------------
  { APE tag data - for internal use }
  TagAPE = record
    { Real structure of APE footer }
    ID: array [1 .. 8] of AnsiChar; { Always "APETAGEX" }
    Version: integer; { Tag version }
    Size: integer; { Tag size including footer }
    Fields: integer; { Number of fields }
    Flags: integer; { Tag flags }
    Reserved: array [1 .. 8] of AnsiChar; { Reserved for later use }
    { Extended data }
    DataShift: Byte; { Used if ID3v1 tag found }
    FileSize: integer; { File size (bytes) }
    Field: array [1 .. FIELD_COUNT_EX] of string; { Information from fields }
  end;

  // -------------- FLAC ---------------

  // TFLAC_MD5 = array [0 .. 15] of Byte;  // Array to hold MD5 signature of the unencoded audio data.
  TFileID = array [1 .. 4] of AnsiChar; // should always be 'fLaC'

  TagFLAC = packed record
    BlockType: Byte;
    BlockSize: array [1 .. 3] of Byte;
  end;

  FLAC_StreamInfo = packed record
    MinBlockSize: array [1 .. 2] of Byte;
    MaxBlockSize: array [1 .. 2] of Byte;
    MinFlameSize: array [1 .. 3] of Byte;
    MaxFlameSize: array [1 .. 3] of Byte;
    SampleRate: array [1 .. 3] of Byte;
    // 4bit of right side in SampleRate[3] is used for for other purpose
    TotalSamples: array [1 .. 5] of Byte;
    // 4bit of left side in TotalSamples[1] is used for for other purpose
    // Above 8(4+4)bits constitutes Number of Channel(3bits) + Bits per Sample(5bits)
    // MD5Signature: TFLAC_MD5;
  end;

  // ------------- VORBIS --------------
  { Ogg page header }
  TagOGG = packed record
    ID: array [1 .. 4] of AnsiChar; { Always "OggS" }
    StreamVersion: Byte; { Stream structure version }
    TypeFlag: Byte; { Header type flag }
    AbsolutePosition: Int64; { Absolute granule position }
    Serial: integer; { Stream serial number }
    PageNumber: integer; { Page sequence number }
    Checksum: integer; { Page checksum }
    Segments: Byte; { Number of page segments }
    LacingValues: array [1 .. $FF] of Byte; { Lacing values - segment sizes }
  end;

  { Vorbis parameter header }
  VorbisHeader = packed record
    ID: array [1 .. 7] of AnsiChar; { Always #1 + "vorbis" }
    BitstreamVersion: array [1 .. 4] of Byte; { Bitstream version number }
    ChannelMode: Byte; { Number of channels }
    SampleRate: integer; { Sample rate (hz) }
    BitRateMaximal: integer; { Bit rate upper limit }
    BitRateNominal: integer; { Nominal bit rate }
    BitRateMinimal: integer; { Bit rate lower limit }
    BlockSize: Byte; { Coded size for small and long blocks }
    StopFlag: Byte; { Always 1 }
  end;

  { Vorbis tag data }
  VorbisTag = record
    ID: array [1 .. 7] of AnsiChar; { Always #3 + "vorbis" }
    Fields: integer; { Number of tag fields }
    FieldData: array [0 .. FIELD_COUNT_EX] of string; { Tag field data }
  end;

  { Speex parameter header }
  SpeexHeader = packed record
    SpeexString: array [1 .. 8] of AnsiChar;
    SpeexVersion: array [1 .. 20] of AnsiChar;
    SpeexVersionID: integer;
    HeaderSize: integer;
    Rate: integer;
    Mode: integer;
    ModeBitStreamVersion: integer;
    Channels: integer;
    Bitrate: integer;
    FrameSize: integer;
    VBR: integer;
    FramesPerPacket: integer;
    ExtraHeaders: integer;
    Reserved1: integer;
    Reserved2: integer;
  end;

  { File data }
  VorbisFileInfo = record
    FPage, SPage, LPage: TagOGG; { First, second and last page }
    Tag: VorbisTag; { Vorbis tag data }
    VorbisParameters: VorbisHeader; { Vorbis parameter header }
    SpeexParameters: SpeexHeader; { Speex parameter header }
    FileSize: Int64; { File size (bytes) }
    Samples: integer; { Total number of samples }
    ID3v2Size: integer; { ID3v2 tag size (bytes) }
    SPagePos: integer; { Position of second Ogg page }
    TagEndPos: integer; { Tag end position }
    VorbisPages: integer;
    isOggVorbis: boolean;
    isSpeex: boolean;
  end;

  // -------------- MAC ----------------
  TagMAC = packed record
    cID: array [0 .. 3] of Byte; // should equal 'MAC '
    nVersion: Word; // version number * 1000 (3.81 = 3810)
  end;

  // old header for <= 3.97
  TagMAC_OLD = packed record
    nCompressionLevel, // the compression level
    nFormatFlags, // any format flags (for future use)
    nChannels: Word; // the number of channels (1 or 2)
    nSampleRate, // the sample rate (typically 44100)
    nHeaderBytes, // the bytes after the MAC header that compose the WAV header
    nTerminatingBytes, // the bytes after that raw data (for extended info)
    nTotalFrames, // the number of frames in the file
    nFinalFrameBlocks: longword; // the number of samples in the final frame
    nInt: integer;
  end;

  // new header for >= 3.98
  TagMAC_NEW = packed record
    nCompressionLevel: Word;
    // the compression level (see defines I.E. COMPRESSION_LEVEL_FAST)
    nFormatFlags: Word;
    // any format flags (for future use) Note: NOT the same flags as the old header!
    nBlocksPerFrame: longword; // the number of audio blocks in one frame
    nFinalFrameBlocks: longword;
    // the number of audio blocks in the final frame
    nTotalFrames: longword; // the total number of frames
    nBitsPerSample: Word; // the bits per sample (typically 16)
    nChannels: Word; // the number of channels (1 or 2)
    nSampleRate: longword; // the sample rate (typically 44100)
  end;

  // data descriptor for >= 3.98
  MAC_DESCRIPTOR = packed record
    padded: Word; // padding/reserved (always empty)
    nDescriptorBytes,
    // the number of descriptor bytes (allows later expansion of this header)
    nHeaderBytes, // the number of header APE_HEADER bytes
    nSeekTableBytes, // the number of bytes of the seek table
    nHeaderDataBytes, // the number of header data bytes (from original file)
    nAPEFrameDataBytes, // the number of bytes of APE frame data
    nAPEFrameDataBytesHigh, // the high order number of APE frame data bytes
    nTerminatingDataBytes: longword;
    // the terminating data of the file (not including tag data)
    cFileMD5: array [0 .. 15] of Byte;
    // the MD5 hash of the file (see notes for usage... it's a littly tricky)
  end;

  // -------------- TTA ----------------
  TagTTA = packed record
    // TTAid: array[0..3] of Char;
    AudioFormat: Word;
    NumChannels: Word;
    BitsPerSample: Word;
    SampleRate: longword;
    DataLength: longword;
    CRC32: longword;
  end;

  // ------------ Wave Pack -------------

  TagWAVPack_3 = record
    ckID: array [0 .. 3] of AnsiChar;
    ckSize: longword;
    Version: Word;
    Bits: Word;
    Flags: Word;
    Shift: Word;
    TotalSamples: longword;
    Crc: longword;
    Crc2: longword;
    Extension: array [0 .. 3] of AnsiChar;
    ExtraBc: Byte;
    Extras: array [0 .. 2] of AnsiChar;
  end;

  TagWAVPack_4 = record
    ckID: array [0 .. 3] of AnsiChar;
    ckSize: longword;
    Version: Word;
    TrackNo: Byte;
    IndexNo: Byte;
    TotalSamples: longword;
    BlockIndex: longword;
    BlockSamples: longword;
    Flags: longword;
    Crc: longword;
  end;

  Fmt_Chunk = record
    wFormatTag: Word;
    wChannels: Word;
    dwSamplesPerSec: longword;
    dwBytesPerSec: longword;
    wBlockAlign: Word;
    wBitsPerSample: Word;
  end;

  RIFF_Chunk = record
    ID: array [0 .. 3] of AnsiChar;
    Size: longword;
  end;

  // -------------- MP+ ----------------
  { File header data - for internal use }
  TagMPPlus = record
    ByteArray: array [1 .. 32] of Byte; { Data as byte array }
    IntegerArray: array [1 .. 8] of integer; { Data as integer array }
    FileSize: integer; { File size }
    ID3v2Size: integer; { ID3v2 tag size (bytes) }
  end;

  // ------------ MPEG Audio -----------
  { Xing/FhG VBR header data }
  VBRData = record
    Found: boolean; { True if VBR header found }
    ID: array [1 .. 4] of AnsiChar; { Header ID: "Xing" or "VBRI" }
    Frames: integer; { Total number of frames }
    Bytes: integer; { Total number of bytes }
    Scale: Byte; { VBR scale (1..100) }
    VendorID: string; { Vendor ID (if present) }
  end;

  { MPEG frame header data }
  TagMPEG = record
    Found: boolean; { True if frame found }
    Position: integer; { Frame position in the file }
    Size: Word; { Frame size (bytes) }
    Xing: boolean; { True if Xing encoder }
    Data: array [1 .. 4] of Byte; { The whole frame header data }
    VersionID: Byte; { MPEG version ID }
    LayerID: Byte; { MPEG layer ID }
    ProtectionBit: boolean; { True if protected by CRC }
    BitRateID: Word; { Bit rate ID }
    SampleRateID: Word; { Sample rate ID }
    PaddingBit: boolean; { True if frame padded }
    PrivateBit: boolean; { Extra information }
    ModeID: Byte; { Channel mode ID }
    ModeExtensionID: Byte; { Mode extension ID (for Joint Stereo) }
    CopyrightBit: boolean; { True if audio copyrighted }
    OriginalBit: boolean; { True if original media }
    EmphasisID: Byte; { Emphasis ID }
  end;

  // ........................... OTHER FUNCTIONS ............................. //

function BuildTagItem(var Item: TPLItem; const FileName: string;
  const IsCueFile: boolean = false): boolean;
begin
  Result := true;
  FillChar(Item, SizeOf(Item), 0);

  Item.plFile := FileName; // записываем имя файла ( обязательно! )
  // Item.plTitle := ChangeFileExt(ExtractFileName(FileName), '');
  Item.plType := UpperCase(Copy(ExtractFileExt(FileName), 2,
    Length(ExtractFileExt(FileName))));
  Item.plCue := IsCueFile;
  Item.plSwitch := true;
  Item.plDuration := -1;
  Item.plError := (not FileExists(FileName)) and (not IsCueFile);
end;

{ --------------------------------------------------------------------------- }

// function IsUTF8String(const Str: ansistring): boolean;
//
// function IsUTF8LeadByte(Lead: AnsiChar): boolean;
// begin
// Result := (Byte(Lead) <= $7F) or (($C2 <= Byte(Lead)) and (Byte(Lead) <= $FD));
// end;
//
// function IsUTF8TrailByte(Lead: AnsiChar): boolean;
// begin
// Result := ($80 <= Byte(Lead)) and (Byte(Lead) <= $BF);
// end;
//
// begin
// Result := (IsUTF8LeadByte(Str[1]) or (IsUTF8TrailByte(Str[1])));
// end;

{ ---------------------------------------------------------------------------

  function IsUTF8String(const aChar: AnsiChar): boolean;
  begin
  Result := (((Byte(aChar) <= $7F) or (($C2 <= Byte(aChar)) and (Byte(aChar) <= $FD))) or ($80 <= Byte(aChar)) and
  (Byte(aChar) <= $BF));
  end;

  { ---------------------------------------------------------------------------

  function GetANSI(const Source: Ansistring): Ansistring; inline;
  var
  Index: integer;
  FirstByte, SecondByte: Byte;
  UnicodeChar: WideChar;
  begin
  Result := '';
  if (Length(Source) > 0) then
  begin
  if (Source[1] = UNICODE_ID) then
  begin
  Result := 'utf16' + WideCharLenToString(PChar(Source), Length(Source));

  // for Index := 2 to ((Length(Source) - 1) div 2) do
  // begin
  // FirstByte := Ord(Source[Index * 2]);
  // SecondByte := Ord(Source[Index * 2 + 1]);
  // UnicodeChar := WideChar(FirstByte or (SecondByte shl 8));
  // if UnicodeChar = #0 then
  // break;
  // // if FirstByte < $FF then
  // Result := Result + UnicodeChar;
  // end;
  Result := Trim(Result);
  end
  else if IsUTF8String(Source[1]) then
  Result := 'utf8' + Trim(UTF8ToString(Source))
  else
  Result := 'nil' + Trim(Source);
  end;
  end;

  { --------------------------------------------------------------------------- }

function IsUTF8(Stream: TStream; out WithBOM: boolean): boolean;
const
  MinimumCountOfUTF8Strings = 1;
  MaxBufferSize = $4000;
  UTF8BOM: array [0 .. 2] of Byte = ($EF, $BB, $BF);
var
  Buffer: array of Byte;
  BufferSize, i, FoundUTF8Strings: integer;

  // 3 trailing bytes are the maximum in valid UTF-8 streams,
  // so a count of 4 trailing bytes is enough to detect invalid UTF-8 streams
  function CountOfTrailingBytes: integer;
  begin
    Result := 0;
    inc(i);
    while (i < BufferSize) and (Result < 4) do
    begin
      if Buffer[i] in [$80 .. $BF] then
        inc(Result)
      else
        Break;
      inc(i);
    end;
  end;

begin
  // if Stream is nil, let Delphi raise the exception, by accessing Stream,
  // to signal an invalid result

  // start analysis at actual Stream.Position
  BufferSize := Min(MaxBufferSize, Stream.Size - Stream.Position);

  // if no special characteristics are found it is not UTF-8
  Result := false;
  WithBOM := false;

  if BufferSize > 0 then
  begin
    SetLength(Buffer, BufferSize);
    Stream.ReadBuffer(Buffer[0], BufferSize);
    Stream.Seek(-BufferSize, soFromCurrent);

    { first search for BOM }

    if (BufferSize >= Length(UTF8BOM)) and CompareMem(@Buffer[0], @UTF8BOM[0],
      Length(UTF8BOM)) then
    begin
      WithBOM := true;
      Result := true;
      Exit;
    end;

    { If no BOM was found, check for leading/trailing byte sequences,
      which are uncommon in usual non UTF-8 encoded text.

      NOTE: There is no 100% save way to detect UTF-8 streams. The bigger
      MinimumCountOfUTF8Strings, the lower is the probability of
      a false positive. On the other hand, a big MinimumCountOfUTF8Strings
      makes it unlikely to detect files with only little usage of non
      US-ASCII chars, like usual in European languages. }

    FoundUTF8Strings := 0;
    i := 0;
    while i < BufferSize do
    begin
      case Buffer[i] of
        $00 .. $7F:
        // skip US-ASCII characters as they could belong to various charsets
          ;
        $C2 .. $DF:
          if CountOfTrailingBytes = 1 then
            inc(FoundUTF8Strings)
          else
            Break;
        $E0:
          begin
            inc(i);
            if (i < BufferSize) and (Buffer[i] in [$A0 .. $BF]) and
              (CountOfTrailingBytes = 1) then
              inc(FoundUTF8Strings)
            else
              Break;
          end;
        $E1 .. $EC, $EE .. $EF:
          if CountOfTrailingBytes = 2 then
            inc(FoundUTF8Strings)
          else
            Break;
        $ED:
          begin
            inc(i);
            if (i < BufferSize) and (Buffer[i] in [$80 .. $9F]) and
              (CountOfTrailingBytes = 1) then
              inc(FoundUTF8Strings)
            else
              Break;
          end;
        $F0:
          begin
            inc(i);
            if (i < BufferSize) and (Buffer[i] in [$90 .. $BF]) and
              (CountOfTrailingBytes = 2) then
              inc(FoundUTF8Strings)
            else
              Break;
          end;
        $F1 .. $F3:
          if CountOfTrailingBytes = 3 then
            inc(FoundUTF8Strings)
          else
            Break;
        $F4:
          begin
            inc(i);
            if (i < BufferSize) and (Buffer[i] in [$80 .. $8F]) and
              (CountOfTrailingBytes = 2) then
              inc(FoundUTF8Strings)
            else
              Break;
          end;
        $C0, $C1, $F5 .. $FF: // invalid UTF-8 bytes
          Break;
        $80 .. $BF: // trailing bytes are consumed when handling leading bytes,
          // any occurence of "orphaned" trailing bytes is invalid UTF-8
          Break;
      end;

      if FoundUTF8Strings = MinimumCountOfUTF8Strings then
      begin
        Result := true;
        Break;
      end;

      inc(i);
    end;
  end;
end;

function IsUTF8String(const Str: Ansistring): boolean;
var
  SS: TStringStream;
  WithBOM: boolean;
begin
  SS := TStringStream.Create(Str);
  try
    Result := IsUTF8(SS, WithBOM);
  finally
    SS.Free;
  end;
end;

function LFToCRLF(S: String): String;
var
  i: integer;
begin
  while true do
  begin
    i := Pos(#10, S);
    if i = 0 then
      Break;
    if i = 1 then
      Result := Result + #13#10
    else if S[i - 1] = #13 then
      Result := Result + Copy(S, 1, i)
    else
      Result := Result + Copy(S, 1, i - 1) + #13#10;
    S := Copy(S, i + 1, Length(S));
  end;
  Result := Result + S;
end;

function GetANSI(const Source: Ansistring): String;
var
  Index: integer;
  FirstByte, SecondByte: Byte;
  UnicodeChar: Char;
begin
  Result := LFToCRLF(Trim(String(Source)));
  if (Length(Source) > 0) then
  begin
    if (Source[1] = UNICODE_ID) then
    begin
      Result := '';
      for Index := 2 to ((Length(Source) - 1) div 2) do
      begin
        FirstByte := Ord(Source[Index * 2]);
        SecondByte := Ord(Source[Index * 2 + 1]);
        UnicodeChar := Char(FirstByte or (SecondByte shl 8));
        if UnicodeChar = #0 then
          Break;
        Result := Result + UnicodeChar;
      end;
      Result := LFToCRLF(Trim(Result));
    end
    else if IsUTF8String(Source) then
      Result := LFToCRLF(Trim(UTF8ToString(Source)));
  end;
end;

{ --------------------------------------------------------------------------- }

function GetID3v2Size(const Source: TFileStream): integer;

type
  ID3v2Header = record
    ID: array [1 .. 3] of AnsiChar;
    Version: Byte;
    Revision: Byte;
    Flags: Byte;
    Size: array [1 .. 4] of Byte;
  end;
var
  Header: ID3v2Header;
begin
  { Get ID3v2 tag size (if exists) }
  Result := 0;
  Source.Seek(0, soFromBeginning);
  Source.Read(Header, SizeOf(Header));
  if Header.ID = ID3V2_ID then
  begin
    Result := Header.Size[1] * $200000 + Header.Size[2] * $4000 + Header.Size[3]
      * $80 + Header.Size[4] + 10;
    if Header.Flags and $10 = $10 then
      inc(Result, 10);
    if Result > Source.Size then
      Result := 0;
  end;
end;

// .............. REALIZATION (ID3v2.2 & ID3v2.3 & ID3v2.4) ................. //

function IFV(const Str1, Str2: Ansistring): string;
var
  Res: string;
begin
  Res := GetANSI(Str2);
  if (Res = '') then
    Res := GetANSI(Str1);
  Result := Res;
end;

{ --------------------------------------------------------------------------- }

function ID3Genre(const GenreString: string): string;
begin
  Result := GetANSI(GenreString);
  if Pos(')', Result) > 0 then
    Delete(Result, 1, LastDelimiter(')', Result));
end;

{ --------------------------------------------------------------------------- }

function ID3Year(const YearString, DateString: string): string;
begin
  Result := GetANSI(YearString);
  if Result = '' then
    Result := GetANSI(Copy(DateString, 1, 4));
end;

{ --------------------------------------------------------------------------- }

function ID3Text(const SourceString: string; LanguageID: boolean): string;
var
  Source, Separator: string;
  EncodingID: AnsiChar;
begin
  Source := SourceString;
  Result := '';
  if Length(Source) > 0 then
  begin
    EncodingID := AnsiChar(Source[1]);
    if EncodingID = UNICODE_ID then
      Separator := #0#0
    else
      Separator := #0;
    if LanguageID then
      Delete(Source, 1, 4)
    else
      Delete(Source, 1, 1);
    Delete(Source, 1, Pos(Separator, Source) + Length(Separator) - 1);
    Result := GetANSI(EncodingID + Source);
  end;
end;

{ --------------------------------------------------------------------------- }

procedure ID3SetTagItem(const ID, Data: Ansistring; var Tag: TagID3v2);
var
  Iterator: Byte;
  FrameID: string;
begin
  for Iterator := 1 to ID3V2_FRAME_COUNT do
  begin
    if Tag.Version > TAG_VERSION_2_2 then
      FrameID := ID3V2_FRAME_NEW[Iterator]
    else
      FrameID := ID3V2_FRAME_OLD[Iterator];

    if (FrameID = ID) and (Data[1] <= UNICODE_ID) then
      Tag.Frame[Iterator] := GetANSI(Data);
  end;
end;

{ --------------------------------------------------------------------------- }

function ID3GetTagSize(const Tag: TagID3v2): integer;
begin
  Result := Tag.Size[1] * $200000 + Tag.Size[2] * $4000 + Tag.Size[3] * $80 +
    Tag.Size[4] + 10;
  if Tag.Flags and $10 = $10 then
    inc(Result, 10);
  if Result > Tag.FileSize then
    Result := 0;
end;

{ --------------------------------------------------------------------------- }

function ID3Swap32(const Figure: integer): integer;
var
  AByte: array [1 .. 4] of Byte absolute Figure;
begin
  Result := AByte[1] * $1000000 + AByte[2] * $10000 + AByte[3] * $100 +
    AByte[4];
end;

{ --------------------------------------------------------------------------- }

function ID3ReadHeader(const fName: WideString; var Tag: TagID3v2): boolean;
var
  SourceFile: TFileStream;
  Transferred: integer;
begin
  try
    SourceFile := TFileStream.Create(fName, fmOpenRead or fmShareDenyWrite);
    Transferred := SourceFile.Read(Tag, 10);
    Tag.FileSize := SourceFile.Size;
    FreeAndNil(SourceFile);
    Result := (Transferred >= 10);
  except
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

// by Silhwan Hyun (TBASSPlayer)
procedure ID3ReadFramesNew2(struct: Pointer; var Tag: TagID3v2);
var
  Frame: FrameHeaderNew;
  Data: array [1 .. 500] of AnsiChar;
  DataOffset, DataSize: integer;
  p: PByte;
begin
  { Get information from frames (ID3v2.3.x & ID3v2.4.x) }
  try
    p := struct;
    inc(p, 10);
    DataOffset := 10;

    while ((DataOffset < ID3GetTagSize(Tag)) and (DataOffset < Tag.FileSize)) do
    begin
      FillChar(Data, SizeOf(Data), 0);
      Move(Pointer(p)^, Frame, 10);
      inc(p, 10);

      if not(Frame.ID[1] in ['A' .. 'Z']) then
        Break;

      if ID3Swap32(Frame.Size) > SizeOf(Data) then
        DataSize := SizeOf(Data)
      else
        DataSize := ID3Swap32(Frame.Size);

      Move(Pointer(p)^, Data, DataSize);
      if Frame.Flags and $8000 <> $8000 then
        ID3SetTagItem(Frame.ID, Data, Tag);

      inc(p, ID3Swap32(Frame.Size));
      DataOffset := longword(struct) - longword(p);
    end;
  except

  end;
end;

{ --------------------------------------------------------------------------- }

// by Silhwan Hyun (TBASSPlayer)
procedure ID3ReadFramesOld2(struct: Pointer; var Tag: TagID3v2);
var
  Frame: FrameHeaderOld;
  Data: array [1 .. 500] of AnsiChar;
  DataOffset, FrameSize, DataSize: integer;
  p: PByte;
begin
  { Get information from frames (ID3v2.2.x }
  try
    p := struct;
    inc(p, 10);
    DataOffset := 10;

    while ((DataOffset < ID3GetTagSize(Tag)) and (DataOffset < Tag.FileSize)) do
    begin
      FillChar(Data, SizeOf(Data), 0);
      Move(Pointer(p)^, Frame, 6);
      inc(p, 6);

      if not(Frame.ID[1] in ['A' .. 'Z']) then
        Break;

      FrameSize := Frame.Size[1] shl 16 + Frame.Size[2] shl 8 + Frame.Size[3];
      if FrameSize > SizeOf(Data) then
        DataSize := SizeOf(Data)
      else
        DataSize := FrameSize;

      Move(Pointer(p)^, Data, DataSize);
      ID3SetTagItem(Frame.ID, Data, Tag);

      inc(p, FrameSize);
      DataOffset := longword(struct) - longword(p);
    end;
  except

  end;
end;
{ --------------------------------------------------------------------------- }

procedure ID3ReadFramesOld(const fName: WideString; var Tag: TagID3v2);
var
  SourceFile: TFileStream;
  Frame: FrameHeaderOld;
  Data: array [1 .. 500] of AnsiChar;
  DataPosition, FrameSize, DataSize: integer;
begin
  try
    SourceFile := TFileStream.Create(fName, fmOpenRead or fmShareDenyWrite);
    SourceFile.Seek(10, soFromBeginning);
    while (SourceFile.Position < ID3GetTagSize(Tag)) and
      (SourceFile.Position < SourceFile.Size) do
    begin
      FillChar(Data, SizeOf(Data), 0);
      SourceFile.Read(Frame, 6);
      if not(Frame.ID[1] in ['A' .. 'Z']) then
        Break;
      DataPosition := SourceFile.Position;
      FrameSize := Frame.Size[1] shl 16 + Frame.Size[2] shl 8 + Frame.Size[3];
      if FrameSize > SizeOf(Data) then
        DataSize := SizeOf(Data)
      else
        DataSize := FrameSize;
      SourceFile.Read(Data, DataSize);
      ID3SetTagItem(Frame.ID, Data, Tag);
      SourceFile.Seek(DataPosition + FrameSize, soFromBeginning);
    end;
    FreeAndNil(SourceFile);
  except
  end;
end;

{ --------------------------------------------------------------------------- }

procedure ID3ReadFramesNew(const fName: WideString; var Tag: TagID3v2);
var
  SourceFile: TFileStream;
  Frame: FrameHeaderNew;
  Data: array [1 .. 500] of AnsiChar;
  DataPosition, DataSize: integer;
begin
  try
    SourceFile := TFileStream.Create(fName, fmOpenRead or fmShareDenyWrite);
    SourceFile.Seek(10, soFromBeginning);
    while (SourceFile.Position < ID3GetTagSize(Tag)) and
      (SourceFile.Position < SourceFile.Size) do
    begin
      FillChar(Data, SizeOf(Data), 0);
      SourceFile.Read(Frame, 10);
      if not(Frame.ID[1] in ['A' .. 'Z']) then
        Break;
      DataPosition := SourceFile.Position;
      if ID3Swap32(Frame.Size) > SizeOf(Data) then
        DataSize := SizeOf(Data)
      else
        DataSize := ID3Swap32(Frame.Size);
      SourceFile.Read(Data, DataSize);
      if Frame.Flags and $8000 <> $8000 then
        ID3SetTagItem(Frame.ID, Data, Tag);
      SourceFile.Seek(DataPosition + ID3Swap32(Frame.Size), soFromBeginning);
    end;
    FreeAndNil(SourceFile);
  except
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectID3v2(var Item: TPLItem): boolean;
var
  Tag: TagID3v2;
  FileSize, fVersion: integer;
begin
  Result := false;
  if Item.plCue then
    Exit;

  try
    ID3ReadHeader(Item.plFile, Tag);
    if (Tag.ID = ID3V2_ID) then
    begin
      Result := true;
      fVersion := Tag.Version;
      FileSize := ID3GetTagSize(Tag);
      if (fVersion in [TAG_VERSION_2_2 .. TAG_VERSION_2_4]) and (FileSize > 0)
      then
      begin
        if fVersion > TAG_VERSION_2_2 then
          ID3ReadFramesNew(Item.plFile, Tag)
        else
          ID3ReadFramesOld(Item.plFile, Tag);

        Item.plTitle := IFV(Tag.Frame[1], Tag.Frame[5]);
        Item.plArtist := IFV(Tag.Frame[2], Tag.Frame[4]);
        Item.plAlbum := IFV(Tag.Frame[9], Tag.Frame[10]);
        Item.plComment := ID3Text(Tag.Frame[8], true);
        Item.plGenre := ID3Genre(Tag.Frame[3]);
        Item.plYear := ID3Year(Tag.Frame[6], Tag.Frame[7]);
        Item.plSize := Tag.FileSize;
      end;
    end;
  except
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectID3v2(struct: Pointer; var Item: TPLItem): boolean;
var
  Tag: TagID3v2;
begin
  Result := false;
  if Item.plCue then
    Exit;

  try
    Move(Pointer(struct)^, Tag, 10);
    if Tag.ID = ID3V2_ID then
    begin
      Result := true;

      with TFileStream.Create(Item.plFile, fmOpenRead or fmShareDenyWrite) do
      begin
        Tag.FileSize := Size;
        Free;
      end;

      if (Tag.Version in [TAG_VERSION_2_2 .. TAG_VERSION_2_4]) and
        (ID3GetTagSize(Tag) > 0) then
      begin
        if Tag.Version > TAG_VERSION_2_2 then
          ID3ReadFramesNew2(struct, Tag)
        else
          ID3ReadFramesOld2(struct, Tag);

        Item.plTitle := IFV(Tag.Frame[1], Tag.Frame[5]);
        Item.plArtist := IFV(Tag.Frame[2], Tag.Frame[4]);
        Item.plAlbum := IFV(Tag.Frame[9], Tag.Frame[10]);
        Item.plComment := ID3Text(Tag.Frame[8], true);
        Item.plGenre := ID3Genre(Tag.Frame[3]);
        Item.plYear := ID3Year(Tag.Frame[6], Tag.Frame[7]);
        Item.plSize := Tag.FileSize;
      end;
    end;
  except
    Result := false;
  end;
end;

// .......................... REALIZATION (ID3v1) ........................... //

function DetectID3v1(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  TagData: TagID3;
  fVersion: Byte;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    FillChar(TagData, SizeOf(TagID3), 0);
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);
    SourceFile.Seek(SourceFile.Size - ID3V1_SIZE, soFromBeginning);
    SourceFile.Read(TagData, ID3V1_SIZE);

    if TagData.ID = ID3V1_ID then
    begin
      Result := true;
      if ((TagData.Comment[28] = #0) and (TagData.Comment[29] <> #0)) or
        ((TagData.Comment[28] = #32) and (TagData.Comment[29] <> #32)) then
        fVersion := TAG_VERSION_1_1
      else
        fVersion := TAG_VERSION_1_0;
      Item.plTitle := Trim(TagData.Title);
      Item.plArtist := Trim(TagData.Artist);
      Item.plAlbum := Trim(TagData.Album);
      Item.plYear := Trim(TagData.Year);
      if fVersion = TAG_VERSION_1_0 then
        Item.plComment := Trim(TagData.Comment)
      else
        Item.plComment := Trim(Copy(TagData.Comment, 1, 27));
      if TagData.Genre > 147 then
        TagData.Genre := 12;
      Item.plGenre := GENRE_TABLE[TagData.Genre];
      Item.plSize := SourceFile.Size;
    end;
    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectID3v1(struct: Pointer; var Item: TPLItem): boolean;
var
  Tag: PTagID3 absolute struct;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    if (assigned(Tag)) then
    begin
      if (Tag^.ID = ID3V1_ID) then
      begin
        Result := true;
        Item.plArtist := Trim(Tag^.Artist);
        Item.plTitle := Trim(Tag^.Title);
        Item.plAlbum := Trim(Tag^.Album);
        Item.plComment := Trim(Tag^.Comment);
        Item.plYear := Trim(Tag^.Year);
        if Tag^.Genre > 147 then
          Tag^.Genre := 12;
        Item.plGenre := GENRE_TABLE[Tag^.Genre];
      end;
    end;
  except
    Result := false;
  end;
end;

// ......................... REALIZATION (LYRICS 3) .......................... //

function DetectLyrics3(struct: string; var Item: TPLItem): boolean;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    if (assigned(Pointer(struct))) then
    begin
      Result := true;
      // Item.fLyrics := Trim(struct);
    end;
  except
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectLyrics3(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  TagData: TagID3;
  Mark: Lyr2Mark;
  iOffSet, Lyrics2Size, ib, ie: integer;
  aBuff11: array [0 .. 10] of AnsiChar;
  aBuff: array of AnsiChar;
begin
  Result := false;
  if Item.plCue then
    Exit;

  try
    FillChar(TagData, SizeOf(TagID3), 0);
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);
    SourceFile.Seek(SourceFile.Size - ID3V1_SIZE, soFromBeginning);
    SourceFile.Read(TagData, ID3V1_SIZE);

    iOffSet := 15;
    if TagData.ID = ID3V1_ID then
      inc(iOffSet, ID3V1_SIZE);
    ib := SourceFile.Size - (iOffSet);
    SourceFile.Seek(ib, soFromBeginning);
    SourceFile.Read(Mark, 15);

    if Mark.Mark = LYR_200 then
    begin
      Lyrics2Size := StrToInt(Mark.Size);
      if Lyrics2Size > 0 then
      begin
        ie := SourceFile.Size - (Lyrics2Size + iOffSet);
        SourceFile.Seek(ie, soFromBeginning);
        SourceFile.Read(aBuff11, 11);
        if aBuff11 = LYR_BEGIN then
        begin
          Result := true;
          SourceFile.Seek(ie, soFromBeginning);
          ie := (ib - ie) + 15;
          SetLength(aBuff, ie);
          if SourceFile.Read(aBuff[0], ie) > 0 then
          begin
            // Item.Lyrics := Trim(PAnsiChar(aBuff));
            // Item.Lyrics := Copy(Item.Lyrics, 37, Length(Item.Lyrics) - Lyrics2Size);
          end;
          SetLength(aBuff, 0);
        end;
      end;
    end;
    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

// ........................... REALIZATION (WMA) ............................ //

function WMAReadFieldString(const Source: TStream; DataSize: Word): string;
var
  Iterator, StringSize: integer;
  FieldData: array [1 .. WMA_MAX_STRING_SIZE * 2] of Byte;
begin
  Result := '';
  StringSize := DataSize div 2;
  if StringSize > WMA_MAX_STRING_SIZE then
    StringSize := WMA_MAX_STRING_SIZE;
  Source.ReadBuffer(FieldData, StringSize * 2);
  Source.Seek(DataSize - StringSize * 2, soFromCurrent);
  for Iterator := 1 to StringSize do
    Result := Result + Char(FieldData[Iterator * 2 - 1] +
      (FieldData[Iterator * 2] shl 8));
end;

{ --------------------------------------------------------------------------- }

procedure WMAReadTagStandard(const Source: TStream; var Tag: TagWMAData);
var
  Iterator: integer;
  FieldSize: array [1 .. 5] of Word;
  FieldValue: string;
begin
  Source.ReadBuffer(FieldSize, SizeOf(FieldSize));
  for Iterator := 1 to 5 do
  begin
    if FieldSize[Iterator] > 0 then
    begin
      FieldValue := WMAReadFieldString(Source, FieldSize[Iterator]);
      case Iterator of
        1:
          Tag[1] := FieldValue;
        2:
          Tag[2] := FieldValue;
        4:
          Tag[6] := FieldValue;
      end;
    end;
  end;
end;

{ --------------------------------------------------------------------------- }

procedure WMAReadTagExtended(const Source: TStream; var Tag: TagWMAData);
var
  Iterator1, Iterator2, FieldCount, DataSize, DataType: Word;
  FieldName, FieldValue: string;
begin
  Source.ReadBuffer(FieldCount, SizeOf(FieldCount));
  for Iterator1 := 1 to FieldCount do
  begin
    Source.ReadBuffer(DataSize, SizeOf(DataSize));
    FieldName := WMAReadFieldString(Source, DataSize);
    Source.ReadBuffer(DataType, SizeOf(DataType));
    if DataType = 0 then
    begin
      Source.ReadBuffer(DataSize, SizeOf(DataSize));
      FieldValue := WMAReadFieldString(Source, DataSize);
    end
    else
      Source.Seek(DataSize, soFromCurrent);
    for Iterator2 := 1 to FIELD_COUNT do
    begin
      if UpperCase(Trim(FieldName)) = WMA_FIELD_NAME[Iterator2] then
        Tag[Iterator2] := FieldValue;
    end;
  end;
end;

{ --------------------------------------------------------------------------- }

procedure WMAReadObject(const ID: WMAObjectID; Source: TStream;
  var Data: TagWMA);
begin
  if ID = WMA_FILE_PROPERTIES_ID then
  begin
    Source.Seek(80, soFromCurrent);
    Source.ReadBuffer(Data.MaxBitRate, SizeOf(Data.MaxBitRate));
  end;
  if ID = WMA_STREAM_PROPERTIES_ID then
  begin
    Source.Seek(60, soFromCurrent);
    Source.ReadBuffer(Data.Channels, SizeOf(Data.Channels));
    Source.ReadBuffer(Data.SampleRate, SizeOf(Data.SampleRate));
    Source.ReadBuffer(Data.ByteRate, SizeOf(Data.ByteRate));
  end;
  if ID = WMA_CONTENT_DESCRIPTION_ID then
  begin
    Source.Seek(4, soFromCurrent);
    WMAReadTagStandard(Source, Data.Tag);
  end;
  if ID = WMA_EXTENDED_CONTENT_DESCRIPTION_ID then
  begin
    Source.Seek(4, soFromCurrent);
    WMAReadTagExtended(Source, Data.Tag);
  end;
end;

{ --------------------------------------------------------------------------- }

function WMAReadData(const plFile: string; var Data: TagWMA): boolean;
var
  Source: TFileStream;
  ID: WMAObjectID;
  Iterator, ObjectCount, ObjectSize, Position: integer;
begin
  Result := false;
  FillChar(Data, SizeOf(Data), 0);
  try
    Source := TFileStream.Create(plFile, fmOpenRead or fmShareDenyWrite);
    Data.FileSize := Source.Size;
    Source.ReadBuffer(ID, SizeOf(ID));
    if ID = WMA_HEADER_ID then
    begin
      Result := true;
      Source.Seek(8, soFromCurrent);
      Source.ReadBuffer(ObjectCount, SizeOf(ObjectCount));
      Source.Seek(2, soFromCurrent);
      for Iterator := 1 to ObjectCount do
      begin
        Position := Source.Position;
        Source.ReadBuffer(ID, SizeOf(ID));
        Source.ReadBuffer(ObjectSize, SizeOf(ObjectSize));
        WMAReadObject(ID, Source, Data);
        Source.Seek(Position + ObjectSize, soFromBeginning);
      end;
    end;
    FreeAndNil(Source);
  except
    FreeAndNil(Source);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectWMA(var Item: TPLItem): boolean;
var
  Data: TagWMA;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    Result := true;
    if WMAReadData(Item.plFile, Data) then
    begin
      Item.plTitle := Trim(Data.Tag[1]);
      Item.plArtist := Trim(Data.Tag[2]);
      Item.plAlbum := Trim(Data.Tag[3]);
      Item.plYear := Trim(Data.Tag[4]);
      Item.plGenre := Trim(Data.Tag[5]);
      Item.plComment := Trim(Data.Tag[5]);
      Item.plSize := Data.FileSize;
      Item.plSampleRate := Data.SampleRate;
      Item.plDuration := Trunc(Data.FileSize * 8 / Data.MaxBitRate);
      Item.plBitrate := Data.ByteRate * 8 div 1000;
    end;
  except
    Result := false;
  end;
end;

// ............ REALIZATION (MO3, IT, XM, S3M, MTM, MOD, UMX) ............... //

function DetectTrack(struct: string; var Item: TPLItem): boolean;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    if assigned(Pointer(struct)) then
    begin
      Result := true;
      Item.plTitle := struct;
    end;
  except
    Result := false;
  end;
end;

// ........................... REALIZATION (WAV) ............................ //

function WAVReadHeader(const plFile: string; var Data: TagWAV): boolean;
var
  SrcFile: file;
begin
  try
    Result := true;
    AssignFile(SrcFile, plFile);
    FileMode := 0;
    Reset(SrcFile, 1);
    BlockRead(SrcFile, Data, 40);
    if Data.DataHeader <> WAV_CHUNK then
    begin
      Seek(SrcFile, Data.FormatSize + 28);
      BlockRead(SrcFile, Data.SampleNumber, 4);
    end;
    CloseFile(SrcFile);
  except
    CloseFile(SrcFile);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectWAV(var Item: TPLItem): boolean;
var
  Data: TagWAV;
  SampleRate, fBytesPerSecond, fSampleNumber, fFileSize, fHeaderSize: integer;

  function GetDuration: Double;
  begin
    Result := 0;
    if (fSampleNumber = 0) and (fBytesPerSecond > 0) then
      Result := (fFileSize - fHeaderSize) / fBytesPerSecond;
    if (fSampleNumber > 0) and (SampleRate > 0) then
      Result := fSampleNumber / SampleRate;
  end;

begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    FillChar(Data, SizeOf(TagWAV), 0);
    if (WAVReadHeader(Item.plFile, Data)) then
    begin
      Result := true;
      SampleRate := Data.SampleRate;
      fBytesPerSecond := Data.BytesPerSecond;
      fSampleNumber := Data.SampleNumber;
      if Data.DataHeader = WAV_CHUNK then
        fHeaderSize := 44
      else
        fHeaderSize := Data.FormatSize + 40;
      fFileSize := Data.FileSize + 8;
      if fHeaderSize > fFileSize then
        fHeaderSize := fFileSize;
      Item.plSampleRate := Data.SampleRate;
      Item.plSize := fFileSize;
      Item.plDuration := Trunc(GetDuration);
    end;
  except
    Result := false;
  end;
end;

// ........................... REALIZATION (AC3) ............................ //

function DetectAC3(var Item: TPLItem): boolean;
var
  SrcFile: TFileStream;
  Sign: Word;
  AByte: Byte;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    SrcFile := TFileStream.Create(Item.plFile, fmOpenRead or fmShareDenyWrite);
    SrcFile.Read(Sign, SizeOf(Sign));
    if (Sign = AC3_ID) then
    begin
      Result := true;
      FillChar(AByte, SizeOf(AByte), 0);
      SrcFile.Seek(2, soFromCurrent);
      SrcFile.Read(AByte, SizeOf(AByte));
      Item.plSize := SrcFile.Size;

      case (AByte and $C0) of
        0:
          Item.plSampleRate := 48000;
        $40:
          Item.plSampleRate := 44100;
        $80:
          Item.plSampleRate := 32000;
      end;
      Item.plBitrate := AC3_BIRATES[(AByte and $3F) shr 1];

      FillChar(AByte, SizeOf(AByte), 0);
      SrcFile.Seek(1, soFromCurrent);
      SrcFile.Read(AByte, SizeOf(AByte));
      Item.plDuration := Trunc(Item.plSize * 8 / 1000 / Item.plBitrate);
    end;
    FreeAndNil(SrcFile);
  except
    FreeAndNil(SrcFile);
    Result := false;
  end;
end;

// ........................... REALIZATION (APE) ............................ //

function APEReadFooter(const plFile: string; var Tag: TagAPE): boolean;
var
  SourceFile: file;
  TagID: array [1 .. 3] of AnsiChar;
  Transferred: integer;
begin
  { Load footer from file to variable }
  try
    Result := true;
    { Set read-access and open file }
    AssignFile(SourceFile, plFile);
    FileMode := 0;
    Reset(SourceFile, 1);
    Tag.FileSize := FileSize(SourceFile);
    { Check for existing ID3v1 tag }
    Seek(SourceFile, Tag.FileSize - ID3V1_SIZE);
    BlockRead(SourceFile, TagID, SizeOf(TagID));
    if TagID = ID3V1_ID then
      Tag.DataShift := ID3V1_SIZE;
    { Read footer data }
    Seek(SourceFile, Tag.FileSize - Tag.DataShift - APE_TAG_FOOTER_SIZE);
    BlockRead(SourceFile, Tag, APE_TAG_FOOTER_SIZE, Transferred);
    CloseFile(SourceFile);
    { if transfer is not complete }
    if Transferred < APE_TAG_FOOTER_SIZE then
      Result := false;
  except
    CloseFile(SourceFile);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

procedure APESetTagItem(const FieldName, FieldValue: string; var Tag: TagAPE);
var
  Iterator: Byte;
begin
  { Set tag item if supported field found }
  for Iterator := 1 to FIELD_COUNT do
  begin
    if UpperCase(FieldName) = FIELD_NAMES[Iterator] then
    begin
      if Tag.Version > APE_VERSION_1_0 then
        Tag.Field[Iterator] := GetANSI(FieldValue)
      else
        Tag.Field[Iterator] := FieldValue;
    end;
  end;
end;

{ --------------------------------------------------------------------------- }

procedure APEReadFields(const plFile: string; var Tag: TagAPE);
var
  SourceFile: file;
  FieldName: string;
  FieldValue: array [1 .. 250] of AnsiChar;
  NextChar: AnsiChar;
  Iterator, ValueSize, ValuePosition, FieldFlags: integer;
begin
  try
    { Set read-access, open file }
    AssignFile(SourceFile, plFile);
    FileMode := 0;
    Reset(SourceFile, 1);
    Seek(SourceFile, Tag.FileSize - Tag.DataShift - Tag.Size);
    { Read all stored fields }
    for Iterator := 1 to Tag.Fields do
    begin
      FillChar(FieldValue, SizeOf(FieldValue), 0);
      BlockRead(SourceFile, ValueSize, SizeOf(ValueSize));
      BlockRead(SourceFile, FieldFlags, SizeOf(FieldFlags));
      FieldName := '';
      repeat
        BlockRead(SourceFile, NextChar, SizeOf(NextChar));
        FieldName := FieldName + NextChar;
      until Ord(NextChar) = 0;
      ValuePosition := FilePos(SourceFile);
      BlockRead(SourceFile, FieldValue, ValueSize mod SizeOf(FieldValue));
      APESetTagItem(Trim(FieldName), Trim(FieldValue), Tag);
      Seek(SourceFile, ValuePosition + ValueSize);
    end;
    CloseFile(SourceFile);
  except
    CloseFile(SourceFile);
  end;
end;

{ --------------------------------------------------------------------------- }

function APEGetTrack(const TrackString: string): Byte;
var
  Index, Value, Code: integer;
begin
  { Get track from string }
  Index := Pos('/', TrackString);
  if Index = 0 then
    Val(TrackString, Value, Code)
  else
    Val(Copy(TrackString, 1, Index - 1), Value, Code);
  if Code = 0 then
    Result := Value
  else
    Result := 0;
end;

{ --------------------------------------------------------------------------- }

function DetectAPE(var Item: TPLItem): boolean;
var
  Tag: TagAPE;
begin
  { Reset data and load footer from file to variable }
  Result := false;
  if Item.plCue then
    Exit;

  try
    FillChar(Tag, SizeOf(Tag), 0);
    Result := APEReadFooter(Item.plFile, Tag) and (Tag.ID = APE_ID);
    { Process data if loaded and footer valid }
    if (Result) then
    begin
      { Fill properties with footer data }
      Item.plSize := Tag.FileSize;
      { Get information from fields }
      APEReadFields(Item.plFile, Tag);
      Item.plTitle := Tag.Field[1];
      Item.plArtist := Tag.Field[2];
      Item.plAlbum := Tag.Field[3];
      Item.plYear := Tag.Field[4];
      Item.plGenre := Tag.Field[5];
      Item.plComment := Tag.Field[6];
    end;
  except
    Result := false;
  end;
end;

// ........................... REALIZATION (AAC) ............................ //

function AACReadBits(Source: TFileStream; Position, Count: integer): integer;
var
  Buffer: array [1 .. 4] of Byte;
begin
  { Read a number of bits from file at the given position }
  Source.Seek(Position div 8, soFromBeginning);
  Source.Read(Buffer, SizeOf(Buffer));
  Result := Buffer[1] * $1000000 + Buffer[2] * $10000 + Buffer[3] * $100 +
    Buffer[4];
  Result := (Result shl (Position mod 8)) shr (32 - Count);
end;

{ --------------------------------------------------------------------------- }

function AACRecognizeHeaderType(const Source: TFileStream): Byte;
var
  Header: array [1 .. 4] of Char;
begin
  { Get header type of the file }
  Result := AAC_HEADER_TYPE_UNKNOWN;
  Source.Seek(GetID3v2Size(Source), soFromBeginning);
  Source.Read(Header, SizeOf(Header));
  if Header[1] + Header[2] + Header[3] + Header[4] = ADIF_ID then
    Result := AAC_HEADER_TYPE_ADIF
  else if (Byte(Header[1]) = $FF) and (Byte(Header[1]) and $F0 = $F0) then
    Result := AAC_HEADER_TYPE_ADTS;
end;

{ --------------------------------------------------------------------------- }

procedure AACReadADIF(const Source: TFileStream; var Item: TPLItem);
var
  Position, FBitRateTypeID: integer;
begin
  { Read ADIF header data }
  Position := GetID3v2Size(Source) * 8 + 32;
  if AACReadBits(Source, Position, 1) = 0 then
    inc(Position, 3)
  else
    inc(Position, 75);
  if AACReadBits(Source, Position, 1) = 0 then
    FBitRateTypeID := AAC_BITRATE_TYPE_CBR
  else
    FBitRateTypeID := AAC_BITRATE_TYPE_VBR;
  inc(Position, 1);
  Item.plBitrate := AACReadBits(Source, Position, 23);
  if FBitRateTypeID = AAC_BITRATE_TYPE_CBR then
    inc(Position, 51)
  else
    inc(Position, 31);
  inc(Position, 2);
  Item.plSampleRate := AACSAMPLE_RATE[AACReadBits(Source, Position, 4)];
end;

{ --------------------------------------------------------------------------- }

procedure AACReadADTS(const Source: TFileStream; var Item: TPLItem);
var
  Frames, TotalSize, TagSize, Position, FMPEGVersionID, f: integer;
begin
  { Read ADTS header data }
  Frames := 0;
  TotalSize := 0;
  TagSize := GetID3v2Size(Source);

  repeat
    inc(Frames);
    Position := (TagSize + TotalSize) * 8;
    if AACReadBits(Source, Position, 12) <> $FFF then
      Break;
    inc(Position, 12);
    if AACReadBits(Source, Position, 1) = 0 then
      FMPEGVersionID := AAC_MPEG_VERSION_4
    else
      FMPEGVersionID := AAC_MPEG_VERSION_2;
    inc(Position, 6);
    Item.plSampleRate := AACSAMPLE_RATE[AACReadBits(Source, Position, 4)];
    inc(Position, 5);
    if FMPEGVersionID = AAC_MPEG_VERSION_4 then
      inc(Position, 9)
    else
      inc(Position, 7);
    inc(TotalSize, AACReadBits(Source, Position, 13));
    inc(Position, 13);
    if AACReadBits(Source, Position, 11) <> $7FF then
      Break;
  until Source.Size <= TotalSize + TagSize;

  Item.plBitrate := Trunc((8 * TotalSize / 1024 / Frames * Item.plSampleRate));
  if Item.plBitrate > 999 then
    Item.plBitrate := Trunc(Item.plBitrate / 1000);
end;
{ --------------------------------------------------------------------------- }

function DetectAAC(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  FHeaderTypeID: integer;
begin
  { Read data from file }
  Result := false;
  if Item.plCue then
    Exit;

  { At first search for tags, then try to recognize header type }
  try
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);
    Item.plSize := SourceFile.Size;
    FHeaderTypeID := AACRecognizeHeaderType(SourceFile);
    { Read header data }
    Result := true;
    case FHeaderTypeID of
      AAC_HEADER_TYPE_ADIF:
        AACReadADIF(SourceFile, Item);
      AAC_HEADER_TYPE_ADTS:
        AACReadADTS(SourceFile, Item);
    else
      Result := false;
    end;
    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

// .......................... REALIZATION (FLAC) ............................ //

procedure FLACReadTag(Source: TFileStream; var Item: TPLItem;
  out CueSheet: string);
var
  i, iCount, iSize, iSepPos: integer;
  Data: PAnsiChar;
  sFieldID, sFieldData: Ansistring;
begin
  Source.Read(iSize, SizeOf(iSize)); // vendor
  Data := AllocMem(iSize);
  try
    Source.Read(Data[0], iSize);
  finally
    FreeMem(Data, iSize);
  end;

  Source.Read(iCount, SizeOf(iCount)); // fieldcount

  for i := 0 to iCount - 1 do
  begin
    Source.Read(iSize, SizeOf(iSize));
    Data := AllocMem(iSize);
    try
      Source.Read(Data[0], iSize);

      iSepPos := AnsiPos('=', Ansistring(Data));
      if iSepPos > 0 then
      begin
        sFieldID := UpperCase(Copy(String(Data), 1, iSepPos - 1));
        sFieldData := GetANSI(Copy(String(Data), iSepPos + 1, MaxInt));

        if (sFieldID = FIELD_NAMES[2]) then
          Item.plArtist := sFieldData
        else if (sFieldID = FIELD_NAMES[3]) then
          Item.plAlbum := sFieldData
        else if (sFieldID = FIELD_NAMES[1]) then
          Item.plTitle := sFieldData
        else if (sFieldID = FIELD_NAMES[4]) then
          Item.plYear := sFieldData
        else if (sFieldID = FIELD_NAMES[5]) then
          Item.plGenre := sFieldData
        else if (sFieldID = FIELD_NAMES[6]) then
          Item.plComment := sFieldData
        else if (sFieldID = FIELD_NAMES[9]) then
        begin
          CueSheet := sFieldData;
          Item.plCue := true;
        end;

      end;
    finally
      FreeMem(Data, iSize);
    end;
  end;
end;
{ --------------------------------------------------------------------------- }

function DetectFLAC(var Item: TPLItem; out CueSheetData: string): boolean;
var
  SourceFile: TFileStream;
  Header: TagFLAC;
  bType: Byte;
  Info: FLAC_StreamInfo;
  GetLastFlag: boolean;
  BlockDataSize, Samples: integer;
  CurPos, NextPos, BlockSize: Int64;
  FileID: TFileID;
begin
  { Get info from file }
  Result := false;

  if Item.plCue then
    Exit;

  try
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);
    Item.plSize := SourceFile.Size;

    SourceFile.Read(FileID, 4);

    if FileID = FLAC_ID then
    begin
      GetLastFlag := false;
      repeat
        CurPos := SourceFile.Position;

        SourceFile.Read(Header, SizeOf(Header));
        if Header.BlockType > 127 then // MSB = 1 ?
        begin
          GetLastFlag := true;
          bType := Header.BlockType and $7F; // strip off MSB
        end
        else
          bType := Header.BlockType;

        BlockDataSize := Header.BlockSize[1] shl 16 + Header.BlockSize[2] shl 8
          + Header.BlockSize[3];
        NextPos := SourceFile.Position + BlockDataSize;

        case bType of
          FLAC_STREAM_INFO:
            begin
              SourceFile.Read(Info, SizeOf(Info));

              Item.plSampleRate := Info.SampleRate[1] * 4096 + Info.SampleRate
                [2] * 16 + Info.SampleRate[3] shr 4;
              Samples := (Info.TotalSamples[1] and $0F) shl 32 +
                (Info.TotalSamples[2] shl 24) + (Info.TotalSamples[3] shl 16) +
                (Info.TotalSamples[4] shl 8) + Info.TotalSamples[5];
            end;

          FLAC_VORBIS_COMMENT:
            FLACReadTag(SourceFile, Item, CueSheetData);
        end;

        if not GetLastFlag then
          SourceFile.Seek(NextPos, soFromBeginning);
      until GetLastFlag;

      if Item.plSampleRate > 0 then
        Item.plDuration := Trunc(Samples / Item.plSampleRate);

      if (Item.plDuration > 0) then
        Item.plBitrate := Trunc((SourceFile.Size - (CurPos + (NextPos - CurPos))
          ) / Item.plDuration / 125);

      Result := true;
    end;

    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;
// ......................... REALIZATION (VORBIS) .......................... //

procedure VorbisSetTagItem(const Data: string; var Info: VorbisFileInfo);
var
  Separator, Index: integer;
  FieldID, FieldData: string;
begin
  { Set Vorbis tag item if supported comment field found }
  Separator := Pos('=', Data);
  if Separator > 0 then
  begin
    FieldID := UpperCase(Copy(Data, 1, Separator - 1));
    FieldData := Copy(Data, Separator + 1, Length(Data) - Length(FieldID));
    for Index := 1 to FIELD_COUNT do
      if FIELD_NAMES[Index] = FieldID then
        Info.Tag.FieldData[Index] := GetANSI(Trim(FieldData));
  end
  else if Info.Tag.FieldData[0] = '' then
    Info.Tag.FieldData[0] := Data;
end;

{ --------------------------------------------------------------------------- }

procedure OGGReadTag(const Source: TFileStream; var Info: VorbisFileInfo);
var
  Index, Size, Position: integer;
  Data: array [1 .. 250] of AnsiChar;
begin
  { Read Vorbis tag }
  Index := 0;
  repeat
    FillChar(Data, SizeOf(Data), 0);
    Source.Read(Size, SizeOf(Size));
    Position := Source.Position;
    if Size > SizeOf(Data) then
      Source.Read(Data, SizeOf(Data))
    else
      Source.Read(Data, Size);
    { Set Vorbis tag item }
    VorbisSetTagItem(Trim(Data), Info);
    Source.Seek(Position + Size, soFromBeginning);
    if Index = 0 then
      Source.Read(Info.Tag.Fields, SizeOf(Info.Tag.Fields));
    inc(Index);
  until Index > Info.Tag.Fields;
  Info.TagEndPos := Source.Position;
end;

{ --------------------------------------------------------------------------- }

function VorbisGetSamples(const Source: TFileStream): integer;
var
  Index, DataIndex, Iterator: integer;
  Data: array [0 .. 250] of AnsiChar;
  Header: TagOGG;
begin
  { Get total number of samples }
  Result := 0;
  for Index := 1 to 50 do
  begin
    DataIndex := Source.Size - (SizeOf(Data) - 10) * Index - 10;
    Source.Seek(DataIndex, soFromBeginning);
    Source.Read(Data, SizeOf(Data));
    { Get number of PCM samples from last Ogg packet header }
    for Iterator := SizeOf(Data) - 10 downto 0 do
      if Data[Iterator] + Data[Iterator + 1] + Data[Iterator + 2] +
        Data[Iterator + 3] = OGG_ID then
      begin
        Source.Seek(DataIndex + Iterator, soFromBeginning);
        Source.Read(Header, SizeOf(Header));
        Result := Header.AbsolutePosition;
        Exit;
      end;
  end;
end;

{ --------------------------------------------------------------------------- }

function GetLacingSize(const Buff: array of Byte; Size: Byte;
  var Last: boolean): integer;
var
  i: integer;
begin
  Result := 0;
  Last := false;
  for i := 0 to Size - 1 do
  begin
    Result := Result + Buff[i];
    if Buff[i] < $FF then
    begin
      Last := true;
      Break;
    end;
  end;
end;

{ --------------------------------------------------------------------------- }

function SpeexGetInfo(const plFile: string; var Info: VorbisFileInfo): boolean;
var
  SourceFile: TFileStream;
  Data: PAnsiChar;
  Last: boolean;
  Size: integer;
begin
  { Get info from file }
  Result := false;
  SourceFile := nil;

  Data := nil;
  try
    SourceFile := TFileStream.Create(plFile, fmOpenRead or fmShareDenyWrite);
    Info.FileSize := SourceFile.Size;

    { First Page }
    SourceFile.Read(Info.FPage, OGG_HEADER_SIZE);
    if Info.FPage.ID <> OGG_ID then
      Exit;
    SourceFile.Read(Info.FPage.LacingValues, Info.FPage.Segments);
    Size := GetLacingSize(Info.FPage.LacingValues, Info.FPage.Segments, Last);

    GetMem(Data, Size);
    SourceFile.Read(Data^, Size);

    { Read Vorbis or SPEEX parameter header }
    if AnsiStrLComp(PAnsiChar(VORBIS_PARAMETERS_ID), Data,
      Length(VORBIS_PARAMETERS_ID)) = 0 then
    begin
      Info.isOggVorbis := true;
      Move(Data^, Info.VorbisParameters, SizeOf(Info.VorbisParameters));
    end
    else if AnsiStrLComp(PAnsiChar(SPEEX_PARAMETERS_ID), Data,
      Length(SPEEX_PARAMETERS_ID)) = 0 then
    begin
      Info.isSpeex := true;
      Move(Data^, Info.SpeexParameters, SizeOf(Info.SpeexParameters));
    end
    else
      Exit;

    Info.SPagePos := SourceFile.Position;
    { Second Page }
    SourceFile.Read(Info.SPage, OGG_HEADER_SIZE);
    SourceFile.Read(Info.SPage.LacingValues, Info.SPage.Segments);
    Size := GetLacingSize(Info.SPage.LacingValues, Info.SPage.Segments, Last);

    Info.VorbisPages := 1;
    Info.LPage.PageNumber := Info.SPage.PageNumber;
    // may span one or more pages, 10 is just a realistic limit
    while (not Last) and (Info.LPage.PageNumber < 10) do
    begin
      SourceFile.Read(Info.LPage, OGG_HEADER_SIZE);
      SourceFile.Read(Info.LPage.LacingValues, Info.LPage.Segments);
      Size := GetLacingSize(Info.LPage.LacingValues, Info.LPage.Segments, Last);

      inc(Info.VorbisPages);
    end;
    Info.TagEndPos := SourceFile.Position;

    { Get total number of samples }
    Info.Samples := VorbisGetSamples(SourceFile);

    Result := true;
  finally
    FreeAndNil(SourceFile);
    FreeMem(Data);
  end;
end;

{ --------------------------------------------------------------------------- }

function OGGGetInfo(const plFile: string; var Info: VorbisFileInfo): boolean;
var
  SourceFile: TFileStream;
begin
  { Get info from file }
  Result := false;
  SourceFile := nil;
  try
    SourceFile := TFileStream.Create(plFile, fmOpenRead or fmShareDenyWrite);
    Info.FileSize := SourceFile.Size;
    Info.ID3v2Size := GetID3v2Size(SourceFile);
    SourceFile.Seek(Info.ID3v2Size, soFromBeginning);
    SourceFile.Read(Info.FPage, SizeOf(Info.FPage));
    if Info.FPage.ID <> OGG_ID then
      Exit;
    SourceFile.Seek(Info.ID3v2Size + Info.FPage.Segments + OGG_HEADER_SIZE,
      soFromBeginning);

    { Read Vorbis parameter header }
    SourceFile.Read(Info.VorbisParameters, SizeOf(Info.VorbisParameters));
    if Info.VorbisParameters.ID <> VORBIS_PARAMETERS_ID then
      Exit;
    Info.SPagePos := SourceFile.Position;
    SourceFile.Read(Info.SPage, SizeOf(Info.SPage));
    SourceFile.Seek(Info.SPagePos + Info.SPage.Segments + OGG_HEADER_SIZE,
      soFromBeginning);
    SourceFile.Read(Info.Tag.ID, SizeOf(Info.Tag.ID));

    { Read Vorbis tag }
    if Info.Tag.ID = VORBIS_TAG_ID then
      OGGReadTag(SourceFile, Info);
    { Get total number of samples }
    Info.Samples := VorbisGetSamples(SourceFile);
    Result := true;
  finally
    FreeAndNil(SourceFile);
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectOGG(var Item: TPLItem): boolean;
var
  Info: VorbisFileInfo;
begin
  { Read data from file }
  Result := false;
  if Item.plCue then
    Exit;

  try
    FillChar(Info, SizeOf(Info), 0);
    if OGGGetInfo(Item.plFile, Info) then
    begin
      { Fill variables }
      Item.plSize := Info.FileSize;
      Item.plSampleRate := Info.VorbisParameters.SampleRate;
      Item.plTitle := Info.Tag.FieldData[1];
      if Info.Tag.FieldData[2] <> '' then
        Item.plArtist := Info.Tag.FieldData[2]
      else
        Item.plArtist := Info.Tag.FieldData[7];
      Item.plAlbum := Info.Tag.FieldData[3];
      Item.plYear := Info.Tag.FieldData[4];
      Item.plGenre := Info.Tag.FieldData[5];
      if Info.Tag.FieldData[7] <> '' then
        Item.plComment := Info.Tag.FieldData[6]
      else
        Item.plComment := Info.Tag.FieldData[8];

      if Info.Samples > 0 then
      begin
        if Item.plSampleRate > 0 then
          Item.plDuration := Trunc(Info.Samples / Item.plSampleRate);
      end
      else if (Info.VorbisParameters.BitRateNominal div 1000 > 0) and
        (Info.VorbisParameters.ChannelMode > 0) then
        Item.plDuration := Trunc((Item.plSize - Info.ID3v2Size) /
          (Info.VorbisParameters.BitRateNominal div 1000) /
          Info.VorbisParameters.ChannelMode / 125 * 2);

      if Item.plDuration > 0 then
        Item.plBitrate := Trunc((Item.plSize - Info.ID3v2Size) /
          Item.plDuration / 125);

      Result := true;
    end;
  except
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectSPX(var Item: TPLItem): boolean;
var
  Info: VorbisFileInfo;
  nCh: integer;
begin
  { Read data from file }
  Result := false;
  if Item.plCue then
    Exit;

  try
    FillChar(Info, SizeOf(Info), 0);

    nCh := 0;
    if SpeexGetInfo(Item.plFile, Info) then
    begin
      { Fill variables }
      Item.plSize := Info.FileSize;
      if Info.isOggVorbis then
      begin
        Item.plSampleRate := Info.VorbisParameters.SampleRate;
        nCh := Info.VorbisParameters.ChannelMode;
      end
      else if Info.isSpeex then
      begin
        Item.plSampleRate := Info.SpeexParameters.Rate;
        nCh := Info.SpeexParameters.Channels;
      end;

      if Info.Samples > 0 then
      begin
        if Item.plSampleRate > 0 then
          Item.plDuration := Trunc(Info.Samples / Item.plSampleRate);
      end
      else if (Info.VorbisParameters.BitRateNominal div 1000 > 0) and (nCh > 0)
      then
        Item.plDuration :=
          Trunc(Item.plSize / (Info.VorbisParameters.BitRateNominal div 1000) /
          nCh / 125 * 2);

      if Item.plDuration > 0 then
        Item.plBitrate := Trunc(Item.plSize / Item.plDuration / 125);

      Result := true;
    end;
  except
    Result := false;
  end;
end;

// ........................... REALIZATION (MAC) ............................ //

function DetectMAC(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  APE: TagMAC; // common header
  APE_OLD: TagMAC_OLD; // old header   <= 3.97
  APE_NEW: TagMAC_NEW; // new header   >= 3.98
  APE_DESC: MAC_DESCRIPTOR; // extra header >= 3.98
  BlocksPerFrame, TagSize, TagID3Size, fVersion, FTotalSamples: integer;
  ApeTag: TagAPE;
begin
  Result := false;
  if Item.plCue then
    Exit;

  try
    // calculate total tag size
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);

    TagSize := 0;

    if DetectID3v1(Item) then
      inc(TagSize, 128);

    if DetectID3v2(Item) then
    begin
      TagID3Size := GetID3v2Size(SourceFile);
      inc(TagSize, TagID3Size);
    end;

    if DetectAPE(Item) then
    begin
      if APEReadFooter(Item.plFile, ApeTag) then
        inc(TagSize, ApeTag.Size);
    end;

    Item.plSize := SourceFile.Size;
    // seek past id3v2-tag
    if TagID3Size > 0 then
      SourceFile.Seek(TagID3Size, soFromBeginning);

    // Read APE Format Header
    FillChar(APE, SizeOf(APE), 0);
    if (SourceFile.Read(APE, SizeOf(APE)) = SizeOf(APE)) and
      (StrLComp(@APE.cID[0], MAC_ID, 4) = 0) then
    begin
      fVersion := APE.nVersion;

      // Load New Monkey's Audio Header for version >= 3.98
      if APE.nVersion >= 3980 then
      begin
        FillChar(APE_DESC, SizeOf(APE_DESC), 0);
        if (SourceFile.Read(APE_DESC, SizeOf(APE_DESC)) = SizeOf(APE_DESC)) then
        begin
          // seek past description header
          if APE_DESC.nDescriptorBytes <> 52 then
            SourceFile.Seek(APE_DESC.nDescriptorBytes - 52, soFromCurrent);
          // load new ape_header
          if APE_DESC.nHeaderBytes > SizeOf(APE_NEW) then
            APE_DESC.nHeaderBytes := SizeOf(APE_NEW);
          FillChar(APE_NEW, SizeOf(APE_NEW), 0);
          if (longword(SourceFile.Read(APE_NEW, APE_DESC.nHeaderBytes))
            = APE_DESC.nHeaderBytes) then
          begin
            // based on MAC SDK 3.98a1 (APEinfo.h)
            Item.plSampleRate := APE_NEW.nSampleRate;

            if (fVersion >= 3950) then
              BlocksPerFrame := 73728 * 4
            else if (fVersion >= 3900) or
              ((fVersion >= 3800) and (APE_OLD.nCompressionLevel = 4000)) then
              BlocksPerFrame := 73728
            else
              BlocksPerFrame := 9216;

            // calculate total uncompressed samples
            if APE_NEW.nTotalFrames > 0 then
              FTotalSamples := Int64(APE_NEW.nBlocksPerFrame) *
                Int64(APE_NEW.nTotalFrames - 1) +
                Int64(APE_NEW.nFinalFrameBlocks);

            Result := true;
          end;
        end;
      end
      else
      begin
        // Old Monkey <= 3.97
        FillChar(APE_OLD, SizeOf(APE_OLD), 0);
        if (SourceFile.Read(APE_OLD, SizeOf(APE_OLD)) = SizeOf(APE_OLD)) then
        begin
          Item.plSampleRate := APE_OLD.nSampleRate;

          // calculate total uncompressed samples
          if APE_OLD.nTotalFrames > 0 then
            FTotalSamples := Int64(APE_OLD.nTotalFrames - 1) *
              Int64(BlocksPerFrame) + Int64(APE_OLD.nFinalFrameBlocks);

          Result := true;
        end;
      end;

      // length
      if Item.plSampleRate > 0 then
        Item.plDuration := Trunc(FTotalSamples / Item.plSampleRate);
      // average bitrate
      if Item.plDuration > 0 then
        Item.plBitrate := Trunc((Item.plSize - Int64(TagSize)) * 8.0 /
          (Item.plDuration / 1000.0));
    end;
    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

// ........................... REALIZATION (TTA) ............................ //

function DetectTTA(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  SignatureChunk: array [0 .. 3] of AnsiChar;
  TTAHeader: TagTTA;
  TagSize, TagID3Size: Int64;
  ApeTag: TagAPE;
begin
  Result := false;
  if Item.plCue then
    Exit;

  try
    // calculate total tag size
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);

    TagSize := 0;

    if DetectID3v1(Item) then
      inc(TagSize, 128);
    TagID3Size := GetID3v2Size(SourceFile);
    inc(TagSize, TagID3Size);
    if APEReadFooter(Item.plFile, ApeTag) then
      inc(TagSize, ApeTag.Size);

    Item.plSize := SourceFile.Size;
    // seek past id3v2-tag
    if TagID3Size > 0 then
      SourceFile.Seek(TagID3Size, soFromBeginning);

    if (SourceFile.Read(SignatureChunk, SizeOf(SignatureChunk))
      = SizeOf(SignatureChunk)) and (StrLComp(SignatureChunk, TTA_ID, 4) = 0)
    then
    begin
      // start looking for chunks
      FillChar(TTAHeader, SizeOf(TTAHeader), 0);
      SourceFile.Read(TTAHeader, SizeOf(TTAHeader));

      Item.plSize := SourceFile.Size;

      Item.plSampleRate := TTAHeader.SampleRate;
      Item.plBitrate :=
        Trunc(Item.plSize * 8 / (TTAHeader.DataLength /
        Item.plSampleRate) / 1000);
      Item.plDuration := Trunc(TTAHeader.DataLength / TTAHeader.SampleRate);

      Result := true;
    end;

    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

// ........................... REALIZATION (WV) ............................. //

function WV_ReadV3(f: TFileStream; const TagSize: integer;
  var Item: TPLItem): boolean;
var
  chunk: RIFF_Chunk;
  wavchunk: array [0 .. 3] of AnsiChar;
  fmt: Fmt_Chunk;
  hasfmt: boolean;
  fpos: Int64;
  wvh3: TagWAVPack_3;
begin

  Result := false;
  hasfmt := false;

  // read and evaluate header
  FillChar(chunk, SizeOf(chunk), 0);
  if (f.Read(chunk, SizeOf(chunk)) <> SizeOf(chunk)) or
    (f.Read(wavchunk, SizeOf(wavchunk)) <> SizeOf(wavchunk)) or
    (wavchunk <> WAV_WAVE_ID) then
    Exit;

  // start looking for chunks
  FillChar(chunk, SizeOf(chunk), 0);
  while (f.Position < f.Size) do
  begin
    if (f.Read(chunk, SizeOf(chunk)) < SizeOf(chunk)) or (chunk.Size <= 0) then
      Break;

    fpos := f.Position;

    if chunk.ID = WAV_FMT_ID then
    begin // Format chunk found read it
      if (chunk.Size >= SizeOf(fmt)) and (f.Read(fmt, SizeOf(fmt)) = SizeOf(fmt))
      then
      begin
        hasfmt := true;
        Result := true;
        Item.plSampleRate := fmt.dwSamplesPerSec;
        Item.plBitrate := Trunc(fmt.dwBytesPerSec / 125.0); // 125 = 1/8*1000
      end
      else
        Break;
    end;

    if (chunk.ID = WAV_CHUNK) and hasfmt then
    begin
      FillChar(wvh3, SizeOf(wvh3), 0);
      f.Read(wvh3, SizeOf(wvh3));
      if wvh3.ckID = WAV_PACK_ID then
      begin // wavpack header found
        Result := true;

        if Item.plSampleRate <= 0 then
          Item.plSampleRate := 44100;
        Item.plDuration := Trunc(wvh3.TotalSamples / Item.plSampleRate);
        if Item.plDuration > 0 then
          Item.plBitrate :=
            Trunc(8.0 * (Item.plSize - Int64(TagSize) - Int64(wvh3.ckSize)) /
            (Item.plDuration * 1000.0));
      end;
      Break;
    end
    else // not a wv file
      Break;

    f.Seek(fpos + chunk.Size, soFromBeginning);
  end; // while
end;

{ --------------------------------------------------------------------------- }

function WV_ReadV4(f: TFileStream; const TagSize: integer;
  var Item: TPLItem): boolean;
var
  wvh4: TagWAVPack_4;
begin
  Result := false;
  FillChar(wvh4, SizeOf(wvh4), 0);
  f.Read(wvh4, SizeOf(wvh4));
  if wvh4.ckID = WAV_PACK_ID then
  // wavpack header found
  begin
    Result := true;
    Item.plSampleRate := (wvh4.Flags and ($1F shl 23)) shr 23;
    if (Item.plSampleRate > 14) or (Item.plSampleRate < 0) then
      Item.plSampleRate := 44100
    else
      Item.plSampleRate := SampleRates[Item.plSampleRate];

    Item.plDuration := Trunc(wvh4.TotalSamples / Item.plSampleRate);
    if Item.plDuration > 0 then
      Item.plBitrate := Trunc((Item.plSize - Int64(TagSize)) * 8 /
        (wvh4.TotalSamples / Item.plSampleRate) / 1000);
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectWV(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  marker: array [0 .. 3] of AnsiChar;
  ApeTag: TagAPE;
  TagSize: integer;
begin
  Result := false;
  if Item.plCue then
    Exit;

  TagSize := 0;
  if APEReadFooter(Item.plFile, ApeTag) then
    TagSize := ApeTag.Size;

  try
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);
    Item.plSize := SourceFile.Size;

    // read first bytes
    FillChar(marker, SizeOf(marker), 0);
    SourceFile.Read(marker, SizeOf(marker));
    SourceFile.Seek(0, soFromBeginning);

    if marker = WAV_RIFF_ID then
      Result := WV_ReadV3(SourceFile, TagSize, Item)
    else if marker = WAV_PACK_ID then
      Result := WV_ReadV4(SourceFile, TagSize, Item);

    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

// ....................... REALIZATION (MPEG Plus) .......................... //

function MPPReadHeader(const plFile: string; var Header: TagMPPlus): boolean;
var
  SourceFile: TFileStream;
  Transferred: integer;
begin
  try
    Result := true;
    { Set read-access and open file }
    SourceFile := TFileStream.Create(plFile, fmOpenRead or fmShareDenyWrite);
    SourceFile.Seek(Header.ID3v2Size, soFromBeginning);
    { Read header and get file size }
    Transferred := SourceFile.Read(Header, 32);
    Header.FileSize := SourceFile.Size;
    FreeAndNil(SourceFile);
    { if transfer is not complete }
    if Transferred < 32 then
      Result := false
    else
      Move(Header.ByteArray, Header.IntegerArray, SizeOf(Header.ByteArray));
  except
    FreeAndNil(SourceFile);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function MPPGetStreamVersion(const Header: TagMPPlus): Byte;
begin
  { Get MPEGplus stream version }
  if Header.IntegerArray[1] = MPP_VERSION_7_ID then
    Result := 7
  else if Header.IntegerArray[1] = MPP_VERSION_71_ID then
    Result := 71
  else
    case (Header.ByteArray[2] mod 32) div 2 of
      3:
        Result := 4;
      7:
        Result := 5;
      11:
        Result := 6
    else
      Result := 0;
    end;
end;

{ --------------------------------------------------------------------------- }

function DetectMPP(var Item: TPLItem): boolean;
var
  Header: TagMPPlus;
  TagID3: TagID3v2;
begin
  Result := false;
  if Item.plCue then
    Exit;
  try
    { Reset data and load header from file to variable }
    FillChar(Header, SizeOf(Header), 0);
    { At first try to load ID3v2 tag data, then header }
    if ID3ReadHeader(Item.plFile, TagID3) then
      Header.ID3v2Size := ID3GetTagSize(TagID3);
    Result := MPPReadHeader(Item.plFile, Header);
    { Process data if loaded and file valid }
    if (Result) and (Header.FileSize > 0) and (MPPGetStreamVersion(Header) > 0)
    then
    begin
      { Fill properties with header data }

      case MPPGetStreamVersion(Header) of
        4, 5:
          Item.plBitrate := Header.IntegerArray[1] shr 23;
      end;

      Item.plSampleRate := MPP_SampleRates[Header.ByteArray[11] and 3];
      Item.plSize := Header.FileSize;
    end;
  except
    Result := false;
  end;
end;

// ....................... REALIZATION (MPEG Audio) ......................... //

function MPEGIsFrameHeader(const HeaderData: array of Byte): boolean;
begin
  { Check for valid frame header }
  Result := ((HeaderData[0] and $FF) <> $FF) or ((HeaderData[1] and $E0) <> $E0)
    or (((HeaderData[1] shr 3) and 3) = 1) or
    (((HeaderData[1] shr 1) and 3) = 0) or ((HeaderData[2] and $F0) = $F0) or
    ((HeaderData[2] and $F0) = 0) or (((HeaderData[2] shr 2) and 3) = 3) or
    ((HeaderData[3] and 3) = 2);
end;

{ --------------------------------------------------------------------------- }

procedure MPEGDecodeHeader(const HeaderData: array of Byte; var Frame: TagMPEG);
begin
  { Decode frame header data }
  Move(HeaderData, Frame.Data, SizeOf(Frame.Data));
  Frame.VersionID := (HeaderData[1] shr 3) and 3;
  Frame.LayerID := (HeaderData[1] shr 1) and 3;
  Frame.ProtectionBit := (HeaderData[1] and 1) <> 1;
  Frame.BitRateID := HeaderData[2] shr 4;
  Frame.SampleRateID := (HeaderData[2] shr 2) and 3;
  Frame.PaddingBit := ((HeaderData[2] shr 1) and 1) = 1;
  Frame.PrivateBit := (HeaderData[2] and 1) = 1;
  Frame.ModeID := (HeaderData[3] shr 6) and 3;
  Frame.ModeExtensionID := (HeaderData[3] shr 4) and 3;
  Frame.CopyrightBit := ((HeaderData[3] shr 3) and 1) = 1;
  Frame.OriginalBit := ((HeaderData[3] shr 2) and 1) = 1;
  Frame.EmphasisID := HeaderData[3] and 3;
end;

{ --------------------------------------------------------------------------- }

function MPEGValidFrameAt(const Index: Word; Data: array of Byte): boolean;
var
  HeaderData: array [1 .. 4] of Byte;
begin
  { Check for frame at given position }
  HeaderData[1] := Data[Index];
  HeaderData[2] := Data[Index + 1];
  HeaderData[3] := Data[Index + 2];
  HeaderData[4] := Data[Index + 3];
  Result := MPEGIsFrameHeader(HeaderData);
end;

{ --------------------------------------------------------------------------- }

function MPEGGetCoefficient(const Frame: TagMPEG): Byte;
begin
  { Get frame size coefficient }
  if Frame.VersionID = MPEG_VERSION_1 then
  begin
    if Frame.LayerID = MPEG_LAYER_I then
      Result := 48
    else
      Result := 144
  end
  else if Frame.LayerID = MPEG_LAYER_I then
    Result := 24
  else if Frame.LayerID = MPEG_LAYER_II then
    Result := 144
  else
    Result := 72;
end;

{ --------------------------------------------------------------------------- }

function GetPadding(const Frame: TagMPEG): Byte;
begin
  { Get frame padding }
  Result := 0;
  if Frame.PaddingBit then
  begin
    if Frame.LayerID = MPEG_LAYER_I then
      Result := 4
    else
      Result := 1
  end;
end;

{ --------------------------------------------------------------------------- }

function MPEGGetFrameLength(const Frame: TagMPEG): Word;
begin
  { Calculate MPEG frame length }
  Result := Trunc(MPEGGetCoefficient(Frame) * MPEG_BIT_RATE[Frame.VersionID,
    Frame.LayerID, Frame.BitRateID] * 1000 / MPEG_SAMPLE_RATE[Frame.VersionID,
    Frame.SampleRateID]) + GetPadding(Frame);
end;

{ --------------------------------------------------------------------------- }

function MPEGGetVBRDeviation(const Frame: TagMPEG): Byte;
begin
  { Calculate VBR deviation }
  if Frame.VersionID = MPEG_VERSION_1 then
  begin
    if Frame.ModeID <> 3 then
      Result := 36
    else
      Result := 21
  end
  else if Frame.ModeID <> 3 then
    Result := 21
  else
    Result := 13;
end;

{ --------------------------------------------------------------------------- }
//
function MPEGIsXing(const Index: Word; Data: array of Byte): boolean;
begin
  { Get true if Xing encoder }
  Result := (Data[Index] = 0) and (Data[Index + 1] = 0) and
    (Data[Index + 2] = 0) and (Data[Index + 3] = 0) and (Data[Index + 4] = 0)
    and (Data[Index + 5] = 0);
end;

{ --------------------------------------------------------------------------- }

function MPEGGetXingInfo(const Index: Word; Data: array of Byte): VBRData;
begin
  { Extract Xing VBR info at given position }
  FillChar(Result, SizeOf(Result), 0);
  Result.Found := true;
  Result.ID := VBR_ID_XING;
  Result.Frames := Data[Index + 8] * $1000000 + Data[Index + 9] * $10000 +
    Data[Index + 10] * $100 + Data[Index + 11];
  Result.Bytes := Data[Index + 12] * $1000000 + Data[Index + 13] * $10000 +
    Data[Index + 14] * $100 + Data[Index + 15];
  Result.Scale := Data[Index + 119];
  { Vendor ID can be not present }
  Result.VendorID := Chr(Data[Index + 120]) + Chr(Data[Index + 121]) +
    Chr(Data[Index + 122]) + Chr(Data[Index + 123]) + Chr(Data[Index + 124]) +
    Chr(Data[Index + 125]) + Chr(Data[Index + 126]) + Chr(Data[Index + 127]);
end;

{ --------------------------------------------------------------------------- }

function MPEGGetFhGInfo(const Index: Word; Data: array of Byte): VBRData;
begin
  { Extract FhG VBR info at given position }
  FillChar(Result, SizeOf(Result), 0);
  Result.Found := true;
  Result.ID := VBR_ID_FHG;
  Result.Scale := Data[Index + 9];
  Result.Bytes := Data[Index + 10] * $1000000 + Data[Index + 11] * $10000 +
    Data[Index + 12] * $100 + Data[Index + 13];
  Result.Frames := Data[Index + 14] * $1000000 + Data[Index + 15] * $10000 +
    Data[Index + 16] * $100 + Data[Index + 17];
end;

{ --------------------------------------------------------------------------- }

function MPEGFindVBR(const Index: Word; Data: array of Byte): VBRData;
begin
  { Check for VBR header at given position }
  FillChar(Result, SizeOf(Result), 0);
  if Chr(Data[Index]) + Chr(Data[Index + 1]) + Chr(Data[Index + 2]) +
    Chr(Data[Index + 3]) = VBR_ID_XING then
    Result := MPEGGetXingInfo(Index, Data);
  if Chr(Data[Index]) + Chr(Data[Index + 1]) + Chr(Data[Index + 2]) +
    Chr(Data[Index + 3]) = VBR_ID_FHG then
    Result := MPEGGetFhGInfo(Index, Data);
end;

{ --------------------------------------------------------------------------- }

function MPEGFindFrame(const Data: array of Byte; var VBR: VBRData): TagMPEG;
var
  HeaderData: array [1 .. 4] of Byte;
  Iterator, VBRIdx: integer;
begin
  { Search for valid frame }
  FillChar(Result, SizeOf(Result), 0);
  Move(Data, HeaderData, SizeOf(HeaderData));
  for Iterator := 0 to SizeOf(Data) - MAX_MPEG_FRAME_LENGTH do
  begin
    { Decode data if frame header found }
    if MPEGIsFrameHeader(HeaderData) then
    begin
      MPEGDecodeHeader(HeaderData, Result);
      { Check for next frame and try to find VBR header }
      VBRIdx := Iterator + MPEGGetFrameLength(Result);
      if (VBRIdx < SizeOf(Data)) and MPEGValidFrameAt(VBRIdx, Data) then
      begin
        Result.Found := true;
        Result.Position := Iterator;
        Result.Size := MPEGGetFrameLength(Result);
        Result.Xing := MPEGIsXing(Iterator + SizeOf(HeaderData), Data);
        VBR := MPEGFindVBR(Iterator + MPEGGetVBRDeviation(Result), Data);
        Break;
      end;
    end;
    { Prepare next data block }
    HeaderData[1] := HeaderData[2];
    HeaderData[2] := HeaderData[3];
    HeaderData[3] := HeaderData[4];
    HeaderData[4] := Data[Iterator + SizeOf(HeaderData)];
  end;
end;

{ --------------------------------------------------------------------------- }

function DetectMPEG(var Item: TPLItem): boolean;
var
  SourceFile: TFileStream;
  Data: array [1 .. MAX_MPEG_FRAME_LENGTH * 2] of Byte;
  Transferred: DWORD;
  Position: Int64;
  Frame: TagMPEG;
  VBR: VBRData;
  id3tag: TagID3v2;
begin
  Result := false;

  if Item.plCue then
    Exit;

  Position := 0;
  try
    // SourceFile := FileOpen(Item.plFile, fmOpenRead or fmShareDenyWrite);
    SourceFile := TFileStream.Create(Item.plFile, fmOpenRead or
      fmShareDenyWrite);

    { At first search for tags & Lyrics3 then search for a MPEG frame and VBR data }
    Result := DetectID3v2(Item);
    if not Result then
      Result := DetectID3v1(Item);

    if Result then
    begin
      // Item.plSize := GetFileSize(SourceFile, nil);
      Item.plSize := SourceFile.Size;

      Position := GetID3v2Size(SourceFile);

      SourceFile.Seek(Position, soFromBeginning);
      Transferred := SourceFile.Read(Data, SizeOf(Data));
      // SetFilePointer(SourceFile, Position, nil, FILE_BEGIN);
      // ReadFile(SourceFile, Data, SizeOf(Data), Transferred, nil);

      Frame := MPEGFindFrame(Data, VBR);

      { patched by e-w@re }
      { Try to find the first frame if no frame at the beginning found }
      if (not Frame.Found) and (Transferred = SizeOf(Data)) then
      begin
        repeat
          Transferred := SourceFile.Read(Data, SizeOf(Data));
          // ReadFile(SourceFile, Data, SizeOf(Data), Transferred, nil);
          inc(Position, Transferred);
          Frame := MPEGFindFrame(Data, VBR);
        until (Frame.Found) or (Transferred < SizeOf(Data));
      end;

      if Frame.Found then
      begin
        Item.plSampleRate := MPEG_SAMPLE_RATE[Frame.VersionID,
          Frame.SampleRateID];

        { Calculate song bitrate }
        if (VBR.Found) and (VBR.Frames > 0) then
          Item.plBitrate := Trunc((VBR.Bytes / VBR.Frames - GetPadding(Frame)) *
            Item.plSampleRate / MPEGGetCoefficient(Frame) / 1000)
        else
          Item.plBitrate := MPEG_BIT_RATE[Frame.VersionID, Frame.LayerID,
            Frame.BitRateID];

        { Calculate song duration }
        if (VBR.Found) and (VBR.Frames > 0) then
          Item.plDuration := Trunc(VBR.Frames * MPEGGetCoefficient(Frame) * 8 /
            Item.plSampleRate)
        else
          Item.plDuration := Trunc((Item.plSize - Position) / Item.plBitrate /
            1000 * 8);
      end;
    end;
    // CloseHandle(SourceFile);
    FreeAndNil(SourceFile);
  except
    FreeAndNil(SourceFile);
    // CloseHandle(SourceFile);
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

end.
