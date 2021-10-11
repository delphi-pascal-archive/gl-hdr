unit l_math;
{$Warnings off}
{$Hints On}
(************************************)
(* SVSD_VAL                         *)
(* Last modify 05.03.08             *)
(************************************)
(* Site : SVSD.MirGames.ru          *)
(* mail : ValDim_05@Mail.ru         *)
(************************************)
(* Additions from Kavis             *)
(* Last modify 12.03.08             *)
(* Site : http://openglmax.narod.ru *)
(* Mail : kavi5@yandex.ru           *)
(************************************)

interface
uses windows;
type


  TVec2b = record
    x, y : ShortInt;
  end;

  TVec2s = record
    x, y : SmallInt;
  end;
  TVec3s = record
    x, y, z : SmallInt;
  end;

  TVec3ub = record
    x, y, z : Byte;
  end;

  TVec3b = record
    x, y, z : ShortInt;
  end;

  TVec2f = record
    x, y : Single;
    class operator Implicit(v: TVec2s): TVec2f;
  end;

  PVec3f = ^TVec3f;
  TVec3f = record
    class operator Implicit(v: TVec3b): TVec3f; inline;
    class operator Equal(v1, v2: TVec3f): Boolean; inline;

    class operator LessThan   (v1, v2: TVec3f): Boolean; inline;
    class operator GreaterThan(v1, v2: TVec3f): Boolean; inline;
    class operator Add(v1, v2: TVec3f): TVec3f; inline;
    class operator Subtract(v1, v2: TVec3f): TVec3f; inline;
    class operator Divide(v: TVec3f; x: Single): TVec3f; inline;

    class operator Multiply(v: TVec3f; x: Single): TVec3f; inline;
    class operator Multiply(v1, v2: TVec3f): TVec3f; inline;
    class operator Negative(v: TVec3f): TVec3f; inline;
    function  Lerp(v: TVec3f; t: Single): TVec3f; inline;
    function  Dot(v: TVec3f): Single; inline;
    function  Cross(v: TVec3f): TVec3f; inline;
    function  Normal: TVec3f;
    procedure Normalize; inline;
    function  Length: Single; inline;
    function  LengthQ: Single; inline;
    function  Angle(v: TVec3f): Single; inline;
    case byte of
    0 :(x, y, z : Single);
    1 :(raw : array [0..2] of single;)
  end;

   TVector = TVec3f ;


  TVec4f = record
    class operator Add(v1, v2: TVec4f): TVec4f;
    class operator Subtract(v1, v2: TVec4f): TVec4f;
    class operator Multiply(v: TVec4f; x: Single): TVec4f;
    function Dot(v: TVec4f): Single;
    function Lerp(v: TVec4f; t: Single): TVec4f;
    function SLerp(v: TVec4f; t: Single): TVec4f;
    procedure Normalize;
    function Length: Single;
    procedure FromVecAngle(v: TVec3f; Angle: Single);
    case byte of
    0 :(x, y, z, w : Single);
    1 :(raw : array [0..3] of single;)
  end;

  PMat4F = ^TMat4f;
  TMat4f = record
    class operator Multiply(m: TMat4f; v: TVec3f): TVec3f; inline;
    class operator Multiply(m: TMat4f; v: TVec4f): TVec4f; inline;
    class operator Multiply(a, b: TMat4f): TMat4f;

    procedure Identity;
    function  Det: Single;
    function  Inverse: TMat4f; 
    procedure SetRot(v: TVec4f); inline;
    procedure SetPos(v: TVec3f); inline;
    procedure SetRotPos(const Angle: TVec4f; const POS:TVec3f); inline;
    case Integer of
      0: (cell : array [0..3, 0..3] of Single);
      1: (e00, e01, e02, e03,
          e10, e11, e12, e13,
          e20, e21, e22, e23,
          e30, e31, e32, e33: Single);
      2: (row: array [0..3] of TVec4f);
      3: (raw: array[0..15]of single);
  end;

TMatrix4 =TMat4f ;


  TPD_V =  array [1..8] of Tvec3f; ///параллепипед


 TFace = array [0..2] of WORD;
  PAabb        = ^TAABB;
  TAabb        = Record
   MINS,MAXS   : TVec3f;
  end;

 TSphere = packed record
    POS   : TVec3f;
    Radius: Single;
 end;

 TShaderVertex = record
  Tangent,               // COL0
  Binormal,              // COL1
  Normal       : TVec3f;       // NRML
  Tex0         : TVec2f;
  Pos          : TVec3f;
 end;

 TQuat     = record
  ImagPart : TVec3f;
  RealPart : Single;
 end;

 TPlane    = record
  Normal   : TVec3f;
  V        : TVec3f;
  D        : single;
 end;

 TDistBool = record
  Point,Vector: TVec3f;
  Dist        : Single;
  Return      : Boolean;
 end;

 TRay = record
   O, D: TVec3f;
 end;
  PDoubleArray = ^TDoubleArray;
  TDoubleArray = array [0..10] of Double;

  PSingleArray = ^TSingleArray;
  TSingleArray = array [0..10] of Single;

  TVec2bArray = array [0..1] of TVec2b;
  PVec2bArray = ^TVec2bArray;

  TVec2sArray = array [0..1] of TVec2s;
  PVec2sArray = ^TVec2sArray;

  TVec2fArray = array [0..1] of TVec2f;
  PVec2fArray = ^TVec2fArray;

  TVec3sArray = array [0..1] of TVec3s;
  PVec3sArray = ^TVec3sArray;

  TVec3ubArray = array [0..1] of TVec3ub;
  PVec3ubArray = ^TVec3ubArray;

  TVec3bArray = array [0..1] of TVec3b;
  PVec3bArray = ^TVec3bArray;

  TVec3fArray = array [0..1] of TVec3f;
  PVec3fArray = ^TVec3fArray;

  TVec4fArray = array [0..1] of TVec4f;
  PVec4fArray = ^TVec4fArray;

  TWordArray = array [0..9] of Word;
  PWordArray = ^TWordArray;


const
 PI                            = 3.14159265358979323846;
 PI2                           = pi*2;
 RAD2DEG                       = 180/PI;
 DEG2RAD                       = PI/180;
 ELASTICITY                    = 0.05;
 FRICTION                      = 0.05;
 MATCH_FACTOR                  = 0.999;
 M_ANGLE                       = MATCH_FACTOR*(2*PI);

 EPSILON_ZERO                  = 0.0;
 EPSILON                       = 0.0001;
 EPSILON_ON_SIDE               = 0.1;
 EPSILON_VECTOR_COMPARE        = 0.00001;
 EPSILON_30                    = 1E-30;
 EPSILON_SNAP_PLANE_NORMAL     = 0.00001;
 EPSILON_SNAP_PLANE_DIST       = 0.01;

 // Identity's
 V_Identity  : TVec3f         = (x:0;y:0;z:0);
 V_mIdentity : TVec3f         = (x:1;y:1;z:1);

 P_Identity  : TPlane          = (Normal  :(x:0;y:0;z:0); V:(x:0;y:0;z:0); D: 0);
 DB_Identity : TDistBool       = (Point   :(x:0;y:0;z:0); Vector:(x:0;y:0;z:0); Dist: 0;Return:false);
 Q_Identity  : TQuat           = (ImagPart:(x:0;y:0;z:0); RealPart: 1);

 v_Gravity                     = 8*0.001;
 Byte2GL                       = 1/255;

  function Min(const x, y: Integer): Integer; inline; overload;
  function Max(const x, y: Integer): Integer; inline; overload;
  function Min(const x, y: Single): Single; inline; overload;
  function Max(const x, y: Single): Single; inline; overload;

 // Math
  function ArcTan2(const Y, X: single): single;
  function ArcCos (const X: single): single;
  function Tan    (const X: Extended): Extended;
  procedure SinCos(const Theta: Single; var Sin, Cos: Single); register;

 // 3D Vector's
  function  Vector      (const X, Y, Z: single): TVec3f;

  Procedure generateNormalAndTangent( xv1, xv2 , xv3: TVec3f; xst1 , xst2, xst3 : TVec2f; var normal, tangent: TVec3f);

  procedure v_clear     (var v: TVec3f);
  function v_Add        (const v1, v2 : TVec3f): TVec3f;
  function v_Sub        (const v1, v2 : TVec3f): TVec3f;
  function v_Mult       (const v: TVec3f; const d: single): TVec3f;
  function v_Div        (const v: TVec3f; const d: single): TVec3f;
  function v_DivV       (const v1, v2 : TVec3f): TVec3f;
  function v_MultV      (const v1, v2 : TVec3f): TVec3f;
  function v_Dist       (const v1, v2 : TVec3f): single;
  function v_Distq      (const v1, v2 : TVec3f): single;
  function v_Length     (const v: TVec3f): single;
  function v_Norm       (const v: TVec3f): Single;
  function v_Normalize  (const v: TVec3f): TVec3f;
  function v_Normalizesafe(const inv: TVec3f; out outv: TVec3f): Single;
  Function v_Negate     (const V: TVec3f): TVec3f;
  function v_Dot        (const v1, v2 : TVec3f): single;
  function v_Cross      (const v1, v2 : TVec3f): TVec3f;
  function v_Angle      (const v1, v2 : TVec3f) : real;
  function v_Angle2     (const V1, v2 : TVec3f): Single;
  function v_Interpolate(const v1, v2 : TVec3f; const k: single): TVec3f;
  function v_combine    (const v1, v2 : TVec3f; const scale : Single): TVec3f;
  function v_spacing    (const v1, v2 : TVec3f): Single;

  function v_RotateX    (const V : TVec3f; const ang : Single): TVec3f;
  function v_RotateY    (const V : TVec3f; const ang : Single): TVec3f;
  function v_RotateZ    (const V : TVec3f; const ang : Single): TVec3f;
  function v_Rotate     (const V,Rot: TVec3f): TVec3f;
  function v_Reflect    (const V,N  : TVec3f): TVec3f;

  function v_Offset     (const V1,V2:TVec3f):TVec3f;
  function v_CreateOffset(const Heading,Tilt:Single):TVec3f;


// 2D Vector's
  function Vector2D     (const X, Y: single): TVec2f;
  function v_Rotate2D   (const v: TVec2f; const ang: single): TVec2f;
  Function V_Length2d(V:TVec2f):Single;
  Function V_sub2d(V,v2:TVec2f):TVec2f;
  Function V_add2d(V,v2:TVec2f):TVec2f;
// Plane
  function P_Normal     (const v1, v2, v3: TVec3f): TVec3f;
  function P_Plane      (const v1, v2, v3: TVec3f): TPlane;
  function P_Plane2     (const Normal,v1: TVec3f): TPlane;
  function P_Dist       (const Pos: TVec3f; const Plane: TPlane): single;
  function P_Classify   (const plane: TPlane; const p: TVec3f): Single;
  function p_evaluate   (const plane: TPlane; const p: TVec3f): Single; register;
  function p_offset     (const Plane: TPlane; const Pos: TVec3f): TPlane;
  function P_InsideTri  (const v, v1, v2, v3: TVec3f): boolean;
  function P_Intersection   (const plane: TPlane; const LineStart, LineEnd: TVec3f): boolean;
  function P_GetIntersection(const plane: TPlane; const LineStart, LineEnd: TVec3f): TVec3f;
  function P_Angle          (const V1, V2, V3: TVec3f): Single;
  Function P_Determine      (const Normal: TVec3f): integer; //0 - Xy, 1 - Yz, 2- xZ
///////
  function EdgeSphereCollision(const Center,v1, v2, v3: TVec3f; const Radius: Single): Boolean;
  function ClosestPointOnLine (const vA, vB, Point: TVec3f): TVec3f;
///////
  function v_Min        (const v1,v2 : TVec3f): boolean;
  Function VAABBMax     (const V1,v2 : TVec3f): TVec3f;
  Function VAABBMin     (const V1,v2 : TVec3f): TVec3f;
  function v_nan        (const V ,v2 : TVec3f): TVec3f;
  function IsNaN        (const v : single) : boolean;
  Function ChangeAcc(const Acc,Normal: TVec3f): TVec3f;

  ////////////////////////////////
  // QUATERNION ROUTINES
  function Quaternion   (const X, Y, Z, W: single): TQuat;
  function Q_Matrix     (const q: TQuat): TMat4f;
  function q_Magnitude  (const Quat: TQuat): Single;
  function q_Normalize  (const Quat: TQuat):TQuat;
  function Q_Mult       (const qL, qR: TQuat): TQuat;
  function Q_FromPoints (const V1, V2: TVec3f): TQuat;
  function Q_FromVector (const v: TVec3f; const Angle: single): TQuat;
  function Q_ToMatrix   (const Q: TQuat): TMat4f;
  function Q_interpolate(const QStart, QEnd: TQuat; const Spin: Integer; const tx: Single): TQuat;

  ////////////////////////////////
  // MATRIX ROUTINES
  function m_CreateScaleMatrix    (const Scale : TVec3f): TMat4f; overload;
  function m_CreateScaleMatrix    (const Scale : Single): TMat4f; overload;
  function m_CreateRotationMatrixZ(const Angle : Single): TMat4f;
  function m_CreateRotationMatrixY(const Angle : Single): TMat4f;
  function m_CreateRotationMatrixX(const Angle : Single): TMat4f;
  function m_CreateRotationMatrix (const Angles: TVec3f): TMat4f;
  function m_SetTranslation       (const M: TMat4f; const Translation: TVec3f): TMat4f;
  function m_FromQuaternion       (const Q: TQuat): TMat4f;
  function m_transpose            (const M: TMat4f): TMat4f;
  function m_TransformVector      (const V: TVec3f; const M: TMat4f): TVec3f;
  function M_Rotation             (const v: TVec3f; const Angle: single): TMat4f;
  function M_MultV                (const m: TMat4f; const v: TVec3f): TVec3f;
  function M_Determinant          (const M: TMat4f): Single;
  Function M_Scale                (const M: TMat4f; const Factor: Single): TMat4f; register;
  Function M_Adjoint              (const M: TMat4f): TMat4f;
  function M_DetInternal          (const a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
  Procedure CreateRotationMatrix(var Result:TMat4f; const Angles, Position: TVec3f);
 ////////////////////////////////

  function  LineVsPolygon (const v1,v2,v3, LB,LE,vNormal : TVec3f):boolean;
  function  LineVsPolygon2(const v1,v2,v3, LB,LE,vNormal : TVec3f;Var vInt : TVec3f):boolean;

  function  LineInsideTri (const PointPlane1,PointPlane2,PointPlane3,BeginPoint,EndPoint: TVec3f): TDistBool;
  function  LineInsideTri2(const PointPlane1,PointPlane2,PointPlane3,BeginPoint,EndPoint: TVec3f): boolean;
  function  MinDistToLine(const Point,LinePoint1,LinePoint2: TVec3f): TDistBool;
  function  CollEllipsToTr(var Center: TVec3f; const Radius,PointPlane1,PointPlane2,PointPlane3: TVec3f): TDistBool;

  function uSphereFromAABB(const aabb: TAABB): TSphere;
  Function uCubeVsPoint   (const Box,Point : TVec3f; Size:Single):Boolean;
  Function uBoxVsPoint    (const Box,BoxSize,Point : TVec3f):Boolean;
  function uAABBVsPoint   (const Minx,Maxx,Pos : TVec3f): boolean;
  function uBoxVsBox      (const Box1,Box2, Box1Size,Box2Size : TVec3f): boolean;
  Function uAABBVsAABB    (const Minx1,Maxx1,Minx2,Maxx2: TVec3f): boolean;
  function uAABBVsSphere  (const Minx,Maxx,Pos : TVec3f;R:Single): boolean;
  function uCubeVsLine    (const BP,LBEGIN,LEND : TVec3f;BS :single): boolean;
  function uAABBVsLine    (const Mins,Maxs,StartPoint, EndPoint : TVec3f): boolean;
  function uSphereVsPoint (const Sphere ,Point : TVec3f; R: Single): boolean;
  Function uSphereVsSphere(const Sphere1,Sphere2 : TVec3f; R1,R2 : Single) : boolean;
  function uSphereVsLine  (const Sphere ,LB,LE : TVec3f;R: Single): boolean;
  function uSphereVsLine2 (const Sphere, P1,P2 : TVec3f;R: Single): boolean;
  function uAABBFromSphere(const POS: TVec3f; Radius:Single): TAABB;

///////////////
  // Shaders //
  procedure CalculateTandB      (var T, B: TVec3f; const st1, st2: TVec2f; const P, Q: TVec3f);
  procedure CalculateTangents   (var v1, v2, v3: TShaderVertex);
  Procedure CreateTangentVectorSpace(const v1, v2, v3 : TVec3f; Const T1,T2,T3:TVec2f; Var tangent, binormal, normal:TVec3f);
  function  dotVecLengthSquared3(v: TVec3f): Single;
  procedure dotVecNormalize3    (var v: TVec3f);


  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //   Additions from Kavis                                                    /
  //   kavi5@yandex.ru                                                         /
  //   http://openglmax.narod.ru                                               /
  //   изменение 3.04.10                                                           /
  //////////////////////////////////////////////////////////////////////////////
  Function V_VectorLen(var V: TVec3f; newLen: Single): Single;
  Function FindIntersection(P1, P2, P3: TVec3f; P: TVec3f; V: TVec3f; var I: TVec3f): single;
  Function FindP(const P1, P2, P3: TVec3f; P: TVec3f; V: TVec3f; var I: TVec3f): single;
  function GetOffsetToTarget(POS,TGPOS:TVector):TVector;
  function RotateAroundVector(const in1, in2 :Tvector; const delta: single) : Tvector;
  //SVSD_VAL
  Procedure M_Inverse(M1:PMat4F; Result: PMat4F);
  Procedure LookAt(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz : Single; M:PMat4F);

  procedure ComputeNormalsTrianglesStrip(var NA: array of TVec3f; Const VA: array of TVec3f; const IA:array of TFace);
  Function  FindFastAngle      (Const Pos,Target:TVec3f;Const Heading:Single):Single;

  function Vec4f(x, y, z, w: Single): TVec4f; inline;
  function Vec3f(x, y, z: Single): TVec3f; inline;
  function Vec2f(x, y: Single): TVec2f; inline;
implementation

function Vec4f(x, y, z, w: Single): TVec4f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Vec3f(x, y, z: Single): TVec3f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec2f(x, y: Single): TVec2f;
begin
  Result.x := x;
  Result.y := y;
end;

function ArcSin(const X: Extended): Extended;
begin
  Result := ArcTan2(X, Sqrt(1 - X * X))
end;

function RadToDeg(const Radians: Extended): Extended;  { Degrees := Radians * 180 / PI }
begin
  Result := Radians * (180 / PI);
end;

Function GetAngle(POS1,POS2:TVec3f):Single;
var
  VLeng,Cosns,Sins,ArCos: Single;
begin
  VLeng:=Sqrt(Sqr(POS2.x-POS1.x)+Sqr(POS2.z-POS1.z));
  if VLeng <> 0 then
  VLeng:= 1 / VLeng;
  Cosns:=(POS2.x-POS1.x)*VLeng;
  Sins :=(POS2.z-POS1.z)*VLeng;
  ArCos:=ArcCos(Cosns);
  if Sins<0 then Result:=360-RadToDeg(ArCos) else Result:=RadToDeg(ArCos);
end;

Function   FindFastAngle      (Const Pos,Target:TVec3f;Const Heading:Single):Single;
var
 Ran,RealRan,
 rr,rr2,rr3 : Single;
begin
          // Получаем угол
          RealRan  := - GetAngle(Pos,Target)+180;
          Ran      := Heading;

       // Выравниваем его чтоб он унас был в пределах 360
       if abs(Ran) > 360 then Ran := Ran - trunc(Ran / 360)*360;

          // Получаем на сколько её повернуть
          rr3   :=      RealRan - Ran;
          rr2   := (360+RealRan)- Ran;

          // Выбираем к какому из них легче повернуть
          if ABS(RR2) > abs(rr3) then
           rr := rr3 else rr := rr2;

          // тепер переделываем всё под наши нужды
          if Abs(rr) > 180 then rr := -(360-rr);
 // Возвращаем то что нам надо
 Result:=RR;
end;


procedure ComputeNormalsTrianglesStrip(var NA: array of TVec3f; Const VA: array of TVec3f; const IA:array of TFace);
var
  i: Integer;
  Normal: TVec3f;
begin
  for i:=0 to High(IA)-2 do
  begin
//    if (IA[i][0]=IA[i][1]) or (IA[i][0]=IA[i][2]) or (IA[i][1]=IA[i][2]) then Continue;
    Normal:=P_Normal(VA[IA[i][0]], VA[IA[i][1]], VA[IA[i][2]]);
    if i mod 2 = 1 then v_mult(Normal,- 1);

    NA[IA[i][0]] :=V_Add(VA[IA[i][0]], V_Mult(Normal, P_Angle(VA[IA[i][0]], VA[IA[i][1]], VA[IA[i][2]]) ) );
    NA[IA[i][1]] :=V_Add(VA[IA[i][1]], V_Mult(Normal, P_Angle(VA[IA[i][1]], VA[IA[i][2]], VA[IA[i][0]]) ) );
    NA[IA[i][2]] :=V_Add(VA[IA[i][2]], V_Mult(Normal, P_Angle(VA[IA[i][2]], VA[IA[i][0]], VA[IA[i][1]]) ) );


  end;
  for i:=0 to High(VA) do NA[i]:=V_Normalize(NA[i]);
end;

function V_CreateOffset(const Heading,Tilt:Single):TVec3f;
var
HD,TL  :Single;
begin
HD     := (Heading-90)*(pi/180);
TL     :=  Tilt*(pi/180);
Result := vector(cos(hd) * cos(tl),
                 sin(-tl),
                 sin(hd) * cos(tl));

end;

function V_Offset(const V1,V2:TVec3f):TVec3f;
begin
Result:= V_div(V_sub(V2,V1),
               V_DIST(V1,V2));
end;

Function ChangeAcc(const Acc,Normal: TVec3f): TVec3f;
Var
D    : Single;
VN,VT: TVec3f;
begin

D := (acc.x * Normal.x) + (acc.y * Normal.y) + (acc.z * Normal.z);
     Vn := v_Mult(Normal,D-0.05);
     Vt := v_Sub (Acc,Vn);
 Result := v_add (v_mult(Vt ,(1.0 - Friction) ),v_mult(Vn, -Elasticity) );
end;

function IsNaN(const v : single) : boolean;
asm
  fld   dword ptr v    // 0: v
  fxam                 // see what we've got, C0 set if NaN
  fstsw ax             // store C0-C3 in ax,
  sahf                 //   then in EFLAGS register: C0 -> CF
  mov   Result,0       // assume false
  jae   @NoNaN         // jump if CF not set
  mov   Result,1       // set result to true
@NoNaN:
  ffree st(0)          // clear FPU register
end;

function Min(const x, y: Integer): Integer;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function Max(const x, y: Integer): Integer;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function Max(const x, y: Single): Single;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function Min(const x, y: Single): Single;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function Tan(const X: Extended): Extended;
{  Tan := Sin(X) / Cos(X) }
asm
        FLD    X
        FPTAN
        FSTP   ST(0)      { FPTAN pushes 1.0 after result }
        FWAIT
end;

(***   Тригонометрия   ***)
function ArcTan2(const Y, X: single): single;
asm
 FLD     Y
 FLD     X
 FPATAN
 FWAIT
end;

function ArcCos(const X: single): single;
asm
{
Result := ArcTan2(Sqrt(1 - X * X), X);
}
       FLD     X
       fmul    ST(0),ST(0)
       FLD1
       FSub    st(0), st(1)
       FSQRT
       FLD     X
       FPATAN
       FWAIT
       FSTP ST(1)
end;

(***   Векторы   ***)

procedure SinCos(const Theta: Single; var Sin, Cos: Single); register;
asm
  fld theta
  fsincos
  fstp dword ptr [edx]
  fstp dword ptr [eax]
end;



{$REGION 'TVec3f'}
class operator TVec3f.LessThan   (v1, v2: TVec3f): Boolean;
begin
Result := (v1.x < v2.x) or  (v1.y < v2.y) or (v1.z < v2.z);
end;

class operator TVec3f.GreaterThan(v1, v2: TVec3f): Boolean;
begin
Result := (v1.x > v2.x) or  (v1.y > v2.y) or (v1.z > v2.z);
end;

class operator TVec3f.Divide(v: TVec3f; x: Single): TVec3f;
var
 S : Single;
begin
  S := 1 / X;
  Result.X := v.x * s;
  Result.Y := v.y * s;
  Result.Z := v.z * s;
end;

class operator TVec3f.Negative(v: TVec3f): TVec3f;
begin
  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;
{ASM
  FLD DWORD PTR [EAX]
  FCHS // WAIT
  FSTP DWORD PTR [EDX]
  FLD DWORD PTR [EAX+4]
  FCHS // WAIT
  FSTP DWORD PTR [EDX+4]
  FLD DWORD PTR [EAX+8]
  FCHS // WAIT
  FSTP DWORD PTR [EDX+8]
}
end;

class operator TVec3f.Implicit(v: TVec3b): TVec3f;
begin
  Result.x := v.x;
  Result.y := v.y;
  Result.z := v.z;
end;

class operator TVec3f.Equal(v1, v2: TVec3f): Boolean;
begin
  Result := (v1.X = v2.X) and (v1.Y = v2.Y) and (v1.Z = v2.Z);
end;

class operator TVec3f.Add(v1, v2: TVec3f): TVec3f;
begin
  Result.X := v1.X + v2.X;
  Result.Y := v1.Y + v2.Y;
  Result.Z := v1.Z + v2.Z;
end;

class operator TVec3f.Subtract(v1, v2: TVec3f): TVec3f;
begin
  Result.X := v1.X - v2.X;
  Result.Y := v1.Y - v2.Y;
  Result.Z := v1.Z - v2.Z;
end;

class operator TVec3f.Multiply(v: TVec3f; x: Single): TVec3f;
begin
  Result.X := v.X * x;
  Result.Y := v.Y * x;
  Result.Z := v.Z * x;
end;

class operator TVec3f.Multiply(v1, v2: TVec3f): TVec3f;
begin
{
  Result.X := v1.Y * v2.Z - v1.Z * v2.Y;
  Result.Y := v1.Z * v2.X - v1.X * v2.Z;
  Result.Z := v1.X * v2.Y - v1.Y * v2.X;     }

  Result.X := v1.X * v2.X;
  Result.Y := v1.Y * v2.Y;
  Result.Z := v1.Z * v2.Z;
end;

function TVec3f.Lerp(v: TVec3f; t: Single): TVec3f;
begin
  Result := Self + (v - Self) * t;
end;

function TVec3f.Dot(v: TVec3f): Single;
begin
  Result := X * v.X + Y * v.Y + Z * v.Z;
end;

function TVec3f.Cross(v: TVec3f): TVec3f;
begin
  Result.X := Y * v.Z - Z * v.Y;
  Result.Y := Z * v.X - X * v.Z;
  Result.Z := X * v.Y - Y * v.X;
end;

function TVec3f.Normal: TVec3f;
var
  len : Single;
begin
  len := Length;
  if len <> 0 then
    Result := Self * (1/len)
  else
    Result := Vec3f(0, 0, 0);
end;

procedure TVec3f.Normalize;
begin
  Self := Normal;
end;

function TVec3f.Length: Single;
begin
  Result := sqrt(LengthQ);
end;

function TVec3f.LengthQ: Single;
begin
  Result := sqr(X) + sqr(Y) + sqr(Z);
end;

function TVec3f.Angle(v: TVec3f): Single;
begin
  Result := ArcCos(Dot(v) * (1/(Length * v.Length)));
end;
{$ENDREGION}

{$REGION 'TVec2f'}
class operator TVec2f.Implicit(v: TVec2s): TVec2f;
begin
  Result.x := v.x;
  Result.y := v.y;
end;
{$ENDREGION}

{$REGION 'TVec4f'}
class operator TVec4f.Add(v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := v1.w + v2.w;
end;

class operator TVec4f.Subtract(v1, v2: TVec4f): TVec4f;
begin
  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := v1.w - v2.w;
end;

class operator TVec4f.Multiply(v: TVec4f; x: Single): TVec4f;
begin
  Result.x := v.x * x;
  Result.y := v.y * x;
  Result.z := v.z * x;
  Result.w := v.w * x;
end;

function TVec4f.Dot(v: TVec4f): Single;
begin
  Result := x * v.x + y * v.y + z * v.z + w * v.w;
end;

function TVec4f.Lerp(v: TVec4f; t: Single): TVec4f;
begin
  if Dot(v) < 0 then
    Result := Self - (v + Self) * t
  else
    Result := Self + (v - Self) * t;
end;

function TVec4f.SLerp(v: TVec4f; t: Single): TVec4f;
var
  omega, d, sinom, scale0, scale1 : Single;
begin
  d := Dot(v);
  if d < 0 then
  begin
    v := v * -1;
    d := -d;
  end;

  if  1 - d > 0 then
  begin
    omega  := ArcCos(d);
    sinom  := 1 / sin(omega);
    scale0 := sin((1 - t) * omega) * sinom;
    scale1 := sin(t * omega) * sinom;
  end else
  begin
    scale0 := 1 - t;
    scale1 := t;
  end;

  Result := (Self * scale0 + v * scale1);
end;

procedure TVec4f.Normalize;
var
  len : Single;
begin
  len := 1 / Length;
  x := x * len;
  y := y * len;
  z := z * len;
  w := w * len;
end;

function TVec4f.Length: Single;
begin
  Result := sqrt(sqr(x) + sqr(y) + sqr(z) + sqr(w));
end;

procedure TVec4f.FromVecAngle(v: TVec3f; Angle: Single);
var
  s : Single;
begin
  Angle := Angle * 0.5;
  v.Normalize;
  s := sin(Angle);
  x := v.x * s;
  y := v.y * s;
  z := v.z * s;
  w := cos(Angle);
end;
{$ENDREGION}

{$REGION 'TMat4f'}
class operator TMat4f.Multiply(m: TMat4f; v: TVec3f): TVec3f;
begin
  with m do
    Result := Vec3f(e00 * v.X + e10 * v.Y + e20 * v.Z + e30,
                    e01 * v.X + e11 * v.Y + e21 * v.Z + e31,
                    e02 * v.X + e12 * v.Y + e22 * v.Z + e32);
end;

class operator TMat4f.Multiply(m: TMat4f; v: TVec4f): TVec4f;
begin
  with m do
    result := Vec4f(raw[ 0]*v.x + raw[ 4]*v.y + raw[ 8]*v.z + raw[12]*v.w,
                    raw[ 1]*v.x + raw[ 5]*v.y + raw[ 9]*v.z + raw[13]*v.w,
                    raw[ 2]*v.x + raw[ 6]*v.y + raw[10]*v.z + raw[14]*v.w,
                    raw[ 3]*v.x + raw[ 7]*v.y + raw[11]*v.z + raw[15]*v.w);
end;

class operator TMat4f.Multiply(a, b: TMat4f): TMat4f;
begin
//FillChar(Result,16*4,0);
  with Result do
  begin
    e00 := a.e00 * b.e00 + a.e01 * b.e10 + a.e02 * b.e20 + a.e03 * b.e30;
    e10 := a.e10 * b.e00 + a.e11 * b.e10 + a.e12 * b.e20 + a.e13 * b.e30;
    e20 := a.e20 * b.e00 + a.e21 * b.e10 + a.e22 * b.e20 + a.e23 * b.e30;
    e30 := a.e30 * b.e00 + a.e31 * b.e10 + a.e32 * b.e20 + a.e33 * b.e30;
    e01 := a.e00 * b.e01 + a.e01 * b.e11 + a.e02 * b.e21 + a.e03 * b.e31;
    e11 := a.e10 * b.e01 + a.e11 * b.e11 + a.e12 * b.e21 + a.e13 * b.e31;
    e21 := a.e20 * b.e01 + a.e21 * b.e11 + a.e22 * b.e21 + a.e23 * b.e31;
    e31 := a.e30 * b.e01 + a.e31 * b.e11 + a.e32 * b.e21 + a.e33 * b.e31;
    e02 := a.e00 * b.e02 + a.e01 * b.e12 + a.e02 * b.e22 + a.e03 * b.e32;
    e12 := a.e10 * b.e02 + a.e11 * b.e12 + a.e12 * b.e22 + a.e13 * b.e32;
    e22 := a.e20 * b.e02 + a.e21 * b.e12 + a.e22 * b.e22 + a.e23 * b.e32;
    e32 := a.e30 * b.e02 + a.e31 * b.e12 + a.e32 * b.e22 + a.e33 * b.e32;
    e03 := a.e00 * b.e03 + a.e01 * b.e13 + a.e02 * b.e23 + a.e03 * b.e33;
    e13 := a.e10 * b.e03 + a.e11 * b.e13 + a.e12 * b.e23 + a.e13 * b.e33;
    e23 := a.e20 * b.e03 + a.e21 * b.e13 + a.e22 * b.e23 + a.e23 * b.e33;
    e33 := a.e30 * b.e03 + a.e31 * b.e13 + a.e32 * b.e23 + a.e33 * b.e33;
  end;
end;

procedure TMat4f.Identity;
var
  i: Integer;
begin
  ZeroMemory(@Self, SizeOf(TMat4f));
  for i := 0 to 3 do
    cell[i, i] := 1;
end;

function TMat4f.Det: Single;
begin
  Result := e00 * e11 * e22 + e10 * e21 * e02 + e20 * e01 * e12 -
            e20 * e11 * e02 - e10 * e01 * e22 - e00 * e21 * e12;
end;

function TMat4f.Inverse: TMat4f;
var
  D : Single;
begin
   D := Det;
if D = 0 then exit;

  D := 1 / D;
  Result.e00 :=  (e11 * e22 - e21 * e12) * D;
  Result.e01 := -(e01 * e22 - e21 * e02) * D;
  Result.e02 :=  (e01 * e12 - e11 * e02) * D;
  Result.e03 := 0;
  Result.e10 := -(e10 * e22 - e20 * e12) * D;
  Result.e11 :=  (e00 * e22 - e20 * e02) * D;
  Result.e12 := -(e00 * e12 - e10 * e02) * D;
  Result.e13 := 0;
  Result.e20 :=  (e10 * e21 - e20 * e11) * D;
  Result.e21 := -(e00 * e21 - e20 * e01) * D;
  Result.e22 :=  (e00 * e11 - e10 * e01) * D;
  Result.e23 := 0;
  Result.e30 := -(e30 * Result.e00 + e31 * Result.e10 + e32 * Result.e20);
  Result.e31 := -(e30 * Result.e01 + e31 * Result.e11 + e32 * Result.e21);
  Result.e32 := -(e30 * Result.e02 + e31 * Result.e12 + e32 * Result.e22);
  Result.e33 := 1;
end;

procedure TMat4f.SetRot(v: TVec4f);
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2 : single;
begin
  with v do
  begin
    x2 := x + x;   y2 := y + y;   z2 := z + z;
    xx := x * x2;  xy := x * y2;  xz := x * z2;
    yy := y * y2;  yz := y * z2;  zz := z * z2;
    wx := w * x2;  wy := w * y2;  wz := w * z2;
  end;

  e00 := 1 - (yy + zz);  e10 := xy + wz;        e20 := xz - wy;
  e01 := xy - wz;        e11 := 1 - (xx + zz);  e21 := yz + wx;
  e02 := xz + wy;        e12 := yz - wx;        e22 := 1 - (xx + yy);

  e30 := 0;
  e31 := 0;
  e32 := 0;
  e03 := 0;
  e13 := 0;
  e23 := 0;
  e33 := 1;
end;

procedure TMat4f.SetRotPos(const Angle: TVec4f; const POS:TVec3f);
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2 : single;
begin
  with Angle do
  begin
    x2 := x + x;   y2 := y + y;   z2 := z + z;
    xx := x * x2;  xy := x * y2;  xz := x * z2;
    yy := y * y2;  yz := y * z2;  zz := z * z2;
    wx := w * x2;  wy := w * y2;  wz := w * z2;
  end;

  e00 := 1 - (yy + zz);  e10 := xy + wz;        e20 := xz - wy;
  e01 := xy - wz;        e11 := 1 - (xx + zz);  e21 := yz + wx;
  e02 := xz + wy;        e12 := yz - wx;        e22 := 1 - (xx + yy);

  e30 := pos.x;
  e31 := pos.y;
  e32 := pos.z;
  e03 := 0;
  e13 := 0;
  e23 := 0;
end;


procedure TMat4f.SetPos(v: TVec3f);
begin
  e30 := v.X;
  e31 := v.Y;
  e32 := v.Z;
  e33 := 1;
end;
{$ENDREGION}


Procedure generateNormalAndTangent( xv1, xv2 , xv3: TVec3f; xst1 , xst2, xst3 : TVec2f; var normal, tangent: TVec3f);
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

//		 binormal := v_cross(normal , tangent);
end;

// Построить вектор
function Vector(const X, Y, Z: single): TVec3f;
begin
Result.X := X;
Result.Y := Y;
Result.Z := Z;
end;
{
Function v_Clear: TVec3f;
asm
  mov [edx  ], 0
  mov [edx+4], 0
  mov [edx+8], 0
end;
}
procedure v_clear(var v: TVec3f);
asm
  XOR EDX, EDX
  MOV [EAX], EDX
  MOV [EAX+4], EDX
  MOV [EAX+8], EDX
end;

{------------------------------------------------------------------------------}
function v_Min(const v1,v2 : TVec3f): boolean;
begin
if (v1.X < v2.X) and
   (v1.Y < v2.Y) and
   (v1.Z < v2.Z) then result:=true else result:=false;
end;

Function VAABBMin(const V1,v2 : TVec3f): TVec3f;
begin
if (v1.x < v2.X) then result.x := v1.X else result.x := v2.X;
if (v1.y < v2.y) then result.y := v1.y else result.y := v2.y;
if (v1.z < v2.z) then result.z := v1.z else result.z := v2.z;
end;

Function VAABBMax(const V1,v2 : TVec3f): TVec3f;
begin
if (v1.x > v2.X) then result.x := v1.X else result.x := v2.X;
if (v1.y > v2.y) then result.y := v1.y else result.y := v2.y;
if (v1.z > v2.z) then result.z := v1.z else result.z := v2.z;
end;

function v_nan(const V,v2 : TVec3f): TVec3f;
begin
    asm
      mov [ecx  ], 0
      mov [ecx+4], 0
      mov [ecx+8], 0
    end;
if not isnan(v.x) then result.x :=v.x else result.x :=v2.x;
if not isnan(v.y) then result.y :=v.y else result.y :=v2.y;
if not isnan(v.z) then result.z :=v.z else result.z :=v2.z;
end;
{------------------------------------------------------------------------------}

function v_Sub(const V1, v2 : TVec3f): TVec3f; assembler; register;
{Result.X := V1.X-V2.X;
 Result.Y := V1.Y-V2.Y;
 Result.Z := V1.Z-V2.Z;}
asm
      FLD DWORD PTR [EAX]    // V1.X
      FSUB DWORD PTR [EDX]   // - V2.X
      FSTP DWORD PTR [ECX]   // Result :=
      FLD DWORD PTR [EAX + 4]
      FSUB DWORD PTR [EDX + 4]
      FSTP DWORD PTR [ECX + 4]
      FLD DWORD PTR [EAX + 8]
      FSUB DWORD PTR [EDX + 8]
      FSTP DWORD PTR [ECX + 8]
end;

function v_ADD(const V1, v2 : TVec3f): TVec3f; assembler; register;
{Result.X := V1.X+V2.X;
 Result.Y := V1.Y+V2.Y;
 Result.Z := V1.Z+V2.Z;}
asm

      FLD DWORD PTR [EAX]
      FADD DWORD PTR [EDX]
      FSTP DWORD PTR [ECX]
      FLD DWORD PTR [EAX + 4]
      FADD DWORD PTR [EDX + 4]
      FSTP DWORD PTR [ECX + 4]
      FLD DWORD PTR [EAX + 8]
      FADD DWORD PTR [EDX + 8]
      FSTP DWORD PTR [ECX + 8]
end;
function v_mult(const v: TVec3f; const D: Single): TVec3f;
{Result.X := V.X*D;
 Result.Y := V.Y*D;
 Result.Z := V.Z*D;}
asm
      FLD  DWORD PTR [EAX]
      FMUL DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX]
      FLD  DWORD PTR [EAX+4]
      FMUL DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX+4]
      FLD  DWORD PTR [EAX+8]
      FMUL DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX+8]
