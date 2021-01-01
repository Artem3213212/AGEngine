program toAGP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  winapi.windows,
  AG.STD.Files in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Files.pas',
  AG.STD.BitMaps in '..\..\..\NoEngineLibs\AGSTD\AG.STD.BitMaps.pas', 
  AG.STD.Types in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Types.pas';

type
  TAzaza=record
    R,G,B,A:byte;
  end;

var
  s0,s1:string;
  btm:TAGBitMap;
  i,p:^TAzaza;
  y:byte;
  //p:pointer;

begin
s0:=ParamStr(1);
s1:=ParamStr(2);
btm:=OpenBmp(pwidechar(s0));
//NormaliseteBitMap(btm);
i:=btm.p;
p:=btm.p;
inc(p,btm.sb div 4);
while not(i=p) do
begin
  if i.A=0 then
  begin
    i.A:=0;
    i.G:=0;
    i.R:=0;
    i.B:=0;
  end;
 {else
  begin
    y:=i.R;
    i.R:=i.B;
    i.B:=y;
  end;}
  inc(i);
end;
//asm
//  mov eax,[btm.p]

//end;
//sleep(10000);

SaveAGP(pwidechar(s1),btm);
end.



