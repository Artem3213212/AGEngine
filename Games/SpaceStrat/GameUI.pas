unit GameUI;

interface

uses
  System.Classes,System.IniFiles,System.SysUtils,System.Generics.Collections,AG.Game,
    AG.Graphic,AG.Types,AG.Resourcer,AG.Levels,AG.Windows,
    AGE.BaseClasses,AGE.Time;

type
  TUIObject=class abstract (TAGEController)
    public
      Core:TAGGraphicCore;
      Data:TAGEngineResource;
      StartTime:Cardinal;
      constructor Create(Core:TAGGraphicCore);virtual;
      procedure OnStart();virtual;
      procedure OnPaint();virtual;
      procedure MouseMove(coord:TAGscreenVector);virtual;
      procedure MouseClick(coord:TAGscreenVector);virtual;
      destructor Destroy();override;
  end;
  TMainMenuIU=class (TUIObject)
    private
      const
        //размеры панели
        x0=262;
        y0=563;
        //размеры кнопки
        x1=398;
        y1=56;
        x2=x1;
        y2=y1;
        //размеры панели выдвигающейся сверху
        x3=932;
        y3=860;
        //Отступ от верхней границы кнопки(для текста)
        yy=15;
        //un=3;
        t1=500;
        text:array[0..5]of string=('Новая игра','Загрузить','Cетевая игра','Настройки','Авторы','Выход');
        text2:array[1..2]of string=('Назад','Далее');
      var
        br:TAGBrush;
        selected,selected2:ShortInt;
        selectedtime,selected2time,selectedtime2:cardinal;
        state:array[0..5]of integer;
        PanelState:array[1..2]of integer;
        Right:boolean;
    public
      constructor Create(Core:TAGGraphicCore);override;
      procedure OnPaint();override;
      procedure StateUpdate(var State:integer;Up:boolean;Delta:integer;max:integer=255;min:integer=0);
      procedure BtnPaintToTree(l,H,i:integer;intense:byte=0);
      procedure BtnPaint(x,y,xx:integer;Text:string;intense:byte=0);
      procedure RBtnPaint(x,y,xx,tx:integer;Text:string;intense:byte=0);
      procedure PaintPanel(x,y:integer);
      function OnKey(key:byte;Info:TAGKeyInfo):boolean;override;
      procedure MouseMove(coord:TAGscreenVector);override;
      procedure MouseClick(coord:TAGscreenVector);override;
      destructor Destroy();override;
  end;

const
  MenuFont:TAGFont=AGFont_UserFonts+1;

var
  UITime:TAGETime;

implementation

function max(a,b:integer):integer;inline;
begin
if b>a then
  Result:=b
else
  Result:=a;
end;

function min(a,b:integer):integer;inline;
begin
if b<a then
  Result:=b
else
  Result:=a;
end;

function count2mn(x0,v0,a,t:single):single;
begin
Result:=x0+t*v0+a*sqr(t)/2;
end;

constructor TUIObject.Create(Core:TAGGraphicCore);
begin
inherited Create;
Self.Core:=Core;
Data.source:=Images.Get(ClassName);
Core.CompleteResourseImages(Data);
end;

procedure TUIObject.OnStart();
begin
StartTime:=UITime.Time;
end;

procedure TUIObject.OnPaint();
begin
end;

procedure TUIObject.MouseMove(coord:TAGscreenVector);
begin
end;

procedure TUIObject.MouseClick(coord:TAGscreenVector);
begin
end;

destructor TUIObject.Destroy();
begin
inherited;
Core.ReleaseResourseImages(Data);
Images.Release(Data.source);
end;

{TMainMenuIU}
constructor TMainMenuIU.Create(Core:TAGGraphicCore);
begin
inherited;
br:=Core.CreateBrush(witecolor);
selected:=-1;
selected2:=-1;
end;

procedure TMainMenuIU.OnPaint();
const
  x1=200;
var
  i:byte;
begin
with Game.Window.getcoord do
begin
  if UITime.Time-StartTime<t1*6 then
    for i:=0 to 5 do
    begin
      if UITime.Time-StartTime>=t1*i then
        if UITime.Time-StartTime<t1*(i+1) then
          BtnPaintToTree(Round(count2mn(0,x1/t1*2,-x1*2/t1/t1,UITime.Time-StartTime-t1*i))-x1,H,i)
        else
          BtnPaintToTree(0,H,i);
      state[i]:=0;
    end
  else
  for i:=0 to 5 do
    if selected2=-1 then
    begin
      StateUpdate(state[i],selected=i,UITime.Time-selectedtime);
      BtnPaintToTree(0,H,i,state[i]);
    end
    else
      if selected=i then
      begin
        state[i]:=min(state[i]+UITime.Time-selectedtime,255);
        BtnPaintToTree(0,H,i,state[i]);
      end
      else
      begin
        state[i]:=max(state[i]-(max(UITime.Time-selected2time-100*i,0)div 2),-398*8);
        BtnPaintToTree(state[i] div 8,H,i);
      end;
  selectedtime:=UITime.Time;
  if selected2<>-1 then
    if UITime.Time-selected2time<t1 then
      PaintPanel((W-x3)div 2+150,Round(y3*min(UITime.Time-selected2time,t1)/t1)-y3)
    else
      PaintPanel((W-x3)div 2+150,0);
  Core.DrawBitmap(TAGScreenCoord.Create(-50,H-550,262,563),Data.img[0]);
