unit uExchangeManager;

interface

uses
  SysUtils, Vcl.ExtCtrls, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  uSettigns

  , uExchangeClass
  , uDepthBinance
  , uDepthBittrex
  , uDepthPoloniex
  , uDepthKraken
  , uDepthBitstamp
  , uDepthBitfinex
  , uDepthHuobi
  , uDepthOkex
  , uDepthHitbtc
  , uDepthBibox;

type
  TExchangeManager = class
    private
      FTimer: TTimer;
      FActive: Boolean;

      FBinance: TDepthBinance;
      FBittrex: TDepthBittrex;
//      FPoloniex: TDepthPoloniex;
      FBitfinex: TDepthBitfinex;
      FKraken: TDepthKraken;
      FBitstamp: TDepthBitstamp;
      FOkex: TDepthOkex;
      FHuobi: TDepthHuobi;
      FHitBTC: TDepthHitBTC;
      FBibox: TDepthBibox;

      FDepthBidsList,
      FDepthAsksList: TList<TPairDepth>;

      FOnUpdateDepth: TOnUpdateDepth;
      FOnUpdateStatistics24h: TOnUpdateStatistics24h;

      FAsksComparison,
      FBidsComparison: IComparer<TPairDepth>;

      FSettins: ISettigns;

      procedure DoDepthManage;

      procedure ApplyUpdate;
      procedure DeleteWhenLess(aList: TList<TPairDepth>; const aMinAmount: Double);
      function  GetTotalAmount(const aList: TList<TPairDepth>): Double;
      procedure DoTimer(Sender: TObject);
      procedure SetActive(const Value: Boolean);
    public
      constructor Create(const aSettins: ISettigns);
      destructor  Destroy; override;

      procedure UpdateActiveExchange;
      procedure BeginManage;

      property OnUpdateDepth: TOnUpdateDepth read FOnUpdateDepth write FOnUpdateDepth;
      property OnUpdateStatistics24h: TOnUpdateStatistics24h read FOnUpdateStatistics24h write FOnUpdateStatistics24h;

      property Active: Boolean read FActive write SetActive;
      property Settings: ISettigns read FSettins;

      property BiBox: TDepthBibox read FBibox;
      property Binance: TDepthBinance read FBinance;
      property Bittrex: TDepthBittrex read FBittrex;
      property Bitfinex: TDepthBitfinex read FBitfinex;
      property Kraken: TDepthKraken read FKraken;
      property Bitstamp: TDepthBitstamp read FBitstamp;
      property Okex: TDepthOkex read FOkex;
      property Huobi: TDepthHuobi read FHuobi;
      property HitBTC: TDepthHitBTC read FHitBTC;
  end;

implementation

uses
  uLogging,
  System.Math;

{ TExchangeManager }

procedure TExchangeManager.ApplyUpdate;
var
  LPairDepth: TPairDepth;
  LIndex, i: Integer;
  LFullArr: TArray<TPairDepth>;
  LTotalBids, LTotalAsks: Double;
