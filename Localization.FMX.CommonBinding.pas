unit Localization.FMX.CommonBinding;

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Forms,
  FMX.Controls,
  FMX.StdCtrls,

  Localization;

implementation

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
//  if Parent is TCustomActionList then
//  begin
//    with TCustomActionList(Parent) do
//      for cc := 0 to ActionCount - 1 do
//        FComponentMethod(Actions[cc]);
//  end;

  for cc := 0 to Parent.ComponentCount - 1 do
  begin
    FComponentMethod(Parent.Components[cc]);
    if Parent.Components[cc].ComponentCount > 0 then
      DeepScan(Parent.Components[cc]);
  end;
end;

initialization
  RegisterRootComponent(Application);

  RegisterSchemeSource(TStyledControl, ControlSchemeSource);

  RegisterSchemeTranslate(TPresentedTextControl, PresentedTextControlSchemeTranslate);

  RegisterDeepScannerClass(TFMXDeepScanner);

end.
