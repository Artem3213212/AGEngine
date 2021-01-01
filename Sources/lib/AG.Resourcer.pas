unit AG.Resourcer;

interface

{$i main.conf}

{$IFDEF VampyreIL}{$ENDIF}
{$IFDEF WIC}{$ENDIF}
{$IFDEF D3DX}{$ENDIF}

uses
  System.Classes,System.SysUtils,System.Zip,System.Generics.Collections,System.IniFiles,
  AG.Utils;

type
  TAGResourceImageEncoder=(
    AGRIE_None
    {$IFDEF VampyreIL},AGRIE_Vampyre{$ENDIF}
    {$IFDEF WIC},AGRIE_WIC{$ENDIF}
    {$IFDEF D3DX},AGRIE_D3DX{$ENDIF}
  );

  TAGResourceImage=record
    d:TStream;
    encoder:TAGResourceImageEncoder;
    constructor LoadByFile(FName:String);
    procedure Free;
  end;

  TAGResource=record
    config:TMemIniFile;
    img:array of TAGResourceImage;
  end;

  PAGResource=record
    r:^TAGResource;
    Name:string;
    changeble:boolean;
  end;

  TAGResourser=class
  private
    Zip:TZipFile;
    Res:TDictionary<string,TPair<word,PAGResource>>;
    function UnLoad(PRes:PAGResource):PAGResource;
    function Load(Name:string):PAGResource;
  public
    function Get(Name:string;const changeble:boolean=false):PAGResource;
    procedure Release(var PRes:PAGResource);
    constructor Create(filename:string);overload;
    destructor Destroy();override;
  end;

const
  InfoCastSection='infocast';

implementation

{$i lib\consts.inc}

constructor TAGResourceImage.LoadByFile(FName:string);
begin
d:=TFileStream.Create(FName,fmOpenRead);
encoder:=
  {$IFDEF VampyreIL}AGRIE_Vampyre
  {$ELSE}{$IFDEF WIC}AGRIE_WIC
  {$ELSE}{$IFDEF D3DX}AGRIE_D3DX
  {$ELSE}AGRIE_None
  {$ENDIF}{$ENDIF}{$ENDIF};
end;

procedure TAGResourceImage.Free;
begin
FreeAndNil(d);
encoder:=AGRIE_None;
end;

constructor TAGResourser.Create(filename:string);
begin
Zip:=TZipFile.Create;
Zip.Open(filename,zmRead);
Res:=TDictionary<string,TPair<word,PAGResource>>.Create();
end;

function TAGResourser.Load(Name:string):PAGResource;
var
  i,n:integer;
  a:TZipHeader;
  format:string{[3]};
begin
Getmem(Result.r,sizeof(TAGResource));
FillChar(Result.r^,sizeof(TAGResource),0);
with Result.r^ do
begin
  Result.Name:=Name;
  Result.changeble:=false;
  zip.Extract(Name+'\index.ini',CTempDir,false);
  config:=TMemIniFile.Create(CTempDir+'index.ini');
  setlength(img,config.ReadInteger('graphics','Enum',0));
  n:=config.ReadInteger('graphics','EnumLen',0);
  {$Warnings Off}
  format:=config.ReadString('graphics','format','AGP');
  {$Warnings On}
  for i:=1 to length(img) do
  begin
    zip.Read(Name+'\'+SizeableWordtoStr(i,n),img[i-1].d,a);
    img[i-1].encoder:=
      {$IFDEF VampyreIL}AGRIE_Vampyre
      {$ELSE}{$IFDEF WIC}AGRIE_WIC
      {$ELSE}{$IFDEF D3DX}AGRIE_D3DX
      {$ELSE}AGRIE_None
      {$ENDIF}{$ENDIF}{$ENDIF};
  end;
end;
end;

function TAGResourser.Get(Name:string;const changeble:boolean):PAGResource;
var
  re:TPair<word,PAGResource>;
begin
if(Res.TryGetValue(Name,re))and not(changeble)then
begin
  Inc(re.Key);
  Res.Items[Name]:=re;
  Result:=re.Value;
end
else
begin
  re.Key:=1;
  re.Value:=Load(Name);
  if not(changeble)then
    Res.Add(Name,re);
  Result:=re.Value;
  Result.changeble:=changeble;
end;
re.Value.r:=nil;
end;

function TAGResourser.UnLoad(PRes:PAGResource):PAGResource;
var
  i:TAGResourceImage;
begin
for i in PRes.r^.img do
  i.Free;
SetLength(PRes.r^.img,0);
FreeAndNil(PRes.r^.config);
end;

procedure TAGResourser.Release(var PRes:PAGResource);
var
  re:TPair<word,PAGResource>;
begin
if PRes.changeble or(not Res.TryGetValue(PRes.Name,re))then
  UnLoad(PRes)
else
  dec(re.Key);
PRes.r:=nil;
end;

destructor TAGResourser.Destroy();
begin
FreeAndNil(Zip);
end;

end.
