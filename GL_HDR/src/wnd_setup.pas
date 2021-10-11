Unit WND_Setup;
{
 Made by : SVSD_VAL
 Site    : http://rtbt.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@Jabber.ru
}

Interface
{$Warnings off}
uses
  windows,messages;

  var
// Выбранные опции
    Options : Record
      Width,
      Height,
      Bpp,
      Freq        : Integer;
      DDeviceName : String;
      FullScreen,
      VSync       : boolean;
      WndPOS      : TRect;
      Lights      : Integer;
    end;

// 1. Создание окна настроек
Procedure CreateSetup;
// 2. Если есть галочька полного экрана, выполнится переход в полный экран
Procedure SetFullScreen;
// 3. Возвращение назад всех настроект :)
Procedure RestoreScreen;

Implementation

Procedure SetFullScreen;
var
  D : TDeviceMode;
begin
  if not Options.fullscreen then
  exit;

  ZeroMemory(@d, SizeOf(d));
  with d do
  begin
    dmSize             := SizeOf(d);
    dmPelsWidth        := Options.width;
    dmPelsHeight       := Options.height;
    dmBitsPerPel       := Options.bpp;
    dmDisplayFrequency := Options.FReq;
    dmFields           := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT
                       or DM_DISPLAYFLAGS or DM_DISPLAYFREQUENCY;
   end;
    ChangeDisplaySettingsEx( @Options.DDeviceName[1] , D , 0 ,CDS_FullScreen,0);
end;

Procedure RestoreScreen;
begin
  if not Options.fullscreen then exit;
    ChangeDisplaySettingsEx( @Options.DDeviceName[1] , DevMode(nil^) , 0 ,CDS_RESET,0);
end;

function IntToStr(Num : Integer) : String;
begin
  Str(Num, result);
end;

type
  TMonitorEnumProc = function(hm: Cardinal; dc: Cardinal; r: PRect; l: LPARAM): Boolean; stdcall;

  PMonitorInfoEx = ^TMonitorInfoEx;
  TMonitorInfoEx = record
    cbSize    : Cardinal;
    rcMonitor : TRect;
    rcWork    : TRect;
    dwFlags   : Cardinal;
    szDevice  : array[0..31] of AnsiChar;
  end;

  TMonInfo = record
    h     :  Cardinal; // хэндл окна рабочего стола
    dc    :  Cardinal; // DC рабочего стола
    r     :  TRect;    // Координаты рабочего стола
    DName : String;    // Название дисплея
  end;
var
  h_button : Array [0..4] of record
    id     : word;
    handle : Cardinal;
    used   : boolean;
    Proc   : Procedure;
  end;

  MonList  : array of TMonInfo;

  Renders  : Array of Record
    DeviceName  : String;
    DeviceString: String;
        Resolutions : Array of Record
              FWidth,
              FHeight,
              FBpp,
              FFreq : Integer;
            end;
  end;

  Done     : boolean;
  H_WND,
  RenderBox,
  ResBox,
  LightBox   : Cardinal;
  ResId,
  RenderID : Integer;



function EnumDisplayMonitors(hdc: Cardinal; lprcIntersect: PRect; lpfnEnumProc: TMonitorEnumProc;
    lData: LPARAM): Boolean; stdcall; external user32 name 'EnumDisplayMonitors';
function GetMonitorInfo(hMonitor: Cardinal; lpMonitorInfo: PMonitorInfoEx): Boolean;
         stdcall; external user32 name 'GetMonitorInfoA';

Procedure GetMonitors();

  function MonitorEnumProc(hMonitor: Cardinal; hdcMonitor: Cardinal; lprcMonitor: Cardinal; dwData: LPARAM): BOOL; stdcall;
  Type
    PRect = ^TRect;
  var
     C    : integer;
     A    : TMonitorInfoEx;
  begin
    c := High(MonList)+1; SetLength(MonList, c+1);
    MonList[c].h  := hMonitor;
    MonList[c].dc := hdcMonitor;
    MonList[c].r  := PRect(lprcMonitor)^;
    a.cbSize      := SizeOf( TMonitorInfoEx );

    GetMonitorInfo(monlist[c].h,@A);
                   monlist[c].DName :=A.szDevice;
    result := true;
  end;

begin
  EnumDisplayMonitors(0, nil, Addr(MonitorEnumProc), 0);
end;

