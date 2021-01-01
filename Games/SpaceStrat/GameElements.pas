unit GameElements;

interface

uses
  System.IniFiles,System.SysUtils,System.Generics.Collections,System.IOUtils,System.Math.Vectors,System.RTTI,
    AG.Graphic,AG.Types,AG.Resourcer,AG.Levels,AGE.BaseClasses,AGE.Time,AG.Utils;

type
  TRotationParams=record
    Rotation:TAG3DVector;
    Incline:TAG3DMatrix;
    class var
      RotCorrection:TAG3DMatrix;
    class operator Add(a,b:TRotationParams):TRotationParams;
    constructor Load(Conf:TCustomIniFile;ConfigSect:String);
    procedure DrawWithRot(Core:TAGGraphicCore;Mesh:TAGMesh;Matrix:TAG3DMatrix;UseLight:boolean=True);inline;
  end;

  TSphere=class abstract(TAGEGlobalXFile)
    protected var
      Radius:Single;
      constructor FCreate(Core:TAGGraphicCore;Textures:TArray<TAGTex>;&File:String);
    public
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);virtual;
  end;

  TCubeMapSphere=class (TSphere)
    strict private const
      numtrans:array[0..5]of byte=(5,6,1,3,2,4);
    public
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);override;
  end;

  TSphereWithRot=class (TSphere)
    strict protected
      RotParam:TRotationParams;
    public
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);virtual;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
  end;

  TCubeMapSphereWithRot=class (TSphereWithRot)
    strict private const
      numtrans:array[0..5]of byte=(5,6,1,3,2,4);
    public
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);override;
  end;

  TFlatObject=class abstract(TAGEGlobalXFile)
    protected var
      Scale:Single;
    public
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);virtual;
  end;

  TSpheredObject=class abstract(TAGE3DObject)
    protected type
      TSpheredObjectLayer=TSphereWithRot;
      TSpheredCubeMapObjectLayer=TCubeMapSphereWithRot;
      TLayerRef=class of TSphereWithRot;
    protected
      Layers:TList<TSphereWithRot>;
    public
      constructor Create(Core:TAGGraphicCore;Config:TCustomIniFile;TexFloder:String;LayerObj:TLayerRef);
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
      function RadiusForCamera:Single;override;
      {function PosForCamera:TAG3DVector;virtual;abstract;
      function FrontForCamera:TAG3DVector;virtual;abstract;}
  end;

  TCirculationInfo=record
    Start,Rot:TAG3DVector;
    Radius:Single;
    //constructor Load(Conf:TCustomIniFile;ConfigSect:String);
    //procedure DrawWithCirc(Core:TAGGraphicCore;Obj:TAGE3DObject;Matrix:TAG3DMatrix);//inline;
  end;

  TSystemCenterControl=class abstract
    private type
      TSystemCenterControlClass=class of TSystemCenterControl;
    private const
      MaxBodys=5;
    private class var
      GlobalIndexedRegister:array[1..MaxBodys]of TDictionary<String,TSystemCenterControlClass>;
    public
      class function GetBodysCount:integer;virtual;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix;Num:integer;Obj:TAGE3DObject);virtual;abstract;
      constructor Create(Conf:TCustomIniFile;size:integer);overload;virtual;abstract;
      class function Create(Conf:TCustomIniFile;size:integer;Name:String):TSystemCenterControl;overload;static;
      class function CreateRandom(Conf:TCustomIniFile;size:integer;out Name:String):TSystemCenterControl;overload;static;
  end;

  TSystemCenterControlNone=class (TSystemCenterControl)
    public
      class function GetBodysCount:integer;override;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix;Num:integer;Obj:TAGE3DObject);override;
      constructor Create(Conf:TCustomIniFile;size:integer);override;
  end;

  TStarSystem = class (TAGE3DObject)
    strict protected type
      TPlanetSystem = class (TAGE3DObject)
        strict protected type
          TPlanet=class(TSpheredObject)
            protected type
              TPlanetLayer=TSpheredObject.TSpheredCubeMapObjectLayer;
              TPlanetMesh=class(TAGEXFileObject)
                strict protected
                  RotParam:TRotationParams;
                  Scale:Single;
                public
                  constructor Create(Core:TAGGraphicCore;Config:TCustomIniFile;ConfigSect,Floder:String;RP:TRotationParams);
                  procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
              end;
              TPlanetRing=class abstract(TFlatObject)
                protected var
                  RotParam:TRotationParams;
                  Radius:Single;
                public
                  constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);
                  procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
              end;
            protected
              Meshs:TList<TPlanetMesh>;
              Rings:TList<TPlanetRing>;
            public
              constructor Create(Core:TAGGraphicCore;ID:Cardinal);
              procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
          end;
        protected
          Planets:TList<TPlanet>;
          //Satellites:TList<TSatellite>;
        public
          //constructor Create(Core:TAGGraphicCore;ConfigSect:string);
          //procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
      end;

      TStar=class(TSpheredObject)
        protected type
          TStarLayer=class(TSpheredObjectLayer)
            public
              procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
          end;
        public
          constructor Create(Core:TAGGraphicCore;ID:Cardinal);
          procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
      end;
    strict protected
      PlanetSystems:TList<TPair<TPlanetSystem,TCirculationInfo>>;
      FStars:TList<TStar>;
      CenterControl:TSystemCenterControl;
      function GetStar(i:integer):TAGE3DObject;
    public
      property Stars[i:integer]:TAGE3DObject read GetStar;
      constructor Create(Core:TAGGraphicCore;Conf:TCustomIniFile);
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);override;
  end;

  TSky=class(TAGEXFileObject)
    protected var
      Correction:TAG3DMatrix;
    public
      constructor Create(Core:TAGGraphicCore);virtual;
      procedure Draw(Core:TAGGraphicCore);overload;
      procedure Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);overload;override;
  end;

