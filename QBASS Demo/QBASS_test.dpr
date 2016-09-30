program QBASS_test;

  |---------------------------------------------
  |  author: Zaripov Ravil aka ZuBy            |
  | contact:                                   |
  |          mail: rzaripov1990@gmail.com      |
  |          web : http://zuby.ucoz.kz         |
  |          Kazakhstan, Semey, © 2010         |
  |--------------------------------------------|

uses
  Windows, Forms, SysUtils, MMSystem, Main in 'Main.pas' {QBForm} , bass in 'bass.pas',
  QBassUtils in 'COMPS\QBassUtils.pas', QBCommon in 'COMPS\QBCommon.pas', QBTags in 'COMPS\QBTags.pas', QBDSP in 'COMPS\QBDSP.pas',
  QBVis in 'COMPS\QBVis.pas', SLCanvas32 in 'COMPS\SLCanvas32.pas', ShowMsg in 'ShowMsg.pas';

{$R *.res}

var
  I: integer;
  dInfo: BASS_DEVICEINFO;
  path: PChar;

begin
  Application.Initialize;
{$IFDEF VER180}
  Application.MainFormOnTaskbar := True;
{$ENDIF}
  Application.Title := 'QBASS Test';
  Application.CreateForm(TQBForm, QBForm);

  if QBass_Init(BASSVERSION) then // check version
  begin
    DeviceCount := waveOutGetNumDevs; // uses MMSystem
    DeviceIndex := 0;

    for I := 1 to DeviceCount do
    begin
      if BASS_Init(I, 44100, BASS_DEVICE_SPEAKERS, Application.Handle, nil) then
      begin
        FillChar(dInfo, sizeof(dInfo), 0);
        DeviceIndex := I;
        BASS_GetDeviceInfo(I, dInfo);
        QBForm.cbDevices.Items.Add(string(dInfo.name));
        Break;
      end;
    end;

    if DeviceIndex = 0 then
    begin
      QBForm.cbDevices.Items.Add('(No Sound)');
      ShowMessageEx('Error', 'Error code:' + IntToStr(BASS_ErrorGetCode));
    end;

    QBForm.cbDevices.ItemIndex := 0;

    path := PChar(ExtractFilePath(ParamStr(0)) + 'Plugins\');
    if DirectoryExists(path) then
      QBass_PluginsLoad(path, {$IFDEF UNICODE} BASS_UNICODE {$ELSE} 0 {$ENDIF}); // load Bass plugins
    FileMask := QBass_FileMask; // get file mask
    // ...

    // load Winamp DSP plugins
    QBass_DSPPluginsLoad(path, DSPFileNames, DSPCaptions);
    for I := 0 to High(DSPFileNames) do
      QBForm.cbDSP.Items.Add(DSPCaptions[I]);
    // ...

    // load Sonique Vis plugins
    QBass_VisPluginsLoad(path, VisFileNames, VisCaptions);
    for I := 0 to High(VisFileNames) do
      QBForm.cbVis.Items.Add(VisCaptions[I]);
    // ...

    BASS_SetConfig(BASS_CONFIG_FLOATDSP, 1); // required !!! (winamp dsp 2.0; equalizer; dsp procedures)

    BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1); // enable read playlists (pls, m3u)
    BASS_SetConfig(BASS_CONFIG_NET_PREBUF, 0);

    QBass_VisSetOptions(QBASS_VIS_ALL_EFFECTS); // set visual render mode
    QBass_VisConfigFile('plugins.ini');
    // set file name(save / load configuration)

    Application.Run;
  end;

  if QBass_DSPActive then
    QBass_DSPDestroy;

  if QBass_VisActive then
    QBass_VisUnload;

  Bass_PluginFree(0); // free all plugins

  QBass_DeInit;

end.
