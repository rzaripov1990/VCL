unit Main;

  |---------------------------------------------
  |  author: Zaripov Ravil aka ZuBy            |
  | contact:                                   |
  |          mail: rzaripov1990@gmail.com      |
  |          web : http://zuby.ucoz.kz         |
  |          Kazakhstan, Semey, © 2010         |
  |--------------------------------------------|

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Bass,
  QBassUtils, QBCommon, QBDSP, QBVis, QBTags, Buttons, ComCtrls, Jpeg, PngImage, GifImg, MediaButton, MediaButtonText,
  MediaSlider, MediaGraphicEQ;

const
  WM_QBASS_MESSAGE = WM_USER + 21;

type
  TQBForm = class(TForm)
    OpenD: TOpenDialog;
    lvPlayList: TListView;
    Timer1: TTimer;
    cbDSP: TComboBox;
    Label1: TLabel;
    cbDevices: TComboBox;
    Label2: TLabel;
    imgCover: TImage;
    Label5: TLabel;
    pbVisRender: TPaintBox;
    Label6: TLabel;
    cbVIS: TComboBox;
    VisRender: TTimer;
    pbBack: TZMSMediaButton;
    pbNext: TZMSMediaButton;
    pbPlayPause: TZMSMediaButton;
    pbStop: TZMSMediaButton;
    pbOpen: TZMSMediaButton;
    pbShuffle: TZMSMediaButtonText;
    pbRepeat: TZMSMediaButtonText;
    mbEQ: TZMSMediaButtonText;
    mbEQReser: TZMSMediaButtonText;
    msProgress: TZMSMediaSlider;
    msLeft: TZMSMediaSlider;
    msRight: TZMSMediaSlider;
    msVolume: TZMSMediaSlider;
    msGraphicEQ: TZMSMediaGraphicEQ;
    msBalans: TZMSMediaSlider;
    msPreference: TZMSMediaButtonText;
    pbUseFading: TZMSMediaButtonText;
    pbAddURL: TZMSMediaButtonText;
    procedure lvPlayListDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbPlayPauseClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure pbStopClick(Sender: TObject);
    procedure pbOpenClick(Sender: TObject);
    procedure cbDSPSelect(Sender: TObject);
    procedure cbDevicesSelect(Sender: TObject);
    procedure pbVisRenderPaint(Sender: TObject);
    procedure VisRenderTimer(Sender: TObject);
    procedure cbVISSelect(Sender: TObject);
    procedure pbVisRenderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mbEQClick(Sender: TObject);
    procedure msProgressStartTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
    procedure msVolumeTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
    procedure msGraphicEQEQChange(Sender: TObject; const ID: Integer; const Position: Single;
      const SetPosition: Boolean);
    procedure mbEQReserClick(Sender: TObject);
    procedure msBalansTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
    procedure pbBackClick(Sender: TObject);
    procedure pbNextClick(Sender: TObject);
    procedure lvPlayListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure msPreferenceClick(Sender: TObject);
    procedure msProgressEndTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
    procedure pbUseFadingClick(Sender: TObject);
    procedure pbAddURLClick(Sender: TObject);
  private
    { Private declarations }
    MessageHandle: DWORD;
    procedure AddToListView(const Files: TStrings);
    procedure PlayID(const ID: Integer);
    procedure Clear;
  public
    { Public declarations }
    function ShowErrorMessage: Boolean;
    function FindGroupID(const Name: string): Integer;
    procedure TrackInfo(const FileName: string; out taginfo: QBASSTagItem; out Duration, Bitrate, Frequency: Cardinal);
    function FormatTime(const Sec: Integer): string;

    procedure QBMessage(var Msg: TMessage); message WM_QBASS_MESSAGE;
  end;

var
  QBForm: TQBForm;
  mCh: DWORD = 0;

  FileMask: string = '';
  stBitrate: string = '0 kbps';
  stFrequency: string = '0 kHz';

  DeviceCount: Cardinal = 0;
  DeviceIndex: Cardinal = 0;
  TrackingID: Integer = -1;

  DSPFileNames, DSPCaptions: QBArrString;
  VisFileNames, VisCaptions: QBArrString;
  blRemaining: Boolean = false;

implementation

uses
  ShowMsg;

{$R *.dfm}
// ******************************************************************************

