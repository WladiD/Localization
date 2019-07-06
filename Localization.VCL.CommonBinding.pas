unit Localization.VCL.CommonBinding;

interface

uses
  Localization,
  System.Actions,
  Vcl.Controls,
  Vcl.StdCtrls;

implementation

type
  // For access to the protected properties
  TControlRobin = class(TControl);

function ControlSchemeSource(Target: TObject): string;
begin
  Result := TControl(Target).HelpKeyword;
end;

function ContainedActionSource(Target: TObject): string;
begin
  Result := TContainedAction(Target).HelpKeyword;
end;

function ControlCaptionScheme(Target: TObject; const Scheme: string; const TranslatedValue: string): Boolean;
var
  Control: TControlRobin absolute Target;
begin
  Result := True;
  if Scheme = TLang.CaptionScheme then
    Control.Caption := TranslatedValue
  else if Scheme = TLang.HintScheme then
    Control.Hint := TranslatedValue
  else
    Result := False;
end;

initialization
  RegisterSchemeSource(TControl, ControlSchemeSource);
  RegisterSchemeSource(TContainedAction, ContainedActionSource);

  RegisterSchemeTranslate(TControl, ControlCaptionScheme);

end.
