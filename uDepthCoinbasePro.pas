unit uDepthCoinbasePro;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthCoinbasePro = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.pro.coinbase.com/products/%s/book?level=2';
        c24hURL = 'https://api.pro.coinbase.com/products/%s/stats';
        cTradesHistoryURL = 'https://api.pro.coinbase.com/products/%s/trades';

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

{ TDepthBibox }

procedure TDepthCoinbasePro.ParseResponse(const aResponse: string);
var
  LJSON, LRes: TJSONValue;
  LArr, LItem: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      //  buy
      if LJSON.TryGetValue<TJSONArray>('bids', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;
          FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<string>.ToDouble,
                                                LItem.Items[1].GetValue<string>.ToDouble,
                                                TExchange.CoinbasePro);
        end;
      end;

      // sell
      if LJSON.TryGetValue<TJSONArray>('asks', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;
          FArrDepthAsks[i] := TPairDepth.Create(LItem.Items[0].GetValue<string>.ToDouble,
                                                LItem.Items[1].GetValue<string>.ToDouble,
                                                TExchange.CoinbasePro);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthCoinbasePro.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>;

      if LObj.TryGetValue<String>('last', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('high', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('volume', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthCoinbasePro.ParseResponseTradesHistory(const aResponse: string);
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
          FLastTimestamp := LArr.Items[0].GetValue<Int64>('trade_id');

        for i := 0 to LArr.Count - 1 do
        begin
          LTime := LArr.Items[i].GetValue<Int64>('trade_id');

          if LTime > FLastTimestamp then
          begin
            LAmount := LArr.Items[i].GetValue<string>('size').ToDouble;
            LIsBuyerMaker := LArr.Items[i].GetValue<String>('side') = 'buy';

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
          end
          else
            Break;
        end;

        FLastTimestamp := LArr.Items[0].GetValue<Int64>('trade_id');

        FBidsTradeHistory.AddSec(LCountBidsTrades, LSumBidsTrades);
        FAsksTradeHistory.AddSec(LCountAsksTrades, LSumAsksTrades);
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;

  Self.TradeHistoryApplyUpdate := True;
end;

procedure TDepthCoinbasePro.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP_Statistics24h.Get(Format(c24hURL, ['BTC-USD'])));
  except
    // ignore error
  end;
end;

procedure TDepthCoinbasePro.TradesHistory;
var
  LRes: string;
begin
  inherited;

  if FWait = 0 then
  try
    LRes := FIdHTTP_TradesHistory.Get(Format(cTradesHistoryURL, ['BTC-USD']));
                                       
    // wait 2 sec for geting trades
    FWait := 2;
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

constructor TDepthCoinbasePro.Create;
begin
  inherited;

  FWait := 0;
  FExchange := TExchange.CoinbasePro;
end;

procedure TDepthCoinbasePro.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_Depth.Get(Format(depthURL, ['BTC-USD']));
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
