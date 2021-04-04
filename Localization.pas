unit Localization;

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ELSE}
  FMX.Platform,
{$ENDIF}
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IniFiles,
  System.RegularExpressions,
  Generics.Collections;

type
  // Translate interface, which can be implemented on any TComponent descendant and will be
  // automatically called by TLang.Translate
  ITranslate = interface
    ['{D5DE8131-BC1E-49D3-9AF4-86A35D557FA7}']
    // If the implementor is ready for translate it should return True here.
    // But if it's not, it must return False and implement the ITranslate.OnReadyForTranslate
    // method.
    function IsReadyForTranslate: Boolean;

    // Event registering
    //
    // As described above, it must only be implemented, if IsReadyForTranslate returns False.
    // In such case it should simply save the passed NotifyEvent and call it at a later moment
    // if the implementor is ready for it.
    procedure OnReadyForTranslate(NotifyEvent: TNotifyEvent);

    // This is the key method of the interface. Here you can translate any specific elements.
    // It will be called automatically by TLang.
    procedure Translate;
  end;

  TLangEntry = record
    Code: string;
    InternationalName: string;
    LocalName: string;
  end;

  TLangEntries = array of TLangEntry;
  TNameHashedStringList = class;

  TLang = class(TComponent)
  protected

    const
    LangFileNameFormat: string = 'Lang.%s.ini';

    InfoSection: string = 'Info';
    ConstsSection: string = 'Consts';
    StringsSection: string = 'Strings';
    MessagesSection: string = 'Messages';

    var
    FLangCode: string;
    FLangInternationalName: string;
    FLangLocalName: string;

    {**
     * Runtime translate of some resource strings of Delphi's Consts.pas
     *
     * @see TLang.SetLangCode.HookConsts
     *}
    FConstResources: TStringDynArray;
    FStrings: TStringList;
    FMessages: TStringList;
    FMessagesOffset: Integer;
    FConsts: TStringList;
    FInitialized: Boolean;
    FNumberPCRE: TRegEx;
    FLangPath: string;

    procedure SetLangCode(NewLangCode: string);
    function GetString(Index: Integer): string;
    function GetConst(Name: string): string;

    procedure ReadyForTranslateEvent(Sender: TObject);
    function GetTranslateObject(Component: TComponent): ITranslate;
    procedure TranslateComponent(Component: TComponent);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    const
    CaptionScheme = 'caption';
    HintScheme = 'hint';
    TextHintScheme = 'texthint';
    TextScheme = 'text';

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetSystemLangCode: string;

    function GetLangFileName(LangCode: string; IncludePath: Boolean = True): string;
    function GetAvailableLanguages: TLangEntries;
    procedure FillAvailableLanguages(Target: TStrings; out SelIndex: Integer);
    function IsLanguageAvailable(LangCode: string): Boolean;

    function CountFormat(StringIndex, Count: Integer): string;

    function Translate(Incoming: string): string; overload;
    procedure Translate(ComponentHolder: TComponent); overload;
    procedure TranslateApplication;

    // Language code by the ISO639-1 standard
    property LangCode: string read FLangCode write SetLangCode;

    // International name of the language
    property LangInternationalName: string read FLangInternationalName;

    // The native name of the language
    property LangLocalName: string read FLangLocalName;

    // The path, where the lang files are contained
    property LangPath: string read FLangPath;

    // Common strings
    //
    // This is the default property. For the best possible speed is the index sequential.
    property Strings[Index: Integer]: string read GetString; default;

    // Named constants
    property Consts[Name: string]: string read GetConst;
  end;

  TNameHashedStringList = class(TStringList)
  private
    FNameHash: TStringHash;
    FNameHashValid: Boolean;

    procedure UpdateNameHash;
  protected
    procedure Changed; override;
  public
    destructor Destroy; override;
    function IndexOfName(const Name: string): Integer; override;
  end;

  TComponentMethod = reference to procedure(Component: TComponent);

  // The abstraction of the object tree walker
  TDeepScanner = class
  protected
    FComponentMethod: TComponentMethod;
  public
    constructor Create(ComponentMethod: TComponentMethod);

    procedure DeepScan(Parent: TComponent); virtual; abstract;
  end;

  TDeepScannerClass = class of TDeepScanner;

  TSchemeSourceFunction = function(Target: TObject): string;

  // The function should return True, if it is responsible for the passed parameters
  TTranslateSchemeFunction = function(Target: TObject; const Scheme: string;
    const TranslatedValue: string): Boolean;

