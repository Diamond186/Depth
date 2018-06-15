unit ufSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, uSettigns,
  VirtualTrees, uExchangeManager;

type
  TfrmSettings = class(TForm)
    pFooter: TPanel;
    bCancel: TButton;
    bSave: TButton;
    cbPairs: TComboBox;
    eSearchPair: TEdit;
    eMinAmount: TEdit;
    eBoldAmount: TEdit;
    pMain: TPanel;
    vstExchanges: TVirtualStringTree;
    procedure vstExchangesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstExchangesInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstExchangesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FExchangeManager: TExchangeManager;
  public
    class function ShowSettings(const aExchandeManager: TExchangeManager): Boolean;
  end;

implementation

{$R *.dfm}

uses
  uExchangeClass;

{ TfrmSettings }

class function TfrmSettings.ShowSettings(const aExchandeManager: TExchangeManager): Boolean;
var
  LNode: PVirtualNode;
  LUseExchange: Boolean;
begin
  Result := False;

  if Assigned(aExchandeManager) then
  with TfrmSettings.Create(nil) do
  try
    FExchangeManager := aExchandeManager;
    vstExchanges.RootNodeCount := TExchange.Count;
    vstExchanges.ReinitNode(nil, True);

    eMinAmount.Text := FloatToStr(aExchandeManager.Settings.MinPrice);
    eBoldAmount.Text := FloatToStr(aExchandeManager.Settings.BoldPrice);
    cbPairs.Text := aExchandeManager.Settings.Pair;

    Result := ShowModal = mrOk;

    if Result then
    begin
      aExchandeManager.Settings.BoldPrice := StrToFloat(eBoldAmount.Text);
      aExchandeManager.Settings.MinPrice := StrToFloat(eMinAmount.Text);

      LNode := vstExchanges.GetFirst;
      while Assigned(LNode) do
      begin
        LUseExchange := LNode^.CheckState = csCheckedNormal;

        case TExchange(LNode^.Index) of
          BiBox: aExchandeManager.Settings.UseBiBox := LUseExchange;
          Binance: aExchandeManager.Settings.UseBinance := LUseExchange;
          Bitfinex: aExchandeManager.Settings.UseBitfinex := LUseExchange;
          Bitstamp: aExchandeManager.Settings.UseBitstamp := LUseExchange;
          Bittrex: aExchandeManager.Settings.UseBittrex := LUseExchange;
          HitBTC: aExchandeManager.Settings.UseHitBTC := LUseExchange;
          Huobi: aExchandeManager.Settings.UseHuobi := LUseExchange;
          Kraken: aExchandeManager.Settings.UseKraken := LUseExchange;
          Okex: aExchandeManager.Settings.UseOkex := LUseExchange;
//          Poloniex: LUseExchange := False;
        end;

        LNode := LNode.NextSibling;
      end;

      aExchandeManager.Settings.Save;
    end;
  finally
    Free;
  end;
end;

procedure TfrmSettings.vstExchangesChecked(Sender: TBaseVirtualTree;
                                           Node: PVirtualNode);
begin
  if Node^.CheckState = csCheckedNormal then
    Caption := 'True'
  else
    Caption := 'False';
end;

procedure TfrmSettings.vstExchangesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  case Column of
    0: CellText := TExchange(Node.Index).ToString;

    1:
      case TExchange(Node^.Index) of
        BiBox: CellText := EmptyStr;
        Binance: CellText := Format('%n', [FExchangeManager.Binance.Statis24h.LastPrice]);
        Bitfinex: CellText := EmptyStr;
        Bitstamp: CellText := EmptyStr;
        Bittrex: CellText := EmptyStr;
        HitBTC: CellText := EmptyStr;
        Huobi: CellText := EmptyStr;
        Kraken: CellText := EmptyStr;
        Okex: CellText := EmptyStr;
        Poloniex: CellText := EmptyStr;
      end;

    2:
      case TExchange(Node^.Index) of
        BiBox: CellText := EmptyStr;
        Binance: CellText := Format('%n', [FExchangeManager.Binance.Statis24h.Volume]);
        Bitfinex: CellText := EmptyStr;
        Bitstamp: CellText := EmptyStr;
        Bittrex: CellText := EmptyStr;
        HitBTC: CellText := EmptyStr;
        Huobi: CellText := EmptyStr;
        Kraken: CellText := EmptyStr;
        Okex: CellText := EmptyStr;
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
