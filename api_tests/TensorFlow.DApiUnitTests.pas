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
unit TensorFlow.DApiUnitTests;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Types, System.IOUtils,
  DUnitX.TestFramework, System.AnsiStrings, System.StrUtils, System.Rtti,
  TensorFlow.LowLevelAPI, TensorFlow.DApiBase, TensorFlow.DApi,
  TensorFlow.DApiOperations;

type
  {$M+}
  //-- [TestFixture('TensorFlow DApi Tests')]
  [TestFixture]
  [IgnoreMemoryLeaks(False)]
  ///<summary>DApi tests.</summary>
  TDApiTest = class
  public
    [Test]
    procedure Test_Status;
    [Test]
    procedure Test_Buffer;
    [Test]
    procedure Test_BasicConstantOps;
    [Test]
    procedure Test_BasicVariables;
    [Test]
    procedure Test_ShowCaseVariable;
    [Test]
    procedure Test_BasicMatrix;
    [Test]
    procedure Test_SumWithAddN;
    [Test]
    procedure Test_Reduce;
//--    [Test]
    procedure Test_LinearRegression;
    //
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

var
 g_lDApiTestsAreInit: Boolean = False;

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

{------------------------------------------------------------------------------}

procedure TDApiTest.Setup;
var
 n: Integer;
begin
 // Every call before single Test
 if not g_lDApiTestsAreInit then begin
   WriteLog(TLogLevel.Information,'Execute TDApiTest.SetupFixture');
   g_aTFProt := Nil;
{$IFDEF FMX}
   TensorFlow.DApiBase.g_aTFProt := GUIXTestRunner.txaProt.Lines;
{$ENDIF}
{$IFDEF VCL}
   TensorFlow.DApiBase.g_aTFProt := GUIVCLTestRunner.rchText.Lines;
{$ENDIF}
   g_lDApiTestsAreInit := True;
 end;
end;

procedure TDApiTest.TearDown;
begin
  // Every call after single Test
 //-- WriteLog(TLogLevel.Information,'Execute TDApiTest.TearDownFixture');
end;

{------------------------------------------------------------------------------}

procedure TDApiTest.Test_Status;
var
 l_iCode:   TF_Code;
 l_sMsg:    TFString;
 l_oStatus: TFStatus;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_Status');

 l_oStatus := TFStatus.Create;
 l_iCode := l_oStatus.StatusCode;
 Assert.IsTrue(l_iCode = TF_Code.TF_OK, 'Assertion failed: Invalid Status Code');
 l_sMsg := l_oStatus.StatusMessage;
 //
 l_oStatus.SetStatusCode(TF_Code.TF_CANCELLED, 'cancel');
 l_iCode := l_oStatus.StatusCode;
 Assert.IsTrue(l_iCode = TF_Code.TF_CANCELLED, 'Assertion failed: Invalid Status Code');
 l_sMsg := l_oStatus.StatusMessage;
 Assert.IsTrue(l_sMsg = 'cancel', 'Assertion failed: Invalid Status Message');
 WriteLog(TLogLevel.Information,' -> l_oStatus.toString by Cancel: ' + l_oStatus.toString());
 //
 l_oStatus.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_Buffer;
var
 l_oOptionsBuffer, l_oMetadataBuffer: TFBuffer;
 l_sOptionsStr:  TFString;
 l_sMetadataStr: TFString;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_Buffer');

 l_oMetadataBuffer := TFBuffer.Create;
 l_oOptionsBuffer := TFBuffer.Create('');

 l_oMetadataBuffer.Free;
 l_oOptionsBuffer.Free;

 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_BasicConstantOps;
