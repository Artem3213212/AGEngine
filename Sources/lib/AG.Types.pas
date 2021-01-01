unit AG.Types;

interface

{$i main.conf}

{$IFDEF Logs}{$ENDIF}
{$IFDEF Vulkan}{$ENDIF}
{$IFDEF D2D1}{$ENDIF}
{$IFDEF D3D9}{$ENDIF}
{$IFDEF OpenGl}{$ENDIF}

{$IFDEF D3D9}
  {$Define Direct3D}
{$ENDIF}

{$IFDEF Direct3D}
  {$Define DirectX}
{$ENDIF}
{$IFDEF D2D1}
  {$Define DirectX}
{$ENDIF}


{$IFDEF Direct3D}
  {$Define AGColorInBrush}
{$ENDIF}
{$IFDEF OpenGl}
  {$Define AGColorInBrush}
{$ENDIF}

{$IFDEF NoDirective}
  {$Define AGFloatColorInBrush}
{$ENDIF}

{$IFDEF Direct3D}
  {$Define NeedWinAPILangConversion}
{$ENDIF}

uses
  System.SysUtils,System.Classes,System.Types,System.Math.Vectors,System.Math,
  {$IFDEF NeedWinAPILangConversion}Winapi.Windows,{$ENDIF}
  {$IFDEF OpenGl}Winapi.OpenGL,Winapi.OpenGLext,{$ENDIF}
  {$IFDEF D2D1}Winapi.D2D1,Winapi.DXGI,Winapi.DXGIformat,{$ENDIF}
  {$IFDEF D3D9}Winapi.Direct3D9,Winapi.D3DX9,{$ENDIF}
  {$IFDEF Direct3D}Winapi.DXTypes,{$ENDIF}
  {$IFDEF Vulkan}Vulkan,{$ENDIF}
  {$IFDEF ANDROID}AndroidAPI.NativeWindow,{$ENDIF}
  AG.Resourcer;

