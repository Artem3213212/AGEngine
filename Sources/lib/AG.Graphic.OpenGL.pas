unit AG.Graphic.OpenGL;

interface

{$i main.conf}

{$IFDEF OpenGL}
uses
  System.SysUtils,System.Generics.Collections,
  AG.Graphic,AG.Types,AG.Resourcer,
  //{$IFDEF AGP}AG.STD.BitMaps,{$ENDIF}
  {$IFDEF VampyreIL}ImagingOpenGL,{$ENDIF}
  Winapi.OpenGL,Winapi.OpenGLext,Winapi.Windows;

type
  TAGOpenGLOldCallPproc=reference to procedure();
  TAGOpenGlGraphicCore=class (TAG3DGraphicCore)
    protected
      FrameBuffer:GlUint;
      Calls:TQueue<TAGOpenGLOldCallPproc>;
      Context:NativeUInt;
      pf:PIXELFORMATDESCRIPTOR;
      DC:nativeint;
      col:TAGFloatColor;
      mode:record
        act:(TAGOpenGlGraphicCore_Off,TAGOpenGlGraphicCore_On,TAGOpenGlGraphicCore_point,
          TAGOpenGlGraphicCore_line,TAGOpenGlGraphicCore_triangle);
        size:cardinal;
      end;
      size:TAGScreenVector;
      fonts:array [0..256]of record
        base:Cardinal;
        font:NativeUInt;
        //gmf:array[0..255] of GLYPHMETRICSFLOAT;
      end;
      const
        STDPic=0;
        {$IFDEF WIC}WICPic=1;{$ENDIF}
        RenderPic=2;
      procedure SetBackColor(color:TAGColor);override;
      function GetBackColor:TAGColor;override;

      {procedure SetMinDepth(d:Single);virtual;abstract;
      function GetMinDepth:Single;virtual;abstract;

      procedure SetMaxDepth(d:Single);virtual;abstract;
      function GetMaxDepth:Single;virtual;abstract;}
    public
      //destructor Destroy();override;
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;under,fscr:boolean);override;
      procedure OnPaint();override;
      procedure Resize(W,H:Word);override;
      //2D
      function CreateBrush(color:TAGColor):TAGBrush;overload;override;
      //function CreateBrush(Colors:TAGGradientColors):TAGBrush;overload;override;
      function CreateBitMap(p:TAGResourceImage):TAGEngineBitMap;overload;override;
      //function GetBtmForDraw:TAGEngineBitMap;overload;override;
      procedure PreDrawHook();inline;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;overload;override;
      procedure Init2D();overload;override;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);overload;override;
      procedure ReleaseBrush(b:TAGBrush);overload;override;
      procedure ReleaseBitMap(b:TAGEngineBitMap);overload;override;
      procedure DrawPoint(point:TAGscreenVector;size:word;brush:TAGBrush);overload;override;
      procedure DrawRectangle(rect:TAGscreenCoord;size:word;brush:TAGBrush);overload;override;
      procedure DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);overload;override;
      procedure DrawLine(point0,point1:TAGscreenVector;size:word;brush:TAGBrush);overload;override;
      procedure DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);overload;override;
      procedure DrawBitmap(coord:TAGscreenCoord;bitmap:TAGEngineBitMap;opacity:byte=255;f:boolean=False);overload;override;
      //procedure FillRectangle(rect:TAGscreenCoord;brush:TAGBrush);override;
      //procedure FillElips(point,radaii:TAGscreenVector;brush:TAGBrush);override;
      //3D
      procedure DrawTriangle(a,b,c:TAG3DVector);overload;override;
      {$IFDEF Easter_Egg}
      procedure DrawGreatLoadScreen();overload;override;
      {$ENDIF}
  end;

  TAGOpenGlRenderBitMapGraphicCore=class(TAGOpenGlGraphicCore)
    protected
      BM:TAGEngineBitMap;
      constructor Create(W,H:cardinal;OldCore:TAGOpenGlGraphicCore);
    public
      destructor Destroy();override;
      function GetBtmForDraw:TAGEngineBitMap;override;
      //убираем лишнее
      procedure Resize(W,H:Word);virtual;abstract;
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;under,fscr:boolean);virtual;abstract;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;override;
  end;
{$ENDIF}

implementation

{$IFDEF OpenGL}
procedure TAGOpenGlGraphicCore.SetBackColor(color:TAGColor);
begin
col:=TAGColorToTAGFloatColor(color);
end;

