unit glRender_Post_Effect;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}


interface

uses OpenGL15, GLSL,GLRender_Check,Textures,objects;


Type
  PFBuff = ^TFBuff;
  TFBuff = Record
    Render,
    Texture      : Cardinal;
    Width,Height : Word;
  end;

Var
  HDRImage        : TFBuff;

Procedure CreateBuffer( Var Buff:TFBuff; W,H:Word; hdr:boolean; StorageType:Cardinal=GL_DEPTH_COMPONENT24 );
Procedure unBindBuff( );
Procedure BindBuff( V:PFBuff; Clear:Cardinal=GL_DEPTH_BUFFER_BIT );

Procedure ProcessPostEffect(HDRImage:Cardinal;FrameTime:Integer);
Procedure InitPostProcess;
implementation

var
  FrameBuffer  : Cardinal;
  RenderBuffers: array [0..8] of Cardinal;
  UsedBuffers  : Integer;



const
  GLSL_PE_blur         = 0;
  GLSL_PE_downLumLog   = 1;
  GLSL_PE_downLum      = 2;
  GLSL_PE_downLum2     = 3;
  GLSL_PE_downLumExp   = 4;
  GLSL_PE_downLumAdapt = 5;
  GLSL_PE_Final        = 6;
var
  ShaderList  : Array [0..6] of TShader;

  Lum         : Array [0..5] of TFBuff;
  Blur        : Array [0..3] of TFBuff;

  ToneSwap    : Boolean;
  ScreenQuad  : Cardinal;



Procedure BindBuff;
begin
	glBindFramebufferEXT      (GL_FRAMEBUFFER_EXT, FrameBuffer);
  glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                               GL_DEPTH_ATTACHMENT_EXT,
                               GL_RENDERBUFFER_EXT, v.render);
//	glBindRenderbufferEXT     (GL_RENDERBUFFER_EXT, v.Render);
  glViewport(0, 0, v.width, v.height);
  glFramebufferTexture2DExt (GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, v.Texture, 0);
  if Clear <> 0 then
  glClear( Clear );
//Writeln(v.Width, ' ' ,v.Height);
  CheckFrameBufferStatus;
end;

Procedure unBindBuff;
begin
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);
end;

Procedure CreateBuffer;
begin
  if UsedBuffers > high(RenderBuffers) then
   begin
     sendtolog('Please more render buffer!!');
     exit;
   end;

  Buff.Width        := W;
  Buff.Height       := H;
  if hdr then
  CreateHDRImage(Buff.Texture, W,H) else
  CreateImage(Buff.Texture, W,H);
  Buff.Render := RenderBuffers[ UsedBuffers ];
  glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, RenderBuffers[ UsedBuffers ]);
  glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, StorageType,
                           W, H);

  inc(UsedBuffers);
 glBindRenderbufferExt(GL_RENDERBUFFER_EXT, 0);
 glBindFramebufferExt(GL_FRAMEBUFFER_EXT, 0);
end;
{$Region 'Blur HDR Image'}

Procedure Calculate_Luminance(HdrImage:Cardinal; FrameTime:cardinal);

begin
  GLClearColor(0,0,0,0);
  BindBuff(@Lum[0]);

  Texture_Enable(HDRImage, 0);
  with ShaderList[GLSL_PE_downLumLog] do Start;
      glCallList(ScreenQuad);
  unBindBuff;

  BindBuff(@Lum[1]);
  Texture_Enable(Lum[0].Texture, 0);
  with ShaderList[GLSL_PE_downLum] do Start;
      glCallList(ScreenQuad);
  unBindBuff;

  BindBuff(@Lum[2]);
  Texture_Enable(Lum[1].Texture, 0);
  with ShaderList[GLSL_PE_downLum2] do Start;
      glCallList(ScreenQuad);
  unBindBuff;

  BindBuff(@Lum[3]);
  Texture_Enable(Lum[2].Texture, 0);
  with ShaderList[GLSL_PE_downLumExp] do Start;
      glCallList(ScreenQuad);
  unBindBuff;

  if ToneSwap then
  begin
    BindBuff(@Lum[5]);
    Texture_Enable(Lum[3].Texture, 0);
    Texture_Enable(Lum[4].Texture, 1);
  end else
  begin
    BindBuff(@Lum[4]);
    Texture_Enable(Lum[3].Texture, 0);
    Texture_Enable(Lum[5].Texture, 1);
  end;

    with ShaderList[GLSL_pe_downLumAdapt] do
    begin
      Start;
      SetUniform(GetUniform('dtime'), FrameTime *0.0010);
    end;

  glCallList(ScreenQuad);
  unBindBuff;

  ToneSwap := not ToneSwap;
  glUseProgramObjectARB(0);
end;


procedure BlurHDRImage(HDRImage:Cardinal);
begin
    BindBuff(@Blur[0]);
   Texture_Enable(HDRImage, 0);

  with ShaderList[glsl_pe_blur] do
  begin
    Start;
    glUniform4fARB( GetUniform ( 'blur_offset' ) , 4.0 / Width, 0.0, 0.0, 1.0 );
  end;

      glCallList(ScreenQuad);
    unBindBuff;
    BindBuff(@Blur[1]);

  with ShaderList[glsl_pe_blur] do
    glUniform4fARB( GetUniform ( 'blur_offset' ) , 0, 4.0 / Height, 0, 1 );

  Texture_Enable(blur[0].Texture, 0);
      glCallList(ScreenQuad);
  // All done!
  glUseProgramObjectARB(0);
  unBindBuff;
end;


