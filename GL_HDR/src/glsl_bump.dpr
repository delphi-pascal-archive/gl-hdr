{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

{$APPTYPE CONSOLE}
{$Warnings off
 $Hinst on}
uses
  Windows,messages, OpenGL15,GLSL,sysutils,MmSystem,
  objects, frust,
  T_Camera,
  l_math,
  sam2_unit,
  textures,wnd_setup,fnt,
  glRender_Check,
  glRender_Post_Effect,
  glShaderList;

Const
  WndName        = 'http://www.rtbt.ru';
  PrjName        = 'OpenGL';
  CubeMapSize    = 256;
  GLSL_Bump      = 0;
  CubeMapsCount  = 2;
  ZBias          : Array [0..CubeMapsCount] of single = (0.0100,0.0150,0.0200);

  type
   PLight =^TLight;
   TLight = Object
      Pos,
      Spos,
      Ran    : TVec3f;
      Radius : Single;
      Color  : TVec3f;
      Speed  : TVec3f;
     Scissor : TClipRect;

     CubeLod : Integer;
     CubeMaps: Array [0..CubeMapsCount] of Cardinal;

      id : integer;
      OQ : Cardinal;
      LAABB: TAABB;

    Procedure DrawBOX;
    procedure UpdateShadowMap();
    end;
var
  msg         : TMsg;
  WndClass    : TWndClass;

  //Позиция света
  Light,
  RenderLight : array of TLight;
  LightQueries: Array of Cardinal;
  rendercount : Integer;

  Model    : TSam2Model;
  Font     : Cardinal;

  update      : integer;
  DrawInfo    : boolean=true;
  usehdr      : boolean;
  FrameBuffer  : Cardinal;
  RenderBuffers : Array [0..CubeMapsCount] of Cardinal;

{$Region 'glLight_'}
procedure glLight_cfg(ID: integer);
const
       light_position  : Array[0..3] of Single = (0, 0, 0, 1);
       light_ambient   : Array[0..3] of Single = (0.0, 0.0, 0.0, 1);
       light_diffuse   : Array[0..3] of Single = (1, 1, 1, 100);//Red Green Blue Light Radius
       light_specular  : Array[0..3] of Single = (1, 1, 1, 1);
begin
glLightfv(ID, GL_POSITION, @light_position);
glLightfv(ID, GL_AMBIENT , @light_ambient);
glLightfv(ID, GL_DIFFUSE,  @light_diffuse);
glLightfv(ID, GL_SPECULAR, @light_specular);

end;

procedure glLight_Pos(ID: integer; Pos:TVector);
var
 p : array [0..3] of single;
begin
p[0] := pos.X;
p[1] := pos.Y;
p[2] := pos.Z;
p[3] := 1;
glLightfv(ID, GL_POSITION, @p);
end;

procedure glLight_Color4f(ID: integer; clr:TVector;R:Single);
var
 c : array [0..3] of single;
begin
c[0] := clr.x;
c[1] := clr.y;
c[2] := clr.z;
c[3] := R;
glLightfv(ID, GL_DIFFUSE,  @c);
glLightfv(ID, GL_SPECULAR, @c);
end;
{$EndRegion}

const Ln = #13+#10;



procedure InitLights;

function CreateNewCube(res: Integer): Cardinal;
var
  i: GLenum;
begin
  glGenTextures(1, @Result);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, Result);

    glTexParameteri ( GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE );

  for i := GL_TEXTURE_CUBE_MAP_POSITIVE_X to GL_TEXTURE_CUBE_MAP_NEGATIVE_Z do
    glCopyTexImage2D(i, 0, GL_RGB, 0, 0, res, res, 0);

  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
end;

var
  i,j : LongInt;
  F : TextFile;
begin
    SetLength(Light       ,0);
    SetLength(RenderLight ,0);
//  AssignFile(logF, appdir+'lights.txt');
//  ReWrite(logF);

  AssignFile(F, 'lights.txt');
  Reset(F);
