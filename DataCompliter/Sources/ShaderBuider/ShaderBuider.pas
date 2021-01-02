program ShaderBuider;

uses
  Classes,SysUtils,IniFiles;

function ExtractOnlyFileName(const FileName: string): string;
begin
  result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

function GenIndent(Indent:Integer):String;
var
  i:integer;
begin
  Result:='';
  for i:=1 to Indent do
    Result:=Result+'  ';
end;

function MkPasLine(Indent:Integer;&in:string):string;
begin
  Result:=GenIndent(Indent)+#$27+&in+#$27;
end;

var
  ResultGLSL,ResultGLSLES:TStrings;

procedure MultiAdd(Data:String);
begin
  ResultGLSL.Add(Data);
  ResultGLSLES.Add(Data);
end;

procedure LoadFile(&To:TStrings;Indent:Integer;&file:string);
var
  Data:TStrings;
  i:integer;
begin
  Data:=TStringList.Create;
  Data.LoadFromFile(&file);
  for i:=0 to Data.Count-2 do
  begin
    if i=1 then
    begin                    
      &To.Add(MkPasLine(Indent,'precision mediump float;')+'+sLineBreak+');
      &To.Add(MkPasLine(Indent,'precision highp int;')+'+sLineBreak+');
    end;
    &To.Add(MkPasLine(Indent,Data[i])+'+sLineBreak+');
  end;
  &To.Add(MkPasLine(Indent,Data[Data.Count-1])+';');
  FreeAndNil(Data);
end;


procedure ProcessFile(Config:TMemIniFile;Indent:Integer;&file:string);
const
  CTempDir='..'+DirectorySeparator+'..'+DirectorySeparator+'temp';
begin              
  ExecuteProcess('spirv-as','-o '+ConcatPaths([CTempDir,'Test.bin'])+' '+&file,[]);
  //GLSL
    ExecuteProcess('spirv-cross',ConcatPaths([CTempDir,'Test.bin'])+' --output '+ConcatPaths([CTempDir,'Test.glsl']),[]);
    LoadFile(ResultGLSL,Indent,ConcatPaths([CTempDir,'Test.glsl']));
    //spirv-as.exe -o Test.bin Test.spirv
    //spirv-cross.exe Test.bin --output Test.glsl
  //GLSLES
    ExecuteProcess('spirv-cross','--version 310 --es '+ConcatPaths([CTempDir,'Test.bin'])+' --output '+ConcatPaths([CTempDir,'Test.glsles']),[]);
    LoadFile(ResultGLSLES,Indent,ConcatPaths([CTempDir,'Test.glsles']));
    //spirv-as.exe -o Test.bin Test.spirv
    //spirv-cross.exe --es Test.bin --output Test.glsles
  DeleteFile(ConcatPaths([CTempDir,'Test.bin']));      
  DeleteFile(ConcatPaths([CTempDir,'Test.glsl']));
  DeleteFile(ConcatPaths([CTempDir,'Test.glsles']));
end;

procedure ProcessDir(Indent:Integer;Dir:string);
var
  Search:TSearchRec;
  Config:TMemIniFile;
begin
  if FileExists(ConcatPaths([Dir,'index.ini']))then
  begin
    if FindFirst(ConcatPaths([Dir,'*']),faAnyFile,Search)=0 then
    begin
        MultiAdd(GenIndent(Indent)+'const');
        inc(Indent);
        Config:=TMemIniFile.Create(ConcatPaths([Dir,'index.ini']));
        repeat                    
          if(Search.Name<>'index.ini')and(Search.Attr and faDirectory=0)then
          begin
            MultiAdd(GenIndent(Indent)+ExtractOnlyFileName(Search.Name)+'=');
            ProcessFile(Config,Indent+1,ConcatPaths([Dir,Search.Name]));
          end;
        until FindNext(Search)<>0;
        FreeAndNil(Config);
    end;
  end
  else
    if FindFirst(ConcatPaths([Dir,'*']),faDirectory,Search)=0 then
    begin
      MultiAdd(GenIndent(Indent)+'type');
      inc(Indent);
      repeat
        if(Search.Name<>'.')and(Search.Name<>'..')and(Search.Attr and faDirectory<>0)then
        begin
          MultiAdd(GenIndent(Indent)+Search.Name+'=class');
          MultiAdd(GenIndent(Indent+1)+'public');
          ProcessDir(Indent+2,ConcatPaths([Dir,Search.Name]));
          MultiAdd(GenIndent(Indent)+'end;');
        end;
      until FindNext(Search)<>0;   
    end;
  FindClose(Search);
end;

const
  ShaderFolder='..'+DirectorySeparator+'..'+DirectorySeparator+'Shaders';
begin
  try 
    WriteLn(ExtractFileDir(Paramstr(0)));
    if not SetCurrentDir(ExtractFileDir(Paramstr(0))) then
      raise Exception.Create('Error in SetCurrentDir');
    ResultGLSL:=TStringList.Create;
    ResultGLSLES:=TStringList.Create;
    ResultGLSL.Add('unit ShadersResouces.GLSL;');
    ResultGLSLES.Add('unit ShadersResouces.GLSLES;');
    MultiAdd('');
    MultiAdd('//**************************');
    MultiAdd('//*Automatic Generated File*');
    MultiAdd('//**************************');
    MultiAdd('');
    MultiAdd('interface');
    MultiAdd('');

    ProcessDir(0,ShaderFolder);

    MultiAdd('');
    MultiAdd('implementation');
    MultiAdd('');
    MultiAdd('end.');
    ResultGLSL.SaveToFile(ShaderFolder+DirectorySeparator+'ShadersResouces.GLSL.pas');
    ResultGLSLES.SaveToFile(ShaderFolder+DirectorySeparator+'ShadersResouces.GLSLES.pas');
  except
    on E:Exception do    
      Writeln(E.ClassName+' Error: '+E.Message);
  end;
end.

