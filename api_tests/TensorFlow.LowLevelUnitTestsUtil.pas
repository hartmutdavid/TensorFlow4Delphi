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
unit TensorFlow.LowLevelUnitTestsUtil;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Types, Generics.Collections, System.AnsiStrings,
  DUnitX.TestFramework,
  TensorFlow.LowLevelAPI, TensorFlow._Helpers;

var
 g_sPlaceholder: TFString = 'Placeholder';
 g_sConst      : TFString = 'Const';
 g_sDType      : TFString = 'dtype';

 g_aTensorList:  TList<PTF_Tensor>;

type

TTFSession = class
 private
   m_pSession:     PTF_Session;
   m_aInputs:      TArray<TF_Output>;
   m_aInputValues: TArray<PTF_Tensor>;
   m_aOutputs:     TArray<TF_Output>;
   m_aOutputValues: TArray<PTF_Tensor>;
   m_aTargets:     TArray<PTF_Operation>;
   procedure DeleteInputs();
   procedure DeleteInputValues();
   procedure ResetOutputs();
   procedure ResetOutputValues();
 public
   constructor Create(graph: PTF_Graph; status: PTF_Status);
   destructor  Destroy; override;
   procedure SetInputs(opers: TArray<PTF_Operation>; tensors: TArray<PTF_Tensor>);
   procedure SetOutputs(opers: TArray<PTF_Operation>); overload;
   procedure SetOutputs(outp:  TArray<TF_Output>);  overload;
   procedure CloseAndDelete(status: PTF_Status);
   procedure Run(status: PTF_Status);
   function  OutputTensor(i: Integer): PTF_Tensor;
end;

TTFExample = class
 private
   lng_: Int64;
   buf_:   AnsiString;
 public
   constructor Create;
   destructor  Destroy; override;
   procedure init;
   procedure add_ivalue(ival: Integer);
   procedure add_fvalue(fval: Single);
   function SerializeAsString(): TFString;
end;

TTFCApiWhileLoopTest = class
 private
   m_pStatus:  PTF_Status;
   m_pGraph:   PTF_Graph;
   m_pTFSession: TTFSession;
 public
   inputs_:   TArray<TF_Output>;    // The inputs to the while loop
   outputs_:  TArray<TF_Output>;    // The final outputs of the while loop
   original_graph_description_: AnsiString;  // Used to verify that errors don't change graph_
   params_:   TF_WhileParams;
   constructor Create;
   destructor  Destroy; override;
   procedure Init(ninputs: Integer);
   procedure ExpectOK;
   procedure ExpectError(expected_code: TF_Code; const expected_msg: AnsiString);
   procedure Run(input_values: TArray<Int32>);
   procedure ExpectOutputValue(idx: Integer; expected_value: Integer);
   procedure CreateCondGraph;    // Create a valid conditional graph. Useful for testing unrelated errors.
   property  TFStatus: PTF_Status read m_pStatus write m_pStatus;
   property  Graph:  PTF_Graph  read m_pGraph  write m_pGraph;
   property  TFSession: TTFSession read m_pTFSession;
end;

TTFCApiAttributesTest = class
 private
   m_iCounter: Integer;
   m_pStatus:  PTF_Status;
   m_pGraph:   PTF_Graph;
 public
   constructor Create;
   destructor  Destroy; override;
   function  Init(i_sType: TFString): PTF_OperationDescription;
   property  TFStatus: PTF_Status read m_pStatus write m_pStatus;
   property  Graph:  PTF_Graph  read m_pGraph  write m_pGraph;
   property  Counter: Integer read m_iCounter write m_iCounter;
end;

//------------------------------------------------------------------------------

function NodeDefToDebugString(l_pNodeDef: PTF_NodeDef; var o_sAnsiTextBuffer: AnsiString): Integer;
function GraphToDebugString(i_pGraph: PTF_Graph; var o_sAnsiTextBuffer: AnsiString): Integer;

//------------------------------------------------------------------------------

/// <summary>Create a tensor with values of type TF_INT8 provided by v.</summary>
function Int32Tensor(v: Int32): PTF_Tensor;
/// <summary>Create a tensor with values of type TF_FLOAT provided by v.</summary>
function FloatTensor(v: Single): PTF_Tensor;
/// <summary>Create a tensor with values of type TF_STRING provided by v.</summary>
function StringTensor(v: TFString): PTF_Tensor;
function Int8ArrayTensor(dims: TArray<TF_int64_t>; num_dims: Integer;
                         values: TArray<Int8>): PTF_Tensor;
function FloatArrayTensor(dims: TArray<TF_int64_t>; num_dims: Integer;
                          values: TArray<Single>): PTF_Tensor;
