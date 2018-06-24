unit ufSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, uSettigns,
  VirtualTrees, uExchangeManager, uExchangeClass;

type
  TfrmSettings = class(TForm)
    pFooter: TPanel;
    bCancel: TButton;
    bSave: TButton;
    cbPair1: TComboBox;
    eSearchPair1: TEdit;
    eMinAmount: TEdit;
    eBoldAmount: TEdit;
    pMain: TPanel;
    vstExchanges: TVirtualStringTree;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    cbPair2: TComboBox;
    eSearchPair2: TEdit;
    GroupBox2: TGroupBox;
    rbPercent: TRadioButton;
    rbAmount: TRadioButton;
    cbPercents: TComboBox;
    eMinRange: TEdit;
    eMaxRange: TEdit;
    procedure vstExchangesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstExchangesInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstExchangesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure rbRangeClick(Sender: TObject);
  private
    FExchangeManager: TExchangeManager;
    FOldUpdateStatistics24h: TOnUpdateStatistics24h;

    procedure DoUpdateStatistics24;

    procedure LoadSettings;
    procedure SaveSettings;
  public
    class function ShowSettings(const aExchangeManager: TExchangeManager): Boolean;
  end;

implementation

{$R *.dfm}

uses
  System.StrUtils;

{ TfrmSettings }

procedure TfrmSettings.DoUpdateStatistics24;
begin
  if Assigned(FOldUpdateStatistics24h) then
    FOldUpdateStatistics24h;

  vstExchanges.Refresh;
end;

procedure TfrmSettings.LoadSettings;
begin
  eMinAmount.Text := FloatToStr(FExchangeManager.Settings.MinPrice);
  eBoldAmount.Text := FloatToStr(FExchangeManager.Settings.BoldPrice);
  cbPair1.Text := FExchangeManager.Settings.Pair;
  rbPercent.Checked := FExchangeManager.Settings.RangeIsPercent;
  cbPercents.ItemIndex := cbPercents.Items.IndexOf(FExchangeManager.Settings.RangePercent.ToString + ' %');
  eMinRange.Text := FExchangeManager.Settings.RangeMinPrice.ToString;
  eMaxRange.Text := FExchangeManager.Settings.RangeMaxPrice.ToString;
end;

procedure TfrmSettings.rbRangeClick(Sender: TObject);
begin
  eMinRange.Enabled := rbAmount.Checked;
  eMaxRange.Enabled := rbAmount.Checked;
  cbPercents.Enabled := rbPercent.Checked;
end;

procedure TfrmSettings.SaveSettings;
var
  LNode: PVirtualNode;
  LUseExchange: Boolean;
begin
  FExchangeManager.Settings.BoldPrice := StrToFloat(eBoldAmount.Text);
  FExchangeManager.Settings.MinPrice := StrToFloat(eMinAmount.Text);

  FExchangeManager.Settings.RangeIsPercent := rbPercent.Checked;
  FExchangeManager.Settings.RangePercent := cbPercents.Items[cbPercents.ItemIndex]
                                                      .Replace(' %', '')
                                                      .ToInteger;
  FExchangeManager.Settings.RangeMinPrice := StrToFloat(eMinRange.Text);
  FExchangeManager.Settings.RangeMaxPrice := StrToFloat(eMaxRange.Text);

  LNode := vstExchanges.GetFirst;
  while Assigned(LNode) do
  begin
    LUseExchange := LNode^.CheckState = csCheckedNormal;

    case TExchange(LNode^.Index) of
      BiBox: FExchangeManager.Settings.UseBiBox := LUseExchange;
      Binance: FExchangeManager.Settings.UseBinance := LUseExchange;
      Bitfinex: FExchangeManager.Settings.UseBitfinex := LUseExchange;
      Bitstamp: FExchangeManager.Settings.UseBitstamp := LUseExchange;
      Bittrex: FExchangeManager.Settings.UseBittrex := LUseExchange;
      HitBTC: FExchangeManager.Settings.UseHitBTC := LUseExchange;
      Huobi: FExchangeManager.Settings.UseHuobi := LUseExchange;
      Kraken: FExchangeManager.Settings.UseKraken := LUseExchange;
      Okex: FExchangeManager.Settings.UseOkex := LUseExchange;
//          Poloniex: LUseExchange := False;
    end;

    LNode := LNode.NextSibling;
  end;

  FExchangeManager.Settings.Save;
end;

