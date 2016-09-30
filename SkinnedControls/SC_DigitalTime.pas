unit SC_DigitalTime;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSDigital: Компонент отображения времени |
  ********************************************* }

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, types, ExtCtrls;

type
  TZMSDigital = class(TGraphicControl)
  private
    fTimer: TTimer;
    fSkin: TBitmap;
    fBuffer: TBitmap;

    fNumbers: string;
    fReverse: boolean;

    fFading: boolean;
    fDoFading: boolean;

    fCount: Integer;
    fCounter: Integer;
    fSize: Integer;

    fTransparent: boolean;
    fTransparentColor: TColor;

    fNumRect: array [0 .. 12] of TRect;

    procedure SetNumbers(Value: string);
    procedure SetSkin(Value: TBitmap);
    procedure SetCount(Value: Integer);
    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(Value: TColor);

    procedure Morphing(Bm1, Bm2: TBitmap; Progress: Integer);
    procedure DrawBitmap(cnv: TCanvas; bmp: TBitmap);
    procedure DrawChar(c: char; RctID: Integer);
    procedure SplitBitmap;
    procedure Render(Sender: TObject);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
    procedure Click; override;
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Bitmap: TBitmap read fSkin write SetSkin;
    property Time: string read fNumbers write SetNumbers;
    property SmoothEnable: boolean read fFading write fFading default true;
    property Count: Integer read fCount write SetCount default 6;
    property Reverse: boolean read fReverse write fReverse default false;
    property Transparent: boolean read fTransparent write SetTransparent
      default false;
    property TransparentColor: TColor read fTransparentColor
      write SetTransparentColor default clFuchsia;

    property Align;
    property Hint;
    property Cursor default crHandPoint;
    property Anchors;
    property Visible;
    property ShowHint;
    property PopupMenu;
    property ParentShowHint;
    property Enabled;

    property OnClick;
    property OnDblClick;
    // property OnMouseEnter;
    // property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

procedure Register;

implementation

const
  dynammin = 0;
  dynammax = 100;

  // ******************************************************************************
procedure TZMSDigital.Morphing(Bm1, Bm2: TBitmap; Progress: Integer);
var
  dstPixel, srcPixel: PRGBQuad;
  Weight: Integer;
  I: Integer;
  R, G, B: Byte;
begin
  if (Assigned(Bm1) and Assigned(Bm2)) then
  begin
    if Bm1.PixelFormat <> pf32bit then
      Bm1.PixelFormat := pf32bit;
    if Bm2.PixelFormat <> pf32bit then
      Bm2.PixelFormat := pf32bit;

    srcPixel := Bm2.ScanLine[Bm2.Height - 1];
    dstPixel := Bm1.ScanLine[Bm1.Height - 1];
    Weight := MulDiv(256, Progress, 100);
    if fTransparent then
    begin
      R := GetRValue(fTransparentColor);
      G := GetGValue(fTransparentColor);
      B := GetBValue(fTransparentColor);

      for I := (Bm1.Width * Bm1.Height) - 1 downto 0 do
      begin
        with dstPixel^ do
        begin
          if not(((R = srcPixel^.rgbRed) and (G = srcPixel^.rgbGreen)) and
            (B = srcPixel^.rgbBlue)) then
          begin
            Inc(rgbRed, (Weight * (srcPixel^.rgbRed - rgbRed)) shr 8);
            Inc(rgbGreen, (Weight * (srcPixel^.rgbGreen - rgbGreen)) shr 8);
            Inc(rgbBlue, (Weight * (srcPixel^.rgbBlue - rgbBlue)) shr 8);
          end;
        end;
        Inc(srcPixel);
        Inc(dstPixel);
      end
    end
    else
    begin
      for I := (Bm1.Width * Bm1.Height) - 1 downto 0 do
      begin
        with dstPixel^ do
        begin
          Inc(rgbRed, (Weight * (srcPixel^.rgbRed - rgbRed)) shr 8);
          Inc(rgbGreen, (Weight * (srcPixel^.rgbGreen - rgbGreen)) shr 8);
          Inc(rgbBlue, (Weight * (srcPixel^.rgbBlue - rgbBlue)) shr 8);
        end;
        Inc(srcPixel);
        Inc(dstPixel);
      end
    end
  end
