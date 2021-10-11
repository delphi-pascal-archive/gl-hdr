unit TokenStream;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

interface

uses l_math;

type
  TSetOfChar = set of Char;

  TTokenStream = class
  private
    FSeparators: TSetOfChar;
    FOpenBracket, FCloseBracket: String;
    FText: String;
    FPosition: Integer;
    FBrackets: Integer;
  public
    constructor Create(filename: String);
    function GetNextToken: String;
    procedure SkipLine;
    property BracketLevel: Integer read FBrackets;
    property Separators: TSetOfChar read FSeparators write FSeparators;
    property OpenBracket: String read FOpenBracket write FOpenBracket;
    property CloseBracket: String read FCloseBracket write FCloseBracket;
    property Text : String read FText Write FText;
  end;

  TConfig = class
    Attribs  : Array of Array [0..1] of String;
    FReady   : boolean;
  public
    constructor Create(filename: String);
    Function GetString (const s:String; const def : string = ''):String;
    Function GetFloat  (const s:String; const def : single = 0 ):Single;
    Function GetInt    (const s:String; const def : integer= 0 ):Integer;
    Property Ready : boolean read FReady;

  end;

function StripQuotes(const s: String): String;
function StrToFloat(const Str: string; const Def: Single = 0): Single;
Function GetVector(s:String):TVector;

implementation
uses objects,windows;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;


function StripQuotes(const s: String): String;
begin

  Result := s;
  if (Result[1] = '''') or (Result[1] = '"') then
    Delete(Result, 1, 1);

  if (Result[Length(Result)] = '''') or (Result[Length(Result)] = '"') then
    Delete(Result, Length(Result), 1);

end;

constructor TTokenStream.Create(filename: String);
var f:file of byte;
begin

  inherited Create;

  FSeparators := [
        #9,       // Tab
        #10,      // LF
        #13,      // CR
        ' '       // Space
      ];
  FOpenBracket := '{';
  FCloseBracket := '}';

  if filename <> '' then

  if FileExists(filename) then
  begin
    assignfile(f,filename);
    reset(f);
      SetLength(   ftext   ,filesize(f)+1);
      Blockread(f, ftext[1],filesize(f)  );
      closefile(f);
  end
      else
  begin
    MessageBox(0,Pchar( 'File not found:'+#13+ FileName ), '',0);
  end;

  FPosition := 1;
  FBrackets := 0;

end;

function TTokenStream.GetNextToken: String;
var
  res: String;
  n: Integer;
begin

  n := Length(FText);

  while (FPosition <= n) and (FText[FPosition] in FSeparators) do INC(FPosition);

  res := '';
  while (FPosition <= n) and (not (FText[FPosition] in FSeparators)) do
  begin
    res := res + FText[FPosition];
    INC(FPosition);
  end;
          {
  if res = FOpenBracket then INC(FBrackets)
  else if res = FCloseBracket then DEC(FBrackets);

  if FBrackets < 0 then
  begin
    result:='';
    exit;
  end;}
{     raise
        Exception.Create('Brackets do not match!');}

  Result := res;

end;

procedure TTokenStream.SkipLine;
const
  LINE_BREAK: TSetOfChar = [ #10, #13 ];
var
  n: Integer;
begin

  n := Length(FText);
  while (FPosition <= n) and (not (FText[FPosition] in LINE_BREAK)) do INC(FPosition);

end;

constructor TConfig.Create(FileName : String);
var
 src : TTokenStream;
 tok,
 str : string;
 i2:integer;
const
  WHITESPACE: set of Char = [ #9, #10, #13, ' ' ];
begin
 inherited Create;
 FReady:=false;
 if not FileExists(FileName) then
 begin
  WriteLN('file not found :' , FileName);
  exit;
 end;

 src := TTokenStream.Create( FileName );

        tok := src.GetNextToken;

  while tok <> '' do
  begin
              if tok = '//' then
              begin
                // Skip comment line.
                src.Separators := [ #10, #13 ];
                src.GetNextToken;
                src.Separators := WHITESPACE;
              end
                  else
              if tok[1] = '"' then
              begin
                i2 := Length(Attribs);
                   SetLength(Attribs,i2+1);
                // Read attribute.
                   str := tok;
                   while tok[Length(tok)] <> '"' do
                   begin
                     tok := src.GetNextToken;
                     str := str + ' ' + tok;
                   end;

                   Attribs[i2][0] := Copy(str, 2, length(str)-2);
                   tok := src.GetNextToken;

                   str := tok;
                   while tok[Length(tok)] <> '"' do
                   begin
                     tok := src.GetNextToken;
                     str := str + ' ' + tok;
                   end;
                   Attribs[i2][1] := Copy(str, 2, length(str)-2);
              end;
              tok := src.GetNextToken;
  end;

  src.Destroy;
  FReady:=true;
end;

Function TConfig.GetString;
 var i :integer;
 begin
 if not FReady then exit;

  for I := 0 to high(attribs) do
  if AnsiUpperCase(attribs[i][0]) = AnsiUpperCase(s) then
      begin
       result:= attribs[i][1];
       exit;
      end;
      result:=def;
end;
//    Function GetFloat  (const s:String; const def : single = 0 ):Single;
Function TConfig.GetFloat;
begin
 if not FReady then exit;
    Result := StrToFloat( GetString(s, ''),def);
end;

Function TConfig.GetInt;
begin
 if not FReady then exit;
    Result := Round( StrToFloat( GetString(s, ''),def) );
end;


function StrToFloat(const Str: string; const Def: Single = 0): Single;
var
  Code : Integer;
begin
  Val(Str, Result, Code);
  if Code <> 0 then
    Result := Def;
end;

 Function GetVector(s:String):TVector;
 var
  i,i2,
  c1,c2 : integer;
  A: Array [0..2] of single;
  R: ^TVector;
 begin
  A[0] := 0;
  A[1] := 0;
  A[2] := 0;

  i  := 1;
  i2 := 0;
  c2 := length(s);

  while (i<=C2) do
  begin
          c1 := i;
          While (s[i]<>' ') and (i<=c2) do inc(i);
          A[i2] := StrToFloat( Copy(s,c1,i-c1));
          inc(i2);
          if i2 > 2 then break;
          inc(i);
  end;

  R := @A;
  Result:=r^;
 end;

end.
