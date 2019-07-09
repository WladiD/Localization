unit Localization.VCL.CommonBinding;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Actions,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.Forms,
  Vcl.Consts,
  Vcl.Menus,

  ProcedureHook,

  Localization;

implementation

type
  // For access to the protected properties
  TControlRobin = class(TControl);

  TVCLDeepScanner = class(TDeepScanner)
  public
    procedure DeepScan(Parent: TComponent); override;
  end;

  TMethodsHolder = class
  public
    type
    TMenuKeyCap = (mkcBkSp, mkcTab, mkcEsc, mkcEnter, mkcSpace, mkcPgUp, mkcPgDn, mkcEnd,
      mkcHome, mkcLeft, mkcUp, mkcRight, mkcDown, mkcIns, mkcDel, mkcShift, mkcCtrl, mkcAlt);

    {**
     * Runtime translate of some resource strings of Delphi's Consts.pas
     *
     * @see TLang.SetLangCode.HookConsts
     *}
    class var
    ConstResources: TStringDynArray;
    MenuKeyCaps: array[TMenuKeyCap] of string;

    class procedure LangChangedEventHandler(Sender: TObject);

    class function ShortCutToText(ShortCut: TShortCut): string;
  end;

var
  OriginShortCutToText: TOverWrittenData;

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

function ContainedActionSchemeTranslate(Target: TObject; const Scheme: string;
  const TranslatedValue: string): Boolean;
var
  Action: TContainedAction absolute Target;
begin
  Result := True;
  if Scheme = TLang.CaptionScheme then
    Action.Caption := TranslatedValue
  else if Scheme = TLang.HintScheme then
    Action.Hint := TranslatedValue
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

procedure HookResourceString(RS: PResStringRec; NewString: PChar);
var
  OldProtect: DWORD;
begin
  VirtualProtect(RS, SizeOf(RS^), PAGE_EXECUTE_READWRITE, @OldProtect);
  RS^.Identifier := Integer(NewString);
  VirtualProtect(RS, SizeOf(RS^), OldProtect, @OldProtect);
end;

function ShortCutToTextController(ShortCut: TShortCut): string;
begin
  if Assigned(Lang) then
    Result := TMethodsHolder.ShortCutToText(ShortCut)
  else
    Result := '';
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

{ TMethodsHolder }

class procedure TMethodsHolder.LangChangedEventHandler(Sender: TObject);
var
  LangSender: TLang absolute Sender;

  procedure ReadKeyCaptionConsts;
  const
    KeyCapIdents: array[TMenuKeyCap] of string = (
      'KeyBackspaceShort',
      'KeyTabShort',
      'KeyEscapeShort',
      'KeyEnterShort',
      'KeySpaceShort',
      'KeyPageUpShort',
      'KeyPageDownShort',
      'KeyEndShort',
      'KeyHomeShort',
      'KeyArrowLeftShort',
      'KeyArrowUpShort',
      'KeyArrowRightShort',
      'KeyArrowDownShort',
      'KeyInsertShort',
      'KeyDeleteShort',
      'KeyShiftShort',
      'KeyControlShort',
      'KeyAlternateShort');
  var
    cc: Integer;
  begin
    for cc := 0 to Ord(High(TMenuKeyCap)) do
      MenuKeyCaps[TMenuKeyCap(cc)] := LangSender.Consts[KeyCapIdents[TMenuKeyCap(cc)]];
  end;

  procedure HookConsts;
  type
    TConstAssign = record
      Name: string;
      Target: PResStringRec;
    end;
  const
    ConstMax = 17;
    ConstResourcesMap: array[0..ConstMax] of TConstAssign = (
      (Name: 'SMsgDlgWarning'; Target: @SMsgDlgWarning),
      (Name: 'SMsgDlgError'; Target: @SMsgDlgError),
      (Name: 'SMsgDlgInformation'; Target: @SMsgDlgInformation),
      (Name: 'SMsgDlgConfirm'; Target: @SMsgDlgConfirm),
      (Name: 'SMsgDlgYes'; Target: @SMsgDlgYes),
      (Name: 'SMsgDlgNo'; Target: @SMsgDlgNo),
      (Name: 'SMsgDlgOK'; Target: @SMsgDlgOK),
      (Name: 'SMsgDlgCancel'; Target: @SMsgDlgCancel),
      (Name: 'SMsgDlgHelp'; Target: @SMsgDlgHelp),
      (Name: 'SMsgDlgHelpNone'; Target: @SMsgDlgHelpNone),
      (Name: 'SMsgDlgHelpHelp'; Target: @SMsgDlgHelpHelp),
      (Name: 'SMsgDlgAbort'; Target: @SMsgDlgAbort),
      (Name: 'SMsgDlgRetry'; Target: @SMsgDlgRetry),
      (Name: 'SMsgDlgIgnore'; Target: @SMsgDlgIgnore),
      (Name: 'SMsgDlgAll'; Target: @SMsgDlgAll),
      (Name: 'SMsgDlgNoToAll'; Target: @SMsgDlgNoToAll),
      (Name: 'SMsgDlgYesToAll'; Target: @SMsgDlgYesToAll),
      (Name: 'SMsgDlgClose'; Target: @SMsgDlgClose)
    );
  var
    cc: Integer;
  begin
    SetLength(ConstResources, ConstMax + 1);
    for cc := 0 to ConstMax do
    begin
      ConstResources[cc] := LangSender.Consts[ConstResourcesMap[cc].Name];
      HookResourceString(ConstResourcesMap[cc].Target, PChar(ConstResources[cc]));
    end;
  end;