//  i:=0;
  repeat
   i := Length(Light);
     SetLength(Light, i + 1);
   ReadLN(f, Light[i].Pos.x,Light[i].Pos.y,Light[i].Pos.z );
   ReadLN(f, Light[i].color.x,Light[i].color.y,Light[i].color.z );
  until eof(f);
  CloseFile(F);
  SetLength(RenderLight, Length(light));

  SetLength( LightQueries, Length(light) );
  glGenQueriesARB(    Length(light) ,@LightQueries[0]);

  for i := 0 to Length(Light) - 1 do
    with Light[i] do
    begin
      id  := i;
      Spos := pos;
      Radius := 150;
      for j := 0 to CubeMapsCount do
      CubeMaps[j] := CreateNewCube(CubeMapSize shr j);
    speed    := Vector((Random(196)+63) / 255,(Random(196)+63) / 255,(Random(196)+63) / 255);

    end;
end;

procedure UpdateLights;
var
  i : LongInt;
begin
  for i := 0 to Length(Light) - 1 do
    with Light[i] do
    begin
      Ran := Ran + Speed * FrameTime *0.1;
      if ran.x > 360 then ran.x:=0;
      if ran.y > 360 then ran.y:=0;
      if ran.z > 360 then ran.z:=0;

      Pos := SPos + V_CreateOFFSET(Ran.y,ran.x)*20;
      LAABB := uaabbfromsphere(Light[i].pos,Light[i].Radius);
    end;
end;

Function cubeProjectionMatrixGL(const zNear, zFar: Single) : TMat4f;
begin
result.row[0] := vec4f(1,  0, 0, 0);
result.row[1] := vec4f(0, -1, 0, 0);
result.row[2] := vec4f(0,  0, (zFar + zNear) / (zFar - zNear), -(2 * zFar * zNear) / (zFar - zNear));
result.row[3] := vec4f(0,  0, 1, 0);
end;

procedure TLight.UpdateShadowMap;
var
  cs: Cardinal;
  dist : Single;
  j: Integer;
  B: Array [0..10000] of integer;
  bc:Integer;
begin
    Sphere.POS := Pos;
    Sphere.R   := Radius;
    Sphere.AABB:= LAABB;
    dist := v_dist(pos,cam.Pos);

       CubeLod :=0;
    if dist > Radius   then CubeLod :=1;
    if dist > Radius*Radius then CubeLod :=2;


           bc:= 0;
         with model do
         for j := 0 to high(objs) do
         with objs[ j ] do
           if uAABBVsAABB(AABB.mins,AABB.MAXS, LAabb.MINS,LAabb.MAXS) then
           begin
            b[ bc ] := j;
           inc(bc);
           end;

    { $define FBOShadow}
{$ifdef FBOShadow}
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FrameBuffer);

  glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                               GL_DEPTH_ATTACHMENT_EXT,
                               GL_RENDERBUFFER_EXT, RenderBuffers[CubeLod]);
{$endif}


  glViewport(0, 0, CubeMapSize shr cubelod, CubeMapSize shr cubelod);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(90, 1, 1, radius);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

    for cs := GL_TEXTURE_CUBE_MAP_POSITIVE_X to GL_TEXTURE_CUBE_MAP_NEGATIVE_Z do
    begin
{$ifdef FBOShadow}
      glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
                                GL_COLOR_ATTACHMENT0_EXT,
                                CS, CubeMaps[CubeLod], 0);

{$endif}
      glClear(GL_DEPTH_BUFFER_BIT);
      glLoadIdentity;
      case cs of
        GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB: begin
            glRotatef(180, 0, 0, 1);
            glRotatef(90, 0, 1, 0);
          end;
        GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB: begin
            glRotatef(-90, 1, 0, 0);
          end;
        GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB: begin
            glRotatef(180, 1, 0, 0);
          end;
        GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB: begin
            glRotatef(180, 0, 0, 1);
            glRotatef(-90, 0, 1, 0);
          end;
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB: begin
            glRotatef(90, 1, 0, 0);
          end;
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB: begin
            glRotatef(180, 0, 0, 1);
          end;
      end;
      with Pos do glTranslatef(-x, -y, -z);
      CalculateFrustum;

     glLight_cfg(gl_light0);
     glLight_Pos(gl_light0,Pos);
     glLight_Color4f(GL_Light0 , Color ,1 / Radius);
     ShaderList[ GLSL_SHADOW ].start;
   glEnableClientState(GL_VERTEX_ARRAY);
