Unit objects;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

interface

uses Windows,OpenGL15,l_math,glsl;
  {$WARNINGS OFF}
  {$OPTIMIZATION ON}
var
  h_Wnd       : HWND;
  h_DC        : HDC;
  h_RC        : HGLRC;
  Width       : Integer = 640;
  Height      : Integer = 480;
  BPP         : Integer = 16;
  Freq        : Integer = 60;
  FULLSCREEN  : Boolean = false;
  WND_Rect    : TRect;

  Done        : boolean;
  AppDir,
  TextureDir  : String;

  FrameTime,
  DemoStart,
  LastTime    : Integer;

  Frames,
  FPSTime,
  fps         : integer;
  FOV         : INTEGER =72;
  ZMIN        : SINGLE  =1;
  ZMAX        : SINGLE  =3000;
  Keys        : array [0..255] of boolean;

  curshader   : PShader;
  curLight    : record
    Pos   : TVec3f;
    ZBias : Single;
  end;

function  IntToStr(Num : Integer) : String;
Function  Booltostr(B:Boolean) : String;
procedure glBindTexture       (target: GLenum; texture: GLuint); stdcall; external opengl32;
Procedure SetProjection(W, H: integer; Ortho: boolean);

function ExtractFileName(const s: string): string;
function ExtractFilePath(const s: string): string;
Function SameText(A,B:String):Boolean;
function ChangeFileExt(const FileName, Extension: string): string;
function FileExists(FileName: string): boolean;
Procedure SetTexProjection(W, H: integer; Ortho: boolean);
function DrawSphere(CX, CY, CZ, Radius : Single; N : Integer) : Cardinal;
Procedure SendToLog( S : String );

implementation

const
 LogFileName = 'engineLog.txt';

var
 LogFile : TextFile;
 CanLog  : boolean;

Procedure InitLog();
begin
  Try
 AssignFile(LogFile, appdir+ LogFileName);
 Rewrite(LogFile);
 CanLog:=true;
  except
     CanLog:=false;
  end;
 SendToLog(' -= RTBT Team Engine =- ');
 SendToLog(' -= ( Keha / Kavis / SVSD_VAL ) =- ');
 SendToLog(' -= --------------------------- =- ');

 SendToLog('Game engine by SVSD_VAL');
 SendToLog('http  : rtbt.ru =- ');
 SendToLog('icq   : 223-725-915 =- ');
 SendToLog('jabber: svsd_val@jabber.ru');
end;

Procedure SendToLog( S : String );
begin
 if not canlog then exit;
 WriteLn(LogFile, S);
 WriteLn(S);
 Flush(LogFile);
end;

Procedure CloseLog();
begin
 if not canlog then exit;

 CloseFile(LogFile);
end;


Procedure generateNormalAndTangent( xv1, xv2 , xv3: TVec3f; xst1 , xst2, xst3 : TVec2f; var normal, binormal,tangent: TVec3f);
var coef : single;
  v1,v2  : TVec3f;
  st1,st2: TVec2f;
begin
    v1 := v_sub( xv2, xv1);
    v2 := v_sub( xv3, xv1);
    st1.x:= xst2.x - xst1.x;
    st1.y:= xst2.y - xst1.y;

    st2.x:= xst3.x - xst1.x;
    st2.y:= xst3.y - xst1.y;

		normal := v_cross(v1, v2);

		 coef := 1/ (st1.x * st2.y - st2.x * st1.y);

    		tangent.x := coef * ((v1.x * st2.y)  + (v2.x * -st1.y));
    		tangent.y := coef * ((v1.y * st2.y)  + (v2.y * -st1.y));
    		tangent.z := coef * ((v1.z * st2.y)  + (v2.z * -st1.y));

		 binormal := v_cross(normal , tangent);
end;

function DrawSphere(CX, CY, CZ, Radius : Single; N : Integer) : Cardinal;
var
 i,j                  : Integer;
 theta1,theta2,theta3,theta4 : Single;
 coef  : Single;
 N1,N2 : TVec3f;
 P1,P2, tangent,binormal : TVec3f;
 st1,st2 :TVec2f;
