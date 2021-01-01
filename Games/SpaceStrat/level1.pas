unit level1;

interface

uses
  System.Classes,System.SysUtils,AG.Levels,AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,
  AG.Resourcer,GameElements,AG.Physic,AG.Video
  {$IFDEF MSWINDOWS},winapi.windows,Winapi.PsAPI{$ENDIF};

procedure LInit(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key:byte;Info:TAGKeyInfo);
procedure LStart(Core:TAGGraphicCore);
procedure LTimed;

const
  CLevel1Info:TAGLevel=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;keydown:LKeydown;Timed:LTimed);

implementation

{$T+}

var
  br:TAGBrush;

procedure LInit(Core:TAGGraphicCore);
begin
end;

procedure LStart(Core:TAGGraphicCore);
begin
  br:=Core.CreateBrush(witecolor);
end;

procedure LPaint(Core:TAGGraphicCore);
begin
with Core do
begin
  Init2D;
  {$IFDEF Debug}
    DrawText(GameInformationString,TAGScreenCoord.Create(40,40,2000,2000),20,AGFont_SystemFont,br);
  {$ENDIF}
end;
end;

procedure LDestoy(Core:TAGGraphicCore);
begin
Core.ReleaseBrush(br);
end;

procedure LKeydown(key:byte;Info:TAGKeyInfo);
begin
  case key of
  27:ExitProcess(0);
  else
  end;
end;

procedure LTimed;
begin

end;

end.
