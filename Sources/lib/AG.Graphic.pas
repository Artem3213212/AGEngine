unit AG.Graphic;

interface

{$i main.conf}

{$IFDEF Logs}{$ENDIF}
{$IFDEF Vulkan}{$ENDIF}
{$IFDEF OpenGl}{$ENDIF}
{$IFDEF D3D9}{$ENDIF}
{$IFDEF VampyreIL}{$ENDIF}

uses
  AG.Resourcer,AG.Shaders,AG.Types,AG.Screen,
  //{$IFDEF Logs}AG.Logs,{$ENDIF}
  //{$IFDEF assimp}FMX.DAE.Importer,FMX.DAE.Model,FMX.DAE.Schema,FMX.Import,{$ENDIF}
  System.SysUtils,System.IOUtils,System.Generics.Collections,System.Math.Vectors;

type
  EAGGraphicCoreException=Exception;
  TAGGraphicCore=class;
  TAGOnpantProcedure=reference to procedure(Core:TAGGraphicCore);
  TAGOnCreateProcedure=reference to procedure(Core:TAGGraphicCore);
  TAGOnDestoyProcedure=reference to procedure(Core:TAGGraphicCore);

  TAGGraphicCore=class abstract
    strict private
      FLabels:TDictionary<String,Variant>;
      function GetLable(Name:string):Variant;
      procedure SetLable(Name:string;Data:Variant);
    protected
      procedure FontsInit();virtual;
      procedure ShadersInit();virtual;

      procedure SetBackColor(color:TAGColor);virtual;abstract;
      function GetBackColor:TAGColor;virtual;abstract;
      //3D
      procedure SetMinDepth(d:Single);virtual;abstract;
      function GetMinDepth:Single;virtual;abstract;

      procedure SetMaxDepth(d:Single);virtual;abstract;
      function GetMaxDepth:Single;virtual;abstract;

      procedure SetFOV(FOV:Single);virtual;abstract;
      function GetFOV:Single;virtual;abstract;
      //Shaders
      function GetShader(Usage:TAGShaderUsage):TAGShader;virtual;abstract;
      procedure SetShader(Usage:TAGShaderUsage;Shader:TAGShader);virtual;abstract;
      //Nil Data mean default shader
      //if(&Type=CPixelShader)and(PixelShaderType=CTextureShader) num meaning texture num;-1 meaning default value(using if not set)
      //if you use -1 and Nil Data, you use default shader as default value, else(0 or highter and Nil Data)you use default value as this shader
      //if you use -2 and Nil Data, you reset all Textures shaders(but not default Shader)
    public
      parrent:TAGGraphicCore;
      hwnd:nativeint;
      drawer:TAGOnpantProcedure;
      initer:TAGOnCreateProcedure;
      property Lable[Name:string]:Variant read GetLable write SetLable;
      //destructor Destroy;virtual;abstract;
      property BackColor:TAGColor read GetBackColor write SetBackColor;

      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);virtual;abstract;//fscr-только для d3d9
      procedure OnPaint();virtual;abstract;
      procedure Resize(W,H:Word);virtual;abstract;
      //2D
      procedure Init2D();virtual;abstract;
      function CreateBrush(Color:TAGColor):TAGBrush;overload;virtual;abstract;
      function CreateBitMap(p:TAGResourceImage):TAGBitMap;virtual;abstract;
      function CreateBitMapFromFile(Name:String):TAGBitMap;virtual;abstract;
      function GetBtmForDraw:TAGBitMap;virtual;abstract;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;virtual;abstract;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);virtual;abstract;
      procedure ReleaseBrush(b:TAGBrush);virtual;abstract;
      procedure ReleaseBitMap(b:TAGBitMap);virtual;abstract;
      procedure DrawPoint(point:TAGScreenVector;size:word;brush:TAGBrush);overload;virtual;
      procedure DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);overload;virtual;
      procedure DrawRectangle(rect:TAGScreenCoord;size:word;brush:TAGBrush);overload;virtual;
      procedure DrawRectangle(rect:TAGCoord;size:word;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);overload;virtual;
      procedure DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);overload;virtual;
      procedure DrawLine(point0,point1:TAGScreenVector;size:word;brush:TAGBrush);overload;virtual;
      procedure DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);overload;virtual;
      procedure DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);overload;virtual;
      procedure DrawText(text:string;position:TAGCoord;size:word;font:TAGFont;brush:TAGBrush);overload;virtual;abstract;
      procedure DrawBitmap(coord:TAGScreenCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);overload;virtual;
      procedure DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);overload;virtual;abstract;
      procedure FillRectangle(rect:TAGScreenCoord;brush:TAGBrush);overload;virtual;
      procedure FillRectangle(rect:TAGCoord;brush:TAGBrush);overload;virtual;abstract;
      procedure FillElips(point,radaii:TAGscreenVector;brush:TAGBrush);overload;virtual;
      procedure FillElips(point,radaii:TAG2DVector;brush:TAGBrush);overload;virtual;abstract;
      procedure FillElips(point,radaii:TAG2DVector;brush:TAGBrush;const Matrix:TAG2DMatrix);overload;virtual;
      //3D
      property MinDepth:Single read GetMinDepth write SetMinDepth;
      property MaxDepth:Single read GetMaxDepth write SetMaxDepth;
      property FOV:Single read GetFOV write SetFOV;

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
        bitmap:TAGBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
      procedure DrawBitmapBy3DCoords(Point:TAG3DVector;Mean:TAGSqueredPolygonPoitMeans;Size:TAG2DVector;
        bitmap:TAGBitMap;const Matrix:TAG3DMatrix;Opacity:byte=255;Smooth:boolean=False);virtual;abstract;
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
      function IsFullRender:boolean;
      {$IFDEF Easter_Egg}
        procedure DrawGreatLoadScreen();virtual;abstract;
      {$ENDIF}
  end;

  TAG3DGraphicCore=class(TAGGraphicCore)
  end;

