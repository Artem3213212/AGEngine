unit AG.Graphic.Vulkan;

interface

{$i main.conf}

{$IFDEF Vulkan}
uses
  System.SysUtils,System.Generics.Collections,
  AG.Graphic,AG.Types,AG.Resourcer,
  //{$IFDEF AGP}AG.STD.BitMaps,{$ENDIF}
  //{$IFDEF VampyreIL}ImagingDirect3D8,{$ENDIF}
  Vulkan;

type
  TAGVulkanGraphicCore=class(TAG3DGraphicCore)
    protected
      dev:nativeint;
      Instance:TVkInstance;
      Device:TvkPhysicalDevice;
    public
      //destructor Destroy();override;
      procedure setbackcolor(color:TAGColor);override;

      destructor Destroy();override;
      procedure Init(W,H:cardinal;hWindow:nativeint;under,fscr:boolean);override;
      procedure OnPaint();override;
      procedure Resize(W,H:Word);override;
      //2D
      function CreateBrush(color:TAGColor):TAGBrush;overload;override;
      function CreateBrush(Colors:TAGGradientColors):TAGBrush;overload;override;
      function CreateBitMap(p:TAGBitMap):TAGEngineBitMap;overload;override;
      //function GetBtmForDraw:TAGEngineBitMap;virtual;abstract;
      //function CreateNewRender(W,H:cardinal;under:boolean):TAGGraphicCore;overload;override;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);override;
      procedure ReleaseBrush(b:TAGBrush);override;
      procedure ReleaseBitMap(b:TAGEngineBitMap);override;
      procedure DrawPoint(point:TAGscreenVector;size:word;brush:TAGBrush);override;
      procedure DrawRectangle(rect:TAGscreenCoord;size:word;brush:TAGBrush);override;
      procedure DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);override;
      procedure DrawLine(point0,point1:TAGscreenVector;size:word;brush:TAGBrush);override;
      procedure DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);override;
      procedure DrawBitmap(coord:TAGscreenCoord;bitmap:TAGEngineBitMap;f:boolean=false);override;
  end;
{$ENDIF}

implementation

{$IFDEF Vulkan}
procedure TAGVulkanGraphicCore.setbackcolor(color:TAGColor);
begin

end;

procedure TAGVulkanGraphicCore.Init(W,H:cardinal;hWindow:nativeint;under,fscr:boolean);
var
  applicationInfo:TvkApplicationInfo;
  cf:TVkInstanceCreateInfo;
  QueueFamilyProperties:TVkQueueFamilyProperties;
  c:cardinal;

  //dF:TVkDeviceCreateInfo;
  //inf:TVkDeviceCreateInfo;
  //cb:TVkAllocationCallbacks;
begin
applicationInfo.Create('Vakarimasen',0,'AGEngine',10,VK_API_VERSION);
cf.Create(0,addr(applicationInfo),0,nil,0,nil);
vkCreateInstance(addr(cf),nil,addr(Instance));
c:=1;
vkEnumeratePhysicalDevices(Instance,addr(c),addr(Device));
c:=1;
vkGetPhysicalDeviceQueueFamilyProperties(Device,addr(c),addr(QueueFamilyProperties));
vkGetPhysicalDeviceQueueFamilyProperties(Device,addr(c),addr(QueueFamilyProperties));
//vkCreateDevice
//df.sType
//vkCreateDevice(PDevice,pCreateInfo:PVkDeviceCreateInfo, pAllocator:PVkAllocationCallbacks,:PVkDevice);

//(0,addr(inf),addr(cb),addr(dev));

//Vulkan.vkcmd
end;

function TAGVulkanGraphicCore.OnPaint():nativeint;
begin

end;

procedure TAGVulkanGraphicCore.Resize(W,H:Word);
begin

end;

destructor TAGVulkanGraphicCore.Destroy;
begin

end;

function TAGVulkanGraphicCore.CreateBrush(color:TAGColor):TAGBrush;
begin

end;

function TAGVulkanGraphicCore.CreateBrush(Colors:TAGGradientColors):TAGBrush;
begin

end;

function TAGVulkanGraphicCore.CreateBitMap(p:TAGBitMap):TAGEngineBitMap;
begin

end;

procedure TAGVulkanGraphicCore.LoadFont(Name,Local:string;size:single;font:TAGFont);
begin

end;

procedure TAGVulkanGraphicCore.ReleaseBrush(b:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.ReleaseBitMap(b:TAGEngineBitMap);
begin

end;

procedure TAGVulkanGraphicCore.DrawPoint(point:TAGscreenVector;size:word;brush:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.DrawRectangle(rect:TAGscreenCoord;brush:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.DrawElips(point,radaii:TAGscreenVector;size:word;brush:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.DrawLine(point0,point1:TAGscreenVector;size:word;brush:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.DrawText(text:string;position:TAGScreenCoord;size:word;font:TAGFont;brush:TAGBrush);
begin

end;

procedure TAGVulkanGraphicCore.DrawBitmap(coord:TAGscreenCoord;bitmap:TAGEngineBitMap;f:boolean=false);
begin

end;

initialization
LoadVulkanLibrary;
if not LoadVulkanGlobalCommands then
begin
  MessageBox(0,'Initialisation Failed',nil,MB_ICONWARNING);
  ExitProcess(0);
end;
{$ENDIF}
end.
