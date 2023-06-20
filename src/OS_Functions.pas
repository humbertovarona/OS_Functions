unit OS_Functions;

interface

Type
  TErrLog = (logAPP, logSYS, logOP, logHWD);

function FuncAvail(_dllname, _funcname: string; var _p: pointer): boolean;
function Is64BitOS : Boolean;
procedure HideAllTaskbarIcons;
procedure ShowAllTaskbarIcons;
procedure HideClockInTaskbar;
procedure ShowClockInTaskbar;
function CurrentLocalTimeToFilename(var Hour, Minute, Second : String) : String;
function LogTime(Hour, Minute, Second : String) : String;
procedure WriteLogs(filename : String; DT : String; lType : TErrLog;  msg : String);


implementation

uses
  Windows, SysUtils;

function FuncAvail(_dllname, _funcname: string; var _p: pointer): boolean;
var
  _lib: tHandle;
begin
     Result := false;
     if LoadLibrary(PChar(_dllname)) = 0 then exit;
     _lib := GetModuleHandle(PChar(_dllname));
     if _lib <> 0 then
       begin
         _p := GetProcAddress(_lib, PChar(_funcname));
         if _p <> NIL then Result := true;
       end;
end;

function Is64BitOS: Boolean;
type
  TIsWow64Process = function(Handle:THandle; var IsWow64 : Boolean) : Boolean; stdcall;
var
  hKernel32 : Integer;
  IsWow64Process : TIsWow64Process;
  IsWow64 : Boolean;
begin
  Result := False;
  hKernel32 := LoadLibrary('kernel32.dll');
  if (hKernel32 = 0) then RaiseLastOSError;
  @IsWow64Process := GetProcAddress(hkernel32, 'IsWow64Process');
  if Assigned(IsWow64Process) then begin
    IsWow64 := False;
    if (IsWow64Process(GetCurrentProcess, IsWow64)) then begin
      Result := IsWow64;
    end
    else RaiseLastOSError;
  end;
  FreeLibrary(hKernel32);
end;

procedure HideAllTaskbarIcons;
begin
  ShowWindow(FindWindowEx( FindWindow('Shell_TrayWnd', nil),
                             HWND(0), 'ReBarWindow32', nil),
                             Sw_Hide);
end;

procedure ShowAllTaskbarIcons;
begin
  ShowWindow(FindWindowEx( FindWindow('Shell_TrayWnd', nil),
                             HWND(0), 'ReBarWindow32', nil),
                             Sw_Show);
end;

procedure HideClockInTaskbar;
begin
  ShowWindow(FindWindowEx(FindWindowEx(FindWindow('Shell_TrayWnd', nil),
                                       HWND(0), 'TrayNotifyWnd', nil),
                                       HWND(0), 'TrayClockWClass', nil),
                                        Sw_Hide)
end;

procedure ShowClockInTaskbar;
begin
  ShowWindow(FindWindowEx(FindWindowEx(FindWindow('Shell_TrayWnd', nil),
                                       HWND(0), 'TrayNotifyWnd', nil),
                                       HWND(0), 'TrayClockWClass', nil),
                                        Sw_Show)
end;

function CurrentLocalTimeToFilename(var Hour, Minute, Second : String) : String;
var
  Year, Month, Day, CurrentTime : String;
begin
  CurrentTime := DateTimeToStr(Now);
  Year := Copy(CurrentTime, 1, 4);
  Month := Copy(CurrentTime, 6, 2);
  Day := Copy(CurrentTime, 9, 2);
  Hour := Copy(CurrentTime, 12, 2);
  Minute := Copy(CurrentTime, 15, 2);
  Second := Copy(CurrentTime, 18, 2);
  Result := Year + Month + Day
end;

function LogTime(Hour, Minute, Second : String) : String;
begin
  Result := Hour + ':' + Minute + ':' + Second
end;

procedure WriteLogs(filename : String; DT : String; lType : TErrLog;  msg : String);
var
  Datafile : TextFile;
  Logname, logType : string;
begin
  Logname:= 'C:/Logs/Data/'+ filename + '.log';
  AssignFile(Datafile,Logname);
  if FileExists(Logname) then
    Append(Datafile)
  else
    Rewrite(Datafile);
  Case lType of
    logAPP  : logType := 'SASSCOMM';
    logSYS : logType := 'SYSTEM';
    logOP : logType := 'OPERATION';
    logHWD : logType := 'HARDWARE';
  end;
  Writeln(Datafile, DT, ',', logType, ',', msg);
  CloseFile(Datafile);
end;

end.
