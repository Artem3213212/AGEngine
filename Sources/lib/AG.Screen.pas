unit AG.Screen;

{$i main.conf}

{$IFDEF Logs}{$ENDIF}
{$IFDEF 8k}{$ENDIF}
{$IFDEF 4k}{$ENDIF}
{$IFDEF NoResize}{$ENDIF}

interface

uses
  {$IFDEF MSWINDOWS}Winapi.Windows,Winapi.MultiMon,{$ENDIF}
  AG.Types;

type
  TAGScreensInfo=class
    public
      class var SceensCount:Integer;
      class var Screens:array of TAGScreenCoord;
  end;

Implementation

{$IFDEF MSWINDOWS}
function Monitors(hm:HMONITOR;dc:HDC;r:PRect;l:LPARAM):Boolean;stdcall;
begin
  inc(TAGScreensInfo.SceensCount);
  SetLength(TAGScreensInfo.Screens,TAGScreensInfo.SceensCount);

  TAGScreensInfo.Screens[TAGScreensInfo.SceensCount-1]:=TAGScreenCoord.FromTRect(r^);
  Result:=true;
end;

initialization
  TAGScreensInfo.SceensCount:=0;
  EnumDisplayMonitors(0,0,Monitors,0);
{$ENDIF}
{$IFDEF ANDROID}
initialization
  TAGScreensInfo.SceensCount:=1;
  SetLength(TAGScreensInfo.Screens,1);
  with TAGScreensInfo.Screens[0]do
  begin
    X:=0;
    Y:=0;
    W:=1000;
    H:=1000;
  end;
{$ENDIF}
end.