procedure TQBForm.cbDevicesSelect(Sender: TObject);
begin
  if BASS_PluginFree(0) and BASS_Free then
  begin
    if BASS_Init(cbDevices.ItemIndex + 1, 44100, BASS_DEVICE_SPEAKERS, Application.Handle, nil) then
    begin
      QBass_PluginsLoad(PChar(ExtractFilePath(ParamStr(0)) + 'Plugins\'), {$IFDEF UNICODE} BASS_UNICODE {$ELSE} 0
{$ENDIF});
      FileMask := QBass_FileMask;

      BASS_SetConfig(BASS_CONFIG_FLOATDSP, 1);     // required !!! (winamp dsp 2.0; equalizer; dsp procedures)
      BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1); // enable read playlists (pls, m3u)
    end;
  end;
end;
// ******************************************************************************

procedure TQBForm.cbDSPSelect(Sender: TObject);
begin
  QBass_DSPDestroy;
  if cbDSP.ItemIndex > 0 then
    QBass_DSPCreate(PChar(DSPFileNames[cbDSP.ItemIndex - 1]));

  if QBass_DSPActive then
    QBass_DSPUpdate(mCh);
end;
// ******************************************************************************

procedure TQBForm.cbVISSelect(Sender: TObject);
begin
  QBass_VisUnload;
  if cbVIS.ItemIndex > 0 then
    QBass_VisLoad(PChar(VisFileNames[cbVIS.ItemIndex - 1]));

  if QBass_VisActive then
    QBass_VisResize(pbVisRender.Width, pbVisRender.Height);
end;
// ******************************************************************************

function TQBForm.FindGroupID(const Name: string): Integer;
var
  i, C: Integer;
begin
  Result := -1;
  if (Name = '') then
    exit;

  C := lvPlayList.Groups.Count;

  i := 0;
  while i < C do
  begin
    with lvPlayList.Groups.Items[i] do
    begin
      if Header = Name then
      begin
        Result := GroupID;
        Break;
      end;
    end;
    inc(i)
  end;
end;
// ******************************************************************************

function TQBForm.FormatTime(const Sec: Integer): string;
var
  H, S, M: Integer;
begin
  H := Sec div 3600;
  S := Sec mod 3600;
  M := S div 60;
  M := M + (H * 60);
  S := (S mod 60);
  if M > 99 then
    Result := format('%3d:%2.2d', [M, S])
  else
    Result := format('%2.2d:%2.2d', [M, S]);
end;
// ******************************************************************************

procedure TQBForm.FormResize(Sender: TObject);
begin
  QBass_VisResize(pbVisRender.Width, pbVisRender.Height);
end;
// ******************************************************************************

procedure TQBForm.AddToListView(const Files: TStrings);
var
  i, C: Integer;
  Title: string;
  Dur, Freq, Bitr: Cardinal;
  Item: QBASSTagItem;
begin
  C := Files.Count;

  lvPlayList.Items.BeginUpdate;
  i := 0;
  while i < C do
  begin
    with lvPlayList.Items.Add do
    begin
      TrackInfo(Files.Strings[i], Item, Dur, Bitr, Freq);

      if (Item.Title <> '') and (Item.Artist <> '') then
        Title := Item.Artist + ' - ' + Item.Title
      else if (Item.Title = '') and (Item.Artist <> '') then
        Title := Item.Artist
      else if (Item.Artist = '') and (Item.Title <> '') then
        Title := Item.Title
      else
        Title := ChangeFileExt(ExtractFileName(Item.FileName), '');

      Checked := true;
      Caption := Title;
      SubItems.Add(Item.Album);
      SubItems.Add(Item.Genre);
      SubItems.Add(UpperCase(Item.Ext));
      SubItems.Add(FormatTime(Dur));
      SubItems.Add(IntToStr(Bitr));
      SubItems.Add(IntToStr(Freq));
      SubItems.Add(Files.Strings[i]);

      if FindGroupID(ExtractFilePath(Files[i])) = -1 then
      begin
        with lvPlayList.Groups.Add do
        begin
          Header := ExtractFilePath(Files[i]);
          State := [lgsNormal, lgsCollapsible];
        end;
      end;
      GroupID := FindGroupID(ExtractFilePath(Files[i]));
    end;
    inc(i);
  end;
  lvPlayList.Items.EndUpdate;
end;
// ******************************************************************************

