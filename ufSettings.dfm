object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 323
  ClientWidth = 833
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 21
  object pFooter: TPanel
    Left = 0
    Top = 282
    Width = 833
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      833
      41)
    object bCancel: TButton
      Left = 751
      Top = 7
      Width = 75
      Height = 30
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object bSave: TButton
      Left = 670
      Top = 7
      Width = 75
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Save'
      ModalResult = 1
      TabOrder = 1
    end
  end
  object pMain: TPanel
    Left = 417
    Top = 0
    Width = 416
    Height = 282
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 103
      Width = 87
      Height = 21
      Caption = 'Min Amount'
    end
    object Label2: TLabel
      Left = 16
      Top = 157
      Width = 91
      Height = 21
      Caption = 'Bold Amount'
    end
    object eBoldAmount: TEdit
      Left = 16
      Top = 176
      Width = 145
      Height = 29
      NumbersOnly = True
      TabOrder = 0
      TextHint = 'Bold Amount'
    end
    object eMinAmount: TEdit
      Left = 15
      Top = 122
      Width = 146
      Height = 29
      NumbersOnly = True
      TabOrder = 1
      TextHint = 'Min Amount'
    end
    object GroupBox1: TGroupBox
      Left = 6
      Top = 2
      Width = 343
      Height = 96
      Caption = 'Pair'
      TabOrder = 2
      object Label3: TLabel
        Left = 167
        Top = 43
        Width = 6
        Height = 21
        Caption = '/'
      end
      object cbPair1: TComboBox
        Left = 10
        Top = 59
        Width = 145
        Height = 29
        Style = csDropDownList
        DropDownCount = 10
        TabOrder = 0
      end
      object eSearchPair1: TEdit
        Left = 10
        Top = 24
        Width = 145
        Height = 29
        TabOrder = 1
        TextHint = 'Search'
      end
      object cbPair2: TComboBox
        Left = 187
        Top = 59
        Width = 145
        Height = 29
        Style = csDropDownList
        DropDownCount = 10
        TabOrder = 2
      end
      object eSearchPair2: TEdit
        Left = 187
        Top = 24
        Width = 145
        Height = 29
        TabOrder = 3
        TextHint = 'Search'
      end
    end
    object GroupBox2: TGroupBox
      Left = 176
      Top = 103
      Width = 233
      Height = 132
      Caption = 'Range'
      TabOrder = 3
      object rbPercent: TRadioButton
        Left = 9
        Top = 24
        Width = 73
        Height = 17
        Caption = 'Percent'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbRangeClick
      end
      object rbAmount: TRadioButton
        Left = 9
        Top = 81
        Width = 80
        Height = 17
        Caption = 'Amount'
        TabOrder = 1
        OnClick = rbRangeClick
      end
      object cbPercents: TComboBox
        Left = 102
        Top = 18
        Width = 76
        Height = 29
        Style = csDropDownList
        ItemIndex = 9
        TabOrder = 2
        Text = '50 %'
        Items.Strings = (
          '5 %'
          '10 %'
          '15 %'
          '20 %'
          '25 %'
          '30 %'
          '35 %'
          '40 %'
          '45 %'
          '50 %'
          '55 %'
          '60 %'
          '65 %'
          '70 %'
          '75 %'
          '80 %'
          '90 %'
          '95 %'
          '100 %')
      end
      object eMinRange: TEdit
        Left = 102
        Top = 58
        Width = 121
        Height = 29
        Enabled = False
        TabOrder = 3
        TextHint = 'Min Range'
      end
      object eMaxRange: TEdit
        Left = 102
        Top = 93
        Width = 121
        Height = 29
        Enabled = False
        TabOrder = 4
        TextHint = 'Max Range'
      end
    end
  end
  object vstExchanges: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 417
    Height = 282
    Align = alLeft
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
    RootNodeCount = 9
    TabOrder = 2
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    OnChecked = vstExchangesChecked
    OnGetText = vstExchangesGetText
    OnInitNode = vstExchangesInitNode
    Columns = <
      item
        CaptionAlignment = taCenter
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment]
        Position = 0
        Width = 133
        WideText = 'Exchange'
      end
      item
        CaptionAlignment = taCenter
        CheckType = ctNone
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment]
        Position = 1
        Width = 130
        WideText = 'Last Price'
      end
      item
        CaptionAlignment = taCenter
        CheckType = ctNone
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment]
        Position = 2
        Width = 150
        WideText = '24h Volume'
      end>
  end
end
