Unit Frust;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

interface
{$Warnings off}
{$Hints on}

Uses OpenGL15,L_math;


Const
	RIGHT	= 0;
	LEFT	= 1;
	BOTTOM	= 2;
	TOP	= 3;
	BACK	= 4;
	FRONT	= 5;

	A	= 0;
	B	= 1;
	C	= 2;
	D	= 3;
Type
	TFrustum = array [0..5] of array [0..3] of single;
  PClipRect = ^TClipRect;
  TClipRect = array [0..3] of Integer;
var
  	Frustum	: TFrustum;
    OldDraw,
    DrawOBJS: Cardinal;
    proj,	// This will hold our projection matrix
    modl,
    mvp       : TMat4f;	// This will hold our modelview matrix
    viewport  : TClipRect;


    Procedure NormalizePlane(var frustum : tfrustum; side : integer);
    Procedure CalculateFrustum;
    function  PointInFrustum (const V:TVector) : BOOLEAN;

    function  SphereInFrustum(const V:TVector; const radius : single) : boolean;
    function  CubeInFrustum  (const V:TVector; size : single) : boolean;
    function  BoxInFrustum   (const Min,Max:TVector) : boolean;
    function  GetDrawObjectsCount:cardinal;
    procedure DrawBBox(const Min,Max:TVector);
    Procedure RenderBox(const vmin,vmax:TVector);


    Procedure uProject(obj:TVec3f;  ProjectionModelview:PMat4f;  var winx, winy, winz : Single);
    Function getZ(Pos:PVec3f):Single;
    function ScissorIntersection(const a, b: TClipRect; var int: TClipRect): Boolean;
    Procedure RenderScisor(rect: TClipRect; Color:TVector);
  function LightScissorRect(const l: TVector; const radius: Single;
                          var scissor: TClipRect): Boolean;
//function GetSphereScissor( P : TVec3f; Radius:Single; Scissor:PClipRect):boolean;

implementation
uses objects;

Procedure RenderScisor(rect: TClipRect; Color:TVector);
var  lclip: TClipRect;
begin
    // Render the scissor rectangles to the screen.
    glPushAttrib(GL_ENABLE_BIT);

    glGetIntegerv(GL_VIEWPORT, @lclip);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_SCISSOR_TEST);

    glMatrixMode(GL_PROJECTION);
    glPushMatrix;
    glLoadIdentity;
    glOrtho(lclip[0], lclip[0]+lclip[2], lclip[1], lclip[1]+lclip[3], -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

//    for i := 0 to High(dispclip) do
//    begin
      glColor3fv(@Color);
      glBegin(GL_LINE_LOOP);
        glVertex2f(Rect[0], Rect[1]);
        glVertex2f(Rect[2], Rect[1]);
        glVertex2f(Rect[2], Rect[3]);
        glVertex2f(Rect[0], Rect[3]);
      glEnd;
//    end;

    glMatrixMode(GL_PROJECTION);
    glPopMatrix;
    glMatrixMode(GL_MODELVIEW);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_SCISSOR_TEST);

    glPopAttrib;

end;


Procedure uProject(obj:TVec3f;  ProjectionModelview:PMat4f;  var winx, winy, winz : Single);
var
    P : TVec4f;
//    proj,mv,mvp:Tmat4f;

begin
//	glGetFloatv( GL_PROJECTION_MATRIX, @proj );
//	glGetFloatv( GL_MODELVIEW_MATRIX, @modl );
//    P2:= modl * vec4f(obj.x,obj.y,obj.z,1);
//    p := proj * p2;
    P := ProjectionModelview^ * vec4f(obj.x,obj.y,obj.z,1);

    if (P.w = 0.0) then exit;
    P := P * ( 1 / P.w);

    P.x := (P.x * 0.5 + 0.5) * viewport[2] + viewport[0];
    P.y := (P.y * 0.5 + 0.5) * viewport[3] + viewport[1];
    P.z :=  P.z * 0.5 + 0.5;

    winx  := P.x;
    winy  := P.y;
    winz  := P.z;
end;

Function getZ(Pos:PVec3f):Single;
var
  P : TVec4f;
begin
  P := MVP * vec4f(pos.x,pos.y,pos.z,1);
  if (P.w = 0.0) then exit;
      Result :=  P.z / P.w * 0.5 + 0.5;
