unit QBassUtils;

{ |---------------------------------------------
  |  author: Zaripov Ravil aka ZuBy            |
  | contact:                                   |
  |          mail: rzaripov1990@gmail.com      |
  |          web : http://zuby.ucoz.kz         |
  |          Kazakhstan, Semey, © 2010         |
  |--------------------------------------------| }

// DSP AUTO VOLUME EFFECT (Edit by Alex Joy, 2011)
interface

uses
  WinApi.Windows, VCl.Graphics, System.SysUtils, BASS, QBCommon, SLCanvas32, QBTags, QBDSP, QBVis;

const
  QBASS_VERSION_ID = 1;

  QBASS_GET_DURATION = 1;
  QBASS_GET_POSITION = 2;
  QBASS_GET_POSITION_REMAINING = 3;
  QBASS_GET_SAMPLERATE = 4;
  QBASS_GET_BITRATE = 5;
  QBASS_GET_VOLUME = 6;
  QBASS_GET_VOLUME_GLOBAL = 7;
  QBASS_GET_BALANS = 8;
  QBASS_GET_FADE_TIME = 9;

  QBASS_SET_POSITION = 1;
  QBASS_SET_VOLUME = 2;
  QBASS_SET_VOLUME_GLOBAL = 3;
  QBASS_SET_BALANS = 4;
  QBASS_SET_FADING = 5;
  QBASS_SET_FADE_VOLUME = 6;
  QBASS_SET_FADE_PLAY = 7;
  QBASS_SET_FADE_PAUSE = 8;
  QBASS_SET_FADE_STOP = 9;
  QBASS_SET_FADE_POSITION = 10;

  // Winamp Status ID's
  QBASS_STATUS_STOP = 0;
  QBASS_STATUS_PLAY = 1;
  QBASS_STATUS_PAUSE = 2;

  // set event
  QBASS_MESSAGE_END = 0;
  // QBASS_MESSAGE_POS = 1;

  // dsp processing
  QBASS_DSP_CHANNEL_DISABLE_LEFT = 0;
  QBASS_DSP_CHANNEL_DISABLE_RIGHT = 1;
  QBASS_DSP_CHANNEL_SWAP = 2;
  QBASS_DSP_VOICE_FILTER = 3;
  QBASS_DSP_AUTO_VOLUME = 4;

  // equalizer mode
  QBASS_EQ_MODE_10 = 0;
  QBASS_EQ_MODE_18 = 1;

  QBASS_DEFAULT_FORMATS = '*.mp3;*.mp2;*.mp1;*.oga;*.ogg;*.wav;*.aif;*.aiff;*.mo3;*.it;*.xm;*.s3m;*.mtm;*.mod;*.umx;';

  QBASSErrorCodes: array [0 .. 46] of string = ('All is OK', 'Memory error', 'Can''t open the file',
    'Can''t find a free sound driver', 'The sample buffer was lost', 'Invalid handle', 'Unsupported sample format',
    'Invalid playback position', 'BASS_Init has not been successfully called',
    'BASS_Start has not been successfully called', 'Unknown error', 'Unknown error', 'Unknown error', 'Unknown error',
    'Already initialized/paused/whatever', 'Unknown error', 'Not paused', 'Unknown error', 'Can''t get a free channel',
    'An illegal type was specified', 'An illegal parameter was specified', 'No 3D support', 'No EAX support',
    'Illegal device number', 'Not playing', 'Illegal sample rate', 'Unknown error', 'The stream is not a file stream',
    'Unknown error', 'No hardware voices available', 'Unknown error', 'The MOD music has no sequence data',
    'No internet connection could be opened', 'Couldn''t create the file', 'Effects are not enabled',
    'The channel is playing', 'Unknown error', 'Requested data is not available', 'The channel is a "decoding channel"',
    'A sufficient DirectX version is not installed', 'Connection timedout', 'Unsupported file format',
    'Unavailable speaker', 'Invalid BASS version (used by add-ons)', 'Codec is not available/supported',
    'The channel/file has ended', 'The device is busy');

  // main function