procedure TQBForm.pbAddURLClick(Sender: TObject);
var
  url: string;
begin
  url := InputBox('URL', '', '');
  if url <> '' then
  begin
    with lvPlayList.Items.Add do
    begin
      Checked := true;
      Caption := url;
      SubItems.Add('');
      SubItems.Add('');
      SubItems.Add('URL');
      SubItems.Add('');
      SubItems.Add('');
      SubItems.Add('');
      SubItems.Add(url);

      if FindGroupID('Radio/URL') = -1 then
      begin
        with lvPlayList.Groups.Add do
        begin
          Header := 'Radio/URL';
          State := [lgsNormal, lgsCollapsible];
        end;
      end;
      GroupID := FindGroupID('Radio/URL');
    end;
  end;
end;
// ******************************************************************************

procedure TQBForm.pbBackClick(Sender: TObject);
var
  i: Cardinal;
begin
  with lvPlayList do
  begin
    if (TrackingID <= 0) or (Items.Count = 0) then
      exit;

    i := 0;
    dec(TrackingID);
    while (not Items[TrackingID].Checked) do
    begin
      if (i = Items.Count) then
        Break
      else
        inc(i);
      dec(TrackingID);
      if TrackingID < 0 then
        Break;
    end;

    if TrackingID >= 0 then
    begin
      Items[TrackingID].Focused := true;
      PlayID(TrackingID);
    end;
  end;
end;
// ******************************************************************************

procedure TQBForm.pbNextClick(Sender: TObject);
var
  i: Cardinal;
begin
  with lvPlayList do
  begin
    if (TrackingID = Items.Count - 1) or (Items.Count = 0) then
      exit;

    i := 0;
    inc(TrackingID);
    while (not Items[TrackingID].Checked) do
    begin
      if (i = Items.Count) then
        Break
      else
        inc(i);
      inc(TrackingID);
      if TrackingID > Items.Count - 1 then
        Break;
    end;

    if TrackingID <= Items.Count - 1 then
    begin
      Items[TrackingID].Focused := true;
      PlayID(TrackingID);
    end;
  end;
end;
// ******************************************************************************

procedure TQBForm.pbOpenClick(Sender: TObject);
begin
  OpenD.Filter := FileMask + 'Cover Art|*.mp3;*.aac;*,ape;*.mpc;*.wv;*.spx;*.tta;*.ogg;*.oga;*.fla;*.flac;';
  if OpenD.Execute then
    AddToListView(OpenD.Files);
end;
// ******************************************************************************

procedure TQBForm.pbPlayPauseClick(Sender: TObject);
begin
  case BASS_ChannelIsActive(mCh) of
    BASS_ACTIVE_PLAYING:
      begin
        pbPlayPause.MediaButton := mbtPlay;
        if pbUseFading.Checked then
          QBass_Set(mCh, QBASS_SET_FADE_PAUSE, msVolume.Position / 100)
        else
          BASS_ChannelPause(mCh);
      end;
    BASS_ACTIVE_PAUSED:
      begin
        pbPlayPause.MediaButton := mbtPause;
        if pbUseFading.Checked then
          QBass_Set(mCh, QBASS_SET_FADE_PLAY, msVolume.Position / 100)
        else
          BASS_ChannelPlay(mCh, false);
      end;
    BASS_ACTIVE_STOPPED, BASS_ACTIVE_STALLED:
      begin
        pbPlayPause.MediaButton := mbtPlay;
        if pbUseFading.Checked then
        begin
          QBass_Set(mCh, QBASS_SET_POSITION, 0);
          QBass_Set(mCh, QBASS_SET_FADE_PLAY, msVolume.Position / 100);
        end
        else
          BASS_ChannelPlay(mCh, true);
      end;
  end;
end;
// ******************************************************************************

procedure TQBForm.Clear;
begin
  imgCover.Picture.Assign(nil);

  Timer1.Enabled := false;
  msProgress.Position := 0;
  msProgress.Max := 0;
  msProgress.Min := 0;
  msLeft.Position := 0;
  msRight.Position := 0;
  Label5.Caption := '';

  stBitrate := '0 kbps';
  stFrequency := '0 kHz';

  Caption := 'QBASS Test';
end;
// ******************************************************************************

