object Form6: TForm6
  Left = 429
  Top = 194
  Width = 696
  Height = 710
  Caption = 'Form6'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 56
    Width = 67
    Height = 13
    Caption = 'Virtual sd card'
  end
  object Label2: TLabel
    Left = 376
    Top = 56
    Width = 72
    Height = 13
    Caption = 'Display sd card'
  end
  object Label3: TLabel
    Left = 80
    Top = 16
    Width = 59
    Height = 13
    Caption = 'Select folder'
  end
  object Label4: TLabel
    Left = 16
    Top = 576
    Width = 289
    Height = 13
    AutoSize = False
    Caption = 'filesize and date'
  end
  object Label5: TLabel
    Left = 376
    Top = 576
    Width = 289
    Height = 13
    AutoSize = False
    Caption = 'filesize and date'
  end
  object Label6: TLabel
    Left = 320
    Top = 16
    Width = 33
    Height = 13
    Caption = 'Sort by'
  end
  object FileListBox1: TListBox
    Left = 16
    Top = 72
    Width = 289
    Height = 497
    Style = lbOwnerDrawFixed
    ItemHeight = 13
    MultiSelect = True
    ExtendedSelect = True
    TabOrder = 0
    OnClick = FileListBox1Click
    OnDrawItem = FileListBoxDrawItem
  end
  object FileListBox2: TListBox
    Left = 376
    Top = 72
    Width = 289
    Height = 497
    Style = lbOwnerDrawFixed
    ItemHeight = 13
    MultiSelect = True
    ExtendedSelect = True
    TabOrder = 1
    OnClick = FileListBox2Click
    OnDrawItem = FileListBoxDrawItem
  end
  object ComboBox1: TComboBox
    Left = 144
    Top = 8
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = 'ComboBox1'
    OnChange = ComboBox1Change
  end
  object Button1: TButton
    Left = 320
    Top = 192
    Width = 41
    Height = 25
    Caption = '>>'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 224
    Width = 41
    Height = 25
    Caption = '<<'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 376
    Top = 600
    Width = 105
    Height = 25
    Caption = 'Remove file'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 560
    Top = 600
    Width = 105
    Height = 25
    Caption = 'Refresh'
    TabOrder = 6
    OnClick = Button4Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 652
    Width = 680
    Height = 19
    Panels = <
      item
        Text = 'current status'
        Width = 600
      end>
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 632
    Width = 665
    Height = 17
    TabOrder = 8
  end
  object ComboBox2: TComboBox
    Left = 384
    Top = 8
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 9
    Text = 'Sort by'
    OnChange = ComboBox2Change
    Items.Strings = (
      'Unsort'
      'Name'
      'Date'
      'Size')
  end
end
