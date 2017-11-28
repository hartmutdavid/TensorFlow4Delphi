{************************************************}
{                                                }
{  ATFileNotification Component                  }
{  Copyright (C) Alexey Torgashin                }
{  http://www.uvviewsoft.com                     }
{                                                }
{************************************************}

{
ATFileNofitication is a modification of fisFileNotifaction component, which was
originally written by FIS House and is available on http://www.torry.net.
In 2006 year I could not contact FIS House about their original component,
since their home site www.fishouse.com was down.
}

{$BOOLEVAL OFF} //Short boolean evaluation.

unit ATFileNotification;

interface

uses
  Windows, Messages, SysUtils, Classes, VCL.Controls, VCL.ExtCtrls,
  ATxTimer;

type
  TATFileNotifyOption = (
    foNotifyFilename,
    foNotifyDirname, //Applies only for a directory
    foNotifyAttributes,
    foNotifySize,
    foNotifyLastWrite,
    foNotifyLastAccess,
    foNotifyCreation,
    foNotifySecurity //Applies only for a directory
    );

  TATFileNotifyOptions = set of TATFileNotifyOption;

const
  cATFileNotifyFlags: array[TATFileNotifyOption] of DWORD = (
    FILE_NOTIFY_CHANGE_FILE_NAME,
    FILE_NOTIFY_CHANGE_DIR_NAME,
    FILE_NOTIFY_CHANGE_ATTRIBUTES,
    FILE_NOTIFY_CHANGE_SIZE,
    FILE_NOTIFY_CHANGE_LAST_WRITE,
    FILE_NOTIFY_CHANGE_LAST_ACCESS,
    FILE_NOTIFY_CHANGE_CREATION,
    FILE_NOTIFY_CHANGE_SECURITY
    );

type
  TATFileNotification = class(TComponent)
  private
    { Private declarations }
    FStarted: Boolean;
    FSubtree: Boolean;
    FOptions: TATFileNotifyOptions;
    FDirectory: WideString;
    FFileName: WideString;
    FOnChanged: TNotifyEvent;
    FDirThread: TThread;
    FTimer: TOldTimer;
    FLock: TRTLCriticalSection;
    procedure SetDirectory(const ADirectory: WideString);
    procedure SetFileName(const AFileName: WideString);
    procedure Timer(Sender: TObject);
    procedure SetEnabled(AValue: Boolean);
  protected
    { Protected declarations }
    procedure WaitForStarted(AValueToStart: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    property Enabled: Boolean read FStarted write SetEnabled;
  published
    { Published declarations }
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property Options: TATFileNotifyOptions read FOptions write FOptions default [foNotifyFilename, foNotifyDirname, foNotifyLastWrite];
    property Subtree: Boolean read FSubtree write FSubtree default False;
    property Directory: WideString read FDirectory write SetDirectory;
    property FileName: WideString read FFileName write SetFileName;
  end;

var
  sMsgNotifError: AnsiString = 'Error';
  sMsgNotifExceptionWait: AnsiString = 'Exception while waiting for notification';
  sMsgNotifExceptionCreate: AnsiString = 'Exception while creating thread';
  sMsgNotifExceptionTerminate: AnsiString = 'Exception while terminating thread';
  sMsgNotifExceptionTimeOut: AnsiString = 'File Notification system timed out at Start/Stop';

procedure Register;


implementation

{ Helper thread class }

type
  TDirThread = class(TThread)
  private
    prDirectory: WideString;
    prFileName: WideString;
    prKillEvent: THandle;
    prSubtree: Boolean;
    prNotifyFilter: DWORD;
    prTimer: TOldTimer;
  protected
    FParent : TATFileNotification;
    procedure Execute; override;
  public
    constructor Create(const AParent: TATFileNotification;
      const ADirectory, AFileName: WideString;
      ASubtree: Boolean; ANotifyFilter: DWORD; ATimer: TOldTimer);
    destructor Destroy; override;
  end;


{ Helper functions }

type
  TFileRec = record
    FExist: Boolean;
    FSizeLow,
    FSizeHigh: DWORD;
    FAttr: DWORD;
    FTimeWr,
    FTimeCr,
    FTimeAcc: TFileTime;
  end;

procedure FGetFileRec(const FileName: WideString; var Rec: TFileRec);
var
  h: THandle;
  fdA: TWin32FindDataA;
  fdW: TWin32FindDataW;
begin
  FillChar(Rec, SizeOf(Rec), 0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    h := FindFirstFileW(PWideChar(FileName), fdW);
    Rec.FExist := h <> INVALID_HANDLE_VALUE;
    if Rec.FExist then
    begin
      Rec.FSizeLow := fdW.nFileSizeLow;
      Rec.FSizeHigh := fdW.nFileSizeHigh;
      Rec.FAttr := fdW.dwFileAttributes;
      Rec.FTimeWr := fdW.ftLastWriteTime;
      Rec.FTimeCr := fdW.ftCreationTime;
      Rec.FTimeAcc := fdW.ftLastAccessTime;
      Windows.FindClose(h);
    end;
  end
  else
  begin
    h := FindFirstFileA(PAnsiChar(AnsiString(FileName)), fdA);
    Rec.FExist := h <> INVALID_HANDLE_VALUE;
    if Rec.FExist then
    begin
      Rec.FSizeLow := fdA.nFileSizeLow;
      Rec.FSizeHigh := fdA.nFileSizeHigh;
      Rec.FAttr := fdA.dwFileAttributes;
      Rec.FTimeWr := fdA.ftLastWriteTime;
      Rec.FTimeCr := fdA.ftCreationTime;
      Rec.FTimeAcc := fdA.ftLastAccessTime;
      Windows.FindClose(h);
    end;
  end;
end;

function FTimesDif(const Time1, Time2: TFileTime): Boolean;
begin
  Result :=
    (Time1.dwLowDateTime <> Time2.dwLowDateTime) or
    (Time1.dwHighDateTime <> Time2.dwHighDateTime);
end;

function FFileChanged(const FileName: WideString; Filter: DWORD; var OldRec: TFileRec): Boolean;
var
  NewRec: TFileRec;
begin
  FGetFileRec(FileName, NewRec);

  Result :=
    ( OldRec.FExist <> NewRec.FExist ) or
    ( ((Filter and FILE_NOTIFY_CHANGE_ATTRIBUTES) <> 0) and (OldRec.FAttr <> NewRec.FAttr) ) or
    ( ((Filter and FILE_NOTIFY_CHANGE_SIZE) <> 0) and ((OldRec.FSizeLow <> NewRec.FSizeLow) or (OldRec.FSizeHigh <> NewRec.FSizeHigh)) ) or
    ( ((Filter and FILE_NOTIFY_CHANGE_LAST_WRITE) <> 0) and FTimesDif(OldRec.FTimeWr, NewRec.FTimeWr) ) or
    ( ((Filter and FILE_NOTIFY_CHANGE_LAST_ACCESS) <> 0) and FTimesDif(OldRec.FTimeAcc, NewRec.FTimeAcc) ) or
    ( ((Filter and FILE_NOTIFY_CHANGE_CREATION) <> 0) and FTimesDif(OldRec.FTimeCr, NewRec.FTimeCr) );

  if Result then
    Move(NewRec, OldRec, SizeOf(TFileRec));
end;

function FNotifyOptionsToFlags(Options: TATFileNotifyOptions): DWORD;
var
  Opt: TATFileNotifyOption;
begin
  Result := 0;
  for Opt := Low(TATFileNotifyOption) to High(TATFileNotifyOption) do
    if Opt in Options then
      Inc(Result, cATFileNotifyFlags[Opt]);
end;

procedure MsgErr(const S: AnsiString);
begin
  MessageBoxA(0, PAnsiChar(S), PAnsiChar(sMsgNotifError), MB_OK or MB_ICONERROR or MB_APPLMODAL);
end;

{ Unicode versions of SysUtils' functions }

function LastDelimiter(const Delimiters, S: WideString): Integer;
var
  i: Integer;
begin
  for i := Length(S) downto 1 do
    if Pos(S[i], Delimiters) > 0 then
      begin Result := i; Exit end;
  Result := 0;
end;

function SExtractFileDir(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := LastDelimiter('\:', FileName);
  if (I > 1) and (FileName[I] = '\')
    then Dec(I);
  Result := Copy(FileName, 1, I);
end;

{
function SExtractFilePath(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I := LastDelimiter('\:', FileName);
  Result := Copy(FileName, 1, I);
end;
}


{ TDirThread }

constructor TDirThread.Create(const AParent: TATFileNotification;
  const ADirectory, AFileName: WideString;
  ASubtree: Boolean; ANotifyFilter: DWORD; ATimer: TOldTimer);
begin
  inherited Create(False);
  FParent := AParent;
  prKillEvent := CreateEvent(nil, False, False, nil);
  prDirectory := ADirectory;
  prFileName := AFileName;
  prSubtree := ASubtree;
  prNotifyFilter := ANotifyFilter;
  prTimer := ATimer;
end;

destructor TDirThread.Destroy;
begin
  if Assigned(FParent) then
  begin
    if FParent.FStarted then
    begin
      FParent.FStarted := False;
    end;
  end;

  SetEvent(prKillEvent);
  CloseHandle(prKillEvent);

  inherited;
end;


procedure TDirThread.Execute;
var
  ObjList: array[0..1] of THandle;
  NotifyRes: THandle;
  ADir: WideString;
  ASubtree: Boolean;
  AFilter: DWORD;
  AFileRec: TFileRec;
  IsFile: Boolean;
begin
  FillChar(AFileRec, SizeOf(TFileRec), 0);

  IsFile := prFileName <> '';
  if IsFile then
  begin
    ADir := SExtractFileDir(prFileName);
    if (ADir <> '') and (ADir[Length(ADir)] = ':') then
      ADir := ADir + '\'; //Handle the case of 'C:\Filename'
    ASubtree := False;
    AFilter := prNotifyFilter and (not (FILE_NOTIFY_CHANGE_DIR_NAME or FILE_NOTIFY_CHANGE_SECURITY));
    FGetFileRec(prFileName, AFileRec);
  end
  else
  begin
    ADir := prDirectory;
    ASubtree := prSubtree;
    AFilter := prNotifyFilter;
  end;

  //Create notification
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    NotifyRes := FindFirstChangeNotificationW(PWideChar(ADir), ASubtree, AFilter)
  else
    NotifyRes := FindFirstChangeNotificationA(PAnsiChar(AnsiString(ADir)), ASubtree, AFilter);

  ObjList[0] := prKillEvent;
  ObjList[1] := NotifyRes;

  //Wait
  if (NotifyRes <> INVALID_HANDLE_VALUE) then
  try
    if Assigned(FParent) then
    begin
      FPArent.FStarted := True;
    end;
    repeat
      if Terminated or //In some unknown circumstances signaling through prKillEvent may not work,
                       //so there is additional check for Terminated to stop thread
                       //during inherited TThread.Destroy.
        (WaitForMultipleObjects(2, @ObjList, False, INFINITE) = WAIT_OBJECT_0) then
      begin
        Break;
      end;
      if (not IsFile) or (FFileChanged(prFileName, AFilter, AFileRec)) then
      begin
        prTimer.Enabled := True;
      end;
    until not FindNextChangeNotification(ObjList[1]);
    FindCloseChangeNotification(ObjList[1]);
  except
    MsgErr(sMsgNotifExceptionWait);
  end;
end;


{ TATFileNotification }

constructor TATFileNotification.Create(AOwner: TComponent);
begin
  inherited;
  FStarted := False;
  FSubtree := False;
  FDirectory := '';
  FFileName := '';
  FOptions := [foNotifyFilename, foNotifyDirname, foNotifyLastWrite];
  FTimer := TOldTimer.Create(Self);
  with FTimer do
  begin
    Enabled := False;
    Interval := 100;
    OnTimer := Timer;
  end;
  InitializeCriticalSection(FLock);
end;


destructor TATFileNotification.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    Stop;
  end;
  DeleteCriticalSection(FLock);
  inherited;
end;


procedure TATFileNotification.Start;
begin
  try
    EnterCriticalSection(FLock);
    try
      if (not FStarted) then
      begin
        FDirThread := TDirThread.Create(Self,
          FDirectory, FFileName, FSubtree,
          FNotifyOptionsToFlags(FOptions), FTimer);

        {
          FStarted := True;
          thread Will set the FStarted to True when the System is ready to run!!!
        }
      end;
    finally
      LeaveCriticalSection(FLock);
    end;

    WaitForStarted(True);
  except
    MsgErr(sMsgNotifExceptionCreate);
  end;
end;


procedure TATFileNotification.Stop;
begin
  try
    EnterCriticalSection(FLock);
    try
      if FStarted then
      begin
        if Assigned(FDirThread) then
        begin
          FDirThread.Free;
          FDirThread := nil;
        end;
        {
          Thread Should handle this on it's destructor

          FStarted := False;
        }
      end;
    finally
      LeaveCriticalSection(FLock);
    end;

    WaitForStarted(False);
  except
    MsgErr(sMsgNotifExceptionTerminate);
  end;
end;


procedure TATFileNotification.Timer(Sender: TObject);
begin
  FTimer.Enabled := False;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;


procedure TATFileNotification.SetDirectory(const ADirectory: WideString);
begin
  if ADirectory <> FDirectory then
  begin
    FDirectory := ADirectory;
    FFileName := '';
  end;
end;


procedure TATFileNotification.SetFileName(const AFileName: WideString);
begin
  if AFileName <> FFileName then
  begin
    FDirectory := '';
    FFileName := AFileName;
  end;
end;


procedure TATFileNotification.SetEnabled(AValue: Boolean);
begin
  if AValue <> FStarted then
  begin
    if AValue then
      Start
    else
      Stop;
  end;
end;


{ Registration }

procedure Register;
begin
  RegisterComponents('Samples', [TATFileNotification]);
end;

procedure TATFileNotification.WaitForStarted(AValueToStart: Boolean);
const
  cTimeOut = 3000; //wait max 3 sec.
var
  Tick: DWORD;
begin
  Tick := GetTickCount;
  while (Abs(GetTickCount - Tick) < cTimeOut)
    and (FStarted <> AValueToStart) do
    Sleep(40);

  if FStarted <> AValueToStart then
    raise Exception.Create(sMsgNotifExceptionTimeOut);
end;

end.
