program Depth;

uses
  Vcl.Forms,
  ufMain in 'ufMain.pas' {frmMain},
  uDepthBinance in 'uDepthBinance.pas',
  uDepthBittrex in 'uDepthBittrex.pas',
  uDepthPoloniex in 'uDepthPoloniex.pas',
  uDepthBitfinex in 'uDepthBitfinex.pas',
  uDepthKraken in 'uDepthKraken.pas',
  uDepthBitstamp in 'uDepthBitstamp.pas',
  uDepthOkex in 'uDepthOkex.pas',
  uDepthHuobi in 'uDepthHuobi.pas',
  uDepthHitbtc in 'uDepthHitbtc.pas',
  uDepthBibox in 'uDepthBibox.pas',
  uCustomDepth in 'uCustomDepth.pas',
  uExchangeClass in 'uExchangeClass.pas',
  uExchangeManager in 'uExchangeManager.pas',
  ufSettings in 'ufSettings.pas' {frmSettings},
  uSettigns in 'uSettigns.pas',
  uLogging in 'uLogging.pas',
  uPairFrame in 'uPairFrame.pas' {framePair: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