implementation

function TAGGraphicCore.GetLable(Name:string):Variant;
begin
  if Assigned(FLabels) then
    FLabels.TryGetValue(Name,Result)
  else
    Result:=Default(Variant);
end;

procedure TAGGraphicCore.SetLable(Name:string;Data:Variant);
begin
  if not Assigned(FLabels) then
    FLabels:=TDictionary<String,Variant>.Create();
  FLabels.AddOrSetValue(Name,Data);
end;

procedure TAGGraphicCore.FontsInit();
begin
  LoadFont('Lucida Console','en-en',{$IFDEF 4k}30{$ELSE}{$IFDEF 8k}60{$ELSE}24{$ENDIF}{$ENDIF},AGFont_SystemFont);
end;

procedure TAGGraphicCore.DrawPoint(point:TAGScreenVector;size:word;brush:TAGBrush);
begin
  DrawPoint(TAG2DVector(point),size,brush);
end;

procedure TAGGraphicCore.DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);
begin
  DrawPoint(point*Matrix,size,brush);
end;

procedure TAGGraphicCore.DrawRectangle(rect:TAGScreenCoord;size:word;brush:TAGBrush);
begin
  DrawRectangle(TAGCoord(rect),size,brush);
end;

procedure TAGGraphicCore.DrawElips(point,radaii:TAGScreenVector;size:word;brush:TAGBrush);
begin
  DrawElips(TAG2DVector(point),radaii,size,brush);
end;

procedure TAGGraphicCore.DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);
begin
  DrawElips(point*Matrix,radaii,size,brush);
end;

procedure TAGGraphicCore.DrawLine(point0,point1:TAGScreenVector;size:word;brush:TAGBrush);
begin
  DrawLine(TAG2DVector(point0),TAG2DVector(point1),size,brush);
end;

