unit uPairFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, VirtualTrees, Vcl.Imaging.pngimage, System.Generics.Collections

  , uExchangeManager
  , uExchangeClass
  , uSettigns
  , uCustomDepth

  ;

type
  TframePair = class(TFrame)
    pMain: TPanel;
    vstBTC: TVirtualStringTree;
    pHeader: TPanel;
    Label2: TLabel;
    lPrice: TLabel;
    pFooter: TPanel;
    gpTotal: TGridPanel;
    lTotalBids: TLabel;
    lTotalAsks: TLabel;
    iClose: TImage;
    iAdd: TImage;
    iSettings: TImage;
    pMainHeader: TPanel;
    pRightHeader: TPanel;
    pLeftHeader: TPanel;
    pDepth: TPanel;
    Splitter: TSplitter;
    VirtualStringTree1: TVirtualStringTree;
    pFooterHistory: TGridPanel;
    lBidsOrders: TLabel;
    lAsksOrders: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    iPriceExchange: TImage;
    listPricingExchange: TListBox;
    GridPanel1: TGridPanel;
    lExchangeName: TLabel;
    Label1: TLabel;
    procedure iCloseClick(Sender: TObject);
    procedure iAddClick(Sender: TObject);
    procedure vstBTCGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBTCPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstBTCGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: string);
    procedure iSettingsClick(Sender: TObject);
    procedure listPricingExchangeClick(Sender: TObject);
    procedure iPriceExchangeClick(Sender: TObject);
    procedure listPricingExchangeExit(Sender: TObject);
  private
    FExchangeManager: TExchangeManager;

    FDepthBidsList,
    FDepthAsksList: TList<TPairDepth>;
    FSettins: ISettigns;
    FCurrentExchange: TCustomDepth;

    procedure DoUpdateStatistics24h;
    procedure DoUpdateDepth(const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double);
    function  GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    class procedure CreateFrame(AOwner: TWinControl; const aSectionName: String);
    destructor Destroy; override;

    property Settins: ISettigns read FSettins;
    property Active: Boolean read GetActive write SetActive;
  end;

implementation

{$R *.dfm}

uses
  Math, ufSettings, System.UITypes;

class procedure TframePair.CreateFrame(AOwner: TWinControl; const aSectionName: String);
begin
  with TframePair.Create(AOwner) do
  begin
    Name := 'pair' + FormatDateTime('ddmmyynnhhss_zzz', Now);
    Parent := AOwner;

    FSettins := uSettigns.CreateSettigns;

    if aSectionName.IsEmpty then
    begin
      FSettins.Load(Name);
      lExchangeName.Caption := EmptyStr;
    end
    else
    begin
      FSettins.Load(aSectionName);
      lExchangeName.Caption := FSettins.CurrentExchange.ToString;
    end;

    FDepthBidsList := TList<TPairDepth>.Create;
    FDepthAsksList := TList<TPairDepth>.Create;

    FormatSettings.DecimalSeparator := '.';
    FExchangeManager := TExchangeManager.Create(FSettins);

    FExchangeManager.OnUpdateDepth := DoUpdateDepth;
    FExchangeManager.OnUpdateStatistics24h := DoUpdateStatistics24h;
    FExchangeManager.OnUpdateTradeHistory :=
      procedure
      begin

      end;

    if not aSectionName.IsEmpty then
    begin
      FCurrentExchange := FExchangeManager.GetDepthFromExchange(FSettins.CurrentExchange);
      FExchangeManager.Active := True;
    end;
  end;
end;

destructor TframePair.Destroy;
begin
  FreeAndNil(FExchangeManager);
  FreeAndNil(FDepthBidsList);
  FreeAndNil(FDepthAsksList);
  FSettins := nil;

  inherited;
end;

procedure TframePair.iAddClick(Sender: TObject);
begin
  TframePair.CreateFrame(Self.Parent, EmptyStr);

  if (Parent is TForm) then
  with (Parent as TForm) do
  begin
    Constraints.MaxWidth := Width + Self.Width;
    Constraints.MinWidth := Width + Self.Width;
  end;
end;

procedure TframePair.iCloseClick(Sender: TObject);
begin
  if (Parent is TForm) then
  with (Parent as TForm) do
  begin
    Constraints.MinWidth := Width - Self.Width;
    Constraints.MaxWidth := Width - Self.Width;
  end;

  FSettins.Delete;

  Self.Parent := nil;
end;

procedure TframePair.iPriceExchangeClick(Sender: TObject);
var
  i: Integer;
begin
  if not listPricingExchange.Visible then
  begin
    listPricingExchange.Clear;

    if FExchangeManager.Binance.Active then
      listPricingExchange.AddItem(FExchangeManager.Binance.ToString, FExchangeManager.Binance);

    if FExchangeManager.BiBox.Active then
      listPricingExchange.AddItem(FExchangeManager.BiBox.ToString, FExchangeManager.BiBox);

    if FExchangeManager.Bittrex.Active then
      listPricingExchange.AddItem(FExchangeManager.Bittrex.ToString, FExchangeManager.Bittrex);

    if FExchangeManager.Bitfinex.Active then
      listPricingExchange.AddItem(FExchangeManager.Bitfinex.ToString, FExchangeManager.Bitfinex);

    if FExchangeManager.Kraken.Active then
      listPricingExchange.AddItem(FExchangeManager.Kraken.ToString, FExchangeManager.Kraken);

    if FExchangeManager.Bitstamp.Active then
      listPricingExchange.AddItem(FExchangeManager.Bitstamp.ToString, FExchangeManager.Bitstamp);

    if FExchangeManager.Okex.Active then
      listPricingExchange.AddItem(FExchangeManager.Okex.ToString, FExchangeManager.Okex);

    if FExchangeManager.Huobi.Active then
      listPricingExchange.AddItem(FExchangeManager.Huobi.ToString, FExchangeManager.Huobi);

    if FExchangeManager.HitBTC.Active then
      listPricingExchange.AddItem(FExchangeManager.HitBTC.ToString, FExchangeManager.HitBTC);

    for i := 0 to listPricingExchange.Items.Count - 1 do
    if listPricingExchange.Items.Objects[i] = FCurrentExchange then
    begin
      listPricingExchange.ItemIndex := i;
      Break;
    end;

    listPricingExchange.Height := listPricingExchange.Items.Count * listPricingExchange.ItemHeight + listPricingExchange.Items.Count + 2;
    listPricingExchange.Visible := True;
    listPricingExchange.SetFocus;
  end
  else
    listPricingExchange.Visible := False;
