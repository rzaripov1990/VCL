unit SC_TrackBarEx;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  ********************************************* }

interface

uses
  Windows, SysUtils, Classes, Controls, Messages, Graphics;

type
  TThumbSlide = (tbMoving, tbUp);
  TOrientationKind = (okHorizontal, okVertical);
  TTrackingPos = procedure(Sender: TObject; const Position: Single;
    const SetPosition: boolean) of object;

  TZMSTrackBar = class(TGraphicControl)
  private
    { Private declarations }
    fBuffer: TBitmap;
    fBufferThmb: TBitmap;

    fFocusMouse: boolean;
    fMouseDown: boolean;

    fEnabled: boolean;
    fReverse: boolean;
    fStretch: boolean;

    fTransparent: boolean;
    fTransparentColor: TColor;

    fSkin: TBitmap;
    // fSkinProgress: TBitmap;
    fSkinThumb: TBitmap;

    fLength: Single;
    fPosInLen: Single;

    fMax: Single;
    fMin: Single;
    fPosition: Single;

    fOnEnd: TNotifyEvent;
    fOnRightClick: TNotifyEvent;
    fOnTracking: TTrackingPos;
    fOnStartTracking: TTrackingPos;
    fOnEndTracking: TTrackingPos;

    fThumbSlide: TThumbSlide;
    fStanding: TOrientationKind;

    fCenterPos: Single;
    fCenterStop: boolean;

    fShowThumb: boolean;

    fSnapActive: boolean;
    fSnapPosition: Single;
    fSnapBuffer: Single;
    fSnapPosInLen: Single;

    fWorkingArea: Single;
    fDrawPosFade: Single;
    fDrawPos: Single;

    procedure CalculateLen;
    procedure CalculatePos(BufPos: Single);
    function CalculatePosFade(BufPos: Single): Single;

    function VerifPosFade(Value: Single): Single;

    procedure Morphing(Bm1, Bm2: TBitmap; Progress: Integer);
    procedure RotateBitmap(Bitmap: TBitmap);

    procedure SetEnable(Value: boolean);
    procedure SetReverse(Value: boolean);
    procedure SetStretch(Value: boolean);

    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(Value: TColor);
    procedure SetSnapActive(Value: boolean);
    procedure SetSnapPosition(Value: Single);
    procedure SetSnapBuffer(Value: Single);
    procedure SetShowThumb(Value: boolean);
    procedure SetStanding(Value: TOrientationKind);
    procedure SetThumbSlide(Value: TThumbSlide);
    procedure SetMax(Value: Single);
    procedure SetMin(Value: Single);
    procedure SetPosition(Value: Single);
    procedure SetSkin(Value: TBitmap);
    procedure SetSkinThumb(Value: TBitmap);
  protected
    { Protected declarations }

    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure Renderer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Background: TBitmap read fSkin write SetSkin;
    property Thumbler: TBitmap read fSkinThumb write SetSkinThumb;

    property Maximum: Single read fMax write SetMax;
    property Minimum: Single read fMin write SetMin;
    property Position: Single read fPosition write SetPosition;

    property CenterPos: Single read fCenterPos write fCenterPos;
    property CenterStop: boolean read fCenterStop write fCenterStop
      default false;

    property SnapActive: boolean read fSnapActive write SetSnapActive
      default false;
    property SnapPosition: Single read fSnapPosition write SetSnapPosition;
    property SnapBuffer: Single read fSnapBuffer write SetSnapBuffer;
    property ShowThumbler: boolean read fShowThumb write SetShowThumb
      default True;
    property Kind: TOrientationKind read fStanding write SetStanding
      default okHorizontal;
    property ThumblerSlide: TThumbSlide read fThumbSlide write SetThumbSlide
      default tbMoving;

    property Enabled: boolean read fEnabled write SetEnable default True;
    property Reverse: boolean read fReverse write SetReverse default false;
    property Stretch: boolean read fStretch write SetStretch default false;

    property Transparent: boolean read fTransparent write SetTransparent
      default false;
    property TransparentColor: TColor read fTransparentColor
      write SetTransparentColor default clfuchsia;

    property OnTracking: TTrackingPos read fOnTracking write fOnTracking;
    property OnStartTracking: TTrackingPos read fOnStartTracking
      write fOnStartTracking;
    property OnEndTracking: TTrackingPos read fOnEndTracking
      write fOnEndTracking;
    property OnEnd: TNotifyEvent read fOnEnd write fOnEnd;
    property OnRightClick: TNotifyEvent read fOnRightClick write fOnRightClick;

    property MouseLDown: boolean read fMouseDown;
    property FocusMouse: boolean read fFocusMouse;

    property Hint;
    property ShowHint;
    property Anchors;
    property Color default clWhite;
    property Cursor default crHandPoint;
    property Visible;
    property PopupMenu;
    property Align;
    property ParentShowHint;
  end;

