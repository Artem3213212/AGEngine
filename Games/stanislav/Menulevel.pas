unit MenuLevel;

interface

uses
  System.Classes,System.SysUtils,AG.Levels,AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,
  AG.Resourcer,AG.Physic,AG.Video,winapi.windows,GameElements,AG.ProcessIncluder,
  Level1;

procedure LInit(Core:TAGGraphicCore);  
procedure LStart(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key,lParam:nativeint);

const
  CMenuLevelInfo:TAGLevel=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;Timed:nil);

implementation

procedure LInit(Core:TAGGraphicCore);
begin
Sleep(100);
end;
 
procedure LStart(Core:TAGGraphicCore); 
begin
with defwndcoord do
  Qemu:=TAGIncludedProcessControl.Create(Config.ReadString('Qemu','Path','C:\Program Files\qemu\')
    +'qemu-system-i386w.exe','-cpu pentium -hda '+GetCurrentDir+'\..\Data\FreeDos.qcow2 -m size=64 -display sdl',
    Game.Window,TAGScreenCoord.Create(Round((W-800)/2*H/1080),Round((H-600)/2*H/1080),800,600));
end;
                           
procedure LPaint(Core:TAGGraphicCore);  
begin
end;

procedure LDestoy(Core:TAGGraphicCore);  
begin

end;

procedure LKeydown(key,lParam:nativeint);   
begin

end;

end.