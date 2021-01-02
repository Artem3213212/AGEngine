{$MODE Delphi}

unit android_native_app_glue;

interface

uses ctypes,baseunix,unixtype,
     EGL14,OpenGLES30,
     configuration,looper,log,input,rect,native_window,native_activity;

type
  Pandroid_poll_source = ^android_poll_source;
  Pandroid_app = ^Tandroid_app;
  android_poll_source = packed record
    // The identifier of this source.  May be LOOPER_ID_MAIN or
    // LOOPER_ID_INPUT.
    id : cint32;
    // The android_app this ident is associated with.
    app : Pandroid_app;
    // Function to call to perform the standard processing of data from
    // this source.
    process : procedure(app: Pandroid_app; source: Pandroid_poll_source); cdecl;
  end;

  Tandroid_app = packed record
    // The application can place a pointer to its own state object
    // here if it likes.
    userData : Pointer;
    // Fill this in with the function to process main app commands (APP_CMD_*)
    onAppCmd : procedure(app: Pandroid_app; cmd: cint32); cdecl;
    // Fill this in with the function to process input events.  At this point
    // the event has already been pre-dispatched, and it will be finished upon
    // return. Return if you have handled the event, 0 for any default
    // dispatching.
    onInputEvent : function(app: Pandroid_app; event: PAInputEvent): cint32; cdecl;
    // The ANativeActivity object instance that this app is running in.
    activity : PANativeActivity;
    // The current configuration the app is running in.
    config : PAConfiguration;
    // This is the last instance's saved state, as provided at creation time.
    // It is NULL if there was no state.  You can use this as you need; the
    // memory will remain around until you call android_app_exec_cmd() for
    // APP_CMD_RESUME, at which point it will be freed and savedState set to NULL.
    // These variables should only be changed when processing a APP_CMD_SAVE_STATE,
    // at which point they will be initialized to NULL and you can malloc your
    // state and place the information here.  In that case the memory will be
    // freed for you later.
    savedState : Pointer;
    savedStateSize : csize_t;
    // The ALooper associated with the app's thread.
    looper : PALooper;
    // When non-NULL, this is the input queue from which the app will
    // receive user input events.
    inputQueue : PAInputQueue;
    // When non-NULL, this is the window surface that the app can draw in.
    window : PANativeWindow;
    // Current content rectangle of the window; this is the area where the
    // window's content should be placed to be seen by the user.
    contentRect : ARect;
    // Current state of the app's activity.  May be either APP_CMD_START,
    // APP_CMD_RESUME, APP_CMD_PAUSE, or APP_CMD_STOP; see below.
    activityState : cint;
    // This is non-zero when the application's NativeActivity is being
    // destroyed and waiting for the app thread to complete.
    destroyRequested : cint;
    // -------------------------------------------------
    // Below are "private" implementation of the glue code.
    cmdPollSource : android_poll_source;
    inputPollSource : android_poll_source;
    running : cint;
    stateSaved : cint;
    destroyed : cint;
    redrawNeeded : cint;
    pendingInputQueue : PAInputQueue;
    pendingWindow : PANativeWindow;
    pendingContentRect : ARect;
  end;

const
  (**
     * Looper data ID of commands coming from the app's main thread, which
     * is returned as an identifier from ALooper_pollOnce().  The data for this
     * identifier is a pointer to an android_poll_source structure.
     * These can be retrieved and processed with android_app_read_cmd()
     * and android_app_exec_cmd().
      *)
  LOOPER_ID_MAIN = 1;
  (**
     * Looper data ID of events coming from the AInputQueue of the
     * application's window, which is returned as an identifier from
     * ALooper_pollOnce().  The data for this identifier is a pointer to an
     * android_poll_source structure.  These can be read via the inputQueue
     * object of android_app.
      *)
  LOOPER_ID_INPUT = 2;
  (**
     * Start of user-defined ALooper identifiers.
      *)
  LOOPER_ID_USER = 3;

