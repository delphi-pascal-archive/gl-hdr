unit Sam2_Unit;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

{SIMPLE MODEL}
interface
{$Warnings off
 $Hints ON}
uses
  windows,l_math,objects, gl_materials,frust;

type
  TQuat = record
    X, Y, Z, W : Single;
  end;

  TFrame = record
    Pos : TVec3f;  // позици€
    Rot : TQuat;    // поворот
  end;

  TFace      = array [0..2] of word;

  TObj       = Object
    AABB        : TAABB;
    Center      : TVec3f;

    TextureName : String;
    V_Count     : Integer;
    Vertex      : array of TVec3f;
    TexCoord    : array of TVec2f;
    Face        : array of TFace;
    FaceGroup   : array of cardinal;

    Normal,
    Tangent,
    binormal   : Array of TVec3f;
    V_Buff : Cardinal;
    F_Buff : Cardinal;
    OQ     : Cardinal;


    Material : TMaterial;

    Procedure AdjustNormals;
  end;

  TObjSort   = record
   ID      : Integer;
   Z       : Single;
   Visible : boolean;
  end;

  TSam2Model = class
    ObjCount    : Integer;
    Center      : TVec3f;
    Radius      : Single;
    Objs        : Array of TObj;
    //
    Queries    : Array of Cardinal;
    ObjSort    : Array of TObjSort;
    ObjSortCount : Integer;
    ObjSortVis   : Integer;

    Function LoadFromFile(Name: string):boolean;
    procedure Render(const matmode:Integer; const POS,Ran:TVec3f);
  end;

  var
  use_vbo : boolean = true;
  Sphere  : Record
    POS : TVec3f;
    R   : Single;
    AABB: TAABB;
  end;
  gfxdir  : String;

procedure DrawBBox(Min,Max:TVec3f);
implementation
uses OpenGL15,textures,t_camera;

const unitname='SVSD_VAL Short Model unit';

procedure TObj.AdjustNormals;
var
    TMPBinormal,TMPNormal,TMPTangent : TVec3f;
    I,J : Integer;

  Procedure generateNormalAndTangent( xv1, xv2 , xv3: TVec3f; xst1 , xst2, xst3 : TVec2f; var tangent, binormal,normal: TVec3f);
  var
  v1,v2,tmpn  : TVec3f;
  st1,st2: TVec2f;
  begin
    v1      :=  v_sub(xv2 , xv1);
    v2      :=  v_sub(xv3 , xv1);
    st1.x   := xst2.x - xst1.x;
    st1.y   := xst2.y - xst1.y;
    st2.x   := xst3.x - xst1.x;
    st2.y   := xst3.y - xst1.y;
       tmpn := v_normalize(v_cross(v2, v1));
   tangent  := v_normalize(v_add(v_mult(v1 , st2.y) , v_mult(v2 , -st1.y)));
   binormal := v_normalize(v_add(v_mult(v2 , st1.x) , v_mult(v1 , -st2.x)));
     normal := v_Cross(binormal,tangent);
   if V_Dot(normal, tmpn) > 0 then normal := v_negate(normal);
  end;
begin

  for I:=0 to High(face) do
   begin
  generateNormalAndTangent(vertex[Face[I][0]],
                           vertex[Face[I][1]],
                           vertex[Face[I][2]],
                           texcoord[Face[I][0]],
                           texcoord[Face[I][1]],
                           texcoord[Face[I][2]],
                           TMPTangent,
                           TMPBinormal ,
                           TMPNormal);
     for j:= 0 to 2 do
       begin
         normal [Face[I][j]] := TMPNormal;
         Tangent[Face[I][j]] := TMPTangent;
         binormal[Face[i][j]] := TMPBinormal;
       end;
   end;

        for i := 0 to High(vertex) do
        for j := 0 to High(vertex) do
        if  i <> j then
        if v_Dist(vertex[i],vertex[j]) < 0.001 then
         if (faceGroup[i div 3] <> 0) and (faceGroup[j div 3]<>0 )then
         if (faceGroup[i div 3] = faceGroup[j div 3] )then
         begin
           Tangent[i] := Tangent[i] + Tangent[j];
           Tangent[j] := Tangent[j] + Tangent[i];
           Normal[i]  := Normal[i] + Normal[j];
           Normal[j]  := Normal[j] + Normal[i];
         end;

        for i := 0 to High(vertex) do
        begin
          Tangent[i].Normalize;
          Normal [i].Normalize;
        end;


      if length(vertex) >0 then
      begin
        aabb.Maxs := vertex[0];
        aabb.Mins := vertex[0];
      end;

     for i := 0 to high(vertex) do
      begin
       aabb.Mins := VAABBMin(aabb.mins, VERTEX[i]);
       aabb.Maxs := VaabbMax(aabb.Maxs, VERTEX[i]);
      end;
      Center := aabb.MINS + (aabb.MAXS - aabb.MINS) * 0.5;