end;

function v_MultV(const v1, v2 : TVec3f): TVec3f; assembler; register;
{Result.X := A.X*B.X;
 Result.Y := A.Y*B.Y;
 Result.Z := A.Z*B.Z;}
asm
      FLD DWORD PTR [EAX]
      FMul DWORD PTR [EDX]
      FSTP DWORD PTR [ECX]
      FLD DWORD PTR [EAX + 4]
      FMul DWORD PTR [EDX + 4]
      FSTP DWORD PTR [ECX + 4]
      FLD DWORD PTR [EAX + 8]
      FMul DWORD PTR [EDX + 8]
      FSTP DWORD PTR [ECX + 8]
end;
function v_dot(const v1, v2 : TVec3f): Single;
// EAX contains address of V1 что то пробило меня на ремарки :D
// EDX contains address of V2
// ST(0) contains the result
{Result := v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;}
asm

      FLD DWORD PTR [EAX]
      FMUL DWORD PTR [EDX]
      FLD DWORD PTR [EAX + 4]
      FMUL DWORD PTR [EDX + 4]
      FADDP
      FLD DWORD PTR [EAX + 8]
      FMUL DWORD PTR [EDX + 8]
      FADDP
end;

function v_DivV(const v1, v2 : TVec3f): TVec3f; assembler; register;
{Result.X := A.X*B.X;
 Result.Y := A.Y*B.Y;
 Result.Z := A.Z*B.Z;}
