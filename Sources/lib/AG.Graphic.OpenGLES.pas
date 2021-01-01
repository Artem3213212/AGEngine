unit AG.Graphic.OpenGLES;

interface

{$i main.conf}

{$IFDEF OpenGLES}
uses
  System.SysUtils,System.Generics.Collections,
  AG.Graphic,AG.Graphic.Parallel,AG.Types,AG.Resourcer,
  //{$IFDEF AGP}AG.STD.BitMaps,{$ENDIF}
  //{$IFDEF VampyreIL}ImagingDirect3D8,{$ENDIF}
  EGL14,OpenGLES30;

type
  EAGGLESException=class(Exception);
  EAGEGLException=class(Exception);

  TAGOpenGLESCallPproc=reference to procedure();
  TAGOpenGLESGraphicCore=class(TAGParallelGraphicCore)
    protected
      ClearCollor:TAGFloatColor;
      display:EGLDisplay;
      context:EGLContext;
      surface:EGLSurface;
      config:EGLConfig;
      DefaultVertexBuff:Cardinal;
      Standart2DPixelShader,StandartVertexShader,Standart2DVertexShader:Cardinal;
      {procedure FontsInit();virtual;
      procedure ShadersInit();virtual;}

      procedure SetBackColor(color:TAGColor);override;
      function GetBackColor:TAGColor;override;
      //3D
      {procedure SetMinDepth(d:Single);virtual;abstract;
      function GetMinDepth:Single;virtual;abstract;

      procedure SetMaxDepth(d:Single);virtual;abstract;
      function GetMaxDepth:Single;virtual;abstract;

      procedure SetFOV(FOV:Single);virtual;abstract;
      function GetFOV:Single;virtual;abstract;
      //Shaders
      function GetShader(Usage:TAGShaderUsage):TAGShader;virtual;abstract;
      procedure SetShader(Usage:TAGShaderUsage;Shader:TAGShader);virtual;abstract;}
      function LoadShader(Shader:string;ShaderType:Cardinal):Cardinal;
      //Nil Data mean default shader
      //if(&Type=CPixelShader)and(PixelShaderType=CTextureShader) num meaning texture num;-1 meaning default value(using if not set)
      //if you use -1 and Nil Data, you use default shader as default value, else(0 or highter and Nil Data)you use default value as this shader
      //if you use -2 and Nil Data, you reset all Textures shaders(but not default Shader)
    public
      constructor Create();
      destructor Destroy;override;

      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);override;
      procedure OnPaint();override;
      procedure Resize(W,H:Word);override;
      //2D
      procedure Init2D();override;
      {function CreateBrush(Color:TAGColor):TAGBrush;overload;virtual;abstract;
      function CreateBrush(Colors:TAGGradientColors):TAGBrush;overload;virtual;abstract;//D2D1 Only
      function CreateBitMap(p:TAGResourceImage):TAGEngineBitMap;overload;virtual;abstract;
      function CreateBitMapFromFile(Name:String):TAGEngineBitMap;overload;virtual;abstract;
      function GetBtmForDraw:TAGEngineBitMap;virtual;abstract;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;virtual;abstract;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);virtual;abstract;
      procedure ReleaseBrush(b:TAGBrush);virtual;abstract;
      procedure ReleaseBitMap(b:TAGEngineBitMap);virtual;abstract;
      procedure DrawPoint(point:TAGscreenVector;size:word;brush:TAGBrush);virtual;abstract;
      procedure DrawRectangle(rect:TAGscreenCoord;size:word;brush:TAGBrush);virtual;abstract;
      procedure DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);virtual;abstract;
      procedure DrawLine(point0,point1:TAGscreenVector;size:word;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);virtual;abstract;
      procedure DrawBitmap(coord:TAGscreenCoord;bitmap:TAGEngineBitMap;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
      procedure FillRectangle(rect:TAGscreenCoord;brush:TAGBrush);virtual;abstract;
      procedure FillElips(point,radaii:TAGscreenVector;brush:TAGBrush);virtual;abstract;
      //3D

      procedure Init3D();virtual;abstract;
      function AddDirectLight(Direction:TAG3DVector;Color:TAGColor;Bright:Single=1):TAGLight;virtual;abstract;
      function AddPointLight(Position:TAG3DVector;Color:TAGColor;Range:Single;Bright:Single=1):TAGLight;virtual;abstract;
      function AddSpotLight(Position,Direction:TAG3DVector;Color:TAGColor;Range,Theta:Single;Bright:Single=1):TAGLight;virtual;abstract;
      function CreateTexFromFile(FileName:String):TAGTex;virtual;abstract;
      function CreateTexFromColor(c:TAGColor):TAGTex;virtual;abstract;
      procedure ResetLightSettings(Tex:TAGTex;Color:TAGColor;Diffuse,Ambient,Specular,Emissive:Single);virtual;abstract;
      procedure ReleaseTex(Tex:TAGTex);virtual;abstract;
      procedure ReleaseMesh(Mesh:TAGMesh);virtual;abstract;
      function CreateReTexturedMesh(Mesh:TAGMesh;Tex:TArray<TAGTex>;UseOriginalLightSettings:boolean=False):TAGMesh;virtual;abstract;
      function LoadXFile(Name:String;Texture:TArray<TAGTex>;UseXFileLightSettings:boolean=False):TAGMesh;overload;virtual;
      function LoadXFile(Name,Floder:String;Texture:TArray<TAGTex>;UseXFileLightSettings:boolean=False):TAGMesh;overload;virtual;abstract;
      function LoadXFileWithoutTextures(Name:String):TAGMesh;virtual;abstract;
      procedure DelLight(l:TAGLight);virtual;abstract;
      procedure SetCameraToObject(Cam,Obj:TAG3DVector);overload;virtual;
      procedure SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);overload;virtual;
      procedure SetCameraByMatrix(Matrix:TAG3DMatrix);overload;virtual;abstract;
      procedure DrawTriangle(a,b,c:TAG3DVector);virtual;abstract;
      procedure DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush);overload;virtual;
      procedure DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush;const Matrix:TAG3DMatrix);overload;virtual;abstract;
      procedure DrawBitmapTo3D(Coords:TAG3DSqueredPolygon;
        bitmap:TAGEngineBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
      procedure DrawBitmapBy3DCoords(Point:TAG3DVector;Mean:TAGSqueredPolygonPoitMeans;Size:TAG2DVector;
        bitmap:TAGEngineBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
      procedure DrawMesh(const Mesh:TAGMesh;UseLight:boolean=True);overload;virtual;
      procedure DrawMesh(const Mesh:TAGMesh;const Matrix:TAG3DMatrix;UseLight:boolean=True);overload;virtual;abstract;

      //Shaders
      function BuildShader(&Type:TAGShaderType;Source:string):TAGShader;virtual;abstract;
      procedure FreeShader(Shader:TAGShader);virtual;abstract;
      property Shaders[Usage:TAGShaderUsage]:TAGShader read GetShader write SetShader;

      //always
      function CompleteResourseImages(res:PAGResource):TAGEngineResource;overload;
      procedure CompleteResourseImages(var res:TAGEngineResource);overload;
      procedure ReleaseResourseImages(var res:TAGEngineResource);overload;
      function IsFullRender:boolean;}
  end;
{$ENDIF}

implementation

{$IFDEF OpenGLES}
procedure RaseEGLException();inline;
begin
  raise EAGEGLException.Create('EGL error. Code: 0x'+IntToHex(eglGetError(),8));
end;
procedure RaseGLESException();inline;
begin
  raise EAGGLESException.Create('GLES error. Code: 0x'+IntToHex(glGetError(),8));
end;

{TAGOpenGLESGraphicCore}
constructor TAGOpenGLESGraphicCore.Create();
begin
  inherited;
end;

destructor TAGOpenGLESGraphicCore.Destroy;
begin
  DoGraphic(procedure()
    begin
      glFlush();
      eglTerminate(display);
    end);
  inherited;
end;

procedure TAGOpenGLESGraphicCore.SetBackColor(color:TAGColor);
begin
  ClearCollor:=color;
end;

function TAGOpenGLESGraphicCore.GetBackColor:TAGColor;
begin
  Result:=ClearCollor;
end;

procedure TAGOpenGLESGraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);
begin
  ClearCollor:=TAGFloatColor.Create(0,0,0,0);
  DoGraphic(procedure()
    const
      attrConf:array[0..16]of integer=(EGL_SURFACE_TYPE,EGL_WINDOW_BIT,
        EGL_CONFORMANT,EGL_OPENGL_ES2_BIT,
        EGL_BLUE_SIZE,8,
        EGL_GREEN_SIZE,8,
        EGL_RED_SIZE,8,
        EGL_ALPHA_SIZE,8,
        EGL_BUFFER_SIZE,32,
        EGL_DEPTH_SIZE,24,
        EGL_NONE);
      attrContx:array[0..2]of integer=(EGL_CONTEXT_CLIENT_VERSION,2,EGL_NONE);
    var
      n:Integer;
      v:integer;
    begin
      display:=eglGetDisplay(EGL_DEFAULT_DISPLAY);
      v:=3;
      if(display<>EGL_NO_DISPLAY)and eglInitialize(display)and eglChooseConfig(display,@attrConf[0],@config,1,n)then
      begin
        surface:=eglCreateWindowSurface(display,config,hWindow,nil);
        eglBindAPI(EGL_OPENGL_API);
        //MessageBoxA(0,PAnsichar(glGetString(GL_EXTENSIONS)),nil,0);
        context:=eglCreateContext(display,config,EGL_NO_CONTEXT,nil);
        eglQueryContext(display, context, EGL_CONTEXT_CLIENT_VERSION, &v);

        //eglQuerySurface(display,surface,EGL_WIDTH,W);
        //eglQuerySurface(display,surface,EGL_HEIGHT,H);

        if eglMakeCurrent(display,surface,surface,context)then
        begin
          //glViewport(0,0,W,H);
          glEnable(GL_BLEND);
          glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
          //glGenVertexArrays(1,@DefaultVertexBuff);
          //Standart2DVertexShader:=LoadShader('layout(location = 0) in vec4 Pos;main{gl_Position=Pos;}',GL_VERTEX_SHADER);
          //Standart2DPixelShader:=LoadShader('layout(location=0)uniform vec4 Color=vec3(0,0,0);main{gl_FragColor=Color;}',GL_FRAGMENT_SHADER);
        end
        else
          RaseEGLException;
      end
      else
        RaseEGLException
    end);
    DoGraphic(procedure()
      var
        Prog:Cardinal;
      begin
        Prog:=glCreateProgram;
        glAttachShader(Prog,Standart2DPixelShader);
        glAttachShader(Prog,Standart2DVertexShader);
        glLinkProgram(Prog);
        glUseProgram(Prog);
      end);