function StringArrayTensor(values: TArray<TFString>): PTF_Tensor;
function PlaceholderOp(graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'feed'): PTF_Operation;     // feed: im Sinne von zuführen ...
function ConstOp(tensor: PTF_Tensor; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'const'): PTF_Operation;
function ScalarConstOp(v: Int32; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'scalar'): PTF_Operation;
function AddOp(l, r: PTF_Operation; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'add'): PTF_Operation; overload
function AddOp(l, r: TF_Output; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'add'): PTF_Operation; overload;
function IsPlaceholder(node_def: PTF_NodeDef): Boolean;
function IsScalarConst(node_def: PTF_NodeDef; v: Integer): Boolean;
function IsAddN(node_def: PTF_NodeDef; n: Integer): Boolean;
function LessThanOp(l, r: TF_Output; graph: PTF_Graph; status: PTF_Status): PTF_Operation;
function NegOp(n: PTF_Operation; graph: PTF_Graph; status: PTF_Status): PTF_Operation;
function GetNodeDef(oper: PTF_Operation): PTF_NodeDef;
function GetGraphDef(graph: PTF_Graph): PTF_GraphDef;
function IsNeg(const node_def: PTF_NodeDef; const input: PTFChar): Boolean;

//------------------------------------------------------------------------------
procedure CreateTensorList;
procedure ClearTensorList;
procedure ClearAndFreeTensorList;


implementation

//------------------------------------------------------------------------------

constructor TTFSession.Create(graph: PTF_Graph; status: PTF_Status);
var
 l_pOpts: PTF_SessionOptions;
begin
 inherited Create;
 SetLength(m_aInputs, 0);
 SetLength(m_aInputValues, 0);
 SetLength(m_aOutputs, 0);
 SetLength(m_aOutputValues, 0);
 SetLength(m_aTargets, 0);
 //
 l_pOpts := TF_NewSessionOptions();
 self.m_pSession := TF_NewSession(graph, l_pOpts, status);
 TF_DeleteSessionOptions(l_pOpts);
end;

destructor TTFSession.Destroy();
var
 l_pStatus: PTF_Status;
begin
 l_pStatus := TF_NewStatus();
 self.CloseAndDelete(l_pStatus);
 TF_DeleteStatus(l_pStatus);
 SetLength(m_aInputs, 0);
 SetLength(m_aInputValues, 0);
 SetLength(m_aOutputs, 0);
 SetLength(m_aOutputValues, 0);
 SetLength(m_aTargets, 0);
 inherited Destroy;
end;

procedure TTFSession.CloseAndDelete(status: PTF_Status);
begin
 DeleteInputs();
 DeleteInputValues();
 ResetOutputs();
 ResetOutputValues();
 if (Assigned(m_pSession)) then begin
   try
     TF_CloseSession(m_pSession, status);
     TF_DeleteSession(m_pSession, status);
   except end;
   m_pSession := Nil;
 end;
end;

procedure TTFSession.SetInputs(opers: TArray<PTF_Operation>; tensors: TArray<PTF_Tensor>);
var
 i: Integer;
begin
 DeleteInputs();
 DeleteInputValues();
 Assert.AreEqual(High(opers), High(tensors), 'Assertion failed: High(opers) <> High(tensors)');
 SetLength(m_aInputs,Length(opers));
 SetLength(m_aInputValues,Length(opers));
 for i := Low(opers) to High(opers) do begin
   m_aInputs[i].oper := opers[i];
   m_aInputs[i].index:= 0;
   m_aInputValues[i] := tensors[i];
 end;
end;

procedure TTFSession.SetOutputs(opers: TArray<PTF_Operation>);
var
 i: Integer;
begin
 ResetOutputs();
 ResetOutputValues();
 SetLength(m_aOutputs,Length(opers));
 for i := Low(opers) to High(opers) do begin
   m_aOutputs[i].oper := opers[i];
   m_aOutputs[i].index:= 0;
 end;
end;

procedure TTFSession.SetOutputs(outp:  TArray<TF_Output>);
var
 i: Integer;
begin
 ResetOutputs();
 ResetOutputValues();
 SetLength(m_aOutputs,Length(outp));
 for i := Low(outp) to High(outp) do begin
   m_aOutputs[i].oper := outp[i].oper;
   m_aOutputs[i].index:= outp[i].index;
 end;
end;

procedure TTFSession.Run(status: PTF_Status);
var
 i, l_iInputsCnt, l_iOutputsCnt, l_iTargetsCnt: Integer;
 l_pInputs, l_pOutputs: PTF_Output;
 l_pInputValues, l_pOutputValues: PTF_Tensor;
 l_pTargets: PTF_Operation;
