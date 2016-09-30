unit OC_FadingCredits;

// ******************************************************** //
// *                                                      * //
// * TFadingCredits - Scrolling credits that fade in the  * //
// *                  margins.                            * //
// *                                                      * //
// * Version - 2.0 (11/8/2002)                            * //
// *                                                      * //
// * Created by Carmi Grushko,                            * //
// *   sf_yourshadow@bezeqint.net                         * //
// *                                                      * //
// * Free for any use (commercial and non-commercial),    * //
// * as long as I'm properly credited.                    * //
// *                                                      * //
// ******************************************************** //
//
// History :
// ---------
// v. 2.0     -    11/8/2002
// -------------------------
// Much less memory and much better
// design-time support.
//
// v. 1.0     -    12/7/2002
// -------------------------
// First release.
//

interface

uses
  Windows, Controls, Graphics, Classes, Messages, SysUtils, Math,
  ExtCtrls;

type
  TRGB = record
    r, g, b: byte;
  end;

  TAutoScrollThread = class(TThread)
  private
    FLastTickCount: integer;
    FInterval: integer;
    FMethod: TThreadMethod;
  public
    procedure Execute; override;
  end;

  TZMSScroller = class(TCustomControl)
  private
    FLines: TStrings; // Strings to be displayed
    FBuffer: TBitmap; // Double-buffering to reduce flicker
    FTextRGB, FBgRGB: TRGB; // RGB representations of colors selected by
    // the user
    FClipRgn: HRGN; // Clipping region, used so that the margin
    // area of the canvas will not be drawen with
    // unprocessed parts of FTextBmp (see Paint)
    FOffsetY: integer; // Y coordinate of FTextBmp, relative to Self
    FMargin: integer; // Height in pixels of the fading area
    FIndent: integer; // Indentation to the right of display
    FThread: TAutoScrollThread;
    // Scrolling support
    FDown: boolean;
    FLastY: integer;
    FMouseInControl: boolean;
    FInterval: integer;
    // Internal
    FTextHeight: integer;
    FTextWidth: integer;

    // Property support
    function GetBgColor: TColor;
    function GetTextColor: TColor;
    procedure SetBgColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetOffsetY(const Value: integer);
    procedure SetMargin(const Value: integer);
    procedure SetLines(const Value: TStrings);

    // Painting support
    procedure ProcessRow(y: integer; P: double);

    // Auto-scroll support
    procedure DoAutoScroll;
    procedure SetIndent(const Value: integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure DrawText(Target: TCanvas);
    procedure ReCreateSupports(AWidth, AHeight: word);
  protected
    procedure Paint; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OffsetY: integer read FOffsetY write SetOffsetY;
  published
    property Lines: TStrings read FLines write SetLines;
    property TextColor: TColor read GetTextColor write SetTextColor;
    property BgColor: TColor read GetBgColor write SetBgColor;
    property Margin: integer read FMargin write SetMargin;
    property Indent: integer read FIndent write SetIndent;
    property Interval: integer read FInterval write FInterval;
  end;

  // Color and RGB support
function RgbToColor(RGB: TRGB): TColor;
function ColorToRgb(Color: TColor): TRGB;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSScroller]);
end;

function RgbToColor(RGB: TRGB): TColor;
begin
  with RGB do
    Result := r or (g shl 8) or (b shl 16);
end;

function ColorToRgb(Color: TColor): TRGB;
begin
  with Result do
  begin
    r := Color and $0000FF shr 0;
    g := Color and $00FF00 shr 8;
    b := Color and $FF0000 shr 16;
  end;
end;

{ TZMSScroller }

procedure TZMSScroller.CMMouseEnter(var Message: TMessage);
begin
  if not FDown then
    FThread.Suspend;
  FMouseInControl := true;
end;

procedure TZMSScroller.CMMouseLeave(var Message: TMessage);
begin
  if not FDown then
    FThread.Resume;
  FMouseInControl := false;
end;

constructor TZMSScroller.Create(AOwner: TComponent);
begin
  inherited;

  // Creating auxilary bitmaps
  FBuffer := TBitmap.Create;
  with FBuffer do
  begin
    Width := Self.Width;
    Height := Self.Height;
    PixelFormat := pf24Bit;
    Dormant;
  end;

  TextColor := clWhite;
  BgColor := clBlack;

  FMargin := 50;
  FOffsetY := 0;
  FIndent := 10;
  FInterval := 10;
  FLines := TStringList.Create;

  FThread := TAutoScrollThread.Create(true);
  with FThread do
  begin
    FMethod := DoAutoScroll;
  end;

  // Should be re-created when resized
  FClipRgn := CreateRectRgn(0, FMargin, Width, Height - FMargin);

  ControlStyle := ControlStyle - [csCaptureMouse];

  Width := 300;
  Height := 200;
end;

procedure TZMSScroller.DrawText(Target: TCanvas);
var
  i, h, w: integer;
  Size: TSize;
begin
  // Drawing text into Bitmap, using TextColor and BgColor
  with Target do
  begin
    h := FOffsetY;
    w := 0;

    for i := 0 to FLines.Count - 1 do
    begin
      if FLines[i] <> '' then
      begin
        TextOut(FIndent, h, FLines[i]);
        Size := TextExtent(FLines[i]);
        inc(h, Size.cy);
        if Size.cx > w then
          w := Size.cx;
      end
      else
      begin
        inc(h, TextHeight('.'));
      end;
    end;
  end;
  FTextHeight := h - OffsetY;
  FTextWidth := w + FIndent;
