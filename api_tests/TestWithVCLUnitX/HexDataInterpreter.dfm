object FormDataInterpreter: TFormDataInterpreter
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Hex Data Interpreter'
  ClientHeight = 348
  ClientWidth = 407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnActivate = FormActivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 19
    Width = 19
    Height = 13
    Caption = 'Hex'
  end
  object Label2: TLabel
    Left = 327
    Top = 324
    Width = 54
    Height = 10
    Caption = 'Win32: 10 Byte'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 327
    Top = 334
    Width = 53
    Height = 10
    Caption = 'Win64:  8 Byte'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object txfHex: TEdit
    Left = 120
    Top = 16
    Width = 249
    Height = 21
    TabOrder = 0
    OnExit = txfHexExit
  end
  object chbxInt8Signed: TCheckBox
    Left = 16
    Top = 56
    Width = 89
    Height = 17
    Caption = 'Int8, signed'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt8Signed: TEdit
    Left = 120
    Top = 54
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 2
  end
  object txfInt8Unsigned: TEdit
    Left = 120
    Top = 81
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object chbxInt8Unsigned: TCheckBox
    Left = 16
    Top = 83
    Width = 98
    Height = 17
    Caption = 'Int8, unsigned'
    TabOrder = 4
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt16Signed: TEdit
    Left = 120
    Top = 108
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 5
  end
  object chbxInt16Signed: TCheckBox
    Left = 16
    Top = 110
    Width = 98
    Height = 17
    Caption = 'Int16, signed'
    TabOrder = 6
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt16Unsigned: TEdit
    Left = 120
    Top = 135
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 7
  end
  object chbxInt16Unsigned: TCheckBox
    Left = 16
    Top = 137
    Width = 98
    Height = 17
    Caption = 'Int16, unsigned'
    TabOrder = 8
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt32Signed: TEdit
    Left = 120
    Top = 162
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 9
  end
  object chbxInt32Signed: TCheckBox
    Left = 16
    Top = 164
    Width = 98
    Height = 17
    Caption = 'Int32, signed'
    Checked = True
    State = cbChecked
    TabOrder = 10
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt32Unsigned: TEdit
    Left = 120
    Top = 189
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 11
  end
  object chbxInt32Unsigned: TCheckBox
    Left = 16
    Top = 191
    Width = 98
    Height = 17
    Caption = 'Int32, unsigned'
    TabOrder = 12
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt64Signed: TEdit
    Left = 120
    Top = 216
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 13
  end
  object chbxInt64Signed: TCheckBox
    Left = 16
    Top = 218
    Width = 98
    Height = 17
    Caption = 'Int64, signed'
    TabOrder = 14
    OnClick = chbxDataTypeChangeClick
  end
  object txfInt64Unsigned: TEdit
    Left = 120
    Top = 241
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 15
  end
  object chbxInt64Unsigned: TCheckBox
    Left = 16
    Top = 243
    Width = 98
    Height = 17
    Caption = 'Int64, unsigned'
    TabOrder = 16
    OnClick = chbxDataTypeChangeClick
  end
  object chbxSingle: TCheckBox
    Left = 16
    Top = 268
    Width = 98
    Height = 17
    Caption = 'Float / Single'
    TabOrder = 17
    OnClick = chbxDataTypeChangeClick
  end
  object txfSingle: TEdit
    Left = 120
    Top = 268
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 18
  end
  object txfDouble: TEdit
    Left = 120
    Top = 295
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 19
  end
  object chbxDouble: TCheckBox
    Left = 16
    Top = 295
    Width = 98
    Height = 17
    Caption = 'Double'
    TabOrder = 20
    OnClick = chbxDataTypeChangeClick
  end
  object txfExtended: TEdit
    Left = 120
    Top = 322
    Width = 201
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 21
  end
  object chbxExtended: TCheckBox
    Left = 16
    Top = 322
    Width = 98
    Height = 17
    Caption = 'Extended'
    TabOrder = 22
    OnClick = chbxDataTypeChangeClick
  end
end