asm
      FLD DWORD PTR [EAX]
      fdiv DWORD PTR [EDX]
      FSTP DWORD PTR [ECX]
      FLD DWORD PTR [EAX + 4]
      Fdiv DWORD PTR [EDX + 4]
      FSTP DWORD PTR [ECX + 4]
      FLD DWORD PTR [EAX + 8]
      Fdiv DWORD PTR [EDX + 8]
      FSTP DWORD PTR [ECX + 8]
end;

function v_Div(Const V: TVec3f;Const D:Single): TVec3f; assembler; register;
{if d=0 then exit;
 Result.X := V.X/D;
 Result.Y := V.Y/D;
 Result.Z := V.Z/D;}
asm
      mov [edx  ], 0
      mov [edx+4], 0
      mov [edx+8], 0
      cmp [ebp+8],0
          jz @@exit1

      FLD  DWORD PTR [EAX]
      Fdiv DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX]
      FLD  DWORD PTR [EAX+4]
      Fdiv DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX+4]
      FLD  DWORD PTR [EAX+8]
      Fdiv DWORD PTR [EBP+8]
      FSTP DWORD PTR [EDX+8]
 @@exit1:
end;

function v_Cross(Const V1, v2 : TVec3f): TVec3f; //Векторное произведение векторов
{Result.X := v1.Y * v2.Z - v1.Z * v2.Y;
 Result.Y := v1.Z * v2.X - v1.X * v2.Z;
 Result.Z := v1.X * v2.Y - v1.Y * v2.X;}
var Temp: TVec3f;
asm

      PUSH EBX                      // сохраняем EBX, всї должно бvть восстановлено в оригинальнуі величину
      LEA EBX, [Temp]
      FLD DWORD PTR [EDX + 8]       // Cперва загружаем все вектора в регистры FPU
      FLD DWORD PTR [EDX + 4]
      FLD DWORD PTR [EDX + 0]
      FLD DWORD PTR [EAX + 8]
      FLD DWORD PTR [EAX + 4]
      FLD DWORD PTR [EAX + 0]

      FLD ST(1)                     // ST(0) := V1.Y
      FMUL ST, ST(6)                // ST(0) := V1.Y * V2.Z
      FLD ST(3)                     // ST(0) := V1.Z
      FMUL ST, ST(6)                // ST(0) := V1.Z * V2.Y
      FSUBP ST(1), ST               // ST(0) := ST(1)-ST(0)
      FSTP DWORD [EBX]              // Temp.X := ST(0)
      FLD ST(2)                     // ST(0) := V1.Z
      FMUL ST, ST(4)                // ST(0) := V1.Z * V2.X
      FLD ST(1)                     // ST(0) := V1.X
      FMUL ST, ST(7)                // ST(0) := V1.X * V2.Z
      FSUBP ST(1), ST               // ST(0) := ST(1)-ST(0)
      FSTP DWORD [EBX + 4]          // Temp.Y := ST(0)
      FLD ST                        // ST(0) := V1.X
      FMUL ST, ST(5)                // ST(0) := V1.X * V2.Y
      FLD ST(2)                     // ST(0) := V1.Y
      FMUL ST, ST(5)                // ST(0) := V1.Y * V2.X
      FSUBP ST(1), ST               // ST(0) := ST(1)-ST(0)
      FSTP DWORD [EBX + 8]          // Temp.Z := ST(0)
      FSTP ST(0)                    // чистим регистры FPU
      FSTP ST(0)
      FSTP ST(0)
      FSTP ST(0)
      FSTP ST(0)
      FSTP ST(0)
      MOV EAX, [EBX]                // переносим всё с Temp в Result
      MOV [ECX], EAX
      MOV EAX, [EBX + 4]
      MOV [ECX + 4], EAX
      MOV EAX, [EBX + 8]
      MOV [ECX + 8], EAX
      POP EBX
end;
(* эх показываю вам два экземпляра второй быстрее ибо нет лопов
function v_Length(Const V: TVec3f): Single; assembler;
{Result := sqrt(sqr(v.X) + sqr(v.Y) + sqr(v.Z));}
asm
        mov edx, 2
        FLDZ
@@Loop: FLD  DWORD PTR [EAX  +  4 * EDX]
        FMUL ST, ST
        FADDP
        SUB  EDX, 1
        JNL  @@Loop
        FSQRT
end;
*)