var
  RotationTime:TAGETime;

implementation

{TRotationParams}

class operator TRotationParams.Add(a,b:TRotationParams):TRotationParams;
begin
Result.Rotation:=a.Rotation+b.Rotation;
Result.Incline:=a.Incline*b.Incline;
end;

constructor TRotationParams.Load(Conf:TCustomIniFile;ConfigSect:String);
begin
with conf do
begin
  Rotation:=TAG3DVector.Create(ReadFloat(ConfigSect,'RotationZ',0),
                              -ReadFloat(ConfigSect,'RotationY',0),
                               ReadFloat(ConfigSect,'RotationX',0))/20000;
  Incline:=TAG3DMatrix.MkRot(TAG3DVector.Create(ReadFloat(ConfigSect,'InclineX',0),
                                              ReadFloat(ConfigSect,'InclineY',0),
                                              ReadFloat(ConfigSect,'InclineZ',0)));
end;
end;

procedure TRotationParams.DrawWithRot(Core:TAGGraphicCore;Mesh:TAGMesh;Matrix:TAG3DMatrix;UseLight:boolean=True);
begin
Core.DrawMesh(Mesh,RotCorrection*TAG3DMatrix.MkRot(RotationTime.Time*(Rotation))*Incline*Matrix,UseLight);
end;

{TSphere}

constructor TSphere.FCreate(Core:TAGGraphicCore;Textures:TArray<TAGTex>;&File:String);
begin
Self:=inherited Create(Core,Textures,&File);
end;

constructor TSphere.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);
var
  tx:TAGTex;
begin
with Conf do
begin
  tx:=Core.CreateTexFromFile(TPath.Combine(TexFloder,ReadString(ConfigSect,'TexFile','.dds')));
  Core.ResetLightSettings(tx,witecolor,ReadFloat(ConfigSect,'Diffuse',1),
                                       ReadFloat(ConfigSect,'Ambient',0.2),
                                       ReadFloat(ConfigSect,'Specular',0.2),
                                       ReadFloat(ConfigSect,'Emissive',0));
  Self:=inherited Create(Core,[tx],'..\Data\Sphere002.x');
  Core.ReleaseTex(tx);
  Radius:=ReadFloat(ConfigSect,'Radius',1);
end;
end;

{TCubeMapSphere}

constructor TCubeMapSphere.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);
var
  i:integer;
  tx:TArray<TAGTex>;
begin
with Conf do
begin
  Radius:=ReadFloat(ConfigSect,'Radius',1);
  setlength(tx,6);
  for i:=0 to 5 do
  begin
    tx[i]:=Core.CreateTexFromFile(TPath.Combine(TexFloder,ReadString(ConfigSect,'TexFile','*.dds')).Replace('*',IntToStr(numtrans[i])));
    Core.ResetLightSettings(tx[i],witecolor,ReadFloat(ConfigSect,'Diffuse',1),
                                            ReadFloat(ConfigSect,'Ambient',0.2),
                                            ReadFloat(ConfigSect,'Specular',0.2),
                                            ReadFloat(ConfigSect,'Emissive',0));
  end;