end;

// ******************************************************************************
procedure TZMSDigital.DrawBitmap(cnv: TCanvas; bmp: TBitmap);
var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  try
    bmpAND := TBitmap.Create;
    bmpAND.Width := bmp.Width;
    bmpAND.Height := bmp.Height;
    bmpAND.Monochrome := true;
    oldcol := SetBkColor(bmp.Canvas.Handle, ColorToRGB(fTransparentColor));
    BitBlt(bmpAND.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    SetBkColor(bmp.Canvas.Handle, oldcol);

    bmpINVAND := TBitmap.Create;
    bmpINVAND.Width := bmp.Width;
    bmpINVAND.Height := bmp.Height;
    bmpINVAND.Monochrome := true;
    BitBlt(bmpINVAND.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, NOTSRCCOPY);

    bmpXOR := TBitmap.Create;
    bmpXOR.Width := bmp.Width;
    bmpXOR.Height := bmp.Height;
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpINVAND.Canvas.Handle, 0, 0, SRCAND);

    bmpTarget := TBitmap.Create;
    bmpTarget.Width := bmp.Width;
    bmpTarget.Height := bmp.Height;
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, cnv.Handle, 0,
      0, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
      bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    BitBlt(cnv.Handle, 0, 0, bmp.Width, bmp.Height, bmpTarget.Canvas.Handle, 0,
      0, SRCCOPY);
  finally
    freeAndNil(bmpXOR);
    freeAndNil(bmpAND);
    freeAndNil(bmpINVAND);
    freeAndNil(bmpTarget);
  end;
end;

// ******************************************************************************
procedure TZMSDigital.Click;
begin
  inherited;
  fReverse := not fReverse;
  Paint;
end;

// ******************************************************************************
procedure TZMSDigital.Render;
var
  I: Integer;
  dynam: TBitmap;
begin
  if (Length(fNumbers) = fCount) then
  begin
    if (fFading and fDoFading) then
    begin
      dynam := TBitmap.Create;
      dynam.Width := Width;
      dynam.Height := Height;
      BitBlt(dynam.Canvas.Handle, 0, 0, Width, Height, fBuffer.Canvas.Handle, 0,
        0, SRCCOPY);
    end;

    for I := 0 to 10 do
      DrawChar(fNumbers[I + 1], I);

    if (fFading and fDoFading) then
    begin
      dec(fCounter, 5);
      Morphing(fBuffer, dynam, fCounter);
      freeAndNil(dynam);
    end;

    Canvas.Draw(0, 0, fBuffer);

    if (fCounter < dynammin) then
    begin
      fCounter := dynammax;
      fDoFading := false;
      fTimer.Enabled := fDoFading;
    end;
  end;
end;

// ******************************************************************************
procedure TZMSDigital.DrawChar(c: char; RctID: Integer);
begin
  with fBuffer do
  begin
    case c of
      '0':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[0]);
      '1':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[1]);
      '2':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[2]);
      '3':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[3]);
      '4':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[4]);
      '5':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[5]);
      '6':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[6]);
      '7':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[7]);
      '8':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[8]);
      '9':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[9]);
      ':':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[10]);
      '-':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[11]);
      ' ':
        Canvas.CopyRect(fNumRect[RctID], fSkin.Canvas, fNumRect[12]);
    end;
  end;
end;

// ******************************************************************************
procedure TZMSDigital.SplitBitmap;
begin
  SetRect(fNumRect[0], 0, 0, fSize, fSkin.Height); // 0
  SetRect(fNumRect[1], fSize, 0, fSize * 2, fSkin.Height); // 1
  SetRect(fNumRect[2], fSize * 2, 0, fSize * 3, fSkin.Height); // 2
  SetRect(fNumRect[3], fSize * 3, 0, fSize * 4, fSkin.Height); // 3
  SetRect(fNumRect[4], fSize * 4, 0, fSize * 5, fSkin.Height); // 4
  SetRect(fNumRect[5], fSize * 5, 0, fSize * 6, fSkin.Height); // 5
  SetRect(fNumRect[6], fSize * 6, 0, fSize * 7, fSkin.Height); // 6
  SetRect(fNumRect[7], fSize * 7, 0, fSize * 8, fSkin.Height); // 7
  SetRect(fNumRect[8], fSize * 8, 0, fSize * 9, fSkin.Height); // 8
  SetRect(fNumRect[9], fSize * 9, 0, fSize * 10, fSkin.Height); // 9
  SetRect(fNumRect[10], fSize * 10, 0, fSize * 11, fSkin.Height); // :
  SetRect(fNumRect[11], fSize * 11, 0, fSize * 12, fSkin.Height); // -
  SetRect(fNumRect[12], fSize * 12, 0, fSize * 13, fSkin.Height); // ' '
