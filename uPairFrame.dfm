object framePair: TframePair
  Left = 0
  Top = 0
  Width = 250
  Height = 305
  Align = alLeft
  TabOrder = 0
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 305
    Align = alLeft
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object vstBTC: TVirtualStringTree
      Left = 0
      Top = 57
      Width = 250
      Height = 212
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoDrag, hoShowSortGlyphs, hoVisible]
      HintMode = hmHint
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoTristateTracking, toAutoChangeScale]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnGetText = vstBTCGetText
      OnPaintText = vstBTCPaintText
      OnGetHint = vstBTCGetHint
      Columns = <
        item
          CaptionAlignment = taCenter
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment]
          Position = 0
          Width = 125
          WideText = 'Bids'
        end
        item
          CaptionAlignment = taCenter
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coUseCaptionAlignment]
          Position = 1
          Width = 125
          WideText = 'Asks'
        end>
    end
    object pHeader: TPanel
      Left = 0
      Top = 0
      Width = 250
      Height = 57
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object pMainHeader: TPanel
        Left = 25
        Top = 0
        Width = 205
        Height = 57
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitLeft = 160
        ExplicitTop = 10
        ExplicitWidth = 102
        ExplicitHeight = 41
        object Label1: TLabel
          Left = 0
          Top = 17
          Width = 205
          Height = 21
          Align = alTop
          Alignment = taCenter
          Caption = 'BTC - USD'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ExplicitTop = 0
          ExplicitWidth = 70
        end
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 205
          Height = 17
          Align = alTop
          Alignment = taCenter
          Caption = 'min -max'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ExplicitTop = 21
          ExplicitWidth = 54
        end
        object lPrice: TLabel
          Left = 0
          Top = 38
          Width = 205
          Height = 19
          Align = alClient
          Alignment = taCenter
          Caption = 'Price'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitWidth = 28
          ExplicitHeight = 17
        end
      end
      object pRightHeader: TPanel
        Left = 230
        Top = 0
        Width = 20
        Height = 57
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object iClose: TImage
          Left = 0
          Top = 0
          Width = 20
          Height = 20
          Cursor = crHandPoint
          Align = alTop
          Picture.Data = {
            0954506E67496D61676589504E470D0A1A0A0000000D49484452000000140000
            00140803000000BA57ED3F000000F0504C5445000000E25438E64B3BE74A3AE7
            4C3BE54C3AE74A3CE74C3CE64A3CDA4848FF0000E54C3AE74C3CE74D3B444440
            444440444440FF3F3FE74C3BDC4B3C6D4845444440D84B3C444440E54B3AE64B
            3CE74A3AD4552AE74B3CE54B3CE54C3CE44A3CE44A3CE34A3CE54C3BE74B3CDF
            3F3FE54B3BFF3333E84D3DE74A3BFF7F00E74C3CE74C3CE44C3CE44C3CE74C3C
            E64C3CE14C3CE04C3CE64C3CDF4C3CDD4C3CDF5C4DE65C4FE0857DEBE9EAE87D
            72E87F75E3E2E3DF8479ECF0F1EBECECE88076E3E4E5E2E6E6E3E1E1E65B4DE8
            8176E87B6FEBEBECE3E7E8E2E3E3E87D73ECECEDE87E74E3E1E2EBEAE9DF5A4C
            E082776A31C1120000002B74524E5300095FAFE3FBE1AD5C0701E7E456010405
            049A980D0999015B54E20658A9DCF6F5DCA75508DF054F8D02E0B65935B20000
            01124944415478DA4D905F4F023110C43BEDF50E0E0F3131C4847B504340BEFF
            87517CF0C108483042C00BB9BFEB6C43A29BF432FDB5DD9D1B182D6885EF396C
            B9D2CEDD0322CE98373D10C21BE4AA44C2A50FA084497B79A4AC5146F58E2DCC
            DD980A6D60BD96A79B0D904E2338A020BBE22069BE00BBF0841E75C1E6AC9D31
            DF700B6F25F1827AD0A04AB77CB047B470B631032FFDEAC2CC017EEED4CB2043
            95B4818170E654B15F2C6EA5AEBA03E2A70B4BBA73262B3A254CE6EA2566BF58
            4ED9BE049A237A337A1E173A6382D3086B697E30FD7C8CD08F9DCE9844762572
            626019A18C76E1CFF3353328973043FFF0970655F5C23CAFBDCDFF333C138EBC
            B5B80DE98BD4EDD298216FCA91732FE55E95FD025EE8708C33001A3700000000
            49454E44AE426082}
          OnClick = iCloseClick
          ExplicitTop = 12
        end
      end
      object pLeftHeader: TPanel
        Left = 0
        Top = 0
        Width = 25
        Height = 57
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 2
        object iAdd: TImage
          Left = 0
          Top = 0
          Width = 25
          Height = 20
          Cursor = crHandPoint
          Align = alTop
          Picture.Data = {
            0954506E67496D61676589504E470D0A1A0A0000000D49484452000000180000
            00180803000000D7A9CDCA000001DA504C544500000030976833976432956332
            956231946331946233956332956231956433A066379B64329663329361329462
            339363378B644444404444403399663194633391613295643296623293623396
            63319763319D62329562329462349D653294623391614444402F976832946235
            9062339662319665329562319564329563319462319463329463329364358F62
            329261339061348E5C339261338F60378D5E309763329462338C5E358E604444
            40348A5D389863349162339262339161339062388560328D6333966232946331
            9362319463339565329364359461329261339764359D68359F6A339865329462
            339262369B6839A66E3AAD7339AA71369C693495633AA46E3BA8703AAC733BA7
            703AA56E3499663596653BA6703FAF77A3D9BEA7DAC043AB77349A6680CAA4FE
            FEFEF5F5F588C7A632946396D3B4F4F4F49ED1B7379B6833916138A56E93CDAF
            A2D8BD33966492CBAE339965349C6840B07783CCA79CD5B898CEB398CDB2C4E0
            D2FFFFFFD1ECDF9DD6B988CCA9359D69359E699FD7BBA6D3BC36A06A9ED6BAA7
            D4BD40AA747FC4A1CBE9DA84C6A542B07933976597D4B538A8709DD0B6369F6A
            80C9A388C8A739A9713FA9749CCFB6A3D3BA43B07A3AAB73359664349B673698
            66338F60369A683AA36D359E6AA124D9CD0000004974524E53002073BCDDF5F6
            DEC078231CA2FDFEAA26040150F3F65D70FD7E5D1AF2F7249EB0051BFC2C6D7C
            B6C5D6E4EEFB7E2CA0B01FF2F72B50FD658502631DA4FCFEAC2A2472DCF4DEBE
            79271C3294D00000018E4944415478DA45925D4B02511086E74D5D23BB488D15
            3248C2B42853A19B2DCB2EBAC9DBFA05F5B7AA1F105D471F0425919541502188
            605852A1B0265B11BBE5763E563B1787799F979933C319903CE89D2F0788DB07
            641823BB0FA7DCD41D2388058E65A67581869311C222E326E70ACB81517C1546
            D0B302B3C73B20C375F3120085A1F50B3EC8D2BE3B2C52068E6180C6525E59C7
            CF8CB688307C088C23E19575D45F3774593188034C44A34DA954EB67E059BE64
            AB4788AF3E9154231FB665381D84F731957B241A173337553E0CEAAC83D81EA6
            D7EF8966EB70FFD82ACF6C60B40433B52B8DF4D33F77871F4C62062FA524D0B6
            159F41B080215C11CDEC21BE7929E635496BD1E79B888822FB98985A2A4AA5B5
            1A4A4B72588F6CC0B4472AAD8CC96B396BA69A072523BE8E508B2577FC5244D9
            CA790D9446D8C7A532CF4639E17C055BA882FC516C9C9AE474C0B90BDB151D14
            D04363999AA7C7B38A6B0785EED7AECDE158F693BB2D78ED427719D897276BB1
            325F8677E04EEF6E49C01E8AE06C19F92C7BFF8AEF08D11FE6579A2133386A61
            0000000049454E44AE426082}
          Proportional = True
          Stretch = True
          Transparent = True
          OnClick = iAddClick
          ExplicitLeft = 5
          ExplicitTop = 5
          ExplicitWidth = 20
        end
        object iSettings: TImage
          Left = 0
          Top = 37
          Width = 25
          Height = 20
          Cursor = crHandPoint
          Align = alBottom
          Picture.Data = {
            0954506E67496D61676589504E470D0A1A0A0000000D49484452000000140000
            00140803000000BA57ED3F0000018C504C544500000000000000000000000000
            0000000000000000000000000000000000444440444440444440000000000000
            0000000000000000000000000303020505042C2C294444404444400000000000
            004444401616150404040909094444404444400000000000002B2B2811111001
            0101000000000000000000050505080807040404000000000000000000121211
            0303020404040404030000000000000000000000000000000707060000000000
            000909082B2B2902020100000000000000000000000000000000000001010100
            00000000000000000000000505050707070101010000000000000505052D2D2B
            0000000101010000000000000000000F0F0E0000000404040505050000001919
            170101010000000404040505050404040000000404040000000000000B0B0A00
            00000000000909080101010D0D0C000000000000010101060605040404000000
            0000000000000000000000000101010000000000000000000000000808070000
            00000000000000010101000000000000000000040404040403020202030303B2
            51635A0000007F74524E530018DC335C49025A938B04050117F0FE7C45BEEE94
            0E090AB2BD0229CB0D0D0F5DD0033E511B6FFCBC89E5B6C1EF31EFE8F9E52536
            0137971E044D15497652FDD8A6F3BBA762BA08D87C68AE3CC21470931392F23B
            D9B83D5305ADAD1BADF928D5CA4751B003669E09C55F529EFD5960E8BBFAD0CF
            B735074C9B320AD2FB2D929C82D60000014A4944415478DA4D903B4803411445
            DF1D12C5EC063FA49045241024202201C5C2C6147E500222181011ADEC04B151
            B0144431B58598265AD8585B88954552984630A86011906C444488C48DE2B2E3
            BC890BBE6A38BCB973EE80083C3FF46FD0026C111D0052D419981E24C2F89B46
            9385201D5037AA1656B37866660520DFEB88AE9CC00D2E9F3EF9CCB5097DFA6E
            FABC443400D49811C88C35336F46A6C545D5ED4541C150C27F6A4CE2FA2512BC
            52D03002364D8C1209094FE5162E4DB5C97E535F495150CBC344B9374F65B25F
            6A481451B4693641B7F94FB0C91C3028EFF2EA5D4AF78B12345C88ABBC87333E
            2EC6A578D470098879E51CDB4F4651D69BAAC7780F55704C56CA827DA494C8EC
            829CB94FD22BBB46BCFD6F6E146A93EE7C27C768D34A961B855B5D7BBDA306B4
            4B7CC07032BA91A34C3771B866C8C61E6D63D76FA47F7C03D8D1A75F222F6976
            A26D22DC0000000049454E44AE426082}
          Proportional = True
          Stretch = True
          Transparent = True
          OnClick = iSettingsClick
          ExplicitLeft = 5
          ExplicitTop = 27
          ExplicitWidth = 20
        end
      end
    end
    object pFooter: TPanel
      Left = 0
      Top = 269
      Width = 250
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object lAmount24h: TLabel
        Left = 0
        Top = 16
        Width = 250
        Height = 20
        Align = alClient
        Alignment = taCenter
        Caption = 'lAmount24h'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 69
        ExplicitHeight = 17
      end
      object gpTotal: TGridPanel
        Left = 0
        Top = 0
        Width = 250
        Height = 16
        Align = alTop
        BevelOuter = bvNone
        ColumnCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = lTotalBids
            Row = 0
          end
          item
            Column = 1
            Control = lTotalAsks
            Row = 0
          end>
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 0
        object lTotalBids: TLabel
          Left = 0
          Top = 0
          Width = 125
          Height = 16
          Align = alClient
          Alignment = taCenter
          Caption = 'lTotalBids'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 55
          ExplicitHeight = 17
        end
        object lTotalAsks: TLabel
          Left = 125
          Top = 0
          Width = 125
          Height = 16
          Align = alClient
          Alignment = taCenter
          Caption = 'lTotalAsks'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 57
          ExplicitHeight = 17
        end
      end
    end
  end
end