end;


function ScissorRect(const pts: array of TVec3f; var scissor: TClipRect;
                     zcull: Boolean): Boolean;
var
  p: array [0..7] of TVec3f;
  i, z_far, z_near: Integer;
begin
  { This function calculates the screen-space bounding rectangle of the given
    array of points, and returns FALSE if the rectangle is entirely off-screen.
    The zcull parameter determines whether or not the function should also
    return FALSE if the rectangle lies outside the depth range. }
  // Convert it to window space.
  z_near := 0;
  z_far  := 0;
  viewport[0]:=0;
  viewport[1]:=0;
  viewport[2]:=Width;
  viewport[3]:=Height;

  for i := 0 to High(pts) do
  begin
    uproject(vec3f(pts[i].x,pts[i].y,pts[i].z),@MVP, p[i].x,p[i].y,p[i].z);

    if zcull then
    begin
      if p[i].z < -EPSILON then INC(z_far)
      else if p[i].z > (1+EPSILON) then INC(z_near);
    end;

    p[i].x := MAX(viewport[0], p[i].x);
    p[i].x := MIN(viewport[0]+viewport[2], p[i].x);

    p[i].y := MAX(viewport[1], p[i].y);
    p[i].y := MIN(viewport[1]+viewport[3], p[i].y);
  end;

  // Determine the window-space bounds of the bbox.
  scissor[0] := Round(p[0].x);
  scissor[1] := Round(p[0].y);
  scissor[2] := Round(p[0].x);
  scissor[3] := Round(p[0].y);

  for i := 1 to High(p) do
  begin
    if p[i].x < scissor[0] then scissor[0] := Round(p[i].x);
    if p[i].y < scissor[1] then scissor[1] := Round(p[i].y);
    if p[i].x > scissor[2] then scissor[2] := Round(p[i].x);
    if p[i].y > scissor[3] then scissor[3] := Round(p[i].y);
  end;

  if (z_far = Length(pts)) or (z_near = Length(pts)) then Result := FALSE
  else if (z_near > 0) and (z_near < Length(pts)) then
  begin
    Result := TRUE;
    scissor[0] := viewport[0];
    scissor[1] := viewport[1];
    scissor[2] := viewport[0] + viewport[2];
    scissor[3] := viewport[1] + viewport[3];
  end
  else Result := TRUE;


end;


function LightScissorRect(const l: TVector; const radius: Single;
                          var scissor: TClipRect): Boolean;
var
  p: array [0..7] of TVec3f;
  xradius : Single;
begin
  // Calculate the (approximate) screen-space bounding rect of a light source.
  xRadius := sqrt(2*Radius*radius);
  // Create the world-space bbox.
  p[0] := l + vec3f(-xradius, -xradius, -xradius);
  p[1] := l + vec3f(-xradius, -xradius,  xradius);
  p[2] := l + vec3f(-xradius,  xradius, -xradius);
  p[3] := l + vec3f(-xradius,  xradius,  xradius);
  p[4] := l + vec3f( xradius, -xradius, -xradius);
  p[5] := l + vec3f( xradius, -xradius,  xradius);
  p[6] := l + vec3f( xradius,  xradius, -xradius);
  p[7] := l + vec3f( xradius,  xradius,  xradius);

  Result := ScissorRect(p, scissor, true);

end;


function ScissorIntersection(const a, b: TClipRect; var int: TClipRect): Boolean;
begin

  // Calculate the intersection of two rectangles. Return FALSE if there is none.
  Result := TRUE;

  int[0] := MAX(a[0], b[0]);
  int[2] := MIN(a[2], b[2]);
  if int[0] >= int[2] then Result := FALSE;

  int[1] := MAX(a[1], b[1]);
  int[3] := MIN(a[3], b[3]);
  if int[1] >= int[3] then Result := FALSE;

end;



///////////////////////////////// NORMALIZE PLANE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This normalizes a plane (A side) from a given frustum.
/////
///////////////////////////////// NORMALIZE PLANE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

function  GetDrawObjectsCount:cardinal;
begin
result:= DrawOBJS;
end;

Procedure NormalizePlane(var frustum : tfrustum; side : integer);
var
	magnitude	: single;
