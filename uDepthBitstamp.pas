unit uDepthBitstamp;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBitstamp = class(TCustomDepth)
    private
      const
        depthURL = 'https://www.bitstamp.net/api/v2/order_book/btcusd/';
        c24hURL = 'https://www.bitstamp.net/api/v2/ticker/btcusd/';

      procedure ParseResponse(const aResponse: string);
      procedure ParseResponse24h(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public
      
  end;

implementation

uses
  System.JSON, uExchangeClass, uLogging;

{ TDepthBitstamp }

procedure TDepthBitstamp.ParseResponse(const aResponse: string);
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
      LRes := LJSON.GetValue<TJSONObject>;

      //  buy
      if LRes.TryGetValue<TJSONArray>('bids', LArr) then
      begin
        SetLength(FArrDepthBids, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;

          FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                LItem.Items[1].GetValue<Double>,
                                                TExchange.Bitstamp);
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
                                                TExchange.Bitstamp);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthBitstamp.ParseResponse24h(const aResponse: string);
var
  LJSON: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
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

procedure TDepthBitstamp.Statistics24h;
begin
  inherited;

  ParseResponse24h(FIdHTTP.Get(c24hURL));
end;

procedure TDepthBitstamp.Depth;
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
