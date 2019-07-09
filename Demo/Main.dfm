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
