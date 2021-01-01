unit AGE.Previewlvl;

interface

uses
  System.SysUtils,System.Classes,AG.Levels,AG.Types,AG.Graphic,AG.Windows,AG.Video,AG.Game,System.SyncObjs;

procedure LStart(Core:TAGGraphicCore);
procedure LPaint(Core:TAGGraphicCore);
procedure LKeydown(key:byte;Info:TAGKeyInfo);
procedure LDestroy(Core:TAGGraphicCore);

const
  CPreviewlvlInfo:TAGLevel=(start:LStart;paint:LPaint;Destroy:LDestroy;keydown:LKeydown);
var
  Nexlevel:TAGLevel;

implementation

var
  Video:TAGVideoPlayer;
  loock:boolean=False;
  TrID,TrH:Cardinal; 
  section:TCriticalSection;      
type
  TLTimer=class(TThread)
    strict protected
      procedure Execute;override;
    public             
      Core:TAGGraphicCore;
      constructor Create(ACore:TAGGraphicCore);overload;
      destructor Destroy;overload;override;
  end;

constructor TLTimer.Create(ACore:TAGGraphicCore);
begin
section:=TCriticalSection.Create;
Core:=ACore;
inherited Create;
end;
 
procedure TLTimer.Execute;
begin
section.Enter;    
//sleep(1000);
Nexlevel.init(Core);
section.Leave;
end;

destructor TLTimer.Destroy;
begin
section.Enter;
inherited;
section.Leave;
FreeAndNil(section);
end;

var
  Timer:TLTimer;

procedure LStart(Core:TAGGraphicCore);
begin
  Timer:=TLTimer.Create(Core);  
  Video:=TAGDShowVideoPlayer.Create(TAGWindow.GetWindowFromCore(Core),'..\Data\preview.avi',ddefwndcoord);
  sleep(100);//подгрузка
  Video.play;
end;

procedure LPaint;
begin
{if loock then
  exit;
if Video.GetStay.Runned then
  ReleaseTime
else if time+2000<GetTime then
begin
  loock:=true;         
  Nexlevel.init:=nil;
  LoadLevel(Nexlevel);
end;
sleep(20);}
end;

procedure LKeydown(key:byte;Info:TAGKeyInfo);
begin
if loock then
  exit;
if(Info.Status=TAGKeyStatusPressed)and(key=27)then
begin
  loock:=true;        
  Nexlevel.init:=nil;
  LoadLevel(Nexlevel);
end;
end;

procedure LDestroy(Core:TAGGraphicCore);
begin      
  FreeAndNil(Timer);
  FreeAndNil(Video); 
end;

end.
