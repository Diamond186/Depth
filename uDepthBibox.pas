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
        c24hURL = 'https://api.bibox.com/v1/mdata?cmd=ticker&pair=BTC_USDT';

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

procedure TDepthBibox.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>('result');

      if LObj.TryGetValue<String>('pair', LStr) then
        FStatistics24h.Symbol := LStr;

      if LObj.TryGetValue<String>('last', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('high', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('vol', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthBibox.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP_Statistics24h.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthBibox.TradesHistory;
begin
  inherited;

end;

constructor TDepthBibox.Create;
begin
  inherited;

  FExchange := TExchange.BiBox;
end;

procedure TDepthBibox.Depth;
var
  LRes: string;
begin
  inherited;

  try
    LRes := FIdHTTP_Depth.Get(depthURL);
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
