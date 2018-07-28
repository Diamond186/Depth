unit uExchangeManager;

interface

uses
  SysUtils, Vcl.ExtCtrls, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  uSettigns

  , uExchangeClass
  , uDepthBinance
  , uDepthBittrex
  , uDepthKraken
  , uDepthBitstamp
  , uDepthBitfinex
  , uDepthHuobi
  , uDepthOkex
  , uDepthHitbtc
  , uDepthCoinbasePro
  , uCustomDepth;

type
  TExchangeManager = class
    private
      FTimer: TTimer;
      FTradesHistoryTimer: TTimer;
      FActive: Boolean;

      FBinance: TDepthBinance;
      FBittrex: TDepthBittrex;
//      FPoloniex: TDepthPoloniex;
      FBitfinex: TDepthBitfinex;
      FKraken: TDepthKraken;
      FBitstamp: TDepthBitstamp;
      FOkex: TDepthOkex;
      FHuobi: TDepthHuobi;
      FHitBTC: TDepthHitBTC;
      FCoinbasePro: TDepthCoinbasePro;

      FDepthBidsList,
      FDepthAsksList: TList<TPairDepth>;

      FBidsTradeHistory,
      FAsksTradeHistory: TTradeHistoryTotal;

      FOnUpdateDepth: TOnUpdateDepth;
      FOnUpdateStatistics24h: TOnUpdateStatistics24h;
      FOnUpdateTradeHistory: TProc;

      FAsksComparison,
      FBidsComparison: IComparer<TPairDepth>;

      FSettins: ISettigns;

      procedure DoDepthManage;

      procedure ApplyUpdate;
      procedure DeleteWhenLessAmount(aList: TList<TPairDepth>; const aMinAmount: Double);
      procedure RangeBetweenPrice(aList: TList<TPairDepth>; const aMinPrice, aMaxPrice: Double);
      function  GetTotalAmount(const aList: TList<TPairDepth>): Double;
      procedure DoTimer(Sender: TObject);
      procedure DoTradesHistoryTimer(Sender: TObject);
      procedure SetActive(const Value: Boolean);
      procedure DoTradeHistory;
    public
      constructor Create(const aSettins: ISettigns);
      destructor  Destroy; override;

      procedure BeginManage;
      procedure UpdateActiveExchange;
      procedure BeginTradeHistory;
      procedure BeginStatistics24h;

      function  GetDepthFromExchange(const aExchage: TExchange): TCustomDepth;

      property OnUpdateDepth: TOnUpdateDepth read FOnUpdateDepth write FOnUpdateDepth;
      property OnUpdateStatistics24h: TOnUpdateStatistics24h read FOnUpdateStatistics24h write FOnUpdateStatistics24h;
      property OnUpdateTradeHistory: TProc read FOnUpdateTradeHistory write FOnUpdateTradeHistory;

      property Active: Boolean read FActive write SetActive;
      property Settings: ISettigns read FSettins;

      property CoinbasePro: TDepthCoinbasePro read FCoinbasePro;
      property Binance: TDepthBinance read FBinance;
      property Bittrex: TDepthBittrex read FBittrex;
      property Bitfinex: TDepthBitfinex read FBitfinex;
      property Kraken: TDepthKraken read FKraken;
      property Bitstamp: TDepthBitstamp read FBitstamp;
      property Okex: TDepthOkex read FOkex;
      property Huobi: TDepthHuobi read FHuobi;
      property HitBTC: TDepthHitBTC read FHitBTC;

      property BidsTradeHistory: TTradeHistoryTotal read FBidsTradeHistory;
      property AsksTradeHistory: TTradeHistoryTotal read FAsksTradeHistory;
  end;

implementation

uses
  uLogging,
  System.Math;

{ TExchangeManager }

procedure TExchangeManager.ApplyUpdate;
var
  LPairDepth: TPairDepth;
  LIndex, i: Integer;
  LFullArr: TArray<TPairDepth>;
  LTotalBids, LTotalAsks,
  LMinPrice, LMaxPrice: Double;
  LStat24H: TStatistics24h;
