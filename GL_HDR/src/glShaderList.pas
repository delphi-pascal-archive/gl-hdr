unit glShaderList;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}


interface

uses OpenGL15,GLSL,objects;

Const
  GLSL_SHADOW      = 0;
  GLSL_BUMP        = 1;
  GLSL_BUMP_SS     = 2;
  GLSL_PARALLAX    = 3;
  GLSL_PARALLAX_SS = 4;
var
  ShaderList  : Array [0..4] of TShader;


Procedure glInitShaders;
Function Get_Shader(S : String):Pshader;

implementation

Function Get_Shader(S : String):Pshader;
begin
    Result:=Nil;
 if SameText(S,'BUMP')        then Result := @ShaderList[GLSL_BUMP];
 if SameText(S,'BUMP_SS')     then Result := @ShaderList[GLSL_BUMP_SS];
 if SameText(S,'PARALLAX')    then Result := @ShaderList[GLSL_PARALLAX];
 if SameText(S,'PARALLAX_SS') then Result := @ShaderList[GLSL_PARALLAX_SS];
end;

Procedure glInitShaders;
const _exponent : single = 48.0;
begin
  SendToLog('Init Shaders');

  SendToLog('Init shadow shader');
  with ShaderList[ GLSL_SHADOW ] do
  begin
    Load(Appdir+'Shaders\shadow.fp', GL_FRAGMENT_SHADER_ARB);
    Load(Appdir+'Shaders\shadow.vp', GL_VERTEX_SHADER_ARB);
    Compile;
  end;

  SendToLog('Init bump shader');
  with ShaderList[ GLSL_BUMP ] do
  begin
    Load(Appdir+'Shaders\Shader1.fp', GL_FRAGMENT_SHADER_ARB);
    Load(Appdir+'Shaders\Shader1.vp', GL_VERTEX_SHADER_ARB);
    Compile;
  Start;
  // Передавать параметры можно через SetUniform и BIND (Остывается ссылка , и по этому он граздо быстрее остальных)
    Binduniform(GetUniform('exponent') ,@_exponent,1);
    SetUniform( GetUniform('color_map'   ),0);
    SetUniform( GetUniform('normal_map'  ),1);
    SetUniform( GetUniform('specular_map'),2);
    SetUniform( GetUniform('shadow_map0' ),3);

    SetUniform( GetUniform('' ),5);
  Stop;
 end;
{
  with ShaderList[ GLSL_BUMP_SS ] do
  begin
    Load(Appdir+'Shaders\Shader2.fp', GL_FRAGMENT_SHADER_ARB);
    Load(Appdir+'Shaders\Shader2.vp', GL_VERTEX_SHADER_ARB);
    Compile;
  Start;
  // Передавать параметры можно через SetUniform и BIND (Остывается ссылка , и по этому он граздо быстрее остальных)
    Binduniform(GetUniform('exponent') ,@_exponent,1);
    SetUniform( GetUniform('color_map'   ),0);
    SetUniform( GetUniform('normal_map'  ),1);
    SetUniform( GetUniform('specular_map'),2);
    SetUniform( GetUniform('shadow_map0' ),3);

    SetUniform( GetUniform('' ),5);
  Stop;
 end;
 }

end;


end.
