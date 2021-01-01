unit AG.Graphic.D2D1;

interface

{$i main.conf}

{$IFDEF D2D1}
uses
  Winapi.D2D1,Winapi.DXGI,Winapi.D3DCommon,Winapi.DXTypes,Winapi.DXGIformat,Winapi.Windows,//D2D1
  {$IFDEF Logs}AG.Logs,{$ENDIF}
  {$IFDEF WIC}Winapi.Wincodec,AG.Graphic.WIC,{$ENDIF}
  {$IFDEF VampyreIL}Imaging,ImagingTypes,ImagingUtility,ImagingFormats,{$ENDIF}
  System.Classes,AG.Graphic,AG.Types,AG.Resourcer,AG.Utils;                                //AG

type
  TAGD2D1GraphicCore=class(TAGGraphicCore)
    protected
      class var
        D2D1Factory:ID2D1Factory;
        DwriteFactory:IDWriteFactory;
      const
        pr:D2D1_BRUSH_PROPERTIES=(opacity:1;transform:(
            _11:2;_12:0;
            _21:0;_22:2;
            _31:1;_32:1));
        prop:TD2D1BitmapProperties=(pixelFormat:(format:DXGI_FORMAT_B8G8R8A8_UNORM;alphaMode:D2D1_ALPHA_MODE_PREMULTIPLIED);
            dpiX:0;dpiY:0);
        rtop:D2D1_RENDER_TARGET_PROPERTIES=(&type:D2D1_RENDER_TARGET_TYPE_HARDWARE;
            pixelFormat:(format:DXGI_FORMAT_UNKNOWN;alphaMode:D2D1_ALPHA_MODE_UNKNOWN);
            dpiX:0;dpiY:0;usage:D2D1_RENDER_TARGET_USAGE_NONE;minLevel:D2D1_FEATURE_LEVEL_DEFAULT);
      var
        bcolor:TAGFloatColor;
        fonts:array[0..255] of IDWriteTextFormat;
        DrawRenderTarget:ID2D1RenderTarget;
      procedure SetBackColor(color:TAGColor);override;
      function GetBackColor:TAGColor;override;
    public
      constructor Create();
      destructor Destroy();override;
      procedure Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);override;
      procedure OnPaint();override;
      procedure Resize(W,H:Word);override;
      //2D
      function CreateBrush(color:TAGColor):TAGBrush;override;
      function CreateBitMap(p:TAGResourceImage):TAGBitMap;override;
      function CreateBitMapFromFile(Name:String):TAGBitMap;override;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;override;
      procedure Init2D();override;
      procedure LoadFont(Name,Local:string;size:single;font:TAGFont);override;
      procedure ReleaseBrush(b:TAGBrush);override;
      procedure ReleaseBitMap(b:TAGBitMap);override;
      procedure DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawRectangle(rect:TAGCoord;size:word;brush:TAGBrush);override;
      procedure DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush);override;
      procedure DrawText(text:string;position:TAGCoord;size:word;font:TAGFont;brush:TAGBrush);override;
      procedure DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;opacity:byte=255;f:boolean=false);override;
      procedure FillRectangle(rect:TAGCoord;brush:TAGBrush);override;
      procedure FillElips(point,radaii:TAG2DVector;brush:TAGBrush);override;
  end;

  TAGD2D1RenderBitMapGraphicCore=class(TAGD2D1GraphicCore)
    private
      constructor Create(DrawRenderTarget2:ID2D1BitmapRenderTarget;OldCore:TAGD2D1GraphicCore);
    protected
      BM:TAGBitMap;
    public
      destructor Destroy();override;
      function CreateNewRender(W,H:cardinal):TAGGraphicCore;override;
      function GetBtmForDraw:TAGBitMap;override;
      //убираем лишнее
      procedure Resize(W,H:Word);virtual;abstract;
      function Init(W,H:cardinal;hWindow:TAGWindowHandle;under:boolean;fscr:boolean):boolean;virtual;abstract;
  end;
{$ENDIF}