type
  TAGWindowHandle={$IFDEF MSWINDOWS}NativeInt{$ENDIF}
  {$IFDEF ANDROID}PANativeWindow{$ENDIF};

  TAGColor=record
    constructor Create(R,G,B,A:Byte);
    class operator Multiply(c:TAGColor;s:Single):TAGColor;
    class operator Multiply(s:Single;c:TAGColor):TAGColor;
    case byte of
      0:(R,G,B,A:byte);
      1:(Arr:array[0..3]of byte);
      {$IFDEF D3D9}3:(D3D9:Winapi.DXTypes.TD3DColor);{$ENDIF}
  end;

  TAGFloatColor=record
    constructor Create(R,G,B,A:Single);
    class operator Multiply(c:TAGFloatColor;s:Single):TAGFloatColor;
    class operator Multiply(s:Single;c:TAGFloatColor):TAGFloatColor;
    class operator Implicit(c:TAGColor):TAGFloatColor;
    class operator Implicit(c:TAGFloatColor):TAGColor;
    class operator Explicit(c:TAGColor):TAGFloatColor;
    class operator Explicit(c:TAGFloatColor):TAGColor;
    case byte of
      0:(R,G,B,A:Single);
      1:(Arr:array[0..3]of Single);
      {$IFDEF D2D1}2:(D2D1:D2D_COLOR_F);{$ENDIF}
      {$IFDEF D3D9}4:(D3D9:Winapi.DXTypes.TD3DColorValue);{$ENDIF}
  end;

  TAGBrush=record
    case byte of
    0:(def:NativeInt);
    {$IFDEF D2D1}1:(D2D1:^ID2D1Brush);{$ENDIF}
    {$IFDEF AGColorInBrush}2:(AGColor:TAGColor);{$ENDIF}
    {$IFDEF AGFloatColorInBrush}3:(AGFloatColor:TAGFloatColor);{$ENDIF}
  end;

  {$IFDEF D3D9}
  TAGD3D9Mat=packed record
    Info:TD3DMaterial9;
    Text:IDirect3DTexture9;
    Spec:IDirect3DTexture9;
    Norm:IDirect3DTexture9;
  end;

  TAGD3D9Mesh=packed record
    Mesh:ID3DXMesh;
    Mat:TArray<TAGD3D9Mat>;
  end;
  {$ENDIF}

  TAGTex=packed record
    case byte of
    0:(def:NativeInt);
    {$IFDEF D3D9}2:(D3D9:^TAGD3D9Mat);{$ENDIF}
  end;

  TAGLight=packed record
    case byte of
    0:(def:NativeInt);
    {$IFDEF D3D9}2:(D3D9:integer);{$ENDIF}
  end;

  TAGMesh=record
    case byte of
    0:(def:NativeInt);
    {$IFDEF D3D9}2:(D3D9:^TAGD3D9Mesh);{$ENDIF}
  end;

  TAGBitMap=packed record
    case byte of
    0:(def:NativeInt);
    {$IFDEF D2D1}1:(D2D1:^ID2D1Bitmap);{$ENDIF}
    {$IFDEF D3D9}3:(D3D9:^Winapi.Direct3D9.IDirect3DTexture9);{$ENDIF}
    {$IFDEF OpenGL}4:(OpenGL:PGlUint);{$ENDIF}
    5:(pn:PNativeInt);
  end;
  TAGFont=word;

  TAGEngineResource=record
    source:PAGResource;
    img:array of TAGBitMap;
  end;

  TAG2DVector=TPointF;
  TAGScreenVector=record
    X,Y:Integer;
    class operator Multiply(A:TAGScreenVector;B:Integer):TAGScreenVector;inline;
    class operator Multiply(A:TAGScreenVector;B:Real):TAG2DVector;inline;
    class operator Multiply(A:TAGScreenVector;B:Single):TAG2DVector;inline;
    class operator Multiply(A:Integer;B:TAGScreenVector):TAGScreenVector;inline;
    class operator Multiply(A:Real;B:TAGScreenVector):TAG2DVector;inline;
    class operator Multiply(A:Single;B:TAGScreenVector):TAG2DVector;inline;
    class operator Multiply(A:TAGScreenVector;B:TAG2DVector):TAG2DVector;inline;
    class operator Multiply(A:TAG2DVector;B:TAGScreenVector):TAG2DVector;inline;

    class operator Divide(A:TAGScreenVector;B:Integer):TAG2DVector;inline;
    class operator Divide(A:TAGScreenVector;B:Real):TAG2DVector;inline;
    class operator Divide(A:TAGScreenVector;B:Single):TAG2DVector;inline;
    class operator Divide(A:Integer;B:TAGScreenVector):TAG2DVector;inline;
    class operator Divide(A:Real;B:TAGScreenVector):TAG2DVector;inline;
    class operator Divide(A:Single;B:TAGScreenVector):TAG2DVector;inline;
    class operator Divide(A:TAGScreenVector;B:TAG2DVector):TAG2DVector;inline;
    class operator Divide(A:TAG2DVector;B:TAGScreenVector):TAG2DVector;inline;

    class operator Add(A,B:TAGScreenVector):TAGScreenVector;inline;
    class operator Subtract(A,B:TAGScreenVector):TAGScreenVector;inline;
    class operator Implicit(a:TAGScreenVector):TAG2DVector;inline;
    class operator Explicit(a:TAG2DVector):TAGScreenVector;inline;
    class operator Explicit(a:TAGScreenVector):TAG2DVector;inline;
    constructor Create(X,Y:Integer);
  end;
  PTAGScreenVector=^TAGScreenVector;

  TAGCoord=packed record
    constructor Create(X,Y,W,H:Single);
    function SizePosRev:TAGCoord;inline;
    {$IFDEF D2D1}function ToTD2D1RectF:TD2D1RectF;inline;{$ENDIF}
    class operator Add(A,B:TAGCoord):TAGCoord;inline;
    class operator Divide(A:TAGCoord;B:Single):TAGCoord;inline;
    case byte of
      0:(X,Y,W,H:Single);
      1:(arr:array[0..3]of Single);
      2:(Pos,Size:TAG2DVector);
  end;
  TAGScreenCoord=packed record
    constructor Create(X,Y,W,H:integer);
    constructor FromTRect(Rect:TRect);
    function SizePosRev:TAGScreenCoord;inline;
    function ToTRect:TRect;inline;
    class operator Add(A,B:TAGScreenCoord):TAGScreenCoord;inline;
    class operator IntDivide(A:TAGScreenCoord;B:integer):TAGScreenCoord;inline;
    class operator Implicit(a:TAGScreenCoord):TAGCoord;inline;
    class operator Explicit(a:TAGCoord):TAGScreenCoord;inline;
    class operator Explicit(a:TAGScreenCoord):TAGCoord;inline;
    case byte of
      0:(X,Y,W,H:integer);
      1:(arr:array[0..3]of integer);
      2:(Pos,Size:TAGScreenVector);
  end;
  PTAGScreenCoord=^TAGScreenCoord;


  TAG3DVector=TPoint3D;
  TAGConst3DVector=packed record
    V:array[0..2]of Single;
    class operator Implicit(a:TAGConst3DVector):TAG3DVector;
  end;
  TAG4DVector=packed record
    type
      TPoint4DArray = array [0..3] of Single;
    function Length:Single;inline;
    function Normalize:TAG4DVector;inline;

    class operator Multiply(A:TAG4DVector;B:Integer):TAG4DVector;inline;
    class operator Multiply(A:TAG4DVector;B:Real):TAG4DVector;inline;
    class operator Multiply(A:TAG4DVector;B:Single):TAG4DVector;inline;
    class operator Multiply(A:Integer;B:TAG4DVector):TAG4DVector;inline;
    class operator Multiply(A:Real;B:TAG4DVector):TAG4DVector;inline;
    class operator Multiply(A:Single;B:TAG4DVector):TAG4DVector;inline;

    class operator Divide(A:TAG4DVector;B:Integer):TAG4DVector;inline;
    class operator Divide(A:TAG4DVector;B:Real):TAG4DVector;inline;
    class operator Divide(A:TAG4DVector;B:Single):TAG4DVector;inline;

    class operator Add(A,B:TAG4DVector):TAG4DVector;inline;
    class operator Subtract(A,B:TAG4DVector):TAG4DVector;inline;
    class operator Implicit(a:TAG4DVector):TAG3DVector;inline;
    constructor Create(X,Y,Z,W:Single);
    case Integer of
      0: (V: TPoint4DArray;);
      1: (X: Single;
          Y: Single;
          Z: Single;
          W: Single;);
  end;

  TAGSqueredPolygonPoitMeans=(AGCenter,AGRU,AGRD,AGLU,AGLD);//Right/Left;Up/Down
  TAG3DSqueredPolygon=record
    Points:array[0..2]of TAG3DVector;
    Means:array[0..2]of TAGSqueredPolygonPoitMeans;
  end;

  TAG2DMatrix=record
      private type
        TArr=array[0..2,0..2]of Single;
      private
        m:TArr;
      public
      constructor Create(a:TArray<Single>);
      class function MkIdent():TAG2DMatrix;static;
      constructor MkTrans(Trans:TAG2DVector);overload;
      constructor MkTrans(X,Y:Single);overload;
      constructor MkScale(Scale:TAG2DVector);overload;
      constructor MkScale(Scale:Single);overload;
      constructor MkRot(Rot:Single);
      constructor MkSRT(Scale:TAG2DVector;Rot:Single;Trans:TAG2DVector);
      function Determinant:double;
      function Invert:TAG2DMatrix;
      function Transpose:TAG2DMatrix;
      function GetPos:TAG2DVector;
      function InvAndGetPos:TAG2DVector;
      class operator Multiply(a,b:TAG2DMatrix):TAG2DMatrix;
      class operator Multiply(a:TAG2DVector;b:TAG2DMatrix):TAG2DVector;
      class operator Divide(a:TAG2DVector;b:TAG2DMatrix):TAG2DVector;
      property Data:TArr read m write m;
    end;

  TAG3DMatrix=record
      private type
        TArr=array[0..3,0..3]of Single;
      private
        m:TArr;
      public
      constructor Create(a:TArray<Single>);
      class function MkIdent():TAG3DMatrix;static;
      constructor MkTrans(Trans:TAG3DVector);overload;
      constructor MkTrans(X,Y,Z:Single);overload;
      constructor MkScale(Scale:TAG3DVector);overload;
      constructor MkScale(Scale:Single);overload;
      constructor MkRotX(Rot:Single);
      constructor MkRotY(Rot:Single);
      constructor MkRotZ(Rot:Single);
      constructor MkRot(Rot:TAG3DVector);
      constructor MkRotWithIncline(Rot,Incline:TAG3DVector);
      constructor MkSRT(Scale,Rot,Trans:TAG3DVector);
      constructor MkCamToObject(Cam,Obj:TAG3DVector);overload;
      constructor MkCamToObject(Cam,Obj,UpDirection:TAG3DVector);overload;
      function Determinant:double;
      function Invert:TAG3DMatrix;
      function Transpose:TAG3DMatrix;
      function GetPos:TAG4DVector;
      function InvAndGetPos:TAG4DVector;
      class operator Multiply(a,b:TAG3DMatrix):TAG3DMatrix;
      class operator Multiply(a:TAG3DVector;b:TAG3DMatrix):TAG4DVector;
      class operator Multiply(a:TAG4DVector;b:TAG3DMatrix):TAG4DVector;
      class operator Divide(a:TAG3DVector;b:TAG3DMatrix):TAG3DVector;
      property Data:TArr read m write m;
      {$IFDEF D3D9}
      function ToD3D9Form:TD3DXMatrix;
      constructor FromD3D9Form(Matrix:TD3DXMatrix);
      {$ENDIF}
    end;