function QBass_Init(const BASS_VER: Cardinal): bool;
function QBass_DeInit: bool;
function QBass_IsInit: bool;
function QBass_CreateFile(const FileName: Pointer; Flags: Cardinal): DWORD;
function QBass_CreateStream(const data: Pointer; OffSet, length: Int64): DWORD;
function QBass_CreateURL(const url: Pointer; Flags: Cardinal; proc: DOWNLOADPROC): DWORD;
procedure QBass_FreeStream(Channel: DWORD);
function QBass_Status(const Channel: DWORD; const WinampStatus: bool): Cardinal;
function QBass_Get(const Channel, Flag: DWORD): Single;
function QBass_Set(const Channel, Flag: DWORD; Value: Single; Ex: Single = 0): bool;
function QBass_MessageAdd(const Channel, Flag, Handle: DWORD; Value: DWORD): DWORD;
function QBass_MessageDel(const Channel, Flag, Handle: DWORD; MessageHandle: DWORD): bool;
function QBass_IsUrl(const s: string): boolean;
function QBass_FileMask: string;
procedure QBass_PluginsLoad(Path: PChar; Flags: DWORD);
// ...

// 10 / 18 Bands equalizer
procedure QBass_EQCreate(const Channel: DWORD; const BandWidth: Single; const Mode: Cardinal);
procedure QBASS_EQDestroy(const Channel: DWORD);
function QBass_EQActive: bool;
function QBass_EQGetPosition(const Band: integer): Single;
procedure QBass_EQSetPosition(const Band: integer; const Value: Single);
procedure QBass_EQPreamp(const Value: Single);
procedure QBass_EQSetDefault(const Value: Single = 0);
// ...

// DSP processing
function QBass_DSPProc(const Channel, fx: DWORD; Activate: bool): bool;

procedure QBassSlideSync(Handle: HSYNC; Channel, data: DWORD; User: Pointer); stdcall;

implementation

// .........................................................
type
  TEQBandCenter = array [1 .. 10] of Single;
  TEQBandsHandle = array [1 .. 10] of DWORD;

  TEQBandCenter18 = array [1 .. 18] of Single;
  TEQBandsHandle18 = array [1 .. 18] of DWORD;

  DataArray32 = array [0 .. 40000] of Single;
  PDataArray32 = ^DataArray32;

  AutoVolume = record
    gain: Double;   // amplification level
    delay: integer; // delay before increasing level
    count: integer; // count of sequential samples below target level
    high: integer;  // the highest in that period
    quiet: integer; // count of sequential samples below quiet level
  end;

const
  MCW_EM = DWORD($133F);

  QBands: TEQBandCenter = (80, 170, 310, 600, 1000, 3000, 6000, 10000, 12000, 14000); // eq band center frequence
  QBands18: TEQBandCenter18 = (80, 120, 200, 350, 550, 750, 1000, 1800, 2500, 3800, 5000, 6200, 7500, 9000, 11000,
    12000, 13000, 14000);

  amptarget = 28000; // target level
  ampquiet = 1000;   // quiet level
  amprate = 0.02;    // amp adjustment rate

var
  Saved8087CW: Word = 0;

  QB_FADING_TIME: Cardinal = 1000;
  QB_FADING_TEMP_VOLUME: Single;
  QB_FADING_MODE: Cardinal = 0;
  // 0 - none
  // 1 - playing
  // 2 - paused
  // 3 - stoped

  ExtString: String = '';
  AudioFilesMask: String = '';
  QB_MESSAGE: DWORD = DW_ERROR;
  QB_MESSAGE_HANDLE: DWORD = DW_ERROR;
  QB_MESSAGE_CHANNEL: DWORD = DW_ERROR;

  // dsp proc
  amp: AutoVolume;
  LC: DWORD = 0;
  RC: DWORD = 0;
  VF: DWORD = 0;
  CS: DWORD = 0;
  AV: DWORD = 0;
  FE: DWORD = 0;

  // equalizer
  EQActive: bool = false;
  EQBandsHandle: TEQBandsHandle = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  EQBandsHandle18: TEQBandsHandle18 = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  EQParam: BASS_DX8_PARAMEQ;
  Preamp: DWORD = 0;
  PreampValue: Single = 0;
  EQMode: Cardinal = 0;

  { qbass functions }

  // ******************************************************************************