implementation

{$IFDEF D2D1}
{$IFDEF VampyreIL}
function ImageFormatToD2D1(ImFormat:TImageFormat;var D2D1Format:TD2D1BitmapProperties):Boolean;
begin
  D2D1Format.dpiX:=0;
  D2D1Format.dpiY:=0;
  D2D1Format.pixelFormat.alphaMode:=D2D1_ALPHA_MODE_PREMULTIPLIED;
  with D2D1Format.pixelFormat do
    case ImFormat of
      {Indexed formats using palette}
      //ifIndex8:format:=DXGI_FORMAT_P8;
      {ARGB formats}
      ifA8R8G8B8:format:=DXGI_FORMAT_B8G8R8A8_UNORM;
      ifX8R8G8B8:format:=DXGI_FORMAT_B8G8R8X8_UNORM;
      ifA16B16G16R16:format:=DXGI_FORMAT_R16G16B16A16_UNORM;
      {Floating point formats}
      ifR32F:format:=DXGI_FORMAT_R32_FLOAT;
      ifA32R32G32B32F:format:=DXGI_FORMAT_R32G32B32A32_FLOAT;
      ifR16F:format:=DXGI_FORMAT_R16_FLOAT;
      ifA16B16G16R16F:format:=DXGI_FORMAT_R16G16B16A16_FLOAT;
      ifR32G32B32F:format:=DXGI_FORMAT_R32G32B32_FLOAT;
    else
      Exit(false);
    end;
  Result:=true;
end;
{$ENDIF}

procedure TAGD2D1GraphicCore.SetBackColor(color:TAGColor);
begin
  bcolor:=color;
end;

function TAGD2D1GraphicCore.GetBackColor:TAGColor;
begin
  Result:=bcolor;
end;

constructor TAGD2D1GraphicCore.Create();
var
  i:byte;
begin
  for i:=0 to 255 do
    fonts[i]:=nil;
end;

destructor TAGD2D1GraphicCore.Destroy();
var
  i:byte;
begin
  DrawRenderTarget:=nil;
  for i:=0 to 255 do
    fonts[i]:=nil;
end;

procedure TAGD2D1GraphicCore.Init(W,H:cardinal;hWindow:TAGWindowHandle;fscr:boolean);
var
  hwndrtop:D2D1_HWND_RENDER_TARGET_PROPERTIES;
  HwndRenderTarget:ID2D1HwndRenderTarget;
begin
  parrent:=nil;
  with hwndrtop do
  begin
    hwnd:=hWindow;
    pixelSize.width:=W;
    pixelSize.height:=H;
    presentOptions:=D2D1_PRESENT_OPTIONS_IMMEDIATELY;
  end;
  HRESULTCHK(D2D1Factory.CreateHwndRenderTarget(rtop,hwndrtop,HwndRenderTarget));
  HwndRenderTarget._AddRef;
  DrawRenderTarget:=HwndRenderTarget;
  if assigned(initer)then
    initer(self);

  FontsInit();
end;

procedure TAGD2D1GraphicCore.OnPaint();
begin
  if bcolor.D2D1.a=0 then
  begin
    Sleep(16);
    Exit;
  end;
  DrawRenderTarget.BeginDraw;
  DrawRenderTarget.Clear(bcolor.D2D1);

  if Assigned(drawer) then
    drawer(self);

  HRESULTCHK(DrawRenderTarget.EndDraw);
end;

procedure TAGD2D1GraphicCore.Resize(W,H:Word);
var
  r:D2D_SIZE_U;
begin
  r.width:=W;
  r.height:=H;
  HRESULTCHK((DrawRenderTarget as ID2D1HWNDRENDERTARGET).Resize(r));
end;

function TAGD2D1GraphicCore.CreateBrush(color:TAGColor):TAGBrush;
var
  B:^ID2D1SolidColorBrush;