const
  AGFont_SystemFont:TAGFont=0;
  AGFont_UserFonts=1;

  ZGUID:PGUID=nil;

  BackColor:TAGColor=(R:0;G:0;B:0;A:255);
  RedColor:TAGColor=(R:255;G:0;B:0;A:255);
  GreenColor:TAGColor=(R:0;G:255;B:0;A:255);
  BlueColor:TAGColor=(R:0;G:0;B:255;A:255);
  WiteColor:TAGColor=(R:255;G:255;B:255;A:255);
  NoColor:TAGColor=(R:0;G:0;B:0;A:0);

{$IFDEF NeedWinAPILangConversion}
function StrToWinAPILang(Lang:string):DWORD;inline;
{$ENDIF}

implementation

{TAGColor}

constructor TAGColor.Create(R,G,B,A:Byte);
begin
Self.R:=R;
Self.G:=G;
Self.B:=B;
Self.A:=A;
end;

class operator TAGColor.Multiply(c:TAGColor;s:Single):TAGColor;
begin
Result.R:=Round(c.R*s);
Result.G:=Round(c.G*s);
Result.B:=Round(c.B*s);
Result.A:=Round(c.A*s);
end;

class operator TAGColor.Multiply(s:Single;c:TAGColor):TAGColor;
begin
Result.R:=Round(c.R*s);
Result.G:=Round(c.G*s);
Result.B:=Round(c.B*s);
Result.A:=Round(c.A*s);
end;

{TAGFloatColor}

constructor TAGFloatColor.Create(R,G,B,A:Single);
begin
  Self.R:=R;
  Self.G:=G;
  Self.B:=B;
  Self.A:=A;
end;

class operator TAGFloatColor.Multiply(c:TAGFloatColor;s:Single):TAGFloatColor;
begin
  Result.R:=c.R*s;
  Result.G:=c.G*s;
  Result.B:=c.B*s;
  Result.A:=c.A*s;
end;

class operator TAGFloatColor.Multiply(s:Single;c:TAGFloatColor):TAGFloatColor;
begin
  Result.R:=c.R*s;
  Result.G:=c.G*s;
  Result.B:=c.B*s;
  Result.A:=c.A*s;
end;

class operator TAGFloatColor.Implicit(c:TAGColor):TAGFloatColor;
begin
  Result.R:=c.R/255;
  Result.G:=c.G/255;
  Result.B:=c.B/255;
  Result.A:=c.A/255;
end;

class operator TAGFloatColor.Implicit(c:TAGFloatColor):TAGColor;
begin
  Result.R:=Round(c.R*255);
  Result.G:=Round(c.G*255);
  Result.B:=Round(c.B*255);
  Result.A:=Round(c.A*255);
end;

class operator TAGFloatColor.Explicit(c:TAGColor):TAGFloatColor;
begin
  Result.R:=c.R/255;
  Result.G:=c.G/255;
  Result.B:=c.B/255;
  Result.A:=c.A/255;
end;

class operator TAGFloatColor.Explicit(c:TAGFloatColor):TAGColor;
begin
  Result.R:=Round(c.R*255);
  Result.G:=Round(c.G*255);
  Result.B:=Round(c.B*255);
  Result.A:=Round(c.A*255);
end;

{TAGCoord}

constructor TAGCoord.Create(X,Y,W,H:Single);
begin
  Self.X:=X;
  Self.Y:=Y;
  Self.W:=W;
  Self.H:=H;
end;

function TAGCoord.SizePosRev:TAGCoord;
begin
  Result.W:=Self.X;
  Result.H:=Self.Y;
  Result.X:=Self.W;
  Result.Y:=Self.H;
end;

{$IFDEF D2D1}
function TAGCoord.ToTD2D1RectF:TD2D1RectF;
begin
  Result.left:=X;
  Result.top:=Y;
  Result.right:=W+X;
  Result.bottom:=H+Y;
end;
{$ENDIF}

class operator TAGCoord.Add(A,B:TAGCoord):TAGCoord;
var
  i:integer;
begin
for i:=0 to 3 do
  Result.arr[i]:=A.arr[i]+B.arr[i];
end;

class operator TAGCoord.Divide(A:TAGCoord;B:Single):TAGCoord;
var
  i:integer;
begin
  for i:=0 to 3 do
    Result.arr[i]:=A.arr[i]/B;
end;

{TAGScreenCoord}

constructor TAGScreenCoord.Create(X,Y,W,H:integer);
begin
  Self.X:=X;
  Self.Y:=Y;
  Self.W:=W;
  Self.H:=H;
end;

function TAGScreenCoord.SizePosRev:TAGScreenCoord;
begin
  Result.W:=Self.X;
  Result.H:=Self.Y;
  Result.X:=Self.W;
  Result.Y:=Self.H;
end;

class operator TAGScreenCoord.Add(A,B:TAGScreenCoord):TAGScreenCoord;
var
  i:integer;
begin
  for i:=0 to 3 do
    Result.arr[i]:=A.arr[i]+B.arr[i];
end;

function TAGScreenCoord.ToTRect:TRect;
begin
  Result.left:=X;
  Result.top:=Y;
  Result.right:=W+X;
  Result.bottom:=H+Y;
end;

constructor TAGScreenCoord.FromTRect(Rect:TRect);
begin
  X:=Rect.Left;
  Y:=Rect.Top;
  W:=Rect.Right-Rect.Left;
  H:=Rect.Bottom-Rect.Top;
end;

class operator TAGScreenCoord.IntDivide(A:TAGScreenCoord;B:integer):TAGScreenCoord;
var
  i:integer;
begin
  for i:=0 to 3 do
    Result.arr[i]:=A.arr[i] div B;
end;

class operator TAGScreenCoord.Implicit(a:TAGScreenCoord):TAGCoord;
begin
  Result.X:=a.X;
  Result.Y:=a.Y;
  Result.W:=a.W;
  Result.H:=a.H;
end;

class operator TAGScreenCoord.Explicit(a:TAGCoord):TAGScreenCoord;
begin
  Result.X:=Round(a.X);
  Result.Y:=Round(a.Y);
  Result.W:=Round(a.W);
  Result.H:=Round(a.H);