procedure Register;

implementation

// ******************************************************************************
procedure DrawTransparentBmp(Cnv: TCanvas; X, Y: Integer; Bmp: TBitmap;
  clTransparent: TColor);
var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  try
    bmpAND := TBitmap.Create;
    bmpAND.Width := Bmp.Width;
    bmpAND.Height := Bmp.Height;
    bmpAND.Monochrome := True;
    oldcol := SetBkColor(Bmp.Canvas.Handle, ColorToRGB(clTransparent));
    BitBlt(bmpAND.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    SetBkColor(Bmp.Canvas.Handle, oldcol);

    bmpINVAND := TBitmap.Create;
    bmpINVAND.Width := Bmp.Width;
    bmpINVAND.Height := Bmp.Height;
    bmpINVAND.Monochrome := True;
    BitBlt(bmpINVAND.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, NOTSRCCOPY);

    bmpXOR := TBitmap.Create;
    bmpXOR.Width := Bmp.Width;
    bmpXOR.Height := Bmp.Height;
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle,
      0, 0, SRCCOPY);
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpINVAND.Canvas.Handle, 0, 0, SRCAND);

    bmpTarget := TBitmap.Create;
    bmpTarget.Width := Bmp.Width;
    bmpTarget.Height := Bmp.Height;
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, Cnv.Handle, X,
      Y, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    BitBlt(Cnv.Handle, X, Y, Bmp.Width, Bmp.Height, bmpTarget.Canvas.Handle, 0,
      0, SRCCOPY);
  finally
    freeAndNil(bmpXOR);
    freeAndNil(bmpAND);
    freeAndNil(bmpINVAND);
    freeAndNil(bmpTarget);
  end;
end;

// ******************************************************************************
procedure TZMSTrackBar.CalculateLen;
begin
  if fPosition < fMin then
    fPosition := fMin
  else if fPosition > fMax then
    fPosition := fMax;

  if fSnapPosition < fMin then
    fSnapPosition := fMin
  else if fSnapPosition > fMax then
    fSnapPosition := fMax;

  if fStanding = okHorizontal then
  begin
    if fShowThumb then
    begin
      if not fSkinThumb.Empty then
        fWorkingArea := Width - fSkinThumb.Width
      else
        fWorkingArea := Width;
    end
    else
      fWorkingArea := Width;
  end
  else
  begin
    if fShowThumb then
    begin
      if not fSkinThumb.Empty then
        fWorkingArea := Height - fSkinThumb.Height
      else
        fWorkingArea := Height;
    end
    else
      fWorkingArea := Height;
  end;

  if (fMin = 0) and (fMax = 0) then
  begin
    fLength := 0;
    fPosInLen := 0;
    fSnapPosInLen := 0;
  end
  else if (fMin < 0) and (fMax < 0) and (fMax > fMin) then
  begin
    fLength := ABS(fMin) - ABS(fMax);
    fPosInLen := ABS(fMin) - ABS(fPosition);
    fSnapPosInLen := ABS(fMin) - ABS(fSnapPosition);
  end
  else if (fMin < 0) and (fMax >= 0) then
  begin
    fLength := ABS(fMin) + fMax;

    if fPosition < 0 then
      fPosInLen := fLength - (ABS(fPosition) + fMax)
    else
      fPosInLen := ABS(fMin) + fPosition;

    if fSnapPosition < 0 then
      fSnapPosInLen := fLength - (ABS(fSnapPosition) + fMax)
    else
      fSnapPosInLen := ABS(fMin) + fSnapPosition;
  end
  else if (fMin >= 0) and (fMax > fMin) then
  begin
    fLength := fMax - fMin;
    fPosInLen := ABS(fMin - fPosition);
    fSnapPosInLen := ABS(fMin - fSnapPosition);
  end;

  if fWorkingArea > 0 then
  begin
    if fReverse then
      fDrawPos := fWorkingArea - MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen),
        Trunc(fLength))
    else
      fDrawPos := MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen), Trunc(fLength));
  end
  else
    fDrawPos := 0;
