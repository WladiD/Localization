unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  Localization;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    LangCombo: TComboBox;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure LangComboChange(Sender: TObject);
  private
    FAvailableLanguages: TLangEntries;
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
    ComboChangeEvent: TNotifyEvent;
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
//  Lang.TranslateApplication;

  FAvailableLanguages := Lang.GetAvailableLanguages;
  FillLangCombo;
end;

procedure TMainForm.LangComboChange(Sender: TObject);
var
  SelIndex: Integer;
begin
  SelIndex := LangCombo.ItemIndex;
  Lang.LangCode := FAvailableLanguages[SelIndex].Code;
end;

end.