function TAGOpenGlGraphicCore.GetBackColor:TAGColor;
begin
Result:=TAGFloatColorToTAGColor(col);
end;

procedure TAGOpenGlGraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;under,fscr:boolean);
begin
InitOpenGLext;
parrent:=nil;
if not under then
begin
  hwnd:=hWindow;
  MainWindow:=hwnd;
  hWindow:=GetDC(hWindow);
end;
with pf do
begin
  nSize:=sizeof(PIXELFORMATDESCRIPTOR);
  nVersion:=1;
  dwFlags:=PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER+PFD_DRAW_TO_WINDOW;
  iPixelType:=PFD_TYPE_RGBA;
  cColorBits:=16;
  cAccumBits:=0;
  cDepthBits:=16;
  cStencilBits:=0;
  iLayerType:=PFD_MAIN_PLANE;
  MainWindow:=0;
end;
Calls:=TQueue<TAGOpenGLOldCallPproc>.Create;
SetPixelFormat(hWindow,ChoosePixelFormat(hWindow,addr(pf)),addr(pf));
Context:=wglCreateContext(hWindow);
wglMakeCurrent(hWindow,Context);
glViewport(0,0,W,H);
DC:=hWindow;
if assigned(initer)then
  initer(self);
Resize(W,H);
FontsInit();
glGetIntegerv(GL_FRAMEBUFFER_BINDING,addr(FrameBuffer));

//wglCreateLayerContext();
end;

procedure TAGOpenGlGraphicCore.OnPaint();
  {//Test 3D
  procedure Test3D(Self:TAGOpenGlGraphicCore);
  var
    a:FMX.DAE.Model.TDAEModel;
    i:integer;
    b:TAG3DVector;
  const
    c=0.1;
  begin
  with Self do
  begin
    //glLoadIdentity();
    //glFrustum(-1,1,1,-1,10,-10);
    b:=TAG3DVector.Create(0,0,0);//
    //b:=TAG3DVector.Create(800,1000,0);//
    //b:=TAG3DVector.Create(0.3,0,0);//
    glRotate(0.1*GetTickCount,0,1,1);
    a:=TDAEModel.Create;
    a.LoadFromFile('W:\AGEngine\Data\cube.dae');
    for i:=0 to length(a.Meshes[0].SubMeshes[0].FTriangles)-3 do
    begin
      if (i mod 3)=0 then
      DrawTriangle(a.Meshes[0].SubMeshes[0].FTriangles[i].Pos*c+b,
                   a.Meshes[0].SubMeshes[0].FTriangles[i+1].Pos*c+b,
                   a.Meshes[0].SubMeshes[0].FTriangles[i+2].Pos*c+b);
    end;
  end;
  end;
  //end}
var
  ps:PAINTSTRUCT;
begin
  wglMakeCurrent(DC,Context);
  while Calls.Count<>0 do
  begin
    Calls.Extract()();
  end;
  with col do
    glClearColor(R,G,B,A);
  glEnable(GL_POINT_SMOOTH);
  glEnable(GL_BLEND);
  glEnable(GL_TEXTURE_2D);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_MULTISAMPLE);


  glPixelStorei(GL_RGBA_MODE,0);
  glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;

  mode.act:=TAGOpenGlGraphicCore_On;
  if assigned(drawer) then
    drawer(self);

  //DrawGreatLoadScreen;
  //Test3D(Self);

  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  mode.act:=TAGOpenGlGraphicCore_Off;



  SwapBuffers(DC);
end;

procedure TAGOpenGlGraphicCore.Resize(W,H:Word);
begin
  glViewport(0,0,W,H);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  InvalidateRect(hwnd, nil, False);
  size.X:=W;
  size.Y:=H;
  glMatrixMode(GL_PROJECTION);
end;

function TAGOpenGlGraphicCore.CreateBrush(color:TAGColor):TAGBrush;
begin
  Result.AGColor:=color;
end;

function TAGOpenGlGraphicCore.CreateBitMap(p:TAGResourceImage):TAGEngineBitMap;
var
  {$IFDEF AGP}pic:^TAGBitMap;{$ENDIF}
  pp:^TAGResourceImage;
  A:TAGEngineBitMap;