begin
  if FBinance.ApplyUpdate
     and FBittrex.ApplyUpdate
     and FBitfinex.ApplyUpdate
     and FKraken.ApplyUpdate
     and FBitstamp.ApplyUpdate
     and FOkex.ApplyUpdate
     and FHuobi.ApplyUpdate
     and FHitbtc.ApplyUpdate
     and FCoinbasePro.ApplyUpdate
  then
  begin
    FDepthBidsList.Clear;
    FDepthBidsList.AddRange(FBinance.ArrDepthBids);
    FDepthBidsList.AddRange(FBittrex.ArrDepthBids);
    FDepthBidsList.AddRange(FBitfinex.ArrDepthBids);
    FDepthBidsList.AddRange(FKraken.ArrDepthBids);
    FDepthBidsList.AddRange(FBitstamp.ArrDepthBids);
    FDepthBidsList.AddRange(FOkex.ArrDepthBids);
    FDepthBidsList.AddRange(FHuobi.ArrDepthBids);
    FDepthBidsList.AddRange(FHitbtc.ArrDepthBids);
    FDepthBidsList.AddRange(FCoinbasePro.ArrDepthBids);

    FDepthAsksList.Clear;
    FDepthAsksList.AddRange(FBinance.ArrDepthAsks);
    FDepthAsksList.AddRange(FBittrex.ArrDepthAsks);
    FDepthAsksList.AddRange(FBitfinex.ArrDepthAsks);
    FDepthAsksList.AddRange(FKraken.ArrDepthAsks);
    FDepthAsksList.AddRange(FBitstamp.ArrDepthAsks);
    FDepthAsksList.AddRange(FOkex.ArrDepthAsks);
    FDepthAsksList.AddRange(FHuobi.ArrDepthAsks);
    FDepthAsksList.AddRange(FHitbtc.ArrDepthAsks);
    FDepthAsksList.AddRange(FCoinbasePro.ArrDepthAsks);

    LMaxPrice := 0;
    LMinPrice := 0;
    if FSettins.RangeIsPercent then
    begin
      LStat24H := nil;

      case FSettins.CurrentExchange of
        TExchange.CoinbasePro: LStat24H := FCoinbasePro.Statis24h;
        TExchange.Binance: LStat24H := FBinance.Statis24h;
        TExchange.Bitfinex: LStat24H := FBitfinex.Statis24h;
        TExchange.Bitstamp: LStat24H := FBitstamp.Statis24h;
        TExchange.Bittrex: LStat24H := FBittrex.Statis24h;
        TExchange.HitBTC: LStat24H := FHitBTC.Statis24h;
        TExchange.Huobi: LStat24H := FHuobi.Statis24h;
        TExchange.Kraken: LStat24H := FKraken.Statis24h;
        TExchange.Okex: LStat24H := FOkex.Statis24h;
      end;

      if Assigned(LStat24H) then
      begin
        LMinPrice := LStat24H.LastPrice - LStat24H.LastPrice * (FSettins.RangePercent / 100);
        LMaxPrice := LStat24H.LastPrice + LStat24H.LastPrice * (FSettins.RangePercent / 100);
      end;
    end
    else
    begin
      LMinPrice := FSettins.RangeMinPrice;
      LMaxPrice := FSettins.RangeMaxPrice;
    end;

    if (LMaxPrice > 0) and (LMinPrice > 0) then
    begin
      RangeBetweenPrice(FDepthBidsList, LMinPrice, LMaxPrice);
      RangeBetweenPrice(FDepthAsksList, LMinPrice, LMaxPrice);
    end;

    FDepthBidsList.Sort(FBidsComparison);
    FDepthAsksList.Sort(FAsksComparison);

    i := 0;
    while i + 1 < FDepthBidsList.Count do
      if FDepthBidsList[i].Price = FDepthBidsList[i + 1].Price then
      begin
        FDepthBidsList[i].AddPair(FDepthBidsList[i + 1]);
        FDepthBidsList.Delete(i + 1);
      end
      else
        Inc(i);

    // Asks list
    i := 0;
    while i + 1 < FDepthAsksList.Count do
      if FDepthAsksList[i].Price = FDepthAsksList[i + 1].Price then
      begin
        FDepthAsksList[i].AddPair(FDepthAsksList[i + 1]);
        FDepthAsksList.Delete(i + 1);
      end
      else
        Inc(i);

    LTotalBids := GetTotalAmount(FDepthBidsList);
    LTotalAsks := GetTotalAmount(FDepthAsksList);

    DeleteWhenLessAmount(FDepthBidsList, FSettins.MinPrice);
    DeleteWhenLessAmount(FDepthAsksList, FSettins.MinPrice);

    TThread.Synchronize(TThread.Current,
    procedure
    begin
      if Assigned(FOnUpdateStatistics24h) then
        FOnUpdateStatistics24h;

      if Assigned(FOnUpdateDepth) then
        FOnUpdateDepth(FDepthBidsList, FDepthAsksList, LTotalBids, LTotalAsks);
    end);

    FBinance.ApplyUpdate := False;
    FBittrex.ApplyUpdate := False;
    FBitfinex.ApplyUpdate := False;
    FKraken.ApplyUpdate := False;
    FBitstamp.ApplyUpdate := False;
    FOkex.ApplyUpdate := False;
    FHuobi.ApplyUpdate := False;
    FHitbtc.ApplyUpdate := False;
    FCoinbasePro.ApplyUpdate := False;

    // Запуск збору стаканів
    FTimer.Enabled := True;
  end;
