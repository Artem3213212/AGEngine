unit AG.ProcessIncluder;

interface

uses System.Classes,System.SysUtils,AG.Windows,AG.Game,AG.Types,Winapi.Windows,Winapi.Messages;

type
  TAGIncludedProcessControl=class(TThread)
    private
      ProcessInformation:TProcessInformation;
      StartupInfo:TStartupInfo;
      &File,Command:string;
      hwindow,HChild,HChild2:NativeUInt;
      pos:TAGScreenCoord;
      class function Find(hwnd:NativeUInt;Self:TAGIncludedProcessControl):boolean;static;stdcall;
    public
      constructor Create(&File,Command:string;Window:TAGWindow;pos:TAGScreenCoord);
      procedure Execute;overload;override;
      destructor Destroy;overload;override;
  end;

implementation

constructor TAGIncludedProcessControl.Create(&File,Command:string;Window:TAGWindow;pos:TAGScreenCoord);
begin
ZeroMemory(@StartupInfo,SizeOf(STARTUPINFO));
StartupInfo.cb:=SizeOf(STARTUPINFO);
Self.&File:=&File;
Self.Command:=Command;
//Self.hwindow:=Window.hWindow;
Self.pos:=pos;
HChild:=0;
inherited Create(False);
end;

class function TAGIncludedProcessControl.Find(hwnd:NativeUInt;Self:TAGIncludedProcessControl):boolean;
var
  ii:NativeUInt;
begin
with Self do
  if(GetWindowThreadProcessId(hwnd,addr(ii))=ProcessInformation.dwThreadId)and(ii=ProcessInformation.dwProcessId)
    and((GetParent(hwnd)=0)or(GetParent(hwnd)=hwindow))then
    begin
    SetParent(hwnd,hwindow);

    HChild:=hwnd;
    Result:=False;
    end;
Result:=True;
end;

procedure TAGIncludedProcessControl.Execute;
begin
try
  if not CreateProcess(pwidechar(&File),pwidechar('"'+&File+'" '+Command),nil,nil,False,0,nil,nil,StartupInfo,ProcessInformation)then
    RaiseLastOSError;
  while not Terminated do
  begin
    while not IsWindow(HChild) and not Terminated do
    begin
      EnumWindows(addr(Find),NativeInt(Self));
      Sleep(1);
    end;
    if HChild<>0 then
      HChild2:=HChild;
    SetWindowLong(HChild2,GWL_STYLE,GetWindowLong(HChild2,GWL_STYLE)and not(WS_CAPTION or WS_THICKFRAME or WS_MINIMIZE or WS_MAXIMIZE or WS_SYSMENU));
    with pos do
      SetWindowPos(HChild2,0,X,Y,W,H,0);
    HChild:=0;
  end;
finally
  //
end;
end;

destructor TAGIncludedProcessControl.Destroy;
begin
TerminateProcess(ProcessInformation.hProcess,0);
end;

end.

