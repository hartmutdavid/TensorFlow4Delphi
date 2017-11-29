{$REGION 'Licence'}
{ Copyright 2015 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Org. Source:  https://github.com/tensorflow/tensorflow
Org. Docu:    https://www.tensorflow.org
The structure of this Delphi porting was oriented to C# porting by Miguel Deicaza.
C# Source:    https://github.com/migueldeicaza/TensorFlowSharp

Delphi porting version: 1.2

==============================================================================}
{$ENDREGION}
unit TensorFlow.LowLevelUnitTests;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Types, System.IOUtils,
  DUnitX.TestFramework, System.AnsiStrings, System.StrUtils,
  TensorFlow.LowLevelAPI, TensorFlow._Helpers;

type
  {$M+}   // <- Generation of runtime type information (RTTI)
  //-- [TestFixture('TensorFlow-API Low Level Tests')]
  [TestFixture]
  [IgnoreMemoryLeaks(False)]
  ///<summary>Low level tests.</summary>
  TLowLevelTest = class
  public
    [Test]
    /// <summary>Test of getting the tensorflow version.</summary>
    procedure Test_TFVersion;
    [Test]
    /// <summary>Test of comparing the Tensorflow datatype with Delphi datatypes.</summary>
    procedure Test_DataTypes;
    [Test]
    /// <summary>Test of Encode and Decode one string required by Tensorflow</summary>
    procedure Test_StringEncoding;
    [Test]
    /// <summary>Test of Encode and Decode more strings required by Tensorflow</summary>
    procedure Test_TensorEncodeDecodeStrings;
    [Test]
    procedure Test_Status;
    [Test]
    procedure Test_Buffer;
    [Test]
    procedure Test_NewTensorForInt32;
    [Test]
    procedure Test_NewTensorForFloat;
    [Test]
    procedure Test_AllocateTensorForFloat;
    [Test]
    procedure Test_TensorMaybeMoveForFloat;
    [Test]
    procedure Test_NewSessionOptions;
    [Test]
    procedure Test_SetShape;
    [Test]
    procedure Test_Shape;
    [Test]
    /// <summary>Test of Imports a graph serialized into the graph</summary>
    procedure Test_ImportGraphDef;
    [Test]
    procedure Test_SessionRun;
    [Test]
    procedure Test_SessionPartialRun;
    [Test]
    procedure Test_ShapeInferenceError;
    [Test]
    procedure Test_ColocateWith;
    [Test]
    procedure Test_LoadSavedModel;
    [Test]
    procedure Test_LoadSavedModelNullArgsAreValid;
    [Test]
    procedure Test_CApiWhileLoop_BasicLoop;
    [Test]
    /// <summary>Test for string attribute</summary>
   	procedure Test_CApiAttributes_String;
    [Test]
    /// <summary>Test for string list attribute</summary>
   	procedure Test_CApiAttributes_StringList;
    [Test]
    /// <summary>Test for int attribute</summary>
  	procedure Test_CApiAttributes_Int;
    [Test]
    /// <summary>Test for int list attribute</summary>
	  procedure Test_CApiAttributes_IntList;
    [Test]
    /// <summary>Test for float attribute</summary>
	  procedure Test_CApiAttributes_Float;
    [Test]
    /// <summary>Test for float list attribute</summary>
	  procedure Test_CApiAttributes_FloatList;
    [Test]
	  procedure Test_CApiAttributes_Bool;
    [Test]
	  procedure Test_CApiAttributes_BoolList;
    [Test]
	  procedure Test_CApiAttributes_Type;
    [Test]
	  procedure Test_CApiAttributes_TypeList;
    [Test]
	  procedure Test_CApiAttributes_Shape;
    [Test]
	  procedure Test_CApiAttributes_ShapeList;
    [Test]
	  procedure Test_CApiAttributes_TensorShapeProto;
    [Test]
	  procedure Test_CApiAttributes_TensorShapeProtoList;
    [Test]
	  procedure Test_CApiAttributes_Tensor;
    [Test]
	  procedure Test_CApiAttributes_TensorList;
    [Test]
	  procedure Test_CApiAttributes_EmptyList;
    [Test]
	  procedure Test_CApiAttributes_Errors;
    //
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

  {$M+}
  //-- [TestFixture('TensorFlow - Special API Tests')]
  [TestFixture]
  [IgnoreMemoryLeaks(False)]
  TLowLevelSpecialTest = class
  public
//--    [Test]
    procedure Test_CommonOpList;    // <- slow!!!
    [Test]
    procedure Test_SpecialTest1;
    [Test]
    procedure Test_SpecialTest2;
  end;

var
 g_lLowLevelTestsAreInit: Boolean = False;

implementation

uses
{$IFDEF FMX}
 DUNitX.Loggers.GUIX,
{$ENDIF}
{$IFDEF VCL}
 DUnitX.Loggers.GUI.VCL,
{$ENDIF}
{$IFDEF CONSOLE}
 DUnitX.Loggers.Console,
{$ENDIF}
TensorFlow.LowLevelUnitTestsUtil;


procedure WriteLog(logType: TLogLevel; msg: String);
begin
{$IFDEF FMX}
 GUIXTestRunner.Log(logType,msg);
{$ENDIF}
{$IFDEF VCL}
 GUIVCLTestRunner.Log(logType,msg);
{$ENDIF}
{$IFDEF CONSOLE}
 System.Writeln(msg);
{$ENDIF}
end;

procedure TLowLevelTest.Setup;
var
 n: Integer;
begin
 // Every call before single Test
 if not g_lLowLevelTestsAreInit then begin
   WriteLog(TLogLevel.Information,'Execute TLowLevelTest.SetupFixture');
   n := TFEX_RegisterOpsForTesting();
   WriteLog(TLogLevel.Information,'-> Register Testing Ops: n=' + IntToStr(n));
   g_lLowLevelTestsAreInit := True;
 end;
end;

procedure TLowLevelTest.TearDown;
begin
  // Every call after single Test
 //-- WriteLog(TLogLevel.Information,'Execute TLowLevelTest.TearDownFixture');
end;

procedure TLowLevelTest.Test_TFVersion;
var
 l_sTFVersion: TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_TFVersion');
 l_sTFVersion := TensorFlow.LowLevelAPI.TF_Version();
{$IFDEF FMX}
 GUIXTestRunner.lbTFVersion.Text := 'TensorFlow-Version: ' + String(l_sTFVersion);
{$ENDIF}
{$IFDEF VCL}
 GUIVCLTestRunner.Caption := 'Testing Tensorflow for Version: ' + String(l_sTFVersion);
{$ENDIF}
 WriteLog(TLogLevel.Information,'TensorFlow-Version: ' + String(l_sTFVersion));
 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_DataTypes;
var
 i: Integer;
 l_sStr: String;
 l_sTFVersion: TFString;
 l_iSize, l_iTFSize: TF_size_t;
 l_enDataType: TF_DataType;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_DataTypes');
 for i := Ord(Low(TF_DataType)) to Ord(High(TF_DataType)) do begin
   l_enDataType := TF_DataType(i);
   l_iTFSize    := TF_DataTypeSize(Int32(l_enDataType));
 end;
 //
 l_iSize      := SizeOf(Single);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_FLOAT));   // <- Immer ueber Variable! Ansonsten ist der 0.
 Assert.IsTrue(l_iSize = l_iTFSize, 'Assertion failed: Invalid Single/TF_FLOAT Size');
 l_iSize      := SizeOf(Double);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_DOUBLE));
 Assert.IsTrue(l_iSize = l_iTFSize, 'Assertion failed: Invalid Double/TF_DOUBLE Size');
 l_iSize      := SizeOf(Integer);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_INT32));
 Assert.IsTrue(l_iSize = l_iTFSize, 'Assertion failed: Invalid Integer/TF_INT32 Size');
 //
 l_iTFSize := TF_DataTypeSize(Int32(TF_DataType.TF_STRING));     // = 0
 //
 l_iSize      := SizeOf(Int64);
 l_iTFSize := TF_DataTypeSize(Int32(TF_DataType.TF_INT64));
 Assert.IsTrue(l_iSize = l_iTFSize, 'Assertion failed: Invalid Int64/TF_INT64 Size');
 l_iSize      := SizeOf(Boolean);
 l_iTFSize := TF_DataTypeSize(Int32(TF_DataType.TF_BOOL));
 Assert.IsTrue(l_iSize = l_iTFSize, 'Assertion failed: Invalid Boolean/TF_BOOL Size');

 l_iSize      := SizeOf(Int8);
 l_iTFSize := TF_DataTypeSize(Int32(TF_DataType.TF_QINT8));          // = 1

 l_iSize      := SizeOf(UInt8);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_QUINT8));      // = 1

 l_iSize      := SizeOf(Int32);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_QINT32));      // = 4

 l_iSize      := SizeOf(Single);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_BFLOAT16));    // = 0

 l_iSize      := SizeOf(Int16);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_QINT16));      // = 0

 l_iSize      := SizeOf(UInt16);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_QUINT16));     // = 0

 l_iSize      := SizeOf(UInt16);
 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_UINT16));      // = 2

 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_COMPLEX));     // = 8

 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_COMPLEX64));   // = 8

 l_iTFSize    := TF_DataTypeSize(Int32(TF_DataType.TF_COMPLEX128));  // = 16
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_StringEncoding;
var
 l_iSize, l_iLen, l_iDecodeLen, l_iEncodeLen: TF_size_t;
 l_pStatus : PTF_Status;
 l_sDecodeStr, l_sDecodeStrDest: TFString;
 l_sEncodeStr: TFString;
 l_pEncodeStr, l_pDecodeStr, l_pDecodeStrDest: PTFChar;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_StringEncoding');
 l_pStatus := TF_NewStatus();
 l_iSize := TF_StringEncodedSize(1);           // = 2
 //
 l_sDecodeStr := 'Dies ist ein Text mit äüöÄÜÖß!';
 l_iDecodeLen := Length(l_sDecodeStr) * SizeOf(TFChar);
 SetLength(l_sEncodeStr,255);
 l_iEncodeLen := Length(l_sEncodeStr) * SizeOf(TFChar);
 l_pDecodeStr := _PTFChar(l_sDecodeStr);
 l_pEncodeStr := _PTFChar(l_sEncodeStr);
{$IFDEF VCL}
  GUIVCLTestRunner.HexProtWriteDesciption('OrgStr');
  GUIVCLTestRunner.HexProtWriteChars(l_pDecodeStr, l_iDecodeLen);
{$ENDIF}
 l_iSize    := TF_StringEncode(l_pDecodeStr, l_iDecodeLen,
                               l_pEncodeStr, l_iEncodeLen, l_pStatus);
 if TF_GetCode(l_pStatus) = TF_Code.TF_OK then begin
{$IFDEF VCL}
   GUIVCLTestRunner.HexProtWriteDesciption('EncodeStr');
   GUIVCLTestRunner.HexProtWriteChars(l_pEncodeStr, l_iSize);
{$ENDIF}
   SetLength(l_sEncodeStr,l_iSize);
   l_iSize :=  TF_StringDecode(l_pEncodeStr, l_iSize,
                               l_pDecodeStr, @l_iDecodeLen,
                               l_pStatus);
{$IFDEF VCL}
   GUIVCLTestRunner.HexProtWriteDesciption('DecodeStr');
   GUIVCLTestRunner.HexProtWriteChars(l_pDecodeStr, l_iDecodeLen);
{$ENDIF}
   SetLength(l_sDecodeStrDest,l_iDecodeLen);
   l_pDecodeStrDest := _PTFChar(l_sDecodeStrDest);
   System.AnsiStrings.StrPCopy(l_pDecodeStrDest,l_pDecodeStr);
   Assert.AreEqual(l_sDecodeStr, l_sDecodeStrDest, 'Assertion failed: Invalid DecodeStrings (Ungleiche Werte!)');
 end;
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TestEncodeDecode(i_aStrings: TArray<TFString>);
var
 l_lOk: Boolean;
 n: Integer;
 l_iDim1, l_iByteSize, l_iByteSize2: TF_int64_t;
 l_lDeallocator_called: Boolean;
 l_pData: Pointer;
 l_aDims: array[0..0] of TF_int64_t;
 l_pTensorSrc, l_pTensorDst:  PTF_Tensor;

 l_iSingleDim2, l_iTensorType, l_iLngDims2, l_iFullLng2: Integer;
 l_aValues2, l_aEncodeValues: TArray<TFString>;
 l_pStatus : PTF_Status;
 l_pOffset: PTF_int64_t;
 l_pTensor: PTF_Tensor;
 l_pntChar, l_pntBase, l_pntSrc, l_pntData2:  PTFChar;
begin
 n := Length(i_aStrings);
 if n > 0 then begin
   l_pData := _AllocMem(i_aStrings, l_iDim1, l_iByteSize);
   l_aDims[0] := l_iDim1;
   l_pTensorSrc := TF_NewTensor(Int32(TF_STRING), PTF_int64_t(@l_aDims[0]), 1,
                          l_pData, l_iByteSize, Deallocator_For_TensorDatas,
                          @l_lDeallocator_called);
   l_iTensorType := TF_TensorType(l_pTensorSrc);
   l_iLngDims2   := TF_NumDims(l_pTensorSrc);
   l_iSingleDim2 := TF_Dim(l_pTensorSrc,0);
   l_iByteSize2  := TF_TensorByteSize(l_pTensorSrc);
   l_pntData2    := PTFChar(TF_TensorData(l_pTensorSrc));
   l_lOk := _GetArray(l_pntData2, l_iSingleDim2, l_iByteSize2, l_aValues2);
   l_pTensorDst := Nil;
   if l_lOk and _EncodeStrings(l_aValues2, l_aEncodeValues) then begin
     l_pData := _AllocMem(l_aValues2, l_iDim1, l_iByteSize);
     l_pTensorDst := TF_NewTensor(Int32(TF_STRING), PTF_int64_t(@l_aDims[0]), 1,
                          l_pData, l_iByteSize, Deallocator_For_TensorDatas,
                          @l_lDeallocator_called);
   end;
   if Assigned(l_pTensorDst) then
     TF_DeleteTensor(l_pTensorDst);
   TF_DeleteTensor(l_pTensorSrc);
 end;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_TensorEncodeDecodeStrings;
