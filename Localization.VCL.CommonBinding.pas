unit Localization.VCL.CommonBinding;

interface

uses
  System.Actions,
  System.Classes,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.Forms,

  Localization;

implementation

type
  // For access to the protected properties
  TControlRobin = class(TControl);

  TVCLDeepScanner = class(TDeepScanner)
  public
    procedure DeepScan(Parent: TComponent); override;
  end;

function ControlSchemeSource(Target: TObject): string;
begin
  Result := TControl(Target).HelpKeyword;
end;

function ContainedActionSource(Target: TObject): string;
begin
  Result := TContainedAction(Target).HelpKeyword;
end;

function ControlSchemeTranslate(Target: TObject; const Scheme: string;
  const TranslatedValue: string): Boolean;
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

function EditSchemeTranslate(Target: TObject; const Scheme: string;
  const TranslatedValue: string): Boolean;
var
  Edit: TCustomEdit absolute Target;
begin
  if Scheme = TLang.TextHintScheme then
  begin
    Edit.TextHint := TranslatedValue;
    Result := True;
  end
  else
    Result := False;
end;

{ TVCLDeepScanner }

procedure TVCLDeepScanner.DeepScan(Parent: TComponent);
var
  cc: Integer;
begin
  if Parent is TCustomActionList then
  begin
    with TCustomActionList(Parent) do
      for cc := 0 to ActionCount - 1 do
        FComponentMethod(Actions[cc]);
  end;

  for cc := 0 to Parent.ComponentCount - 1 do
  begin
    FComponentMethod(Parent.Components[cc]);
    if Parent.Components[cc].ComponentCount > 0 then
      DeepScan(Parent.Components[cc]);
  end;
end;

initialization
  RegisterRootComponent(Application);

  RegisterSchemeSource(TControl, ControlSchemeSource);
  RegisterSchemeSource(TContainedAction, ContainedActionSource);

  RegisterSchemeTranslate(TControl, ControlSchemeTranslate);
  RegisterSchemeTranslate(TCustomEdit, EditSchemeTranslate);

  RegisterDeepScannerClass(TVCLDeepScanner);
end.