begin
  getmem(B,sizeof(ID2D1SolidColorBrush));
  ZeroMemory(B,sizeof(ID2D1SolidColorBrush));
  HRESULTCHK(DrawRenderTarget.CreateSolidColorBrush(TAGFloatColor(color).D2D1,addr(pr),B^));
  Result.D2D1:=@B^;
end;

function TAGD2D1GraphicCore.CreateBitMap(p:TAGResourceImage):TAGBitMap;
  {$IFDEF VampyreIL}
  function LocalSTDLoad(self:TAGD2D1GraphicCore;pic:TAGResourceImage):TAGBitMap;inline;
  var
    s:D2D1_SIZE_U;
    p:TDynImageDataArray;
    prop:TD2D1BitmapProperties;
  begin
    if not LoadMultiImageFromStream(pic.d,p)then
      raise EImagingError.Create('Error in LoadMultiImageFromStream');
    if not ImageFormatToD2D1(p[0].Format,prop)then
    begin
      if not ConvertImage(p[0],ifA8R8G8B8)then
        raise EImagingError.Create('Error in ConvertImage')
      else
        if not ImageFormatToD2D1(p[0].Format,prop)then
          raise EImagingError.Create('Error in ConvertImage');
    end;
    with p[0] do
    begin
      s.width:=Width;
      s.height:=Height;
    end;
    GetMem(Result.D2D1,sizeof(Result.D2D1^));
    Result.pn^:=0;
    HRESULTCHK(Self.DrawRenderTarget.CreateBitmap(s,p[0].Bits,p[0].Width*4,prop,Result.D2D1^));
    Imaging.FreeImagesInArray(p);
  end;
  {$ENDIF}
  {$IFDEF WIC}
  function LocalWicLoad(self:TAGD2D1GraphicCore;pic:TAGResourceImage):TAGBitMap;inline;
  var
    Decoder:IWICBitmapDecoder;
    Stream:IWICStream;
    Frame:IWICBitmapFrameDecode;
    Converter:IWICFormatConverter;
    p:Pointer;
  begin
    getmem(Result.D2D1,sizeof(Result.D2D1^));
    Result.pn^:=0;
    GetMem(p,pic.d.Size);
    pic.d.Read(p^,pic.d.Size);
    pic.d.Seek(0,soBeginning);
    HRESULTCHK(WICImgFactory.CreateStream(Stream));
    HRESULTCHK(Stream.InitializeFromMemory(p,pic.d.Size));
    HRESULTCHK(WICImgFactory.CreateDecoderFromStream(Stream,ZGUID^,WICDecodeMetadataCacheOnLoad,Decoder));
    HRESULTCHK(Decoder.GetFrame(0,Frame));
    HRESULTCHK(WICImgFactory.CreateFormatConverter(Converter));
    HRESULTCHK(Converter.Initialize(Frame,GUID_WICPixelFormat32bppPBGRA,WICBitmapDitherTypeNone,nil,1,WICBitmapPaletteTypeMedianCut));
    Result.pn^:=0;
    HRESULTCHK(Self.DrawRenderTarget.CreateBitmapFromWicBitmap(Converter,addr(prop),Result.D2D1^));
    FreeMem(p);
  end;
  {$ENDIF}
begin
  case p.encoder of
  AGRIE_None:Result.def:=0;
  {$IFDEF VampyreIL}
    else
        Result:=LocalSTDLoad(self,p);
  {$ELSE}
    {$IFDEF WIC}
      else
          Result:=LocalWicLoad(self,p);
    {$ENDIF}
  {$ENDIF}
  end;
end;

function TAGD2D1GraphicCore.CreateBitMapFromFile(Name:String):TAGBitMap;
{$IFDEF VampyreIL}
var
  s:D2D1_SIZE_U;
  p:TDynImageDataArray;
  prop:TD2D1BitmapProperties;
