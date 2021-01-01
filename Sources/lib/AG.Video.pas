unit AG.Video;

interface

{$i main.conf}

uses
  System.Sysutils,winapi.windows,AG.Graphic,AG.Windows,AG.Types
  {$IFDEF DShow},
  Winapi.DirectShow9,Winapi.ActiveX
  {$ENDIF};

type
  TAGVideoStay=record
    Runned:boolean;
  end;

  TAGVideoPlayer=class
    private
    protected
    public
      function GetStay:TAGVideoStay;virtual;abstract;
      procedure play;virtual;abstract;
  end;

  {$IFDEF DShow}
  TAGDShowVideoPlayer=class(TAGVideoPlayer)
    private
    protected
      GraphBuilder:IGraphBuilder;
      MediaControl:IMediaControl; //управление графом
      MediaEvent:IMediaEvent; //обработчик событий
      VideoWindow:IVideoWindow; //задает окно дл€ вывода
      MediaPosition:IMediaPosition; //позици€ проигрывани€
      BasicAudio:IBasicAudio; //управление звуком
    public
      constructor Create(Window:TAGWindow;s:string;coord:TAGScreenCoord);
      function GetStay:TAGVideoStay;override;
      procedure play;override;
      destructor Destroy;override;
  end;
  {$ENDIF}

implementation
            
{$IFDEF DShow}
function GetPin(Filter:IBaseFilter;pinDir:PIN_DIRECTION):IPin;
var
  pEnum:IEnumPins;
  PinDirThis:PIN_DIRECTION;
begin
Filter.EnumPins(pEnum);
while pEnum.Next(1,Result,nil)=S_OK do
begin
  Result.QueryDirection(PinDirThis);
  if pinDir=PinDirThis then
    break;
end;
pEnum._Release;
end;

constructor TAGDShowVideoPlayer.Create(Window:TAGWindow;s:string;coord:TAGScreenCoord);
begin
  CoCreateInstance(CLSID_FilterGraph,nil,CLSCTX_INPROC_SERVER,IID_IGraphBuilder,GraphBuilder);

  GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
  GraphBuilder.QueryInterface(IID_IMediaEvent,MediaEvent);
  GraphBuilder.QueryInterface(IID_IVideoWindow,VideoWindow);
  GraphBuilder.QueryInterface(IID_IBasicAudio,BasicAudio);
  GraphBuilder.QueryInterface(IID_IMediaPosition,MediaPosition);
  GraphBuilder.RenderFile(PWideChar(s),'');
  VideoWindow.Put_Owner(Window.Handle);//”станавливаем "владельца" окна, в нашем случае Panel1
  VideoWindow.Put_WindowStyle(WS_CHILD OR WS_CLIPSIBLINGS);//—тиль окна

  //VideoWindow.put_MessageDrain(Window.hWindow);//указываем что Panel1 будет получать сообщени€ видео окна
  VideoWindow.SetWindowPosition(0,0,coord.W,coord.H);//размеры
end;

function TAGDShowVideoPlayer.GetStay:TAGVideoStay;
var
  a:_FilterState;
  b,c:TRefTime;
begin
MediaControl.GetState(0,a);
MediaPosition.get_CurrentPosition(b);
MediaPosition.get_StopTime(c);
Result.Runned:=(a=State_Running)and(b<>c);
end;

procedure TAGDShowVideoPlayer.play;
begin
MediaControl.Run;
end;

destructor TAGDShowVideoPlayer.Destroy;
begin
BasicAudio._Release;
Pointer(BasicAudio):=nil;
MediaPosition._Release;
Pointer(MediaPosition):=nil;
VideoWindow._Release;
Pointer(VideoWindow):=nil;
MediaEvent._Release;
Pointer(MediaEvent):=nil;
MediaControl._Release;
Pointer(MediaControl):=nil;
GraphBuilder._Release;
Pointer(GraphBuilder):=nil;
end;
{$ENDIF}

end.
