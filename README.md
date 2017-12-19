# TensorFlow4Delphi
TensorFlow API (Wrapper) for Delphi

Requirements and versions
- Python 3.6 64-bit with installed Tensorflow 1.4.0 64-bit
- Delphi 10.2 Tokyo
  * Set the enviroment variable DUnitX for Path to DUnitX-Source in the IDE options mask.
- Visual Studio 2015 for C-Api-Extensions

There are three DUnitX-Projects for console, fmx and vcl to test the Delphi-API.
My preferred DUnitX-Project is: "api_tests\TestWithVCLUnitX\VCLTestTensorFlow.dproj".
This DUnitX-Project allows you to take a closer look at the Tensorflow API.
The project contains a hex viewer.

For fast solutions with Tensorflow I prefer to use the package "Python4Delphi" (P4D).
Prototyping is done directly in Python and for the later interaction with the users I use
Delphi. See the directory "P4DTensorflowDemos" and the project "P4DDemoControl.dproj". 
The subdirectory "demos\Machine_Learning_with_TensorFlow" contains examples of the book
"Machine Learning with TensorFlow" ( https://github.com/BinRoot/TensorFlow-Book ).


You can find a corrected "Python4Delphi"-Version here:

https://github.com/hartmutdavid/python4delphi

This version includes customizations to Python 3.x, 64bit-Windows and FireDAC.
