program UnArcRGBABMP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  winapi.windows,
  winapi.Activex,
  winapi.wincodec,
  AG.STD.Files in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Files.pas',
  AG.STD.BitMaps in '..\..\..\NoEngineLibs\AGSTD\AG.STD.BitMaps.pas',
  AG.STD.Types in '..\..\..\NoEngineLibs\AGSTD\AG.STD.Types.pas';

const 
  z:PGUID=nil;
  BuffSize=1024*1024*128;
  
var
  WICImgFactory:IWICImagingFactory;
  s0,s1:string;
  n:integer;
  a:IWICBitmapDecoder;
  c:IWICBitmapFrameDecode;
  d:IWICFormatConverter;
  aa:WICRect;
  Buff:array[0..BuffSize]of byte;
  W,H:cardinal;              
  Data:packed record 
    a:TAGBMPHead;
    b:TAGBMPInfoHead12;
  end=(a:(BM:'BM';Size:12+$E;zReszerv:0;Map:12+$E;);b:(Size:12;W:0;H:0;Planes:1;bits:32));
  q:array[0..1]of TAGData=((sb:sizeof(Data);p:addr(Data)),(sb:0;p:nil));
  
begin         
CoInitialize(nil);   
CoCreateInstance(CLSID_WICImagingFactory,nil,CLSCTX_INPROC_SERVER,IID_IWICImagingFactory,pointer(WICImgFactory));
s0:=ParamStr(1);
s1:=ParamStr(2);   
n:=strtoint(ParamStr(3));

WICImgFactory.CreateDecoderFromFilename(pwidechar(s0),z^,GENERIC_READ,WICDecodeMetadataCacheOnLoad,a); 
a.GetFrame(n,c);
WICImgFactory.CreateFormatConverter(d);         
d.Initialize(c,GUID_WICPixelFormat32bppBGRA,WICBitmapDitherTypeNone,nil,1,WICBitmapPaletteTypeMedianCut);
if ParamCount=7 then  
  with aa do
  begin     
    X:=strtoint(ParamStr(4));
    Y:=strtoint(ParamStr(5));
    Width:=strtoint(ParamStr(6));
    Height:=strtoint(ParamStr(7));   
  end
else                
  with aa do
  begin
    d.GetSize(W,H); 
    X:=0;
    Y:=0;  
    Width:=W;
    Height:=H;  
  end;
d.CopyPixels(addr(aa),aa.Width*4,BuffSize,addr(Buff[0]));
with aa do
  q[1]:=TAGData.Comp(Buff[0],4*Width*Height);
  
Data.b.W:=aa.Width;
Data.b.H:=aa.Height;
inc(Data.a.Size,q[1].sb);
AG.STD.Files.AGWrite(s1,addr(q[0]),2);
end.
