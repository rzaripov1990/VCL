unit SC_Image;

{ *********************************************
  | zubymplayer: audio player                  |
  |                                            |
  |   author:  Zaripov Ravil aka ZuBy          |
  | contacts:  icq : 400-464-936               |
  |            mail: zuby3534@gmail.com        |
  |            web : http://zuby.ucoz.kz       |
  |            Kazakhstan, Semey, 2010         |
  |                                            |
  | TZMSImage: Компонент для отображения bmp   |
  ********************************************* }

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics;

type
  TZMSImage = class(TCustomControl)
  private
    fBuffer: TBitmap;
    fStretch: boolean;
    fAutoSize: boolean;

    fTransparent: boolean;
    fTransparentColor: TColor;

    procedure SetLoadBmp(Bmp: TBitmap);
    procedure SetStretch(Active: boolean);
    procedure SetAutoSized(Active: boolean);
    procedure SetTransparent(Value: boolean);
    procedure SetTransparentColor(Value: TColor);

    procedure Render;
    procedure DrawBitmap(cnv: TCanvas; Bmp: TBitmap; sWidth, sHeight: integer);
    { Private declarations }
  protected
    procedure Paint; override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    { Public declarations }
  published
    property Stretch: boolean read fStretch write SetStretch default false;
    property AutoSize: boolean read fAutoSize write SetAutoSized default false;
    property Bitmap: TBitmap read fBuffer write SetLoadBmp;
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
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnKeyUp;
    property OnKeyDown;
    { Published declarations }
  end;

type
  TZMSPanel = class(TZMSImage)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  end;

procedure Register;

implementation

// ******************************************************************************
procedure TZMSImage.DrawBitmap(cnv: TCanvas; Bmp: TBitmap;
  sWidth, sHeight: integer);

  function check: boolean;
  begin
    Result := (sWidth > Bmp.Width) or (sHeight > Bmp.Height);
  end;

var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  try
    bmpAND := TBitmap.Create;
    bmpAND.Width := Bmp.Width;
    bmpAND.Height := Bmp.Height;
    bmpAND.Monochrome := True;
    oldcol := SetBkColor(Bmp.Canvas.Handle, ColorToRGB(fTransparentColor));
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
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, cnv.Handle, 0,
      0, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    if check then
    begin
      StretchBlt(cnv.Handle, 0, 0, sWidth, sHeight, bmpTarget.Canvas.Handle, 0,
        0, Bmp.Width, Bmp.Height, SRCCOPY);
    end
    else
      BitBlt(cnv.Handle, 0, 0, Bmp.Width, Bmp.Height, bmpTarget.Canvas.Handle,
        0, 0, SRCCOPY);
  finally
    freeAndNil(bmpXOR);
    freeAndNil(bmpAND);
    freeAndNil(bmpINVAND);
    freeAndNil(bmpTarget);
  end;
end;

// ******************************************************************************
procedure TZMSImage.Render;
var
  Bmp: TBitmap;
begin
  if fAutoSize then
  begin
    if not fBuffer.Empty then
    begin
      Width := fBuffer.Width;
      Height := fBuffer.Height;
    end;
  end;

  with fBuffer do
  begin
    if Empty then
    begin
      Self.Canvas.Brush.Style := bsClear;
      Self.Canvas.Pen.Color := clRed;
      Self.Canvas.Pen.Style := psDashDot;
      Self.Canvas.Rectangle(ClientRect);
    end
    else
    begin
      if (fAutoSize) and (not fStretch) then
      begin

        if fTransparent then
        begin
          Bmp := TBitmap.Create;
          Bmp.Width := Width;
          Bmp.Height := Height;
          BitBlt(Bmp.Canvas.Handle, 0, 0, Width, Height, Canvas.Handle, 0,
            0, SRCCOPY);
          DrawBitmap(Self.Canvas, Bmp, Width, Height);
          freeAndNil(Bmp);
        end
        else
          BitBlt(Self.Canvas.Handle, 0, 0, Width, Height, Canvas.Handle, 0,
            0, SRCCOPY);

      end
      else if (not fAutoSize) and (fStretch) then
      begin

        if fTransparent then
        begin
          Bmp := TBitmap.Create;
          Bmp.Width := Width;
          Bmp.Height := Height;
          BitBlt(Bmp.Canvas.Handle, 0, 0, Width, Height, Canvas.Handle, 0,
            0, SRCCOPY);
          DrawBitmap(Self.Canvas, Bmp, Self.Width, Self.Height);
          freeAndNil(Bmp);
        end
        else
          StretchBlt(Self.Canvas.Handle, 0, 0, Self.Width, Self.Height,
            Canvas.Handle, 0, 0, Width, Height, SRCCOPY);

      end
      else
      begin

        if fTransparent then
        begin
          Bmp := TBitmap.Create;
          Bmp.Width := Width;
          Bmp.Height := Height;
          BitBlt(Bmp.Canvas.Handle, 0, 0, Width, Height, Canvas.Handle, 0,
            0, SRCCOPY);
          DrawBitmap(Self.Canvas, Bmp, Width, Height);
          freeAndNil(Bmp);
        end
        else
          BitBlt(Self.Canvas.Handle, 0, 0, Width, Height, Canvas.Handle, 0,
            0, SRCCOPY);

      end;
    end;
  end;
end;

// ******************************************************************************
procedure TZMSImage.SetLoadBmp(Bmp: TBitmap);
begin
  fBuffer.Assign(Bmp);
  if (Assigned(Bmp)) then
  begin
    fBuffer.Width := Bmp.Width;
    fBuffer.Height := Bmp.Height;
  end;
  Render;
end;

// ******************************************************************************
procedure TZMSImage.Paint;
begin
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSImage.Click;
begin
  inherited;
  Render;
end;

// ******************************************************************************
procedure TZMSImage.SetStretch(Active: boolean);
begin
  if fStretch <> Active then
  begin
    fStretch := Active;
    Render;
  end;
end;

// ******************************************************************************
procedure TZMSImage.SetTransparent(Value: boolean);
begin
  if fTransparent <> Value then
  begin
    ParentBackground := Value;
    fTransparent := Value;
    Render;
  end;
end;

// ******************************************************************************
procedure TZMSImage.SetTransparentColor(Value: TColor);
begin
  if fTransparentColor <> Value then
  begin
    fTransparentColor := Value;
    Render;
  end;
end;

// ******************************************************************************
procedure TZMSImage.SetAutoSized(Active: boolean);
begin
  if fAutoSize <> Active then
  begin
    fAutoSize := Active;
    Render;
  end;
end;

// ******************************************************************************
constructor TZMSImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  // ParentColor := false;
  // Color := clWhite;
  fBuffer := TBitmap.Create;

  fStretch := false;
  fAutoSize := false;

  fTransparent := false;
  fTransparentColor := clFuchsia;

  Height := 50;
  Width := 100;
end;

// ******************************************************************************
destructor TZMSImage.Destroy;
begin
  freeAndNil(fBuffer);
  inherited;
end;

// ******************************************************************************
constructor TZMSPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
end;

// ******************************************************************************
procedure TZMSPanel.Click;
begin
  inherited;
  SetFocus;
  Render;
end;
// ******************************************************************************

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSImage, TZMSPanel]);
end;

end.
