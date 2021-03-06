unit uDepthBittrex;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBittrex = class(TCustomDepth)
    private
      const
        depthBittrex = 'https://bittrex.com/api/v1.1/public/getorderbook?market=USDT-BTC&type=both';
        StatisURL = 'https://bittrex.com/api/v1.1/public/getmarketsummary?market=USDT-BTC';
        cTradesHistoryURL = 'https://bittrex.com/api/v1.1/public/getmarkethistory?market=%s';

      procedure ParseResponse(const aResponse: string);
      procedure ParseResponseStatis24h(const aResponse: string);
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

{ TDepthBittrex }

procedure TDepthBittrex.ParseResponse(const aResponse: string);
var
  LJSON, LRes, LItem: TJSONValue;
  LArr: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LRes := LJSON.GetValue<TJSONObject>('result');

      //  buy
      if LRes.TryGetValue<TJSONArray>('buy', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONValue>;

          FArrDepthBids[i] := TPairDepth.Create(LItem.GetValue<Currency>('Rate'),
                                                LItem.GetValue<Double>('Quantity'),
                                                TExchange.Bittrex);
        end;
      end;

      // sell
      if LRes.TryGetValue<TJSONArray>('sell', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONValue>;

          FArrDepthAsks[i] := TPairDepth.Create(LItem.GetValue<Currency>('Rate'),
                                                LItem.GetValue<Double>('Quantity'),
                                                TExchange.Bittrex);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthBittrex.ParseResponseStatis24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONArray>('result').Items[0];

      if LObj.TryGetValue<String>('MarketName', LStr) then
        FStatistics24h.Symbol := LStr;

      if LObj.TryGetValue<String>('Last', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('High', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('Low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('Volume', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthBittrex.ParseResponseTradesHistory(const aResponse: string);
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
      LArr := LJSON.GetValue<TJSONValue>.GetValue<TJSONArray>('result');

      if LArr.Count > 0 then
      begin
        if FLastTimestamp = 0 then
          FLastTimestamp := LArr.Items[0].GetValue<Int64>('Id');

        for i := 0 to LArr.Count - 1 do
        begin
          LTime := LArr.Items[i].GetValue<Int64>('Id');

          if LTime > FLastTimestamp then
          begin
            LAmount := LArr.Items[i].GetValue<string>('Quantity').ToDouble;
            LIsBuyerMaker := LArr.Items[i].GetValue<string>('OrderType') = 'SELL';

            if LIsBuyerMaker then
            begin
              LSumBidsTrades := LSumBidsTrades + LAmount;
              Inc(LCountBidsTrades);
            end
            else
            begin
              LSumAsksTrades := LSumAsksTrades + LAmount;
              Inc(LCountAsksTrades);
            end;
          end
          else
            Break;
        end;

        FLastTimestamp := LArr.Items[0].GetValue<Int64>('Id');

        FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
        FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthBittrex.Statistics24h;
begin
  inherited;

  try
    ParseResponseStatis24h(FIdHTTP_Statistics24h.Get(StatisURL));
  except
    // ignore error
  end;
end;

procedure TDepthBittrex.TradesHistory;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_TradesHistory.Get(Format(cTradesHistoryURL, ['USDT-BTC']));
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

constructor TDepthBittrex.Create;
begin
  inherited;

  FExchange := TExchange.Bittrex;
end;

procedure TDepthBittrex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_Depth.Get(depthBittrex);
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
