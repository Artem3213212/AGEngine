unit AG.Physic;

interface

uses
  System.SysUtils,System.Math,AG.Types,System.Generics.Collections{$IFDEF Debug},AG.Graphic{$ENDIF};

type
  TAGFloat=Extended;
  TAGPhysicVector=record
    X,Y:TAGFloat;
    function length:TAGFloat;inline;
    function &nil:boolean;inline;
    procedure RoundTo(sym:smallint);inline;
    class operator Multiply(A:TAGPhysicVector;B:Integer):TAGPhysicVector;inline;
    class operator Multiply(A:TAGPhysicVector;B:TAGFloat):TAGPhysicVector;inline;
    class operator Multiply(A:Integer;B:TAGPhysicVector):TAGPhysicVector;inline;
    class operator Multiply(A:TAGFloat;B:TAGPhysicVector):TAGPhysicVector;inline;
    class operator Add(A,B:TAGPhysicVector):TAGPhysicVector;inline;
    class operator Subtract(A,B:TAGPhysicVector):TAGPhysicVector;inline;
    class operator Divide(A:TAGPhysicVector;B:Integer):TAGPhysicVector;inline;
    class operator Divide(A:TAGPhysicVector;B:TAGFloat):TAGPhysicVector;inline;
    class operator Implicit(A:TAGScreenVector):TAGPhysicVector;inline;
    class operator Implicit(A:TAGPhysicVector):TAGScreenVector;inline;
    class operator Round(A:TAGPhysicVector):TAGScreenVector;inline;
    constructor Create(X,Y:TAGFloat);
  end;
  PTAGPhysicVector=^TAGPhysicVector;
  const Cnil:TAGPhysicVector=(X:0;Y:0);
type
  TAGPointList=array of TAGPhysicVector;
  TAGPointListHelper=record helper for TAGPointList
    procedure Clear;
    procedure Add(const A:TAGPhysicVector);
    procedure AddRectangle(const size:TAGScreenVector);
  end;

  TAGPhysicAddProc=procedure(var Acc:TAGPhysicVector;spd:TAGPhysicVector;dt:TAGFloat);
  TAGPhysicAddObjProc=procedure(var Acc:TAGPhysicVector;spd:TAGPhysicVector;dt:TAGFloat)of object;

  TAGPhysic=class
    private
      oldtime:Cardinal;
      type
        TPhObj=record
          pos:PTAGScreenVector;
          max,spd:TAGPhysicVector;
          pointlist:TAGPointList;
          constructor Create(Apr:TAGPhysicAddProc;Apos:PTAGScreenVector;Amax:TAGPhysicVector;pointlist:TAGPointList);overload;
          constructor Create(Apr:TAGPhysicAddObjProc;Apos:PTAGScreenVector;Amax:TAGPhysicVector;pointlist:TAGPointList);overload;
          case byte of
            0:(pr:TAGPhysicAddProc);
            1:(opr:TAGPhysicAddObjProc);
        end;
        TPhStatic=record
          miu:TAGFloat;
          constructor Create(AX0,AY0,AX1,AY1:integer;Amiu:TAGFloat);overload;
          constructor Create(AA,AB:TAGScreenVector;Amiu:TAGFloat);overload;
          case byte of
            0:(X0,Y0,X1,Y1:integer);
            1:(A,B:TAGScreenVector);
        end;
      var
        PhObjList:TList<TPhObj>;
        PhStaticList:TList<TPhStatic>;
    public
      BaseAcc:TAGPhysicVector;
      procedure Add(X0,Y0,X1,Y1:integer;Amiu:TAGFloat);overload;virtual;
      procedure Add(Coord:TAGScreenCoord;Amiu:TAGFloat;AddX:boolean=true;AddY:boolean=true);overload;virtual;
      procedure Add(pr:TAGPhysicAddProc;var pos:TAGScreenVector;max:TAGPhysicVector;pointlist:TAGPointList);overload;virtual;
      procedure Add(pr:TAGPhysicAddObjProc;var pos:TAGScreenVector;max:TAGPhysicVector;pointlist:TAGPointList);overload;virtual;
      procedure Tic(Time:Cardinal);
      {$IFDEF Debug}procedure DebugDraw(Core:TAGGraphicCore;a:TAGScreenVector;br:TAGbrush);{$ENDIF}
      constructor Create(Time:Cardinal);
      destructor Destroy();override;
  end;

