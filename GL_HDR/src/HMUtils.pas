unit HMUtils;

interface

uses
  OpenGL15,DotMath, Math,classes,sysutils;

// Create a normal map from a heightfield.
function hmCreateNormalMap(const map: array of Byte; const w, h: Integer;
                           const vscale: Single): GLuint;
// Calculate a horizon map for a heightfield.
function hmCreateHorizonMap(const map: array of Byte; const w, h,bpp: Integer;
                            const vscale: Single; const samples: Integer;
                            const filename: String = ''): GLuint;
// Load a horizon map from disk.
function hmLoadHorizonMap(const filename: String): GLuint;
// Create a heading/elevation lookup table.
function hmCreateHeadingElevationLUT(size: Integer): GLuint;

implementation


{*** Heightfield to normal map conversion *************************************}

function hmCreateNormalMap(const map: array of Byte; const w, h: Integer;
                           const vscale: Single): GLuint;
var
  x, y: Integer;
  vs, vt, n: TDotVector3;
  h0, hs, ht: Byte;
  nmap: array of record
      R, G, B: Byte;
    end;
  tex: GLuint;

  function SampleMap(i, j: Integer): Byte;
  begin
    Result := map[(j mod h)*w + (i mod w)];
  end;

begin

  SetLength(nmap, w*h);

  for y := 0 to h - 1 do
  begin
    for x := 0 to w - 1 do
    begin
      h0 := SampleMap(x, y);
      hs := SampleMap(x+1, y);
      ht := SampleMap(x, y+1);

      vs := dotVector3(1, 0, (hs-h0)*vscale/255);
      vt := dotVector3(0, 1, (ht-h0)*vscale/255);

      n := dotVecCross3(vs, vt);
      dotVecNormalize3(n);

      with nmap[y*w + x] do
      begin
        R := Trunc(128 + (n.x*127));
        G := Trunc(128 + (n.y*127));
        B := Trunc(128 + (n.z*127));
      end;
    end;
  end;

  glGenTextures(1, @tex);
  glBindTexture(GL_TEXTURE_2D, tex);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, @nmap[0]);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

  SetLength(nmap, 0);
  Result := tex;

end;

{*** Horizon map generation ***************************************************}

function hmCalcHorizon(const map: array of Byte; const w, h,bpp, x, y: Integer;
                       const vscale: Single; const direction: TDotVector2): Byte;
var
  pos, dir: TDotVector2;
  curH, maxH, origin: Byte;
  i, j: Integer;
  flat, elev: TDotVector3;
begin

  pos := dotVector2(x, y);

  // Scale the direction vector such that the largest component is 1.
  dir := direction;
  dotVecScalarMult2(dir, 1/MAX(dir.x, dir.y));

  maxH := 0;

  // Trace a ray through the heightmap and keep track of the horizon elevation.
  pos := dotVecAdd2(pos, dir);
  i := Round(pos.x);
  j := Round(pos.y);
  while (i >= 0) and (i < w) and (j >= 0) and (j < h) do
  begin
    // Height of the current sample point:
    curH := map[(j*w+i)*bpp];
    origin := map[(y*w+x)*bpp];
    { If the current sample point is lower than the ray origin, it can't affect
      our horizon, so skip it. }
    if curH > origin then
    begin
      // Calculate the elevation angle of the current sample point:
      flat := dotVector3(i - x, j - y, 0); //origin*vscale/255);
      dotVecNormalize3(flat);
      elev := dotVector3(i - x, j - y, curH*vscale/255 - origin*vscale/255);
      dotVecNormalize3(elev);
      // Output: [0=horizontal, 1=vertical].
      curH := Round((1-dotVecDot3(flat, elev))*255);

      maxH := MAX(curH, maxH);

      { If the current sample value is 255, no point beyond it can possibly be
        higher, so stop here. }
      if map[(j*w+i)*bpp] = 255 then Break;
    end;

    // Move one step further along the ray.
    pos := dotVecAdd2(pos, dir);
    i := Round(pos.x);
    j := Round(pos.y);
  end;

  Result := maxH;

end;

function hmCreateHorizonMap(const map: array of Byte; const w, h,bpp: Integer;
                            const vscale: Single; const samples: Integer;
                            const filename: String): GLuint;
var
  horizon: array of Byte;
  i, j, k: Integer;
  dir: TDotVector2;
  hmap: GLuint;
  f: File of byte;
begin

  SetLength(horizon, w*h*samples);

  for k := 0 to samples-1 do
  begin
    for j := 0 to h-1 do
    begin