Function GetMonRecrt( DevName:String; RID : Integer ) : TRect;
var i :integer;
begin
  for i := 0 to high(monlist) do
  if monlist[i].DName = DevName then
        begin
         result := monlist[i].r;
         exit;
        end;
  if (RID<0) or (Rid > length( Monlist )) then
  begin
    MessageBox(0,'o.O what a ???... error in GetMonRect!!',nil,Mb_ICONError);
    exit;
  end;
  result := MonList[rid].r;
end;

Procedure GetDisplayInfo;
var
 lpDisplayDevice: TDisplayDevice;
 DevMode        : TDevMode;
 i, k,x,x2      : integer;
begin
 GetMonitors;
 // Подготовка структуры lpDisplayDevice
 lpDisplayDevice.cb := sizeof(lpDisplayDevice);
 // Получение списка видеоадаптеров
 i := 0;
 SetLength(Renders,0);
 while i < length(monlist) do
  begin
  if not EnumDisplayDevices(nil, i, lpDisplayDevice, 0) then break;
  x := Length(Renders);
    SetLength(Renders,x+1);
    Renders[x].DeviceName    := lpDisplayDevice.DeviceName;
    Renders[x].DeviceString  := lpDisplayDevice.DeviceString;
    Inc(i);

  k := 0;

  SetLength(Renders[x].Resolutions,0);

  while EnumDisplaySettings(lpDisplayDevice.DeviceName , k, DevMode) do
  begin
   inc(k);
      if (DevMode.dmBitsPerPel<16) or
         (DevMode.dmDisplayFrequency < 60) then continue;

   x2 := Length(Renders[x].Resolutions);
      SetLength(Renders[x].Resolutions,x2+1);
           With Renders[x].Resolutions[x2] do
             begin
              FWidth := DevMode.dmPelsWidth;
              FHeight:= DevMode.dmPelsHeight;
              FBPP   := DevMode.dmBitsPerPel;
              FFreq  := DevMode.dmDisplayFrequency;
             end;
  end;

 end;

 RenderID:=0;
 ResID   :=0;
end;

Function AddButton(Caption: PChar; X,Y,W,H:Word; Flags : Cardinal; P:Pointer): cardinal;
var i :integer;
begin
for i := 0 to high(h_button) do
with h_button[i] do
  if not used  then
  begin
     id     := 1+i;
     used   := true;
     Proc   := p;
     handle := CreateWindowExA(0 ,'BUTTON', Caption,
                                  WS_VISIBLE or WS_CHILD or flags,// без multiline - однострочный ввод
                                  x, y, w, h, h_wnd, id, 0, nil);
     SendMessage( handle, WM_SETFONT, GetStockObject( ANSI_VAR_FONT ), 0 );
     Result := handle;
   exit;
 end;

end;

Procedure UpdateResList ( RIndex: Integer );
var i , c : integer;
begin
  if (RIndex <0) or (RIndex>High(renders)) then exit;

              c := SendMessage( ResBox, CB_GETCOUNT, 0, 0);
              for i := 0 to c-1 do
              SendMessage( ResBox, CB_DELETESTRING, 0, 0);

              with renders[ RIndex ] do
              for i :=0 to high(Resolutions) do
              SendMessage( ResBox, CB_ADDSTRING, 0, Integer( PChar(
               IntToStR( Resolutions[i].fWidth  ) + 'x'+
               IntToStR( Resolutions[i].fHeight ) + 'x'+
               IntToStR( Resolutions[i].fBPP    ) + 'x'+
               IntToStR( Resolutions[i].fFreq   )
                )) );
  SendMessage(ResBox, CB_SETCURSEL, 0, 0);
end;

function WndProc(Wnd:Cardinal;Msg,wParam,lParam:Integer):Integer;stdcall;
var i :integer;
begin
  Result:=0;
	case msg of
    WM_COMMAND :
    begin
     for i := 0 to high(h_button) do
     if h_button[i].used  then
       if h_button[i].id = WORD(wParam) then
          if (wParam shr 16) = BN_CLICKED then // код уведомления о нажатии кнопки
            if @h_button[i].proc <> nil then
                h_button[i].proc;


       if (HIWORD(wParam)=CBN_SELENDOK) then
        begin
         i := SendMessage( lParam, CB_GETCURSEL, 0, 0);

           if lparam=RenderBox then
           begin
              RenderID := I;
            UpdateResList(i);
           end else ResId := I;
        end




    end;
    WM_CREATE: ;
    WM_CLOSE : PostQuitMessage(0);
    else Result := DefWindowProcA(Wnd,Msg,wParam,LParam);
  end;
end;

