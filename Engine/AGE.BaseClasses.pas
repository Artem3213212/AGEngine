unit AGE.BaseClasses;

interface

uses
  System.SysUtils,System.Generics.Collections,
    AG.Graphic,AG.Types,AG.Resourcer,AG.Levels,Ag.Windows;

type
  TAGE3DObject=class abstract
    public
      function RadiusForCamera:Single;virtual;abstract;
      function PosForCamera:TAG3DVector;virtual;abstract;
      function FrontForCamera:TAG3DVector;virtual;abstract;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);virtual;abstract;
      destructor Destroy(Core:TAGGraphicCore);virtual;abstract;
  end;

  TAGEGlobalMesh=class abstract(TAGE3DObject)
    private class var
      GlobalMeshs:TDictionary<TClass,TAGMesh>;
    protected type
      TGetMeshFunc=reference to function(Core:TAGGraphicCore):TAGMesh;
    protected var
      Mesh:TAGMesh;
    public
      constructor Create(Core:TAGGraphicCore;Textures:TArray<TAGTex>;GetMesh:TGetMeshFunc);
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
  end;

  TAGEGlobalXFile=class abstract(TAGE3DObject)
    private class var
      GlobalMeshs:TDictionary<String,TAGMesh>;
    protected var
      Mesh:TAGMesh;
    public
      constructor Create(Core:TAGGraphicCore;Textures:TArray<TAGTex>;&File:String);
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);overload;override;
  end;

  TAGEXFileObject=class (TAGE3DObject)
    protected
      Mesh:TAGMesh;
    public
      constructor Create(Core:TAGGraphicCore;Name,Floder:String);overload;
      constructor Create(Core:TAGGraphicCore;Name:String);overload;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
      destructor Destroy(Core:TAGGraphicCore);override;
  end;

  TAGEController=class abstract
    protected class var
      GlobalRegister:TList<TAGEController>;
      constructor FCreate();
    public
      function OnKey(key:byte;Info:TAGKeyInfo):boolean;virtual;abstract;
      class function GlobalKey(key:byte;Info:TAGKeyInfo):boolean;static;
      class procedure Clear();static;
      constructor Create();
      destructor Destroy();override;
  end;

  TAGE3DCamera=class abstract (TAGEController)
    private class var
      GlobalCameraController:TAGE3DCamera;
    strict private
      const
        CameraCoreLableName='WhatCameraNow';
      var
        FMyCore:TAGGraphicCore;
      function GetMyCore:TAGGraphicCore;
      procedure MakeCoreMine(Core:TAGGraphicCore);
    strict protected
      property MyCore:TAGGraphicCore read GetMyCore write MakeCoreMine;
    public
      procedure SetToObject(Obj:TAGE3DObject;NoRot:boolean=True);overload;virtual;abstract;
      procedure SetToObject(Obj:TAGE3DObject;CameraPos:TAG3DVector);overload;virtual;abstract;
      procedure SetToObject(Obj,CameraPos:TAG3DVector);overload;virtual;abstract;
      procedure InitGraphicCore(Core:TAGGraphicCore);virtual;
      function OnKey(key:byte;Info:TAGKeyInfo):boolean;override;
      procedure Select(Core:TAGGraphicCore;OverrideCameraController:boolean=True);virtual;
      constructor Create();
  end;

  TAGESTDMatrix3DCamera=class (TAGE3DCamera)
    strict protected var
      Matrix:TAG3DMatrix;
    public
      procedure SetToObject(Obj:TAGE3DObject;NoRot:boolean=True);override;
      procedure SetToObject(Obj:TAGE3DObject;CameraPos:TAG3DVector);override;
      procedure SetToObject(Obj,CameraPos:TAG3DVector);override;
      procedure InitGraphicCore(Core:TAGGraphicCore);override;
      constructor Create();
  end;

implementation

{TAGEGlobalMesh}

constructor TAGEGlobalMesh.Create(Core:TAGGraphicCore;Textures:TArray<TAGTex>;GetMesh:TGetMeshFunc);
var
  Mes:TAGMesh;
begin
if not GlobalMeshs.TryGetValue(ClassType,Mes) then
begin
  Mes:=GetMesh(Core);
  GlobalMeshs.Add(ClassType,Mes);
end;
if Length(Textures)<>0 then
  Mesh:=Core.CreateReTexturedMesh(Mes,Textures,False);
end;

procedure TAGEGlobalMesh.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
Core.DrawMesh(Mesh,Matrix);
end;

