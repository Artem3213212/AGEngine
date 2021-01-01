unit Pylvl;

interface

uses
  AG.Levels,AG.Graphic,AG.STD.BitMaps,AG.STD.Types,AG.Resourcer,AG.Types,AG.Scripts,AG.Windows;

procedure LInit(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key:byte;Info:TAGKeyInfo);
procedure LStart(Core:TAGGraphicCore);
procedure LTimed;

const
  CScriptLevelInfo:TLevelInfo=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;keydown:LKeydown;Timed:LTimed);

implementation

var
  Script:TAGScriptEngine;
  br:TAGBrush;

procedure LInit(Core:TAGGraphicCore);
begin
  Script:= TAGPythonScriptEngine.Create;
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
  18:if BtnCheck(115) then
    FreeGame;
  27:FreeGame;
  else
  end;
end;

procedure LTimed;
begin
end;

end.
