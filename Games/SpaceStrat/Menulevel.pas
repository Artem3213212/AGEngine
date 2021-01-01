unit MenuLevel;

interface

uses
  System.Classes,System.SysUtils,AG.Levels,AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,
  AG.Resourcer,AG.Physic,AG.Video,winapi.windows,GameElements,Level1,GameUI,AG.Graphic.D3D9;

procedure LInit(Core:TAGGraphicCore);
procedure LStart(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key:byte;Info:TAGKeyInfo);

procedure LClk(coord:TAGscreenVector);
procedure LMove(coord:TAGscreenVector);

const
  CMenuLevelInfo:TAGLevel=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;keydown:LKeydown;Timed:nil);
  CMouse:TAGMouseClicer=(L:(dwn:LClk;up:nil;dclk:nil);
                         R:(dwn:nil;up:nil;dclk:nil);
                         M:(dwn:nil;up:nil;dclk:nil);
                         X:(dwn:nil;up:nil;dclk:nil);
                         move:LMove;wheel:nil;hwheel:nil);

implementation

{$T+}

var
  br:TAGBrush;
  s:string;
  UI:TMainMenuIU;
  MainLigth:TAGLight;
  Sky:TSky;
  //tstobj:TAGMesh;

procedure LInit(Core:TAGGraphicCore);
begin
end;

procedure LStart(Core:TAGGraphicCore);
var
  i:word;
begin
Game.Window.Mouse:=CMouse;
br:=Core.CreateBrush(witecolor);
Core.LoadFont('Arial','ru-ru',24,MenuFont);
//3D
{for i:=Low(Pl) to High(Pl) do
  Pl[i]:=TPlanet.Create(Core,i);}
Core.MaxDepth:=10000000000;
Core.AddDirectLight(TAG3DVector.Create(0,-1,-1),witecolor);
//Core.AddDirectLight(TAG3DVector.Create(1,-0.5,0),witecolor);
UI:=TMainMenuIU.Create(Core);
UI.OnStart;
Sky:=TSky.Create(Core);
//tstobj:=Core.LoadXFile('../Data/mining_viladge_01/mining_viladge_01_bin.X',[],False);
end;

procedure LClk(coord:TAGscreenVector);
begin
UI.MouseClick(coord);
end;

procedure LMove(coord:TAGscreenVector);
begin
UI.MouseMove(coord);
end;

procedure LPaint(Core:TAGGraphicCore);
var
  i:word;
begin
with Core do
begin
  Init3D;
  SetCameraToObject(TAG3DVector.Create(10000,0,10000),TAG3DVector.Create(0,0,5000));
  {DrawMesh(tstobj,TAG3DVector.Zero,TAG3DVector.Zero,TAG3DVector.Create(0.1,0.1,0.1));}
  //DrawMesh(sky,False);
  Sky.Draw(Core);
  Init2D;
  UI.OnPaint;
  {$IFDEF Debug}
    DrawText(GameInformationString+s,TAGScreenCoord.Create(40,40,2000,2000),20,AGFont_SystemFont,br);
  {$ENDIF}
end;
end;

procedure LDestoy(Core:TAGGraphicCore);
var
  i:byte;
begin
Core.ReleaseBrush(br);
FreeAndNil(UI);
FreeAndNil(Sky);
end;

procedure LKeydown(key:byte;Info:TAGKeyInfo);
begin
if UI.OnKey(key,Info) then
  exit;
if(Info.Status=TAGKeyStatusPressed)and(Info.Repeats=0)then
  case key of
    49:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,1);
    50:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,2);
    51:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,3);
    27:
    begin
      FreeGame;
      halt;//ExitProcess(0);
    end;
  else
    s:=inttostr(key);
  end;
end;

end.
