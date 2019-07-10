object MainForm: TMainForm
  Left = 0
  Top = 0
  HelpType = htKeyword
  HelpKeyword = '"Caption=0"'
  Caption = 'This is the Demo project for the Localization Delphi unit'
  ClientHeight = 425
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    728
    425)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 452
    Top = 16
    Width = 112
    Height = 13
    HelpType = htKeyword
    HelpKeyword = '"Caption=1:"'
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'Choose your language:'
  end
  object LangCombo: TComboBox
    Left = 570
    Top = 13
    Width = 145
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    TabOrder = 0
    OnChange = LangComboChange
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 369
    Height = 27
    HelpType = htKeyword
    HelpKeyword = '"TextHint=2"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TextHint = 'Your search query'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 56
    Width = 369
    Height = 201
    Caption = 'MessageDlg(...)'
    TabOrder = 2
    object MsgDlgButtonsGroupBox: TGroupBox
      Left = 167
      Top = 16
      Width = 185
      Height = 142
      Caption = 'TMsgDlgButtons'
      TabOrder = 0
      object CheckBox1: TCheckBox
        Left = 9
        Top = 16
        Width = 80
        Height = 17
        Caption = 'mbYes'
        TabOrder = 0
      end
      object CheckBox2: TCheckBox
        Tag = 1
        Left = 95
        Top = 16
        Width = 80
        Height = 17
        Caption = 'mbNo'
        TabOrder = 1
      end
      object CheckBox3: TCheckBox
        Tag = 2
        Left = 9
        Top = 36
        Width = 80
        Height = 17
        Caption = 'mbOK'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object CheckBox4: TCheckBox
        Tag = 3
        Left = 95
        Top = 36
        Width = 80
        Height = 17
        Caption = 'mbCancel'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object CheckBox5: TCheckBox
        Tag = 4
        Left = 9
        Top = 56
        Width = 80
        Height = 17
        Caption = 'mbAbort'
        TabOrder = 4
      end
      object CheckBox6: TCheckBox
        Tag = 5
        Left = 95
        Top = 56
        Width = 80
        Height = 17
        Caption = 'mbRetry'
        TabOrder = 5
      end
      object CheckBox7: TCheckBox
        Tag = 6
        Left = 9
        Top = 76
        Width = 80
        Height = 17
        Caption = 'mbIgnore'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object CheckBox8: TCheckBox
        Tag = 7
        Left = 95
        Top = 76
        Width = 80
        Height = 17
        Caption = 'mbAll'
        TabOrder = 7
      end
      object CheckBox9: TCheckBox
        Tag = 8
        Left = 9
        Top = 96
        Width = 80
        Height = 17
        Caption = 'mbNoToAll'
        TabOrder = 8
      end
      object CheckBox10: TCheckBox
        Tag = 9
        Left = 95
        Top = 96
        Width = 80
        Height = 17
        Caption = 'mbYesToAll'
        TabOrder = 9
      end
      object CheckBox11: TCheckBox
        Tag = 11
        Left = 95
        Top = 117
        Width = 80
        Height = 17
        Caption = 'mbClose'
        TabOrder = 10
      end
      object CheckBox12: TCheckBox
        Tag = 10
        Left = 9
        Top = 117
        Width = 80
        Height = 17
        Caption = 'mbHelp'
        TabOrder = 11
      end
    end
    object MsgDlgTypeGroupBox: TGroupBox
      Left = 16
      Top = 16
      Width = 137
      Height = 105
      Caption = 'TMsgDlgType'
      TabOrder = 1
      object RadioButton1: TRadioButton
        Left = 9
        Top = 16
        Width = 113
        Height = 17
        Caption = 'mtWarning'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object RadioButton2: TRadioButton
        Tag = 1
        Left = 9
        Top = 36
        Width = 113
        Height = 17
        Caption = 'mtError'
        TabOrder = 1
      end
      object RadioButton3: TRadioButton
        Tag = 2
        Left = 9
        Top = 56
        Width = 113
        Height = 17
        Caption = 'mtInformation '
        TabOrder = 2
      end
      object RadioButton4: TRadioButton
        Tag = 3
        Left = 9
        Top = 76
        Width = 113
        Height = 17
        Caption = 'mtConfirmation '
        TabOrder = 3
      end
    end
    object ShowMessageButton: TButton
      Left = 86
      Top = 164
      Width = 170
      Height = 25
      HelpType = htKeyword
      HelpKeyword = 'Caption=14'
      Caption = 'Show message box'
      TabOrder = 2
      OnClick = ShowMessageButtonClick
    end
  end
  object ActionList: TActionList
    Left = 536
    Top = 320
    object NewFileAction: TAction
      Category = 'File'
      Caption = 'New'
      HelpKeyword = 'Caption=6'
      ShortCut = 16462
      OnExecute = DummyActionExecute
    end
    object OpenFileAction: TAction
      Category = 'File'
      Caption = 'Open'
      HelpKeyword = '"Caption=7..."'
      ShortCut = 16463
      OnExecute = DummyActionExecute
    end
    object SaveFileAction: TAction
      Category = 'File'
      Caption = 'Save'
      HelpKeyword = 'Caption=8'
      ShortCut = 16467
      OnExecute = DummyActionExecute
    end
    object SaveAsFileAction: TAction
      Category = 'File'
      Caption = 'Save as...'
      HelpKeyword = '"Caption=9..."'
      OnExecute = DummyActionExecute
    end
    object CloseAction: TAction
      Category = 'File'
      Caption = 'Exit'
      HelpKeyword = 'Caption=10'
      OnExecute = CloseActionExecute
    end
    object CutEditActionAction: TAction
      Category = 'Edit'
      Caption = 'Cut'
      HelpKeyword = 'Caption=11'
      ShortCut = 16472
      OnExecute = DummyActionExecute
    end
    object CopyEditAction: TAction
      Category = 'Edit'
      Caption = 'Copy'
      HelpKeyword = 'Caption=12'
      ShortCut = 16451
      OnExecute = DummyActionExecute
    end
    object PasteEditAction: TAction
      Category = 'Edit'
      Caption = 'Paste'
      HelpKeyword = 'Caption=13'
      ShortCut = 16470
      OnExecute = DummyActionExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 592
    Top = 320
    object FileMenuItem: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Action = NewFileAction
      end
      object Open1: TMenuItem
        Action = OpenFileAction
      end
      object Save1: TMenuItem
        Action = SaveFileAction
      end
      object Saveas1: TMenuItem
        Action = SaveAsFileAction
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = CloseAction
      end
    end
    object EditMenuItem: TMenuItem
      Caption = 'Edit'
      object Cut1: TMenuItem
        Action = CutEditActionAction
      end
      object Copy1: TMenuItem
        Action = CopyEditAction
      end
      object Paste1: TMenuItem
        Action = PasteEditAction
      end
    end
    object SearchMenuItem: TMenuItem
      Caption = 'Search'
    end
  end
end
