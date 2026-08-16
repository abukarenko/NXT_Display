object Form5: TForm5
  Left = 601
  Top = 188
  BorderStyle = bsSingle
  Caption = 'MicroEditor'
  ClientHeight = 603
  ClientWidth = 676
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 200
    Top = 0
    Width = 476
    Height = 603
    Center = True
    Proportional = True
    Stretch = True
  end
  object RichEdit1: TRichEdit
    Left = 200
    Top = 0
    Width = 476
    Height = 603
    Align = alRight
    Lines.Strings = (
      'RichEdit1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 197
    Height = 603
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 1
    object Label2: TLabel
      Left = 4
      Top = 128
      Width = 21
      Height = 13
      Caption = 'Files'
    end
    object Label1: TLabel
      Left = 4
      Top = 48
      Width = 29
      Height = 13
      Caption = 'Folder'
    end
    object ListBox1: TListBox
      Left = 8
      Top = 144
      Width = 188
      Height = 458
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBox1Click
      OnMouseDown = ListBox1MouseDown
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 64
      Width = 185
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = 'ComboBox1'
      OnChange = ComboBox1Change
    end
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Rescan'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 104
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Upload'
      TabOrder = 3
    end
  end
end
