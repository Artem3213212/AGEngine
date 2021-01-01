unit AG.Graphic.D3D9;

interface

{$i main.conf}

{$IFDEF D3D9}
uses
  Winapi.Windows,Winapi.Direct3D9,Winapi.D3DX9,Winapi.DXTypes,
  AG.Graphic,AG.Types,AG.Resourcer,AG.Shaders,AG.Utils,
  {$IFDEF VampyreIL}ImagingDirect3D9,{$ENDIF}
  System.SysUtils,System.Classes,System.IOUtils,System.Generics.Collections,System.Math.Vectors;

{TODO -oArtem: FillElips}
{TODO -oArtem: DrawTriangle}
{TODO -oArtem: DrawPoint}

type
  TAGD3D9GraphicCore=class abstract(TAG3DGraphicCore)
    protected
      d3p:D3DPRESENT_PARAMETERS;
      fonts:TDictionary<TAGFont,ID3DXFont>;
      Dev:IDirect3DDevice9;
      ScrSize:TAGScreenVector;
      FBackColor:TAGColor;
      Camera3D,Camera2D:TD3DXMatrix;
      Use3D:Boolean;
      FMinDepth,FMaxDepth,FFOV:Single;

      function FCreateTexFromFile(FileName:String):TAGD3D9Mat;virtual;
      procedure SetMaterial(Mat:TAGD3D9Mat);virtual;

      function GenProjection():TD3DXMatrix;//inline;
      procedure Update2DCam();

      procedure SetBackColor(color:TAGColor);override;
      function GetBackColor:TAGColor;override;

      procedure SetMinDepth(d:Single);override;
      function GetMinDepth:Single;override;

      procedure SetMaxDepth(d:Single);override;
      function GetMaxDepth:Single;override;

      procedure SetFOV(AFOV:Single);override;
      function GetFOV:Single;override;
      const
        DEFTEXF=D3DTEXF_LINEAR;
    public
      constructor Create();
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);override;
      procedure OnPaint();override;
      procedure Resize(W,H:Word);override;
      destructor Destroy();override;
      procedure SetDebug(param1,param2:NativeUInt);
      //2D
      function CreateBrush(Color:TAGColor):TAGBrush;override;
      //function CreateBrush(Colors:TAGGradientColors):TAGBrush;override;//D2D1 Only
      function CreateBitMap(p:TAGResourceImage):TAGBitMap;override;
      function CreateBitMapFromFile(Name:String):TAGBitMap;override;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);override;
      procedure ReleaseBrush(b:TAGBrush);override;
      procedure ReleaseBitMap(b:TAGBitMap);override;
      procedure DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawText(text:string;position:TAGCoord;size:word;font:TAGFont;brush:TAGBrush);override;
      //3D
      function CreateTexFromFile(FileName:String):TAGTex;override;
      function CreateTexFromColor(c:TAGColor):TAGTex;override;
      procedure ResetLightSettings(Tex:TAGTex;Color:TAGColor;Diffuse,Ambient,Specular,Emissive:Single);override;
      procedure ReleaseTex(Tex:TAGTex);override;
      procedure ReleaseMesh(Mesh:TAGMesh);override;
      function CreateReTexturedMesh(Mesh:TAGMesh;Tex:TArray<TAGTex>;UseOriginalLightSettings:boolean=False):TAGMesh;override;
      function LoadXFile(Name,Floder:String;Texture:TArray<TAGTex>;UseXFileLightSettings:boolean=False):TAGMesh;override;
      function LoadXFileWithoutTextures(Name:String):TAGMesh;override;
      function LoadXFile2(Name:String;Texture:TArray<TAGTex>;Floder:String=''):TAGMesh;
  end;

  TAGD3D9NoShaderGraphicCore=class(TAGD3D9GraphicCore)//unsupported speculars and normals
    protected
      procedure SetMaterial(Mat:TAGD3D9Mat);override;

      procedure CameraUpdate(m:TD3DXMatrix);//override;

      procedure SetMinDepth(d:Single);override;
      procedure SetMaxDepth(d:Single);override;
      procedure SetFOV(AFOV:Single);override;
    public
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);override;
      //2D
      procedure Init2D();override;
      //function CreateNewRender(W,H:cardinal):TAGGraphicCore;virtual;abstract;
      //procedure DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawRectangle(rect:TAGCoord;size:word;brush:TAGBrush);override;
      procedure DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);override;
      procedure FillRectangle(rect:TAGCoord;brush:TAGBrush);override;
      //procedure FillElips(point,radaii:TAG2DVector;brush:TAGBrush);override;
      //3D
      procedure Init3D();override;
      function AddDirectLight(Direction:TAG3DVector;Color:TAGColor;Bright:Single=1):TAGLight;override;
      function AddPointLight(Position:TAG3DVector;Color:TAGColor;Range:Single;Bright:Single=1):TAGLight;override;
      function AddSpotLight(Position,Direction:TAG3DVector;Color:TAGColor;Range,Theta:Single;Bright:Single=1):TAGLight;override;
      procedure DelLight(l:TAGLight);override;
      procedure SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);override;
      procedure SetCameraByMatrix(Matrix:TAG3DMatrix);override;
      //procedure DrawTriangle(a,b,c:TAG3DVector);virtual;abstract;
      procedure DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush);override;
      {procedure DrawBitmapTo3D(Coords:TAG3DSqueredPolygon;
        bitmap:TAGBitMap;const Matrix:TAGMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
      procedure DrawBitmapBy3DCoords(Point:TAG3DVector;Mean:TAGSqueredPolygonPoitMeans;
        bitmap:TAGBitMap;const Matrix:TAGMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;}
      procedure DrawMesh(const Mesh:TAGMesh;const Matrix:TAG3DMatrix;UseLight:boolean=True);override;
  end;

  TAGD3D9ShaderGraphicCore=class (TAGD3D9GraphicCore)
    protected type
      TPixelShaderAbout=packed record
        Direct,Point,Spot:byte;
        constructor Create(ADirect,APoint,ASpot:byte);
      end;
    protected
      Standart2DPixelShader:IDirect3DPixelShader9;
      StandartVertexShader,Standart2DVertexShader:IDirect3DVertexShader9;
      DefPixelShaders:TDictionary<TPixelShaderAbout,IDirect3DPixelShader9>;
      LitingConf:packed record
        BaseID:NativeInt;
        NeedUpdate:boolean;
        Direct:array of record
          FID:NativeUInt;
          FDir,FCol:TD3DXVector3;
          FBright:Single;
        end;
        Point:array of record
          FID:NativeUInt;
          FPos,FCol:TD3DXVector3;
          FRange,FBright:Single;
        end;
        Spot:array of record
          ID:NativeUInt;
          Pos,Dir,Col:TD3DXVector3;
          Range,Theta,Bright:Single;
        end;
      end;
      Shaders:record
        Vertex:IDirect3DVertexShader9;
        PreProcess,PostProcess,TextureDef:IDirect3DPixelShader9;
        Textures:TArray<IDirect3DPixelShader9>;
      end;

      function LoadVertexShader(Shader:AnsiString):IDirect3DVertexShader9;
      function LoadPixelShader(Shader:AnsiString):IDirect3DPixelShader9;

      procedure SetUnicolorMod(Col:TAGColor);inline;
      //2D
      procedure Update2DVertexConfig();inline;
      procedure Set2DVertexDeclaration(UseText,UseColor:boolean);inline;
      procedure Set2DTexturedMod(Text:IDirect3DTexture9;opacity:single=1);inline;
      //3D
      function FCreateTexFromFile(FileName:String):TAGD3D9Mat;override;
      procedure SetMaterial(Mat:TAGD3D9Mat);override;
      procedure Set3DUniTextureMod(Text:IDirect3DTexture9;opacity:single=1);
      procedure Update3DVertexConfig();overload;inline;
      procedure Update3DVertexConfig(CurrPos:TD3DXMatrix);overload;inline;
      procedure Update3DVertexConfigAsIdenty();
      procedure Set3DOpacity(opacity:Single);inline;
      procedure Set3DLightingEnable(Enable:longbool);inline;
      function GenPixel3DShader(Direct,Point,Spot:byte):AnsiString;
      function GetPixel3DShader(Direct,Point,Spot:byte):IDirect3DPixelShader9;inline;
      procedure UpdateLightingConf();
      //Shaders
      function GetShader(Usage:TAGShaderUsage):TAGShader;override;
      procedure SetShader(Usage:TAGShaderUsage;Shader:TAGShader);override;
    public
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);override;
      //2D
      procedure Init2D();override;
      {function GetBtmForDraw:TAGBitMap;virtual;abstract;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;virtual;abstract;
      procedure DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush);virtual;abstract;}
      procedure DrawRectangle(rect:TAGCoord;size:word;brush:TAGBrush);override;
      procedure DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);override;
      procedure FillRectangle(rect:TAGCoord;brush:TAGBrush);override;
      //procedure FillElips(point,radaii:TAG2DVector;brush:TAGBrush);virtual;abstract;
      //3D
      procedure Init3D();override;
      function AddDirectLight(Direction:TAG3DVector;Color:TAGColor;Bright:Single=1):TAGLight;override;
      function AddPointLight(Position:TAG3DVector;Color:TAGColor;Range:Single;Bright:Single=1):TAGLight;override;
      //function AddSpotLight(Position:TAG3DVector;Direction:TAG3DVector;Range,Theta:Single;Color:TAGColor;Bright:Single=1):TAGLight;override;
      {procedure ResetLightSettings(Tex:TAGTex;Color:TAGColor;Diffuse,Ambient,Specular,Emissive:Single);virtual;abstract;
      procedure ReleaseTex(Tex:TAGTex);virtual;abstract;
      function CreateReTexturedMesh(Mesh:TAGMesh;Tex:TArray<TAGTex>;UseOriginalLightSettings:boolean=False):TAGMesh;virtual;abstract;}
      procedure DelLight(l:TAGLight);override;
      procedure SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);override;
      procedure SetCameraByMatrix(Matrix:TAG3DMatrix);override;
      {procedure DrawTriangle(a,b,c:TAG3DVector);virtual;abstract;}
      procedure DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush;const Matrix:TAG3DMatrix);override;
      {procedure DrawBitmapTo3D(Coords:TAG3DSqueredPolygon;
        bitmap:TAGBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;}
      procedure DrawBitmapBy3DCoords(Point:TAG3DVector;Mean:TAGSqueredPolygonPoitMeans;Size:TAG2DVector;
        bitmap:TAGBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);override;
      procedure DrawMesh(const Mesh:TAGMesh;const Matrix:TAG3DMatrix;UseLight:boolean=True);overload;override;
      //Shaders
      function BuildShader(&Type:TAGShaderType;Source:string):TAGShader;override;
      procedure FreeShader(Shader:TAGShader);override;
  end;
{$ENDIF}

implementation

{$IFDEF D3D9}
var
  D3D9:IDirect3D9;

//Delphi DX9 Fix
type
  TD3DMATERIALFix=record
    MatD3D9:D3DMATERIAL9;
    &File:PAnsiChar;
  end;
  PD3DMATERIALFix=^TD3DMATERIALFix;

{TAGD3D9GraphicCore}

function TAGD3D9GraphicCore.FCreateTexFromFile(FileName:String):TAGD3D9Mat;
begin
with Result.Info do
begin
  Diffuse:=$FFFFFFFF;
  Ambient:=$00000000;
  Specular:=$00000000;
  Emissive:=$00000000;
  Power:=1;
end;
{$IFDEF VampyreIL}
  ImagingDirect3D9.LoadD3DTextureFromFile(FileName,Dev,Result.Text);
{$ELSE}
  D3DXCreateTextureFromFileEx(Dev,PChar(FileName),
    D3DX_DEFAULT,D3DX_DEFAULT,D3DX_DEFAULT,0,D3DFMT_UNKNOWN,D3DPOOL_MANAGED,
    D3DX_DEFAULT,D3DX_DEFAULT,$00000000,nil,nil,Result.Text);
{$ENDIF}
end;

procedure TAGD3D9GraphicCore.SetMaterial(Mat:TAGD3D9Mat);
begin
Dev.SetTexture(0,Mat.Text);
end;

function TAGD3D9GraphicCore.GenProjection():TD3DXMatrix;
begin
with ScrSize do
  if Use3D then
    D3DXMatrixPerspectiveFovLH(Result,FFOV,y/x,FMinDepth,FMaxDepth)
  else
    D3DXMatrixOrthoLH(Result,y,x,-1,FMaxDepth);
end;

procedure TAGD3D9GraphicCore.Update2DCam();
var
  Mat:array[1..2]of TD3DXMatrix;
begin
with ScrSize do
  D3DXMatrixTranslation(Mat[1],-y/2,-x/2,0);
D3DXMatrixScaling(Mat[2],1,-1,1);
D3DXMatrixMultiply(Camera2D,Mat[1],Mat[2]);
end;

procedure TAGD3D9GraphicCore.SetBackColor(color:TAGColor);
begin
FBackColor:=color;
end;

function TAGD3D9GraphicCore.GetBackColor():TAGColor;
begin
Result:=FBackColor;
end;

constructor TAGD3D9GraphicCore.Create();
begin
FBackColor:=WiteColor;
FMinDepth:=0.1;
FMaxDepth:=10000;
//1.570796326795/2
//1.91986/2
FFOV:=Pi/8;
end;

procedure TAGD3D9GraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);
begin
ZeroMemory(@d3p,SizeOf(d3p));
fscr:=False;
with d3p do
begin
  BackBufferWidth:=W; //Устанавливаем ширину заднего буфера
	BackBufferHeight:=H;//Устанавливаем высоту заднего буфера
  if fscr then
  begin
    BackBufferCount:=2;
	  FullScreen_RefreshRateInHz:=D3DPRESENT_RATE_DEFAULT;
 	 	PresentationInterval:=D3DPRESENT_INTERVAL_ONE;
  end;
  hDeviceWindow:=hWindow;
	BackBufferFormat:=D3DFMT_A8R8G8B8;
  BackBufferCount:=1;
	EnableAutoDepthStencil:=true;
	//AutoDepthStencilFormat:=D3DFMT_D24S8;
  AutoDepthStencilFormat:=D3DFMT_D24S8;
	//Windowed:=not fscr;
	Windowed:=not fscr;//true;
	SwapEffect:=D3DSWAPEFFECT_DISCARD;
  MultiSampleType:=D3DMULTISAMPLE_4_SAMPLES;
  MultiSampleQuality:=0;
