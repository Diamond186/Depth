unit uExchangeClass;

interface

uses
  System.SysUtils, System.Classes,
  System.Generics.Collections;

type
  TExchange = (Binance, Bitfinex, Bitstamp, Bittrex, HitBTC, Huobi, Kraken, Okex, BitMEX, CoinbasePro);

  TExchangeHelper = record helper for TExchange
    private
      const
        cArrExchangesText: array [TExchange] of string = ('Binance', 'Bitfinex', 'Bitstamp', 'Bittrex', 'HitBTC',
                                                          'Huobi', 'Kraken', 'Okex', 'BitMEX', 'CoinbasePro');
    public
      function ToString: string; overload; inline;
      class function ExchangeFromString(const aExchangeName: string): TExchange; inline; static;
      class function Count: Integer; inline; static;
  end;

  TTradeHistory = class
    private
      type
        TPeriod = class
          Count: Integer;
          Amount: Double;

          constructor Create(const aCount: Integer;
                             const aAmount: Double); overload;

          constructor Create; overload;
      end;

      var
        FSec: TPeriod;
        F15SecSum:  TPeriod;
        F30SecSum: TPeriod;
        F1MinSum:  TPeriod;
        F15MinSum: TPeriod;
        F30MinSum: TPeriod;
        F1HourSum: TPeriod;

        F15Sec:  TQueue<TPeriod>;
        F30Sec: TQueue<TPeriod>;
        F1Min:  TQueue<TPeriod>;
        F15Min: TQueue<TPeriod>;
        F30Min: TQueue<TPeriod>;
        F1Hour: TQueue<TPeriod>;
    public
      constructor Create;
      destructor  Destroy; override;

      procedure AddSec(const aCount: Integer;
                       const aAmount: Double);

      property OneSec: TPeriod read FSec;
      property _15Sec: TPeriod read F15SecSum;
      property _30Sec: TPeriod read F30SecSum;
      property _1Min: TPeriod read F1MinSum;
      property _15Min: TPeriod read F15MinSum;
      property _30Min: TPeriod read F30MinSum;
      property _1Hour: TPeriod read F1HourSum;
  end;

  TTradeHistoryTotal = class
    private
      FSec:   TTradeHistory.TPeriod;
      F15Sec:  TTradeHistory.TPeriod;
      F30Sec: TTradeHistory.TPeriod;
      F1Min:  TTradeHistory.TPeriod;
      F15Min: TTradeHistory.TPeriod;
      F30Min: TTradeHistory.TPeriod;
      F1Hour: TTradeHistory.TPeriod;
    public
      constructor Create;
      destructor  Destroy; override;

      procedure SetOneSec(const aCount: Integer; const aAmount: Double);
      procedure Set15Sec(const aCount: Integer; const aAmount: Double);
      procedure Set30Sec(const aCount: Integer; const aAmount: Double);
      procedure Set1Min(const aCount: Integer; const aAmount: Double);
      procedure Set15Min(const aCount: Integer; const aAmount: Double);
      procedure Set30Min(const aCount: Integer; const aAmount: Double);
      procedure Set1Hour(const aCount: Integer; const aAmount: Double);

      property OneSec: TTradeHistory.TPeriod read FSec;
      property _15Sec: TTradeHistory.TPeriod read F15Sec;
      property _30Sec: TTradeHistory.TPeriod read F30Sec;
      property _1Min: TTradeHistory.TPeriod read F1Min;
      property _15Min: TTradeHistory.TPeriod read F15Min;
      property _30Min: TTradeHistory.TPeriod read F30Min;
      property _1Hour: TTradeHistory.TPeriod read F1Hour;
  end;

  TPairDepth = class
    private
      FPrice: Currency;
      FAmount: Double;
      FExchangeList: TStringList;
    function GetExchangeName: String;
    public
      constructor Create(const aPrice: Currency;
                         const aAmount: Double;
                         const aExchange: TExchange); overload;

      constructor Create(const aPrice: Currency;
                         const aAmount: Double;
                         const aExchangeList: string); overload;

      destructor  Destroy; override;

      procedure AddPair(const aPairDepth: TPairDepth);

      property Price: Currency read FPrice;
      property Amount: Double read FAmount;
      property ExchangeList: String read GetExchangeName;
  end;

  TStatistics24h = class
    private
      FSymbol: String;
      FPriceChange: Double; // зміна ціни за 24 години
      FPriceChangePercent: String; // зміна ціни за 24 години у відсотках
      FWeightedAvgPrice: Currency; // Середня ціна
      FPrevClosePrice: Currency; // Попередня ціна закриття
      FLastPrice: Currency; // Остання ціна
      FLastQty: Double; // Останній обєм
      FBidPrice: Currency; // Ціна покупки
      FAskPrice: Currency; // Ціна продажу
      FOpenPrice: Currency; // Ціна відкриття
      FHighPrice: Currency; // Сама висока ціна
      FLowPrice: Currency; // Сама низька ціна
      FVolume: Currency; // Обєм торгів за 24
      FCount: Integer; // Кількість ордерів
    public
      property Symbol: String read FSymbol write FSymbol;
      property PriceChange: Double read FPriceChange write FPriceChange;
      property PriceChangePercent: String read FPriceChangePercent write FPriceChangePercent;
      property WeightedAvgPrice: Currency read FWeightedAvgPrice write FWeightedAvgPrice;
      property PrevClosePrice: Currency read FPrevClosePrice write FPrevClosePrice;
      property LastPrice: Currency read FLastPrice write FLastPrice;
      property LastQty: Double read FLastQty write FLastQty;
      property BidPrice: Currency read FBidPrice write FBidPrice;
      property AskPrice: Currency read FAskPrice write FAskPrice;
      property OpenPrice: Currency read FOpenPrice write FOpenPrice;
      property HighPrice: Currency read FHighPrice write FHighPrice;
      property LowPrice: Currency read FLowPrice write FLowPrice;
      property Volume: Currency read FVolume write FVolume;
      property Count: Integer read FCount write FCount;
  end;

  TOnUpdateDepth = procedure (const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double) of Object;
  TOnUpdateStatistics24h = procedure of Object;