begin
 if Length(m_aInputs) <> Length(m_aInputValues) then
   Assert.IsTrue(False, 'Assertion failed: Call SetInputs() before Run()');
 //
 ResetOutputValues();
 SetLength(m_aOutputValues,Length(m_aOutputs));
 for i := 0 to Length(m_aOutputValues)-1 do
   m_aOutputValues[i] := Nil;
 //
 if Length(m_aInputs) = 0 then
   l_pInputs := Nil
 else
   l_pInputs := @(m_aInputs[0]);
 if Length(m_aInputValues) = 0 then
   l_pInputValues := Nil
 else
   l_pInputValues := @(m_aInputValues[0]);
 if Length(m_aOutputs) = 0 then
   l_pOutputs := Nil
 else
   l_pOutputs := @(m_aOutputs[0]);
 if Length(m_aOutputValues) = 0 then
   l_pOutputValues := Nil
 else
   l_pOutputValues := @(m_aOutputValues[0]);
 if Length(m_aTargets) = 0 then
   l_pTargets := Nil
 else
   l_pTargets := @(m_aTargets[0]);
 l_iInputsCnt := Length(m_aInputs);
 l_iOutputsCnt:= Length(m_aOutputs);
 l_iTargetsCnt:= Length(m_aTargets);
 TF_SessionRun(m_pSession, Nil, l_pInputs, l_pInputValues,
               l_iInputsCnt, l_pOutputs, l_pOutputValues,
               l_iOutputsCnt, l_pTargets, l_iTargetsCnt, Nil, status);
 DeleteInputValues();
end;

function  TTFSession.OutputTensor(i: Integer): PTF_Tensor;
begin
 Result := m_aOutputValues[i];
end;

procedure TTFSession.DeleteInputs();
begin
 SetLength(m_aInputs,0);
end;

procedure TTFSession.DeleteInputValues();
var
 i: Integer;
begin
 for i := 0 to Length(m_aInputValues)-1 do begin
   if Assigned(m_aInputValues[i]) then
     TF_DeleteTensor(m_aInputValues[i]);
 end;
 SetLength(m_aInputValues,0);
end;

procedure TTFSession.ResetOutputs();
begin
 SetLength(m_aOutputs,0);
end;

procedure TTFSession.ResetOutputValues();
var
 i: Integer;
begin
 for i := 0 to Length(m_aOutputValues)-1 do begin
   if Assigned(m_aOutputValues[i]) then
     TF_DeleteTensor(m_aOutputValues[i]);
 end;
 SetLength(m_aOutputValues,0);
end;

//------------------------------------------------------------------------------

constructor TTFExample.Create;
begin
 self.init;
end;

destructor TTFExample.Destroy;
begin
 SetLength(buf_,0);
 inherited Destroy;
end;

procedure TTFExample.init;
begin
 lng_ := 0;
 SetLength(buf_,lng_);
end;

procedure TTFExample.add_ivalue(ival: Integer);
var
 l_iNewLng: Integer;
 l_pInt: PInteger;
begin
 l_iNewLng := lng_ + sizeof(Integer);
 SetLength(buf_,l_iNewLng);
 l_pInt := PInteger(@(buf_[lng_+1]));
 l_pInt^ := ival;
 lng_ := l_iNewLng;
end;

procedure TTFExample.add_fvalue(fval: Single);
var
 l_iNewLng: Integer;
 l_pFloat: PSingle;
begin
 l_iNewLng := lng_ + sizeof(Single);
 SetLength(buf_,l_iNewLng);
 l_pFloat  := PSingle(@(buf_[lng_+1]));
 l_pFloat^ := fval;
 lng_ := l_iNewLng;
end;

function TTFExample.SerializeAsString(): TFString;
var
 i, l_iLen: Integer;
 l_aPreExampleBytes: TBytes;
 l_fFloatVal: Single;
 l_pFloatVal: PSingle;
 l_sStr: TFString;
begin
 if lng_ > 0 then begin
   l_aPreExampleBytes := [$0A,$0F,$0A,$0D,$0A,$01,$78,$12,$08,$12,$06,$0A,$04];
   l_iLen    := Length(l_aPreExampleBytes);
   SetLength(l_sStr,l_iLen);
   for i := Low(l_aPreExampleBytes) to High(l_aPreExampleBytes) do
     l_sStr[i+1] := AnsiChar(l_aPreExampleBytes[i]);
   Result := l_sStr + buf_;
 end
 else
   Result := '';
end;

//------------------------------------------------------------------------------

constructor TTFCApiWhileLoopTest.Create;
begin
 m_pStatus := TF_NewStatus();
 m_pGraph  := TF_NewGraph();
 m_pTFSession := Nil;
