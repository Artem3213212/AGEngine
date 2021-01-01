program toRGBABMP;

{$APPTYPE CONSOLE}

{$SetPEFlags 1}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Zip,
  System.ZLib,
  System.IniFiles,
  System.IOUtils,
  System.SyncObjs,
  Winapi.Windows,
  AG.Logs in '..\..\..\NoEngineLibs\AGLogs\AG.Logs.pas',
  AG.STD.Files in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Files.pas',
  AG.STD.BitMaps in '..\..\..\NoEngineLibs\AGSTD\AG.STD.BitMaps.pas',
  AG.STD.Types in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Types.pas',
  Imaging,ImagingTypes;

type
  TStreamHelper=class helper for TStream
    public
      procedure Write(s:string);overload;
  end;

procedure TStreamHelper.Write(s:string);
begin
{$IF sizeof(char)=2}
if Position=0 then
  WriteData(Word($FEFF));
{$ENDIF}
WriteData(addr(s[{$IFDEF NEXTGEN}0{$ELSE}1{$ENDIF}]),Length(s)*SizeOf(Char));
end;

type
  TPairString=array[0..1]of string;

  TMirroring=set of(TMVertical,TMHorisontal);

  TPicInfo=record
    Names:TPairString;
    Mirroring:TMirroring;
  end;

  TInfo=record
    Use:boolean;
    Cut:boolean;
    CutSz:record
      X,Y,W,H:integer;
    end;
    Graphic:boolean;
    GraphicInfo:record
      Scale:single;
      Format:string;
      Enum:record
        Len,eStart,eEnd:integer;
      end;
      mask:String;
    end;
    FilesToAdd:array of TPairString;
    WorkArray:array of TPicInfo;
    Filters:array of string;
    UseInfocast:boolean;
    Infocast:string;
    constructor Create(floder:string);
  end;

const
  CSourceDir='..\..\DataSrc\Images\';
  CTempDir='..\..\Temp\';
  UsingComp:TZipCompression=zcDeflate;

var
  Log:TAGLog;
  CurrObjectPath,s:string;
  SoucseDir,TempDir:string;
  f:boolean;
  Zip,Zipp:Tzipfile;
  ZipLock:TCriticalSection;
  ZipHeader:TZipHeader;
  black_list:TStringList;

function PathOptimise(const Path:string):string;inline;
var
  l:TArray<string>;
  i,ii:integer;
