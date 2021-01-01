unit AG.Acelrator;

interface

{$i lib\main.conf}

{$IFDEF Logs}{$ENDIF}

uses
  System.SysUtils,CL21,CL21Types{,CL,CL_dx9_media_sharing,CL_ext,CL_gl,CL_gl_ext,CL_platform,clext,DelphiCL,
  oclUtils,SimpleImageLoader}{$IFDEF Logs},AG.Logs{$ENDIF};

type
  TAGACDev=class
    private
    protected
    public
      &platform:TCL_platform_id;
      device:TCL_Device_ID;
      constructor Create({$IFDEF Logs}log:TAGLog{$ENDIF});overload;//override;
  end;

implementation

function AGACDevInfoUnder(pp:PCL_platform_id;val:cardinal{$IFDEF Logs};s:widestring;log:TAGLog{$ENDIF}):pansichar;
var
  p:size_t;
begin
getmem(Result,200);
clGetPlatformInfo(pp^,val,200,Result,p);
{$IFDEF Logs}log.Write(s+Result);{$ENDIF}
end;

procedure AGACDevInfo(pp:PCL_platform_id{$IFDEF Logs};log:TAGLog{$ENDIF});
begin
{$IFDEF Logs}
log.Write('Параметры платформы:');
log.Tab();
{$ENDIF}
freemem(AGACDevInfoUnder(pp,CL_PLATFORM_PROFILE   {$IFDEF Logs},'Профиль:    ',log{$ENDIF}));
freemem(AGACDevInfoUnder(pp,CL_PLATFORM_VERSION   {$IFDEF Logs},'Версия:     ',log{$ENDIF}));
freemem(AGACDevInfoUnder(pp,CL_PLATFORM_NAME      {$IFDEF Logs},'Имя:        ',log{$ENDIF}));
freemem(AGACDevInfoUnder(pp,CL_PLATFORM_VENDOR    {$IFDEF Logs},'Ключ:       ',log{$ENDIF}));
freemem(AGACDevInfoUnder(pp,CL_PLATFORM_EXTENSIONS{$IFDEF Logs},'Расширения: ',log{$ENDIF}));
{$IFDEF Logs}log.UnTab();{$ENDIF}
end;

constructor TAGACDev.Create({$IFDEF Logs}log:TAGLog{$ENDIF});
var
  p:TCL_uint;
  ppl:PCL_platform_id;
  pdv:PCL_device_id;
  i:byte;
begin
getmem(ppl,sizeof(NativeUInt)*8);
for i:=0 to 7 do
begin
  getmem(ppl^,sizeof(NativeUInt));
  inc(ppl);
end;
dec(ppl,8);
clGetPlatformIDs(7,ppl^,p);
for i:=0 to p-1 do
begin
  {$IFDEF Logs}log.Write('Платформа '+inttostr(i)+':');{$ENDIF}
  AGACDevInfo(ppl{$IFDEF Logs},log{$ENDIF});
  inc(ppl);
end;
{$IFDEF Logs}log.Write('Испльзуется платформа 0.');{$ENDIF}
&platform:=ppl^;
for i:=0 to 7 do
begin
  freemem(ppl^);
  inc(ppl);
end;
dec(ppl,8);
FreeMem(ppl);
getmem(pdv,sizeof(NativeUInt)*8);
for i:=0 to 7 do
begin
  getmem(pdv^,sizeof(NativeUInt));
  inc(pdv);
end;
dec(pdv,8);
clGetDeviceIDs(&platform,cl21.CL_DEVICE_TYPE_ALL,8,pdv^,p);
for i:=0 to 7 do
begin
  freemem(pdv^);
  inc(pdv);
end;
dec(pdv,8);
FreeMem(pdv);

end;

initialization
//InitOpenCL();
end.
