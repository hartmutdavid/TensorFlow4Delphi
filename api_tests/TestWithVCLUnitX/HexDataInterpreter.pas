{
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

==============================================================================}

unit HexDataInterpreter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.StrUtils;

type
 PInt8   = ^Int8;
 PUInt8  = ^UInt8;
 PInt16  = ^Int16;
 PUInt16 = ^UInt16;
 PInt32  = ^Int32;
 PUInt32 = ^UInt32;
 PInt64  = ^Int64;
 PUInt64 = ^UInt64;

  TFormDataInterpreter = class(TForm)
    txfHex: TEdit;
    Label1: TLabel;
    chbxInt8Signed: TCheckBox;
    txfInt8Signed: TEdit;
    txfInt8Unsigned: TEdit;
    chbxInt8Unsigned: TCheckBox;
    txfInt16Signed: TEdit;
    chbxInt16Signed: TCheckBox;
    txfInt16Unsigned: TEdit;
    chbxInt16Unsigned: TCheckBox;
    txfInt32Signed: TEdit;
    chbxInt32Signed: TCheckBox;
    txfInt32Unsigned: TEdit;
    chbxInt32Unsigned: TCheckBox;
    txfInt64Signed: TEdit;
    chbxInt64Signed: TCheckBox;
    txfInt64Unsigned: TEdit;
    chbxInt64Unsigned: TCheckBox;
    chbxSingle: TCheckBox;
    txfSingle: TEdit;
    txfDouble: TEdit;
    chbxDouble: TCheckBox;
    txfExtended: TEdit;
    chbxExtended: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    procedure txfHexExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chbxDataTypeChangeClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure ClearFields;
    procedure Interprete;
  public
    { Public-Deklarationen }
    procedure SetHexText(aHexText: String);
  end;

var
  FormDataInterpreter: TFormDataInterpreter;

implementation

{$R *.dfm}

procedure TFormDataInterpreter.FormActivate(Sender: TObject);
begin
 //
end;

procedure TFormDataInterpreter.FormShow(Sender: TObject);
begin
 self.ClearFields;
 if Length(txfHex.Text) > 0 then
   self.Interprete;
end;

procedure TFormDataInterpreter.txfHexExit(Sender: TObject);
begin
 if Length(txfHex.Text) > 0 then
   self.Interprete
 else
   self.ClearFields;
end;

procedure TFormDataInterpreter.chbxDataTypeChangeClick(Sender: TObject);
begin
 if Length(txfHex.Text) > 0 then
   self.Interprete;
end;

procedure TFormDataInterpreter.ClearFields;
begin
 txfInt8Signed.Clear;
 txfInt8Unsigned.Clear;
 txfInt16Signed.Clear;
 txfInt16Unsigned.Clear;
 txfInt32Signed.Clear;
 txfInt32Unsigned.Clear;
 txfInt64Signed.Clear;
 txfInt64Unsigned.Clear;
 txfSingle.Clear;
 txfDouble.Clear;
 txfExtended.Clear;
end;

procedure TFormDataInterpreter.SetHexText(aHexText: String);
begin
 txfHex.Text := aHexText;
 self.Interprete;
end;

procedure TFormDataInterpreter.Interprete;
var
 l_sStr: String;
 l_aStrings: TStringDynArray;
 i, lng, l_iHex: Integer;
 l_sAnsiText: AnsiString;
 l_pAnsiChar: PAnsiChar;
 l_iInt8:   Int8;
 l_iUInt8:  UInt8;
 l_iInt16:  Int16;
 l_iUInt16: UInt16;
 l_iInt32:  Int32;
 l_iUInt32: UInt32;
 l_iInt64:  Int64;
 l_iUInt64: UInt64;
 l_fSingle: Single;
 l_fDouble: Double;
 l_fExtended: Extended;
 l_pInt8:   PInt8;
 l_pUInt8:  PUInt8;
 l_pInt16:  PInt16;
 l_pUInt16: PUInt16;
 l_pInt32:  PInt32;
 l_pUInt32: PUInt32;
 l_pInt64:  PInt64;
 l_pUInt64: PUInt64;
 l_pSingle: PSingle;
 l_pDouble: PDouble;
 l_pExtended: PExtended;
begin
 l_sStr := Trim(txfHex.Text);
 lng := Length(l_sStr);
 SetLength(l_sAnsiText,lng);
 self.ClearFields;
 l_aStrings := SplitString(l_sStr,' ');
 for i := 0 to Length(l_aStrings)-1 do begin
   l_sStr := '$' + l_aStrings[i];
   l_iHex := StrToInt(l_sStr);
   l_sAnsiText[i+1] := AnsiChar(l_iHex);
 end;
 l_pAnsiChar := PAnsiChar(@(l_sAnsiText[1]));
 if chbxInt8Signed.Checked then begin
   l_pInt8 := PInt8(l_pAnsiChar);
   l_iInt8 := l_pInt8^;
   try
     txfInt8Signed.Text := IntToStr(l_iInt8);
   except end;
 end;
 if chbxInt8Unsigned.Checked then begin
   l_pUInt8 := PUInt8(l_pAnsiChar);
   l_iUInt8 := l_pUInt8^;
   try
     txfInt8Unsigned.Text := IntToStr(l_iUInt8);
   except end;
 end;
 if chbxInt16Signed.Checked then begin
   l_pInt16 := PInt16(l_pAnsiChar);
   l_iInt16 := l_pInt16^;
   try
     txfInt16Signed.Text := IntToStr(l_iInt16);
   except end;
 end;
 if chbxInt16Unsigned.Checked then begin
   l_pUInt16 := PUInt16(l_pAnsiChar);
   l_iUInt16 := l_pUInt16^;
   try
     txfInt16Unsigned.Text := IntToStr(l_iUInt16);
   except end;
 end;
 if chbxInt32Signed.Checked then begin
   l_pInt32 := PInt32(l_pAnsiChar);
   l_iInt32 := l_pInt32^;
   try
     txfInt32Signed.Text := IntToStr(l_iInt32);
   except end;
 end;
 if chbxInt32Unsigned.Checked then begin
   l_pUInt32 := PUInt32(l_pAnsiChar);
   l_iUInt32 := l_pUInt32^;
   try
     txfInt32Unsigned.Text := UIntToStr(l_iUInt32);
   except end;
 end;
 if chbxInt64Signed.Checked then begin
   l_pInt64 := PInt64(l_pAnsiChar);
   l_iInt64 := l_pInt64^;
   try
     txfInt64Signed.Text := IntToStr(l_iInt64);
   except end;
 end;
 if chbxInt64Unsigned.Checked then begin
   l_pUInt64 := PUInt64(l_pAnsiChar);
   l_iUInt64 := l_pUInt64^;
   try
     txfInt64Unsigned.Text := UIntToStr(l_iUInt64);
   except end;
 end;
 if chbxSingle.Checked then begin
   l_pSingle := PSingle(l_pAnsiChar);
   l_fSingle := l_pSingle^;
   try
     txfSingle.Text := FloatToStr(l_fSingle);
   except end;
 end;
 if chbxDouble.Checked then begin
   l_pDouble := PDouble(l_pAnsiChar);
   l_fDouble := l_pDouble^;
   try
     txfDouble.Text := FloatToStr(l_fDouble);
   except end;
 end;
 if chbxExtended.Checked then begin
   l_pExtended := PExtended(l_pAnsiChar);
   l_fExtended := l_pExtended^;
   try
     txfExtended.Text := FloatToStr(l_fExtended);
   except end;
 end;
end;

end.