end;
D3D9.CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,hWindow,D3DCREATE_HARDWARE_VERTEXPROCESSING,addr(d3p),Dev);
with Dev do
begin
  SetSamplerState(0,D3DSAMP_ADDRESSU,D3DTADDRESS_MIRROR);
  SetSamplerState(0,D3DSAMP_ADDRESSV,D3DTADDRESS_MIRROR);
  SetSamplerState(0,D3DSAMP_BORDERCOLOR,0);
  SetSamplerState(0,D3DSAMP_MAGFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MINFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MIPFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MAXMIPLEVEL,1);

  SetRenderState(D3DRS_ALPHABLENDENABLE,1);
  SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);
  SetRenderState(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
  SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);
	SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,2);
  SetRenderState(D3DRS_SPECULARENABLE,1);
  SetRenderState(D3DRS_ZENABLE,D3DZB_TRUE);
  SetRenderState(D3DRS_ZWRITEENABLE,1);
  SetRenderState(D3DRS_LIGHTING,1);
  SetRenderState(D3DRS_ALPHATESTENABLE,1);
  SetRenderState(D3DRS_ALPHAFUNC,D3DCMP_GREATER);
  SetRenderState(D3DRS_ALPHAREF,0);

	SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,2);
end;

ScrSize:=TAGScreenVector.Create(h,w);
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);

fonts:=TDictionary<TAGFont,ID3DXFont>.Create;
FontsInit();

Update2DCam;

hwnd:=hWindow;
end;

procedure TAGD3D9GraphicCore.OnPaint();
begin
//D3DCLEAR_ZBUFFER
Dev.Clear(0,nil,D3DCLEAR_TARGET+D3DCLEAR_ZBUFFER+D3DCLEAR_STENCIL,backcolor.D3D9,2,1);
Dev.BeginScene();          //Начало сцены
if Assigned(drawer) then
  drawer(self);
Dev.EndScene();            //Конец сцены
Dev.Present(nil,nil,0,nil);//Отображаем весь задний буфер
end;

procedure TAGD3D9GraphicCore.Resize(W,H:Word);
var
  i:ID3DXFont;
begin
for i in fonts.Values do
  i.OnLostDevice;
d3p.BackBufferWidth:=W; //Устанавливаем ширину заднего буфера
d3p.BackBufferHeight:=H;//Устанавливаем высоту заднего буфера
ScrSize:=TAGScreenVector.Create(h,w);
Dev.Reset(d3p);
with Dev do
begin
  SetSamplerState(0,D3DSAMP_ADDRESSU,D3DTADDRESS_MIRROR);
  SetSamplerState(0,D3DSAMP_ADDRESSV,D3DTADDRESS_MIRROR);
  SetSamplerState(0,D3DSAMP_BORDERCOLOR,0);
  SetSamplerState(0,D3DSAMP_MAGFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MINFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MIPFILTER,DEFTEXF);
  SetSamplerState(0,D3DSAMP_MAXMIPLEVEL,1);

  SetRenderState(D3DRS_ALPHABLENDENABLE,1);
  SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);
  SetRenderState(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
  SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);
	SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,2);
  SetRenderState(D3DRS_SPECULARENABLE,1);
  SetRenderState(D3DRS_ZENABLE,D3DZB_TRUE);
  SetRenderState(D3DRS_ZWRITEENABLE,1);
  SetRenderState(D3DRS_LIGHTING,1);
  SetRenderState(D3DRS_ALPHATESTENABLE,1);
  SetRenderState(D3DRS_ALPHAFUNC,D3DCMP_GREATER);
  SetRenderState(D3DRS_ALPHAREF,0);

	SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,2);
end;
for i in fonts.Values do
  i.OnResetDevice;
end;

destructor TAGD3D9GraphicCore.Destroy();
var
  i:TAGFont;
begin
inherited;
with fonts do
  for i in Keys do
  begin
    if Assigned(Items[i])then
      Items[i]._Release;
    Remove(i);
  end;
FreeAndNil(fonts);
if Assigned(Dev)then
begin
  Dev._Release;
  Pointer(Dev):=nil;
end;
end;

procedure TAGD3D9GraphicCore.SetDebug(param1,param2:NativeUInt);
begin
case param1 of
0:
Dev.SetRenderState(D3DRS_FILLMODE,param2);
end;
end;



//2D

function TAGD3D9GraphicCore.CreateBrush(Color:TAGColor):TAGBrush;
begin
Result.def:=((Color.A*256+Color.B)*256+Color.G)*256+Color.R;
end;

function TAGD3D9GraphicCore.CreateBitMap(p:TAGResourceImage):TAGBitMap;
  {$IFDEF VampyreIL}
  function LoadByVampire(Dev:IDirect3DDevice9;p:TAGResourceImage):TAGBitMap;
  begin
    GetMem(Result.D3D9,SizeOf(Result.D3D9^));
    ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
    LoadD3DTextureFromStream(p.d,Dev,Result.D3D9^,nil,nil);
  end;
  {$ENDIF}
  {$IFDEF D3DX}
  function LoadDef(Dev:IDirect3DDevice9;Res:TAGResourceImage):TAGBitMap;
  var
    p:Pointer;
  begin
    GetMem(Result.D3D9,SizeOf(Result.D3D9^));
    ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
    GetMem(p,Res.d.Size);
    Res.d.Read(p^,Res.d.Size);
    Res.d.Seek(0,soBeginning);
    D3DXCreateTextureFromFileInMemory(Dev,p,Res.d.Size,Result.D3D9^);
    FreeMem(p);
  end;
  {$ENDIF}
begin
  case p.encoder of
  AGRIE_None:Result.def:=0;
  {$IFDEF VampyreIL}AGRIE_Vampyre:Result:=LoadByVampire(Dev,p);{$ENDIF}
  {$IFDEF D3DX}AGRIE_D3DX:Result:=LoadDef(Dev,p);{$ENDIF}
  else
  {$IFDEF VampyreIL}
  Result:=LoadByVampire(Dev,p);
  {$ELSE}{$IFDEF D3DX}
  Result:=LoadDef(Dev,p);
  {$ENDIF}{$ENDIF}
  end;
end;

function TAGD3D9GraphicCore.CreateBitMapFromFile(Name:String):TAGBitMap;
begin
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
{$IFDEF VampyreIL}
  LoadD3DTextureFromFile(Name,Dev,Result.D3D9^,nil,nil);
{$ELSE}{$IFDEF D3DX}
  D3DXCreateTextureFromFile(Dev,PWideChar(Name),Result.D3D9^);
{$ENDIF}{$ENDIF}
end;

procedure TAGD3D9GraphicCore.LoadFont(Name,Local:string;size:single;font:TAGFont);
var
  FF:ID3DXFont;
begin
with fonts do
  if ContainsKey(font) then
  begin
    if Assigned(Items[font]) then
      Items[font]._Release;
    Remove(font);
  end;
D3DXCreateFont(Dev,
  Round(size),                    //высота шрифта
  0,                              //ширина шрифта;если передать 0, то установится автоматически
  400,                            //толшина шрифта:от нуля,до тысячи
  0,                              //уровень MIP
  false,                          //наклонный шрифт
  StrToWinAPILang(Local),         //кодировка
  OUT_DEFAULT_PRECIS,             //точность вывода
  ANTIALIASED_QUALITY,            //качество(сглаженный шрифт, ClearType...)
  DEFAULT_PITCH or FF_DONTCARE,   //шаг и семейство шрифта
  PChar(Name),                    //имя шрифта (Arial, Times New Roman...)
  FF);
fonts.AddOrSetValue(font,FF);
Pointer(FF):=nil;
end;

procedure TAGD3D9GraphicCore.ReleaseBrush(b:TAGBrush);
begin
end;

procedure TAGD3D9GraphicCore.ReleaseBitMap(b:TAGBitMap);
begin
if b.D3D9^<>nil then
  b.D3D9._Release;
b.def:=0;
end;

procedure TAGD3D9GraphicCore.DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush);
var
  p:PD3DXVector2;
  l:ID3DXLine;
begin
D3DXCreateLine(Dev,l);
GetMem(p,SizeOf(TD3DXVector3)*2);
with p^ do
begin
  x:=point0.X;
  y:=point0.Y;
end;
inc(p,1);
with p^ do
begin
  x:=point1.X;
  y:=point1.Y;
end;
dec(p,1);

l.SetAntialias(true);
l.SetWidth(size);
l._Begin();
l.Draw(p,2,brush.AGColor.D3D9);
l._End();

FreeMem(p);
l._Release;
Pointer(l):=nil;
end;

procedure TAGD3D9GraphicCore.DrawText(text:string;position:TAGCoord;size:word;font:TAGFont;brush:TAGBrush);
var
  r:TRect;
begin
  r:=TAGScreenCoord(position).ToTRect;
  HRESULTCHK(fonts[font].DrawTextW(nil,PWideChar(text),-1,@r,DT_LEFT+DT_TOP,brush.AGColor.D3D9));
end;

//3D

procedure TAGD3D9GraphicCore.SetMinDepth(d:Single);
begin
  FMinDepth:=d;
end;

function TAGD3D9GraphicCore.GetMinDepth:Single;
begin
  Result:=FMinDepth;
end;

procedure TAGD3D9GraphicCore.SetMaxDepth(d:Single);
begin
  FMaxDepth:=d;
end;

function TAGD3D9GraphicCore.GetMaxDepth:Single;
begin
  Result:=FMaxDepth;
end;

procedure TAGD3D9GraphicCore.SetFOV(AFOV:Single);
begin
FFOV:=AFOV;
end;

function TAGD3D9GraphicCore.GetFOV:Single;
begin
Result:=FFOV;
end;

function TAGD3D9GraphicCore.CreateTexFromFile(FileName:String):TAGTex;
begin
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
Result.D3D9^:=FCreateTexFromFile(FileName);
end;

function TAGD3D9GraphicCore.CreateTexFromColor(c:TAGColor):TAGTex;
begin
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
Result.D3D9^.Info.Diffuse:=TAGFloatColor(c).D3D9;
with Result.D3D9^.Info do
begin
  Ambient:=Diffuse;
  Specular:=Diffuse;
  Emissive:=Diffuse;
  Power:=1;
end;
Pointer(Result.D3D9^.Text):=nil;
Pointer(Result.D3D9^.Spec):=nil;
Pointer(Result.D3D9^.Norm):=nil;
end;

procedure TAGD3D9GraphicCore.ResetLightSettings(Tex:TAGTex;Color:TAGColor;Diffuse,Ambient,Specular,Emissive:Single);
begin
with Tex.D3D9^ do
begin
  Info.Diffuse:=(Color*Diffuse).D3D9;
  Info.Ambient:=(Color*Ambient).D3D9;//*Ambient;
  Info.Specular:=(Color*Specular).D3D9;//*Specular;
  Info.Emissive:=(Color*Emissive).D3D9;//*Emissive;
  Info.Power:=1;
end;
end;

procedure TAGD3D9GraphicCore.ReleaseTex(Tex:TAGTex);
begin
if Assigned(Tex.D3D9.Text) then
  Tex.D3D9.Text._Release;
Pointer(Tex.D3D9.Text):=nil;
FreeMem(Tex.D3D9);
end;

procedure TAGD3D9GraphicCore.ReleaseMesh(Mesh:TAGMesh);
begin
Finalize(Mesh.D3D9^);
FreeMem(Mesh.D3D9);
Mesh.def:=0;
end;

function TAGD3D9GraphicCore.CreateReTexturedMesh(Mesh:TAGMesh;Tex:TArray<TAGTex>;UseOriginalLightSettings:boolean=False):TAGMesh;
var
  i:integer;
