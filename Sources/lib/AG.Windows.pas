unit AG.Windows;

{$i main.conf}

{$IFDEF Logs}{$ENDIF}

interface

uses
  System.SysUtils,System.Generics.Collections,System.DateUtils,
  {$IFDEF MSWINDOWS}Winapi.Messages,Winapi.Windows,{$ENDIF}
  {$IFDEF ANDROID}Androidapi.NativeWindow,{$ENDIF}
  AG.Graphic,AG.Types;

type
  TAGMouseProc=reference to procedure(coord:TAGscreenVector);
  TAGMouseWheelProc=reference to procedure(delta:SmallInt;coord:TAGscreenVector);

  TAGMouseClicer=record
    L,R,M,X:record
      dwn,up,dclk:TAGMouseProc;
    end;
    move:TAGMouseProc;
    wheel,hwheel:TAGMouseWheelProc;
  end;

  TInputRemaper=function(key:nativeint):nativeint;

  TAGFPSCounter=class
    private
    protected
      BeginTime:TDateTime;
      count:word;
    public
      NowFPS:word;
      procedure Update();
      constructor Create();
  end;

  TAGKeyStatus=(TAGKeyStatusPressed,TAGKeyStatusUpped);
  TAGKeyInfo=record
      Repeats:word;
      Status:TAGKeyStatus;
      {$IFDEF MSWINDOWS}constructor MkFromLParam(lParam:NativeInt);{$ENDIF}
  end;
  TAGKeyProc=reference to procedure(key:byte;Info:TAGKeyInfo);

  TAGWindow=class
    {$IFDEF MSWINDOWS}
      private class var
        WindowByHandle:TDictionary<THandle,TAGWindow>;
        class function GWndProc(hwnd,msg,wParam,lParam:NativeUInt):NativeUInt;static;stdcall;
    {$ENDIF}
    protected
      {$IFDEF MSWINDOWS}
        wndclass:WNDCLASS;
        WndClassCounter:Integer;
      {$ENDIF}
      procedure Update(Coord:TAGScreenCoord);
    public
      [weak] GaphicCore:TAGGraphicCore;
      Mouse:TAGMouseClicer;
      Handle,DC,DC0:nativeint;
      inputproc:TAGKeyProc;
      FPS:TAGFPSCounter;
      InputRemaper:TInputRemaper;
      class function GetWindowFromCore(Core:TAGGraphicCore):TAGWindow;static;
      {$IFDEF MSWINDOWS}function WndProc(hwnd,msg,wParam,lParam:NativeUInt):NativeUInt;{$ENDIF}
      constructor Create(WindowName:string;coord:TAGScreenCoord;Graphic:TAGGraphicCore;fscr:boolean);
      destructor Destroy();override;
      function GetCoord():TAGScreenCoord;
  end;

var
  NowCreateWindow:TAGWindow;

function AGLoadICO(f:pwidechar):boolean;

Implementation

constructor TAGFPSCounter.Create();
begin
  BeginTime:=Now;
  NowFPS:=0;
  count:=0;
end;

procedure TAGFPSCounter.Update();
begin
  if MilliSecondsBetween(BeginTime,Now)>1000 then
  begin
    self.BeginTime:=Now;
    NowFPS:=count;
    count:=1;
  end
  else
    inc(count,1);
end;

{$IFDEF MSWINDOWS}
const
  WS_EX_NOREDIRECTIONBITMAP=2097152;
  WS_FULLSCREEN=WS_VISIBLE or WS_POPUP or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
  WS_NOFULLSCREEN=WS_VISIBLE or WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN;

var
  ico:Nativeuint;

constructor TAGKeyInfo.MkFromLParam(lParam:NativeInt);
begin
  Repeats:=lParam and $FFFF;
  Status:=TAGKeyStatusPressed
end;

function unvert(i:nativeint):TAGscreenVector;inline;
begin
  Result.X:=$FFFF and i;
  Result.Y:=i div $FFFF;
end;

function delta(i:nativeint):SmallInt;
begin
  Result:=i div $FFFF;
end;

{TAGWindow}

