unit QBDSP;

interface

uses
  WinApi.Windows, VCL.Forms, System.SysUtils, System.Classes, Bass, QBCommon;

// Winamp DSP 2.0 Support
procedure QBass_DSPCreate(const FileName: PChar);
procedure QBass_DSPDestroy;
procedure QBass_DSPUpdate(const Channel: DWORD);
procedure QBass_DSPPluginsLoad(Path: PChar; var FileNames, Titles: QBArrString);
function QBass_DSPActive: bool;
procedure QBass_DSPConfig;
function QBass_DSPHeaderInfo: PAnsiChar;
function QBass_DSPModuleInfo: PAnsiChar;
// ...

implementation

const
  DSP_HDRVER = $20;

type
  PWinampDSPModule = ^TWinampDSPModule;

  TWinampDSPModule = record
    Description: PAnsiChar;
    hWndParent: HWND;
    hDllInstance: HINST;
    Config: procedure(PDSPModule: PWinampDSPModule); cdecl;
    Init: function(PDSPModule: PWinampDSPModule): integer; cdecl;
    ModifySamples: function(PDSPModule: PWinampDSPModule; Samples: Pointer;
      NumSamples: integer; BPS: integer; NCh: integer; SRate: integer)
      : integer; cdecl;
    Quit: procedure(PDSPModule: PWinampDSPModule); cdecl;
    userData: procedure; cdecl;
  end;

  PWinampDSPHeader = ^TWinampDSPHeader;

  TWinampDSPHeader = record
    Version: integer;
    Description: PAnsiChar;
    GetModule: function(Which: integer): PWinampDSPModule; cdecl;
  end;

  // ******************************************************************************

var
  PluginLoaded: bool = false;
  DSPActive: bool = false;

  DSPHandle: DWORD = 0;
  SavedChannel: DWORD = 0;
  ChanInfo: BASS_CHANNELINFO;
  NumChan: integer = 0;
  SampleRate: integer = 0;

  DSPDLLHandle: Cardinal = 0;
  WinampSamplesForDSP: PSmallInt = nil;

  DSPHeader: PWinampDSPHeader = nil;
  DSPModule: PWinampDSPModule = nil;
  DSPGetHeader: function: PWinampDSPHeader; cdecl;

function LoadPlugin(FileName: PChar): bool;
begin
  Result := false;
  PluginLoaded := false;
  DSPDLLHandle := LoadLibrary(FileName);
  if (DSPDLLHandle = 0) then
    Exit;

  @DSPGetHeader := GetProcAddress(DSPDLLHandle,
    PChar('winampDSPGetHeader2'));
  if @DSPGetHeader <> nil then
  begin
    DSPHeader := DSPGetHeader;
    if DSPHeader.Version <> DSP_HDRVER then
    begin
      DSPHeader := nil;
      DSPGetHeader := nil;
      Exit;
    end;

    DSPModule := DSPHeader.GetModule(0);
    if DSPModule <> nil then
    begin
      DSPModule^.hDllInstance := DSPDLLHandle;
      DSPModule^.hWndParent := Application.Handle;
      if (DSPModule^.Init(DSPModule) <> 0) then
      begin
        DSPHeader := nil;
        DSPGetHeader := nil;
        DSPModule := nil;
        Exit;
      end;
      Result := true;
      PluginLoaded := true;
    end;
  end;
end;
// ******************************************************************************

function FreePlugin: bool;
begin
  Result := false;
  try
    if (DSPDLLHandle <> 0) then
    begin
      if Assigned(DSPModule) then
        DSPModule^.Quit(DSPModule);
      FreeLibrary(DSPDLLHandle);
      DSPDLLHandle := 0;
      DSPHeader := nil;
      DSPModule := nil;
      DSPGetHeader := nil;
      PluginLoaded := false;
      Result := true;
    end;
  except

  end;
end;
// ******************************************************************************

procedure DSP32Proc(Handle: HDSP; Channel: DWORD; buffer: Pointer;
  length: DWORD; user: Pointer); stdcall;
