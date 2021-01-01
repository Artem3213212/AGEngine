const
  CDataDir='..\Data\';
  CCTempDir='%Temp%\';

function CTempDir:string;
var
  P:array[0..100]of widechar;
begin
ExpandEnvironmentStrings(CCTempDir,addr(P),100);
Result:=P;
end;
function PWCCTempDir:Pwidechar;
begin
getmem(Result,100);
ExpandEnvironmentStrings(CCTempDir,Result,100);
end;