implementation

uses
  uSettigns, System.StrUtils,
  System.Math;

{ TPairDepth }

procedure TPairDepth.AddPair(const aPairDepth: TPairDepth);
begin
  if Assigned(aPairDepth) then
  begin
    FAmount := FAmount + aPairDepth.Amount;

    FExchangeList.Add(aPairDepth.ExchangeList);
  end;
end;

constructor TPairDepth.Create(const aPrice: Currency;
                              const aAmount: Double;
                              const aExchange: TExchange);
begin
  FPrice := aPrice;
  FAmount := aAmount;

  FExchangeList := TStringList.Create;

  FExchangeList.Add(aExchange.ToString + ' - ' + Format('%n', [SimpleRoundTo(aAmount)]));
end;

constructor TPairDepth.Create(const aPrice: Currency;
                              const aAmount: Double;
                              const aExchangeList: string);
begin
  FPrice := aPrice;
  FAmount := aAmount;

  FExchangeList := TStringList.Create;
  FExchangeList.Add(aExchangeList);
end;

destructor TPairDepth.Destroy;
begin
  FreeAndNil(FExchangeList);

  inherited;
end;

function TPairDepth.GetExchangeName: String;
begin
  Result := FExchangeList.Text.Trim;
end;

{ TExchange }

class function TExchangeHelper.Count: Integer;
begin
  Result := Length(cArrExchangesText);
end;

class function TExchangeHelper.ExchangeFromString(const aExchangeName: string): TExchange;
var
  LIndex: Integer;
begin
  LIndex := IndexText(aExchangeName, cArrExchangesText);

  if LIndex > -1 then
    Result := TExchange(LIndex)
  else
    raise Exception.Create('The name "' + aExchangeName + '" was not found.');
end;

function TExchangeHelper.ToString: string;
begin
  Result := cArrExchangesText[Self];
end;

{ TTradeHistory }

procedure TTradeHistory.AddSec(const aCount: Integer; const aAmount: Double);
var
  LLastPeriod: TPeriod;
begin
  FSec.Count := aCount;
  FSec.Amount := aAmount;

  F15Sec.Enqueue(TPeriod.Create(aCount, aAmount));
  F30Sec.Enqueue(TPeriod.Create(aCount, aAmount));
  F1Min.Enqueue(TPeriod.Create(aCount, aAmount));
  F15Min.Enqueue(TPeriod.Create(aCount, aAmount));
  F30Min.Enqueue(TPeriod.Create(aCount, aAmount));
  F1Hour.Enqueue(TPeriod.Create(aCount, aAmount));

  F15SecSum.Count := F15SecSum.Count + FSec.Count;
  F15SecSum.Amount := F15SecSum.Amount + FSec.Amount;
  if F15Sec.Count > 15 then
  begin
    LLastPeriod := F15Sec.Extract;

    try
      F15SecSum.Count := F15SecSum.Count - LLastPeriod.Count;
      F15SecSum.Amount := F15SecSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;

  F30SecSum.Count := F30SecSum.Count + FSec.Count;
  F30SecSum.Amount := F30SecSum.Amount + FSec.Amount;
  if F30Sec.Count > 30 then
  begin
    LLastPeriod := F30Sec.Extract;

    try
      F30SecSum.Count := F30SecSum.Count - LLastPeriod.Count;
      F30SecSum.Amount := F30SecSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;

  F1MinSum.Count := F1MinSum.Count + FSec.Count;
  F1MinSum.Amount := F1MinSum.Amount + FSec.Amount;
  if F1Min.Count > SecsPerMin then
  begin
    LLastPeriod := F1Min.Extract;

    try
      F1MinSum.Count := F1MinSum.Count - LLastPeriod.Count;
      F1MinSum.Amount := F1MinSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;

  F15MinSum.Count := F15MinSum.Count + FSec.Count;
  F15MinSum.Amount := F15MinSum.Amount + FSec.Amount;
  if F15Min.Count > 15 * SecsPerMin then
  begin
    LLastPeriod := F15Min.Extract;

    try
      F15MinSum.Count := F15MinSum.Count - LLastPeriod.Count;
      F15MinSum.Amount := F15MinSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;

  F30MinSum.Count := F30MinSum.Count + FSec.Count;
  F30MinSum.Amount := F30MinSum.Amount + FSec.Amount;
  if F30Min.Count > 30 * SecsPerMin then
  begin
    LLastPeriod := F30Min.Extract;

    try
      F30MinSum.Count := F30MinSum.Count - LLastPeriod.Count;
      F30MinSum.Amount := F30MinSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;

  F1HourSum.Count := F1HourSum.Count + FSec.Count;
  F1HourSum.Amount := F1HourSum.Amount + FSec.Amount;
  if F1Hour.Count > SecsPerHour then
  begin
    LLastPeriod := F1Hour.Extract;

    try
      F1HourSum.Count := F1HourSum.Count - LLastPeriod.Count;
      F1HourSum.Amount := F1HourSum.Amount - LLastPeriod.Amount;
    finally
      FreeAndNil(LLastPeriod);
    end;
  end;
