unit SC_ContextMenu;

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
  Windows, SysUtils, Classes, Menus, Graphics, GraphUtil, StrUtils;

type
  TZMSContextMenu = class(TPopupMenu)
  private
    { Private declarations }
    fBitmap: TBitmap;

    fFont: TFont;

    fColorSelected: TColor;
    fColorDisabled: TColor;

    procedure SetBitmap(Value: TBitmap);
    procedure SetFont(Value: TFont);
    procedure SetColorDisabled(Value: TColor);
    procedure SetColorSelected(Value: TColor);
  protected
    { Protected declarations }
    procedure RendererItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      State: TOwnerDrawState);
    procedure VerifMeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);

    procedure NewChange(Sender: TObject);
    procedure InitItem(Item: TMenuItem);
    procedure InitItems(Item: TMenuItem);

    procedure DrawSelected(ACanvas: TCanvas; ARect: TRect; ASkin: TBitmap);
    procedure DrawGrayed(ACanvas: TCanvas; ARect: TRect; ASkin: TBitmap);
    procedure DrawNormal(ACanvas: TCanvas; ARect: TRect; ASkin: TBitmap);
    procedure DrawItemIcon(ACanvas: TCanvas; ARect: TRect;
      AIconBitmap: TBitmap);

    procedure DrawChecked(ACanvas: TCanvas; ARect: TRect; ARadioItem: boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property OnPopup;
    property Images;
    // property _Captions: TStringList read fCaptions write fCaptions;
    // property _DrawCaptions: boolean read fDrawCaption write fDrawCaption default false;
    property clrSelected: TColor read fColorSelected write SetColorSelected
      default clRed;
    property clrDisabled: TColor read fColorDisabled write SetColorDisabled
      default clGray;
    property Font: TFont read fFont write SetFont;
    property Bitmap: TBitmap read fBitmap write SetBitmap;
  end;

procedure Register;

implementation

{ TZMSContextMenu }

constructor TZMSContextMenu.Create(AOwner: TComponent);
begin
  inherited;

  fBitmap := TBitmap.Create;
  fBitmap.Width := 0;
  fBitmap.Height := 0;

  // fDrawCaption := false;
  // fCaptions := TStringList.Create;

  fColorSelected := clRed;
  fColorDisabled := clGray;

  fFont := TFont.Create;
  fFont.Color := clBlack;

  OwnerDraw := false;
  OnPopup := NewChange;
end;

destructor TZMSContextMenu.Destroy;
begin
  FreeAndNil(fBitmap);
  FreeAndNil(fFont);
  // FreeAndNil(fCaptions);
  inherited;
end;

procedure TZMSContextMenu.SetColorDisabled(Value: TColor);
begin
  fColorDisabled := Value;
end;

procedure TZMSContextMenu.SetColorSelected(Value: TColor);
begin
  fColorSelected := Value;
end;

procedure TZMSContextMenu.SetFont(Value: TFont);
begin
  if Assigned(Value) then
    fFont.Assign(Value);
end;

procedure TZMSContextMenu.SetBitmap(Value: TBitmap);
begin
  if Assigned(Value) then
    fBitmap.Assign(Value)
  else
  begin
    fBitmap.Width := 0;
    fBitmap.Height := 0;
  end;
  OwnerDraw := not fBitmap.Empty;
end;

procedure TZMSContextMenu.InitItem(Item: TMenuItem);
begin
  Item.OnAdvancedDrawItem := RendererItem;
  Item.OnMeasureItem := VerifMeasureItem;
end;

procedure TZMSContextMenu.InitItems(Item: TMenuItem);
var
  I: Word;
begin
  I := 0;
  while I < Item.Count do
  begin
    InitItem(Item[I]);
    if Item[I].Count > 0 then
      InitItems(Item[I]);
    Inc(I);
  end;
end;

procedure TZMSContextMenu.NewChange(Sender: TObject);
begin
  if fBitmap.Empty then
    OwnerDraw := false
  else
    InitItems(Items);
end;

procedure TZMSContextMenu.DrawChecked(ACanvas: TCanvas; ARect: TRect;
  ARadioItem: boolean);
var
  PR: TPenRecall;
begin
  if Assigned(ACanvas) then
  begin
    if ARadioItem then
    begin
      PR := TPenRecall.Create(ACanvas.Pen);
      ACanvas.Pen.Mode := pmNot;
      ACanvas.Pen.Width := 1;
      ACanvas.Polyline([Point(ARect.Left + 7, ARect.Top + 5),
        Point(ARect.Left + 7, ARect.Top + 15), Point(ARect.Left + 17,
        ARect.Top + 15), Point(ARect.Left + 17, ARect.Top + 5),
        Point(ARect.Left + 7, ARect.Top + 5)]);
      ACanvas.MoveTo(ARect.Left + 11, ARect.Top + 8);
      ACanvas.LineTo(ARect.Left + 14, ARect.Top + 8);
      ACanvas.MoveTo(ARect.Left + 10, ARect.Top + 9);
      ACanvas.LineTo(ARect.Left + 15, ARect.Top + 9);
      ACanvas.MoveTo(ARect.Left + 10, ARect.Top + 10);
      ACanvas.LineTo(ARect.Left + 15, ARect.Top + 10);
      ACanvas.MoveTo(ARect.Left + 10, ARect.Top + 11);
      ACanvas.LineTo(ARect.Left + 15, ARect.Top + 11);
      ACanvas.MoveTo(ARect.Left + 11, ARect.Top + 12);
      ACanvas.LineTo(ARect.Left + 14, ARect.Top + 12);
      FreeAndNil(PR);
    end
    else
    begin
      PR := TPenRecall.Create(ACanvas.Pen);
      ACanvas.Pen.Mode := pmNot;
      ACanvas.Pen.Width := 1;
      ACanvas.Polyline([Point(ARect.Left + 7, ARect.Top + 5),
        Point(ARect.Left + 7, ARect.Top + 15), Point(ARect.Left + 17,
        ARect.Top + 15), Point(ARect.Left + 17, ARect.Top + 5),
        Point(ARect.Left + 7, ARect.Top + 5)]);
      DrawCheck(ACanvas, Point(ARect.Left + 9, ARect.Top + 10), 2, false);
      FreeAndNil(PR);
    end;
  end;
end;

procedure TZMSContextMenu.DrawGrayed(ACanvas: TCanvas; ARect: TRect;
  ASkin: TBitmap);
begin
  if Assigned(ACanvas) and Assigned(ASkin) then
  begin
    if (ASkin.Width = 80) and (ASkin.Height = 45) then
    begin
      ACanvas.CopyRect(Rect(ARect.Left, ARect.Top, 23, ARect.Bottom),
        ASkin.Canvas, Rect(0, 40, 18, 45));
      ACanvas.CopyRect(Rect(ARect.Left + 23, ARect.Top, 33, ARect.Bottom),
        ASkin.Canvas, Rect(18, 40, 28, 45));
      ACanvas.CopyRect(Rect(ARect.Left + 33, ARect.Top, ARect.Right - 50,
        ARect.Bottom), ASkin.Canvas, Rect(25, 40, 55, 45));
      ACanvas.CopyRect(Rect(ARect.Right - 50, ARect.Top, ARect.Right,
        ARect.Bottom), ASkin.Canvas, Rect(ASkin.Width - 25, 40,
        ASkin.Width, 45));
    end;
  end;
end;

procedure TZMSContextMenu.DrawItemIcon(ACanvas: TCanvas; ARect: TRect;
  AIconBitmap: TBitmap);
begin

end;

procedure TZMSContextMenu.DrawNormal(ACanvas: TCanvas; ARect: TRect;
  ASkin: TBitmap);
begin
  if Assigned(ACanvas) and Assigned(ASkin) then
  begin
    if (ASkin.Width = 80) and (ASkin.Height = 45) then
    begin
      ACanvas.CopyRect(Rect(ARect.Left, ARect.Top, 23, ARect.Bottom),
        ASkin.Canvas, Rect(0, 0, 18, 20));
      ACanvas.CopyRect(Rect(ARect.Left + 23, ARect.Top, 33, ARect.Bottom),
        ASkin.Canvas, Rect(18, 0, 28, 20));
      ACanvas.CopyRect(Rect(ARect.Left + 33, ARect.Top, ARect.Right - 25,
        ARect.Bottom), ASkin.Canvas, Rect(28, 0, 55, 20));
      ACanvas.CopyRect(Rect(ARect.Right - 25, ARect.Top, ARect.Right,
        ARect.Bottom), ASkin.Canvas, Rect(ASkin.Width - 25, 0,
        ASkin.Width, 20));
    end;
  end;
end;

procedure TZMSContextMenu.DrawSelected(ACanvas: TCanvas; ARect: TRect;
  ASkin: TBitmap);
begin
  if Assigned(ACanvas) and Assigned(ASkin) then
  begin
    if (ASkin.Width = 80) and (ASkin.Height = 45) then
    begin
      ACanvas.CopyRect(Rect(ARect.Left, ARect.Top, ARect.Left + 2,
        ARect.Top + 2), ASkin.Canvas, Rect(0, 20, 2, 22));
      ACanvas.CopyRect(Rect(ARect.Left, ARect.Bottom - 2, ARect.Left + 2,
        ARect.Bottom), ASkin.Canvas, Rect(0, 38, 2, 40));
      ACanvas.CopyRect(Rect(ARect.Right - 2, ARect.Top, ARect.Right,
        ARect.Top + 2), ASkin.Canvas, Rect(ASkin.Width - 2, 20,
        ASkin.Width, 22));
      ACanvas.CopyRect(Rect(ARect.Right - 2, ARect.Bottom - 2, ARect.Right,
        ARect.Bottom), ASkin.Canvas, Rect(ASkin.Width - 2, 38,
        ASkin.Width, 40));

      ACanvas.CopyRect(Rect(ARect.Left + 2, ARect.Top, ARect.Right - 2,
        ARect.Top + 2), ASkin.Canvas, Rect(2, 20, ASkin.Width - 2, 22));
      ACanvas.CopyRect(Rect(ARect.Left + 2, ARect.Bottom - 2, ARect.Right - 2,
        ARect.Bottom), ASkin.Canvas, Rect(2, 38, ASkin.Width - 2, 40));

      ACanvas.CopyRect(Rect(ARect.Left, ARect.Top + 2, 20, ARect.Bottom - 2),
        ASkin.Canvas, Rect(0, 22, 20, 38));
      ACanvas.CopyRect(Rect(ARect.Left + 20, ARect.Top + 2, ARect.Right - 20,
        ARect.Bottom - 2), ASkin.Canvas, Rect(20, 22, 75, 38));
      ACanvas.CopyRect(Rect(ARect.Right - 20, ARect.Top + 2, ARect.Right,
        ARect.Bottom - 2), ASkin.Canvas, Rect(ASkin.Width - 20, 22,
        ASkin.Width, 38));
    end;
  end;
end;

procedure TZMSContextMenu.RendererItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; State: TOwnerDrawState);
var
  Item: TMenuItem;
  ACaption: String;
  AHeight: Integer;
