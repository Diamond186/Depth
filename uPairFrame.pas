unit uPairFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, VirtualTrees, Vcl.Imaging.pngimage, System.Generics.Collections

  , uExchangeManager
  , uExchangeClass
  , uSettigns

  ;

type
  TframePair = class(TFrame)
    Panel: TPanel;
    vstBTC: TVirtualStringTree;
    pHeader: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lPrice: TLabel;
    pFooter: TPanel;
    lAmount24h: TLabel;
    gpTotal: TGridPanel;
    lTotalBids: TLabel;
    lTotalAsks: TLabel;
    iClose: TImage;
    iAdd: TImage;
    iSettings: TImage;
    pMainHeader: TPanel;
    pRightHeader: TPanel;
    pLeftHeader: TPanel;
    procedure iCloseClick(Sender: TObject);
    procedure iAddClick(Sender: TObject);
    procedure vstBTCGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBTCPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstBTCGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: string);
    procedure iSettingsClick(Sender: TObject);
  private
    FExchangeManager: TExchangeManager;

    FDepthBidsList,
    FDepthAsksList: TList<TPairDepth>;
    FSettins: ISettigns;

    procedure DoUpdateStatistics24h(const aStatistics24h: TStatistics24h);
    procedure DoUpdateDepth(const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double);
    function  GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    class procedure CreateFrame(AOwner: TWinControl; const aPairName: String);
    destructor Destroy; override;

    property Settins: ISettigns read FSettins;
    property Active: Boolean read GetActive write SetActive;
  end;

implementation

{$R *.dfm}

uses
  Math, ufSettings, System.UITypes;

class procedure TframePair.CreateFrame(AOwner: TWinControl; const aPairName: String);
begin
  with TframePair.Create(AOwner) do
  begin
    Parent := AOwner;

    FSettins := uSettigns.CreateSettigns;
    FSettins.Load(aPairName);

    FDepthBidsList := TList<TPairDepth>.Create;
    FDepthAsksList := TList<TPairDepth>.Create;

    FormatSettings.DecimalSeparator := '.';
    FExchangeManager := TExchangeManager.Create(FSettins);

    FExchangeManager.OnUpdateDepth := DoUpdateDepth;
    FExchangeManager.OnUpdateStatistics24h := DoUpdateStatistics24h;

    FExchangeManager.Active := True;
  end;
end;

destructor TframePair.Destroy;
begin
  FreeAndNil(FExchangeManager);
  FreeAndNil(FDepthBidsList);
  FreeAndNil(FDepthAsksList);
  FSettins := nil;

  inherited;
end;

procedure TframePair.iAddClick(Sender: TObject);
begin
  TframePair.CreateFrame(Self, EmptyStr);
end;

procedure TframePair.iCloseClick(Sender: TObject);
begin
  Self.Parent := nil;
end;

procedure TframePair.iSettingsClick(Sender: TObject);
begin
  if TfrmSettings.ShowSettings(FSettins) then
  begin
    FExchangeManager.UpdateActiveExchange;
  end;
end;

procedure TframePair.SetActive(const Value: Boolean);
begin
  FExchangeManager.Active := Value;
end;

procedure TframePair.DoUpdateDepth(const aBidsList, aAsksList: TList<TPairDepth>; const aTotalBids, aTotalAsks: Double);
var
  i: Integer;
begin
  if Assigned(aBidsList)
    and Assigned(aAsksList)
  then
  begin
    vstBTC.BeginUpdate;
    try
      FDepthBidsList.Clear;
      FDepthAsksList.Clear;

      for i := 0 to aBidsList.Count - 1 do
        FDepthBidsList.Add(TPairDepth.Create(aBidsList[i].Price,
                                             aBidsList[i].Amount,
                                             aBidsList[i].ExchangeList));

      for i := 0 to aAsksList.Count - 1 do
        FDepthAsksList.Add(TPairDepth.Create(aAsksList[i].Price,
                                             aAsksList[i].Amount,
                                             aAsksList[i].ExchangeList));

      vstBTC.RootNodeCount := Max(FDepthBidsList.Count, FDepthAsksList.Count);

      vstBTC.Refresh;
    finally
      vstBTC.EndUpdate;
    end;

    lTotalBids.Caption := Format('%n', [SimpleRoundTo(aTotalBids)]);
    lTotalAsks.Caption := Format('%n', [SimpleRoundTo(aTotalAsks)]);
  end;
end;

procedure TframePair.DoUpdateStatistics24h(const aStatistics24h: TStatistics24h);
const
  cMinMax = '%n - %n';
begin
  Label2.Caption := Format(cMinMax, [SimpleRoundTo(aStatistics24h.LowPrice),
                                     SimpleRoundTo(aStatistics24h.HighPrice)]);

  lPrice.Caption := Format('%n', [SimpleRoundTo(aStatistics24h.LastPrice)]);

  lAmount24h.Caption := Format('%n', [SimpleRoundTo(aStatistics24h.Volume)]);
end;

function TframePair.GetActive: Boolean;
begin
  Result := FExchangeManager.Active;
end;

procedure TframePair.vstBTCGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
const
  cBids = 0;
  cAsks = 1;
var
  LPair: TPairDepth;
  LAccess: Boolean;
begin
  CellText := EmptyStr;
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
  then
    CellText := FloatToStr(LPair.Price) + ' - ' + FloatToStr(SimpleRoundTo(LPair.Amount));
end;

procedure TframePair.vstBTCGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: string);
const
  cBids = 0;
  cAsks = 1;
var
  LAccess: Boolean;
  LPair: TPairDepth;
begin
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
  then
    HintText := LPair.ExchangeList;
end;

procedure TframePair.vstBTCPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
const
  cBids = 0;
  cAsks = 1;
var
  LPair: TPairDepth;
  LAccess: Boolean;
begin
  LAccess := False;
  LPair := nil;

  case Column of
    cBids:
      begin
        LAccess := Node.Index < Word(FDepthBidsList.Count);

        if LAccess then
          LPair := FDepthBidsList[Node.Index];
      end;

    cAsks:
      begin
        LAccess := Node.Index < Word(FDepthAsksList.Count);

        if LAccess then
          LPair := FDepthAsksList[Node.Index];
      end;
  end;

  if LAccess
    and Assigned(LPair)
    and (LPair.Amount >= FSettins.BoldPrice)
  then
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
end;

end.
