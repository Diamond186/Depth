unit uSettigns;

interface

uses
  uExchangeClass;

type
  ISettigns = interface
    function GetBoldPrice: Currency;
    function GetMinPrice: Currency;
    function GetPair: String;
    procedure SetBoldPrice(const Value: Currency);
    procedure SetMinPrice(const Value: Currency);
    procedure SetPair(const Value: String);
    function GetUseBiBox: Boolean;
    function GetUseBinance: Boolean;
    function GetUseBitfinex: Boolean;
    function GetUseBitstamp: Boolean;
    function GetUseBittrex: Boolean;
    function GetUseHitBTC: Boolean;
    function GetUseHuobi: Boolean;
    function GetUseKraken: Boolean;
    function GetUseOkex: Boolean;
    function  GetCurrentExchange: TExchange;
    procedure SetUseBiBox(const Value: Boolean);
    procedure SetUseBinance(const Value: Boolean);
    procedure SetUseBitfinex(const Value: Boolean);
    procedure SetUseBitstamp(const Value: Boolean);
    procedure SetUseBittrex(const Value: Boolean);
    procedure SetUseHitBTC(const Value: Boolean);
    procedure SetUseHuobi(const Value: Boolean);
    procedure SetUseKraken(const Value: Boolean);
    procedure SetUseOkex(const Value: Boolean);
    procedure SetCurrentExchange(const Value: TExchange);

    procedure Load(const aSectionName: string);
    procedure Save;
    procedure Delete;

    property Pair: String read GetPair write SetPair;
    property MinPrice: Currency read GetMinPrice write SetMinPrice;
    property BoldPrice: Currency read GetBoldPrice write SetBoldPrice;

    property UseBiBox: Boolean read GetUseBiBox write SetUseBiBox;
    property UseBinance: Boolean read GetUseBinance write SetUseBinance;
    property UseBitfinex: Boolean read GetUseBitfinex write SetUseBitfinex;
    property UseBitstamp: Boolean read GetUseBitstamp write SetUseBitstamp;
    property UseBittrex: Boolean read GetUseBittrex write SetUseBittrex;
    property UseHitBTC: Boolean read GetUseHitBTC write SetUseHitBTC;
    property UseHuobi: Boolean read GetUseHuobi write SetUseHuobi;
    property UseKraken: Boolean read GetUseKraken write SetUseKraken;
    property UseOkex: Boolean read GetUseOkex write SetUseOkex;

    property CurrentExchange: TExchange read GetCurrentExchange write SetCurrentExchange;
  end;

function CreateSettigns: ISettigns;

implementation

uses
  System.SysUtils,
  System.IniFiles;

type
  TSettigns = class(TInterfacedObject, ISettigns)
    private
      FPair,
      FSectionName: String;

      FUseBiBox: Boolean;
      FUseBinance: Boolean;
      FUseBitfinex: Boolean;
      FUseBitstamp: Boolean;
      FUseBittrex: Boolean;
      FUseHitBTC: Boolean;
      FUseHuobi: Boolean;
      FUseKraken: Boolean;
      FUseOkex: Boolean;

      FMinPrice: Currency;
      FBoldPrice: Currency;

      FFileName: string;
      FCurrentExchange: TExchange;

      function GetBoldPrice: Currency;
      function GetMinPrice: Currency;
      function GetPair: String;
      procedure SetBoldPrice(const Value: Currency);
      procedure SetMinPrice(const Value: Currency);
      procedure SetPair(const Value: String);
      function GetUseBiBox: Boolean;
      function GetUseBinance: Boolean;
      function GetUseBitfinex: Boolean;
      function GetUseBitstamp: Boolean;
      function GetUseBittrex: Boolean;
      function GetUseHitBTC: Boolean;
      function GetUseHuobi: Boolean;
      function GetUseKraken: Boolean;
      function GetUseOkex: Boolean;
      procedure SetUseBiBox(const Value: Boolean);
      procedure SetUseBinance(const Value: Boolean);
      procedure SetUseBitfinex(const Value: Boolean);
      procedure SetUseBitstamp(const Value: Boolean);
      procedure SetUseBittrex(const Value: Boolean);
      procedure SetUseHitBTC(const Value: Boolean);
      procedure SetUseHuobi(const Value: Boolean);
      procedure SetUseKraken(const Value: Boolean);
      procedure SetUseOkex(const Value: Boolean);
      function  GetCurrentExchange: TExchange;
      procedure SetCurrentExchange(const Value: TExchange);
    public
      constructor Create;

      procedure Load(const aSectionName: string);
      procedure Save;
      procedure Delete;

      property Pair: String read GetPair write SetPair;
      property MinPrice: Currency read GetMinPrice write SetMinPrice;
      property BoldPrice: Currency read GetBoldPrice write SetBoldPrice;

      property UseBiBox: Boolean read GetUseBiBox write SetUseBiBox;
      property UseBinance: Boolean read GetUseBinance write SetUseBinance;
      property UseBitfinex: Boolean read GetUseBitfinex write SetUseBitfinex;
      property UseBitstamp: Boolean read GetUseBitstamp write SetUseBitstamp;
      property UseBittrex: Boolean read GetUseBittrex write SetUseBittrex;
      property UseHitBTC: Boolean read GetUseHitBTC write SetUseHitBTC;
      property UseHuobi: Boolean read GetUseHuobi write SetUseHuobi;
      property UseKraken: Boolean read GetUseKraken write SetUseKraken;
      property UseOkex: Boolean read GetUseOkex write SetUseOkex;

      property CurrentExchange: TExchange read GetCurrentExchange write SetCurrentExchange;
  end;