begin
  Item := TMenuItem(Sender);
  if (not fBitmap.Empty) and Assigned(Item) then
  begin
    ACanvas.Font.Assign(fFont);

    // if fDrawCaption then
    // ACaption := fCaptions.Strings[Items.IndexOf(Item)]
    // else
    ACaption := Item.Caption;

    if Pos('&', ACaption) > 0 then
      ACaption := ReplaceStr(ACaption, '&', '');

    AHeight := ACanvas.TextHeight(ACaption) + 6;

    if (odSelected in State) then
    begin
      if (not Item.Enabled) then
      begin
        DrawNormal(ACanvas, ARect, fBitmap);
        ACanvas.Brush.Style := bsClear;
        ACanvas.Font.Color := fColorDisabled;
        ACanvas.TextOut(ARect.Left + 30,
          (ARect.Top + (AHeight div 2) - (ACanvas.TextHeight(ACaption) div 2)),
          ACaption);
        ACanvas.Brush.Style := bsSolid;
      end
      else
      begin
        DrawSelected(ACanvas, ARect, fBitmap);
        ACanvas.Brush.Style := bsClear;
        ACanvas.Font.Color := fColorSelected;
        ACanvas.TextOut(ARect.Left + 30,
          (ARect.Top + (AHeight div 2) - (ACanvas.TextHeight(ACaption) div 2)),
          ACaption);
        ACanvas.Brush.Style := bsSolid;
      end;
    end
    else if (odGrayed in State) then
    begin
      if (not Item.Enabled) then
      begin
        DrawNormal(ACanvas, ARect, fBitmap);
        ACanvas.Brush.Style := bsClear;
        ACanvas.Font.Color := fColorDisabled;
        ACanvas.TextOut(ARect.Left + 30,
          (ARect.Top + (AHeight div 2) - (ACanvas.TextHeight(ACaption) div 2)),
          ACaption);
        ACanvas.Brush.Style := bsSolid;
      end
      else
      begin
        DrawGrayed(ACanvas, ARect, fBitmap);
      end;
    end
    else if (odNoAccel in State) then
    begin
      DrawNormal(ACanvas, ARect, fBitmap);
      ACanvas.Brush.Style := bsClear;
      ACanvas.TextOut(ARect.Left + 30,
        (ARect.Top + (AHeight div 2) - (ACanvas.TextHeight(ACaption) div 2)),
        ACaption);
      ACanvas.Brush.Style := bsSolid;
    end
    else if (odDefault in State) then
    begin
      DrawNormal(ACanvas, ARect, fBitmap);
      ACanvas.Brush.Style := bsClear;
      ACanvas.TextOut(ARect.Left + 30,
        (ARect.Top + (AHeight div 2) - (ACanvas.TextHeight(ACaption) div 2)),
        ACaption);
      ACanvas.Brush.Style := bsSolid;
    end;

    if (odChecked in State) then
    begin
      DrawChecked(ACanvas, ARect, TMenuItem(Sender).RadioItem);
    end;
  end;
end;

procedure TZMSContextMenu.VerifMeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
var
  Item: TMenuItem;
  ACaption: string;
begin
  Item := TMenuItem(Sender);
  if (not fBitmap.Empty) and Assigned(Item) then
  begin
    ACanvas.Font.Assign(fFont);

    // if fDrawCaption then
    // ACaption := fCaptions.Strings[Items.IndexOf(Item)]
    // else
    ACaption := Item.Caption;

    if Pos('&', ACaption) > 0 then
      ACaption := ReplaceStr(ACaption, '&', '');
    if (ACaption = '-') then
    begin
      Height := 5;
      Width := ACanvas.TextWidth(ACaption) + 33;
    end
    else
    begin
      Height := ACanvas.TextHeight(ACaption) + 8;
      Width := ACanvas.TextWidth(ACaption) + 33;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('ZMSystem', [TZMSContextMenu]);
end;

end.
