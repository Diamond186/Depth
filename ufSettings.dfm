object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 323
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 21
  object pFooter: TPanel
    Left = 0
    Top = 282
    Width = 589
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      589
      41)
    object bCancel: TButton
      Left = 507
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
      Left = 426
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
    Width = 172
    Height = 282
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 1
    object cbPairs: TComboBox
      Left = 15
      Top = 47
      Width = 145
      Height = 29
      Style = csDropDownList
      DropDownCount = 10
      TabOrder = 0
    end
    object eBoldAmount: TEdit
      Left = 15
      Top = 127
      Width = 145
      Height = 29
      NumbersOnly = True
      TabOrder = 1
      TextHint = 'Bold Amount'
    end
    object eMinAmount: TEdit
      Left = 15
      Top = 92
      Width = 145
      Height = 29
      NumbersOnly = True
      TabOrder = 2
      TextHint = 'Min Amount'
    end
    object eSearchPair: TEdit
      Left = 15
      Top = 12
      Width = 145
      Height = 29
      TabOrder = 3
      TextHint = 'Search'
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