end;

constructor TTradeHistory.Create;
begin
  FSec := TPeriod.Create;
  F15SecSum := TPeriod.Create;
  F30SecSum := TPeriod.Create;
  F1MinSum := TPeriod.Create;
  F15MinSum := TPeriod.Create;
  F30MinSum := TPeriod.Create;
  F1HourSum := TPeriod.Create;

  F15Sec  := TQueue<TPeriod>.Create;
  F30Sec := TQueue<TPeriod>.Create;
  F1Min  := TQueue<TPeriod>.Create;
  F15Min := TQueue<TPeriod>.Create;
  F30Min := TQueue<TPeriod>.Create;
  F1Hour := TQueue<TPeriod>.Create;
end;

destructor TTradeHistory.Destroy;
begin
  FreeAndNil(FSec);
  FreeAndNil(F15SecSum);
  FreeAndNil(F30SecSum);
  FreeAndNil(F1MinSum);
  FreeAndNil(F15MinSum);
  FreeAndNil(F30MinSum);
  FreeAndNil(F1HourSum);

  FreeAndNil(F15Sec);
  FreeAndNil(F30Sec);
  FreeAndNil(F1Min);
  FreeAndNil(F15Min);
  FreeAndNil(F30Min);
  FreeAndNil(F1Hour);

  inherited;
end;

{ TTradeHistory.TPeriod }

constructor TTradeHistory.TPeriod.Create(const aCount: Integer;
                                         const aAmount: Double);
begin
  Count := aCount;
  Amount := aAmount;
end;

constructor TTradeHistory.TPeriod.Create;
begin
  Count := 0;
  Amount := 0;
end;

{ TTradeHistoryTotal }

constructor TTradeHistoryTotal.Create;
begin
  FSec   := TTradeHistory.TPeriod.Create;
  F15Sec := TTradeHistory.TPeriod.Create;
  F30Sec := TTradeHistory.TPeriod.Create;
  F1Min  := TTradeHistory.TPeriod.Create;
  F15Min := TTradeHistory.TPeriod.Create;
  F30Min := TTradeHistory.TPeriod.Create;
  F1Hour := TTradeHistory.TPeriod.Create;
end;

destructor TTradeHistoryTotal.Destroy;
begin
  FreeAndNil(FSec);
  FreeAndNil(F15Sec);
  FreeAndNil(F30Sec);
  FreeAndNil(F1Min);
  FreeAndNil(F15Min);
  FreeAndNil(F30Min);
  FreeAndNil(F1Hour);

  inherited;
end;

procedure TTradeHistoryTotal.Set15Min(const aCount: Integer;
                                      const aAmount: Double);
begin
  F15Min := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.Set1Hour(const aCount: Integer;
                                      const aAmount: Double);
begin
  F1Hour := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.Set1Min(const aCount: Integer;
                                     const aAmount: Double);
begin
  F1Min := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.Set30Min(const aCount: Integer;
                                      const aAmount: Double);
begin
  F30Min := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.Set30Sec(const aCount: Integer;
                                      const aAmount: Double);
begin
  F30Sec := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.Set15Sec(const aCount: Integer;
                                     const aAmount: Double);
begin
  F15Sec := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

procedure TTradeHistoryTotal.SetOneSec(const aCount: Integer;
                                       const aAmount: Double);
begin
  FSec := TTradeHistory.TPeriod.Create(aCount, aAmount);
end;

end.
