unit uDepthBitMEX;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBitMEX = class(TCustomDepth)
    private
      const
        cDepthURL = 'https://www.bitmex.com/api/v1/orderBook/L2?symbol=XBT&depth=0';
        c24hURL = 'https://api.bitfinex.com/v1/pubticker/BTCUSD';
        cTradesHistoryURL = 'https://api.bitfinex.com/v1/trades/BTCUSD';

      var
        FWait: Word;

      procedure ParseResponse(const aResponse: string);
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
  System.JSON, uExchangeClass, uLogging;

{ TDepthBitfinex }

procedure TDepthBitMEX.ParseResponse(const aResponse: string);
var
  LJSON, LItem: TJSONValue;
  LArr: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      //  bids
      if LJSON.TryGetValue<TJSONArray>('bids', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONValue>;

          FArrDepthBids[i] := TPairDepth.Create(LItem.GetValue<Currency>('price'),
                                                LItem.GetValue<Double>('amount'),
                                                TExchange.Bitfinex);
        end;
      end;

      // asks
      if LJSON.TryGetValue<TJSONArray>('asks', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONValue>;

          FArrDepthAsks[i] := TPairDepth.Create(LItem.GetValue<Currency>('price'),
                                                LItem.GetValue<Double>('amount'),
                                                TExchange.Bitfinex);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthBitMEX.ParseResponse24h(const aResponse: string);
var
  LJSON: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<String>('last_price', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('high', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('volume', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthBitMEX.ParseResponseTradesHistory(const aResponse: string);
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
  LSumBidsTrades := 0;
  LSumAsksTrades := 0;
  LCountBidsTrades := 0;
  LCountAsksTrades := 0;

  if not aResponse.IsEmpty then
  begin

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LArr := LJSON.GetValue<TJSONArray>;

      if LArr.Count > 0 then
      begin
        if FLastTimestamp = 0 then
          FLastTimestamp := LArr.Items[LArr.Count - 1].GetValue<Int64>('timestamp');

        for i := LArr.Count - 1 downto 0 do
        begin
          LTime := LArr.Items[i].GetValue<Int64>('timestamp');

          if LTime > FLastTimestamp then
          begin
            LAmount := LArr.Items[i].GetValue<string>('amount').ToDouble;
            LIsBuyerMaker := LArr.Items[i].GetValue<string>('type') = 'sell';

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
          end;
        end;

        FLastTimestamp := LArr.Items[0].GetValue<Int64>('timestamp');
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
  FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthBitMEX.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP_Statistics24h.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthBitMEX.TradesHistory;
var
  LRes: string;
begin
  inherited;

  if FWait = 0 then
    try
      if FLastTimestamp = 0 then
        LRes := FIdHTTP_TradesHistory.Get(cTradesHistoryURL + '?limit_trades=1')
      else
        LRes := FIdHTTP_TradesHistory.Get(cTradesHistoryURL + '?timestamp=' + FLastTimestamp.ToString);

      // wait 5 sec for geting trades
      FWait := 5;
    except
      on E: Exception do
      begin
        LRes := EmptyStr;
        Self.TradeHistoryApplyUpdate := True;
      end;
    end
  else
  begin
    Dec(FWait);
    LRes := EmptyStr;
  end;

  ParseResponseTradesHistory(LRes);

  if Assigned(FTradeHistoryProc)
    and (TradeHistoryApplyUpdate or LRes.IsEmpty)
  then
    FTradeHistoryProc;
end;

constructor TDepthBitMEX.Create;
begin
  inherited;

  FWait := 0;
  FExchange := TExchange.Bitfinex;
end;

procedure TDepthBitMEX.Depth;
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

  ParseResponse(LRes);

  if Assigned(FDepthManage)
    and (ApplyUpdate or LRes.IsEmpty)
  then
      FDepthManage;
end;

end.