begin
  if FBinance.ApplyUpdate
     and FBittrex.ApplyUpdate
     and FBitfinex.ApplyUpdate
     and FKraken.ApplyUpdate
     and FBitstamp.ApplyUpdate
     and FOkex.ApplyUpdate
     and FHuobi.ApplyUpdate
     and FHitbtc.ApplyUpdate
     and FBibox.ApplyUpdate
  then
  begin
    FDepthBidsList.Clear;
    FDepthBidsList.AddRange(FBinance.ArrDepthBids);
    FDepthBidsList.AddRange(FBittrex.ArrDepthBids);
    FDepthBidsList.AddRange(FBitfinex.ArrDepthBids);
    FDepthBidsList.AddRange(FKraken.ArrDepthBids);
    FDepthBidsList.AddRange(FBitstamp.ArrDepthBids);
    FDepthBidsList.AddRange(FOkex.ArrDepthBids);
    FDepthBidsList.AddRange(FHuobi.ArrDepthBids);
    FDepthBidsList.AddRange(FHitbtc.ArrDepthBids);
    FDepthBidsList.AddRange(FBibox.ArrDepthBids);

    FDepthAsksList.Clear;
    FDepthAsksList.AddRange(FBinance.ArrDepthAsks);
    FDepthAsksList.AddRange(FBittrex.ArrDepthAsks);
    FDepthAsksList.AddRange(FBitfinex.ArrDepthAsks);
    FDepthAsksList.AddRange(FKraken.ArrDepthAsks);
    FDepthAsksList.AddRange(FBitstamp.ArrDepthAsks);
    FDepthAsksList.AddRange(FOkex.ArrDepthAsks);
    FDepthAsksList.AddRange(FHuobi.ArrDepthAsks);
    FDepthAsksList.AddRange(FHitbtc.ArrDepthAsks);
    FDepthAsksList.AddRange(FBibox.ArrDepthAsks);

    DeleteWhenLess(FDepthBidsList, FSettins.MinPrice);
    DeleteWhenLess(FDepthAsksList, FSettins.MinPrice);

    FDepthBidsList.Sort(FBidsComparison);
    FDepthAsksList.Sort(FAsksComparison);

    i := 0;
    while i + 1 < FDepthBidsList.Count do
      if FDepthBidsList[i].Price = FDepthBidsList[i + 1].Price then
      begin
        FDepthBidsList[i].AddPair(FDepthBidsList[i + 1]);
        FDepthBidsList.Delete(i + 1);
      end
      else
        Inc(i);

    // Asks list
    i := 0;
    while i + 1 < FDepthAsksList.Count do
      if FDepthAsksList[i].Price = FDepthAsksList[i + 1].Price then
      begin
        FDepthAsksList[i].AddPair(FDepthAsksList[i + 1]);
        FDepthAsksList.Delete(i + 1);
      end
      else
        Inc(i);

    LTotalBids := GetTotalAmount(FDepthBidsList);
    LTotalAsks := GetTotalAmount(FDepthAsksList);

    TThread.Synchronize(TThread.Current,
    procedure
    begin
      if Assigned(FOnUpdateStatistics24h) then
        FOnUpdateStatistics24h(FBinance.Statis24h);

      if Assigned(FOnUpdateDepth) then
        FOnUpdateDepth(FDepthBidsList, FDepthAsksList, LTotalBids, LTotalAsks);
    end);

    FBinance.ApplyUpdate := False;
    FBittrex.ApplyUpdate := False;
    FBitfinex.ApplyUpdate := False;
    FKraken.ApplyUpdate := False;
    FBitstamp.ApplyUpdate := False;
    FOkex.ApplyUpdate := False;
    FHuobi.ApplyUpdate := False;
    FHitbtc.ApplyUpdate := False;
    FBibox.ApplyUpdate := False;

    // Запуск збору стаканів
    FTimer.Enabled := True;
  end;
end;

procedure TExchangeManager.DeleteWhenLess(aList: TList<TPairDepth>;
                                  const aMinAmount: Double);
var
  i: Integer;
begin
  i := 0;

  while i < aList.Count do
  begin
    if aList[i].Amount <= aMinAmount then
      aList.Delete(i)
    else
      Inc(i);
  end;
end;

function TExchangeManager.GetTotalAmount(const aList: TList<TPairDepth>): Double;
var
  LPair: TPairDepth;
begin
  Result := 0;

  for LPair in aList do
    Result := Result + LPair.Amount;
end;

procedure TExchangeManager.SetActive(const Value: Boolean);
begin
  FActive := Value;

  if FActive then
    BeginManage;
end;

procedure TExchangeManager.UpdateActiveExchange;
begin
  FBinance.Active := FSettins.UseBinance;
  FBittrex.Active := FSettins.UseBittrex;
  FBitfinex.Active := FSettins.UseBitfinex;
  FKraken.Active := FSettins.UseKraken;
  FBitstamp.Active := FSettins.UseBitstamp;
  FOkex.Active := FSettins.UseOkex;
  FHuobi.Active := FSettins.UseHuobi;
  FHitbtc.Active := FSettins.UseHitBTC;
  FBibox.Active := FSettins.UseBiBox;