end;

procedure TAGOpenGLESGraphicCore.OnPaint();
begin
  DoGraphic(procedure()
    begin
      with ClearCollor do
        glClearColor(R,G,B,A);
      glDepthRangef(0,1);
      glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);
    end);
  if Assigned(drawer) then
    drawer(self);
  DoGraphic(procedure()
    const
      aaa:array[0..4*4-1]of single=(-0.4,-0.4,0,1,
                                  -0.4,0.4,0,1,
                                  0.4,0.4,0,1,
                                  0.4,-0.4,0,1);
      Matrix:array[0..4*4-1]of single=(1,0,0,0,
                                       0,1,0,0,
                                       0,0,1,0,
                                       0,0,0,1);
    begin
	    //glUniformMatrix4fv(Matrix,1,false,Matrix);
      {glBindBuffer(GL_ARRAY_BUFFER,DefaultVertexBuff);
	    glBufferData(GL_ARRAY_BUFFER,sizeof(aaa),@aaa,GL_STATIC_DRAW);
      glEnableVertexAttribArray(DefaultVertexBuff);
      glVertexAttribPointer(0,4,GL_FLOAT,false,0,@aaa);
      glDrawArrays(GL_TRIANGLE_STRIP,0,4);}
      glDisableVertexAttribArray(DefaultVertexBuff);
      glFlush();
      eglSwapBuffers(display,surface);
    end);