{TAGEGlobalXFile}

constructor TAGEGlobalXFile.Create(Core:TAGGraphicCore;Textures:TArray<TAGTex>;&File:String);
var
  Mes:TAGMesh;
begin
if not GlobalMeshs.TryGetValue(&File,Mes) then
begin
  Mes:=Core.LoadXFileWithoutTextures(&File);
  GlobalMeshs.Add(&File,Mes);
end;
if Length(Textures)<>0 then
  Mesh:=Core.CreateReTexturedMesh(Mes,Textures,False);
end;

procedure TAGEGlobalXFile.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
Core.DrawMesh(Mesh,Matrix);
end;

{TXFileObject}

constructor TAGEXFileObject.Create(Core:TAGGraphicCore;Name,Floder:String);
begin
Mesh:=Core.LoadXFile(Name,Floder,[]);
end;

constructor TAGEXFileObject.Create(Core:TAGGraphicCore;Name:String);
begin
Mesh:=Core.LoadXFile(Name,[]);
end;

procedure TAGEXFileObject.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
Core.DrawMesh(Mesh,Matrix);
end;


destructor TAGEXFileObject.Destroy(Core:TAGGraphicCore);
begin
Core.ReleaseMesh(Mesh);
end;

{TAGEController}

constructor TAGEController.FCreate();
begin
Inherited;
end;

class function TAGEController.GlobalKey(key:byte;Info:TAGKeyInfo):boolean;
var
  i:TAGEController;
begin
if Assigned(TAGE3DCamera.GlobalCameraController)then
begin
  Result:=TAGE3DCamera.GlobalCameraController.OnKey(key,Info);
  if Result then
    exit;
end;
for i in GlobalRegister do
begin
  Result:=i.OnKey(key,Info);
  if Result then
    break;
end;
end;

class procedure TAGEController.Clear();
var
  i:TAGEController;
begin
for i in GlobalRegister do
  i.Destroy;
GlobalRegister.Clear;
end;

constructor TAGEController.Create();
begin
GlobalRegister.Add(Self);
end;

destructor TAGEController.Destroy();
begin
GlobalRegister.Remove(Self);
end;

{TAGE3DCamera}

function TAGE3DCamera.GetMyCore:TAGGraphicCore;
begin
Result:=nil;
if Assigned(FMyCore) then
  if FMyCore.Lable[CameraCoreLableName]=self.GetHashCode then
    Result:=FMyCore;
end;

procedure TAGE3DCamera.MakeCoreMine(Core:TAGGraphicCore);
var
  LastCore:TAGGraphicCore;
begin
LastCore:=GetMyCore;
if Assigned(LastCore) then
  LastCore.Lable[CameraCoreLableName]:=0;
FMyCore:=Core;
Core.Lable[CameraCoreLableName]:=self.GetHashCode;
end;

procedure TAGE3DCamera.InitGraphicCore(Core:TAGGraphicCore);
begin
MyCore:=Core;
end;

function TAGE3DCamera.OnKey(key:byte;Info:TAGKeyInfo):boolean;
begin
Result:=False;
end;

procedure TAGE3DCamera.Select(Core:TAGGraphicCore;OverrideCameraController:boolean=True);
begin
if OverrideCameraController then
  GlobalCameraController:=Self;
InitGraphicCore(Core);
end;

constructor TAGE3DCamera.Create();
begin
inherited FCreate;
end;

{TAGESTDMatrix3DCamera}

procedure TAGESTDMatrix3DCamera.SetToObject(Obj:TAGE3DObject;NoRot:boolean=True);
begin
if NoRot then

else

end;

procedure TAGESTDMatrix3DCamera.SetToObject(Obj:TAGE3DObject;CameraPos:TAG3DVector);
begin

end;

procedure TAGESTDMatrix3DCamera.SetToObject(Obj,CameraPos:TAG3DVector);
begin
//Matrix:=TAG3DMatrix.MkCamToObject();
end;

procedure TAGESTDMatrix3DCamera.InitGraphicCore(Core:TAGGraphicCore);
begin
inherited;
Core.SetCameraByMatrix(Matrix);
end;

constructor TAGESTDMatrix3DCamera.Create();
begin
end;

initialization
TAGEGlobalMesh.GlobalMeshs:=TDictionary<TClass,TAGMesh>.Create;
TAGEGlobalXFile.GlobalMeshs:=TDictionary<String,TAGMesh>.Create;
TAGEController.GlobalRegister:=TList<TAGEController>.Create;
end.
