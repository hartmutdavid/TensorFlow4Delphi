program VCLTestTensorFlow;

{$R *.res}

uses
  {$IF DEFINED(MSWINDOWS) and DEFINED(DEBUG)}
  FastMM4 in '..\..\third_party\FastMM4\FastMM4.pas',
  {$ENDIF }
  Vcl.Forms,
  System.SysUtils,
  FastMM4Messages in '..\..\third_party\FastMM4\FastMM4Messages.pas',
  DUnitX.Loggers.GUI.VCL in 'DUnitX.Loggers.GUI.VCL.pas' {GUIVCLTestRunner},
  DUnitX.ResStrs in 'DUnitX.ResStrs.pas',
  ATBinHex in '..\..\third_party\ATViewer\ATBinHex.pas',
  HexDataInterpreter in 'HexDataInterpreter.pas' {FormDataInterpreter},
  DUnitX.MemoryLeakMonitor.FastMM4 in 'DUnitX.MemoryLeakMonitor.FastMM4.pas',
  TensorFlow.LowLevelAPI in '..\..\api\TensorFlow.LowLevelAPI.pas',
  TensorFlow.DApi in '..\..\api\TensorFlow.DApi.pas',
  TensorFlow.DApiOperations in '..\..\api\TensorFlow.DApiOperations.pas',
  TensorFlow.DApiBase in '..\..\api\TensorFlow.DApiBase.pas',
  TensorFlow._Helpers in '..\..\api\TensorFlow._Helpers.pas',
  TensorFlow.DApiUnitTests in '..\TensorFlow.DApiUnitTests.pas',
  TensorFlow.LowLevelUnitTests in '..\TensorFlow.LowLevelUnitTests.pas',
  TensorFlow.LowLevelUnitTestsUtil in '..\TensorFlow.LowLevelUnitTestsUtil.pas';

begin
  Application.Initialize;
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  Application.CreateForm(TFormDataInterpreter, FormDataInterpreter);
  Application.Run;
end.
