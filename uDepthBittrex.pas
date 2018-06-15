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

      procedure ParseResponse(const aResponse: string);
      procedure ParseResponseStatis24h(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public
      
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
  LJSON: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<String>('MarketName', LStr) then
        FStatistics24h.Symbol := LStr;

      if LJSON.TryGetValue<String>('Last', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('Bid', LStr) then
        FStatistics24h.BidPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('Ask', LStr) then
        FStatistics24h.AskPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('High', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('Low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LJSON.TryGetValue<String>('BaseVolume', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthBittrex.Statistics24h;
begin
  inherited;

  ParseResponseStatis24h(FIdHTTP.Get(StatisURL));
end;

procedure TDepthBittrex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthBittrex);
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