begin
Result.def:=0;
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
Pointer(Result.D3D9.Mesh):=Pointer(Mesh.D3D9.Mesh);
Mesh.D3D9.Mesh._AddRef;
SetLength(Result.D3D9.Mat,length(Mesh.D3D9.Mat));
for i:=0 to length(Mesh.D3D9.Mat)-1 do
  if i<length(Tex)then
  begin
    if UseOriginalLightSettings then
      Result.D3D9.Mat[i].Info:=Mesh.D3D9.Mat[i].Info
    else
      Result.D3D9.Mat[i].Info:=Tex[i].D3D9.Info;
    Result.D3D9.Mat[i].Text:=Tex[i].D3D9.Text;
    Result.D3D9.Mat[i].Spec:=Tex[i].D3D9.Spec;
    Result.D3D9.Mat[i].Norm:=Tex[i].D3D9.Norm;
  end
  else
  begin
    Result.D3D9.Mat[i].Info:=Mesh.D3D9.Mat[i].Info;
    Result.D3D9.Mat[i].Text:=Mesh.D3D9.Mat[i].Text;
    Result.D3D9.Mat[i].Spec:=Mesh.D3D9.Mat[i].Spec;
    Result.D3D9.Mat[i].Norm:=Mesh.D3D9.Mat[i].Norm;
  end;
end;

function TAGD3D9GraphicCore.LoadXFile(Name:String;Floder:String;Texture:TArray<TAGTex>;UseXFileLightSettings:boolean=False):TAGMesh;
  function comp(&in:ID3DXMesh):ID3DXMesh;
  const
    decl:array[0..3]of TD3DVertexElement9=(
      (Stream:0;Offset:0;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_POSITION;UsageIndex:0),
      (Stream:0;Offset:12;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_NORMAL;UsageIndex:0),
      (Stream:0;Offset:24;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TEXCOORD;UsageIndex:0),
      (Stream:$FF;Offset:0;_Type:D3DDECLTYPE_UNUSED;Method:TD3DDeclMethod(0);Usage:TD3DDeclUsage(0);UsageIndex:0));
    decl2:array[0..5]of TD3DVertexElement9=(
      (Stream:0;Offset:0;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_POSITION;UsageIndex:0),
      (Stream:0;Offset:12;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_NORMAL;UsageIndex:0),
      (Stream:0;Offset:24;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TEXCOORD;UsageIndex:0),
      (Stream:0;Offset:36;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TANGENT;UsageIndex:0),
      (Stream:0;Offset:48;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_BINORMAL;UsageIndex:0),
      (Stream:$FF;Offset:0;_Type:D3DDECLTYPE_UNUSED;Method:TD3DDeclMethod(0);Usage:TD3DDeclUsage(0);UsageIndex:0));
  var
    tempMesh:ID3DXMesh;
    IDecl:IDirect3DVertexDeclaration9;
  begin
  Dev.CreateVertexDeclaration(addr(decl),IDecl);
  // Clone into tempMesh.
  &in.CloneMesh(D3DXMESH_MANAGED,addr(decl),Dev,tempMesh);

  D3DXComputeTangent(tempMesh,0,0,0,1,nil); //compute tangent(u) and later binormal (v)
  //D3DXComputeTangent(tempMesh,0,0,0,1,nil);
  // Clone SysMesh into ResultMesh.
  tempMesh.CloneMesh(D3DXMESH_MANAGED,addr(decl2),Dev,Result);
  end;
var
  Adjacency,BuffMat,EffInst:ID3DXBuffer;
  n,i:integer;
  d3dxMaterials:^TD3DXMATERIAL;
  pMat:PD3DMATERIALFix;
begin
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
D3DXLoadMeshFromX(PWideChar(Name),D3DXMESH_SYSTEMMEM,Dev,@Adjacency,@BuffMat,nil,@n,Result.D3D9.Mesh);
//Extract the materials, and load textures
SetLength(Result.D3D9.Mat,n);
if(BuffMat<>nil)and(n<>0)then
begin
  pMat:=BuffMat.GetBufferPointer;
  for i:=0 to n-1 do
  begin
    if i<length(Texture)then
    begin
      Result.D3D9.Mat[i]:=Texture[i].D3D9^;
      if UseXFileLightSettings then
        Result.D3D9.Mat[i].Info:=pMat.MatD3D9;
    end
    else
    begin
      if pMat.&File='' then
      begin
        Result.D3D9.Mat[i].Text:=nil;
        Result.D3D9.Mat[i].Spec:=nil;
        Result.D3D9.Mat[i].Norm:=nil;
      end
      else
        if Floder='' then
          Result.D3D9^.Mat[i]:=FCreateTexFromFile(pMat.&File)
        else
          Result.D3D9^.Mat[i]:=FCreateTexFromFile(Floder+TPath.DirectorySeparatorChar+String(pMat.&File));
      Result.D3D9.Mat[i].Info:=pMat.MatD3D9;
    end;
    inc(pMat,1);
  end;
end;
//Optimize the mesh
//Result.D3D9.Mesh.OptimizeInplace(D3DXMESHOPT_ATTRSORT or D3DXMESHOPT_COMPACT or D3DXMESHOPT_VERTEXCACHE,Adjacency.GetBufferPointer,nil,nil,nil);
Result.D3D9.Mesh:=comp(Result.D3D9.Mesh);
end;

function TAGD3D9GraphicCore.LoadXFileWithoutTextures(Name:String):TAGMesh;
const
  decl:array[0..3]of TD3DVertexElement9=(
    (Stream:0;Offset:0;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_POSITION;UsageIndex:0),
    (Stream:0;Offset:12;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_NORMAL;UsageIndex:0),
    (Stream:0;Offset:24;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TEXCOORD;UsageIndex:0),
    (Stream:$FF;Offset:0;_Type:D3DDECLTYPE_UNUSED;Method:TD3DDeclMethod(0);Usage:TD3DDeclUsage(0);UsageIndex:0));
  decl2:array[0..5]of TD3DVertexElement9=(
    (Stream:0;Offset:0;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_POSITION;UsageIndex:0),
    (Stream:0;Offset:12;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_NORMAL;UsageIndex:0),
    (Stream:0;Offset:24;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TEXCOORD;UsageIndex:0),
    (Stream:0;Offset:36;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_TANGENT;UsageIndex:0),
    (Stream:0;Offset:48;_Type:D3DDECLTYPE_FLOAT3;Method:D3DDECLMETHOD_DEFAULT;Usage:D3DDECLUSAGE_BINORMAL;UsageIndex:0),
    (Stream:$FF;Offset:0;_Type:D3DDECLTYPE_UNUSED;Method:TD3DDeclMethod(0);Usage:TD3DDeclUsage(0);UsageIndex:0));
var
  Adjacency,BuffMat,EffInst:ID3DXBuffer;
  tempMesh1,tempMesh2:ID3DXMesh;
  n,i:integer;
begin
GetMem(Result.D3D9,SizeOf(Result.D3D9^));
ZeroMemory(Result.D3D9,SizeOf(Result.D3D9^));
D3DXLoadMeshFromX(PWideChar(Name),D3DXMESH_SYSTEMMEM,Dev,@Adjacency,@BuffMat,nil,@n,tempMesh1);
//Extract the materials, and load textures
SetLength(Result.D3D9.Mat,n);
for i:=0 to n-1 do
  ZeroMemory(Addr(Result.D3D9.Mat[i]),SizeOf(Result.D3D9.Mat[i]));
//Optimize the mesh
//Result.D3D9.Mesh.OptimizeInplace(D3DXMESHOPT_ATTRSORT or D3DXMESHOPT_COMPACT or D3DXMESHOPT_VERTEXCACHE,Adjacency.GetBufferPointer,nil,nil,nil);


tempMesh1.CloneMesh(D3DXMESH_MANAGED,addr(decl),Dev,tempMesh2);
//compute tangent(u) and later binormal (v)
D3DXComputeTangent(tempMesh2,0,0,0,1,nil);
tempMesh2.CloneMesh(D3DXMESH_MANAGED,addr(decl2),Dev,Result.D3D9.Mesh);
end;

function TAGD3D9GraphicCore.LoadXFile2(Name:String;Texture:TArray<TAGTex>;Floder:String=''):TAGMesh;
var
  {&File:IDirectXFile;
  Enum:IDirectXFileEnumObject;
  FileData:IDirectXFileData;}
  Adjacency,BuffMat,EffInst:ID3DXBuffer;
  n,i:cardinal;
  d3dxMaterials:^TD3DXMATERIAL;
  pMat:PD3DMATERIALFix;
begin
{DirectXFileCreate(&File);
with &File do
begin
  RegisterTemplates(addr(D3DRM_XTEMPLATES),D3DRM_XTEMPLATE_BYTES);
  CreateEnumObject(PWideChar(Name),DXFILELOAD_FROMFILE,Enum);
  while Succeeded(Enum.GetNextDataObject(FileData))do
  begin
    FileData._Release;
    Pointer(FileData):=nil;
  end;
end;}
GetMem(Result.D3D9,sizeof(Result.D3D9^));
ZeroMemory(Result.D3D9,sizeof(Result.D3D9^));
//D3DXLoadMeshHierarchyFromX(PWideChar(Name),D3DXMESH_SYSTEMMEM,Dev,@Adjacency,@BuffMat,nil,@n,Result.D3D9.Mesh);
//Extract the materials, and load textures.
if(BuffMat<>nil)and(n<>0)then
begin
  pMat:=BuffMat.GetBufferPointer;
  SetLength(Result.D3D9.Mat,n);
  for i:=0 to n-1 do
  begin
    Result.D3D9.Mat[i].Info:=pMat.MatD3D9;
    Result.D3D9.Mat[i].Info.Ambient:=Result.D3D9.Mat[i].Info.Diffuse;
    if pMat.&File='' then
      Result.D3D9.Mat[i].Text:=nil
    else
      if Floder='' then
        D3DXCreateTextureFromFileExA(Dev,pMat.&File,
          D3DX_DEFAULT,D3DX_DEFAULT,D3DX_DEFAULT,D3DUSAGE_DYNAMIC,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,
          D3DX_DEFAULT,D3DX_DEFAULT,$00000000,nil,nil,Result.D3D9.Mat[i].Text)
      else
        D3DXCreateTextureFromFileEx(Dev,PChar(Floder+'\'+String(pMat.&File)),
          D3DX_DEFAULT,D3DX_DEFAULT,D3DX_DEFAULT,D3DUSAGE_DYNAMIC,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,
          D3DX_DEFAULT,D3DX_DEFAULT,$00000000,nil,nil,Result.D3D9.Mat[i].Text);
    inc(pMat,1);
  end;
end;
//Optimize the mesh.
//Result.D3D9.Mesh.OptimizeInplace(D3DXMESHOPT_ATTRSORT or D3DXMESHOPT_COMPACT or D3DXMESHOPT_VERTEXCACHE,Adjacency.GetBufferPointer,0,0,0);
end;

{TAGD3D9NoShaderGraphicCore}

procedure TAGD3D9NoShaderGraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);
begin
inherited;
with Dev do
begin
  SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_MODULATE);
  SetTextureStageState(0,D3DTSS_COLORARG1,D3DTA_TEXTURE);
  SetTextureStageState(0,D3DTSS_COLORARG2,D3DTA_DIFFUSE);
  SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_MODULATE);
  SetTextureStageState(0,D3DTSS_ALPHAARG1,D3DTA_TEXTURE);

  SetTextureStageState(0,D3DTSS_CONSTANT,$FFFFFFFF);
  SetTextureStageState(0,D3DTSS_ALPHAARG2,D3DTA_CONSTANT);
  SetTextureStageState(1,D3DTSS_COLOROP,D3DTOP_DISABLE);
  SetTextureStageState(1,D3DTSS_ALPHAOP,D3DTOP_DISABLE);

  //SetRenderState(D3DRS_ALPHATESTENABLE,1);
  SetRenderState(D3DRS_ALPHAREF,$20);
  SetRenderState(D3DRS_ALPHAFUNC,D3DCMP_GREATER);
	SetRenderState(D3DRS_POINTSPRITEENABLE,1);
  SetRenderState(D3DRS_STENCILENABLE,1);

	SetRenderState(D3DRS_MULTISAMPLEANTIALIAS,2);
end;

if Assigned(initer) then
  initer(self);
end;

procedure TAGD3D9NoShaderGraphicCore.Init2D();
begin
Use3D:=False;
with Dev do
begin
  //Выключение отбраковки
  SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
  //Выключение освещения
  SetRenderState(D3DRS_LIGHTING,0);
  //Выключение Z-буфера
  //SetRenderState(D3DRS_ZENABLE,0);
  //SetRenderState(D3DRS_ZWRITEENABLE,0);
  SetRenderState(D3DRS_ZFUNC,D3DCMP_ALWAYS);
end;
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);
Update2DCam;
CameraUpdate(Camera2D);
end;

procedure TAGD3D9NoShaderGraphicCore.DrawRectangle(rect:TAGCoord;Size:word;brush:TAGBrush);
var
  a:array[0..9]of record
     v:TD3DXVECTOR3;
     c:TD3DColor;
  end;
  i:byte;
  PSz:Single;
begin
for i:=0 to 9 do
  a[i].c:=brush.def;
PSz:=size/2;
with Rect do
begin
  a[0].v:=TD3DXVECTOR3.Create(X+PSz,Y+PSz,0);
  a[1].v:=TD3DXVECTOR3.Create(X-PSz,Y-PSz,0);
  a[2].v:=TD3DXVECTOR3.Create(X+W-PSz,Y+PSz,0);
  a[3].v:=TD3DXVECTOR3.Create(X+W+PSz,Y-PSz,0);
  a[4].v:=TD3DXVECTOR3.Create(X+W-PSz,Y+H-PSz,0);
  a[5].v:=TD3DXVECTOR3.Create(X+W+PSz,Y+H+PSz,0);
  a[6].v:=TD3DXVECTOR3.Create(X+PSz,Y+H-PSz,0);
  a[7].v:=TD3DXVECTOR3.Create(X-PSz,Y+H+PSz,0);
  a[8].v:=a[0].v;
  a[9].v:=a[1].v;