Procedure ProcessPostEffect;
begin
  if gl_Fp_texture then
  Calculate_Luminance(HDRImage,FrameTime);
  BlurHDRImage(HDRImage);
  glViewport(0, 0, Width, Height);


    glDisable(GL_DEPTH_TEST);
  with ShaderList[ GLSL_PE_Final ] do
    Start;

  if ToneSwap then
      Texture_Enable(lum[5].texture , 2) else
      Texture_Enable(lum[4].texture , 2);

      Texture_Enable(Blur[1].Texture, 1);
      Texture_Enable(HDRImage  , 0);

      glCallList(ScreenQuad);

    Texture_Disable(0);
    Texture_Disable(1);
    Texture_Disable(2);

    glEnable(GL_DEPTH_TEST);
    glUseProgramObjectARB(0);

end;

{$EndRegion }

Procedure InitPostProcess;
var shaderdir : string;
begin

            ScreenQuad := glGenLists(1);
  glcolor3f(1,1,1);
  glNewList(ScreenQuad, GL_COMPILE);
      glBegin(GL_QUADS);
        glTexCoord2f(0, 0);   glVertex2f( -1 , -1);
        glTexCoord2f(1, 0);   glVertex2f(  1 , -1);
        glTexCoord2f(1, 1);   glVertex2f(  1 ,  1);
        glTexCoord2f(0, 1);   glVertex2f( -1 ,  1);
      glEnd;
  glEndList;

  UsedBuffers:=0;
  glGenFramebuffersEXT (1, @FrameBuffer);
  glGenRenderbuffersEXT( length(RenderBuffers)  , @RenderBuffers[0]);

  CreateBuffer(HDRImage, Width, Height, false);

  CreateBuffer(Blur[0], Width div 4, Height div 4, false);
  CreateBuffer(Blur[1], Width div 4, Height div 4, false);

  if gl_Fp_texture then
  begin
    CreateBuffer(Lum[0],32,32,true);
    CreateBuffer(Lum[1],16,16,true);
    CreateBuffer(Lum[2], 4, 4,true);
    CreateBuffer(Lum[3], 1, 1,true);
    CreateBuffer(Lum[4], 1, 1,true);
    CreateBuffer(Lum[5], 1, 1,true);
  end;


  ShaderDir := appdir+'Shaders\PostProcess\';
  with ShaderList[GLSL_PE_Blur] do
  begin
  //Загрузка бумпа
  Load(ShaderDir+'blur.fp', GL_FRAGMENT_SHADER_ARB);
  Load(ShaderDir+'v_prog.vp', GL_VERTEX_SHADER_ARB);
  //Его компиляция
   Compile;

  Start;
    SetUniform(GetUniform('t_hdrimage'),0);
  Stop;
  end;

  if gl_Fp_texture then
  begin

    with ShaderList[GLSL_PE_downLumLog] do
    begin
    //Загрузка бумпа
    Load(ShaderDir+'downLumLog.fp', GL_FRAGMENT_SHADER_ARB);
    Load(ShaderDir+'v_prog.vp'  , GL_VERTEX_SHADER_ARB);
    //Его компиляция
     Compile;

    Start;
      SetUniform(GetUniform('DownSampler')  ,0);
    Stop;
    end;

    with ShaderList[GLSL_PE_downLum] do
    begin
    //Загрузка бумпа
    Load(ShaderDir+'downLum.fp', GL_FRAGMENT_SHADER_ARB);
    Load(ShaderDir+'v_prog.vp'  , GL_VERTEX_SHADER_ARB);
    //Его компиляция
     Compile;

    Start;
      SetUniform(GetUniform('DownSampler')  ,0);
    Stop;
    end;

    with ShaderList[GLSL_PE_downLum2] do
    begin
    //Загрузка бумпа
    Load(ShaderDir+'downLum2.fp', GL_FRAGMENT_SHADER_ARB);
    Load(ShaderDir+'v_prog.vp'  , GL_VERTEX_SHADER_ARB);
    //Его компиляция
     Compile;

    Start;
      SetUniform(GetUniform('DownSampler')  ,0);
    Stop;
    end;

    with ShaderList[GLSL_PE_downLumExp] do
    begin
    //Загрузка бумпа
    Load(ShaderDir+'downLumExp.fp', GL_FRAGMENT_SHADER_ARB);
    Load(ShaderDir+'v_prog.vp'  , GL_VERTEX_SHADER_ARB);
    //Его компиляция
     Compile;

    Start;
      SetUniform(GetUniform('DownSampler')  ,0);
    Stop;
    end;


    with ShaderList[GLSL_PE_downLumAdapt] do
    begin
    //Загрузка бумпа
    Load(ShaderDir+'adaptLum.fp', GL_FRAGMENT_SHADER_ARB);
    Load(ShaderDir+'v_prog.vp'  , GL_VERTEX_SHADER_ARB);
    //Его компиляция
    Compile;

    Start;
      SetUniform(GetUniform('CurLum')  ,0);
      SetUniform(GetUniform('AdaptLum'),1);
    Stop;
    end;
  end;


  with ShaderList[GLSL_PE_Final] do
  begin
  //Загрузка бумпа
  if gl_Fp_texture then
  Load(ShaderDir+'tonemap.fp', GL_FRAGMENT_SHADER_ARB) else
  Load(ShaderDir+'tonemap_only.fp', GL_FRAGMENT_SHADER_ARB);
  Load(ShaderDir+'v_prog.vp', GL_VERTEX_SHADER_ARB);
  //Его компиляция
   Compile;

  Start;
      SetUniform(GetUniform('srcImage'),0);
      SetUniform(GetUniform('blurYImage'),1);
      SetUniform(GetUniform('adaptLumImage'),2);
      SetUniform(GetUniform('exposure'),1.0);
  Stop;
  end;


end;

end.
