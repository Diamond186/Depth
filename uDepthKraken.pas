unit uDepthKraken;

interface

uses
  System.SysUtils, System.Classes,
  uCustomDepth;

type
  TDepthKraken = class(TCustomDepth)
    private
      const
        depthURL = 'https://api.kraken.com/0/public/Depth?pair=XBTUSD&count=1000';
        c24hURL = 'https://api.kraken.com/0/public/Ticker?pair=XBTUSD';

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

{ TDepthKraken }

procedure TDepthKraken.ParseResponse(const aResponse: string);
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
      if LJSON.TryGetValue<TJSONObject>('result', LObj) then
      begin
        LRes := LObj.GetValue<TJSONObject>('XXBTZUSD');

        //  buy
        if LRes.TryGetValue<TJSONArray>('bids', LArr) then
        begin
          SetLength(FArrDepthBids, LArr.Count);

          for i := 0 to LArr.Count - 1 do
          begin
            LItem := LArr.Items[i].GetValue<TJSONArray>;

            FArrDepthBids[i] := TPairDepth.Create(LItem.Items[0].GetValue<Currency>,
                                                  LItem.Items[1].GetValue<Double>,
                                                  TExchange.Kraken);
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
                                                  TExchange.Kraken);
          end;
        end;
      end;
    finally
      FreeAndNil(LJSON);
    end;

    Self.ApplyUpdate := True;
  end;
end;

procedure TDepthKraken.ParseResponse24h(const aResponse: string);
var
  LJSON, LObj: TJSONValue;
  LArrStr: TJSONArray;
begin
  if not aResponse.IsEmpty then
  begin
    LJSON := TJSONObject.ParseJSONValue(aResponse);
    try
      LObj := LJSON.GetValue<TJSONValue>('result');
      LObj := LObj.GetValue<TJSONValue>('XXBTZUSD');

      if Assigned(LObj) then
      begin
        if LObj.TryGetValue<TJSONArray>('c', LArrStr) then
          FStatistics24h.LastPrice := LArrStr.Items[0].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('h', LArrStr) then
          FStatistics24h.HighPrice := LArrStr.Items[1].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('l', LArrStr) then
          FStatistics24h.LowPrice := LArrStr.Items[1].Value.ToExtended;

        if LObj.TryGetValue<TJSONArray>('v', LArrStr) then
          FStatistics24h.Volume := LArrStr.Items[1].Value.ToExtended;
      end;
    finally
      FreeAndNil(LJSON);
    end;
  end;
end;

procedure TDepthKraken.Statistics24h;
begin
  inherited;

  try
    ParseResponse24h(FIdHTTP.Get(c24hURL));
  except
    // ignore error
  end;
end;

procedure TDepthKraken.TradesHistory;
begin
  inherited;

end;

constructor TDepthKraken.Create;
begin
  inherited;

  FExchange := TExchange.Kraken;
end;

procedure TDepthKraken.Depth;
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