end;
with Dev do
begin
  SetTexture(0,nil);
  SetFVF(D3DFVF_XYZ+D3DFVF_DIFFUSE);
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,8,a,SizeOf(a[0]));
end;
end;

procedure TAGD3D9NoShaderGraphicCore.DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);
var
  i,st:integer;
  a:array of record
     v:TD3DXVECTOR3;
     c:TD3DColor;
  end;
begin
with radaii do
  if x>y then
    st:=System.Round(x)
  else
    st:=System.Round(y);
SetLength(a,st*4+2);
for i:=0 to st*2 do
begin
  a[i*2].v:=TD3DXVECTOR3.Create(cos(i*pi/st)*(radaii.X-size/2)+point.X,sin(i*pi/st)*(radaii.Y-size/2)+point.Y,0);
  a[i*2].c:=brush.def;
  a[i*2+1].v:=TD3DXVECTOR3.Create(cos(i*pi/st)*(radaii.X+size/2)+point.X,sin(i*pi/st)*(radaii.Y+size/2)+point.Y,0);
  a[i*2+1].c:=brush.def;
end;
with Dev do
begin
  SetTexture(0,nil);
  SetFVF(D3DFVF_XYZ+D3DFVF_DIFFUSE);
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,st*4,a[0],SizeOf(a[0]));
end;
end;

procedure TAGD3D9NoShaderGraphicCore.DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);
var
  Data:array[0..3]of record
    x,y,z,Tx,Ty:Single;
  end;
begin
with Data[0] do
begin
  x:=coord.X;
  y:=coord.Y;
  z:=0;
  Tx:=0;
  Ty:=0;
end;
with Data[1] do
begin
  x:=coord.X+coord.W;
  y:=coord.Y;
  z:=0;
  Tx:=1;
  Ty:=0;
end;
with Data[2] do
begin
  x:=coord.X;
  y:=coord.Y+coord.H;
  z:=0;
  Tx:=0;
  Ty:=1;
end;
with Data[3] do
begin
  x:=coord.X+coord.W;
  y:=coord.Y+coord.H;
  z:=0;
  Tx:=1;
  Ty:=1;
end;

with Dev do
begin
  SetTexture(0,bitmap.D3D9^);
  SetFVF(D3DFVF_XYZ+D3DFVF_TEX1);
  if opacity<>255 then
    SetTextureStageState(0,D3DTSS_CONSTANT,$FFFFFF+$1000000*opacity);
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MINFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);
  end;
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,Data,SizeOf(Data[0]));
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MINFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MIPFILTER,DEFTEXF);
  end;
  SetTextureStageState(0,D3DTSS_CONSTANT,$FFFFFFFF);
end;
end;

procedure TAGD3D9NoShaderGraphicCore.FillRectangle(rect:TAGCoord;brush:TAGBrush);
var
  a:array[0..3]of record
     v:TD3DXVECTOR3;
     c:TD3DColor;
  end;
  i:byte;
begin
for i:=0 to 3 do
  a[i].c:=brush.def;
with rect do
begin
  a[0].v:=TD3DXVECTOR3.Create(X,Y,0);
  a[1].v:=TD3DXVECTOR3.Create(X,Y+H,0);
  a[2].v:=TD3DXVECTOR3.Create(X+W,Y,0);
  a[3].v:=TD3DXVECTOR3.Create(X+W,Y+H,0);
end;
with Dev do
begin
  SetTexture(0,nil);
  SetFVF(D3DFVF_XYZ+D3DFVF_DIFFUSE);
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,a,SizeOf(a[0]));
end;
end;

//3D

procedure TAGD3D9NoShaderGraphicCore.SetMaterial(Mat:TAGD3D9Mat);
begin
inherited;
Dev.SetMaterial(Mat.Info);
end;

procedure TAGD3D9NoShaderGraphicCore.CameraUpdate(m:TD3DXMatrix);
begin
Dev.SetTransform(D3DTS_VIEW,m)
end;

procedure TAGD3D9NoShaderGraphicCore.SetMinDepth(d:Single);
begin
inherited;
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);
end;

procedure TAGD3D9NoShaderGraphicCore.SetMaxDepth(d:Single);
begin
inherited;
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);
end;

procedure TAGD3D9NoShaderGraphicCore.SetFOV(AFOV:Single);
begin
inherited;
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);
end;

procedure TAGD3D9NoShaderGraphicCore.Init3D();
begin
with Dev do
begin
  SetRenderState(D3DRS_CULLMODE,D3DCULL_CCW);
  SetRenderState(D3DRS_LIGHTING,1);
  //SetRenderState(D3DRS_ZENABLE,1);
  //SetRenderState(D3DRS_ZWRITEENABLE,1);
  SetRenderState(D3DRS_ZFUNC,D3DCMP_LESS);
end;
Use3D:=True;
Dev.SetTransform(D3DTS_PROJECTION,GenProjection);
CameraUpdate(Camera3D);
end;

function TAGD3D9NoShaderGraphicCore.AddDirectLight(Direction:TAG3DVector;Color:TAGColor;Bright:Single=1):TAGLight;
var
  light:D3DLIGHT9;
  b:LongBool;
begin
light._Type:=D3DLIGHT_DIRECTIONAL;

with light.Ambient do
begin
  r:=0;
  g:=0;
  b:=0;
  a:=0;
end;

Bright:=Bright/255;

with light.Diffuse do
begin
  r:=Color.R*Bright;
  g:=Color.G*Bright;
  b:=Color.B*Bright;
  a:=Color.A*Bright;
end;

Bright:=Bright/1.2;

with light.Specular do
begin
  r:=Color.R*Bright;
  g:=Color.G*Bright;
  b:=Color.B*Bright;
  a:=Color.A*Bright;
end;

{$IF sizeof(TAG3DVector)=sizeof(Single)*3}
light.Direction:=TD3DVector(Direction);
{$ELSE}
light.Direction:=TD3DVector.Create(Direction.X,Direction.Y,Direction.Z);
{$ENDIF}

Result.D3D9:=0;
b:=False;
Dev.GetLightEnable(Result.D3D9,b);
while b do
begin
  inc(Result.D3D9);
  HRESULTCHK(Dev.GetLightEnable(Result.D3D9,b));
end;

Dev.SetLight(Result.D3D9,light);
Dev.LightEnable(Result.D3D9,true);
end;

function TAGD3D9NoShaderGraphicCore.AddPointLight(Position:TAG3DVector;Color:TAGColor;Range:Single;Bright:Single=1):TAGLight;
var
  light:D3DLIGHT9;
  b:LongBool;
begin
light._Type:=D3DLIGHT_POINT;

with light.Ambient do
begin
  r:=0;
  g:=0;
  b:=0;
  a:=0;
end;

with light.Diffuse do
begin
  r:=Color.R*Bright/255;
  g:=Color.G*Bright/255;
  b:=Color.B*Bright/255;
  a:=Color.A*Bright/255;
end;

with light.Specular do
begin
  r:=Color.R*Bright/255;
  g:=Color.G*Bright/255;
  b:=Color.B*Bright/255;
  a:=Color.A*Bright/255;
end;

light.Range:=Range;

with light do
begin
  Attenuation0:=0;
  Attenuation1:=1;
  Attenuation2:=0;
end;

light.Position:=TD3DVector{$IF sizeof(TAG3DVector)=sizeof(Single)*3}
                (Position)
              {$ELSE}
                .Create(Position.X,Position.Y,Position.Z)
              {$ENDIF};

Result.D3D9:=0;
b:=False;
Dev.GetLightEnable(Result.D3D9,b);
while b do
begin
  inc(Result.D3D9);
  Dev.GetLightEnable(Result.D3D9,b);
end;

Dev.SetLight(Result.D3D9,light);
Dev.LightEnable(Result.D3D9,true);
end;

function TAGD3D9NoShaderGraphicCore.AddSpotLight(Position,Direction:TAG3DVector;Color:TAGColor;Range,Theta:Single;Bright:Single=1):TAGLight;
var
  light:D3DLIGHT9;
  b:LongBool;
begin
light._Type:=D3DLIGHT_SPOT;

with light.Ambient do
begin
  r:=0;
  g:=0;
  b:=0;
  a:=0;
end;

with light.Diffuse do
begin
  r:=Color.R*Bright/255;
  g:=Color.G*Bright/255;
  b:=Color.B*Bright/255;
  a:=Color.A*Bright/255;
end;

with light.Specular do
begin
  r:=Color.R*Bright/255;
  g:=Color.G*Bright/255;
  b:=Color.B*Bright/255;
  a:=Color.A*Bright/255;
end;

with light do
begin
  Attenuation0:=0;
  Attenuation1:=1;
  Attenuation2:=0;
end;

light.Range:=Range;
light.Theta:=Theta;
light.Phi:=light.Theta;

{$IF sizeof(TAG3DVector)=sizeof(Single)*3}
light.Position:=TD3DVector(Position);
{$ELSE}
light.Position:=TD3DVector.Create(Position.X,Position.Y,Position.Z);
{$ENDIF}

{$IF sizeof(TAG3DVector)=sizeof(Single)*3}
light.Direction:=TD3DVector(Direction);
{$ELSE}
light.Direction:=TD3DVector.Create(Direction.X,Direction.Y,Direction.Z);
{$ENDIF}

Result.D3D9:=0;
b:=False;
Dev.GetLightEnable(Result.D3D9,b);
while b do
begin
  inc(Result.D3D9);
  Dev.GetLightEnable(Result.D3D9,b);
end;

Dev.SetLight(Result.D3D9,light);
Dev.LightEnable(Result.D3D9,true);
end;

procedure TAGD3D9NoShaderGraphicCore.DelLight(l:TAGLight);
begin
Dev.LightEnable(l.D3D9,false);
end;

procedure TAGD3D9NoShaderGraphicCore.SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);
begin
D3DXMatrixLookAtLH(Camera3D,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (Cam)
  {$ELSE}
    .Create(Cam.X,Cam.Y,Cam.Z)
  {$ENDIF}
  ,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (Obj)
  {$ELSE}
    .Create(Obj.X,Obj.Y,Obj.Z)
  {$ENDIF},TD3DXVECTOR3.Create(0,1,0));
Init3D;
end;

procedure TAGD3D9NoShaderGraphicCore.SetCameraByMatrix(Matrix:TAG3DMatrix);
begin
Camera3D:=Matrix.ToD3D9Form;
Init3D;
end;

{procedure TAGD3D9GraphicCore.DrawPoint(point:TAG3DVector;size:word;brush:TAGBrush);
type
  TD3D9VertexRec=record
    x0,y0,z0:Single;
  end;
  PD3D9VertexRec=^TD3D9VertexRec;
var
  p:PD3D9VertexRec;
  Info:D3DMATERIAL9;
  sz:Single;
begin
GetMem(p,SizeOf(TD3D9VertexRec));
with p^ do
begin
  x0:=point0.X;
  y0:=point0.Y;
  z0:=point0.Z;
end;
sz:=size;

Info.Diffuse:=brush.D3D9;
Info.Ambient:=Info.Diffuse;
Info.Specular:=Info.Diffuse;
Info.Emissive:=Info.Diffuse;
Info.Power:=1;
with Dev do
begin
  SetMaterial(Info);
  SetTexture(0,nil);
  SetFVF(D3DFVF_XYZ);
  SetRenderState(D3DRS_POINTSIZE,Cardinal(Addr(sz)^));
  DrawPrimitiveUP(D3DPT_POINTLIST,2,p^,SizeOf(Single)*3);
end;
end;}

procedure TAGD3D9NoShaderGraphicCore.DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush);
var
  a:array[0..3]of packed record
     v:TD3DXVECTOR3;
     c:TD3DColor;
  end;
  Mat:array[1..3]of TD3DXMatrix;
  Vp:TD3DViewport9;
  p0,p1,p2,p3:TD3DXVECTOR3;
  s:Single;
begin
with brush do
begin
  a[0].c:=def;
  a[1].c:=def;
  a[2].c:=def;
  a[3].c:=def;
end;
with Dev do
begin
  GetTransform(D3DTS_PROJECTION,Mat[1]);
  GetTransform(D3DTS_VIEW,Mat[2]);
  GetTransform(D3DTS_WORLD,Mat[3]);
  GetViewport(Vp);
end;
D3DXVec3Project(p0,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (point0)
  {$ELSE}
    .Create(point0.X,point0.Y,point0.Z)
  {$ENDIF},Vp,Mat[1],Mat[2],Mat[3]);
D3DXVec3Project(p1,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (point1)
  {$ELSE}
    .Create(point1.X,point1.Y,point1.Z)
  {$ENDIF},Vp,Mat[1],Mat[2],Mat[3]);

