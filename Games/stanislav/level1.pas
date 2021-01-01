unit level1;

interface

uses
  System.Classes,System.SysUtils,AG.Levels,AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,
  AG.Resourcer,GameElements,AG.Physic,AG.Video;

procedure LInit(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LDestoy(Core:TAGGraphicCore);
procedure LKeydown(key,lParam:nativeint);
procedure LStart(Core:TAGGraphicCore);
procedure LTimed;

const
  CLevel1Info:TAGLevel=(init:LInit;start:LStart;paint:LPaint;Destroy:LDestoy;Timed:LTimed);

implementation

{$T+}

{var
  br:TAGBrush;
  charr:THero;
  contrl:TController;
  Physic:TAGPhysic;
  levelpics:TAGEngineResource;

  Floor,Wall,WallC:integer;
  walldata:TWallData;
  FloorPlase,WallPlase:TAGScreenCoord;}

procedure LInit(Core:TAGGraphicCore);
begin
  //levelpics.source:=Images.Get('school_lvl');
end;
  
procedure LStart(Core:TAGGraphicCore);
const
  TBC:TAGColor=(R:255;G:255;B:255;A:255);
begin
//Core.BackColor:=TBC;
(*ReleseTime;
  FloorPlase:=TAGScreenCoord.Create(-800,800,1600,80);
  WallPlase:=TAGScreenCoord.Create(800,-800,80,1600);

  Core.CompleteResourseImages(levelpics);
  Floor:=levelpics.source.r^.config.ReadInteger(InfoCastSection,'Tfloor',0)-1;
  Wall:=levelpics.source.r^.config.ReadInteger(InfoCastSection,'Twall',0)-1;
  WallC:=levelpics.source.r^.config.ReadInteger(InfoCastSection,'Cwall',0);
  walldata:=CreateWall(levelpics,Wall,WallC,WallPlase);

  br:=Core.CreateBrush(witecolor);
  charr:=THero1.Create(Core);
  contrl:=TController.Create(charr);
  Physic:=TAGPhysic.Create(time);
  Physic.BaseAcc:=TAGPhysicVector.Create(0,2);
  charr.&Register(Physic);
  Physic.Add(FloorPlase,1,true,false);
  Physic.Add(WallPlase,0.1,false,true);*)
end;

procedure LPaint(Core:TAGGraphicCore);
begin
(*ReleseTime;
with Core do
begin
  Init2D;
  DrawWall(Core,levelpics,Wall,walldata,WallPlase);
  DrawFloor(Core,levelpics,Floor,FloorPlase);
  {$IFDEF Debug}
  DrawText(GameInformationString,TAGScreenCoord.Create(40,40,2000,2000),20,AGFont_SystemFont,br);
  Physic.DebugDraw(Core,TAGScreenVector.Create((wndcoord.W div 2),(wndcoord.H div 2)),br);
  {$ENDIF}
  charr.Paint;
end;*)
end;

procedure LDestoy(Core:TAGGraphicCore);
begin
{freeandnil(Physic);
charr.Destoy;
contrl.Destroy;
Core.ReleaseBrush(br);}
end;

procedure LKeydown(key,lParam:nativeint);
begin
  case key of
  27:
  begin
    //FreeGame;
    //DestroyWindow(Game.Window.hWindow);
    FreeGame;
    Halt;
  end;
  {37:
  begin
    vecc.X:=vecc.X-100;
  end;
  38:
  begin
    vecc.Y:=vecc.Y-100;
  end;
  39:
  begin
    vecc.X:=vecc.X+100;
  end;
  40:
  begin
    vecc.Y:=vecc.Y+100;
  end;}
  else
    //contrl.OnKeyPressed(key,lParam);
  end;
end;

procedure LTimed;
begin
//ReleseTime;
//Physic.Tic(time);
end;

end.
