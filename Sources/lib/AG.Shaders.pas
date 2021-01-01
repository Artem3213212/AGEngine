unit AG.Shaders;

interface

uses
  System.Classes;

type
  TAGShaderType=(
    CAGVertexShader,
    CAGPixelShader,
    CAGGeometryShader
    );

  TAGPixelShaderUsage=(
    CAGTextureShader,
    CAGPreProcessShader,
    CAGPostProcessShader
    );

  TAGShaderUsage=packed record
    &Type:TAGShaderType;
    PixelShaderType:TAGPixelShaderUsage;//if &Type=CPixelShader
    Num:SmallInt;//if PixelShaderType=CTextureShader
    constructor Create(&Type:TAGShaderType);overload;
    constructor Create(PixelShaderType:TAGPixelShaderUsage);overload;
    constructor Create(Num:SmallInt);overload;
  end;

  TAGShader=TStream;

implementation

{TShaderUsage}

constructor TAGShaderUsage.Create(&Type:TAGShaderType);
begin
Self.&Type:=&Type;
end;

constructor TAGShaderUsage.Create(PixelShaderType:TAGPixelShaderUsage);
begin
&Type:=CAGPixelShader;
Self.PixelShaderType:=PixelShaderType;
end;

constructor TAGShaderUsage.Create(Num:SmallInt);
begin
&Type:=CAGPixelShader;
Self.PixelShaderType:=CAGTextureShader;
Self.Num:=Num;
end;

end.