implementation

const
  MSpF=1000 div 60;

procedure TAGPointListHelper.Clear;
begin
setlength(self,0);
end;

procedure TAGPointListHelper.Add(const A:TAGPhysicVector);
var
 b:cardinal;
begin
b:=length(self);
setlength(self,b+1);
self[b]:=A;
end;

procedure TAGPointListHelper.AddRectangle(const size:TAGScreenVector);
var
 b:cardinal;
 c:TAGPhysicVector;
begin
c:=TAGPhysicVector(size)/2;
b:=length(self);
setlength(self,b+4);
self[b]:=c;
c.X:=-c.X;
self[b+1]:=c;
c.Y:=-c.Y;
self[b+2]:=c;
c.X:=-c.X;
self[b+3]:=c;
end;

function TAGPhysicVector.length:TAGFloat;
begin
Result:=sqrt(sqr(self.X)+sqr(self.Y));
end;

function TAGPhysicVector.&nil:boolean;
begin
Result:=(X=0)and(Y=0);
end;

procedure TAGPhysicVector.RoundTo(sym:smallint);
begin
X:=System.Math.RoundTo(X,sym);
Y:=System.Math.RoundTo(Y,sym);
end;

class operator TAGPhysicVector.Multiply(A:TAGPhysicVector;B:Integer):TAGPhysicVector;
begin
Result.X:=B*A.X;
Result.Y:=B*A.Y;
end;

class operator TAGPhysicVector.Multiply(A:TAGPhysicVector;B:TAGFloat):TAGPhysicVector;
begin
Result.X:=B*A.X;
Result.Y:=B*A.Y;
end;

class operator TAGPhysicVector.Multiply(A:Integer;B:TAGPhysicVector):TAGPhysicVector;
begin
Result:=B*A;
end;

class operator TAGPhysicVector.Multiply(A:TAGFloat;B:TAGPhysicVector):TAGPhysicVector;
begin
Result:=B*A;
end;

class operator TAGPhysicVector.Add(A,B:TAGPhysicVector):TAGPhysicVector;
begin
Result.X:=B.X+A.X;
Result.Y:=B.Y+A.Y;
end;

class operator TAGPhysicVector.Subtract(A,B:TAGPhysicVector):TAGPhysicVector;
begin
Result.X:=B.X-A.X;
Result.Y:=B.Y-A.Y;
end;

class operator TAGPhysicVector.Divide(A:TAGPhysicVector;B:Integer):TAGPhysicVector;
begin
Result.X:=A.X/B;
Result.Y:=A.Y/B;
end;

class operator TAGPhysicVector.Divide(A:TAGPhysicVector;B:TAGFloat):TAGPhysicVector;
begin
Result.X:=A.X/B;
Result.Y:=A.Y/B;
end;

class operator TAGPhysicVector.Implicit(A:TAGScreenVector):TAGPhysicVector;
begin
Result.X:=A.X;
Result.Y:=A.Y;
end;

class operator TAGPhysicVector.Implicit(A:TAGPhysicVector):TAGScreenVector;
begin
Result:=Round(A);
end;

class operator TAGPhysicVector.Round(A:TAGPhysicVector):TAGScreenVector;
begin
Result.X:=Round(A.X);
Result.Y:=Round(A.Y);
end;

constructor TAGPhysicVector.Create(X,Y:TAGFloat);
begin
self.X:=X;
self.Y:=Y;
end;

constructor TAGPhysic.TPhStatic.Create(AX0,AY0,AX1,AY1:integer;Amiu:TAGFloat);
begin
X0:=AX0;
Y0:=AY0;
X1:=AX1;
Y1:=AY1;
miu:=Amiu;
end;

constructor TAGPhysic.TPhStatic.Create(AA,AB:TAGScreenVector;Amiu:TAGFloat);
begin
A:=AA;
B:=AB;
miu:=Amiu;
end;