D3DXVec3Subtract(p2,p0,p1);
s:=size/2/sqrt(sqr(p2.x)+sqr(p2.y));
with p3 do
begin
  x:=p0.x+s*p2.y;
  y:=p0.y-s*p2.x;
  z:=p0.z;
  D3DXVec3Unproject(a[0].v,p3,Vp,Mat[1],Mat[2],Mat[3]);
  x:=p0.x-s*p2.y;
  y:=p0.y+s*p2.x;
  D3DXVec3Unproject(a[1].v,p3,Vp,Mat[1],Mat[2],Mat[3]);
  x:=p1.x+s*p2.y;
  y:=p1.y-s*p2.x;
  z:=p1.z;
  D3DXVec3Unproject(a[2].v,p3,Vp,Mat[1],Mat[2],Mat[3]);
  x:=p1.x-s*p2.y;
  y:=p1.y+s*p2.x;
  D3DXVec3Unproject(a[3].v,p3,Vp,Mat[1],Mat[2],Mat[3]);
end;
with Dev do
begin
  SetTexture(0,nil);
  SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
  SetRenderState(D3DRS_LIGHTING,0);
  SetFVF(D3DFVF_XYZ+D3DFVF_DIFFUSE);
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,a,SizeOf(a[0]));
  SetRenderState(D3DRS_LIGHTING,1);
  SetRenderState(D3DRS_CULLMODE,D3DCULL_CCW);
end;
end;

procedure TAGD3D9NoShaderGraphicCore.DrawMesh(const Mesh:TAGMesh;const Matrix:TAG3DMatrix;UseLight:boolean=True);
var
  i:integer;
begin
if not UseLight then
  Dev.SetRenderState(D3DRS_LIGHTING,0);
for i:=0 to Length(Mesh.D3D9.Mat)-1 do
begin
  //Dev.SetMaterial(Mesh.D3D9.Mat[i].Info);
  //Dev.SetTexture(0,Mesh.D3D9.Mat[i].Text);
  Self.SetMaterial(Mesh.D3D9.Mat[i]);
  Mesh.D3D9.Mesh.DrawSubset(i);
end;
Dev.SetTransform(D3DTS_WORLD,TAG3DMatrix.MkIdent.ToD3D9Form);
if not UseLight then
  Dev.SetRenderState(D3DRS_LIGHTING,1);
end;

{TAGD3D9ShaderGraphicCore}

constructor TAGD3D9ShaderGraphicCore.TPixelShaderAbout.Create(ADirect,APoint,ASpot:byte);
begin
Direct:=ADirect;
Point:=APoint;
Spot:=ASpot;
end;

function TAGD3D9ShaderGraphicCore.LoadVertexShader(Shader:ansistring):IDirect3DVertexShader9;
var
  temp:ID3DXBuffer;
{$IFDEF DEBUG}
  temp2:ID3DXBuffer;
  s:string;
begin
D3DXAssembleShader(PAnsiChar(Shader),length(Shader),nil,nil,0,addr(temp),addr(temp2));
if Assigned(temp2) then
  s:=PAnsiChar(temp2.GetBufferPointer);
Dev.CreateVertexShader(temp.GetBufferPointer,Result);
{$ELSE}
begin
HRESULTCHK(D3DXAssembleShader(PAnsiChar(Shader),length(Shader),nil,nil,0,addr(temp),nil));
HRESULTCHK(Dev.CreateVertexShader(temp.GetBufferPointer,Result));
{$ENDIF}
end;

function TAGD3D9ShaderGraphicCore.LoadPixelShader(Shader:ansistring):IDirect3DPixelShader9;
var
  temp:ID3DXBuffer;
{$IFDEF DEBUG}
  temp2:ID3DXBuffer;
  s:string;
begin
D3DXAssembleShader(PAnsiChar(Shader),length(Shader),nil,nil,0,addr(temp),addr(temp2));
if Assigned(temp2) then
  s:=PAnsiChar(temp2.GetBufferPointer);
Dev.CreatePixelShader(temp.GetBufferPointer,Result);
{$ELSE}
begin
HRESULTCHK(D3DXAssembleShader(PAnsiChar(Shader),length(Shader),nil,nil,0,addr(temp),nil));
HRESULTCHK(Dev.CreatePixelShader(temp.GetBufferPointer,Result));
{$ENDIF}
end;

procedure TAGD3D9ShaderGraphicCore.SetUnicolorMod(Col:TAGColor);
var
  bools:array[0..1]of longbool;
  FCol:TAGFloatColor;
begin
bools[0]:=False;
bools[1]:=True;
FCol:=TAGFloatColor(Col);
with Dev do
begin
  SetPixelShaderConstantB(0,addr(bools),2);
  SetPixelShaderConstantF(0,addr(FCol),1);
end;
Set2DVertexDeclaration(False,False);
end;

//2D

procedure TAGD3D9ShaderGraphicCore.Update2DVertexConfig();
var
  m:TD3DXMatrix;
begin
D3DXMatrixMultiply(m,Camera2D,GenProjection);
Dev.SetVertexShaderConstantF(0,addr(m),4);
end;

procedure TAGD3D9ShaderGraphicCore.Set2DVertexDeclaration(UseText,UseColor:boolean);
var
  p:array[0..3]of TD3DVertexElement9;
  vd:IDirect3DVertexDeclaration9;
begin
with p[0] do
begin
  Stream:=0;
  Offset:=0;
  _Type:=D3DDECLTYPE_FLOAT3;
  Method:=D3DDECLMETHOD_DEFAULT;
  Usage:=D3DDECLUSAGE_POSITION;
  UsageIndex:=0;
end;
if not UseText and not UseColor then
  p[1]:=D3DDECL_END
else if UseText and not UseColor then
begin
  with p[1] do
  begin
    Stream:=0;
    Offset:=12;
    _Type:=D3DDECLTYPE_FLOAT2;
    Method:=D3DDECLMETHOD_DEFAULT;
    Usage:=D3DDECLUSAGE_TEXCOORD;
    UsageIndex:=0;
  end;
  p[2]:=D3DDECL_END;
end
else if not UseText and UseColor then
begin
  with p[1] do
  begin
    Stream:=0;
    Offset:=8;
    _Type:=D3DDECLTYPE_D3DCOLOR;
    Method:=D3DDECLMETHOD_DEFAULT;
    Usage:=D3DDECLUSAGE_COLOR;
    UsageIndex:=0;
  end;
  p[2]:=D3DDECL_END;
end
else
begin
  with p[1] do
  begin
    Stream:=0;
    Offset:=8;
    _Type:=D3DDECLTYPE_FLOAT2;
    Method:=D3DDECLMETHOD_DEFAULT;
    Usage:=D3DDECLUSAGE_TEXCOORD;
    UsageIndex:=0;
  end;
  with p[2] do
  begin
    Stream:=0;
    Offset:=16;
    _Type:=D3DDECLTYPE_D3DCOLOR;
    Method:=D3DDECLMETHOD_DEFAULT;
    Usage:=D3DDECLUSAGE_COLOR;
    UsageIndex:=0;
  end;
  p[3]:=D3DDECL_END;
end;
Dev.CreateVertexDeclaration(addr(p),vd);
Dev.SetVertexDeclaration(vd);
end;

procedure TAGD3D9ShaderGraphicCore.Set2DTexturedMod(Text:IDirect3DTexture9;opacity:single=1);
var
  bools:longbool;
  alpha:array[0..3]of Single;
begin
bools:=Text<>nil;
alpha[3]:=opacity;
with Dev do
begin
  Text.PreLoad;
  SetTexture(0,Text);
  SetPixelShaderConstantB(0,addr(bools),1);
  SetPixelShaderConstantF(0,addr(alpha),1);
end;
Set2DVertexDeclaration(True,False);
end;

//3D



function TAGD3D9ShaderGraphicCore.FCreateTexFromFile(FileName:String):TAGD3D9Mat;
var
  s:string;
begin
Result:=inherited;
s:=TPath.GetDirectoryName(FileName)+TPath.DirectorySeparatorChar+TPath.GetFileNameWithoutExtension(FileName);
{$IFDEF VampyreIL}
  try
    LoadD3DTextureFromFile(s+'_spec'+TPath.GetExtension(FileName),Dev,Result.Spec);
  except
    Pointer(Result.Norm):=nil;
  end;
  try
    LoadD3DTextureFromFile(s+'_norm'+TPath.GetExtension(FileName),Dev,Result.Norm);
  except
    Pointer(Result.Norm):=nil;
  end;
{$ELSE}
  D3DXCreateTextureFromFileEx(Dev,PChar(s+'_spec'+TPath.GetExtension(FileName)),
    D3DX_DEFAULT,D3DX_DEFAULT,D3DX_DEFAULT,0,D3DFMT_UNKNOWN,D3DPOOL_MANAGED,
    D3DX_DEFAULT,D3DX_DEFAULT,$00000000,nil,nil,Result.Spec);
  D3DXCreateTextureFromFileEx(Dev,PChar(s+'_norm'+TPath.GetExtension(FileName)),
    D3DX_DEFAULT,D3DX_DEFAULT,D3DX_DEFAULT,0,D3DFMT_UNKNOWN,D3DPOOL_MANAGED,
    D3DX_DEFAULT,D3DX_DEFAULT,$00000000,nil,nil,Result.Norm);
{$ENDIF}
end;

procedure TAGD3D9ShaderGraphicCore.SetMaterial(Mat:TAGD3D9Mat);
var
  bools:array[0..2]of longbool;
begin
inherited;
bools[0]:=Mat.Text<>nil;
if not bools[0] then
begin
  bools[1]:=True;
  Dev.SetPixelShaderConstantB(0,addr(bools),2);
end
else
begin
  bools[1]:=Mat.Spec<>nil;
  bools[2]:=Mat.Norm<>nil;
  if bools[1] then
    Dev.SetTexture(1,Mat.Spec);
  if bools[2] then
    Dev.SetTexture(2,Mat.Norm);
  Dev.SetPixelShaderConstantB(0,addr(bools),3);
end;
end;

procedure TAGD3D9ShaderGraphicCore.Set3DUniTextureMod(Text:IDirect3DTexture9;opacity:single=1);
const
  F:longbool=False;
begin
Set2DTexturedMod(Text,opacity);
Dev.SetPixelShaderConstantB(3,addr(F),1);
end;

procedure TAGD3D9ShaderGraphicCore.Update3DVertexConfig();
var
  m:array[0..1]of TD3DXMatrix;
  view_pos:TD3DXVector4;
begin
D3DXMatrixMultiply(m[0],Camera3D,GenProjection);
D3DXMatrixInverse(m[1],nil,m[0]);
view_pos.x:=m[1]._41;
view_pos.y:=m[1]._42;
view_pos.z:=m[1]._43;
view_pos.w:=m[1]._44;
Dev.SetPixelShaderConstantF(1,addr(view_pos),1);

D3DXMatrixIdentity(m[1]);
Dev.SetVertexShaderConstantF(0,addr(m[0]),8);
end;

procedure TAGD3D9ShaderGraphicCore.Update3DVertexConfig(CurrPos:TD3DXMatrix);
var
  m:array[0..1]of TD3DXMatrix;
  view_pos:TD3DXVector4;
begin
D3DXMatrixMultiply(m[1],Camera3D,GenProjection);
D3DXMatrixInverse(m[0],nil,m[1]);
view_pos.x:=m[1]._41;
view_pos.y:=m[1]._42;
view_pos.z:=m[1]._43;
view_pos.w:=m[1]._44;
Dev.SetPixelShaderConstantF(1,addr(view_pos),1);

D3DXMatrixMultiply(m[0],CurrPos,m[1]);
m[1]:=CurrPos;
Dev.SetVertexShaderConstantF(0,addr(m[0]),8);
end;

procedure TAGD3D9ShaderGraphicCore.Update3DVertexConfigAsIdenty();
const
  view_pos:TD3DXVector4=(x:0;y:0;z:0;w:1);
  m:array[0..1]of TD3DXMatrix=(
     (_11:1;_12:0;_13:0;_14:0;
      _21:0;_22:1;_23:0;_24:0;
      _31:0;_32:0;_33:1;_34:0;
      _41:0;_42:0;_43:0;_44:1),
     (_11:1;_12:0;_13:0;_14:0;
      _21:0;_22:1;_23:0;_24:0;
      _31:0;_32:0;_33:1;_34:0;
      _41:0;_42:0;_43:0;_44:1));
begin
Dev.SetPixelShaderConstantF(1,addr(view_pos),1);
Dev.SetVertexShaderConstantF(0,addr(m[0]),8);
end;

procedure TAGD3D9ShaderGraphicCore.Set3DOpacity(opacity:Single);
var
  alpha:array[0..3]of Single;
begin
alpha[3]:=opacity;
Dev.SetPixelShaderConstantF(0,addr(alpha),1);
end;

procedure TAGD3D9ShaderGraphicCore.Set3DLightingEnable(Enable:longbool);
begin
Dev.SetPixelShaderConstantB(3,addr(Enable),1);
end;

function TAGD3D9ShaderGraphicCore.GenPixel3DShader(Direct,Point,Spot:byte):AnsiString;
var
  i:integer;