begin
Result:='';
l:=TArray<string>.Create();
l:=Path.Split(['\','/']);
ii:=length(l)-1;
i:=0;
while ii>0 do
begin
  if l[ii]='..' then
    while(l[ii]='..')or(i<>0)do
    begin
      if l[ii]='..' then
        inc(i)
      else
        dec(i);
      dec(ii);
    end
  else
  begin
    Result:=TPath.DirectorySeparatorChar+l[ii]+Result;
    dec(ii);
  end;
end;
Result:=l[0]+Result;
end;

function Join(const s0,s1:string):string;inline;
begin
Result:=TPath.Combine(s0,s1);
end;

function Combine(const s:array of string):string;
var
  i:integer;
begin
Result:=s[0];
for i:=1 to length(s)-1 do
  Result:=Result+' '+s[i];
end;

function Quote(const s:string):string;inline;
begin
Result:='"'+s+'"';
end;

function IsTrueStr(s:string):boolean;
begin
Result:='true'=LowerCase(s)
end;

procedure LoggingInit();inline;
begin
Log:=TAGMultiLog.Create();
with (Log as TAGMultiLog).Logs do
begin
  Add(TAGDiskLog.Create(CSourceDir+'Main.log'));
  Add(TAGCommandLineLog.Create());
end;
end;

procedure LoggingEnd();inline;
begin
FreeAndNil(Log);
end;

procedure AddToZip(data:TStream;ZName:string);overload;
begin
data.Seek(0,soBeginning);
ZipLock.Enter;
Zip.Add(data,ZName,UsingComp);
ZipLock.Leave;
end;

procedure AddToZip(FName,ZName:string);overload;
var
  temp:TMemoryStream;
begin
temp:=TMemoryStream.Create;
temp.LoadFromFile(FName);
AddToZip(temp,ZName);
end;

procedure workfile(inf:TInfo;ii,s1:string;Mirroring:TMirroring);
var
  str:string;
  x,y:integer;
  px:TColor32Rec;
  sfile:string;
  Data,Temp:TImageData;
  &Out:TStream;
begin
with inf do
  if Graphic and Use then
    with GraphicInfo do
    begin
      sfile:=Join(CurrObjectPath,s1);
      Log.Write(sfile);
      if format='NOCONV' then
        AddToZip(sfile,Join(TPath.GetFileName(CurrObjectPath),ii))
      else
      begin
        LoadImageFromFile(sfile,Data);
        if Cut then
        begin
          with CutSz do
          begin
            NewImage(W,H,ifA8R8G8B8,Temp);
            CopyRect(Data,X,Y,W,H,Temp,0,0);
          end;
        end
        else
        begin
          NewImage(Data.Width,Data.Height,ifA8R8G8B8,Temp);
          CopyRect(Data,0,0,Data.Width,Data.Height,Temp,0,0);
        end;
        if Scale<>1 then
          ResizeImage(Temp,Round(Scale*Temp.Width),Round(Scale*Temp.Height),rfBicubic);
        for str in Filters do
          if str='boolalpha' then
            for x:=0 to Temp.Width-1 do
              for y:=0 to Temp.Height-1 do
              begin
                px:=GetPixel32(Temp,x,y);
                if px.A>0 then
                  px.A:=255;
                SetPixel32(Temp,x,y,px);
              end;
        if TMVertical in Mirroring then
          MirrorImage(Temp);
        if TMHorisontal in Mirroring then
          FlipImage(Temp);
        &Out:=TMemoryStream.Create;
        if format='AGP' then
        begin
          &Out.WriteData(Word(CAGAGPSTDHead));
          &Out.WriteData(Word(Temp.Width));
          &Out.WriteData(Word(Temp.Height));
          WriteRawImageToStream(&Out,Temp,2*3);
        end
        else
          SaveImageToStream(Format,&Out,Temp);
        AddToZip(&Out,Join(TPath.GetFileName(CurrObjectPath),ii));
      end;
    end;
end;

constructor TInfo.Create(floder:string);
var
  ini:TIniFile;
  i:integer;
  tss:TStrings;
begin
try
  ini:=TIniFile.Create(Join(floder,'index.ini'));
except
  Use:=False;
  exit;
end;
with ini do
begin
  Use:=SectionExists('main');
  if not Use then
    exit;
  if IsTrueStr(ReadString('Main','Useble','false')) then
  begin
    cut:=IsTrueStr(ReadString('Main','cut','false'))and(SectionExists('cut'));
    if cut then
      with CutSz do
      begin
        X:=ReadInteger('cut','X',0);
        Y:=ReadInteger('cut','Y',0);
        W:=ReadInteger('cut','W',10000);
        H:=ReadInteger('cut','H',10000);
      end;
    Graphic:=SectionExists('graphics');
    if Graphic then
      with GraphicInfo do
      begin
        Scale:=ReadFloat('graphics','Scale',1);
        Format:=UpperCase(ReadString('graphics','Format','AGP'));
        with Enum do
        begin
          Len:=ReadInteger('graphics','EnumLen',0);     //i0
          eStart:=ReadInteger('graphics','EnumStart',1);//i1
          eEnd:=ReadInteger('graphics','EnumEnd',1);    //i2
          mask:=ReadString('graphics','mask','*');      //s0
          if Pos('*',mask)=0 then
          begin
            SetLength(WorkArray,1);
            WorkArray[0].Names[0]:='0';
            WorkArray[0].Names[1]:=ReadString('graphics','0',mask);
          end
          else if Len<>0 then
          begin
            SetLength(WorkArray,eEnd-eStart+1);
            for i:=eStart to eEnd do
            begin
              WorkArray[i-eStart].Names[0]:=SizeableWordtoStr(i,Len);
              WorkArray[i-eStart].Names[1]:=ReadString('graphics',WorkArray[i-eStart].Names[0],StringReplace(mask,'*',WorkArray[i-eStart].Names[0],[]));
              case UpperCase(ReadString('mirroring',WorkArray[i-eStart].Names[0],'N')){$IFDEF NEXTGEN}[0]{$ELSE}[1]{$ENDIF} of
              'V':WorkArray[i-eStart].Mirroring:=[TMVertical];
              'H':WorkArray[i-eStart].Mirroring:=[TMHorisontal];
              'A':WorkArray[i-eStart].Mirroring:=[TMVertical,TMHorisontal];
              else//'N'
                WorkArray[i-eStart].Mirroring:=[];
              end;
            end;
          end;
        end;
      end;
    if SectionExists('addfiles')then
    begin
      SetLength(FilesToAdd,ReadInteger('addfiles','count',0));
      for i:=1 to Length(FilesToAdd) do
      begin
        FilesToAdd[i-1][0]:=ReadString('addfiles','f'+inttostr(i),'');
        FilesToAdd[i-1][1]:=ReadString('addfiles','z'+inttostr(i),'');
      end;
    end
    else
      SetLength(FilesToAdd,0);
    if SectionExists('filters')then
    begin
      SetLength(Filters,ReadInteger('filters','count',0));
      for i:=0 to Length(Filters)-1 do
        Filters[i]:=ReadString('filters','f'+inttostr(i),'');
    end
    else
      SetLength(Filters,0);
    if UseInfocast then
    UseInfocast:=SectionExists('infocast');
    begin
      tss:=TStringList.Create();
      ReadSectionValues('infocast',tss);
      InfoCast:='[infocast]'+sLineBreak+tss.Text;
    end;
  end;
FreeAndNil(ini);
end;
end;

procedure ParallelMain(s:string);
var
  inf:TInfo;
  i:TPicInfo;
  i0:TPairString;
  temp:TStream;
begin
inf:=TInfo.Create(s);
with inf do
begin
  if Graphic then
    for i in WorkArray do
      workfile(inf,i.Names[0],i.Names[1],i.Mirroring);
  for i0 in FilesToAdd do
    AddToZip(i0[0],i0[1]);
  temp:=TMemoryStream.Create;
  if cut then
    with CutSz do
    begin
      temp.Write(
      '[oldcut]'+sLineBreak+
      'X='+IntToStr(X)+sLineBreak+
      'Y='+IntToStr(Y)+sLineBreak+
      'W='+IntToStr(W)+sLineBreak+
      'H='+IntToStr(H)+sLineBreak);
    end;
  if Use then
    temp.Write('[main]'+sLineBreak+
               'useble=true'+sLineBreak);
  if Graphic then
    with GraphicInfo.Enum do
      temp.Write('[graphics]'+sLineBreak+
                 'Enum='+inttostr(eEnd-eStart+1)+sLineBreak+
                 'EnumLen='+inttostr(Len)+sLineBreak+
                 'format='+GraphicInfo.format+sLineBreak);
  if UseInfocast then
    temp.Write(Infocast+sLineBreak);
  AddToZip(temp,Join(TPath.GetFileName(CurrObjectPath),'index.ini'));
end;
end;

begin
FormatSettings.DecimalSeparator:='.';
LoggingInit;
ZipLock:=TCriticalSection.Create();
Zip:=TZipFile.Create;
Zip.Open('..\..\Data\img.zip',zmWrite);
Log.Write('Open "..\..\Data\img.zip"');

//Set Commpression to Max
Zip.RegisterCompressionHandler(zcDeflate,
    function(InStream:TStream;const ZipFile:TZipFile;const Item:TZipHeader):TStream
    begin
      Result:=TZCompressionStream.Create(InStream,zcMax,-15);
    end,
    function(InStream:TStream;const ZipFile:TZipFile;const Item:TZipHeader):TStream
    begin
      Result:=TZDecompressionStream.Create(InStream,-15);
    end);

TempDir:=PathOptimise(Join(GetCurrentDir,CTempDir));
SoucseDir:=PathOptimise(Join(GetCurrentDir,CSourceDir));

black_list:=TStringList.Create;
black_list.LoadFromFile(Join(SoucseDir,'black.list'));

for CurrObjectPath in TDirectory.GetDirectories(SoucseDir)do
begin
  f:=True;
  for s in black_list.ToStringArray do
    if s=TPath.GetFileName(CurrObjectPath) then
    begin
      f:=False;
      break;
    end;
  if f then
    ParallelMain(CurrObjectPath);
end;
Zip.Close;
//Zip.Open('../../Data/data.zip',zmWrite);
//Zip.Add('../../Data/img.zip','z',zzzt);
//Zip.Close;

//Zip.Open('../../Data/img.zip',zmRead);
//Zip.Read('',Stream,ZipHeader);
//PClass(Stream)^:=TNoBugStream;
{Zipp:=TZipFile.Create;
Zipp.Open(Stream,zmRead);
Zipp.ExtractAll('');}
//Zip.Close;
LoggingEnd;
end.
