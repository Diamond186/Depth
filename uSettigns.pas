unit uSettigns;

interface

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
    procedure SetUseBiBox(const Value: Boolean);
    procedure SetUseBinance(const Value: Boolean);
    procedure SetUseBitfinex(const Value: Boolean);
    procedure SetUseBitstamp(const Value: Boolean);
    procedure SetUseBittrex(const Value: Boolean);
    procedure SetUseHitBTC(const Value: Boolean);
    procedure SetUseHuobi(const Value: Boolean);
    procedure SetUseKraken(const Value: Boolean);
    procedure SetUseOkex(const Value: Boolean);

    procedure Load(const aPairName: string);
    procedure Save;

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
  end;

function CreateSettigns: ISettigns;

implementation

uses
  System.SysUtils,
  System.IniFiles;

type
  TSettigns = class(TInterfacedObject, ISettigns)
    private
      FPair: String;

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
    public
      constructor Create;

      procedure Load(const aPairName: string);
      procedure Save;

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

function TSettigns.GetBoldPrice: Currency;
begin
  Result := FBoldPrice;
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

procedure TSettigns.Load(const aPairName: string);
begin
  if FileExists(FFileName) then
  with TMemIniFile.Create(FFileName) do
  try
    FPair := aPairName;
    FMinPrice := ReadFloat(aPairName, 'MinPrice', 0);
    FBoldPrice := ReadFloat(aPairName, 'BoldPrice', 0);
    FUseOkex := ReadBool(FPair, 'UseOkex', True);
    FUseKraken := ReadBool(FPair, 'UseKraken', True);
    FUseHuobi := ReadBool(FPair, 'UseHuobi', True);
    FUseHitBTC := ReadBool(FPair, 'UseHitBTC', True);
    FUseBittrex := ReadBool(FPair, 'UseBittrex', True);
    FUseBitstamp := ReadBool(FPair, 'UseBitstamp', True);
    FUseBitfinex := ReadBool(FPair, 'UseBitfinex', True);
    FUseBinance := ReadBool(FPair, 'UseBinance', True);
    FUseBiBox := ReadBool(FPair, 'UseBiBox', True);
  finally
    Free;
  end;
end;

procedure TSettigns.Save;
begin
  if FileExists(FFileName) then
  with TMemIniFile.Create(FFileName) do
  try
    WriteFloat(FPair, 'MinPrice', FMinPrice);
    WriteFloat(FPair, 'BoldPrice', FBoldPrice);
    WriteBool(FPair, 'UseOkex', FUseOkex);
    WriteBool(FPair, 'UseKraken', FUseKraken);
    WriteBool(FPair, 'UseHuobi', FUseHuobi);
    WriteBool(FPair, 'UseHitBTC', FUseHitBTC);
    WriteBool(FPair, 'UseBittrex', FUseBittrex);
    WriteBool(FPair, 'UseBitstamp', FUseBitstamp);
    WriteBool(FPair, 'UseBitfinex', FUseBitfinex);
    WriteBool(FPair, 'UseBinance', FUseBinance);
    WriteBool(FPair, 'UseBiBox', FUseBiBox);

    UpdateFile;
  finally
    Free;
  end;
end;

procedure TSettigns.SetBoldPrice(const Value: Currency);
begin
  FBoldPrice := Value;
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