// Initializes the global TLang instance Lang
//
// @param LangPath Path where all your language files are located
// @param LangCode Optional. ISO639-1 standard. Initialize with a specific language.
//        If no LangCode is passed:
//        - Language file, which match the system language, is used
//        - If no language file exists for the system language, so English (en) will be used.
procedure InitializeLang(LangPath: string; LangCode: string = '');

function CountFormat(const Conditions: string; Count: Integer): string;

procedure RegisterSchemeSource(TargetClass: TClass; Func: TSchemeSourceFunction);

procedure RegisterSchemeTranslate(TargetClass: TClass; Func: TTranslateSchemeFunction;
  HighPriority: Boolean = False);

procedure RegisterDeepScannerClass(Scanner: TDeepScannerClass);

procedure RegisterRootComponent(Component: TComponent);

procedure RegisterAfterLanguageChangeNotifyEvent(NotifyEvent: TNotifyEvent);
procedure RemoveAfterLanguageChangeNotifyEvent(NotifyEvent: TNotifyEvent);

var
  {**
   * Global TLang instance
   *
   * Initialize it with the procedure InitializeLang.
   * Don't free it manually, it is destroyed by TApplication automatically!
   *}
  Lang: TLang;

implementation

type
  TSchemeEntry = record
    TargetClass: TClass;
    TranslateSchemeFunction: TTranslateSchemeFunction;
  end;
  TSchemeList = TList<TSchemeEntry>;

  TSchemeSourceEntry = record
    TargetClass: TClass;
    SchemeSourceFunction: TSchemeSourceFunction;
  end;
  TSchemeSourceList = TList<TSchemeSourceEntry>;

procedure InitializeLang(LangPath, LangCode: String);
const
  DefaultLangCode: string = 'en';
begin
  Lang.Free;
  Lang := TLang.Create(nil);
  Lang.FLangPath := IncludeTrailingPathDelimiter(LangPath);

  if LangCode = '' then
    LangCode := TLang.GetSystemLangCode;
  if (LangCode <> DefaultLangCode) and not Lang.IsLanguageAvailable(LangCode) then
    LangCode := DefaultLangCode;

  Lang.LangCode := LangCode;
end;