function CreateComboBox(id,x,y,w,h:Integer):Cardinal;
var i :integer;
begin
 Result := CreateWindowExA(0,'COMBOBOX', nil,
    WS_CHILD or WS_VISIBLE or CBS_DROPDOWNLIST or CBS_AUTOHSCROLL or WS_VSCROLL,
    x, y, w, h, h_wnd,
    id, // идентификатор ComboBox - при посылке сообщения CBN_SELCHANGE передаётся в LOWORD(wParam)
    0, nil);
 SendMessage( Result, WM_SETFONT, GetStockObject( ANSI_VAR_FONT ), 0 );
 case id of
   1 :
      for i :=0 to high(renders) do
        SendMessage(Result, CB_ADDSTRING, 0, Integer( PChar( Renders[i].DeviceString + Renders[i].DeviceName )) );
   3 :
     for i := 1 to 4 do
        SendMessage(Result, CB_ADDSTRING, 0, Integer( PChar( 'lights per pass '+Inttostr(i) )) );

 end;
 SendMessage(Result, CB_SETCURSEL, 0, 0);
end;

Procedure CreateSetup;
var
  msg         : TMsg;
  Wnd         : TWndClassEx;
const
  PrjName     = '-=Setup=-';
  WndName     = 'Setup window';

  Procedure btn_exit;
  begin
   halt;
  end;

  Procedure btn_go;
  begin
   done := true;
  end;

const
  SWidth      : word = 280;
  SHeight     : word = 160;
  check_box   = 3 or WS_TABSTOP;
  var
  vsync,
  fullscr: Cardinal;
begin
  GetDisplayInfo;

  ZeroMemory(@wnd, SizeOf(wnd));
  with Wnd do
  begin
    Style         := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc   := @WndProc;
    lpszClassName := PrjName;
    cbSize        := SizeOf(wnd);
    hbrBackground := COLOR_BTNSHADOW;
  end;

  RegisterClassExA(Wnd);
    H_WND := CreateWindowExA( 8 ,PrjName,WndName,WS_VISIBLE,
              GetSystemMetrics(SM_CXSCREEN) div 2 - swidth div 2,
              GetSystemMetrics(SM_CYSCREEN) div 2 - sheight div 2,swidth,sheight,0,0,0,nil);

  AddButton('Go !'       ,swidth-160  ,100  ,70 ,20, 0,@btn_go);
  AddButton('Quit'       ,swidth-85   ,100  ,70 ,20, 0,@btn_exit);
 fullscr:= AddButton('FullScreen',10  ,65  ,70,20, check_box,nil);
 vsync:= AddButton('VSync'     ,90  ,65  ,70,20, check_box,nil);
  AddButton('Graphic'   ,5   ,5   ,Swidth-15,85, BS_GROUPBOX or WS_TABSTOP,nil);


  RenderBox := CreateComboBox(1, 10,20,SWidth-25,100);
  ResBox    := CreateComboBox(2, 10,40,SWidth-25,100);
  LightBox  := CreateComboBox(3, 10,100,105,100);


  UpdateResList(0);

  SetForeGroundWindow(h_wnd);
  SetFocus(h_wnd);
  ShowWindow(h_Wnd,SW_SHOW);

  Done  := false;

  while Done=FALSE do
   if (PeekMessageA(msg, 0, 0, 0, PM_REMOVE)) then
 		begin
    	TranslateMessage(Msg);
 			DispatchMessageA(Msg);
 		end;
    RenderID           :=  SendMessage( RenderBox, CB_GETCURSEL, 0, 0);
    ResID              :=  SendMessage( ResBox   , CB_GETCURSEL, 0, 0);
    Options.Lights     :=  SendMessage( LightBox , CB_GETCURSEL, 0, 0)+1;
    Options.VSync      :=  Boolean(SendMessage( vsync , BM_GETCHECK , 0, 0));
    Options.FullScreen :=  Boolean(SendMessage( fullscr, BM_GETCHECK , 0, 0));

  DestroyWindow      (H_Wnd);
  UnRegisterClassA(PRJName,0);

  with Renders [ RenderID ] do
  with Resolutions[ ResID ] do
  begin
    options.Width         := fWidth;
    options.Height        := fHeight;
    options.Freq          := fFreq;
    options.BPP           := fBpp;
    options.WndPos        := GetMonRecrt(DeviceName, RenderID);
    options.DDeviceName   := DeviceName;
  end;
  SetLength(Renders,0);
  SetLength(MonList,0);
end;


end.
