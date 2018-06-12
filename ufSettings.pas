unit ufSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, uSettigns,
  VirtualTrees;

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
    FSettigns: ISettigns;
  public
    class function ShowSettings(const aSettigns: ISettigns): Boolean;
  end;

implementation

{$R *.dfm}

uses
  uExchangeClass;

{ TfrmSettings }

class function TfrmSettings.ShowSettings(const aSettigns: ISettigns): Boolean;
var
  LNode: PVirtualNode;
  LUseExchange: Boolean;
begin
  Result := False;

  if Assigned(aSettigns) then
  with TfrmSettings.Create(nil) do
  try
    FSettigns := aSettigns;
    vstExchanges.RootNodeCount := TExchange.Count;
    vstExchanges.ReinitNode(nil, True);

    eMinAmount.Text := FloatToStr(aSettigns.MinPrice);
    eBoldAmount.Text := FloatToStr(aSettigns.BoldPrice);
    cbPairs.Text := aSettigns.Pair;

    Result := ShowModal = mrOk;

    if Result then
    begin
      aSettigns.BoldPrice := StrToFloat(eBoldAmount.Text);
      aSettigns.MinPrice := StrToFloat(eMinAmount.Text);

      LNode := vstExchanges.GetFirst;
      while Assigned(LNode) do
      begin
        LUseExchange := LNode^.CheckState = csCheckedNormal;

        case TExchange(LNode^.Index) of
          BiBox: FSettigns.UseBiBox := LUseExchange;
          Binance: FSettigns.UseBinance := LUseExchange;
          Bitfinex: FSettigns.UseBitfinex := LUseExchange;
          Bitstamp: FSettigns.UseBitstamp := LUseExchange;
          Bittrex: FSettigns.UseBittrex := LUseExchange;
          HitBTC: FSettigns.UseHitBTC := LUseExchange;
          Huobi: FSettigns.UseHuobi := LUseExchange;
          Kraken: FSettigns.UseKraken := LUseExchange;
          Okex: FSettigns.UseOkex := LUseExchange;
//          Poloniex: LUseExchange := False;
        end;

        LNode := LNode.NextSibling;
      end;

      aSettigns.Save;
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
  end;
end;

procedure TfrmSettings.vstExchangesInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  LUseExchange: Boolean;
begin
  if Assigned(FSettigns) then
  begin
    Node^.CheckType := ctCheckBox;

    case TExchange(Node^.Index) of
      BiBox: LUseExchange := FSettigns.UseBiBox;
      Binance: LUseExchange := FSettigns.UseBinance;
      Bitfinex: LUseExchange := FSettigns.UseBitfinex;
      Bitstamp: LUseExchange := FSettigns.UseBitstamp;
      Bittrex: LUseExchange := FSettigns.UseBittrex;
      HitBTC: LUseExchange := FSettigns.UseHitBTC;
      Huobi: LUseExchange := FSettigns.UseHuobi;
      Kraken: LUseExchange := FSettigns.UseKraken;
      Okex: LUseExchange := FSettigns.UseOkex;
      Poloniex: LUseExchange := False;
    end;

    if LUseExchange then
      Node^.CheckState := csCheckedNormal
    else
      Node^.CheckState := csUncheckedNormal;
  end;
end;

end.