function v_length(const v: TVec3f): Single;
// EAX contains address of V
// result is passed in ST(0)
{Result := sqrt(sqr(v.X) + sqr(v.Y) + sqr(v.Z));}
asm
      FLD  DWORD PTR [EAX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FMUL ST, ST
      FADDP
      FLD  DWORD PTR [EAX+8]
      FMUL ST, ST
      FADDP
      FSQRT
end;

function v_norm(const v: TVec3f): Single;
// EAX contains address of V
// result is passed in ST(0)
{Result := sqr(v.X) + sqr(v.Y) + sqr(v.Z);}
asm
      FLD  DWORD PTR [EAX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FMUL ST, ST
      FADDP
      FLD  DWORD PTR [EAX+8]
      FMUL ST, ST
      FADDP
end;

// Расстояние между двумя точками
function v_Dist(const v1, v2 : TVec3f): single;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
// Result := sqrt(sqr(v2.X - v1.X) + sqr(v2.Y - v1.Y) +sqr(v2.Z - v1.Z));
asm
      FLD  DWORD PTR [EAX]
      FSUB DWORD PTR [EDX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FSUB DWORD PTR [EDX+4]
      FMUL ST, ST
      FADD
      FLD  DWORD PTR [EAX+8]
      FSUB DWORD PTR [EDX+8]
      FMUL ST, ST
      FADD
      FSQRT
end;


// Квадрат расстояния между двумя точками
// Расстояние между двумя точками
function v_Distq(const v1, v2 : TVec3f): single;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
// Result := sqr(v2.X - v1.X) + sqr(v2.Y - v1.Y) +sqr(v2.Z - v1.Z);
asm
      FLD  DWORD PTR [EAX]
      FSUB DWORD PTR [EDX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FSUB DWORD PTR [EDX+4]
      FMUL ST, ST
      FADD
      FLD  DWORD PTR [EAX+8]
      FSUB DWORD PTR [EDX+8]
      FMUL ST, ST
      FADD
end;


function v_spacing(const v1, v2 : TVec3f): Single;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
// Result:=Abs(v2.x-v1.x)+Abs(v2.y-v1.y)+Abs(v2.z-v1.z);
asm
      FLD  DWORD PTR [EAX]
      FSUB DWORD PTR [EDX]
      FABS
      FLD  DWORD PTR [EAX+4]
      FSUB DWORD PTR [EDX+4]
      FABS
      FADD
      FLD  DWORD PTR [EAX+8]
      FSUB DWORD PTR [EDX+8]
      FABS
      FADD
end;

function v_combine(const v1, v2 : TVec3f; const scale : Single): TVec3f;
// EAX contains address of v1
// EDX contains address of v2
// EBP+8 contains address of scale
// ECX contains address of Result
asm
      FLD  DWORD PTR [EDX]
      FMUL DWORD PTR [EBP+8]
      FADD DWORD PTR [EAX]
      FSTP DWORD PTR [ECX]

      FLD  DWORD PTR [EDX+4]
      FMUL DWORD PTR [EBP+8]
      FADD DWORD PTR [EAX+4]
      FSTP DWORD PTR [ECX+4]

      FLD  DWORD PTR [EDX+8]
      FMUL DWORD PTR [EBP+8]
      FADD DWORD PTR [EAX+8]
      FSTP DWORD PTR [ECX+8]
end;

function v_Normalize(const v: TVec3f): TVec3f;
// EAX contains address of V1
// EDX contains the result
{
var s : Extended;
begin
s :=  1 / sqrt(sqr(v.X) + sqr(v.Y) + sqr(v.Z));

Result.x := v.x * s;
Result.y := v.y * s;
Result.z := v.z * s;
end;
}
asm
      // V_Length
      FLD  DWORD PTR [EAX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FMUL ST, ST
      FADD
      FLD  DWORD PTR [EAX+8]
      FMUL ST, ST
      FADD
      FSQRT
      // if V_length(v) = 0 then jump to exit;
      // push eax
      mov ecx , eax // незделаем это хана умножению :)
      FTST
      FSTSW AX
      Sahf
      mov eax , ecx
      // pop eax
      jz @@Exit

      // V_Mult
      FLD1
      FDIVR
      FLD  ST
      FMUL DWORD PTR [EAX]
      FSTP DWORD PTR [EDX]
      FLD  ST
      FMUL DWORD PTR [EAX+4]
      FSTP DWORD PTR [EDX+4]
      FMUL DWORD PTR [EAX+8]
      FSTP DWORD PTR [EDX+8]

      jmp @@exit2

      @@Exit:
      //result:=vector(0,0,0);
      FST  DWORD PTR [EDX]
      FST  DWORD PTR [EDX+4]
      FSTP DWORD PTR [EDX+8]
      @@exit2:
end;

function v_Angle2(const V1, v2 : TVec3f): Single;  //Скалярное произведение векторов
// Result = v_Dot(V1, V2) / (v_Length(V1) * v_Length(V2))
asm
      FLD DWORD PTR [EAX]           // V1.x
      FLD ST                        // double V1.x
      FMUL ST, ST                   // V1.x^2 (prep. for divisor)
      FLD DWORD PTR [EDX]           // V2.x
      FMUL ST(2), ST                // ST(2) := V1.x * V2.x
      FMUL ST, ST                   // V2.x^2 (prep. for divisor)
      FLD DWORD PTR [EAX + 4]       // V1.y
      FLD ST                        // double V1.y
      FMUL ST, ST                   // ST(0) := V1.y^2
      FADDP ST(3), ST               // ST(2) := V1.x^2 + V1.y *  * 2
      FLD DWORD PTR [EDX + 4]       // V2.y
      FMUL ST(1), ST                // ST(1) := V1.y * V2.y
      FMUL ST, ST                   // ST(0) := V2.y^2
      FADDP ST(2), ST               // ST(1) := V2.x^2 + V2.y^2
      FADDP ST(3), ST               // ST(2) := V1.x * V2.x + V1.y * V2.y
      FLD DWORD PTR [EAX + 8]       // load V2.y
      FLD ST                        // same calcs go here
      FMUL ST, ST                   // (compare above)
      FADDP ST(3), ST
      FLD DWORD PTR [EDX + 8]
      FMUL ST(1), ST
      FMUL ST, ST
      FADDP ST(2), ST
      FADDP ST(3), ST
      FMULP                         // ST(0) := (V1.x^2 + V1.y^2 + V1.z) *
                                    //          (V2.x^2 + V2.y^2 + V2.z)
      FSQRT                         // sqrt(ST(0))
      FDIVP                         // ST(0) := Result := ST(1) / ST(0)
                                    // the result is expected in ST(0), if it's invalid, an error is raised
end;

function v_Reflect(const V, N: TVec3f): TVec3f;
  {     Dot := v_Dot(V, N);
   Result.X := V.X-2 * Dot * N.X;
   Result.Y := V.Y-2 * Dot * N.Y;
   Result.Z := V.Z-2 * Dot * N.Z;}
asm
      CALL v_Dot                    // dot is now in ST(0)
      FCHS                          // -dot
      FADD ST, ST                   // -dot * 2
      FLD DWORD PTR [EDX]           // ST := N.x
      FMUL ST, ST(1)                // ST := -2 * dot * N.x
      FADD DWORD PTR[EAX]           // ST := V.x - 2 * dot * N.x
      FSTP DWORD PTR [ECX]          // store result
      FLD DWORD PTR [EDX + 4]       // etc.
      FMUL ST, ST(1)
      FADD DWORD PTR[EAX + 4]
      FSTP DWORD PTR [ECX + 4]
      FLD DWORD PTR [EDX + 8]
      FMUL ST, ST(1)
      FADD DWORD PTR[EAX + 8]
      FSTP DWORD PTR [ECX + 8]
      FSTP ST                       // clean FPU stack
end;

Function v_Negate(const V: TVec3f): TVec3f;
 {V.X := -V.X;
  V.Y := -V.Y;
  V.Z := -V.Z;}
asm
  FLD DWORD PTR [EAX]
  FCHS // WAIT
  FSTP DWORD PTR [EDX]
  FLD DWORD PTR [EAX+4]
  FCHS // WAIT
  FSTP DWORD PTR [EDX+4]
  FLD DWORD PTR [EAX+8]
  FCHS // WAIT
  FSTP DWORD PTR [EDX+8]
end;

function v_normalizesafe(const inv: TVec3f; out outv: TVec3f): Single;
var len: Single;
begin
  len := v_length(inv);
  if len = 0 then
  begin
    outv := v_Identity;
    Result := 0;
    Exit;
  end;

  Result := len;
  len    := 1/len;
  outv   := v_mult(inv,len);
end;

function v_Angle(const v1, v2 : TVec3f) : real;
{Result := ArcCos(v_Dot( v_Normalize(v1), v_Normalize(v2)));}
var
  Dot,VectorsMagnitude : Single;
begin
  Dot := v_Dot(v1,v2);
  VectorsMagnitude := v_Length(v1) * v_Length(v2);
 if Dot>=VectorsMagnitude then Result:=0 else Result := arccos( Dot / VectorsMagnitude );
end;


Function V_RadAngleY(const V1 , V2 : TVec3f):Single;
var
Angle,
 p : TVec3f;

begin
// Угол отсносительно Y
if v_dist(V1,V2)<1 then exit;
p.X := V2.X - V1.X;
p.Y := 0;
p.Z := V2.Z - V1.Z;
Angle.Y := V_Angle(Vector(1, 0, 0), p);
if p.Z < 0 then Angle.Y := 2 * pi - Angle.Y;
if (Angle.Y) > pi then Angle.Y := Angle.Y + pi * 2;

// Угол относительно X
p.Y := V2.Y - V1.Y;
Angle.X := V_Angle(Vector(p.X, 0, p.Z), p);
if p.Y < 0 then Angle.X := 2 * pi - Angle.X;
if (Angle.X) > pi then Angle.X := Angle.X + pi * 2;
end;


function v_Interpolate(const v1, v2 : TVec3f; const k: single): TVec3f;
var x:single;
begin
     x := 1/k;
Result := v_add(v1 , v_mult(v_sub(v2,v1),x));
end;

Function v_RotateX(const V : TVec3f; const ang : Single): TVec3f;
var
  radAng : Single;
begin
  radAng := ang * DEG2RAD;

  Result.x := v.x;
  Result.y := (v.y * cos(radAng)) - (v.z * sin(radAng));
  Result.z := (v.y * sin(radAng)) + (v.z * cos(radAng));
end;

Function v_RotateY(const V : TVec3f; const ang : Single): TVec3f;
var
  radAng : Single;
begin
  radAng := ang * DEG2RAD;

  Result.x := (v.x * cos(radAng)) - (v.z * sin(radAng));
  Result.y :=  v.y;
  Result.z := (v.z * sin(radAng)) + (v.x * cos(radAng));
end;

Function v_RotateZ(const V : TVec3f; const ang : Single): TVec3f;
var
  radAng : Single;
begin
  radAng := ang * DEG2RAD;

  Result.x := (v.x * cos(radAng)) - (v.y * sin(radAng));
  Result.y := (v.y * sin(radAng)) + (v.x * cos(radAng));
  Result.z :=  v.z;
end;

function v_Rotate(const V,Rot: TVec3f): TVec3f;
var
  radAng : Single;
  Ran    : array [0..2] of TVec2f;
  R      : TVec3f;
begin
//Такая форма записи хорошая но увы медленная
{ Result := v_RotateZ(v_RotateY(v_RotateX(V,Rot.x),rot.y),rot.z);}
  radAng   := Rot.x * DEG2RAD;  Ran[0].x := cos(radAng);  Ran[0].Y := sin(radang);
  radAng   := Rot.y * DEG2RAD;  Ran[1].x := cos(radAng);  Ran[1].Y := sin(radang);
  radAng   := Rot.z * DEG2RAD;  Ran[2].x := cos(radAng);  Ran[2].Y := sin(radang);

  R   := V;
  // Rotate X
  R.y := (r.y * Ran[0].x) - (r.z * Ran[0].y);
  R.z := (r.y * Ran[0].y) + (r.z * Ran[0].x);
  // Rotate Y
  R.x := (r.x * Ran[1].x) - (r.z * Ran[1].y);
  R.z := (r.z * Ran[1].y) + (r.x * Ran[1].x);
  // Rotate Z
  R.x := (r.x * Ran[2].x) - (r.y * Ran[2].y);
  R.y := (r.y * Ran[2].y) + (r.x * Ran[2].x);
  Result:=r;

end;

// 2D Vector's
function Vector2D(const X, Y: single): TVec2f;
begin
Result.X := X;
Result.Y := Y;
end;

Function V_add2d(V,v2:TVec2f):TVec2f;
begin
  Result.x := v.x + v2.x;
  Result.y := v.y + v2.y;
end;

Function V_sub2d(V,v2:TVec2f):TVec2f;
begin
  Result.x := v.x - v2.x;
  Result.y := v.y - v2.y;
end;

Function V_Length2d(V:TVec2f):Single;
begin
  Result := sqrt(sqr(v.X) + sqr(v.Y));
end;

function v_Rotate2D(const v: TVec2f; const ang: single): TVec2f;
var
 l : single;
begin
l := sqrt(sqr(v.X) + sqr(v.Y));
  Result.X := cos(ang) * l;
  Result.Y := sin(ang) * l;
end;


// Plane
function P_Normal(const v1, v2, v3: TVec3f): TVec3f;
begin
Result := v_Normalize( v_Cross( v_Sub(v3, v1), v_Sub(v2, v1) )) ;
end;

function P_Plane(const v1, v2, v3: TVec3f): TPlane;
begin
Result.Normal := P_Normal(v1, v2, v3);
Result.D      := -v_Dot(Result.Normal, v1);
Result.V      := v1;
end;

function P_Plane2(const Normal,v1: TVec3f): TPlane;
begin
result.Normal := Normal;
result.d      := -v_Dot(Normal, v1);
Result.V      := v1;
end;

function P_Dist(const Pos: TVec3f; const Plane: TPlane): single;
begin
Result := (v_Dot(Plane.Normal, Pos) + Plane.D);
end;

function P_Classify(const plane: TPlane; const p: TVec3f): Single;
begin
Result := Plane.Normal.X * (p.x - plane.V.x) + Plane.Normal.Y * (p.y - plane.V.y) + Plane.Normal.Z * (p.z - plane.V.z);
//Result := v_Dot(Plane.Normal, v_Sub(Pos, Plane.V));
end;

function p_evaluate(const plane: TPlane; const p: TVec3f): Single; register;
// EAX contains address of plane
// EDX contains address of point
// result is stored in ST(0)
asm
  FLD DWORD PTR [EAX]
  FMUL DWORD PTR [EDX]
  FLD DWORD PTR [EAX + 4]
  FMUL DWORD PTR [EDX + 4]
  FADDP
  FLD DWORD PTR [EAX + 8]
  FMUL DWORD PTR [EDX + 8]
  FADDP
  FLD DWORD PTR [EAX + 16]
  FADDP
end;

function p_offset(const Plane: TPlane; const Pos: TVec3f): TPlane;
begin
  Result.Normal := Plane.Normal;
  Result.D := -(Plane.D + v_dot(Plane.Normal, Pos));
end;

function P_Angle(const V1, V2, V3: TVec3f): Single;
var v,vv:TVec3f;
begin
  V:=V_Sub(V1, V2);
  Vv:=V_Sub(V1, V3);
  Result:=arccos(V_Dot(V, Vv)/(V_length(V)*V_Length(Vv)));
end;

Function  P_Intersection(const plane: TPlane; const LineStart, LineEnd: TVec3f): boolean;
var
	Sign , Sign1 : Single;
begin
	sign  := P_Dist( LineStart , plane);
	sign1 := P_Dist( LineEnd   , plane);
	result := ( ((sign < 0) and (sign1 > 0)) or ((sign > 0) and (sign1 <=0)) );
end;

Function  P_GetIntersection(const plane: TPlane; const LineStart, LineEnd: TVec3f): TVec3f;
var
  ptDirection : TVec3f;
  denominator : single;
  D           : single;
begin
	ptDirection := v_sub( LineEnd, LineStart );
	denominator := v_Dot( plane.Normal, ptDirection );
        Result:=LineEnd;

	if denominator = 0 then exit;

	D := ( plane.D - v_Dot( plane.normal, LineStart )) / denominator;
	ptDirection := v_mult( ptDirection,  D);
	result      := v_add(LineStart, ptDirection);
end;

Function P_Determine(const Normal: TVec3f): integer; //0 - Xy, 1 - Yz, 2- xZ
begin
  Result := -1;
  if (abs(Normal.x) >= abs(Normal.y)) and (abs(Normal.x) >= abs(normal.z)) then  Result := 1; //YZ plane
  if (abs(Normal.y) >= abs(Normal.x)) and (abs(Normal.y) >= abs(normal.z)) then  Result := 2; //XZ Plane
  if (abs(Normal.z) >= abs(Normal.x)) and (abs(Normal.z) >= abs(normal.y)) then  Result := 0; //XY Plane

end;


function P_InsideTri(const v, v1, v2, v3: TVec3f): boolean;
var
 i      : Integer;
 Angle  : Double;
 vec    : array [0..2] of TVec3f;
begin
Result := False;
vec[0] := v_Sub(v1, v);
vec[1] := v_Sub(v2, v);
vec[2] := v_Sub(v3, v);
Angle := 0;
for i := 0 to 2 do
 Angle := Angle + v_Angle(vec[i], vec[(i + 1) mod 3]);
	if(Angle >= M_angle )	then
 Result := true;
end;

////////////////////////////////////////////////////////////////////////////////

// 3D Vector's & Martix's
//------------------------------------------------------------------------------
// QUATERNION ROUTINES
//------------------------------------------------------------------------------
function Quaternion(const X, Y, Z, W: single): TQuat;
begin
Result.ImagPart.X := X;
Result.ImagPart.Y := Y;
Result.ImagPart.Z := Z;
Result.RealPart   := W;
end;

function Q_Matrix(const q: TQuat): TMat4f;
var
 wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2 : single;
 m : TMat4f;
begin
with q.ImagPart do
 begin
 x2 := x + x;   y2 := y + y;   z2 := z + z;
 xx := x * x2;  xy := x * y2;  xz := x * z2;
 yy := y * y2;  yz := y * z2;  zz := z * z2;
 end;

 wx := q.RealPart * x2;  wy := q.RealPart * y2;  wz := q.RealPart * z2;

m.cell[0][0] := 1 - (yy + zz);  m.cell[0][1] := xy + wz;        m.cell[0][2] := xz - wy;
m.cell[1][0] := xy - wz;        m.cell[1][1] := 1 - (xx + zz);  m.cell[1][2] := yz + wx;
m.cell[2][0] := xz + wy;        m.cell[2][1] := yz - wx;        m.cell[2][2] := 1 - (xx + yy);

m.cell[0][3] := 0;
m.cell[1][3] := 0;
m.cell[2][3] := 0;
m.cell[3][0] := 0;
m.cell[3][1] := 0;
m.cell[3][2] := 0;
m.cell[3][3] := 1;
result  := m;
end;

function q_Magnitude(const Quat: TQuat): Single;
begin
  Result := Sqrt(v_dot(Quat.ImagPart, Quat.ImagPart) + Sqr(Quat.RealPart));
end;

function q_Normalize(const Quat: TQuat):TQuat;
var m, f: Single;
begin
  m := q_Magnitude(Quat);

  if m > EPSILON_30 then
  begin
    f := 1 / m;
    Result.ImagPart := v_mult(Quat.ImagPart, f);
    Result.RealPart := Quat.RealPart * f;
  end
  else
    Result := Q_Identity;
end;

function Q_Mult(const qL, qR: TQuat): TQuat;
var Temp : TQuat;
begin
  Temp.RealPart := qL.RealPart * qR.RealPart - qL.ImagPart.x * qR.ImagPart.x -
                   qL.ImagPart.y * qR.ImagPart.y - qL.ImagPart.z * qR.ImagPart.z;
  Temp.ImagPart.x := qL.RealPart * qR.ImagPart.x + qL.ImagPart.x * qR.RealPart +
                      qL.ImagPart.y * qR.ImagPart.z - qL.ImagPart.z * qR.ImagPart.y;
  Temp.ImagPart.y := qL.RealPart * qR.ImagPart.y + qL.ImagPart.y * qR.RealPart +
                      qL.ImagPart.z * qR.ImagPart.x - qL.ImagPart.x * qR.ImagPart.z;
  Temp.ImagPart.z := qL.RealPart * qR.ImagPart.z + qL.ImagPart.z * qR.RealPart +
                      qL.ImagPart.x * qR.ImagPart.y - qL.ImagPart.y * qR.ImagPart.x;
  Result := Temp;
end;

function Q_ToMatrix(const Q: TQuat): TMat4f;
// Constructs rotation matrix from (possibly non-unit) quaternion.
// Assumes matrix is used to multiply column vector on the left:
// vnew = mat vold.  Works correctly for right-handed coordinate system
// and right-handed rotations.
var
  V : TVec3f;
  SinA, CosA,
  A, B, C: Single;

begin
  V := Q.ImagPart;
  V := V_Normalize(V);
  SinCos(Q.RealPart / 2, SinA, CosA);
  A := V.x * SinA;
  B := V.y * SinA;
  C := V.z * SinA;

  Result.Identity;
  Result.cell[0, 0] := 1 - 2 * B * B - 2 * C * C;
  Result.cell[0, 1] := 2 * A * B - 2 * CosA * C;
  Result.cell[0, 2] := 2 * A * C + 2 * CosA * B;

  Result.cell[1, 0] := 2 * A * B + 2 * CosA * C;
  Result.cell[1, 1] := 1 - 2 * A * A - 2 * C * C;
  Result.cell[1, 2] := 2 * B * C - 2 * CosA * A;

  Result.cell[2, 0] := 2 * A * C - 2 * CosA * B;
  Result.cell[2, 1] := 2 * B * C + 2 * CosA * A;
  Result.cell[2, 2] := 1 - 2 * A * A - 2 * B * B;
end;

function Q_FromVector(const v: TVec3f; const Angle: single): TQuat;
var
 s, c : single;
begin
c := Angle*0.5;
s := sin(c);
Result.ImagPart.X := v.X * s;
Result.ImagPart.Y := v.Y * s;
Result.ImagPart.Z := v.Z * s;
Result.RealPart   := cos(c);
end;

function Q_FromPoints(const V1, V2: TVec3f): TQuat;
// constructs a unit quaternion from two points on unit sphere
// EAX contains address of V1
// ECX contains address to result
// EDX contains address of V2
asm
  {Result.ImagPart := V_Cross(V1, V2);
   Result.RealPart :=  Sqrt((V_Dot(V1, V2) + 1)/2);}
              PUSH EAX
              CALL V_Cross                  // determine axis to rotate about
              POP EAX
              FLD1                          // prepare next calculation
              Call V_Dot                    // calculate cos(angle between V1 and V2)
              FADD ST, ST(1)                // transform angle to angle/2 by: cos(a/2)=sqrt((1 + cos(a))/2)
              FXCH ST(1)
              FADD ST, ST
              FDIVP ST(1), ST
              FSQRT
              FSTP DWORD PTR [ECX + 12]     // Result.RealPart := ST(0)
end;

function Q_interpolate(const QStart, QEnd: TQuat; const Spin: Integer; const tx: Single): TQuat;

// spherical linear interpolation of unit quaternions with spins
// QStart, QEnd - start and end unit quaternions
// t            - interpolation parameter (0 to 1)
// Spin         - number of extra spin rotations to involve

var beta,                   // complementary interp parameter
    theta,                  // Angle between A and B
    sint, cost,             // sine, cosine of theta
    phi,t: Single;            // theta plus spins
    bflip: Boolean;         // use negativ t?


begin
  // cosine theta
  cost := V_Angle(QStart.ImagPart, QEnd.ImagPart);
  t    :=tx;

  // if QEnd is on opposite hemisphere from QStart, use -QEnd instead
  if cost < 0 then
  begin
    cost := -cost;
    bflip := True;
  end
  else bflip := False;

  // if QEnd is (within precision limits) the same as QStart,
  // just linear interpolate between QStart and QEnd.
  // Can't do spins, since we don't know what direction to spin.

  if (1 - cost) < EPSILON then beta := 1 - t
                          else
  begin
    // normal case
    theta := arccos(cost);
    phi := theta + Spin * Pi;
    sint := sin(theta);
    beta := sin(theta - t * phi) / sint;
    t := sin(t * phi) / sint;
  end;

  if bflip then t := -t;

  // interpolate
  Result.ImagPart.X := beta * QStart.ImagPart.X + t * QEnd.ImagPart.X;
  Result.ImagPart.Y := beta * QStart.ImagPart.Y + t * QEnd.ImagPart.Y;
  Result.ImagPart.Z := beta * QStart.ImagPart.Z + t * QEnd.ImagPart.Z;
  Result.RealPart := beta * QStart.RealPart + t * QEnd.RealPart;
end;

////////////////////////////////////////////////////////////////////////////////

function M_MultV(const m: TMat4f; const v: TVec3f): TVec3f;
begin
Result.X := m.cell[0, 0] * v.X + m.cell[1, 0] * v.Y + m.cell[2, 0] * v.Z + m.cell[3, 0];
Result.Y := m.cell[0, 1] * v.X + m.cell[1, 1] * v.Y + m.cell[2, 1] * v.Z + m.cell[3, 1];
Result.Z := m.cell[0, 2] * v.X + m.cell[1, 2] * v.Y + m.cell[2, 2] * v.Z + m.cell[3, 2];
end;

function M_Rotation(const v: TVec3f; const Angle: single): TMat4f;
var
 s, c, inv_c : single;
begin
s := sin(Angle);
c := cos(Angle);
inv_c := 1 - c;

Result.cell[0][0] := (inv_c * v.X * v.X) + c;
Result.cell[0][1] := (inv_c * v.X * v.Y) - (v.Z * s);
Result.cell[0][2] := (inv_c * v.Z * v.X) + (v.Y * s);

Result.cell[1][0] := (inv_c * v.X * v.Y) + (v.Z * s);
Result.cell[1][1] := (inv_c * v.Y * v.Y) + c;
Result.cell[1][2] := (inv_c * v.Y * v.Z) - (v.X * s);

Result.cell[2][0] := (inv_c * v.Z * v.X) - (v.Y * s);
Result.cell[2][1] := (inv_c * v.Y * v.Z) + (v.X * s);
Result.cell[2][2] := (inv_c * v.Z * v.Z) + c;

Result.cell[3, 0] := 0;
Result.cell[3, 1] := 0;
Result.cell[3, 2] := 0;
Result.cell[0, 3] := 0;
Result.cell[1, 3] := 0;
Result.cell[2, 3] := 0;
Result.cell[3, 3] := 1;
end;

//------------------------------------------------------------------------------
// MATRIX ROUTINES
//------------------------------------------------------------------------------
function m_transpose(const M: TMat4f): TMat4f;
var
  f : Single;
begin
  f:=M.cell[0, 1]; Result.cell[0, 1]:=M.cell[1, 0]; Result.cell[1, 0]:=f;
  f:=M.cell[0, 2]; Result.cell[0, 2]:=M.cell[2, 0]; Result.cell[2, 0]:=f;
  f:=M.cell[0, 3]; Result.cell[0, 3]:=M.cell[3, 0]; Result.cell[3, 0]:=f;
  f:=M.cell[1, 2]; Result.cell[1, 2]:=M.cell[2, 1]; Result.cell[2, 1]:=f;
  f:=M.cell[1, 3]; Result.cell[1, 3]:=M.cell[3, 1]; Result.cell[3, 1]:=f;
  f:=M.cell[2, 3]; Result.cell[2, 3]:=M.cell[3, 2]; Result.cell[3, 2]:=f;
end;

function m_FromQuaternion(const Q: TQuat): TMat4f;
var
  x, y, z, w, xx, xy, xz, xw, yy, yz, yw, zz, zw: Single;
  Quat: TQuat;
begin
  Quat := q_Normalize(q);

  x := Quat.ImagPart.x;
  y := Quat.ImagPart.y;
  z := Quat.ImagPart.z;
  w := Quat.RealPart;

  xx := x * x;
  xy := x * y;
  xz := x * z;
  xw := x * w;
  yy := y * y;
  yz := y * z;
  yw := y * w;
  zz := z * z;
  zw := z * w;

  Result.cell[0, 0] := 1 - 2 * ( yy + zz );
  Result.cell[1, 0] :=     2 * ( xy - zw );
  Result.cell[2, 0] :=     2 * ( xz + yw );
  Result.cell[3, 0] := 0;
  Result.cell[0, 1] :=     2 * ( xy + zw );
  Result.cell[1, 1] := 1 - 2 * ( xx + zz );
  Result.cell[2, 1] :=     2 * ( yz - xw );
  Result.cell[3, 1] := 0;
  Result.cell[0, 2] :=     2 * ( xz - yw );
  Result.cell[1, 2] :=     2 * ( yz + xw );
  Result.cell[2, 2] := 1 - 2 * ( xx + yy );
  Result.cell[3, 2] := 0;
  Result.cell[0, 3] := 0;
  Result.cell[1, 3] := 0;
  Result.cell[2, 3] := 0;
  Result.cell[3, 3] := 1;
end;

function m_SetTranslation(const M: TMat4f; const Translation: TVec3f): TMat4f;
begin
  Result       :=M;
  Result.cell[3, 0] := Translation.x;
  Result.cell[3, 1] := Translation.y;
  Result.cell[3, 2] := Translation.z;
end;

function m_TransformVector(const V: TVec3f; const M: TMat4f): TVec3f;
begin
  Result.x:=V.x * M.cell[0, 0] + V.y * M.cell[1, 0] + V.z * M.cell[2, 0] + M.cell[3, 0];
  Result.y:=V.x * M.cell[0, 1] + V.y * M.cell[1, 1] + V.z * M.cell[2, 1] + M.cell[3, 1];
  Result.z:=V.x * M.cell[0, 2] + V.y * M.cell[1, 2] + V.z * M.cell[2, 2] + M.cell[3, 2];
end;

function m_CreateRotationMatrix(const Angles: TVec3f): TMat4f;
var cx, sx, cy, sy, cz, sz: Single;
begin
  SinCos(angles.x, sx, cx);
  SinCos(angles.y, sy, cy);
  SinCos(angles.z, sz, cz);

  Result.cell[0, 0] := cy * cz;
  Result.cell[0, 1] := cy * sz;
  Result.cell[0, 2] :=-sy;
  Result.cell[0, 3] := 0;

  Result.cell[1, 0] := sx * sy * cz - cx * sz;
  Result.cell[1, 1] := sx * sy * sz + cx * cz;
  Result.cell[1, 2] := sx * cy;
  Result.cell[1, 3] := 0;

  Result.cell[2, 0] := cx * sy * cz + sx * sz;
  Result.cell[2, 1] := cx * sy * sz - sx * cz;
  Result.cell[2, 2] := cx * cy;
  Result.cell[2, 3] := 0;

  Result.cell[3, 0] := 0;
  Result.cell[3, 1] := 0;
  Result.cell[3, 2] := 0;
  Result.cell[3, 3] := 1;
end;

function m_CreateRotationMatrixX(const Angle: Single): TMat4f;
var sine, cosine: Single;
begin
  SinCos(Angle, sine, cosine);

  Result.cell[0, 0] := 1;
  Result.cell[0, 1] := 0;
  Result.cell[0, 2] := 0;
  Result.cell[0, 3] := 0;

  Result.cell[1, 0] := 0;
  Result.cell[1, 1] := cosine;
  Result.cell[1, 2] := sine;
  Result.cell[1, 3] := 0;

  Result.cell[2, 0] := 0;
  Result.cell[2, 1] := -sine;
  Result.cell[2, 2] := cosine;
  Result.cell[2, 3] := 0;

  Result.cell[3, 0] := 0;
  Result.cell[3, 1] := 0;
  Result.cell[3, 2] := 0;
  Result.cell[3, 3] := 1;
end;

function m_CreateRotationMatrixY(const Angle: Single): TMat4f;
var sine, cosine: Single;
begin
  SinCos(Angle, sine, cosine);

  Result.cell[0, 0] := cosine;
  Result.cell[0, 1] := 0;
  Result.cell[0, 2] := -sine;
  Result.cell[0, 3] := 0;

  Result.cell[1, 0] := 0;
  Result.cell[1, 1] := 1;
  Result.cell[1, 2] := 0;
  Result.cell[1, 3] := 0;

  Result.cell[2, 0] := sine;
  Result.cell[2, 1] := 0;
  Result.cell[2, 2] := cosine;
  Result.cell[2, 3] := 0;

  Result.cell[3, 0] := 0;
  Result.cell[3, 1] := 0;
  Result.cell[3, 2] := 0;
  Result.cell[3, 3] := 1;
end;

function m_CreateRotationMatrixZ(const Angle: Single): TMat4f;
var sine, cosine: Single;
begin
  SinCos(Angle, sine, cosine);

  Result.cell[0, 0] := cosine;
  Result.cell[0, 1] := sine;
  Result.cell[0, 2] := 0;
  Result.cell[0, 3] := 0;

  Result.cell[1, 0] := -sine;
  Result.cell[1, 1] := cosine;
  Result.cell[1, 2] := 0;
  Result.cell[1, 3] := 0;

  Result.cell[2, 0] := 0;
  Result.cell[2, 1] := 0;
  Result.cell[2, 2] := 1;
  Result.cell[2, 3] := 0;

  Result.cell[3, 0] := 0;
  Result.cell[3, 1] := 0;
  Result.cell[3, 2] := 0;
  Result.cell[3, 3] := 1;
end;

function m_CreateScaleMatrix(const Scale: Single): TMat4f; overload;
begin
  Result.Identity;

  Result.cell[0, 0] := Scale;
  Result.cell[1, 1] := Scale;
  Result.cell[2, 2] := Scale;
end;

function m_CreateScaleMatrix(const Scale: TVec3f): TMat4f; overload;
begin
  Result.Identity;

  Result.cell[0, 0] := Scale.x;
  Result.cell[1, 1] := Scale.y;
  Result.cell[2, 2] := Scale.z;
end;

function M_DetInternal(const a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
// internal version for the determinant of a 3x3 matrix
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;

//----------------------------------------------------------------------------------------------------------------------

Function M_Adjoint(const M: TMat4f): TMat4f;
// Adjoint of a 4x4 matrix - used in the computation of the inverse
// of a 4x4 matrix
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: Single;
begin
    a1 :=  M.cell[0, 0]; b1 :=  M.cell[0, 1];
    c1 :=  M.cell[0, 2]; d1 :=  M.cell[0, 3];
    a2 :=  M.cell[1, 0]; b2 :=  M.cell[1, 1];
    c2 :=  M.cell[1, 2]; d2 :=  M.cell[1, 3];
    a3 :=  M.cell[2, 0]; b3 :=  M.cell[2, 1];
    c3 :=  M.cell[2, 2]; d3 :=  M.cell[2, 3];
    a4 :=  M.cell[3, 0]; b4 :=  M.cell[3, 1];
    c4 :=  M.cell[3, 2]; d4 :=  M.cell[3, 3];
    //)---</
    Result.cell[0, 0] :=  M_DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    Result.cell[1, 0] := -M_DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    Result.cell[2, 0] :=  M_DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    Result.cell[3, 0] := -M_DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);

    Result.cell[0, 1] := -M_DetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    Result.cell[1, 1] :=  M_DetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    Result.cell[2, 1] := -M_DetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    Result.cell[3, 1] :=  M_DetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);

    Result.cell[0, 2] :=  M_DetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    Result.cell[1, 2] := -M_DetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    Result.cell[2, 2] :=  M_DetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    Result.cell[3, 2] := -M_DetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);

    Result.cell[0, 3] := -M_DetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);
    Result.cell[1, 3] :=  M_DetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);
    Result.cell[2, 3] := -M_DetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);
    Result.cell[3, 3] :=  M_DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;

