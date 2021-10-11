Unit FNT;
{$WARNINGS OFF}
{$HINTS ON}
{
 Original code from : http://XProger.MirGames.Ru -> eXgine

 Made by : SVSD_VAL
 Site    : http://svsd.mirgames.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.Sibnet.ru
}

Interface

Uses OpenGL15,Windows,l_math;

 function FontCreate(Name: PChar; Size,Tex_Size: Integer): Cardinal;
 procedure TextOut(Font:Cardinal; Size, x,y : Single ; str:string);
 procedure TextOut2(Font:Cardinal; Size, x,y : Single ; str:string; count:cardinal);

Implementation
uses objects,textures;

type
  TCoord    = Array [0..3] of TVec2f;
  PFontData = ^TFontData;
  TFontData = record
    Font  : Cardinal;
    Vert  : Array [0..255] of TCoord;
    Width : array [0..255] of ShortInt;
  end;

var
 Fonts     : array of PFontData;

function FontCreate(Name: PChar; Size,Tex_Size: Integer): Cardinal;
var
  FNT  : HFONT;
  DC   : HDC;
  MDC  : HDC;
  BMP  : HBITMAP;
  BI   : BITMAPINFO;
  pix  : PByteArray;
  i    : Integer;
  cs   : TSize;
  s, t : Single;
  Data : PByteArray;
begin
  DC  := GetDC(h_wnd);
 FNT := CreateFontA(-MulDiv(Size, GetDeviceCaps(DC, LOGPIXELSY), 72), 0,0,0,FW_BOLD,0,0,0,RUSSIAN_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
                    ANTIALIASED_QUALITY, 0, Name);
  ZeroMemory(@BI, SizeOf(BI));
  with BI.bmiHeader do
  begin
    biSize      := SizeOf(BITMAPINFOHEADER);
    biWidth     := TEX_SIZE;
    biHeight    := TEX_SIZE;
    biPlanes    := 1;
    biBitCount  := 24;
    biSizeImage := biWidth * biHeight * biBitCount div 8;
  end;

  MDC := CreateCompatibleDC(DC);
  BMP := CreateDIBSection(MDC, BI, DIB_RGB_COLORS, Pointer(pix), 0, 0);
  ZeroMemory(pix, TEX_SIZE * TEX_SIZE * 3);

  SelectObject(MDC, BMP);
  SelectObject(MDC, FNT);
  SetBkMode(MDC, TRANSPARENT);
  SetTextColor(MDC, $FFFFFF);

  for i := 0 to 255 do
    Windows.TextOut(MDC, i mod 16 * (TEX_SIZE div 16), i div 16 * (TEX_SIZE div 16), @Char(i), 1);

  Result := HIGH(Cardinal);
  for i := 0 to Length(Fonts) - 1 do
    if Fonts[i] = nil then
    begin
      Result := i;
      break;
    end;
  if Result = HIGH(Cardinal) then
  begin
    Result := Length(Fonts);
    SetLength(Fonts, Result + 1);
  end;

  New(Fonts[Result]);
  with Fonts[Result]^ do
  begin
     GetMem(Data, TEX_SIZE * TEX_SIZE * 2);
    for i := 0 to TEX_SIZE * TEX_SIZE - 1 do
    begin
      Data[i * 2]     := 255;
      Data[i * 2 + 1] := pix[i * 3];
    end;
    Font := CreateTexture(TEX_SIZE, TEX_SIZE, GL_LUMINANCE_ALPHA,Data);
    FreeMem(Data);
    for i := 0 to 255 do
    begin
      s := (i mod 16)/16 +0.001;
      t := (i div 16)/16 +0.001;
      GetTextExtentPoint32(MDC, @Char(i), 1, cs);
      Width[i] := cs.cx;
      Vert[i][0] := Vector2d(s                  ,1 - t);
      Vert[i][1] := Vector2d(s + cs.cx/TEX_SIZE ,1 - t - cs.cy/TEX_SIZE);
      Vert[i][2] := Vector2d(cs.cx              , cs.cy);
    end;
  end;

  DeleteObject(FNT);
  DeleteObject(BMP);
  DeleteDC(MDC);
  ReleaseDC(h_wnd, DC);
end;

procedure TextOut(Font:Cardinal; Size, x,y : Single ; str:string);
var i,i2:Word;
    ch:char;
    V:TCoord;
begin


  glPushAttrib(GL_ENABLE_BIT);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
//  glEnable(GL_ALPHA_TEST);
//  glAlphaFunc(GL_GEQUAL, 0.1);
  glEnable(GL_Blend);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  Texture_Enable(Fonts[Font]^.Font,0);
  glPushMatrix;

  glTranslatef(X, Y, 0);
  for i:=1 to length(str) do
  begin
       ch:= str[i];
      i2 := ord(ch);

      V  := Fonts[font]^.Vert[i2];

    glBegin(gl_polygon);
        glTexCoord2f(v[0].x , v[0].y);     glVertex2f( 0            ,0  );
        glTexCoord2f(v[1].x , v[0].y);     glVertex2f( v[2].x +Size ,0  );
        glTexCoord2f(v[1].x , v[1].y);     glVertex2f( v[2].x +Size ,(v[2].y+Size) );
        glTexCoord2f(v[0].x , v[1].y);     glVertex2f( 0            ,(v[2].y+Size) );
    glEnd;
    GLTranslatef(v[2].x +Size,0,0);;

  end;
  Texture_Disable(0);
  glDisable(GL_Blend);

  glPopMatrix;
  glPopAttrib;
end;


procedure TextOut2(Font:Cardinal; Size, x,y : Single ; str:string; count:cardinal);
var i,i2:Word;
    ch:char;
    V:TCoord;
begin

  if count > length(str) then exit;

  glPushAttrib(GL_ENABLE_BIT);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glDisable(GL_LIGHTING);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GEQUAL, 0.1);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  Texture_Enable(Fonts[Font]^.Font,0);
  glPushMatrix;

  glTranslatef(X, Y, 0);

  for i:=1 to count do
  begin
       ch:= str[i];
      i2 := ord(ch);

      V  := Fonts[font]^.Vert[i2];

    glBegin(gl_polygon);
        glTexCoord2f(v[0].x , v[0].y);     glVertex2f( 0            ,0  );
        glTexCoord2f(v[1].x , v[0].y);     glVertex2f( v[2].x +Size ,0  );
        glTexCoord2f(v[1].x , v[1].y);     glVertex2f( v[2].x +Size ,v[2].y+Size );
        glTexCoord2f(v[0].x , v[1].y);     glVertex2f( 0            ,v[2].y+Size );
    glEnd;
    GLTranslatef(v[2].x +Size,0,0);;

  end;

  glPopMatrix;
  glPopAttrib;
end;

end.