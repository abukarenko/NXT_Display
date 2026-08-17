object Form2: TForm2
  Left = 454
  Top = 212
  BorderStyle = bsDialog
  Caption = 'Font Preview'
  ClientHeight = 436
  ClientWidth = 769
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 272
    Top = 40
    Width = 480
    Height = 320
    OnPaint = PaintBox1Paint
  end
  object Label6: TLabel
    Left = 364
    Top = 368
    Width = 28
    Height = 13
    Caption = 'Width'
  end
  object Label7: TLabel
    Left = 425
    Top = 368
    Width = 31
    Height = 13
    Caption = 'Height'
  end
  object Label8: TLabel
    Left = 496
    Top = 368
    Width = 3
    Height = 13
    Caption = ''
  end
  object Label1: TLabel
    Left = 8
    Top = 312
    Width = 56
    Height = 13
    Caption = 'Font folder'
  end
  object ListBox1: TListBox
    Left = 8
    Top = 8
    Width = 250
    Height = 296
    ItemHeight = 13
    Sorted = False
    TabOrder = 0
    OnClick = ListBox1Click
  end
  object Edit1: TEdit
    Left = 272
    Top = 8
    Width = 480
    Height = 21
    TabOrder = 1
    Text = 'NXT Display 12345 '#1040#1041#1042#1043
    OnChange = Edit1Change
  end
  object Button1: TButton
    Left = 584
    Top = 384
    Width = 80
    Height = 25
    Caption = 'Use'
    Default = False
    TabOrder = 2
    OnClick = Button1Click
    Enabled = False
  end
  object Button2: TButton
    Left = 672
    Top = 384
    Width = 80
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object SpinEdit3: TSpinEdit
    Left = 359
    Top = 384
    Width = 49
    Height = 22
    MaxValue = 480
    MinValue = 1
    TabOrder = 4
    Value = 1
    OnChange = FrameSizeChange
  end
  object SpinEdit4: TSpinEdit
    Left = 423
    Top = 384
    Width = 49
    Height = 22
    MaxValue = 320
    MinValue = 1
    TabOrder = 5
    Value = 1
    OnChange = FrameSizeChange
  end
  object CheckBox1: TCheckBox
    Left = 248
    Top = 384
    Width = 97
    Height = 17
    Caption = 'Show border'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CheckBox1Click
  end
  object Edit2: TEdit
    Left = 8
    Top = 328
    Width = 170
    Height = 21
    TabOrder = 8
  end
  object Button4: TButton
    Left = 184
    Top = 326
    Width = 34
    Height = 25
    Caption = '...'
    TabOrder = 9
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 224
    Top = 326
    Width = 34
    Height = 25
    Caption = 'R'
    TabOrder = 10
    OnClick = Button5Click
  end
  object Button3: TButton
    Left = 496
    Top = 384
    Width = 80
    Height = 25
    Caption = 'Push SD'
    TabOrder = 7
    OnClick = Button3Click
    Enabled = False
  end
end