end;

// ******************************************************************************
procedure TZMSTrackBar.CalculatePos(BufPos: Single);
var
  PosBufferNew: Single;
begin
  CalculateLen;

  if BufPos < 0 then
    PosBufferNew := 0
  else if BufPos > fWorkingArea then
    PosBufferNew := fWorkingArea
  else
    PosBufferNew := BufPos;

  if fStanding = okHorizontal then
  begin
    fPosInLen := MulDiv(Trunc(fLength), Trunc(PosBufferNew),
      Trunc(fWorkingArea));
    if fReverse then
      fPosition := (fMin + fMax) - (fMin + fPosInLen)
    else
      fPosition := fMin + fPosInLen;
    if fWorkingArea > 0 then
      fDrawPos := MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen), Trunc(fLength))
    else
      fDrawPos := 0;
  end
  else
  begin
    fPosInLen := MulDiv(Trunc(fLength), Trunc(PosBufferNew),
      Trunc(fWorkingArea));
    fPosInLen := fLength - fPosInLen;
    if fReverse then
      fPosition := (fMin + fMax) - (fMin + fPosInLen)
    else
      fPosition := fMin + fPosInLen;
    if fWorkingArea > 0 then
      fDrawPos := MulDiv(Trunc(fWorkingArea), Trunc(fPosInLen), Trunc(fLength))
    else
      fDrawPos := 0;
  end;

  if fSnapActive then
  begin
    if (fPosition < (fSnapPosition + fSnapBuffer)) and
      (fPosition > (fSnapPosition - fSnapBuffer)) then
    begin
      fPosition := fSnapPosition;
      CalculateLen;
    end;
  end;
end;

// ******************************************************************************
function TZMSTrackBar.CalculatePosFade(BufPos: Single): Single;
var
  PosBufferNew: Single;
  Return: Single;
begin
  if BufPos < 0 then
    PosBufferNew := 0
  else if BufPos > fWorkingArea then
    PosBufferNew := fWorkingArea
  else
    PosBufferNew := BufPos;

  if fStanding = okHorizontal then
  begin
    Return := MulDiv(Trunc(fLength), Trunc(PosBufferNew), Trunc(fWorkingArea));
    Return := fMin + Return;
  end
  else
  begin
    Return := MulDiv(Trunc(fLength), Trunc(PosBufferNew), Trunc(fWorkingArea));
    Return := fMin + (fLength - Return);
  end;

  if fReverse then
    Result := (fMin + fMax) - Return
  else
    Result := Return;
end;

// ******************************************************************************
procedure TZMSTrackBar.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  fFocusMouse := True;
end;

// ******************************************************************************
procedure TZMSTrackBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  fFocusMouse := false;
end;

