program toRGBABMP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,system.classes,winapi.windows;

var
  ProcessInformation:TProcessInformation;
  StartupInfo:TStartupInfo;
  s0,s1,s:string;

begin
s0:=ParamStr(1);
s1:=ParamStr(2);
    //default : 0

if ParamCount=6 then       
  s:=' -crop '+ParamStr(3)+' '+ParamStr(4)+' '+ParamStr(5)+' '+ParamStr(6)
else
  s:='';
    

ZeroMemory(@StartupInfo,SizeOf(STARTUPINFO));
StartupInfo.cb:=SizeOf(STARTUPINFO);
if not CreateProcess(nil,pwidechar('nconvert -set_alpha -c 0 -overwrite -ctype rgba -out bmp'+s+' -o '+s1+' '+s0),nil,nil,False,0,nil,nil,StartupInfo,ProcessInformation)then
  RaiseLastOSError;
WaitForSingleObject(ProcessInformation.hProcess,INFINITE);
CloseHandle(ProcessInformation.hThread);
CloseHandle(ProcessInformation.hProcess);
end.

