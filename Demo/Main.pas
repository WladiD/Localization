unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.Menus,

  Localization;

type
  TMainForm = class(TForm, ITranslate)
    Label1: TLabel;
    LangCombo: TComboBox;
    Edit1: TEdit;
    ActionList: TActionList;
    MainMenu: TMainMenu;
    FileMenuItem: TMenuItem;
    EditMenuItem: TMenuItem;
    SearchMenuItem: TMenuItem;
    NewFileAction: TAction;
    OpenFileAction: TAction;
    SaveFileAction: TAction;
    SaveAsFileAction: TAction;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    CloseAction: TAction;
    N1: TMenuItem;
    Exit1: TMenuItem;
    CutEditActionAction: TAction;
    CopyEditAction: TAction;
    PasteEditAction: TAction;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure LangComboChange(Sender: TObject);
    procedure DummyActionExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
  private
    FAvailableLanguages: TLangEntries;

  // ITranslate-Interface
  private
    function IsReadyForTranslate: Boolean;
    procedure OnReadyForTranslate(NotifyEvent: TNotifyEvent);
    procedure Translate;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);

  procedure FillLangCombo;
  var
    Language: TLangEntry;
    DisplayText: string;
    ItemIndex, SelIndex: Integer;
  begin
    LangCombo.Items.Clear;
    LangCombo.Items.BeginUpdate;
    try
      SelIndex := -1;
      for Language in FAvailableLanguages do
      begin
        if Language.LocalName <> Language.InternationalName then
          DisplayText := Format('%s (%s)', [Language.LocalName, Language.InternationalName])
        else
          DisplayText := Language.LocalName;
        ItemIndex := LangCombo.Items.Add(DisplayText);
        if Language.Code = Lang.LangCode then
          SelIndex := ItemIndex;
      end;

      if SelIndex >= 0 then
        LangCombo.ItemIndex := SelIndex;
    finally
      LangCombo.Items.EndUpdate;
    end;
  end;

begin
  InitializeLang(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Locals');
  FAvailableLanguages := Lang.GetAvailableLanguages;
  FillLangCombo;
end;

// Method for ITranslate.IsReadyForTranslate
function TMainForm.IsReadyForTranslate: Boolean;
begin
  // True means, we are ready for immediate translate
  Result := True;
end;

// Method for ITranslate.OnReadyForTranslate
procedure TMainForm.OnReadyForTranslate(NotifyEvent: TNotifyEvent);
begin
  // If IsReadyForTranslate would return False, then this method would be called and we must
  // save and call the passed NotifyEvent at a time point when it become valid.
end;

procedure TMainForm.Translate;
begin
  // TMenuItem has no HelpKeyword property, which we can misuse, so we bind manually here...
  FileMenuItem.Caption := Lang[3];
  EditMenuItem.Caption := Lang[4];
  SearchMenuItem.Caption := Lang[5];
end;

procedure TMainForm.LangComboChange(Sender: TObject);
var
  SelIndex: Integer;
begin
  SelIndex := LangCombo.ItemIndex;
  Lang.LangCode := FAvailableLanguages[SelIndex].Code;
end;

procedure TMainForm.CloseActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.DummyActionExecute(Sender: TObject);
begin
  //
end;

end.