end;
end;

procedure TMainMenuIU.StateUpdate(var State:integer;Up:boolean;Delta:integer;max:integer=255;min:integer=0);
begin
if Up then
  State:=GameUI.min(State+Delta,max)
else
  State:=GameUI.max(State-Delta,min);
end;

procedure TMainMenuIU.BtnPaintToTree(l,H,i:integer;intense:byte=0);
begin
BtnPaint(l+i*26-120,H-479+i*65,68-i*26+120,text[i],intense);
end;

procedure TMainMenuIU.BtnPaint(x,y,xx:integer;Text:string;intense:byte=0);
begin
x:=intense div 8+x;
if intense<>255 then
  Core.DrawBitmap(TAGScreenCoord.Create(x,y,x1,y1),Data.img[1]);
if intense<>0 then
  Core.DrawBitmap(TAGScreenCoord.Create(x,y,x2,y2),Data.img[2],intense);
Core.DrawText(Text,TAGSCreenCoord.Create(x+xx,y+yy,1000,1000),16,MenuFont,br);
end;

procedure TMainMenuIU.RBtnPaint(x,y,xx,tx:integer;Text:string;intense:byte=0);
begin
x:=x-intense div 8;
if intense<>255 then
  Core.DrawBitmap(TAGScreenCoord.Create(x-x1,y,x1,y1),Data.img[3]);
if intense<>0 then
  Core.DrawBitmap(TAGScreenCoord.Create(x-x1,y,x2,y2),Data.img[4],intense);
Core.DrawText(Text,TAGSCreenCoord.Create(x-xx-tx,y+yy,1000,1000),16,MenuFont,br);
end;

procedure TMainMenuIU.PaintPanel(x,y:integer);
begin
//Левая кнопка
StateUpdate(PanelState[1],selected2=1,UITime.Time-selectedtime2);
RBtnPaint(x+530,y+764,200,60,text2[1],PanelState[1]);
//Правая кнопка
StateUpdate(PanelState[2],selected2=2,UITime.Time-selectedtime2);
BtnPaint(x+400,y+764,200,text2[2],PanelState[2]);

selectedtime2:=UITime.Time;
Core.DrawBitmap(TAGScreenCoord.Create(x,y,x3,y3),Data.img[5]);
end;

function TMainMenuIU.OnKey(key:byte;Info:TAGKeyInfo):boolean;
begin
Result:=False;
end;

procedure TMainMenuIU.MouseMove(coord:TAGscreenVector);
var
  i:byte;
  temp:integer;
begin
if UITime.Time-StartTime>3000 then
  if selected2=-1 then
  begin
    with Game.Window.getcoord do
      for i:=0 to 5 do
      begin
        temp:=H-479+i*65;
        if(temp<coord.Y)and(coord.Y<temp+y1)and(60<coord.X)and(Round(x1+state[i]/8+i*26-120-(coord.Y-(temp))/2)>coord.X)then
        begin
          selected:=i;
          exit;
        end;
      end;
    selected:=-1;
  end
  else
    with Game.Window.getcoord do
    begin
      if UITime.Time-selected2time<t1 then
        temp:=Round(y3*min(UITime.Time-selected2time,t1)/t1)-y3+764
      else
        temp:=764;
      if(temp<coord.Y)and(coord.Y<temp+y1)then
        if((W-x3)div 2+500>coord.X)and((W-x3+coord.Y-temp)div 2+275-PanelState[2]div 8<coord.X)then
          selected2:=1
        else if((W-x3)div 2+740<coord.X)and((W-x3+coord.Y-temp)div 2+925+PanelState[2]div 8>coord.X)then
          selected2:=2
        else
          selected2:=0
      else
        selected2:=0;
    end;
end;

procedure TMainMenuIU.MouseClick(coord:TAGscreenVector);
begin
MouseMove(coord);
if selected2=-1 then
  case selected of
  0:
  begin
    selected2:=0;
    selected2time:=UITime.Time;
  end;
  1:;
  2:;
  3:;
  4:;
  5:
  begin
    FreeGame;
    Halt(0);
  end;
  end;
end;

destructor TMainMenuIU.Destroy();
begin
Core.ReleaseBrush(br);
inherited;
end;

initialization
UITime:=TAGELevelTime.Create;
finalization
FreeAndNil(UITime);
end.
