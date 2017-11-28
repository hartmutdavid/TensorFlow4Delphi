//The code is taken from Delphi source.
//Copyright (c) Borland corp.
unit ATxTimer;

interface
  uses Windows, Messages, classes, VCL.Forms;
type
  TOldTimer = class(TComponent)
  private
    FInterval: Cardinal;
    FWindowHandle: HWND;
    FOnTimer: TNotifyEvent;
    FEnabled: Boolean;
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: Cardinal);
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Timer; dynamic;
{$IFDEF CLR}
  strict protected
    procedure Finalize; override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: Cardinal read FInterval write SetInterval default 1000;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
  end;

implementation

{ TOldTimer }

constructor TOldTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FInterval := 1000;
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TOldTimer.Destroy;
begin
  FEnabled := False;
{$IFDEF CLR}
  if FWindowHandle <> 0 then
  begin
    UpdateTimer;
    DeallocateHWnd(FWindowHandle);
    FWindowHandle := 0;
  end;
  System.GC.SuppressFinalize(self);
{$ELSE}
  DeallocateHWnd(FWindowHandle);
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF CLR}
procedure TOldTimer.Finalize;
begin
  FEnabled := False;
  if FWindowHandle <> 0 then
  begin
    KillTimer(FWindowHandle, 1);
    DeallocateHWnd(FWindowHandle);
    FWindowHandle := 0;
  end;
  inherited;
end;
{$ENDIF}

procedure TOldTimer.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = WM_TIMER then
      try
        Timer;
      except
        Application.HandleException(Self);
      end
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TOldTimer.UpdateTimer;
begin
  KillTimer(FWindowHandle, 1);
  if (FInterval <> 0) and FEnabled and Assigned(FOnTimer) then
    if SetTimer(FWindowHandle, 1, FInterval, nil) = 0 then
      raise EOutOfResources.Create('No more Timers');
end;

procedure TOldTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    UpdateTimer;
  end;
end;

procedure TOldTimer.SetInterval(Value: Cardinal);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;
    UpdateTimer;
  end;
end;

procedure TOldTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure TOldTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;


end.
