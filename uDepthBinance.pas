unit uDepthBinance;

interface

uses
  System.SysUtils, System.Classes, uExchangeClass,
  uCustomDepth;

type
  TDepthBinance = class(TCustomDepth)
    private
      const
        cDepthURL = 'https://api.binance.com/api/v1/depth?symbol=BTCUSDT&limit=1000';
        c24hURL = 'https://api.binance.com/api/v1/ticker/24hr?symbol=BTCUSDT';
        cTradesHistoryURL = 'https://api.binance.com/api/v1/trades?symbol=BTCUSDT&limit=100';


      procedure ParseResponseDepth(const aResponse: string);
      procedure ParseResponse24h(const aResponse: string);
      procedure ParseResponseTradesHistory(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
      procedure TradesHistory; override;
    public
      constructor Create; override;
  end;

implementation

uses
  System.JSON, uLogging;

{ TDepthBinance }

procedure TDepthBinance.ParseResponse24h(const aResponse: string);
var
  LJSON: TJSONValue;
  LStr: String;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<String>('symbol', LStr) then
        FStatistics24h.Symbol := LStr;

      if LJSON.TryGetValue<String>('priceChange', LStr) then
        FStatistics24h.PriceChange := LStr.ToExtended;

      if LJSON.TryGetValue<String>('priceChangePercent', LStr) then
        FStatistics24h.PriceChangePercent := LStr;

      if LJSON.TryGetValue<String>('weightedAvgPrice', LStr) then
        FStatistics24h.WeightedAvgPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('prevClosePrice', LStr) then
        FStatistics24h.PrevClosePrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('lastPrice', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('lastQty', LStr) then
        FStatistics24h.LastQty := LStr.ToDouble;

      if LJSON.TryGetValue<String>('bidPrice', LStr) then
        FStatistics24h.BidPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('askPrice', LStr) then
        FStatistics24h.AskPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('openPrice', LStr) then
        FStatistics24h.OpenPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('highPrice', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('lowPrice', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('volume', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;

      if LJSON.TryGetValue<Integer>('count', i) then
        FStatistics24h.Count := i;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthBinance.ParseResponseDepth(const aResponse: string);
var
  LJSON: TJSONValue;
  LArr, LItem: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    Clear;

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      //  bids
      if LJSON.TryGetValue<TJSONArray>('bids', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;

          FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                LItem.Items[1].GetValue<Double>,
                                                TExchange.Binance);
        end;
      end;

      // asks
      if LJSON.TryGetValue<TJSONArray>('asks', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;

          FArrDepthAsks[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                LItem.Items[1].GetValue<Double>,
                                                TExchange.Binance);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthBinance.ParseResponseTradesHistory(const aResponse: string);
var
  LJSON: TJSONValue;
  LArr: TJSONArray;
  i, LTime: Integer;
  LAmount: Double;
  LIsBuyerMaker: Boolean;
begin
  if not aResponse.IsEmpty then
  begin
    FSumBidsTrades := 0;
    FSumAsksTrades := 0;
    FTradesList.Clear;

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LArr := LJSON.GetValue<TJSONArray>;

      if LArr.Count > 0 then
      begin
        if FLastTradeHistoryTime = 0 then
          FLastTradeHistoryTime := LArr.Items[LArr.Count - 1].GetValue<Int64>('time');

        for i := LArr.Count - 1 downto 0 do
        begin
          LTime := LArr.Items[LArr.Count - 1].GetValue<Int64>('time');

          if LTime > FLastTradeHistoryTime - cIntervalTradeHistory then
          begin
            LAmount := LArr.Items[LArr.Count - 1].GetValue<string>('qty').ToDouble;
            LIsBuyerMaker := LArr.Items[LArr.Count - 1].GetValue<Boolean>('isBuyerMaker');

            if LIsBuyerMaker then
              FSumBidsTrades := FSumBidsTrades + LAmount
            else
              FSumAsksTrades := FSumAsksTrades + LAmount;

            FTradesList.Add(TTrade.Create(LAmount, LIsBuyerMaker));
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthBinance.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthBinance.TradesHistory;
begin
  inherited;

  ParseResponseTradesHistory(FIdHTTP.Get(cTradesHistoryURL));
end;

constructor TDepthBinance.Create;
begin
  inherited;

  FExchange := TExchange.Binance;
end;

procedure TDepthBinance.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(cDepthURL);
  except
    on E: Exception do
    begin
      LRes := EmptyStr;
      ApplyUpdate := True;

      TTestRun.AddMarker('Error: ' + E.Message);
    end;
  end;

  ParseResponseDepth(LRes);

  if Assigned(FDepthManage)
    and (ApplyUpdate or LRes.IsEmpty)
  then
      FDepthManage;
end;

end.