//       gldisable(gl_depth_test);

         with model do
         for j := 0 to bc-1 do
         with objs[ b[j] ] do
           if BoxInFrustum( AABB.MINS, AABB.MAXS) then
           begin
                glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buff );
                glVertexPointer  (3, GL_FLOAT, 0, nil  );
                glDrawArrays(GL_TRIANGLES, 0,v_count);
           end;
   glDisableClientState(GL_VERTEX_ARRAY);
   glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
   glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

     glUseProgramObjectARB(0);

{$ifdef FBOShadow}
{$else}
      glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, CubeMaps[CubeLod]);
      glCopyTexSubImage2D(cs, 0, 0, 0, 0, 0, CubeMapSize shr CubeLod, CubeMapSize shr CubeLod);

{$endif}
    end;

{$ifdef FBOShadow}
//  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);
{$endif}
  glViewport(0, 0, Width, Height);

end;

Procedure TLight.DrawBOX;
var S:Single;
begin
 GLPushMatrix;
 S := sqrt(Radius*Radius);
    GlTranslateF(pos.X,pos.Y,pos.Z);
 glBegin(GL_QUADS);
    glVertex3f(-s , s, s); glVertex3f(-s ,-s, s); glVertex3f( s ,-s, s); glVertex3f( s , s, s);
//    --
    glVertex3f(-s , s,-s); glVertex3f( s , s,-s); glVertex3f( s ,-s,-s); glVertex3f(-s ,-s,-s);
//    --
    glVertex3f(-s , s,-s); glVertex3f(-s ,-s,-s); glVertex3f(-s ,-s, s); glVertex3f(-s , s, s);
//    --
    glVertex3f( s , s,-s); glVertex3f( s , s, s); glVertex3f( s ,-s, s); glVertex3f( s ,-s,-s);
//    --
    glVertex3f( s , s, s); glVertex3f( s , s,-s); glVertex3f(-s , s,-s); glVertex3f(-s , s, s);
//    --
    glVertex3f(-s ,-s, s); glVertex3f(-s ,-s,-s); glVertex3f( s ,-s,-s); glVertex3f( s ,-s, s);
  glEnd;
 GLPopMatrix;
end;



{ ------------------------------------------------------------------------ }
{ --Обработка всех вычислений -------------------------------------------- }
{ ------------------------------------------------------------------------ }
Procedure Process;
begin
  cam.UpdateMouse( WND_Rect.Left + (WND_Rect.Right - WND_Rect.Left) div 2 ,
                   WND_Rect.top  + (WND_Rect.Bottom - WND_Rect.Top) div 2 );
  if Keys[ord('W')] then cam.Move(  0, 1,frameTime/10);
  if Keys[ord('S')] then cam.Move(180,-1,frameTime/10);
  if Keys[ord('A')] then cam.Move(-90, 0,frameTime/10);
  if Keys[ord('D')] then cam.Move( 90, 0,frameTime/10);


  if Keys[vk_space] then
  begin
    UseHdr := not UseHdr;
    Keys[vk_space] := false;
  end;

  if Keys[ord('H')] then
  begin
    DrawInfo := not DrawInfo;
    Keys[ord('H')] := false;
  end;
end;

procedure glRenderScene(mode:integer);
begin
  Model.Render(mode,vec3f(0,0,0),vec3f(0,0,0));
end;

{ ------------------------------------------------------------------------ }
{ --Отрисовка ------------------------------------------------------------ }
{ ------------------------------------------------------------------------ }

Procedure DrawScene;
var
  i : integer;
  gw,gh:integer;

  Procedure CalcShadows;
  var i : integer;
  begin
    for i := 0 to rendercount-1 do
    with RenderLight[i] do
         UpdateShadowMap();
  end;

begin
  if keys[ord('G')] then
    Light[0].Pos  := cam.pos;

