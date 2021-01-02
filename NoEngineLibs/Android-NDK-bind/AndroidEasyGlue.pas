{$MODE Delphi}
unit AndroidEasyGlue;

interface

uses SysUtils,log,input,rect,jni,native_window;

type
  EAEGException=Exception;
  TAEGOnWindowResize=procedure(H,W:Cardinal);  
  TAEGOnStart=procedure();
  TAEGOnPaint=procedure();  
  TAEGOnMouseInput=procedure(x,y:integer);  
  TAEGOnKeyDown=procedure(Key:byte;Repeats:Word);
  TAEGOnKeyUp=procedure(Key:byte);
  TAEGOnFinish=procedure();

procedure AEGWindowCreate(jenv:PJNIEnv;obj:jobject;surface:jobject);cdecl;
procedure AEGWindowResize(jenv:PJNIEnv;obj:jobject;H,W:Cardinal);cdecl;
procedure AEGStart(jenv:PJNIEnv;obj:jobject);cdecl;
procedure AEGPaint(jenv:PJNIEnv;obj:jobject);cdecl;  
procedure AEGMouseUp(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl;
procedure AEGMouseMove(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl;
procedure AEGMouseDown(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl; 
procedure AEGKeyUp(jenv:PJNIEnv;obj:jobject;key:Integer);cdecl;
procedure AEGKeyDown(jenv:PJNIEnv;obj:jobject;key,repeats:Integer);cdecl;
procedure AEGFinish(jenv:PJNIEnv;obj:jobject);cdecl;

var
  AEGCurrWindow:PANativeWindow=nil;
  AEGCurrWindowW,AEGCurrWindowH:Cardinal;
  AEGAndroidAppStarted:Boolean=false;
  //CallBacks
  AEGOnWindowResize:TAEGOnWindowResize=nil;
  AEGOnStart:TAEGOnStart=nil;
  AEGOnPaint:TAEGOnPaint=nil;    
  AEGOnMouseUp:TAEGOnMouseInput=nil;   
  AEGOnMouseMove:TAEGOnMouseInput=nil;
  AEGOnMouseDown:TAEGOnMouseInput=nil;    
  AEGOnKeyUp:TAEGOnKeyUp=nil;
  AEGOnKeyDown:TAEGOnKeyDown=nil;
  AEGOnFinish:TAEGOnFinish=nil;


implementation

function ANativeWindow_fromSurface(env:PJNIEnv;surface:jobject):PANativeWindow;cdecl;external 'libandroid.so';

{$i AndroidCodetable.inc}

{type
 ppthread_t = ^pthread_t;
 ppthread_attr_t = ^pthread_attr_t;
 ppthread_mutex_t = ^pthread_mutex_t;
 ppthread_cond_t = ^pthread_cond_t;
 ppthread_mutexattr_t = ^pthread_mutexattr_t;
 ppthread_condattr_t = ^pthread_condattr_t;

 __start_routine_t = pointer;

const
 PTHREAD_CREATE_DETACHED = 1;

function pthread_create(var thread:pthread_t; attr:ppthread_attr_t;entry: __start_routine_t;arg:pointer):longint;cdecl;external 'libc.so';
function pthread_attr_init(__attr:ppthread_attr_t):longint;cdecl;external 'libc.so';
function pthread_attr_setdetachstate(__attr:ppthread_attr_t; __detachstate:longint):longint;cdecl;external 'libc.so';
function pthread_mutex_init(__mutex:ppthread_mutex_t; __mutex_attr:ppthread_mutexattr_t):longint;cdecl;external 'libc.so';
function pthread_mutex_destroy(__mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';
function pthread_mutex_lock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
function pthread_mutex_unlock(__mutex: ppthread_mutex_t):longint;cdecl;external 'libc.so';
function pthread_cond_init(__cond:ppthread_cond_t; __cond_attr:ppthread_condattr_t):longint;cdecl;external 'libc.so';
function pthread_cond_destroy(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
function pthread_cond_signal(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
function pthread_cond_broadcast(__cond:ppthread_cond_t):longint;cdecl;external 'libc.so';
function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';}

procedure AEGWindowCreate(jenv:PJNIEnv;obj:jobject;surface:jobject);cdecl;
begin
  try
    if Assigned(AEGCurrWindow) then
      raise EAEGException.Create('Error double WindowCreate call.')
    else
      AEGCurrWindow:=ANativeWindow_fromSurface(jenv,surface)
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGWindowResize(jenv:PJNIEnv;obj:jobject;H,W:Cardinal);cdecl;
begin
  try
    AEGCurrWindowW:=W;
    AEGCurrWindowH:=H;
    {$IFDEF DEBUG}LOGI(ANDROID_LOG_INFO,'Info',PChar('WindowSize W:'+IntToStr(W)+' H:'+IntToStr(H)));{$ENDIF}
    if AEGAndroidAppStarted and Assigned(AEGOnWindowResize)then
      AEGOnWindowResize(W,H);    
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;     

procedure AEGStart(jenv:PJNIEnv;obj:jobject);cdecl;
begin    
  try
    if Assigned(AEGOnStart) then
      AEGOnStart;
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGPaint(jenv:PJNIEnv;obj:jobject);cdecl;
begin    
  try
    if Assigned(AEGOnStart) then
      AEGOnPaint;
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGMouseUp(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl;
begin
  try
    if Assigned(AEGOnMouseUp) then
      AEGOnMouseUp(x,y);
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGMouseMove(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl;
begin
  try
    if Assigned(AEGOnMouseMove) then
      AEGOnMouseMove(x,y);
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGMouseDown(jenv:PJNIEnv;obj:jobject;X,Y:Integer);cdecl;
begin
  try             
    {$IFDEF DEBUG}LOGI(ANDROID_LOG_INFO,'Info',PChar('ClickPos W:'+IntToStr(X)+' H:'+IntToStr(Y)));{$ENDIF}
    if Assigned(AEGOnMouseDown)then
      AEGOnMouseDown(x,y);
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;       

procedure AEGKeyUp(jenv:PJNIEnv;obj:jobject;key:Integer);cdecl;
begin
  try
    {$IFDEF DEBUG}LOGI(ANDROID_LOG_INFO,'Info',PChar('Key:'+IntToStr(Key)));{$ENDIF}
    if Assigned(AEGOnKeyUp)then
      AEGOnKeyUp(A2WKeycode[key]);
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;         

procedure AEGKeyDown(jenv:PJNIEnv;obj:jobject;key,repeats:Integer);cdecl;
begin
  try
    {$IFDEF DEBUG}LOGI(ANDROID_LOG_INFO,'Info',PChar('Key:'+IntToStr(Key)));{$ENDIF}
    if Assigned(AEGOnKeyDown)then
      AEGOnKeyDown(A2WKeycode[key],repeats);
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

procedure AEGFinish(jenv:PJNIEnv;obj:jobject);cdecl;
begin  
  try
    if Assigned(AEGOnStart) then
      AEGOnFinish;
  except
    on E:Exception do
      jenv^.ThrowNew(jenv,jenv^.FindClass(jenv,'java/lang/Exception'),PChar(E.ClassName+': '+E.Message));
  end;
end;

end.














