unit OC_Magnetic;

{ ********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby90@mail.ru            |
  |            mail: support@zubymplayer.com   |
  |            web : http://zubymplayer.com    |
  |            Kazakhstan, Semey, 2010         |
  ********************************************* }

interface

uses
  Windows, SysUtils, Messages;

type
  PWnd_Info = ^TWnd_Info;

  TWnd_Info = record
    h_wnd: HWND;
    hWndParent: HWND;
    Glue: Boolean;
  end;

  TSubClass_Proc = function(lng_hWnd: HWND; uMsg: Integer; var Msg: TMessage;
    var bHandled: Boolean): Boolean;

  TMagnetic = class(TObject)
    constructor Create;
    destructor Destroy; override;
  private
    FSnapWidth: Integer;
    m_uWndInfo: array of TWnd_Info;
    m_rcWnd: array of TRect;
    m_lWndCount: Integer;
    m_ptAnchor: TPoint;
    m_ptOffset: TPoint;
    m_ptCurr: TPoint;
    m_ptLast: TPoint;
    function GetSnapWidth: Integer;
    procedure SetSnapWidth(const Value: Integer);
    procedure pvSizeRect(Handle: HWND; var rcWnd: TRect; lfEdge: Integer);
    procedure pvMoveRect(Handle: HWND; var rcWnd: TRect);
    procedure pvCheckGlueing;
    function pvWndsConnected(rcWnd1: TRect; rcWnd2: TRect): Boolean;
    function pvWndGetInfoIndex(Handle: HWND): Integer;
    function pvWndParentGetInfoIndex(hWndParent: HWND): Integer;
    procedure zSubclass_Proc(lng_hWnd: HWND; uMsg, wParam, lParam: Integer;
      var lReturn: Integer; var bHandled: Boolean);
  public
    function AddWindow(Handle: HWND; hWndParent: HWND;
      var FuncPointer: TSubClass_Proc): Boolean;
    function RemoveWindow(Handle: HWND): Boolean;
    procedure CheckGlueing;
    function IsSticky(Handle: Thandle): Boolean;
    property SnapWidth: Integer read GetSnapWidth write SetSnapWidth;
  end;

const
  lb_Rect = 16;

var
  MagneticWnd: TMagnetic;

implementation

function Subclass_Proc(lng_hWnd: HWND; uMsg: Integer; var Msg: TMessage;
  var bHandled: Boolean): Boolean;
var
  int: Integer;
begin
  if Assigned(MagneticWnd) then
  begin
    int := Msg.Result;
    MagneticWnd.zSubclass_Proc(lng_hWnd, uMsg, Msg.wParam, Msg.lParam, int,
      bHandled);
    Result := true;
    Msg.Result := int;
  end
  else
    Result := false;
end;

constructor TMagnetic.Create;
begin
  // Default snap width
  SnapWidth := 10;
  // Initialize registered number of window
  m_lWndCount := 0;
end;

destructor TMagnetic.Destroy;
begin
  MagneticWnd := nil;
  SetLength(m_uWndInfo, 0); // not sure this is needed
  SetLength(m_rcWnd, 0); // not sure this is needed
  inherited;
end;

function TMagnetic.GetSnapWidth: Integer;
begin
  Result := FSnapWidth;
end;

procedure TMagnetic.SetSnapWidth(const Value: Integer);
begin
  FSnapWidth := Value;
end;

procedure TMagnetic.zSubclass_Proc(lng_hWnd: HWND;
  uMsg, wParam, lParam: Integer; var lReturn: Integer; var bHandled: Boolean);
{
  Parameters:
  lng_hWnd - The window handle
  uMsg     - The message number
  wParam   - Message related data
  lParam   - Message related data
  lReturn  - Set this variable as per your intentions and requirements, see the MSDN
  documentation or each individual message value.
  bHandled - Set this variable to True in a 'before' callback to prevent the message being
  subsequently processed by the default handler... and if set, an 'after' callback
}