end;
inherited FCreate(Core,tx,'..\Data\Sphere001.x');
for i:=0 to 5 do
  Core.ReleaseTex(tx[i]);
SetLength(tx,0);
end;

{TSphereWithRot}

constructor TSphereWithRot.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);
begin
Self:=inherited Create(Core,Conf,ConfigSect,TexFloder);
RotParam:=TRotationParams.Load(Conf,ConfigSect)+RP;
end;

procedure TSphereWithRot.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
RotParam.DrawWithRot(Core,Mesh,TAG3DMatrix.MkScale(Radius)*Matrix);
end;

{TCubeMapSphereWithRot}

constructor TCubeMapSphereWithRot.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);
var
  i:integer;
  tx:TArray<TAGTex>;
begin
with Conf do
begin
  Radius:=ReadFloat(ConfigSect,'Radius',1);
  setlength(tx,6);
  for i:=0 to 5 do
  begin
    tx[i]:=Core.CreateTexFromFile(TPath.Combine(TexFloder,ReadString(ConfigSect,'TexFile','*.dds')).Replace('*',IntToStr(numtrans[i])));
    Core.ResetLightSettings(tx[i],witecolor,ReadFloat(ConfigSect,'Diffuse',1),
                                            ReadFloat(ConfigSect,'Ambient',0.2),
                                            ReadFloat(ConfigSect,'Specular',0.2),
                                            ReadFloat(ConfigSect,'Emissive',0));
  end;
end;
inherited FCreate(Core,tx,'..\Data\Sphere001.x');
for i:=0 to 5 do
  Core.ReleaseTex(tx[i]);
SetLength(tx,0);
RotParam:=TRotationParams.Load(Conf,ConfigSect)+RP;
end;

{TFlatObject}

constructor TFlatObject.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String);
var
  tx:TAGTex;
begin
with Conf do
begin
  tx:=Core.CreateTexFromFile(TPath.Combine(TexFloder,ReadString(ConfigSect,'TexFile','.dds')));
  Core.ResetLightSettings(tx,witecolor,ReadFloat(ConfigSect,'Diffuse',1),
                                       ReadFloat(ConfigSect,'Ambient',0.2),
                                       ReadFloat(ConfigSect,'Specular',0.2),
                                       ReadFloat(ConfigSect,'Emissive',0));
  Scale:=ReadFloat(ConfigSect,'Scale',1);
end;
Self:=inherited Create(Core,[tx],'..\Data\ring_02.X');
Core.ReleaseTex(tx);
end;

{TSpheredObject}

constructor TSpheredObject.Create(Core:TAGGraphicCore;Config:TCustomIniFile;TexFloder:String;LayerObj:TLayerRef);
var
  i:integer;
  RP:TRotationParams;
begin
inherited Create;
//Config.ReadSubSections();
RP:=TRotationParams.Load(Config,'Main');
Layers:=TList<TSphereWithRot>.Create();
i:=1;
while Config.SectionExists('Layer'+IntToStr(i))do
begin
  Layers.Add(LayerObj.Create(Core,Config,'Layer'+IntToStr(i),TexFloder,RP));
  inc(i);
end;
end;

procedure TSpheredObject.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
var
  i:TSphere;
begin
for i in Layers do
  i.Draw(Core,Matrix);
end;

function TSpheredObject.RadiusForCamera:Single;
var
  i:TSpheredObjectLayer;
begin
  for i in Layers do
    if Result<i.Radius then
      Result:=i.Radius;

  Result:=Result*167;
end;

{TSystemCenterControl}

class function TSystemCenterControl.GetBodysCount:integer;
begin
  Result:=1;
end;

class function TSystemCenterControl.Create(Conf:TCustomIniFile;size:integer;Name:String):TSystemCenterControl;
var
  meta:TClass;
begin
  Result:=GlobalIndexedRegister[size][Name].Create(Conf,size);
end;

class function TSystemCenterControl.CreateRandom(Conf:TCustomIniFile;size:integer;out Name:String):TSystemCenterControl;
var
  RttiContext:TRttiContext;
  &Type:TRttiType;
  Types:TList<TPair<String,TSystemCenterControlClass>>;
  meta:TClass;