// ******************************************************************************
constructor TZMSTrackBar.Create(AOwner: TComponent);
begin
  inherited;

  fTransparent := false;
  fTransparentColor := clfuchsia;
  Cursor := crHandPoint;

  fCenterPos := 0;
  fCenterStop := false;

  fBuffer := TBitmap.Create;
  fBuffer.Width := Width;
  fBuffer.Height := Height;
  fBuffer.Canvas.Pen.Color := Color;
  fBuffer.Canvas.Brush.Color := Color;
  fBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));

  fBufferThmb := TBitmap.Create;
  fBufferThmb.Width := 0;
  fBufferThmb.Height := 0;

  fEnabled := True;
  fReverse := false;
  fStretch := false;

  fSkin := TBitmap.Create;
  fSkin.Width := 0;
  fSkin.Height := 0;

  fSkinThumb := TBitmap.Create;
  fSkinThumb.Width := 0;
  fSkinThumb.Height := 0;

  fMax := 0;
  fMin := 0;
  fPosition := 0;

  fLength := 100;
  fPosInLen := 0;

  fSnapActive := false;
  fSnapPosition := 0;
  fSnapBuffer := 3;
  fSnapPosInLen := 0;

  fShowThumb := True;

  fThumbSlide := tbMoving;
  fStanding := okHorizontal;

  Resize;
end;

// ******************************************************************************
destructor TZMSTrackBar.Destroy;
begin
  freeAndNil(fBuffer);
  freeAndNil(fBufferThmb);
  freeAndNil(fSkin);
  freeAndNil(fSkinThumb);
  inherited;
end;