begin
  case p.encoder of
  AGRIE_None:A.def:=0;
  {$IFDEF AGP}
  AGRIE_AGP:
  begin
    GetMem(A.OpenGL,SizeOf(A.OpenGL^));
    GetMem(pic,SizeOf(pic^));
    pic^:=DecodeAGP(p.d).Copy();
    Calls.Enqueue(procedure
                  begin
                    glGenTextures(1,A.OpenGL);
                    glBindTexture(GL_TEXTURE_2D,A.OpenGL^);
                    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
                    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
                    glTexImage2D(GL_TEXTURE_2D,0,4,pic.W,pic.H,0,GL_BGRA_EXT,GL_UNSIGNED_BYTE,pic.p);
                    glBindTexture(GL_TEXTURE_2D,0);
                    FreeMem(pic);
                  end);
  end;
  {$ENDIF}
  {$IFDEF VampyreIL}
  AGRIE_Vampyre:
  begin
    GetMem(A.OpenGL,SizeOf(A.OpenGL^));
    GetMem(pp,SizeOf(pp^));
    pp^.d:=p.d.Copy;
    Calls.Enqueue(procedure
                  var
                    c,b:LongInt;
                  begin
                    A.OpenGL^:=LoadGLTextureFromMemory(pp.d.p,p.d.sb,addr(c),addr(b));
                    pp^.Free;
                    FreeMem(pp);
                  end);
  end;
  {$ENDIF}
  {$IFDEF VampyreIL}
  else
    GetMem(A.OpenGL,SizeOf(A.OpenGL^));
    GetMem(pp,SizeOf(pp^));
    pp^.d:=p.d.Copy;
    Calls.Enqueue(procedure
                  var
                    c,b:LongInt;
                  begin
                  A.OpenGL^:=LoadGLTextureFromMemory(p.d.p,p.d.sb,addr(c),addr(b));
                  pp^.Free;
                  FreeMem(pp);
                  end);
  {$ENDIF}
  end;
  Result:=A;
end;

function TAGOpenGlGraphicCore.CreateNewRender(W,H:cardinal):TAGGraphicCore;
begin
  Result:=TAGOpenGlRenderBitMapGraphicCore.Create(W,H,self);
end;

procedure TAGOpenGlGraphicCore.Init2D();
begin
  glLoadIdentity();
  glOrtho(0,size.X,size.Y,0,10000,-1000);
end;

procedure TAGOpenGlGraphicCore.LoadFont(Name,Local:string;size:single;font:TAGFont);
begin
  with fonts[font] do
  begin// Список для 256 букв алфавита
   base:=glGenLists(256);
   // Создаем шрифт, подробнее см. SDK
   Font:=CreateFont(-28,0,0,0,FW_BOLD,0,0,0,RUSSIAN_CHARSET,OUT_TT_PRECIS,
   CLIP_DEFAULT_PRECIS,DRAFT_QUALITY,FF_DONTCARE or DEFAULT_PITCH,pwidechar(Name));
   // Устанавливаем шрифт для DC
   SelectObject(DC,Font);
   // Создаем команды списка.
   // Выбираем один из двух вариантов
   // Если используем wglUseFontBitmaps то - это растровое изображение
   {if not }wglUseFontBitmaps(DC,0,256,base);// then
   // Если используем wglUseFontOutlines то - это векторное изображение
   //if not wglUseFontOutlines(DC, 0, 255, base, 0, 0.2, WGL_FONT_POLYGONS, @gmf) then
     //MessageBox(0, 'Font not create', 'glBuildFont', MB_OK);
   // Удаляем шрифт, так как соответствующий список уже создан
   DeleteObject(Font);
  end;
end;

procedure TAGOpenGlGraphicCore.ReleaseBrush(b:TAGBrush);
begin
end;

procedure TAGOpenGlGraphicCore.ReleaseBitMap(b:TAGEngineBitMap);
begin
  Calls.Enqueue(procedure
                  begin
                  glDeleteTextures(1,Pointer(b.OpenGL));
                  FreeMem(b.OpenGL);
                  end);
end;

procedure TAGOpenGlGraphicCore.DrawPoint(point:TAGscreenVector;size:word;brush:TAGBrush);
begin
  PreDrawHook;
  if(mode.act<>TAGOpenGlGraphicCore_point)or(size<>mode.size)then
  begin
    if mode.act<>TAGOpenGlGraphicCore_On then
      glEnd;
    glPointSize(size);
    glbegin(GL_POINTS);
    mode.act:=TAGOpenGlGraphicCore_point;
    mode.size:=size;
  end;
  glColor4ubv(addr(brush.AGColor));
  glVertex2iv(addr(point));
