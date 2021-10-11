unit glRender_Check;
interface
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}


Uses OpenGL15,SysUtils,windows,objects;

var
   gl_Fp_texture : boolean;

procedure CheckFrameBufferStatus;
function CreateHDRImage(var Tex:Cardinal; const w, h: Integer; alpha:boolean=false): boolean;
function CreateImage(var Tex:Cardinal; const w, h: Integer): boolean;
Procedure CheckForFPTextrue;

Implementation

var
 Use_32BitInsteadOf16Bit : boolean=true;
const
  GL_HALF_FLOAT = GL_HALF_FLOAT_ARB;

procedure CheckFrameBufferStatus;
var
  s: GLenum;
begin
  // Calls glCheckFrameBufferStatusEXT and raises an exception if anything is wrong.
  s := glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
  case s of
    GL_FRAMEBUFFER_COMPLETE_EXT:
      Exit;
    GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
      raise Exception.Create('Incomplete attachment');
    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
      raise Exception.Create('Missing attachment');
    GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT:
      raise Exception.Create('Duplicate attachment');
    GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
      raise Exception.Create('Incomplete dimensions');
    GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
      raise Exception.Create('Incomplete formats');
    GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
      raise Exception.Create('Incomplete draw buffer');
    GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
      raise Exception.Create('Incomplete read buffer');
    GL_FRAMEBUFFER_UNSUPPORTED_EXT:
      raise Exception.Create('Framebuffer unsupported');
  end;

end;


function CreateImage(var Tex:Cardinal; const w, h: Integer): boolean;
begin
  glGenTextures(1, @tex);
  glBindTexture(GL_TEXTURE_2D, tex);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//  glTexImage2D(GL_TEXTURE_2D,0, GL_RGB, w, h,0, GL_RGB, GL_UNSIGNED_BYTE, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, W, H, 0);

end;

function CreateHDRImage(var Tex:Cardinal; const w, h: Integer; alpha:boolean=false): boolean;
begin
  // Create an RGB16F texture with the given dimensions
  glGenTextures(1, @Tex);
  glBindTexture(GL_TEXTURE_2D, Tex);

//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	if(alpha = true) then
	begin
		if(Use_32BitInsteadOf16Bit = TRUE) then
		begin
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, 0, 0, W, H, 0);
//				glTexImage2D(GL_TEXTURE_2D,0, GL_RGBA32F_ARB, w, h,0, GL_BGRA, GL_FLOAT, nil);

  			if (glGetError <> GL_NO_ERROR) then
//  			glTexImage2D(GL_TEXTURE_2D,0, GL_RGBA_FLOAT32_ATI, w, h,0, GL_BGRA, GL_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA_FLOAT32_ATI, 0, 0, W, H, 0);

  			if glGetError <> GL_NO_ERROR then
//				glTexImage2D(GL_TEXTURE_2D,0, GL_FLOAT_RGBA32_NV, w, h,0, GL_BGRA, GL_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_FLOAT_RGBA32_NV, 0, 0, W, H, 0);

		  	if (glGetError <> GL_NO_ERROR) then
				Use_32BitInsteadOf16Bit := FALSE;
		end;

		if(Use_32BitInsteadOf16Bit = false) then
		begin
//				glTexImage2D(GL_TEXTURE_2D,0, GL_RGBA16F_ARB, w, h,0, GL_BGRA, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 0, 0, W, H, 0);

  			if (glGetError <> GL_NO_ERROR) then
//  			glTexImage2D(GL_TEXTURE_2D,0, GL_RGBA_FLOAT16_ATI, w, h,0, GL_BGRA, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA_FLOAT16_ATI, 0, 0, W, H, 0);

  			if (glGetError <> GL_NO_ERROR) then
//				glTexImage2D(GL_TEXTURE_2D,0, GL_FLOAT_RGBA16_NV, w, h,0, GL_BGRA, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_FLOAT_RGBA16_NV, 0, 0, W, H, 0);
		end;
	end
	else // if(alpha == false)
	begin
		if(Use_32BitInsteadOf16Bit = TRUE) then
		begin
//				glTexImage2D(GL_TEXTURE_2D,0, GL_RGB32F_ARB, w, h,0, GL_BGR, GL_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F_ARB, 0, 0, W, H, 0);

  			if (glGetError <> GL_NO_ERROR) then
//  			glTexImage2D(GL_TEXTURE_2D,0, GL_RGB_FLOAT32_ATI, w, h,0, GL_BGR, GL_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB_FLOAT32_ATI, 0, 0, W, H, 0);

	  		if (glGetError <> GL_NO_ERROR) then
//				glTexImage2D(GL_TEXTURE_2D,0, GL_FLOAT_RGB32_NV, w, h,0, GL_BGR, GL_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_FLOAT_RGB32_NV, 0, 0, W, H, 0);

  			if (glGetError <> GL_NO_ERROR) then
				Use_32BitInsteadOf16Bit := FALSE;
		end;

		if(Use_32BitInsteadOf16Bit = FALSE) then
		begin
//				glTexImage2D(GL_TEXTURE_2D,0, GL_RGB16F_ARB, w, h,0, GL_BGR, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, 0, 0, W, H, 0);
		  	if (glGetError <> GL_NO_ERROR) then
//				glTexImage2D(GL_TEXTURE_2D,0, GL_FLOAT_RGB16_NV, w, h,0, GL_BGR, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_FLOAT_RGB16_NV, 0, 0, W, H, 0);

		  	if (glGetError <> GL_NO_ERROR) then
//  			glTexImage2D(GL_TEXTURE_2D,0, GL_RGB_FLOAT16_ATI, w, h,0, GL_BGR, GL_HALF_FLOAT, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB_FLOAT16_ATI, 0, 0, W, H, 0);
		end;
	end;

  Result := true;

  if (glGetError <> GL_NO_ERROR) then
  begin
//    glTexImage2D(GL_TEXTURE_2D,0, GL_RGB, w, h,0, GL_RGB, GL_UNSIGNED_BYTE, nil);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, W, H, 0);
    Result := false;
  end;

end;

Procedure CheckForFPTextrue;
var
 Tex: Cardinal;
begin
 gl_Fp_texture:= CreateHDRImage(tex,2,2);
 glDeleteTextures(1,@Tex);

  if not gl_Fp_texture then
  SendToLog('Float Point Texture Format unsupported');

end;


end.