constructor TAGPhysic.TPhObj.Create(Apr:TAGPhysicAddProc;Apos:PTAGScreenVector;Amax:TAGPhysicVector;pointlist:TAGPointList);
begin
pr:=Apr;
pos:=Apos;
self.pointlist:=pointlist;
max:=Amax;
spd:=TAGScreenVector.Create(0,0);
end;

constructor TAGPhysic.TPhObj.Create(Apr:TAGPhysicAddObjProc;Apos:PTAGScreenVector;Amax:TAGPhysicVector;pointlist:TAGPointList);
begin
opr:=Apr;
pos:=Apos;
self.pointlist:=pointlist;
max:=Amax;
spd:=TAGScreenVector.Create(0,0);
end;

constructor TAGPhysic.Create(Time:Cardinal);
begin
PhStaticList:=TList<TPhStatic>.Create;
PhStaticList.Clear;
PhObjList:=TList<TPhObj>.Create;
PhObjList.Clear;
oldtime:=Time;
end;

procedure TAGPhysic.Add(X0,Y0,X1,Y1:integer;Amiu:TAGFloat);
begin
PhStaticList.Add(TPhStatic.Create(X0,Y0,X1,Y1,Amiu));
end;

procedure TAGPhysic.Add(Coord:TAGScreenCoord;Amiu:TAGFloat;AddX,AddY:boolean);
begin
if not AddX then
  Coord.W:=0;
if not AddY then
  Coord.H:=0;
PhStaticList.Add(TPhStatic.Create(Coord.X,Coord.Y,Coord.X+Coord.W,Coord.Y+Coord.H,Amiu));
end;

procedure TAGPhysic.Add(pr:TAGPhysicAddProc;var pos:TAGScreenVector;max:TAGPhysicVector;pointlist:TAGPointList);
begin
//PhObjList.Add(TPhObj.Create(pr,addr(pos),max,H,W));
end;

procedure TAGPhysic.Add(pr:TAGPhysicAddObjProc;var pos:TAGScreenVector;max:TAGPhysicVector;pointlist:TAGPointList);
begin
PhObjList.Add(TPhObj.Create(pr,addr(pos),max,pointlist));
end;

{$IFDEF Debug}
procedure TAGPhysic.DebugDraw(Core:TAGGraphicCore;a:TAGScreenVector;br:TAGbrush);
var
  i:TPhStatic;
begin
for i in PhStaticList.List do
  Core.DrawLine(a+i.A,A+i.B,3,br);
end;
{$ENDIF}

procedure TAGPhysic.Tic(Time:Cardinal);
  function min(a,b:TAGFloat):TAGFloat;inline;
  begin
  if a<=b then
    Result:=a
  else
    Result:=b;
  end;
  function max(a,b:TAGFloat):TAGFloat;inline;
  begin
  if a>=b then
    Result:=a
  else
    Result:=b;
  end;
  function tomax(const spd,max:TAGPhysicVector):TAGPhysicVector;inline;
    function min(a,b:TAGFloat):TAGFloat;inline;
    begin
    if a>=0 then
    begin
      if a>b then
        Result:=b
      else
        Result:=a;
    end
    else
    begin
      if -a>b then
        Result:=-b
      else
        Result:=a;
    end;
    end;
  begin
    Result.X:=min(spd.X,max.X);
    Result.Y:=min(spd.Y,max.Y);
  end;
  {function tomax2(const spd,max:TAGPhysicVector):TAGPhysicVector;inline;
    function min(a,b:TAGFloat):TAGFloat;inline;
    begin
    if b>=0 then
    begin
      if a<0 then
        Result:=0
      else if a>b then
        Result:=b
      else
        Result:=a;
    end
    else
    begin
      if a>0 then
        Result:=0
      else if a<b then
        Result:=b
      else
        Result:=a;
    end;
    end;
  begin
    Result.X:=min(spd.X,max.X);
    Result.Y:=min(spd.Y,max.Y);
  end;        }
  function CountDt(A,B:TAGScreenVector;v:TAGPhysicVector;X:TAGScreenVector):TAGFloat;inline;
  var
    b2,c2:TAGFloat;
  begin
    B:=B-A;
    X:=X-A;
    b2:=(v.X*B.Y)-(v.Y*B.X);
    c2:=(X.X*B.Y)-(X.Y*B.X);
    if b2<>0 then
      Result:=-c2/b2
    else if c2=0 then
      Result:=0
    else
      Result:=-1;
    if Result>=0 then
    begin
      A:=X+Result*V;
      if (A.X<=max(0,B.X))and(A.Y<=max(0,B.Y))
      and(A.X>=min(0,B.X))and(A.Y>=min(0,B.Y))then
      else Result:=-1;
    end;
  end;
  function WherePoint(a,b,p:TAGScreenVector):integer;
  var
    s:TAGFloat;
  begin
    s:=(b.x-a.x)*(p.y-a.y)-(b.y-a.y)*(p.x-a.x);
    if s>0 then
      WherePoint:=1
    else if s<0 then
      WherePoint:=-1
    else
      WherePoint:=0;
  end;
