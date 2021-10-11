unit Textures;
{$Warnings off}
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

interface

uses
  Windows, OpenGL15,HMUtils;

Type PbyteArray = ^TbyteArray;
     TbyteArray = array [0..1023] of byte;
var

  GL_MIP_MAP : Boolean=true;
  GL_Texture_32BIT : boolean;
function LoadTexture(Filename: String; var Texture: Integer): Boolean;
function CreateHorizonMap(Filename: String; var Texture: Cardinal): Boolean;
procedure Texture_Enable(const ID: Cardinal; const Channel: Integer);
procedure Texture_Disable(const Channel: Integer);

procedure TextureCubeMap_Enable(const ID: Cardinal; const Channel: Integer);
procedure TextureCubeMap_Disable(const Channel: Integer);

procedure Texture3D_Enable(const ID: Cardinal; const Channel: Integer);
procedure Texture3D_Disable(const Channel: Integer);

function CreateTexture(Width, Height, Format : Word; pData : Pointer) : Integer;

implementation
uses objects;

 var
   Materials : Array of Record
        Name : String;
        ID   : Integer;
    end;

    CurImage : Array [0..31] of Integer;


procedure Texture_Enable(const ID: Cardinal; const Channel: Integer);
begin
        if CurImage[Channel]  = id then exit;
           CurImage[Channel] := id;

  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
  glEnable(GL_TEXTURE_2D);
  // если текстура не существует - включаем текстуру по умолчанию
{  if (ID = 0) or not glIsTexture(ID) then
        glBindTexture(GL_TEXTURE_2D,  0) else
                          }
        glBindTexture(GL_TEXTURE_2D, ID);
end;

procedure Texture3D_Enable(const ID: Cardinal; const Channel: Integer);
begin
  glActiveTextureARB(GL_TEXTURE0_ARB+Channel);
  glEnable(GL_TEXTURE_3D);
  glBindTexture(GL_TEXTURE_3D, ID);
end;

procedure Texture3D_Disable(const Channel: Integer);
begin
  glActiveTextureARB(GL_TEXTURE0_ARB+Channel);
  glDisable(GL_TEXTURE_3D);
  glBindTexture(GL_TEXTURE_3D, 0);
end;


procedure Texture_Disable(const Channel: Integer);
begin
  CurImage[Channel]:= -1;
  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
//  glBindTexture(GL_TEXTURE_2D, 0);
  glDisable(GL_TEXTURE_2D);
end;

procedure TextureCubeMap_Enable(const ID: Cardinal; const Channel: Integer);
begin
  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, ID);
end;

procedure TextureCubeMap_Disable(const Channel: Integer);
begin
  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, 0);
end;


{------------------------------------------------------------------}
{  Create the Texture                                              }
{------------------------------------------------------------------}
function CreateTexture(Width, Height, Format : Word; pData : Pointer) : Integer;
var
  Texture : Cardinal;
begin
  glGenTextures(1, @Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);      {Texture blends with object background}

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  if GL_MIP_MAP then
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR) else

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  GL_Texture_32BIT :=false;

  case format of
   GL_RGBA,32 :
    begin
      gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pData);
      GL_Texture_32BIT :=true;
    end;

   GL_RGB ,24 :
   begin
      gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, pData);
   end;

   GL_BGRA    :
   begin
     gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_BGRA, GL_UNSIGNED_BYTE,  pData);
     GL_Texture_32BIT :=true;
   end;

   GL_RGB8    :
   begin
     gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB8, Width, Height, GL_RGB , GL_UNSIGNED_BYTE,  pData);
   end;

   GL_LUMINANCE_ALPHA:
   begin
     gluBuild2DMipmaps(GL_TEXTURE_2D, 2, Width, Height, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, pData);
   end;

  end;

  result :=Texture;
end;

procedure SwapRGB(data : PbyteArray; Size,bpp : Integer);
var i : integer;
    C : Byte;
begin
    for I :=0 to Size - 1 do
    begin
      c  := Data[i*bpp+2];
            Data[i*bpp+2] := Data[i*bpp];
            Data[i*bpp  ] := c;
    end;
end;


{------------------------------------------------------------------}
{  Loads 8 , 24 and 32bpp (alpha channel) TGA textures             }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String; var Texture: Integer): Boolean;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array [0..4] of Byte;
    OrigX        : Word;
    OrigY        : Word;
    Width        : Word;
    Height       : Word;
    BPP          : Byte;
    ImageInfo    : Byte;
  end;
  TGAFile   : File;
  image     : PbyteArray;    {or PRGBTRIPLE}
  image256  : PbyteArray;
  i,
  ImageSize : Integer;
  Pall      : Array [0..255] of Array [0..2] of Byte;