begin
	// Here we calculate the magnitude of the normal to the plane (point A B C)
	// Remember that (A, B, C) is that same thing as the normal's (X, Y, Z).
	// To calculate magnitude you use the equation:  magnitude = sqrt( x^2 + y^2 + z^2)
	magnitude := sqrt( frustum[side][A] * frustum[side][A] + 
							   frustum[side][B] * frustum[side][B] + 
							   frustum[side][C] * frustum[side][C] );

	// Then we divide the plane's values by it's magnitude.
	// This makes it easier to work with.
	frustum[side][A] := frustum[side][A] / magnitude;
	frustum[side][B] := frustum[side][B] / magnitude;
	frustum[side][C] := frustum[side][C] / magnitude;
	frustum[side][D] := frustum[side][D] / magnitude; 
end;


///////////////////////////////// CALCULATE FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This extracts our frustum from the projection and modelview matrix.
/////
///////////////////////////////// CALCULATE FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

Procedure CalculateFrustum;
begin
  OldDraw :=DrawOBJS;
  DrawOBJS:=0;
	// glGetFloatv() is used to extract information about our OpenGL world.
	// Below, we pass in GL_PROJECTION_MATRIX to abstract our projection matrix.
	// It then stores the matrix into an array of [16].
	glGetFloatv( GL_PROJECTION_MATRIX, @proj );

	// By passing in GL_MODELVIEW_MATRIX, we can abstract our model view matrix.
	// This also stores it in an array of [16].
	glGetFloatv( GL_MODELVIEW_MATRIX, @modl );
  glGetIntegerv(GL_VIEWPORT       , @viewport);

	// Now that we have our modelview and projection matrix, if we combine these 2 matrices,
	// it will give us our clipping planes.  To combine 2 matrices, we multiply them.
  mvp := modl * proj;



	// Now we actually want to get the sides of the frustum.  To do this we take
	// the clipping planes we received above and extract the sides from them.

	// This will extract the RIGHT side of the frustum
	Frustum[RIGHT][A] := mvp.raw[ 3] - mvp.raw[ 0];
	Frustum[RIGHT][B] := mvp.raw[ 7] - mvp.raw[ 4];
	Frustum[RIGHT][C] := mvp.raw[11] - mvp.raw[ 8];
	Frustum[RIGHT][D] := mvp.raw[15] - mvp.raw[12];

	// Now that we have a normal (A,B,C) and a distance (D) to the plane,
	// we want to normalize that normal and distance.

	// Normalize the RIGHT side
	NormalizePlane(Frustum, RIGHT);

	// This will extract the LEFT side of the frustum
	Frustum[LEFT][A] := mvp.raw[ 3] + mvp.raw[ 0];
	Frustum[LEFT][B] := mvp.raw[ 7] + mvp.raw[ 4];
	Frustum[LEFT][C] := mvp.raw[11] + mvp.raw[ 8];
	Frustum[LEFT][D] := mvp.raw[15] + mvp.raw[12];

	// Normalize the LEFT side
	NormalizePlane(Frustum, LEFT);

	// This will extract the BOTTOM side of the frustum
	Frustum[BOTTOM][A] := mvp.raw[ 3] + mvp.raw[ 1];
	Frustum[BOTTOM][B] := mvp.raw[ 7] + mvp.raw[ 5];
	Frustum[BOTTOM][C] := mvp.raw[11] + mvp.raw[ 9];
	Frustum[BOTTOM][D] := mvp.raw[15] + mvp.raw[13]+15;

	// Normalize the BOTTOM side
	NormalizePlane(Frustum, BOTTOM);

	// This will extract the TOP side of the frustum
	Frustum[TOP][A] := mvp.raw[ 3] - mvp.raw[ 1];
	Frustum[TOP][B] := mvp.raw[ 7] - mvp.raw[ 5];
	Frustum[TOP][C] := mvp.raw[11] - mvp.raw[ 9];
	Frustum[TOP][D] := mvp.raw[15] - mvp.raw[13];

	// Normalize the TOP side
	NormalizePlane(Frustum, TOP);

	// This will extract the BACK side of the frustum
	Frustum[BACK][A] := mvp.raw[ 3] - mvp.raw[ 2];
	Frustum[BACK][B] := mvp.raw[ 7] - mvp.raw[ 6];
	Frustum[BACK][C] := mvp.raw[11] - mvp.raw[10];
	Frustum[BACK][D] := mvp.raw[15] - mvp.raw[14];

	// Normalize the BACK side
	NormalizePlane(Frustum, BACK);

	// This will extract the FRONT side of the frustum
	Frustum[FRONT][A] := mvp.raw[ 3] + mvp.raw[ 2];
	Frustum[FRONT][B] := mvp.raw[ 7] + mvp.raw[ 6];
	Frustum[FRONT][C] := mvp.raw[11] + mvp.raw[10];
	Frustum[FRONT][D] := mvp.raw[15] + mvp.raw[14];

	// Normalize the FRONT side
	NormalizePlane(Frustum, FRONT);
