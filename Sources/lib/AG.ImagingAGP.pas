unit AG.ImagingAGP;

{$I ImagingOptions.inc}

interface

uses
  SysUtils,Classes,Imaging,ImagingTypes,ImagingIO,ImagingUtility;

type
  TAGPFileFormat=class(TImageFileFormat)
  protected
    procedure Define;override;
    function LoadData(Handle:TImagingHandle;var Images:TDynImageDataArray;OnlyFirstLevel:Boolean):Boolean;override;
    function SaveData(Handle:TImagingHandle;const Images:TDynImageDataArray;Index:LongInt):Boolean;override;
    procedure ConvertToSupported(var Image:TImageData;const Info:TImageFormatInfo);override;
  public
    function TestFormat(Handle:TImagingHandle):Boolean;override;
  end;

  TAGAGPHead=packed record
    Magic:String[4];
    &type,X,Y:Cardinal;
  end;

const
  AGPv0Magic:String[4]='AGP'#0;

implementation

procedure TAGPFileFormat.Define;
begin
  inherited;
  FName:='AGEngine Picture';
  FFeatures := [ffLoad, ffSave, ffMultiImage];
  FSupportedFormats := [ifGray8,ifA8Gray8,ifR3G3B2,ifR5G6B5,ifA1R5G5B5,ifA4R4G4B4,ifR8G8B8,ifA8R8G8B8];

  AddMasks('*.AGP');
end;

function TAGPFileFormat.LoadData(Handle:TImagingHandle;var Images:TDynImageDataArray;OnlyFirstLevel:Boolean):Boolean;
var
  Head:TAGAGPHead;
  ReadCount:Integer;
begin
  GetIO.Read(Handle,@Head,SizeOf(Head));
  SetLength(Images,1);
  if ReadCount=SizeOf(Head) then
  begin
    with Images[1] do
    begin
      Format:=TImageFormat(Head.&type);
      Width:=Head.X;
      Height:=Head.Y;
      Size:=GetPixelsSize(Format,Head.X,Head.Y);
      GetMem(Bits,Size);
      GetIO.Read(Handle,Bits,Size);
      Palette:=nil;
      Tag:=nil;
    end;
  end
  else
    Result:=False;
end;

function TAGPFileFormat.SaveData(Handle:TImagingHandle;const Images:TDynImageDataArray;Index:Integer):Boolean;
var
  Head:TAGAGPHead;
begin
  with Images[1] do
  begin
    Head.Magic:=AGPv0Magic;
    Head.&type:=Cardinal(Format);
    Head.X:=Width;
    Head.Y:=Height;
    GetIO.Write(Handle,@Head,SizeOf(Head));
    GetIO.Write(Handle,Bits,Size);
  end;
end;

procedure TAGPFileFormat.ConvertToSupported(var Image:TImageData;const Info:TImageFormatInfo);
begin
  ConvertImage(Image,ifA8R8G8B8);
end;

function TAGPFileFormat.TestFormat(Handle:TImagingHandle):Boolean;
var
  Magic:Array[0..3]of AnsiChar;
  ReadCount:Integer;
begin
  Result:=false;
  if Handle <> nil then
  begin
    ReadCount:=GetIO.Read(Handle,@Magic,4);
    GetIO.Seek(Handle,-ReadCount,smFromCurrent);
    Result:=(ReadCount=SizeOf(Magic))and(Magic=AGPv0Magic);
  end;
end;

initialization
  RegisterImageFileFormat(TAGPFileFormat);
end.