end;

// ******************************************************************************
procedure TZMSDigital.Resize;
begin
  if not fSkin.Empty then
  begin
    fSize := fSkin.Width div 13;
    Height := fSkin.Height;
    Width := fSize * fCount;

    fBuffer.Width := Width;
    fBuffer.Height := Height;
  end
  else
    inherited;
end;

// ******************************************************************************
procedure TZMSDigital.Paint;
begin
  inherited;
  if fSkin.Empty then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Style := psDashDot;
    Canvas.Rectangle(ClientRect);
  end
  else
    Render(nil);
end;

// ******************************************************************************
procedure TZMSDigital.Loaded;
begin
  inherited;
  Resize;
  SplitBitmap;
  Paint;
end;

// ******************************************************************************
procedure TZMSDigital.SetNumbers(Value: string);
begin
  if fNumbers <> Value then
  begin
    if Length(Value) = fCount then
      fNumbers := Value;
    fDoFading := fFading;
    fCounter := dynammax;
    Resize;
    SplitBitmap;
    if fDoFading then
      fTimer.Enabled := fDoFading and fFading
    else
      Render(nil);
  end;
end;

// ******************************************************************************
procedure TZMSDigital.SetCount(Value: Integer);
begin
  if fCount <> Value then
  begin
    if (fCount <= 0) and (fCount >= 12) then
      fCount := 6;

    fCount := Value;
    case fCount of
      2:
        fNumbers := '00';
      3:
        fNumbers := '000';
      4:
        fNumbers := ' 000';
      5:
        fNumbers := '00:00';
      6:
        fNumbers := ' 00:00';
      7:
        fNumbers := '00:00:0';
      8:
        fNumbers := '00:00:00';
      9:
        fNumbers := ' 00:00:00';
      10:
        fNumbers := '  00:00:00';
      11:
        fNumbers := '00:00:00:00';
    end;
    Resize;
    SplitBitmap;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSDigital.SetTransparent(Value: boolean);
begin
  if fTransparent <> Value then
  begin
    // ParentBackground := Value;
    fTransparent := Value;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSDigital.SetTransparentColor(Value: TColor);
begin
  if fTransparentColor <> Value then
  begin
    fTransparentColor := Value;
    Paint;
  end;
end;

// ******************************************************************************
procedure TZMSDigital.SetSkin(Value: TBitmap);
begin
  fSkin.Assign(Value);
  fBuffer.Assign(Value);
  if (Value.Width mod 13 = 0) then
  begin
    Resize;
    SplitBitmap;
    Paint;
  end;
end;

// ******************************************************************************
constructor TZMSDigital.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  // ParentColor := false;
  // Color := clWhite;
  Cursor := crHandPoint;

  // ControlStyle := ControlStyle + [csOpaque];
  // Height := 20;
  // Width := 90;

  fSkin := TBitmap.Create;
  fBuffer := TBitmap.Create;

  fTimer := TTimer.Create(nil);
  fTimer.Enabled := false;
  fTimer.Interval := 25;
  fTimer.OnTimer := Render;

  fFading := true;
  fDoFading := false;
  fReverse := false;
  fCount := 6;
  fSize := 15;
  fCounter := dynammax;
  fNumbers := ' 00:00';

  fTransparent := false;
  fTransparentColor := clFuchsia;
end;

// ******************************************************************************
destructor TZMSDigital.Destroy;
begin
  freeAndNil(fSkin);
  freeAndNil(fBuffer);
  freeAndNil(fTimer);
  inherited Destroy;
end;

// ******************************************************************************
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSDigital]);
end;

end.