//  if update > 2 then
  begin
    gw:= width div 2;
    gh:= height div 2;
  glViewport(0, 0, gw, gh);
  glClear(GL_DEPTH_BUFFER_BIT);

  glPolygonMode(gl_front, gl_fill);
  SetProjection(gw,gh,false);

     glLoadIdentity;
     glRotatef( Cam.Tilt   , 1, 0, 0);
     glRotatef( Cam.Heading, 0, 1, 0);
     glTranslatef(-Cam.Pos.x, -Cam.Pos.y, -Cam.Pos.z);
     CalculateFrustum;

      glRenderScene(1);
      glDepthMask(false);
      rendercount := 0;

      for i := 0 to high(light) do
      if SphereInFrustum(light[i].Pos,light[i].Radius) then
      begin
           Light[i].OQ := 0;
           glBeginQueryARB(GL_SAMPLES_PASSED_ARB, LightQueries[ i ]);
           Light[i].DrawBOX;
           glEndQueryARB(GL_SAMPLES_PASSED_ARB);
           glGetQueryObjectuivARB(LightQueries[ i ], GL_QUERY_RESULT_ARB,@light[i].oq);

             if (light[i].oq > 0) or uAABBvsSphere(light[i].LAABB.MINS,light[i].LAABB.MAXS,Cam.Pos,10)  then
             if LightScissorRect(light[i].Pos,light[i].Radius, light[i].scissor) then
             begin
                  RenderLight[rendercount] := light[i];
                  inc(rendercount);
             end;
      end;

      glDepthMask(true);


      update := 0;
  end;
  inc(update);


  CalcShadows;

  if Keys[ord('F')] then
  glPolygonMode(gl_front, gl_line);
  if usehdr then
  BindBuff(@HDRImage);
  glViewport(0, 0, Width, Height);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  SetProjection(width,Height,false);
  glLoadIdentity;

     glRotatef( Cam.Tilt   , 1, 0, 0);
     glRotatef( Cam.Heading, 0, 1, 0);
  glTranslatef(-Cam.Pos.x, -Cam.Pos.y, -Cam.Pos.z);
  CalculateFrustum;


      glcolor3f(0.0,0.0,0.0);
      glRenderScene(2);

      glDepthFunc(GL_EQUAL);
      glDepthMask(False);
      glEnable(GL_BLEND);
      glBlendFunc(GL_ONE, GL_ONE);


   glEnable(GL_SCISSOR_TEST);

  for i := 0 to rendercount -1 do
  begin
     curLight.pos   :=        RenderLight[i].pos;
     curLight.ZBias := Zbias[ RenderLight[i].CubeLod ];

     TextureCubeMap_Enable(RenderLight[i].CubeMaps[ RenderLight[i].CubeLod ],3);

     glLight_cfg(gl_light0);
     glLight_Pos(gl_light0,RenderLight[i].Pos);
     glLight_Color4f(GL_Light0 , RenderLight[i].Color ,1 / RenderLight[i].Radius);

     Sphere.POS := RenderLight[i].Pos;
     Sphere.R   := RenderLight[i].Radius;
     Sphere.AABB:= RenderLight[i].LAABB;
     with RenderLight[i] do
    glscissor(Scissor[0],            Scissor[1],
              Scissor[2]-Scissor[0], Scissor[3]-Scissor[1]);

        glRenderScene(3);
  end;
           TextureCubeMap_Disable(3);

   glDisable(GL_SCISSOR_TEST);

  glDepthFunc(GL_LESS);
  glDisable(GL_BLEND);
  glDepthMask(true);

  glUseProgramObjectARB(0);
    {
  if DrawInfo then
  begin
  glEnable(GL_POINT_SMOOTH);
  GLDisable(gl_depth_test);
  glPointSize(4);
  glBegin(GL_POINTS);
    for i := 0 to rendercount-1 do
    begin
      glColor3fv(@RenderLight[i].Color);
      glVertex3fv(@RenderLight[i].Pos);
    end;
  glEnd;

  glColor3f(1,1,1);
  GLenable(gl_depth_test);
  end;
     }
  if usehdr then
  unBindBuff;


  UpdateLights;
end;