var
  SampleBuffer: PSingle;
  WinampBuf: PSmallInt;
  BufEndPnt: DWORD;
  SaveValue: integer;
  SamplesReturned: DWORD;
  NumberOfBufferSamples: DWORD;
begin
  try
    if (PluginLoaded) and (Handle > 0) and (Channel > 0) and
      (Assigned(DSPModule)) and (NumChan <= 2) then
    begin
      BufEndPnt := DWORD(buffer) + length;
      SampleBuffer := buffer;
      WinampBuf := WinampSamplesForDSP;
      while DWORD(SampleBuffer) < BufEndPnt do
      begin
        SaveValue := Trunc(SampleBuffer^ * 32768);
        if SaveValue > 32767 then
          SaveValue := 32767
        else if SaveValue < -32768 then
          SaveValue := -32768;
        WinampBuf^ := SmallInt(SaveValue);
        Inc(WinampBuf);
        Inc(SampleBuffer);

        if NumChan = 2 then
        begin
          SaveValue := Trunc(SampleBuffer^ * 32768);
          if SaveValue > 32767 then
            SaveValue := 32767
          else if SaveValue < -32768 then
            SaveValue := -32768;
          WinampBuf^ := SmallInt(SaveValue);
          Inc(WinampBuf);
          Inc(SampleBuffer);
        end;
      end;
      NumberOfBufferSamples := (length div (NumChan * 4));
      SamplesReturned := 0;
      try
        SamplesReturned := DSPModule^.ModifySamples(DSPModule,
          WinampSamplesForDSP, NumberOfBufferSamples, 16, NumChan, SampleRate);
      except
      end;
      if SamplesReturned <> NumberOfBufferSamples then
        Exit;
      SampleBuffer := buffer;
      WinampBuf := WinampSamplesForDSP;
      while DWORD(SampleBuffer) < BufEndPnt do
      begin
        SampleBuffer^ := WinampBuf^ / 32768;
        Inc(WinampBuf);
        Inc(SampleBuffer);

        if NumChan = 2 then
        begin
          SampleBuffer^ := WinampBuf^ / 32768;
          Inc(WinampBuf);
          Inc(SampleBuffer);
        end;
      end;
    end;
  except
  end;
end;
// ******************************************************************************

procedure DSP16Proc(Handle: HDSP; Channel: DWORD; buffer: Pointer;
  length: DWORD; user: Pointer); stdcall;
var
  NumberOfBufferSamples: integer;
  WinampBuf: PSmallInt;
begin
  if (PluginLoaded) and Assigned(DSPModule) and (NumChan <= 2) then
  begin
    try
      WinampBuf := WinampSamplesForDSP;
      Move(buffer^, WinampBuf^, length);
      NumberOfBufferSamples := length div (NumChan * 2);
      if DSPModule^.ModifySamples(DSPModule, WinampBuf, NumberOfBufferSamples,
        16, NumChan, SampleRate) = NumberOfBufferSamples then
        Move(WinampBuf^, buffer^, length);
    except
    end;
  end;
end;
// ******************************************************************************

procedure QBass_DSPCreate(const FileName: PChar);
var
  WinAmpSamplesAllocate: integer;
begin
  if not InitDLL then
    Exit;

  DSPActive := false;
  if PluginLoaded then
    FreePlugin;
  if LoadPlugin(FileName) then
  begin
    WinAmpSamplesAllocate := Round(96000 * 4 * 2 * (200 + 5) / 1000) * 2;
    GetMem(WinampSamplesForDSP, WinAmpSamplesAllocate);
    DSPActive := true;
  end;
end;
// ******************************************************************************

procedure QBass_DSPDestroy;
begin
  if not InitDLL then
    Exit;

  if DSPActive then
  begin
    if (DSPHandle > 0) and (SavedChannel > 0) then
    begin
      if BASS_ChannelRemoveDSP(SavedChannel, DSPHandle) then
      begin
        DSPHandle := 0;
        SavedChannel := 0;
      end;
    end;
    if PluginLoaded then
      FreePlugin;
    FreeMem(WinampSamplesForDSP);
    WinampSamplesForDSP := nil;
    DSPActive := false;
  end;
