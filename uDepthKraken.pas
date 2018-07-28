unit uDepthKraken;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthKraken = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.kraken.com/0/public/Depth?pair=XBTUSD&count=1000';
        c24hURL = 'https://api.kraken.com/0/public/Ticker?pair=XBTUSD';
        cTradesHistoryURL = 'https://api.kraken.com/0/public/Trades?pair=%s';

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

{ TDepthKraken }

procedure TDepthKraken.ParseResponse(const aResponse: string);
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
      if LJSON.TryGetValue<TJSONObject>('result', LObj) then
      begin
        LRes := LObj.GetValue<TJSONObject>('XXBTZUSD');

        //  buy
        if LRes.TryGetValue<TJSONArray>('bids', LArr) then
        begin
          SetLength(FArrDepthBids, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            LItem := LArr.Items[i].GetValue<TJSONArray>;

            FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                  LItem.Items[1].GetValue<Double>,
                                                  TExchange.Kraken);
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
                                                  TExchange.Kraken);
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthKraken.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LArrStr: TJSONArray;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>('result');
      LObj := LObj.GetValue<TJSONValue>('XXBTZUSD');

      if Assigned(LObj) then
      begin
        if LObj.TryGetValue<TJSONArray>('c', LArrStr) then
          FStatistics24h.LastPrice := LArrStr.Items[0].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('h', LArrStr) then
          FStatistics24h.HighPrice := LArrStr.Items[1].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('l', LArrStr) then
          FStatistics24h.LowPrice := LArrStr.Items[1].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('v', LArrStr) then
          FStatistics24h.Volume := LArrStr.Items[1].Value.ToExtended;
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthKraken.ParseResponseTradesHistory(const aResponse: string);
var
  LJSON, LResult: TJSONValue;
  LArr, LItemArr: TJSONArray;
  i, j: Integer;
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
      LResult := LJSON.GetValue<TJSONValue>('result');
      LArr := LResult.GetValue<TJSONArray>('XXBTZUSD');

      if LArr.Count > 0 then
      begin
        if FLastTimestamp = 0 then
        begin
          FLastTimestamp := LResult.GetValue<string>('last').ToInt64;
          Self.TradeHistoryApplyUpdate := True;
          Exit;
        end;

        for i := 0 to LArr.Count - 1 do
        begin
          LItemArr := LArr.Items[i].GetValue<TJSONArray>;

          LAmount := LItemArr.Items[1].GetValue<string>.ToDouble;
          LIsBuyerMaker := LItemArr.Items[3].GetValue<string> = 's';

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
        end;

        FLastTimestamp := LResult.GetValue<string>('last').ToInt64;

        FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
        FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthKraken.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP_Statistics24h.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthKraken.TradesHistory;
var
  LRes, LUrl: string;
begin
  inherited;

  try
    LUrl := Format(cTradesHistoryURL, ['XBTUSD', FLastTimestamp]);

    if FLastTimestamp > 0 then
      LUrl := LUrl + '&since=' + FLastTimestamp.ToString;

    LRes := FIdHTTP_TradesHistory.Get(LUrl);
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

constructor TDepthKraken.Create;
begin
  inherited;

  FExchange := TExchange.Kraken;
end;

procedure TDepthKraken.Depth;
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