end;

destructor TTFCApiWhileLoopTest.Destroy;
begin
 SetLength(inputs_,0);
 if Assigned(m_pTFSession) then
   m_pTFSession.Free;
 TF_DeleteGraph(m_pGraph);
 TF_DeleteStatus(m_pStatus);
 inherited Destroy;
end;

procedure TTFCApiWhileLoopTest.Init(ninputs: Integer);
var
 i: Integer;
 l_pOp: PTF_Operation;
 l_pInputs: PTF_Output;
 l_sId: TFString;
begin
 SetLength(inputs_,0);
 if ninputs > 0 then begin
   SetLength(inputs_,ninputs);
   SetLength(outputs_,ninputs);
   for i := 0 to ninputs-1 do begin
     l_sId := 'p' + IntToStr(i);
     l_pOp := PlaceholderOp(m_pGraph, m_pStatus, l_sId);
     inputs_[i].oper  := l_pOp;
     inputs_[i].index := 0;
     // Initialize outputs_ so we can easily detect errors/bugs
     outputs_[i].oper  := Nil;
     outputs_[i].index := 0;
   end;
   GraphToDebugString(self.m_pGraph, self.original_graph_description_);
   l_pInputs := @(inputs_[0]);
   params_ := TF_NewWhile(m_pGraph, l_pInputs, ninputs, m_pStatus);
   params_.name := 'test_loop';
 end;
end;

procedure TTFCApiWhileLoopTest.ExpectOK;
begin
 TF_FinishWhile(@params_, m_pStatus, @(outputs_[0]));
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(m_pStatus)), 'Assertion failed: ' + TF_Message(m_pStatus));
end;

procedure TTFCApiWhileLoopTest.ExpectError(expected_code: TF_Code; const expected_msg: AnsiString);
begin
 TF_FinishWhile(@params_, m_pStatus, @(outputs_[0]));
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(m_pStatus)), 'Assertion failed: ' + TF_Message(m_pStatus));
    // TODO(skyewm): this assert is currently broken. Fix or remove guarantee.
    // ASSERT_EQ(original_graph_description_, GraphDebugString()) <<
    //     "TF_FinishWhile() altered graph on error";
end;

procedure TTFCApiWhileLoopTest.Run(input_values: TArray<Int32>);
var
 i, n1, n2: Integer;
 l_aInputOpers:   TArray<PTF_Operation>;
 l_aOutputOpers:  TArray<PTF_Operation>;
 l_aInputTensors: TArray<PTF_Tensor>;
begin
 n1 := Length(inputs_);
 n2 := Length(input_values);
 Assert.AreEqual(n1, n2, 'Assertion failed: Length(inputs_) <> Length(input_values)');
 if Assigned(m_pTFSession) then
   m_pTFSession.Free;
 m_pTFSession:= TTFSession.Create(m_pGraph,m_pStatus);
 SetLength(l_aInputOpers,n1);
 SetLength(l_aInputTensors,n1);
 for i := 0 to n1-1 do begin
   l_aInputTensors[i] := Int32Tensor(input_values[i]);
   l_aInputOpers[i]   := inputs_[i].oper;
 end;
 m_pTFSession.SetInputs(l_aInputOpers, l_aInputTensors);
 m_pTFSession.SetOutputs(outputs_);
 m_pTFSession.Run(m_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(m_pStatus)), 'Assertion failed: ' + TF_Message(m_pStatus));
end;

procedure TTFCApiWhileLoopTest.ExpectOutputValue(idx: Integer; expected_value: Integer);
var
 l_pOut: PTF_Tensor;
 l_pInt32: PInt32;
begin
 l_pOut := m_pTFSession.OutputTensor(idx);
 Assert.IsTrue(Assigned(l_pOut), 'Assertion failed: l_pOut is Nil');
 Assert.AreEqual(Integer(TF_INT32), Integer(TF_TensorType(l_pOut)), 'Assertion failed: TensorType <> TF_INT32');
 Assert.AreEqual(0, Integer(TF_NumDims(l_pOut)), 'Assertion failed: TF_NumDims <> 0');
 Assert.AreEqual(sizeof(Int32), Integer(TF_TensorByteSize(l_pOut)), 'Assertion failed: TF_TensorByteSize <> sizeof(Int32)');
 l_pInt32 := TF_TensorData(l_pOut);
 Assert.AreEqual(l_pInt32^, expected_value, 'Assertion failed: Data <> expected_value');
end;

procedure TTFCApiWhileLoopTest.CreateCondGraph;    // Create a valid conditional graph. Useful for testing unrelated errors.
var
 l_pOneOp, l_pLessThanOp: PTF_Operation;
 l, r: TF_Output;