//----------------------------------------------------------------------------------------------------------------------

function M_Determinant(const M: TMat4f): Single;

// Determinant of a 4x4 matrix

var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : Single;

begin
  a1 := M.cell[0, 0];  b1 := M.cell[0, 1];  c1 := M.cell[0, 2];  d1 := M.cell[0, 3];
  a2 := M.cell[1, 0];  b2 := M.cell[1, 1];  c2 := M.cell[1, 2];  d2 := M.cell[1, 3];
  a3 := M.cell[2, 0];  b3 := M.cell[2, 1];  c3 := M.cell[2, 2];  d3 := M.cell[2, 3];
  a4 := M.cell[3, 0];  b4 := M.cell[3, 1];  c4 := M.cell[3, 2];  d4 := M.cell[3, 3];

  Result := a1 * M_DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * M_DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * M_DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * M_DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;

//----------------------------------------------------------------------------------------------------------------------

Function M_Scale(const M: TMat4f; const Factor: Single): TMat4f; register;
// multiplies all elements of a 4x4 matrix with a factor
var I, J: Integer;
begin
  for I := 0 to 3 do
    for J := 0 to 3 do Result.cell[I, J] := M.cell[I, J] * Factor;
end;


Procedure CreateRotationMatrix(var Result:TMat4f; const Angles, Position: TVec3f);
var cx, sx, cy, sy, cz, sz: Single;
  //  Result : TMat4f;