begin
  result :=FALSE;
  if not FileExists(Filename) then
  begin
   messagebox(0,Pchar('File Not found:'+filename),'Texture Unit',0);
   exit;
  end;

  try
    AssignFile(TGAFile, Filename);
    Reset(TGAFile, 1);
    // Read in the bitmap file header
    BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));


    // Get the width, height, and color depth
    with TGAHeader do
    IF BPP = 8 then
    begin
    BlockRead(TGAFile, PALL[0][0], 768);

                                     ImageSize  := Width*Height;
                GetMem(image256    , ImageSize);
    BlockRead(TGAFile, image256^[0], ImageSize);

                GetMem(Image       , Width * Height * 3);

       For i := 0 To ImageSize-1 do
       begin
       Image[i*3    ] := Pall[ image256[i] ] [2];
       Image[i*3+1  ] := Pall[ image256[i] ] [1];
       Image[i*3+2  ] := Pall[ image256[i] ] [0];
       end;
       bpp := 24;
     FreeMem(Image256);
    end
    else
    begin
    ImageSize  := Width*Height*(bpp div 8);

    GetMem(Image, ImageSize);
    BlockRead(TGAFile, image^[0], ImageSize);

    SwapRGB(Image, Width * Height, BPP div 8);
    end;

    Texture := CreateTexture(TGAHeader.Width, TGAHeader.Height, TGAHeader.BPP, Image);

    FreeMem(Image);
    Result:=True;
   except
   end;
end;

function CreateHorizonMap(Filename: String; var Texture: Cardinal): Boolean;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array [0..4] of Byte;
    OrigX        : Word;
    OrigY        : Word;
    Width        : Word;
    Height       : Word;
    BPP          : Byte;
    ImageInfo    : Byte;
  end;
  TGAFile   : File;
  image     : PbyteArray;    {or PRGBTRIPLE}
  image256  : PbyteArray;
  i,
  ImageSize : Integer;
  Pall      : Array [0..255] of Array [0..2] of Byte;
begin
  result :=FALSE;
  if fileExists(ChangeFileExt(FileName,'.hrz'))then
  begin
    SendToLog('Loading horizon map :'+ ChangeFileExt(FileName,'.hrz'));
    Texture := hmLoadHorizonMap(ChangeFileExt(FileName,'.hrz'));
    result :=true;
    exit;
  end;

  if not FileExists(Filename) then
  begin
   messagebox(0,Pchar('File Not found:'+filename),'Texture Unit',0);
   exit;
  end;

  try
    AssignFile(TGAFile, Filename);
    Reset(TGAFile, 1);
    // Read in the bitmap file header
    BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));


    // Get the width, height, and color depth
    with TGAHeader do
    IF BPP = 8 then
    begin
    BlockRead(TGAFile, PALL[0][0], 768);

                                     ImageSize  := Width*Height;
                GetMem(image256    , ImageSize);
    BlockRead(TGAFile, image256^[0], ImageSize);

                GetMem(Image       , Width * Height * 3);
{
       For i := 0 To ImageSize-1 do
       begin
       Image[i*3    ] := Pall[ image256[i] ] [2];
       Image[i*3+1  ] := Pall[ image256[i] ] [1];
       Image[i*3+2  ] := Pall[ image256[i] ] [0];
       end;
       bpp := 24;
 }      Texture := hmCreateHorizonMap(image256^,TGAHeader.Width, TGAHeader.Height, 1,20,1, ChangeFileExt(FileName,'.hrz'));
       exit;
     FreeMem(Image256);
    end
    else
    begin
    ImageSize  := Width*Height*(bpp div 8);

    GetMem(Image, ImageSize);
    BlockRead(TGAFile, image^[0], ImageSize);

    SwapRGB(Image, Width * Height, BPP div 8);
    end;

    Texture := hmCreateHorizonMap(Image^,TGAHeader.Width, TGAHeader.Height, TGAHeader.BPP div 8,20,1, ChangeFileExt(FileName,'.hrz'));

    FreeMem(Image);
    Result:=True;
   except
   end;
end;


function LoadTexture(Filename: String; var Texture: Integer): Boolean;
var
i :integer;
begin
if Filename = '' then exit;

for i := 0 to length(Materials)-1 do
If Materials[i].Name = FileName then
  Begin
    Texture := Materials[i].id;
    exit;
  end;

   i := Length(Materials);
     SetLength(Materials,i+1);
               Materials[i].Name := FileName;
                     LoadTGATexture(FileName, Materials[i].id);
    Texture := Materials[i].id;

end;


end.