procedure ANativeActivity_onCreate(activity: PANativeActivity; savedState: Pointer; savedStateSize: csize_t); cdecl;

implementation

uses cmem;

function strerror(i: longint): pchar; cdecl;
begin
   result := 'Undefined!';
end;

procedure free_saved_state(android_app: Pandroid_app);
begin
   if android_app^.savedState <> Nil then
   begin
      free(android_app.savedState);
      android_app.savedState := nil;
      android_app.savedStateSize := 0;
   end;
end;

procedure print_cur_config(android_app: Pandroid_app);
var lang, country: array[0..1] of char;
begin
    AConfiguration_getLanguage(android_app^.config, @lang[0]);
    AConfiguration_getCountry(android_app^.config, @country[0]);

    LOGI(ANDROID_LOG_FATAL,'Crap','Config: mcc:=%d mnc:=%d lang:=%c%c cnt:=%c%c orien:=%d touch:=%d dens:=%d '+
            'keys:=%d nav:=%d keysHid:=%d navHid:=%d sdk:=%d size:=%d long:=%d '+
            'modetype:=%d modenight:=%d',
            AConfiguration_getMcc(android_app^.config),
            AConfiguration_getMnc(android_app^.config),
            lang[0], lang[1], country[0], country[1],
            AConfiguration_getOrientation(android_app^.config),
            AConfiguration_getTouchscreen(android_app^.config),
            AConfiguration_getDensity(android_app^.config),
            AConfiguration_getKeyboard(android_app^.config),
            AConfiguration_getNavigation(android_app^.config),
            AConfiguration_getKeysHidden(android_app^.config),
            AConfiguration_getNavHidden(android_app^.config),
            AConfiguration_getSdkVersion(android_app^.config),
            AConfiguration_getScreenSize(android_app^.config),
            AConfiguration_getScreenLong(android_app^.config),
            AConfiguration_getUiModeType(android_app^.config),
            AConfiguration_getUiModeNight(android_app^.config));
end;

procedure android_app_destroy(android_app: Pandroid_app);
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','android_app_destroy!');
    free_saved_state(android_app);
    if (android_app^.inputQueue <> nil) then
        AInputQueue_detachLooper(android_app^.inputQueue);
    AConfiguration_delete(android_app^.config);
    android_app^.destroyed := 1;
    // Can't touch android_app object after this.
end;

procedure process_input(app: Pandroid_app; source: Pandroid_poll_source); cdecl;
var event: PAInputEvent;
    handled: cint32;
begin
    event := nil;
    if (AInputQueue_getEvent(app^.inputQueue, @event) >= 0) then
    begin
        LOGI(ANDROID_LOG_FATAL,'Crap','New input event: type:=%d',AInputEvent_getType(event));
        if AInputQueue_preDispatchEvent(app^.inputQueue, event) <> 0 then
          exit;
        handled := 0;
        if Assigned(app^.onInputEvent)then
          handled := app^.onInputEvent(app, event);
        AInputQueue_finishEvent(app^.inputQueue, event, handled);
    end
    else
        LOGI(ANDROID_LOG_FATAL,'Crap','Failure reading next input event: %s', strerror(errno));
end;

// --------------------------------------------------------------------
// Native activity interaction (called from main thread)
// --------------------------------------------------------------------

function android_app_create(activity: PANativeActivity; savedState: Pointer; savedStateSize: csize_t): Pandroid_app;
var android_app: Pandroid_app;
    msgpipe: array[0..1] of cint;
    attr: pthread_attr_t;