end;

procedure TAGOpenGlGraphicCore.DrawRectangle(rect:TAGscreenCoord;size:word;brush:TAGBrush);
begin
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  mode.act:=TAGOpenGlGraphicCore_On;
  glLineWidth(size);
  glbegin(GL_LINE_LOOP);
  glColor4ubv(addr(brush.AGColor));
  with rect do
  begin
    glVertex2f(X,Y);
    glVertex2f(X+W,Y);
    glVertex2f(X+W,Y+H);
    glVertex2f(X,Y+H);
  end;
  glEnd;
end;

procedure TAGOpenGlGraphicCore.DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);
var
  i,st:integer;
begin
  with radaii do
    if x>y then
      st:=x
    else
      st:=y;
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  glLineWidth(size);
  mode.act:=TAGOpenGlGraphicCore_On;
  glColor4ubv(addr(brush.AGColor));
  glBegin(GL_LINE_LOOP);
  for i:=0 to st*2 do
    glVertex2f(cos(i*pi/st)*radaii.X+point.X,sin(i*pi/st)*radaii.Y+point.Y);
  glEnd;
end;

procedure TAGOpenGlGraphicCore.DrawLine(point0,point1:TAGscreenVector;size:word;brush:TAGBrush);
begin
  PreDrawHook;
  if(mode.act<>TAGOpenGlGraphicCore_line)or(size<>mode.size)then
  begin
    if mode.act<>TAGOpenGlGraphicCore_On then
      glEnd;
    glLineWidth(size);
    glbegin(GL_LINES);
    mode.act:=TAGOpenGlGraphicCore_line;
    mode.size:=size;
  end;
  glColor4ubv(addr(brush.AGColor));
  glVertex2iv(addr(point0));
  glVertex2iv(addr(point1));
end;

procedure TAGOpenGlGraphicCore.DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);
begin
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  mode.act:=TAGOpenGlGraphicCore_On;
  with fonts[font] do
  begin
    glRasterPos2i(position.Y,position.X+size*2);
    glPushAttrib(GL_LIST_BIT);
    // Указыывем, что первая буква алфавита рисуется 1-ым набором команд
    glListBase(base);
    // Выводим текст
    glCallLists(length(text),GL_UNSIGNED_SHORT,pChar(text));
    glPopAttrib();
  end;
end;

procedure TAGOpenGlGraphicCore.DrawBitmap(coord:TAGscreenCoord;bitmap:TAGEngineBitMap;opacity:byte=255;f:boolean=False);
begin
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  mode.act:=TAGOpenGlGraphicCore_On;
  glColor4d(1,1,1,opacity/255);

  glBindTexture(GL_TEXTURE_2D,bitmap.OpenGL^);
  if f then
  begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  end
  else
  begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  end;
  glBegin(GL_QUADS);
  with coord do
  begin
    glTexCoord2f(0,0);
    glVertex3f(X,Y,0);
    glTexCoord2f(0,1);
    glVertex2f(X,Y+H);
    glTexCoord2f(1,1);
    glVertex2f(X+W,Y+H);
    glTexCoord2f(1,0);
    glVertex2f(X+W,Y);
  end;
  glEnd();
  glBindTexture(GL_TEXTURE_2D,0);
end;


//3D
procedure TAGOpenGlGraphicCore.DrawTriangle(a,b,c:TAG3DVector);
begin
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_triangle then
  begin
    if mode.act<>TAGOpenGlGraphicCore_On then
      glEnd;
    //glTranslate(0,0,0);
    //glRotate(GetTickCount*0.001,0,0,1);
    //glTranslate(500,500,0);
    //glScale(0.1,0.1,0.01);

    glColor4f(1,0,0,1);
    glPointSize(10);
    glbegin(GL_POINTS);
    glVertex3fv(addr(a.V[0]));
    glVertex3fv(addr(b.V[0]));
    glVertex3fv(addr(c.V[0]));
    glEnd;
    glbegin(GL_TRIANGLES);
    mode.act:=TAGOpenGlGraphicCore_triangle;
  end;
  glColor4f(1,1,1,1);
  //glVertex3fv(addr(a.V[0]));
  //glVertex3fv(addr(b.V[0]));
  //glVertex3fv(addr(c.V[0]));
  glEnd;
  mode.act:=TAGOpenGlGraphicCore_On;
end;