procedure TQBForm.pbStopClick(Sender: TObject);
begin
  if mCh > 0 then
  begin
    if QBass_Status(mCh, false) <> QBASS_STATUS_STOP then
    begin
      if pbUseFading.Checked then
        QBass_Set(mCh, QBASS_SET_FADE_STOP, msVolume.Position / 100)
      else
        BASS_ChannelStop(mCh);
    end
    else
    begin
      if pbRepeat.Checked then
      begin
        QBass_Set(mCh, QBASS_SET_POSITION, 0);
        exit;
      end;

      if QBass_EQActive then
        QBASS_EQDestroy(mCh);

      QBass_MessageDel(mCh, QBASS_MESSAGE_END, Handle, MessageHandle);

      QBass_FreeStream(mCh);
      mCh := 0;

      Clear;
    end;
  end;

  pbPlayPause.MediaButton := mbtPlay;
end;
// ******************************************************************************

procedure TQBForm.pbUseFadingClick(Sender: TObject);
begin
  QBass_Set(mCh, QBASS_SET_FADING, 1000, Integer(pbUseFading.Checked));
end;
// ******************************************************************************

procedure QBass_RenderCoverArt(Image: TBitmap; const ImageData: TMemoryStream; const ImageMime: String);
var
  jpg: TJPEGImage;
  png: TPngImage;
  gif: TGIFImage;
  met: TMetafile;
  ico: TIcon;
begin
  Image.PixelFormat := pf32bit;
  if Pos(QBASS_EXT_BMP, ImageMime) > 0 then
  begin
    Image.LoadFromStream(ImageData);
  end
  else if (Pos(QBASS_EXT_JPG, ImageMime) > 0) then
  begin
    jpg := TJPEGImage.Create;
    jpg.CompressionQuality := 100;
    jpg.LoadFromStream(ImageData);
    Image.Assign(jpg);
    FreeAndNil(jpg);
  end
  else if Pos(QBASS_EXT_PNG, ImageMime) > 0 then
  begin
    png := TPngImage.Create;
    png.LoadFromStream(ImageData);
    Image.Assign(png);
    FreeAndNil(png);
  end
  else if Pos(QBASS_EXT_GIF, ImageMime) > 0 then
  begin
    gif := TGIFImage.Create;
    gif.LoadFromStream(ImageData);
    Image.Assign(gif);
    FreeAndNil(gif);
  end
  else if (Pos(QBASS_EXT_WMF, ImageMime) > 0) or (Pos(QBASS_EXT_EMF, ImageMime) > 0) then
  begin
    met := TMetafile.Create;
    met.LoadFromStream(ImageData);
    Image.Assign(met);
    FreeAndNil(met);
  end
  else if Pos(QBASS_EXT_ICO, ImageMime) > 0 then
  begin
    ico := TIcon.Create;
    ico.LoadFromStream(ImageData);
    Image.Assign(ico);
    FreeAndNil(ico);
  end;
end;
// ******************************************************************************

procedure TQBForm.PlayID(const ID: Integer);
var
  FileName, S: String;
  cdDuration: Single;

  ImageInfo: QBASSPictureInfo;
  ImageData: TBytesStream;
  NetItem: QBASSTagItem;
