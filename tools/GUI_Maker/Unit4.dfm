object Form4: TForm4
  Left = 661
  Top = 203
  Width = 588
  Height = 594
  Caption = 'Messages'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 572
    Height = 514
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    OnDblClick = Memo1DblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 514
    Width = 572
    Height = 41
    Align = alBottom
    Caption = ' '
    TabOrder = 1
    object Button1: TButton
      Left = 480
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = Button1Click
    end
    object CheckBox1: TCheckBox
      Left = 24
      Top = 16
      Width = 73
      Height = 17
      Caption = 'Receive'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object CheckBox2: TCheckBox
      Left = 96
      Top = 16
      Width = 73
      Height = 17
      Caption = 'Transmit'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object CheckBox3: TCheckBox
      Left = 176
      Top = 16
      Width = 73
      Height = 17
      Caption = 'System info'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object CheckBox4: TCheckBox
      Left = 328
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Wrap string'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = CheckBox4Click
    end
  end
end
