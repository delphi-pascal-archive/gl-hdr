(
	FileName = GetSaveFileName types:"SVSD_VAL Anim model (*.sam)|*.sam|"
--if (FileName = undefined) then exit
    file = fopen FileName "wb"

		global objs = #()
		for obj in objects do
            if ((classOf obj) != BoneGeometry) and ((classOf obj) != Biped_Object) and (canConvertTo obj TriMeshGeometry) then
				append objs obj

	-- сохранение заголовка
		writeLong file objs.count
	-- поиск экспортируемого меша
	for obj in objs do -- цикл по всем объектам
		(
--		collapseStack(obj)
--		convertToMesh(obj)
--		collapse(obj)
--		makePlanar(obj)
--		unifyNormal(obj)
--		break (obj)
		mesh = snapshotAsMesh obj

         -- сохранение в файл
		V_Count    = obj.numVerts  -- кол-во вершин
		F_Count    = obj.numFaces  -- кол-во граней
		T_Count    = obj.numTVerts -- кол-во текстурных координат
		--конецформыначалоформыgetFaceNormal

	-- сохранение данных обьекта заголовка
--				if (obj.material == undefined) or (obj.material.maps[2] == undefined) then
--					dTex = "notexture" else	
					dTex = obj.material.maps[2].FileName
--dTex = "tex0_d.tga"
		WriteLong   file F_Count;
        WriteLong   file dTex.Count
        WriteString file dTex
		
	-- сохранение граней
				frame =0
					at time frame			
Print "Write vertex";
        m = obj.objectTransform;
		local invertface = false;
		if (m[1].x * m[2].y * m[3].z < 0) then (  invertface = true )
		print m

				for i = 1 to F_Count do
				(
					f = (GetFace mesh i)-- - [1, 1, 1]
					
		  if (invertface == false) then
		  (
					v1 = (GetVert mesh f.x)
					v2 = (GetVert mesh f.y)
					v3 = (GetVert mesh f.z)
		  ) else
		  (
					v1 = (GetVert mesh f.x)
					v2 = (GetVert mesh f.z)
					v3 = (GetVert mesh f.y)
		  )
					WriteFloat file v1.x;
					WriteFloat file v1.z;
					WriteFloat file -v1.y;
					WriteFloat file v2.x;
					WriteFloat file v2.z;
					WriteFloat file -v2.y;
					WriteFloat file v3.x;
					WriteFloat file v3.z;
					WriteFloat file -v3.y;
				)
Print "Write texcoord";
				for i = 1 to F_Count do
				(
					f2 = (GetTVFace mesh i)-- - [1, 1, 1]
--			t1 = (GetTVert obj f2.x-1)	
--			t2 = (GetTVert obj f2.y-1)	
--			t3 = (GetTVert obj f2.z-1)
					
  		  if (invertface == false) then
  		  (
  					t1 = (GetTVert mesh f2.x-1)	
  					t2 = (GetTVert mesh f2.y-1)	
  					t3 = (GetTVert mesh f2.z-1)
  		  ) else
  		  (
  					t1 = (GetTVert mesh f2.x-1)	
  					t2 = (GetTVert mesh f2.z-1)	
  					t3 = (GetTVert mesh f2.y-1)	
  		  )
					WriteFloat file t1.x;
					WriteFloat file -t1.y;
					WriteFloat file t2.x;
					WriteFloat file -t2.y;
					WriteFloat file t3.x;
					WriteFloat file -t3.y;
				)
				
				for i = 1 to F_Count do
				(
					fg = (getFaceSmoothGroup mesh i)
					WriteLong file (fg)
				)
				
	)
	
	fclose file
)