class function TAGWindow.GWndProc(hwnd,msg,wParam,lParam:NativeUInt):NativeUInt;stdcall;
var
  Window:TAGWindow;
begin
  try
    if WindowByHandle.TryGetValue(HWND,Window) then
      Result:=Window.WndProc(hwnd,msg,wParam,lParam)
    else
      Result:=DefWindowProc(hwnd,msg,wParam,lParam);
  except on E:Exception do
    begin
      MessageBox(0,PWideChar(E.Message),'ERROR',MB_OK+MB_ICONWARNING);
      Halt;
    end;
  end;
end;

class function TAGWindow.GetWindowFromCore(Core:TAGGraphicCore):TAGWindow;
var
  Enum:TEnumerator<TPair<THandle,TAGWindow>>;
begin
  Enum:=WindowByHandle.GetEnumerator;
  while Enum.MoveNext do
    if Enum.Current.Value.GaphicCore.Equals(Core) then
      exit(Enum.Current.Value);
end;

function TAGWindow.WndProc(hwnd,msg,wParam,lParam:NativeUInt):NativeUInt;
begin
  Result:=0;
  case msg of
  WM_CREATE:;
  WM_DESTROY:PostQuitMessage(0);
  //WM_CLOSE:Result:=0;
  wm_paint:
  begin
    FPS.Update();
    GaphicCore.onpaint();
    Result:=0;
  end;
  WM_KEYDOWN,WM_KEYUP:
  begin
    if Assigned(InputRemaper)then
      wParam:=InputRemaper(wParam);
    if addr(inputproc)<>nil then
      inputproc(wParam,TAGKeyInfo.MkFromLParam(lParam));
  end;
  WM_SIZE:GaphicCore.ReSize(lParam mod 65536,lParam div 65536);
  WM_LBUTTONDOWN:if Assigned(Mouse.L.dwn) then
                   Mouse.L.dwn(unvert(lParam));
  WM_MBUTTONDOWN:if Assigned(Mouse.M.dwn) then
                   Mouse.M.dwn(unvert(lParam));
  WM_RBUTTONDOWN:if Assigned(Mouse.R.dwn) then
                   Mouse.R.dwn(unvert(lParam));
  WM_XBUTTONDOWN:if Assigned(Mouse.X.dwn) then
                   Mouse.X.dwn(unvert(lParam));
  WM_LBUTTONUP:if Assigned(Mouse.L.up) then
                 Mouse.L.up(unvert(lParam));
  WM_MBUTTONUP:if Assigned(Mouse.M.up) then
                 Mouse.M.up(unvert(lParam));
  WM_RBUTTONUP:if Assigned(Mouse.R.up) then
                 Mouse.R.up(unvert(lParam));
  WM_XBUTTONUP:if Assigned(Mouse.X.up) then
                 Mouse.X.up(unvert(lParam));
  WM_LBUTTONDBLCLK:if Assigned(Mouse.L.dclk) then
                 Mouse.L.dclk(unvert(lParam));
  WM_MBUTTONDBLCLK:if Assigned(Mouse.M.dclk) then
                 Mouse.M.dclk(unvert(lParam));
  WM_RBUTTONDBLCLK:if Assigned(Mouse.R.dclk) then
                     Mouse.R.dclk(unvert(lParam));
  WM_XBUTTONDBLCLK:if Assigned(Mouse.X.dclk) then
                     Mouse.X.dclk(unvert(lParam));
  WM_MOUSEMOVE:if Assigned(Mouse.move) then
                  Mouse.move(unvert(lParam));
  WM_MOUSEWHEEL:if Assigned(Mouse.wheel) then
                  Mouse.wheel(delta(wParam),unvert(lParam));
  WM_MOUSEHWHEEL:if Assigned(Mouse.hwheel) then
                   Mouse.hwheel(delta(wParam),unvert(lParam));
  else
    Result:=DefWindowProc(hwnd,msg,wParam,lParam);
  end;
end;

procedure TAGWindow.Update(Coord:TAGScreenCoord);
var
  point,point0:TPoint;
  WSize:TSize;
  bl:TBlendFunction;