//  calc_normals_sm;
end;


Function TSam2Model.LoadFromFile(Name: string):boolean;
var
  F : File;
  I,j,vc,F_Count : Integer;
  d:single;
begin
Try
  if not FileExists(name) then
  begin
      MessageBox(0,Pchar('Model file not found !!' + #13+#10 + Name) ,'',0);
     exit;
  end;


  AssignFile(F, Name);
  Reset(F, 1);

   BlockRead(F, ObjCount , 4);
   WriteLn( 'Objects count :', ObjCOunt );

   SetLength(objs, ObjCount );

    SetLength( ObjSort, ObjCount );
    SetLength( Queries, ObjCount );
    glGenQueriesARB(    ObjCount ,@Queries[0]);

   For i := 0 to ObjCount -1 do
   With objs[i] do
   begin
      BlockRead(F, F_Count     , 4);
      V_Count := F_Count * 3;
      BlockRead(F, j , 4);
      SetLength(TextureName, j);
      BlockRead(F, TextureName[1] , j+1);
      SetLength(Vertex        , V_Count);
      SetLength(TexCoord      , V_Count);
      SetLength(FaceGroup     , F_Count);
      BlockRead(F, Vertex[0].x   , V_Count * SizeOf(TVec3f));
      BlockRead(F, TexCoord[0].x , V_Count * SizeOf(TVec2f));
      BlockRead(F, FaceGroup[0]  , F_Count * 4);



      SetLength(face    , v_count div 3);

      for j := 0 to high(face) do
      begin
        face[j][0]    := j*3;
        face[j][1]    := j*3+1;
        face[j][2]    := j*3+2;
      end;



      Material.Load (gfxdir+ ExtractFileName( ChangeFileExt(TextureName,'.mtf') ));

      SetLength(Normal        , V_Count);
      SetLength(Tangent       , V_Count);
      SetLength(Binormal      , V_Count);

     AdjustNormals;



  if GL_ARB_vertex_buffer_object then
  begin
    glGenBuffersARB(1, @v_buff);
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, v_buff);
    glBufferDataARB(GL_ARRAY_BUFFER_ARB, V_Count * ( 4 * SizeOf(TVec3f) + SizeOf(TVec2f) ), nil, GL_STATIC_DRAW_ARB);

    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB , 0                            , V_Count * SizeOf(TVec3f ), @Vertex[0].x );
    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB , V_Count * SizeOf(TVec3f )   , V_Count * SizeOf(TVec3f ), @Normal[0].x );
    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB , V_Count * SizeOf(TVec3f )*2 , V_Count * SizeOf(TVec3f ), @Tangent[0].x );
    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB , V_Count * SizeOf(TVec3f )*3 , V_Count * SizeOf(TVec3f ), @BiNormal[0].x );
    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,  V_Count * SizeOf(TVec3f )*4 , V_Count * SizeOf(TVec2f), @TexCoord[0].x);


    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);


    glGenBuffersARB(1, @f_buff);
    glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, F_buff);
    glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, Length(face) * sizeof(TFACE),
                    @Face[0][0], GL_STATIC_DRAW_ARB);

    glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
  end;


    end;

  Center := Vec3f(0,0,0);
  VC     := 0;
 for I := 0 to high(objs) do
 begin
  for j := 0 to high(objs[i].vertex) do
  Center := V_Add(Center, objs[i].Vertex[j]);
  inc(vc , length(objs[i].vertex));
 end;
  Center := V_Div(Center, vc );

  Radius :=-1;
 for I := 0 to high(objs) do
  for j := 0 to high(objs[i].vertex) do
  begin
         d := V_Distq(Center, objs[i].Vertex[j]);
      if d > Radius then   Radius := d;
   Radius := sqrt(Radius);
  end;

  CloseFile(F);

  result:=true;
  except
//      MessageOut('ћодель не загружена !!' + #13+#10 + Name);
  end;
end;

