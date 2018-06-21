unit uDepthHitbtc;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthHitBTC = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.hitbtc.com/api/2/public/orderbook/BTCUSD?limit=0';
        c24hURL = 'https://api.hitbtc.com/api/2/public/ticker/BTCUSD';

      procedure ParseResponse(const aResponse: string);
      procedure ParseResponse24h(const aResponse: string);
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

{ TDepthHitbtc }

procedure TDepthHitbtc.ParseResponse(const aResponse: string);
var
  LJSON: TJSONValue;
  LArr: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      //  buy
      if LJSON.TryGetValue<TJSONArray>('bid', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          FArrDepthBids[i] := TPairDepth.Create(LArr.Items[i].GetValue<Currency>('price'),
                                                LArr.Items[i].GetValue<Double>('size'),
                                                TExchange.HitBTC);
        end;
      end;

      // sell
      if LJSON.TryGetValue<TJSONArray>('ask', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          FArrDepthAsks[i] := TPairDepth.Create(LArr.Items[i].GetValue<Currency>('price'),
                                                LArr.Items[i].GetValue<Double>('size'),
                                                TExchange.HitBTC);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthHitBTC.ParseResponse24h(const aResponse: string);
var
  LJSON: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<String>('symbol', LStr) then
        FStatistics24h.Symbol := LStr;

      if LJSON.TryGetValue<String>('last', LStr) then
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

procedure TDepthHitbtc.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthHitBTC.TradesHistory;
begin
  inherited;

end;

constructor TDepthHitBTC.Create;
begin
  inherited;

  FExchange := TExchange.HitBTC;
end;

procedure TDepthHitbtc.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthURL);
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