function QBass_Init(const BASS_VER: Cardinal): bool;
begin
  InitDLL := (HIWORD(Bass_GetVersion) = BASS_VER);
  Result := InitDLL;

  if Result then
  begin
    Saved8087CW := Get8087CW;
    Set8087CW(MCW_EM);

    VisBuffer := TBitmap.Create;
    VisBuffer.Width := 10;
    VisBuffer.Height := 10;
    VisBuffer.PixelFormat := pf32bit;

    Drawer := TacSLCanvas32.Create(VisBuffer);
    Drawer.SetAllPixels(0, 0, 0, 255);
  end;
end;

// ******************************************************************************
function QBass_DeInit: bool;
begin
  Result := BASS_Free;
  if Result then
  begin
    InitDLL := false;
    Set8087CW(Saved8087CW);
    Saved8087CW := 0;

    if Drawer.LoadedMemory then
      Drawer.DetachMemory;
    FreeAndNil(Drawer);

    FreeAndNil(VisBuffer);
  end;
end;

// ******************************************************************************
function QBass_IsInit: bool;
begin
  Result := InitDLL;
end;

// ******************************************************************************
function QBass_CreateFile(const FileName: Pointer; Flags: Cardinal): DWORD;
begin
  Result := DW_ERROR;
  if (not InitDLL) or (FileName = nil) then
    exit;

  if (Flags and BASS_STREAM_PRESCAN) <> BASS_STREAM_PRESCAN then
    Flags := Flags or BASS_STREAM_PRESCAN;

  Result := BASS_StreamCreateFile(false, FileName, 0, 0, Flags);
  if (Result = 0) then
  begin
    if (Flags and BASS_MUSIC_CALCLEN) <> BASS_MUSIC_CALCLEN then
      Flags := Flags or BASS_MUSIC_CALCLEN;
    Result := BASS_MusicLoad(false, FileName, 0, 0, Flags, 0);
  end;
end;
// ******************************************************************************

function QBass_CreateStream(const data: Pointer; OffSet, length: Int64): DWORD;
begin
  Result := DW_ERROR;
  if (not InitDLL) or (data = nil) then
    exit;

  Result := BASS_StreamCreateFile(true, data, OffSet, length, BASS_STREAM_PRESCAN);
  if (Result = 0) then
    Result := BASS_MusicLoad(true, data, OffSet, length, BASS_MUSIC_CALCLEN, 0);
end;

// ******************************************************************************

function QBass_CreateURL(const url: Pointer; Flags: Cardinal; proc: DOWNLOADPROC): DWORD;
begin
  Result := DW_ERROR;
  if (not InitDLL) or (url = nil) then
    exit;

  Result := BASS_StreamCreateURL(url, 0, Flags, proc, nil);
end;
// ******************************************************************************

procedure QBass_FreeStream(Channel: DWORD);
begin
  if (not InitDLL) or (Channel <= 0) then
    exit;

  BASS_MusicFree(Channel);
  BASS_StreamFree(Channel);
end;

// ******************************************************************************
// Winamp Status - the result will be adapted for Winamp
function QBass_Status(const Channel: DWORD; const WinampStatus: bool): Cardinal;
begin
  if WinampStatus then
    Result := QBASS_STATUS_STOP
  else
    Result := BASS_ACTIVE_STOPPED;

  if (not InitDLL) or (Channel <= 0) then
    exit;

  Result := BASS_ChannelIsActive(Channel);
  if WinampStatus then
  begin
    case Result of
      BASS_ACTIVE_PLAYING:
        Result := QBASS_STATUS_PLAY;
      BASS_ACTIVE_STALLED, BASS_ACTIVE_STOPPED:
        Result := QBASS_STATUS_STOP;
      BASS_ACTIVE_PAUSED:
        Result := QBASS_STATUS_PAUSE;
    end;
  end;