procedure TSam2Model.Render;
var
  j,i : Integer;
   p_ver,
   p_tan,
   p_norm,
   p_tex,
   p_face,p_bin : Pointer;
   b: boolean;
   A:TAABB;
   Tmp:TObjSort;
function somedist(const v1, v2 : PVec3f): single;
begin
 Result := sqrt(sqr(v2.X - v1.X) + sqr(v2.Y - v1.Y) + sqr(v2.Z - v1.Z));
end;
begin
 TexID:= -1;

   glEnableClientState(GL_VERTEX_ARRAY);

   case MatMode of
     0: // Z_Only
       begin
         for j := 0 to high(objs) do
         with objs[ j ] do
           if uAABBVsAABB(AABB.mins,AABB.MAXS, Sphere.AABB.MINS,Sphere.AABB.MAXS) then
           if BoxInFrustum( AABB.MINS, AABB.MAXS) then
           begin
                glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buff );
                glVertexPointer  (3, GL_FLOAT, 0, nil  );
                glDrawArrays(GL_TRIANGLES, 0,v_count);

           end;
       end;

     1: // Z_Only
       begin
         ObjSortCount:=0;
         for j := 0 to high(objs) do
         with objs[j] do
         begin
           ObjSort[ObjSortCount].Visible := BoxInFrustum( AABB.MINS, AABB.MAXS);
           ObjSort[ObjSortCount].Z       := somedist(@center,@cam.pos);//}getZ(@center);// + model.obj[j].MaxDist;
           ObjSort[ObjSortCount].ID      := j;
           OQ :=0;
           inc(ObjSortCount);
         end;

          for i := 0 to ObjSortCount-1 do
          for j := 0 to ObjSortCount-1 do
          if i <> j then
          if ObjSort[i].Z < ObjSort[j].Z then
          begin
                   TMP := ObjSort[i];
            ObjSort[i] := ObjSort[j];
            ObjSort[j] := tmp;
          end;





         for j := 0 to ObjSortCount-1 do
         if ObjSort[j].Visible then
         with objs[ ObjSort[j].ID ] do
         begin

           {$Region 'Pointers'}
          if use_vbo and GL_ARB_vertex_buffer_object then
            begin
              p_ver     := 0;
//              p_face    := 0;
              glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buff );
//              glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, F_buff);
            end else
            begin
              p_ver     := @Vertex[0];
//              p_face    := @Face[0];
            end;
          {$endregion}
           glBeginQueryARB(GL_SAMPLES_PASSED_ARB, queries[ ObjSort[j].ID ]);
           glVertexPointer  (3, GL_FLOAT, 0, p_ver  );

//              glDrawElements(GL_TRIANGLES, v_count, GL_UNSIGNED_SHORT, p_face);
                glDrawArrays(GL_TRIANGLES, 0,v_count);
           glEndQueryARB(GL_SAMPLES_PASSED_ARB);

         end;
       end;

     2: // Z_Only
       begin

         for j := 0 to ObjSortCount-1 do
         if ObjSort[j].Visible and (objs[ ObjSort[j].id ].OQ > 0) then
         with objs[ ObjSort[j].ID ] do
         begin

           {$Region 'Pointers'}
          if use_vbo and GL_ARB_vertex_buffer_object then
            begin
              p_ver     := 0;
              p_face    := 0;
              {$IFDef AlphaZ}
              if Material.alpha then
              p_tex     := pointer( V_Count * SizeOf(TVec3f)*3 );
              {$endif}
              glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buff );
              glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, F_buff);
            end else
            begin
              p_ver     := @Vertex[0];
              p_face    := @Face[0];
              {$IFDef AlphaZ}
              if Material.alpha then
              p_tex     := @TexCoord[0];
              {$endif}
            end;

              {$IFDef AlphaZ}
            if Material.alpha then
            begin
              glEnable(GL_ALPHA_Test);
              glAlphaFunc(GL_GREATER,0.5);
              Material.AmbinetEnable;
             glEnableClientState(GL_TEXTURE_COORD_ARRAY);


             glClientActiveTextureARB(GL_TEXTURE0_ARB);
               glTexCoordPointer(2, GL_FLOAT, 0, p_tex);

            end;
              {$endif}

          {$endregion}
           glVertexPointer  (3, GL_FLOAT, 0, p_ver  );

