unit uLogging;

interface

uses
  Windows,
  Classes;

type
  TTestRun = class
    private
      class function DoCreateOpenFile(const aPath: string): TFileStream; static;
    public
      class procedure AddMarker(const aText: string); static;
  end;

implementation

uses
  SysUtils;

function GetModuleName: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, Length(ModName)));
end;

{ TTestRun }

class procedure TTestRun.AddMarker(const aText: string);
var
  LFile, LText: String;
  LFileStream: TFileStream;
begin
  LFile := ExtractFilePath(GetModuleName) + 'TestRun.txt';

  LFileStream := DoCreateOpenFile(LFile);
  try
    LFileStream.Seek(0, TSeekOrigin.soEnd);

    LText := FormatDateTime('hh:mm:ss', Now) + aText + #13;
    LFileStream.WriteBuffer(PChar(LText)^, Length(LText));
  finally
    FreeAndNil(LFileStream);
  end;
end;

class function TTestRun.DoCreateOpenFile(const aPath: string): TFileStream;
var
  Mode: Word;
begin
  if FileExists(aPath) then
    Mode := SysUtils.fmOpenReadWrite
  else
    Mode := Classes.fmCreate;

  Result := TFileStream.Create(aPath, Mode);
end;

end.