{
  Notes:
  If you really know what you're doing, it's possible to change the values of the
  lng_hWnd, uMsg, wParam and lParam parameters in a 'before' callback so that different
  values get passed to the default handler.. and optionaly, the 'after' callback
}
var
  rcWnd: TRect;
  lC: Integer;
  pWINDOWPOS: ^TWINDOWPOS;
begin
  bHandled := false;
  case uMsg of
    // Size/Move starting
    WM_ENTERSIZEMOVE:
      begin
        // Get Desktop area (as first rectangle)
        SystemParametersInfo(SPI_GETWORKAREA, 0, @m_rcWnd[0], 0);
        // Get rectangles of all handled windows
        for lC := 1 to m_lWndCount do
        begin
          // Window maximized ?
          if (IsZoomed(m_uWndInfo[lC].h_wnd)) then // Take work are rectangle
            CopyMemory(@m_rcWnd[lC], @m_rcWnd[0], lb_Rect)
          else
            GetWindowRect((m_uWndInfo[lC].h_wnd), m_rcWnd[lC]);
          // Get window rectangle
          // Is it our current window ?
          if (m_uWndInfo[lC].h_wnd = lng_hWnd) then
          begin
            // Get anchor-offset
            GetCursorPos(m_ptAnchor);
            GetCursorPos(m_ptLast);
            m_ptOffset.x := m_rcWnd[lC].Left - m_ptLast.x;
            m_ptOffset.y := m_rcWnd[lC].Top - m_ptLast.y;
          end;
        end;
      end;
    // Sizing
    WM_SIZING:
      begin
        CopyMemory(@rcWnd, pointer(lParam), lb_Rect);
        pvSizeRect(lng_hWnd, rcWnd, wParam);
        CopyMemory(pointer(lParam), @rcWnd, lb_Rect);
        bHandled := true;
        lReturn := 1;
      end;
    // Moving
    WM_MOVING:
      begin
        CopyMemory(@rcWnd, pointer(lParam), lb_Rect);
        pvMoveRect(lng_hWnd, rcWnd);
        CopyMemory(pointer(lParam), @rcWnd, lb_Rect);
        bHandled := true;
        lReturn := 1;
      end;
    // Size/Move finishing
    WM_EXITSIZEMOVE:
      pvCheckGlueing;
    // at after Shown or Hidden window
    WM_WINDOWPOSCHANGED: // ************** Added
      begin
        pWINDOWPOS := pointer(lParam);
        if ((pWINDOWPOS^.flags and SWP_SHOWWINDOW) = SWP_SHOWWINDOW) or
          ((pWINDOWPOS^.flags and SWP_HIDEWINDOW) = SWP_HIDEWINDOW) then
          pvCheckGlueing;
      end;
    // Special case: *menu* call
    WM_SYSCOMMAND:
      begin
        if (wParam = SC_MINIMIZE) or (wParam = SC_RESTORE) then
          pvCheckGlueing;
      end;
    // Special case: *control* call
    WM_COMMAND:
      pvCheckGlueing;
  end;
end;

function TMagnetic.AddWindow(Handle: HWND; hWndParent: HWND;
  var FuncPointer: TSubClass_Proc): Boolean;
var
  lC: Integer;
begin
  Result := false; // assume failure
  FuncPointer := nil;
  // Already in collection ?
  for lC := 1 to m_lWndCount do
  begin
    if (Handle = m_uWndInfo[lC].h_wnd) then
      Exit;
  end;
  // Validate windows
  if IsWindow(Handle) and (IsWindow(hWndParent) or (hWndParent = 0)) then
  // ********* Changed
  begin
    // Increase count
    inc(m_lWndCount);
    // Resize arrays
    SetLength(m_uWndInfo, m_lWndCount + 1);
    SetLength(m_rcWnd, m_lWndCount + 1);
    // Add info
    m_uWndInfo[m_lWndCount].h_wnd := Handle;
    if hWndParent = Handle then
      // Parent window is Self window ?       //******** Added
      m_uWndInfo[m_lWndCount].hWndParent := 0
      // Then same to "no parent"  //******** Added
    else
      m_uWndInfo[m_lWndCount].hWndParent := hWndParent;
    // Check glueing for first time
    pvCheckGlueing;
    FuncPointer := Subclass_Proc;
    // Success
    Result := true;
  end;
