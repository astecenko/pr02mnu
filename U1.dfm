object FormZapuskatr1: TFormZapuskatr1
  Tag = -1
  Left = 368
  Top = 73
  Anchors = [akTop, akRight]
  BorderStyle = bsDialog
  Caption = 'FormZapuskatr1'
  ClientHeight = 453
  ClientWidth = 367
  Color = clInfoBk
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    367
    453)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 366
    Height = 61
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Color = clInfoBk
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object lbl2: TLabel
    Left = 65
    Top = 415
    Width = 89
    Height = 16
    Cursor = crNoDrop
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1093#1086#1076' - ESC'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = lbl2Click
  end
  object lbl3: TLabel
    Left = 205
    Top = 415
    Width = 88
    Height = 16
    Cursor = crHelp
    Anchors = [akRight, akBottom]
    Caption = #1055#1086#1084#1086#1097#1100' - F1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = lbl3Click
  end
  object lst1: TListBox
    Left = 0
    Top = 62
    Width = 366
    Height = 352
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Color = clBtnFace
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemHeight = 32
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnClick = lst1Click
    OnDblClick = lst1DblClick
    OnKeyDown = lst1KeyDown
    OnKeyPress = lst1KeyPress
  end
  object stat1: TStatusBar
    Left = 0
    Top = 434
    Width = 367
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
end