begin
 l_pOneOp := ScalarConstOp(1, params_.cond_graph, m_pStatus);
 l := params_.cond_inputs^;
 r.oper  := l_pOneOp;
 r.index := 0;
 l_pLessThanOp := LessThanOp(l, r, m_pGraph, m_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(m_pStatus)), 'Assertion failed: ' + TF_Message(m_pStatus));
 params_.cond_output.oper  := l_pLessThanOp;
 params_.cond_output.index := 0;
end;

//------------------------------------------------------------------------------

constructor TTFCApiAttributesTest.Create;
begin
 m_iCounter := 0;
 m_pStatus  := TF_NewStatus();
 m_pGraph   := TF_NewGraph();
end;

destructor  TTFCApiAttributesTest.Destroy;
begin
 TF_DeleteGraph(m_pGraph);
 TF_DeleteStatus(m_pStatus);
 inherited Destroy;
end;

function TTFCApiAttributesTest.Init(i_sType: TFString): PTF_OperationDescription;
var
 n: Integer;
 l_sOpType, l_sOpName, l_sStr: TFString;
begin
 // Construct op_name to match the name used by REGISTER_OP
 l_sOpType := 'CApiAttributesTestOp';
 if Pos('list(',i_sType) > 0 then begin
   l_sOpType := l_sOpType + 'List';
   l_sStr := Copy(i_sType,6,999);
   n := Pos(')',l_sStr);
   if n > 0 then
     l_sStr[n] := ' ';
   i_sType := Trim(l_sStr);
 end;
 l_sOpType := l_sOpType + i_sType;
 Inc(m_iCounter);
 l_sOpName := 'name' + IntToStr(m_iCounter);
 Result := TF_NewOperation(m_pGraph,@(l_sOpType[1]),@(l_sOpName[1]));
end;

//------------------------------------------------------------------------------

function GraphToDebugString(i_pGraph: PTF_Graph; var o_sAnsiTextBuffer: AnsiString): Integer;
var
 lng: Integer;
 l_pStatus: PTF_Status;
 l_pGraphDefBuffer: PTF_Buffer;
 l_pGraphDef: PTF_GraphDef;
 l_pStr, l_pDestStr: PTFChar;
begin
 Result := 0;
 l_pStatus := TF_NewStatus();
 l_pGraphDefBuffer := TF_NewBuffer();
 TF_GraphToGraphDef(i_pGraph, l_pGraphDefBuffer, l_pStatus);
 l_pGraphDef := TFEX_AllocGraphDefFromBuffer(l_pGraphDefBuffer);
 l_pStr := TFEX_AllocGraphDefDebugString(l_pGraphDef);
 //
 lng := System.AnsiStrings.Strlen(l_pStr);
 SetLength(o_sAnsiTextBuffer,lng);
 l_pDestStr := @(o_sAnsiTextBuffer[1]);
 System.AnsiStrings.StrCopy(l_pDestStr,l_pStr);
 //
 TFEX_DeleteDebugString(l_pStr);
 TFEX_DeleteGraphDef(l_pGraphDef);
 TF_DeleteBuffer(l_pGraphDefBuffer);
 TF_DeleteStatus(l_pStatus);
 Result := lng;
end;

function NodeDefToDebugString(l_pNodeDef: PTF_NodeDef; var o_sAnsiTextBuffer: AnsiString): Integer;
var
 lng: Integer;
 l_pStr, l_pDestStr: PTFChar;
begin
 l_pStr := TFEX_AllocNodeDefDebugString(l_pNodeDef);
 lng := System.AnsiStrings.Strlen(l_pStr);
 SetLength(o_sAnsiTextBuffer,lng);
 l_pDestStr := @(o_sAnsiTextBuffer[1]);
 System.AnsiStrings.StrCopy(l_pDestStr,l_pStr);
 TFEX_DeleteDebugString(l_pStr);
 Result := lng;
end;

//------------------------------------------------------------------------------

function Int32Tensor(v: Int32): PTF_Tensor;
var
 l_iLen:      TF_size_t;
 l_lDeallocator_called: Boolean;
 l_pntInt32: PInt32;
