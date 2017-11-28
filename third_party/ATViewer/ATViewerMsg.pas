unit ATViewerMsg;

interface

uses
  Windows;

function MsgBox(const Msg, Title: WideString; Flags: Integer; hWnd: THandle = 0): Integer;
procedure MsgInfo(const Msg: WideString; hWnd: THandle = 0);
procedure MsgError(const Msg: WideString; hWnd: THandle = 0);
procedure MsgWarning(const Msg: WideString; hWnd: THandle = 0);

var
  ATViewerMessagesEnabled: Boolean = True;

var
  MsgViewerCaption: Widestring = 'Viewer';
  MsgViewerShowCfm: Widestring = 'Format unknown'#13'Click here to show binary dump';
  MsgViewerShowEmpty: Widestring = 'File is empty';
  MsgViewerErrCannotFindFile: Widestring = 'File not found: "%s"';
  MsgViewerErrCannotFindFolder: Widestring = 'Folder not found: "%s"';
  MsgViewerErrCannotOpenFile: Widestring = 'Cannot open file: "%s"';
  MsgViewerErrCannotLoadFile: Widestring = 'Cannot load file: "%s"';
  MsgViewerErrCannotReadFile: Widestring = 'Cannot read file: "%s"';
  MsgViewerErrCannotReadStream: Widestring = 'Cannot read stream';
  MsgViewerErrCannotReadPos: Widestring = 'Read error at offset %s';
  MsgViewerErrDetect: Widestring = 'Program could not detect file format'#13'Dump is shown';
  MsgViewerErrImage: Widestring = 'Unknown image format';
  MsgViewerErrMedia: Widestring = 'Unknown multimedia format';
  MsgViewerErrOffice: Widestring = 'MS Office module doesn''t support this file type';
  MsgViewerErrInitControl: Widestring = 'Cannot initialize %s';
  MsgViewerErrInitOffice: Widestring = 'Cannot initialize MS Office control';
  MsgViewerErrCannotCopyData: Widestring = 'Cannot copy data to Clipboard';
  MsgViewerWlxException: Widestring = 'Exception in plugin "%s" in function "%s"';
  MsgViewerWlxParentNotSpecified: Widestring = 'Cannot load plugins: parent form not specified';
  MsgViewerAniTitle: Widestring = 'Title: ';
  MsgViewerAniCreator: Widestring = 'Creator: ';
  MsgViewerPageHint: Widestring = 'Previous/Next page'#13'Current page: %d of %d';

implementation

uses
  SysUtils, VCL.Forms;

function MsgBox(const Msg, Title: WideString; Flags: Integer; hWnd: THandle = 0): Integer;
begin
  if ATViewerMessagesEnabled then
    Result := MessageBoxW(hWnd, PWideChar(Msg), PWideChar(Title),
      Flags or MB_SETFOREGROUND or MB_TASKMODAL)
  else
    Result := IDCANCEL;
end;

procedure MsgInfo(const Msg: WideString; hWnd: THandle = 0);
begin
  MsgBox(Msg, MsgViewerCaption, MB_OK or MB_ICONINFORMATION, hWnd);
end;

procedure MsgError(const Msg: WideString; hWnd: THandle = 0);
begin
  MsgBox(Msg, MsgViewerCaption, MB_OK or MB_ICONERROR, hWnd);
end;

procedure MsgWarning(const Msg: WideString; hWnd: THandle = 0);
begin
  MsgBox(Msg, MsgViewerCaption, MB_OK or MB_ICONEXCLAMATION, hWnd);
end;

end.
