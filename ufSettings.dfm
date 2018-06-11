object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 323
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 21
  object cbExchangeList: TCheckListBox
    Left = 0
    Top = 0
    Width = 289
    Height = 282
    Align = alLeft
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ItemHeight = 21
    Items.Strings = (
      'BiBox'
      'Binance'
      'Bitfinex'
      'Bitstamp'
      'Bittrex'
      'HitBTC'
      'Huobi'
      'Kraken'
      'Okex')
    TabOrder = 0
  end
  object pFooter: TPanel
    Left = 0
    Top = 282
    Width = 457
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      457
      41)
    object bCancel: TButton
      Left = 375
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
      Left = 294
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
    Left = 289
    Top = 0
    Width = 168
    Height = 282
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 2
    ExplicitLeft = 176
    ExplicitTop = 28
    ExplicitWidth = 265
    ExplicitHeight = 213
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
  object VirtualStringTree1: TVirtualStringTree
    Left = 83
    Top = 127
    Width = 200
    Height = 100
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 3
    Columns = <>
  end
end
