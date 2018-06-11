unit uDepthBitfinex;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBitfinex = class(TCustomDepth)
    private
      const
        depthBinance = 'https://api.bitfinex.com/v1/book/BTCUSD?limit_bids=3000&limit_asks=3000&group=1';

      procedure ParseResponse(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public

  end;

implementation

uses
  System.JSON, uExchangeClass;

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

    if Assigned(FDepthManage) then
      FDepthManage;
  end;
end;

procedure TDepthBitfinex.Statistics24h;
begin
  inherited;

end;

procedure TDepthBitfinex.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthBinance);
  except
    LRes := EmptyStr;
  end;

  ParseResponse(LRes);
end;

end.
