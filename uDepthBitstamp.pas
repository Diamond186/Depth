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

      procedure ParseResponse(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public
      
  end;

implementation

uses
  System.JSON, uExchangeClass;

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

    if Assigned(FDepthManage) then
      FDepthManage;
  end;
end;

procedure TDepthBitstamp.Statistics24h;
begin
  inherited;

end;

procedure TDepthBitstamp.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP.Get(depthURL);
  except
    LRes := EmptyStr;
  end;

  ParseResponse(LRes);
end;

end.
