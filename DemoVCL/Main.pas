unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.UITypes,
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
    GroupBox1: TGroupBox;
    MsgDlgButtonsGroupBox: TGroupBox;
    MsgDlgTypeGroupBox: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    ShowMessageButton: TButton;
    CheckBox12: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure LangComboChange(Sender: TObject);
    procedure DummyActionExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure ShowMessageButtonClick(Sender: TObject);
  private
    FAvailableLanguages: TLangEntries;

  // ITranslate-Interface
  private
    function IsReadyForTranslate: Boolean;
    procedure OnReadyForTranslate(NotifyEvent: TNotifyEvent);
    procedure Translate;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);

  procedure FillLangCombo;
  var
    SelIndex: Integer;
  begin
    Lang.FillAvailableLanguages(LangCombo.Items, SelIndex);
    LangCombo.ItemIndex := SelIndex;
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

procedure TMainForm.ShowMessageButtonClick(Sender: TObject);

  function GetMsgDlgType: TMsgDlgType;
  var
    cc: Integer;
    RB: TRadioButton;
  begin
    for cc := 0 to MsgDlgTypeGroupBox.ControlCount - 1 do
      if MsgDlgTypeGroupBox.Controls[cc] is TRadioButton then
      begin
        RB := TRadioButton(MsgDlgTypeGroupBox.Controls[cc]);
        if RB.Checked then
          Exit(TMsgDlgType(RB.Tag));
      end;

    Result := mtInformation;
  end;

  function GetMsgDlgButtons: TMsgDlgButtons;
  var
    cc: Integer;
    CB: TCheckBox;
  begin
    Result := [];

    for cc := 0 to MsgDlgButtonsGroupBox.ControlCount - 1 do
      if MsgDlgButtonsGroupBox.Controls[cc] is TCheckBox then
      begin
        CB := TCheckBox(MsgDlgButtonsGroupBox.Controls[cc]);
        if CB.Checked then
          Include(Result, TMsgDlgBtn(CB.Tag));
      end;
  end;

begin
  MessageDlg(Lang[100000], GetMsgDlgType, GetMsgDlgButtons, 0);
end;

end.