var
 l_aDecodeStrings: TArray<TFString>;
 l_pBigStr: PTFChar;
 l_sBigStr: TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_TensorEncodeDecodeStrings');
 l_aDecodeStrings := ['hello'];
 TestEncodeDecode(l_aDecodeStrings);
 l_aDecodeStrings := ['the', 'quick', 'brown', 'fox', 'jumped', 'over'];
 TestEncodeDecode(l_aDecodeStrings);
 SetLength(l_sBigStr,1000);
 l_pBigStr := PTFChar(l_sBigStr);
 FillChar(l_pBigStr^,1000,'a');
 l_aDecodeStrings := ['small', l_sBigStr, 'small2'];
 TestEncodeDecode(l_aDecodeStrings);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_Status;
var
 l_sMsg: TFString;
 l_pStatus: PTF_Status;
 l_iCode:   TF_Code;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_Status');
 l_pStatus := TF_NewStatus();
 l_iCode   := TF_GetCode(l_pStatus);
 Assert.IsTrue(l_iCode = TF_Code.TF_OK, 'Assertion failed: Invalid Status Code');
 l_sMsg := TF_Message(l_pStatus);
 //
 TF_SetStatus(l_pStatus, TF_Code.TF_CANCELLED, 'cancel');
 l_iCode   := TF_GetCode(l_pStatus);
 Assert.IsTrue(l_iCode = TF_Code.TF_CANCELLED, 'Assertion failed: Invalid Status Code');
 l_sMsg := TF_Message(l_pStatus);
 Assert.IsTrue(l_sMsg = TFString('cancel'), 'Assertion failed: Invalid Status Message');
 //
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_Buffer;
var
 l_pntOptionsBuffer, l_pntMetadataBuffer: PTF_Buffer;
 l_sOptionsStr:  TFString;
 l_sMetadataStr: TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_Buffer');
 l_sOptionsStr := '';
 l_pntOptionsBuffer  := TF_NewBufferFromString(PTFChar(l_sOptionsStr), 0);
 l_pntMetadataBuffer := TF_NewBuffer();
 TF_DeleteBuffer(l_pntMetadataBuffer);
 TF_DeleteBuffer(l_pntOptionsBuffer);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_NewTensorForInt32;
const
 l_RowCnt = 3;
 l_ColCnt = 4;
