unit Main;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Layouts,

  Localization;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    Layout1: TLayout;
    Label2: TLabel;
    LangCombo: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure LangComboChange(Sender: TObject);
  private

  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
var
  SelIndex: Integer;
  PrevChangeEvent: TNotifyEvent;
begin
  InitializeLang(IncludeTrailingPathDelimiter(TPath.GetLibraryPath));

  PrevChangeEvent := LangCombo.OnChange;
  try
    LangCombo.OnChange := nil;
    Lang.FillAvailableLanguages(LangCombo.Items, SelIndex);
    LangCombo.ItemIndex := SelIndex;
  finally
    LangCombo.OnChange := PrevChangeEvent;
  end;
end;

procedure TMainForm.LangComboChange(Sender: TObject);
begin
  Lang.LangCode := Lang.GetAvailableLanguages[LangCombo.ItemIndex].Code;
end;

end.