begin
  if not LoadMultiImageFromFile(Name,p)then
    raise EImagingError.Create('Error in LoadMultiImageFromFile');
  if not ImageFormatToD2D1(p[0].Format,prop)then
  begin
    if not ConvertImage(p[0],ifA8R8G8B8)then
      raise EImagingError.Create('Error in ConvertImage')
    else
      if not ImageFormatToD2D1(p[0].Format,prop)then
        raise EImagingError.Create('Error in ConvertImage');
  end;
  with p[0] do
  begin
    s.width:=Width;
    s.height:=Height;
  end;
  GetMem(Result.D2D1,sizeof(Result.D2D1^));
  Result.pn^:=0;
  HRESULTCHK(DrawRenderTarget.CreateBitmap(s,p[0].Bits,p[0].Width*4,prop,Result.D2D1^));
  Imaging.FreeImagesInArray(p);
{$ELSE}
{$IFDEF WIC}
var
  Decoder:IWICBitmapDecoder;
  Frame:IWICBitmapFrameDecode;
  Converter:IWICFormatConverter;
begin
  HRESULTCHK(WICImgFactory.CreateDecoderFromFilename(PWidechar(Name),ZGUID^,GENERIC_READ,WICDecodeMetadataCacheOnLoad,Decoder));
  HRESULTCHK(Decoder.GetFrame(0,Frame));
  HRESULTCHK(WICImgFactory.CreateFormatConverter(Converter));
  HRESULTCHK(Converter.Initialize(Frame,GUID_WICPixelFormat32bppPBGRA,WICBitmapDitherTypeNone,nil,1,WICBitmapPaletteTypeMedianCut));
  GetMem(Result.D2D1,sizeof(Result.D2D1^));
  Result.pn^:=0;
  HRESULTCHK(DrawRenderTarget.CreateBitmapFromWicBitmap(Converter,addr(prop),Result.D2D1^));
{$ELSE}
begin
  raise EAGGraphicCoreException.Create('No graphic loader lib in TAGD2D1GraphicCore.CreateBitMapFromFile');
{$ENDIF}
{$ENDIF}
end;

function TAGD2D1GraphicCore.CreateNewRender(W,H:cardinal):TAGGraphicCore;
var
  II:ID2D1BitmapRenderTarget;
  a:TD2D1SizeF;
begin
  a.width:=W;
  a.height:=H;
  HRESULTCHK(DrawRenderTarget.CreateCompatibleRenderTarget(addr(a),nil,nil,D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE,II));
  Result:=TAGD2D1RenderBitMapGraphicCore.Create(II,self);
end;

procedure TAGD2D1GraphicCore.Init2D();
begin
end;

procedure TAGD2D1GraphicCore.LoadFont(Name,Local:string;size:single;font:TAGFont);
begin
  if fonts[font]<>nil then
    fonts[font]._Release;
  Pointer(fonts[font]):=nil;
  HRESULTCHK(DwriteFactory.CreateTextFormat(pwidechar(Name),nil,DWRITE_FONT_WEIGHT_REGULAR,
      DWRITE_FONT_STYLE_NORMAL,DWRITE_FONT_STRETCH_NORMAL,size,PWidechar(Local+'-'+Local),fonts[font]));
end;

procedure TAGD2D1GraphicCore.ReleaseBrush(b:TAGBrush);
begin
  b.D2D1._Release;
  FreeMem(b.D2D1);
  b.def:=0;
end;

procedure TAGD2D1GraphicCore.ReleaseBitMap(b:TAGBitMap);
begin
  b.D2D1._Release;
  FreeMem(b.D2D1);
  b.def:=0;
end;

procedure TAGD2D1GraphicCore.DrawPoint(point:TAG2DVector;size:word;brush:TAGBrush);
var
  e:D2D1_ELLIPSE;
begin
  e.point.x:=point.X;
  e.point.y:=point.Y;
  e.radiusX:=size;
  e.radiusY:=e.radiusX;
  DrawRenderTarget.FillEllipse(e,brush.D2D1^);
end;

procedure TAGD2D1GraphicCore.DrawRectangle(Rect:TAGCoord;size:word;brush:TAGBrush);
begin
  DrawRenderTarget.DrawRectangle(Rect.ToTD2D1RectF,brush.D2D1^,size);