end;

procedure TExchangeManager.DeleteWhenLessAmount(aList: TList<TPairDepth>;
                                                const aMinAmount: Double);
var
  i: Integer;
begin
  i := 0;

  while i < aList.Count do
  begin
    if aList[i].Amount <= aMinAmount then
      aList.Delete(i)
    else
      Inc(i);
  end;
end;

function TExchangeManager.GetDepthFromExchange(const aExchage: TExchange): TCustomDepth;
begin
  case aExchage of
    TExchange.CoinbasePro: Result := FCoinbasePro;
    TExchange.Binance: Result := FBinance;
    TExchange.Bitfinex: Result := FBitfinex;
    TExchange.Bitstamp: Result := FBitstamp;
    TExchange.Bittrex: Result := FBittrex;
    TExchange.HitBTC: Result := FHitBTC;
    TExchange.Huobi: Result := FHuobi;
    TExchange.Kraken: Result := FKraken;
    TExchange.Okex: Result := FOkex
  else
    Result := nil;
  end;
end;

function TExchangeManager.GetTotalAmount(const aList: TList<TPairDepth>): Double;
var
  LPair: TPairDepth;
begin
  Result := 0;

  for LPair in aList do
    Result := Result + LPair.Amount;
end;

procedure TExchangeManager.RangeBetweenPrice(aList: TList<TPairDepth>;
                                             const aMinPrice, aMaxPrice: Double);
var
  i: Integer;
begin
  i := 0;

  while i < aList.Count do
  begin
    if (aList[i].Price < aMinPrice)
      or (aList[i].Price > aMaxPrice)
    then
      aList.Delete(i)
    else
      Inc(i);
  end;
end;

procedure TExchangeManager.SetActive(const Value: Boolean);
begin
  FActive := Value;

  if FActive then
  begin
    BeginTradeHistory;
    BeginManage;
  end;
end;

procedure TExchangeManager.UpdateActiveExchange;
begin
  FBinance.Active := FSettins.UseBinance;
  FBittrex.Active := FSettins.UseBittrex;
  FBitfinex.Active := FSettins.UseBitfinex;
  FKraken.Active := FSettins.UseKraken;
  FBitstamp.Active := FSettins.UseBitstamp;
  FOkex.Active := FSettins.UseOkex;
  FHuobi.Active := FSettins.UseHuobi;
  FHitbtc.Active := FSettins.UseHitBTC;
  FCoinbasePro.Active := FSettins.UseCoinbasePro;

  Active := True;
end;

procedure TExchangeManager.BeginManage;
begin
  FBinance.BeginManage;
  FBittrex.BeginManage;
  FBitfinex.BeginManage;
  FKraken.BeginManage;
  FBitstamp.BeginManage;
  FOkex.BeginManage;
  FHuobi.BeginManage;
  FHitbtc.BeginManage;
  FCoinbasePro.BeginManage;
end;

procedure TExchangeManager.BeginStatistics24h;
begin
  FBinance.BeginStatistics24h;
  FBittrex.BeginStatistics24h;
  FBitfinex.BeginStatistics24h;
  FKraken.BeginStatistics24h;
  FBitstamp.BeginStatistics24h;
  FOkex.BeginStatistics24h;
  FHuobi.BeginStatistics24h;
  FHitbtc.BeginStatistics24h;
  FCoinbasePro.BeginStatistics24h;
end;

procedure TExchangeManager.BeginTradeHistory;
begin
  FBinance.BeginTradeHistory;
  FBittrex.BeginTradeHistory;
  FBitfinex.BeginTradeHistory;
  FKraken.BeginTradeHistory;
  FBitstamp.BeginTradeHistory;
  FOkex.BeginTradeHistory;
  FHuobi.BeginTradeHistory;
  FHitbtc.BeginTradeHistory;
  FCoinbasePro.BeginTradeHistory;
end;