//      HMForm.Progress(Format('Calculating horizon map (%d/%d)',
//                             [(k*w+j) div samples, h]));
      for i := 0 to w-1 do
      begin
        dir := dotVector2(1, 0);
        dotVecRotate2(dir, k*2*PI/samples);
        horizon[(k*w*h)+(j*w)+i] := hmCalcHorizon(map, w, h,bpp, i, j, vscale, dir);
      end;
    end;
  end;

  glGenTextures(1, @hmap);
  glBindTexture(GL_TEXTURE_3D, hmap);
  glTexImage3D(GL_TEXTURE_3D, 0, GL_LUMINANCE8, w, h, samples, 0, GL_LUMINANCE,
               GL_UNSIGNED_BYTE, @horizon[0]);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);

  // Save the map to disk if requested.
  if filename <> '' then
  begin
    AssignFile(f, filename);
    ReWrite(f);

    BlockWrite(f, w, SizeOf(Integer));
    BlockWrite(f,h, SizeOf(Integer));
    BlockWrite(f,samples, SizeOf(Integer));
    BlockWrite(f,horizon[0], w*h*samples);

    closefile(f);
  end;

  SetLength(horizon, 0);
  Result := hmap;

end;
{
function hmLoadHorizonMap(const filename: String): GLuint;
var
  w, h, d: Integer;
  buf: array of Byte;
  f: File of byte;
  hmap: GLuint;
begin

  AssignFile(f,filename);
  Reset(f);

  BlockRead(f,w, SizeOf(Integer));
  BlockRead(f,h, SizeOf(Integer));
  BlockRead(f,d, SizeOf(Integer));

  SetLength(buf, w*h*d);
  BlockRead(f,buf[0], w*h*d);

  CloseFile(f);

  glGenTextures(1, @hmap);
  glBindTexture(GL_TEXTURE_3D, hmap);
  glTexImage3D(GL_TEXTURE_3D, 0, GL_LUMINANCE8, w, h, d, 0, GL_LUMINANCE,
               GL_UNSIGNED_BYTE, @buf[0]);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);

  SetLength(buf, 0);
  Result := hmap;

end;
 }

 function hmLoadHorizonMap(const filename: String): GLuint;
var
  w, h, d: Integer;
  buf: array of Byte;
  f: TFileStream;
  hmap: GLuint;
begin

  f := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);

  f.Read(w, SizeOf(Integer));
  f.Read(h, SizeOf(Integer));
  f.Read(d, SizeOf(Integer));

  SetLength(buf, w*h*d);
  f.Read(buf[0], w*h*d);

  f.Free;

  glGenTextures(1, @hmap);
  glBindTexture(GL_TEXTURE_3D, hmap);
  glTexImage3D(GL_TEXTURE_3D, 0, GL_LUMINANCE8, w, h, d, 0, GL_LUMINANCE,
               GL_UNSIGNED_BYTE, @buf[0]);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);

  SetLength(buf, 0);
  Result := hmap;

end;                            

{*** Heading/elevation lookup table *******************************************}

function hmGetCubeVector(side, cubesize, x, y: Integer): TDotVector3;
var
  s, t, sc, tc: Single;
begin

  s := (x + 0.5) / cubesize;
  t := (y + 0.5) / cubesize;
  sc := s*2 - 1;
  tc := t*2 - 1;

  case side of
    GL_TEXTURE_CUBE_MAP_POSITIVE_X: begin
         Result := dotVector3(1, -tc, -sc);
       end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_X: begin
         Result := dotVector3(-1, -tc, sc);
       end;
    GL_TEXTURE_CUBE_MAP_POSITIVE_Y: begin
         Result := dotVector3(sc, 1, tc);
       end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Y: begin
         Result := dotVector3(sc, -1, -tc);
       end;
    GL_TEXTURE_CUBE_MAP_POSITIVE_Z: begin
         Result := dotVector3(sc, -tc, 1);
       end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Z: begin
         Result := dotVector3(-sc, -tc, -1);
       end;
  end;

  dotVecNormalize3(Result);

end;


function hmCreateHeadingElevationLUT(size: Integer): GLuint;
var
  vector: TDotVector3;
  i, x, y: Integer;
  pixels: array of GLubyte;
  tex: GLuint;
  heading, elevation: Single;
  e, e0: TDotVector3;
begin

  SetLength(pixels, size*size*2);

  glGenTextures(1, @tex);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, tex);

  for i := GL_TEXTURE_CUBE_MAP_POSITIVE_X to GL_TEXTURE_CUBE_MAP_NEGATIVE_Z do
  begin
    for y := 0 to size - 1 do
    begin
      for x := 0 to size - 1 do
      begin
        vector := hmGetCubeVector(i, size, x, y);

        // Calculate elevation:
        e0 := dotVector3(vector.x, vector.y, 0);
        dotVecNormalize3(e0);
        e := vector;
        elevation := 1 - dotVecDot3(e0, e);

        // Calculate heading:
        heading := ArcCos(e0.x);
        if e0.y < 0 then
          heading := PI + (PI - heading);

        // Write them to the cube map.
        pixels[(y*size + x)*2 + 0] := Trunc((heading/(2*PI))*255);
        pixels[(y*size + x)*2 + 1] := Trunc(elevation*255);
      end;
    end;
    glTexImage2D(i, 0, GL_LUMINANCE8_ALPHA8, size, size, 0, GL_LUMINANCE_ALPHA,
                 GL_UNSIGNED_BYTE, @pixels[0]);
  end;

  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

  Result := tex;

end;

initialization

  SetPrecisionMode(pmSingle);

end.