end;

destructor TZMSScroller.Destroy;
begin
  FThread.Suspend;
  FThread.Free;

  FBuffer.Free;
  DeleteObject(FClipRgn);
  FLines.Free;
  inherited;
end;

procedure TZMSScroller.DoAutoScroll;
begin
  dec(FOffsetY);
  Paint;

  if FOffsetY < -FTextHeight - 100 then
    FOffsetY := Height;
end;

function TZMSScroller.GetBgColor: TColor;
begin
  Result := RgbToColor(FBgRGB);
end;

function TZMSScroller.GetTextColor: TColor;
begin
  Result := RgbToColor(FTextRGB);
end;

procedure TZMSScroller.Loaded;
var
  Msg: TWMSize;
begin
  inherited;
  OffsetY := Height; // FTextBmp.Height;
  FThread.FInterval := FInterval;
  if not(csDesigning in ComponentState) then
    FThread.Resume;
  Msg.Width := Width;
  Msg.Height := Height;
  WMSize(Msg);
end;

procedure TZMSScroller.Paint;
var
  y: integer;
begin
  if (Height = 0) or (Width = 0) or (csLoading in ComponentState) then
    exit;

  with FBuffer do
  begin
    // Clearing background to BgColor
    Canvas.FillRect(Rect(0, 0, Self.Width, Self.Height));

    // Copying unprocessed portion of TextBitmap into Canvas
    DrawText(Canvas);

    if ((FTextHeight + FOffsetY) > 0) and (FOffsetY < FMargin) then
    begin
      // We have Upper Band to process
      for y := Max(-FOffsetY, 0) to Min((FMargin - FOffsetY), FTextHeight) - 1 do
      begin
        ProcessRow(y + FOffsetY, (y + FOffsetY) / FMargin);
      end;
    end;

    if ((FTextHeight + FOffsetY) > Height - FMargin) and (FOffsetY < Height) then
    begin
      // We have Lower Band to process
      for y := Max(Height - FMargin - FOffsetY, 0) to Min(Height - FOffsetY, FTextHeight) - 1 do
      begin
        ProcessRow(y + OffsetY, (Height - y - OffsetY) / Margin);
      end;
    end;
  end;

  Canvas.Draw(0, 0, FBuffer);
end;

procedure TZMSScroller.ProcessRow(y: integer; P: double);
var
  x: integer;
  Lines: PByteArray;
begin
  Lines := FBuffer.ScanLine[y];

  x := FIndent * 3;
  while (x < FTextWidth * 3) do
  begin
    if Lines[x] = FTextRGB.b then
      if Lines[x + 1] = FTextRGB.g then
        if Lines[x + 2] = FTextRGB.r then
        begin
          Lines[x] := round(FTextRGB.b * P + FBgRGB.b * (1 - P));
          Lines[x + 1] := round(FTextRGB.g * P + FBgRGB.g * (1 - P));
          Lines[x + 2] := round(FTextRGB.r * P + FBgRGB.r * (1 - P));
        end;

    inc(x, 3);
  end;
end;

procedure TZMSScroller.SetBgColor(const Value: TColor);
begin
  FBgRGB := ColorToRgb(Value);
  FBuffer.Canvas.Brush.Color := Value;
end;

procedure TZMSScroller.SetIndent(const Value: integer);
begin
  FIndent := Value;
  Paint;
end;

procedure TZMSScroller.SetLines(const Value: TStrings);
begin
  if Value <> FLines then
  begin
    FLines.Assign(Value);
    Paint;
  end;
end;

procedure TZMSScroller.SetMargin(const Value: integer);
begin
  FMargin := Value;
  Paint;
end;

procedure TZMSScroller.SetOffsetY(const Value: integer);
begin
  FOffsetY := Value;
  Paint;
end;

procedure TZMSScroller.SetTextColor(const Value: TColor);
begin
  FTextRGB := ColorToRgb(Value);
  FBuffer.Canvas.Font.Color := Value;
end;

procedure TZMSScroller.WMLButtonDown(var Message: TWMLButtonDown);
begin
  FDown := true;
  FLastY := Message.YPos;
  Mouse.Capture := Handle;
end;

procedure TZMSScroller.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FDown := false;
  Mouse.Capture := 0;
  if not FMouseInControl then
    FThread.Resume;
end;

procedure TZMSScroller.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if FDown then
  begin
    inc(FOffsetY, Message.YPos - FLastY);
    FLastY := Message.YPos;
    Paint;
  end;
end;

procedure TZMSScroller.WMSize(var Message: TWMSize);
begin
  ReCreateSupports(Message.Width, Message.Height);
  Paint;
end;

procedure TZMSScroller.ReCreateSupports(AWidth, AHeight: word);
begin
  // Clip Region update
  DeleteObject(FClipRgn);
  FClipRgn := CreateRectRgn(0, FMargin, AWidth, AHeight - FMargin);

  // FBuffer and FTextBmp update
  with FBuffer do
  begin
    Width := AWidth;
    Height := AHeight;
  end;
end;

{ TAutoScrollThread }

procedure TAutoScrollThread.Execute;
var
  t: integer;
begin
  FLastTickCount := GetTickCount;
  FreeOnTerminate := true;
  Priority := tpIdle;

  while (not Terminated) do
  begin
    t := GetTickCount;
    if t - FLastTickCount >= FInterval then
    begin
      FLastTickCount := t;
      Synchronize(FMethod);
    end;
  end;
end;

end.
