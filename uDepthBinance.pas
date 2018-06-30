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
        cTradesHistoryURL = 'https://api.binance.com/api/v1/trades?symbol=BTCUSDT&limit=300';

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
  i: Integer;
  LTime: Int64;
  LAmount: Double;
  LIsBuyerMaker: Boolean;
  LSumBidsTrades,
  LSumAsksTrades: Double;
  LCountBidsTrades,
  LCountAsksTrades: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    LSumBidsTrades := 0;
    LSumAsksTrades := 0;
    LCountBidsTrades := 0;
    LCountAsksTrades := 0;

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LArr := LJSON.GetValue<TJSONArray>;

      if LArr.Count > 0 then
      begin
        if FLastTimestamp = 0 then
          FLastTimestamp := LArr.Items[LArr.Count - 1].GetValue<Int64>('time');

        for i := LArr.Count - 1 downto 0 do
        begin
          LTime := LArr.Items[i].GetValue<Int64>('time');

          if LTime > FLastTimestamp then
          begin
            LAmount := LArr.Items[i].GetValue<string>('qty').ToDouble;
            LIsBuyerMaker := LArr.Items[i].GetValue<Boolean>('isBuyerMaker');

            if LIsBuyerMaker then
            begin
              LSumAsksTrades := LSumAsksTrades + LAmount;
              Inc(LCountAsksTrades);
            end
            else
            begin
              LSumBidsTrades := LSumBidsTrades + LAmount;
              Inc(LCountBidsTrades);
            end;
          end
          else
            Break;
        end;

        FLastTimestamp := LArr.Items[LArr.Count - 1].GetValue<Int64>('time');

        FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
        FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);
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
    ParseResponse24h(FIdHTTP_Statistics24h.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthBinance.TradesHistory;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_TradesHistory.Get(cTradesHistoryURL);
  except
    on E: Exception do
    begin
      LRes := EmptyStr;
      Self.TradeHistoryApplyUpdate := True;
    end;
  end;

  ParseResponseTradesHistory(LRes);

  if Assigned(FTradeHistoryProc)
    and (TradeHistoryApplyUpdate or LRes.IsEmpty)
  then
    FTradeHistoryProc;
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
    LRes := FIdHTTP_Depth.Get(cDepthURL);
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
