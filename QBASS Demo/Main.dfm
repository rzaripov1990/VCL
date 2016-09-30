object QBForm: TQBForm
  Left = 213
  Top = 148
  Caption = 'QBASS Test'
  ClientHeight = 480
  ClientWidth = 971
  Color = clBtnFace
  Constraints.MinHeight = 518
  Constraints.MinWidth = 987
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnResize = FormResize
  DesignSize = (
    971
    480)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 82
    Width = 96
    Height = 13
    Caption = 'Winamp DSP Plugins'
  end
  object Label2: TLabel
    Left = 336
    Top = 82
    Width = 32
    Height = 13
    Caption = 'Device'
  end
  object imgCover: TImage
    Left = 714
    Top = 240
    Width = 249
    Height = 207
    Anchors = [akRight, akBottom]
    Center = True
    Proportional = True
    Stretch = True
  end
  object Label5: TLabel
    Left = 714
    Top = 455
    Width = 249
    Height = 17
    Anchors = [akRight, akBottom]
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object pbVisRender: TPaintBox
    Left = 714
    Top = 54
    Width = 249
    Height = 177
    Anchors = [akTop, akRight]
    OnMouseDown = pbVisRenderMouseDown
    OnPaint = pbVisRenderPaint
  end
  object Label6: TLabel
    Left = 714
    Top = 8
    Width = 93
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Sonique VIS Plugins'
  end
  object pbBack: TZMSMediaButton
    Left = 8
    Top = 13
    Width = 30
    Height = 30
    Cursor = crHandPoint
    Hint = #1055#1088#1077#1076#1099#1076#1091#1097#1080#1081' '#1090#1088#1077#1082
    ParentCustomHint = False
    MediaButton = mbtPrevious
    BorderColor = clBlack
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    DownBrushColor = 12235692
    DownPenColor = 9470839
    TransparentColor = clBtnFace
    OnClick = pbBackClick
  end
  object pbNext: TZMSMediaButton
    Left = 41
    Top = 13
    Width = 30
    Height = 30
    Cursor = crHandPoint
    Hint = #1057#1083#1077#1076#1091#1102#1097#1080#1081' '#1090#1088#1077#1082
    ParentCustomHint = False
    MediaButton = mbtNext
    BorderColor = clBlack
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    DownBrushColor = 12235692
    DownPenColor = 9470839
    TransparentColor = clBtnFace
    OnClick = pbNextClick
  end
  object pbPlayPause: TZMSMediaButton
    Left = 73
    Top = 8
    Width = 40
    Height = 40
    Cursor = crHandPoint
    Hint = #1042#1086#1089#1087#1088#1086#1080#1079#1074#1077#1089#1090#1080'/'#1055#1072#1091#1079#1072
    ParentCustomHint = False
    MediaButton = mbtPlay
    BorderColor = clBlack
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    DownBrushColor = 12235692
    DownPenColor = 9470839
    TransparentColor = clBtnFace
    OnClick = pbPlayPauseClick
  end
  object pbStop: TZMSMediaButton
    Left = 118
    Top = 13
    Width = 30
    Height = 30
    Cursor = crHandPoint
    Hint = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
    ParentCustomHint = False
    MediaButton = mbtStop
    BorderColor = clBlack
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    DownBrushColor = 12235692
    DownPenColor = 9470839
    TransparentColor = clBtnFace
    OnClick = pbStopClick
  end
  object pbOpen: TZMSMediaButton
    Left = 150
    Top = 13
    Width = 30
    Height = 30
    Cursor = crHandPoint
    Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1092#1072#1081#1083#1099
    ParentCustomHint = False
    MediaButton = mbtOpen
    BorderColor = clBlack
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    DownBrushColor = 12235692
    DownPenColor = 9470839
    TransparentColor = clBtnFace
    OnClick = pbOpenClick
  end
  object pbShuffle: TZMSMediaButtonText
    Left = 198
    Top = 8
    Width = 55
    Height = 16
    Caption = 'SHUFFLE'
    Alignment = taCenter
    ButtonMode = mbmChecked
    BorderType = mbbRound
    BorderColor = 9470839
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = 9470839
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = 14998738
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = 12235692
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = []
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = 9470839
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold]
  end
  object pbRepeat: TZMSMediaButtonText
    Left = 198
    Top = 23
    Width = 55
    Height = 16
    Caption = 'REPEAT'
    Alignment = taCenter
    ButtonMode = mbmChecked
    BorderType = mbbRound
    BorderColor = 9470839
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = 9470839
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = 14998738
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = 12235692
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = []
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = 9470839
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold]
  end
  object mbEQ: TZMSMediaButtonText
    Left = 438
    Top = 8
    Width = 20
    Height = 13
    Caption = 'OFF'
    Anchors = [akTop, akRight]
    Alignment = taCenter
    ButtonMode = mbmChecked
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = clRed
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = clSilver
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = clSilver
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = [fsBold]
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = clLime
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold, fsUnderline]
    AutoSize = True
    OnClick = mbEQClick
  end
  object mbEQReser: TZMSMediaButtonText
    Left = 433
    Top = 27
    Width = 31
    Height = 13
    Caption = 'RESET'
    Anchors = [akTop, akRight]
    Alignment = taCenter
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = clBlack
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = clGray
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = clSilver
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = [fsBold]
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = clBlack
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold, fsUnderline]
    AutoSize = True
    OnClick = mbEQReserClick
  end
  object msProgress: TZMSMediaSlider
    Left = 8
    Top = 50
    Width = 184
    Height = 13
    Hint = #1055#1088#1086#1075#1088#1077#1089#1089
    BorderType = msbRound
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    Indent = 4
    ThumbSize = 25.000000000000000000
    SnapBuffer = 3.000000000000000000
    Transparent = True
    TransparentColor = clBtnFace
    OnStartTracking = msProgressStartTracking
    OnEndTracking = msProgressEndTracking
  end
  object msLeft: TZMSMediaSlider
    Left = 8
    Top = 66
    Width = 91
    Height = 10
    Cursor = crDefault
    BorderType = msbRound
    BrushColor = 5774818
    PenColor = clWhite
    HotBrushColor = 6960868
    HotPenColor = clWhite
    Max = 100.000000000000000000
    Indent = 1
    ThumbSize = 10.000000000000000000
    SnapBuffer = 3.000000000000000000
    SliderThumb = mstProgress
    Transparent = True
  end
  object msRight: TZMSMediaSlider
    Left = 101
    Top = 66
    Width = 91
    Height = 10
    Cursor = crDefault
    BorderType = msbRound
    BrushColor = 5774818
    PenColor = clWhite
    HotBrushColor = 6960868
    HotPenColor = clWhite
    Max = 100.000000000000000000
    Indent = 1
    ThumbSize = 10.000000000000000000
    SnapBuffer = 3.000000000000000000
    SliderThumb = mstProgress
    RenderMode = mrmRevers
    Transparent = True
  end
  object msVolume: TZMSMediaSlider
    Left = 198
    Top = 50
    Width = 55
    Height = 13
    Hint = #1043#1088#1086#1084#1082#1086#1089#1090#1100
    BorderType = msbRound
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    Max = 100.000000000000000000
    Position = 100.000000000000000000
    Indent = 4
    ThumbSize = 20.000000000000000000
    CenterPos = 100.000000000000000000
    CenterStop = True
    SnapBuffer = 3.000000000000000000
    Transparent = True
    TransparentColor = clBtnFace
    OnTracking = msVolumeTracking
    OnStartTracking = msVolumeTracking
    OnEndTracking = msVolumeTracking
  end
  object msGraphicEQ: TZMSMediaGraphicEQ
    Left = 472
    Top = 11
    Width = 225
    Height = 35
    Anchors = [akTop, akRight]
    Max = 30.000000000000000000
    PreAmpMax = 20.000000000000000000
    BandCount = 18
    BorderType = mebRound
    CurveColor = 9470839
    MiddleColor = 14998738
    OnEQChange = msGraphicEQEQChange
  end
  object msBalans: TZMSMediaSlider
    Left = 198
    Top = 66
    Width = 55
    Height = 10
    Hint = #1041#1072#1083#1072#1085#1089
    BorderType = msbRound
    BrushColor = 9470839
    PenColor = 9470839
    HotBrushColor = 14998738
    HotPenColor = 9470839
    Max = 100.000000000000000000
    Min = -100.000000000000000000
    Indent = 2
    ThumbSize = 20.000000000000000000
    CenterStop = True
    SnapActive = True
    SnapBuffer = 5.000000000000000000
    SliderThumb = mstProgress
    RenderMode = mrmCenter
    Transparent = True
    TransparentColor = clBtnFace
    OnTracking = msBalansTracking
    OnStartTracking = msBalansTracking
    OnEndTracking = msBalansTracking
  end
  object msPreference: TZMSMediaButtonText
    Left = 243
    Top = 101
    Width = 76
    Height = 21
    Caption = 'Preference'
    Alignment = taCenter
    BorderType = mbbRound
    BorderColor = 9470839
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = 9470839
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = 14998738
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = 12235692
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = []
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = 9470839
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold]
    OnClick = msPreferenceClick
  end
  object pbUseFading: TZMSMediaButtonText
    Left = 259
    Top = 8
    Width = 102
    Height = 16
    Caption = 'USE FADING'
    Alignment = taCenter
    ButtonMode = mbmChecked
    BorderType = mbbRound
    BorderColor = 9470839
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = 9470839
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = clGray
    HotFont.Height = -11
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = 12235692
    DownFont.Height = -11
    DownFont.Name = 'Tahoma'
    DownFont.Style = []
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = 9470839
    CheckedFont.Height = -11
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold, fsUnderline]
    OnClick = pbUseFadingClick
  end
  object pbAddURL: TZMSMediaButtonText
    Left = 180
    Top = 8
    Width = 12
    Height = 19
    Caption = '+'
    TransparentColor = clBlack
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = clBlack
    NormalFont.Height = -16
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    HotFont.Charset = DEFAULT_CHARSET
    HotFont.Color = clGray
    HotFont.Height = -16
    HotFont.Name = 'Tahoma'
    HotFont.Style = [fsBold]
    DownFont.Charset = DEFAULT_CHARSET
    DownFont.Color = clSilver
    DownFont.Height = -16
    DownFont.Name = 'Tahoma'
    DownFont.Style = []
    CheckedFont.Charset = DEFAULT_CHARSET
    CheckedFont.Color = clBlack
    CheckedFont.Height = -16
    CheckedFont.Name = 'Tahoma'
    CheckedFont.Style = [fsBold, fsUnderline]
    AutoSize = True
    OnClick = pbAddURLClick
  end
  object lvPlayList: TListView
    Left = 8
    Top = 128
    Width = 695
    Height = 344
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Checkboxes = True
    Columns = <
      item
        Caption = 'Artist - Title'
        MinWidth = 250
        Width = 250
      end
      item
        Caption = 'Album'
        MinWidth = 100
        Width = 100
      end
      item
        Caption = 'Genre'
        MinWidth = 100
        Width = 100
      end
      item
        Caption = 'Ext'
        MinWidth = 50
      end
      item
        Caption = 'Duration'
        MinWidth = 53
        Width = 53
      end
      item
        Caption = 'Bitrate'
        MinWidth = 50
      end
      item
        Caption = 'Frequency'
        MinWidth = 70
        Width = 70
      end
      item
        Caption = 'FileName'
        Width = 0
      end>
    Ctl3D = False
    MultiSelect = True
    GroupView = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvPlayListDblClick
    OnKeyUp = lvPlayListKeyUp
  end
  object cbDSP: TComboBox
    Left = 8
    Top = 101
    Width = 229
    Height = 21
    Style = csDropDownList
    DropDownCount = 10
    ItemIndex = 0
    TabOrder = 1
    Text = '(Disabled)'
    OnSelect = cbDSPSelect
    Items.Strings = (
      '(Disabled)')
  end
  object cbDevices: TComboBox
    Left = 336
    Top = 101
    Width = 367
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnSelect = cbDevicesSelect
  end
  object cbVIS: TComboBox
    Left = 714
    Top = 27
    Width = 249
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    DropDownCount = 20
    ItemIndex = 0
    TabOrder = 3
    Text = '(Disabled)'
    OnSelect = cbVISSelect
    Items.Strings = (
      '(Disabled)')
  end
  object OpenD: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofNoTestFileCreate, ofNoNetworkButton, ofEnableSizing, ofDontAddToRecent]
    Left = 24
    Top = 136
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 0
    OnTimer = Timer1Timer
    Left = 16
    Top = 240
  end
  object VisRender: TTimer
    Interval = 21
    OnTimer = VisRenderTimer
    Left = 16
    Top = 184
  end
end