function CreateSettigns: ISettigns;
begin
  Result := TSettigns.Create;
end;

{ TSettigns }

constructor TSettigns.Create;
begin
  FFileName := ExtractFilePath(ParamStr(0)) + 'Settings.ini';
end;

procedure TSettigns.Delete;
begin
  if FileExists(FFileName) then
  with TMemIniFile.Create(FFileName) do
  try
    EraseSection(FSectionName);

    UpdateFile;
  finally
    Free;
  end;
end;

function TSettigns.GetBoldPrice: Currency;
begin
  Result := FBoldPrice;
end;

function TSettigns.GetCurrentExchange: TExchange;
begin
  Result := FCurrentExchange;
end;

function TSettigns.GetMinPrice: Currency;
begin
  Result := FMinPrice;
end;

function TSettigns.GetPair: String;
begin
  Result := FPair;
end;

function TSettigns.GetUseBiBox: Boolean;
begin
  Result := FUseBiBox;
end;

function TSettigns.GetUseBinance: Boolean;
begin
  Result := FUseBinance;
end;

function TSettigns.GetUseBitfinex: Boolean;
begin
  Result := FUseBitfinex;
end;

function TSettigns.GetUseBitstamp: Boolean;
begin
  Result := FUseBitstamp;
end;

function TSettigns.GetUseBittrex: Boolean;
begin
  Result := FUseBittrex;
end;

function TSettigns.GetUseHitBTC: Boolean;
begin
  Result := FUseHitBTC;
end;

function TSettigns.GetUseHuobi: Boolean;
begin
  Result := FUseHuobi;
end;

function TSettigns.GetUseKraken: Boolean;
begin
  Result := FUseKraken;
end;

function TSettigns.GetUseOkex: Boolean;
begin
  Result := FUseOkex;
end;

procedure TSettigns.Load(const aSectionName: string);
var
  LExchangeName: string;