end;

class operator TAGScreenCoord.Explicit(a:TAGScreenCoord):TAGCoord;
begin
  Result.X:=a.X;
  Result.Y:=a.Y;
  Result.W:=a.W;
  Result.H:=a.H;
end;

{TAGScreenVector}

class operator TAGScreenVector.Multiply(A:TAGScreenVector;B:Integer):TAGScreenVector;
begin
Result.X:=A.X*B;
Result.Y:=A.Y*B;
end;

class operator TAGScreenVector.Multiply(A:TAGScreenVector;B:Real):TAG2DVector;
begin
Result.X:=A.X*B;
Result.Y:=A.Y*B;
end;

class operator TAGScreenVector.Multiply(A:TAGScreenVector;B:Single):TAG2DVector;
begin
Result.X:=A.X*B;
Result.Y:=A.Y*B;
end;

class operator TAGScreenVector.Multiply(A:Integer;B:TAGScreenVector):TAGScreenVector;
begin
Result.X:=A*B.X;
Result.Y:=A*B.Y;
end;

class operator TAGScreenVector.Multiply(A:Real;B:TAGScreenVector):TAG2DVector;
begin
Result.X:=A*B.X;
Result.Y:=A*B.Y;
end;

class operator TAGScreenVector.Multiply(A:Single;B:TAGScreenVector):TAG2DVector;
begin
Result.X:=A*B.X;
Result.Y:=A*B.Y;
end;

class operator TAGScreenVector.Multiply(A:TAGScreenVector;B:TAG2DVector):TAG2DVector;
begin
Result.X:=A.X*B.X;
Result.Y:=A.Y*B.Y;
end;

class operator TAGScreenVector.Multiply(A:TAG2DVector;B:TAGScreenVector):TAG2DVector;
begin
Result.X:=A.X*B.X;
Result.Y:=A.Y*B.Y;
end;

class operator TAGScreenVector.Divide(A:TAGScreenVector;B:Integer):TAG2DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
end;

class operator TAGScreenVector.Divide(A:TAGScreenVector;B:Real):TAG2DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
end;

class operator TAGScreenVector.Divide(A:TAGScreenVector;B:Single):TAG2DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
end;

