object Form3: TForm3
  Left = 568
  Top = 267
  Width = 657
  Height = 480
  Caption = 'Image area'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 8
    Top = 8
    Width = 480
    Height = 320
    OnMouseDown = PaintBox1MouseDown
    OnMouseMove = PaintBox1MouseMove
    OnMouseUp = PaintBox1MouseUp
    OnPaint = PaintBox1Paint
  end
  object Label1: TLabel
    Left = 504
    Top = 16
    Width = 6
    Height = 13
    Caption = 'X'
  end
  object Label2: TLabel
    Left = 504
    Top = 64
    Width = 6
    Height = 13
    Caption = 'Y'
  end
  object Label3: TLabel
    Left = 504
    Top = 112
    Width = 28
    Height = 13
    Caption = 'Width'
  end
  object Label4: TLabel
    Left = 504
    Top = 160
    Width = 31
    Height = 13
    Caption = 'Height'
  end
  object Label5: TLabel
    Left = 504
    Top = 248
    Width = 25
    Height = 13
    Caption = 'Scale'
  end
  object Label6: TLabel
    Left = 568
    Top = 248
    Width = 29
    Height = 13
    Alignment = taRightJustify
    Caption = '100%'
  end
  object Label7: TLabel
    Left = 504
    Top = 304
    Width = 59
    Height = 13
    Caption = 'Transparent'
  end
  object Label8: TLabel
    Left = 568
    Top = 304
    Width = 18
    Height = 13
    Alignment = taRightJustify
    Caption = '255'
  end
  object SpinEdit1: TSpinEdit
    Left = 504
    Top = 32
    Width = 96
    Height = 22
    MaxValue = 10000
    MinValue = 0
    TabOrder = 0
    Value = 0
    OnChange = SpinEditChange
  end
  object SpinEdit2: TSpinEdit
    Left = 504
    Top = 80
    Width = 96
    Height = 22
    MaxValue = 10000
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnChange = SpinEditChange
  end
  object SpinEdit3: TSpinEdit
    Left = 504
    Top = 128
    Width = 96
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 2
    Value = 1
    OnChange = SpinEditChange
  end
  object SpinEdit4: TSpinEdit
    Left = 504
    Top = 176
    Width = 96
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 3
    Value = 1
    OnChange = SpinEditChange
  end
  object Button1: TButton
    Left = 504
    Top = 368
    Width = 96
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object Button2: TButton
    Left = 504
    Top = 400
    Width = 96
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object Button3: TButton
    Left = 504
    Top = 208
    Width = 96
    Height = 25
    Caption = 'Full image'
    TabOrder = 4
    OnClick = Button3Click
  end
  object TrackBar1: TTrackBar
    Left = 496
    Top = 264
    Width = 120
    Height = 41
    Max = 400
    Min = 10
    Frequency = 25
    Position = 100
    TabOrder = 7
    OnChange = TrackBar1Change
  end
  object TrackBar2: TTrackBar
    Left = 496
    Top = 320
    Width = 120
    Height = 41
    Max = 255
    Min = 20
    Frequency = 25
    Position = 255
    TabOrder = 8
    OnChange = TrackBar2Change
  end
end
