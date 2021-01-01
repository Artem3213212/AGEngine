unit GameElements.Camera;

interface

uses AG.Graphic,AGE.BaseClasses,AG.Windows;

type
  TMainCamera=class (TAGE3DCamera)
    public
      //procedure SetToObject(Obj:TAGE3DObject;NoRot:boolean=True);override;
      //procedure SetToObject(Obj:TAGE3DObject;CameraPos:TAG3DVector);override;
      //procedure SetToObject(Obj,CameraPos:TAG3DVector);override;
      procedure InitGraphicCore(Core:TAGGraphicCore);override;
      function OnKey(key:byte;Info:TAGKeyInfo):boolean;override;
      constructor Create();
  end;

implementation

{TMainCamera}

procedure TMainCamera.InitGraphicCore(Core:TAGGraphicCore);
begin

end;

function TMainCamera.OnKey(key:byte;Info:TAGKeyInfo):boolean;
begin

end;

constructor TMainCamera.Create();
begin

end;

end.