begin
  SinCos(angles.x * deg2rad, sx, cx);
  SinCos(angles.y * deg2rad, sy, cy);
  SinCos(angles.z * deg2rad, sz, cz);

  Result.cell[0, 0] := cy * cz;
  Result.cell[0, 1] := cy * sz;
  Result.cell[0, 2] :=-sy;
  Result.cell[0, 3] := 0;

  Result.cell[1, 0] := sx * sy * cz - cx * sz;
  Result.cell[1, 1] := sx * sy * sz + cx * cz;
  Result.cell[1, 2] := sx * cy;
  Result.cell[1, 3] := 0;

  Result.cell[2, 0] := cx * sy * cz + sx * sz;
  Result.cell[2, 1] := cx * sy * sz - sx * cz;
  Result.cell[2, 2] := cx * cy;
  Result.cell[2, 3] := 0;

  Result.cell[3, 0] := position.x;
  Result.cell[3, 1] := position.y;
  Result.cell[3, 2] := position.z;
  Result.cell[3, 3] := 1;
//  R:=Result;
end;
////////////
////////////////////////////////////////////////////////////////////////////////

function ClosestPointOnLine(const vA, vB, Point: TVec3f): TVec3f;
var
 Vector1, Vector2, Vector3: TVec3f;
 d, t: double;
begin
Vector1 := v_Sub(Point, vA);
Vector2 := v_Normalize(v_Sub(vB, vA));
d := v_Dist(vA, vB);
t := v_Dot(Vector2, Vector1);

if t <= 0 then
 begin
 Result := vA;
 Exit;
 end;

if t >= d then
 begin
 Result := vB;
 Exit;
 end;

Vector3 := v_Mult(Vector2, t);
Result := v_Add(vA, Vector3);
end;

function EdgeSphereCollision(const Center,v1, v2, v3: TVec3f; const Radius: Single): Boolean;
var i: Integer;
    Point: TVec3f;
    Distance: Single;
 v : array [0..2] of TVec3f;
begin
v[0] := v1;
v[1] := v2;
v[2] := v3;
for i := 0 to 2 do
 begin
 Point := ClosestPointOnLine(v[i], v[(i + 1) mod 3], Center);
 Distance := v_Dist(Point, Center);
 if Distance < Radius then
  begin
  Result := true;
  Exit;
  end;
 end;
Result := false;
end;

function LineVsPolygon(const v1,v2,v3, LB,LE,vNormal : TVec3f):boolean;
var
  vIntersection : TVec3f;
  originDistance : Extended;
  distance1 : Extended;
  distance2 : Extended;
  vVector1 : TVec3f;
  vVector2 : TVec3f;
  vPoint : TVec3f;
  vLineDir : TVec3f;
  Numerator : Extended;
  Denominator : Extended;
  dist : Extended;
  Angle,tempangle : Extended; // Initialize the angle
	vA, vB : TVec3f;						// Create temp vectors
  I : integer;
  dotProduct : Extended;
  vectorsMagnitude : Extended;
  vPoly            : array [0..2] of TVec3f;
  verticeCount : integer;
begin
  vPoint  := vector(0,0,0);
  vLineDir:= vector(0,0,0);
  Angle := 0;
  vpoly[0] := v1;
  vpoly[1] := v2;
  vpoly[2] := v3;
  verticeCount:=3;

  vVector1 := v_sub(vPoly[2],vPoly[0]);
  vVector2 := v_sub(vPoly[1],vPoly[0]);

  originDistance := -1 * v_Dot(vNormal,vPoly[0]);

	distance1 := v_Dot(vNormal,lb) + originDistance;// Cz + D
	distance2 := v_Dot(vNormal,le) + originDistance;// Cz + D
	if(distance1 * distance2 >= 0) then
  begin
	  result := false;
    exit;
  end;
  vLineDir := v_sub(le,lb);    // Get the X value of our new vector
  v_normalize(vLineDir);
	Numerator := -1 * (v_Dot(vNormal,lb) + originDistance);
	Denominator := v_Dot(vNormal,vLineDir);

	if( Denominator = 0) then	 // Check so we don't divide by zero
  begin
		vIntersection := lb; // Return an arbitrary point on the line
  end
  else
  begin

  	dist := Numerator / Denominator;
  	vPoint := v_ADD(lb,v_Mult(vLineDir,dist));
  	vIntersection := vPoint;								// Return the intersection point
  end;

  // Go in a circle to each vertex and get the angle between
  for i := 0 to verticeCount-1 do
  begin

    vA := v_sub(vPoly[i],vIntersection);
    vB := v_sub(vPoly[(i + 1) mod verticeCount],vIntersection);

    dotProduct       := v_Dot(vA,vB);
	  vectorsMagnitude := v_Length(VA)* v_Length(VB);
    tempangle        := arccos( dotProduct / vectorsMagnitude );
	  if(isnan(tempangle)) then
  		tempangle := 0;
	  Angle := Angle + tempangle;
  end;

	if(Angle >= (M_Angle) ) then
  begin
		result := TRUE;
    exit;
  end;

	result := false; // There was no collision, so return false
end;

function LineVsPolygon2(const v1,v2,v3, LB,LE,vNormal : TVec3f;Var vInt : TVec3f):boolean;
var
  vIntersection : TVec3f;
  originDistance : Extended;
  distance1 : Extended;
  distance2 : Extended;
  vVector1 : TVec3f;
  vVector2 : TVec3f;
  vPoint : TVec3f;
  vLineDir : TVec3f;
  Numerator : Extended;
  Denominator : Extended;
  dist : Extended;
  Angle,tempangle : Extended; // Initialize the angle
	vA, vB : TVec3f;						// Create temp vectors
  I : integer;
  dotProduct : Extended;
  vectorsMagnitude : Extended;
  vPoly            : array [0..2] of TVec3f;
  verticeCount : integer;
begin
  vint:=vector(0,0,0);
  vPoint  := vector(0,0,0);
  vLineDir:= vector(0,0,0);
  Angle := 0;
  vpoly[0] := v1;
  vpoly[1] := v2;
  vpoly[2] := v3;
  verticeCount:=3;

  vVector1 := v_sub(vPoly[2],vPoly[0]);
  vVector2 := v_sub(vPoly[1],vPoly[0]);

  originDistance := -1 * v_Dot(vNormal,vPoly[0]);

	distance1 := v_Dot(vNormal,lb) + originDistance;// Cz + D
	distance2 := v_Dot(vNormal,le) + originDistance;// Cz + D
	if(distance1 * distance2 >= 0) then
  begin
	  result := false;
    exit;
  end;
  vLineDir := v_sub(le,lb);    // Get the X value of our new vector
  v_normalize(vLineDir);
	Numerator := -1 * (v_Dot(vNormal,lb) + originDistance);
	Denominator := v_Dot(vNormal,vLineDir);

	if( Denominator = 0) then	 // Check so we don't divide by zero
  begin
		vIntersection := lb; // Return an arbitrary point on the line
  end
  else
  begin

  	dist := Numerator / Denominator;
  	vPoint := v_ADD(lb,v_Mult(vLineDir,dist));
  	vIntersection := vPoint;								// Return the intersection point
//  vint := vIntersection;
  end;

  // Go in a circle to each vertex and get the angle between
  for i := 0 to verticeCount-1 do
  begin

    vA := v_sub(vPoly[i],vIntersection);
    vB := v_sub(vPoly[(i + 1) mod verticeCount],vIntersection);

    dotProduct       := v_Dot(vA,vB);
	  vectorsMagnitude := v_Length(VA)* v_Length(VB);
    tempangle        := arccos( dotProduct / vectorsMagnitude );
	  if(isnan(tempangle)) then
  		tempangle := 0;
	  Angle := Angle + tempangle;
  end;

	if(Angle >= (M_Angle) ) then
  begin
		result := TRUE;
    vint := vIntersection;
    exit;
  end;
  vInt := vector(0,0,0);
	result := false; // There was no collision, so return false
end;

////////////////////////////// LINE POLYGON COLLISION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

/////////////////////////// ELIPSOID POLYGON COLLISION \\\\\\\\\\\\\\\\\\\\\\\\\\*
// Создано на основе проверки столкновения :
// Сергея Бехтера Email : killerman1985@mail.ru
function LineInsideTri(const PointPlane1,PointPlane2,PointPlane3,BeginPoint,EndPoint: TVec3f): TDistBool;
var p1,p2,p3,p4: TVec3f;
    t,u,v,det: Single;
begin
 Result := DB_Identity;
p1:=v_sub(BeginPoint , PointPlane1);
p2:=v_sub(BeginPoint , EndPoint);
p3:=v_sub(PointPlane2, PointPlane1);
p4:=v_sub(PointPlane3, PointPlane1);

 det:=v_Dot(p2,v_Cross(p3,p4));
 if det=0 then Exit;

 t:=v_Dot(p1,v_Cross(p3,p4))/det;
 if (t<0) or (t>1) then Exit;

 u:=v_Dot(p2,v_Cross(p1,p4))/det;
 if (u<0) or (u>1) then Exit;

 v:=v_Dot(p2,v_Cross(p3,p1))/det;
 if (v<0) or (v>1) then Exit;

 if (u+v)>1 then Exit;

 Result.Point.X:= PointPlane1.X+p3.X*u+p4.X*v;
 Result.Point.Y:= PointPlane1.Y+p3.Y*u+p4.Y*v;
 Result.Point.Z:= PointPlane1.Z+p3.Z*u+p4.Z*v;
 Result.Vector := v_normalize( V_Negate(p2) );
 Result.Dist   := v_dist(Result.Point,BeginPoint);
 Result.Return := True;
end;

function LineInsideTri2(const PointPlane1,PointPlane2,PointPlane3,BeginPoint,EndPoint: TVec3f): boolean;
var p1,p2,p3,p4: TVec3f;
    t,u,v,det: Single;