begin
 l_iLen   := 1 * sizeof(Int32);
 GetMem(l_pntInt32, l_iLen);
 l_pntInt32^ := v;
 l_lDeallocator_called := False;
 Result := TF_NewTensor(Int32(TF_INT32), Nil, 0,
                      l_pntInt32, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
end;

function FloatTensor(v: Single): PTF_Tensor;
var
 l_iLen:      TF_size_t;
 l_lDeallocator_called: Boolean;
 l_pntSingle: PSingle;
begin
 l_iLen   := 1 * sizeof(Single);
 GetMem(l_pntSingle, l_iLen);
 l_pntSingle^ := v;
 l_lDeallocator_called := False;
 Result := TF_NewTensor(Int32(TF_FLOAT), Nil, 0,
                      l_pntSingle, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
end;

function StringTensor(v: TFString): PTF_Tensor;
var
 l_iLen:      TF_size_t;
 l_lDeallocator_called: Boolean;
 l_pntChar, l_pntSrc:  PTFChar;
begin
 l_iLen   := Length(v) * sizeof(TFChar);
 GetMem(l_pntChar, l_iLen);
 l_pntSrc := PTFChar(v);
 Move(l_pntSrc^, l_pntChar^, l_iLen);
 l_lDeallocator_called := False;
 Result := TF_NewTensor(Int32(TF_STRING), Nil, 0,
                      l_pntChar, l_iLen, Deallocator_For_TensorDatas,
                      @l_lDeallocator_called);
end;

function Int8ArrayTensor(dims: TArray<TF_int64_t>; num_dims: Integer;
                         values: TArray<Int8>): PTF_Tensor;
var
 i: Integer;
 l_iNumValues: TF_int64_t;
 l_pTensor: PTF_Tensor;
 l_pData:   Pointer;
 l_pVal:    PInt8;
begin
 l_iNumValues := 1;
 for i := 0 to num_dims-1 do
   l_iNumValues := l_iNumValues * dims[i];
 l_pTensor := TF_AllocateTensor(Integer(TF_INT8), PTF_int64_t(@dims[0]), num_dims,
                                sizeof(Int8) * l_iNumValues);
 l_pData   := TF_TensorData(l_pTensor);
 l_pVal    := PInt8(@values[0]);
 Move(l_pVal^, l_pData^, sizeof(Int8) * l_iNumValues);
 Result := l_pTensor;
end;

function FloatArrayTensor(dims: TArray<TF_int64_t>; num_dims: Integer;
                          values: TArray<Single>): PTF_Tensor;
var
 i: Integer;
 l_iNumValues: TF_int64_t;
 l_pTensor: PTF_Tensor;
 l_pData:  Pointer;
 l_pVal:   PSingle;
begin
 l_iNumValues := 1;
 for i := 0 to num_dims-1 do
   l_iNumValues := l_iNumValues * dims[i];
 l_pTensor := TF_AllocateTensor(Integer(TF_FLOAT), PTF_int64_t(@dims[0]), num_dims,
                                sizeof(Single) * l_iNumValues);
 l_pData   := TF_TensorData(l_pTensor);
 l_pVal    := PSingle(@values[0]);
 Move(l_pVal^, l_pData^, sizeof(Single) * l_iNumValues);
 Result := l_pTensor;
end;

function StringArrayTensor(values: TArray<TFString>): PTF_Tensor;
var
 l_iDim1, l_iByteSize: TF_int64_t;
 l_lDeallocator_called: Boolean;
 l_pData: Pointer;
 l_aDims: array[0..0] of TF_int64_t;
begin
 l_pData := _AllocMem(values, l_iDim1, l_iByteSize);
 l_aDims[0] := l_iDim1;
 Result := TF_NewTensor(Int32(TF_STRING), PTF_int64_t(@l_aDims[0]), 1,
                        l_pData, l_iByteSize, Deallocator_For_TensorDatas,
                        @l_lDeallocator_called);
end;

function PlaceholderOp(graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'feed'): PTF_Operation;
var
 l_oDesc: PTF_OperationDescription;
begin
 l_oDesc := TF_NewOperation(graph, PTFChar(g_sPlaceholder), PTFChar(name));
 TF_SetAttrType(l_oDesc, PTFChar(g_sDType), Integer(TF_INT32));
 Result := TF_FinishOperation(l_oDesc, status);
end;

function ConstOp(tensor: PTF_Tensor; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'const'): PTF_Operation;
var
 l_pntDesc: PTF_OperationDescription;
begin
 l_pntDesc := TF_NewOperation(graph, 'Const', PTFChar(name));
 TF_SetAttrTensor(l_pntDesc, 'value', tensor, status);
 if TF_GetCode(status) = TF_OK then begin
   TF_SetAttrType(l_pntDesc, 'dtype', Integer(TF_TensorType(tensor)));
   Result := TF_FinishOperation(l_pntDesc, status);
 end
 else begin
   Result := Nil;
 end;
end;

function ScalarConstOp(v: Int32; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'scalar'): PTF_Operation;
var
 l_pTensor: PTF_Tensor;
begin
 l_pTensor := Int32Tensor(v);
 if Assigned(l_pTensor) then begin
   g_aTensorList.Add(l_pTensor);
   Result := ConstOp(l_pTensor, graph, status, name);
 end
 else begin
   Result := Nil;
 end;
end;

function AddOp(l, r: PTF_Operation; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'add'): PTF_Operation;
var
 l_pDesc: PTF_OperationDescription;
 l_aAddInputs: array[0..1] of TF_Output;
begin
 l_pDesc := TF_NewOperation(graph, PTFChar('AddN'), PTFChar(name));
 l_aAddInputs[0].oper := l;
 l_aAddInputs[0].index:= 0;
 l_aAddInputs[1].oper := r;
 l_aAddInputs[1].index:= 0;
 TF_AddInputList(l_pDesc, PTF_Output(@l_aAddInputs[0]), 2);
 Result := TF_FinishOperation(l_pDesc, status);
end;

function AddOp(l, r: TF_Output; graph: PTF_Graph; status: PTF_Status;
                 const name: TFString = 'add'): PTF_Operation;
var
 l_pDesc: PTF_OperationDescription;
 l_aAddInputs: array[0..1] of TF_Output;
begin
 l_pDesc := TF_NewOperation(graph, PTFChar('AddN'), PTFChar(name));
 l_aAddInputs[0] := l;
 l_aAddInputs[1] := r;
 TF_AddInputList(l_pDesc, PTF_Output(@l_aAddInputs[0]), 2);
 Result := TF_FinishOperation(l_pDesc, status);
end;

function IsPlaceholder(node_def: PTF_NodeDef): Boolean;
var
 l_lFoundDType, l_lFoundShape: Boolean;
 l_sOp, l_sName, l_sKey: TFString;
 l_iType: Int32;
 l_pAttrMap: PTF_AttrMap;
 l_pAttrVal: PTF_AttrValue;
begin
 Result := True;
 l_sOp  := TFEX_GetNodeDefOp(node_def);
 l_sName:= TFEX_GetNodeDefName(node_def);
 if (l_sOp <> 'Placeholder') or (l_sName <> 'feed') then begin
   Result := False;
 end
 else begin
   l_lFoundDType := False;
   l_lFoundShape := False;
   l_pAttrMap := TFEX_GetNodeDefAttrMap(node_def);
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'dtype');
     l_iType    := TFEX_GetAttrValueType(l_pAttrVal);
     if l_iType = Int32(TF_INT32) then
       l_lFoundDType := True;
   except end;
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'shape');
     l_lFoundShape := True;
   except end;
   Result := l_lFoundDType and l_lFoundShape;
 end;
