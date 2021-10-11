unit t_camera;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

{$Warnings off}
{$Hints on}

interface
uses
 Windows,OpenGL15,l_math;

type

// Camera <-+->
 TCamera = object
  public
   Pos   : TVector; // позиция
   Heading,         // Угол поворота головы лево /право
   Tilt,
   DST   : Single;  // угол поворота головы вер /низ
   TGPOS : TVector;
   notmoveable : boolean;
   Mpos   : TPoint;     // Старая позиция мыши (для получения поворота камеры)
    procedure Init(P:Tvector;HD,TL:Single);
    procedure Update(const PPos:TVector);
    Procedure SetView;  // Установка вида
    Procedure Move(HD,TL,Speed:Single); // Перемищение камеры
    Procedure UpdateMouse(X,Y:Integer); // Обновление её разворотов
    Procedure Update2DMouse(X,Y:Integer);

 end;

 var
  Cam : TCamera;


 const
 MouseSpeed=10;
 Camera_Radius=1;

implementation
uses objects;

procedure Tcamera.Init(P:Tvector;HD,TL:Single);
begin
  // Вычисляем предпологаемое место камеры :)
pos :=V_add(p, V_mult (v_CreateOffset(hd+180,-tl), DST));
tgpos:=Pos;
Heading:= hd;
Tilt   := tl;
end;

Procedure TCamera.Move(HD,TL,Speed:Single);
begin
 // Получение новой позиции
 POS := v_add(POS,v_mult(v_CreateOffset(Heading+HD,Tilt*TL),Speed));
end;

Procedure TCamera.UpdateMouse(X,Y:Integer);
begin
GetCursorPos(mpos);                           // Читаем позицию мыши
SetCursorPos(x,y);                        // Устанавливаем её позицию на экране
Heading := Heading + (mpos.x - x)/100 * MouseSpeed ; // Крутим голову по Y
Tilt    := Tilt    - (y - mpos.y)/100 * MouseSpeed ; // Крутим голову по X

if Tilt >  90 then Tilt := 90;  // Ограничеваем поворот головы чтоб не смог крутится
if Tilt < -90 then Tilt :=-90;
//--
if Heading >  360 then Heading := 0;
if Heading <    0 then Heading := 360;
end;

Procedure TCamera.Update2DMouse(X,Y:Integer);
begin
GetCursorPos(mpos);                           // Читаем позицию мыши
SetCursorPos(x,y);                        // Устанавливаем её позицию на экране
pos.x := pos.x + (mpos.x - x)/100 * MouseSpeed; // Крутим голову по Y
pos.y := pos.y - (y - mpos.y)/100 * MouseSpeed; // Крутим голову по X
end;

Procedure TCamera.SetView;
begin
GlRotatef   ( Tilt   ,1,0,0); // Разворот мира
GlRotatef   ( heading,0,1,0);
GlTranslatef(-pos.x,-pos.y,-pos.z); // Перемещение центра мира
end;

procedure Tcamera.Update(const PPos:TVector);
var
 SpeedT : Single;
 Speed  : TVector;
begin
  SpeedT:=FrameTime/200; // Скрорость передвижения камеры
  speed:=vector(0,0,0);
  // Вычисляем предпологаемое место камеры
  TGPOS := V_add(ppos, V_mult (v_CreateOffset(heading+180,-tilt),DST));
  Speed := V_SUB(TGPOS,POS);
  // Проверяем находится ли камера около ожидаемоей точки

  if not notmoveable then
  if V_dist(pos,tgpos) > Camera_Radius*0.2 then
  Pos   := V_Add(Pos, V_Mult(Speed,Speedt));
//  map.Collision(Pos,10);

end;

end.

