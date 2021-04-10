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
  FMX.Platform,

  Localization;

type
  TMainForm = class(TForm, ITranslate)
    Label1: TLabel;
    Layout1: TLayout;
    Label2: TLabel;
    LangCombo: TComboBox;
    ShowMessageButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure LangComboChange(Sender: TObject);
    procedure ShowMessageButtonClick(Sender: TObject);

  // ITranslate-Interface
  private
    function IsReadyForTranslate: Boolean;
    procedure OnReadyForTranslate(NotifyEvent: TNotifyEvent);
    procedure Translate;
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
{$IFDEF MSWINDOWS}
  // On windows the lang files should be in this example in the same path as the exe is
  InitializeLang(IncludeTrailingPathDelimiter(TPath.GetLibraryPath));
{$ELSE}
  InitializeLang(IncludeTrailingPathDelimiter(TPath.GetDocumentsPath));
{$ENDIF}

  PrevChangeEvent := LangCombo.OnChange;
  try
    LangCombo.OnChange := nil;
    Lang.FillAvailableLanguages(LangCombo.Items, SelIndex);
    LangCombo.ItemIndex := SelIndex;
  finally
    LangCombo.OnChange := PrevChangeEvent;
  end;
end;

// Method for ITranslate.IsReadyForTranslate
function TMainForm.IsReadyForTranslate: Boolean;
begin
  Result := True; // True means, we are ready for immediate translate
end;

// Method for ITranslate.OnReadyForTranslate
procedure TMainForm.OnReadyForTranslate(NotifyEvent: TNotifyEvent);
begin
  // If IsReadyForTranslate would return False, then this method would be called and we must
  // save and call the passed NotifyEvent at a time point when it become valid.
end;

// Method for ITranslate.Translate
procedure TMainForm.Translate;
begin
  Caption := Lang[0];
end;

procedure TMainForm.LangComboChange(Sender: TObject);
begin
  Lang.LangCode := Lang.GetAvailableLanguages[LangCombo.ItemIndex].Code;
end;

procedure TMainForm.ShowMessageButtonClick(Sender: TObject);
var
  DialogService: IFMXDialogServiceAsync;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXDialogServiceAsync, DialogService) then
    DialogService.MessageDialogAsync(Lang.Strings[100000],
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0, nil);

//  ShowMessage(Lang.Strings[100000]);
end;

end.
