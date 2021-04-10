unit Localization.FMX.CommonBinding;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Forms,
  FMX.Types,
  FMX.Consts,
  FMX.Controls,
  FMX.StdCtrls,

  Localization;

implementation

type
  TFMXConstMap = record
  private
    class var Map: TDictionary<string, string>;
    class constructor Create;
    class destructor Destroy;

  public
    class function IsFMXConst(const ConstText: string; out Key: string): Boolean; static;
  end;

// Binding function to FMX.Types.CustomTranslateProc
//
// It is responsible for:
// - Translation for the consts in FMX.Consts
function Translate(const Text: string): string;
var
  FMXConst, FMXConstTranslation: string;
begin
  if TFMXConstMap.IsFMXConst(Text, FMXConst) then
  begin
    FMXConstTranslation := Lang.Consts[FMXConst];
    if FMXConstTranslation <> '' then
      Result := FMXConstTranslation
    else
      Result := Text;
  end
  else
    Result := Text;
end;

function ControlSchemeSource(Target: TObject): string;
begin
  Result := TStyledControl(Target).HelpKeyword;
end;

function PresentedTextControlSchemeTranslate(Target: TObject; const Scheme: string;
  const TranslatedValue: string): Boolean;
var
  Control: TPresentedTextControl absolute Target;
begin
  Result := True;
  if (Scheme = TLang.CaptionScheme) or (Scheme = TLang.TextScheme) then
    Control.Text := TranslatedValue
  else if Scheme = TLang.HintScheme then
    Control.Hint := TranslatedValue
  else
    Result := False;
end;

function ControlSchemeTranslate(Target: TObject; const Scheme: string;
  const TranslatedValue: string): Boolean;
var
  Control: TControl absolute Target;
begin
  Result := True;
  if Scheme = TLang.HintScheme then
    Control.Hint := TranslatedValue
  else
    Result := False;
end;

type
  TFMXDeepScanner = class(TDeepScanner)
  public
    procedure DeepScan(Parent: TComponent); override;
  end;

{ TFMXDeepScanner }

procedure TFMXDeepScanner.DeepScan(Parent: TComponent);
var
  cc: Integer;
begin
  for cc := 0 to Parent.ComponentCount - 1 do
  begin
    FComponentMethod(Parent.Components[cc]);
    if Parent.Components[cc].ComponentCount > 0 then
      DeepScan(Parent.Components[cc]);
  end;
end;

{ TFMXConstMap }

class constructor TFMXConstMap.Create;
begin
  Map := TDictionary<string, string>.Create;

  Map.AddOrSetValue(SMsgDlgWarning, 'SMsgDlgWarning');
  Map.AddOrSetValue(SMsgDlgError, 'SMsgDlgError');
  Map.AddOrSetValue(SMsgDlgInformation, '');
  Map.AddOrSetValue(SMsgDlgConfirm, 'SMsgDlgConfirm');
  Map.AddOrSetValue(SMsgDlgYes, 'SMsgDlgYes');
  Map.AddOrSetValue(SMsgDlgNo, 'SMsgDlgNo');
  Map.AddOrSetValue(SMsgDlgOK, 'SMsgDlgOK');
  Map.AddOrSetValue(SMsgDlgCancel, 'SMsgDlgCancel');
  Map.AddOrSetValue(SMsgDlgHelp, 'SMsgDlgHelp');
  Map.AddOrSetValue(SMsgDlgHelpNone, 'SMsgDlgHelpNone');
  Map.AddOrSetValue(SMsgDlgHelpHelp, 'SMsgDlgHelpHelp');
  Map.AddOrSetValue(SMsgDlgAbort, 'SMsgDlgAbort');
  Map.AddOrSetValue(SMsgDlgRetry, 'SMsgDlgRetry');
  Map.AddOrSetValue(SMsgDlgIgnore, 'SMsgDlgIgnore');
  Map.AddOrSetValue(SMsgDlgAll, 'SMsgDlgAll');
  Map.AddOrSetValue(SMsgDlgNoToAll, 'SMsgDlgNoToAll');
  Map.AddOrSetValue(SMsgDlgYesToAll, 'SMsgDlgYesToAll');
  Map.AddOrSetValue(SMsgDlgClose, 'SMsgDlgClose');
end;

class destructor TFMXConstMap.Destroy;
begin
  Map.Free;
end;

class function TFMXConstMap.IsFMXConst(const ConstText: string; out Key: string): Boolean;
begin
  Result := Map.TryGetValue(ConstText, Key);
end;

initialization
  RegisterRootComponent(Application);

  RegisterSchemeSource(TStyledControl, ControlSchemeSource);

  RegisterSchemeTranslate(TPresentedTextControl, PresentedTextControlSchemeTranslate);
  RegisterSchemeTranslate(TControl, ControlSchemeTranslate);

  RegisterDeepScannerClass(TFMXDeepScanner);
  CustomTranslateProc := Translate;

end.