// ******************************************************************************
procedure TZMSTrackBar.Morphing(Bm1, Bm2: TBitmap; Progress: Integer);
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
procedure TZMSTrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if Button = mbRight then
  begin
    if (fCenterStop) then
    begin
      Position := fCenterPos;
      if Assigned(fOnRightClick) then
        fOnRightClick(self);
    end;
    Renderer;
    exit;
  end
  else
  begin
    if Button <> mbLeft then
      exit;
  end;

  fMouseDown := True;

  if fEnabled then
  begin
    if fStanding = okHorizontal then
    begin
      if fThumbSlide = tbMoving then
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
          begin
            CalculatePos(X - (fSkinThumb.Width / 2));
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self,
                CalculatePosFade(X - (fSkinThumb.Width / 2)), false);
          end
          else
          begin
            CalculatePos(X);
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self, CalculatePosFade(X), false);
          end;
        end
        else
        begin
          CalculatePos(X);
          if Assigned(fOnStartTracking) then
            fOnStartTracking(self, CalculatePosFade(X), false);
        end;
      end
      else
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
          begin
            fDrawPosFade := VerifPosFade(X - (fSkinThumb.Width / 2));
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self,
                CalculatePosFade(X - (fSkinThumb.Width / 2)), false);
          end
          else
          begin
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self, CalculatePosFade(X), false);
          end;
        end
        else
        begin
          if Assigned(fOnStartTracking) then
            fOnStartTracking(self, CalculatePosFade(X), false);
        end;
      end;
    end
    else // okVertical ------------------------
    begin
      if fThumbSlide = tbMoving then
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
          begin
            CalculatePos(Y - (fSkinThumb.Height / 2));
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self,
                CalculatePosFade(Y - (fSkinThumb.Height / 2)), false);
          end
          else
          begin
            CalculatePos(Y);
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self, CalculatePosFade(Y), false);
          end;
        end
        else
        begin
          CalculatePos(Y);
          if Assigned(fOnStartTracking) then
            fOnStartTracking(self, CalculatePosFade(Y), false);
        end;
      end
      else
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
          begin
            fDrawPosFade := VerifPosFade(Y - (fSkinThumb.Height / 2));
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self,
                CalculatePosFade(Y - (fSkinThumb.Height / 2)), false);
          end
          else
          begin
            if Assigned(fOnStartTracking) then
              fOnStartTracking(self, CalculatePosFade(Y), false);
          end;
        end
        else
        begin
          if Assigned(fOnStartTracking) then
            fOnStartTracking(self, CalculatePosFade(Y), false);
        end;
      end;
    end;
  end;

  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if fEnabled then
  begin
    if fMouseDown then
    begin
      if fStanding = okHorizontal then
      begin
        if fThumbSlide = tbMoving then
        begin
          if fShowThumb then
          begin
            if not fSkinThumb.Empty then
            begin
              CalculatePos(X - (fSkinThumb.Width / 2));
              if Assigned(fOnTracking) then
                fOnTracking(self, fPosition, false)
            end
            else
            begin
              CalculatePos(X);
              if Assigned(fOnTracking) then
                fOnTracking(self, fPosition, false)
            end;
          end
          else
          begin
            CalculatePos(X);
            if Assigned(fOnTracking) then
              fOnTracking(self, fPosition, false)
          end;
        end
        else
        begin
          if fShowThumb then
          begin
            if not fSkinThumb.Empty then
            begin
              fDrawPosFade := VerifPosFade(X - (fSkinThumb.Width / 2));
              if Assigned(fOnTracking) then
                fOnTracking(self,
                  CalculatePosFade(X - (fSkinThumb.Width / 2)), false)
            end
            else
            begin
              if Assigned(fOnTracking) then
                fOnTracking(self, CalculatePosFade(X), false)
            end;
          end
          else
          begin
            if Assigned(fOnTracking) then
              fOnTracking(self, CalculatePosFade(X), false)
          end;
        end;
      end
      else // okVertical -----------------------
      begin
        if fThumbSlide = tbMoving then
        begin
          if fShowThumb then
          begin
            if not fSkinThumb.Empty then
            begin
              CalculatePos(Y - (fSkinThumb.Height / 2));
              if Assigned(fOnTracking) then
                fOnTracking(self,
                  CalculatePosFade(Y - (fSkinThumb.Height / 2)), false);
            end
            else
            begin
              CalculatePos(Y);
              if Assigned(fOnTracking) then
                fOnTracking(self, CalculatePosFade(Y), false);
            end;
          end
          else
          begin
            CalculatePos(Y);
            if Assigned(fOnTracking) then
              fOnTracking(self, CalculatePosFade(Y), false);
          end;
        end
        else
        begin
          if fShowThumb then
          begin
            if not fSkinThumb.Empty then
            begin
              fDrawPosFade := VerifPosFade(Y - (fSkinThumb.Height / 2));
              if Assigned(fOnTracking) then
                fOnTracking(self,
                  CalculatePosFade(Y - (fSkinThumb.Height / 2)), false);
            end
            else
            begin
              if Assigned(fOnTracking) then
                fOnTracking(self, CalculatePosFade(Y), false);
            end;
          end
          else
          begin
            if Assigned(fOnTracking) then
              fOnTracking(self, CalculatePosFade(Y), false);
          end;
        end;
      end;
    end;
  end;

  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if Button <> mbLeft then
    exit;
  if fMouseDown then
    fMouseDown := false
  else
    exit;

  if fEnabled then
  begin
    if fStanding = okHorizontal then
    begin
      if fThumbSlide = tbUp then
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
            CalculatePos(X - (fSkinThumb.Width / 2))
          else
            CalculatePos(X);
        end
        else
          CalculatePos(X);
      end;
    end
    else
    begin
      if fThumbSlide = tbUp then
      begin
        if fShowThumb then
        begin
          if not fSkinThumb.Empty then
            CalculatePos(Y - (fSkinThumb.Height / 2))
          else
            CalculatePos(Y);
        end
        else
          CalculatePos(Y);
      end;
    end;

    // if fThumbSlide = tbUp then
    // begin
    if Assigned(fOnEndTracking) then
      fOnEndTracking(self, fPosition, false);
    // end;
  end;

  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.Paint;
begin
  inherited;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.Renderer;
var
  BMP2: TBitmap;