end;

procedure TAGOpenGLESGraphicCore.Resize(W,H:Word);
begin

end;

procedure TAGOpenGLESGraphicCore.Init2D();
begin

end;

function TAGOpenGLESGraphicCore.LoadShader(Shader:String;ShaderType:Cardinal):Cardinal;
var
  //len:array of integer;
  //addr:array of pointer;
  //i,currlen:integer;
  PAsniShader:PAnsiChar;
begin
  //eglInitialize(display);
  //eglBindAPI(EGL_OPENGL_ES3_BIT);
      Result:=glCreateShader(ShaderType);
      PAsniShader:=PAnsiChar(Shader);
      {SetLength(addr,0);
      SetLength(len,0);
      i:=0;
      currlen:=0;
      while ord(PAsniShader^)<>0 do
      begin
        if currlen=0 then
        begin
          if not((ord(PAsniShader^)=$10)or(ord(PAsniShader^)=$13))then
          begin
            inc(i);
            SetLength(addr,i);
            SetLength(len,i);
            addr[i-1]:=PAsniShader;
            currlen:=1;
          end;
        end
        else
        begin
          if(ord(PAsniShader^)=$10)or(ord(PAsniShader^)=$13)then
          begin
            len[i-1]:=currlen;
            currlen:=0
          end
          else
            inc(currlen);
        end;
        inc(PAsniShader);
      end;
      if currlen<>0 then
    len[i-1]:=currlen;}
    //if Result=0 then
    //  RaseGLESException
    //else
    //begin
    //glShaderSource(Result,i,@addr[0],@len[0]);
    glShaderSource(Result,1,@PAsniShader,nil);
    glCompileShader(Result);
    //end;
end;
{$ENDIF}

end.
