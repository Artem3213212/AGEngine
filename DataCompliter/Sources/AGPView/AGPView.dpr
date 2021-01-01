program AGPView;

{$APPTYPE GUI}

uses
  System.SysUtils,
  winapi.windows,
  winapi.messages,
  AG.Graphic in '..\..\..\Sources\lib\AG.Graphic.pas',
  AG.Resourcer in '..\..\..\Sources\lib\AG.Resourcer.pas',
  AG.Types in '..\..\..\Sources\lib\AG.Types.pas',
  AG.Windows in '..\..\..\Sources\lib\AG.Windows.pas',
  AG.STD.BitMaps in '..\..\..\NoEngineLibs\AGSTD\AG.STD.BitMaps.pas',
  AG.STD.Files in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Files.pas', 
  AG.STD.Types in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Types.pas',
  AG.Logs in '..\..\..\NoEngineLibs\AGLogs\AG.Logs.pas';

var
  m:msg;
  GraphicCore:TAGGraphicCore;
  Window:TAGWindow;
  br:TAGBrush;
  pic:TAGEngineBitMap;
  p0:TAGBitMap;
  f:boolean;

const
  backcolor:TAGColor=(R:0;G:0;B:0;A:255);
  defwndcoord:TAGScreenCoord=(X:100;Y:100;W:300;H:300);
  witecolor:TAGColor=(R:255;G:255;B:255;A:255);

procedure initer(Core:TAGGraphicCore);
begin
  br:=core.CreateBrush(witecolor);
  pic:=core.CreatePicture(p0);
end;

procedure maindraw(Core:TAGGraphicCore);
const
  pos:TAGScreenCoord=(X:0;Y:0;W:10;H:400);
var
  i:integer;
  p:TAGScreenvector;
  pos2:TAGScreenCoord;
begin
  if Window<>nil then
  begin
    Core.DrawText(inttostr(Window.FPS.NowFPS),pos,10,0,br);
    pos2:=Window.getcoord;
    pos2.X:=0;
    pos2.Y:=0;
    Core.DrawBitmap(pos2,pic,255,f);
  end;
end;

procedure keydown(key,lParam:nativeint);
begin
case key of
32:f:=not f;
27:DestroyWindow(Window.hWindow);
end;
end;

begin
p0:=OpenAGP(Pwidechar(ParamStr(1)));
Graphiccore:=TAGD2D1GraphicCore.Create;
Graphiccore.drawer:=maindraw;
Graphiccore.initer:=initer;
Graphiccore.setbackcolor(backcolor);
Window:=TAGWindow.Create(WS_VISIBLE or WS_POPUP or WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,'AG.AGPView',defwndcoord,Graphiccore,SW_NORMAl,false);
Window.inputproc:=keydown;

while GetMessage(m, 0, 0, 0) do
begin
  TranslateMessage(m);
  DispatchMessage(m);
end;
end.