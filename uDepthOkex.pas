unit uDepthOkex;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthOkex = class(TCustomDepth)
    private
      const
        depthURL = 'https://www.okex.com/api/v1/depth.do?symbol=btc_usdt';
        c24hURL = 'https://www.okex.com/api/v1/ticker.do?symbol=btc_usdt';
        cTradesHistoryURL = 'https://www.okex.com/api/v1/trades.do?symbol=btc_usdt';

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

{ TDepthOkex }

procedure TDepthOkex.ParseResponse(const aResponse: string);
var
  LJSON, LRes: TJSONValue;
  LArr, LItem: TJSONArray;
  LObj: TJSONObject;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<TJSONObject>(LObj) then
      begin
        LRes := LObj;

        //  buy
        if LRes.TryGetValue<TJSONArray>('bids', LArr) then
        begin
          SetLength(FArrDepthBids, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            LItem := LArr.Items[i].GetValue<TJSONArray>;

            FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                  LItem.Items[1].GetValue<Double>,
                                                  TExchange.Okex);
          end;
        end;

        // sell
        if LRes.TryGetValue<TJSONArray>('asks', LArr) then
        begin
          SetLength(FArrDepthAsks, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            LItem := LArr.Items[i].GetValue<TJSONArray>;

            FArrDepthAsks[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                  LItem.Items[1].GetValue<Double>,
                                                  TExchange.Okex);
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthOkex.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>('ticker');

      if LObj.TryGetValue<String>('last', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('high', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('vol', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthOkex.ParseResponseTradesHistory(const aResponse: string);
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
          FLastTimestamp := LArr.Items[LArr.Count - 1].GetValue<Int64>('tid');

        for i := LArr.Count - 1 downto 0 do
        begin
          LTime := LArr.Items[i].GetValue<Int64>('tid');

          if LTime > FLastTimestamp then
          begin
            LAmount := LArr.Items[i].GetValue<string>('amount').ToDouble;
            LIsBuyerMaker := LArr.Items[i].GetValue<string>('type') = 'sell';

            if not LIsBuyerMaker then
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

        FLastTimestamp := LArr.Items[LArr.Count - 1].GetValue<Int64>('tid');
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
  FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthOkex.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP_Statistics24h.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthOkex.TradesHistory;
var
  LRes: string;
begin
  inherited;

  try
    if FLastTimestamp = 0 then
      LRes := FIdHTTP_TradesHistory.Get(cTradesHistoryURL)
    else
      LRes := FIdHTTP_TradesHistory.Get(cTradesHistoryURL + '&since=' + FLastTimestamp.ToString);
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

constructor TDepthOkex.Create;
begin
  inherited;

  FExchange := TExchange.Okex;
end;

procedure TDepthOkex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_Depth.Get(depthURL);
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
