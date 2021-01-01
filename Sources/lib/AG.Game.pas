unit AG.Game;

{$i main.conf}

{$IFDEF Logs}{$ENDIF}
{$IFDEF 8k}{$ENDIF}
{$IFDEF 4k}{$ENDIF}
{$IFDEF NoResize}{$ENDIF}

interface

uses
  System.SysUtils,System.Generics.Collections,
  {$IFDEF MSWINDOWS}Winapi.Windows,{$ENDIF}
  {$IFDEF D2D1}AG.Graphic.D2D1,{$ENDIF}
  {$IFDEF D3D9}AG.Graphic.D3D9,{$ENDIF}
  {$IFDEF Vulkan}AG.Graphic.Vulkan,{$ENDIF}
  {$IFDEF OpenGL}AG.Graphic.OpenGL,{$ENDIF}
  {$IFDEF OpenGLES}AG.Graphic.OpenGLES,{$ENDIF}
  {$IFDEF Logs}AG.Logs,{$ENDIF}
  AG.Types,AG.Windows,AG.Screen,AG.Graphic;

type
  TAGGame=class
    private
    protected
      {$IFDEF Logs}log:TAGLog;{$ENDIF}
    public
      Window:TAGWindow;
      GraphicCore{$IFNDEF NoResize},GC2{$ENDIF}:TAGGraphicCore;
      constructor Create(name,logfile:string;initer:TAGOnCreateProcedure;drawer:TAGOnpantProcedure;backcolor:TAGColor;wndcoord:TAGScreenCoord;fscr:boolean);
      procedure Start;
      destructor Destroy();override;
  end;

Implementation

constructor TAGGame.Create(name,logfile:string;initer:TAGOnCreateProcedure;drawer:TAGOnpantProcedure;backcolor:TAGColor;wndcoord:TAGScreenCoord;fscr:boolean);
var
  tid:cardinal;
  {$IFNDEF NoResize}incoord:TAGScreenCoord;{$ENDIF}
begin
  fscr:=False;
  {$IFDEF Logs}
    log:=TAGDiskLog.Create(logfile);
    log.Write('Инициализация:',self);
  {$ENDIF}
  {$IFDEF D2D1}GraphicCore:=TAGD2D1GraphicCore.Create;{$ENDIF}
  {$IFDEF Vulkan}Graphiccore:=TAGVulkanGraphicCore.Create;{$ENDIF}
  {$IFDEF OpenGl}Graphiccore:=TAGOpenGlGraphicCore.Create;{$ENDIF}
  {$IFDEF D3D9}Graphiccore:=TAGD3D9ShaderGraphicCore.Create;{$ENDIF}
  {$IFDEF OpenGlES}Graphiccore:=TAGOpenGlESGraphicCore.Create;{$ENDIF}
  Graphiccore.BackColor:=backcolor;
  {$IFDEF NoResize}
    Graphiccore.initer:=initer;
    Graphiccore.drawer:=drawer;
  {$ELSE}
    GC2:=GraphicCore;
    incoord:=wndcoord;
    if wndcoord.W/wndcoord.H<16/9 then
    begin
      incoord.H:=Round(wndcoord.W*9/16);
      incoord.X:=0;
      incoord.Y:=(wndcoord.H-incoord.H)div 2;
    end
    else if wndcoord.W/wndcoord.H>16/9 then
    begin
      incoord.W:=Round(wndcoord.H*16/9);
      incoord.X:=(wndcoord.W-incoord.W)div 2;
      incoord.Y:=0;
    end;
    GC2.drawer:=procedure(Core:TAGGraphicCore)
      begin
        Core.Init2D();
        if Assigned(GraphicCore.drawer) then
        begin
          GraphicCore.OnPaint;
          Core.DrawBitmap(incoord,GraphicCore.GetBtmForDraw,255,true);
        end;
      end;
    GC2.initer:=procedure(Core:TAGGraphicCore)
      begin
        GraphicCore:=Core.CreateNewRender(
          {$IFDEF 8k}7680,4320{$ELSE}
          {$IFDEF 4k}3840,2160{$ELSE}
          wndcoord.W,wndcoord.H{$ENDIF}{$ENDIF});
      end;
  {$ENDIF}
  Window:=TAGWindow.Create(name,wndcoord,{$IFDEF NoResize}GraphicCore{$ELSE}GC2{$ENDIF},fscr);
  {$IFNDEF NoResize}
    Graphiccore.BackColor:=backcolor;
    initer(GraphicCore);
    GraphicCore.drawer:=drawer;
  {$ENDIF}
end;

procedure TAGGame.Start;
{$IFDEF MSWINDOWS}
var
  m:msg;
begin
  while PeekMessage(m,0,0,0,PM_NOYIELD+PM_REMOVE)do
  begin
    TranslateMessage(m);
    DispatchMessage(m);
  end;
{$ENDIF}
{$IFDEF ANDROID}
begin
{$ENDIF}
end;

destructor TAGGame.Destroy();
begin
  {$IFDEF Logs}
    log.Write('Выключение.',self);
    sleep(1000);
    FreeAndNil(log);
  {$ENDIF}
  FreeAndNil(GraphicCore);
  {$IFNDEF NoResize}
    Pointer(GC2):=nil;
  {$ENDIF}
  FreeAndNil(Window);
end;

end.