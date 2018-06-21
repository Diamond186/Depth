unit uDepthBitfinex;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBitfinex = class(TCustomDepth)
    private
      const
        cDepthURL = 'https://api.bitfinex.com/v1/book/BTCUSD?limit_bids=3000&limit_asks=3000&group=1';
        c24hURL = 'https://api.bitfinex.com/v1/pubticker/BTCUSD';

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

{ TDepthBitfinex }

procedure TDepthBitfinex.ParseResponse(const aResponse: string);
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

procedure TDepthBitfinex.ParseResponse24h(const aResponse: string);
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

procedure TDepthBitfinex.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthBitfinex.TradesHistory;
begin
  inherited;

end;

constructor TDepthBitfinex.Create;
begin
  inherited;

  FExchange := TExchange.Bitfinex;
end;

procedure TDepthBitfinex.Depth;
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

  ParseResponse(LRes);

  if Assigned(FDepthManage)
    and (ApplyUpdate or LRes.IsEmpty)
  then
      FDepthManage;
end;

end.
