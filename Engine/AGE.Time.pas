unit AGE.Time;

interface

uses
  AG.Types,Winapi.Windows;

type
  TAGETime=class abstract
    protected
      function GetTime:cardinal;virtual;abstract;
    public
      property Time:cardinal read GetTime;
  end;

  TAGEPcTime=class (TAGETime)
    protected
      function GetTime:cardinal;override;
  end;

  TAGEGameTime=class (TAGETime)
    private class var
      InitTime:cardinal;
    protected
      function GetTime:cardinal;override;
  end;

  TAGELevelTime=class (TAGETime)
    private class var
      InitTime:cardinal;
    protected
      function GetTime:cardinal;override;
  end;

  TAGEZeroTime=class (TAGETime)
    protected
      function GetTime:cardinal;override;
  end;

procedure TimersLevelInitCallBack;

implementation

{TAGEPcTime}

function TAGEPcTime.GetTime:cardinal;
begin
Result:=GetTickCount;
end;

{TAGEGameTime}

function TAGEGameTime.GetTime:cardinal;
begin
Result:=GetTickCount-InitTime;
end;

{TAGELevelTime}

function TAGELevelTime.GetTime:cardinal;
begin
Result:=GetTickCount-InitTime;
end;

procedure TimersLevelInitCallBack;
begin
TAGELevelTime.InitTime:=GetTickCount;
end;

{TAGEZeroTime}

function TAGEZeroTime.GetTime:cardinal;
begin
Result:=0;
end;

initialization
TAGEGameTime.InitTime:=GetTickCount;
end.