begin
  pbStopClick(nil);
  pbStopClick(nil); // нужен двойной запуск этой процедуры

  if ID = -1 then
    exit;

  TrackingID := ID;
  FileName := lvPlayList.Items.Item[ID].SubItems.Strings[6];

  if QBass_IsUrl(FileName) then
    mCh := QBass_CreateURL(Pointer(FileName), {$IFDEF UNICODE} BASS_UNICODE {$ELSE} 0 {$ENDIF}, nil)
  else
    mCh := QBass_CreateFile(Pointer(FileName), {$IFDEF UNICODE} BASS_UNICODE or
{$ENDIF} BASS_SAMPLE_FLOAT or BASS_STREAM_PRESCAN);

  if ShowErrorMessage then
    exit;

  if QBass_IsUrl(FileName) then
  begin
    FillChar(NetItem, sizeof(NetItem), 0);
    NetItem.FileName := FileName;
    NetItem.Ext := UpperCase(copy(ExtractFileExt(FileName), 2, length(ExtractFileExt(FileName))));

    if QBass_ReadNetTags(mCh, NetItem) then
    begin
      with lvPlayList.Items.Item[ID] do
      begin
        if (NetItem.Title <> '') and (NetItem.Artist <> '') then
          Caption := NetItem.Artist + ' - ' + NetItem.Title
        else if (NetItem.Title = '') and (NetItem.Artist <> '') then
          Caption := NetItem.Artist
        else if (NetItem.Artist = '') and (NetItem.Title <> '') then
          Caption := NetItem.Title;

        SubItems.Strings[0] := NetItem.Album;
        SubItems.Strings[1] := NetItem.Genre;
        SubItems.Strings[2] := NetItem.Ext;
        SubItems.Strings[3] := '';
        SubItems.Strings[4] := NetItem.Comment;
        SubItems.Strings[5] := '44100';
      end;
    end;
  end;

  if mbEQ.Checked then
    mbEQClick(nil);

  if QBass_DSPActive then
    QBass_DSPUpdate(mCh);

  pbUseFadingClick(nil);

  QBass_Set(mCh, QBASS_SET_BALANS, msBalans.Position / 100);

  if pbUseFading.Checked then
    QBass_Set(mCh, QBASS_SET_FADE_PLAY, msVolume.Position / 100)
  else
  begin
    QBass_Set(mCh, QBASS_SET_VOLUME, msVolume.Position / 100);
    BASS_ChannelPlay(mCh, true);
  end;

  Timer1.Interval := BASS_GetConfig(BASS_CONFIG_UPDATEPERIOD);
  Timer1.Enabled := true;

  MessageHandle := QBass_MessageAdd(mCh, QBASS_MESSAGE_END, Handle, WM_QBASS_MESSAGE);

  cdDuration := QBass_Get(mCh, QBASS_GET_DURATION);

  with lvPlayList.Items.Item[ID] do
  begin
    S := '(' + SubItems[2] + ')  ' + Caption;
    stBitrate := SubItems[4] + ' kbps';
    stFrequency := SubItems[5] + ' Hz';
  end;

  ImageData := TBytesStream.Create;
  FillChar(ImageInfo, sizeof(ImageInfo), 0);
  if QBass_ReadCover(mCh, ImageInfo, ImageData) then
  begin
    Label5.Caption := ImageInfo.mime;
    QBass_RenderCoverArt(imgCover.Picture.Bitmap, ImageData, Label5.Caption);
    imgCover.Repaint;
  end;
  FreeAndNil(ImageData);
  FillChar(ImageInfo, sizeof(ImageInfo), 0);

  msProgress.Max := cdDuration * 1000;

  Caption := format('QBASS Test [ %s : %s : %s, %s ]', [FormatTime(Trunc(cdDuration)), S, stBitrate, stFrequency]);

  pbPlayPause.MediaButton := mbtPause;
end;
// ******************************************************************************

procedure TQBForm.lvPlayListDblClick(Sender: TObject);
begin
  PlayID(lvPlayList.ItemIndex);
end;
// ******************************************************************************

procedure TQBForm.lvPlayListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      PlayID(lvPlayList.ItemIndex);
    Ord('A'), Ord('a'):
      if (ssCtrl in Shift) then
        lvPlayList.SelectAll;
    Ord('O'), Ord('0'):
      if (ssCtrl in Shift) then
        pbOpenClick(nil);
  end;
end;
// ******************************************************************************

procedure TQBForm.pbVisRenderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if QBass_VisActive then
    QBass_VisClicked(X, Y, Integer(Button));
end;
// ******************************************************************************

procedure TQBForm.pbVisRenderPaint(Sender: TObject);
begin
  if not QBass_VisActive then
    PatBlt(pbVisRender.Canvas.Handle, 0, 0, pbVisRender.Width, pbVisRender.Height, BLACKNESS)
  else
    QBass_VisRender(mCh, pbVisRender.Canvas.Handle);
end;
// ******************************************************************************

procedure TQBForm.QBMessage(var Msg: TMessage);
begin
  inherited;
  case Msg.WParam of
    QBASS_MESSAGE_END:
      begin
        pbStopClick(nil);
        pbNextClick(nil);
      end;
  end;
end;
// ******************************************************************************

function TQBForm.ShowErrorMessage: Boolean;
var
  ec: Cardinal;
