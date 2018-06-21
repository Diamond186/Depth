unit ufMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, VirtualTrees, Vcl.ExtCtrls

  , uPairFrame

  , Vcl.Menus, Vcl.AppEvnts;

type
  TfrmMain = class(TForm)
    MainMenu: TMainMenu;
    miSettings: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
  private

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.IniFiles;

procedure TfrmMain.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  AutoSize := False;
  Constraints.MaxWidth := Width;
  Constraints.MinWidth := Width;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
const
  cFileName = 'Settings.ini';
var
  LFileName, LSectionName: String;
  LSections: TStringList;
begin
  LFileName := ExtractFilePath(ParamStr(0)) + cFileName;

  if FileExists(LFileName) then
  with TMemIniFile.Create(LFileName) do
  try
    LSections := TStringList.Create;
    try
      ReadSections(LSections);

      if LSections.Count = 0 then
        TframePair.CreateFrame(self, EmptyStr)
      else
      for LSectionName in LSections do
        TframePair.CreateFrame(self, LSectionName);
    finally
      FreeAndNil(LSections);
    end;

    AutoSize := True;
  finally
    Free;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  i: Integer;
  LFrame: TframePair;
begin
  for i := 0 to Self.ControlCount - 1 do
  if Self.Controls[i] is TframePair then
  begin
    LFrame := (Self.Controls[i] as TframePair);

    if LFrame.Active then
      LFrame.Active := False;
  end;

  Sleep(5000);
end;

end.