begin
  ReadKeyCaptionConsts;
  HookConsts;
end;

class function TMethodsHolder.ShortCutToText(ShortCut: TShortCut): string;
var
  Name: string;
  Key: Byte;

  function GetSpecialName(ShortCut: TShortCut): string;
  var
    ScanCode: Integer;
    KeyName: array[0..255] of Char;
  begin
    Result := '';
    ScanCode := MapVirtualKey(LoByte(Word(ShortCut)), 0) shl 16;
    if ScanCode <> 0 then
    begin
      GetKeyNameText(ScanCode, KeyName, Length(KeyName));
      GetSpecialName := KeyName;
    end;
  end;
begin
  Key := LoByte(Word(ShortCut));
  case Key of
    $08, $09:
      Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcBkSp) + Key - $08)];
    $0D:
      Name := MenuKeyCaps[mkcEnter];
    $1B:
      Name := MenuKeyCaps[mkcEsc];
    $20..$28:
      Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcSpace) + Key - $20)];
    $2D..$2E:
      Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcIns) + Key - $2D)];
    $30..$39:
      Name := Chr(Key - $30 + Ord('0'));
    $41..$5A:
      Name := Chr(Key - $41 + Ord('A'));
    $60..$69:
      Name := Chr(Key - $60 + Ord('0'));
    $70..$87:
      Name := 'F' + IntToStr(Key - $6F);
    else
      Name := GetSpecialName(ShortCut);
  end;
  if Name <> '' then
  begin
    Result := '';
    if ShortCut and scCtrl <> 0 then
      Result := Result + MenuKeyCaps[mkcCtrl] + '+';
    if ShortCut and scAlt <> 0 then
      Result := Result + MenuKeyCaps[mkcAlt] + '+';
    if ShortCut and scShift <> 0 then
      Result := Result + MenuKeyCaps[mkcShift] + '+';
    Result := Result + Name;
  end
  else
    Result := '';
end;

initialization
  RegisterRootComponent(Application);

  RegisterSchemeSource(TControl, ControlSchemeSource);
  RegisterSchemeSource(TContainedAction, ContainedActionSource);

  RegisterSchemeTranslate(TControl, ControlSchemeTranslate);
  RegisterSchemeTranslate(TContainedAction, ContainedActionSchemeTranslate);
  RegisterSchemeTranslate(TCustomEdit, EditSchemeTranslate);

  RegisterDeepScannerClass(TVCLDeepScanner);

  RegisterAfterLanguageChangeNotifyEvent(TMethodsHolder.LangChangedEventHandler);

  OverwriteProcedure(@ShortCutToText, @ShortCutToTextController, @OriginShortCutToText);

finalization
  RestoreProcedure(@ShortCutToText, OriginShortCutToText);

end.
