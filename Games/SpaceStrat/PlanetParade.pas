unit PlanetParade;

interface

uses
  System.SysUtils,AG.Levels,AG.Types,AG.Graphic,AG.Resourcer,GameElements,AG.Graphic.D3D9,AGE.BaseClasses,GameElements.PlanetParade,
  System.IniFiles,AG.Windows,GameUI;

procedure LInit(Core:TAGGraphicCore);
procedure LStart(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key:byte;Info:TAGKeyInfo);

const
  CPlanetParadeInfo:TAGLevel=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;keydown:LKeydown;Timed:nil);

implementation

{$T+}

var
  br:TAGBrush;
  s:string;
  MainLigth:TAGLight;
  sky:TAGMesh;
  //Star:TStar;
  //Pl:array[0..8]of TPlanet;
  CamPos,CamTarget:TAG3DVector;
  AlphaTest:TAGEGlobalXFile;
  SkyMatrix:TAG3DMatrix;
  StarSystem:TStarSystem;

procedure LInit(Core:TAGGraphicCore);
begin
end;

procedure LStart(Core:TAGGraphicCore);
var
  i:word;
begin
br:=Core.CreateBrush(witecolor);
Core.LoadFont('Arial','ru-ru',24,MenuFont);
//3D
StarSystem:=TStarSystem.Create(Core,TMemIniFile.Create('..\Data\TestStarSystem.ini'));
{Star:=TStar.Create(Core,0);
for i:=Low(Pl) to High(Pl) do
  Pl[i]:=TPlanet.Create(Core,i);}
Core.MaxDepth:=1000000;	     //1,-0.5,0
Core.MinDepth:=10;
Core.AddDirectLight(TAG3DVector.Create(0,-1,-1),witecolor);
//Core.AddPointLight(TAG3DVector.Create(0,1000,1100),witecolor,10000,10);
CamPos:=TAG3DVector.Create(600,2500,0);
CamTarget:=TAG3DVector.Create(500,0,0);
//AlphaTest:=TAGEGlobalXFile.Create(Core,[Core.CreateTexFromFile('..\Data\Gradient_Alfa.dds')],'..\Data\ring_02.X');
Core.BackColor:=WiteColor;
sky:=Core.LoadXFile('../Data/sky/001_spasesky.X',[],False);
SkyMatrix:=TAG3DMatrix.MkScale(50);
end;

procedure LPaint(Core:TAGGraphicCore);
const
  r=1;
var
  i:word;
begin
with Core do
begin
  Init3D;
  SetCameraToObject(CamPos,CamTarget);
  DrawMesh(sky,SkyMatrix,False);
  StarSystem.Draw(Core,TAG3DMatrix.MkIdent);
  //AlphaTest.Draw(Core,TAG3DVector.Create(1000,600,0),TAG3DVector.Zero,TAG3DVector.Create(20,10,10));
  {Star.Draw(Core,TAGMatrix.MkTrans(TAG3DVector.Create(-600,0,0)));
  for i:=Low(Pl) to High(Pl) do
    if i<4 then
      Pl[i].Draw(Core,TAGMatrix.MkTrans(TAG3DVector.Create(i*80,0,0)))
    else if i<6 then
      Pl[i].Draw(Core,TAGMatrix.MkTrans(TAG3DVector.Create(i*600-1900,0,0)))
    else
      Pl[i].Draw(Core,TAGMatrix.MkTrans(TAG3DVector.Create(i*240+200,0,0)));}
  Init2D;
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
end;

procedure LKeydown(key:byte;Info:TAGKeyInfo);
begin
case key of
  48:
  begin
    CamPos:=TAG3DVector.Create(600,2500,0);
    CamTarget:=TAG3DVector.Create(500,0,0);
  end;
  49,50,51,52,53,54,55,56:
  begin
    if key-49<4 then
      CamTarget.X:=(key-49)*80
    else if key-49<6 then
      CamTarget.X:=(key-49)*600-1900
    else
      CamTarget.X:=(key-49)*240+200;
    //CamPos:=TAG3DVector.Create(CamTarget.X,Pl[key-49].Radius*4,0);
  end;
  112:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,1);
  113:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,2);
  114:(Game.GraphicCore as TAGD3D9GraphicCore).SetDebug(0,3);
  37:
  CamTarget.X:=CamTarget.X+100;
  39:
  CamTarget.X:=CamTarget.X-100;
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