end;

// The code below will allow us to make checks within the frustum.  For example,
// if we want to see if a point, a sphere, or a cube lies inside of the frustum.
// Because all of our planes point INWARDS (The normals are all pointing inside the frustum)
// we then can assume that if a point is in FRONT of all of the planes, it's inside.

///////////////////////////////// POINT IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This determines if a point is inside of the frustum
/////
///////////////////////////////// POINT IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

function PointInFrustum(const V:TVector ) : BOOLEAN;
var
	i	: integer;
begin
	// Go through all the sides of the frustum
	for i := 0 to 5 do
	begin
		// Calculate the plane equation and check if the point is behind a side of the frustum
		if(Frustum[i][A] * v.x + Frustum[i][B] * v.y + Frustum[i][C] * v.z + Frustum[i][D] <= 0) then
		begin
			// The point was behind a side, so it ISN'T in the frustum
			result := false; exit;
		end;
	end;

	// The point was inside of the frustum (In front of ALL the sides of the frustum)
	result := true;
  inc(DrawOBJS);
end;


///////////////////////////////// SPHERE IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This determines if a sphere is inside of our frustum by it's center and radius.
/////
///////////////////////////////// SPHERE IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

function SphereInFrustum(const V:TVector; const radius : single) : boolean;
var
	i	: integer;
begin
	// Go through all the sides of the frustum
	for i := 0 to 5 do
	begin
		// If the center of the sphere is farther away from the plane than the radius
		if( Frustum[i][A] * v.x + Frustum[i][B] * v.y + Frustum[i][C] * v.z + Frustum[i][D] <= -radius ) then
		begin
			// The distance was greater than the radius so the sphere is outside of the frustum
			result := false; exit;
		end;
	end;
	
	// The sphere was inside of the frustum!
	result := true;
  inc(DrawOBJS);
end;


///////////////////////////////// CUBE IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This determines if a cube is in or around our frustum by it's center and 1/2 it's length
/////
///////////////////////////////// CUBE IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

function CubeInFrustum(const V:TVector; size : single) : boolean;
var
	i	: integer;
begin
	// Basically, what is going on is, that we are given the center of the cube,
	// and half the length.  Think of it like a radius.  Then we checking each point
	// in the cube and seeing if it is inside the frustum.  If a point is found in front
	// of a side, then we skip to the next side.  If we get to a plane that does NOT have
	// a point in front of it, then it will return false.

	// *Note* - This will sometimes say that a cube is inside the frustum when it isn't.
	// This happens when all the corners of the bounding box are not behind any one plane.
	// This is rare and shouldn't effect the overall rendering speed.

	for i := 0 to 5 do
	begin
		if(Frustum[i][A] * (v.x - size) + Frustum[i][B] * (v.y - size) + Frustum[i][C] * (v.z - size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x + size) + Frustum[i][B] * (v.y - size) + Frustum[i][C] * (v.z - size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x - size) + Frustum[i][B] * (v.y + size) + Frustum[i][C] * (v.z - size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x + size) + Frustum[i][B] * (v.y + size) + Frustum[i][C] * (v.z - size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x - size) + Frustum[i][B] * (v.y - size) + Frustum[i][C] * (v.z + size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x + size) + Frustum[i][B] * (v.y - size) + Frustum[i][C] * (v.z + size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x - size) + Frustum[i][B] * (v.y + size) + Frustum[i][C] * (v.z + size) + Frustum[i][D] > 0) then
		   continue;
		if(Frustum[i][A] * (v.x + size) + Frustum[i][B] * (v.y + size) + Frustum[i][C] * (v.z + size) + Frustum[i][D] > 0) then
		   continue;

		// If we get here, it isn't in the frustum
		result := false; exit;
	end;

	result := true;
  inc(DrawOBJS);