procedure GLDraw;
begin
    DrawScene;
  if usehdr then
    ProcessPostEffect(hdrImage.Texture,FrameTime);

  glColor3f(1,1,1);
  SetProjection(width,height,true);
    if DrawInfo then
    begin
      TextOut(font,0,10,10,'FPS:'+inttostr(fps)+' lights:'+inttostr(rendercount)+' hdr:'+IntToStr(integer(usehdr)) );
      TextOut(font,0,10,30,'By SVSD_VAL (powered by delphi)');
      TextOut(font,0,10,50,'http://rtbt.ru');
      TextOut(font,0,10,70,'h - show/hide this text');
    end else
      TextOut(font,0,10,10,' hdr:'+IntToStr(integer(usehdr)) );

end;

procedure InitShaders;
var
i : integer;

begin
  glGenFramebuffersEXT(1, @FrameBuffer);
  glGenRenderbuffersEXT(CubeMapsCount, @RenderBuffers);
  for I := 0 to CubeMapsCount do
  begin
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, RenderBuffers[i]);
    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24,CubeMapSize shr i, CubeMapSize shr i);
  end;
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);

  glInitShaders;

end;

Procedure WaitVSync(b:boolean);
begin
if @wglSwapIntervalEXT <> nil then
      wglSwapIntervalEXT(Byte(b));
end;

procedure glInit;
VAR
	pfd:TPixelFormatDescriptor;
  I  :INTEGER;
