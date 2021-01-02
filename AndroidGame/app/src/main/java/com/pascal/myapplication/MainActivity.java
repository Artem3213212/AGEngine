package com.pascal.myapplication;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.graphics.Canvas;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.WindowManager;

import java.util.Timer;
import java.util.TimerTask;

class Pascal {
    public static native void AEGWindowCreate(Surface Surface);
    public static native void AEGWindowResize(int W, int H);
    public static native void AEGStart();
    public static native void AEGPaint();
    public static native void AEGMouseUp(int X, int Y);
    public static native void AEGMouseMove(int X, int Y);
    public static native void AEGMouseDown(int X, int Y);
    public static native void AEGKeyUp(int key);
    public static native void AEGKeyDown(int key,int repeats);
    public static native void AEGFinish();

    static {
        System.loadLibrary("main");
    }
}

public class MainActivity extends AppCompatActivity implements SurfaceHolder.Callback,View.OnTouchListener {
    Timer PaintTimer=new Timer();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final PascalViewer pascalView=new PascalViewer(this);
        setContentView(pascalView);
        getSupportActionBar().hide();
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
        pascalView.getHolder().addCallback(this);
        pascalView.setOnTouchListener(this);
        PaintTimer.scheduleAtFixedRate(new TimerTask(){
            @Override
            public void run() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        pascalView.invalidate();
                    }
                });
            }
        },1000,16);
    }

    class PascalViewer extends SurfaceView {
        public PascalViewer(Context context) {
            super(context);
            setWillNotDraw(false);

            //setOnTouchListener();
            //new MotionEvent().
        }

        @Override
        protected void onDraw(Canvas canvas) {
            runOnUiThread(new Runnable() {
                @Override
                public void run(){
                    Pascal.AEGPaint();
                }
            });
        }
    }

    static int w2,h2;
    static SurfaceHolder holder2;
    public void surfaceChanged(SurfaceHolder holder,int format,int w,int h){
        w2=w;
        h2=h;
        holder2=holder;
        runOnUiThread(new Runnable() {
            @Override
            public void run(){
                Pascal.AEGWindowResize(holder2.getSurfaceFrame().height(),holder2.getSurfaceFrame().width());
                Pascal.AEGWindowCreate(holder2.getSurface());
                Pascal.AEGStart();
            }
        });
    }

    public void surfaceCreated(SurfaceHolder holder) {
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        runOnUiThread(new Runnable() {
            @Override
            public void run(){
                Pascal.AEGFinish();
            }
        });
    }

    public boolean onTouch(View v, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN)
            Pascal.AEGMouseDown(Math.round(event.getX()),Math.round(event.getY()));
        if (event.getAction() == MotionEvent.ACTION_MOVE)
            Pascal.AEGMouseMove(Math.round(event.getX()),Math.round(event.getY()));
        if (event.getAction() == MotionEvent.ACTION_UP)
            Pascal.AEGMouseUp(Math.round(event.getX()),Math.round(event.getY()));
        return true;
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(!super.onKeyDown(keyCode,event))
            Pascal.AEGKeyDown(keyCode,event.getRepeatCount());
        return true;
    }

    @Override
    public boolean onKeyLongPress(int keyCode, KeyEvent event) {
        if(!super.onKeyDown(keyCode,event))
            Pascal.AEGKeyDown(keyCode,event.getRepeatCount());
        return true;
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if(!super.onKeyDown(keyCode,event))
            Pascal.AEGKeyUp(keyCode);
        return true;
    }
}