begin
    android_app := Pandroid_app(malloc(sizeof(Tandroid_app)));
    fillchar(android_app^, sizeof(tandroid_app), 0);
    android_app^.activity := activity;

    if Assigned(savedState) then
    begin
        android_app^.savedState := malloc(savedStateSize);
        android_app^.savedStateSize := savedStateSize;
        move(pbyte(savedState)^, pbyte(android_app^.savedState)^, savedStateSize);
    end;

    //print_cur_config(android_app); 
    {android_app.config := AConfiguration_new();
    AConfiguration_fromAssetManager(android_app.config, android_app.activity.assetManager);
    android_app.looper := ALooper_prepare(ALOOPER_PREPARE_ALLOW_NON_CALLBACKS);}

    result := android_app;
end;

procedure android_app_set_input(android_app: Pandroid_app; inputQueue: PAInputQueue);
begin
    android_app.pendingInputQueue := inputQueue;
end;

procedure android_app_free(android_app: Pandroid_app);
begin
    free(android_app);
end;

procedure onDestroy(activity: PANativeActivity); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Destroy: %p', activity);
    android_app_free(Pandroid_app(activity^.instance));
end;

procedure onStart(activity: PANativeActivity); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Start: %p', activity);
end;

procedure onResume(activity: PANativeActivity); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Resume: %p', activity);
end;

function onSaveInstanceState(activity: PANativeActivity; outLen: pcsize_t): Pointer; cdecl;
var android_app: Pandroid_app;
    savedState: pointer;
begin
    android_app := activity^.instance;
    savedState := nil;

    LOGI(ANDROID_LOG_FATAL,'Crap','SaveInstanceState: %p', activity);
    android_app^.stateSaved := 0;

    if android_app^.savedState <> nil then
    begin
        savedState := android_app^.savedState;
        outLen^ := android_app^.savedStateSize;
        android_app^.savedState := nil;
        android_app^.savedStateSize := 0;
    end;


    result := savedState;
end;

procedure onPause(activity: PANativeActivity); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Pause: %p', activity);
end;

procedure onStop(activity: PANativeActivity); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Stop: %p', activity);
end;

procedure onConfigurationChanged(activity: PANativeActivity); cdecl;
var android_app: Pandroid_app;
begin
    android_app := activity^.instance;
    LOGI(ANDROID_LOG_FATAL,'Crap','ConfigurationChanged: %p', activity);
end;

procedure onLowMemory(activity: PANativeActivity); cdecl;
var android_app: Pandroid_app;
begin
    android_app := activity^.instance;
    LOGI(ANDROID_LOG_FATAL,'Crap','LowMemory: %p', activity);
end;

procedure onWindowFocusChanged(activity: PANativeActivity; focused: cint); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','WindowFocusChanged: %p -- %d', activity, focused);
end;

type
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
function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):longint;cdecl;external 'libc.so';

function Paint(activity: pointer):Pointer; cdecl;
var
  a:PAInputEvent;
begin
  //LOGI(ANDROID_LOG_FATAL,'Crap','Paint: %p', activity);
  glClearColor(1,1,0,1);
                  
    FpSleep(230);
  while true do
  begin
    glClear(GL_COLOR_BUFFER_BIT);
    if AInputQueue_hasEvents(Pandroid_app(activity).inputQueue)=1 then
      AInputQueue_getEvent(Pandroid_app(activity).inputQueue,@a);
    FpSleep(23);
  end;
end;

procedure onNativeWindowCreated(activity: PANativeActivity; window: PANativeWindow); cdecl;
const
  attrConf:array[0..16]of integer=(EGL_SURFACE_TYPE,EGL_WINDOW_BIT,
    EGL_CONFORMANT,EGL_OPENGL_ES2_BIT,
    EGL_BLUE_SIZE,8,
    EGL_GREEN_SIZE,8,
    EGL_RED_SIZE,8,
    EGL_ALPHA_SIZE,8,
    EGL_BUFFER_SIZE,32,
    EGL_DEPTH_SIZE,24,
    EGL_NONE);
var
  n:Integer;
  v:integer; 
      display:EGLDisplay;
      context:EGLContext;
      surface:EGLSurface;
      config:EGLConfig;
      tt:pthread_t;
