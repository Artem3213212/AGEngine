program MainGame;

//{$APPTYPE Console}
{$APPTYPE GUI}
{$WEAKLINKRTTI OFF}

//{$Define PyExample}
//{$UNDEF Stanislav}
{$IFNDEF Stanislav}
  {$IFNDEF PyExample}
    {$IFNDEF SpaceStrat}
      {$Define Test}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

uses
  System.SysUtils,
  System.Classes,
  AG.Game,
  AG.Types,
  AG.Screen,
  AG.Graphic,
  AG.Windows,
  AG.Resourcer,
  //AG.ImagingAGP,
  AG.Logs in '..\NoEngineLibs\AGLogs\AG.Logs.pas',
  {$IFNDEF Test}
    AG.Levels,
    AGE.BaseClasses in '..\Engine\AGE.BaseClasses.pas',
    AGE.Previewlvl in '..\Engine\AGE.Previewlvl.pas',
    AGE.Time in '..\Engine\AGE.Time.pas',
    {Vulkan in '..\NoEngineLibs\Vulkan\Vulkan.pas',
    PythonEngine in '..\NoEngineLibs\PythonEngine.pas',
    MethodCallBack in '..\NoEngineLibs\MethodCallBack.pas',}
    //Pylvl in '..\Engine\Pylvl.pas',
  {$ENDIF}
  {$IFDEF Stanislav}
    Menulevel in '..\Games\Stanislav\Menulevel.pas',
    GameElements in '..\Games\Stanislav\GameElements.pas',
    level1 in '..\Games\Stanislav\level1.pas',
  {$ENDIF}
  {$IFDEF SpaceStrat}
    Menulevel in '..\Games\SpaceStrat\Menulevel.pas',
    PlanetParade in '..\Games\SpaceStrat\PlanetParade.pas',
    GameUI in '..\Games\SpaceStrat\GameUI.pas',
    GameElements in '..\Games\SpaceStrat\GameElements.pas',
    level1 in '..\Games\SpaceStrat\level1.pas',
    GameElements.PlanetParade in '..\Games\SpaceStrat\GameElements.PlanetParade.pas',
    GameElements.Camera in '..\Games\SpaceStrat\GameElements.Camera.pas',
  {$ENDIF}
  EGL14 in '..\NoEngineLibs\DelphiEGL\EGL14.pas',
  OpenGLES30 in '..\NoEngineLibs\OpenGLES30\OpenGLES30.pas';

{$IFDEF MSWINDOWS}
  {$SetPEFlags 1}
{$ENDIF}

var
  s:string;
  br,br1:TAGBrush;
  {$IFDEF D3D9}mes:TAGMesh;{$ENDIF}
  Game:TAGGame;
  pic:TAGBitMap;
  pics:array[0..10]of TAGBitMap;
  p0,p1:TAGResourceImage;
  vecc:TAGScreenVector=(X:700;Y:700);
  Images:TAGResourser;

{$IFDEF Test}
procedure init(Core:TAGGraphicCore);
var
  i:integer;
begin
  br:=Core.CreateBrush(WiteColor);
  br1:=Core.CreateBrush(GreenColor);
  {$IFDEF D3D9}
    //mes:=(core as TAGD3D9GraphicCore).LoadXFile('bigship1.x');
    //mes:=(Core as TAGD3D9GraphicCore).LoadXFile('..\Data\Planet_00\00_planet_00.X','..\Data\Planet_00');
    Core.AddDirectLight(TAG3DVector.Create(1,-1,1),witecolor);
  {$ELSE}
    pic:=Core.CreateBitMap(p0);
    p0.Free;
    for i:=1 to 7 do
      pics[i]:=Core.CreateBitMapFromFile(inttostr(i)+'.bmp');
  {$ENDIF}
end;

procedure maindraw(Core:TAGGraphicCore);
const
  pos:TAGScreenCoord=(X:0;Y:0;W:100;H:4000);
  pos0:TAGScreenCoord=(X:300;Y:0;W:100;H:4000);
  pos1:TAGScreenCoord=(X:10;Y:10;W:50;H:30);
  pos2:TAGScreenCoord=(X:100;Y:100;W:800;H:800);
  vec:TAGScreenVector=(X:1;Y:1);
  vec0:TAGScreenVector=(X:500;Y:500);
  vec1:TAGScreenVector=(X:100;Y:500);
  vec2:TAGScreenVector=(X:100;Y:100);
  vec3:TAGScreenVector=(X:500;Y:100);
  vecc0:TAGScreenVector=(X:50;Y:200);