begin
Result:='ps.3.0'+sLineBreak+
        //*********************************************
        //*Inputs                                     *
        //*********************************************
        //v0              Texture coord
        //v1              Color
        //v2              Normal
        //s0              Diffuse
        //s1              Normal
        //s2              Specular
        //*********************************************
        //*Constants                                  *
        //*********************************************
        //b0              Use texture
        //b1              if b0: Use specular
        //b1              else:  Use color const
        //b2              Use normal
        //b3              Use lighting
        //c0.xyz          if not b0: Color
        //c0.w            Gloabal alpha
        //c1.xyz          View
        //*********************************************
        //Global dirrect light
        //c[2+i*2].xyz    Direction
        //c[2+i*2+1].xyz  Color
        //c[2+i*2+1].w    Bright
        //*********************************************
        //Point light
        //c[2+i*2].xyz    Position
        //c[2+i*2+1].xyz  Color
        //c[2+i*2].w      Radius
        //c[2+i*2+1].w    Bright
        //*********************************************
        //Conus light
        //c[2+i*3].xyz    Direction
        //c[2+i*3+1].xyz  Position
        //c[2+i*3+2].xyz  Color
        //c[2+i*3].w      Angle
        //c[2+i*3+1].w    Radius
        //c[2+i*3+2].w    Bright
        //*********************************************
        //*Outputs                                    *
        //*********************************************
        //o0              Color
        //*********************************************
        'dcl_2d s0'+sLineBreak+
        'dcl_2d s1'+sLineBreak+
        'dcl_2d s2'+sLineBreak+
        'dcl_texcoord0 v0.xy'+sLineBreak+
        'dcl_color     v1'+sLineBreak+
        'dcl_normal    v2.xyz'+sLineBreak+
        'dcl_tangent   v3.xyz'+sLineBreak+
        'dcl_binormal  v4.xyz'+sLineBreak+
        'dcl_texcoord1 v5.xyz'+sLineBreak+
        'def c2,-1,2,16,1'+sLineBreak+
        'def c3,0,1,10,5'+sLineBreak+
        //'def c111,0,0,16,1.13'+sLineBreak+
        //Load diffuse color to r0
        'if b0'+sLineBreak+
        '  texld r0,v0,s0'+sLineBreak+
        '  mul r0.a,r0.a,c0.a'+sLineBreak+
        'else'+sLineBreak+
        '  if b1'+sLineBreak+
        '    mov r0,c0'+sLineBreak+
        '  else'+sLineBreak+
        '    mov r0,v1'+sLineBreak+
        '  endif'+sLineBreak+
        'endif'+sLineBreak;
if(Direct<>0)or(Point<>0)or(Spot<>0)then
begin
  Result:=Result+'if b3'+sLineBreak+
                 //Modify r0 by litghting if need
                 '  mov r10,c3.x'+sLineBreak+
                    //Load specular color to r11
                 '  if b0'+sLineBreak+
                 '    if b1'+sLineBreak+
                 '      texld r11,v0,s1'+sLineBreak+
                 '    else'+sLineBreak+
                 '      mov r11,c3.x'+sLineBreak+
                 '    endif'+sLineBreak+
                 '  else'+sLineBreak+
                 '  endif'+sLineBreak+
                 '  if b0'+sLineBreak+
                 '    if b2'+sLineBreak+
                 '      texld r12,v0,s2'+sLineBreak+
                 '    else'+sLineBreak+
                 '      mov r12.x,c3.x'+sLineBreak+
                 '      mov r12.y,c3.x'+sLineBreak+
                 '      mov r12.z,c2.w'+sLineBreak+
                 '    endif'+sLineBreak+
                 '  else'+sLineBreak+
                 '    mov r12.x,c3.x'+sLineBreak+
                 '    mov r12.y,c3.x'+sLineBreak+
                 '    mov r12.z,c2.w'+sLineBreak+
                 '  endif'+sLineBreak+
                 '  nrm r1.xyz,r12.xyz'+sLineBreak+
                 '  mul r2.xyz,r1.x,v3.xyz'+sLineBreak+
                 '  mad r2.xyz,r1.y,v4.xyz,r2.xyz'+sLineBreak+
                 '  mad r2.xyz,r1.z,v2.xyz,r2.xyz'+sLineBreak+
                 '  nrm r12.xyz,r2.xyz'+sLineBreak;
  for i:=0 to Direct-1 do
    Result:=Result+'  nrm r1,c'+inttostr(4+i*2)+'.xyz'+sLineBreak+
                   '  mov r2,c'+inttostr(5+i*2)+sLineBreak+
                   '  call l0'+sLineBreak;
  for i:=0 to Point-1 do
    Result:=Result+'  mov r1,c'+inttostr(4+(Direct+i)*2)+sLineBreak+
                   '  mov r2,c'+inttostr(5+(Direct+i)*2)+sLineBreak+
                   '  call l1';
  {for i:=0 to Point-1 do
    Result:=Result+'  nrm r1,c'+inttostr(2+i*2)+'.xyz'+sLineBreak+
                   '  mul r1,r1,c1.x'+sLineBreak+
                   '  dp3 r1.x,v2.xyz,r1.xyz'+sLineBreak+
                   '  mul r1.x,r1.x,c'+inttostr(3+i*2)+'.w'+sLineBreak+
                   '  mul r1.x,r1.x,c1.y'+sLineBreak+
                   '  mul r1.xyz,r1.x,c'+inttostr(3+i*2)+'.xyz'+sLineBreak+
                   '  mul r0.xyz,r1.xyz,r0.xyz'+sLineBreak;}
  Result:=Result+'  mov r0.xyz,r10.xyz'+sLineBreak+
                 'endif'+sLineBreak+

                 //'mul r0.a,c111.w,r0.a'+sLineBreak+
                 //'pow r0.a,r0.a,c111.z'+sLineBreak+

                 'mov oC0,r0'+sLineBreak+
                 'ret'+sLineBreak;
  if Point>0 then
    Result:=Result+
                   //************************************************
                   //*Call for point light count                   *
                   //************************************************
                   //r0     Diffuse color
                   //r1     c[2+i*2]
                   //r2     c[2+i*2+1]
                   //r10    Current color
                   //r11    Specular color
                   //r12    ExNormal
                   //************************************************
                   'label l1'+sLineBreak+
                   'sub r3.xyz,v5.xyz,r1.xyz'+sLineBreak+
                   'nrm r1.xyz,r3.xyz'+sLineBreak+
                   'rcp r1.w,r3.x'+sLineBreak+
                   'mul r1.w,r1.w,r1.x'+sLineBreak+
                   'mul r2.w,r2.w,r1.x'+sLineBreak+

                   'call l0'+sLineBreak+

                   'ret'+sLineBreak;
  if Direct+Point>0 then
    Result:=Result+
                   //************************************************
                   //*Call for direct light count                   *
                   //************************************************
                   //r0     Diffuse color
                   //r1.xyz Normalized Direction(normal(c[2+i*2]))
                   //r2     c[2+i*2+1]
                   //r10    Current color
                   //r11    Specular color
                   //r12    ExNormal
                   //************************************************
                   'label l0'+sLineBreak+
                   {'mov r3,r1'+sLineBreak+
                   'mul r1,r1,c2.x'+sLineBreak+
                   'dp3 r1.x,r12.xyz,r1.xyz'+sLineBreak+
                   'mul r1.x,r1.x,r2.w'+sLineBreak+
                   'mul r1.x,r1.x,c2.y'+sLineBreak+
                   'mul r1.xyz,r1.x,r2.xyz'+sLineBreak+
                   'mad_sat r10.xyz,r1.xyz,r0xyz,r10.xyz'+sLineBreak+

                   'sub r4.xyz,c1.xyz,r3.xyz'+sLineBreak+
                   'nrm r3.xyz,r4.xyz'+sLineBreak+//incidentVec=normalize(view-direcion)
                   'dp3 r4.x,r3.xyz,r12.xyz'+sLineBreak+//r3=Dot(incidentVec,normal)
                   'pow r3.x,r4.x,c2.z'+sLineBreak+//pow(dot(normal,r3),16)
                   'mul r3.x,r3.x,r2.w'+sLineBreak+
                   //'mul r3.x,r3.x,c2.z'+sLineBreak+
                   'mul r3.xyz,r3.x,r2.xyz'+sLineBreak+
                   'mul r3.xyz,r3.xyz,r11.xyz'+sLineBreak+//specular_color*specular_intensity*
                   'mad_sat r10.xyz,r3.xyz,r0.xyz,r10.xyz'+sLineBreak+} //15 lines
                   //'mov r3,r1'+sLineBreak+
                   'mul r3,r1,c2.x'+sLineBreak+
                   'dp3 r3.x,r12.xyz,r3.xyz'+sLineBreak+
                   'mul r13.x,r3.x,c2.y'+sLineBreak+

                   'sub r4.xyz,c1.xyz,r1.xyz'+sLineBreak+
                   'nrm r3.xyz,r4.xyz'+sLineBreak+//incidentVec=normalize(view-direcion)
                   'dp3 r4.x,r3.xyz,r12.xyz'+sLineBreak+//r3=Dot(incidentVec,normal)
                   'pow r3.x,r4.x,c2.z'+sLineBreak+//pow(dot(normal,r3),16)

                   'mad_sat r3.xyz,r3.x,r11.xyz,r13.x'+sLineBreak+
                   'mul r3.xyz,r3.xyz,r2.w'+sLineBreak+
                   'mul r3.xyz,r3.xyz,r2.xyz'+sLineBreak+
                   'mad_sat r10.xyz,r3.xyz,r0.xyz,r10.xyz'+sLineBreak+ //11 lines
                   'ret'+sLineBreak;
end
else
  Result:=Result+'mov oC0,r0';
//;mov oDepth,r0.x
end;

function TAGD3D9ShaderGraphicCore.GetPixel3DShader(Direct,Point,Spot:byte):IDirect3DPixelShader9;
begin
if not DefPixelShaders.TryGetValue(TPixelShaderAbout.Create(Direct,Point,Spot),Result) then
begin
  Result:=LoadPixelShader(GenPixel3DShader(Direct,Point,Spot));
  DefPixelShaders.Add(TPixelShaderAbout.Create(Direct,Point,Spot),Result);
end;
end;

procedure TAGD3D9ShaderGraphicCore.UpdateLightingConf();
var
  CurrentConf:TList<TD3DXVector4>;
  i:Word;
begin
with LitingConf do
begin
  Dev.SetPixelShader(GetPixel3DShader(length(Direct),length(Point),length(Spot)));
  if NeedUpdate then
  begin
    CurrentConf:=TList<TD3DXVector4>.Create;
    if length(Direct)<>0 then
      for i:=0 to length(Direct)-1 do
        with Direct[i] do
        begin
          CurrentConf.Add(TD3DXVector4.Create(FDir,0));
          CurrentConf.Add(TD3DXVector4.Create(FCol,FBright));
        end;
    if length(Point)<>0 then
      for i:=0 to length(Point)-1 do
        with Point[i] do
        begin
         CurrentConf.Add(TD3DXVector4.Create(FPos,FRange));
          CurrentConf.Add(TD3DXVector4.Create(FCol,FBright));
        end;
    if length(Spot)<>0 then
      for i:=0 to length(Spot)-1 do
        with Spot[i] do
        begin
          CurrentConf.Add(TD3DXVector4.Create(Dir,Theta));
          CurrentConf.Add(TD3DXVector4.Create(Pos,Range));
          CurrentConf.Add(TD3DXVector4.Create(Col,Bright));
        end;
    Dev.SetPixelShaderConstantF(4,addr(CurrentConf.List[0]),CurrentConf.Count);
    FreeAndNil(CurrentConf);
  end;
end;
end;

//Shaders

function TAGD3D9ShaderGraphicCore.GetShader(Usage:TAGShaderUsage):TAGShader;
var
  Size:cardinal;
begin
with Shaders do
  with Usage do
    case &Type of
    CAGVertexShader:
      if Assigned(Vertex)then
      begin
        Vertex.GetFunction(nil,size);
        Result:=TMemoryStream.Create;
        (Result as TMemoryStream).SetSize(size);
        Vertex.GetFunction((Result as TMemoryStream).Memory,size);
      end
      else
        Result:=nil;
    CAGPixelShader:
      case PixelShaderType of
      CAGTextureShader:
        if Num=-1 then
          if Assigned(TextureDef)then
          begin
            TextureDef.GetFunction(nil,size);
            Result:=TMemoryStream.Create;
            (Result as TMemoryStream).SetSize(size);
            TextureDef.GetFunction((Result as TMemoryStream).Memory,size);
          end
          else
            Result:=nil
        else if Assigned(Textures[Num])then
        begin
          TextureDef.GetFunction(nil,size);
          Result:=TMemoryStream.Create;
          (Result as TMemoryStream).SetSize(size);
          TextureDef.GetFunction((Result as TMemoryStream).Memory,size);
        end
        else
          Result:=nil;
      CAGPreProcessShader:
        if Assigned(PreProcess)then
        begin
          PreProcess.GetFunction(nil,size);
          Result:=TMemoryStream.Create;
          (Result as TMemoryStream).SetSize(size);
          PreProcess.GetFunction((Result as TMemoryStream).Memory,size);
        end
        else
          Result:=nil;
      CAGPostProcessShader:
        if Assigned(PostProcess)then
        begin
          PostProcess.GetFunction(nil,size);
          Result:=TMemoryStream.Create;
          (Result as TMemoryStream).SetSize(size);
          PostProcess.GetFunction((Result as TMemoryStream).Memory,size);
        end
        else
          Result:=nil;
      end;
    CAGGeometryShader:
      raise EAGUnSupportedException.Create('Geometry shaders unsupported by D3D9');
    end;