end;

procedure TAGD2D1GraphicCore.DrawElips(point,radaii:TAG2DVector;size:word;brush:TAGBrush);
var
  e:D2D1_ELLIPSE;
begin
  e.point.x:=point.X;
  e.point.Y:=point.Y;
  e.radiusX:=radaii.X;
  e.radiusY:=radaii.Y;
  DrawRenderTarget.DrawEllipse(e,brush.D2D1^,size);
end;

procedure TAGD2D1GraphicCore.DrawLine(point0,point1:TAG2DVector;size:word;brush:TAGBrush);
begin
  DrawRenderTarget.DrawLine(TD2DPoint2f(point0),TD2DPoint2f(point1),brush.D2D1^,size);
end;

procedure TAGD2D1GraphicCore.DrawText(text:string;position:TAGCoord;size:word;font:TAGFont;brush:TAGBrush);
begin
  DrawRenderTarget.DrawText(PWideChar(text),Length(text),fonts[font],position.ToTD2D1RectF,brush.D2D1^);
end;

procedure TAGD2D1GraphicCore.DrawBitmap(coord:TAGCoord;bitmap:TAGBitMap;opacity:byte=255;f:boolean=False);
var
  p:TD2D1RectF;
begin
  p:=coord.ToTD2D1RectF;
  if f then
    DrawRenderTarget.DrawBitmap(bitmap.D2D1^,addr(p),opacity/255,D2D1_BITMAP_INTERPOLATION_MODE_LINEAR)
  else
    DrawRenderTarget.DrawBitmap(bitmap.D2D1^,addr(p),opacity/255,D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR);
end;

procedure TAGD2D1GraphicCore.FillRectangle(rect:TAGCoord;brush:TAGBrush);
begin
  DrawRenderTarget.FillRectangle(rect.ToTD2D1RectF,brush.D2D1^);
end;

procedure TAGD2D1GraphicCore.FillElips(point,radaii:TAG2DVector;brush:TAGBrush);
var
  e:D2D1_ELLIPSE;
begin
  e.point.x:=point.X;
  e.point.Y:=point.Y;
  e.radiusX:=radaii.X;
  e.radiusY:=radaii.Y;
  DrawRenderTarget.FillEllipse(e,brush.D2D1^);
end;

constructor TAGD2D1RenderBitMapGraphicCore.Create(DrawRenderTarget2:ID2D1BitmapRenderTarget;OldCore:TAGD2D1GraphicCore);
begin
  parrent:=OldCore;
  inherited Create();
  Getmem(BM.D2D1,sizeof(ID2D1Bitmap));
  BM.pn^:=0;
  DrawRenderTarget2.GetBitmap(BM.D2D1^);
  Self.DrawRenderTarget:=DrawRenderTarget2;
  if Assigned(initer) then
    initer(self);

  FontsInit();
end;

destructor TAGD2D1RenderBitMapGraphicCore.Destroy;
begin
  ReleaseBitMap(BM);
  inherited Destroy;
end;

function TAGD2D1RenderBitMapGraphicCore.CreateNewRender(W,H:cardinal):TAGGraphicCore;
begin
  Result:=parrent.CreateNewRender(W,H);
end;

function TAGD2D1RenderBitMapGraphicCore.GetBtmForDraw:TAGBitMap;
begin
  Result:=BM;
end;

const
  fop:D2D1_FACTORY_OPTIONS=(debugLevel:D2D1_DEBUG_LEVEL_NONE);

initialization
  D2D1CreateFactory({$IFDEF Mulitr}D2D1_FACTORY_TYPE_MULTI_THREADED
                    {$ELSE}D2D1_FACTORY_TYPE_SINGLE_THREADED{$ENDIF},IID_ID2D1Factory,addr(fop),TAGD2D1GraphicCore.D2D1Factory);
  DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED,IID_IDWriteFactory,IUnknown(TAGD2D1GraphicCore.DWriteFactory));
{$ENDIF}
end.