begin
  ec := BASS_ErrorGetCode;
  Result := ec > 0;
  if Result then
  begin
    if ec > 46 then
      ec := 26;
    ShowMessageEx('Error', 'Error code: ' + IntToStr(ec) + #13 + QBASSErrorCodes[ec]);
  end;
end;
// ******************************************************************************

procedure TQBForm.Timer1Timer(Sender: TObject);
begin
  msProgress.Position := QBass_Get(mCh, QBASS_GET_POSITION) * 1000;

  msLeft.Position := MulDiv(100, LOWORD(BASS_ChannelGetLevel(mCh)), 32768);
  msRight.Position := MulDiv(100, HIWORD(BASS_ChannelGetLevel(mCh)), 32768);
end;
// ******************************************************************************

procedure TQBForm.VisRenderTimer(Sender: TObject);
begin
  if QBass_VisActive then
    pbVisRender.Repaint;
end;
// ******************************************************************************

procedure TQBForm.msPreferenceClick(Sender: TObject);
begin
  if QBass_DSPActive then
    QBass_DSPConfig;
end;
// ******************************************************************************

procedure TQBForm.msBalansTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
begin
  if not SetPosition then
    QBass_Set(mCh, QBASS_SET_BALANS, Position / 100);
end;
// ******************************************************************************

procedure TQBForm.mbEQClick(Sender: TObject);
var
  i: Integer;
begin
  QBASS_EQDestroy(mCh);
  mbEQ.Caption := 'OFF';

  if mbEQ.Checked then
  begin
    mbEQ.Caption := 'ON ';
    QBass_EQCreate(mCh, 2.0, QBASS_EQ_MODE_18);
    msGraphicEQ.BandCount := 18;

    for i := 0 to msGraphicEQ.BandCount - 1 do
      QBass_EQSetPosition(i, msGraphicEQ.GetBandValue(i));
    QBass_EQPreamp(msGraphicEQ.PreAmp);
  end;
end;
// ******************************************************************************

procedure TQBForm.mbEQReserClick(Sender: TObject);
begin
  msGraphicEQ.ResetEQ;
end;
// ******************************************************************************

procedure TQBForm.msGraphicEQEQChange(Sender: TObject; const ID: Integer; const Position: Single;
  const SetPosition: Boolean);
begin
  if not SetPosition then
  begin
    QBass_EQSetPosition(ID, Position);
    QBass_EQPreamp(msGraphicEQ.PreAmp);
  end;
end;
// ******************************************************************************

procedure TQBForm.msProgressEndTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
begin
  if not SetPosition then
  begin
    if pbUseFading.Checked then
      QBass_Set(mCh, QBASS_SET_FADE_POSITION, Position / 1000, msVolume.Position / 100)
    else
      QBass_Set(mCh, QBASS_SET_POSITION, Position / 1000);
  end;
end;
// ******************************************************************************

procedure TQBForm.msProgressStartTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
begin
  if pbUseFading.Checked then
    QBass_Set(mCh, QBASS_SET_VOLUME, 0);
end;
// ******************************************************************************

procedure TQBForm.msVolumeTracking(Sender: TObject; const Position: Single; const SetPosition: Boolean);
begin
  if not SetPosition then
  begin
    if pbUseFading.Checked then
      QBass_Set(mCh, QBASS_SET_FADE_VOLUME, Position / 100)
    else
      QBass_Set(mCh, QBASS_SET_VOLUME, Position / 100);
  end;
end;
// ******************************************************************************

procedure TQBForm.TrackInfo(const FileName: string; out taginfo: QBASSTagItem;
  out Duration, Bitrate, Frequency: Cardinal);
var
  temp: DWORD;
begin
  temp := QBass_CreateFile(Pointer(FileName), {$IFDEF UNICODE} BASS_UNICODE or {$ENDIF} BASS_STREAM_DECODE);

  if temp > 0 then
  begin
    // required
    taginfo.FileName := FileName;
    taginfo.Ext := copy(ExtractFileExt(taginfo.FileName), 2, length(ExtractFileExt(taginfo.FileName)));
    // ...

    QBass_ReadTags(temp, taginfo); // read tags from bass

    Duration := Trunc(QBass_Get(temp, QBASS_GET_DURATION)); // in sec
    Bitrate := Trunc(QBass_Get(temp, QBASS_GET_BITRATE));
    Frequency := Trunc(QBass_Get(temp, QBASS_GET_SAMPLERATE)); // in Herz
    QBass_FreeStream(temp);
  end
  else
    ShowErrorMessage;
end;
// ******************************************************************************

initialization

ReportMemoryLeaksOnShutdown := true;

end.
