unit GLSL;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}
interface
uses OpenGL15, Windows;

Type
  GLHandleARB = Integer;
  PShader = ^TShader;
  TShader = object
  private
    sh       : GLHandleARB;
    shaders  : array of GLHandleARB;
    Procedure SetUniformV(uniform:Cardinal; value:PGLFloat; Size:byte);
    Procedure SetAttribV (uniform:Cardinal; value:PGLFloat; Size:byte);
    function  CheckForErrors(glObject: GLHandleARB): String;
  public
    Tangent,
    Binormal  : Cardinal;
    procedure Load(Filename: string; Shader_Type: Glenum;Define:String='');
    Function  Compile : boolean;
    procedure Start;
    procedure Stop;
    procedure Free;
    function  GetInfoLog: string;
    function  GetUniform(uniform: PChar): GLuint;
    function  GetAttrib(attrib: PChar): GLuint;
    procedure SetUniform(uniform: GLuint; value0: Single); overload;
    procedure SetUniform(uniform: GLuint; value0: Integer); overload;
    procedure SetUniform(uniform: GLuint; value0, value1: Single); overload;
    procedure SetUniform(uniform: GLuint; value0, value1, value2: Single); overload;
    procedure SetUniform(uniform: GLuint; value0, value1, value2, value3: Single); overload;

    procedure SetAttrib (uniform: GLuint; value0 : Single); overload;
    procedure SetAttrib (uniform: GLuint; value0, value1 : Single); overload;
    procedure SetAttrib (uniform: GLuint; value0, value1, value2: Single); overload;
    procedure SetAttrib (uniform: GLuint; value0, value1, value2,value3: Single); overload;
    procedure BindUniform(uniform:GLuint; Value: PGLFLoat; size:byte); overload;
    procedure BindUniform(const name:string; Value: PGLFLoat; size:byte); overload;
    procedure BindAttrib(uniform:GLuint; Value: PGLFLoat; size:Byte); overload;
    procedure BindAttrib(const name:string; Value: PGLFLoat; size:byte); overload;
  end;

Procedure StopShader;

implementation
uses objects;
Const
 WND_GLSL = 'GLSL 1.00 :';

function TShader.CheckForErrors(glObject: GLHandleARB): String;
 var
  blen, slen: GLInt;
  InfoLog   : PGLCharARB;
begin
 glGetObjectParameterivARB(glObject, GL_OBJECT_INFO_LOG_LENGTH_ARB, @blen);
 if blen > 1 then
 begin
  GetMem(InfoLog, blen*SizeOf(PGLCharARB));
  glGetInfoLogARB(glObject, blen , slen, InfoLog);
  Result:= PChar(InfoLog);
  Dispose(InfoLog);
 end;
end;

procedure TShader.Load(Filename: string; Shader_Type: Glenum;Define:String='');
var
  str,tmp: string;
  F      : Text;
  source : PChar;
  shader : Cardinal;
  i,
  status : integer;
begin
  if not GL_ARB_shading_language_100 then
//  begin
//    MessageBox('Can''t initializate Shader', 1);
    exit;
 // end;

  If Not FileExists(FileName) then exit;

  str := '';
  for I := 1 to Length(Define)  do
  case Define[i] of
   '|':  str := str + #13+#10;
  else  str := str + Define[i];
  end;