{**
 * Formatiert eine Anzahl
 *
 * Der String mit dem StringIndex muss dem SDF-Format (CSV) entsprechen, d.h.:
 *
 * Jede Anweisung, die ein Leerzeichen [ ], Komma [,] oder Anführungsstriche ["] enthält, wird in
 * Anführungsstriche eingeschlossen. Eventuell in der Anweisung vorkommende Anführungsstriche werden
 * verdoppelt. Jede Anweisung wird mit einem Komma [,] oder einem Leerzeichen [ ] voneinander
 * getrennt.
 *
 * Jede Anweisung beginnt mit einer Operation gefolgt vom Gleichheitszeichen [=]. Vor und nach dem
 * Gleichheitszeichen sollten keine Leerzeichen stehen.
 *
 * Nach dem Gleichheitszeichen folgt der Ausgabestring, der optional einen für die
 * Delphi-Format-Funktion gültigen Format-String (%d, %u oder %x) enthält.
 *
 * Operationen
 * -----------
 * eq[Zahl] = Gleich (Equal)
 * gt[Zahl] = Größer als (Greater then)
 * lt[Zahl] = Kleiner als (Lower then)
 * else     = Sonstiger Fall, wird beim erreichen sofort verwendet, restliche Anweisungen werden
 *            nicht berücksichtigt.
 *
 * Die Anweisungen werden von Links nach Rechts verarbeitet, was als erstes zutrifft, wird
 * verwendet.
 *
 * Beispiele:
 * "eq0=Keine Dateien ausgewählt","eq1=Eine Datei ausgewählt","else=%d Dateien ausgewählt"
 * "lt0=Fehler","eq100=Genau ein Hundert","gt100=Über ein Hundert","lt100=Weniger als ein Hundert"
 *}
function CountFormat(const Conditions: string; Count: Integer): string;
var
  ConditionList: TStringList;
  ConditionIndex: Integer;

  {**
   * Determines, whether the passed condition match the count
   *}
  function ConditionMatch(Condition: string): Boolean;
  const
    // Special operators are handled before basics
    OPElse = 'else';
    // Basic operators are fixed length
    BasicOPLength = 2;
    OPEqual = 'eq';
    OPGreaterThen = 'gt';
    OPLowerThen = 'lt';
  var
    Operation: string;
    CountString: string;
    MatchCount: Integer;
  begin
    Condition := Trim(LowerCase(Condition));
    if (Condition = '') or (Length(Condition) < 3) then
      Exit(False);
    if Condition = OPElse then
      Exit(True);
    Operation := Copy(Condition, 1, BasicOPLength);
    CountString := Copy(Condition, BasicOPLength + 1, Length(Condition) - BasicOPLength);
    if not TryStrToInt(CountString, MatchCount) then
      Exit(False);

    Result := ((Operation = OPEqual) and (Count = MatchCount)) or
      ((Operation = OPLowerThen) and (Count < MatchCount)) or
      ((Operation = OPGreaterThen) and (Count > MatchCount));
  end;

  {**
   * Determines, whether the passed string contains valid format string for use the count with
   * Delphi's Format function.
   *}
  function HasValidFormatString(const Output: string): Boolean;
  begin
    {**
     * The percent sign must be there in each case, so we do a short check
     *}
    if Pos('%', Output) = 0 then
      Exit(False);

    Result := TRegEx.IsMatch(Output, '%[\-\d\.:]*[dux]', [roIgnoreCase]);
  end;

begin
  Result := '';

  ConditionList := TStringList.Create;
  try
    ConditionList.CommaText := Conditions;
    {**
     * Search for a matching condition
     *}
    for ConditionIndex := 0 to ConditionList.Count - 1 do
      if ConditionMatch(ConditionList.Names[ConditionIndex]) then
      begin
        Result := ConditionList.ValueFromIndex[ConditionIndex];
        Break;
      end;
    {**
     * Pass the count to Delphi's Format, if possible
     *}
    if (Result <> '') and HasValidFormatString(Result) then
      Result := Format(Result, [Count]);
  finally
    ConditionList.Free;
  end;
end;

var
  SchemeSourceRegistry: TSchemeSourceList;

procedure RegisterSchemeSource(TargetClass: TClass; Func: TSchemeSourceFunction);
var
  Entry: TSchemeSourceEntry;
begin
  if not Assigned(SchemeSourceRegistry) then
    SchemeSourceRegistry := TSchemeSourceList.Create;

  Entry.TargetClass := TargetClass;
  Entry.SchemeSourceFunction := Func;

  SchemeSourceRegistry.Add(Entry);
end;

var
  SchemeTranslateRegistry: TSchemeList;

procedure RegisterSchemeTranslate(TargetClass: TClass; Func: TTranslateSchemeFunction;
  HighPriority: Boolean);
var
  Entry: TSchemeEntry;
begin
  if not Assigned(SchemeTranslateRegistry) then
    SchemeTranslateRegistry := TSchemeList.Create;

  Entry.TargetClass := TargetClass;
  Entry.TranslateSchemeFunction := Func;

  if HighPriority then
    SchemeTranslateRegistry.Insert(0, Entry)
  else
    SchemeTranslateRegistry.Add(Entry);
end;

var
  DeepScannerClass: TDeepScannerClass;

procedure RegisterDeepScannerClass(Scanner: TDeepScannerClass);
begin
  DeepScannerClass := Scanner;
end;

var
  RootComponent: TComponent;

procedure RegisterRootComponent(Component: TComponent);
begin
  RootComponent := Component;
end;

var
  AfterLanguageChangeNotifyList: TList<TNotifyEvent>;

procedure RegisterAfterLanguageChangeNotifyEvent(NotifyEvent: TNotifyEvent);
begin
  if not Assigned(AfterLanguageChangeNotifyList) then
    AfterLanguageChangeNotifyList := TList<TNotifyEvent>.Create;
  AfterLanguageChangeNotifyList.Add(NotifyEvent);
end;

procedure RemoveAfterLanguageChangeNotifyEvent(NotifyEvent: TNotifyEvent);
begin
  if Assigned(AfterLanguageChangeNotifyList) then
    AfterLanguageChangeNotifyList.Remove(NotifyEvent);
end;

{ TLang }

constructor TLang.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FStrings := TStringList.Create;
  FMessages := TStringList.Create;
  FConsts := TNameHashedStringList.Create;
  FNumberPCRE := TRegEx.Create('(?(?=\\\d)(?P<Escaped>\\(?P<EscapedNumber>\d+))|(?P<Number>\d+))',
    [roCompiled]);
end;

destructor TLang.Destroy;
begin
  FStrings.Free;
  FMessages.Free;
  FConsts.Free;

  inherited Destroy;
end;

procedure TLang.FillAvailableLanguages(Target: TStrings; out SelIndex: Integer);
var
  Language: TLangEntry;
  DisplayText: string;
  ItemIndex: Integer;
begin
  Target.Clear;
  Target.BeginUpdate;
  try
    SelIndex := -1;
    for Language in GetAvailableLanguages do
    begin
      if Language.LocalName <> Language.InternationalName then
        DisplayText := Format('%s (%s)', [Language.LocalName, Language.InternationalName])
      else
        DisplayText := Language.LocalName;
      ItemIndex := Target.Add(DisplayText);
      if Language.Code = LangCode then
        SelIndex := ItemIndex;
    end;
  finally
    Target.EndUpdate;
  end;
end;

function TLang.CountFormat(StringIndex, Count: Integer): string;
begin
  Result := Localization.CountFormat(Strings[StringIndex], Count);
end;

// Retrieve a array, that contain main information of available languages
function TLang.GetAvailableLanguages: TLangEntries;
var
  SR: TSearchRec;
  LangINI: TMemIniFile;
  LangINIFileName, LangCode, LangLocalName, LangIntlName: string;
  Index: Integer;
begin
  if FindFirst(GetLangFileName('*'), 0, SR) <> 0 then
    Exit;

  try
    repeat
      SR.Name := LangPath + SR.Name;
      LangINIFileName := ExtractFileName(SR.Name);

      LangINI := TMemIniFile.Create(SR.Name, TEncoding.UTF8);
      try
        LangCode := LangINI.ReadString(InfoSection, 'LangCode', '');
        LangLocalName := LangINI.ReadString(InfoSection, 'LocalName', '');
        LangIntlName := LangINI.ReadString(InfoSection, 'InternationalName', '');
      finally
        LangINI.Free;
      end;

      {**
       * Finally we can add one language to our result array
       *}
      Index := Length(Result);
      SetLength(Result, Index + 1);
      Result[Index].Code := LangCode;
      Result[Index].InternationalName := LangIntlName;
      Result[Index].LocalName := LangLocalName;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function TLang.GetConst(Name: string): string;
begin
  Result := FConsts.Values[Name];
end;

function TLang.GetLangFileName(LangCode: string; IncludePath: Boolean): string;
begin
  if IncludePath then
    Result := FLangPath
  else
    Result := '';
  Result := Result + Format(LangFileNameFormat, [LangCode]);
end;

function TLang.GetString(Index: Integer): string;
begin
  if Index >= FMessagesOffset then
    Result := FMessages[Index - FMessagesOffset]
  else
    Result := FStrings[Index];
end;

{**
 * Determines the system language code ISO 639-1
 *}
class function TLang.GetSystemLangCode: string;
begin
{$IFDEF MSWINDOWS}
  case GetUserDefaultLangID and $00FF of
    LANG_GERMAN:
      Result := 'de';
    LANG_FRENCH:
      Result := 'fr';
    LANG_GREEK:
      Result := 'el';
    LANG_LITHUANIAN:
      Result := 'lt';
    LANG_NORWEGIAN:
      Result := 'no';
    LANG_POLISH:
      Result := 'pl';
    LANG_PORTUGUESE:
      Result := 'pt';
    LANG_RUSSIAN:
      Result := 'ru';
    LANG_SPANISH:
      Result := 'es';
    LANG_SWEDISH:
      Result := 'sv';
    LANG_TURKISH:
      Result := 'tr';
    LANG_FINNISH:
      Result := 'fi';
    LANG_DUTCH:
      Result := 'nl';
    LANG_ITALIAN:
      Result := 'it';
    LANG_DANISH:
      Result := 'da';
    LANG_CHINESE:
      Result := 'zh';
    else
      Result := 'en';
  end;
{$ELSE}
  var LocaleSvc: IFMXLocaleService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXLocaleService, LocaleSvc) then
    Result := LocaleSvc.GetCurrentLangID;
{$ENDIF}
end;

