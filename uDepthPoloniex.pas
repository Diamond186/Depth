unit uDepthPoloniex;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthPoloniex = class(TCustomDepth)
    private
      const
        depthPoloniex = 'https://poloniex.com/public?command=returnOrderBook&currencyPair=USDT_ETH&depth=10';

      procedure ParseResponse(const aResponse: string);
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

{ TDepthPoloniex }

procedure TDepthPoloniex.ParseResponse(const aResponse: string);
var
  LJSON: TJSONValue;
  LArr, LItem: TJSONArray;
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
          LItem := LArr.Items[i].GetValue<TJSONArray>;

          FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                LItem.Items[1].GetValue<Double>,
                                                TExchange.Poloniex);
        end;
      end;

      // asks
      if LJSON.TryGetValue<TJSONArray>('asks', LArr) then
      begin
        SetLength(FArrDepthAsks, LArr.Count);

        for i := 0 to LArr.Count - 1 do
        begin
          LItem := LArr.Items[i].GetValue<TJSONArray>;

          FArrDepthAsks[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                LItem.Items[1].GetValue<Double>,
                                                TExchange.Poloniex);
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthPoloniex.Statistics24h;
begin
  inherited;

end;

procedure TDepthPoloniex.TradesHistory;
begin
  inherited;

end;

constructor TDepthPoloniex.Create;
begin
  inherited;

  FExchange := TExchange.Poloniex;
end;

procedure TDepthPoloniex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthPoloniex);
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