constructor TExchangeManager.Create(const aSettins: ISettigns);
begin
  FSettins := aSettins;

  FAsksComparison := TDelegatedComparer<TPairDepth>.Construct(
    function(const Left, Right: TPairDepth): Integer
    begin
      Result := -1;

      if Assigned(Left) and Assigned(Right) then
        if Left.Price = Right.Price then Result := 0 else
        if Left.Price > Right.Price then Result := 1
        else
          Result := -1;
    end);

  FBidsComparison := TDelegatedComparer<TPairDepth>.Construct(
    function(const Left, Right: TPairDepth): Integer
    begin
      Result := -1;

      if Assigned(Left) and Assigned(Right) then
        if Left.Price = Right.Price then Result := 0 else
        if Left.Price < Right.Price then Result := 1
        else
          Result := -1;
    end);

  FDepthBidsList := TList<TPairDepth>.Create;
  FDepthAsksList := TList<TPairDepth>.Create;
  FAsksTradeHistory  := TTradeHistoryTotal.Create;
  FBidsTradeHistory  := TTradeHistoryTotal.Create;

  FBinance := TDepthBinance.Create;
  FBinance.OnDepthManage := DoDepthManage;
  FBinance.OnTradeHistory := DoTradeHistory;
  FBinance.Active := FSettins.UseBinance;

  FBittrex := TDepthBittrex.Create;
  FBittrex.OnDepthManage := DoDepthManage;
  FBittrex.OnTradeHistory := DoTradeHistory;
  FBittrex.Active := FSettins.UseBittrex;

  FBitfinex := TDepthBitfinex.Create;
  FBitfinex.OnDepthManage := DoDepthManage;
  FBitfinex.OnTradeHistory := DoTradeHistory;
  FBitfinex.Active := FSettins.UseBitfinex;

  FKraken := TDepthKraken.Create;
  FKraken.OnDepthManage := DoDepthManage;
  FKraken.OnTradeHistory := DoTradeHistory;
  FKraken.Active := FSettins.UseKraken;

  FBitstamp := TDepthBitstamp.Create;
  FBitstamp.OnDepthManage := DoDepthManage;
  FBitstamp.OnTradeHistory := DoTradeHistory;
  FBitstamp.Active := FSettins.UseBitstamp;

  FOkex := TDepthOkex.Create;
  FOkex.OnDepthManage := DoDepthManage;
  FOkex.OnTradeHistory := DoTradeHistory;
  FOkex.Active := FSettins.UseOkex;

  FHuobi := TDepthHuobi.Create;
  FHuobi.OnDepthManage := DoDepthManage;
  FHuobi.OnTradeHistory := DoTradeHistory;
  FHuobi.Active := FSettins.UseHuobi;

  FHitBTC := TDepthHitbtc.Create;
  FHitBTC.OnDepthManage := DoDepthManage;
  FHitBTC.OnTradeHistory := DoTradeHistory;
  FHitBTC.Active := FSettins.UseHitBTC;

  FCoinbasePro := TDepthCoinbasePro.Create;
  FCoinbasePro.OnDepthManage := DoDepthManage;
  FCoinbasePro.OnTradeHistory := DoTradeHistory;
  FCoinbasePro.Active := FSettins.UseCoinbasePro;

//  FPoloniex := TDepthPoloniex.Create;
//  FPoloniex.OnDepthManage := DoDepthManageBittrex;

  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 5000;
  FTimer.OnTimer := DoTimer;

  FTradesHistoryTimer := TTimer.Create(nil);
  FTradesHistoryTimer.Enabled := False;
  FTradesHistoryTimer.Interval := 1000;
  FTradesHistoryTimer.OnTimer := DoTradesHistoryTimer;
end;

destructor TExchangeManager.Destroy;
begin
  FTimer.Enabled := False;
  FreeAndNil(FTimer);

  FreeAndNil(FBinance);
  FreeAndNil(FBittrex);
  FreeAndNil(FBitfinex);
  FreeAndNil(FKraken);
  FreeAndNil(FBitstamp);
  FreeAndNil(FOkex);
  FreeAndNil(FHuobi);
  FreeAndNil(FHitbtc);
  FreeAndNil(FCoinbasePro);
//  FreeAndNil(FPoloniex);

  FreeAndNil(FDepthAsksList);
  FreeAndNil(FDepthBidsList);
  FreeAndNil(FAsksTradeHistory);
  FreeAndNil(FBidsTradeHistory);

  inherited;
end;

procedure TExchangeManager.DoDepthManage;
begin
  ApplyUpdate;
end;

procedure TExchangeManager.DoTimer(Sender: TObject);
begin
  FTimer.Enabled := False;

  if Active then
    BeginManage;
end;