procedure TAGGraphicCore.DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush;const Matrix:TAG2DMatrix);
begin
  DrawLine(point0*Matrix,point1*Matrix,size,brush);
end;

procedure TAGGraphicCore.DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);
begin
  DrawText(text,TAGCoord(position),size,font,brush);
end;

procedure TAGGraphicCore.DrawBitmap(coord:TAGScreenCoord;bitmap:TAGBitMap;Opacity:byte=255;Smooth:boolean=False);
begin
  DrawBitmap(TAGCoord(coord),bitmap,opacity,Smooth);
end;

procedure TAGGraphicCore.FillRectangle(rect:TAGScreenCoord;brush:TAGBrush);
begin
  FillRectangle(TAGCoord(rect),brush);
end;

procedure TAGGraphicCore.FillElips(point,radaii:TAGScreenVector;brush:TAGBrush);
begin
  FillElips(TAG2DVector(point),TAG2DVector(radaii),brush);
end;

procedure TAGGraphicCore.FillElips(point,radaii:TAG2DVector;brush:TAGBrush;const Matrix:TAG2DMatrix);
begin
  FillElips(point*Matrix,radaii*Matrix,brush);
end;

//3D

procedure TAGGraphicCore.ShadersInit();
begin
  Shaders[TAGShaderUsage.Create(CAGVertexShader)]:=nil;
  Shaders[TAGShaderUsage.Create(-1)]:=nil;
  Shaders[TAGShaderUsage.Create(-2)]:=nil;
  Shaders[TAGShaderUsage.Create(CAGPreProcessShader)]:=nil;
  Shaders[TAGShaderUsage.Create(CAGPostProcessShader)]:=nil;
  Shaders[TAGShaderUsage.Create(CAGGeometryShader)]:=nil;
end;

function TAGGraphicCore.LoadXFile(Name:String;Texture:TArray<TAGTex>;UseXFileLightSettings:boolean=False):TAGMesh;
begin
Result:=LoadXFile(Name,TPath.GetDirectoryName(Name),Texture,UseXFileLightSettings);
end;

procedure TAGGraphicCore.SetCameraToObject(Cam,Obj:TAG3DVector);
begin
SetCameraByMatrix(TAG3DMatrix.MkCamToObject(Cam,Obj));
end;

procedure TAGGraphicCore.SetCameraToObject(Cam,Obj,UpDirection:TAG3DVector);
begin
SetCameraByMatrix(TAG3DMatrix.MkCamToObject(Cam,Obj,UpDirection));
end;

procedure TAGGraphicCore.DrawLine(point0,point1:TAG3DVector;size:Single;brush:TAGBrush);
begin
DrawLine(point0,point1,size,brush,TAG3DMatrix.MkIdent);
end;

procedure TAGGraphicCore.DrawMesh(const Mesh:TAGMesh;UseLight:boolean=True);
begin
  DrawMesh(Mesh,TAG3DMatrix.MkIdent(),UseLight);
end;

function TAGGraphicCore.IsFullRender:boolean;
begin
  Result:=hwnd<>0;
end;

function TAGGraphicCore.CompleteResourseImages(res:PAGResource):TAGEngineResource;
var
  i:integer;
begin
Result.source:=res;
SetLength(Result.img,Length(res.r^.img));
for i:=0 to Length(res.r^.img)-1 do
  Result.img[i]:=CreateBitMap(res.r^.img[i]);
end;

procedure TAGGraphicCore.ReleaseResourseImages(var res:TAGEngineResource);
var
  i:TAGBitMap;
begin
for i in res.img do
  ReleaseBitMap(i);
SetLength(res.img,0);
end;

procedure TAGGraphicCore.CompleteResourseImages(var res:TAGEngineResource);
var
  i:integer;
begin
SetLength(res.img,Length(res.source.r^.img));
for i:=0 to Length(res.source.r^.img)-1 do
begin
  res.img[i]:=CreateBitMap(res.source.r.img[i]);
end;
end;

end.