begin
  if FileExists(FFileName) then
  with TMemIniFile.Create(FFileName) do
  try
    FSectionName := aSectionName;
    FPair := ReadString(aSectionName, 'Pair', EmptyStr);
    FMinPrice := ReadFloat(aSectionName, 'MinPrice', 2);
    FBoldPrice := ReadFloat(aSectionName, 'BoldPrice', 100);
    FUseOkex := ReadBool(aSectionName, TExchange.Okex.ToString, False);
    FUseKraken := ReadBool(aSectionName, TExchange.Kraken.ToString, False);
    FUseHuobi := ReadBool(aSectionName, TExchange.Huobi.ToString, False);
    FUseHitBTC := ReadBool(aSectionName, TExchange.HitBTC.ToString, False);
    FUseBittrex := ReadBool(aSectionName, TExchange.Bittrex.ToString, False);
    FUseBitstamp := ReadBool(aSectionName, TExchange.Bitstamp.ToString, False);
    FUseBitfinex := ReadBool(aSectionName, TExchange.Bitfinex.ToString, False);
    FUseBinance := ReadBool(aSectionName, TExchange.Binance.ToString, False);
    FUseBiBox := ReadBool(aSectionName, TExchange.BiBox.ToString, False);

    LExchangeName := ReadString(aSectionName, 'CurrentExchange', EmptyStr);
    if not LExchangeName.IsEmpty then
      FCurrentExchange := TExchange.ExchangeFromString(LExchangeName)
    else
      if FUseOkex then FCurrentExchange := TExchange.Okex else
      if FUseKraken then FCurrentExchange := TExchange.Kraken else
      if FUseHuobi then FCurrentExchange := TExchange.Huobi else
      if FUseHitBTC then FCurrentExchange := TExchange.HitBTC else
      if FUseBittrex then FCurrentExchange := TExchange.Bittrex else
      if FUseBitstamp then FCurrentExchange := TExchange.Bitstamp else
      if FUseBitfinex then FCurrentExchange := TExchange.Bitfinex else
      if FUseBinance then FCurrentExchange := TExchange.Binance else
      if FUseBiBox then FCurrentExchange := TExchange.BiBox;
  finally
    Free;
  end;
end;

procedure TSettigns.Save;
begin
  if FileExists(FFileName) then
  with TMemIniFile.Create(FFileName) do
  try
    WriteString(FSectionName, 'Pair', FPair);
    WriteFloat(FSectionName, 'MinPrice', FMinPrice);
    WriteFloat(FSectionName, 'BoldPrice', FBoldPrice);
    WriteBool(FSectionName, TExchange.Okex.ToString, FUseOkex);
    WriteBool(FSectionName, TExchange.Kraken.ToString, FUseKraken);
    WriteBool(FSectionName, TExchange.Huobi.ToString, FUseHuobi);
    WriteBool(FSectionName, TExchange.HitBTC.ToString, FUseHitBTC);
    WriteBool(FSectionName, TExchange.Bittrex.ToString, FUseBittrex);
    WriteBool(FSectionName, TExchange.Bitstamp.ToString, FUseBitstamp);
    WriteBool(FSectionName, TExchange.Bitfinex.ToString, FUseBitfinex);
    WriteBool(FSectionName, TExchange.Binance.ToString, FUseBinance);
    WriteBool(FSectionName, TExchange.BiBox.ToString, FUseBiBox);
    WriteString(FSectionName, 'CurrentExchange', FCurrentExchange.ToString);

    UpdateFile;
  finally
    Free;
  end;
end;

procedure TSettigns.SetBoldPrice(const Value: Currency);
begin
  FBoldPrice := Value;
end;

procedure TSettigns.SetCurrentExchange(const Value: TExchange);
begin
  FCurrentExchange := Value;
end;

procedure TSettigns.SetMinPrice(const Value: Currency);
begin
  FMinPrice := Value;
end;

procedure TSettigns.SetPair(const Value: String);
begin
  FPair := Value;
end;

procedure TSettigns.SetUseBiBox(const Value: Boolean);
begin
  FUseBiBox := Value;
end;

procedure TSettigns.SetUseBinance(const Value: Boolean);
begin
  FUseBinance := Value;
end;

procedure TSettigns.SetUseBitfinex(const Value: Boolean);
begin
  FUseBitfinex := Value;
end;

procedure TSettigns.SetUseBitstamp(const Value: Boolean);
begin
  FUseBitstamp := Value;
end;

procedure TSettigns.SetUseBittrex(const Value: Boolean);
begin
  FUseBittrex := Value;
end;

procedure TSettigns.SetUseHitBTC(const Value: Boolean);
begin
  FUseHitBTC := Value;
end;

procedure TSettigns.SetUseHuobi(const Value: Boolean);
begin
  FUseHuobi := Value;
end;

procedure TSettigns.SetUseKraken(const Value: Boolean);
begin
  FUseKraken := Value;
end;

procedure TSettigns.SetUseOkex(const Value: Boolean);
begin
  FUseOkex := Value;
end;

end.
