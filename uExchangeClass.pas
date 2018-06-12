unit uExchangeClass;

interface

uses
  System.SysUtils, System.Classes,
  System.Generics.Collections;

type
  TExchange = (BiBox, Binance, Bitfinex, Bitstamp, Bittrex, HitBTC, Huobi, Kraken, Okex, Poloniex);

  TExchangeHelper = record helper for TExchange
    private
      const
        cArrExchangesText: array [TExchange] of string = ('BiBox', 'Binance', 'Bitfinex',
                                                           'Bitstamp', 'Bittrex', 'HitBTC',
                                                           'Huobi', 'Kraken', 'Okex', 'Poloniex');
    public
      function ToString: string; overload; inline;
      class function Count: Integer; inline; static;
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
  TOnUpdateStatistics24h = procedure (const aStatistics24h: TStatistics24h) of Object;

implementation

uses
  uSettigns,
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

function TExchangeHelper.ToString: string;
begin
  Result := cArrExchangesText[Self];
end;
end.