begin
  // Resize;
  CalculateLen;

  // if not fSkin.Empty then
  // begin
  // if fReverse then
  // Canvas.StretchDraw(ClientRect, fSkin)
  // else
  // Canvas.Draw(0, 0, fBuffer);
  // end else
  // exit;

  // вырезано выше ..
  fBuffer.Width := Width;
  fBuffer.Height := Height;

  if fEnabled then
  begin
    if fStanding = okHorizontal then
    begin
      if fThumbSlide = tbMoving then
      begin
        if fStretch then
          fBuffer.Canvas.StretchDraw(ClientRect, fSkin)
        else
          fBuffer.Canvas.Draw(0, 0, fSkin);

        if fShowThumb then
        begin
          if fTransparent then
          begin
            DrawTransparentBmp(fBuffer.Canvas, Trunc(fDrawPos), 0, fSkinThumb,
              fTransparentColor);
          end
          else
          begin
            fBuffer.Canvas.CopyRect(Rect(Trunc(fDrawPos), 0,
              Trunc(fDrawPos) + fSkinThumb.Width, fSkinThumb.Height),
              fSkinThumb.Canvas, Rect(0, 0, fSkinThumb.Width,
              fSkinThumb.Height));
          end;
        end;
      end
      else // tbUp ----------------
      begin
        if fStretch then
          fBuffer.Canvas.StretchDraw(ClientRect, fSkin)
        else
          fBuffer.Canvas.Draw(0, 0, fSkin);

        if fShowThumb then
        begin
          if fTransparent then
          begin
            DrawTransparentBmp(fBuffer.Canvas, Trunc(fDrawPos), 0, fSkinThumb,
              fTransparentColor);
          end
          else
          begin
            fBuffer.Canvas.CopyRect(Rect(Trunc(fDrawPos), 0,
              Trunc(fDrawPos) + fSkinThumb.Width, fSkinThumb.Height),
              fSkinThumb.Canvas, Rect(0, 0, fSkinThumb.Width,
              fSkinThumb.Height));
          end;

          if fMouseDown then
          begin
            fBufferThmb.Width := fSkinThumb.Width;
            fBufferThmb.Height := fSkinThumb.Height;

            fBufferThmb.Canvas.CopyRect(Rect(0, 0, fSkinThumb.Width,
              fSkinThumb.Height), fBuffer.Canvas, Rect(Trunc(fDrawPosFade), 0,
              Trunc(fDrawPosFade) + fSkinThumb.Width, fSkinThumb.Height));

            Morphing(fBufferThmb, fSkinThumb, 50);
            fBuffer.Canvas.CopyRect(Rect(Trunc(fDrawPosFade), 0,
              Trunc(fDrawPosFade) + fBufferThmb.Width, fBufferThmb.Height),
              fBufferThmb.Canvas, Rect(0, 0, fBufferThmb.Width,
              fBufferThmb.Height));
            fBufferThmb.Width := 0;
            fBufferThmb.Height := 0;
          end;
        end;
      end;
    end
    else // okVertical -------------------------------
    begin
      if fThumbSlide = tbMoving then
      begin
        if fStretch then
          fBuffer.Canvas.StretchDraw(ClientRect, fSkin)
        else
          fBuffer.Canvas.Draw(0, 0, fSkin);

        if fShowThumb then
        begin
          if fTransparent then
          begin
            BMP2 := TBitmap.Create;
            BMP2.Width := fSkin.Width;
            BMP2.Height := fSkin.Height;
            BMP2.Canvas.Draw(0, 0, fSkin);
            DrawTransparentBmp(fBuffer.Canvas, 0,
              fBuffer.Height - Trunc(fDrawPos) - fSkinThumb.Height, BMP2,
              fTransparentColor);
            freeAndNil(BMP2);
          end
          else
            fBuffer.Canvas.Draw(0, fBuffer.Height - Trunc(fDrawPos) -
              fSkinThumb.Height, fSkinThumb);
        end;
      end
      else // tbUp ---------------
      begin
        if fStretch then
          fBuffer.Canvas.StretchDraw(ClientRect, fSkin)
        else
          fBuffer.Canvas.Draw(0, 0, fSkin);

        if fShowThumb then
        begin
          if fTransparent then
          begin
            BMP2 := TBitmap.Create;
            BMP2.Width := fSkin.Width;
            BMP2.Height := fSkin.Height;
            BMP2.Canvas.Draw(0, 0, fSkin);
            DrawTransparentBmp(fBuffer.Canvas, 0,
              fBuffer.Height - Trunc(fDrawPos) - fSkinThumb.Height, BMP2,
              fTransparentColor);
            freeAndNil(BMP2);
          end
          else
            fBuffer.Canvas.Draw(0, fBuffer.Height - Trunc(fDrawPos) -
              fSkinThumb.Height, fSkinThumb);

          if fMouseDown then
          begin
            fBufferThmb.Width := fSkinThumb.Width;
            fBufferThmb.Height := fSkinThumb.Height;

            fBufferThmb.Canvas.CopyRect(Rect(0, 0, fSkinThumb.Width,
              fSkinThumb.Height), fBuffer.Canvas, Rect(0, Trunc(fDrawPosFade),
              fSkinThumb.Width, Trunc(fDrawPosFade) + fSkinThumb.Height));
            Morphing(fBufferThmb, fSkinThumb, 50);
            fBuffer.Canvas.CopyRect(Rect(0, Trunc(fDrawPosFade),
              fSkinThumb.Width, Trunc(fDrawPosFade) + fSkinThumb.Height),
              fBufferThmb.Canvas, Rect(0, 0, fBufferThmb.Width,
              fBufferThmb.Height));

            fBufferThmb.Width := 0;
            fBufferThmb.Height := 0;
          end;
        end;
      end;
    end;
  end
  else // fEnabled -----------
  begin
    if fStretch then
      fBuffer.Canvas.StretchDraw(ClientRect, fSkin)
    else
      fBuffer.Canvas.Draw(0, 0, fSkin);
  end;

  Canvas.Draw(0, 0, fBuffer);