begin
  RttiContext:=TRttiContext.Create;
  Types:=TList<TPair<String,TSystemCenterControlClass>>.Create;
  for &Type in RttiContext.GetTypes do
    if &Type.IsInstance then
    begin
      if (meta.InheritsFrom(TSystemCenterControl))and(TSystemCenterControlClass(meta).GetBodysCount=size)then
        Types.Add(TPair<String,TSystemCenterControlClass>.Create(&Type.Name,TSystemCenterControlClass(meta)));
    end;
  with Types[Random(Types.Count-1)]do
  begin
    Name:=Key;
    Result:=Value.Create(Conf,size);
  end;
  FreeAndNil(Types);
  FreeAndNil(RttiContext);
end;

{TSystemCenterControlNone}

class function TSystemCenterControlNone.GetBodysCount:integer;
begin
Result:=1;
end;

procedure TSystemCenterControlNone.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix;Num:integer;Obj:TAGE3DObject);
begin
  Obj.Draw(Core,Matrix);
end;

constructor TSystemCenterControlNone.Create(Conf:TCustomIniFile;size:integer);
begin
end;

{TStarSystem}

{TStarSystem.TPlanetSystem}

{TStarSystem.TPlanetSystem.TPlanet}

{TStarSystem.TPlanetSystem.TPlanet.TPlanetMesh}

constructor TStarSystem.TPlanetSystem.TPlanet.TPlanetMesh.Create(Core:TAGGraphicCore;Config:TCustomIniFile;ConfigSect,Floder:String;RP:TRotationParams);
begin
with Config do
  if SectionExists(ConfigSect) then
  begin
    inherited Create(Core,Floder+TPath.DirectorySeparatorChar+ReadString(ConfigSect,'XFile','.x'));
    RotParam:=TRotationParams.Load(Config,ConfigSect);
    Scale:=ReadFloat(ConfigSect,'Scale',1);
  end;
end;

procedure TStarSystem.TPlanetSystem.TPlanet.TPlanetMesh.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
RotParam.DrawWithRot(Core,Mesh,TAG3DMatrix.MkScale(Scale)*Matrix);
end;

{TStarSystem.TPlanetSystem.TPlanet.TPlanetRing}

constructor TStarSystem.TPlanetSystem.TPlanet.TPlanetRing.Create(Core:TAGGraphicCore;Conf:TCustomIniFile;ConfigSect,TexFloder:String;RP:TRotationParams);
begin
with Conf do
begin
  RotParam:=TRotationParams.Load(Conf,ConfigSect)+RP;
  Radius:=ReadFloat(ConfigSect,'Radius',1);
end;
inherited Create(Core,Conf,ConfigSect,TexFloder);
end;

procedure TStarSystem.TPlanetSystem.TPlanet.TPlanetRing.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
RotParam.DrawWithRot(Core,Mesh,TAG3DMatrix.MkScale(Radius)*Matrix,False);
end;

constructor TStarSystem.TPlanetSystem.TPlanet.Create(Core:TAGGraphicCore;ID:Cardinal);
var
  Conf:TMemIniFile;
  RP:TRotationParams;
  i:byte;
