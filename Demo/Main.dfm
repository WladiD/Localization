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
end