end;

// ******************************************************************************
procedure TZMSTrackBar.Loaded;
begin
  inherited;
  Resize;
end;

// ******************************************************************************
procedure TZMSTrackBar.Resize;
begin
  if not fSkin.Empty then
  begin
    if fStretch then
      inherited
    else
    begin
      Width := fSkin.Width;
      Height := fSkin.Height;
    end;
  end
  else
    inherited;
end;

// ******************************************************************************
procedure TZMSTrackBar.RotateBitmap(Bitmap: TBitmap);
// type
// TRGBArray = array[0..64000] of TRGBTriple;
// PRGBArray = ^TRGBArray;
// var
// X, Y, W, H: Integer;
// Bmp: TBitmap;
// dstPixel, srcPixel: PRGBArray;
// begin
// if Bitmap.Empty then exit;
//
// if Bitmap.PixelFormat <> pf24Bit then Bitmap.PixelFormat := pf24Bit;
// Bmp := TBitmap.Create;
// try
// Bmp.Assign(Bitmap);
// W := Bitmap.Width - 1;
// H := Bitmap.Height - 1;
// Bitmap.Width := H + 1;
// Bitmap.Height := W + 1;
//
// for Y := 0 to H do
// begin
// srcPixel := Bmp.ScanLine[Y];
// for X := 0 to W do
// begin
// dstPixel := Bitmap.ScanLine[Bitmap.Height - 1 - X];
// dstPixel[Y].rgbtRed := srcPixel[X].rgbtRed;
// dstPixel[Y].rgbtGreen := srcPixel[X].rgbtGreen;
// dstPixel[Y].rgbtBlue := srcPixel[X].rgbtBlue;
// end;
// end;
// finally
// FreeAndNil(Bmp);
// end;
// end;

type
  PRGB = ^TRGB;

  TRGB = record
    B, G, R: Byte;
  end;

  PByteArray = ^TByteArray;
  TByteArray = array [0 .. 32767] of Byte;
var
  VertArray: array of PByteArray;
  X, Y, W, H, V: Integer;
  Bmp: TBitmap;
  Dest: PRGB;
begin
  if Bitmap.Empty then
    exit;

  if Bitmap.PixelFormat <> pf24Bit then
    Bitmap.PixelFormat := pf24Bit;
  Bmp := TBitmap.Create;
  try
    Bmp.Assign(Bitmap);
    W := Bitmap.Width - 1;
    H := Bitmap.Height - 1;
    Bitmap.Width := H + 1;
    Bitmap.Height := W + 1;
    SetLength(VertArray, H + 1);
    V := H;
    for Y := 0 to H do
      VertArray[Y] := Bmp.ScanLine[ABS(V - Y)];
    for X := 0 to W do
    begin
      Dest := Bitmap.ScanLine[X];
      for Y := 0 to H do
      begin
        V := ABS(0 - X) * 3;
        with Dest^ do
        begin
          B := VertArray[Y, V];
          G := VertArray[Y, V + 1];
          R := VertArray[Y, V + 2];
        end;
        Inc(Dest);
      end;
    end;
  finally
    freeAndNil(Bmp);
  end;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetReverse(Value: boolean);