begin
Conf:=TMemIniFile.Create('..\Data\planets\'+SizeableWordtoStr(ID,2)+'\index.ini');
inherited Create(Core,
  Conf,'..\Data\planets\'+SizeableWordtoStr(ID,2),TPlanetLayer);
RP:=TRotationParams.Load(Conf,'Main');
Meshs:=TList<TPlanetMesh>.Create;
Rings:=TList<TPlanetRing>.Create;

i:=1;
while Conf.SectionExists('Mesh'+inttostr(i)) do
begin
  Meshs.Add(TPlanetMesh.Create(Core,Conf,'Mesh'+inttostr(i),'..\Data\planets\'+SizeableWordtoStr(ID,2),RP));
  inc(i);
end;

i:=1;
while Conf.SectionExists('Ring'+inttostr(i)) do
begin
  Rings.Add(TPlanetRing.Create(Core,Conf,'Ring'+inttostr(i),'..\Data\planets\'+SizeableWordtoStr(ID,2),RP));
  inc(i);
end;
end;

procedure TStarSystem.TPlanetSystem.TPlanet.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
var
  i0:TPlanetMesh;
  i1:TPlanetRing;
begin
inherited;
for i0 in Meshs do
  i0.Draw(Core,Matrix);
for i1 in Rings do
  i1.Draw(Core,Matrix);
end;

{TStarSystem.TStar}

{TStarSystem.TStar.TStarLayer}

procedure TStarSystem.TStar.TStarLayer.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
RotParam.DrawWithRot(Core,Mesh,TAG3DMatrix.MkScale(Radius)*Matrix,False);
end;

constructor TStarSystem.TStar.Create(Core:TAGGraphicCore;ID:Cardinal);
var
  Conf:TMemIniFile;
  i:byte;
begin
Conf:=TMemIniFile.Create('..\Data\stars\'+SizeableWordtoStr(ID,2)+'\index.ini');
inherited Create(Core,Conf,'..\Data\stars\'+SizeableWordtoStr(ID,2),TStarLayer);
end;

procedure TStarSystem.TStar.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
inherited;
end;

function TStarSystem.GetStar(i:integer):TAGE3DObject;
begin
Result:=FStars[i];
end;

constructor TStarSystem.Create(Core:TAGGraphicCore;Conf:TCustomIniFile);
const
  DefControls:array[1..5]of string=('TSystemCenterControlNone','','','','');
var
  i:integer;
begin
i:=1;
FStars:=TList<TStar>.Create();
while Conf.ValueExists('Main','Star'+IntToStr(i)) do
begin
  FStars.Add(TStar.Create(Core,Conf.ReadInteger('Main','Star'+IntToStr(i),0)));
  inc(i);
end;
CenterControl:=TSystemCenterControl.Create(Conf,i-1,Conf.ReadString('Main','CenerType',DefControls[FStars.Count]));
i:=1;
PlanetSystems:=TList<TPair<TPlanetSystem,TCirculationInfo>>.Create();
{while Conf.ValueExists('Main','Star'+IntToStr(i)) do
begin
  FStars.Add(TStar.Create(Core,Conf.ReadInteger('Main','Star'+IntToStr(i),0)));
  inc(i);
end;
CenterControl:=TSystemCenterControl.Create(Conf,i-1,Conf.ReadString('Main','CenerType',DefControls[FStars.Count]));}
end;

procedure TStarSystem.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
var
  i:integer;
begin
for i:=0 to FStars.Count-1 do
  CenterControl.Draw(Core,Matrix,i,FStars[i]);
end;

{TSky}

constructor TSky.Create(Core:TAGGraphicCore);
begin
Self:=inherited Create(Core,'../Data/sky/001_spasesky.X');
Correction:=TAG3DMatrix.MkScale(50);
end;

procedure TSky.Draw(Core:TAGGraphicCore;Matrix:TAG3DMatrix);
begin
Core.DrawMesh(Mesh,Correction,False);
end;

procedure TSky.Draw(Core:TAGGraphicCore);
begin
Core.DrawMesh(Mesh,Correction,False);
end;

var
  RttiContext:TRttiContext;
  &Type:TRttiType;
  meta:TClass;
  i:integer;
  s:string;
initialization
TSystemCenterControlNone.ClassName;
FormatSettings.DecimalSeparator:='.';
RotationTime:=TAGEGameTime.Create;
TRotationParams.RotCorrection:=TAG3DMatrix.MkRot(TAG3DVector.Create(pi/2,0,0));
for i:=Low(TSystemCenterControl.GlobalIndexedRegister)to High(TSystemCenterControl.GlobalIndexedRegister)do
  TSystemCenterControl.GlobalIndexedRegister[i]:=TDictionary<String,TSystemCenterControl.TSystemCenterControlClass>.Create();
RttiContext:=TRttiContext.Create;
for &Type in RttiContext.GetTypes do
  if &Type.IsInstance then
  begin
    meta:=&Type.AsInstance.MetaclassType;
    s:=&Type.Name;
    if meta.InheritsFrom(TSystemCenterControl) then
      TSystemCenterControl.GlobalIndexedRegister[TSystemCenterControl.TSystemCenterControlClass(meta).GetBodysCount].Add(
        &Type.Name,TSystemCenterControl.TSystemCenterControlClass(meta));
  end;
RttiContext.Free;
finalization
FreeAndNil(RotationTime);
FreeAndNil(TSystemCenterControl.GlobalIndexedRegister);
end.