end;

procedure TExchangeManager.BeginManage;
begin
  FBinance.BeginManage;
  FBittrex.BeginManage;
  FBitfinex.BeginManage;
  FKraken.BeginManage;
  FBitstamp.BeginManage;
  FOkex.BeginManage;
  FHuobi.BeginManage;
  FHitbtc.BeginManage;
  FBibox.BeginManage;
//  FPoloniex.BeginManage;
end;

constructor TExchangeManager.Create(const aSettins: ISettigns);
begin
  FSettins := aSettins;

  FAsksComparison := TDelegatedComparer<TPairDepth>.Construct(
    function(const Left, Right: TPairDepth): Integer
    begin
      Result := -1;

      if Assigned(Left) and Assigned(Right) then
        if Left.Price = Right.Price then Result := 0 else
        if Left.Price > Right.Price then Result := 1
        else
          Result := -1;
    end);

  FBidsComparison := TDelegatedComparer<TPairDepth>.Construct(
    function(const Left, Right: TPairDepth): Integer
    begin
      Result := -1;

      if Assigned(Left) and Assigned(Right) then
        if Left.Price = Right.Price then Result := 0 else
        if Left.Price < Right.Price then Result := 1
        else
          Result := -1;
    end);


  FDepthBidsList := TList<TPairDepth>.Create;
  FDepthAsksList := TList<TPairDepth>.Create;

  FBinance := TDepthBinance.Create;
  FBinance.OnDepthManage := DoDepthManage;
  FBinance.Active := FSettins.UseBinance;

  FBittrex := TDepthBittrex.Create;
  FBittrex.OnDepthManage := DoDepthManage;
  FBittrex.Active := FSettins.UseBittrex;

  FBitfinex := TDepthBitfinex.Create;
  FBitfinex.OnDepthManage := DoDepthManage;
  FBitfinex.Active := FSettins.UseBitfinex;

  FKraken := TDepthKraken.Create;
  FKraken.OnDepthManage := DoDepthManage;
  FKraken.Active := FSettins.UseKraken;

  FBitstamp := TDepthBitstamp.Create;
  FBitstamp.OnDepthManage := DoDepthManage;
  FBitstamp.Active := FSettins.UseBitstamp;

  FOkex := TDepthOkex.Create;
  FOkex.OnDepthManage := DoDepthManage;
  FOkex.Active := FSettins.UseOkex;

  FHuobi := TDepthHuobi.Create;
  FHuobi.OnDepthManage := DoDepthManage;
  FHuobi.Active := FSettins.UseHuobi;

  FHitbtc := TDepthHitbtc.Create;
  FHitbtc.OnDepthManage := DoDepthManage;
  FHitbtc.Active := FSettins.UseHitBTC;

  FBibox := TDepthBibox.Create;
  FBibox.OnDepthManage := DoDepthManage;
  FBibox.Active := FSettins.UseBiBox;

//  FPoloniex := TDepthPoloniex.Create;
//  FPoloniex.OnDepthManage := DoDepthManageBittrex;

  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 5000;
  FTimer.OnTimer := DoTimer;
end;

destructor TExchangeManager.Destroy;
begin
  FTimer.Enabled := False;
  FreeAndNil(FTimer);

  FreeAndNil(FBinance);
  FreeAndNil(FBittrex);
  FreeAndNil(FBitfinex);
  FreeAndNil(FKraken);
  FreeAndNil(FBitstamp);
  FreeAndNil(FOkex);
  FreeAndNil(FHuobi);
  FreeAndNil(FHitbtc);
  FreeAndNil(FBibox);
//  FreeAndNil(FPoloniex);

  FreeAndNil(FDepthAsksList);
  FreeAndNil(FDepthBidsList);

  inherited;
end;

procedure TExchangeManager.DoDepthManage;
begin
  ApplyUpdate;
end;

procedure TExchangeManager.DoTimer(Sender: TObject);
begin
  FTimer.Enabled := False;

  if Active then
    BeginManage;
end;

end.
