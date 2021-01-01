unit AG.Graphic.WIC;

interface

{$i main.conf}

{$IFDEF WIC}
uses
  Winapi.Wincodec,Winapi.ActiveX;

var
  WICImgFactory:IWICImagingFactory;
{$ENDIF}

implementation

{$IFDEF WIC}
initialization
CoInitialize(nil);
CoCreateInstance(CLSID_WICImagingFactory,nil,CLSCTX_INPROC_SERVER,IID_IWICImagingFactory,pointer(WICImgFactory));
{$ENDIF}
end.