begin
  LOGI(ANDROID_LOG_FATAL,'Crap','NativeWindowCreated: %p -- %p', activity, window);
  Pandroid_app(activity.instance).pendingWindow := window;

  display:=eglGetDisplay(EGL_DEFAULT_DISPLAY);
  if(display<>EGL_NO_DISPLAY)and eglInitialize(display,nil,nil)and eglChooseConfig(display,@attrConf[0],@config,1,n)then
  begin
    surface:=eglCreateWindowSurface(display,config,window,nil);     
    LOGI(ANDROID_LOG_FATAL,'Crap','eglCreateWindowSurface: %p', surface);
    eglBindAPI(EGL_OPENGL_ES_API);
    context:=eglCreateContext(display,config,EGL_NO_CONTEXT,nil);  
    LOGI(ANDROID_LOG_FATAL,'Crap','eglCreateContext: %p', context);
    eglQueryContext(display, context, EGL_CONTEXT_CLIENT_VERSION, &v);

    if eglMakeCurrent(display,surface,surface,context)then
    begin
      glViewport(0,0,300,300);
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    end
    else
      LOGW('Error2');
  end
  else
    LOGW('Error1');
  pthread_create(tt,nil,@Paint,activity.instance);
end;

procedure onNativeWindowDestroyed(activity: PANativeActivity; window: PANativeWindow); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','NativeWindowDestroyed: %p -- %p', activity, window);
    Pandroid_app(activity.instance).pendingWindow := nil;
end;

      
procedure onPaint(activity: PANativeActivity; window: PANativeWindow); cdecl;
begin                   
    LOGI(ANDROID_LOG_FATAL,'Crap','onPaint: %p -- %p', activity, window);
  glClearColor(1,1,0,1);
  glClear(GL_COLOR_BUFFER_BIT);
end;

procedure onInputQueueCreated(activity: PANativeActivity; queue: PAInputQueue); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','InputQueueCreated: %p -- %p', activity, queue);
    android_app_set_input(activity^.instance, queue);
end;

procedure onInputQueueDestroyed(activity: PANativeActivity; queue: PAInputQueue); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','InputQueueDestroyed: %p -- %p', activity, queue);
    android_app_set_input(activity^.instance, nil);
end;

procedure onContentRectChanged(activity: PANativeActivity; rect: PARect); cdecl;
begin

end;

procedure onNativeWindowResized(activity: PANativeActivity; window: PANativeWindow); cdecl;
begin

end;

procedure ANativeActivity_onCreate(activity: PANativeActivity; savedState: Pointer; savedStateSize: csize_t); cdecl;
begin
    LOGI(ANDROID_LOG_FATAL,'Crap','Creating: %p', activity);
    activity.callbacks.onDestroy := onDestroy;
    activity.callbacks.onStart := onStart;
    activity.callbacks.onResume := onResume;
    activity.callbacks.onSaveInstanceState := onSaveInstanceState;
    activity.callbacks.onPause := onPause;
    activity.callbacks.onStop := onStop;
    activity.callbacks.onConfigurationChanged := onConfigurationChanged;
    activity.callbacks.onLowMemory:=onLowMemory;
    activity.callbacks.onWindowFocusChanged:=onWindowFocusChanged;
    activity.callbacks.onNativeWindowDestroyed:=onNativeWindowDestroyed;
    activity.callbacks.onInputQueueCreated:=onInputQueueCreated;
    activity.callbacks.onInputQueueDestroyed:=onInputQueueDestroyed;
    activity.callbacks.onNativeWindowRedrawNeeded:=onPaint;
    activity.callbacks.onContentRectChanged:=onContentRectChanged;              
    activity.callbacks.onNativeWindowResized:=onNativeWindowResized;
    activity.callbacks.onNativeWindowCreated:=onNativeWindowCreated;

    activity.instance := android_app_create(activity, savedState, savedStateSize);
    //Pandroid_app(activity.instance).onAppCmd:=;
end;

end.