function TLang.IsLanguageAvailable(LangCode: string): Boolean;
begin
  Result := FileExists(GetLangFileName(LangCode));
end;

procedure TLang.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opInsert then
    Translate(AComponent);
end;

procedure TLang.ReadyForTranslateEvent(Sender: TObject);
begin
  Translate(TComponent(Sender));
  (TComponent(Sender) as ITranslate).OnReadyForTranslate(nil);
end;

{**
 * Liest eine Sprache ein
 *}
procedure TLang.SetLangCode(NewLangCode: string);
var
  SectionList: TStringList;
  LangItem: string;
  LangVarPCRE: TRegEx;
  INI: TMemIniFile;
  cc, InsertIndex: Integer;

  procedure Prepare(List: TStringList);
  var
    cc: Integer;
    Match: TMatch;
  begin
    for cc := 0 to List.Count - 1 do
    begin
      LangItem := List[cc];
      {**
       * Die Stringfolge '\n' durch echten Umbruch ersetzen
       *}
      LangItem := StringReplace(LangItem, '\n', sLineBreak, [rfReplaceAll]);
      {**
       * Sprachkonstanten ersetzen
       *
       * Wenn in einem String ein Wort von Dollarzeichen umschlossen wird, so wird davon
       * ausgegangen, dass es sich um eine Sprachkonstante handelt.
       *
       * Beispiel:
       * [Consts]
       * TODAY=Heute
       * DAY=Tag
       *
       * [Strings]
       * 0=$TODAY$ ist ein guter $DAY$
       *
       * Nach dem Durchlauf hat Self.Strings[0] den Wert:
       * 'Heute ist ein guter Tag'
       *}
      if Pos('$', LangItem) > 0 then
      begin
        Match := LangVarPCRE.Match(LangItem);

        while Match.Success do
        begin
          LangItem := StringReplace(LangItem, Match.Groups[0].Value, Consts[Match.Groups[1].Value],
            [rfReplaceAll]);
          Match := Match.NextMatch;
        end;
      end;
      {**
       * Schlussendlich wird der präparierte String wieder zugewiesen
       *}
      List[cc] := LangItem;
    end;
  end;

  {**
   * Räumt eine Liste auf, indem es alle leeren Strings entfernt
   *}
  procedure CleanList(List: TStringList);
  var
    cc: Integer;
  begin
    for cc := List.Count - 1 downto 0 do
      if Trim(List[cc]) = '' then
        List.Delete(cc);
  end;