end;

// ******************************************************************************
function QBass_Get(const Channel, Flag: DWORD): Single;
begin
  Result := 0;
  if (not InitDLL) or (Channel <= 0) then
    exit;

  case Flag of
    QBASS_GET_DURATION:
      Result := BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel, BASS_POS_BYTE));
    QBASS_GET_POSITION:
      Result := BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel, BASS_POS_BYTE));
    QBASS_GET_POSITION_REMAINING:
      Result := BASS_ChannelSeconds2Bytes(Channel, BASS_ChannelGetLength(Channel, BASS_POS_BYTE)) -
        BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel, BASS_POS_BYTE));
    QBASS_GET_SAMPLERATE:
      BASS_ChannelGetAttribute(Channel, BASS_ATTRIB_FREQ, Result);
    QBASS_GET_BITRATE:
      Result := BASS_StreamGetFilePosition(Channel, BASS_FILEPOS_END) /
        (125 * BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetLength(Channel, BASS_POS_BYTE)));
    QBASS_GET_VOLUME:
      BASS_ChannelGetAttribute(Channel, BASS_ATTRIB_VOL, Result);
    QBASS_GET_VOLUME_GLOBAL:
      Result := BASS_GetVolume;
    QBASS_GET_BALANS:
      BASS_ChannelGetAttribute(Channel, BASS_ATTRIB_PAN, Result);
    QBASS_GET_FADE_TIME:
      Result := QB_FADING_TIME;
  end;
end;
// ******************************************************************************

procedure QBassSlideSync(Handle: HSYNC; Channel, data: DWORD; User: Pointer); stdcall;
var
  Volume: Single;
begin
  if data = BASS_ATTRIB_VOL then
  begin
    if BASS_ChannelGetAttribute(Channel, BASS_ATTRIB_VOL, Volume) then
    begin
      if Volume <> 0 then
        exit;
      case QB_FADING_MODE of
        0, 1:
          ;
        2:
          begin
            BASS_ChannelPause(Channel);
            BASS_ChannelSetAttribute(Channel, BASS_ATTRIB_VOL, QB_FADING_TEMP_VOLUME);
          end;
        3:
          begin
            BASS_ChannelStop(Channel);
            BASS_ChannelSetAttribute(Channel, BASS_ATTRIB_VOL, QB_FADING_TEMP_VOLUME);
          end;
      end;
    end;
  end;
  QB_FADING_MODE := 0;
end;

function QBass_Set(const Channel, Flag: DWORD; Value: Single; Ex: Single = 0): bool;
begin
  Result := false;
  if (not InitDLL) then
    exit;

  case Flag of
    QBASS_SET_POSITION:
      Result := BASS_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel, Value), BASS_POS_BYTE);
    QBASS_SET_VOLUME:
      Result := BASS_ChannelSetAttribute(Channel, BASS_ATTRIB_VOL, Value);
    QBASS_SET_VOLUME_GLOBAL:
      Result := BASS_SetVolume(Value);
    QBASS_SET_BALANS:
      Result := BASS_ChannelSetAttribute(Channel, BASS_ATTRIB_PAN, Value);

    QBASS_SET_FADING:
      begin
        if FE <> 0 then
        begin
          BASS_ChannelRemoveSync(Channel, FE);
          FE := 0;
        end;

        if Ex = 1 then
          FE := BASS_ChannelSetSync(Channel, BASS_SYNC_SLIDE, 0, @QBassSlideSync, nil);

        QB_FADING_TIME := Trunc(Value);
        Result := true;
      end;
    QBASS_SET_FADE_VOLUME:
      Result := BASS_ChannelSlideAttribute(Channel, BASS_ATTRIB_VOL, Value, QB_FADING_TIME);
    QBASS_SET_FADE_PLAY:
      begin
        BASS_ChannelSetAttribute(Channel, BASS_ATTRIB_VOL, 0);
        BASS_ChannelPlay(Channel, false);
        BASS_ChannelSlideAttribute(Channel, BASS_ATTRIB_VOL, Value, QB_FADING_TIME);
        Result := true;
      end;
    QBASS_SET_FADE_PAUSE:
      begin
        QB_FADING_MODE := 2;
        QB_FADING_TEMP_VOLUME := Value;
        BASS_ChannelSlideAttribute(Channel, BASS_ATTRIB_VOL, 0, QB_FADING_TIME);
        Result := true;
      end;
    QBASS_SET_FADE_STOP:
      begin
        QB_FADING_MODE := 3;
        QB_FADING_TEMP_VOLUME := Value;
        BASS_ChannelSlideAttribute(Channel, BASS_ATTRIB_VOL, 0, QB_FADING_TIME);
        Result := true;
      end;
    QBASS_SET_FADE_POSITION:
      begin
        BASS_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel, Value), BASS_POS_BYTE);
        Result := BASS_ChannelSlideAttribute(Channel, BASS_ATTRIB_VOL, Ex, QB_FADING_TIME div 2);
      end;
  end;
