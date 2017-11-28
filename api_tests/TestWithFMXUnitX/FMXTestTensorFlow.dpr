program FMXTestTensorFlow;

uses
  FMX.Forms,
  System.SysUtils,
  DUNitX.Loggers.GUIX in 'DUNitX.Loggers.GUIX.pas' {GUIXTestRunner},
  TensorFlow.DApiUnitTests in '..\TensorFlow.DApiUnitTests.pas',
  TensorFlow.LowLevelUnitTests in '..\TensorFlow.LowLevelUnitTests.pas',
  TensorFlow.LowLevelUnitTestsUtil in '..\TensorFlow.LowLevelUnitTestsUtil.pas',
  TensorFlow._Helpers in '..\..\api\TensorFlow._Helpers.pas',
  TensorFlow.DApi in '..\..\api\TensorFlow.DApi.pas',
  TensorFlow.DApiBase in '..\..\api\TensorFlow.DApiBase.pas',
  TensorFlow.DApiOperations in '..\..\api\TensorFlow.DApiOperations.pas',
  TensorFlow.LowLevelAPI in '..\..\api\TensorFlow.LowLevelAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGUIXTestRunner, GUIXTestRunner);
  Application.Run;
end.