end;

procedure TAGD3D9ShaderGraphicCore.SetShader(Usage:TAGShaderUsage;Shader:TAGShader);
var
  p:Pointer;
begin
with Shaders do
  with Usage do
  begin
    case &Type of
    CAGVertexShader:
      if Assigned(Vertex)then
        Vertex:=nil;
    CAGPixelShader:
      case PixelShaderType of
      CAGTextureShader:
        if Num=-1 then
        begin
          if Assigned(TextureDef)then
            TextureDef:=nil;
        end
        else if Assigned(Textures[Num])then
          TextureDef:=nil;
      CAGPreProcessShader:
        if Assigned(PreProcess)then
          PreProcess:=nil;
      CAGPostProcessShader:
        if Assigned(PostProcess)then
          PostProcess:=nil;
      end;
    end;
    if Assigned(Shader) then
    begin
      GetMem(p,Shader.Size);
      Shader.Read(p^,Shader.Size);
      Shader.Seek(0,soBeginning);
      case &Type of
      CAGVertexShader:
        HRESULTCHK(Dev.CreateVertexShader(p,Vertex));
      CAGPixelShader:
        case PixelShaderType of
        CAGTextureShader:
          if Num=-1 then
            HRESULTCHK(Dev.CreatePixelShader(p,TextureDef))
          else
            HRESULTCHK(Dev.CreatePixelShader(p,Textures[Num]));
        CAGPreProcessShader:
          HRESULTCHK(Dev.CreatePixelShader(p,PreProcess));
        CAGPostProcessShader:
          HRESULTCHK(Dev.CreatePixelShader(p,PostProcess));
        end;
      CAGGeometryShader:
        raise EAGUnSupportedException.Create('Geometry shaders unsupported by D3D9');
      end;
      FreeMem(p);
    end;
  end;
end;

{public}

procedure TAGD3D9ShaderGraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);
begin
inherited;
StandartVertexShader:=LoadVertexShader('vs.3.0'+sLineBreak+
                                       //*********************************************
                                       //*Inputs                                     *
                                       //*********************************************
                                       //v0              Position
                                       //v1              Texture coord
                                       //v2              Color
                                       //v3              Normal
                                       //*********************************************
                                       //*Constants                                  *
                                       //*********************************************
                                       //Matrix for position
                                       //c0-c3           Projection*Camera*World
                                       //c4-c7           World
                                       //*********************************************
                                       //*Outputs                                    *
                                       //*********************************************
                                       //o0              Position
                                       //o1              Texture coord
                                       //o2              Color
                                       //o3              Normal
                                       //o4              Tangent
                                       //o5              Binormal
                                       //o6              Position as text
                                       //*********************************************
                                       'dcl_position  v0'+sLineBreak+
                                       'dcl_texcoord  v1.xy'+sLineBreak+
                                       'dcl_color     v2'+sLineBreak+
                                       'dcl_normal    v3.xyz'+sLineBreak+
                                       'dcl_tangent   v4.xyz'+sLineBreak+
                                       'dcl_binormal  v5.xyz'+sLineBreak+
                                       'dcl_position  o0'+sLineBreak+
                                       'dcl_texcoord0 o1.xy'+sLineBreak+
                                       'dcl_color     o2'+sLineBreak+
                                       'dcl_normal    o3.xyz'+sLineBreak+
                                       'dcl_tangent   o4.xyz'+sLineBreak+
                                       'dcl_binormal  o5.xyz'+sLineBreak+
                                       'dcl_texcoord1 o6.xyz'+sLineBreak+
                                       'def c100,1,1,1,1'+sLineBreak+
                                       'mul r0,c0,v0.x'+sLineBreak+
                                       'mad r0,c1,v0.y,r0'+sLineBreak+
                                       'mad r0,c2,v0.z,r0'+sLineBreak+
                                       'mad o0,c3,v0.w,r0'+sLineBreak+
                                       'mov o1.xy,v1.xy'+sLineBreak+
                                       'mov o2,v2'+sLineBreak+

                                       'mul r0,c4,v3.x'+sLineBreak+
                                       'mad r0,c5,v3.y,r0'+sLineBreak+
                                       //'mad r0,c6,v3.z,r0'+sLineBreak+
                                       //'mad o3,c7,v3.w,r0'+sLineBreak+
                                       'mad r3.xyz,c6,v3.z,r0'+sLineBreak+

                                       'mul r0,c4,v4.x'+sLineBreak+
                                       'mad r0,c5,v4.y,r0'+sLineBreak+
                                       //'mad r0,c6,v4.z,r0'+sLineBreak+
                                       //'mad o4,c7,v4.w,r0'+sLineBreak+
                                       'mad r4.xyz,c6,v4.z,r0'+sLineBreak+

                                       'crs r5.xyz,r3,r4'+sLineBreak+
                                       'mov o5.xyz,r5.xyz'+sLineBreak+
                                       'mov o3.xyz,r3.xyz'+sLineBreak+
                                       'mov o4.xyz,r4.xyz'+sLineBreak+

                                       'mul r0,c4,v0.x'+sLineBreak+
                                       'mad r0,c5,v0.y,r0'+sLineBreak+
                                       'mad r0,c6,v0.z,r0'+sLineBreak+
                                       'mad o6.xyz,c7,v0.w,r0');
Standart2DVertexShader:=LoadVertexShader('vs.3.0'+sLineBreak+
                                         //*********************************************
                                         //*Inputs                                     *
                                         //*********************************************
                                         //v0              Position
                                         //v1              Texture coord
                                         //v2              Color
                                         //*********************************************
                                         //*Constants                                  *
                                         //*********************************************
                                         //Matrix for position
                                         //c0-c3           Projetion*Camera
                                         //*********************************************
                                         //*Outputs                                    *
                                         //*********************************************
                                         //o0              Position
                                         //o1              Texture coord
                                         //o2              Color
                                         //*********************************************
                                         'dcl_position v0'+sLineBreak+
                                         'dcl_texcoord v1.xy'+sLineBreak+
                                         'dcl_color    v2'+sLineBreak+
                                         'dcl_position o0'+sLineBreak+
                                         'dcl_texcoord o1.xy'+sLineBreak+
                                         'dcl_color    o2'+sLineBreak+
                                         'mul r0,c0,v0.x'+sLineBreak+
                                         'mad r0,c1,v0.y,r0'+sLineBreak+
                                         'mad r0,c2,v0.z,r0'+sLineBreak+
                                         'mad o0,c3,v0.w,r0'+sLineBreak+
                                         'mov o1.xy,v1.xy'+sLineBreak+
                                         'mov o2,v2'
                                         );
Standart2DPixelShader:=LoadPixelShader('ps.3.0'+sLineBreak+
                                       //*********************************************
                                       //*Inputs                                     *
                                       //*********************************************
                                       //v0              Texture coord
                                       //v1              Color
                                       //s0              Texture(if need)
                                       //*********************************************
                                       //*Constants                                  *
                                       //*********************************************
                                       //Configuration
                                       //b0              Use texture
                                       //b1              if not b0: Use color const
                                       //c0.xyz          if not b0 and b1: Color
                                       //c0.w            Opasity
                                       //*********************************************
                                       //*Outputs                                    *
                                       //*********************************************
                                       //oC0             Color
                                       //*********************************************
                                       'dcl_2d s0'+sLineBreak+
                                       'dcl_texcoord v0.xy'+sLineBreak+
                                       'dcl_color v1'+sLineBreak+
                                       'if b0'+sLineBreak+
                                       '  texld r0,v0,s0'+sLineBreak+
                                       '  mul r0.a,r0.a,c0.a'+sLineBreak+
                                       'else'+sLineBreak+
                                       '  if b1'+sLineBreak+
                                       '    mov r0,c0'+sLineBreak+
                                       '  else'+sLineBreak+
                                       '    mov r0,v1'+sLineBreak+
                                       '  endif'+sLineBreak+
                                       'endif'+sLineBreak+
                                       'mov oC0,r0'
                                       );

if Assigned(initer) then
  initer(self);
D3DXMatrixIdentity(Camera3D);
with LitingConf do
begin
  BaseID:=0;
  NeedUpdate:=True;
  SetLength(Direct,0);
  SetLength(Point,0);
  SetLength(Spot,0);
end;
DefPixelShaders:=TDictionary<TPixelShaderAbout,IDirect3DPixelShader9>.Create();
end;

//2D

procedure TAGD3D9ShaderGraphicCore.Init2D();
begin
Use3D:=False;
with Dev do
begin
  //Выключение отбраковки
  SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
  //Выключение освещения
  SetRenderState(D3DRS_LIGHTING,0);
  //Выключение Z-буфера
  //SetRenderState(D3DRS_ZENABLE,0);
  //SetRenderState(D3DRS_ZWRITEENABLE,0);
  SetRenderState(D3DRS_ZFUNC,D3DCMP_ALWAYS);

  SetVertexShader(Standart2DVertexShader);
  SetPixelShader(Standart2DPixelShader);
end;
Update2DCam;
Update2DVertexConfig;
end;

procedure TAGD3D9ShaderGraphicCore.DrawRectangle(rect:TAGCoord;size:word;brush:TAGBrush);
var
  a:array[0..9]of TD3DXVECTOR2;
  PSz:Single;
begin
SetUnicolorMod(brush.AGColor);
PSz:=size/2;
with rect do
begin
  a[0]:=TD3DXVECTOR2.Create(X+PSz,Y+PSz);
  a[1]:=TD3DXVECTOR2.Create(X-PSz,Y-PSz);
  a[2]:=TD3DXVECTOR2.Create(X+W-PSz,Y+PSz);
  a[3]:=TD3DXVECTOR2.Create(X+W+PSz,Y-PSz);
  a[4]:=TD3DXVECTOR2.Create(X+W-PSz,Y+H-PSz);
  a[5]:=TD3DXVECTOR2.Create(X+W+PSz,Y+H+PSz);
  a[6]:=TD3DXVECTOR2.Create(X+PSz,Y+H-PSz);
  a[7]:=TD3DXVECTOR2.Create(X-PSz,Y+H+PSz);
  a[8]:=a[0];
  a[9]:=a[1];
end;
with Dev do
begin
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,8,a,SizeOf(a[0]));
end;
end;

procedure TAGD3D9ShaderGraphicCore.DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);
var
  i,st:integer;
  a:array of TD3DXVECTOR2;
begin
SetUnicolorMod(brush.AGColor);
with radaii do
  if x>y then
    st:=System.Round(x)
  else
    st:=System.Round(y);
SetLength(a,st*4+2);
for i:=0 to st*2 do
begin
  a[i*2]:=TD3DXVECTOR2.Create(cos(i*pi/st)*(radaii.X-size/2)+point.X,sin(i*pi/st)*(radaii.Y-size/2)+point.Y);
  a[i*2+1]:=TD3DXVECTOR2.Create(cos(i*pi/st)*(radaii.X+size/2)+point.X,sin(i*pi/st)*(radaii.Y+size/2)+point.Y);
end;
Dev.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,st*4,a[0],SizeOf(a[0]));
end;

procedure TAGD3D9ShaderGraphicCore.DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);
var
  Data:array[0..3]of record
    x,y,z:single;
    Tx,Ty:Single;
  end;
begin
Set2DTexturedMod(bitmap.D3D9^,opacity/255);
with Data[0] do
begin
  x:=coord.X;
  y:=coord.Y;
  z:=0;
  Tx:=0;
  Ty:=0;
end;
with Data[1] do
begin
  x:=coord.X+coord.W;
  y:=coord.Y;
  z:=0;
  Tx:=1;
  Ty:=0;
end;
with Data[2] do
begin
  x:=coord.X;
  y:=coord.Y+coord.H;
  z:=0;
  Tx:=0;
  Ty:=1;
end;
with Data[3] do
begin
  x:=coord.X+coord.W;
  y:=coord.Y+coord.H;
  z:=0;
  Tx:=1;
  Ty:=1;
end;

with Dev do
begin
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MINFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);
  end;
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,Data[0],SizeOf(Data[0]));
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MINFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MIPFILTER,DEFTEXF);
  end;
end;
end;

procedure TAGD3D9ShaderGraphicCore.FillRectangle(rect:TAGCoord;brush:TAGBrush);
var
  a:array[0..3]of TD3DXVECTOR3;
begin
SetUnicolorMod(brush.AGColor);
with rect do
begin
  a[0]:=TD3DXVECTOR3.Create(X+W,Y,0);
  a[1]:=TD3DXVECTOR3.Create(X,Y,0);
  a[2]:=TD3DXVECTOR3.Create(X+W,Y+H,0);
  a[3]:=TD3DXVECTOR3.Create(X,Y+H,0);
end;
Dev.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,a,SizeOf(a[0]));
end;

//3D

procedure TAGD3D9ShaderGraphicCore.Init3D();
begin
with Dev do
begin
  SetRenderState(D3DRS_CULLMODE,D3DCULL_CCW);
  SetRenderState(D3DRS_LIGHTING,1);
  //SetRenderState(D3DRS_ZENABLE,1);
  //SetRenderState(D3DRS_ZWRITEENABLE,1);
  SetRenderState(D3DRS_ZFUNC,D3DCMP_LESS);

  SetVertexShader(StandartVertexShader);
