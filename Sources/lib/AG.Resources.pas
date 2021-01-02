unit AG.Resources;

interface

{$i main.conf}

uses
  Classes,SysUtils,Generics.Collections,IniFiles,
  AG.Utils,AG.Types,AG.Graphic,TarLib;

type
  TAGResourceUnit=class
    public
      constructor CreateFromRaw(Data:TStream);
      //function LoadImages(Core:TAGGraphicCore):;
  end;

  TAGResourceModel=class abstract
    private
      FConfig:TCustomIniFile;
      function GetRawUnit(Name:String):TStream;virtual;abstract;
    public
      constructor Create(Config:TCustomIniFile);
      function GetUnit(Name:String):TAGResourceUnit;
      destructor Destroy;override;
  end;

  {$IFDEF DiskResourceModel}
  TAGDiskResourceModel=class(TAGResourceModel)
    private
      FDirPath:String;          
      function GetRawUnit(Name:String):TStream;override;
    public
      constructor Create(Folder:String='../Data');
  end;
  {$ENDIF}


implementation       

constructor TAGResourceUnit.CreateFromRaw(Data:TStream);
begin

end;

constructor TAGResourceModel.Create(Config:TCustomIniFile);
begin
  FConfig:=Config;
end;

function TAGResourceModel.GetUnit(Name:String):TAGResourceUnit;
begin
  Result:=TAGResourceUnit.CreateFromRaw(GetRawUnit(Name));
end;

destructor TAGResourceModel.Destroy; 
begin
  FreeAndNil(FConfig);
end;

{$IFDEF DiskResourceModel}
constructor TAGDiskResourceModel.Create(Folder:String='../Data');
begin
  inherited Create(TMemIniFile.Create(Folder+DirectorySeparator+'index.ini'));
  FDirPath:=Folder;
end;

function TAGDiskResourceModel.GetRawUnit(Name:String):TStream;
begin
  Result:=TFileStream.Create(FDirPath+DirectorySeparator+Name,fmOpenRead);
end;
{$ENDIF}

end.
