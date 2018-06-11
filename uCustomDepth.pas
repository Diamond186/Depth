unit uCustomDepth;

interface

uses
  System.SysUtils, IdHTTP, System.Classes,
  uExchangeClass;

type
  TCustomDepth = class
    private
      FActive,
      FApplyUpdate: Boolean;

      function GetDepthManage: TProc;
      procedure SetDepthManage(const Value: TProc);
      procedure SetApplyUpdate(const Value: Boolean);
    protected
      FArrDepthBids,
      FArrDepthAsks: TArray<TPairDepth>;
      FDepthManage: TProc;
      FIdHTTP: TIdHTTP;
      FStatistics24h: TStatistics24h;

      procedure Clear;
      procedure Depth; virtual; abstract;
      procedure Statistics24h; virtual; abstract;
    public
      constructor Create;
      destructor  Destroy; override;

      procedure BeginManage;

      property ArrDepthBids: TArray<TPairDepth> read FArrDepthBids;
      property ArrDepthAsks: TArray<TPairDepth> read FArrDepthAsks;
      property OnDepthManage: TProc read GetDepthManage write SetDepthManage;
      property Active: Boolean read FActive write FActive;
      property ApplyUpdate: Boolean read FApplyUpdate write SetApplyUpdate;
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
      Depth;
      Statistics24h;
    end).Start
  else
  begin
    Clear;
    FApplyUpdate := True;
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

  FIdHTTP := TIdHTTP.Create(nil);

  LIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP);
  LIOHandler.SSLOptions.Method := sslvSSLv23;

  FIdHTTP.IOHandler := LIOHandler;
  FIdHTTP.Request.UserAgent := 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MAAU)';
  FIdHTTP.ConnectTimeout := 1000;
//  FIdHTTP.ReadTimeout := 2000;
end;

destructor TCustomDepth.Destroy;
begin
  FreeAndNil(FStatistics24h);
  FreeAndNil(FIdHTTP);

  inherited;
end;

function TCustomDepth.GetDepthManage: TProc;
begin
  Result := FDepthManage;
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

end.
