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
    public
      
  end;

implementation

uses
  System.JSON, uExchangeClass;

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

    if Assigned(FDepthManage) then
      FDepthManage;
  end;
end;

procedure TDepthPoloniex.Statistics24h;
begin
  inherited;

end;

procedure TDepthPoloniex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthPoloniex);
  except
    LRes := EmptyStr;
  end;

  ParseResponse(LRes);
end;

end.