end;

procedure TframePair.iSettingsClick(Sender: TObject);
begin
  if TfrmSettings.ShowSettings(FExchangeManager) then
  begin
    FCurrentExchange := nil;
    FExchangeManager.UpdateActiveExchange;

    if FExchangeManager.Binance.Active then FCurrentExchange := FExchangeManager.Binance else
    if FExchangeManager.BiBox.Active then FCurrentExchange := FExchangeManager.BiBox else
    if FExchangeManager.Bittrex.Active then FCurrentExchange := FExchangeManager.Bittrex else
    if FExchangeManager.Bitfinex.Active then FCurrentExchange := FExchangeManager.Bitfinex else
    if FExchangeManager.Kraken.Active then FCurrentExchange := FExchangeManager.Kraken else
    if FExchangeManager.Bitstamp.Active then FCurrentExchange := FExchangeManager.Bitstamp else
    if FExchangeManager.Okex.Active then FCurrentExchange := FExchangeManager.Okex else
    if FExchangeManager.Huobi.Active then FCurrentExchange := FExchangeManager.Huobi else
    if FExchangeManager.HitBTC.Active then FCurrentExchange := FExchangeManager.HitBTC;

    if Assigned(FCurrentExchange) then
    begin
      lExchangeName.Caption := FCurrentExchange.ToString;
      FSettins.CurrentExchange := FCurrentExchange.Exchange;
      FSettins.Save;
    end
    else
      lExchangeName.Caption := EmptyStr;
  end;
end;

procedure TframePair.listPricingExchangeClick(Sender: TObject);
begin
  listPricingExchange.Visible := False;

  FCurrentExchange := TCustomDepth(listPricingExchange.Items.Objects[listPricingExchange.ItemIndex]);
  FSettins.CurrentExchange := FCurrentExchange.Exchange;
  lExchangeName.Caption := FCurrentExchange.ToString;
end;

procedure TframePair.listPricingExchangeExit(Sender: TObject);
begin
  listPricingExchange.Visible := False;
end;

procedure TframePair.SetActive(const Value: Boolean);
begin
  FExchangeManager.Active := Value;
end;

procedure TframePair.DoUpdateDepth(const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double);
var
  i: Integer;
begin
  if Assigned(aBidsList)
    and Assigned(aAsksList)
  then
  begin
    vstBTC.BeginUpdate;
    try
      FDepthBidsList.Clear;
      FDepthAsksList.Clear;

      for i := 0 to aBidsList.Count - 1 do
        FDepthBidsList.Add(TPairDepth.Create(aBidsList[i].Price,
                                             aBidsList[i].Amount,
                                             aBidsList[i].ExchangeList));

      for i := 0 to aAsksList.Count - 1 do
        FDepthAsksList.Add(TPairDepth.Create(aAsksList[i].Price,
                                             aAsksList[i].Amount,
                                             aAsksList[i].ExchangeList));

      vstBTC.RootNodeCount := Max(FDepthBidsList.Count, FDepthAsksList.Count);

      vstBTC.Refresh;
    finally
      vstBTC.EndUpdate;
    end;

    lTotalBids.Caption := Format('%n', [SimpleRoundTo(aTotalBids)]);
    lTotalAsks.Caption := Format('%n', [SimpleRoundTo(aTotalAsks)]);
  end;
end;

procedure TframePair.DoUpdateStatistics24h;
const
  cMinMax = '%n - %n';
begin
  if Assigned(FCurrentExchange)
    and Assigned(FCurrentExchange.Statis24h)
  then
  begin
    Label2.Caption := Format(cMinMax, [SimpleRoundTo(FCurrentExchange.Statis24h.LowPrice),
                                       SimpleRoundTo(FCurrentExchange.Statis24h.HighPrice)]);

    lPrice.Caption := Format('%n', [SimpleRoundTo(FCurrentExchange.Statis24h.LastPrice)]);

  //  lAmount24h.Caption := Format('%n', [SimpleRoundTo(aStatistics24h.Volume)]);
  end;
end;

function TframePair.GetActive: Boolean;
begin
  Result := FExchangeManager.Active;
end;

procedure TframePair.vstBTCGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
const
  cBids = 0;
  cAsks = 1;
var
  LPair: TPairDepth;
  LAccess: Boolean;
begin
  CellText := EmptyStr;
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
  then
    CellText := FloatToStr(LPair.Price) + ' - ' + FloatToStr(SimpleRoundTo(LPair.Amount));
end;

procedure TframePair.vstBTCGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: string);
const
  cBids = 0;
  cAsks = 1;
var
  LAccess: Boolean;
  LPair: TPairDepth;
begin
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
  then
    HintText := LPair.ExchangeList;
end;

procedure TframePair.vstBTCPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
const
  cBids = 0;
  cAsks = 1;
var
  LPair: TPairDepth;
  LAccess: Boolean;
begin
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
    and (LPair.Amount >= FSettins.BoldPrice)
  then
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
end;

end.
