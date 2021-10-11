unit GL_Materials;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

interface
uses glsl, OpenGL15,textures,TokenStream;


Type

  PMaterial = ^TMaterial;
  TMaterial = record
  private
    Name   : String;
    ID     : array [0..4] of Integer;
    ID3D   : Cardinal;
    Ref    : Integer;
    Specular : Single;
    Shader   : ^TShader;
  private
  public
    Tag      : Char;
    alpha    : boolean;
    procedure Load(const Name: String);
    procedure Free;
    procedure Enable;
    procedure AmbinetEnable;
    procedure Disable;
//    procedure Enable(ID:Cardinal); overload;
//    procedure Disable(ID:Cardinal); overload;
  end;

var
      texid : Integer;

Procedure StopShader;


implementation
uses objects,l_math,HMUtils,glShaderList;

type
      TManager = record
        List : Array of pointer;
        function  Get(const Name: String): PMaterial;
        procedure Add(Texture: PMaterial);
        procedure Del(const Name: String);
      end;
var
      Manager : TManager;
      MapsInit: boolean = false;
      FLUT    : Cardinal;


Procedure InitMaps;
begin
if MapsInit then exit;
   FLUT := hmCreateHeadingElevationLUT(32);

   MapsInit:=true;
end;

procedure TMaterial.Load;
const
  Fmt : array [0..3] of Integer =(GL_RGB, GL_RGBA, GL_BGR, GL_BGRA);
var
  Item  : PMaterial;
  i  : Integer;
  mat: TConfig;
  s : string;
  Function LoadMap(Name:String; PID:Integer) : boolean;
  begin
   if mat.GetString(Name) = '' then exit;
   writeln( name , ' ,: ',mat.GetString(Name) );
    S := appdir + mat.GetString(name);
   if not FileExists(s) then
   begin
     WriteLN('File not found !!',#13,#10,S);
     result:=false;
     exit;
   end;
   result:=LoadTexture( s ,id[ Pid ]);
 end;

  Function LoadHorizon(Name:String) : boolean;
  begin
   if mat.GetString(Name) = '' then exit;
   writeln( name , ' ,: ',mat.GetString(Name) );
    S := appdir + mat.GetString(name);
   if not FileExists(s) then
   begin
     WriteLN('File not found !!',#13,#10,S);
     result:=false;
     exit;
   end;
   result:=CreateHorizonMap( s ,id3d);
 end;


begin
    InitMaps;

if not fileExists(name) then exit;

  Self.Name := Name;

       Item := Manager.Get(Name);
    if Item <> nil then
    begin
      Item^.Ref := Item^.Ref + 1;
      ID       := Item^.ID;
      Tag      := Item^.Tag;
      Shader   := Item^.Shader;
      Specular := Item^.Specular;
    Exit;
    end;
    Ref := 1;

 for i := 0 to high(id) do
   id[i]   := -1;

 if not FileExists(name) then
 begin
  WriteLN('Material not found :' , name);

  New(Item);
  Item^ := Self;
  Manager.Add(item);

 exit;
 end;

 mat := TConfig.Create(name);

   writeln( name );

 for i := 0 to high(id) do
   id[i]   := -1;

   LoadMap('diffuse map'  ,0);
   alpha := GL_Texture_32BIT;
   LoadMap('normal map'   ,1);
   LoadMap('specular map' ,2);
   LoadMap('lum map'      ,3);
   LoadMap('height map'   ,4);
   LoadHorizon('horizon map');

   if mat.GetString('shader') <> '' then
    Shader := Get_Shader( mat.GetString('shader') ) else
    Shader := nil;
//  if mat.GetString('shader') = 'water' then tag:='w';
  mat.Destroy;
//  Shader:=nil;
//  GetMem(Pointer(Item), SizeOf(TMaterial));
  New(Item);
  Item^ := Self;
  Manager.Add(item);
end;

procedure TMaterial.Free;
var
  Item : PMaterial;
begin
  Item := Manager.Get(Name);
  if Item <> nil then
  begin
    Item^.Ref := Item^.Ref - 1;
    if Item^.Ref <= 0 then
    begin
      glDeleteTextures(2, @Item.ID);
      Manager.Del(Name);
    end;
  end;
end;

procedure TMaterial.Enable;
var i : integer;
    b : boolean;
begin
//  if Shader <> @CurShader then
  if Shader <> nil then
     with Shader^ do
     begin
     Start;
       bindUniform( GetUniform(Pchar( 'light0') ), @CurLight.pos,3 );
       SetUniform( GetUniform('zbias') , CurLight.ZBias );

       SetUniform( GetUniform('height_map') , 4);
       SetUniform( GetUniform('Angle') , 5);
       SetUniform( GetUniform('Horizon') , 6);


     end;

    for i := 0 to high(id) do
    if id[i] <> -1 then
    texture_enable(id[i],i);

    TextureCubeMap_Enable(FLUT,5);
    Texture3D_Enable(id3d,6);


{
  glActiveTextureARB(GL_TEXTURE5_ARB);
  glEnable(GL_TEXTURE_CUBE_MAP_ARB);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, FLUT);

  glActiveTextureARB(GL_TEXTURE6_ARB);
  glEnable(GL_TEXTURE_3D);
  glBindTexture(GL_TEXTURE_3D, id3d );
 }
  {
    texture_enable(id[0],0);
    texture_enable(id[1],1);
    texture_enable(id[2],2);
    texture_enable(id[3],3);
    texture_enable(id[4],4);
 }
//   if tag = 'w' then
//    texture_enable(ref_tex,2);
//     else
//    texture_disable(2)
{
  case Tag of
    'g', 'w' :
      begin
      end;
  end;
 }
end;

procedure TMaterial.AmbinetEnable;
begin
     if alpha then
     texture_enable(id[0],0);
end;


procedure TMaterial.Disable;
var i : integer;
begin
  texture_disable(0);
    if GL_ARB_shading_language_100 then
    for i := 1 to high(id) do
    texture_disable(i);

  if Shader <> nil then Shader.Stop;
  case Tag of
    'g', 'w' :
      begin
//  texture_disable(2);
//        glDepthMask(True);
//        glEnable(GL_CULL_FACE);
      end;
  end;
end;

{$REGION 'Tex Manager'}
function TManager.Get;
var
  i : Integer;
begin
  for i := 0 to high(list) do
    if PMaterial(list[i])^.Name = Name then
    begin
      Result := List[i];
      Exit;
    end;
  Result := nil;
end;

procedure TManager.Add;
var i :integer;
begin
  I := Length(List);
   SetLength(List,i+1);
  list[i] := Texture;
end;

procedure TManager.Del;
var
  i : Integer;
begin
  for i := 0 to high(list) do
    if PMaterial(list[i]).Name = Name then
    begin
      FreeMem(list[i]);
      list[i] := list[high(list)];
      setlength(list,high(list));
      exit;
    end;
end;

Procedure StopShader;
begin
 GLSL.StopShader;
end;

{$ENDREGION}

end.