end;
// ******************************************************************************

function QBass_IsUrl(const s: string): boolean;
begin
  Result := false;
  if (Copy(LowerCase(s), 1, 7) = 'http://') or (Copy(LowerCase(s), 1, 6) = 'ftp://') or
    (Copy(LowerCase(s), 1, 6) = 'mms://') then
    Result := true;
end;
// ******************************************************************************

function QBass_FileMask: string;
begin
  Result := AudioFilesMask;
end;
// ******************************************************************************

procedure QBass_PluginsLoad(Path: PChar; Flags: DWORD);
var
  SearchRec: TSearchRec;
  i, bassplug: Cardinal;
  pluginfo: PBASS_PLUGININFO;
  name, ext, exts, ExtAdd: string;
begin
  if Path[length(Path)] <> '\' then
    Path := PChar(Path + '\');

  AudioFilesMask := '';

  if FindFirst(Path + 'bass*.dll', faAnyFile, SearchRec) = 0 then
  begin
    ExtString := '';
    repeat
      if (SearchRec.Attr and faDirectory) <> faDirectory then
      begin
        pluginfo := nil;
        bassplug := BASS_PluginLoad(PChar(Path + SearchRec.Name), Flags);
        if bassplug > 0 then
        begin
          pluginfo := BASS_PluginGetInfo(bassplug);
          exts := '';
          name := pluginfo^.formats^[0].Name;

          for i := 0 to pluginfo^.formatc - 1 do
          begin
            ext := pluginfo^.formats^[i].exts;

            if ext[length(ext)] <> ';' then
              ext := ext + ';';
            exts := exts + ext;

            if not(Pos(ext, AudioFilesMask) > 0) then
              AudioFilesMask := AudioFilesMask + ext;
          end;

          ExtAdd := name + '|' + exts + '|';
          if Pos(Name, ExtString) = 0 then
            ExtString := ExtString + ExtAdd;
        end;
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;

  AudioFilesMask := 'All supported formats|' + QBASS_DEFAULT_FORMATS + AudioFilesMask + '|' +
    'Apple AIFF|*.aiff;*.aif|MPEG Audio|*.mp1;*.mp2;*.mp3;|OGG Vorbis|*.ogg;*.oga;|Windows Wave|*.wav;|Tracker Music|*.mo3;*.it;*.xm;*.s3m;*.mtm;*.mod;*.umx;|'
    + ExtString;
end;

// ******************************************************************************
procedure EndSync(Handle: HSYNC; Channel, data: DWORD; User: Pointer);
begin
  SendMessage(QB_MESSAGE_HANDLE, QB_MESSAGE, QBASS_MESSAGE_END, 0);
end;

function QBass_MessageAdd(const Channel, Flag, Handle: DWORD; Value: DWORD): DWORD;
begin
  Result := DW_ERROR;
  if (not InitDLL) or (Channel <= 0) then
    exit;

  QB_MESSAGE := Value;
  QB_MESSAGE_HANDLE := Handle;
  QB_MESSAGE_CHANNEL := Channel;
  case Flag of
    QBASS_MESSAGE_END:
      Result := BASS_ChannelSetSync(QB_MESSAGE_CHANNEL, BASS_SYNC_END, 0, @EndSync, nil);
  end;
end;
// ******************************************************************************

function QBass_MessageDel(const Channel, Flag, Handle: DWORD; MessageHandle: DWORD): bool;
begin
  Result := true;
  if (not InitDLL) or (Channel <= 0) then
    exit;

  QB_MESSAGE := DW_ERROR;
  QB_MESSAGE_HANDLE := DW_ERROR;
  QB_MESSAGE_CHANNEL := DW_ERROR;
  case Flag of
    QBASS_MESSAGE_END:
      Result := BASS_ChannelRemoveSync(Channel, MessageHandle);
    // QBASS_MESSAGE_POS:      ;
  end;
end;
// ******************************************************************************

/// //////////////////////////////////////////////////////////////////////////////
/// DSP PROC
/// //////////////////////////////////////////////////////////////////////////////
procedure DSPProc_VoiceOff(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  i: DWORD;
  dmch: Single;
  lch, rch: PSingle;
begin
  try
    if (Channel = 0) or (length = 0) then
      exit;

    i := 0;
    lch := buffer;
    rch := buffer;
    inc(rch);

    while (i < length) do
    begin
      dmch := ((0 - lch^) + rch^) / 2;

      if dmch <> 0 then
      begin
        lch^ := dmch;
        rch^ := dmch;
      end
      else
      begin
        lch^ := lch^;
        rch^ := rch^;
      end;

      inc(lch, 2);
      inc(rch, 2);
      inc(i, sizeof(Single) * 2);
    end;
  except
  end;
end;

// ******************************************************************************

procedure DSPProc_LeftChannel(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  i: DWORD;
  lch, rch: PSingle;
begin
  try
    if (Channel = 0) or (length = 0) then
      exit;

    i := 0;
    lch := buffer;
    rch := buffer;
    inc(rch);

    while (i < length) do
    begin
      lch^ := 0;
      rch^ := rch^;

      inc(lch, 2);
      inc(rch, 2);
      inc(i, sizeof(Single) * 2);
    end;
  except
  end;
end;

// ******************************************************************************

procedure DSPProc_RightChannel(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  i: DWORD;
  lch, rch: PSingle;
begin
  try
    if (Channel = 0) or (length = 0) then
      exit;

    i := 0;
    lch := buffer;
    rch := buffer;
    inc(rch);

    while (i < length) do
    begin
      lch^ := lch^;
      rch^ := 0;

      inc(lch, 2);
      inc(rch, 2);
      inc(i, sizeof(Single) * 2);
    end;
  except
  end;
end;

// ******************************************************************************

procedure DSPProc_SwapChannel(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  lch, rch: PSingle;
  Temp: PSingle;
  i: Cardinal;
begin
  try
    if (Channel = 0) or (length = 0) then
      exit;

    i := 0;
    lch := buffer;
    rch := buffer;
    inc(rch);

    while (i < length) do
    begin
      Temp^ := lch^;
      lch^ := rch^;
      rch^ := Temp^;

      inc(lch, 2);
      inc(rch, 2);
      inc(i, sizeof(Single) * 2);
    end;
  except
  end;
end;

// ******************************************************************************

function GetAutoAmpValue(SampleValue: integer): integer; register;
var
  sa: integer;
begin
  //
  Result := Round(SampleValue * amp.gain); // amplify sample. "усиленое" значение
  sa := abs(Result);                       // Получаем положительное значение (число)
  if (abs(SampleValue) < amp.quiet) then
    inc(amp.quiet) // sample is below quiet level. сэмпл ниже тихой уровня
  else
    amp.quiet := 0;
  if (sa < amptarget) then
  begin
    // amplified level is below target
    // Усиленный уровень ниже целевого
    if (sa > amp.high) then
      amp.high := sa;
    inc(amp.count);
    if (amp.count = amp.delay) then
    begin
      // been below target for a while
      if (amp.quiet > amp.delay) then
        // it's quiet, go back towards normal level
        amp.gain := amp.gain + 10 * amprate * (1 - amp.gain)
      else
        amp.gain := amp.gain + amprate * amptarget / amp.high; // increase amp
      amp.high := 0;
      amp.count := 0; // reset counts
    end;
  end
  else
  begin // amplified level is above target
    if (Result < -32768) then
      Result := -32768
    else if (Result > 32767) then
      Result := 32767;
    amp.gain := amp.gain - 2 * amprate * sa / amptarget; // decrease amp
    amp.high := 0;
    amp.count := 0;
  end;
end;

procedure DSPProc_AutoAmp32(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  c: DWORD;
  d: integer;
begin
  // 32bit - 4bytes
  for c := 0 to (length div 4) - 1 do // По каждому сэмплу
  begin
    // ---------Сингловский сэмпл----------//
    d := Trunc(Single(Pointer(Cardinal(buffer) + c * 4)^) * 32768); // Получаем сэмпл и преобразовываем в целое
    //
    if d > 32767 then
      d := 32767
    else if d < -32768 then
      d := -32768;
    //
    Single(Pointer(Cardinal(buffer) + c * 4)^) := GetAutoAmpValue(d) / 32768;
  end;
end;
// ******************************************************************************

function QBass_DSPProc(const Channel, fx: DWORD; Activate: bool): bool;
begin
  Result := false;

  if (not InitDLL) or (Channel <= 0) then
    exit;

  Result := true;
  case fx of
    QBASS_DSP_CHANNEL_DISABLE_LEFT:
      begin
        if LC > 0 then
          Result := BASS_ChannelRemoveDSP(Channel, LC);
        LC := 0;

        if Activate then
        begin
          LC := BASS_ChannelSetDSP(Channel, @DSPProc_LeftChannel, nil, 2);
          Result := LC > 0;
        end;
      end;

    QBASS_DSP_CHANNEL_DISABLE_RIGHT:
      begin
        if RC > 0 then
          Result := BASS_ChannelRemoveDSP(Channel, RC);
        RC := 0;

        if Activate then
        begin
          RC := BASS_ChannelSetDSP(Channel, @DSPProc_RightChannel, nil, 2);
          Result := RC > 0;
        end;
      end;

    QBASS_DSP_CHANNEL_SWAP:
      begin
        if CS > 0 then
          Result := BASS_ChannelRemoveDSP(Channel, CS);
        CS := 0;

        if Activate then
        begin
          CS := BASS_ChannelSetDSP(Channel, @DSPProc_SwapChannel, nil, 2);
          Result := CS > 0;
        end;
      end;

    QBASS_DSP_VOICE_FILTER:
      begin
        if VF > 0 then
          Result := BASS_ChannelRemoveDSP(Channel, VF);
        VF := 0;

        if Activate then
        begin
          VF := BASS_ChannelSetDSP(Channel, @DSPProc_VoiceOff, nil, 2);
          Result := VF > 0;
        end;
      end;

    QBASS_DSP_AUTO_VOLUME:
      begin
        if AV > 0 then
          Result := BASS_ChannelRemoveDSP(Channel, AV);
        AV := 0;

        if Activate then
        begin
          AV := BASS_ChannelSetDSP(Channel, @DSPProc_AutoAmp32, nil, 2);
          Result := AV > 0;
        end;
      end;
  else
    Result := false;

  end;
end;
// ******************************************************************************

/// //////////////////////////////////////////////////////////////////////////////
/// EQUALIZER
/// //////////////////////////////////////////////////////////////////////////////
procedure DSPProc_PreAmp(Handle: HDSP; Channel: DWORD; buffer: Pointer; length: DWORD; User: Pointer); stdcall;
var
  i: DWORD;
  lch, rch: PSingle;
begin
  try
    if (Channel = 0) or (length = 0) then
      exit;

    i := 0;
    lch := buffer;
    rch := buffer;

    if PreampValue > 0 then
      inc(rch)
    else
      inc(lch);

    while (i < length) do
    begin
      if PreampValue = 0 then
      begin
        lch^ := lch^;
        rch^ := rch^;
      end
      else if PreampValue > 0 then
      begin
        lch^ := lch^ * PreampValue;
        rch^ := rch^ * PreampValue;
      end
      else
      begin
        lch^ := lch^ / PreampValue;
        rch^ := rch^ / PreampValue;
      end;

      inc(lch, 2);
      inc(rch, 2);
      inc(i, sizeof(Single) * 2);
    end;
  except
  end;
end;

// ******************************************************************************
procedure QBASS_EQDestroy(const Channel: DWORD);
var
  i, c: Byte;
begin
  if not InitDLL then
    exit;

  EQActive := false;

  if (Channel <= 0) then
    exit;

  if Preamp > 0 then
    BASS_ChannelRemoveDSP(Channel, Preamp);

  case EQMode of
    0:
      c := 10;
    1:
      c := 18;
  else
    exit;
  end;

  for i := 1 to c do
    BASS_ChannelRemoveFX(Channel, EQBandsHandle[i]);
end;

// ******************************************************************************
procedure QBass_EQCreate(const Channel: DWORD; const BandWidth: Single; const Mode: Cardinal);
var
  i, c: Byte;
begin
  if not InitDLL then
    exit;

  if EQActive then
    QBASS_EQDestroy(Channel);

  if (not InitDLL) or (Channel <= 0) then
    exit;

  case EQMode of
    0:
      c := 10;
    1:
      c := 18;
  else
    exit;
  end;

  for i := 1 to c do
  begin
    EQBandsHandle[i] := BASS_ChannelSetFX(Channel, BASS_FX_DX8_PARAMEQ, 1);
    if EQMode = 0 then
      EQParam.fCenter := QBands[i]
    else
      EQParam.fCenter := QBands18[i];
    EQParam.fGain := 0;
    EQParam.fBandwidth := BandWidth;
    BASS_FXSetParameters(EQBandsHandle[i], @EQParam);
  end;

  Preamp := BASS_ChannelSetDSP(Channel, @DSPProc_PreAmp, nil, 6);
  EQActive := true;
end;

// ******************************************************************************
procedure QBass_EQPreamp(const Value: Single);
begin
  if (not InitDLL) and (EQActive) then
    exit;
  PreampValue := Value;
end;

// ******************************************************************************
function QBass_EQActive: bool;
begin
  Result := false;
  if not InitDLL then
    exit;
  Result := EQActive;
end;

// ******************************************************************************
function QBass_EQGetPosition(const Band: integer): Single;
begin
  Result := 0;
  if (not InitDLL) and (EQActive) then
    exit;

  BASS_FXGetParameters(EQBandsHandle[Band], @EQParam);
  Result := EQParam.fGain;
end;

// ******************************************************************************
procedure QBass_EQSetPosition(const Band: integer; const Value: Single);
begin
  if (not InitDLL) and (EQActive) then
    exit;

  BASS_FXGetParameters(EQBandsHandle[Band], @EQParam);
  EQParam.fGain := Value;
  BASS_FXSetParameters(EQBandsHandle[Band], @EQParam);
end;

// ******************************************************************************
procedure QBass_EQSetDefault(const Value: Single = 0);
var
  i, c: integer;
begin
  if (not InitDLL) and (EQActive) then
    exit;

  case EQMode of
    0:
      c := 10;
    1:
      c := 18;
  else
    exit;
  end;

  for i := 1 to c do
    QBass_EQSetPosition(i, Value);
end;
// ******************************************************************************

end.
