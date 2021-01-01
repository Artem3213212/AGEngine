unit AG.Levels;

interface

{$i main.conf}

uses
  {$IFDEF AutoRemap}system.inifiles,{$ENDIF}
  System.SysUtils,System.Classes,
  AG.Game,AG.Types,AG.Graphic,AG.Windows,AG.Logs,AG.Resourcer,AG.Utils,AG.Screen,
  AGE.Time,Winapi.Windows,Winapi.PsAPI;

{$IFDEF Mulitr}{$ENDIF}
{$IFDEF AutoRemap}{$ENDIF}

type
  TAGStartProcedure=TAGOnCreateProcedure;
  TAGTimerProc=reference to procedure;

  TAGLevel=record
    init:TAGOnCreateProcedure;
    start:TAGStartProcedure;
    paint:TAGOnpantProcedure;
    Destroy:TAGOnDestoyProcedure;
    keydown:TAGKeyProc;
    Timed:TAGTimerProc;
  end;

const
  CSTDLevel=0;

var
  Game:TAGGame;
  Images:TAGResourser;
  Currentlevel:TAGLevel;


function BtnCheck(Btn:byte):boolean;inline;

procedure LoadLevel(level:TAGLevel);
procedure FreeGame;

function GameInformationString:string;inline;

implementation

function BtnCheck(Btn:byte):boolean;inline;
begin
{$IFDEF MSWINDOWS}
  Result:=(Word(GetKeyState(Btn))and $8000)=0;
{$ENDIF}
end;

var
  OnPaint:TAGOnpantProcedure;
  OnKey:TAGKeyProc;
  GDestoy:TAGOnDestoyProcedure;
  q:TAGTimerProc;

{$i lib\consts.inc}

procedure LPaint(Core:TAGGraphicCore);
begin
if Assigned(OnPaint) then
  OnPaint(Core);
if Assigned(q)then
  q;
end;

procedure LKey(key:byte;Info:TAGKeyInfo);
begin
  if Assigned(OnKey) then
    OnKey(key,Info);
end;

procedure FreeGame;
begin
  OnPaint:=nil;
  OnKey:=nil;
  if Assigned(GDestoy) then
    GDestoy(Game.GraphicCore);
  FreeAndNil(Game);
end;

{$IFDEF AutoRemap}
var
  Remapdic:array[byte]of byte;

procedure LoadAutoRemap(&file:string);
var
  ini:TInifile;
  s1:TStrings;
  i:integer;
begin
  ini:=TInifile.Create(&file);
  s1:=TStringList.Create;
  ini.ReadSection('Remap',s1);
  for i:=0 to s1.Count-1 do
    Remapdic[StrToInt(s1[i])]:=ini.ReadInteger('Remap',s1[i],StrToInt(s1[i]));
end;

function AutoRemap(key:nativeint):nativeint;
begin
  Result:=Remapdic[key];
end;
{$ENDIF}

procedure LoadLevel(level:TAGLevel);
begin
  TimersLevelInitCallBack;
  Currentlevel:=level;
  if Assigned(Game) then
  begin
    if Assigned(GDestoy) then
      GDestoy(Game.GraphicCore);
    if Assigned(level.init) then
      level.init(Game.GraphicCore);
    if Assigned(level.start) then
      level.start(Game.GraphicCore);
    OnPaint:=level.paint;
    OnKey:=level.keydown;
    GDestoy:=level.Destroy;
  end
  else
  begin
    with level do
      Game:=TAGGame.Create('game','../main.log',init,LPaint,backcolor,TAGScreensInfo.Screens[0],true);
    if Assigned(level.Start) then
      level.start(Game.GraphicCore);
    OnPaint:=level.paint;
    GDestoy:=level.Destroy;
    OnKey:=level.keydown;
    Game.Window.inputproc:=LKey;
    {$IFDEF AutoRemap}
      game.Window.InputRemaper:=AutoRemap;
    {$ENDIF}
  end;
  q:=level.Timed;
end;

function GameInformationString:string;
  function CleverPrint(a:NativeUint):string;inline;
  begin
    Result:=SizeableWordtoStr(a div 1048576,2)+','+SizeableWordtoStr((a div 1024)mod 1024,3)+','+SizeableWordtoStr(a mod 1024,3);
  end;
var
  aa0,aa1:NativeUint;
  i:TSmallBlockTypeState;
  Status:TMemoryManagerState;
  a:_PROCESS_MEMORY_COUNTERS;
begin
{$IFDEF DEBUG}
  GetProcessMemoryInfo(GetCurrentProcess,addr(a),sizeof(a));
  System.GetMemoryManagerState(Status);
  aa0:=Status.TotalAllocatedMediumBlockSize+Status.TotalAllocatedLargeBlockSize;
  aa1:=Status.ReservedMediumBlockAddressSpace+Status.ReservedLargeBlockAddressSpace;

  for i in Status.SmallBlockTypeStates do
  begin
    inc(aa0,i.UseableBlockSize);
    inc(aa1,i.ReservedAddressSpace);
  end;
  if Assigned(Game) then
    Result:=
      'FPS:        '+IntToStr(Game.Window.FPS.NowFPS)+sLineBreak+
      'WorkingMem: '+CleverPrint(a.WorkingSetSize)+sLineBreak+
      'AllocateMem:'+CleverPrint(aa0)+sLineBreak+
      'ReservedMem:'+CleverPrint(aa0)+sLineBreak;
{$ENDIF}
end;

{$IFDEF AutoRemap}
var
  i:byte;
{$ENDIF}

initialization
  {$IFDEF AutoRemap}
    for i:=0 to 255 do
      Remapdic[i]:=i;
    LoadAutoRemap('../Data/InputDefault.ini');
    LoadAutoRemap('../Data/Input.ini');
  {$ENDIF}
  Images:=TAGResourser.Create(CDataDir+'img.zip');
end.
