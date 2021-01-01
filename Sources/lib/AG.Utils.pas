unit AG.Utils;

interface

{$i main.conf}

{$IFDEF D2D1}
  {$Define Safecall}
{$ENDIF}
{$IFDEF D3D9}
  {$Define Safecall}
{$ENDIF}

uses
  System.SysUtils;

type
  EAGUnSupportedException=class(Exception);

{$IFDEF Safecall}
procedure HRESULTCHK(ERROR:HRESULT);inline;
{$ENDIF}

function IntToBin(IValue:integer;len:byte=1):string;inline;
function SizeableWordtoStr(i:word;size:int8):string;inline;

implementation

{$IFDEF Safecall}
procedure HRESULTCHK(ERROR:HRESULT);inline;
begin
if ERROR and HRESULT($80000000)<>0 then
  raise ESafecallException.Create('Critical error. Code: 0x'+IntToHex(ERROR,8));
end;
{$ENDIF}

function IntToBin(IValue:integer;len:byte=1):string;
begin
Result:='';
while IValue<>0 do
begin
    Result:=char(48+(IValue and 1))+Result;
    IValue:=IValue shr 1;
end;
while length(Result)<len do
  Result:='0'+Result;
end;

function SizeableWordtoStr(i:word;size:int8):string;
begin
  Result:=IntToStr(i);
  dec(size,Length(Result));
  case size of
  0:Result:=Result;
  1:Result:='0'+Result;
  2:Result:='00'+Result;
  3:Result:='000'+Result;
  4:Result:='0000'+Result;
  end;
end;

end.