var
  i:integer;
//  p:TAGScreenvector;
begin
{$IFDEF D3D9}
  Core.SetCameraToObject(TAG3DVector.Create(500,400,-500),TAG3DVector.Create(0,0,0));
  Core.Init3D;
  Core.DrawMesh(mes,TAG3DVector.Create(0,0,0),TAG3DVector.Create(2,2,2));
  Core.DrawText(inttostr(Game.Window.FPS.NowFPS),pos,20,0,br);
{$ELSE}
  Core.BackColor:=GreenColor;
  Core.Init2D;
  {Core.DrawPoint(vec0,20,br);
  Core.DrawText(inttostr(Game.Window.FPS.NowFPS),pos,20,0,br);
  Core.DrawText(s,pos0,20,0,br);
  Core.DrawRectangle(TAGscreenCoord.Create(100,100,400,400),20,br);
  Core.DrawLine(vec1,vec2,20,br);
  Core.DrawPoint(vec1,20,br);
  Core.DrawPoint(vec2,20,br);
  Core.DrawPoint(vec3,20,br);
  Core.DrawElips(vecc,vecc0,20,br1);
  Core.DrawRectangle(pos2,2,br);
  Core.FillRectangle(pos1,br);
  Core.DrawBitmap(pos2,pic,255,True);}
  for i:=1 to 7 do
    Core.DrawBitmap(pos2,pics[i],255,True);
{$ENDIF}
end;

procedure keydown(key:byte;Info:TAGKeyInfo);
begin
case key of
  27:
  begin
    {$IFNDEF D3D9}
    Game.GraphicCore.ReleaseBrush(br);
    //Game.GraphicCore.ReleaseBitMap(pic);
    {$ENDIF}
    FreeAndNil(Game);
    halt;
  end;
  37:vecc.X:=vecc.X-100;
  38:vecc.Y:=vecc.Y-100;
  39:vecc.X:=vecc.X+100;
  40:vecc.Y:=vecc.Y+100;
else
  s:=inttostr(key);
end;
end;

procedure mouse(coord:TAGscreenVector);
begin
  s:=s+'1';
end;

procedure mouse0(coord:TAGscreenVector);
begin
  s:=s+'0';
end;       
{$ENDIF}

var
  log:TAGLog;
begin
//AGLoadICO('1.ico');
{$IFNDEF Test}
  {$IFDEF PyExample}
  //PyLvlFileName:='..\Games\PyTest\Testlvl.py';
  {$ELSE}{$IFDEF Melanholya}
    AGLoadICO('..\Melanholya.ico');
    Nexlevel:=CMenuLevelInfo;
  {$ELSE}
    Nexlevel:=CMenuLevelInfo;//CLevel1Info;//CLevelTest16bitEmuInfo;//CLevel1Info;
  {$ENDIF}{$ENDIF}
  {$IFDEF SpaceStrat}
    LoadLevel({$IFDEF DEBUG}CPlanetParadeInfo{$ELSE}CPreviewlvlInfo{$ENDIF});
  {$ELSE}
    LoadLevel({$IFDEF PyExample}CScriptLevelInfo{$ELSE}CPreviewlvlInfo{$ENDIF});
  {$ENDIF}
{$ELSE}
  p0:=TAGResourceImage.LoadByFile('2.bmp');
  //p1:=DecodeAGP(qwert(''));
  //p1:=OpenBmp('..\Temp\1.bmp');//5.bmp');
  //p1:=OpenAGP('..\Temp\1.agp');

  //p1:=AGRead('1.bin');



  //log:=AG.Logs.TAGDiskLog.Create('../my.log');
  //AC:=TAGACDev.Create(log);
  //sleep(1000);
  //cl.clCreateContext

  //p0:=images.Get();

  Game:=TAGGame.Create('game','../main.log',init,maindraw,backcolor,TAGScreensInfo.Screens[0],true);
  game.Window.inputproc:=keydown;

  game.Window.Mouse.L.dwn:=mouse0;
  game.Window.Mouse.R.dwn:=mouse0;
  game.Window.Mouse.M.dwn:=mouse0;
  game.Window.Mouse.X.dwn:=mouse0;
  game.Window.Mouse.L.up:=mouse;
  game.Window.Mouse.R.up:=mouse;
  game.Window.Mouse.M.up:=mouse;
  game.Window.Mouse.X.up:=mouse;
{$ENDIF}

Game.Start;
{$IFDEF Test}
  FreeAndNil(Game);
{$ENDIF}
end.