begin
  fReverse := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetStretch(Value: boolean);
begin
  fStretch := Value;
  Resize;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetEnable(Value: boolean);
begin
  fEnabled := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetMax(Value: Single);
begin
  if fMax <> Value then
  begin
    if Value >= fMin then
      fMax := Value
    else if Value < fMin then
    begin
      fMin := Value - 1;
      fMax := Value;
    end;
    Renderer;
  end;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetMin(Value: Single);
begin
  if fMin <> Value then
  begin
    if Value <= fMax then
      fMin := Value
    else if Value > fMax then
    begin
      fMax := Value + 1;
      fMin := Value;
    end;
    Renderer;
  end;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetPosition(Value: Single);
begin
  fPosition := Value;
  Renderer;

  if Assigned(fOnEnd) then
  begin
    if ((fMax <> 0) and (fPosition <> 0)) and (fPosition >= fMax) then
    begin
      fOnEnd(self);
      exit;
    end;
  end;

  if Assigned(fOnEndTracking) then // fOnTracking
    fOnEndTracking(self, fPosition, True);
end;

// ******************************************************************************
procedure TZMSTrackBar.SetShowThumb(Value: boolean);
begin
  fShowThumb := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetSkin(Value: TBitmap);
begin
  if Assigned(Value) then
    fSkin.Assign(Value)
  else
  begin
    fSkin.Width := 0;
    fSkin.Height := 0;
  end;
  fBuffer.Assign(fSkin);
  Resize;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetSkinThumb(Value: TBitmap);
begin
  if Assigned(Value) then
    fSkinThumb.Assign(Value)
  else
  begin
    fSkinThumb.Width := 0;
    fSkinThumb.Height := 0;
  end;
  fBufferThmb.Assign(fSkinThumb);
  Resize;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetSnapActive(Value: boolean);
begin
  fSnapActive := Value;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetSnapBuffer(Value: Single);
begin
  fSnapBuffer := Value;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetSnapPosition(Value: Single);
begin
  fSnapPosition := Value;
  CalculateLen;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetStanding(Value: TOrientationKind);
begin
  if (Value = okHorizontal) and (fStanding <> Value) then
  begin
    fStanding := okHorizontal;
    if (not fSkin.Empty) and (fSkin.Height > fSkin.Width) then
      RotateBitmap(fSkin);
    if (not fSkinThumb.Empty) and (fSkinThumb.Height > fSkinThumb.Width) then
      RotateBitmap(fSkinThumb);
  end
  else if (Value = okVertical) and (fStanding <> Value) then
  begin
    fStanding := okVertical;
    if (not fSkin.Empty) and (fSkin.Width > fSkin.Height) then
      RotateBitmap(fSkin);
    if (not fSkinThumb.Empty) and (fSkinThumb.Width > fSkinThumb.Height) then
      RotateBitmap(fSkinThumb);
  end;
  Resize;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetThumbSlide(Value: TThumbSlide);
begin
  fThumbSlide := Value;
  Renderer;
end;

// ******************************************************************************
function TZMSTrackBar.VerifPosFade(Value: Single): Single;
begin
  if Value < 0 then
    Result := 0
  else if Value > fWorkingArea then
    Result := fWorkingArea
  else
    Result := Value;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetTransparent(Value: boolean);
begin
  fTransparent := Value;
  Renderer;
end;

// ******************************************************************************
procedure TZMSTrackBar.SetTransparentColor(Value: TColor);
begin
  fTransparentColor := Value;
  Renderer;
end;

// ******************************************************************************
procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSTrackBar]);
end;
// ******************************************************************************

end.