end;

function TMagnetic.RemoveWindow(Handle: HWND): Boolean;
var
  lc1: Integer;
  lc2: Integer;
begin
  Result := false; // assume failure
  for lc1 := 1 to m_lWndCount do
  begin
    if (Handle = m_uWndInfo[lc1].h_wnd) then
    begin
      // Move down
      for lc2 := lc1 to (m_lWndCount - 1) do
        m_uWndInfo[lc2] := m_uWndInfo[lc2 + 1];
      // Resize arrays
      dec(m_lWndCount);
      SetLength(m_uWndInfo, m_lWndCount + 1);
      SetLength(m_rcWnd, m_lWndCount + 1);
      // Remove parent relationships
      for lc2 := 1 to m_lWndCount do
        if (m_uWndInfo[lc2].hWndParent = Handle) then
          m_uWndInfo[lc2].hWndParent := 0;
      // verify connections
      pvCheckGlueing;
      // Success
      Result := true;
      Break;
    end;
  end;
end;

function TMagnetic.IsSticky(Handle: Thandle): Boolean;
var
  lc1: Integer;
begin
  Result := false;
  for lc1 := 1 to m_lWndCount do
  begin
    if (Handle = m_uWndInfo[lc1].h_wnd) then
      Result := m_uWndInfo[lc1].Glue;
  end;
end;

procedure TMagnetic.CheckGlueing;
begin
  // Check ALL windows for possible new *connections*.
  pvCheckGlueing;
end;

procedure TMagnetic.pvSizeRect(Handle: HWND; var rcWnd: TRect; lfEdge: Integer);
var
  rcTmp: TRect;
  lC: Integer;
begin
  // Get a copy
  CopyMemory(@rcTmp, @rcWnd, lb_Rect);
  // Check all windows
  for lC := 0 to m_lWndCount do
  begin
    with m_rcWnd[lC] do
    begin
      // Avoid hidden window
      if lC <> 0 then // m_rcWnd[0] has the window rect of Desktop area
        if not IsWindowVisible(m_uWndInfo[lC].h_wnd) then
          continue; // **************** Added
      // Avoid current window
      if (m_uWndInfo[lC].h_wnd <> Handle) then
      begin
        // X magnetism.
        if (rcWnd.Top < Bottom + SnapWidth) and (rcWnd.Bottom > Top - SnapWidth)
        then
        begin
          case lfEdge of
            WMSZ_LEFT, WMSZ_TOPLEFT, WMSZ_BOTTOMLEFT:
              begin
                // Case True of
                case Abs(rcTmp.Left - Left) < SnapWidth of
                  true:
                    rcWnd.Left := Left;
                end;
                case Abs(rcTmp.Left - Right) < SnapWidth of
                  true:
                    rcWnd.Left := Right;
                end;
              end;
            WMSZ_RIGHT, WMSZ_TOPRIGHT, WMSZ_BOTTOMRIGHT:
              begin
                case Abs(rcTmp.Right - Left) < SnapWidth of
                  true:
                    rcWnd.Right := Left;
                end;
                case Abs(rcTmp.Right - Right) < SnapWidth of
                  true:
                    rcWnd.Right := Right;
                end;
              end;
          end;
        end;
        // Y magnetism
        if (rcWnd.Left < Right + SnapWidth) and (rcWnd.Right > Left - SnapWidth)
        then
        begin
          case lfEdge of
            WMSZ_TOP, WMSZ_TOPLEFT, WMSZ_TOPRIGHT:
              begin
                case Abs(rcTmp.Top - Top) < SnapWidth of
                  true:
                    rcWnd.Top := Top;
                end;
                case Abs(rcTmp.Top - Bottom) < SnapWidth of
                  true:
                    rcWnd.Top := Bottom;
                end;
              end;
            WMSZ_BOTTOM, WMSZ_BOTTOMLEFT, WMSZ_BOTTOMRIGHT:
              begin
                case Abs(rcTmp.Bottom - Top) < SnapWidth of
                  true:
                    rcWnd.Bottom := Top;
                end;
                case Abs(rcTmp.Bottom - Bottom) < SnapWidth of
                  true:
                    rcWnd.Bottom := Bottom;
                end;
              end;
          end;
        end;
      end;
    end; // end of "with m_rcWnd[lC] do"
  end; // end of "for lC := 0 to m_lWndCount do"