class function TfrmSettings.ShowSettings(const aExchangeManager: TExchangeManager): Boolean;
begin
  Result := False;

  if Assigned(aExchangeManager) then
  with TfrmSettings.Create(nil) do
  try
    FExchangeManager := aExchangeManager;
    vstExchanges.RootNodeCount := TExchange.Count;
    vstExchanges.ReinitNode(nil, True);

    LoadSettings;

    FOldUpdateStatistics24h := aExchangeManager.OnUpdateStatistics24h;
    aExchangeManager.OnUpdateStatistics24h := DoUpdateStatistics24;
    aExchangeManager.BeginStatistics24h;

    Result := ShowModal = mrOk;

    if Result then
      SaveSettings;
  finally
    aExchangeManager.OnUpdateStatistics24h := FOldUpdateStatistics24h;

    Free;
  end;
end;

procedure TfrmSettings.vstExchangesChecked(Sender: TBaseVirtualTree;
                                           Node: PVirtualNode);
begin
  Caption := IfThen(Node^.CheckState = csCheckedNormal, 'True', 'False');
end;

procedure TfrmSettings.vstExchangesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  case Column of
    0: CellText := TExchange(Node.Index).ToString;

    1:
      case TExchange(Node^.Index) of
        BiBox: CellText := Format('%n', [FExchangeManager.BiBox.Statis24h.LastPrice]);
        Binance: CellText := Format('%n', [FExchangeManager.Binance.Statis24h.LastPrice]);
        Bitfinex: CellText := Format('%n', [FExchangeManager.Bitfinex.Statis24h.LastPrice]);
        Bitstamp: CellText := Format('%n', [FExchangeManager.Bitstamp.Statis24h.LastPrice]);
        Bittrex: CellText := Format('%n', [FExchangeManager.Bittrex.Statis24h.LastPrice]);
        HitBTC: CellText := Format('%n', [FExchangeManager.HitBTC.Statis24h.LastPrice]);
        Huobi: CellText := Format('%n', [FExchangeManager.Huobi.Statis24h.LastPrice]);
        Kraken: CellText := Format('%n', [FExchangeManager.Kraken.Statis24h.LastPrice]);
        Okex: CellText := Format('%n', [FExchangeManager.Okex.Statis24h.LastPrice]);
        Poloniex: CellText := EmptyStr;
      end;

    2:
      case TExchange(Node^.Index) of
        BiBox: CellText := Format('%n', [FExchangeManager.BiBox.Statis24h.Volume]);
        Binance: CellText := Format('%n', [FExchangeManager.Binance.Statis24h.Volume]);
        Bitfinex: CellText := Format('%n', [FExchangeManager.Bitfinex.Statis24h.Volume]);
        Bitstamp: CellText := Format('%n', [FExchangeManager.Bitstamp.Statis24h.Volume]);
        Bittrex: CellText := Format('%n', [FExchangeManager.Bittrex.Statis24h.Volume]);
        HitBTC: CellText := Format('%n', [FExchangeManager.HitBTC.Statis24h.Volume]);
        Huobi: CellText := Format('%n', [FExchangeManager.Huobi.Statis24h.Volume]);
        Kraken: CellText := Format('%n', [FExchangeManager.Kraken.Statis24h.Volume]);
        Okex: CellText := Format('%n', [FExchangeManager.Okex.Statis24h.Volume]);
        Poloniex: CellText := EmptyStr;
      end;
  end;
end;

procedure TfrmSettings.vstExchangesInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LUseExchange: Boolean;
begin
  if Assigned(FExchangeManager) then
  begin
    if TExchange(Node^.Index) = TExchange.Poloniex then
      Include(InitialStates, ivsDisabled);

    Node^.CheckType := ctCheckBox;

    case TExchange(Node^.Index) of
      BiBox: LUseExchange := FExchangeManager.Settings.UseBiBox;
      Binance: LUseExchange := FExchangeManager.Settings.UseBinance;
      Bitfinex: LUseExchange := FExchangeManager.Settings.UseBitfinex;
      Bitstamp: LUseExchange := FExchangeManager.Settings.UseBitstamp;
      Bittrex: LUseExchange := FExchangeManager.Settings.UseBittrex;
      HitBTC: LUseExchange := FExchangeManager.Settings.UseHitBTC;
      Huobi: LUseExchange := FExchangeManager.Settings.UseHuobi;
      Kraken: LUseExchange := FExchangeManager.Settings.UseKraken;
      Okex: LUseExchange := FExchangeManager.Settings.UseOkex;
    else LUseExchange := False;
    end;

    if LUseExchange then
      Node^.CheckState := csCheckedNormal
    else
      Node^.CheckState := csUncheckedNormal;
  end;
end;

end.