end;


/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

///////////////////////////////// BOX IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This determines if a BOX is in or around our frustum by it's min and max points
/////
///////////////////////////////// BOX IN FRUSTUM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

function BoxInFrustum(const Min,Max:TVector) : boolean;
var
	i	: integer;
begin
	// Go through all of the corners of the box and check then again each plane
	// in the frustum.  If all of them are behind one of the planes, then it most
	// like is not in the frustum.
	for i := 0 to 5 do
	begin
		if(Frustum[i][A] * Min.x + Frustum[i][B] * Min.y  + Frustum[i][C] * Min.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Max.x + Frustum[i][B] * Min.y  + Frustum[i][C] * Min.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Min.x + Frustum[i][B] * Max.y  + Frustum[i][C] * Min.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Max.x + Frustum[i][B] * Max.y  + Frustum[i][C] * Min.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Min.x + Frustum[i][B] * Min.y  + Frustum[i][C] * Max.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Max.x + Frustum[i][B] * Min.y  + Frustum[i][C] * Max.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Min.x + Frustum[i][B] * Max.y  + Frustum[i][C] * Max.z  + Frustum[i][D] > 0)  then continue;
		if(Frustum[i][A] * Max.x + Frustum[i][B] * Max.y  + Frustum[i][C] * Max.z  + Frustum[i][D] > 0)  then continue;

		// If we get here, it isn't in the frustum
		result := false; exit;
	end;

	// Return a true for the box being inside of the frustum
	result := true;
  inc(DrawOBJS);
end;

procedure DrawBBox(const Min,Max:TVector);
var
 Vertices: Array[1..8] of TVector;
 i :integer;
begin
 Vertices[1]:= Vector(Min.X,Max.Y,Min.Z);
 Vertices[2]:= Vector(Max.X,Max.Y,Min.Z);
 Vertices[3]:= Vector(Min.X,Max.Y,Max.Z);
 Vertices[4]:= Vector(Max.X,Max.Y,Max.Z);
 Vertices[5]:= Vector(Min.X,Min.Y,Min.Z);
 Vertices[6]:= Vector(Max.X,Min.Y,Min.Z);
 Vertices[7]:= Vector(Min.X,Min.Y,Max.Z);
 Vertices[8]:= Vector(Max.X,Min.Y,Max.Z);

glPushAttrib(GL_CURRENT_BIT);
glDisable(GL_TEXTURE_2D);
glColor3f(1,1,1);
 glBegin(GL_LINES);
  for i:=1 to 8 do
  glVertex3fv(@Vertices[i]);

  glVertex3fv(@Vertices[1]);
  glVertex3fv(@Vertices[3]);
  glVertex3fv(@Vertices[2]);
  glVertex3fv(@Vertices[4]);
  glVertex3fv(@Vertices[5]);
  glVertex3fv(@Vertices[7]);
  glVertex3fv(@Vertices[6]);
  glVertex3fv(@Vertices[8]);

  for i:=1 to 4 do
  begin
  glVertex3fv(@Vertices[i]);
  glVertex3fv(@Vertices[i+4]);
  end;
 glEnd;
glEnable(GL_TEXTURE_2D);
glPopAttrib;
end;



Procedure RenderBox(const vmin,vmax:TVector);
var
xMin,xMax,XCen,XExt : TVector;
begin
	glDisable(GL_LIGHTING);
	glDisable(GL_TEXTURE_2D);
	glShadeModel(GL_FLAT);
	glColor3f(1,1,1);
	glLineWidth(10);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

	xMin := Vector(vmin.x, vmin.y, vmin.z);
	xMax := Vector(vmax.x, vmax.y, vmax.z);
	xCen := V_Mult( V_Sub(xMax,xMin), 0.5);
	xExt := V_Mult( V_Add(xMax,xMin), 0.5);

	glPushMatrix();
	glTranslatef(xCen.x, xCen.y, xCen.z);
	glScalef    (xExt.x, xExt.y, xExt.z);
//	glutSolidCube(2.0f);
	glPopMatrix();

//	glEnable(GL_LIGHTING);
	glShadeModel(GL_SMOOTH);
	glPolygonMode(GL_FRONT_AND_BACK, GL_Fill);

end;



end.