begin

  FillChar(pfd,sizeof(pfd),0);
  H_DC:=GetDC(h_Wnd);
  pfd.nSize:=SizeOf(pfd);
  pfd.nVersion:=1;
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType:=PFD_TYPE_RGBA;
  pfd.cColorBits:=24;
  pfd.cDepthBits:=24;
  i:=ChoosePixelFormat(H_DC,@pfd);
  SetPixelFormat(H_DC,i,@pfd);
  H_RC:=wglCreateContext(H_DC);

  ActivateRenderingContext(h_dc,h_rc);

  glEnable   (GL_DEPTH_TEST);
  glDepthFunc(GL_LESS);
  glHint     (GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
  glEnable   (GL_TEXTURE_2D);
  glEnable(GL_CULL_FACE);
  glShadeModel(GL_SMOOTH);
  glClearDepth(1.0);
  glEnable(GL_TEXTURE_2D);
  glViewPort(0, 0, Width, Height);

  /////////////////////////////
//  glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 40);
  SetProjection(WIDTH,HEIGHT,FALSE);
//  GLClearColor(0.3,0.3,0.3,0);
  GLClearColor(0,0,0,0);

  if not GL_ARB_shading_language_100 then
    messagebox(0,'For GLSL bump demo need (ARB_shading_language_100)','Warning', MB_ICONWARNING);
  CheckForFPTextrue;
  InitPostProcess;

  cam.DST :=20;
  cam.Init(v_identity,0,0);
  InitShaders;
  Font := FontCreate('Courier New Cyr',12,512);

  GFXDir   := AppDir + 'textures\';
  Model    := TSam2Model.Create;
  Model.LoadFromFile('models\test.tri.sam');

    cam.pos     := vector(-10, 50, 150);
    cam.tilt    := 28;
    cam.heading := 0;
    FrameTime := 16;

  InitLights;
  WaitVSync( Options.vsync );
  SetCursorPos(WND_Rect.Left + (WND_Rect.Right - WND_Rect.Left) div 2 ,
                   WND_Rect.top  + (WND_Rect.Bottom - WND_Rect.Top) div 2);
end;

function WndProc(Wnd:HWND;Msg,wParam,lParam:Integer):Integer;stdcall;
begin
  Result:=0;
	case msg of
    WM_CLOSE:PostQuitMessage(0);
    WM_KEYDOWN: keys[wParam]:=TRUE;
    WM_KEYUP  : keys[wParam]:=FALSE;
    WM_MOUSEWHEEL:
         begin
            if wParam >0 then cam.dst := cam.dst -2 else
                              cam.dst := cam.dst +2;

                           if cam.dst >200 then cam.dst:=200;
                           if cam.dst <2   then cam.dst:=2;
         end;
    else Result:=DefWindowProc(Wnd,Msg,wParam,LParam);
  end;
end;

Procedure KillWnd;
begin
//     FreeTextures;

  if FULLSCREEN then
  If ChangeDisplaySettings(DEVMODE(nil^),0)=0 then;

  wglMakeCurrent     (H_DC,0);
  wglDeleteContext   (H_RC);
{) ------------------------------- (}
  ReleaseDC          (H_Wnd,H_DC);
  DestroyWindow      (H_Wnd);
  UnRegisterClass(PRJName,hInstance);
end;

Procedure CreateWND;
var
DWStyle: Cardinal;
i : integer;
begin
  for i := 1 to ParamCount-1 do
  begin
	if sametext ( ParamStr(i) , '/w'          ) then Options.Width      := StrToIntDef(ParamStr(i+1),0);
	if sametext ( ParamStr(i) , '/h'          ) then Options.Height     := StrToIntDef(ParamStr(i+1),0);
	if sametext ( ParamStr(i) , '/bpp'        ) then Options.bpp        := StrToIntDef(ParamStr(i+1),0);
	if sametext ( ParamStr(i) , '/freq'       ) then Options.Freq       := StrToIntDef(ParamStr(i+1),60);
	if sametext ( ParamStr(i) , '/fullscreen' ) then Options.fullscreen := true;
	if sametext ( ParamStr(i) , '/vsync' )      then Options.vsync := true;
  end;

  Width       := Options.Width;
  Height      := Options.Height;
  Bpp         := Options.Bpp;
  FullScreen  := Options.FullScreen;
  Freq        := Options.Freq;

  Done:=FALSE;
  SetFullScreen;

  with WndClass do
  begin
    Style:=CS_HREDRAW or CS_VREDRAW;
    hIcon:=LoadIcon(GetModuleHandle(nil),'MAINICON');
    lpfnWndProc:=@WndProc;
    hInstance:=hInstance;
    lpszClassName:=PrjName;
    hCursor:=LoadCursor(0,IDC_ARROW);
  end;
  RegisterClass(WndClass);
  if Fullscreen then
  DWStyle := WS_POPUP else
  DWStyle := WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX;

  with WND_Rect do
  begin
    if not Fullscreen then
    begin
      Left   := Options.WndPos.Left + (Options.WndPos.Right  - Options.WndPos.Left) div 2  - Width div 2;
      Top    := Options.WndPos.top  + (Options.WndPos.Bottom - Options.WndPos.Top ) div 2  - Height div 2;
    end   else
    begin
      Left   := Options.WndPos.Left;
      Top    := Options.WndPos.top;
    end;
      Left   := Options.WndPos.Left;
      Top    := Options.WndPos.top;

    Right    := left + width;
    Bottom   := top + height;
  end;

    H_WND := CreateWindowExA( 8 ,PrjName,WndName,DWStyle,wnd_rect.left, wnd_rect.top,width,height,0,0,0,nil);

    if fullscreen then
    ShowCursor(FALSE) else
    With wnd_rect do
  	begin
      AdjustWindowRect(WND_Rect, dwStyle, False);
      MoveWindow(h_Wnd, left, top, Right - Left, Bottom - Top, False);
  	end;

  ShowWindow(H_Wnd,SW_SHOW);
  SetForeGroundWindow(H_wnd);
  SetFocus(H_wnd);

end;
begin
  InitOpenGL;
  Appdir := ExtractFilePath(Paramstr(0));
  CreateSetup;

  CreateWND;
  glInit;
  FrameTime:=16;
  LastTime:=TimeGetTime;
  while Done=FALSE do
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then
 		begin
   		if Msg.message=WM_QUIT then Done:=TRUE;
    	TranslateMessage(Msg);
 			DispatchMessage(Msg);
 		end else
  if getforegroundwindow = h_wnd then
  begin

      FrameTime   := GetTickCount - LastTime;
      LastTime    := GetTickCount;
      inc(Frames);

     Process;
     GLDraw;
     SwapBuffers(H_DC);

     if  FPSTime < TimeGetTime then
     begin
        Write(frames,' ':3, Options.Lights ,' <-lights   ');
        with cam.pos do
        Write( X:0:2,' ':3,Y:0:2,' ':3,Z:0:2,' ':3, CAM.TILT:0:3,' ':3,CAM.HEADING:0:3,' ':3,#13);
        FPS := Frames;
//        FPS := 60+random(2);
        Frames :=0;
        FPSTime := TimeGetTime + 1000;
     end;
   end;
  KillWnd;

end.