var
  c,c0,i,i0,l,ii,ii0:integer;
  l0:TList<integer>;
  Acc,temp,i1,l1:TAGPhysicVector;
  t,temp0,temp1,temp2,dt,mindt:TAGFloat;
begin
t:=(Time-oldtime)*60/1000;
if t=0 then
  exit;
oldtime:=time;
c:=PhObjList.Count-1;
for i:=0 to c do
begin
  with PhObjList.List[i] do
  begin
    Acc:=BaseAcc;
    opr(Acc,spd,t);
    l0:=TList<integer>.Create;
    l0.Clear;

    spd.RoundTo(-5);
    spd:=tomax(spd+Acc*t,max);
    while True do
    begin
      l:=-1;
      c0:=PhStaticList.Count-1;
      mindt:=t;
      for i0:=0 to c0 do
      begin
        if l0.Contains(i0)then
          Continue;
        for i1 in pointlist do
        begin
          dt:=CountDt(PhStaticList.Items[i0].A,PhStaticList.Items[i0].B,spd,pos^+i1);
          if (dt>=0)and(dt<mindt)then
          begin
            mindt:=dt;
            l:=i0;
            l1:=i1;
          end;
        end;
      end;
      if mindt<t then
      begin
        pos^:=pos^+spd*mindt;
        t:=t-mindt;
        l0.Add(l);

        ii:=WherePoint(PhStaticList.Items[l].A,PhStaticList.Items[l].B,pos^);
        i0:=WherePoint(PhStaticList.Items[l].A,PhStaticList.Items[l].B,pos^+l1+spd*t);
        if ii=i0 then
          continue;

        if spd.&nil then
          break
        else
        begin
          temp:=PhStaticList.Items[l].B-PhStaticList.Items[l].A;
          if temp.X=0 then
            if spd.X=0 then
              if spd.Y>0 then
                if temp.Y>0 then
                  temp0:=0
                else
                  temp0:=-pi
              else
                if temp.Y>0 then
                  temp0:=pi
                else
                  temp0:=0
            else
              if temp.Y>0 then
                temp0:=pi/2-ArcTan(spd.Y/spd.X)
              else
                temp0:=-pi/2-ArcTan(spd.Y/spd.X)
          else
            if spd.X=0 then
              if spd.Y>0 then
                temp0:=ArcTan(temp.Y/temp.X)-pi/2
              else
                temp0:=ArcTan(temp.Y/temp.X)+pi/2
            else
              temp0:=ArcTan(temp.Y/temp.X)-ArcTan(spd.Y/spd.X);
          temp1:=cos(temp0);
          temp2:=sin(temp0)*PhStaticList.Items[l].miu;
          if abs(temp1)<=abs(temp2) then
            spd:=Cnil
          else
            if temp2=0 then
              continue
            else
              if temp2>0 then
                if temp1<0 then
                  spd:=temp/temp.length*spd.length*(temp1-temp2)
                else
                  spd:=temp/temp.length*spd.length*(-temp1+temp2)
              else
                if temp1<0 then
                  spd:=temp/temp.length*spd.length*(temp1-temp2)
                else
                  spd:=temp/temp.length*spd.length*(+temp1+temp2)
        end;
      end
      else
      begin
        spd:=tomax(spd,max);
        pos^:=pos^+spd*t;
        break;
      end;
    end;
    FreeAndNil(l0);
  end;
end;
end;

destructor TAGPhysic.Destroy();
begin
PhStaticList.Destroy;
PhObjList.Destroy;
end;

end.