end;

function IsScalarConst(node_def: PTF_NodeDef; v: Integer): Boolean;
var
 l_iCnt, l_iVal: Integer;
 l_lFoundDType, l_lFoundValue: Boolean;
 l_sOp, l_sName, l_sKey: TFString;
 l_iType: Int32;
 l_pAttrMap: PTF_AttrMap;
 l_pAttrVal: PTF_AttrValue;
 l_pTensor:  PTF_Tensor;
begin
 Result := True;
 l_sOp  := TFEX_GetNodeDefOp(node_def);
 l_sName:= TFEX_GetNodeDefName(node_def);
 if (l_sOp <> 'Const') or (l_sName <> 'scalar') then begin
   Result := False;
 end
 else begin
   l_lFoundDType := False;
   l_lFoundValue := False;
   l_pAttrMap := TFEX_GetNodeDefAttrMap(node_def);
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'dtype');
     l_iType    := TFEX_GetAttrValueType(l_pAttrVal);
     if l_iType = Int32(TF_INT32) then
       l_lFoundDType := True;
   except end;
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'value');
     if TFEX_AttrValueHasTensor(l_pAttrVal) > 0 then begin
       l_pTensor := TFEX_GetAttrValue_tensor(l_pAttrVal);
       l_iCnt  := TFEX_TensorIntValCount(l_pTensor);
       l_iVal  := TFEX_TensorIntVal(l_pTensor,0);
       if (l_iCnt = 1) and (l_iVal = v) then
         l_lFoundValue := True;
     end;
   except end;
   Result := l_lFoundDType and l_lFoundValue;
 end;
end;

function IsAddN(node_def: PTF_NodeDef; n: Integer): Boolean;
var
 i, l_iInputSize: Integer;
 l_lFound_t, l_lFound_n: Boolean;
 l_sOp, l_sName, l_sKey: TFString;
 l_iType: Int32;
 l_pAttrMap: PTF_AttrMap;
 l_pAttrVal: PTF_AttrValue;