{$IFDEF Easter_Egg}
procedure TAGOpenGlGraphicCore.DrawGreatLoadScreen();
var
  i:TAGConstVector3D;
const
  c=0.1;
  a:array[0..35]of TAGConstVector3D=(
    (V:(1,1,-1)),
    (V:(-0.999999701976776,1,-1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(-1,1,1)),
    (V:(1,0.999999523162842,1)),
    (V:(0.999999403953552,-1.00000095367432,1)),
    (V:(1,0.999999523162842,1)),
    (V:(1,1,-1)),
    (V:(1,-1,-1)),
    (V:(0.999999403953552,-1.00000095367432,1)),
    (V:(1,-1,-1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(-0.999999701976776,1,-1)),
    (V:(-1,1,1)),
    (V:(1,1,-1)),
    (V:(1,0.999999523162842,1)),
    (V:(-1,1,1)),
    (V:(1,1,-1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(1,-1,-1)),
    (V:(-1,1,1)),
    (V:(0.999999403953552,-1.00000095367432,1)),
    (V:(-1,-0.999999701976776,1)),
    (V:(1,0.999999523162842,1)),
    (V:(1,-1,-1)),
    (V:(0.999999403953552,-1.00000095367432,1)),
    (V:(0.999999403953552,-1.00000095367432,1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(-1,-0.999999701976776,1)),
    (V:(-1,-0.999999821186066,-1)),
    (V:(-1,1,1)),
    (V:(-1,-0.999999701976776,1)),
    (V:(1,1,-1)),
    (V:(-1,1,1)),
    (V:(-0.999999701976776,1,-1)));
begin
  PreDrawHook;
  if mode.act<>TAGOpenGlGraphicCore_On then
    glEnd;
  mode.act:=TAGOpenGlGraphicCore_On;
  glRotate(0.1*GetTickCount,0,1,1);
  glColor4f(1,0,0,1);
  glPointSize(10);
  glbegin(GL_POINTS);
  for i in a do
    with i do
      glVertex3f(V[0]*c,V[1]*c,V[2]*c);
  glEnd;
end;
{$ENDIF}

procedure TAGOpenGlGraphicCore.PreDrawHook;
var
  t:GlUint;
begin
  glGetIntegerv(GL_RENDERBUFFER_BINDING,addr(t));
  if t<>FrameBuffer then
  begin
    glBindTexture(GL_TEXTURE_2D,FrameBuffer);
    if mode.act<>TAGOpenGlGraphicCore_On then
      glEnd;
    mode.act:=TAGOpenGlGraphicCore_On;
  end;
end;

constructor TAGOpenGlRenderBitMapGraphicCore.Create(W,H:cardinal;OldCore:TAGOpenGlGraphicCore);
begin
  inherited Create;
  InitOpenGLext;
  parrent:=OldCore;
  Self.Context:=OldCore.Context;
  BM.&Type:=RenderPic;
  GetMem(BM.OpenGL,sizeof(BM.OpenGL^));

  OldCore.Calls.Enqueue(procedure
                  begin
                  glGenTextures(1,BM.OpenGL);
                  glBindTexture(GL_TEXTURE_2D,BM.OpenGL^);
                  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,W,H,0,GL_RGB,GL_UNSIGNED_BYTE,nil);
                  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
                  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
                  glBindTexture(GL_TEXTURE_2D,0);

                  glGenRenderbuffers(1,addr(FrameBuffer));
                  glBindRenderbuffer(GL_RENDERBUFFER,FrameBuffer);
                  glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT,W,H);
                  glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,FrameBuffer);

                  glFramebufferTexture(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,BM.OpenGL^,0);
                  glDrawBuffer(GL_COLOR_ATTACHMENT0);
                  //OldCore.Resize(OldCore.size.X,OldCore.size.Y);
                  end);

  size.X:=W;
  size.Y:=H;

  Calls:=OldCore.Calls;
end;

destructor TAGOpenGlRenderBitMapGraphicCore.Destroy();
begin
  ReleaseBitMap(BM);
  inherited Destroy;
end;

function TAGOpenGlRenderBitMapGraphicCore.GetBtmForDraw:TAGEngineBitMap;
begin
  Result:=BM;
end;

function TAGOpenGlRenderBitMapGraphicCore.CreateNewRender(W,H:cardinal):TAGGraphicCore;
begin
  Result:=parrent.CreateNewRender(W,H);
end;
{$ENDIF}

end.
