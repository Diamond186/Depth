unit uCustomDepth;

interface

uses
  Winapi.Windows, System.Generics.Collections,
  System.SysUtils, IdHTTP, System.Classes, IdComponent,
  uExchangeClass;

type
  TCustomDepth = class
    private
      FActive,
      FApplyUpdate: Boolean;
      FTradeHistoryApplyUpdate: Boolean;

      function GetDepthManage: TProc;
      procedure SetDepthManage(const Value: TProc);
      procedure SetApplyUpdate(const Value: Boolean);
      function GetTradeHistory: TProc;
      procedure SetTradeHistory(const Value: TProc);
    protected
      const
        cIntervalTradeHistory = 1000;

      var
        FArrDepthBids,
        FArrDepthAsks: TArray<TPairDepth>;
        FDepthManage,
        FTradeHistoryProc: TProc;

        FIdHTTP_Depth,
        FIdHTTP_Statistics24h,
        FIdHTTP_TradesHistory: TIdHTTP;

        FStatistics24h: TStatistics24h;
        FExchange: TExchange;

        FLastTimestamp: Int64;
        FBidsTradeHistory,
        FAsksTradeHistory: TTradeHistory;

        procedure Clear;
        procedure Depth; virtual; abstract;
        procedure Statistics24h; virtual; abstract;
        procedure TradesHistory; virtual; abstract;
    public
      constructor Create; virtual;
      destructor  Destroy; override;

      procedure BeginManage;
      procedure BeginTradeHistory;
      procedure BeginStatistics24h;

      function ToString: string; override;
      function Exchange: TExchange;

      property ArrDepthBids: TArray<TPairDepth> read FArrDepthBids;
      property ArrDepthAsks: TArray<TPairDepth> read FArrDepthAsks;
      property Statis24h: TStatistics24h read FStatistics24h;
      property AsksTradeHistory: TTradeHistory read FAsksTradeHistory;
      property BidsTradeHistory: TTradeHistory read FBidsTradeHistory;

      property Active: Boolean read FActive write FActive;
      property TradeHistoryApplyUpdate: Boolean read FTradeHistoryApplyUpdate write FTradeHistoryApplyUpdate;
      property ApplyUpdate: Boolean read FApplyUpdate write SetApplyUpdate;

      property OnDepthManage: TProc read GetDepthManage write SetDepthManage;
      property OnTradeHistory: TProc read GetTradeHistory write SetTradeHistory;
  end;

implementation

uses
  IdSSLOpenSSL;

{ TCustomDepth }

procedure TCustomDepth.BeginManage;
begin
  if FActive then
    TThread.CreateAnonymousThread(procedure
    begin
      Statistics24h;
      Depth;
    end).Start
  else
  begin
    Clear;
    FApplyUpdate := True;
  end;
end;

procedure TCustomDepth.BeginStatistics24h;
begin
  TThread.CreateAnonymousThread(procedure
    begin
      Statistics24h;
    end).Start
end;

procedure TCustomDepth.BeginTradeHistory;
begin
  if FActive then
    TThread.CreateAnonymousThread(procedure
    begin
      TradesHistory;
    end).Start
  else
  begin
    FTradeHistoryApplyUpdate := True;
  end;
end;

procedure TCustomDepth.Clear;
var
  i: Integer;
begin
  for i := Low(FArrDepthBids) to High(FArrDepthBids) do
    FArrDepthBids[i].Free;

  for i := Low(FArrDepthAsks) to High(FArrDepthAsks) do
    FArrDepthAsks[i].Free;

  SetLength(FArrDepthBids, 0);
  SetLength(FArrDepthAsks, 0);
end;

constructor TCustomDepth.Create;
var
  LIOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  FApplyUpdate := False;
  FStatistics24h := TStatistics24h.Create;

  FIdHTTP_Depth := TIdHTTP.Create(nil);
  FIdHTTP_Statistics24h := TIdHTTP.Create(nil);
  FIdHTTP_TradesHistory := TIdHTTP.Create(nil);

  LIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP_Depth);
  LIOHandler.SSLOptions.Method := sslvSSLv23;

  FIdHTTP_Depth.IOHandler := LIOHandler;
  FIdHTTP_Depth.Request.UserAgent := 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MAAU)';
  FIdHTTP_Depth.ConnectTimeout := 1000;

  LIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP_Statistics24h);
  LIOHandler.SSLOptions.Method := sslvSSLv23;

  FIdHTTP_Statistics24h.IOHandler := LIOHandler;
  FIdHTTP_Statistics24h.Request.UserAgent := 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MAAU)';
  FIdHTTP_Statistics24h.ConnectTimeout := 1000;

  LIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP_TradesHistory);
  LIOHandler.SSLOptions.Method := sslvSSLv23;

  FIdHTTP_TradesHistory.IOHandler := LIOHandler;
  FIdHTTP_TradesHistory.Request.UserAgent := 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MAAU)';
  FIdHTTP_TradesHistory.ConnectTimeout := 1000;

  FBidsTradeHistory := TTradeHistory.Create;
  FAsksTradeHistory := TTradeHistory.Create;
  FLastTimestamp := 0;
end;

destructor TCustomDepth.Destroy;
begin
  FreeAndNil(FStatistics24h);
  FreeAndNil(FBidsTradeHistory);
  FreeAndNil(FAsksTradeHistory);
  FreeAndNil(FIdHTTP_Depth);
  FreeAndNil(FIdHTTP_Statistics24h);
  FreeAndNil(FIdHTTP_TradesHistory);

  inherited;
end;

function TCustomDepth.Exchange: TExchange;
begin
  Result := FExchange;
end;

function TCustomDepth.GetDepthManage: TProc;
begin
  Result := FDepthManage;
end;

function TCustomDepth.GetTradeHistory: TProc;
begin
  Result := FTradeHistoryProc;
end;

procedure TCustomDepth.SetApplyUpdate(const Value: Boolean);
begin
  FApplyUpdate := Value;

  if not FApplyUpdate then
    Clear;
end;

procedure TCustomDepth.SetDepthManage(const Value: TProc);
begin
  FDepthManage := Value;
end;

procedure TCustomDepth.SetTradeHistory(const Value: TProc);
begin
  FTradeHistoryProc := Value;
end;

function TCustomDepth.ToString: string;
begin
  Result := FExchange.ToString;
end;

end.