end;
// ******************************************************************************

procedure QBass_DSPUpdate(const Channel: DWORD);
const
  setdatanum: array [boolean] of integer = (0, 1);
var
  dsp32bit: boolean;
begin
  if not InitDLL then
    Exit;
  if (not DSPActive) then
    Exit;

  if DSPActive and PluginLoaded then
  begin
    if (DSPHandle > 0) and (SavedChannel > 0) then
    begin
      if BASS_ChannelRemoveDSP(SavedChannel, DSPHandle) then
      begin
        DSPHandle := 0;
        SavedChannel := 0;
      end;
    end;
    SavedChannel := Channel;
    BASS_ChannelGetInfo(SavedChannel, ChanInfo);
    NumChan := ChanInfo.chans;
    SampleRate := ChanInfo.freq;

    dsp32bit := ((ChanInfo.Flags and BASS_SAMPLE_FLOAT) = BASS_SAMPLE_FLOAT);
    BASS_SetConfig(BASS_CONFIG_FLOATDSP, setdatanum[dsp32bit]);

    if dsp32bit then
      DSPHandle := BASS_ChannelSetDSP(SavedChannel, @DSP32Proc, nil, 7)
    else
      DSPHandle := BASS_ChannelSetDSP(SavedChannel, @DSP16Proc, nil, 7);
  end;
end;
// ******************************************************************************

procedure QBass_DSPPluginsLoad(Path: PChar; var FileNames, Titles: QBArrString);
var
  SearchRec: TSearchRec;
  Count: Cardinal;

  procedure TempLoadPlugin(FileName: PChar);
  var
    dll: THandle;
    tempHeader: PWinampDSPHeader;
    tempGetHeader: function: PWinampDSPHeader; cdecl;
  begin
    tempHeader := nil;
    tempGetHeader := nil;
    dll := LoadLibrary(FileName);
    if (dll = 0) then
      Exit;

    @tempGetHeader := GetProcAddress(dll, PChar('winampDSPGetHeader2'));
    if @tempGetHeader <> nil then
    begin
      tempHeader := tempGetHeader;
      if tempHeader.Version <> DSP_HDRVER then
      begin
        tempHeader := nil;
        tempGetHeader := nil;
        Exit;
      end;

      // if Titles.IndexOf(tempHeader^.Description) = -1 then
      // begin
      SetLength(FileNames, Count + 1);
      SetLength(Titles, Count + 1);

      FileNames[Count] := FileName;
      Titles[Count] := tempHeader^.Description;
      Inc(Count);

      // end;
      tempGetHeader := nil;
      tempHeader := nil;
      FreeLibrary(dll);
    end;
  end;

begin
  if not InitDLL then
    Exit;

  if Path[length(Path)] <> '\' then
    Path := PChar(Path + '\');
  Count := 0;
  if FindFirst(Path + 'dsp*.dll', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory) <> faDirectory then
        TempLoadPlugin(PChar(Path + SearchRec.Name));
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;
// ******************************************************************************

function QBass_DSPActive: bool;
begin
  Result := false;
  if not InitDLL then
    Exit;
  Result := DSPActive;
end;
// ******************************************************************************

procedure QBass_DSPConfig;
begin
  if not InitDLL then
    Exit;
  if (DSPActive and PluginLoaded) and Assigned(DSPModule) then
    DSPModule^.Config(DSPModule);
end;
// ******************************************************************************

function QBass_DSPHeaderInfo: PAnsiChar;
begin
  if not InitDLL then
    Exit;
  Result := PAnsiChar(format('%s (%d)', [DSPHeader.Description,
    DSPHeader.Version]));
end;
// ******************************************************************************

function QBass_DSPModuleInfo: PAnsiChar;
begin
  if not InitDLL then
    Exit;
  Result := PAnsiChar(format('%s', [DSPModule.Description]));
end;

end.