procedure TExchangeManager.DoTradeHistory;
begin
  if FBinance.TradeHistoryApplyUpdate
    and FBittrex.TradeHistoryApplyUpdate
    and FBitfinex.TradeHistoryApplyUpdate
    and FKraken.TradeHistoryApplyUpdate
    and FBitstamp.TradeHistoryApplyUpdate
    and FOkex.TradeHistoryApplyUpdate
    and FHuobi.TradeHistoryApplyUpdate
    and FHitBTC.TradeHistoryApplyUpdate
    and FCoinbasePro.TradeHistoryApplyUpdate
  then
  begin
    FAsksTradeHistory.SetOneSec(FBinance.AsksTradeHistory.OneSec.Count +
                                FBittrex.AsksTradeHistory.OneSec.Count +
                                FBitfinex.AsksTradeHistory.OneSec.Count +
                                FKraken.AsksTradeHistory.OneSec.Count +
                                FBitstamp.AsksTradeHistory.OneSec.Count +
                                FOkex.AsksTradeHistory.OneSec.Count +
                                FHuobi.AsksTradeHistory.OneSec.Count +
                                FHitBTC.AsksTradeHistory.OneSec.Count +
                                FCoinbasePro.AsksTradeHistory.OneSec.Count,
                                FBinance.AsksTradeHistory.OneSec.Amount +
                                FBittrex.AsksTradeHistory.OneSec.Amount +
                                FBitfinex.AsksTradeHistory.OneSec.Amount +
                                FKraken.AsksTradeHistory.OneSec.Amount +
                                FBitstamp.AsksTradeHistory.OneSec.Amount +
                                FOkex.AsksTradeHistory.OneSec.Amount +
                                FHuobi.AsksTradeHistory.OneSec.Amount +
                                FHitBTC.AsksTradeHistory.OneSec.Amount +
                                FCoinbasePro.AsksTradeHistory.OneSec.Amount);

    FAsksTradeHistory.Set15Sec(FBinance.AsksTradeHistory._15Sec.Count +
                               FBittrex.AsksTradeHistory._15Sec.Count +
                               FBitfinex.AsksTradeHistory._15Sec.Count +
                               FKraken.AsksTradeHistory._15Sec.Count +
                               FBitstamp.AsksTradeHistory._15Sec.Count +
                               FOkex.AsksTradeHistory._15Sec.Count +
                               FHuobi.AsksTradeHistory._15Sec.Count +
                               FHitBTC.AsksTradeHistory._15Sec.Count +
                               FCoinbasePro.AsksTradeHistory._15Sec.Count,
                               FBinance.AsksTradeHistory._15Sec.Amount +
                               FBittrex.AsksTradeHistory._15Sec.Amount +
                               FBitfinex.AsksTradeHistory._15Sec.Amount +
                               FKraken.AsksTradeHistory._15Sec.Amount +
                               FBitstamp.AsksTradeHistory._15Sec.Amount +
                               FOkex.AsksTradeHistory._15Sec.Amount +
                               FHuobi.AsksTradeHistory._15Sec.Amount +
                               FHitBTC.AsksTradeHistory._15Sec.Amount +
                               FCoinbasePro.AsksTradeHistory._15Sec.Amount);

    FAsksTradeHistory.Set30Sec(FBinance.AsksTradeHistory._30Sec.Count +
                               FBittrex.AsksTradeHistory._30Sec.Count +
                               FBitfinex.AsksTradeHistory._30Sec.Count +
                               FKraken.AsksTradeHistory._30Sec.Count +
                               FBitstamp.AsksTradeHistory._30Sec.Count +
                               FOkex.AsksTradeHistory._30Sec.Count +
                               FHuobi.AsksTradeHistory._30Sec.Count +
                               FHitBTC.AsksTradeHistory._30Sec.Count +
                               FCoinbasePro.AsksTradeHistory._30Sec.Count,
                               FBinance.AsksTradeHistory._30Sec.Amount +
                               FBittrex.AsksTradeHistory._30Sec.Amount +
                               FBitfinex.AsksTradeHistory._30Sec.Amount +
                               FKraken.AsksTradeHistory._30Sec.Amount +
                               FBitstamp.AsksTradeHistory._30Sec.Amount +
                               FOkex.AsksTradeHistory._30Sec.Amount +
                               FHuobi.AsksTradeHistory._30Sec.Amount +
                               FHitBTC.AsksTradeHistory._30Sec.Amount +
                               FCoinbasePro.AsksTradeHistory._30Sec.Amount);

    FAsksTradeHistory.Set1Min(FBinance.AsksTradeHistory._1Min.Count +
                              FBittrex.AsksTradeHistory._1Min.Count +
                              FBitfinex.AsksTradeHistory._1Min.Count +
                              FKraken.AsksTradeHistory._1Min.Count +
                              FBitstamp.AsksTradeHistory._1Min.Count +
                              FOkex.AsksTradeHistory._1Min.Count +
                              FHuobi.AsksTradeHistory._1Min.Count +
                              FHitBTC.AsksTradeHistory._1Min.Count +
                              FCoinbasePro.AsksTradeHistory._1Min.Count,
                              FBinance.AsksTradeHistory._1Min.Amount +
                              FBittrex.AsksTradeHistory._1Min.Amount +
                              FBitfinex.AsksTradeHistory._1Min.Amount +
                              FKraken.AsksTradeHistory._1Min.Amount +
                              FBitstamp.AsksTradeHistory._1Min.Amount +
                              FOkex.AsksTradeHistory._1Min.Amount +
                              FHuobi.AsksTradeHistory._1Min.Amount +
                              FHitBTC.AsksTradeHistory._1Min.Amount +
                              FCoinbasePro.AsksTradeHistory._1Min.Amount);

    FAsksTradeHistory.Set15Min(FBinance.AsksTradeHistory._15Min.Count +
                               FBittrex.AsksTradeHistory._15Min.Count +
                               FBitfinex.AsksTradeHistory._15Min.Count +
                               FKraken.AsksTradeHistory._15Min.Count +
                               FBitstamp.AsksTradeHistory._15Min.Count +
                               FOkex.AsksTradeHistory._15Min.Count +
                               FHuobi.AsksTradeHistory._15Min.Count +
                               FHitBTC.AsksTradeHistory._15Min.Count +
                               FCoinbasePro.AsksTradeHistory._15Min.Count,
                               FBinance.AsksTradeHistory._15Min.Amount +
                               FBittrex.AsksTradeHistory._15Min.Amount +
                               FBitfinex.AsksTradeHistory._15Min.Amount +
                               FKraken.AsksTradeHistory._15Min.Amount +
                               FBitstamp.AsksTradeHistory._15Min.Amount +
                               FOkex.AsksTradeHistory._15Min.Amount +
                               FHuobi.AsksTradeHistory._15Min.Amount +
                               FHitBTC.AsksTradeHistory._15Min.Amount +
                               FCoinbasePro.AsksTradeHistory._15Min.Amount);

    FAsksTradeHistory.Set30Min(FBinance.AsksTradeHistory._30Min.Count +
                               FBittrex.AsksTradeHistory._30Min.Count +
                               FBitfinex.AsksTradeHistory._30Min.Count +
                               FKraken.AsksTradeHistory._30Min.Count +
                               FBitstamp.AsksTradeHistory._30Min.Count +
                               FOkex.AsksTradeHistory._30Min.Count +
                               FHuobi.AsksTradeHistory._30Min.Count +
                               FHitBTC.AsksTradeHistory._30Min.Count +
                               FCoinbasePro.AsksTradeHistory._30Min.Count,
                               FBinance.AsksTradeHistory._30Min.Amount +
                               FBittrex.AsksTradeHistory._30Min.Amount +
                               FBitfinex.AsksTradeHistory._30Min.Amount +
                               FKraken.AsksTradeHistory._30Min.Amount +
                               FBitstamp.AsksTradeHistory._30Min.Amount +
                               FOkex.AsksTradeHistory._30Min.Amount +
                               FHuobi.AsksTradeHistory._30Min.Amount +
                               FHitBTC.AsksTradeHistory._30Min.Amount +
                               FCoinbasePro.AsksTradeHistory._30Min.Amount);

    FAsksTradeHistory.Set1Hour(FBinance.AsksTradeHistory._1Hour.Count +
                               FBittrex.AsksTradeHistory._1Hour.Count +
                               FBitfinex.AsksTradeHistory._1Hour.Count +
                               FKraken.AsksTradeHistory._1Hour.Count +
                               FBitstamp.AsksTradeHistory._1Hour.Count +
                               FOkex.AsksTradeHistory._1Hour.Count +
                               FHuobi.AsksTradeHistory._1Hour.Count +
                               FHitBTC.AsksTradeHistory._1Hour.Count +
                               FCoinbasePro.AsksTradeHistory._1Hour.Count,
                               FBinance.AsksTradeHistory._1Hour.Amount +
                               FBittrex.AsksTradeHistory._1Hour.Amount +
                               FBitfinex.AsksTradeHistory._1Hour.Amount +
                               FKraken.AsksTradeHistory._1Hour.Amount +
                               FBitstamp.AsksTradeHistory._1Hour.Amount +
                               FOkex.AsksTradeHistory._1Hour.Amount +
                               FHuobi.AsksTradeHistory._1Hour.Amount +
                               FHitBTC.AsksTradeHistory._1Hour.Amount +
                               FCoinbasePro.AsksTradeHistory._1Hour.Amount);

    FBidsTradeHistory.SetOneSec(FBinance.BidsTradeHistory.OneSec.Count +
                                FBittrex.BidsTradeHistory.OneSec.Count +
                                FBitfinex.BidsTradeHistory.OneSec.Count +
                                FKraken.BidsTradeHistory.OneSec.Count +
                                FBitstamp.BidsTradeHistory.OneSec.Count +
                                FOkex.BidsTradeHistory.OneSec.Count +
                                FHuobi.BidsTradeHistory.OneSec.Count +
                                FHitBTC.BidsTradeHistory.OneSec.Count +
                                FCoinbasePro.BidsTradeHistory.OneSec.Count,
                                FBinance.BidsTradeHistory.OneSec.Amount +
                                FBittrex.BidsTradeHistory.OneSec.Amount +
                                FBitfinex.BidsTradeHistory.OneSec.Amount +
                                FKraken.BidsTradeHistory.OneSec.Amount +
                                FBitstamp.BidsTradeHistory.OneSec.Amount +
                                FOkex.BidsTradeHistory.OneSec.Amount +
                                FHuobi.BidsTradeHistory.OneSec.Amount +
                                FHitBTC.BidsTradeHistory.OneSec.Amount +
                                FCoinbasePro.BidsTradeHistory.OneSec.Amount);

    FBidsTradeHistory.Set15Sec(FBinance.BidsTradeHistory._15Sec.Count +
                               FBittrex.BidsTradeHistory._15Sec.Count +
                               FBitfinex.BidsTradeHistory._15Sec.Count +
                               FKraken.BidsTradeHistory._15Sec.Count +
                               FBitstamp.BidsTradeHistory._15Sec.Count +
                               FOkex.BidsTradeHistory._15Sec.Count +
                               FHuobi.BidsTradeHistory._15Sec.Count +
                               FHitBTC.BidsTradeHistory._15Sec.Count +
                               FCoinbasePro.BidsTradeHistory._15Sec.Count,
                               FBinance.BidsTradeHistory._15Sec.Amount +
                               FBittrex.BidsTradeHistory._15Sec.Amount +
                               FBitfinex.BidsTradeHistory._15Sec.Amount +
                               FKraken.BidsTradeHistory._15Sec.Amount +
                               FBitstamp.BidsTradeHistory._15Sec.Amount +
                               FOkex.BidsTradeHistory._15Sec.Amount +
                               FHuobi.BidsTradeHistory._15Sec.Amount +
                               FHitBTC.BidsTradeHistory._15Sec.Amount +
                               FCoinbasePro.BidsTradeHistory._15Sec.Amount);

    FBidsTradeHistory.Set30Sec(FBinance.BidsTradeHistory._30Sec.Count +
                               FBittrex.BidsTradeHistory._30Sec.Count +
                               FBitfinex.BidsTradeHistory._30Sec.Count +
                               FKraken.BidsTradeHistory._30Sec.Count +
                               FBitstamp.BidsTradeHistory._30Sec.Count +
                               FOkex.BidsTradeHistory._30Sec.Count +
                               FHuobi.BidsTradeHistory._30Sec.Count +
                               FHitBTC.BidsTradeHistory._30Sec.Count +
                               FCoinbasePro.BidsTradeHistory._30Sec.Count,
                               FBinance.BidsTradeHistory._30Sec.Amount +
                               FBittrex.BidsTradeHistory._30Sec.Amount +
                               FBitfinex.BidsTradeHistory._30Sec.Amount +
                               FKraken.BidsTradeHistory._30Sec.Amount +
                               FBitstamp.BidsTradeHistory._30Sec.Amount +
                               FOkex.BidsTradeHistory._30Sec.Amount +
                               FHuobi.BidsTradeHistory._30Sec.Amount +
                               FHitBTC.BidsTradeHistory._30Sec.Amount +
                               FCoinbasePro.BidsTradeHistory._30Sec.Amount);

    FBidsTradeHistory.Set1Min(FBinance.BidsTradeHistory._1Min.Count +
                              FBittrex.BidsTradeHistory._1Min.Count +
                              FBitfinex.BidsTradeHistory._1Min.Count +
                              FKraken.BidsTradeHistory._1Min.Count +
                              FBitstamp.BidsTradeHistory._1Min.Count +
                              FOkex.BidsTradeHistory._1Min.Count +
                              FHuobi.BidsTradeHistory._1Min.Count +
                              FHitBTC.BidsTradeHistory._1Min.Count +
                              FCoinbasePro.BidsTradeHistory._1Min.Count,
                              FBinance.BidsTradeHistory._1Min.Amount +
                              FBittrex.BidsTradeHistory._1Min.Amount +
                              FBitfinex.BidsTradeHistory._1Min.Amount +
                              FKraken.BidsTradeHistory._1Min.Amount +
                              FBitstamp.BidsTradeHistory._1Min.Amount +
                              FOkex.BidsTradeHistory._1Min.Amount +
                              FHuobi.BidsTradeHistory._1Min.Amount +
                              FHitBTC.BidsTradeHistory._1Min.Amount +
                              FCoinbasePro.BidsTradeHistory._1Min.Amount);

    FBidsTradeHistory.Set15Min(FBinance.BidsTradeHistory._15Min.Count +
                               FBittrex.BidsTradeHistory._15Min.Count +
                               FBitfinex.BidsTradeHistory._15Min.Count +
                               FKraken.BidsTradeHistory._15Min.Count +
                               FBitstamp.BidsTradeHistory._15Min.Count +
                               FOkex.BidsTradeHistory._15Min.Count +
                               FHuobi.BidsTradeHistory._15Min.Count +
                               FHitBTC.BidsTradeHistory._15Min.Count +
                               FCoinbasePro.BidsTradeHistory._15Min.Count,
                               FBinance.BidsTradeHistory._15Min.Amount +
                               FBittrex.BidsTradeHistory._15Min.Amount +
                               FBitfinex.BidsTradeHistory._15Min.Amount +
                               FKraken.BidsTradeHistory._15Min.Amount +
                               FBitstamp.BidsTradeHistory._15Min.Amount +
                               FOkex.BidsTradeHistory._15Min.Amount +
                               FHuobi.BidsTradeHistory._15Min.Amount +
                               FHitBTC.BidsTradeHistory._15Min.Amount +
                               FCoinbasePro.BidsTradeHistory._15Min.Amount);

    FBidsTradeHistory.Set30Min(FBinance.BidsTradeHistory._30Min.Count +
                               FBittrex.BidsTradeHistory._30Min.Count +
                               FBitfinex.BidsTradeHistory._30Min.Count +
                               FKraken.BidsTradeHistory._30Min.Count +
                               FBitstamp.BidsTradeHistory._30Min.Count +
                               FOkex.BidsTradeHistory._30Min.Count +
                               FHuobi.BidsTradeHistory._30Min.Count +
                               FHitBTC.BidsTradeHistory._30Min.Count +
                               FCoinbasePro.BidsTradeHistory._30Min.Count,
                               FBinance.BidsTradeHistory._30Min.Amount +
                               FBittrex.BidsTradeHistory._30Min.Amount +
                               FBitfinex.BidsTradeHistory._30Min.Amount +
                               FKraken.BidsTradeHistory._30Min.Amount +
                               FBitstamp.BidsTradeHistory._30Min.Amount +
                               FOkex.BidsTradeHistory._30Min.Amount +
                               FHuobi.BidsTradeHistory._30Min.Amount +
                               FHitBTC.BidsTradeHistory._30Min.Amount +
                               FCoinbasePro.BidsTradeHistory._30Min.Amount);

    FBidsTradeHistory.Set1Hour(FBinance.BidsTradeHistory._1Hour.Count +
                               FBittrex.BidsTradeHistory._1Hour.Count +
                               FBitfinex.BidsTradeHistory._1Hour.Count +
                               FKraken.BidsTradeHistory._1Hour.Count +
                               FBitstamp.BidsTradeHistory._1Hour.Count +
                               FOkex.BidsTradeHistory._1Hour.Count +
                               FHuobi.BidsTradeHistory._1Hour.Count +
                               FHitBTC.BidsTradeHistory._1Hour.Count +
                               FCoinbasePro.BidsTradeHistory._1Hour.Count,
                               FBinance.BidsTradeHistory._1Hour.Amount +
                               FBittrex.BidsTradeHistory._1Hour.Amount +
                               FBitfinex.BidsTradeHistory._1Hour.Amount +
                               FKraken.BidsTradeHistory._1Hour.Amount +
                               FBitstamp.BidsTradeHistory._1Hour.Amount +
                               FOkex.BidsTradeHistory._1Hour.Amount +
                               FHuobi.BidsTradeHistory._1Hour.Amount +
                               FHitBTC.BidsTradeHistory._1Hour.Amount +
                               FCoinbasePro.BidsTradeHistory._1Hour.Amount);

    TThread.Synchronize(TThread.Current,
    procedure
    begin
      if Assigned(FOnUpdateTradeHistory) then
        FOnUpdateTradeHistory;
    end);

    FBinance.TradeHistoryApplyUpdate := False;
    FBittrex.TradeHistoryApplyUpdate := False;
    FBitfinex.TradeHistoryApplyUpdate := False;
    FKraken.TradeHistoryApplyUpdate := False;
    FBitstamp.TradeHistoryApplyUpdate := False;
    FOkex.TradeHistoryApplyUpdate := False;
    FHuobi.TradeHistoryApplyUpdate := False;
    FHitbtc.TradeHistoryApplyUpdate := False;
    FCoinbasePro.TradeHistoryApplyUpdate := False;

    // Запуск збору стаканів
    FTradesHistoryTimer.Enabled := True;
  end;
end;

procedure TExchangeManager.DoTradesHistoryTimer(Sender: TObject);
begin
  FTradesHistoryTimer.Enabled := False;

  if Active then
    BeginTradeHistory;
end;

end.