end;

procedure TMagnetic.pvMoveRect(Handle: HWND; var rcWnd: TRect);
var
  lc1: Integer;
  lc2: Integer;
  lWId: Integer;
  rcTmp: TRect;
  lOffx: Integer;
  lOffy: Integer;
  hDWP: Integer;
begin
  // Get current cursor position
  GetCursorPos(m_ptCurr);
  // Check magnetism for current window
  // 'Move' current window
  OffseTRect(rcWnd, (m_ptCurr.x - rcWnd.Left) + m_ptOffset.x, 0);
  OffseTRect(rcWnd, 0, (m_ptCurr.y - rcWnd.Top) + m_ptOffset.y);
  lOffx := 0;
  lOffy := 0;
  // Check all windows
  for lc1 := 0 to m_lWndCount do
  begin
    // Avoid hidden window
    if lc1 <> 0 then // m_rcWnd[0] has the window rect of Desktop area
      if not IsWindowVisible(m_uWndInfo[lc1].h_wnd) then
        continue; // **************** Added
    // Avoid current window.
    if (m_uWndInfo[lc1].h_wnd <> Handle) then
    begin
      // Avoid child windows
      if (m_uWndInfo[lc1].Glue = false) or (m_uWndInfo[lc1].hWndParent <> Handle)
      then
      begin
        with m_rcWnd[lc1] do
        begin
          // X Magnetism.
          if (rcWnd.Top < Bottom + SnapWidth) and
            (rcWnd.Bottom > Top - SnapWidth) then
          begin

            if lc1 = 0 then
            begin
              case Abs(rcWnd.Left - Left) < SnapWidth of
                true:
                  lOffx := Left - rcWnd.Left;
              end;
            end
            else
            begin
              if (Abs(rcWnd.Left - Left) < SnapWidth) and (rcWnd.Top >= Bottom)
              then
                lOffx := Left - rcWnd.Left;
            end;

            case Abs(rcWnd.Left - Right) < SnapWidth of
              true:
                lOffx := Right - rcWnd.Left;
            end;

            case Abs(rcWnd.Right - Left) < SnapWidth of
              true:
                lOffx := Left - rcWnd.Right;
            end;

            if lc1 = 0 then
            begin
              case Abs(rcWnd.Right - Right) < SnapWidth of
                true:
                  lOffx := Right - rcWnd.Right;
              end;
            end
            else
            begin
              if (Abs(rcWnd.Right - Right) < SnapWidth) and (rcWnd.Top >= Bottom)
              then
                lOffx := Right - rcWnd.Right;
            end;

          end;
          // Y Magnetism.
          if (rcWnd.Left < Right + SnapWidth) and
            (rcWnd.Right > Left - SnapWidth) then
          begin

            if lc1 = 0 then
            begin
              case Abs(rcWnd.Top - Top) < SnapWidth of
                true:
                  lOffy := Top - rcWnd.Top;
              end;
            end;

            case Abs(rcWnd.Top - Bottom) < SnapWidth of
              true:
                lOffy := Bottom - rcWnd.Top;
            end;
            case Abs(rcWnd.Bottom - Top) < SnapWidth of
              true:
                lOffy := Top - rcWnd.Bottom;
            end;

            if lc1 = 0 then
            begin
              case Abs(rcWnd.Bottom - Bottom) < SnapWidth of
                true:
                  lOffy := Bottom - rcWnd.Bottom;
              end;

            end;
          end;
        end;
      end;
    end;
  end;
  // Check magnetism for child windows
  for lc1 := 1 to m_lWndCount do
  begin
    // Avoid hidden window
    if not IsWindowVisible(m_uWndInfo[lc1].h_wnd) then
      continue; // **************** Added
    // Child and connected window ?
    if (m_uWndInfo[lc1].Glue) and (m_uWndInfo[lc1].hWndParent = Handle) then
    begin
      // 'Move' child window
      CopyMemory(@rcTmp, @m_rcWnd[lc1], lb_Rect);
      OffseTRect(rcTmp, m_ptCurr.x - m_ptAnchor.x, 0);
      OffseTRect(rcTmp, 0, m_ptCurr.y - m_ptAnchor.y);
      for lc2 := 0 to m_lWndCount do
      begin
        if (lc1 <> lc2) then
        begin
          // Avoid hidden window
          if not IsWindowVisible(m_uWndInfo[lc2].h_wnd) then
            continue; // **************** Added
          // Avoid child windows
          if (m_uWndInfo[lc2].Glue = false) and (m_uWndInfo[lc2].h_wnd <> Handle)
          then
          begin
            with m_rcWnd[lc2] do
            begin
              // X magnetism
              if (rcTmp.Top < Bottom + SnapWidth) and
                (rcTmp.Bottom > Top - SnapWidth) then
              begin
                case Abs(rcTmp.Left - Left) < SnapWidth of
                  true:
                    lOffx := Left - rcTmp.Left;
                end;
                case Abs(rcTmp.Left - Right) < SnapWidth of
                  true:
                    lOffx := Right - rcTmp.Left;
                end;
                case Abs(rcTmp.Right - Left) < SnapWidth of
                  true:
                    lOffx := Left - rcTmp.Right;
                end;
                case Abs(rcTmp.Right - Right) < SnapWidth of
                  true:
                    lOffx := Right - rcTmp.Right;
                end;
              end;
              // Y magnetism
              if (rcTmp.Left < Right + SnapWidth) and
                (rcTmp.Right > Left - SnapWidth) then
              begin
                case Abs(rcTmp.Top - Top) < SnapWidth of
                  true:
                    lOffy := Top - rcTmp.Top;
                end;
                case Abs(rcTmp.Top - Bottom) < SnapWidth of
                  true:
                    lOffy := Bottom - rcTmp.Top;
                end;
                case Abs(rcTmp.Bottom - Top) < SnapWidth of
                  true:
                    lOffy := Top - rcTmp.Bottom;
                end;
                case Abs(rcTmp.Bottom - Bottom) < SnapWidth of
                  true:
                    lOffy := Bottom - rcTmp.Bottom;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  // Apply offsets
  OffseTRect(rcWnd, lOffx, lOffy);
  // Glueing (move child windows, if any)
  hDWP := BeginDeferWindowPos(1);
  for lc1 := 1 to m_lWndCount do
  begin
    // Avoid hidden window
    if not IsWindowVisible(m_uWndInfo[lc1].h_wnd) then
      continue; // **************** Added
    with m_uWndInfo[lc1] do
      // Is parent our current window ?
      if (hWndParent = Handle) and (Glue) then
      begin
        // Move 'child' window
        lWId := pvWndGetInfoIndex(Handle);
        with m_rcWnd[lc1] do
          DeferWindowPos(hDWP, m_uWndInfo[lc1].h_wnd, 0,
            Left - (m_rcWnd[lWId].Left - rcWnd.Left),
            Top - (m_rcWnd[lWId].Top - rcWnd.Top), 0 { width } , 0 { height } ,
            // No size change
            SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
      end;
  end;
  EndDeferWindowPos(hDWP);
  // Store last cursor position
  m_ptLast := m_ptCurr;
end;

procedure TMagnetic.pvCheckGlueing;
var
  lcMain: Integer;
  lc1: Integer;
  lc2: Integer;
  lWId: Integer;
begin
  // Get all windows rectangles / Reset glueing
  for lc1 := 1 to m_lWndCount do
  begin
    GetWindowRect(m_uWndInfo[lc1].h_wnd, m_rcWnd[lc1]);
    m_uWndInfo[lc1].Glue := false;
  end;
  // Check direct connection
  for lc1 := 1 to m_lWndCount do
  begin
    if not IsWindowVisible(m_uWndInfo[lc1].h_wnd) then
      continue; // **************** Added
    if (m_uWndInfo[lc1].hWndParent <> 0) then
    begin
      // Get parent window info index
      lWId := pvWndParentGetInfoIndex(m_uWndInfo[lc1].hWndParent);
      // Connected ?
      m_uWndInfo[lc1].Glue := pvWndsConnected(m_rcWnd[lWId], m_rcWnd[lc1]);
    end;
  end;
  // Check indirect connection
  for lcMain := 1 to m_lWndCount do
  // to check the windows snapped far lower level
  begin // in multi-layer snapped structure
    for lc1 := 1 to m_lWndCount do
    begin
      // Avoid hidden window
      if not IsWindowVisible(m_uWndInfo[lc1].h_wnd) then
        continue; // **************** Added
      if (m_uWndInfo[lc1].Glue) then
      begin
        for lc2 := 1 to m_lWndCount do
        begin
          // Avoid hidden window
          if not IsWindowVisible(m_uWndInfo[lc2].h_wnd) then
            continue; // **************** Added
          if (lc1 <> lc2) then
          begin
            if (m_uWndInfo[lc1].hWndParent = m_uWndInfo[lc2].hWndParent) then
            begin
              // Connected ?
              if (m_uWndInfo[lc2].Glue = false) then
                m_uWndInfo[lc2].Glue := pvWndsConnected(m_rcWnd[lc1],
                  m_rcWnd[lc2]);
            end;
          end;
        end; // end of for lc2
      end;
    end; // end of for lc1
  end; // end of for lcMain
end;

function TMagnetic.pvWndsConnected(rcWnd1: TRect; rcWnd2: TRect): Boolean;
var
  rcUnion: TRect;
begin
  Result := false; // assume not connected
  // Calc. union rectangle of windows
  UnionRect(rcUnion, rcWnd1, rcWnd2);
  // Bounding glue-rectangle
  if ((rcUnion.Right - rcUnion.Left) <= (rcWnd1.Right - rcWnd1.Left) +
    (rcWnd2.Right - rcWnd2.Left)) and
    ((rcUnion.Bottom - rcUnion.Top) <= (rcWnd1.Bottom - rcWnd1.Top) +
    (rcWnd2.Bottom - rcWnd2.Top)) then
  begin
    // Edge coincidences ?
    if (rcWnd1.Left = rcWnd2.Left) or (rcWnd1.Left = rcWnd2.Right) or
      (rcWnd1.Right = rcWnd2.Left) or (rcWnd1.Right = rcWnd2.Right) or
      (rcWnd1.Top = rcWnd2.Top) or (rcWnd1.Top = rcWnd2.Bottom) or
      (rcWnd1.Bottom = rcWnd2.Top) or (rcWnd1.Bottom = rcWnd2.Bottom) then
      pvWndsConnected := true;
  end;
end;

function TMagnetic.pvWndGetInfoIndex(Handle: HWND): Integer;
var
  lC: Integer;
begin
  Result := -1; // assume no matched item
  for lC := 1 to m_lWndCount do
  begin
    if (m_uWndInfo[lC].h_wnd = Handle) then
    begin
      pvWndGetInfoIndex := lC;
      Break;
    end;
  end;
end;

function TMagnetic.pvWndParentGetInfoIndex(hWndParent: HWND): Integer;
var
  lC: Integer;
begin
  Result := -1; // assume no matched item
  for lC := 1 to m_lWndCount do
  begin
    if (m_uWndInfo[lC].h_wnd = hWndParent) then
    begin
      pvWndParentGetInfoIndex := lC;
      Break;
    end;
  end;
end;

end.