//              glDrawElements(GL_TRIANGLES, v_count, GL_UNSIGNED_SHORT, p_face);
                glDrawArrays(GL_TRIANGLES, 0,v_count);
              {$IFDef AlphaZ}
           if Material.alpha then
           begin
             glDisableClientState(GL_TEXTURE_COORD_ARRAY);
              glDisable(GL_ALPHA_Test);
             Material.disable;
           end;
              {$endif}

         end;
       end;

     else // Material

       for j := 0 to ObjSortCount-1 do
       if ObjSort[j].Visible and (objs[ ObjSort[j].id ].OQ > 0) then

       with objs[ ObjSort[j].id ] do


//       if BoxInFrustum(AABB.mins,AABB.MAXS) then
       if uAABBVsAABB(AABB.mins,AABB.MAXS, Sphere.AABB.MINS,Sphere.AABB.MAXS) then
       begin
         glEnableClientState(GL_NORMAL_ARRAY);

          {$Region 'Pointers'}
          if use_vbo and GL_ARB_vertex_buffer_object then
          begin
            p_ver     := 0;
            p_norm    := pointer( V_Count * SizeOf(TVec3f)   );
            p_tan     := pointer( V_Count * SizeOf(TVec3f)*2 );
            p_bin     := pointer( V_Count * SizeOf(TVec3f)*3 );
            p_tex     := pointer( V_Count * SizeOf(TVec3f)*4 );
            p_face    := 0;
            glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buff );
            glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, F_buff);
          end else
          begin
            p_ver := @Vertex[0];  p_norm := @Normal[0];
            p_tan := @Tangent[0]; p_bin  := @biNormal[0]; p_tex  := @TexCoord[0]; p_face := @Face[0];
          end;
          {$endregion}
          material.Enable;
            glNormalPointer  (   GL_FLOAT, 0, p_norm );

             glClientActiveTextureARB(GL_TEXTURE2_ARB);
             glEnableClientState(GL_TEXTURE_COORD_ARRAY);
               glTexCoordPointer(3, GL_FLOAT, 0, p_bin);
             glClientActiveTextureARB(GL_TEXTURE1_ARB);
             glEnableClientState(GL_TEXTURE_COORD_ARRAY);
               glTexCoordPointer(3, GL_FLOAT, 0, p_tan);
             glClientActiveTextureARB(GL_TEXTURE0_ARB);
               glEnableClientState(GL_TEXTURE_COORD_ARRAY);
               glTexCoordPointer(2, GL_FLOAT, 0, p_tex);


             glVertexPointer  (3, GL_FLOAT, 0, p_ver  );

//             glDrawElements(GL_TRIANGLES, v_count, GL_UNSIGNED_SHORT, p_face);
                glDrawArrays(GL_TRIANGLES, 0,v_count);

            material.Disable;
      end;
   end;
   glDisableClientState(GL_VERTEX_ARRAY);



   case MatMode of
   1:begin

       for i := 0 to high(ObjSort) do
       if ObjSort[i].Visible then
       begin
       glGetQueryObjectuivARB(queries[ ObjSort[i].ID ], GL_QUERY_RESULT_ARB,@objs[ ObjSort[i].ID ].oq);
       end;

     end;
   3:
     begin
      	glClientActiveTextureARB(GL_TEXTURE0_ARB);
        	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
       	glClientActiveTextureARB(GL_TEXTURE1_ARB);
        	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      	glClientActiveTextureARB(GL_TEXTURE2_ARB);
        	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

       glDisableClientState(GL_NORMAL_ARRAY);
     end;
   end;
   if use_vbo and GL_ARB_vertex_buffer_object then
   begin
      glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
      glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
   end;


// отрисовка

end;

procedure DrawBBox(Min,Max:TVec3f);
var
 Vertices: Array[1..8] of TVec3f;
 i :integer;
begin
 Vertices[1]:= Vec3f(Min.X,Max.Y,Min.Z);
 Vertices[2]:= Vec3f(Max.X,Max.Y,Min.Z);
 Vertices[3]:= Vec3f(Min.X,Max.Y,Max.Z);
 Vertices[4]:= Vec3f(Max.X,Max.Y,Max.Z);
 Vertices[5]:= Vec3f(Min.X,Min.Y,Min.Z);
 Vertices[6]:= Vec3f(Max.X,Min.Y,Min.Z);
 Vertices[7]:= Vec3f(Min.X,Min.Y,Max.Z);
 Vertices[8]:= Vec3f(Max.X,Min.Y,Max.Z);
glPushAttrib(GL_CURRENT_BIT);
glLineWidth(2);
glDisable(GL_TEXTURE_2D);
// glcolor3f(0,1,0);
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



end.