begin
  if (FLangCode = NewLangCode) or not IsLanguageAvailable(NewLangCode) then
    Exit;

  FLangCode := NewLangCode;

  FStrings.Clear;
  FMessages.Clear;
  SectionList := TStringList.Create;
  INI := TMemIniFile.Create(GetLangFileName(LangCode), TEncoding.UTF8);
  // Regulären Ausdruck für das Ersetzen von Sprachvariablen initiieren
  LangVarPCRE := TRegEx.Create('\$([\w\d\-]+)\$', [roIgnoreCase, roCompiled]);
  try
    FLangInternationalName := INI.ReadString(InfoSection, 'InternationalName', '');
    FLangLocalName := INI.ReadString(InfoSection, 'LocalName', LangCode);
    {**
     * Read constants
     *}
    INI.ReadSectionValues(ConstsSection, FConsts);
    {**
     * Read strings
     *}
    INI.ReadSection(StringsSection, SectionList);
    CleanList(SectionList);
    for cc := 0 to SectionList.Count - 1 do
      if TryStrToInt(SectionList[cc], InsertIndex) then
        FStrings.Insert(InsertIndex, INI.ReadString(StringsSection, SectionList[cc], ''));
    {**
     * Read messages
     *}
    SectionList.Clear;
    INI.ReadSection(MessagesSection, SectionList);
    CleanList(SectionList);
    FMessagesOffset := StrToInt(SectionList[0]);
    for cc := 0 to SectionList.Count - 1 do
      if TryStrToInt(SectionList[cc], InsertIndex) then
        FMessages.Insert(InsertIndex - FMessagesOffset,
          INI.ReadString(MessagesSection, SectionList[cc], ''));
    {**
     * Replace used constants in strings and messages
     *}
    Prepare(FStrings);
    Prepare(FMessages);

    FInitialized := True;

    if Assigned(AfterLanguageChangeNotifyList) then
      for cc := 0 to AfterLanguageChangeNotifyList.Count - 1 do
        AfterLanguageChangeNotifyList[cc](Self);

    TranslateApplication;
  finally
    INI.Free;
    SectionList.Free;
  end;
