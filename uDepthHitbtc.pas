unit uDepthHitbtc;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthHitbtc = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.hitbtc.com/api/2/public/orderbook/BTCUSD?limit=0';

      procedure ParseResponse(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public
      
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

procedure TDepthHitbtc.Statistics24h;
begin
  inherited;

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
