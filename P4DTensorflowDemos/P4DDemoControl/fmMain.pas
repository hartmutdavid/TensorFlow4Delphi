unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  System.Types, System.UITypes, System.IOUtils, StrUtils,
  System.Generics.Collections, Variants, System.Math,
  ComCtrls, ExtCtrls, StdCtrls, PythonEngine, PythonGUIInputOutput,
  Grids, WrapDelphi, SynEditHighlighter, SynHighlighterPython, SynEdit,
  Vcl.Menus, Vcl.Buttons, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc;

type
 TDlgType  = (DTUnknown,DTString,DTInteger,DTRadioGroup,DTCheckboxGroup,DTFile,DTDate);
 TPropType = (PTUnknown,PTString,PTInteger,PTBoolArray,PTDateArray);

 TFProp = class
   Name:   String;
   DlgType:   TDlgType;
   PropType:  TPropType;
   WinCtrls:  array of TWinControl;
   constructor Create;
   destructor  Destroy; override;
 end;

 TOneDemoInfo = class
 public
   TFProperties:   TList<TFProp>;
   PythonFileName: String;
   RTFFileName:    String;
   XMLFileName:    String;
   SynEditScript:  TSynEdit;
   RichEdit:       TRichEdit;
   constructor Create;
   destructor  Destroy; override;
 end;

  TMain = class(TForm)
    RichEditOutput: TRichEdit;
    PageControl: TPageControl;
    SplitterBottom: TSplitter;
    TabSheet1: TTabSheet;
    PythonGUIInputOutput: TPythonGUIInputOutput;
    PanelTop: TPanel;
    SynEditScript1: TSynEdit;
    SynPythonSyn: TSynPythonSyn;
    Panel1: TPanel;
    SplitterVert1: TSplitter;
    PythonEngine: TPythonEngine;
    TabSheet0: TTabSheet;
    btnExecuteScript: TButton;
    RichEdit1: TRichEdit;
    txaIntro: TRichEdit;
    ScrollBox1: TScrollBox;
    SplitterHoriz1: TSplitter;
    PopupMenu1: TPopupMenu;
    SaveRTF1: TMenuItem;
    P4DProps: TPythonDelphiVar;
    PanelTFProps1: TPanel;
    dlg_file1: TGroupBox;
    btnOpenFile1: TSpeedButton;
    txfFilename1: TEdit;
    FileOpenDialog1: TOpenDialog;
    dlg_date1: TGroupBox;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    dlg_string1: TGroupBox;
    EditString1: TEdit;
    dlg_integer1: TGroupBox;
    EditInteger1: TEdit;
    dlg_radiogroup1: TRadioGroup;
    dlg_checkboxgroup1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    XMLDocument: TXMLDocument;
    procedure btnExecuteScriptClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveRTFClick(Sender: TObject);
    procedure P4DPropsChange(Sender: TObject);
    procedure P4DPropsExtGetData(Sender: TObject; var Data: PPyObject);
    procedure P4DPropsExtSetData(Sender: TObject; Data: PPyObject);
    procedure btnOpenFile1Click(Sender: TObject);
  private
    m_sDemosDir: String;
    m_arDemoInfo: TList<TOneDemoInfo>;
    m_pyP4DProps: PPyObject;
    function CreateTabSheetPyExample(aIdx: Integer;
                   var aPanelTFProps: TPanel;
                   var aSynEditScript: TSynEdit;
                   var aRichEdit: TRichEdit): Boolean;
    function  CreateTFDelphiProps(aOneDemoInfo: TOneDemoInfo): PPyObject;
    procedure UpdateTFDelphiProps(aProps : PPyObject);
    function  BuildPropDlgString(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropDlgInteger(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropDlgRadioGroup(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropDlgCheckboxGroup(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropDlgFile(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropDlgDate(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
    function  BuildPropsDialog(aPanelTFProps: TPanel; aXMLFileName: String): TList<TFProp>;
  public
  end;

var
  Main: TMain;


implementation


{$R *.DFM}

//------------------------------------------------------------------------------

constructor TFProp.Create;
begin
 Name    := '';
 DlgType := TDlgType.DTUnknown;
 PropType:= TPropType.PTUnknown;
 SetLength(WinCtrls,0);
end;

destructor TFProp.Destroy();
begin
 SetLength(WinCtrls,0);
 inherited Destroy;
end;

//------------------------------------------------------------------------------

constructor TOneDemoInfo.Create;
begin
 inherited Create;
 self.TFProperties   := Nil;
 self.PythonFileName := '';
 self.RTFFileName    := '';
 self.XMLFileName    := '';
 self.SynEditScript  := Nil;
 self.RichEdit := Nil;
end;

destructor TOneDemoInfo.Destroy();
var
 i: Integer;
begin
 if Assigned(self.TFProperties) then begin
   for i := self.TFProperties.Count-1 downto 0 do
     self.TFProperties[i].Free;
   self.TFProperties.Clear;
   self.TFProperties.Free;
   self.TFProperties := Nil;
 end;
 inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TMain.FormShow(Sender: TObject);
var
 l_lOk: Boolean;
 i, j, n: Integer;
 l_sFilePattern, l_sPreFileName, l_sFileName, l_sStr: String;
 l_arFiles: TStringDynArray;
 l_arPyFileNames, l_arRTFFileNames, l_arXMLFileNames: TStringList;
 l_oPanelTFProps:  TPanel;
 l_oSynEditScript: TSynEdit;
 l_oRichEdit: TRichEdit;
 l_oOneDemoInfo: TOneDemoInfo;
begin
 l_sFilePattern := 'E*_*';
 l_arFiles := TDirectory.GetFiles(self.m_sDemosDir, l_sFilePattern, TSearchOption.soTopDirectoryOnly);
 if Length(l_arFiles) > 0 then begin
   l_arPyFileNames  := TStringList.Create;
   l_arRTFFileNames := TStringList.Create;
   l_arXMLFileNames := TStringList.Create;
   for i := Low(l_arFiles) to High(l_arFiles) do begin
     if Pos('.py',l_arFiles[i]) > 0 then
       l_arPyFileNames.Add(l_arFiles[i]);
     if Pos('.rtf',l_arFiles[i]) > 0 then
       l_arRTFFileNames.Add(l_arFiles[i]);
     if Pos('.xml',l_arFiles[i]) > 0 then
       l_arXMLFileNames.Add(l_arFiles[i]);
   end;
   l_arPyFileNames.Sort;
   l_arRTFFileNames.Sort;
   if Pos('E00', l_arRTFFileNames[0]) > 0 then
     txaIntro.Lines.LoadFromFile(l_arRTFFileNames[0]);
   for i := 0 to l_arPyFileNames.Count-1 do begin
     if i > 0 then begin
       l_lOk := self.CreateTabSheetPyExample(i, l_oPanelTFProps, l_oSynEditScript, l_oRichEdit);
     end
     else begin
       l_lOk := True;
       l_oPanelTFProps  := PanelTFProps1;
       l_oSynEditScript := self.SynEditScript1;
       l_oRichEdit      := self.RichEdit1;
       m_arDemoInfo     := TList<TOneDemoInfo>.Create;
     end;
     if l_lOk then begin
       l_oOneDemoInfo := TOneDemoInfo.Create;
       l_oOneDemoInfo.PythonFileName := l_arPyFileNames[i];
       l_oOneDemoInfo.SynEditScript  := l_oSynEditScript;
       l_oOneDemoInfo.RichEdit       := l_oRichEdit;
       //
       l_oSynEditScript.Lines.LoadFromFile(l_arPyFileNames[i]);
       l_sFileName := TPath.GetFileNameWithoutExtension(l_arPyFileNames[i]);
       n := Pos('_',l_sFileName);
       if n > 0 then begin
         l_sPreFileName := Copy(l_sFileName,1,n);
         for j := 0 to l_arRTFFileNames.Count-1 do begin
           if Pos(l_sPreFileName,l_arRTFFileNames[j]) > 0 then begin
             l_oRichEdit.Lines.LoadFromFile(l_arRTFFileNames[j]);
             l_oOneDemoInfo.RTFFileName := l_arRTFFileNames[j];
             break;
           end;
         end;
         for j := 0 to l_arXMLFileNames.Count-1 do begin
           if Pos(l_sPreFileName,l_arXMLFileNames[j]) > 0 then begin
             l_oOneDemoInfo.TFProperties := self.BuildPropsDialog(l_oPanelTFProps, l_arXMLFileNames[j]);
             if Assigned(l_oOneDemoInfo.TFProperties) then begin
               if l_oPanelTFProps.Height > (Panel1.Height div 2) then begin
                 TScrollBox(l_oPanelTFProps.Parent).Height := Panel1.Height div 2;
                 TScrollBox(l_oPanelTFProps.Parent).VertScrollBar.Range := l_oPanelTFProps.Height;
               end
               else
                 TScrollBox(l_oPanelTFProps.Parent).Height := l_oPanelTFProps.Height + 5;
             end
             else begin
               l_oPanelTFProps.Height := 0;
               TScrollBox(l_oPanelTFProps.Parent).Height := 1;
             end;
             l_oOneDemoInfo.XMLFileName := l_arXMLFileNames[j];
             break;
           end;
         end;
       end;
       m_arDemoInfo.Add(l_oOneDemoInfo);
     end;
   end;
   //
   l_arPyFileNames.Clear;
   l_arPyFileNames.Free;
   l_arRTFFileNames.Clear;
   l_arRTFFileNames.Free;
   l_arXMLFileNames.Clear;
   l_arXMLFileNames.Free;
 end;
 PageControl.TabIndex := 0;
 RichEditOutput.Lines.Clear;
end;

procedure TMain.FormCreate(Sender: TObject);
var
 i: Integer;
 l_sStr: String;
begin
 m_arDemoInfo := Nil;
 if System.ParamCount > 0 then begin
   for i := 1 to ParamCount do begin
     l_sStr := UpperCase(ParamStr(i));
     if l_sStr = '-DIR' then begin
       self.m_sDemosDir := Trim(ParamStr(i+1));
     end;
   end;
 end;
 ScrollBox1.Height    := 1;
 PanelTFProps1.Height := 0;
end;

procedure TMain.FormDestroy(Sender: TObject);
var
 i: Integer;
begin
 if Assigned(m_arDemoInfo) then begin
   for i := m_arDemoInfo.Count-1 downto 0 do
     m_arDemoInfo[i].Free;
   m_arDemoInfo.Clear;
   m_arDemoInfo.Free;
 end;
end;

procedure TMain.PageControlChange(Sender: TObject);
begin
 if PageControl.TabIndex = 0 then begin
   // Overview
 end
 else begin
 end;
end;

procedure TMain.SaveRTFClick(Sender: TObject);
var
 l_iPageNo: Integer;
 l_oOneDemoInfo: TOneDemoInfo;
begin
 if Assigned(m_arDemoInfo) then begin
   l_iPageNo := PageControl.TabIndex;
   if (l_iPageNo > 0) and (l_iPageNo <= m_arDemoInfo.Count) then begin
     l_oOneDemoInfo := m_arDemoInfo[l_iPageNo-1];
     if Length(l_oOneDemoInfo.RTFFileName) > 0 then
       l_oOneDemoInfo.RichEdit.Lines.SaveToFile(l_oOneDemoInfo.RTFFileName);
   end;
 end;
end;

procedure TMain.btnExecuteScriptClick(Sender: TObject);
var
 l_iPageNo: Integer;
 l_oOneDemoInfo: TOneDemoInfo;
begin
 RichEditOutput.Lines.Clear;
 if Assigned(m_arDemoInfo) then begin
   l_iPageNo := PageControl.TabIndex;
   if (l_iPageNo > 0) and (l_iPageNo <= m_arDemoInfo.Count) then begin
     l_oOneDemoInfo := m_arDemoInfo[l_iPageNo-1];
     with GetPythonEngine do begin
       if Assigned(l_oOneDemoInfo.TFProperties) then begin
         // Detach from previous object
         Py_XDecRef(m_pyP4DProps);
         // Create new object
         m_pyP4DProps := self.CreateTFDelphiProps(l_oOneDemoInfo);
       end;
       ExecStrings( l_oOneDemoInfo.SynEditScript.Lines );
     end;
   end;
 end;
end;

function  TMain.CreateTFDelphiProps(aOneDemoInfo: TOneDemoInfo): PPyObject;
var
 i, j, l_iVal: Integer;
 l_sVal:    String;
 l_oTFProp: TFProp;
 pyObject : PPyObject;
 l_arVar: array of TVarRec;
 l_pAnsiName: PAnsiChar;
 l_sAnsiName, l_sAnsiDate1, l_sAnsiDate2: AnsiString;
begin
 with GetPythonEngine do begin
   // Create new dictionary
   Result := PyDict_New();
   for i:= 0 to aOneDemoInfo.TFProperties.Count-1 do begin
     l_oTFProp := aOneDemoInfo.TFProperties[i];
     l_sAnsiName := AnsiString(l_oTFProp.Name);
     l_pAnsiName := PAnsiChar(l_sAnsiName);
     //
     case l_oTFProp.DlgType of
       DTString: begin
         l_sVal := TEdit(l_oTFProp.WinCtrls[0]).Text;
       end;
       DTInteger: begin
         l_sVal := TEdit(l_oTFProp.WinCtrls[0]).Text;
         try l_iVal := StrToInt(l_sVal); except end;
       end;
       DTRadioGroup: begin
         l_iVal := TRadioGroup(l_oTFProp.WinCtrls[0]).ItemIndex;
       end;
       DTCheckboxGroup: begin
         SetLength(l_arVar,Length(l_oTFProp.WinCtrls));
         for j := 0 to Length(l_oTFProp.WinCtrls)-1 do begin
           l_arVar[j].VType    := vtBoolean;
           l_arVar[j].VBoolean := TCheckbox(l_oTFProp.WinCtrls[j]).Checked;
         end;
       end;
       DTFile: begin
         l_sVal := TEdit(l_oTFProp.WinCtrls[0]).Text;
       end;
       DTDate: begin
         SetLength(l_arVar,2);
         l_arVar[0].VType := vtString;
         l_arVar[1].VType := vtString;
         l_arVar[0].VAnsiString := Nil;
         l_arVar[1].VAnsiString := Nil;
         if Assigned(l_oTFProp.WinCtrls[0]) then begin
           l_sAnsiDate1 := AnsiString(' ' + DateToStr(TDateTimePicker(l_oTFProp.WinCtrls[0]).Date));
           l_arVar[0].VAnsiString := PAnsiChar(l_sAnsiDate1);
         end;
         if Assigned(l_oTFProp.WinCtrls[1]) then begin
           l_sAnsiDate2 := AnsiString(' ' + DateToStr(TDateTimePicker(l_oTFProp.WinCtrls[1]).Date));
           l_arVar[1].VAnsiString := PAnsiChar(l_sAnsiDate2);
         end;
       end;
     end;
     //
     case l_oTFProp.PropType of
       PTString: begin
         PyDict_SetItemString( Result, l_pAnsiName, VariantAsPyObject(l_sVal) );
       end;
       PTInteger: begin
         PyDict_SetItemString( Result, l_pAnsiName, VariantAsPyObject(l_iVal) );
       end;
       PTBoolArray: begin
         pyObject := ArrayToPyTuple( l_arVar );
         PyDict_SetItemString(Result, l_pAnsiName, pyObject);
       end;
       PTDateArray: begin
         pyObject := ArrayToPyTuple( l_arVar );
         PyDict_SetItemString(Result, l_pAnsiName, pyObject);
       end;
     end;
   end;
 end;
end;

procedure TMain.UpdateTFDelphiProps(aProps: PPyObject );
var
 i, j, n, l_iPageNo, l_iVal: Integer;
 l_oOneDemoInfo: TOneDemoInfo;
 l_oTFProp: TFProp;
 l_sVal:    String;
 l_sAnsiName: AnsiString;
 l_pAnsiName: PAnsiChar;
 l_arVar:     array of TVarRec;
 l_arAnsiVal: array of AnsiString;
 l_oItem: PPyObject;
 l_arCom: Variant;
begin
 l_iPageNo := PageControl.TabIndex;
 if (l_iPageNo > 0) and (l_iPageNo <= m_arDemoInfo.Count) then begin
   l_oOneDemoInfo := m_arDemoInfo[l_iPageNo-1];
   with GetPythonEngine do begin
     // Check if the transmitted object is a dictionary
     if not PyDict_Check(aProps) then
       Exit;
     // Extract our key/values
     for i:= 0 to l_oOneDemoInfo.TFProperties.Count-1 do begin
       l_oTFProp := l_oOneDemoInfo.TFProperties[i];
       l_sAnsiName := AnsiString(l_oTFProp.Name);
       l_pAnsiName := @(l_sAnsiName[1]);
       case l_oTFProp.PropType of
         PTString: begin
           l_sVal := PyObjectAsVariant( PyDict_GetItemString(aProps, l_pAnsiName) );
         end;
         PTInteger: begin
           l_iVal := PyObjectAsVariant( PyDict_GetItemString(aProps, l_pAnsiName) );
           l_sVal := IntToStr(l_iVal);
         end;
         PTBoolArray: begin
           l_arCom := PyObjectAsVariant( PyDict_GetItemString(aProps, l_pAnsiName) );
           if VarIsArray(l_arCom) then begin
             n := VarArrayHighBound( l_arCom, 1 ) + 1;
             SetLength(l_arVar,n);
             for j := 0 to n-1 do begin
               l_iVal := l_arCom[j];
               l_arVar[j].VType    := vtBoolean;
               l_arVar[j].VBoolean := l_arCom[j] > 0;
             end;
           end;
         end;
         PTDateArray: begin
           l_arCom := PyObjectAsVariant( PyDict_GetItemString(aProps, l_pAnsiName) );
           if VarIsArray(l_arCom) then begin
             n := VarArrayHighBound( l_arCom, 1 ) + 1;
             SetLength(l_arAnsiVal,n);
             for j := 0 to n-1 do begin
               l_arAnsiVal[j] := l_arCom[j];
             end;
           end;
         end;
       end;
       //
       case l_oTFProp.DlgType of
         DTString: begin
           TEdit(l_oTFProp.WinCtrls[0]).Text := l_sVal;
         end;
         DTInteger: begin
           TEdit(l_oTFProp.WinCtrls[0]).Text := l_sVal;
         end;
         DTRadioGroup: begin
           TRadioGroup(l_oTFProp.WinCtrls[0]).ItemIndex := l_iVal;
         end;
         DTCheckboxGroup: begin
           n := Min(Length(l_arVar),Length(l_oTFProp.WinCtrls));
           for j := 0 to n-1 do begin
             TCheckbox(l_oTFProp.WinCtrls[j]).Checked := l_arVar[j].VBoolean;
           end;
         end;
         DTFile: begin
           TEdit(l_oTFProp.WinCtrls[0]).Text := l_sVal;
         end;
         DTDate: begin
           n := Min(Length(l_arAnsiVal),Length(l_oTFProp.WinCtrls));
           for j := 0 to n-1 do begin
             if Length(l_arAnsiVal[j]) > 0 then
               try TDateTimePicker(l_oTFProp.WinCtrls[j]).Date := StrToDate(l_arAnsiVal[j]); except end;
           end;
         end;
       end;
     end;
   end;
 end;
end;

procedure TMain.P4DPropsChange(Sender: TObject);
begin
 UpdateTFDelphiProps(m_pyP4DProps);
end;

procedure TMain.P4DPropsExtGetData(Sender: TObject; var Data: PPyObject);
begin
 with GetPythonEngine do begin
   // Return our object
   Data := m_pyP4DProps;
   // Don't forget to increment it, otherwise we would loose property !
   Py_XIncRef(Data);
 end;
end;

procedure TMain.P4DPropsExtSetData(Sender: TObject; Data: PPyObject);
begin
 with GetPythonEngine do begin
   // Check if the transmitted object is a dictionary
   if not PyDict_Check(Data) then
     Exit;
   // Acquire property to the transmitted object
   Py_XIncRef(Data);
   // Release property of our previous object
   Py_XDecRef(m_pyP4DProps);
   // Assisgn transmitted object
   m_pyP4DProps := Data;
 end;
end;

procedure TMain.btnOpenFile1Click(Sender: TObject);
var
 i: Integer;
 l_sFileName: String;
 l_oParent: TWinControl;
 l_oEdit: TEdit;
begin
 if Sender is TSpeedButton then begin
   l_oParent := TSpeedButton(Sender).Parent;
   if l_oParent is TGroupBox then begin
     l_oEdit := Nil;
     for i := 0 to TGroupBox(l_oParent).ControlCount-1 do begin
       if TGroupBox(l_oParent).Controls[i] is TEdit then begin
         l_oEdit := TEdit(TGroupBox(l_oParent).Controls[i]);
         break;
       end;
     end;
     if Assigned(l_oEdit) then begin
       FileOpenDialog1.FileName := l_oEdit.Text;
       FileOpenDialog1.InitialDir := TDirectory.GetCurrentDirectory;
       if FileOpenDialog1.Execute then begin
         l_oEdit.Text := FileOpenDialog1.FileName;
       end;
     end;
   end;
 end;
end;

function TMain.CreateTabSheetPyExample(aIdx: Integer;
                   var aPanelTFProps: TPanel;
                   var aSynEditScript: TSynEdit;
                   var aRichEdit: TRichEdit): Boolean;
var
 l_oOrgTabSheet, l_oNewTabSheet: TTabSheet;
 l_oScrollBox: TScrollBox;
 l_oSplitter:  TSplitter;
 l_oPanelRight: TPanel;
begin
 l_oOrgTabSheet := PageControl.Pages[1];
 l_oNewTabSheet := TTabSheet.Create(self);
 l_oNewTabSheet.PageControl := PageControl;
 l_oNewTabSheet.Caption := 'Example ' + IntToStr(aIdx+1);
 // TSynEdit
 aSynEditScript := TSynEdit.Create(self);
 aSynEditScript.Parent := l_oNewTabSheet;
 aSynEditScript.Left   := SynEditScript1.Left;
 aSynEditScript.Top    := SynEditScript1.Top;
 aSynEditScript.Align  := SynEditScript1.Align;
 aSynEditScript.Height := SynEditScript1.Height;
 aSynEditScript.Width  := SynEditScript1.Width;
 aSynEditScript.ScrollBars := SynEditScript1.ScrollBars;
 aSynEditScript.ReadOnly   := SynEditScript1.ReadOnly;
 aSynEditScript.Options    := SynEditScript1.Options;
 aSynEditScript.Gutter     := SynEditScript1.Gutter;
 aSynEditScript.Highlighter:= SynEditScript1.Highlighter;
 // TSplitter - vert.
 l_oSplitter := TSplitter.Create(self);
 l_oSplitter.Parent := l_oNewTabSheet;
 l_oSplitter.Left   := SplitterVert1.Left;
 l_oSplitter.Top    := SplitterVert1.Top;
 l_oSplitter.Align  := SplitterVert1.Align;
 l_oSplitter.Cursor := SplitterVert1.Cursor;
 l_oSplitter.Height := SplitterVert1.Height;
 l_oSplitter.Width  := SplitterVert1.Width;
 // TPanel
 l_oPanelRight := TPanel.Create(self);
 l_oPanelRight.Parent := l_oNewTabSheet;
 l_oPanelRight.Left   := Panel1.Left;
 l_oPanelRight.Top    := Panel1.Top;
 l_oPanelRight.Align  := Panel1.Align;
 l_oPanelRight.Height := Panel1.Height;
 l_oPanelRight.Width  := Panel1.Width;
 // TScrollBox
 l_oScrollBox := TScrollBox.Create(self);
 l_oScrollBox.Parent := l_oPanelRight;
 l_oScrollBox.Left   := ScrollBox1.Left;
 l_oScrollBox.Top    := ScrollBox1.Top;
 l_oScrollBox.Align  := ScrollBox1.Align;
 l_oScrollBox.Height := ScrollBox1.Height;
 l_oScrollBox.Width  := ScrollBox1.Width;
 l_oScrollBox.VertScrollBar := ScrollBox1.VertScrollBar;
 // TPanel for TFProps
 aPanelTFProps := TPanel.Create(self);
 aPanelTFProps.Parent := l_oScrollBox;
 aPanelTFProps.Left   := PanelTFProps1.Left;
 aPanelTFProps.Top    := PanelTFProps1.Top;
 aPanelTFProps.Align  := PanelTFProps1.Align;
 aPanelTFProps.Height := PanelTFProps1.Height;
 aPanelTFProps.Width  := PanelTFProps1.Width;
 // TSplitter - horiz.
 l_oSplitter := TSplitter.Create(self);
 l_oSplitter.Parent := l_oPanelRight;
 l_oSplitter.Left   := SplitterHoriz1.Left;
 l_oSplitter.Top    := SplitterHoriz1.Top;
 l_oSplitter.Align  := SplitterHoriz1.Align;
 l_oSplitter.Cursor := SplitterHoriz1.Cursor;
 l_oSplitter.Height := SplitterHoriz1.Height;
 l_oSplitter.Width  := SplitterHoriz1.Width;
 // TRichEdit
 aRichEdit := TRichEdit.Create(self);
 aRichEdit.Parent := l_oPanelRight;
 aRichEdit.Align  := alClient;
 aRichEdit.Left   := RichEdit1.Left;
 aRichEdit.Top    := RichEdit1.Top;
 aRichEdit.Align  := RichEdit1.Align;
 aRichEdit.Height := RichEdit1.Height;
 aRichEdit.Width  := RichEdit1.Width;
 aRichEdit.ScrollBars := RichEdit1.ScrollBars;
 aRichEdit.PopupMenu  := RichEdit1.PopupMenu;
 aRichEdit.ReadOnly   := RichEdit1.ReadOnly;
 //
 l_oScrollBox.Height  := 1;
 aPanelTFProps.Height := 0;
 //
 Result := True;
end;

function TMain.BuildPropDlgString(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 l_sName, l_sCaption, l_sPropType, l_sValue: String;
 l_oGroupBox: TGroupBox;
 l_oEdit: TEdit;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;      except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text;   except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sValue    := aNodeElement.ChildNodes.Nodes['value'].Text;     except l_lOk := False; end;
 if l_lOk then begin
   l_oGroupBox := TGroupBox.Create(Self);
   l_oGroupBox.Parent := aPanelTFProps;
   l_oGroupBox.Left   := dlg_string1.Left;
   l_oGroupBox.Top    := aYPos;
   l_oGroupBox.Align  := dlg_string1.Align;
   l_oGroupBox.Height := dlg_string1.Height;
   l_oGroupBox.Width  := dlg_string1.Width;
   l_oGroupBox.Caption:= l_sCaption;
   l_oEdit := TEdit.Create(self);
   l_oEdit.Parent := l_oGroupBox;
   l_oEdit.Left   := EditString1.Left;
   l_oEdit.Top    := EditString1.Top;
   l_oEdit.Align  := EditString1.Align;
   l_oEdit.Height := EditString1.Height;
   l_oEdit.Width  := EditString1.Width;
   l_oEdit.Text   := l_sValue;
   //
   aYPos := aYPos + dlg_string1.Height;
   //
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTString;
   Result.PropType := TPropType.PTString;
   SetLength(Result.WinCtrls,1);
   Result.WinCtrls[0] := l_oEdit;
 end;
end;

function TMain.BuildPropDlgInteger(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 l_sName, l_sCaption, l_sPropType, l_sValue: String;
 l_oGroupBox: TGroupBox;
 l_oEdit: TEdit;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;      except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text;   except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sValue    := aNodeElement.ChildNodes.Nodes['value'].Text;     except l_lOk := False; end;
 if l_lOk then begin
   l_oGroupBox := TGroupBox.Create(Self);
   l_oGroupBox.Parent := aPanelTFProps;
   l_oGroupBox.Left   := dlg_integer1.Left;
   l_oGroupBox.Top    := aYPos;
   l_oGroupBox.Align  := dlg_integer1.Align;
   l_oGroupBox.Height := dlg_integer1.Height;
   l_oGroupBox.Width  := dlg_integer1.Width;
   l_oGroupBox.Caption:= l_sCaption;
   l_oEdit := TEdit.Create(self);
   l_oEdit.Parent := l_oGroupBox;
   l_oEdit.Left   := EditInteger1.Left;
   l_oEdit.Top    := EditInteger1.Top;
   l_oEdit.Align  := EditInteger1.Align;
   l_oEdit.Height := EditInteger1.Height;
   l_oEdit.Width  := EditInteger1.Width;
   l_oEdit.NumbersOnly := EditInteger1.NumbersOnly;
   l_oEdit.Text   := l_sValue;
   //
   aYPos := aYPos + dlg_string1.Height;
   //
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTInteger;
   Result.PropType := TPropType.PTInteger;
   SetLength(Result.WinCtrls,1);
   Result.WinCtrls[0] := l_oEdit;
 end;
end;

function TMain.BuildPropDlgRadioGroup(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 i: Integer;
 l_sName, l_sCaption, l_sPropType, l_sItemsCaption, l_sValue: String;
 l_arItemsCaption, l_arItemsValue: TStringDynArray;
 l_oRadioGroup: TRadioGroup;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;      except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text;   except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sItemsCaption := aNodeElement.ChildNodes.Nodes['items_caption'].Text; except l_lOk := False; end;
 try l_sValue    := aNodeElement.ChildNodes.Nodes['value'].Text;   except l_lOk := False; end;
 if l_lOk then begin
   l_oRadioGroup := TRadioGroup.Create(Self);
   l_oRadioGroup.Parent := aPanelTFProps;
   l_oRadioGroup.Left   := dlg_radiogroup1.Left;
   l_oRadioGroup.Top    := aYPos;
   l_oRadioGroup.Align  := dlg_radiogroup1.Align;
   l_oRadioGroup.Height := dlg_radiogroup1.Height;
   l_oRadioGroup.Width  := dlg_radiogroup1.Width;
   l_oRadioGroup.Caption:= l_sCaption;
   l_oRadioGroup.Columns := dlg_radiogroup1.Columns;
   //
   l_arItemsCaption := StrUtils.SplitString(l_sItemsCaption, ';');
   for i := Low(l_arItemsCaption) to High(l_arItemsCaption) do begin
     l_oRadioGroup.Items.Add(l_arItemsCaption[i]);
   end;
   try l_oRadioGroup.ItemIndex := StrToInt(l_sValue); except l_oRadioGroup.ItemIndex := -1; end;
   //
   aYPos := aYPos + dlg_string1.Height;
   //
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTRadioGroup;
   Result.PropType := TPropType.PTInteger;
   SetLength(Result.WinCtrls,1);
   Result.WinCtrls[0] := l_oRadioGroup;
 end;
end;

function TMain.BuildPropDlgCheckboxGroup(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 l_iCnt: Integer;
 l_sName, l_sCaption, l_sPropType, l_sItemsCaption, l_sItemsValue: String;
 l_arItemsCaption, l_arItemsValue: TStringDynArray;
 l_oGroupBox: TGroupBox;
 l_oCheckbox1, l_oCheckbox2, l_oCheckbox3, l_oCheckbox4: TCheckbox;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;      except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text;   except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sItemsCaption := aNodeElement.ChildNodes.Nodes['items_caption'].Text; except l_lOk := False; end;
 try l_sItemsValue   := aNodeElement.ChildNodes.Nodes['items_value'].Text;   except l_lOk := False; end;
 if l_lOk then begin
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTCheckboxGroup;
   Result.PropType := TPropType.PTBoolArray;
   SetLength(Result.WinCtrls,1);

   l_oGroupBox := TGroupBox.Create(Self);
   l_oGroupBox.Parent := aPanelTFProps;
   l_oGroupBox.Left   := dlg_checkboxgroup1.Left;
   l_oGroupBox.Top    := aYPos;
   l_oGroupBox.Align  := dlg_checkboxgroup1.Align;
   l_oGroupBox.Height := dlg_checkboxgroup1.Height;
   l_oGroupBox.Width  := dlg_checkboxgroup1.Width;
   l_oGroupBox.Caption:= l_sCaption;
   //
   l_arItemsCaption := StrUtils.SplitString(l_sItemsCaption, ';');
   l_arItemsValue   := StrUtils.SplitString(l_sItemsValue, ';');
   l_iCnt := Length(l_arItemsCaption);
   if l_iCnt >= 1 then begin
     SetLength(Result.WinCtrls,l_iCnt);
     l_oCheckbox1 := TCheckbox.Create(Self);
     l_oCheckbox1.Parent := l_oGroupBox;
     l_oCheckbox1.Left   := CheckBox1.Left;
     l_oCheckbox1.Top    := CheckBox1.Top;
     l_oCheckbox1.Align  := CheckBox1.Align;
     l_oCheckbox1.Height := CheckBox1.Height;
     l_oCheckbox1.Width  := CheckBox1.Width;
     l_oCheckbox1.Caption := l_arItemsCaption[0];
     if l_arItemsValue[0] = 'T' then
       l_oCheckbox1.Checked := True
     else
       l_oCheckbox1.Checked := False;
     Result.WinCtrls[0] := l_oCheckbox1;
   end;
   if l_iCnt >= 2 then begin
     l_oCheckbox2 := TCheckbox.Create(Self);
     l_oCheckbox2.Parent := l_oGroupBox;
     l_oCheckbox2.Left   := CheckBox2.Left;
     l_oCheckbox2.Top    := CheckBox2.Top;
     l_oCheckbox2.Align  := CheckBox2.Align;
     l_oCheckbox2.Height := CheckBox2.Height;
     l_oCheckbox2.Width  := CheckBox2.Width;
     l_oCheckbox2.Caption := l_arItemsCaption[1];
     if l_arItemsValue[1] = 'T' then
       l_oCheckbox2.Checked := True
     else
       l_oCheckbox2.Checked := False;
     Result.WinCtrls[1] := l_oCheckbox2;
   end;
   if l_iCnt >= 3 then begin
     l_oCheckbox3 := TCheckbox.Create(Self);
     l_oCheckbox3.Parent := l_oGroupBox;
     l_oCheckbox3.Left   := CheckBox3.Left;
     l_oCheckbox3.Top    := CheckBox3.Top;
     l_oCheckbox3.Align  := CheckBox3.Align;
     l_oCheckbox3.Height := CheckBox3.Height;
     l_oCheckbox3.Width  := CheckBox3.Width;
     l_oCheckbox3.Caption := l_arItemsCaption[2];
     if l_arItemsValue[2] = 'T' then
       l_oCheckbox3.Checked := True
     else
       l_oCheckbox3.Checked := False;
     Result.WinCtrls[2] := l_oCheckbox3;
   end;
   if l_iCnt >= 4 then begin
     l_oCheckbox4 := TCheckbox.Create(Self);
     l_oCheckbox4.Parent := l_oGroupBox;
     l_oCheckbox4.Left   := CheckBox4.Left;
     l_oCheckbox4.Top    := CheckBox4.Top;
     l_oCheckbox4.Align  := CheckBox4.Align;
     l_oCheckbox4.Height := CheckBox4.Height;
     l_oCheckbox4.Width  := CheckBox4.Width;
     l_oCheckbox4.Caption := l_arItemsCaption[3];
     if l_arItemsValue[2] = 'T' then
       l_oCheckbox4.Checked := True
     else
       l_oCheckbox4.Checked := False;
     Result.WinCtrls[3] := l_oCheckbox4;
   end;
   //
   aYPos := aYPos + dlg_string1.Height;
 end;
end;

function TMain.BuildPropDlgFile(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 l_sName, l_sCaption, l_sPropType, l_sValue: String;
 l_oGroupBox: TGroupBox;
 l_oEdit: TEdit;
 l_oBtn: TSpeedButton;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;    except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text; except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sValue    := aNodeElement.ChildNodes.Nodes['value'].Text;   except l_lOk := False; end;
 if l_lOk then begin
   l_oGroupBox := TGroupBox.Create(Self);
   l_oGroupBox.Parent := aPanelTFProps;
   l_oGroupBox.Left   := dlg_file1.Left;
   l_oGroupBox.Top    := aYPos;
   l_oGroupBox.Align  := dlg_file1.Align;
   l_oGroupBox.Height := dlg_file1.Height;
   l_oGroupBox.Width  := dlg_file1.Width;
   l_oGroupBox.Caption:= l_sCaption;
   l_oEdit := TEdit.Create(self);
   l_oEdit.Parent := l_oGroupBox;
   l_oEdit.Left   := txfFilename1.Left;
   l_oEdit.Top    := txfFilename1.Top;
   l_oEdit.Align  := txfFilename1.Align;
   l_oEdit.Height := txfFilename1.Height;
   l_oEdit.Width  := txfFilename1.Width;
   l_oEdit.Text   := l_sValue;
   l_oBtn := TSpeedButton.Create(Self);
   l_oBtn.Parent := l_oGroupBox;
   l_oBtn.Left   := btnOpenFile1.Left;
   l_oBtn.Top    := btnOpenFile1.Top;
   l_oBtn.Align  := btnOpenFile1.Align;
   l_oBtn.Height := btnOpenFile1.Height;
   l_oBtn.Width  := btnOpenFile1.Width;
   l_oBtn.Glyph  := btnOpenFile1.Glyph;
   l_oBtn.OnClick:= btnOpenFile1.OnClick;
   //
   aYPos := aYPos + dlg_string1.Height;
   //
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTFile;
   Result.PropType := TPropType.PTString;
   SetLength(Result.WinCtrls,1);
   Result.WinCtrls[0] := l_oEdit;
 end;
end;

function TMain.BuildPropDlgDate(aNodeElement: IXMLNode; aPanelTFProps: TPanel; var aYPos: Integer): TFProp;
var
 l_lOk: Boolean;
 l_sName, l_sCaption, l_sPropType, l_sValue1, l_sValue2: String;
 l_oGroupBox: TGroupBox;
 l_oDateTime1, l_oDateTime2: TDateTimePicker;
begin
 Result := Nil;
 l_lOk  := True;
 try l_sName     := aNodeElement.ChildNodes.Nodes['name'].Text;      except l_lOk := False; end;
 try l_sCaption  := aNodeElement.ChildNodes.Nodes['caption'].Text;   except l_lOk := False; end;
 try l_sPropType := aNodeElement.ChildNodes.Nodes['prop_type'].Text; except l_lOk := False; end;
 try l_sValue1   := aNodeElement.ChildNodes.Nodes['date_from'].Text; except l_lOk := False; end;
 try l_sValue2   := aNodeElement.ChildNodes.Nodes['date_until'].Text; except l_lOk := False; end;
 if l_lOk then begin
   l_oDateTime1 := Nil;
   l_oDateTime2 := Nil;
   l_oGroupBox := TGroupBox.Create(Self);
   l_oGroupBox.Parent := aPanelTFProps;
   l_oGroupBox.Left   := dlg_file1.Left;
   l_oGroupBox.Top    := aYPos;
   l_oGroupBox.Align  := dlg_file1.Align;
   l_oGroupBox.Height := dlg_file1.Height;
   l_oGroupBox.Width  := dlg_file1.Width;
   l_oGroupBox.Caption:= l_sCaption;
   if Length(l_sValue1) > 5 then begin
     l_oDateTime1 := TDateTimePicker.Create(self);
     l_oDateTime1.Parent := l_oGroupBox;
     l_oDateTime1.Left   := DateTimePicker1.Left;
     l_oDateTime1.Top    := DateTimePicker1.Top;
     l_oDateTime1.Align  := DateTimePicker1.Align;
     l_oDateTime1.Height := DateTimePicker1.Height;
     l_oDateTime1.Width  := DateTimePicker1.Width;
     l_oDateTime1.Date   := StrToDate(l_sValue1);
   end;
   if Length(l_sValue2) > 5 then begin
     l_oDateTime2 := TDateTimePicker.Create(self);
     l_oDateTime2.Parent := l_oGroupBox;
     l_oDateTime2.Left   := DateTimePicker2.Left;
     l_oDateTime2.Top    := DateTimePicker2.Top;
     l_oDateTime2.Align  := DateTimePicker2.Align;
     l_oDateTime2.Height := DateTimePicker2.Height;
     l_oDateTime2.Width  := DateTimePicker2.Width;
     l_oDateTime2.Date   := StrToDate(l_sValue2);
   end;
   //
   aYPos := aYPos + dlg_string1.Height;
   //
   Result := TFProp.Create;
   Result.Name     := l_sName;
   Result.DlgType  := TDlgType.DTDate;
   Result.PropType := TPropType.PTDateArray;
   SetLength(Result.WinCtrls,2);
   Result.WinCtrls[0] := l_oDateTime1;
   Result.WinCtrls[1] := l_oDateTime2;
 end;
end;

function  TMain.BuildPropsDialog(aPanelTFProps: TPanel; aXMLFileName: String): TList<TFProp>;
var
 i, l_iYPos: Integer;
 l_oRootElement, l_oNodeElement, l_oNode: IXMLNode;
 l_oPropList:  IXMLNodeList;
 l_sDlgType, l_sAttrValue: String;
 l_oTFProp: TFProp;
begin
 Result := Nil;
 try
   XMLDocument.FileName := aXMLFileName;
   XMLDocument.Active   := True;
   l_oRootElement := XMLDocument.ChildNodes.FindNode('TFDelphiProps');
   if Assigned(l_oRootElement) then begin
     l_iYPos := 0;
     l_oPropList := l_oRootElement.ChildNodes;
     for i := 0 to l_oRootElement.ChildNodes.Count - 1 do begin
       l_oNodeElement := l_oRootElement.ChildNodes[i];
       if l_oNodeElement.NodeName = 'Prop' then begin
         l_iYPos := l_iYPos + 5;
         l_oNode := l_oNodeElement.ChildNodes.Nodes['dlg_type'];
         l_sDlgType := l_oNode.Text;
         if l_sDlgType = 'dlg_string' then begin
           l_oTFProp := self.BuildPropDlgString(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else if l_sDlgType = 'dlg_integer' then begin
           l_oTFProp := self.BuildPropDlgInteger(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else if l_sDlgType = 'dlg_radiogroup' then begin
           l_oTFProp := self.BuildPropDlgRadioGroup(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else if l_sDlgType = 'dlg_checkboxgroup' then begin
           l_oTFProp := self.BuildPropDlgCheckboxGroup(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else if l_sDlgType = 'dlg_file' then begin
           l_oTFProp := self.BuildPropDlgFile(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else if l_sDlgType = 'dlg_date' then begin
           l_oTFProp := self.BuildPropDlgDate(l_oNodeElement, aPanelTFProps, l_iYPos);
         end
         else begin
           l_oTFProp := Nil;
           RichEditOutput.Lines.Add(Format('XML-File "%s" contains a unknown dlg_type="%s"', [aXMLFileName, l_sDlgType]));
         end;
         if Assigned(l_oTFProp) then begin
           if not Assigned(Result) then
             Result := TList<TFProp>.Create;
           Result.Add(l_oTFProp);
         end
         else
           l_iYPos := l_iYPos - 5;
       end;
     end;
     if l_iYPos > 0 then begin
       aPanelTFProps.Height := l_iYPos + 5;
     end;
   end;
   if XMLDocument.Active then
     XMLDocument.Active   := False;
 except end;
end;

end.