end;

{**
 * Liefert die Referenz, vom Objekt welches die ITranslate-Schnittstelle implementiert, falls...
 *
 * - sie tatsächlich die Schnittstelle implementiert
 * - falls ITranslate.IsReadyFroTranslate TRUE liefert
 *
 * gleichzeitig setzt es das OnReadyForTranslate-Event, wenn ITranslate.IsReadyFroTranslate
 * FALSE liefert.
 *
 * Sonst wird nil geliefert.
 *}
function TLang.GetTranslateObject(Component: TComponent): ITranslate;
begin
  Result := nil;
  if not Supports(Component, ITranslate) then
    Exit;
  Result := Component as ITranslate;
  if not Result.IsReadyForTranslate then
  begin
    Result.OnReadyForTranslate(ReadyForTranslateEvent);
    Result := nil;
  end;
end;

procedure TLang.TranslateComponent(Component: TComponent);
var
  Current: TComponent;

  {**
   * Übersetzt die aktuelle Komponente in Current nach einem Schema
   *
   * Ein Schema kann mehrere Eigenschaften in einem String für die Übersetzung definieren.
   *
   * Beispiel: '"Caption=13..." "Hint=14"'
   *}
  procedure TranslateScheme(Scheme: string);
  var
    IncomingSchemes: TStringList;
    Replacement: string;
    cc: Integer;
    SchemeEntry: TSchemeEntry;
    MatchingClasses: TSchemeList;
  begin
    if Scheme = '' then
      Exit;

    IncomingSchemes := nil;
    MatchingClasses := TSchemeList.Create;
    try
      for SchemeEntry in SchemeTranslateRegistry do
        if Current is SchemeEntry.TargetClass then
          MatchingClasses.Add(SchemeEntry);

      if MatchingClasses.Count = 0 then
        Exit;

      IncomingSchemes := TStringList.Create;
      IncomingSchemes.CommaText := Scheme;
      for cc := 0 to IncomingSchemes.Count - 1 do
      begin
        Scheme := LowerCase(IncomingSchemes.Names[cc]);
        Replacement := Translate(IncomingSchemes.ValueFromIndex[cc]);

        for SchemeEntry in MatchingClasses do
          if SchemeEntry.TranslateSchemeFunction(Current, Scheme, Replacement) then
            Break;
      end;
    finally
      IncomingSchemes.Free;
      MatchingClasses.Free;
    end;
  end;

var
  TranslateObject: ITranslate;
  Entry: TSchemeSourceEntry;
  SchemeSource: string;
begin
  if not Assigned(SchemeSourceRegistry) then
    Exit;

  for Entry in SchemeSourceRegistry do
    if Component is Entry.TargetClass then
    begin
      Current := Component;
      SchemeSource := Entry.SchemeSourceFunction(Current);
      TranslateScheme(SchemeSource);
      Break;
    end;

  TranslateObject := GetTranslateObject(Component);
  if Assigned(TranslateObject) then
    TranslateObject.Translate;
end;

{**
 * Übersetzt rekursiv alle Unterobjekte von ComponentHolder
 *}
procedure TLang.Translate(ComponentHolder: TComponent);
var
  DeepScanner: TDeepScanner;
begin
  {**
   * Das hier bedeutet, dass das Objekt noch nicht bereit für die Übersetzung ist, wenn das
   * der Fall ist...so wird die Prozedur verlassen...doch in GetTranslateObject() wird der
   * Event-Handler für OnReadyForTranslate gesetzt, sodass per Konzeption diese Methode wieder
   * aufgerufen wird, sobald es für die Übersetzung bereit ist.
   *}
  if Supports(ComponentHolder, ITranslate) and (GetTranslateObject(ComponentHolder) = nil) then
    Exit;

  if not FInitialized then
    Exit;

  TranslateComponent(ComponentHolder);

  if Assigned(DeepScannerClass) then
  begin
    DeepScanner := DeepScannerClass.Create(TranslateComponent);
    try
      DeepScanner.DeepScan(ComponentHolder);
    finally
      DeepScanner.Free;
    end;
  end;
