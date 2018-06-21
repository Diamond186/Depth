unit uDepthHuobi;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthHuobi = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.huobi.pro/market/depth?symbol=btcusdt&type=step0';
        c24hURL = 'https://api.huobi.pro/market/detail?symbol=btcusdt';

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

{ TDepthHuobi }

procedure TDepthHuobi.ParseResponse(const aResponse: string);
var
  LJSON, LRes: TJSONValue;
  LArr, LItem: TJSONArray;
  LObj: TJSONObject;
  i: Integer;
begin
  if not aResponse.IsEmpty then
  begin
    SetLength(FArrDepthBids, 0);
    SetLength(FArrDepthAsks, 0);

    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      if LJSON.TryGetValue<TJSONObject>('tick', LObj) then
      begin
        LRes := LObj;

        //  buy
        if LRes.TryGetValue<TJSONArray>('bids', LArr) then
        begin
          SetLength(FArrDepthBids, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            LItem := LArr.Items[i].GetValue<TJSONArray>;

            FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                  LItem.Items[1].GetValue<Double>,
                                                  TExchange.Huobi);
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
                                                  TExchange.Huobi);
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthHuobi.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LStr: String;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>('tick');

      if LObj.TryGetValue<String>('close', LStr) then
        FStatistics24h.LastPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('high', LStr) then
        FStatistics24h.HighPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('low', LStr) then
        FStatistics24h.LowPrice := LStr.ToExtended;

      if LObj.TryGetValue<String>('amount', LStr) then
        FStatistics24h.Volume := LStr.ToExtended;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthHuobi.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthHuobi.TradesHistory;
begin
  inherited;

end;

constructor TDepthHuobi.Create;
begin
  inherited;

  FExchange := TExchange.Huobi;
end;

procedure TDepthHuobi.Depth;
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