begin
 Result := True;
 l_sOp  := TFEX_GetNodeDefOp(node_def);
 l_sName:= TFEX_GetNodeDefName(node_def);
 l_iInputSize := TFEX_GetNodeDefInputCount(node_def);
 if (l_sOp <> 'AddN') or (l_sName <> 'add') or (l_iInputSize <> n) then begin
   Result := False;
 end
 else begin
   l_lFound_t := False;
   l_lFound_n := False;
   l_pAttrMap := TFEX_GetNodeDefAttrMap(node_def);
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'T');
     l_iType    := TFEX_GetAttrValueType(l_pAttrVal);
     if l_iType = Int32(TF_INT32) then
       l_lFound_t := True;
   except end;
   try
     l_pAttrVal := TFEX_GetAttrMapAt(l_pAttrMap,'N');
     i := TFEX_GetAttrValue_i(l_pAttrVal);
     if i = n then
       l_lFound_n := True;
   except end;
   Result := l_lFound_t and l_lFound_n;
 end;
end;

function LessThanOp(l, r: TF_Output; graph: PTF_Graph; status: PTF_Status): PTF_Operation;
var
 l_pDesc: PTF_OperationDescription;
begin
 l_pDesc := TF_NewOperation(graph, 'Less', 'less_than');
 TF_AddInput(l_pDesc, l);
 TF_AddInput(l_pDesc, r);
 Result := TF_FinishOperation(l_pDesc, status);
end;

function NegOp(n: PTF_Operation; graph: PTF_Graph; status: PTF_Status): PTF_Operation;
var
 l_pDesc: PTF_OperationDescription;
 l_oNegInputs: TF_Output;
begin
 l_pDesc := TF_NewOperation(graph, PTFChar('Neg'), PTFChar('neg'));
 l_oNegInputs.oper  := n;
 l_oNegInputs.index := 0;
 TF_AddInput(l_pDesc,l_oNegInputs);
 Result := TF_FinishOperation(l_pDesc, status);
end;

function GetNodeDef(oper: PTF_Operation): PTF_NodeDef;
var
 l_pStatus: PTF_Status;
 l_pBuffer: PTF_Buffer;
begin
 Result := Nil;
 l_pStatus := TF_NewStatus();
 l_pBuffer := TF_NewBuffer();
 TF_OperationToNodeDef(oper,l_pBuffer,l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Result := TFEX_AllocNodeDefFromBuffer(l_pBuffer);
 TF_DeleteBuffer(l_pBuffer);
 TF_DeleteStatus(l_pStatus);
end;

function GetGraphDef(graph: PTF_Graph): PTF_GraphDef;
var
 l_pStatus: PTF_Status;
 l_pBuffer: PTF_Buffer;
begin
 Result := Nil;
 l_pStatus := TF_NewStatus();
 l_pBuffer := TF_NewBuffer();
 TF_GraphToGraphDef(graph, l_pBuffer, l_pStatus);
 Assert.AreEqual(Integer(TF_OK), Integer(TF_GetCode(l_pStatus)), 'Assertion failed: ' + TF_Message(l_pStatus));
 Result := TFEX_AllocGraphDefFromBuffer(l_pBuffer);
 TF_DeleteBuffer(l_pBuffer);
 TF_DeleteStatus(l_pStatus);
end;

function IsNeg(const node_def: PTF_NodeDef; const input: PTFChar): Boolean;
var
 l_iCnt: Integer;
 l_sOp, l_sName, l_iInp: TFString;
begin
 l_sOp  := TFEX_GetNodeDefOp(node_def);
 l_sName:= TFEX_GetNodeDefName(node_def);
 l_iCnt := TFEX_GetNodeDefInputCount(node_def);
 l_iInp := TFEX_GetNodeDefInput(node_def,0);
 Result := (l_sOp=TFString('Neg')) and (l_sName=TFString('neg')) and
           (l_iCnt=1) and (l_iInp=input);
end;

//------------------------------------------------------------------------------

procedure CreateTensorList;
begin
 g_aTensorList := TList<PTF_Tensor>.Create;
end;

procedure ClearTensorList;
var
 i: Integer;
begin
 if g_aTensorList.Count > 0 then begin
   for i := 0 to g_aTensorList.Count-1 do begin
     if Assigned(g_aTensorList[i]) then begin
       TF_DeleteTensor(g_aTensorList[i]);
       g_aTensorList[i] := Nil;
     end;
   end;
   g_aTensorList.Clear;
 end;
end;

procedure ClearAndFreeTensorList;
var
 i: Integer;
begin
 ClearTensorList;
 g_aTensorList.Free;
 g_aTensorList := Nil;
end;

initialization
 CreateTensorList;

finalization
 ClearAndFreeTensorList;

end.