end;

// Translates an incoming string
//
// All contained numbers in the incoming string are replaced with the corresponding string
// from the language file
//
// Examples:
// '23...' --> 'Settings...'
// '22 "23"' --> 'Click on "Settings"'
//
// To let a number as it is in the incoming string, you can escape it with a backslash '\'
//
// Example:
// '\1. 24' --> '1. Title'
function TLang.Translate(Incoming: string): string;
var
  Index, Offset: Integer;

  function ReplaceCapture(Incoming, Replace: string; GroupOffset, GroupLength: Integer): string;
  var
    FirstPos, LastPos: Integer;
  begin
    FirstPos := GroupOffset;
    LastPos := FirstPos + GroupLength;
    Result := Copy(Incoming, 1, FirstPos - 1) + Replace + Copy(Incoming, LastPos);
    Offset := FirstPos + Length(Replace);
  end;

var
  Match: TMatch;
  Group: TGroup;

  function MatchGroup(const GroupName: string): Boolean;
  begin
    Group := Match.Groups['Number'];
    Result := Group.Success;
  end;

begin
  // The fastest way: if the string contains only a number
  if TryStrToInt(Trim(Incoming), Index) then
    Exit(GetString(Index));

  // The slower variant: A regex is performed to match any numbers and replace them with the
  // corresponding string from the language file
  Match := FNumberPCRE.Match(Incoming);
  if Match.Success then
  begin
    Result := Incoming;
    Offset := 1;
    repeat
      if MatchGroup('Number') then
        Result := ReplaceCapture(Result, GetString(StrToInt(Group.Value)), Group.Index, Group.Length)
      else if MatchGroup('Escaped') then
        Result := ReplaceCapture(Result, Group.Value, Group.Index, Group.Length);

      Match := FNumberPCRE.Match(Result, Offset);
    until not Match.Success;
  end;
end;

{**
 * Übersetzt die gesamte Anwendung
 *
 * Erreicht werden sämtliche Komponenten, die über den Owner-Mechanismus von TComponent mit der
 * Application (egal auf welcher Ebene) verbunden sind.
 *
 * Diese Methode wird auch beim setzen der LangCode-Eigenschaft aufgerufen.
 *}
procedure TLang.TranslateApplication;
begin
  Translate(RootComponent);
end;

{** TNameHashedStringList **}

destructor TNameHashedStringList.Destroy;
begin
  FNameHash.Free;

  inherited Destroy;
end;

procedure TNameHashedStringList.Changed;
begin
  inherited Changed;

  FNameHashValid := False;
end;

function TNameHashedStringList.IndexOfName(const Name: string): Integer;
begin
  UpdateNameHash;
  if CaseSensitive then
    Result := FNameHash.ValueOf(Name)
  else
    Result := FNameHash.ValueOf(UpperCase(Name));
end;

procedure TNameHashedStringList.UpdateNameHash;
var
  cc: Integer;
  Key: string;
  ToUpperCase: Boolean;
begin
  if FNameHashValid then
    Exit;

  if Assigned(FNameHash) then
    FNameHash.Clear
  else
    FNameHash := TStringHash.Create;

  ToUpperCase := not CaseSensitive;

  for cc := 0 to Count - 1 do
  begin
    Key := Names[cc];
    if Key <> '' then
    begin
      if ToUpperCase then
        Key := UpperCase(Key);
      FNameHash.Add(Key, cc);
    end;
  end;

  FNameHashValid := True;
end;

{ TDeepScanner }

constructor TDeepScanner.Create(ComponentMethod: TComponentMethod);
begin
  FComponentMethod := ComponentMethod;
end;

initialization

finalization
  FreeAndNil(Lang);
  FreeAndNil(SchemeTranslateRegistry);
  FreeAndNil(SchemeSourceRegistry);
  FreeAndNil(AfterLanguageChangeNotifyList);

end.
