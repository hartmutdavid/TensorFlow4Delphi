rd /s /q api_tests\TestWithVCLUnitX\__history
rd /s /q api_tests\TestWithVCLUnitX\ModelSupport_VCLTestTensorFlow
rd /s /q api_tests\TestWithVCLUnitX\Win64
del /q api_tests\TestWithVCLUnitX\VCLTestTensorFlow.dproj.local
del /q api_tests\TestWithVCLUnitX\VCLTestTensorFlow.identcache
del /q api_tests\TestWithVCLUnitX\VCLTestTensorFlow.stat
del /q api_tests\TestWithVCLUnitX\VCLTestTensorFlow_project.tvsconfig

rd /s /q api_tests\TestWithConsoleDUnitX\__history
rd /s /q api_tests\TestWithConsoleDUnitX\ModelSupport_ConsoleTestTensorFlow
rd /s /q api_tests\TestWithConsoleDUnitX\Win64
del /q api_tests\TestWithConsoleDUnitX\ConsoleTestTensorFlow.dproj.local
del /q api_tests\TestWithConsoleDUnitX\ConsoleTestTensorFlow.identcache
del /q api_tests\TestWithConsoleDUnitX\ConsoleTestTensorFlow.stat
del /q api_tests\TestWithConsoleDUnitX\ConsoleTestTensorFlow_project.tvsconfig

rd /s /q api_tests\TestWithFMXUnitX\__history
rd /s /q api_tests\TestWithFMXUnitX\ModelSupport_FMXTestTensorFlow
rd /s /q api_tests\TestWithFMXUnitX\Win64
del /q api_tests\TestWithFMXUnitX\FMXTestTensorFlow.dproj.local
del /q api_tests\TestWithFMXUnitX\FMXTestTensorFlow.identcache
del /q api_tests\TestWithFMXUnitX\FMXTestTensorFlow.stat
del /q api_tests\TestWithFMXUnitX\FMXTestTensorFlow_project.tvsconfig

del /q bin\ConsoleTestTensorFlow.*
del /q bin\FMXTestTensorFlow.*
del /q bin\VCLTestTensorFlow.*
del /q bin\dunitx.*
del /q bin\*.xml

Pause