var
 s:     TFSession;
 g:     TFGraph;
 a, b:  TFOutput;
 res:   TFTensor;
 val:   TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_BasicConstantOps');
 //
 TFMMEnv.StartMM;
 //
 // Test the manual GetRunner, this could be simpler
 // we should at some point allow Run (a+b) for Integer;
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   a := g.OpConst(_T(4));
   b := g.OpConst(_T(3));
   //--WriteLog(TLogLevel.Information,'- for Integer: a=4 b=3');
   // Add two constants
   res := s.GetRunner().Run(g.OpAdd(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a + b = ' + val.ToString);
   Assert.AreEqual(7, val.AsInteger, 'Assertion failed: a=4 b=3; a+b<>7');
   // Multiply two constants
   res := s.GetRunner().Run(g.OpMul(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a * b = ' + val.ToString);
   Assert.AreEqual(12, val.AsInteger, 'Assertion failed: a=4 b=3; a*b<>12');
   // Division two constants
   res := s.GetRunner().Run(g.OpDiv(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a div b = ' + val.ToString);
   Assert.AreEqual(1, val.AsInteger, 'Assertion failed: a=4 b=3; a div b<>1');
 end;
 s.Free;
 //
 // Test the manual GetRunner, this could be simpler
 // we should at some point allow Run (a+b) for Float;
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   a := g.OpConst(_T(4.0));
   b := g.OpConst(_T(3.0));
   //--WriteLog(TLogLevel.Information,'- for Float: a=4.0 b=3.0');
   // Add two constants
   res := s.GetRunner().Run(g.OpAdd(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a + b = ' + val.ToString);
   Assert.AreEqual(Extended(7.0), val.AsExtended, 'Assertion failed: a=4.0 b=3.0; a+b<>7.0');
   // Multiply two constants
   res := s.GetRunner().Run(g.OpMul(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a * b = ' + val.ToString);
   Assert.AreEqual(Extended(12.0), val.AsExtended, 'Assertion failed: a=4.0 b=3.0; a*b<>12.0');
   // Division two constants
   res := s.GetRunner().Run(g.OpDiv(a, b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a / b = ' + val.ToString);
   Assert.IsTrue(Abs(val.AsExtended-1.33333)<0.001, 'Assertion failed: a=4.0 b=3.0; a/b<>1.33333');
 end;
 s.Free;
 //
 // Test the manual GetRunner, this could be simpler
 // we should at some point allow Run (sin(x)) for Float;
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   a := g.OpConst(_T(PI/4.0));
   b := g.OpConst(_T(PI/2.0));
   //--WriteLog(TLogLevel.Information,'- sin(x): a=PI/4.0 b=PI/2.0');
   //
   res := s.GetRunner().Run(g.OpSin(a));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  sin(a) = ' + val.ToString);
   Assert.IsTrue(Abs(val.AsExtended-0.707106)<0.001, 'Assertion failed: sin(PI/4.0)<>0.707106');
   // Multiply two constants
   res := s.GetRunner().Run(g.OpSin(b));
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  sin(b) = ' + val.ToString);
   Assert.IsTrue(Abs(val.AsExtended-1.0)<0.001, 'Assertion failed: sin(PI/2.0)<>1.0');
 end;
 s.Free;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_BasicVariables;
var
 s:     TFSession;
 g:     TFGraph;
 add, mul: TFOutput;
 res:   TFTensor;
 ten_a, ten_b: TFTensor;
 var_a, var_b: TFOutput;
 runner: TFSessionRunner;
 val:   TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_BasicVariables');
 //
 TFMMEnv.StartMM;
 //
 // We use "shorts" here, so notice the casting to short to get the
 // tensor with the right data type.
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;

   var_a := g.OpPlaceholder(TF_DataType.TF_INT16);
   var_b := g.OpPlaceholder(TF_DataType.TF_INT16);

   add   := g.OpAdd(var_a, var_b);
   mul   := g.OpMul(var_a, var_b);

   ten_a := _TInt16(3);
   ten_b := _TInt16(2);
   //--WriteLog(TLogLevel.Information,'  a=3  b=2');

 	 runner := s.GetRunner();

	 runner.AddInput(var_a, ten_a);
	 runner.AddInput(var_b, ten_b);
   res := runner.Run(add);
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a+b= ' + val.ToString);
   Assert.AreEqual(5, val.AsInteger, 'Assertion failed: a=3 b=2; a+b<>5');

   runner.Reset;

 	 runner.AddInput(var_a, ten_a);
	 runner.AddInput(var_b, ten_b);
   res := runner.Run(mul);
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  a*b= ' + val.ToString);
   Assert.AreEqual(6, val.AsInteger, 'Assertion failed: a=3 b=2; a*b<>6');
end;
 s.Free;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_ShowCaseVariable;
var
 i: Integer;

 s:     TFSession;
 g:     TFGraph;
 l_oStatus:  TFStatus;
 initValue, increment: TFOutput;
 init, update:  TFOperation;
 value, hnd: TFOutput ;
 res:   TFTensor;
 val:   TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_ShowCaseVariable');
 //
 TFMMEnv.StartMM;
 //
 l_oStatus := TFStatus.Create;
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //
   initValue := g.OpConst(_T(1.5));
   increment := g.OpConst(_T(0.5));
   //
   hnd := g.Variable(initValue, init, value);

   // Add 0.5 and assign to the variable.
   // Perhaps using op.AssignAddVariable would be better,
   // but demonstrating with Add and Assign for now.
   update := g.OpAssignVariable(hnd, g.OpAdd(value,increment));

   // Must first initialize all the variables.
   s.GetRunner().AddTarget(init).Run(l_oStatus);

   if l_oStatus.Ok then begin
     // Now print the value, run the update op and repeat
     // Ignore errors.
     for i := 0 to 4 do begin
       res := s.GetRunner().Fetch(value).AddTarget(update).Run();
       //
       val := res.Value;
       //-- WriteLog(TLogLevel.Information,Format('  Result of variable read %d -> %s', [i, val.ToString]));
       if i = 0 then
         Assert.AreEqual(1.5, val.AsExtended, 'Assertion failed: Result of variable <> 1.5')
       else if i = 1 then
         Assert.AreEqual(2.0, val.AsExtended, 'Assertion failed: Result of variable <> 2.0')
       else if i = 2 then
         Assert.AreEqual(2.5, val.AsExtended, 'Assertion failed: Result of variable <> 2.5')
       else if i = 3 then
         Assert.AreEqual(3.0, val.AsExtended, 'Assertion failed: Result of variable <> 3.0')
       else if i = 4 then
         Assert.AreEqual(3.5, val.AsExtended, 'Assertion failed: Result of variable <> 3.5');
     end;
   end;
 end;
 s.Free;
 //
 TFMMEnv.EndMM;
 l_oStatus.Free;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_BasicMatrix;
var
 i: Integer;
 s:     TFSession;
 g:     TFGraph;
 array1, array2, values: TArray<TArray<Double>>;
 matrix1, matrix2, product: TFOutput;
 res:   TFTensor;
 dim1, dim2: TF_int64_t;
 val:   TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_BasicMatrix');
 //
 TFMMEnv.StartMM;
 //
 // 1x2 matrix
 array1 := [[3.0, 3.0]];
 // 2x1 matrix
 array2 := [[2.0], [2.0]];
 //
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //
   matrix1 := g.OpConst(_TADouble(array1));
   matrix2 := g.OpConst(_TADouble(array2));
   //
   product := g.OpMatMul (matrix1, matrix2);
   //
   res := s.GetRunner().Run(product);
   if res.IsArray(dim1,dim2) then begin
     res.GetArray(values);
     //--WriteLog(TLogLevel.Information,' [[3.0, 3.0]] * [[2.0], [2.0]] = [[' + values[0][0].ToString + ']]');
     Assert.AreEqual(12.0, values[0][0], 'Assertion failed: [[3.0, 3.0]] * [[2.0], [2.0]] <> [[12]]');
   end
   else
     Assert.IsTrue(False, 'Assertion failed: Is not an Array!');
 end;
 s.Free;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_SumWithAddN;
var
 i: Integer;
 array_int1, array_int2, array_int3: TArray<Integer>;
 values: TArray<Integer>;
 ten_array1, ten_array2, ten_array3: TFTensor;

 s:     TFSession;
 g:     TFGraph;
 a, b, c:  TFOutput;
 res:   TFTensor;
 val:   TValue;
 ten_a, ten_b: TFTensor;
 addN:  TFOutput;
 inputs: TArray<TFOutput>;
 dim1, dim2: TF_int64_t;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_SumWithAddN');
 //
 TFMMEnv.StartMM;
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //
   //--WriteLog(TLogLevel.Information,'- sum(44,21,33)');
   //
   a := g.OpConst(_T(44));
   b := g.OpConst(_T(21));
   c := g.OpConst(_T(33));
   SetLength(inputs,3);
   inputs[0] := a;
   inputs[1] := b;
   inputs[2] := c;
   addN  := g.OpAddN(inputs);
   //
   res := s.GetRunner().Run(addN);
   //
   val := res.Value;
   //--WriteLog(TLogLevel.Information,'  sum = ' + val.ToString);
   Assert.AreEqual(98, val.AsInteger, 'Assertion failed: sum(44,21,33)<>98');
 end;
 s.Free;
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //
   //--WriteLog(TLogLevel.Information,'- sum([1,2,3],[6,7,8]])');
   //
   array_int1 := [1,2,3];
   ten_array1:= _T(array_int1);
   array_int2 := [6,7,8];
   ten_array2:= _T(array_int2);

   a := g.OpConst(ten_array1);
   b := g.OpConst(ten_array2);
   SetLength(inputs,2);
   inputs[0] := a;
   inputs[1] := b;
   addN  := g.OpAddN(inputs);
   //
   res := s.GetRunner().Run(addN);
   //
   if res.IsArray(dim1,dim2) then begin
     res.GetArray(values);
     //--for i := 0 to Length(values)-1 do
     //--  WriteLog(TLogLevel.Information,'  sum(i=' + IntToStr(i) + ') = ' + values[i].ToString);
     Assert.AreEqual( 7, values[0], 'Assertion failed: sum([1,2,3],[6,7,8])<>[7,9,11]');
     Assert.AreEqual( 9, values[1], 'Assertion failed: sum([1,2,3],[6,7,8])<>[7,9,11]');
     Assert.AreEqual(11, values[2], 'Assertion failed: sum([1,2,3],[6,7,8])<>[7,9,11]');
   end
   else
     Assert.IsTrue(False, 'Assertion failed: Is not an Array!');
 end;
 s.Free;
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //
   //--WriteLog(TLogLevel.Information,'- sum([1,10,100],[2,11,101],[3,12,102])');
   //
   array_int1 := [1,10,100];
   ten_array1:= _T(array_int1);
   array_int2 := [2,11,101];
   ten_array2:= _T(array_int2);
   array_int3 := [3,12,102];
   ten_array3:= _T(array_int3);

   a := g.OpConst(ten_array1);
   b := g.OpConst(ten_array2);
   c := g.OpConst(ten_array3);
   SetLength(inputs,3);
   inputs[0] := a;
   inputs[1] := b;
   inputs[2] := c;
   addN  := g.OpAddN(inputs);
   //
   res := s.GetRunner().Run(addN);
   //
   if res.IsArray(dim1,dim2) then begin
     res.GetArray(values);
     //--for i := 0 to Length(values)-1 do
     //--  WriteLog(TLogLevel.Information,'  sum(i=' + IntToStr(i) + ') = ' + values[i].ToString);
     Assert.AreEqual(  6, values[0], 'Assertion failed: sum([1,10,100],[2,11,101],[3,12,102])<>[6,33,303]');
     Assert.AreEqual( 33, values[1], 'Assertion failed: sum([1,10,100],[2,11,101],[3,12,102])<>[6,33,303]');
     Assert.AreEqual(303, values[2], 'Assertion failed: sum([1,10,100],[2,11,101],[3,12,102])<>[6,33,303]');
   end
   else
     Assert.IsTrue(False, 'Assertion failed: Is not an Array!');
 end;
 s.Free;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_Reduce;
var
 i: Integer;
 dim1, dim2: TF_int64_t;
 s:     TFSession;
 g:     TFGraph;
 arrayInt: TArray<TArray<Integer>>;
 values  : TArray<Integer>;
 x, reduce_sum, axis: TFOutput;
 arrayDim1, arrayDim2, arrayDim3, arrayDim4, arrayDim5, arrayDim6, arrayDim7: TArray<Integer>;
 arrayAxisTensor:  array[1..11] of TFTensor;
 res, arrayIntTensor:   TFTensor;
 y_tf:  TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_Reduce');
 //
 TFMMEnv.StartMM;
 //
 arrayInt := [[1, 2, 3], [4, 5, 6]];
 arrayIntTensor := _T(arrayInt);
 //
 arrayDim1 := [0,0];
 arrayDim2 := [0,-2];
 arrayDim3 := [1,1];
 arrayDim4 := [1,-1];
 arrayDim5 := [0,1];
 arrayDim6 := [-1,-2];
 arrayDim7 := [-2,-1,0,1];
 //
 arrayAxisTensor[1]  := _T(0);
 arrayAxisTensor[2]  := _T(-2);
 arrayAxisTensor[3]  := _T(arrayDim1);
 arrayAxisTensor[4]  := _T(arrayDim2);
 arrayAxisTensor[5]  := _T(1);
 arrayAxisTensor[6]  := _T(-1);
 arrayAxisTensor[7]  := _T(arrayDim3);
 arrayAxisTensor[8]  := _T(arrayDim4);
 arrayAxisTensor[9]  := _T(arrayDim5);
 arrayAxisTensor[10] := _T(arrayDim6);
 arrayAxisTensor[11] := _T(arrayDim7);
 //
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   x := g.OpConst(arrayIntTensor);
   reduce_sum := g.OpReduceSum(x);
   res := s.GetRunner().Run(reduce_sum);
   if res.IsArray(dim1,dim2) then begin
     Assert.IsTrue(False, 'Assertion failed: Is an Array!');
   end
   else begin
     y_tf := res.Value;
     //--WriteLog(TLogLevel.Information,'  ReduceSum y_tf = ' + y_tf.ToString);
     Assert.AreEqual(21, y_tf.AsInteger, 'Assertion failed: ReduceSum y_tf <> 21');
   end;
 end;
 s.Free;
 //
 for i := Low(arrayAxisTensor) to High(arrayAxisTensor) do begin
   s := TFSession.Create();
   with s do begin
     g := s.Graph;
     x := g.OpConst(arrayIntTensor);
     axis := g.OpConst(arrayAxisTensor[i]);
     reduce_sum := g.OpReduceSum(x,axis);
     res := s.GetRunner().Run(reduce_sum);
     if (i >= 1) and (i <= 4) then begin
       if res.IsArray(dim1,dim2) then begin
         Assert.AreEqual(Integer(dim1), 3, 'Assertion failed: dim1 <> 3');
         Assert.AreEqual(Integer(dim2), 0, 'Assertion failed: dim2 <> 0');
         res.GetArray(values);
         Assert.AreEqual(  5, values[0], 'Assertion failed: OpReduceSum((x,axis)<>[5,7,9]');
         Assert.AreEqual(  7, values[1], 'Assertion failed: OpReduceSum((x,axis)<>[5,7,9]');
         Assert.AreEqual(  9, values[2], 'Assertion failed: OpReduceSum((x,axis)<>[5,7,9]');
       end
       else begin
         Assert.IsTrue(False, 'Assertion failed: Is not an Array!');
       end;
     end
     else if (i >= 5) and (i <= 8) then begin
       if res.IsArray(dim1,dim2) then begin
         Assert.AreEqual(Integer(dim1), 2, 'Assertion failed: dim1 <> 2');
         Assert.AreEqual(Integer(dim2), 0, 'Assertion failed: dim2 <> 0');
         res.GetArray(values);
         Assert.AreEqual(  6, values[0], 'Assertion failed: OpReduceSum((x,axis)<>[6,15]');
         Assert.AreEqual( 15, values[1], 'Assertion failed: OpReduceSum((x,axis)<>[6,15]');
       end
       else begin
         Assert.IsTrue(False, 'Assertion failed: Is not an Array!');
       end;
     end
     else if (i >= 9) and (i <= 11) then begin
       if res.IsArray(dim1,dim2) then begin
         Assert.IsTrue(False, 'Assertion failed: Is an Array!');
       end
       else begin
         y_tf := res.Value;
         //--WriteLog(TLogLevel.Information,'  ReduceSum y_tf = ' + y_tf.ToString);
         Assert.AreEqual(21, y_tf.AsInteger, 'Assertion failed: ReduceSum y_tf <> 21');
       end;
     end;
   end;
   s.Free;
 end;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

procedure TDApiTest.Test_LinearRegression;
var
 i, n_samples: Integer;

 s:     TFSession;
 g:     TFGraph;
 train_x, train_y, values: TArray<Double>;
 matrix1, matrix2, product: TFOutput;
 res:   TFTensor;
 dim1, dim2: TF_int64_t;
 val:   TValue;
begin
 WriteLog(TLogLevel.Information,'Execute TDApiTest.Test_LinearRegression');
 //
 TFMMEnv.StartMM;
 //
 // Training data
 train_x := [3.3, 4.4, 5.5, 6.71, 6.93, 4.168, 9.779, 6.182, 7.59, 2.167,
			       7.042, 10.791, 5.313, 7.997, 5.654, 9.27, 3.1];
 train_y := [1.7,2.76,2.09,3.19,1.694,1.573,3.366,2.596,2.53,1.221,
			       2.827,3.465,1.65,2.904,2.42,2.94,1.3];
 //
 n_samples := Length(train_x);
 s := TFSession.Create();   // <- The session implicitly creates the graph, get it.
 with s do begin
   g := s.Graph;
   //TODO:
  end;
 s.Free;
 //
 TFMMEnv.EndMM;
 //
 // MemoryLeaks
 Assert.Pass;
end;

{------------------------------------------------------------------------------}

initialization
begin
  TDUnitX.RegisterTestFixture(TDApiTest);
end;

end.