begin
  with Coord do
  begin
    point:=TPoint.Create(Coord.X,Coord.Y);
    point0:=TPoint.Create(0,0);
    WSize:=TSize.Create(W,H);
    DC:=getdc(0);
    DC0:=CreateCompatibleDC(DC);
    bl.BlendOp:=AC_SRC_OVER;
    bl.BlendFlags:=0;
    bl.SourceConstantAlpha:=255;
    bl.AlphaFormat:=AC_SRC_ALPHA;
    UpdateLayeredWindow(Handle,DC,addr(point),addr(WSize),DC0,addr(point0),rgb(0,0,0),addr(bl),ULW_ALPHA);
  end;
end;

constructor TAGWindow.Create(WindowName:string;Coord:TAGScreenCoord;Graphic:TAGGraphicCore;fscr:boolean);
var
  Style:Cardinal;
begin
  if fscr then
    Style:=WS_FULLSCREEN
  else
    Style:=WS_NOFULLSCREEN;
  NowCreateWindow:=self;
  InputRemaper:=nil;
  with Coord do
  begin
    self.FPS:=TAGFPSCounter.Create;
    GaphicCore:=Graphic;
    wndclass.Style:=cs_hRedraw+cs_vRedraw;
    wndclass.cbClsExtra:=0;
    wndclass.cbWndExtra:=0;
    wndclass.hInstance:=system.MainInstance;
    wndclass.hIcon:=ico;
    wndclass.hCursor:=LoadCursor(0, idc_Arrow);
    wndclass.hbrBackground:=GetStockObject(WHITE_BRUSH);
    wndclass.lpszMenuName:=nil;
    wndclass.lpszClassName:=PWideChar(self.ClassName+inttostr(WndClassCounter));
    inc(WndClassCounter);

    wndclass.lpfnWndProc:=addr(GWndProc);
    RegisterClass(wndclass);
    Handle:=CreateWindow(wndclass.lpszClassName,PWideChar(WindowName),Style,X,Y,W,H,0,0,GetModuleHandle(nil),nil);
    WindowByHandle.Add(Handle,self);
    GaphicCore.init(W,H,Handle,fscr);

    if Handle<>0 then
    begin
      ShowWindow(Handle,CmdShow);
      if fscr then
        ShowWindow(Handle,SW_SHOWMAXIMIZED)
      else
        ShowWindow(Handle,SW_NORMAL);
    end;
  end;
  Pointer(NowCreateWindow):=nil;
end;

destructor TAGWindow.Destroy();
begin
  DestroyWindow(Handle);
  UnregisterClass(wndclass.lpszClassName,wndclass.hInstance);
  WindowByHandle.Remove(Handle);
  Pointer(GaphicCore):=nil;
  FreeAndNil(FPS);
end;

function TAGWindow.GetCoord():TAGScreenCoord;
var
  q:TRect;
begin
  GetWindowRect(Handle,q);
  Result:=TAGScreenCoord.FromTRect(q);
end;

function AGLoadICO(f:pwidechar):boolean;
var
  ico0:NativeUInt;
begin
  ico0:=LoadImage(0,f,IMAGE_ICON,0,0,LR_LOADFROMFILE or LR_DEFAULTSIZE or LR_DEFAULTCOLOR);
  Result:=ico0<>0;
  if Result then
  begin
    DestroyIcon(ico);
    ico:=ico0;
  end;
end;

initialization
  TAGWindow.WindowByHandle:=TDictionary<THandle,TAGWindow>.Create();
  ico:=LoadIcon(0,idi_Application);
{$ENDIF}

{$IFDEF ANDROID}
{TAGWindow}

procedure TAGWindow.Update(Coord:TAGScreenCoord);
begin

end;

class function TAGWindow.GetWindowFromCore(Core:TAGGraphicCore):TAGWindow;
begin

end;

constructor TAGWindow.Create(WindowName:string;coord:TAGScreenCoord;Graphic:TAGGraphicCore;fscr:boolean);
begin

end;

destructor TAGWindow.Destroy();
begin

end;

function TAGWindow.GetCoord():TAGScreenCoord;
begin

end;

function AGLoadICO(f:pwidechar):boolean;
begin

end;
{$ENDIF}

end.