//  messagebox(str +#13+#10 + 'define:'+define,0);

  AssignFile(f, Filename);
  Reset(f);
  repeat
    ReadLn(f, tmp);
    str := str + tmp + #13#10;
  until Eof(f);
  CloseFile(f);

  source := PChar(str);
  shader := glCreateShaderObjectARB(Shader_Type);
  if shader = 0 then
  begin
    MessageBox(0, 'Error creating shader object', 'Error', MB_OK);
    exit;
  end;
  glShaderSourceARB(shader, 1, @source, nil);
  glCompileShaderARB(shader);
  glGetObjectParameterivARB(shader, GL_OBJECT_COMPILE_STATUS_ARB, @status);
  if status <> 1 then
  begin
    messagebox(0,Pchar(CheckForErrors(shader) +#13+#10+filename),'',1);
    glDeleteObjectARB(shader);
    exit;
  end;
  SetLength(shaders, length(shaders)+1);
  shaders[length(shaders)-1] := shader;
end;

Function TShader.Compile : boolean;
var
  i: integer;
  status: integer;
begin
  if not GL_ARB_shading_language_100 then exit;

  sh := glCreateProgramObjectARB;
  for i := 0 to length(shaders)-1 do
    glAttachObjectARB(sh, shaders[i]);
  glLinkProgramARB(sh);

  glGetObjectParameterivARB(sh, GL_OBJECT_LINK_STATUS_ARB, @status);
  Result:=true;

  if status <> 1 then
  begin
    Result:=false;
    glDeleteObjectARB(sh);
    MessageBox(0,'Error while compiling','', 1);
    exit;
  end;
end;

procedure TShader.Start;
begin
  if not GL_ARB_shading_language_100 then exit;
  glUseProgramObjectARB(sh);
  CurShader := @Self;
end;

function TShader.GetInfoLog: string;
var
  LogLen, Written: Integer;
begin
  Result:='';
  glGetObjectParameterivARB(Sh, GL_OBJECT_INFO_LOG_LENGTH_ARB, @LogLen);
  if LogLen<1 then Exit;
  SetLength(Result, LogLen);
  glGetInfoLogARB(Sh, LogLen, Written, PChar(Result));
  SetLength(Result, Written);
end;

procedure TShader.Stop;
begin
  if not GL_ARB_shading_language_100 then exit;
  glUseProgramObjectARB(0);
end;

procedure TShader.Free;
begin
  if not GL_ARB_shading_language_100 then exit;
  glDeleteObjectARB(sh);
end;

function TShader.GetUniform(uniform: PChar): GLuint;
begin
  Result := 0;
  if not GL_ARB_shading_language_100 then exit;
  Result := glGetUniformLocationARB(sh, uniform);
end;

function TShader.GetAttrib(attrib: PChar): GLuint;
begin
  Result := 0;
  if not GL_ARB_shading_language_100 then exit;
  Result := glGetAttribLocationARB(sh, attrib);
end;

procedure TShader.SetUniform(uniform: GLuint; value0: Integer);
begin
  if not GL_ARB_shading_language_100 then exit;
  glUniform1iARB(uniform, value0);
end;

procedure TShader.SetUniform(uniform: GLuint; value0: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glUniform1fARB(uniform, value0);
end;

procedure TShader.SetUniform(uniform: GLuint; value0, value1: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glUniform2fARB(uniform, value1, value1);
end;

procedure TShader.SetUniform(uniform: GLuint; value0, value1, value2: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glUniform3fARB(uniform, value0, value1, value2);
end;

procedure TShader.SetUniform(uniform: GLuint; value0, value1, value2, value3: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glUniform4fARB(uniform, value0, value1, value2, value3);
end;

procedure TShader.SetAttrib(uniform: GLuint; value0: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glVertexAttrib1f(uniform,value0);
end;

procedure TShader.SetAttrib(uniform: GLuint; value0: Single; value1: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glVertexAttrib2f(uniform,value0,value1);
end;

procedure TShader.SetAttrib(uniform: GLuint; value0, value1, value2: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glVertexAttrib3f(uniform,value0,value1,value2);
end;

procedure TShader.SetAttrib(uniform: GLuint; value0, value1, value2, value3: Single);
begin
  if not GL_ARB_shading_language_100 then exit;
  glVertexAttrib4f(uniform,value0,value1,value2,value3);
end;



procedure TShader.BindUniform(uniform:GLuint; Value: PGLFLoat; size:Byte);
begin
  if not GL_ARB_shading_language_100 then exit;
      SetUniformV(uniform,value,size);
end;


procedure TShader.BindUniform(const name:string; Value: PGLFLoat; size:Byte);
var uniform:cardinal;
begin
  if not GL_ARB_shading_language_100 then exit;
  if (sh = 0) then exit;

      glUseProgramObjectARB(sh);
      uniform := glGetUniformLocationARB(sh, pchar(name));
      SetUniformV(uniform,value,size);
end;

procedure TShader.BindAttrib(uniform:GLuint; Value: PGLFLoat; size:Byte);
begin
  if not GL_ARB_shading_language_100 then exit;
      SetAttribV(uniform,value,size);
end;

procedure TShader.BindAttrib(const name:string; Value: PGLFLoat; size:Byte);
var uniform:cardinal;
begin
  if not GL_ARB_shading_language_100 then exit;
  if (sh = 0) then exit;

      glUseProgramObjectARB(sh);
      uniform := glGetUniformLocationARB(sh, pchar(name));
      SetAttribV(uniform,value,size);
end;

Procedure TShader.SetUniformV(uniform:Cardinal; value:PGLFloat; Size:Byte);
begin
      if      (size = 1) then glUniform1fvARB(uniform, 1, value)
      else if (size = 2) then glUniform2fvARB(uniform, 1, value)
      else if (size = 3) then glUniform3fvARB(uniform, 1, value)
      else if (size = 4) then glUniform4fvARB(uniform, 1, value)
      else if (size = 9) then glUniformMatrix3fvARB(uniform, 1, false, value)
      else if (size = 16) then glUniformMatrix4fvARB(uniform, 1, false, value);
end;

Procedure TShader.SetAttribV(uniform:Cardinal; value:PGLFloat; Size:Byte);
begin
      if      (size = 1) then glVertexAttrib1fv(uniform, value)
      else if (size = 2) then glVertexAttrib2fv(uniform, value)
      else if (size = 3) then glVertexAttrib3fv(uniform, value)
      else if (size = 4) then glVertexAttrib4fv(uniform, value)
      else if (size = 9) then glUniformMatrix3fvARB(uniform, 1, false, value)
      else if (size = 16) then glUniformMatrix4fvARB(uniform, 1, false, value);
end;

Procedure StopShader;
begin
  if GL_ARB_shading_language_100 then
  glUseProgramObjectARB(0);
end;

end.