class operator TAGScreenVector.Divide(A:Integer;B:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A/B.X;
  Result.Y:=A/B.Y;
end;

class operator TAGScreenVector.Divide(A:Real;B:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A/B.X;
  Result.Y:=A/B.Y;
end;

class operator TAGScreenVector.Divide(A:Single;B:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A/B.X;
  Result.Y:=A/B.Y;
end;

class operator TAGScreenVector.Divide(A:TAGScreenVector;B:TAG2DVector):TAG2DVector;
begin
  Result.X:=A.X/B.X;
  Result.Y:=A.Y/B.Y;
end;

class operator TAGScreenVector.Divide(A:TAG2DVector;B:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A.X/B.X;
  Result.Y:=A.Y/B.Y;
end;

class operator TAGScreenVector.Add(A,B:TAGScreenVector):TAGScreenVector;
begin
  Result.X:=A.X+B.X;
  Result.Y:=A.Y+B.Y;
end;

class operator TAGScreenVector.Subtract(A,B:TAGScreenVector):TAGScreenVector;
begin
  Result.X:=A.X-B.X;
  Result.Y:=A.Y-B.Y;
end;

class operator TAGScreenVector.Implicit(a:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A.X;
  Result.Y:=A.Y;
end;

class operator TAGScreenVector.Explicit(a:TAG2DVector):TAGScreenVector;
begin
  Result.X:=Round(A.X);
  Result.Y:=Round(A.Y);
end;

class operator TAGScreenVector.Explicit(a:TAGScreenVector):TAG2DVector;
begin
  Result.X:=A.X;
  Result.Y:=A.Y;
end;

constructor TAGScreenVector.Create(X,Y:Integer);
begin
  Self.X:=X;
  Self.Y:=Y;
end;

{TAGConst3DVector}

class operator TAGConst3DVector.Implicit(a:TAGConst3DVector):TAG3DVector;
begin
  Result:=TAG3DVector.Create(a.V[0],a.V[1],a.V[2]);
end;

{TAG4DVector}

function TAG4DVector.Length:Single;
begin
  Result:=sqrt(sqr(X)+sqr(Y)+sqr(Z)+sqr(W));
end;

function TAG4DVector.Normalize:TAG4DVector;
begin
  Result:=self/Length;
end;

class operator TAG4DVector.Multiply(A:TAG4DVector;B:Integer):TAG4DVector;
begin
  Result.X:=A.X*B;
  Result.Y:=A.Y*B;
  Result.Z:=A.Z*B;
  Result.W:=A.W*B;
end;

class operator TAG4DVector.Multiply(A:TAG4DVector;B:Real):TAG4DVector;
begin
  Result.X:=A.X*B;
  Result.Y:=A.Y*B;
  Result.Z:=A.Z*B;
  Result.W:=A.W*B;
end;

class operator TAG4DVector.Multiply(A:TAG4DVector;B:Single):TAG4DVector;
begin
  Result.X:=A.X*B;
  Result.Y:=A.Y*B;
  Result.Z:=A.Z*B;
  Result.W:=A.W*B;
end;

class operator TAG4DVector.Multiply(A:Integer;B:TAG4DVector):TAG4DVector;
begin
  Result.X:=A*B.X;
  Result.Y:=A*B.Y;
  Result.Z:=A*B.Z;
  Result.W:=A*B.W;
end;

class operator TAG4DVector.Multiply(A:Real;B:TAG4DVector):TAG4DVector;
begin
  Result.X:=A*B.X;
  Result.Y:=A*B.Y;
  Result.Z:=A*B.Z;
  Result.W:=A*B.W;
end;

class operator TAG4DVector.Multiply(A:Single;B:TAG4DVector):TAG4DVector;
begin
  Result.X:=A*B.X;
  Result.Y:=A*B.Y;
  Result.Z:=A*B.Z;
  Result.W:=A*B.W;
end;

class operator TAG4DVector.Divide(A:TAG4DVector;B:Integer):TAG4DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
  Result.Z:=A.Z/B;
  Result.W:=A.W/B;
end;

class operator TAG4DVector.Divide(A:TAG4DVector;B:Real):TAG4DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
  Result.Z:=A.Z/B;
  Result.W:=A.W/B;
end;

class operator TAG4DVector.Divide(A:TAG4DVector;B:Single):TAG4DVector;
begin
  Result.X:=A.X/B;
  Result.Y:=A.Y/B;
  Result.Z:=A.Z/B;
  Result.W:=A.W/B;
end;

class operator TAG4DVector.Add(A,B:TAG4DVector):TAG4DVector;
begin
  Result.X:=A.X+B.X;
  Result.Y:=A.Y+B.Y;
  Result.Z:=A.Z+B.Z;
  Result.W:=A.W+B.W;
end;

class operator TAG4DVector.Subtract(A,B:TAG4DVector):TAG4DVector;
begin
  Result.X:=A.X-B.X;
  Result.Y:=A.Y-B.Y;
  Result.Z:=A.Z-B.Z;
  Result.W:=A.W-B.W;
end;

class operator TAG4DVector.Implicit(a:TAG4DVector):TAG3DVector;
begin
  with a do
  begin
    Result.X:=X/W;
    Result.Y:=Y/W;
    Result.Z:=Z/W;
  end;
end;

constructor TAG4DVector.Create(X,Y,Z,W:Single);
begin
  Self.X:=X;
  Self.Y:=Y;
  Self.Z:=Z;
  Self.W:=W;
end;

{TAG2DMatrix}

constructor TAG2DMatrix.Create(a:TArray<Single>);
var
  i0,i1:byte;
begin
  for i0:=0 to 2 do
    for i1:=0 to 2 do
      m[i0][i1]:=a[i0*3+i1];
end;

class function TAG2DMatrix.MkIdent():TAG2DMatrix;
begin
  Result:=TAG2DMatrix.Create([1,0,0,0,1,0,0,0,1]);
end;

constructor TAG2DMatrix.MkTrans(Trans:TAG2DVector);
begin
  Self:=Create([1,0,0,0,1,0,Trans.X,Trans.Y,1]);
end;

constructor TAG2DMatrix.MkTrans(X,Y:Single);
begin
  Self:=Create([1,0,0,0,1,0,X,Y,1]);
end;

constructor TAG2DMatrix.MkScale(Scale:TAG2DVector);
begin
  Self:=Create([Scale.X,0,0,0,Scale.Y,0,0,0,1]);
end;

constructor TAG2DMatrix.MkScale(Scale:Single);
begin
  Self:=Create([Scale,0,0,0,Scale,0,0,0,1]);
end;

constructor TAG2DMatrix.MkRot(Rot:Single);
var
  sin,cos:Single;
begin
  SinCos(Rot,sin,cos);
  Self:=Create([cos,-sin,0,sin,cos,0,0,0,1]);
end;

constructor TAG2DMatrix.MkSRT(Scale:TAG2DVector;Rot:Single;Trans:TAG2DVector);
var
  sin,cos:Single;
begin
  SinCos(Rot,sin,cos);
  Self:=Create([Scale.X*cos,Scale.X*sin,0,-Scale.Y*sin,Scale.Y*cos,0,Trans.X,Trans.Y,1]);
end;

function TAG2DMatrix.Determinant:double;
begin
  Result:=m[0,0]*(m[1,1]*m[2,2]-m[1,2]*m[2,1])
    -m[0,1]*(m[1,0]*m[2,2]-m[1,2]*m[2,0])
    +m[0,2]*(m[1,0]*m[2,1]-m[1,1]*m[2,0]);
end;

function TAG2DMatrix.Invert:TAG2DMatrix;
var
  tt:double;
begin
  tt:=Determinant;

  Result.m[0,0]:=(m[1,1]*m[2,2]-m[1,2]*m[2,1])/tt;
  Result.m[0,1]:=(m[0,2]*m[2,1]-m[0,1]*m[2,2])/tt;
  Result.m[0,2]:=(m[0,1]*m[1,2]-m[0,2]*m[1,1])/tt;

  Result.m[1,0]:=(m[1,2]*m[2,0]-m[1,0]*m[2,2])/tt;
  Result.m[1,1]:=(m[0,0]*m[2,2]-m[0,2]*m[2,0])/tt;
  Result.m[1,2]:=(m[0,2]*m[1,0]-m[0,0]*m[1,2])/tt;

  Result.m[2,0]:=(m[1,0]*m[2,1]-m[1,1]*m[2,0])/tt;
  Result.m[2,1]:=(m[0,1]*m[2,0]-m[0,0]*m[2,1])/tt;
  Result.m[2,2]:=(m[0,0]*m[1,1]-m[0,1]*m[1,0])/tt;
end;

function TAG2DMatrix.Transpose:TAG2DMatrix;
var
  i0,i1:byte;
begin
  for i0:=0 to 2 do
    for i1:=0 to 2 do
      Result.m[i1,i0]:=m[i0,i1];
end;

function TAG2DMatrix.GetPos:TAG2DVector;
begin
  Result.Create(m[2,0]/m[2,2],m[2,1]/m[2,2]);
end;

function TAG2DMatrix.InvAndGetPos:TAG2DVector;
var
  tt,z:double;
begin
  z:=(m[0,0]*m[1,1]-m[0,1]*m[1,0]);
  Result.x:=(m[1,0]*m[2,1]-m[1,1]*m[2,0])/z;
  Result.y:=(m[0,1]*m[2,0]-m[0,0]*m[2,1])/z;
end;

class operator TAG2DMatrix.Multiply(a,b:TAG2DMatrix):TAG2DMatrix;
var
  i0,i1,i2:byte;
begin
  for i0:=0 to 2 do
    for i1:=0 to 2 do
    begin
      Result.m[i0,i1]:=0;
      for i2:=0 to 2 do
        Result.m[i0,i1]:=Result.m[i0,i1]+a.m[i0,i2]*b.m[i2,i1];
    end;
end;

class operator TAG2DMatrix.Multiply(a:TAG2DVector;b:TAG2DMatrix):TAG2DVector;
var
  z:double;
begin
  z:=a.X*b.m[0,2]+a.Y*b.m[1,2]+b.m[2,2];
  Result.X:=(a.X*b.m[0,0]+a.Y*b.m[1,0]+b.m[2,0])/z;
  Result.Y:=(a.X*b.m[0,1]+a.Y*b.m[1,1]+b.m[2,1])/z;
end;

class operator TAG2DMatrix.Divide(a:TAG2DVector;b:TAG2DMatrix):TAG2DVector;
begin
  Result:=a*b.Invert;
end;

{TAG3DMatrix}

constructor TAG3DMatrix.Create(a:TArray<Single>);
var
  i0,i1:byte;
begin
  for i0:=0 to 3 do
    for i1:=0 to 3 do
      m[i0][i1]:=a[i0*4+i1];
end;

class function TAG3DMatrix.MkIdent():TAG3DMatrix;
begin
  Result:=TAG3DMatrix.Create([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
end;

constructor TAG3DMatrix.MkTrans(Trans:TAG3DVector);
begin
  Self:=Create([1,0,0,0,0,1,0,0,0,0,1,0,Trans.X,Trans.Y,Trans.Z,1]);
end;

constructor TAG3DMatrix.MkTrans(X,Y,Z:Single);
begin
  Self:=Create([1,0,0,0,0,1,0,0,0,0,1,0,X,Y,Z,1]);
end;

constructor TAG3DMatrix.MkScale(Scale:TAG3DVector);
begin
  Self:=Create([Scale.X,0,0,0,0,Scale.Y,0,0,0,0,Scale.Z,0,0,0,0,1]);
end;

constructor TAG3DMatrix.MkScale(Scale:Single);
begin
  Self:=Create([Scale,0,0,0,0,Scale,0,0,0,0,Scale,0,0,0,0,1]);
end;

constructor TAG3DMatrix.MkRotX(Rot:Single);
var
  sin,cos:Single;
begin
  SinCos(Rot,sin,cos);
  Self:=Create([1,0,0,0,0,cos,sin,0,0,0,-sin,cos,0,0,0,1]);
end;

constructor TAG3DMatrix.MkRotY(Rot:Single);
var
  sin,cos:Single;
begin
  SinCos(Rot,sin,cos);
  self:=Create([cos,0,-sin,0,0,1,0,0,sin,0,cos,0,0,0,0,1]);
end;

constructor TAG3DMatrix.MkRotZ(Rot:Single);
var
  sin,cos:Single;
begin
  SinCos(Rot,sin,cos);
  Self:=TAG3DMatrix.Create([cos,sin,0,0,-sin,cos,0,0,0,0,1,0,0,0,0,1]);
end;

(*
{{1,0,0,0},{0,cos(x),sin(x),0},{0,-sin(x),cos(x),0},{0,0,0,1}}*
{{cos(y),0,-sin(y),0},{0,1,0,0},{sin(y),0,cos(y),0},{0,0,0,1}}*
{{cos(z),sin(z),0,0},{-sin(z),cos(z),0,0},{0,0,1,0},{0,0,0,1}}
*)
constructor TAG3DMatrix.MkRot(Rot:TAG3DVector);
var
  sx,cx,sy,cy,sz,cz,t0,t1,t2,t3:Single;
begin
  SinCos(Rot.X,sx,cx);
  SinCos(Rot.Y,sy,cy);
  SinCos(Rot.Z,sz,cz);
  t0:=cx*sz;
  t1:=sx*sz;
  t2:=cx*cz;
  t3:=cz*sx;
  Self:=TAG3DMatrix.Create([
    cy*cz,    cy*sz,    -sy,   0,
    t3*sy-t0, t1*sy+t2, cy*sx, 0,
    t2*sy+t1, t0*sy-t3, cy*cx, 0,
    0,        0,        0,     1]);
end;

(*
({{1,0,0,0},{0,cos[x1],sin[x1],0},{0,-sin[x1],cos[x1],0},{0,0,0,1}}.
{{cos[y1],0,-sin[y1],0},{0,1,0,0},{sin[y1],0,cos[y1],0},{0,0,0,1}}.
{{cos[z1],sin[z1],0,0},{-sin[z1],cos[z1],0,0},{0,0,1,0},{0,0,0,1}}).

({{1,0,0,0},{0,cos[x],sin[x],0},{0,-sin[x],cos[x],0},{0,0,0,1}}.
{{cos[y],0,-sin[y],0},{0,1,0,0},{sin[y],0,cos[y],0},{0,0,0,1}}.
{{cos[z],sin[z],0,0},{-sin[z],cos[z],0,0},{0,0,1,0},{0,0,0,1}}).

({{1,0,0,0},{0,cos[x1],sin[x1],0},{0,-sin[x1],cos[x1],0},{0,0,0,1}}.
{{cos[y1],0,-sin[y1],0},{0,1,0,0},{sin[y1],0,cos[y1],0},{0,0,0,1}}.
{{cos[z1],sin[z1],0,0},{-sin[z1],cos[z1],0,0},{0,0,1,0},{0,0,0,1}})^1
*)
constructor TAG3DMatrix.MkRotWithIncline(Rot,Incline:TAG3DVector);
var
  temp:TAG3DMatrix;
begin
  temp:=MkRot(Incline);
  Self:=temp*MkRot(Rot)*temp.Invert;
end;

(*
{{x0,0,0,0},{0,y0,0,0},{0,0,z0,0},{0,0,0,1}}*
{{1,0,0,0},{0,cos(x1),sin(x1),0},{0,-sin(x1),cos(x1),0},{0,0,0,1}}*
{{cos(y1),0,-sin(y1),0},{0,1,0,0},{sin(y1),0,cos(y1),0},{0,0,0,1}}*
{{cos(z1),sin(z1),0,0},{-sin(z1),cos(z1),0,0},{0,0,1,0},{0,0,0,1}}*
{{1,0,0,0},{0,1,0,0},{0,0,1,0},{x2,y2,z2,1}}
*)
constructor TAG3DMatrix.MkSRT(Scale,Rot,Trans:TAG3DVector);
var
  sx,cx,sy,cy,sz,cz,t0,t1,t2,t3:Single;
begin
  SinCos(Rot.X,sx,cx);
  SinCos(Rot.Y,sy,cy);
  SinCos(Rot.Z,sz,cz);
  t0:=cx*sz;
  t1:=sx*sz;
  t2:=cx*cz;
  t3:=cz*sx;
  Self:=TAG3DMatrix.Create([
    Scale.X*cy*cz,     Scale.X*cy*sz,     -Scale.X*sy,    0,
    Scale.Y*(t3*sy-t0),Scale.Y*(t1*sy+t2),Scale.Y*(cy*sx),0,
    Scale.Z*(t2*sy+t1),Scale.Z*(t0*sy-t3),Scale.Z*(cy*cx),0,
    Trans.X,           Trans.Y,           Trans.Z,        1]);
end;

constructor TAG3DMatrix.MkCamToObject(Cam,Obj:TAG3DVector);
var
  zaxis,xaxis,yaxis:TAG3DVector;
begin
  zaxis:=(Obj-Cam).Normalize;
  with zaxis do
    xaxis:=TAG3DVector.Create(-Y,X,0).Normalize;
  //yaxis:=zaxis.CrossProduct(xaxis);
  yaxis.X:=-(zaxis.Z*xaxis.Y);
  yaxis.Y:=(zaxis.Z*xaxis.X);
  yaxis.Z:=(zaxis.X*xaxis.Y)-(zaxis.Y*xaxis.X);
  Self:=TAG3DMatrix.Create([
   xaxis.x,                         yaxis.x,               zaxis.x,              0,
   xaxis.y,                         yaxis.y,               zaxis.y,              0,
   0,                               yaxis.z,               zaxis.z,              0,
  -(xaxis.X*Cam.X)-(xaxis.Y*Cam.Y),-yaxis.DotProduct(Cam),-zaxis.DotProduct(Cam),1]);
end;

constructor TAG3DMatrix.MkCamToObject(Cam,Obj,UpDirection:TAG3DVector);
var
  zaxis,xaxis,yaxis:TAG3DVector;
begin
  zaxis:=(Obj-Cam).Normalize;
  xaxis:=(UpDirection.CrossProduct(zaxis)).Normalize;
  yaxis:=zaxis.CrossProduct(xaxis);
  Self:=TAG3DMatrix.Create([
   xaxis.x,               yaxis.x,               zaxis.x,              0,
   xaxis.y,               yaxis.y,               zaxis.y,              0,
   xaxis.z,               yaxis.z,               zaxis.z,              0,
  -xaxis.DotProduct(Cam),-yaxis.DotProduct(Cam),-zaxis.DotProduct(Cam),1]);
end;

{ToDo :оптимизировать на основе этого}
{a03 a12 a21 a30 - a02 a13 a21 a30 - a03 a11 a22 a30 +
 a01 a13 a22 a30 + a02 a11 a23 a30 - a01 a12 a23 a30 -
 a03 a12 a20 a31 + a02 a13 a20 a31 + a03 a10 a22 a31 -
 a00 a13 a22 a31 - a02 a10 a23 a31 + a00 a12 a23 a31 +
 a03 a11 a20 a32 - a01 a13 a20 a32 - a03 a10 a21 a32 +
 a00 a13 a21 a32 + a01 a10 a23 a32 - a00 a11 a23 a32 -
 a02 a11 a20 a33 + a01 a12 a20 a33 + a02 a10 a21 a33 -
 a00 a12 a21 a33 - a01 a10 a22 a33 + a00 a11 a22 a33}
//or
{a01 a13 a22 a30 - a01 a12 a23 a30 - a00 a13 a22 a31 +
 a00 a12 a23 a31 - a01 a13 a20 a32 + a00 a13 a21 a32 +
 a01 a10 a23 a32 - a00 a11 a23 a32 +
 a03 (a12 a21 a30 - a11 a22 a30 - a12 a20 a31 + a10 a22 a31 +
    a11 a20 a32 - a10 a21 a32) + a01 a12 a20 a33 - a00 a12 a21 a33 -
 a01 a10 a22 a33 + a00 a11 a22 a33 +
 a02 (-a13 a21 a30 + a11 a23 a30 + a13 a20 a31 - a10 a23 a31 -
    a11 a20 a33 + a10 a21 a33)}
function TAG3DMatrix.Determinant:double;
var
  t0,t1,t2,t3,t4,t5:double;
begin
  t0:=m[2,2]*m[3,3]-m[2,3]*m[3,2];
  t1:=m[2,0]*m[3,3]-m[2,3]*m[3,0];
  t2:=m[2,0]*m[3,1]-m[2,1]*m[3,0];
  t3:=m[2,1]*m[3,2]-m[2,2]*m[3,1];
  t4:=m[2,0]*m[3,2]-m[2,2]*m[3,0];
  t5:=m[2,1]*m[3,3]-m[2,3]*m[3,1];
  Result:=m[0,0]*(m[1,1]*t0-m[1,2]*t5+m[1,3]*t3);
  Result:=Result-m[0,1]*(m[1,0]*t0-m[1,2]*t1+m[1,3]*t4);
  Result:=Result+m[0,2]*(m[1,0]*t5-m[1,1]*t1+m[1,3]*t2);
  Result:=Result-m[0,3]*(m[1,0]*t3-m[1,1]*t4+m[1,2]*t2);
end;

function TAG3DMatrix.Invert:TAG3DMatrix;
var
  tt:double;
  t,b:array[0..11]of double;
  //i0,i1:byte;
begin
  tt:=Determinant;

  t[0]:=m[2,0]*m[3,1];
  t[1]:=m[2,0]*m[3,2];
  t[2]:=m[2,0]*m[3,3];
  t[3]:=m[2,1]*m[3,0];
  t[4]:=m[2,1]*m[3,2];
  t[5]:=m[2,1]*m[3,3];
  t[6]:=m[2,2]*m[3,0];
  t[7]:=m[2,2]*m[3,1];
  t[8]:=m[2,2]*m[3,3];
  t[9]:=m[2,3]*m[3,0];
  t[10]:=m[2,3]*m[3,1];
  t[11]:=m[2,3]*m[3,2];

  b[0]:=m[0,0]*m[1,1];
  b[1]:=m[0,0]*m[1,2];
  b[2]:=m[0,0]*m[1,3];
  b[3]:=m[0,1]*m[1,0];
  b[4]:=m[0,1]*m[1,2];
  b[5]:=m[0,1]*m[1,3];
  b[6]:=m[0,2]*m[1,0];
  b[7]:=m[0,2]*m[1,1];
  b[8]:=m[0,2]*m[1,3];
  b[9]:=m[0,3]*m[1,0];
  b[10]:=m[0,3]*m[1,1];
  b[11]:=m[0,3]*m[1,2];

  Result.m[0,0]:=(m[1,3]*(t[4]-t[7])+m[1,2]*(t[10]-t[5])+m[1,1]*(t[8]-t[11]))/tt;
  Result.m[0,1]:=(m[0,3]*(t[7]-t[4])+m[0,2]*(t[5]-t[10])+m[0,1]*(t[11]-t[8]))/tt;
  Result.m[0,2]:=(m[3,1]*(b[8]-b[11])+m[3,2]*(b[10]-b[5])+m[3,3]*(b[4]-b[7]))/tt;
  Result.m[0,3]:=(m[2,1]*(b[11]-b[8])+m[2,2]*(b[5]-b[10])+m[2,3]*(b[7]-b[4]))/tt;

  Result.m[1,0]:=(m[1,3]*(t[6]-t[1])+m[1,2]*(t[2]-t[9])+m[1,0]*(t[11]-t[8]))/tt;
  Result.m[1,1]:=(m[0,3]*(t[1]-t[6])+m[0,2]*(t[9]-t[2])+m[0,0]*(t[8]-t[11]))/tt;
  Result.m[1,2]:=(m[3,0]*(b[11]-b[8])+m[3,2]*(b[2]-b[9])+m[3,3]*(b[6]-b[1]))/tt;
  Result.m[1,3]:=(m[2,0]*(b[8]-b[11])+m[2,2]*(b[9]-b[2])+m[2,3]*(b[1]-b[6]))/tt;

  Result.m[2,0]:=(m[1,3]*(t[0]-t[3])+m[1,1]*(t[9]-t[2])+m[1,0]*(t[5]-t[10]))/tt;
  Result.m[2,1]:=(m[0,3]*(t[3]-t[0])+m[0,1]*(t[2]-t[9])+m[0,0]*(t[10]-t[5]))/tt;
  Result.m[2,2]:=(m[3,0]*(b[5]-b[10])+m[3,1]*(b[9]-b[2])+m[3,3]*(b[0]-b[3]))/tt;
  Result.m[2,3]:=(m[2,0]*(b[10]-b[5])+m[2,1]*(b[2]-b[9])+m[2,3]*(b[3]-b[0]))/tt;

  Result.m[3,0]:=(m[1,2]*(t[3]-t[0])+m[1,1]*(t[1]-t[6])+m[1,0]*(t[7]-t[4]))/tt;
  Result.m[3,1]:=(m[0,2]*(t[0]-t[3])+m[0,1]*(t[6]-t[1])+m[0,0]*(t[4]-t[7]))/tt;
  Result.m[3,2]:=(m[3,0]*(b[7]-b[4])+m[3,1]*(b[1]-b[6])+m[3,2]*(b[3]-b[0]))/tt;
  Result.m[3,3]:=(m[2,0]*(b[4]-b[7])+m[2,1]*(b[6]-b[1])+m[2,2]*(b[0]-b[3]))/tt;
end;

function TAG3DMatrix.Transpose:TAG3DMatrix;
var
  i0,i1:byte;
begin
  for i0:=0 to 3 do
    for i1:=0 to 3 do
      Result.m[i1,i0]:=m[i0,i1];
end;

function TAG3DMatrix.GetPos:TAG4DVector;
begin
  Result.Create(m[3,0],m[3,1],m[3,2],m[3,3]);
end;

function TAG3DMatrix.InvAndGetPos:TAG4DVector;
var
  tt,t0,t1,t2,t3,t4,t5:double;
  b:array[0..5]of double;
begin
  tt:=Determinant;

  t0:=m[2,0]*m[3,1]-m[2,1]*m[3,0];
  t1:=m[2,0]*m[3,2]-m[2,2]*m[3,0];
  t2:=m[2,1]*m[3,2]-m[2,2]*m[3,1];

  t3:=m[0,0]*m[1,1]-m[0,1]*m[1,0];
  t4:=m[0,0]*m[1,2]-m[0,2]*m[1,0];
  t5:=m[0,1]*m[1,2]-m[0,2]*m[1,1];

  Result.x:=(-m[1,2]*t0+m[1,1]*t1-m[1,0]*t2)/tt;
  Result.y:=( m[0,2]*t0-m[0,1]*t1+m[0,0]*t2)/tt;
  Result.z:=(-m[3,0]*t5+m[3,1]*t4-m[3,2]*t3)/tt;
  Result.w:=( m[2,0]*t5-m[2,1]*t4+m[2,2]*t3)/tt;
end;

class operator TAG3DMatrix.Multiply(a,b:TAG3DMatrix):TAG3DMatrix;
var
  i0,i1,i2:byte;
begin
  for i0:=0 to 3 do
    for i1:=0 to 3 do
    begin
      Result.m[i0,i1]:=0;
      for i2:=0 to 3 do
        Result.m[i0,i1]:=Result.m[i0,i1]+a.m[i0,i2]*b.m[i2,i1];
    end;
end;

class operator TAG3DMatrix.Multiply(a:TAG3DVector;b:TAG3DMatrix):TAG4DVector;
var
  i0,i1:byte;
begin
  for i0:=0 to 2 do
  begin
    Result.V[i0]:=b.m[3,i0];
    for i1:=0 to 2 do
      Result.V[i0]:=Result.V[i0]+a.V[i1]*b.m[i1,i0];
  end;
  Result.W:=a.X*b.m[0,3]+a.Y*b.m[1,3]+a.Z*b.m[2,3]+b.m[3,3];
end;

class operator TAG3DMatrix.Multiply(a:TAG4DVector;b:TAG3DMatrix):TAG4DVector;
var
  i0,i1:byte;
begin
  for i0:=0 to 3 do
  begin
    Result.V[i0]:=0;
    for i1:=0 to 3 do
      Result.V[i0]:=Result.V[i0]+a.V[i1]*b.m[i1,i0];
  end;
end;

class operator TAG3DMatrix.Divide(a:TAG3DVector;b:TAG3DMatrix):TAG3DVector;
begin
  Result:=a*b.Invert;
end;

{$IFDEF D3D9}
function TAG3DMatrix.ToD3D9Form:TD3DXMatrix;
begin
  Result:=TD3DXMatrix(Self);
end;

constructor TAG3DMatrix.FromD3D9Form(Matrix:TD3DXMatrix);
begin
  self:=TAG3DMatrix(Matrix);
end;
{$ENDIF}

{$IFDEF NeedWinAPILangConversion}
function StrToWinAPILang(Lang:String):DWORD;inline;
begin
//https://msdn.microsoft.com/ru-ru/library/cc250412.aspx
Result:=OEM_CHARSET;
if(Lang.ToLower='ansi')or(Lang.ToLower='ascii')then
  Result:=ANSI_CHARSET
else if(Lang.ToLower='def')or(Lang.ToLower='default')then
  Result:=DEFAULT_CHARSET
else if(Lang.ToLower='jp-jp')or(Lang.ToLower='japanese')or(Lang.ToLower='jp')or(Lang.ToLower='jpn')then
  Result:=SHIFTJIS_CHARSET
{else if(Local.ToLower='jp-jp')or(Local.ToLower='japanese')or(Local.ToLower='jp')or(Local.ToLower='jpn')then
  HANGEUL_CHARSET = 129;
  JOHAB_CHARSET = 130;
  GB2312_CHARSET = 134;
  CHINESEBIG5_CHARSET = 136;
  GREEK_CHARSET = 161;
  TURKISH_CHARSET = 162;
  VIETNAMESE_CHARSET = 163;
  HEBREW_CHARSET = 177;
  ARABIC_CHARSET = 178;
  THAI_CHARSET = 222;
  EASTEUROPE_CHARSET = 238;}
else if(Lang.ToLower='ru-ru')or(Lang.ToLower='russian')or(Lang.ToLower='ru')or(Lang.ToLower='rus')then
  Result:=RUSSIAN_CHARSET;
end;
{$ENDIF}

end.