begin
 Result := False;
p1:=v_sub(BeginPoint , PointPlane1);
p2:=v_sub(BeginPoint , EndPoint);
p3:=v_sub(PointPlane2, PointPlane1);
p4:=v_sub(PointPlane3, PointPlane1);

 det:=v_Dot(p2,v_Cross(p3,p4));
 if det=0 then Exit;

 t:=v_Dot(p1,v_Cross(p3,p4))/det;
 if (t<0) or (t>1) then Exit;

 u:=v_Dot(p2,v_Cross(p1,p4))/det;
 if (u<0) or (u>1) then Exit;

 v:=v_Dot(p2,v_Cross(p3,p1))/det;
 if (v<0) or (v>1) then Exit;

 if (u+v)>1 then Exit;
 Result:= True;
end;




function MinDistToLine(const Point,LinePoint1,LinePoint2: TVec3f): TDistBool;
var
d,t: Single;
V1,V2,V3: TVec3f;
begin
V1  := v_sub (Point,LinePoint1);
V2  := v_normalize( v_sub(LinePoint2,LinePoint1) );
d   := v_dist(LinePoint1,LinePoint2);
t   := v_Dot(V1,V2);
if t<=0 then
 begin
   Result.Point := LinePoint1;
   Result.Vector:= v_Normalize(v1);
   Result.Dist  := v_dist(Point,LinePoint1);
 end
 else
  if t>=d then
   begin
     Result.Point  :=LinePoint2;
     Result.Vector :=v_normalize(v_sub(Point,LinePoint2));
     Result.Dist   :=v_dist(Point,LinePoint2);
   end
   else
   begin
     V3:= v_add ( v_mult(V2,t) ,LinePoint1);
     Result.Point := V3;
     Result.Dist  := v_dist(Point , V3);
     Result.Vector:=v_normalize( v_sub(Point,V3));
   end;

end;

function CollEllipsToTr(var Center: TVec3f; const Radius,PointPlane1,PointPlane2,PointPlane3: TVec3f): TDistBool;
var Normal,EndPoint,IntP,EdCent,VectEl,
    TrP1,TrP2,TrP3 ,VDiv: TVec3f;
    Intersect           : TDistBool;
    RadEl,DistToP       : Single;
    Label GoEnd;
begin
Result := DB_Identity;
vdiv := v_divv(V_mIdentity,radius);

//Переводим координаты вершин треугольника в эллипсойдные
TrP1:= v_multv( v_sub(PointPlane1,Center) ,vdiv);
TrP2:= v_multv( v_sub(PointPlane2,Center) ,vdiv);
TrP3:= v_multv( v_sub(PointPlane3,Center) ,vdiv);
//Проверяем пересечение плоскости треугольника с ед сферой
    Normal := V_Negate(P_Normal(TrP1,TrP2,TrP3));
    EdCent := V_Identity;
 if -v_dot(Normal,EdCent) >1 then Exit;

    EndPoint := V_Negate(Normal);

    Intersect:= LineInsideTri(TrP1,TrP2,TrP3,EdCent,EndPoint);

     if Intersect.Return then
     goto GoEnd;

   /// проверяем первую грань треугольника///
   Intersect:=MinDistToLine(EdCent,TrP1,TrP2);
    if Intersect.Dist<1 then
     goto GoEnd;

   /// проверяем вторую грань треугольника///
   Intersect:=MinDistToLine(EdCent,TrP2,TrP3);
    if Intersect.Dist<1 then
     goto GoEnd;


   /// проверяем третью грань треугольника///
   Intersect:=MinDistToLine(EdCent,TrP3,TrP1);
    if Intersect.Dist<1 then
     goto GoEnd;

/// Выходим пересечения небыло///
Exit;
/// Есть пересечение ///
GoEnd:
     VectEl       := v_multv (Intersect.Vector,radius);
     RadEl        := v_length(VectEl);
     IntP         := v_multv (Intersect.Point,radius);
     IntP         := v_add   (intp,Center);
     DistToP      := v_dist  (Center,IntP);

     Result.Vector:= VectEl;
     Result.Point := IntP;
     Result.Dist  := DistToP;
     Result.Return:= True;


     Center.X     :=IntP.X-(IntP.X-Center.X)*(RadEl/DistToP);
     Center.Y     :=IntP.Y-(IntP.Y-Center.Y)*(RadEl/DistToP);
     Center.Z     :=IntP.Z-(IntP.Z-Center.Z)*(RadEl/DistToP);
end;

/////////////////////////// ELIPSOID POLYGON COLLISION \\\\\\\\\\\\\\\\\\\\\\\\\\*

//--------------------------------
function uSphereFromAABB(const aabb: TAABB): TSphere;
var v: TVec3f;
begin
  v := v_add(aabb.Mins, aabb.Maxs);
  Result.POS := v_mult(v, 0.5);
  Result.Radius := v_dist(Result.Pos, aabb.Maxs);
end;

function uAABBFromSphere(const POS: TVec3f; Radius:Single): TAABB;
var dist:single;
begin
      dist := sqrt(Radius*Radius);
      result.mins := Pos - vec3f(dist,dist,dist);
      result.maxs := Pos + vec3f(dist,dist,dist);
end;


Function uCubeVsPoint(const Box,Point : TVec3f; Size:Single):Boolean;
Begin
  If (abs(Point.x - Box.x)< Size) And
     (abs(Point.y - Box.y)< Size) And
     (abs(Point.z - Box.z)< Size) Then Result := True Else Result := False;
end;

Function uBoxVsPoint(const Box,BoxSize,Point : TVec3f):Boolean;
Begin
  IF (abs(Point.x - Box.x)< BoxSize.x) And
     (abs(Point.y - Box.y)< BoxSize.y) And
     (abs(Point.z - Box.z)< BoxSize.z) Then Result := True Else Result := False;
end;


function uAABBVsPoint(const Minx,Maxx,Pos : TVec3f): boolean;
begin
IF (Pos.X >= Minx.X) and (Pos.X <= Maxx.X) and
   (Pos.y >= Minx.y) and (Pos.y <= Maxx.y) and
   (Pos.z >= Minx.z) and (Pos.z <= Maxx.z) then result := true else result:=false;
end;

function uBoxVsBox(const Box1,Box2,
                    Box1Size,Box2Size : TVec3f): boolean;
begin
 if (box1.X + box1size.X < Box2.X) or
    (box1.y + box1size.y < Box2.y) or
    (box1.z + box1size.z < Box2.z) or

    (Box2.x + box2size.X < box1.X) or
    (Box2.y + box2size.y < box1.y) or
    (Box2.z + box2size.z < box1.z) then
     Result:=false else result:=true;
end;

Function uAABBVsAABB(const Minx1,Maxx1,Minx2,Maxx2: TVec3f): boolean;
begin
result:=true;
		if (Minx1.x > Maxx2.x) or (Maxx1.x < Minx2.x) or (Minx1.y > Maxx2.y) or
  		 (Maxx1.y < Minx2.y) or (Minx1.z > Maxx2.z) or (Maxx1.z < Minx2.z) then result:=false;
end;


function uAABBVsSphere(const Minx,Maxx,Pos : TVec3f;R:Single): boolean;
var
d :single;
begin
   d := 0;

      // если центр сферы лежит перед AABB,
      if (Pos.x < Minx.x) then d:=d+ abs(Pos.x - Minx.x); // то вычисляем расстояние по этой оси
      // если центр сферы лежит после AABB,
      if (pos.x > Maxx.x) then d:=d+ abs(Pos.x - Maxx.x); // то вычисляем расстояние по этой оси

(******************************************************************************)
      if (Pos.y < Minx.y) then d :=d + abs(Pos.y - Minx.y);
      if (pos.y > Maxx.y) then d :=d + abs(Pos.y - Maxx.y);
(******************************************************************************)
      if (Pos.z < Minx.z) then d :=d + abs(Pos.z - Minx.z);
      if (pos.z > Maxx.z) then d :=d + abs(Pos.z - Maxx.z);
(******************************************************************************)

   result := (d  <=  R);

end;


function uCubeVsLine(const BP,LBEGIN,LEND: TVec3f;BS :single): boolean;
Var
  MID,
  DIR,
  T   : TVec3f;
  HL,
  R   : Single;

begin
  // Получаем центр
  Mid.x := lbegin.x+(lend.x-lbegin.x)*0.5;
  Mid.y := lbegin.y+(lend.y-lbegin.y)*0.5;
  Mid.z := lbegin.z+(lend.z-lbegin.z)*0.5;

  // Получаем направление
  dir.x := (lend.x-lbegin.x);
  dir.y := (lend.y-lbegin.y);
  dir.z := (lend.z-lbegin.z);

  // Получаем длину
  hl := sqrt(sqr(dir.x)+sqr(dir.y)+sqr(dir.z));
  // Нормализуем её
  if hl <> 0 then
  begin
         r:= 1/hl;
    dir.x := dir.x * r;
    dir.y := dir.y * r;
    dir.z := dir.z * r;

    hl    := hl * 0.5;
  end;

  // Получаем позицию куба относительно середины линии
   t.x := BP.x -mid.x;
   t.y := BP.y -mid.y;
   t.z := BP.z -mid.z;

    // проверяем, является ли одна из осей X,Y,Z разделяющей
   if ( (abs(T.x) > BS + hl*abs(dir.x)) or
        (abs(T.y) > BS + hl*abs(dir.y)) or
        (abs(T.z) > BS + hl*abs(dir.z)) ) then begin result := false ; exit; end;

   // проверяем X ^ dir
    r := BS*abs(dir.z) + BS*abs(dir.y);
    if ( abs(T.y*dir.z - T.z*dir.y) > r ) then begin result := false ; exit; end;

   // проверяем Y ^ dir
    r := BS* abs(dir.z) + BS* abs(dir.x);
    if ( abs(T.z*dir.x - T.x*dir.z) > r ) then begin result := false ; exit; end;

   // проверяем Z ^ dir
    r := BS*abs(dir.y) + BS*abs(dir.x);
    if ( abs(T.x*dir.y - T.y*dir.x) > r ) then begin result := false ; exit; end;

   result := true;

end;

function uAABBVsLine(const Mins,Maxs,StartPoint, EndPoint : TVec3f): boolean;
var
  dir, lineDir, ld, lineCenter, center, extents, cross: TVec3f;
begin
result:=false;
  center := v_mult(v_add(Mins, Maxs), 0.5);
  extents := v_sub(center,mins);
  lineDir := v_mult(v_sub(EndPoint, StartPoint), 0.5);
  lineCenter := v_add(StartPoint, lineDir);
  dir := v_sub(lineCenter, center);

  ld.x := Abs(lineDir.x);
  if Abs(dir.x) > (extents.x + ld.x) then Exit;

  ld.y := Abs(lineDir.y);
  if Abs(dir.y) > (extents.y + ld.y) then Exit;

  ld.z := Abs(lineDir.z);
  if Abs(dir.z) > (extents.z + ld.z) then Exit;

  cross := v_cross(lineDir, dir);

  if Abs(cross.x) > ((extents.y * ld.z) + (extents.z * ld.y)) then Exit;
  if Abs(cross.y) > ((extents.x * ld.z) + (extents.z * ld.x)) then Exit;
  if Abs(cross.z) > ((extents.x * ld.y) + (extents.y * ld.x)) then Exit;

  Result := True;
end;


function uSphereVsPoint(const Sphere,Point : TVec3f; R: Single): boolean;
Var
  dist: Single;
begin
// Получение дистанции мужду двумя точками
  dist:=sqrt(sqr(Sphere.X-Point.X)+sqr(Sphere.Y-Point.Y)+sqr(Sphere.Z-Point.Z));
// Если она меньше радиуса сферы то есть столкновение
  if dist<=R then result:=true else result:=false;
end;

Function uSphereVsSphere(const Sphere1,Sphere2 : TVec3f; R1,R2 : Single) : boolean;
Var
R,RR  : Single;
X,Y,Z : Single;
begin
  R:= (R1 + R2);
  //Получем центр и радиус
  X := Sphere2.x - Sphere1.X;
  Y := Sphere2.Y - Sphere1.Y;
  Z := Sphere2.Z - Sphere1.Z;

  rr := sqrt(x*x +y*y +z*z);
  if rr < r then Result := True else Result := false;
  // если r больше rr то нет столкновения
end;

function uSphereVsLine(const Sphere, LB,LE : TVec3f;R: Single): boolean;
var
 Point,
 Vector1,
 Vector2,
 Dir    : TVec3f;
 D, T   : Single;
begin
Result  :=false;

// Узнаём положение сферы относительно начала линии
Vector1 := v_sub(Sphere,Lb);
// Узнаём направление
Dir     := v_sub(Le,Lb);
// Узнаём длину
D       := v_length(dir);
// Нормализируем её
if d >0 then
  begin
    Vector2  := v_mult(Dir, 1/d);
  end;

// Узнаём дистанцию между началом и концом линии
d := v_dist(Lb,le);

// Перемножаем их и получаем приделы линии где может быть сфера
t := (Vector1.X * Vector2.X) + (Vector1.Y * Vector2.Y) + (Vector1.Z * Vector2.Z);

// Вышли за приделы линии
if t+r <= 0 then  Exit;
if t-r >= d then  Exit;

// Получаем местоположение сферы относительно линии
Point := v_adD(lb,v_mult(Vector2,t));
// Получаем дистанцию между сферой и точкой ..
// Если она меньше радиуса сферы то есть столкновение
  if v_dist(sphere,point) <=R then
Result := true;
end;

function uSphereVsLine2(const Sphere, P1,P2 : TVec3f;R: Single): boolean;
var
  v, dir: TVec3f;
  d, len: Single;
begin
  dir := v_sub(p2, p1);
  len := v_normalizesafe(dir, dir);

  v := v_sub(Sphere, p1);
  d := v_dot(v, dir);

  Result := False;

  if d > len + R then Exit;
  if d < -R then Exit;

  len := v_dist(v_combine(p1, dir, d), sphere);

  if len > R then Exit;

  Result := True;
end;




///////////////////////////////////////////////////////////////////////////////
//Shaders//////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure CalculateTandB(var T, B: TVec3f; const st1, st2: TVec2f; const P, Q: TVec3f);
var
  s: Single;
  st: array [0..1, 0..1] of Single;
  pq: array [0..2, 0..1] of Single;
begin

  // Calculate tangent and binormal for a triangle with the given edges P and Q.
  s := 1 / ((st1.x * st2.y) - (st2.x * st1.y));

  st[0,0] := st2.y;   st[1,0] := -st1.y;
  st[0,1] := -st2.x;  st[1,1] := st1.x;

  pq[0,0] := P.X;   pq[1,0] := P.Y;   pq[2,0] := P.Z;
  pq[0,1] := Q.X;   pq[1,1] := Q.Y;   pq[2,1] := Q.Z;

  T.X := s * (st[0,0]*pq[0,0] + st[1,0]*pq[0,1]);
  T.Y := s * (st[0,0]*pq[1,0] + st[1,0]*pq[1,1]);
  T.Z := s * (st[0,0]*pq[2,0] + st[1,0]*pq[2,1]);

  B.X := s * (st[0,1]*pq[0,0] + st[1,1]*pq[0,1]);
  B.Y := s * (st[0,1]*pq[1,0] + st[1,1]*pq[1,1]);
  B.Z := s * (st[0,1]*pq[2,0] + st[1,1]*pq[2,1]);

end;

procedure CalculateTangents(var v1, v2, v3: TShaderVertex);
var
  P, Q: TVec3f;
  st1, st2: TVec2f;
  T, B: TVec3f;
