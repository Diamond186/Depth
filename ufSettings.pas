unit ufSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, uSettigns,
  VirtualTrees;

type
  TfrmSettings = class(TForm)
    cbExchangeList: TCheckListBox;
    pFooter: TPanel;
    bCancel: TButton;
    bSave: TButton;
    cbPairs: TComboBox;
    eSearchPair: TEdit;
    eMinAmount: TEdit;
    eBoldAmount: TEdit;
    pMain: TPanel;
    VirtualStringTree1: TVirtualStringTree;
  private

  public
    class function ShowSettings(const aSettigns: ISettigns): Boolean;
  end;

implementation

{$R *.dfm}

{ TfrmSettings }

class function TfrmSettings.ShowSettings(const aSettigns: ISettigns): Boolean;
begin
  Result := False;

  if Assigned(aSettigns) then
  with TfrmSettings.Create(nil) do
  try
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('BiBox')] := aSettigns.UseBiBox;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Binance')] := aSettigns.UseBinance;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bitfinex')] := aSettigns.UseBitfinex;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bitstamp')] := aSettigns.UseBitstamp;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bittrex')] := aSettigns.UseBittrex;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('HitBTC')] := aSettigns.UseHitBTC;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Huobi')] := aSettigns.UseHuobi;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Kraken')] := aSettigns.UseKraken;
    cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Okex')] := aSettigns.UseOkex;

    eMinAmount.Text := FloatToStr(aSettigns.MinPrice);
    eBoldAmount.Text := FloatToStr(aSettigns.BoldPrice);
    cbPairs.Text := aSettigns.Pair;

    Result := ShowModal = mrOk;

    if Result then
    begin
      aSettigns.BoldPrice := StrToFloat(eBoldAmount.Text);
      aSettigns.MinPrice := StrToFloat(eMinAmount.Text);

      aSettigns.UseBiBox := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('BiBox')];
      aSettigns.UseBinance := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Binance')];
      aSettigns.UseBitfinex := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bitfinex')];
      aSettigns.UseBitstamp := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bitstamp')];
      aSettigns.UseBittrex := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Bittrex')];
      aSettigns.UseHitBTC := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('HitBTC')];
      aSettigns.UseHuobi := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Huobi')];
      aSettigns.UseKraken := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Kraken')];
      aSettigns.UseOkex := cbExchangeList.Checked[cbExchangeList.Items.IndexOf('Okex')];

      aSettigns.Save;
    end;
  finally
    Free;
  end;
end;

end.