begin
if Radius < 0 then
 Radius :=-Radius;
  if n < 0 then
      n := -n;

 glBegin(GL_QUAD_strip);
 for j := 0 to n div 2 -1 do
 begin
 theta1 :=  J   *2*PI/N - PI/2;
 theta2 := (J+1)*2*PI/n - PI/2;
     for i := 0 to n do
        begin
          theta3 := i*2*PI/N;
            n1.Z := cos(theta2) * cos(theta3);
            n1.y := sin(theta2);
            n1.X := cos(theta2) * sin(theta3);
              p1.X := CX + Radius*n1.x;
              p1.y := CY + Radius*n1.y;
              p1.Z := CZ + Radius*n1.z;
            n2.Z := cos(theta1) * cos(theta3);
            n2.Y := sin(theta1);
            n2.X := cos(theta1) * sin(theta3);
              p2.X := CX + Radius*n2.X;
              p2.y := CY + Radius*n2.Y;
              p2.Z := CZ + Radius*n2.Z;
          st1 := vec2f( -(1-I/n), 2*(J+1)/n);
          st2 := vec2f( -(1-i/n), 2*j/n);
          		 coef := (st1.x * st2.y - st2.x * st1.y);
               if coef <> 0 then coef := 1 / coef;
               
    		tangent.x := coef * ((p1.x * st2.y)  + (p2.x * -st1.y));
    		tangent.y := coef * ((p1.y * st2.y)  + (p2.y * -st1.y));
    		tangent.z := coef * ((p1.z * st2.y)  + (p2.z * -st1.y));
        tangent := v_normalize(tangent);
   		 binormal := v_cross(n1 , tangent);


          glNormal3f(n1.X,n1.Y,n1.Z);
          glMultiTexCoord2f(GL_TEXTURE0, st1.x, st1.y);
          glMultiTexCoord3fv(GL_TEXTURE2, @tangent);
          glMultiTexCoord3fv(GL_TEXTURE1, @binormal);

          glVertex3f(p1.x,p1.y,p1.z);

          glNormal3f(n2.X,n2.Y,n2.Z);
          glMultiTexCoord2f(GL_TEXTURE0, st2.x, st2.y);
          glMultiTexCoord3fv(GL_TEXTURE2, @tangent);
   		 binormal := v_cross(n2 , tangent);
          glMultiTexCoord3fv(GL_TEXTURE1, @binormal);
          glVertex3f(p2.x,p2.y,p2.z);


        end;
 end;
 glEnd;
end;

Procedure SetProjection(W, H: integer; Ortho: boolean);
begin

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  if ortho then
    glOrtho(0, w, h, 0, -1, 100)
  else
    gluPerspective(FOV, W/H, zmin, Zmax);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

end;

Procedure SetTexProjection(W, H: integer; Ortho: boolean);
begin

  glMatrixMode(GL_Texture);
  glLoadIdentity();

  if ortho then
    glOrtho(0, w, h, 0, -1, 100)
  else
    gluPerspective(FOV, W/H, zmin, Zmax);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

end;

function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;

Function Booltostr(B:Boolean) : String;
begin
if b = true then result := 'Вкл' else result := 'Выкл';
end;

function ExtractFilePath(const s: string): string;
var
i :integer;
begin
//    setlength(s,length(s)-1);
    for i :=length(s)-1 downto 1 do
    if s[i]='\' then
    begin
    result := copy(s,1,i);
    exit;
    end;
end;

function ExtractFileName(const s: string): string;
var
i :integer;
begin
Result:=S;
    for i :=length(s)-1 downto 1 do
    if s[i]='\' then
    begin
    result := copy(s,i+1,length(s)-1);
    exit;
    end;
end;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

Function SameText(A,B:String):Boolean;
begin
if AnsiUpperCase(a) = AnsiUpperCase(b) then result:=true else result:=false;
end;

function ChangeFileExt(const FileName, Extension: string): string;
var
  I: Integer;
  S: String;
begin
I := POS('.',FileName);
s := Copy(FileName,1,i-1);
    Result:= S+Extension;
end;

function FileExists(FileName: string): boolean;
var
 F: File;
begin
FileMode := 64;
AssignFile(F, FileName);
{$I-}
Reset(F);
{$I+}
Result:=IOResult=0;
if Result then
 CloseFile(F);
end;


Initialization
 initlog;

Finalization
  closelog;

end.