var
 i, j: Integer;
 l_iVal:      Int32;
 l_iLen:      TF_size_t;
 l_arDims:    TArray<Int64>;
 l_pntTensor: PTF_Tensor;
 l_lDeallocator_called: Boolean;
 l_pntInt32, l_pntInt32Save, l_pntInt32Tmp: PInt32;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_NewTensorForInt32');
 l_arDims := [l_RowCnt, l_ColCnt];
 l_iLen   := l_RowCnt * l_ColCnt * sizeof(Int32);
 GetMem(l_pntInt32, l_iLen);
 l_pntInt32Save := l_pntInt32;
 l_iVal := 0;
 for i := 1 to l_RowCnt do begin
   for j := 1 to l_ColCnt do begin
     Inc(l_iVal);
     l_pntInt32^ := l_iVal;
     Inc(l_pntInt32);
   end;
 end;
 l_pntInt32 := l_pntInt32Save;
 l_lDeallocator_called := False;
 l_pntTensor := TF_NewTensor(Int32(TF_INT32), PTF_int64_t(@l_arDims[0]), 2,
                      l_pntInt32, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
 Assert.IsFalse(l_lDeallocator_called,'Assertion failed: Deallocator was called !');
 Assert.AreEqual(Int32(TF_INT32), TF_TensorType(l_pntTensor), 'Assertion failed: TF_TensorType is not TF_INT32 !');
 Assert.AreEqual(2, TF_NumDims(l_pntTensor), 'Assertion failed: Tensor Dimension ist not 2 !');
 Assert.AreEqual(l_arDims[0], TF_Dim(l_pntTensor,0), 'Assertion failed: Tensor Dimension[0] is not 3 !');
 Assert.AreEqual(l_arDims[1], TF_Dim(l_pntTensor,1), 'Assertion failed: Tensor Dimension[1] is not 4 !');
 Assert.AreEqual(l_iLen, TF_TensorByteSize(l_pntTensor), 'Assertion failed: Tensor Byte Size is not ' + IntToStr(l_iLen) + ' !');

 l_pntInt32Tmp := PInt32(TF_TensorData(l_pntTensor));
 for i := 1 to l_RowCnt do begin
   for j := 1 to l_ColCnt do begin
     Assert.AreEqual(l_pntInt32^, l_pntInt32Tmp^, 'Assertion failed: Int32 Data wrong !');
     Inc(l_pntInt32);
     Inc(l_pntInt32Tmp);
   end;
 end;

 TF_DeleteTensor(l_pntTensor);   // <- Der Speicher in l_pntInt32Save wird hiermit auch gelöscht!
 Assert.IsTrue(l_lDeallocator_called,'Assertion failed: Deallocator is not called!');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_NewTensorForFloat;
const
 l_RowCnt = 2;
 l_ColCnt = 3;
var
 i, j:        Integer;
 l_fVal:      Single;
 l_iLen:      TF_size_t;
 l_arDims:    TArray<Int64>;
 l_pntTensor: PTF_Tensor;
 l_lDeallocator_called: Boolean;
 l_pntSingle, l_pntSingleSave, l_pntSingleTmp: PSingle;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_NewTensorForFloat');
 l_arDims := [l_RowCnt, l_ColCnt];
 l_iLen   := l_RowCnt * l_ColCnt * sizeof(Single);
 GetMem(l_pntSingle, l_iLen);
 l_pntSingleSave := l_pntSingle;

 l_fVal := 0.0;
 for i := 1 to l_RowCnt do begin
   for j := 1 to l_ColCnt do begin
     l_fVal := l_fVal + 1.0;
     l_pntSingle^ := l_fVal;
     Inc(l_pntSingle);
   end;
 end;
 l_pntSingle := l_pntSingleSave;

 l_lDeallocator_called := False;
 l_pntTensor := TF_NewTensor(Int32(TF_FLOAT), PTF_int64_t(@l_arDims[0]), 2,
                      l_pntSingle, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
 Assert.IsFalse(l_lDeallocator_called,'Assertion failed: Deallocator was called !');
 Assert.AreEqual(Int32(TF_FLOAT), TF_TensorType(l_pntTensor), 'Assertion failed: TF_TensorType is not TF_FLOAT !');
 Assert.AreEqual(2, TF_NumDims(l_pntTensor), 'Assertion failed: Tensor Dimension ist not 2 !');
 Assert.AreEqual(l_arDims[0], TF_Dim(l_pntTensor,0), 'Assertion failed: Tensor Dimension[0] is not 2 !');
 Assert.AreEqual(l_arDims[1], TF_Dim(l_pntTensor,1), 'Assertion failed: Tensor Dimension[1] is not 3 !');
 Assert.AreEqual(l_iLen, TF_TensorByteSize(l_pntTensor), 'Assertion failed: Tensor Byte Size is not ' + IntToStr(l_iLen) + ' !');

 l_pntSingleTmp := PSingle(TF_TensorData(l_pntTensor));
 Assert.IsTrue(Assigned(l_pntSingleTmp),'Assertion failed: No Datas exist!');
 if Assigned(l_pntSingleTmp) then begin
   for i := 1 to l_RowCnt do begin
     for j := 1 to l_ColCnt do begin
       Assert.AreEqual(l_pntSingle^, l_pntSingleTmp^, 'Assertion failed: Single Data wrong !');
       Inc(l_pntSingle);
       Inc(l_pntSingleTmp);
     end;
   end;
 end;

 TF_DeleteTensor(l_pntTensor);  // <- Der Speicher in l_pntSingleSave wird hiermit auch gelöscht!
 Assert.IsTrue(l_lDeallocator_called,'Assertion failed: Deallocator is not called!');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_AllocateTensorForFloat;
const
 l_RowCnt = 2;
 l_ColCnt = 3;
var
 i, j:        Integer;
 l_fVal:      Single;
 l_iLen:      TF_size_t;
 l_arDims:    TArray<Int64>;
 l_pntTensor: PTF_Tensor;
 l_pntSingle: PSingle;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_NewTensorForFloat');
 l_arDims := [l_RowCnt, l_ColCnt];
 l_iLen   := l_RowCnt * l_ColCnt * sizeof(Single);

 l_pntTensor := TF_AllocateTensor(Int32(TF_FLOAT), PTF_int64_t(@l_arDims[0]), 2, l_iLen);
 Assert.AreEqual(Int32(TF_FLOAT), TF_TensorType(l_pntTensor), 'Assertion failed: TF_TensorType is not TF_FLOAT !');
 Assert.AreEqual(l_RowCnt, TF_NumDims(l_pntTensor), 'Assertion failed: Tensor Dimension ist not ' + IntToStr(l_RowCnt));
 Assert.AreEqual(l_arDims[0], TF_Dim(l_pntTensor,0), 'Assertion failed: Tensor Dimension[0] is not ' + IntToStr(l_RowCnt));
 Assert.AreEqual(l_arDims[1], TF_Dim(l_pntTensor,1), 'Assertion failed: Tensor Dimension[1] is not ' + IntToStr(l_ColCnt));
 Assert.AreEqual(l_iLen, TF_TensorByteSize(l_pntTensor), 'Assertion failed: Tensor Byte Size is not ' + IntToStr(l_iLen) + ' !');

 l_pntSingle := PSingle(TF_TensorData(l_pntTensor));
 Assert.IsTrue(Assigned(l_pntSingle),'Assertion failed: No Datas exist!');
 if Assigned(l_pntSingle) then begin
   for i := 1 to (l_RowCnt * l_ColCnt) do begin
     l_fVal := l_pntSingle^;
     Inc(l_pntSingle);
   end;
 end;

 TF_DeleteTensor(l_pntTensor);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_TensorMaybeMoveForFloat;
const
 l_RowCnt = 2;
 l_ColCnt = 3;
var
 i, j:        Integer;
 l_fVal:      Single;
 l_iLen:      TF_size_t;
 l_arDims:    TArray<Int64>;
 l_pntTensor1, l_pntTensor2: PTF_Tensor;
 l_lDeallocator_called: Boolean;
 l_pntSingle, l_pntSingleSave, l_pntSingleTmp: PSingle;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_TensorMaybeMoveForFloat');
 l_arDims := [l_RowCnt, l_ColCnt];
 l_iLen   := l_RowCnt * l_ColCnt * sizeof(Single);
 GetMem(l_pntSingle, l_iLen);
 l_pntSingleSave := l_pntSingle;

 l_fVal := 0.0;
 for i := 1 to l_RowCnt do begin
   for j := 1 to l_ColCnt do begin
     l_fVal := l_fVal + 1.0;
     l_pntSingle^ := l_fVal;
     Inc(l_pntSingle);
   end;
 end;
 l_pntSingle := l_pntSingleSave;

 l_lDeallocator_called := False;
 l_pntTensor1 := TF_NewTensor(Int32(TF_FLOAT), PTF_int64_t(@l_arDims[0]), 2,
                      l_pntSingle, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
 l_pntTensor2 := TF_TensorMaybeMove(l_pntTensor1);
 Assert.IsFalse(Assigned(l_pntTensor2),'Assertion failed: It is unsafe to move memory TF might not own!');

 TF_DeleteTensor(l_pntTensor1);   // <- Der Speicher in l_pntSingleSave wird hiermit auch gelöscht!
 Assert.IsTrue(l_lDeallocator_called,'Assertion failed: Deallocator is not called!');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_NewSessionOptions;
var
 l_pntOpt: PTF_SessionOptions;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_NewSessionOptions');
 l_pntOpt := TF_NewSessionOptions();
 Assert.IsTrue(Assigned(l_pntOpt),'Assertion failed: TF_NewSessionOptions failed!');
 if Assigned(l_pntOpt) then
   TF_DeleteSessionOptions(l_pntOpt);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_SetShape;
var
 l_iNumDims:  Integer;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpFeed, l_pOpThree:   PTF_Operation;
 l_pTensorInt32: PTF_Tensor;
 l_oOutput:   TF_Output;
 l_oThreeOut: TF_Output;
 l_iDim:      TF_int64_t;
 l_arDims:    TArray<Int64>;
 l_arDimsRet: TArray<TF_int64_t>;
begin
 // Tensor Shape:
 // =============
 // Rank | Shape          | Dimension Number | Example
 // -----------------------------------------------------
 //    0 |             [] |         0        |     4 
 //    1 |           [D0] |         1        |    [4] 
 //    2 |        [D0,D1] |         2        |  [6,2]
 //    3 |     [D0,D1,D2] |         3        |[7,3,2]
 //    n |[D0,D1,...Dn-1] |         n-1      |A Tensor shape [D0,D1,...,Dn-1}
 //
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_SetShape');
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

 l_pOpFeed := PlaceholderOp(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Fetch the shape, it should be completely unknown.
 l_oOutput.oper := l_pOpFeed;
 l_oOutput.index:= 0;
 l_iNumDims := TF_GraphGetTensorNumDims(l_pGraph, l_oOutput, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.AreEqual(-1, l_iNumDims, 'Assertion failed: NumDims wrong!');

 // Set the shape to be 2 x Unknown
 l_arDims := [2, -1];
 TF_GraphSetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDims[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Fetch the shape and validate it is 2 by -1.
 l_iNumDims := TF_GraphGetTensorNumDims(l_pGraph, l_oOutput, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.AreEqual(2, l_iNumDims, 'Assertion failed: NumDims wrong!');

 // Resize the dimension vector appropriately.
 l_arDimsRet := [11, 12];
 TF_GraphGetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDimsRet[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.AreEqual(2, l_iNumDims, 'Assertion failed: NumDims wrong!');
 Assert.AreEqual(l_arDims[0], l_arDimsRet[0], 'Assertion failed: l_arDims[0] <> l_arDimsRet[0]');
 Assert.AreEqual(l_arDims[1], l_arDimsRet[1], 'Assertion failed: l_arDims[1] <> l_arDimsRet[1]');

 // Set to a new valid shape: [2, 3]
 l_arDims[1] := 3;
 TF_GraphSetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDims[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Fetch and see that the new value is returned.
 TF_GraphGetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDimsRet[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.AreEqual(l_arDims[0], l_arDimsRet[0], 'Assertion failed: l_arDims[0] <> l_arDimsRet[0]');
 Assert.AreEqual(l_arDims[1], l_arDimsRet[1], 'Assertion failed: l_arDims[1] <> l_arDimsRet[1]');

 // Try to set 'unknown' on the shape and see that
 // it doesn't change.
 l_arDims[0] := -1;
 l_arDims[1] := -1;
 TF_GraphSetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDims[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 // Fetch and see that the new value is returned.
 TF_GraphGetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDimsRet[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.AreEqual(TF_int64_t(2), l_arDimsRet[0], 'Assertion failed: l_arDims[0] <> l_arDimsRet[0]');
 Assert.AreEqual(TF_int64_t(3), l_arDimsRet[1], 'Assertion failed: l_arDims[1] <> l_arDimsRet[1]');

 // Try to fetch a shape with the wrong num_dims
 TF_GraphGetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDimsRet[0]), 5, l_pStatus);
 Assert.AreEqual(Integer(TF_INVALID_ARGUMENT), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Try to set an invalid shape (cannot change 2x3 to a 2x5).
 l_arDims[1] := 5;
 TF_GraphSetTensorShape(l_pGraph, l_oOutput, PTF_int64_t(@l_arDims[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_INVALID_ARGUMENT), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Test for a scalar.
 l_pTensorInt32 := Int32Tensor(3);
 l_pOpThree     := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 if Assigned(l_pOpThree) then begin
   l_oThreeOut.oper := l_pOpThree;
   l_oThreeOut.index:= 0;
   l_iNumDims := TF_GraphGetTensorNumDims(l_pGraph, l_oThreeOut, l_pStatus);
   Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
   Assert.AreEqual(0, l_iNumDims, 'Assertion failed: l_iNumDims is not 0');
   TF_GraphGetTensorShape(l_pGraph, l_oThreeOut, PTF_int64_t(@l_arDimsRet[0]), l_iNumDims, l_pStatus);
   Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 end;

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_Shape;
var
 i, l, l_iNumDims, l_iNum, l_iType, l_iLng:  Integer;
 l_lFoundPlaceholder, l_lFoundScalarConst, l_lFoundAdd, l_lFoundNeg: Boolean;
 l_iVal64: Int64;
 l_iPos:   TF_size_t;
 l_pStr:   PTFChar;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pGraphDef, l_pGraphDef2: PTF_GraphDef;
 l_pNodeDef,  l_pNodeDef2, l_pAddedNode:  PTF_NodeDef;
 l_pOp:  PTF_Operation;
 l_pOpFeed, l_pOpFeed2, l_pOpThree, l_pOpAdd, l_pOpNeg, l_pOpNeg2:  PTF_Operation;
 l_pTensorInt32: PTF_Tensor;
 l_pAttrValue: PTF_AttrValue;
 l_oInput, l_oFeedPort, l_oThreePort: TF_Input;
 l_oOutput:   TF_Output;
 l_oThreeOut: PTF_Output;
 l_iDim:      TF_int64_t;
 l_arDims:    TArray<Int64>;
 l_arDimsRet: TArray<TF_int64_t>;
 l_sStr, l_sStr1, l_sStr2: TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_Shape');
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

  // Make a placeholder operation.
 l_pOpFeed := PlaceholderOp(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Test TF_Operation*() query functions.
 l_sStr := TFString(TF_OperationName(l_pOpFeed));
 Assert.AreEqual(TFString('feed'), l_sStr, 'Assertion failed: Wrong OperationName "feed"');
 l_sStr := TFString(TF_OperationOpType(l_pOpFeed));
 Assert.AreEqual(TFString('Placeholder'), l_sStr, 'Assertion failed: Wrong OperationOpType "Placeholder"');
 l_sStr := TFString(TF_OperationDevice(l_pOpFeed));
 Assert.AreEqual(TFString(''), l_sStr, 'Assertion failed: Wrong OperationOpType ""');
 l_iDim := TF_OperationNumOutputs(l_pOpFeed);
 Assert.AreEqual(1, Integer(l_iDim), 'Assertion failed: Wrong OperationNumOutputs 1');
 l_oOutput.oper  := l_pOpFeed;
 l_oOutput.index := 0;
 l_iType := Integer(TF_OperationOutputType(l_oOutput));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong OperationOutputType TF_INT32');
 TF_OperationOutputListLength(l_pOpFeed, PTFChar('output'), l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_iNumDims := TF_OperationNumInputs(l_pOpFeed);
 Assert.AreEqual(0, l_iNumDims, 'Assertion failed: Wrong OperationNumInputs');
 l_oOutput.oper  := l_pOpFeed;
 l_oOutput.index := 0;
 l_iNum := TF_OperationOutputNumConsumers(l_oOutput);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationOutputNumConsumers');
 l_iNum := TF_OperationNumControlInputs(l_pOpFeed);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationNumControlInputs');
 l_iNum := TF_OperationNumControlOutputs(l_pOpFeed);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationNumControlOutputs');

 l_pAttrValue := TFEX_AllocAttrValue(l_pOpFeed, 'dtype', l_pStatus);
 Assert.IsTrue(Assigned(l_pAttrValue), 'Assertion failed: TFEX_AllocAttrValue delivered Nil');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_iType := Integer(TFEX_GetAttrValueType(l_pAttrValue));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong AttrValueType TF_INT32');

 // Test not found errors in TF_Operation*() query functions.
 l_iLng := TF_OperationOutputListLength(l_pOpFeed,'bogus', l_pStatus);
 Assert.AreEqual(-1, l_iLng, 'Assertion failed: Wrong OperationOutputListLength');
 Assert.AreEqual(TF_INVALID_ARGUMENT, TF_GetCode(l_pStatus), 'Assertion failed: Not expected TF_INVALID_ARGUMENT');

 l_pAttrValue := TFEX_AllocAttrValue(l_pOpFeed, 'missing', l_pStatus);
 Assert.IsFalse(Assigned(l_pAttrValue), 'Assertion failed: TFEX_GetAttrValue delivered Nil');
 l_sStr := TF_Message(l_pStatus);
 Assert.IsTrue(Pos('has no attr named',l_sStr) > 0, 'Assertion failed: Operation "feed" has no attr named "missing" ...');

 // Make a constant oper with the scalar "3".
 l_pTensorInt32 := Int32Tensor(3);
 l_pOpThree := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Add oper.
 l_pOpAdd := AddOp(l_pOpFeed, l_pOpThree, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Test TF_Operation*() query functions.
 l_sStr := TF_OperationName(l_pOpAdd);
 Assert.AreEqual(TFString('add'), l_sStr, 'Assertion failed: Wrong OperationName, expected "add"');
 l_sStr := TF_OperationOpType(l_pOpAdd);
 Assert.AreEqual(TFString('AddN'), l_sStr, 'Assertion failed: Wrong OperationOpType, expected "AddN"');

 l_sStr := TF_OperationDevice(l_pOpAdd);
 Assert.AreEqual(TFString(''), l_sStr, 'Assertion failed: Wrong OperationDevice, expected ""');
 l_iNum := TF_OperationNumOutputs(l_pOpAdd);
 Assert.AreEqual(1, l_iNum, 'Assertion failed: Wrong OperationNumOutputs, expected 1');
 l_oOutput.oper  := l_pOpAdd;
 l_oOutput.index := 0;
 l_iType := Integer(TF_OperationOutputType(l_oOutput));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong OperationOutputType TF_INT32');
 l_iLng := TF_OperationOutputListLength(l_pOpAdd, 'sum', l_pStatus);
 Assert.AreEqual(1, l_iLng, 'Assertion failed: Wrong TF_OperationOutputListLength expected 1');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_iNum := TF_OperationNumInputs(l_pOpAdd);
 Assert.AreEqual(2, l_iNum, 'Assertion failed: Wrong TF_OperationNumInputs expected 2');
 l_iLng := TF_OperationInputListLength(l_pOpAdd, 'inputs', l_pStatus);
 Assert.AreEqual(2, l_iNum, 'Assertion failed: Wrong TF_OperationInputListLength expected 2');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_oInput.oper := l_pOpAdd;
 l_oInput.index:= 0;
 l_iType := Integer(TF_OperationInputType(l_oInput));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong TF_OperationInputType TF_INT32');
 l_oInput.oper := l_pOpAdd;
 l_oInput.index:= 1;
 l_iType := Integer(TF_OperationInputType(l_oInput));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong TF_OperationInputType TF_INT32');
 l_oInput.oper := l_pOpAdd;
 l_oInput.index:= 0;
 l_oOutput := TF_OperationInput(l_oInput);
 Assert.AreEqual(l_pOpFeed, l_oOutput.oper, 'Assertion failed: Wrong OperationInput, expected oper=l_pFeed');
 Assert.AreEqual(0, l_oOutput.index, 'Assertion failed: Wrong OperationInput, expected index=0');
 l_oInput.oper := l_pOpAdd;
 l_oInput.index:= 1;
 l_oOutput := TF_OperationInput(l_oInput);
 Assert.AreEqual(l_pOpThree, l_oOutput.oper, 'Assertion failed: Wrong OperationInput, expected oper=l_pThree');
 Assert.AreEqual(0, l_oOutput.index, 'Assertion failed: Wrong OperationInput, expected index=0');
 l_oOutput.oper := l_pOpAdd;
 l_oOutput.index:= 0;
 l_iNum := TF_OperationOutputNumConsumers(l_oOutput);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationOutputNumConsumers, expected l_iNum=0');
 l_iNum := TF_OperationNumControlInputs(l_pOpAdd);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationNumControlInputs, expected l_iNum=0');
 l_iNum := TF_OperationNumControlOutputs(l_pOpAdd);
 Assert.AreEqual(0, l_iNum, 'Assertion failed: Wrong OperationNumControlOutputs, expected l_iNum=0');
 l_pAttrValue := TFEX_AllocAttrValue(l_pOpAdd, 'T', l_pStatus);
 Assert.IsTrue(Assigned(l_pAttrValue), 'Assertion failed: TFEX_GetAttrValue delivered Nil');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_iType := Integer(TFEX_GetAttrValueType(l_pAttrValue));
 Assert.AreEqual(Integer(TF_INT32), l_iType, 'Assertion failed: Wrong AttrValueType TF_INT32');
 l_pAttrValue := TFEX_AllocAttrValue(l_pOpAdd, 'N', l_pStatus);
 Assert.IsTrue(Assigned(l_pAttrValue), 'Assertion failed: TFEX_GetAttrValue delivered Nil');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_iVal64 := TFEX_GetAttrValue_i(l_pAttrValue);
 Assert.AreEqual(Int64(2), l_iVal64, 'Assertion failed: ' + TF_Message(l_pStatus));

 // Placeholder oper now has a consumer.
 l_oOutput.oper := l_pOpFeed;
 l_oOutput.index:= 0;
 l_iNum := TF_OperationOutputNumConsumers(l_oOutput);
 Assert.AreEqual(1, l_iNum, 'Assertion failed: Wrong OperationOutputNumConsumers, expected l_iNum=0');
 l_oOutput.oper := l_pOpFeed;
 l_oOutput.index:= 0;
 l_iNum := TF_OperationOutputConsumers(l_oOutput,@l_oFeedPort,1);
 Assert.AreEqual(1, l_iNum, 'Assertion failed: Wrong OperationOutputConsumers, expected l_iNum=1');
 Assert.AreEqual(l_pOpAdd, l_oFeedPort.oper, 'Assertion failed: Wrong OperationOutputConsumers, expected l_pOpAdd=l_oFeedPort.oper');
 Assert.AreEqual(0, l_oFeedPort.index, 'Assertion failed: Wrong OperationOutputConsumers, expected l_oFeedPort.index=0');

 // The scalar const oper also has a consumer.
 l_oOutput.oper := l_pOpThree;
 l_oOutput.index:= 0;
 l_iNum := TF_OperationOutputNumConsumers(l_oOutput);
 Assert.AreEqual(1, l_iNum, 'Assertion failed: Wrong OperationOutputNumConsumers, expected l_iNum=1');
 l_oOutput.oper := l_pOpThree;
 l_oOutput.index:= 0;
 l_iNum := TF_OperationOutputConsumers(l_oOutput, @l_oThreePort, 1);
 Assert.AreEqual(1, l_iNum, 'Assertion failed: Wrong OperationOutputConsumers, expected l_iNum=1');
 Assert.AreEqual(l_pOpAdd, l_oThreePort.oper, 'Assertion failed: Wrong OperationOutputConsumers, expected l_pOpAdd=l_oThreePort.oper');
 Assert.AreEqual(1, l_oThreePort.index, 'Assertion failed: Wrong OperationOutputConsumers, expected l_oThreePort.index=1');

 // Serialize to GraphDef.
 l_pGraphDef := TFEX_AllocGraphDefFromGraph(l_pGraph);
 Assert.IsTrue(Assigned(l_pGraphDef),'Assertion failed: TFEX_AllocGraphDefFromGraph delivered Nil');

 // Validate GraphDef is what we expect.
 l_lFoundPlaceholder := False;
 l_lFoundScalarConst := False;
 l_lFoundAdd         := False;
 l_iNum := TFEX_GetNodeDefsCount(l_pGraphDef);
 for i := 0 to l_iNum-1 do begin
   l_pNodeDef := TFEX_GetNodeDef(l_pGraphDef, i);
   Assert.IsTrue(Assigned(l_pNodeDef),'Assertion failed: TFEX_GetNodeDef delivered Nil');
   if (IsPlaceholder(l_pNodeDef)) then begin
      Assert.IsFalse(l_lFoundPlaceholder,'Assertion failed: l_lFoundPlaceholder is True');
      l_lFoundPlaceholder := True;
   end
   else if IsScalarConst(l_pNodeDef, 3) then begin
      Assert.IsFalse(l_lFoundScalarConst,'Assertion failed: l_lFoundScalarConst is True');
      l_lFoundScalarConst := True;
   end
   else if IsAddN(l_pNodeDef, 2) then begin
      Assert.IsFalse(l_lFoundAdd,'Assertion failed: l_lFoundAdd is True');
     l_lFoundAdd := True;
   end
   else begin
     System.Writeln('-> Unexpected NodeDef');
   end;
 end;
 Assert.IsTrue(l_lFoundPlaceholder,'Assertion failed: l_lFoundPlaceholder is False');
 Assert.IsTrue(l_lFoundScalarConst,'Assertion failed: l_lFoundScalarConst is False');
 Assert.IsTrue(l_lFoundAdd,'Assertion failed: l_lFoundAdd is False');

 // Add another oper to the graph.
 l_pOpNeg := NegOp(l_pOpAdd, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Serialize to NodeDef.
 l_pNodeDef := GetNodeDef(l_pOpNeg);
 Assert.IsTrue(Assigned(l_pNodeDef),'Assertion failed: GetNodeDef delivered Nil');

 // Validate NodeDef is what we expect.
 Assert.IsTrue(IsNeg(l_pNodeDef, 'add'),'Assertion failed: GetNodeDef delivered Nil');

 // Serialize to GraphDef.
 l_pGraphDef2 := GetGraphDef(l_pGraph);
 Assert.IsTrue(Assigned(l_pGraphDef2),'Assertion failed: GetGraphDef delivered Nil');

 // Compare with first GraphDef + added NodeDef.
 l_pAddedNode := TFEX_AddNodeDefToGraphDef(l_pGraphDef);
 //TODO: EXPECT_EQ(ProtoDebugString(graph_def), ProtoDebugString(graph_def2));

  // Look up some nodes by name.
 l_pOpNeg2 := TF_GraphOperationByName(l_pGraph, 'neg');
 Assert.IsTrue(l_pOpNeg = l_pOpNeg2,'Assertion failed: TF_GraphOperationByName delivered wrong l_pOpNeg2');
 l_pNodeDef2 := GetNodeDef(l_pOpNeg2);
 Assert.IsTrue(Assigned(l_pNodeDef2),'Assertion failed: GetNodeDef delivered Nil');
 l := NodeDefToDebugString(l_pNodeDef, l_sStr1);
 l := NodeDefToDebugString(l_pNodeDef2,l_sStr2);
 Assert.AreEqual(l_sStr1, l_sStr2, 'Assertion failed: l_pNodeDef <> l_pNodeDef2');

 l_pOpFeed2 := TF_GraphOperationByName(l_pGraph, 'feed');
 Assert.IsTrue(l_pOpFeed = l_pOpFeed2,'Assertion failed: TF_GraphOperationByName delivered wrong l_pFeed2');
 l_pNodeDef := GetNodeDef(l_pOpFeed);
 l_pNodeDef2:= GetNodeDef(l_pOpFeed2);
 l := NodeDefToDebugString(l_pNodeDef, l_sStr1);
 l := NodeDefToDebugString(l_pNodeDef2,l_sStr2);
 Assert.AreEqual(l_sStr1, l_sStr2, 'Assertion failed: l_pNodeDef <> l_pNodeDef2');

 // Test iterating through the nodes of a graph.
 l_lFoundPlaceholder := False;
 l_lFoundScalarConst := False;
 l_lFoundAdd         := False;
 l_lFoundNeg         := False;
 l_iPos := 0;
 while True do begin
   l_pOp := TF_GraphNextOperation(l_pGraph, @l_iPos);
   if not Assigned(l_pOp) then
     break;
   if l_pOp = l_pOpFeed then
     l_lFoundPlaceholder := True
   else if l_pOp = l_pOpThree then
     l_lFoundScalarConst := True
   else if l_pOp = l_pOpAdd then
     l_lFoundAdd         := True
   else if l_pOp = l_pOpNeg then
     l_lFoundNeg         := True
   else begin
     Assert.IsFalse(True,'Assertion failed: TF_GraphNextOperation delivered wrong l_pOp');
   end;
 end;
 Assert.IsTrue(l_lFoundPlaceholder,'Assertion failed: l_lFoundPlaceholder is False');
 Assert.IsTrue(l_lFoundScalarConst,'Assertion failed: l_lFoundScalarConst is False');
 Assert.IsTrue(l_lFoundAdd,        'Assertion failed: l_lFoundAdd is False');
 Assert.IsTrue(l_lFoundNeg,        'Assertion failed: l_lFoundNeg is False');

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_ImportGraphDef;
var
 l_iNum: Integer;
 l_pStr1:   PTFChar;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_oOutput, l_oNegInput: TF_Output;
 l_oInput:  TF_Input;
 l_pTensorInt32: PTF_Tensor;
 l_sDebugStr: AnsiString;
 l_aReturnOutputs: array[0..1] of TF_Output;
 l_aControlInputs: array[0..99] of PTF_Operation;
 l_pControlInputs, l_pOpAdd: PTF_Operation;
 l_pGraphDefBuffer: PTF_Buffer;
 l_pOp, l_pOpFeed, l_pOpThree, l_pOpNeg, l_pOpScalar: PTF_Operation;
 l_pOpScalar2, l_pOpFeed2, l_pOpNeg2: PTF_Operation;
 l_pOpScalar3, l_pOpFeed3, l_pOpNeg3: PTF_Operation;
 l_pOpScalar4, l_pOpFeed4: PTF_Operation;
 l_pOpts: PTF_ImportGraphDefOptions;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_ImportGraphDef');
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

 // Create a graph with two nodes: x and 3
 l_pOpFeed := PlaceholderOp(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pOp := TF_GraphOperationByName(l_pGraph, 'feed');
 Assert.IsTrue(Assigned(l_pOp),'Assertion failed: TF_GraphOperationByName delivered Nil');
 l_pTensorInt32 := Int32Tensor(3);
 l_pOpThree := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pOp := TF_GraphOperationByName(l_pGraph, 'scalar');
 Assert.IsTrue(Assigned(l_pOp),'Assertion failed: TF_GraphOperationByName delivered Nil');
 l_pOpNeg := NegOp(l_pOp, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pOp := TF_GraphOperationByName(l_pGraph, 'neg');
 Assert.IsTrue(Assigned(l_pOp),'Assertion failed: TF_GraphOperationByName delivered Nil');

 // Export to a GraphDef-Buffer
 l_pGraphDefBuffer := TF_NewBuffer();
 TF_GraphToGraphDef(l_pGraph, l_pGraphDefBuffer, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
{$IF DEFINED(VCL) and DEFINED(TF_PROTOCOL)}
 GUIVCLTestRunner.HexProtWriteDesciption('GraphDef-Buffer (1)');
 GUIVCLTestRunner.HexProtWriteChars(PTFChar(l_pGraphDefBuffer.data), Integer(l_pGraphDefBuffer.length));
{$ENDIF}
 TensorFlow.LowLevelUnitTestsUtil.GraphToDebugString(l_pGraph, l_sDebugStr);

 // Import it again, with a prefix, in a fresh graph.
 TF_DeleteGraph(l_pGraph);
 l_pGraph := TF_NewGraph();
 l_pOpts  := TF_NewImportGraphDefOptions();
 TF_ImportGraphDefOptionsSetPrefix(l_pOpts, 'imported');
 TF_GraphImportGraphDef(l_pGraph, l_pGraphDefBuffer, l_pOpts, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pOpScalar := TF_GraphOperationByName(l_pGraph, 'imported/scalar');
 l_pOpFeed   := TF_GraphOperationByName(l_pGraph, 'imported/feed');
 l_pOpNeg    := TF_GraphOperationByName(l_pGraph, 'imported/neg');
 Assert.IsTrue(Assigned(l_pOpScalar),'Assertion failed: TF_GraphOperationByName with imported/scalar delivered Nil');
 Assert.IsTrue(Assigned(l_pOpFeed),  'Assertion failed: TF_GraphOperationByName with imported/feed delivered Nil');
 Assert.IsTrue(Assigned(l_pOpNeg),   'Assertion failed: TF_GraphOperationByName with imported/neg delivered Nil');

 // Import it again, with an input mapping and return outputs, into the same
 // graph.
 TF_DeleteImportGraphDefOptions(l_pOpts);
 l_pOpts := TF_NewImportGraphDefOptions();
 TF_ImportGraphDefOptionsSetPrefix(l_pOpts, 'imported2');
 l_oOutput.oper := l_pOpScalar;
 l_oOutput.index:= 0;
 TF_ImportGraphDefOptionsAddInputMapping(l_pOpts, 'scalar', 0, l_oOutput);
 TF_ImportGraphDefOptionsAddReturnOutput(l_pOpts, 'feed', 0);
 TF_ImportGraphDefOptionsAddReturnOutput(l_pOpts, 'scalar', 0);
 l_iNum := TF_ImportGraphDefOptionsNumReturnOutputs(l_pOpts);
 Assert.AreEqual(l_iNum, 2, 'Assertion failed: TF_ImportGraphDefOptionsNumReturnOutputs returned not 2');
 TF_GraphImportGraphDefWithReturnOutputs(l_pGraph, l_pGraphDefBuffer, l_pOpts,
                                         PTF_Output(@l_aReturnOutputs[0]), 2, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpScalar2 := TF_GraphOperationByName(l_pGraph, 'imported2/scalar');
 l_pOpFeed2   := TF_GraphOperationByName(l_pGraph, 'imported2/feed');
 l_pOpNeg2    := TF_GraphOperationByName(l_pGraph, 'imported2/neg');
 Assert.IsTrue(Assigned(l_pOpScalar2),'Assertion failed: TF_GraphOperationByName with imported2/scalar delivered Nil');
 Assert.IsTrue(Assigned(l_pOpFeed2),  'Assertion failed: TF_GraphOperationByName with imported2/feed delivered Nil');
 Assert.IsTrue(Assigned(l_pOpNeg2),   'Assertion failed: TF_GraphOperationByName with imported2/neg delivered Nil');

 // Check input mapping
 l_oInput.oper := l_pOpNeg;
 l_oInput.index:= 0;
 l_oNegInput := TF_OperationInput(l_oInput);
 Assert.AreEqual(l_pOpScalar, l_oNegInput.oper, 'Assertion failed: l_pOpScalar <> l_oNegInput.oper');
 Assert.AreEqual(0, l_oNegInput.index, 'Assertion failed: l_oNegInput.oper <> 0');

 // Check return outputs
 Assert.AreEqual(l_pOpFeed2, l_aReturnOutputs[0].oper, 'Assertion failed: l_pOpFeed2 <> l_aReturnOutputs[0].oper');
 Assert.AreEqual(0, l_aReturnOutputs[0].index, 'Assertion failed: l_aReturnOutputs[0].index <> 0');
 Assert.AreEqual(l_pOpScalar, l_aReturnOutputs[1].oper, 'Assertion failed: l_pOpScalar <> l_aReturnOutputs[1].oper');  // remapped
 Assert.AreEqual(0, l_aReturnOutputs[1].index, 'Assertion failed: l_aReturnOutputs[1].index <> 0');

 // Import again, with control dependencies, into the same graph.
 TF_DeleteImportGraphDefOptions(l_pOpts);
 l_pOpts := TF_NewImportGraphDefOptions();
 TF_ImportGraphDefOptionsSetPrefix(l_pOpts, 'imported3');
 TF_ImportGraphDefOptionsAddControlDependency(l_pOpts, l_pOpFeed);
 TF_ImportGraphDefOptionsAddControlDependency(l_pOpts, l_pOpFeed2);
 TF_GraphImportGraphDef(l_pGraph, l_pGraphDefBuffer, l_pOpts, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpScalar3 := TF_GraphOperationByName(l_pGraph, 'imported3/scalar');
 l_pOpFeed3   := TF_GraphOperationByName(l_pGraph, 'imported3/feed');
 l_pOpNeg3    := TF_GraphOperationByName(l_pGraph, 'imported3/neg');
 Assert.IsTrue(Assigned(l_pOpScalar3),'Assertion failed: TF_GraphOperationByName with imported3/scalar delivered Nil');
 Assert.IsTrue(Assigned(l_pOpFeed3),  'Assertion failed: TF_GraphOperationByName with imported3/feed delivered Nil');
 Assert.IsTrue(Assigned(l_pOpNeg3),   'Assertion failed: TF_GraphOperationByName with imported3/neg delivered Nil');

 // Check that newly-imported scalar and feed have control deps (neg3 will
 // inherit them from input)
 l_pControlInputs := PTF_Operation(@l_aControlInputs[0]);
 l_iNum := TF_OperationGetControlInputs(
                 l_pOpScalar3, l_pControlInputs,
                 TF_OperationNumControlInputs(l_pOpScalar3));
 Assert.AreEqual(2, l_iNum, 'Assertion failed: TF_OperationGetControlInputs returned wrong Value');
 Assert.AreEqual(l_pOpFeed,  l_aControlInputs[0], 'Assertion failed: l_pOpFeed,  l_aControlInputs[0]');
 Assert.AreEqual(l_pOpFeed2, l_aControlInputs[1], 'Assertion failed: l_pOpFeed2, l_aControlInputs[1]');

 l_pControlInputs := PTF_Operation(@l_aControlInputs[0]);
 l_iNum := TF_OperationGetControlInputs(
                 l_pOpFeed3, l_pControlInputs, TF_OperationNumControlInputs(l_pOpFeed3));
 Assert.AreEqual(2, l_iNum, 'Assertion failed: TF_OperationGetControlInputs returned wrong Value');
 Assert.AreEqual(l_pOpFeed,  l_aControlInputs[0], 'Assertion failed: l_pOpFeed,  l_aControlInputs[0]');
 Assert.AreEqual(l_pOpFeed2, l_aControlInputs[1], 'Assertion failed: l_pOpFeed2, l_aControlInputs[1]');

 // Export to a graph def so we can import a graph with control dependencies
 TF_DeleteBuffer(l_pGraphDefBuffer);
 l_pGraphDefBuffer := TF_NewBuffer();
 TF_GraphToGraphDef(l_pGraph, l_pGraphDefBuffer, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
{$IF DEFINED(VCL) and DEFINED(TF_PROTOCOL)}
 GUIVCLTestRunner.HexProtWriteDesciption('GraphDef-Buffer (2)');
 GUIVCLTestRunner.HexProtWriteChars(PTFChar(l_pGraphDefBuffer.data), Integer(l_pGraphDefBuffer.length));
{$ENDIF}

 // Import again, with remapped control dependency, into the same graph
 TF_DeleteImportGraphDefOptions(l_pOpts);
 l_pOpts := TF_NewImportGraphDefOptions();
 TF_ImportGraphDefOptionsSetPrefix(l_pOpts, 'imported4');
 TF_ImportGraphDefOptionsRemapControlDependency(l_pOpts, 'imported/feed', l_pOpFeed);
 TF_GraphImportGraphDef(l_pGraph, l_pGraphDefBuffer, l_pOpts, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpScalar4 := TF_GraphOperationByName(l_pGraph, 'imported4/imported3/scalar');
 l_pOpFeed4   := TF_GraphOperationByName(l_pGraph, 'imported4/imported2/feed');

 // Check that imported `imported3/scalar` has remapped control dep from
 // original graph and imported control dep
 l_pControlInputs := PTF_Operation(@l_aControlInputs[0]);
 l_iNum := TF_OperationGetControlInputs(
                 l_pOpScalar4, l_pControlInputs, TF_OperationNumControlInputs(l_pOpScalar4));
 Assert.AreEqual(2, l_iNum, 'Assertion failed: TF_OperationGetControlInputs returned wrong Value');
 Assert.AreEqual(l_pOpFeed,  l_aControlInputs[0], 'Assertion failed: l_pOpFeed,  l_aControlInputs[0]');
 Assert.AreEqual(l_pOpFeed4, l_aControlInputs[1], 'Assertion failed: l_pOpFeed4, l_aControlInputs[1]');

 TF_DeleteImportGraphDefOptions(l_pOpts);
 TF_DeleteBuffer(l_pGraphDefBuffer);

 // Can add nodes to the imported graph without trouble.
 l_pOpAdd := AddOp(l_pOpFeed, l_pOpScalar, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_SessionRun;
var
 l_iNum: Integer;
 l_pInt32:  PInt32;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpFeed, l_pOpTwo, l_pOpAdd, l_pOpNeg: PTF_Operation;
 l_pTensorInt32: PTF_Tensor;
 l_oTFSession: TTFSession;
 l_pOut: PTF_Tensor;
 l_iDatatype: Int32;
 l_aInputOpers:   TArray<PTF_Operation>;
 l_aOutputOpers:  TArray<PTF_Operation>;
 l_aInputTensors: TArray<PTF_Tensor>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_SessionRun');
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

  // Make a placeholder operation.
 l_pOpFeed := PlaceholderOp(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Make a constant operation with the scalar "2".
 l_pTensorInt32 := Int32Tensor(2);
 l_pOpTwo := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Add operation.
 l_pOpAdd := AddOp(l_pOpFeed, l_pOpTwo, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Create a session for this graph.
 l_oTFSession := TTFSession.Create(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Run the graph.
 SetLength(l_aInputOpers,1);
 SetLength(l_aInputTensors,1);
 l_aInputOpers[0]  := l_pOpFeed;
 l_aInputTensors[0]:= Int32Tensor(3);
 SetLength(l_aOutputOpers,1);
 l_aOutputOpers[0] := l_pOpAdd;
 //
 l_oTFSession.SetInputs(l_aInputOpers, l_aInputTensors);
 l_oTFSession.SetOutputs(l_aOutputOpers);
 l_oTFSession.Run(l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pOut := l_oTFSession.OutputTensor(0);
 Assert.IsTrue(Assigned(l_pOut), 'Assertion failed: l_pOut = Nil');
 l_iDatatype := TF_TensorType(l_pOut);
 Assert.AreEqual(Integer(TF_INT32), Integer(l_iDatatype), 'Assertion failed: TensorType <> TF_INT32');
 l_iNum := TF_NumDims(l_pOut);
 Assert.AreEqual(l_iNum, 0, 'Assertion failed: NumDims is not 0');   // scalar
 Assert.AreEqual(TF_size_t(sizeof(Int32)), TF_TensorByteSize(l_pOut), 'Assertion failed: TF_TensorByteSize is not sizeof(Int32)');
 l_pInt32 := TF_TensorData(l_pOut);
 l_iNum   := l_pInt32^;
 Assert.AreEqual(l_iNum, 3+2, 'Assertion failed: TF_TensorData is not 3+2');

 // Add another operation to the graph.
 l_pOpNeg := NegOp(l_pOpAdd, l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Run up to the new operation.
 SetLength(l_aInputOpers,1);
 SetLength(l_aInputTensors,1);
 l_aInputOpers[0]  := l_pOpFeed;
 l_aInputTensors[0]:= Int32Tensor(7);
 SetLength(l_aOutputOpers,1);
 l_aOutputOpers[0] := l_pOpNeg;
 //
 l_oTFSession.SetInputs(l_aInputOpers, l_aInputTensors);
 l_oTFSession.SetOutputs(l_aOutputOpers);
 l_oTFSession.Run(l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOut := l_oTFSession.OutputTensor(0);
 Assert.IsTrue(Assigned(l_pOut), 'Assertion failed: l_pOut = Nil');
 l_iDatatype := TF_TensorType(l_pOut);
 Assert.AreEqual(Integer(TF_INT32), Integer(l_iDatatype), 'Assertion failed: TensorType <> TF_INT32');
 l_iNum := TF_NumDims(l_pOut);
 Assert.AreEqual(l_iNum, 0, 'Assertion failed: NumDims is not 0');   // scalar
 Assert.AreEqual(TF_size_t(sizeof(Int32)), TF_TensorByteSize(l_pOut), 'Assertion failed: TF_TensorByteSize is not sizeof(Int32)');
 l_pInt32 := TF_TensorData(l_pOut);
 l_iNum   := l_pInt32^;
 Assert.AreEqual(l_iNum, -(7 + 2), 'Assertion failed: TF_TensorData is not -(7 + 2)');

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 l_oTFSession.Free;
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_SessionPartialRun;
var
 l_iNum: Integer;
 l_pInt32:  PInt32;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pSess:   PTF_Session;
 l_pHandle: PTFChar;
 l_pOpA, l_pOpB, l_pOpTwo, l_pOpPlus2, l_pOpPlusB: PTF_Operation;
 l_pTensorInt32: PTF_Tensor;
 l_pOpts: PTF_SessionOptions;
 l_pOut: PTF_Tensor;
 l_iDatatype: Int32;
 l_aFeeds,  l_aFetches:  array[0..1] of TF_Output;
 l_aFeeds1, l_aFetches1, l_aFeeds2, l_aFetches2: array[0..0] of TF_Output;
 l_aFeedValues1, l_aFetchValues1, l_aFeedValues2, l_aFetchValues2: array[0..0] of PTF_Tensor;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_SessionPartialRun');
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

 // Construct the graph: A + 2 + B
 l_pOpA := PlaceholderOp(l_pGraph, l_pStatus, 'A');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpB := PlaceholderOp(l_pGraph, l_pStatus, 'B');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pTensorInt32 := Int32Tensor(2);
 l_pOpTwo := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpPlus2 := AddOp(l_pOpA, l_pOpTwo, l_pGraph, l_pStatus, 'plus2');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpPlusB := AddOp(l_pOpPlus2, l_pOpB, l_pGraph, l_pStatus, 'plusB');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Setup a session and a partial run handle.  The partial run will allow
 // computation of A + 2 + B in two phases (calls to TF_SessionPRun):
 // 1. Feed A and get (A+2)     (im Sinne von zuführen ...)
 // 2. Feed B and get (A+2)+B
 l_pOpts := TF_NewSessionOptions();
 l_pSess := TF_NewSession(l_pGraph, l_pOpts, l_pStatus);
 TF_DeleteSessionOptions(l_pOpts);

 l_aFeeds[0].oper    := l_pOpA;
 l_aFeeds[0].index   := 0;
 l_aFeeds[1].oper    := l_pOpB;
 l_aFeeds[1].index   := 0;
 l_aFetches[0].oper  := l_pOpPlus2;
 l_aFetches[0].index := 0;
 l_aFetches[1].oper  := l_pOpPlusB;
 l_aFetches[1].index := 0;
 l_pHandle := Nil;
 TF_SessionPRunSetup(l_pSess, PTF_Output(@l_aFeeds[0]), Length(l_aFeeds),
                     PTF_Output(@l_aFetches[0]), Length(l_aFetches),
                     Nil, 0, &l_pHandle, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Feed A and fetch A + 2.
 l_aFeeds1[0].oper    := l_pOpA;
 l_aFeeds1[0].index   := 0;
 l_aFetches1[0].oper  := l_pOpPlus2;
 l_aFetches1[0].index := 0;
 l_aFeedValues1[0]    := Int32Tensor(1);
 l_aFetchValues1[0]   := Nil;
 TF_SessionPRun(l_pSess, l_pHandle,
                PTF_Output(@l_aFeeds1[0]), PTF_Tensor(@l_aFeedValues1[0]), 1,
                PTF_Output(@l_aFetches1[0]), PTF_Tensor(@l_aFetchValues1[0]), 1, nil, 0, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pInt32 := TF_TensorData(l_aFetchValues1[0]);
 l_iNum   := l_pInt32^;
 Assert.AreEqual(l_iNum, 3, 'Assertion failed: TF_TensorData is not 3');
 TF_DeleteTensor(l_aFeedValues1[0]);
 TF_DeleteTensor(l_aFetchValues1[0]);

 // Feed B and fetch (A + 2) + B.
 l_aFeeds2[0].oper    := l_pOpB;
 l_aFeeds2[0].index   := 0;
 l_aFetches2[0].oper  := l_pOpPlusB;
 l_aFetches2[0].index := 0;
 l_aFeedValues2[0]    := Int32Tensor(4);
 l_aFetchValues2[0]   := Nil;
 TF_SessionPRun(l_pSess, l_pHandle,
                PTF_Output(@l_aFeeds2[0]), PTF_Tensor(@l_aFeedValues2[0]), 1,
                PTF_Output(@l_aFetches2[0]), PTF_Tensor(@l_aFetchValues2[0]), 1, nil, 0, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pInt32 := TF_TensorData(l_aFetchValues2[0]);
 l_iNum   := l_pInt32^;
 Assert.AreEqual(l_iNum, 7, 'Assertion failed: TF_TensorData is not 7');
 TF_DeleteTensor(l_aFeedValues2[0]);
 TF_DeleteTensor(l_aFetchValues2[0]);

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 TF_DeletePRunHandle(l_pHandle);
 TF_DeleteSession(l_pSess, l_pStatus);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_ShapeInferenceError;
var
 l_iNum: Integer;
 l_pInt32:  PInt32;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpAdd, l_pOpVec2, l_pOpVec3:  PTF_Operation;
 l_pVec2Tensor, l_pVec3Tensor: PTF_Tensor;
 l_aData:     TArray<Int8>;
 l_aVec2Dims, l_aVec3Dims: TArray<TF_int64_t>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_ShapeInferenceError');
 // TF_FinishOperation should fail if the shape of the added operation cannot
 // be inferred.
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

 // Create this failure by trying to add two nodes with incompatible shapes
 // (A tensor with shape [2] and a tensor with shape [3] cannot be added).
 l_aData := [1, 2, 3];
 l_aVec2Dims := [2];
 l_pVec2Tensor := Int8ArrayTensor(l_aVec2Dims, Length(l_aVec2Dims), l_aData);
 l_pOpVec2 := ConstOp(l_pVec2Tensor, l_pGraph, l_pStatus, 'vec2');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_aVec3Dims := [3];
 l_pVec3Tensor := Int8ArrayTensor(l_aVec3Dims, Length(l_aVec3Dims), l_aData);
 l_pOpVec3 := ConstOp(l_pVec3Tensor, l_pGraph, l_pStatus, 'vec3');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pOpAdd := AddOp(l_pOpVec2, l_pOpVec3, l_pGraph, l_pStatus);
 Assert.AreNotEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.IsFalse(Assigned(l_pOpAdd), 'Assertion failed: l_pOpAdd is not Nil');

 // Clean up
 TF_DeleteTensor(l_pVec2Tensor);
 TF_DeleteTensor(l_pVec3Tensor);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_ColocateWith;
var
 l_iNum: Integer;
 l_pInt32:  PInt32;
 l_pColocationAttrName: PTFChar;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpFeed, l_pOpConstant, l_pOpAdd: PTF_Operation;
 l_pTensorInt32: PTF_Tensor;
 l_pDesc:   PTF_OperationDescription;
 l_aInputs: array[0..1] of TF_Output;
 l_oAttrMetadata: TF_AttrMetadata;
 l_aLens:   array[0..0] of TF_size_t;
 l_aValues: array[0..0] of Pointer;
 l_pStorage, l_pStr: PTFChar;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_ColocateWith');
 // Colocate ist ein Verb, das bedeutet, zwei oder mehr Items eng zusammenzusetzen.
 l_pStatus := TF_NewStatus();
 l_pGraph  := TF_NewGraph();

 l_pOpFeed := PlaceholderOp(l_pGraph, l_pStatus, 'A');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pTensorInt32 := Int32Tensor(10);
 l_pOpConstant  := ConstOp(l_pTensorInt32, l_pGraph, l_pStatus, 'scalar');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pDesc := TF_NewOperation(l_pGraph, 'AddN', 'add');
 l_aInputs[0].oper := l_pOpFeed;
 l_aInputs[0].index:= 0;
 l_aInputs[1].oper := l_pOpConstant;
 l_aInputs[1].index:= 0;
 TF_AddInputList(l_pDesc, PTF_Output(@l_aInputs[0]), Length(l_aInputs));
 TF_ColocateWith(l_pDesc, l_pOpFeed);

 l_pOpAdd := TF_FinishOperation(l_pDesc, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 l_pColocationAttrName := TFEX_ColocationAttrName();
 l_oAttrMetadata := TF_OperationGetAttrMetadata(l_pOpAdd, l_pColocationAttrName, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Assert.IsTrue(l_oAttrMetadata.is_list, 'Assertion failed: l_oAttrMetadata is not list');
 Assert.AreEqual(1, Integer(l_oAttrMetadata.list_size), 'Assertion failed: l_oAttrMetadata.list_size is not 1');
 Assert.AreEqual(Integer(TF_ATTR_STRING), Integer(l_oAttrMetadata.AttrType), 'Assertion failed: l_oAttrMetadata.list_size is not 1');

 GetMem(l_pStorage, l_oAttrMetadata.total_size);
 TF_OperationGetAttrStringList(l_pOpAdd, l_pColocationAttrName, @l_aValues[0],
                               PTF_size_t(@l_aLens[0]), 1, l_pStorage, l_oAttrMetadata.total_size,
                               l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 l_pStr := l_aValues[0];

 //TODO: EXPECT_EQ("loc:@feed", string(static_cast<const char*>(values[0]), lens[0]));
 FreeMem(l_pStorage);

 // Clean up
 TF_DeleteTensor(l_pTensorInt32);
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_LoadSavedModel;
var
 l_iLen, l_iStrLng, l_iIdx, i, n: Integer;
 l_sModelDir, l_sInputName, l_sOutputName: TFString;
 l_aSplitStrings: TStrings;
 l_sMsg, l_pOpType, l_pOpDevice: PTFChar;
 l_sSavedModelTagServe: PTFChar;
 l_pInputName, l_pOutputName, l_pInputOpName, l_pOutputOpName: PTFChar;
 l_aTags:   TArray<PTFChar>;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpt:    PTF_SessionOptions;
 l_pRunOptionsBuf, l_pMetagraphBuf: PTF_Buffer;
 l_pSession: PTF_Session;
 l_pMetaGraphDef: PTF_MetaGraphDef;
 l_pSignatureDefMap: PTF_SignatureDefMap;
 l_pSignatureDef: PTF_SignatureDef;
 l_pInputOp, l_pOutputOp, l_pOp_a, l_pOp_b: PTF_Operation;
 l_aValues, l_aEncodeValues: TArray<TFString>;
 l_pInputTensor, l_pTensor_a, l_pTensor_b: PTF_Tensor;
 l_oTFSession: TTFSession;
 l_aInputOpers:   TArray<PTF_Operation>;
 l_aOutputOpers:  TArray<PTF_Operation>;
 l_aInputTensors: TArray<PTF_Tensor>;
 l_oExample: TTFExample;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_LoadSavedModel');

 l_sModelDir := 'SavedModels/half_plus_two/00000123';

 l_pOpt := TF_NewSessionOptions();
 l_pRunOptionsBuf := TF_NewBufferFromString(PTFChar(''), 0);
 l_pMetagraphBuf  := TF_NewBuffer();
 l_pStatus := TF_NewStatus();

 l_sSavedModelTagServe := TFEX_SavedModelTagServe();
 l_aTags  := [l_sSavedModelTagServe];
 l_pGraph := TF_NewGraph();

 l_pSession := TF_LoadSessionFromSavedModel(
      l_pOpt, l_pRunOptionsBuf, PTFChar(l_sModelDir), PTFChar(@l_aTags[0]), 1, l_pGraph, l_pMetagraphBuf, l_pStatus);
 l_sMsg := TF_Message(l_pStatus);
 TF_DeleteBuffer(l_pRunOptionsBuf);
 TF_DeleteSessionOptions(l_pOpt);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
{$IF DEFINED(VCL) and DEFINED(TF_PROTOCOL)}
 GUIVCLTestRunner.HexProtWriteDesciption('MetagraphBuf');
 GUIVCLTestRunner.HexProtWriteChars(PTFChar(l_pMetagraphBuf.data), Integer(l_pMetagraphBuf.length));
{$ENDIF}
 l_pMetaGraphDef := TFEX_AllocMetaGraphDefFromBuffer(l_pMetagraphBuf);

 l_pSignatureDefMap := TFEX_GetSignatureDefMapFromMetaGraphDef(l_pMetaGraphDef);
 l_pSignatureDef    := TFEX_GetSignatureDefFromMap(l_pSignatureDefMap,PTFChar('regress_x_to_y'));
 //-- l_pInputName       := TFEX_GetInputNameFromSignatureDef(l_pSignatureDef);
 //-- l_pOutputName   := TFEX_GetOutputNameFromSignatureDef(l_pSignatureDef);

 l_sInputName  := SplitString(TFEX_GetInputNameFromSignatureDef(l_pSignatureDef),':')[0];    // tf_example
 l_pInputName  := _PTFChar(l_sInputName);
 l_sOutputName := SplitString(TFEX_GetOutputNameFromSignatureDef(l_pSignatureDef),':')[0];   // y
 l_pOutputName := _PTFChar(l_sOutputName);

 l_pInputOp     := TF_GraphOperationByName(l_pGraph, l_pInputName);
 Assert.IsTrue(Assigned(l_pInputOp), 'Assertion failed: l_pInputOp is Nil');

 l_pOutputOp    := TF_GraphOperationByName(l_pGraph, l_pOutputName);
 Assert.IsTrue(Assigned(l_pOutputOp), 'Assertion failed: l_pOutputOp is Nil');

 // Template-Struktur von Example
 SetLength(l_aValues,4);
 l_oExample := TTFExample.Create;
 for i := 0 to 3 do begin
   l_oExample.Init;
   l_oExample.add_fvalue(Single(i));
   l_aValues[i] := l_oExample.SerializeAsString();
 end;
 l_oExample.Free;
 Assert.IsTrue(_EncodeStrings(l_aValues, l_aEncodeValues), 'Assertion failed: EncodeStringArray1d fault');
 l_pInputTensor := StringArrayTensor(l_aEncodeValues);

 l_pOp_a  := TF_GraphOperationByName(l_pGraph, 'a');
 l_pOpType := TF_OperationOpType(l_pOp_a);      // <- 'VariableV2'
 l_pOpDevice := TF_OperationDevice(l_pOp_a);    // <- ''
 n := TF_OperationNumOutputs(l_pOp_a);          // <- 1
 n := TF_OperationNumInputs(l_pOp_a);           // <- 0

 l_pTensor_a := FloatTensor(0.0);

 l_pOp_b  := TF_GraphOperationByName(l_pGraph, 'b');
 l_pOpType := TF_OperationOpType(l_pOp_b);      // <- 'VariableV2'
 l_pOpDevice := TF_OperationDevice(l_pOp_b);    // <- ''
 n := TF_OperationNumOutputs(l_pOp_b);          // <- 1
 n := TF_OperationNumInputs(l_pOp_b);           // <- 0

 l_pTensor_b := FloatTensor(0.0);

 // Create a session for this graph.
 l_oTFSession := TTFSession.Create(l_pGraph, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 SetLength(l_aInputOpers,3);
 SetLength(l_aInputTensors,3);
 l_aInputOpers[0]  := l_pInputOp;
 l_aInputTensors[0]:= l_pInputTensor;
 l_aInputOpers[1]  := l_pOp_a;
 l_aInputTensors[1]:= l_pTensor_a;
 l_aInputOpers[2]  := l_pOp_b;
 l_aInputTensors[2]:= l_pTensor_b;
 SetLength(l_aOutputOpers,1);
 l_aOutputOpers[0] := l_pOutputOp;
 //
 l_oTFSession.SetInputs(l_aInputOpers, l_aInputTensors);
 l_oTFSession.SetOutputs(l_aOutputOpers);
 //
 l_oTFSession.Run(l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 //
 l_oTFSession.CloseAndDelete(l_pStatus);;
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Clean up
 TFEX_DeleteMetaGraphDef(l_pMetaGraphDef);
 TF_DeleteGraph(l_pGraph);
 l_oTFSession.Free;
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_LoadSavedModelNullArgsAreValid;
var
 l_sModelDir: TFString;
 l_sSavedModelTagServe: PTFChar;
 l_aTags:   TArray<PTFChar>;
 l_pStatus: PTF_Status;
 l_pGraph:  PTF_Graph;
 l_pOpt:    PTF_SessionOptions;
 l_pSession: PTF_Session;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_LoadSavedModelNullArgsAreValid');

 l_sModelDir := 'SavedModels/half_plus_two/00000123';

 l_pOpt := TF_NewSessionOptions();
 l_pStatus := TF_NewStatus();

 l_sSavedModelTagServe := TFEX_SavedModelTagServe();
 l_aTags  := [l_sSavedModelTagServe];
 l_pGraph := TF_NewGraph();

 // NULL run_options and meta_graph_def should work.
 l_pSession := TF_LoadSessionFromSavedModel(
      l_pOpt, Nil, PTFChar(l_sModelDir), PTFChar(@l_aTags[0]), 1, l_pGraph, Nil, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));

 // Clean up
 TF_DeleteSessionOptions(l_pOpt);
 TF_CloseSession(l_pSession, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 TF_DeleteSession(l_pSession, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 TF_DeleteGraph(l_pGraph);
 TF_DeleteStatus(l_pStatus);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiWhileLoop_BasicLoop;
var
 l_oCApiWhileLoopTest: TTFCApiWhileLoopTest;
 l_pLessThanOp, l_pAdd1Op, l_pAdd2Op, l_pOneOp: PTF_Operation;
 l_aValues: TArray<Int32>;
 l_aPCondInputs:  TArray<Pointer>;
 l_aPBodyInputs:  TArray<Pointer>;
 l_aPBodyOutputs: TArray<Pointer>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiWhileLoop_BasicLoop');

 l_oCApiWhileLoopTest := TTFCApiWhileLoopTest.Create;
 l_oCApiWhileLoopTest.Init(2);
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.params_.body_graph), 'Assertion failed: l_oCApiWhileLoopTest.Params.body_graph is Nil');
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.params_.cond_graph), 'Assertion failed: l_oCApiWhileLoopTest.Params.cond_graph is Nil');
 Assert.AreEqual(2, l_oCApiWhileLoopTest.params_.ninputs, 'Assertion failed: l_oCApiWhileLoopTest.Params.ninputs <> 2');
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.params_.cond_inputs), 'Assertion failed: l_oCApiWhileLoopTest.Params.cond_inputs is Nil');
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.params_.body_inputs), 'Assertion failed: l_oCApiWhileLoopTest.Params.body_inputs is Nil');
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.params_.body_outputs),'Assertion failed: l_oCApiWhileLoopTest.Params.body_outputs is Nil');

 // Create loop: while (input1 < input2) input1 += input2 + 1
 _GetPointerArray(l_oCApiWhileLoopTest.params_.cond_inputs, 2, sizeof(TF_Output), l_aPCondInputs);
 l_pLessThanOp := LessThanOp(PTF_Output(l_aPCondInputs[0])^, PTF_Output(l_aPCondInputs[1])^,
                             l_oCApiWhileLoopTest.params_.cond_graph, l_oCApiWhileLoopTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiWhileLoopTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiWhileLoopTest.TFStatus));
 l_oCApiWhileLoopTest.params_.cond_output.oper  := l_pLessThanOp;
 l_oCApiWhileLoopTest.params_.cond_output.index := 0;

 _GetPointerArray(l_oCApiWhileLoopTest.params_.body_inputs, 2, sizeof(TF_Output),
                             l_aPBodyInputs);
 l_pAdd1Op := AddOp(PTF_Output(l_aPBodyInputs[0])^, PTF_Output(l_aPBodyInputs[1])^,
                  l_oCApiWhileLoopTest.params_.body_graph, l_oCApiWhileLoopTest.TFStatus, 'add1');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiWhileLoopTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiWhileLoopTest.TFStatus));
 l_pOneOp := ScalarConstOp(1, l_oCApiWhileLoopTest.params_.body_graph, l_oCApiWhileLoopTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiWhileLoopTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiWhileLoopTest.TFStatus));

 l_pAdd2Op := AddOp(l_pAdd1Op, l_pOneOp, l_oCApiWhileLoopTest.params_.body_graph,
                    l_oCApiWhileLoopTest.TFStatus, 'add2');
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiWhileLoopTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiWhileLoopTest.TFStatus));

 _GetPointerArray(l_oCApiWhileLoopTest.params_.body_outputs, 2, sizeof(TF_Output),
                             l_aPBodyOutputs);
 PTF_Output(l_aPBodyOutputs[0])^.Oper  := l_pAdd2Op;
 PTF_Output(l_aPBodyOutputs[0])^.index := 0;
 PTF_Output(l_aPBodyOutputs[1])^.Oper  := PTF_Output(l_aPBodyInputs[1])^.Oper;
 PTF_Output(l_aPBodyOutputs[1])^.index := PTF_Output(l_aPBodyInputs[1])^.index;

 // Finalize while loop
 l_oCApiWhileLoopTest.ExpectOK();

 // Validate while loop outputs returned by TF_FinishWhile()
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.outputs_[0].oper), 'Assertion failed: l_oCApiWhileLoopTest.Outputs[0].oper is Nil');
 Assert.IsTrue(l_oCApiWhileLoopTest.outputs_[0].index >= 0, 'Assertion failed: l_oCApiWhileLoopTest.Outputs[0].index is not >= 0');
 Assert.IsTrue(Assigned(l_oCApiWhileLoopTest.outputs_[1].oper), 'Assertion failed: l_oCApiWhileLoopTest.Outputs[1].oper is Nil');
 Assert.IsTrue(l_oCApiWhileLoopTest.outputs_[1].index >= 0, 'Assertion failed: l_oCApiWhileLoopTest.Outputs[1].index is not >= 0');

 // Run the graph
 SetLength(l_aValues,2);
 l_aValues[0] := -9;
 l_aValues[1] := 2;
 l_oCApiWhileLoopTest.Run(l_aValues);
 l_oCApiWhileLoopTest.ExpectOutputValue(0, 3);
 l_oCApiWhileLoopTest.ExpectOutputValue(1, 2);

 ClearTensorList;
 l_oCApiWhileLoopTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;


procedure ExpectTFMeta(oper: PTF_Operation;
                       attr_name: TFString;
                       expected_list_size: Integer;
                       expected_type: TF_AttrType;
                       expected_total_size: Integer;
                       status: PTF_Status);
var
 l_oMeta: TF_AttrMetadata;
begin
 l_oMeta := TF_OperationGetAttrMetadata(oper, _PTFChar(attr_name), status);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(status)),'Assertion failed: ' + TF_Message(status));
 Assert.AreEqual(l_oMeta.is_list, expected_list_size >= 0,'Assertion failed: wrong "is_list"');
 Assert.AreEqual(expected_list_size, Integer(l_oMeta.list_size),'Assertion failed: wrong "list_size"');
 Assert.AreEqual(Integer(expected_type), Integer(l_oMeta.AttrType),'Assertion failed: wrong "AttrType"');
 Assert.AreEqual(Integer(expected_total_size), Integer(l_oMeta.total_size),'Assertion failed: wrong "total_size"');
end;

procedure TLowLevelTest.Test_CApiAttributes_String;
var
 l_sAttrName, l_sValue: TFString;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sVal:  TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_String');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('string');
 l_sAttrName := 'v';
 l_sValue    := 'bunny';
 TF_SetAttrString(l_pDesc, _PTFChar(l_sAttrName), _PTFChar(l_sValue), 5);

 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_STRING, 5, l_oCApiAttributesTest.TFStatus);

 SetLength(l_sVal,5);
 TF_OperationGetAttrString(l_pOper, 'v', _PTFChar(l_sVal), 5, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 Assert.AreEqual(TFString('bunny'), l_sVal,'Assertion failed: Value is not "bunny"');

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_StringList;
var
 i, l_iListSize, l_iListTotalSize: Integer;
 l_sAttrName, l_sValue: TFString;
 l_aStrings: TArray<TFString>;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_aLengths, l_aLengths2: TArray<TF_size_t>;
 l_aPTFChar, l_aPTFChar2: TArray<PTFChar>;
 l_pStorage, l_pValue: PTFChar;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_StringList');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(string)');
 l_sAttrName := 'v';
 //
 l_aStrings := ['bugs', 'bunny', 'duck'];
 l_iListSize := Length(l_aStrings);
 l_iListTotalSize := 0;
 for i := 0 to l_iListSize-1 do
   l_iListTotalSize := l_iListTotalSize + Length(l_aStrings[i]);
 _GetPTFCharArray(l_aStrings,l_aLengths,l_aPTFChar);
 TF_SetAttrStringList(l_pDesc, _PTFChar(l_sAttrName), @(l_aPTFChar[0]), @(l_aLengths[0]),l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_STRING, l_iListTotalSize, l_oCApiAttributesTest.TFStatus);
 //
 SetLength(l_aLengths2,l_iListSize);
 SetLength(l_aPTFChar2,l_iListSize);
 GetMem(l_pStorage, l_iListTotalSize);
 TF_OperationGetAttrStringList(l_pOper, _PTFChar(l_sAttrName),
                               @(l_aPTFChar2[0]), @(l_aLengths2[0]),
                               l_iListSize,
                               l_pStorage,
                               l_iListTotalSize,
                               l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aLengths[i], l_aLengths2[i], 'Assertion failed: l_aLengths[i] <> l_aLengths2[i]');
   SetLength(l_sValue,l_aLengths2[i]);
   l_pValue := _PTFChar(l_sValue);
   Move(l_aPTFChar2[i]^, l_pValue^, l_aLengths2[i]);
   Assert.AreEqual(l_sValue, l_aStrings[i], 'Assertion failed: l_aPTFChar[i] <> l_aPTFChar2[i]');
 end;
 //
 FreeMem(l_pStorage);
 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Int;
var
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_iValue: TF_int64_t;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Int');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('int');
 l_sAttrName := 'v';
 TF_SetAttrInt(l_pDesc, _PTFChar(l_sAttrName), 31415);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_INT, -1, l_oCApiAttributesTest.TFStatus);

 TF_OperationGetAttrInt(l_pOper, _PTFChar(l_sAttrName), @l_iValue, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 Assert.AreEqual(Integer(l_iValue), 31415, 'Assertion failed: l_iValue <> 31415');

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_IntList;
var
 i, l_iListSize, l_iListTotalSize: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_aInt64, l_aInt64_2:  TArray<TF_int64_t>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_IntList');
 l_aInt64 := [1, 2, 3, 4];
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(int)');
 l_sAttrName := 'v';
 l_iListSize := Length(l_aInt64);
 TF_SetAttrIntList(l_pDesc, _PTFChar(l_sAttrName), @(l_aInt64[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_INT, -1, l_oCApiAttributesTest.TFStatus);

 SetLength(l_aInt64_2, l_iListSize);
 TF_OperationGetAttrIntList(l_pOper, _PTFChar(l_sAttrName), @(l_aInt64_2[0]),
                            l_iListSize, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aInt64[i], l_aInt64_2[i], 'Assertion failed: l_aInt64[i] <> l_aInt64_2[i]');
 end;

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Float;
var
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_fValue: Single;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Float');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('float');
 l_sAttrName := 'v';
 TF_SetAttrFloat(l_pDesc, _PTFChar(l_sAttrName), 2.718);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_FLOAT, -1, l_oCApiAttributesTest.TFStatus);

 TF_OperationGetAttrFloat(l_pOper, _PTFChar(l_sAttrName), @l_fValue, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 Assert.AreEqual(l_fValue, Single(2.718), 'Assertion failed: l_fValue <> 2.718');

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_FloatList;
var
 i, l_iListSize, l_iListTotalSize: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_aFloat, l_aFloat2:  TArray<Single>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_FloatList');
 l_aFloat := [1.414, 2.718, 3.1415];
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(float)');
 l_sAttrName := 'v';
 l_iListSize := Length(l_aFloat);
 TF_SetAttrFloatList(l_pDesc, _PTFChar(l_sAttrName), @(l_aFloat[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_FLOAT, -1, l_oCApiAttributesTest.TFStatus);

 SetLength(l_aFloat2, l_iListSize);
 TF_OperationGetAttrFloatList(l_pOper, _PTFChar(l_sAttrName), @(l_aFloat2[0]),
                            l_iListSize, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aFloat[i], l_aFloat2[i], 'Assertion failed: l_aFloat[i] <> l_aFloat2[i]');
 end;

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Bool;
var
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_lValue: Boolean;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Bool');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('bool');
 l_sAttrName := 'v';
 TF_SetAttrBool(l_pDesc, _PTFChar(l_sAttrName), True);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_BOOL, -1, l_oCApiAttributesTest.TFStatus);

 TF_OperationGetAttrBool(l_pOper, _PTFChar(l_sAttrName), @l_lValue, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 Assert.AreEqual(l_lValue, True, 'Assertion failed: l_lValue <> True');

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_BoolList;
var
 i, l_iListSize, l_iListTotalSize: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_aBool, l_aBool2:  TArray<Boolean>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_BoolList');
 l_aBool := [False, True, True, False, False, True, True];
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(bool)');
 l_sAttrName := 'v';
 l_iListSize := Length(l_aBool);
 TF_SetAttrBoolList(l_pDesc, _PTFChar(l_sAttrName), @(l_aBool[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_BOOL, -1, l_oCApiAttributesTest.TFStatus);

 SetLength(l_aBool2, l_iListSize);
 TF_OperationGetAttrBoolList(l_pOper, _PTFChar(l_sAttrName), @(l_aBool2[0]),
                            l_iListSize, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aBool[i], l_aBool2[i], 'Assertion failed: l_aBool[i] <> l_aBool2[i]');
 end;

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Type;
var
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_iType: Integer;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Type');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('type');
 l_sAttrName := 'v';
 TF_SetAttrType(l_pDesc, _PTFChar(l_sAttrName), Integer(TF_COMPLEX128));
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_TYPE, -1, l_oCApiAttributesTest.TFStatus);

 TF_OperationGetAttrType(l_pOper, _PTFChar(l_sAttrName), @l_iType, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 Assert.AreEqual(l_iType, Integer(TF_COMPLEX128), 'Assertion failed: l_iValue <> TF_COMPLEX128');

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_TypeList;
var
 i, l_iListSize, l_iListTotalSize: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_aType, l_aType2:  TArray<Integer>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_TypeList');
 l_aType := [Integer(TF_FLOAT), Integer(TF_DOUBLE), Integer(TF_HALF), Integer(TF_COMPLEX128)];
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(type)');
 l_sAttrName := 'v';
 l_iListSize := Length(l_aType);
 TF_SetAttrTypeList(l_pDesc, _PTFChar(l_sAttrName), @(l_aType[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_TYPE, -1, l_oCApiAttributesTest.TFStatus);

 SetLength(l_aType2, l_iListSize);
 TF_OperationGetAttrTypeList(l_pOper, _PTFChar(l_sAttrName), @(l_aType2[0]),
                            l_iListSize, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aType[i], l_aType2[i], 'Assertion failed: l_aType[i] <> l_aType2[i]');
 end;

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Shape;
var
 i, l_iListSize: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_iType: Integer;
 l_aPartialShape, l_aValues: TArray<TF_int64_t>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Shape');
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('shape');
 l_sAttrName := 'v';
 TF_SetAttrShape(l_pDesc, _PTFChar(l_sAttrName), Nil, -1);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_SHAPE, -1, l_oCApiAttributesTest.TFStatus);
 TF_OperationGetAttrShape(l_pOper, _PTFChar(l_sAttrName), Nil, 10, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 //
 l_aPartialShape := [17, -1];
 l_iListSize := Length(l_aPartialShape);
 l_pDesc := l_oCApiAttributesTest.Init('shape');
 TF_SetAttrShape(l_pDesc, _PTFChar(l_sAttrName), @(l_aPartialShape[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_SHAPE, l_iListSize, l_oCApiAttributesTest.TFStatus);
 SetLength(l_aValues,l_iListSize);
 TF_OperationGetAttrShape(l_pOper, _PTFChar(l_sAttrName), @(l_aValues[0]), l_iListSize, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aPartialShape[i], l_aValues[i], 'Assertion failed: l_aPartialShape[i] <> l_aValues[i]');
 end;

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_ShapeList;
var
 i, j, n, l_iTotalNDims, l_iListSize, l_iTotalListSize, l_iNumDims: Integer;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_sAttrName: TFString;
 l_iType: Integer;
 l_aShape1, l_aShape2, l_aStorage: TArray<TF_int64_t>;
 l_aList, l_aList2:  TArray<PTF_int64_t>;
 l_pValue2: PTF_int64_t;
 l_iValue1, l_iValue2: TF_int64_t;
 l_aDims: TArray<Integer>;
 l_aValuesNDims: TArray<Integer>;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_ShapeList');
 l_sAttrName := 'v';
 l_aShape1 := [1, 3];
 l_aShape2 := [2, 4, 6];
 l_aList   := [@(l_aShape1[0]), @(l_aShape2[0])];
 l_iListSize := Length(l_aList);
 l_aDims := [Length(l_aShape1), Length(l_aShape2)];
 l_iTotalNDims := Length(l_aShape1) + Length(l_aShape2);
 //
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('list(shape)');
 TF_SetAttrShapeList(l_pDesc, _PTFChar(l_sAttrName), @(l_aList[0]), @(l_aDims[0]), l_iListSize);
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', l_iListSize, TF_ATTR_SHAPE, l_iTotalNDims, l_oCApiAttributesTest.TFStatus);

 {TODO:  Schmiert ab, in TF_OperationGetAttrShapeList
  bei
  std::vector<PartialTensorShape> shapes;
  status->status = tensorflow::GetNodeAttr(oper->node.attrs(), attr_name, &shapes); <-

 SetLength(l_aList2,l_iListSize);
 SetLength(l_aValuesNDims,l_iListSize);
 SetLength(l_aStorage,l_iTotalNDims);
 TF_OperationGetAttrShapeList(l_pDesc, ToPTFChar_@(l_sAttrName),
                              @(l_aList2[0]), @(l_aValuesNDims[0]),
                              l_iListSize, @(l_aStorage[0]),
                              l_iTotalNDims, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 n := 0;
 for i := 0 to l_iListSize-1 do begin
   Assert.AreEqual(l_aDims[i], Integer(l_aValuesNDims[i]), 'Assertion failed: l_aDims[i] <> l_aValuesNDims[i]');
   l_pValue2 := l_aList2[i];
   for j := 0 to l_aValuesNDims[i]-1 do begin
     l_iValue1 := l_aList[i][j];
     l_iValue2 := l_aList2[n];
     Assert.AreEqual(l_iValue1, l_iValue2, 'Assertion failed: l_iValue1 <> l_iValue2');
     Inc(n);
   end;
 end;
 }
{
procedure TF_OperationGetAttrShapeList(
                                      oper: PTF_Operation;
                                      attr_name: PTFChar;
                                      dims: PTF_int64_t;
                                      num_dims: PInteger;
                                      num_shapes: Integer;
                                      storage: PTF_int64_t;
                                      storage_size: Integer;
                                      status: PTF_Status); cdecl;

  void TF_OperationGetAttrShapeList (TF_Operation oper,
    string attr_name,
    long** dims,
    int* num_dims,
    int num_shapes,
    long* storage,
    int storage_size,
    TF_Status status);

TF_CAPI_EXPORT extern void TF_OperationGetAttrShapeList(
    TF_Operation* oper, const char* attr_name,
    int64_t** dims, int* num_dims,
    int num_shapes, int64_t* storage,
    int storage_size, TF_Status* status);
void TF_OperationGetAttrShapeList(TF_Operation* oper, const char* attr_name,
                                  int64_t** values, int* num_dims,
                                  int max_values, int64_t* storage,
                                  int storage_size, TF_Status* status) {


  int64_t* values[list_size];
  int values_ndims[list_size];
  int64_t storage[total_ndims];
  TF_OperationGetAttrShapeList(oper, "v", values, values_ndims, list_size,
                               storage, total_ndims, s_);

}

 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_TensorShapeProto;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_TensorShapeProto');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_TensorShapeProtoList;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_TensorShapeProtoList');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Tensor;
var
 i, l_iDim, l_iTensorType: Integer;
 l_iNumDims, l_iNumDims2: TF_size_t;
 l_sAttrName: TFString;
 l_pOper: PTF_Operation;
 l_pDesc: PTF_OperationDescription;
 l_oCApiAttributesTest: TTFCApiAttributesTest;
 l_aInt8Data:  TArray<Int8>;
 l_arDims:  TArray<Int64>;
 l_pInt8Tensor, l_pInt8Tensor2: PTF_Tensor;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Tensor');
 l_sAttrName := 'v';
 l_aInt8Data := [5, 7];
 l_arDims := [1, 2];
 l_iNumDims := Length(l_arDims);
 //
 l_oCApiAttributesTest := TTFCApiAttributesTest.Create;
 l_pDesc := l_oCApiAttributesTest.Init('tensor');
 l_pInt8Tensor := Int8ArrayTensor(l_arDims, l_iNumDims, l_aInt8Data);
 TF_SetAttrTensor(l_pDesc, _PTFChar(l_sAttrName), l_pInt8Tensor, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 l_pOper := TF_FinishOperation(l_pDesc, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));
 ExpectTFMeta(l_pOper,'v', -1, TF_ATTR_TENSOR, -1, l_oCApiAttributesTest.TFStatus);

 TF_OperationGetAttrTensor(l_pOper, _PTFChar(l_sAttrName), l_pInt8Tensor2, l_oCApiAttributesTest.TFStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_oCApiAttributesTest.TFStatus)),
                 'Assertion failed: ' + TF_Message(l_oCApiAttributesTest.TFStatus));

 l_iTensorType := TF_TensorType(l_pInt8Tensor2);
 l_iNumDims2   := TF_NumDims(l_pInt8Tensor2);
 Assert.AreEqual(Int32(TF_INT8), l_iTensorType, 'Assertion failed: TF_TensorType is not TF_INT8 !');
 Assert.AreEqual(2, Integer(l_iNumDims2), 'Assertion failed: Tensor Dimension ist not 2 !');
 for i := 0 to l_iNumDims2-1 do begin
   l_iDim := TF_Dim(l_pInt8Tensor2,i);
   Assert.AreEqual(Integer(l_arDims[i]), l_iDim, 'Assertion failed: Tensor Dimension[i] is wrong !');
 end;

 TF_DeleteTensor(l_pInt8Tensor);
 l_oCApiAttributesTest.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_TensorList;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_TensorList');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_EmptyList;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_EmptyList');

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelTest.Test_CApiAttributes_Errors;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelTest.Test_CApiAttributes_Errors');

 // MemoryLeaks
 Assert.Pass;
end;


{------------------------------- TLowLevelSpecial -----------------------------}

procedure TLowLevelSpecialTest.Test_CommonOpList;
var
 i, j, l_iCnt: Integer;
 l_iLen, l_iEncodeLen: TF_size_t;
 l_iVal64: Int64;
 l_fVal:  Single;
 c: Char;
 l_iDataType: TF_Datatype;
 l_pntBuf:  PTF_Buffer;
 l_pntOpList: PTF_OpList;
 l_pntOpDef:  PTF_OpDef;
 l_pntOpDefArg:  PTF_OpDefArg;
 l_pntOpDefAttr: PTF_OpDefAttr;
 l_pntTFChar, l_pntOpType, l_pntOpDevice, l_pntArgDefName: PTFChar;
 l_pntArgDefDesc, l_pntAttrType, l_pntAttrName, l_pntAttrDesc: PTFChar;
 l_pntAttrMetadata: PTF_AttrMetadata;
 l_pntAttrValue: PTF_AttrValue;
 l_iAttrValueCase: TF_AttrValueCase;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelSpecial.Test_CommonOpList');
 l_pntBuf := TF_GetAllOpList();

 l_pntOpList := TFEX_AllocOpListFromBuffer(l_pntBuf);
 l_iCnt := TFEX_GetOpListCount(l_pntOpList);
 for i := 0 to l_iCnt-1 do begin
   l_pntOpDef    := TFEX_GetOpDef(l_pntOpList, i);
   l_pntTFChar := TFEX_GetOpDefName(l_pntOpDef);
   l_iCnt    := TFEX_GetOpDefInputArgCount(l_pntOpDef);
   for j := 0 to l_iCnt-1 do begin
     l_pntOpDefArg     := TFEX_GetOpDefInputArg(l_pntOpDef,j);
     l_pntArgDefName   := TFEX_GetOpDefArgDefName(l_pntOpDefArg);
     l_pntArgDefDesc   := TFEX_GetOpDefArgDefDescription(l_pntOpDefArg);
     l_iDataType       := TF_Datatype(TFEX_GetOpDefArgDefDataType(l_pntOpDefArg));
     l_pntAttrType     := TFEX_GetOpDefArgDefTypeAttr(l_pntOpDefArg);
   end;
   l_iCnt    := TFEX_GetOpDefOutputArgCount(l_pntOpDef);
   for j := 0 to l_iCnt-1 do begin
     l_pntOpDefArg     := TFEX_GetOpDefOutputArg(l_pntOpDef,j);
     l_pntArgDefName   := TFEX_GetOpDefArgDefName(l_pntOpDefArg);
     l_pntArgDefDesc   := TFEX_GetOpDefArgDefDescription(l_pntOpDefArg);
     l_iDataType       := TF_Datatype(TFEX_GetOpDefArgDefDataType(l_pntOpDefArg));
     l_pntAttrType     := TFEX_GetOpDefArgDefTypeAttr(l_pntOpDefArg);
   end;
   l_iCnt := TFEX_GetOpDefAttrCount(l_pntOpDef);
    for j := 0 to l_iCnt-1 do begin
     l_pntOpDefAttr    := TFEX_GetOpDefAttr(l_pntOpDef,j);
     l_pntAttrMetadata := TFEX_GetOpDefAttrMetadata(l_pntOpDefAttr);
     l_pntAttrName     := TFEX_GetOpDefAttrName(l_pntOpDefAttr);
     l_pntAttrDesc     := TFEX_GetOpDefAttrDescription(l_pntOpDefAttr);
     l_pntAttrType     := TFEX_GetOpDefAttrType(l_pntOpDefAttr);
     l_pntAttrValue    := TFEX_GetOpDefAttrDefaultValue(l_pntOpDefAttr);
     l_iAttrValueCase  := TFEX_GetAttrValueCase(l_pntAttrValue);
     l_pntTFChar     := TFEX_GetAttrValue_s(l_pntAttrValue);
     l_iVal64          := TFEX_GetAttrValue_i(l_pntAttrValue);
     l_fVal            := TFEX_GetAttrValue_f(l_pntAttrValue);
   end;
  end;

 // Assert.AreEqual('Test', 'Test22', ' <-> Ungleicher Text!!!');

 TFEX_DeleteOpList(l_pntOpList);
 TF_DeleteBuffer(l_pntBuf);

 // MemoryLeaks
 Assert.Pass;
end;

procedure SpecialTestProtCallback(prot_buf: PTFChar; prot_buf_len: TF_size_t); cdecl;
var
 l_sProtText: TFString;
 l_pProtText: PTFChar;
begin
 if prot_buf_len > 0 then begin
{$IFDEF VCL}
   GUIVCLTestRunner.HexProtWriteDesciption('SpecialTestProtCallback');
   GUIVCLTestRunner.HexProtWriteChars(prot_buf, prot_buf_len);
{$ENDIF}
   SetLength(l_sProtText,prot_buf_len);
   l_pProtText := _PTFChar(l_sProtText);
   System.AnsiStrings.StrPCopy(l_pProtText,prot_buf);
   WriteLog(TLogLevel.Information,'  >>>' + l_sProtText);
 end
 else
   WriteLog(TLogLevel.Information,'  >>> SpecialTestProtCallback ist called with 0-Size-String');
end;

procedure TLowLevelSpecialTest.Test_SpecialTest1;
var
 n, lng: Integer;
 l_sProtBuf: TFString;
 l_pProtBuf: PTFChar;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelSpecial.Test_SpecialTest1');
 SetLength(l_sProtBuf,1024);
 l_pProtBuf := _PTFChar(l_sProtBuf);
 n := TFEX_SpecialTest1(l_pProtBuf, 1024, SpecialTestProtCallback);

 // MemoryLeaks
 Assert.Pass;
end;

procedure TLowLevelSpecialTest.Test_SpecialTest2;
var
 n, lng: Integer;
 l_sProtBuf: TFString;
 l_pProtBuf: PTFChar;
begin
 WriteLog(TLogLevel.Information,'Execute TLowLevelSpecial.Test_SpecialTest2');
 SetLength(l_sProtBuf,1024);
 l_pProtBuf := _PTFChar(l_sProtBuf);
 n := TFEX_SpecialTest2(l_pProtBuf, 1024, SpecialTestProtCallback);

 // MemoryLeaks
 Assert.Pass;
end;

{------------------------------------------------------------------------------}

initialization
begin
  TDUnitX.RegisterTestFixture(TLowLevelTest);
  TDUnitX.RegisterTestFixture(TLowLevelSpecialTest);
end;

end.