begin

  // Calculate triangle's edges:
  P.X := v2.Pos.X - v1.Pos.X;
  P.Y := v2.Pos.Y - v1.Pos.Y;
  P.Z := v2.Pos.Z - v1.Pos.Z;

  Q.X := v3.Pos.X - v1.Pos.X;
  Q.Y := v3.Pos.Y - v1.Pos.Y;
  Q.Z := v3.Pos.Z - v1.Pos.Z;

  // Calculate S and T vectors:
  st1.x := v2.Tex0.x - v1.Tex0.x;
  st1.y := v2.Tex0.y - v1.Tex0.y;

  st2.x := v3.Tex0.x - v1.Tex0.x;
  st2.y := v3.Tex0.y - v1.Tex0.y;

  // Calculate the tangent and binormal:
  CalculateTandB(T, B, st1, st2, P, Q);

  v1.Tangent.X := v1.Tangent.X + T.X;     v1.Binormal.X := v1.Binormal.X + B.X;
  v1.Tangent.Y := v1.Tangent.Y + T.Y;     v1.Binormal.Y := v1.Binormal.Y + B.Y;
  v1.Tangent.Z := v1.Tangent.Z + T.Z;     v1.Binormal.Z := v1.Binormal.Z + B.Z;

  v2.Tangent.X := v2.Tangent.X + T.X;     v2.Binormal.X := v2.Binormal.X + B.X;
  v2.Tangent.Y := v2.Tangent.Y + T.Y;     v2.Binormal.Y := v2.Binormal.Y + B.Y;
  v2.Tangent.Z := v2.Tangent.Z + T.Z;     v2.Binormal.Z := v2.Binormal.Z + B.Z;

  v3.Tangent.X := v3.Tangent.X + T.X;     v3.Binormal.X := v3.Binormal.X + B.X;
  v3.Tangent.Y := v3.Tangent.Y + T.Y;     v3.Binormal.Y := v3.Binormal.Y + B.Y;
  v3.Tangent.Z := v3.Tangent.Z + T.Z;     v3.Binormal.Z := v3.Binormal.Z + B.Z;
end;

function dotVecLengthSquared3(v: TVec3f): Single;
begin
  Result := v.x*v.x + v.y*v.y + v.z*v.z;
end;

procedure dotVecNormalize3(var v: TVec3f);
var
  L: Single;
const
  DOT_ORIGIN3: TVec3f = (x: 0; y: 0; z: 0);
begin

  L := dotVecLengthSquared3(v);
  if L = 0 then v := DOT_ORIGIN3
  else begin
    L := sqrt(L);
    v.x := v.x / L;
    v.y := v.y / L;
    v.z := v.z / L;
  end;

end;


Procedure CreateTangentVectorSpace(const v1, v2, v3 : TVec3f; Const T1,T2,T3:TVec2f; Var tangent, binormal, normal:TVec3f);
var
T, B, N,
direction_v2_to_v1, direction_v3_to_v1 : TVec3f;

direction_v2u_to_v1u, direction_v2v_to_v1v ,
direction_v3u_to_v1u, direction_v3v_to_v1v ,
denominator, scale , scale2 : Single;

begin
   direction_v2_to_v1 := v_sub(v2 , v1);
   direction_v3_to_v1 := v_sub(v3 , v1);

   direction_v2u_to_v1u := t2.x - t1.x;
   direction_v2v_to_v1v := t2.y - t1.y;

   direction_v3u_to_v1u := t3.x - t1.x;
   direction_v3v_to_v1v := t3.y - t1.y;

   denominator := direction_v2u_to_v1u * direction_v3v_to_v1v -
                       direction_v3u_to_v1u * direction_v2v_to_v1v;
   if denominator <>0 then
   
   begin

      scale := 1.0 / denominator;

      T.x := (direction_v3v_to_v1v * direction_v2_to_v1.x  - direction_v2v_to_v1v * direction_v3_to_v1.x ) * scale;
      T.y := (direction_v3v_to_v1v * direction_v2_to_v1.y  - direction_v2v_to_v1v * direction_v3_to_v1.y ) * scale;
      T.z := (direction_v3v_to_v1v * direction_v2_to_v1.z  - direction_v2v_to_v1v * direction_v3_to_v1.z ) * scale;

      B.x := (-direction_v3u_to_v1u * direction_v2_to_v1.x  + direction_v2u_to_v1u * direction_v3_to_v1.x ) * scale;
      B.y := (-direction_v3u_to_v1u * direction_v2_to_v1.y  + direction_v2u_to_v1u * direction_v3_to_v1.y ) * scale;
      B.z := (-direction_v3u_to_v1u * direction_v2_to_v1.z  + direction_v2u_to_v1u * direction_v3_to_v1.z ) * scale;

      N := V_Cross(T, B);

      scale2 := 1.0 / ((T.x  * B.y * N.z - T.z * B.y * N.x) +
                       (B.x  * N.y * T.z - B.z * N.y * T.x) +
                       (N.x  * T.y * B.z - N.z * T.y * B.x));

      tangent.x :=   V_Cross(B, N).x  * scale2;
      tangent.y := -(V_Cross(N, T).x  * scale2);
      tangent.z :=   V_Cross(T, B).x  * scale2;
      tangent   :=v_Normalize(tangent);

      binormal.x := -(v_Cross(B, N).y * scale2);
      binormal.y :=   v_Cross(N, T).y * scale2;
      binormal.z := -(v_Cross(T, B).y * scale2);
      binormal   :=v_Normalize(binormal);

      normal.x   :=   v_Cross(B, N).z * scale2;
      normal.y   := -(v_Cross(N, T).z * scale2);
      normal.z   :=   v_Cross(T, B).z * scale2;
      normal   :=v_Normalize(normal);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//   Additions from Kavis                                                      /
//   kavi5@yandex.ru                                                           /
//   http://openglmax.narod.ru                                                 /
////////////////////////////////////////////////////////////////////////////////
(*Function V_VectorLen(var V: TVec3f; newLen: Single): Single;
Begin //Установить нужную длину вектора. Возвращает старую длину.
{}result:=sqrt(sqr(V.x)+sqr(V.y)+sqr(V.z));
{}if result>0 then begin
{}{}V.x:=V.x/result*newLen; V.y:=V.y/result*newLen; V.z:=V.z/result*newLen;
{}end;
End;    *)

Function V_VectorLen(var V: TVec3f; newLen: Single): Single;
Begin //Установить нужную длину вектора. Возвращает старую длину.
{}result:=v_length(v);
{}if result>0 then
{}//v:= v_div(v,result*newLen);
begin
V.x:=V.x/result*newLen; V.y:=V.y/result*newLen; V.z:=V.z/result*newLen;
end
End;



Function VectorPlusVectorK(const V1,V2: TVec3f; k: single): TVec3f;
Begin //Вектор плюс вектор, умноженный на число
result := V_ADD(V1,v_mult(V2, k) );
End;

Function VectorQuad(const V: TVec3f): single;
var
V2: TVec3f;
Begin //Возведение вектора в квадрат
V2:=V_MultV(V,V);
result:=V2.X + V2.Y +V2.Z;
End;

Function FindIntersection(P1, P2, P3: TVec3f; P: TVec3f; V: TVec3f; var I: TVec3f): single;
{}//Нахождение пересечения луча P,V с треугольником P1,P2,P3.
{}//Возвращает отрицательное число, если пересечения не было, либо
{}// неотрицательное число, если пересечение было.
{}//Точка пересечения I=P+V*result. Чем меньше result, тем раньше произошло пересечение.
Var
{}V1,V2: TVec3f; //Образующие векторы треугольника
{}N: TVec3f; //Нормаль к треугольнику
{}k: single; //Вспомогателный коэффициент
{}T: TVec3f; //Вектор из P1 в I
{}c1,c2: single; //Координаты T в базисе V1,V2
{}v1v1,v1v2,v2v2,v1t,v2t: single; //Значения различных скалярных произведений
Begin
{}I:=P;

{}V1:=V_Sub(P2,P1); V2:=V_Sub(P3,P1);
{}N:=V_Cross(V1,V2);

{}k:=v_dot(V,N);
{}//Луч лежит в плоскости треугольника, либо параллелен ей:
{}If k=0 Then Begin result:=-1; exit; End;

{}result:=v_dot(V_Sub(P1,P),N)/k;
{}//Луч не пересекается с плоскостью треугольника
{}If result<0 Then exit;

{}I:=VectorPlusVectorK(P,V,result); //Точка пересечения.
{}T:=V_Sub(I,P1);

{}v1v1:=VectorQuad(V1); v1v2:=v_dot(V1,V2); v2v2:=VectorQuad(V2);
{}v1t:=v_dot(V1,T); v2t:=v_dot(V2,T);

{}k:=v1v1*v2v2-sqr(v1v2);
{}c1:=(v1t*v2v2-v2t*v1v2)/k;
{}c2:=(v2t*v1v1-v1t*v1v2)/k;

{}If (c1<0) or (c2<0) or ((c1+c2)>1) Then result:=-1; //Луч не пересёкся с треугольником
End;



Function FindP(const P1, P2, P3: TVec3f; P: TVec3f; V: TVec3f; var I: TVec3f): single;
{}//Нахождение пересечения луча P,V с прямоугольником P1,P2,P3. //задается тремя точками
{}//Возвращает отрицательное число, если пересечения не было, либо
{}// неотрицательное число, если пересечение было.
{}//Точка пересечения I=P+V*result. Чем меньше result, тем раньше произошло пересечение.
Var
{}V1,V2: TVec3f; //Образующие векторы треугольника
{}N: TVec3f; //Нормаль к треугольнику
{}k: single; //Вспомогателный коэффициент
{}T: TVec3f; //Вектор из P1 в I
{}c1,c2: single; //Координаты T в базисе V1,V2
{}v1v1,v1v2,v2v2,v1t,v2t: single; //Значения различных скалярных произведений
Begin
{}I:=P;

{}V1:=V_Sub(P2,P1); V2:=V_Sub(P3,P1);
{}N:=V_Cross(V1,V2);

{}k:=v_dot(V,N);
{}//Луч лежит в плоскости треугольника, либо параллелен ей:
{}If k=0 Then Begin result:=-1; exit; End;

{}result:=v_dot(V_Sub(P1,P),N)/k;
{}//Луч не пересекается с плоскостью треугольника
{}If result<0 Then exit;

{}I:=VectorPlusVectorK(P,V,result); //Точка пересечения.
{}T:=V_Sub(I,P1);

{}v1v1:=VectorQuad(V1); v1v2:=v_dot(V1,V2); v2v2:=VectorQuad(V2);
{}v1t:=v_dot(V1,T); v2t:=v_dot(V2,T);

{}k:=v1v1*v2v2-sqr(v1v2);
{}c1:=(v1t*v2v2-v2t*v1v2)/k;
{}c2:=(v2t*v1v1-v1t*v1v2)/k;

If (c1<0) or (c2<0) or (c1>1) or (c2>1) Then result:=-1; //Луч не пересёкся с прямоугольником
End;





function GetOffsetToTarget(POS,TGPOS:TVector):TVector;
begin
Result:= V_div(V_sub(tgpos,pos),
               V_DIST(POS,TGPOS));
end;
//********************************************
//Поворот вектора вокуг вектора
//********************************************/
function  RotateAroundVector(const in1, in2 :Tvector; const delta: single) : Tvector;
var
dz, dx, dy : Tvector;
begin
    dz := v_mult(in2 , v_Dot(in1,in2));
    dx := v_sub(in1 , dz);
    dy := v_Cross(dx,in2);
    RotateAroundVector := v_add( v_add ( v_mult (dx, cos(delta)) , v_mult(dy , sin(delta))) , dz);

{
	 dz := in2 * V_Dot(in1,in2);
	 dx := in1 - dz;
	 dy := Cross(dx,in2);
	out = dx*cosf(delta)+dy*sinf(delta)+dz;
                      }
{out - результ вектор
in1 - вектор вокруг которого =) 
in2 - вектор который =) 
delta - угол. }
end;


Procedure M_Inverse(M1:PMat4F; Result: PMat4F);
var
  D : Single;
begin
  D := M_Determinant(M1^);

 // if ABS(d) < 1e-40 then
 if D= 0 then
  begin
   Result^.Identity ;
    exit;
  end else
     D := 1 / D;

  Result.cell [0,0] :=  (M1.cell[1,1] *M1.cell[2,2] -M1.cell[2,1] *M1.cell[1,2]) * D;
  Result.cell[0,1] := -(M1.cell[0,1] *M1.cell[2,2] -M1.cell[2,1] *M1.cell[0,2]) * D;
  Result.cell[0,2] :=  (M1.cell[0,1] *M1.cell[1,2] -M1.cell[1,1] *M1.cell[0,2]) * D;
  Result.cell[0,3] := 0;
  Result.cell[1,0] := -(M1.cell[1,0] *M1.cell[2,2] -M1.cell[2,0] *M1.cell[1,2]) * D;
  Result.cell[1,1] :=  (M1.cell[0,0] *M1.cell[2,2] -M1.cell[2,0] *M1.cell[0,2]) * D;
  Result.cell[1,2] := -(M1.cell[0,0] *M1.cell[1,2] -M1.cell[1,0] *M1.cell[0,2]) * D;
  Result.cell[1,3] := 0;
  Result.cell[2,0] :=  (M1.cell[1,0] *M1.cell[2,1] -M1.cell[2,0] *M1.cell[1,1]) * D;
  Result.cell[2,1] := -(M1.cell[0,0] *M1.cell[2,1] -M1.cell[2,0] *M1.cell[0,1]) * D;
  Result.cell[2,2] :=  (M1.cell[0,0] *M1.cell[1,1] -M1.cell[1,0] *M1.cell[0,1]) * D;
  Result.cell[2,3] := 0;
  Result.cell[3,0] := -(M1.cell[3,0] * Result.cell[0,0] +M1.cell[3,1] * Result.cell[1,0] +M1.cell[3,2] * Result.cell[2,0]);
  Result.cell[3,1] := -(M1.cell[3,0] * Result.cell[0,1] +M1.cell[3,1] * Result.cell[1,1] +M1.cell[3,2] * Result.cell[2,1]);
  Result.cell[3,2] := -(M1.cell[3,0] * Result.cell[0,2] +M1.cell[3,1] * Result.cell[1,2] +M1.cell[3,2] * Result.cell[2,2]);
  Result.cell[3,3] := 1;
end;

//устанавливает матрицу по трем векторам (например для отображения объекта)
Procedure LookAt(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz : Single; M:PMat4F);
var
 forward, side, up : TVec3f;
begin

    forward.x := centerx - eyex;
    forward.y := centery - eyey;
    forward.z := centerz - eyez;

    up.x := upx;
    up.y := upy;
    up.z := upz;

    forward := v_normalize(forward);

   // /* Side = forward x up */
    side := v_cross(forward, up);
    side := v_normalize(side);

   // /* Recompute up as: up = side x forward */
    up   := v_cross(side, forward);

    m.cell [0][0] := side.x;
    m.cell[1][0] := side.y;
    m.cell[2][0] := side.z;

    m.cell[0][1] := up.x;
    m.cell[1][1] := up.y;
    m.cell[2][1] := up.z;

    m.cell[0][2] := -forward.x;
    m.cell[1][2] := -forward.y;
    m.cell[2][2] := -forward.z;

    M.cell[3][0] := eyex;
    M.cell[3][1] := eyey;
    M.cell[3][2] := eyez;

    M.cell[0][3] := 0;
    M.cell[1][3] := 0;
    M.cell[2][3] := 0;
    M.cell[3][3] := 1;
//    glMultMatrixf(&m[0][0]);
//    glTranslated(-eyex, -eyey, -eyez);
end;


end.