end;
Use3D:=True;
Update3DVertexConfig(TD3DXMatrix.Create(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
UpdateLightingConf;
end;

function TAGD3D9ShaderGraphicCore.AddDirectLight(Direction:TAG3DVector;Color:TAGColor;Bright:Single=1):TAGLight;
var
  pos:SmallInt;
begin
with LitingConf do
begin
  NeedUpdate:=True;
  pos:=Length(Direct);
  SetLength(Direct,pos+1);
  with Direct[pos] do
  begin
    FID:=BaseID;
    FDir:=TD3DXVECTOR3
         {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
           (Direction)
         {$ELSE}
           .Create(Direction.X,Direction.Y,Direction.Z)
         {$ENDIF};
    with Color do
      FCol:=TD3DXVECTOR3.Create(R/255,G/255,B/255);
    FBright:=Bright;
  end;
  Result.def:=BaseID;
  inc(BaseID);
end;
end;

function TAGD3D9ShaderGraphicCore.AddPointLight(Position:TAG3DVector;Color:TAGColor;Range:Single;Bright:Single=1):TAGLight;
var
  pos:SmallInt;
begin
with LitingConf do
begin
  NeedUpdate:=True;
  pos:=Length(Point);
  SetLength(Point,pos+1);
  with Point[pos] do
  begin
    FID:=BaseID;
    FPos:=TD3DXVECTOR3
         {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
           (Position)
         {$ELSE}
           .Create(Position.X,Position.Y,Position.Z)
         {$ENDIF};
    FRange:=Range;
    with Color do
      FCol:=TD3DXVECTOR3.Create(R/255,G/255,B/255);
    FBright:=Bright;
  end;
  Result.def:=BaseID;
  inc(BaseID);
end;
end;

procedure TAGD3D9ShaderGraphicCore.DelLight(l:TAGLight);
var
  i,i0:word;
begin
with LitingConf do
begin
  NeedUpdate:=True;
  for i:=0 to length(Direct)-1 do
    if Direct[i].FID=l.def then
    begin
      for i0:=i to length(Direct)-2 do
        Direct[i0]:=Direct[i0+1];
      exit;
    end;
  for i:=0 to length(Point)-1 do
    if Point[i].FID=l.def then
    begin
      for i0:=i to length(Point)-2 do
        Point[i0]:=Point[i0+1];
      exit;
    end;
  for i:=0 to length(Spot)-1 do
    if Spot[i].ID=l.def then
    begin
      for i0:=i to length(Spot)-2 do
        Spot[i0]:=Spot[i0+1];
      exit;
    end;
end;
end;

procedure TAGD3D9ShaderGraphicCore.SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);
begin
D3DXMatrixLookAtLH(Camera3D,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (Cam)
  {$ELSE}
    .Create(Cam.X,Cam.Y,Cam.Z)
  {$ENDIF}
  ,TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (Obj)
  {$ELSE}
    .Create(Obj.X,Obj.Y,Obj.Z)
  {$ENDIF},TD3DXVECTOR3
  {$IF sizeof(TAG3DVector)=sizeof(Single)*3}
    (UpDirection)
  {$ELSE}
    .Create(UpDirection.X,UpDirection.Y,UpDirection.Z)
  {$ENDIF});
end;

procedure TAGD3D9ShaderGraphicCore.SetCameraByMatrix(Matrix:TAG3DMatrix);
begin
Camera3D:=Matrix.ToD3D9Form;
end;

procedure TAGD3D9ShaderGraphicCore.DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush;const Matrix:TAG3DMatrix);
var
  m:TAG3DMatrix;
  p,pp,p0,p1,p2,p3:TAG2DVector;
  Data:array[0..3]of TAG3DVector;
  i:byte;
begin
Update3DVertexConfigAsIdenty;
SetUnicolorMod(brush.AGColor);
m:=Matrix*TAG3DMatrix.FromD3D9Form(Camera3D)*TAG3DMatrix.FromD3D9Form(GenProjection);

point0:=point0*m;
point1:=point1*m;

with point0 do
  p0:=TAG2DVector.Create(x,y);
with point1 do
  p1:=TAG2DVector.Create(x,y);
with ScrSize do
  p:=((p0-p1)*TAGScreenVector.Create(y,x)).Normalize*size;
with ScrSize do
  pp:=TAG2DVector.Create(p.x/y,p.y/x);
with p/ScrSize do
  p2:=TAG2DVector.Create(y,-x);

p1:=p1-pp;
p0:=p0+pp;

with p1+p2 do
  Data[0]:=TAG3DVector.Create(x,y,point1.z);
with p1-p2 do
  Data[1]:=TAG3DVector.Create(x,y,point1.z);
with p0+p2 do
  Data[2]:=TAG3DVector.Create(x,y,point0.z);
with p0-p2 do
  Data[3]:=TAG3DVector.Create(x,y,point0.z);

Dev.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,Data[0],SizeOf(Data[0]));
end;

procedure TAGD3D9ShaderGraphicCore.DrawBitmapBy3DCoords(Point:TAG3DVector;Mean:TAGSqueredPolygonPoitMeans;Size:TAG2DVector;
  bitmap:TAGBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);
var
  Data:array[0..3]of record
    x,y,z:single;
    Tx,Ty:Single;
  end;
  procedure CenterGen(Point:TAG3DVector;Size:TAG2DVector;const m:TAG3DMatrix);//need optimization
  var
    l,t0,t1,t2,t3:Double;
    mm:array[0..2]of Double;
    i:byte;
  begin
  l:=sqr(Size.Y)+sqr(Size.X);

  Data[1].X:=Point.X-Data[2].X;
  Data[1].Y:=Point.Y-Data[2].Y;
  Data[1].Z:=Point.Z-Data[2].Z;
  Data[2].X:=Point.X+Data[2].X;
  Data[2].Y:=Point.Y+Data[2].Y;
  Data[2].Z:=Point.Z+Data[2].Z;

  with ScrSize*Size do
    for i:=0 to 2 do
      mm[i]:=m.Data[i,0]+x/y*m.Data[i,1];
  {(a12 m0 + a02 m1)
  Sqrt[l/
  (a12^2 (m0^2 + m2^2) + a22^2 ( m0^2 + m1^2) +a02^2 (m1^2 + m2^2) + 2 a02 a12 m0 m1 + 2 a02 a22 m0 m2 - 2 a12 a22 m1 m2)]}
  t0:=2*(m.Data[0,2]*m.Data[1,2]*mm[0]*mm[1]+m.Data[0,2]*m.Data[2,2]*mm[0]*mm[2]+m.Data[1,2]*m.Data[2,2]*mm[1]*mm[2]);
  t1:=sqr(m.Data[0,2])*(sqr(mm[1])+sqr(mm[2]));
  t2:=sqr(m.Data[1,2])*(sqr(mm[0])+sqr(mm[2]));
  t3:=sqr(m.Data[2,2])*(sqr(mm[0])+sqr(mm[1]));
  Data[3].Z:=(m.Data[1,2]*mm[0]-m.Data[0,2]*mm[1])*Sqrt(l/(t1+t2+t3-t0));

  t0:=sqr(mm[0])+sqr(mm[1]);
  t1:=mm[1]*mm[2]*Data[3].Z;
  t2:=(t0+sqr(mm[2]))*sqr(Data[3].Z);
  Data[3].Y:=-(t1-mm[0]*sqrt(abs(l*t0-t2)))/t0;
  Data[3].X:=Sqrt(l-sqr(Data[3].Y)-sqr(Data[3].Z));

  Data[0].X:=Point.X+Data[3].X;
  Data[0].Y:=Point.Y+Data[3].Y;
  Data[0].Z:=Point.Z+Data[3].Z;
  Data[3].X:=Point.X-Data[3].X;
  Data[3].Y:=Point.Y-Data[3].Y;
  Data[3].Z:=Point.Z-Data[3].Z;

  with ScrSize*Size do
    for i:=0 to 2 do
      mm[i]:=m.Data[i,0]-x/y*m.Data[i,1];
  t0:=2*(m.Data[0,2]*m.Data[1,2]*mm[0]*mm[1]+m.Data[0,2]*m.Data[2,2]*mm[0]*mm[2]+m.Data[1,2]*m.Data[2,2]*mm[1]*mm[2]);
  t1:=sqr(m.Data[0,2])*(sqr(mm[1])+sqr(mm[2]));
  t2:=sqr(m.Data[1,2])*(sqr(mm[0])+sqr(mm[2]));
  t3:=sqr(m.Data[2,2])*(sqr(mm[0])+sqr(mm[1]));
  Data[2].Z:=-(m.Data[1,2]*mm[0]-m.Data[0,2]*mm[1])*Sqrt(l/(t1+t2+t3-t0));

  t0:=sqr(mm[0])+sqr(mm[1]);
  t1:=mm[1]*mm[2]*Data[2].Z;
  t2:=(t0+sqr(mm[2]))*sqr(Data[2].Z);
  Data[2].Y:=(-t1+mm[0]*sqrt(abs(l*t0-t2)))/t0;
  Data[2].X:=Sqrt(l-sqr(Data[2].Y)-sqr(Data[2].Z));

  Data[1].X:=Point.X-Data[2].X;
  Data[1].Y:=Point.Y-Data[2].Y;
  Data[1].Z:=Point.Z-Data[2].Z;
  Data[2].X:=Point.X+Data[2].X;
  Data[2].Y:=Point.Y+Data[2].Y;
  Data[2].Z:=Point.Z+Data[2].Z;
  end;
var
  m:TAG3DMatrix;
begin
Set3DUniTextureMod(bitmap.D3D9^,opacity/255);
Update3DVertexConfig(Matrix.ToD3D9Form);

m:=Matrix*TAG3DMatrix.FromD3D9Form(Camera3D)*TAG3DMatrix.FromD3D9Form(GenProjection);

CenterGen(Point,Size,m);
{brush.AGColor.R:=255;
brush.AGColor.G:=78;
brush.AGColor.B:=2;}
{DrawLine(Point,TAG3DVector.Create(Data[0].X,Data[0].Y,Data[0].Z),20,CreateBrush(RedColor),Matrix);
DrawLine(Point,TAG3DVector.Create(Data[1].X,Data[1].Y,Data[1].Z),20,CreateBrush(GreenColor),Matrix);
DrawLine(Point,TAG3DVector.Create(Data[2].X,Data[2].Y,Data[2].Z),20,CreateBrush(BlueColor),Matrix);
DrawLine(Point,TAG3DVector.Create(Data[3].X,Data[3].Y,Data[3].Z),20,CreateBrush(WiteColor),Matrix);
Update3DVertexConfig(Matrix.ToD3D9Form);
Set3DUniTextureMod(bitmap.D3D9^,opacity/255);}

with Data[0] do
begin
  Tx:=0;
  Ty:=0;
end;
with Data[1] do
begin
  Tx:=1;
  Ty:=0;
end;
with Data[2] do
begin
  Tx:=0;
  Ty:=1;
end;
with Data[3] do
begin
  Tx:=1;
  Ty:=1;
end;

case Mean of
AGCenter:CenterGen(Point,Size,m);
AGRU:{TODO -oArtem: TAGD3D9ShaderGraphicCore.AGRU};
AGRD:{TODO -oArtem: TAGD3D9ShaderGraphicCore.AGRD};
AGLU:{TODO -oArtem: TAGD3D9ShaderGraphicCore.AGLU};
AGLD:{TODO -oArtem: TAGD3D9ShaderGraphicCore.AGLD};
end;

with Dev do
begin
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MINFILTER,D3DTEXF_NONE);
    SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);
  end;
  DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,Data[0],SizeOf(Data[0]));
  if not Smooth then
  begin
    SetSamplerState(0,D3DSAMP_MAGFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MINFILTER,DEFTEXF);
    SetSamplerState(0,D3DSAMP_MIPFILTER,DEFTEXF);
  end;
end;
end;

procedure TAGD3D9ShaderGraphicCore.DrawMesh(const Mesh:TAGMesh;const Matrix:TAG3DMatrix;UseLight:boolean=True);
var
  i:integer;
  FVFDecl:TFVFDeclaration;
  IFVFDecl:IDirect3DVertexDeclaration9;
  temp:Single;
begin
Mesh.D3D9.Mesh.GetDeclaration(FVFDecl);
Dev.CreateVertexDeclaration(addr(FVFDecl),IFVFDecl);
Dev.SetVertexDeclaration(IFVFDecl);
if UseLight then
  UpdateLightingConf();
Set3DLightingEnable(UseLight);
Set3DOpacity(1);

Update3DVertexConfig(Matrix.ToD3D9Form);

for i:=0 to Length(Mesh.D3D9.Mat)-1 do
begin
  SetMaterial(Mesh.D3D9.Mat[i]);
  Mesh.D3D9.Mesh.DrawSubset(i);
end;
end;

//Shaders

function TAGD3D9ShaderGraphicCore.BuildShader(&Type:TAGShaderType;Source:string):TAGShader;
begin
{ToDo -oArtem when AGPascal will be maided}
EAGUnSupportedException.Create('Error unsupported TAGD3D9ShaderGraphicCore.BuildShader');
end;

procedure TAGD3D9ShaderGraphicCore.FreeShader(Shader:TAGShader);
begin
Shader.Free;
end;

initialization
D3D9:=Direct3DCreate9(D3D9b_SDK_VERSION);
{$ENDIF}
end.
