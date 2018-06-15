unit uDepthBibox;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthBibox = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.bibox.com/v1/mdata?cmd=depth&pair=BTC_USDT&size=80';

      procedure ParseResponse(const aResponse: string);
    protected
      procedure Depth; override;
      procedure Statistics24h; override;
    public
      
  end;

implementation

uses
  System.JSON, uExchangeClass, uLogging;

{ TDepthBibox }

procedure TDepthBibox.ParseResponse(const aResponse: string);
var
  LJSON, LRes: TJSONValue;
  LArr: TJSONArray;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<TJSONValue>('result', LRes) then
      begin
        //  buy
        if LRes.TryGetValue<TJSONArray>('bids', LArr) then
        begin
          SetLength(FArrDepthBids, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            FArrDepthBids[i] := TPairDepth.Create(LArr.Items[i].GetValue<Currency>('price'),
                                                  LArr.Items[i].GetValue<Double>('volume'),
                                                  TExchange.BiBox);
          end;
        end;

        // sell
        if LRes.TryGetValue<TJSONArray>('asks', LArr) then
        begin
          SetLength(FArrDepthAsks, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            FArrDepthAsks[i] := TPairDepth.Create(LArr.Items[i].GetValue<Currency>('price'),
                                                  LArr.Items[i].GetValue<Double>('volume'),
                                                  TExchange.BiBox);
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthBibox.Statistics24h;
begin
  inherited;

end;

procedure TDepthBibox.Depth;
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
