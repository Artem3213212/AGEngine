unit AG.Graphic.Parallel;

interface

{$i main.conf}

uses
  AG.Graphic,System.Classes,System.Generics.Collections;

type
  TAGParallelGraphicCore=class abstract(TAG3DGraphicCore)
    strict protected type
      TAGGraphicWork=Reference to procedure();
      TAGMathWork=Reference to function():TAGGraphicWork;
      TAGWork=record
        Math:Boolean;
        MW:TAGMathWork;
        GW:TAGGraphicWork;
      end;
    strict private type
      TAGMathThread=class(TThread)
        protected type
          TAGGraphicThread=class(TThread)
            protected
              TotalDuedWork:UInt64;
              procedure Execute;override;
            public
              WorkQueue:TThreadedQueue<TAGGraphicWork>;
              constructor Create();
          end;
          procedure Execute;override;
        public
          GraphicThread:TAGGraphicThread;
          WorkQueue:TThreadedQueue<TAGWork>;
          constructor Create();
      end;
      var
        MathThread:TAGMathThread;
    strict protected
      TotalStartedWork:UInt64;
      procedure DoMath(Work:TAGMathWork);
      procedure DoMathSync(Work:TAGMathWork);
      procedure DoGraphic(Work:TAGGraphicWork);
      procedure DoGraphicSync(Work:TAGGraphicWork);
    public
      constructor Create();
      destructor Destroy();override;
      procedure Flush();
  end;

const
  QueueLen=10;

implementation

{TAGParallelGraphicCore}

{TAGParallelGraphicCore.TAGGraphicThread}

{TAGParallelGraphicCore.TAGMathThread.TAGGraphicThread}
constructor TAGParallelGraphicCore.TAGMathThread.TAGGraphicThread.Create();
begin
  inherited Create(false);
  TotalDuedWork:=0;
  WorkQueue:=TThreadedQueue<TAGGraphicWork>.Create(QueueLen);
end;

procedure TAGParallelGraphicCore.TAGMathThread.TAGGraphicThread.Execute();
begin
  while not Terminated do
  begin
    WorkQueue.PopItem()();
    inc(TotalDuedWork);
    Sleep(0);
  end;
end;

constructor TAGParallelGraphicCore.TAGMathThread.Create();
begin
  inherited Create(false);
  GraphicThread:=TAGGraphicThread.Create();
  WorkQueue:=TThreadedQueue<TAGWork>.Create(QueueLen);
end;

procedure TAGParallelGraphicCore.TAGMathThread.Execute();
var
  Curr:TAGWork;
begin
  while not Terminated do
  begin
    Curr:=WorkQueue.PopItem();
    if Curr.Math then
      GraphicThread.WorkQueue.PushItem(Curr.MW())
    else
      GraphicThread.WorkQueue.PushItem(Curr.GW);
    Sleep(0);
  end;
end;

procedure TAGParallelGraphicCore.DoMath(Work:TAGMathWork);
var
  Curr:TAGWork;
begin
  inc(TotalStartedWork);
  Curr.Math:=true;
  Curr.MW:=Work;
  MathThread.WorkQueue.PushItem(Curr);
end;

procedure TAGParallelGraphicCore.DoMathSync(Work:TAGMathWork);
var
  Num:Integer;
begin
  DoMath(Work);
  Num:=TotalStartedWork;
  while Num>MathThread.GraphicThread.TotalDuedWork do
    TThread.Sleep(0);
end;

procedure TAGParallelGraphicCore.DoGraphic(Work:TAGGraphicWork);
var
  Curr:TAGWork;
begin
  inc(TotalStartedWork);
  Curr.Math:=false;
  Curr.GW:=Work;
  MathThread.WorkQueue.PushItem(Curr);
end;

procedure TAGParallelGraphicCore.DoGraphicSync(Work:TAGGraphicWork);
var
  Num:Cardinal;
begin
  DoGraphic(Work);
  Num:=TotalStartedWork;
  while Num>MathThread.GraphicThread.TotalDuedWork do
    TThread.Sleep(0);
end;

constructor TAGParallelGraphicCore.Create();
begin
  inherited Create();
  MathThread:=TAGMathThread.Create;
  TotalStartedWork:=0;
end;

destructor TAGParallelGraphicCore.Destroy();
begin
  Flush();
  MathThread.WorkQueue.DoShutDown;
  MathThread.Terminate;
  while not MathThread.Finished do
  begin
    TThread.Sleep(0);
  end;
  MathThread.GraphicThread.WorkQueue.DoShutDown;
  MathThread.GraphicThread.Terminate;
  while not MathThread.GraphicThread.Finished do
  begin
    TThread.Sleep(0);
  end;
    TThread.Sleep(1000);
  inherited;
end;

procedure TAGParallelGraphicCore.Flush();
begin
  while(MathThread.WorkQueue.QueueSize<>0)or(MathThread.GraphicThread.WorkQueue.QueueSize<>0)do
  begin
    TThread.Sleep(0);
  end;
end;

end.
