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
    vstTradeHistory: TVirtualStringTree;
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
    procedure vstTradeHistoryGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
  private
    FExchangeManager: TExchangeManager;

    FDepthBidsList,
    FDepthAsksList: TList<TPairDepth>;
    FSettins: ISettigns;
    FCurrentExchange: TCustomDepth;
    FBidsTradeHistory,
    FAsksTradeHistory: TTradeHistoryTotal;

    procedure DoUpdateStatistics24h;
    procedure DoUpdateDepth(const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double);
    procedure DoUpdateTradeHistory;
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

    FBidsTradeHistory := TTradeHistoryTotal.Create;
    FAsksTradeHistory := TTradeHistoryTotal.Create;

    FormatSettings.DecimalSeparator := '.';
    FExchangeManager := TExchangeManager.Create(FSettins);

    FExchangeManager.OnUpdateDepth := DoUpdateDepth;
    FExchangeManager.OnUpdateStatistics24h := DoUpdateStatistics24h;
    FExchangeManager.OnUpdateTradeHistory := DoUpdateTradeHistory;

    if not aSectionName.IsEmpty then
    begin
      FCurrentExchange := FExchangeManager.GetDepthFromExchange(FSettins.CurrentExchange);
      FExchangeManager.Active := True;
    end;

    vstTradeHistory.RootNodeCount := 6;
  end;
end;

destructor TframePair.Destroy;
begin
  FreeAndNil(FAsksTradeHistory);
  FreeAndNil(FBidsTradeHistory);
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

    if FExchangeManager.CoinbasePro.Active then
      listPricingExchange.AddItem(FExchangeManager.CoinbasePro.ToString, FExchangeManager.CoinbasePro);

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
    if FExchangeManager.CoinbasePro.Active then FCurrentExchange := FExchangeManager.CoinbasePro else
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

procedure TframePair.DoUpdateTradeHistory;
begin
  lBidsOrders.Caption := FExchangeManager.BidsTradeHistory.OneSec.Count.ToString + ' (' +
                         Format('%n', [FExchangeManager.BidsTradeHistory.OneSec.Amount]) + ' BTC)';

  lAsksOrders.Caption := FExchangeManager.AsksTradeHistory.OneSec.Count.ToString + ' (' +
                         Format('%n', [FExchangeManager.AsksTradeHistory.OneSec.Amount]) + ' BTC)';

  vstTradeHistory.BeginUpdate;
  try
    FAsksTradeHistory._15Sec.Count := FExchangeManager.AsksTradeHistory._15Sec.Count;
    FAsksTradeHistory._15Sec.Amount := FExchangeManager.AsksTradeHistory._15Sec.Amount;
    FAsksTradeHistory._30Sec.Count := FExchangeManager.AsksTradeHistory._30Sec.Count;
    FAsksTradeHistory._30Sec.Amount := FExchangeManager.AsksTradeHistory._30Sec.Amount;
    FAsksTradeHistory._1Min.Count := FExchangeManager.AsksTradeHistory._1Min.Count;
    FAsksTradeHistory._1Min.Amount := FExchangeManager.AsksTradeHistory._1Min.Amount;
    FAsksTradeHistory._15Min.Count := FExchangeManager.AsksTradeHistory._15Min.Count;
    FAsksTradeHistory._15Min.Amount := FExchangeManager.AsksTradeHistory._15Min.Amount;
    FAsksTradeHistory._30Min.Count := FExchangeManager.AsksTradeHistory._30Min.Count;
    FAsksTradeHistory._30Min.Amount := FExchangeManager.AsksTradeHistory._30Min.Amount;
    FAsksTradeHistory._1Hour.Count := FExchangeManager.AsksTradeHistory._1Hour.Count;
    FAsksTradeHistory._1Hour.Amount := FExchangeManager.AsksTradeHistory._1Hour.Amount;

    FBidsTradeHistory._15Sec.Count := FExchangeManager.BidsTradeHistory._15Sec.Count;
    FBidsTradeHistory._15Sec.Amount := FExchangeManager.BidsTradeHistory._15Sec.Amount;
    FBidsTradeHistory._30Sec.Count := FExchangeManager.BidsTradeHistory._30Sec.Count;
    FBidsTradeHistory._30Sec.Amount := FExchangeManager.BidsTradeHistory._30Sec.Amount;
    FBidsTradeHistory._1Min.Count := FExchangeManager.BidsTradeHistory._1Min.Count;
    FBidsTradeHistory._1Min.Amount := FExchangeManager.BidsTradeHistory._1Min.Amount;
    FBidsTradeHistory._15Min.Count := FExchangeManager.BidsTradeHistory._15Min.Count;
    FBidsTradeHistory._15Min.Amount := FExchangeManager.BidsTradeHistory._15Min.Amount;
    FBidsTradeHistory._30Min.Count := FExchangeManager.BidsTradeHistory._30Min.Count;
    FBidsTradeHistory._30Min.Amount := FExchangeManager.BidsTradeHistory._30Min.Amount;
    FBidsTradeHistory._1Hour.Count := FExchangeManager.BidsTradeHistory._1Hour.Count;
    FBidsTradeHistory._1Hour.Amount := FExchangeManager.BidsTradeHistory._1Hour.Amount;
  finally
    vstTradeHistory.EndUpdate;
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

procedure TframePair.vstTradeHistoryGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
const
  c15Sec = 0;
  c30Sec = 1;
  c1Min = 2;
  c15Min = 3;
  c30Min = 4;
  c1Hour = 5;
var
  LCount: Integer;
  LAmount: Double;
begin
  if Column = 1 then
  begin
    case Node.Index of
      c15Sec: CellText := '15 Sec';
      c30Sec: CellText := '30 Sec';
      c1Min: CellText := '1 Min';
      c15Min: CellText := '15 Min';
      c30Min: CellText := '30 Min';
      c1Hour: CellText := '1 Hour';
    end;

    Exit;
  end;

  LCount := 0;
  LAmount := 0;

  if Column in [0, 2] then
  case Node.Index of
    c15Sec:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._15Sec.Count, FAsksTradeHistory._15Sec.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._15Sec.Amount, FAsksTradeHistory._15Sec.Amount);
      end;

    c30Sec:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._30Sec.Count, FAsksTradeHistory._30Sec.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._30Sec.Amount, FAsksTradeHistory._30Sec.Amount);
      end;

    c1Min:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._1Min.Count, FAsksTradeHistory._1Min.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._1Min.Amount, FAsksTradeHistory._1Min.Amount);
      end;

    c15Min:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._15Min.Count, FAsksTradeHistory._15Min.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._15Min.Amount, FAsksTradeHistory._15Min.Amount);
      end;

    c30Min:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._30Min.Count, FAsksTradeHistory._30Min.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._30Min.Amount, FAsksTradeHistory._30Min.Amount);
      end;

    c1Hour:
      begin
        LCount := IfThen(Column = 0, FBidsTradeHistory._1Hour.Count, FAsksTradeHistory._1Hour.Count);
        LAmount := IfThen(Column = 0, FBidsTradeHistory._1Hour.Amount, FAsksTradeHistory._1Hour.Amount);
      end;
  end;

  CellText := Format('%d', [LCount]) + ' (' + Format('%n', [LAmount]) + ' BTC)';
end;

end.
