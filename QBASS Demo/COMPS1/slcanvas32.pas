unit SLCanvas32;

/// ///////////////////////////////////////////////
//
// author: SalasAndriy
// contact: icq : 258-21-52
// mail: life-program@yandex.ru
// web : http://gs-team.3dn.ru/
// Ukraine, Copyright GS-Team © 2010
//
/// ///////////////////////////////////////////////
//
// Модуль для работы с битовой картой...
// Прототип стандартного класса TCanvas
// Только имеет больше возможностей...
//
/// ///////////////////////////////////////////////

interface

uses
  WinApi.Windows, Vcl.Graphics, System.SysUtils, Math;

type
  fixed = Integer;

type
  TacSLDigitalFilter = array [0 .. 2, 0 .. 2] of SmallInt;

  // Быстрое получение цвета с помощью
  // ассемблерной вставки
function GetColor24(R, G, B: Integer): TColor;
function TrimInt(i, Min, Max: Integer): Integer;
function IntToByte(i: Integer): Byte;

// Обмен
procedure Swap(var T1, T2: Integer);

// представляет целое число в формате чисел с фиксированной точкой
function int_to_fixed(Value: Integer): fixed;

// целая часть числа с фиксированной точкой
function fixed_to_int(Value: fixed): Integer;

// округление до ближайшего целого
function round_fixed(Value: fixed): Integer;

// представляет число с плавающей точкой в формате чисел с фиксированной точкой
// здесь происходят большие потери точности
function double_to_fixed(Value: double): fixed;
function float_to_fixed(Value: single): fixed;

// записывает отношение (a / b) в формате чисел с фиксированной точкой
function frac_to_fixed(a, B: Integer): fixed;

type
  TacSLColor = class(TObject)
  private
    FRed: Byte;
    FGreen: Byte;
    FBlue: Byte;
    FAlphaBlend: Byte;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Color: TacSLColor);

    property Red: Byte read FRed write FRed;
    property Green: Byte read FGreen write FGreen;
    property Blue: Byte read FBlue write FBlue;
    property AlphaBlend: Byte read FAlphaBlend write FAlphaBlend;
  end;

  TacSLAlphaMode = (slamNone, slamNormalAlpha, slamMask, slamRed, slamGreen, slamBlue, slamRejection);

  // TacSLAlphaMode - Режимы работы альфа канала
  // ===========================================================================
  // Для увеличения производительности даем возможность отключения альфаканала
  // slamNone - Альфа канал отсутствует совсем... Просчёт пикселей проходит без
  // альфа канала. Влияние на скорость отрисовки = 0%
  // slamNormalAlpha - Альфа канал включен в обычном режиме. Значение альфы
  // используется то что указано в RGBAColor.AlphaBlend
  // или же RGBAGradient.AlphaBlend при рисовании градиента.
  // ВНИМАНИЕ!
  // Если RGBAColor.AlphaBlend равен 255 тогда просчёт
  // альфа канала не происходит
  // Если RGBAColor.AlphaBlend равен 0 тогда
  // Прорисовка пикселя не происходит...
  // slamRed, slamGreen,
  // slamBlue - Режимы при которых альфа канал прощитывается относительно
  // цветов Red, Green и Blue соответственно...
  // По формуле так, чтобы максимально вычитать указанный цвет.
  // slamRejection - Режим при котором альфа канал просчитывается относительно
  // отклонения цветов Red, Green и Blue от их общего
  // равенства друг другу...
  // Пример: 0, 0, 255
  // Максимальное отклонение = 255, Альфа примит значение 255
  // Пример: 128, 191, 233
  // Максимальное отклонение = 105, Альфа примит значение 105
  // Пример: 128, 128, 128
  // Максимальное отклонение = 0, Альфа примит значение 0
  // ВНИМАНИЕ!!!
  // Режимы slamRed, slamGreen, slamBlue, slamRejection
  // Используются только при прорисовке изображений
  // Если использовать эти режимы при прорисовке элементов, просчёт альфы будет
  // такой же как при режиме slamNormalAlpha
  // ===========================================================================

  TacSLPenStyle = (slpsContinuous, slpsDots, slpsLines, slpsDotsLines, slpsMicroLines);

  // TacSLPenStyle - Стили пера
  // ===========================================================================
  // slpsContinuous - Стандартный стиль (Сплошная линия)
  // slpsDots - Стиль точки
  // slpsLines - Стиль линий отрезков
  // slpsDotsLines - Стиль линий отрезков и между отрезками точек
  // slpsMicroLines - Стиль маленьких линий отрезков
  // Пример:

  // slpsContinuous
  // __________________________________________________________________________

  // slpsDots
  // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

  // slpsLines
  // __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __

  // slpsDotsLines
  // __ . __ . __ . __ . __ . __ . __ . __ . __ . __ . __ . __ . __ . __ . __ .

  // slpsMicroLines
  // _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

  TacSLPenMode = (slpmNormal, slpmXor);

  // TacSLPenMode - Режимы рисования пером
  // ===========================================================================
  // slpmNormal - в этом режиме перо рисует "как есть" т.е. таким цветом и
  // альфой(если включено) которые указаны в RGBAColor.
  // slpmXor - в этом режиме перо рисует через Xor... Пример присвоения цветов:
  //
  // Pixel[x, y].Red := Pixel[x, y].Red xor RGBAColor.Red;
  // Pixel[x, y].Green := Pixel[x, y].Green xor RGBAColor.Green;
  // Pixel[x, y].Blue := Pixel[x, y].Blue xor RGBAColor.Blue;
  //
  // ВНИМАНИЕ!
  // Все режимы действуют только на значения RGB, но не на альфа канал!
  // Если нужно изменять режим альфы, редактируйте AlphaMode.
  // ===========================================================================

  TacSLGradientMode = (slgmNormal, slgmOnlyAlpha, slgmOnlyColor);

  // TacSLGradientMode - Режимы градиентной заливки
  // ===========================================================================
  // Для увеличения производительности и избежания дополнительного
  // Просчёта перехода альфа канала дадим возможность указывать
  // Режим градиентной заливки.
  // slgmNormal - Идёт прощёт цвета включая альфа канал
  // slgmOnlyAlpha - Идёт прощёт только альфа канала
  // slgmOnlyColor - Идёт прощёт только цвета RGB
  //
  // ВНИМАНИЕ!
  // При использовании режимов slgmNormal значения альфы будут
  // заносится в битовую карту памяти, но они не будут влиять на прорисовку
  // градиента если будет включен режим slamNormalAlpha.
  // Так же при использовании режима slgmOnlyAlpha нужного эффекта прозрачности
  // при прорисовке элементов вы не увидите, пока не будет
  // включён режим slamNormalAlpha
  // ===========================================================================

  TacSLGradientStyle = (slgsHorizontal, slgsVertical);

  // TacSLGradientStyle - Стиль градиентной заливки
  // ===========================================================================
  // slgsHorizontal горизонтальный переход
  // slgsVertical вертикальный переход
  // ===========================================================================

  TacSLPen = class(TObject)
  private
    FPenStyle: TacSLPenStyle;
    FRGBAColor: TacSLColor;
    FRGBAGradient: TacSLColor;
    FAlphaMode: TacSLAlphaMode;
    FPenMode: TacSLPenMode;
    FGradientMode: TacSLGradientMode;

    GeneratorCounter: Byte; // Генератор линий
    GeneratorLength: Byte;

    function GetGenerator: Byte;
    function GenerateLine: boolean;

    function GetColor: TColor;
    procedure SetColor(Value: TColor);
    function GetGradientColor: TColor;
    procedure SetGradientColor(Value: TColor);
    procedure SetPenStyle(const Value: TacSLPenStyle);
  public
    constructor Create;
    destructor Destroy; override;

    property PenStyle: TacSLPenStyle read FPenStyle write SetPenStyle;
    property RGBAColor: TacSLColor read FRGBAColor write FRGBAColor;
    property RGBAGradient: TacSLColor read FRGBAGradient write FRGBAGradient;
    property Color: TColor read GetColor write SetColor;
    property GradientColor: TColor read GetGradientColor write SetGradientColor;
    property AlphaMode: TacSLAlphaMode read FAlphaMode write FAlphaMode;
    property PenMode: TacSLPenMode read FPenMode write FPenMode;
    property GradientMode: TacSLGradientMode read FGradientMode write FGradientMode;
  end;

  TacSLBrushStyle = (slbsNormal, slbsClear);

  TacSLBrush = class(TObject)
  private
    FRGBAColor: TacSLColor;
    FRGBAGradient: TacSLColor;
    FAlphaMode: TacSLAlphaMode;
    FBrushStyle: TacSLBrushStyle;
    FGradientMode: TacSLGradientMode;

    FRGBAQuadroGradientLT: TacSLColor; // Левый верхний
    FRGBAQuadroGradientRT: TacSLColor; // Правый верхний
    FRGBAQuadroGradientLB: TacSLColor; // Левый нижний
    FRGBAQuadroGradientRB: TacSLColor; // Правый нижний

    function GetGradientColor: TColor;
    procedure SetGradientColor(Value: TColor);
    function GetColor: TColor;
    procedure SetColor(Value: TColor);
  public
    constructor Create;
    destructor Destroy; override;

    property BrushStyle: TacSLBrushStyle read FBrushStyle write FBrushStyle;
    property RGBAColor: TacSLColor read FRGBAColor write FRGBAColor;
    property RGBAGradient: TacSLColor read FRGBAGradient write FRGBAGradient;
    property Color: TColor read GetColor write SetColor;
    property GradientColor: TColor read GetGradientColor write SetGradientColor;
    property AlphaMode: TacSLAlphaMode read FAlphaMode write FAlphaMode;
    property GradientMode: TacSLGradientMode read FGradientMode write FGradientMode;

    property RGBAQuadroGradientLT: TacSLColor read FRGBAQuadroGradientLT write FRGBAQuadroGradientLT;
    property RGBAQuadroGradientRT: TacSLColor read FRGBAQuadroGradientRT write FRGBAQuadroGradientRT;
    property RGBAQuadroGradientLB: TacSLColor read FRGBAQuadroGradientLB write FRGBAQuadroGradientLB;
    property RGBAQuadroGradientRB: TacSLColor read FRGBAQuadroGradientRB write FRGBAQuadroGradientRB;
  end;

  TacSLCanvas32 = class(TObject)
  private
    FVideoData: Pointer;

    FPenPos: TPoint;

    FWidth: Integer;
    FHeight: Integer;
    FDelta: Integer;

    FStartAddress: Integer;
    FDeltaAddress: Integer;

    FPen: TacSLPen;
    FBrush: TacSLBrush;

    FScanLines: array of PRGBQuad;

    SpecialColorTemp: TacSLColor;
    GradientColorTemp: TacSLColor;

    GVectorLen: Integer;
    GVectorPos: Integer;

    AttachedMemory: boolean;

    // Процедура для расчёта градиента с определённым шагом GVectorPos
    procedure GetGradientRGB(GMode: TacSLGradientMode; InputColor1, InputColor2: TacSLColor; Reverse: boolean;
      out R, G, B, a: Byte);

    procedure RendererPixel(X, Y: Integer; Source: PRGBQuad; Reverse: boolean);

    // Для скорости ставим дерективу inline
    function ExtractNotRed(R, G, B: Byte): Byte;    // inline;
    function ExtractNotGreen(R, G, B: Byte): Byte;  // inline;
    function ExtractNotBlue(R, G, B: Byte): Byte;   // inline;
    function ExtractRejection(R, G, B: Byte): Byte; // inline;

    // Процедуры для ввода пикселей при определённых операциях
    procedure PutPixel(X, Y: Integer);
    procedure PutSpecialPixel(X, Y: Integer);
    procedure PutGradientPixel(X, Y: Integer);

    // Ввод пикселя с параметрами FBrush
    // Для зарисовки поверхностей элементов
    procedure PutBrushPixel(X, Y: Integer; InputColor: TacSLColor);

    function GetPixelRGBA(X, Y: Integer): PRGBQuad;
    function GetPixelColor(X, Y: Integer): TColor;
    function GetSpeedPixelColor(X, Y: Integer): TColor; // Assebmler

    // Функция получения указателя на массив бит
    // Это аналог TBitmap.ScanLine[Index: Integer]
    function GetScanLine(Index: Integer): Pointer;

    function GetPixelRValue(X, Y: Integer): Byte;
    function GetPixelGValue(X, Y: Integer): Byte;
    function GetPixelBValue(X, Y: Integer): Byte;
    function GetPixelAValue(X, Y: Integer): Byte;

    procedure SetPixelRValue(X, Y: Integer; const Value: Byte);
    procedure SetPixelGValue(X, Y: Integer; const Value: Byte);
    procedure SetPixelBValue(X, Y: Integer; const Value: Byte);
    procedure SetPixelAValue(X, Y: Integer; const Value: Byte);

    procedure SetPixelRGBA(X, Y: Integer; const Value: PRGBQuad);
    procedure SetPixelColor(X, Y: Integer; const Value: TColor);
    procedure SetSpeedPixel(X, Y: Integer; const Value: TColor); // Assebmler

    // Рисование элементарных линий
    procedure DrawHLine(x1, x2, Y: Integer);
    procedure DrawVLine(y1, y2, X: Integer);

    // Рисование элементарных линий для заполнения элементов
    procedure DrawBrushHLine(x1, x2, Y: Integer; InPutRGBA: TacSLColor);
    procedure DrawBrushVLine(y1, y2, X: Integer; InPutRGBA: TacSLColor);

    // Рисование градиентных элементарных линий
    procedure DrawHGradientLine(x1, x2, Y: Integer; Reverse: boolean; Ex: boolean);
    procedure DrawVGradientLine(y1, y2, X: Integer; Reverse: boolean; Ex: boolean);

    function LineLength(x1, y1, x2, y2: Integer): Integer;
  public
    constructor Create; overload;
    constructor Create(Bitmap: TBitmap); overload;
    constructor Create(PVideoData: Pointer; AWidth, AHeight, APitch: Integer); overload;

    destructor Destroy; override;
    // ==========================================================================
    // Процедуры работы с указателем
    // ==========================================================================
    // 1. Рисование линий
    // ==========================================================================

    procedure MoveTo(X, Y: Integer);
    procedure LineTo(X, Y: Integer);
    procedure SmoothLineTo(X, Y: Integer);
    procedure GradientLineTo(X, Y: Integer; Reverse: boolean);
    procedure GradientLineToEx(X, Y: Integer; Reverse: boolean; VectorLen, VectorPos: Integer);

    // ==========================================================================
    // 2. Круг, шар, эллипс
    // ==========================================================================

    procedure Circle(xc, yc, R: Integer);
    procedure Sphere(xc, yc, R: Integer; Reverse: boolean);

    // Пока только контур... Эллипс без заливки
    procedure Ellipse(cx, cy, Rx, Ry: Integer);

    // ==========================================================================
    // 3. Прямоугольники и триугольники
    // ==========================================================================

    procedure Rectangle(x1, y1, x2, y2: Integer); overload;
    procedure Rectangle(Rect: TRect); overload;
    procedure Rectangle(Point1, Point2: TPoint); overload;
    procedure FillRect(x1, y1, x2, y2: Integer); overload;
    procedure FillRect(Rect: TRect); overload;
    procedure FillRect(Point1, Point2: TPoint); overload;

    // Недочет в том что контур рисуется поверх заливки
    // и когда контур будет рисоваться с альфа каналом
    // он отрисуется поверх заливки Триугольника и будет уже
    // не тот эффект что при рисовании FillRect
    // Возможно в будущем исправлю, а пока и так пойдёт =)
    procedure Triangle(x1, y1, x2, y2, x3, y3: Integer); overload;
    procedure Triangle(Point1, Point2, Point3: TPoint); overload;

    // ==========================================================================
    // 4. Прямоугольники в градиентной зальвке
    // ==========================================================================

    procedure GradientFill(x1, y1, x2, y2: Integer; Reverse: boolean; Style: TacSLGradientStyle); overload;
    procedure GradientFill(Rect: TRect; Reverse: boolean; Style: TacSLGradientStyle); overload;
    procedure GradientFill(Point1, Point2: TPoint; Reverse: boolean; Style: TacSLGradientStyle); overload;
    procedure GradientFillQuadro(x1, y1, x2, y2: Integer); overload;
    procedure GradientFillQuadro(Rect: TRect); overload;
    procedure GradientFillQuadro(Point1, Point2: TPoint); overload;

    // ==========================================================================
    // 5. Утилиты
    // ==========================================================================

    // Задает всей памяти указанные значения
    // Это не рисование... Можно сравнить с ZeroMemory
    procedure SetAllPixels(Red, Green, Blue, Alpha: Byte); overload;
    procedure SetAllPixels(Red, Green, Blue: Byte); overload; // Assebmler
    procedure SetAllPixels(Color: TColor); overload; // Assebmler

    // Захвачиваем память
    function AttachTo(PVideoData: Pointer; AWidth, AHeight, APitch: Integer): boolean; overload;
    function AttachTo(Bitmap: TBitmap): boolean; overload;

    // Отделяемся от памяти
    procedure DetachMemory;

    // ==========================================================================
    // 6. Рендеринг
    // ==========================================================================

    // Напоминаю, что Рендеринг изображений происходит
    // с учетом свойства Brush.AlphaMode
    // Так что будьте внимательны
    // AlphaReverse указывает реверсировать полученый альфа канал
    // Т.е. если альфа равна 255 то она будет равна нулю, а если равна нулю, то
    // примит значение 255
    procedure Draw(X, Y: Integer; Bitmap: TBitmap; AlphaReverse: boolean); overload;
    procedure Draw(X, Y: Integer; SLCanvas32: TacSLCanvas32; AlphaReverse: boolean); overload;

    // ==========================================================================

    // Прототип TCanvas.Pen
    property Pen: TacSLPen read FPen write FPen;

    // Прототип TCanvas.Brush
    property Brush: TacSLBrush read FBrush write FBrush;

    // свойство получения указателя на массив бит
    // Это аналог TBitmap.ScanLine[Index: Integer]
    property ScanLine[Row: Integer]: Pointer read GetScanLine;

    // Аналог TCanvas.PenPos
    property PenPos: TPoint read FPenPos write FPenPos;

    property PixelRGBA[X, Y: Integer]: PRGBQuad read GetPixelRGBA write SetPixelRGBA;
    property PixelColor[X, Y: Integer]: TColor read GetPixelColor write SetPixelColor;

    property PixelRValue[X, Y: Integer]: Byte read GetPixelRValue write SetPixelRValue;
    property PixelGValue[X, Y: Integer]: Byte read GetPixelGValue write SetPixelGValue;
    property PixelBValue[X, Y: Integer]: Byte read GetPixelBValue write SetPixelBValue;
    property PixelAValue[X, Y: Integer]: Byte read GetPixelAValue write SetPixelAValue;

    property LoadedMemory: boolean read AttachedMemory;

    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

  TacSLRecall = class(TObject)
  private
    TempPen: TacSLPen;
    TempBrush: TacSLBrush;
    PenObject: TacSLPen;
    BrushObject: TacSLBrush;
  public
    constructor Create(APen: TacSLPen); overload;
    constructor Create(ABrush: TacSLBrush); overload;
    destructor Destroy;
    procedure Free;
  end;

type
  TLine = array [0 .. 0] of TRGBQuad;
  PLine = ^TLine;
  TPLines = array [0 .. 0] of PLine;
  PPLines = ^TPLines;

  TBytes = array [0 .. 0] of Byte;
  PBytes = ^TBytes;
  TPBytes = array [0 .. 0] of PBytes;
  PPBytes = ^TPBytes;

const
  BlurFilter: TacSLDigitalFilter = ((-1, -1, -1), (-1, 1, -1), (-1, -1, -1));
  SharpFilter: TacSLDigitalFilter = ((-5, -5, -5), (-5, 160, -5), (-5, -5, -5));
  EdgeFilter: TacSLDigitalFilter = ((-1, -1, -1), (-1, 8, -1), (-1, -1, -1));
  EmbossFilter: TacSLDigitalFilter = ((-100, 0, 0), (0, 0, 0), (0, 0, 100));
  Enhance3DFilter: TacSLDigitalFilter = ((-100, 5, 5), (5, 5, 5), (5, 5, 100));
  TVImageFilter: TacSLDigitalFilter = ((50, 50, 50), (50, 50, 50), (50, 50, 50));

procedure ApplyFilter(Dst: TacSLCanvas32; DF: TacSLDigitalFilter);
procedure SplitBlur(Bmp: TacSLCanvas32; Amount: Integer);
procedure Twist(Bmp, Dst: TacSLCanvas32; Amount: Integer);
procedure FishEye(Bmp, Dst: TacSLCanvas32; Amount: Extended);
procedure Spray(Bmp, Dst: TacSLCanvas32; Amount: Integer);
procedure HorizontalLinesMove(Dst: TacSLCanvas32; Amount: Integer);
procedure VerticalLinesMove(Dst: TacSLCanvas32; Amount: Integer);

implementation

procedure HorizontalLinesMove(Dst: TacSLCanvas32; Amount: Integer);
var
  X, Y: Integer;
begin
  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;

  for Y := 0 to Dst.Height - 1 do
  begin
    if (Y mod 2) = 0 then
    begin
      for X := 0 to Dst.Width - 1 do
      begin
        Dst.PixelColor[X, Y] := Dst.PixelColor[X + Amount, Y]
      end
    end
    else
    begin
      for X := Dst.Width - 1 downto 0 do
      begin
        Dst.PixelColor[X, Y] := Dst.PixelColor[X - Amount, Y]
      end
    end
  end
end;

procedure VerticalLinesMove(Dst: TacSLCanvas32; Amount: Integer);
var
  X, Y: Integer;
begin
  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;
  for X := 0 to Dst.Width - 1 do
  begin
    if (X mod 2) = 0 then
    begin
      for Y := 0 to Dst.Height - 1 do
      begin
        Dst.PixelColor[X, Y] := Dst.PixelColor[X, Y + Amount]
      end
    end
    else
    begin
      for Y := Dst.Height - 1 downto 0 do
      begin
        Dst.PixelColor[X, Y] := Dst.PixelColor[X, Y - Amount]
      end
    end
  end
end;

procedure Spray(Bmp, Dst: TacSLCanvas32; Amount: Integer);
var
  R, X, Y: Integer;
  RDM: Integer;
  x2, y2: Integer;
begin
  if not Assigned(Bmp) then
    Exit;

  if not Bmp.LoadedMemory then
    Exit;

  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;

  for Y := 0 to Bmp.Height - 1 do
  begin
    for X := 0 to Bmp.Width - 1 do
    begin
      { r:=Random(Amount);
        Dst.PixelColor[x,y]:=
        Bmp.PixelColor[TrimInt(x+(r-Random(r*2)),0,Bmp.Width-1),
        TrimInt(y+(r-Random(r*2)),0,Bmp.Height-1)]; }
      R := ((-Amount) div 2) + Random(Amount);

      RDM := Random(8);

      if RDM = 0 then
      begin
        x2 := TrimInt(X + (R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (R), 0, Bmp.Height - 1)
      end
      else if RDM = 1 then
      begin
        x2 := TrimInt(X + (-R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (R), 0, Bmp.Height - 1)
      end
      else if RDM = 2 then
      begin
        x2 := TrimInt(X + (-R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (-R), 0, Bmp.Height - 1)
      end
      else if RDM = 3 then
      begin
        x2 := TrimInt(X + (R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (-R), 0, Bmp.Height - 1)
      end
      else if RDM = 4 then
      begin
        x2 := TrimInt(X, 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (R), 0, Bmp.Height - 1)
      end
      else if RDM = 5 then
      begin
        x2 := TrimInt(X, 0, Bmp.Width - 1);
        y2 := TrimInt(Y + (-R), 0, Bmp.Height - 1)
      end
      else if RDM = 6 then
      begin
        x2 := TrimInt(X + (R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y, 0, Bmp.Height - 1)
      end
      else
      begin
        x2 := TrimInt(X + (-R), 0, Bmp.Width - 1);
        y2 := TrimInt(Y, 0, Bmp.Height - 1)
      end;

      Dst.PixelColor[X, Y] := Bmp.PixelColor[x2, y2]
    end
  end
end;

procedure ApplyFilter(Dst: TacSLCanvas32; DF: TacSLDigitalFilter);
var
  i, j, X, Y: Integer;
  Sum, Red, Green, Blue: Longint; // total value
  Tmp, Color: PRGBQuad;
begin
  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;

  Sum := DF[0, 0] + DF[1, 0] + DF[2, 0] + DF[0, 1] + DF[1, 1] + DF[2, 1] + DF[0, 2] + DF[1, 2] + DF[2, 2];

  if Sum = 0 then
    Sum := 1;

  for Y := 0 to Dst.Height - 1 do
  begin
    Color := Dst.ScanLine[Y];
    for X := 0 to Dst.Width - 1 do
    begin
      Red := 0;
      Green := 0;
      Blue := 0;
      for i := 0 to 2 do
        for j := 0 to 2 do
        begin
          Tmp := Dst.PixelRGBA[TrimInt(X + i - 1, 0, Dst.Width - 1), TrimInt(Y + j - 1, 0, Dst.Height - 1)];
          Inc(Blue, DF[i, j] * Tmp.rgbBlue);
          Inc(Green, DF[i, j] * Tmp.rgbGreen);
          Inc(Red, DF[i, j] * Tmp.rgbRed);
        end;

      Color.rgbBlue := IntToByte(Blue div Sum);
      Color.rgbGreen := IntToByte(Green div Sum);
      Color.rgbRed := IntToByte(Red div Sum);
      Inc(Color);
    end;
  end;
end;

procedure SplitBlur(Bmp: TacSLCanvas32; Amount: Integer);
var
  // Lin1, Lin2: PRGBQuad;
  pc: PRGBQuad;
  cx, X, Y: Integer;
  Buf: array [0 .. 3] of PRGBQuad;
begin
  if not Assigned(Bmp) then
    Exit;

  if not Bmp.LoadedMemory then
    Exit;

  for Y := 0 to Bmp.Height - 1 do
  begin
    pc := Bmp.ScanLine[Y];
    for X := 0 to Bmp.Width - 1 do
    begin
      cx := TrimInt(X + Amount, 0, Bmp.Width - 1);
      Buf[0] := Bmp.PixelRGBA[cx, TrimInt(Y + Amount, 0, Bmp.Height - 1)];
      Buf[1] := Bmp.PixelRGBA[cx, TrimInt(Y - Amount, 0, Bmp.Height - 1)];
      cx := TrimInt(X - Amount, 0, Bmp.Width - 1);
      Buf[2] := Bmp.PixelRGBA[cx, TrimInt(Y + Amount, 0, Bmp.Height - 1)];
      Buf[3] := Bmp.PixelRGBA[cx, TrimInt(Y - Amount, 0, Bmp.Height - 1)];
      pc.rgbBlue := (Buf[0].rgbBlue + Buf[1].rgbBlue + Buf[2].rgbBlue + Buf[3].rgbBlue) shr 2;
      pc.rgbGreen := (Buf[0].rgbGreen + Buf[1].rgbGreen + Buf[2].rgbGreen + Buf[3].rgbGreen) shr 2;
      pc.rgbRed := (Buf[0].rgbRed + Buf[1].rgbRed + Buf[2].rgbRed + Buf[3].rgbRed) shr 2;
      Inc(pc);
    end
  end
end;

procedure Twist(Bmp, Dst: TacSLCanvas32; Amount: Integer);
var
  fxmid, fymid: single;
  txmid, tymid: single;
  fx, fy: single;
  tx2, ty2: single;
  R: single;
  theta: single;
  ifx, ify: Integer;
  dx, dy: single;
  OFFSET: single;
  ty, tx: Integer;
  weight_x, weight_y: array [0 .. 1] of single;
  weight: single;
  new_red, new_green: Integer;
  new_blue: Integer;
  total_red, total_green: single;
  total_blue: single;
  ix, iy: Integer;
  sli, slo: PLine;

  function ArcTan2(xt, yt: single): single;
  begin
    if xt = 0 then
      if yt > 0 then
        Result := Pi / 2
      else
        Result := -(Pi / 2)
    else
    begin
      Result := ArcTan(yt / xt);
      if xt < 0 then
        Result := Pi + ArcTan(yt / xt);
    end;
  end;

begin
  if not Assigned(Bmp) then
    Exit;

  if not Bmp.LoadedMemory then
    Exit;

  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;

  OFFSET := -(Pi / 2);
  dx := Bmp.Width - 1;
  dy := Bmp.Height - 1;
  R := Sqrt(dx * dx + dy * dy);
  tx2 := R;
  ty2 := R;
  txmid := (Bmp.Width - 1) / 2;  // Adjust these to move center of rotation
  tymid := (Bmp.Height - 1) / 2; // Adjust these to move ......
  fxmid := (Bmp.Width - 1) / 2;
  fymid := (Bmp.Height - 1) / 2;
  if tx2 >= Bmp.Width then
    tx2 := Bmp.Width - 1;
  if ty2 >= Bmp.Height then
    ty2 := Bmp.Height - 1;

  for ty := 0 to Round(ty2) do
  begin
    for tx := 0 to Round(tx2) do
    begin
      dx := tx - txmid;
      dy := ty - tymid;
      R := Sqrt(dx * dx + dy * dy);
      if R = 0 then
      begin
        fx := 0;
        fy := 0;
      end
      else
      begin
        theta := ArcTan2(dx, dy) - R / Amount - OFFSET;
        fx := R * Cos(theta);
        fy := R * Sin(theta);
      end;
      fx := fx + fxmid;
      fy := fy + fymid;

      ify := Trunc(fy);
      ifx := Trunc(fx);
      // Calculate the weights.
      if fy >= 0 then
      begin
        weight_y[1] := fy - ify;
        weight_y[0] := 1 - weight_y[1];
      end
      else
      begin
        weight_y[0] := -(fy - ify);
        weight_y[1] := 1 - weight_y[0];
      end;
      if fx >= 0 then
      begin
        weight_x[1] := fx - ifx;
        weight_x[0] := 1 - weight_x[1];
      end
      else
      begin
        weight_x[0] := -(fx - ifx);
        weight_x[1] := 1 - weight_x[0];
      end;

      if ifx < 0 then
        ifx := Bmp.Width - 1 - (-ifx mod Bmp.Width)
      else if ifx > Bmp.Width - 1 then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height - 1 - (-ify mod Bmp.Height)
      else if ify > Bmp.Height - 1 then
        ify := ify mod Bmp.Height;

      total_red := 0.0;
      total_green := 0.0;
      total_blue := 0.0;
      for ix := 0 to 1 do
      begin
        for iy := 0 to 1 do
        begin
          if ify + iy < Bmp.Height then
            sli := Bmp.ScanLine[ify + iy]
          else
            sli := Bmp.ScanLine[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then
          begin
            new_red := sli^[ifx + ix].rgbRed;
            new_green := sli^[ifx + ix].rgbGreen;
            new_blue := sli^[ifx + ix].rgbBlue;
          end
          else
          begin
            new_red := sli^[Bmp.Width - ifx - ix].rgbRed;
            new_green := sli^[Bmp.Width - ifx - ix].rgbGreen;
            new_blue := sli^[Bmp.Width - ifx - ix].rgbBlue;
          end;
          weight := weight_x[ix] * weight_y[iy];
          total_red := total_red + new_red * weight;
          total_green := total_green + new_green * weight;
          total_blue := total_blue + new_blue * weight;
        end;
      end;
      slo := Dst.ScanLine[ty];
      slo^[tx].rgbRed := Round(total_red);
      slo^[tx].rgbGreen := Round(total_green);
      slo^[tx].rgbBlue := Round(total_blue);
    end;
  end;
end;

procedure FishEye(Bmp, Dst: TacSLCanvas32; Amount: Extended);
var
  xmid, ymid: single;
  fx, fy: single;
  r1, r2: single;
  ifx, ify: Integer;
  dx, dy: single;
  rmax: single;
  ty, tx: Integer;
  weight_x, weight_y: array [0 .. 1] of single;
  weight: single;
  new_red, new_green: Integer;
  new_blue: Integer;
  total_red, total_green: single;
  total_blue: single;
  ix, iy: Integer;
  sli, slo: PLine;
begin
  if not Assigned(Bmp) then
    Exit;

  if not Bmp.LoadedMemory then
    Exit;

  if not Assigned(Dst) then
    Exit;

  if not Dst.LoadedMemory then
    Exit;

  xmid := Bmp.Width / 2;
  ymid := Bmp.Height / 2;
  rmax := Dst.Width * Amount;

  for ty := 0 to Dst.Height - 1 do
  begin
    for tx := 0 to Dst.Width - 1 do
    begin
      dx := tx - xmid;
      dy := ty - ymid;
      r1 := Sqrt(dx * dx + dy * dy);
      if r1 = 0 then
      begin
        fx := xmid;
        fy := ymid;
      end
      else
      begin
        r2 := rmax / 2 * (1 / (1 - r1 / rmax) - 1);
        fx := dx * r2 / r1 + xmid;
        fy := dy * r2 / r1 + ymid;
      end;
      ify := Trunc(fy);
      ifx := Trunc(fx);
      // Calculate the weights.
      if fy >= 0 then
      begin
        weight_y[1] := fy - ify;
        weight_y[0] := 1 - weight_y[1];
      end
      else
      begin
        weight_y[0] := -(fy - ify);
        weight_y[1] := 1 - weight_y[0];
      end;
      if fx >= 0 then
      begin
        weight_x[1] := fx - ifx;
        weight_x[0] := 1 - weight_x[1];
      end
      else
      begin
        weight_x[0] := -(fx - ifx);
        weight_x[1] := 1 - weight_x[0];
      end;

      if ifx < 0 then
        ifx := Bmp.Width - 1 - (-ifx mod Bmp.Width)
      else if ifx > Bmp.Width - 1 then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height - 1 - (-ify mod Bmp.Height)
      else if ify > Bmp.Height - 1 then
        ify := ify mod Bmp.Height;

      total_red := 0.0;
      total_green := 0.0;
      total_blue := 0.0;
      for ix := 0 to 1 do
      begin
        for iy := 0 to 1 do
        begin
          if ify + iy < Bmp.Height then
            sli := Bmp.ScanLine[ify + iy]
          else
            sli := Bmp.ScanLine[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then
          begin
            new_red := sli^[ifx + ix].rgbRed;
            new_green := sli^[ifx + ix].rgbGreen;
            new_blue := sli^[ifx + ix].rgbBlue;
          end
          else
          begin
            new_red := sli^[Bmp.Width - ifx - ix].rgbRed;
            new_green := sli^[Bmp.Width - ifx - ix].rgbGreen;
            new_blue := sli^[Bmp.Width - ifx - ix].rgbBlue;
          end;
          weight := weight_x[ix] * weight_y[iy];
          total_red := total_red + new_red * weight;
          total_green := total_green + new_green * weight;
          total_blue := total_blue + new_blue * weight;
        end;
      end;
      slo := Dst.ScanLine[ty];
      slo^[tx].rgbRed := Round(total_red);
      slo^[tx].rgbGreen := Round(total_green);
      slo^[tx].rgbBlue := Round(total_blue);

    end;
  end;
end;

function TrimInt(i, Min, Max: Integer): Integer;
begin
  if i > Max then
    Result := Max
  else if i < Min then
    Result := Min
  else
    Result := i;
end;

function IntToByte(i: Integer): Byte;
begin
  if i > 255 then
    Result := 255
  else if i < 0 then
    Result := 0
  else
    Result := i;
end;

// представляет целое число в формате чисел с фиксированной точкой
function int_to_fixed(Value: Integer): fixed;
begin
  Result := (Value shl 16);
end;

// целая часть числа с фиксированной точкой
function fixed_to_int(Value: fixed): Integer;
begin
  if (Value < 0) then
    Result := (Value shr 16 - 1);
  if (Value >= 0) then
    Result := (Value shr 16);
end;

// округление до ближайшего целого
function round_fixed(Value: fixed): Integer;
begin
  Result := fixed_to_int(Value + (1 shl 15));
end;

// представляет число с плавающей точкой в формате чисел с фиксированной точкой
// здесь происходят большие потери точности
function double_to_fixed(Value: double): fixed;
begin
  Result := Round(Value * (65536.0));
end;

function float_to_fixed(Value: single): fixed;
begin
  Result := Round(Value * (65536.0));
end;

// записывает отношение (a / b) в формате чисел с фиксированной точкой
function frac_to_fixed(a, B: Integer): fixed;
begin
  Result := Round((a shl 16) / B);
end;

function GetColor24(R, G, B: Integer): TColor;
asm
  { ecx будет содержать значение TColor }
  mov ecx,0
  { начинаем с красной компоненты }
  mov eax,R
  { необходимо убедиться, что красный находится в диапазоне 0<=Red<=255 }
  and eax,255
  { сдвигаем значение красного в правильное положение }
  shl eax,16
  { выравниваем значение TColor }
  xor ecx,eax
  { проделываем тоже самое с зелёным }
  mov eax,G
  and eax,255
  shl eax,8
  xor ecx,eax
  { и тоже самое с синим }
  mov eax,B
  and eax,255
  xor ecx,eax
  mov Result, ecx
end;

procedure Swap(var T1, T2: Integer);
var
  t3: Integer;
begin
  t3 := T1;
  T1 := T2;
  T2 := t3;
end;

{ TacSLCanvas32 }

function TacSLCanvas32.AttachTo(PVideoData: Pointer; AWidth, AHeight, APitch: Integer): boolean;
var
  i: Integer;
begin
  DetachMemory;

  FVideoData := PVideoData;

  // SpecialColorTemp := TacSLColor.Create;
  // GradientColorTemp := TacSLColor.Create;
  //
  // FPen := TacSLPen.Create;
  // FBrush := TacSLBrush.Create;

  FPenPos.X := 0;
  FPenPos.Y := 0;

  if (FVideoData <> nil) or (AWidth <> Abs(APitch)) then
  begin
    AttachedMemory := True;

    FWidth := AWidth;
    FHeight := AHeight;

    FDelta := APitch;

    SetLength(FScanLines, AHeight);
    for i := 0 to AHeight - 1 do
      FScanLines[i] := Pointer(Cardinal(PVideoData) + Cardinal(i * FDelta * 4));

    FStartAddress := Integer(PVideoData);
    FDeltaAddress := Integer(Cardinal(PVideoData) + Cardinal(1 * FDelta * 4)) - FStartAddress;
  end
  else
  begin
    FVideoData := nil;
    AttachedMemory := False;
    FWidth := 0;
    FHeight := 0;
    FDelta := 0;
    FStartAddress := 0;
    FDeltaAddress := 0;
  end;

  Result := AttachedMemory
end;

function TacSLCanvas32.AttachTo(Bitmap: TBitmap): boolean;
var
  i: Integer;
begin
  DetachMemory;

  FPenPos.X := 0;
  FPenPos.Y := 0;

  if Assigned(Bitmap) then
  begin
    if not Bitmap.Empty then
    begin
      if Bitmap.PixelFormat = pf32bit then
      begin
        if AttachedMemory then
          SetLength(FScanLines, 0); // Покидаем память захваченную до этого

        FVideoData := Bitmap.ScanLine[0];

        AttachedMemory := True;

        FWidth := Bitmap.Width;
        FHeight := Bitmap.Height;

        FDelta := -Bitmap.Width;

        SetLength(FScanLines, FHeight);
        for i := 0 to FHeight - 1 do
          FScanLines[i] := Pointer(Cardinal(FVideoData) + Cardinal(i * FDelta * 4));

        FStartAddress := Integer(FVideoData);
        FDeltaAddress := Integer(Cardinal(FVideoData) + Cardinal(1 * FDelta * 4)) - FStartAddress;
      end
      else
      begin
        FVideoData := nil;
        AttachedMemory := False;
        FWidth := 0;
        FHeight := 0;
        FDelta := 0;
        FStartAddress := 0;
        FDeltaAddress := 0;
      end;
    end
    else
    begin
      FVideoData := nil;
      AttachedMemory := False;
      FWidth := 0;
      FHeight := 0;
      FDelta := 0;
      FStartAddress := 0;
      FDeltaAddress := 0;
    end;
  end
  else
  begin
    FVideoData := nil;
    AttachedMemory := False;
    FWidth := 0;
    FHeight := 0;
    FDelta := 0;
    FStartAddress := 0;
    FDeltaAddress := 0;
  end;

  Result := AttachedMemory
end;

procedure TacSLCanvas32.Circle(xc, yc, R: Integer);
var
  dx, dy, d: Integer;
  y1, y2, y3, Y4: Integer;
  procedure sim(X, Y: Integer);
  begin
    if FBrush.FBrushStyle = slbsNormal then
    begin
      // Мроверим: рисовали ли мы здесь уже линию?
      if (y1 <> (Y + yc - 1)) and (R <> Y) then
      begin
        // Нижняя плоскость
        if (dx + 1) <= dy then
        begin
          DrawBrushHLine(X + xc - 1, xc - X, Y + yc, FBrush.FRGBAColor);
          y1 := Y + yc - 1;
        end
      end;

      // Мроверим: рисовали ли мы здесь уже линию?
      if (y2 <> (-Y + yc + 1)) and (R <> Y) then
      begin
        // Верхняя плоскость
        if (dx + 1) <= dy then
        begin
          DrawBrushHLine(X + xc - 1, xc - X, -Y + yc, FBrush.FRGBAColor);
          y2 := -Y + yc + 1;
        end
      end;

      // Мроверим: рисовали ли мы здесь уже линию?
      if y3 <> (X + yc) then
      begin
        // Центральная нижняя
        DrawBrushHLine(Y + xc - 1, xc - Y, X + yc, FBrush.FRGBAColor);
        y3 := X + yc;
      end;

      // Мроверим: рисовали ли мы здесь уже линию?
      if y3 <> (-X + yc) then
      begin
        // Центральная верхняя
        DrawBrushHLine(Y + xc - 1, xc - Y, -X + yc, FBrush.FRGBAColor);
        Y4 := -X + yc;
      end;
    end;

    PutPixel(X + xc, Y + yc);
    PutPixel(X + xc, -Y + yc);
    PutPixel(-X + xc, -Y + yc);
    PutPixel(-X + xc, Y + yc);
    PutPixel(Y + xc, X + yc);
    PutPixel(Y + xc, -X + yc);
    PutPixel(-Y + xc, -X + yc);
    PutPixel(-Y + xc, X + yc);
  end;

begin
  dy := R;
  d := 3 - 2 * dy;
  dx := 0;
  y1 := 0;
  y2 := 0;
  y3 := 0;
  Y4 := 0;

  while (dx <= dy) do
  begin
    sim(Round(dx), Round(dy));

    if d < 0 then
      d := d + 4 * dx + 6
    else
    begin
      d := d + 4 * (dx - dy) + 10;
      dy := dy - 1
    end;

    dx := dx + 1
  end
end;

procedure TacSLCanvas32.Sphere(xc, yc, R: Integer; Reverse: boolean);
var
  r2, R3, k: single;
  X, Y: Integer;
begin
  if R < 1 then
    Exit;

  r2 := R * R;

  GVectorLen := 255; // Длина вектора

  for X := 0 to R do
  begin
    for Y := 0 to X do
    begin
      R3 := X * X + Y * Y;
      if (R3 > r2) then
        break;

      k := 1 - R3 / r2;

      GVectorPos := Byte(Round(k * 255)); // Позиция вектора

      GetGradientRGB(FBrush.FGradientMode, FBrush.FRGBAColor, FBrush.FRGBAGradient, Reverse, SpecialColorTemp.FRed,
        SpecialColorTemp.FGreen, SpecialColorTemp.FBlue, SpecialColorTemp.FAlphaBlend);

      // Небольшая оптимизация
      // Проверяем может этот пиксель мы уже выводили
      // И так для всех остальных октантов
      if (yc + Y) <> (yc) then
        PutBrushPixel(xc + X, yc + Y, SpecialColorTemp);

      PutBrushPixel(xc + X, yc - Y, SpecialColorTemp);

      if (X) <> (Y) then
        PutBrushPixel(xc - X, yc + Y, SpecialColorTemp);

      if (yc - Y) <> yc then
        PutBrushPixel(xc - X, yc - Y, SpecialColorTemp);

      if (X) <> (Y) then
        PutBrushPixel(xc + Y, yc + X, SpecialColorTemp);

      if (X) <> (Y) then
        PutBrushPixel(xc + Y, yc - X, SpecialColorTemp);

      if (xc - Y) <> xc then
        PutBrushPixel(xc - Y, yc + X, SpecialColorTemp);

      if ((xc - Y) <> xc) and ((X) <> (Y)) then
        PutBrushPixel(xc - Y, yc - X, SpecialColorTemp);

      // используем
      // симметрию шара
    end
  end
end;

procedure TacSLCanvas32.Triangle(x1, y1, x2, y2, x3, y3: Integer);
var
  dx13, dx12, dx23, wx1, wx2: fixed;
  _dx13, i, j: Integer;
  X, Y: Integer;
begin
  X := FPenPos.X;
  Y := FPenPos.Y;

  if FBrush.FBrushStyle = slbsNormal then
  begin

    // Упорядочиваем точки p1(x1, y1),
    // p2(x2, y2), p3(x3, y3)
    if (y2 < y1) then
    begin
      Swap(y1, y2);
      Swap(x1, x2);
    end; // точки p1, p2 упорядочены
    if (y3 < y1) then
    begin
      Swap(y1, y3);
      Swap(x1, x3);
    end; // точки p1, p3 упорядочены
    // теперь p1 самая верхняя
    // осталось упорядочить p2 и p3
    if (y2 > y3) then
    begin
      Swap(y2, y3);
      Swap(x2, x3);
    end;

    // приращения по оси x для трёх сторон
    // треугольника
    dx13 := 0;
    dx12 := 0;
    dx23 := 0;

    // вычисляем приращения
    // в случае, если ординаты двух точек
    // совпадают, приращения
    // полагаются равными нулю
    if (y3 <> y1) then
    begin
      dx13 := int_to_fixed(x3 - x1);
      dx13 := dx13 div (y3 - y1);
    end
    else
    begin
      dx13 := 0;
    end;

    if (y2 <> y1) then
    begin
      dx12 := int_to_fixed(x2 - x1);
      dx12 := dx12 div (y2 - y1);
    end
    else
    begin
      dx12 := 0;
    end;

    if (y3 <> y2) then
    begin
      dx23 := int_to_fixed(x3 - x2);
      dx23 := dx23 div (y3 - y2);
    end
    else
    begin
      dx23 := 0;
    end;

    // "рабочие точки"
    // изначально они находятся в верхней точке
    wx1 := int_to_fixed(x1);
    wx2 := wx1;

    // сохраняем приращение dx13 в другой переменной
    _dx13 := dx13;

    // упорядочиваем приращения таким образом, чтобы
    // в процессе работы алгоритмы
    // точка wx1 была всегда левее wx2
    if (dx13 > dx12) then
    begin
      Swap(dx13, dx12);
    end;

    // растеризуем верхний полутреугольник
    for i := y1 to y2 - 1 do
    begin
      // рисуем горизонтальную линию между рабочими точками
      for j := fixed_to_int(wx1) to fixed_to_int(wx2) do
      begin
        PutBrushPixel(j, i, FBrush.FRGBAColor);
        // SetPixel(hdc, j, i, 0);
      end;
      Inc(wx1, dx13);
      Inc(wx2, dx12);
    end;

    // вырожденный случай, когда верхнего полутреугольника нет
    // надо разнести рабочие точки по оси x,
    // т.к. изначально они совпадают
    if (y1 = y2) then
    begin
      wx1 := int_to_fixed(x1);
      wx2 := int_to_fixed(x2);
    end;

    // упорядочиваем приращения
    // (используем сохраненное приращение)
    if (_dx13 < dx23) then
    begin
      Swap(_dx13, dx23);
    end;

    // растеризуем нижний полутреугольник
    for i := y2 to y3 do
    begin
      // рисуем горизонтальную линию между рабочими точками
      for j := fixed_to_int(wx1) to fixed_to_int(wx2) do
      begin
        PutBrushPixel(j, i, FBrush.FRGBAColor);
        // SetPixel(hdc, j, i, 0);
      end;
      Inc(wx1, _dx13);
      Inc(wx2, dx23);
    end;

  end;

  MoveTo(x1, y1);
  LineTo(x2, y2);
  LineTo(x3, y3);
  LineTo(x1, y1);

  MoveTo(X, Y); // Возвращаем позицию
end;

procedure TacSLCanvas32.Triangle(Point1, Point2, Point3: TPoint);
begin
  Triangle(Point1.X, Point1.Y, Point2.X, Point2.Y, Point3.X, Point3.Y);
end;

procedure TacSLCanvas32.Ellipse(cx, cy, Rx, Ry: Integer);
var
  Rx2, Ry2, twoRx2, twoRy2, p, X, Y, px, py: Integer;
begin
  Rx2 := Rx * Rx;
  Ry2 := Ry * Ry;
  twoRx2 := 2 * Rx2;
  twoRy2 := 2 * Ry2;
  X := 0;
  Y := Ry;
  px := 0;
  py := twoRx2 * Y;

  PutPixel(cx + X, cy + Y);
  PutPixel(cx - X, cy + Y);
  PutPixel(cx + X, cy - Y);
  PutPixel(cx - X, cy - Y);

  p := Ry2 - (Rx2 * Ry) + (Rx2 div 4);
  while px < py do
  begin
    Inc(X);
    Inc(px, twoRy2);
    if p < 0 then
      Inc(p, Ry2 + px)
    else
    begin
      Dec(Y);
      Dec(py, twoRx2);
      Inc(p, Ry2 + px - py);
    end;

    PutPixel(cx + X, cy + Y);
    PutPixel(cx - X, cy + Y);
    PutPixel(cx + X, cy - Y);
    PutPixel(cx - X, cy - Y);
  end;

  p := Round(Ry2 * (X + 0.5) * (X + 0.5) + Rx2 * (Y - 1) * (Y - 1) - Rx2 * Ry2);
  while Y > 0 do
  begin
    Dec(Y);
    Dec(py, twoRx2);
    if p > 0 then
      Inc(p, Rx2 - py)
    else
    begin
      Inc(X);
      Inc(px, twoRy2);
      Inc(p, Rx2 - py + px);
    end;

    PutPixel(cx + X, cy + Y);
    PutPixel(cx - X, cy + Y);
    PutPixel(cx + X, cy - Y);
    PutPixel(cx - X, cy - Y);
  end;
end;

function TacSLCanvas32.ExtractNotBlue(R, G, B: Byte): Byte;
begin
  Result := Byte(255 - MulDiv(255 - (R + G) div 2, B, 255));
end;

function TacSLCanvas32.ExtractNotGreen(R, G, B: Byte): Byte;
begin
  Result := Byte(255 - MulDiv(255 - (B + R) div 2, G, 255));
end;

function TacSLCanvas32.ExtractNotRed(R, G, B: Byte): Byte;
begin
  Result := Byte(255 - MulDiv(255 - (B + G) div 2, R, 255));
end;

function TacSLCanvas32.ExtractRejection(R, G, B: Byte): Byte;
var
  cMax, cMin: Byte;
begin
  cMax := Max(R, Max(G, B));
  cMin := Min(R, Min(G, B));

  Result := Abs(cMax - cMin);
end;

procedure TacSLCanvas32.FillRect(Point1, Point2: TPoint);
begin
  FillRect(Point1.X, Point1.Y, Point2.X, Point2.Y);
end;

procedure TacSLCanvas32.Draw(X, Y: Integer; Bitmap: TBitmap; AlphaReverse: boolean);
var
  x1, y1: Integer;
  x2, y2: Integer;
  Temp: TacSLCanvas32;
begin
  if Assigned(Bitmap) then
  begin
    Temp := TacSLCanvas32.Create(Bitmap);
    if (Temp.AttachedMemory) and (FVideoData <> Bitmap.ScanLine[0]) then
    begin
      x2 := X;
      y2 := Y;
      for y1 := 0 to Temp.FHeight - 1 do
      begin
        x2 := X;
        for x1 := 0 to Temp.FWidth - 1 do
        begin
          RendererPixel(x2, y2, Temp.PixelRGBA[x1, y1], AlphaReverse);
          Inc(x2)
        end;
        Inc(y2)
      end
    end;

    if Assigned(Temp) then
      Temp.Free
  end
end;

procedure TacSLCanvas32.Draw(X, Y: Integer; SLCanvas32: TacSLCanvas32; AlphaReverse: boolean);
var
  x1, y1: Integer;
  x2, y2: Integer;
begin
  if Assigned(SLCanvas32) then
  begin
    if SLCanvas32 <> Self then
    begin
      if (SLCanvas32.AttachedMemory) and (FVideoData <> SLCanvas32.ScanLine[0]) then
      begin
        x2 := X;
        y2 := Y;
        for y1 := 0 to SLCanvas32.FHeight - 1 do
        begin
          x2 := X;
          for x1 := 0 to SLCanvas32.FWidth - 1 do
          begin
            RendererPixel(x2, y2, SLCanvas32.PixelRGBA[x1, y1], AlphaReverse);
            Inc(x2)
          end;
          Inc(y2)
        end
      end
    end
  end
end;

procedure TacSLCanvas32.DrawBrushHLine(x1, x2, Y: Integer; InPutRGBA: TacSLColor);
var
  t: Integer;
begin
  if (x1 > x2) then
  begin
    while (x1 > x2) do
    begin
      PutBrushPixel(x1, Y, InPutRGBA);
      Dec(x1)
    end
  end
  else
  begin
    while (x1 < x2) do
    begin
      PutBrushPixel(x1, Y, InPutRGBA);
      Inc(x1)
    end
  end
end;

procedure TacSLCanvas32.DrawBrushVLine(y1, y2, X: Integer; InPutRGBA: TacSLColor);
var
  t: Integer;
begin
  if (y1 > y2) then
  begin
    while (y1 > y2) do
    begin
      PutBrushPixel(X, y1, FBrush.FRGBAColor);
      Dec(y1)
    end
  end
  else
  begin
    while (y1 < y2) do
    begin
      PutBrushPixel(X, y1, FBrush.FRGBAColor);
      Inc(y1)
    end
  end
end;

procedure TacSLCanvas32.MoveTo(X, Y: Integer);
begin
  FPenPos.X := X;
  FPenPos.Y := Y;
end;

procedure TacSLCanvas32.DrawHLine(x1, x2, Y: Integer);
var
  t: Integer;
begin
  if (x1 > x2) then
  begin
    while (x1 > x2) do
    begin
      if FPen.GenerateLine then
        PutPixel(x1, Y);
      Dec(x1)
    end
  end
  else
  begin
    while (x1 < x2) do
    begin
      if FPen.GenerateLine then
        PutPixel(x1, Y);
      Inc(x1)
    end
  end
end;

procedure TacSLCanvas32.DrawVLine(y1, y2, X: Integer);
var
  t: Integer;
begin
  if (y1 > y2) then
  begin
    while (y1 > y2) do
    begin
      if FPen.GenerateLine then
        PutPixel(X, y1);
      Dec(y1)
    end
  end
  else
  begin
    while (y1 < y2) do
    begin
      if FPen.GenerateLine then
        PutPixel(X, y1);
      Inc(y1)
    end
  end
end;

procedure TacSLCanvas32.LineTo(X, Y: Integer);
var
  d, ax, ay, sx, sy, dx, dy: Integer;
  x1, y1, x2, y2: Integer;
  p: PRGBQuad;
begin
  if (FPenPos.Y = Y) then
  begin
    DrawHLine(FPenPos.X, X, FPenPos.Y);
    MoveTo(X, Y);
    Exit;
  end
  else if (FPenPos.X = X) then
  begin
    DrawVLine(FPenPos.Y, Y, FPenPos.X);
    MoveTo(X, Y);
    Exit;
  end;
  (* Не порядок! Бывает что функция не отсекает линию, а стает причиной зависания!
    else if not cut_line(FPenPos.X, FPenPos.Y, X, Y) then
    Exit;
  *)
  x1 := FPenPos.X;
  y1 := FPenPos.Y;
  x2 := X;
  y2 := Y;
  MoveTo(X, Y);

  dx := x2 - x1;
  ax := Abs(dx) shl 1;
  if dx < 0 then
    sx := -1
  else
    sx := 1;
  dy := y2 - y1;
  ay := Abs(dy) shl 1;
  if dy < 0 then
    sy := -1
  else
    sy := 1;

  if FPen.GenerateLine then
    PutPixel(x1, y1);
  if ax > ay then
  begin
    d := ay - (ax shr 1);
    // while x1<>x2 do
    while x1 < x2 do
    begin
      if d > -1 then
      begin
        Inc(y1, sy);
        Dec(d, ax);
      end;
      Inc(x1, sx);
      Inc(d, ay);

      if FPen.GenerateLine then
        if x1 <> x2 then
          PutPixel(x1, y1);
    end;
  end
  else
  begin
    d := ax - (ay shr 1);
    // while y1<>y2 do
    while y1 < y2 do
    begin
      if d >= 0 then
      begin
        Inc(x1, sx);
        Dec(d, ay);
      end;
      Inc(y1, sy);
      Inc(d, ax);

      if FPen.GenerateLine then
        if y1 <> y2 then
          PutPixel(x1, y1);
    end;
  end;
end;

procedure TacSLCanvas32.SmoothLineTo(X, Y: Integer);
var
  dx, dy, d, s, ci, ea, ec: Integer;
  p: PRGBQuad;
  x1, y1, x2, y2: Integer;
begin
  x1 := FPenPos.X;
  y1 := FPenPos.Y;

  if (y1 = Y) or (x1 = X) then
    LineTo(X, Y)
  else
  (* Не порядок! Бывает что функция не отсекает линию, а стает причиной зависания!
    if not cut_line(X1, Y1, X, Y) then
    Exit
    else *)
  begin
    x2 := X;
    y2 := Y;
    MoveTo(X, Y);

    if FPen.GenerateLine then
      PutPixel(x1, y1);

    if y1 > y2 then
    begin
      d := y1;
      y1 := y2;
      y2 := d;
      d := x1;
      x1 := x2;
      x2 := d;
    end;

    dx := x2 - x1;
    dy := y2 - y1;
    if dx > -1 then
      s := 1
    else
    begin
      s := -1;
      dx := -dx;
    end;
    ec := 0;

    if dy > dx then
    begin
      ea := (dx shl 16) div dy;
      while dy > 1 do
      begin
        Dec(dy);
        d := ec;
        Inc(ec, ea);
        ec := ec and $FFFF;
        if ec <= d then
          Inc(x1, s);
        Inc(y1);
        ci := ec shr 8;

        if FPen.GenerateLine then
        begin

          p := PixelRGBA[x1, y1];

          if p <> nil then
          begin
            SpecialColorTemp.Blue := (p^.rgbBlue - FPen.FRGBAColor.FBlue) * ci shr 8 + FPen.FRGBAColor.FBlue;
            SpecialColorTemp.Green := (p^.rgbGreen - FPen.FRGBAColor.FGreen) * ci shr 8 + FPen.FRGBAColor.FGreen;
            SpecialColorTemp.Red := (p^.rgbRed - FPen.FRGBAColor.FRed) * ci shr 8 + FPen.FRGBAColor.FRed;
            PutSpecialPixel(x1, y1);
          end;

          p := PixelRGBA[x1 + s, y1];

          if p <> nil then
          begin
            SpecialColorTemp.Blue := (FPen.FRGBAColor.FBlue - p^.rgbBlue) * ci shr 8 + p^.rgbBlue;
            SpecialColorTemp.Green := (FPen.FRGBAColor.FGreen - p^.rgbGreen) * ci shr 8 + p^.rgbGreen;
            SpecialColorTemp.Red := (FPen.FRGBAColor.FRed - p^.rgbRed) * ci shr 8 + p^.rgbRed;
            PutSpecialPixel(x1 + s, y1);
          end
        end
      end
    end
    else
    begin
      ea := (dy shl 16) div dx;
      while dx > 1 do
      begin
        Dec(dx);
        d := ec;
        Inc(ec, ea);
        ec := ec and $FFFF;
        if ec <= d then
          Inc(y1);
        Inc(x1, s);
        ci := ec shr 8;

        if FPen.GenerateLine then
        begin

          p := PixelRGBA[x1, y1];

          if p <> nil then
          begin
            SpecialColorTemp.Blue := (p^.rgbBlue - FPen.FRGBAColor.FBlue) * ci shr 8 + FPen.FRGBAColor.FBlue;
            SpecialColorTemp.Green := (p^.rgbGreen - FPen.FRGBAColor.FGreen) * ci shr 8 + FPen.FRGBAColor.FGreen;
            SpecialColorTemp.Red := (p^.rgbRed - FPen.FRGBAColor.FRed) * ci shr 8 + FPen.FRGBAColor.FRed;
            PutSpecialPixel(x1, y1);
          end;

          p := PixelRGBA[x1, y1 + 1];

          if p <> nil then
          begin
            SpecialColorTemp.Blue := (FPen.FRGBAColor.FBlue - p^.rgbBlue) * ci shr 8 + p^.rgbBlue;
            SpecialColorTemp.Green := (FPen.FRGBAColor.FGreen - p^.rgbGreen) * ci shr 8 + p^.rgbGreen;
            SpecialColorTemp.Red := (FPen.FRGBAColor.FRed - p^.rgbRed) * ci shr 8 + p^.rgbRed;
            PutSpecialPixel(x1, y1 + 1);
          end
        end
      end
    end
  end
end;

procedure TacSLCanvas32.DrawHGradientLine(x1, x2, Y: Integer; Reverse: boolean; Ex: boolean);
var
  t: Integer;
begin
  if (x1 > x2) then
  begin
    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

    while (x1 > x2) do
    begin
      if not Ex then
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

      if not Ex then
        Inc(GVectorPos);

      if FPen.GenerateLine then
        PutGradientPixel(x1, Y);
      Dec(x1)
    end
  end
  else
  begin
    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

    while (x1 < x2) do
    begin
      if not Ex then
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

      if not Ex then
        Inc(GVectorPos);

      if FPen.GenerateLine then
        PutGradientPixel(x1, Y);
      Inc(x1)
    end
  end
end;

procedure TacSLCanvas32.DrawVGradientLine(y1, y2, X: Integer; Reverse: boolean; Ex: boolean);
var
  t: Integer;
begin
  if (y1 > y2) then
  begin
    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

    while (y1 > y2) do
    begin
      if not Ex then
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

      if not Ex then
        Inc(GVectorPos);

      if FPen.GenerateLine then
        PutGradientPixel(X, y1);

      Dec(y1)
    end
  end
  else
  begin
    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

    while (y1 < y2) do
    begin
      if not Ex then
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);
      if not Ex then
        Inc(GVectorPos);

      if FPen.GenerateLine then
        PutGradientPixel(X, y1);

      Inc(y1)
    end
  end
end;

function TacSLCanvas32.LineLength(x1, y1, x2, y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(x2 - x1) + Sqr(y2 - y1)))
end;

procedure TacSLCanvas32.GradientLineTo(X, Y: Integer; Reverse: boolean);
var
  d, ax, ay, sx, sy, dx, dy: Integer;
  x1, y1, x2, y2: Integer;
  p: PRGBQuad;
begin
  x1 := FPenPos.X;
  y1 := FPenPos.Y;
  x2 := X;
  y2 := Y;
  GVectorLen := LineLength(x1, y1, x2, y2) - 1;
  GVectorPos := 0;

  if (FPenPos.Y = Y) then
  begin
    DrawHGradientLine(FPenPos.X, X, FPenPos.Y, Reverse, False);
    MoveTo(X, Y);
    Exit;
  end
  else if (FPenPos.X = X) then
  begin
    DrawVGradientLine(FPenPos.Y, Y, FPenPos.X, Reverse, False);
    MoveTo(X, Y);
    Exit;
  end;
  (* Не порядок! Бывает что функция не отсекает линию, а стает причиной зависания!
    else if not cut_line(X1, Y1, X, Y) then
    Exit;
  *)
  MoveTo(X, Y);

  dx := x2 - x1;
  ax := Abs(dx) shl 1;
  if dx < 0 then
    sx := -1
  else
    sx := 1;
  dy := y2 - y1;
  ay := Abs(dy) shl 1;
  if dy < 0 then
    sy := -1
  else
    sy := 1;

  GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
    GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

  PutGradientPixel(x1, y1);

  if ax > ay then
  begin
    d := ay - (ax shr 1);
    // while x1<>x2 do
    while x1 < x2 do
    begin
      if d > -1 then
      begin
        Inc(y1, sy);
        Dec(d, ax);
      end;
      Inc(x1, sx);
      Inc(d, ay);
      if x1 <> x2 then
      begin
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);
        Inc(GVectorPos);
        PutGradientPixel(x1, y1);
      end;
    end;
  end
  else
  begin
    d := ax - (ay shr 1);
    // while y1<>y2 do
    while y1 < y2 do
    begin
      if d >= 0 then
      begin
        Inc(x1, sx);
        Dec(d, ay);
      end;
      Inc(y1, sy);
      Inc(d, ax);
      if y1 <> y2 then
      begin
        GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
          GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);
        Inc(GVectorPos);
        PutGradientPixel(x1, y1);
      end
    end
  end
end;

procedure TacSLCanvas32.GradientLineToEx(X, Y: Integer; Reverse: boolean; VectorLen, VectorPos: Integer);
var
  d, ax, ay, sx, sy, dx, dy: Integer;
  x1, y1, x2, y2: Integer;
  p: PRGBQuad;
begin
  x1 := FPenPos.X;
  y1 := FPenPos.Y;
  x2 := X;
  y2 := Y;

  if GVectorPos > GVectorLen then
    GVectorPos := VectorLen - 1;

  GVectorLen := Abs(VectorLen - 1);
  GVectorPos := Abs(VectorPos);

  if (FPenPos.Y = Y) then
  begin
    DrawHGradientLine(FPenPos.X, X, FPenPos.Y, Reverse, True);
    MoveTo(X, Y);
    Exit;
  end
  else if (FPenPos.X = X) then
  begin
    DrawVGradientLine(FPenPos.Y, Y, FPenPos.X, Reverse, True);
    MoveTo(X, Y);
    Exit;
  end;
  (* Не порядок! Бывает что функция не отсекает линию, а стает причиной зависания!
    else if not cut_line(X1, Y1, X, Y) then
    Exit;
  *)
  MoveTo(X, Y);

  dx := x2 - x1;
  ax := Abs(dx) shl 1;
  if dx < 0 then
    sx := -1
  else
    sx := 1;
  dy := y2 - y1;
  ay := Abs(dy) shl 1;
  if dy < 0 then
    sy := -1
  else
    sy := 1;

  GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
    GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);

  PutGradientPixel(x1, y1);

  if ax > ay then
  begin
    d := ay - (ax shr 1);

    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);
    while x1 <> x2 do
    begin
      if d > -1 then
      begin
        Inc(y1, sy);
        Dec(d, ax);
      end;
      Inc(x1, sx);
      Inc(d, ay);
      if x1 <> x2 then
      begin
        PutGradientPixel(x1, y1);
      end;
    end;
  end
  else
  begin
    d := ax - (ay shr 1);

    GetGradientRGB(FPen.FGradientMode, FPen.FRGBAColor, FPen.FRGBAGradient, Reverse, GradientColorTemp.FRed,
      GradientColorTemp.FGreen, GradientColorTemp.FBlue, GradientColorTemp.FAlphaBlend);
    while y1 <> y2 do
    begin
      if d >= 0 then
      begin
        Inc(x1, sx);
        Dec(d, ay);
      end;
      Inc(y1, sy);
      Inc(d, ax);
      if y1 <> y2 then
      begin
        PutGradientPixel(x1, y1);
      end
    end
  end
end;

procedure TacSLCanvas32.Rectangle(Rect: TRect);
begin
  Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure TacSLCanvas32.Rectangle(x1, y1, x2, y2: Integer);
var
  i: Integer;
  X, Y: Integer;
begin
  if x1 > x2 then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;
  if y1 > y2 then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  Dec(x2);
  Dec(y2);

  X := FPenPos.X;
  Y := FPenPos.Y;

  MoveTo(x1, y1);
  LineTo(x2, y1);
  LineTo(x2, y2);
  LineTo(x1, y2);
  LineTo(x1, y1);

  FPenPos.X := X;
  FPenPos.Y := Y;
end;

procedure TacSLCanvas32.FillRect(Rect: TRect);
begin
  FillRect(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure TacSLCanvas32.FillRect(x1, y1, x2, y2: Integer);
var
  i, X, Y: Integer;
begin
  if x1 > x2 then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;
  if y1 > y2 then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  if FBrush.FBrushStyle = slbsNormal then
  begin
    for Y := y1 + 1 to y2 - 1 do
      for X := x1 + 1 to x2 - 1 do
        PutBrushPixel(X, Y, FBrush.FRGBAColor);
  end;

  Rectangle(x1, y1, x2, y2);
end;

procedure TacSLCanvas32.GradientFill(x1, y1, x2, y2: Integer; Reverse: boolean; Style: TacSLGradientStyle);
var
  i: Integer;
  X, Y: Integer;
  x3, y3: Integer;
begin
  if x1 > x2 then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;
  if y1 > y2 then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  Dec(x2);
  Dec(y2);

  if Style = slgsHorizontal then // горизонтальный переход
  begin
    GVectorLen := Abs(x2 - x1);
    GVectorPos := 0;

    for x3 := x1 to x2 do
    begin
      GetGradientRGB(FBrush.FGradientMode, FBrush.FRGBAColor, FBrush.FRGBAGradient, Reverse, SpecialColorTemp.FRed,
        SpecialColorTemp.FGreen, SpecialColorTemp.FBlue, SpecialColorTemp.FAlphaBlend);
      Inc(GVectorPos);

      for y3 := y1 to y2 do
      begin
        PutBrushPixel(x3, y3, SpecialColorTemp);
      end;
    end;
  end
  else // вертикальный переход
  begin
    GVectorLen := Abs(y2 - y1);
    GVectorPos := 0;

    for y3 := y1 to y2 do
    begin
      GetGradientRGB(FBrush.FGradientMode, FBrush.FRGBAColor, FBrush.FRGBAGradient, Reverse, SpecialColorTemp.FRed,
        SpecialColorTemp.FGreen, SpecialColorTemp.FBlue, SpecialColorTemp.FAlphaBlend);
      Inc(GVectorPos);

      for x3 := x1 to x2 do
      begin
        PutBrushPixel(x3, y3, SpecialColorTemp);
      end
    end
  end
end;

procedure TacSLCanvas32.GradientFill(Rect: TRect; Reverse: boolean; Style: TacSLGradientStyle);
begin
  GradientFill(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, Reverse, Style);
end;

procedure TacSLCanvas32.GradientFillQuadro(Point1, Point2: TPoint);
begin
  GradientFillQuadro(Point1.X, Point1.Y, Point2.X, Point2.Y);
end;

procedure TacSLCanvas32.GradientFillQuadro(Rect: TRect);
begin
  GradientFillQuadro(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure TacSLCanvas32.GradientFillQuadro(x1, y1, x2, y2: Integer);
var
  i: Integer;
  xc, yc, t, T2, z, iz, rp, rp2, gp, gp2, bp, bp2, ap, ap2, dx, xx: Integer;
  R, G, B, a: Byte;
  Increment: Integer;
begin
  if x1 > x2 then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;
  if y1 > y2 then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  Dec(x2);
  Dec(y2);

  z := 0;
  iz := 65536;
  if x2 <> x1 then
    t := 65536 div (x2 - x1)
  else
    t := 0;
  if y2 <> y1 then
    T2 := 65536 div (y2 - y1)
  else
    T2 := 0;
  dx := x2 - x1;
  for yc := y1 to y2 - 1 do
  begin

    // Если нужно прощитывать цвет, то вперёд!
    if (FBrush.FGradientMode = slgmNormal) or (FBrush.FGradientMode = slgmOnlyColor) then
    begin
      xx := ((FBrush.FRGBAQuadroGradientLT.FRed * iz + FBrush.FRGBAQuadroGradientLB.FRed * z) shr 16);
      rp := xx shl 16;
      rp2 := (((FBrush.FRGBAQuadroGradientRT.FRed * iz + FBrush.FRGBAQuadroGradientRB.FRed * z) shr 16) - xx) * t;

      xx := ((FBrush.FRGBAQuadroGradientLT.FGreen * iz + FBrush.FRGBAQuadroGradientLB.FGreen * z) shr 16);
      gp := xx shl 16;
      gp2 := (((FBrush.FRGBAQuadroGradientRT.FGreen * iz + FBrush.FRGBAQuadroGradientRB.FGreen * z) shr 16) - xx) * t;

      xx := ((FBrush.FRGBAQuadroGradientLT.FBlue * iz + FBrush.FRGBAQuadroGradientLB.FBlue * z) shr 16);
      bp := xx shl 16;
      bp2 := (((FBrush.FRGBAQuadroGradientRT.FBlue * iz + FBrush.FRGBAQuadroGradientRB.FBlue * z) shr 16) - xx) * t;
    end;

    // Если нужно прощитывать альфу, то вперёд!
    if (FBrush.FGradientMode = slgmNormal) or (FBrush.FGradientMode = slgmOnlyAlpha) then
    begin
      xx := ((FBrush.FRGBAQuadroGradientLT.FAlphaBlend * iz + FBrush.FRGBAQuadroGradientLB.FAlphaBlend * z) shr 16);
      ap := xx shl 16;
      ap2 := (((FBrush.FRGBAQuadroGradientRT.FAlphaBlend * iz + FBrush.FRGBAQuadroGradientRB.FAlphaBlend * z) shr 16)
        - xx) * t;
    end;

    Increment := 0;

    for xc := 0 to dx - 1 do
    begin
      // Если нужно прощитывать цвет, то вперёд!
      if (FBrush.FGradientMode = slgmNormal) or (FBrush.FGradientMode = slgmOnlyColor) then
      begin
        Inc(bp, bp2);
        Inc(gp, gp2);
        Inc(rp, rp2);
        SpecialColorTemp.FBlue := bp shr 16;
        SpecialColorTemp.FGreen := gp shr 16;
        SpecialColorTemp.FRed := rp shr 16;
      end
      else
      begin
        SpecialColorTemp.FBlue := FBrush.FRGBAColor.FBlue;
        SpecialColorTemp.FGreen := FBrush.FRGBAColor.FGreen;
        SpecialColorTemp.FRed := FBrush.FRGBAColor.FRed;
      end;

      // Если нужно прощитывать альфу, то вперёд!
      if (FBrush.FGradientMode = slgmNormal) or (FBrush.FGradientMode = slgmOnlyAlpha) then
      begin
        Inc(ap, ap2);
        SpecialColorTemp.FAlphaBlend := ap shr 16;
      end;

      PutBrushPixel(x1 + Increment, yc, SpecialColorTemp);

      Inc(Increment);
    end;
    Inc(z, T2);
    Dec(iz, T2);
  end;
end;

constructor TacSLCanvas32.Create(PVideoData: Pointer; AWidth, AHeight, APitch: Integer);
var
  i: Integer;
begin
  inherited Create;

  FVideoData := PVideoData;

  // SpecialColorTemp := TacSLColor.Create;
  // GradientColorTemp := TacSLColor.Create;
  //
  // FPen := TacSLPen.Create;
  // FBrush := TacSLBrush.Create;

  FPenPos.X := 0;
  FPenPos.Y := 0;

  if (FVideoData <> nil) or (AWidth <> Abs(APitch)) then
  begin
    AttachedMemory := True;

    FWidth := AWidth;
    FHeight := AHeight;

    FDelta := APitch;

    SetLength(FScanLines, AHeight);
    for i := 0 to AHeight - 1 do
      FScanLines[i] := Pointer(Cardinal(PVideoData) + Cardinal(i * FDelta * 4));

    FStartAddress := Integer(PVideoData);
    FDeltaAddress := Integer(Cardinal(PVideoData) + Cardinal(1 * FDelta * 4)) - FStartAddress;
  end
  else
  begin
    FVideoData := nil;
    AttachedMemory := False;
    FWidth := 0;
    FHeight := 0;
    FDelta := 0;
    FStartAddress := 0;
    FDeltaAddress := 0;
  end;
end;

constructor TacSLCanvas32.Create;
begin
  inherited Create;

  SpecialColorTemp := TacSLColor.Create;
  GradientColorTemp := TacSLColor.Create;

  FPen := TacSLPen.Create;
  FBrush := TacSLBrush.Create;

  FPenPos.X := 0;
  FPenPos.Y := 0;

  FVideoData := nil;

  AttachedMemory := False;
  FWidth := 0;
  FHeight := 0;
  FDelta := 0;
  FStartAddress := 0;
  FDeltaAddress := 0;
end;

constructor TacSLCanvas32.Create(Bitmap: TBitmap);
var
  i: Integer;
begin
  inherited Create;

  // SpecialColorTemp := TacSLColor.Create;
  // GradientColorTemp := TacSLColor.Create;
  //
  // FPen := TacSLPen.Create;
  // FBrush := TacSLBrush.Create;

  FPenPos.X := 0;
  FPenPos.Y := 0;

  if Assigned(Bitmap) then
  begin
    if not Bitmap.Empty then
    begin
      if Bitmap.PixelFormat = pf32bit then
      begin
        FVideoData := Bitmap.ScanLine[0];

        AttachedMemory := True;

        FWidth := Bitmap.Width;
        FHeight := Bitmap.Height;

        FDelta := -Bitmap.Width;

        SetLength(FScanLines, FHeight);
        for i := 0 to FHeight - 1 do
          FScanLines[i] := Pointer(Cardinal(FVideoData) + Cardinal(i * FDelta * 4));

        FStartAddress := Integer(FVideoData);
        FDeltaAddress := Integer(Cardinal(FVideoData) + Cardinal(1 * FDelta * 4)) - FStartAddress;
      end
      else
      begin
        FVideoData := nil;
        AttachedMemory := False;
        FWidth := 0;
        FHeight := 0;
        FDelta := 0;
        FStartAddress := 0;
        FDeltaAddress := 0;
      end;
    end
    else
    begin
      FVideoData := nil;
      AttachedMemory := False;
      FWidth := 0;
      FHeight := 0;
      FDelta := 0;
      FStartAddress := 0;
      FDeltaAddress := 0;
    end;
  end
  else
  begin
    FVideoData := nil;
    AttachedMemory := False;
    FWidth := 0;
    FHeight := 0;
    FDelta := 0;
    FStartAddress := 0;
    FDeltaAddress := 0;
  end;
end;

destructor TacSLCanvas32.Destroy;
begin
  // if Assigned(FPen) then
  // FPen.Free;
  //
  // if Assigned(FBrush) then
  // FBrush.Free;

  // fixed
  FreeAndNil(GradientColorTemp);
  FreeAndNil(SpecialColorTemp);

  FreeAndNil(FPen);
  FreeAndNil(FBrush);
  // fix

  if AttachedMemory then
    SetLength(FScanLines, 0); // Покидаем память захваченную до этого

  inherited;
end;

procedure TacSLCanvas32.DetachMemory;
begin
  if AttachedMemory then
    SetLength(FScanLines, 0);

  // // fixed
  // FreeAndNil(GradientColorTemp);
  // FreeAndNil(SpecialColorTemp);
  //
  // FreeAndNil(FPen);
  // FreeAndNil(FBrush);
  // // fixed

  FVideoData := nil;
  AttachedMemory := False;
  FWidth := 0;
  FHeight := 0;
  FDelta := 0;
  FStartAddress := 0;
  FDeltaAddress := 0;
end;

function TacSLCanvas32.GetPixelRGBA(X, Y: Integer): PRGBQuad;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Result := Temp;
  end
  else
    Result := nil;
end;

procedure TacSLCanvas32.GetGradientRGB(GMode: TacSLGradientMode; InputColor1, InputColor2: TacSLColor; Reverse: boolean;
  out R, G, B, a: Byte);
var
  h, i: Integer;
  A1, A2, A3, A4, B1, B2, B3, B4: Integer;
begin
  if Reverse then
  begin
    A1 := InputColor2.FRed;
    A2 := InputColor2.FGreen;
    A3 := InputColor2.FBlue;
    A4 := InputColor2.FAlphaBlend;
    B1 := InputColor1.FRed;
    B2 := InputColor1.FGreen;
    B3 := InputColor1.FBlue;
    B4 := InputColor1.FAlphaBlend;
  end
  else
  begin
    A1 := InputColor1.FRed;
    A2 := InputColor1.FGreen;
    A3 := InputColor1.FBlue;
    A4 := InputColor1.FAlphaBlend;
    B1 := InputColor2.FRed;
    B2 := InputColor2.FGreen;
    B3 := InputColor2.FBlue;
    B4 := InputColor2.FAlphaBlend;
  end;

  h := GVectorLen;

  // Если нужно прощитывать цвет, то вперёд!
  if (GMode = slgmNormal) or (GMode = slgmOnlyColor) then
  begin
    // Немножко оптимизации не помешает
    // Проверяем если каждый компонент цвета уже равен финальному
    // Тогда отпадает потребность в формуле вычисления градиента
    // Просто присвоим значения

    if InputColor1.FRed <> InputColor2.FRed then
      R := Round(A1 - (A1 - B1) / GVectorLen * GVectorPos)
    else
      R := InputColor2.FRed;

    if InputColor1.FGreen <> InputColor2.FGreen then
      G := Round(A2 - (A2 - B2) / GVectorLen * GVectorPos)
    else
      G := InputColor2.FGreen;

    if InputColor1.FBlue <> InputColor2.FBlue then
      B := Round(A3 - (A3 - B3) / GVectorLen * GVectorPos)
    else
      B := InputColor2.FBlue;
  end
  else
  begin
    R := InputColor1.FRed;
    G := InputColor1.FGreen;
    B := InputColor1.FBlue;
  end;

  // Если нужно прощитывать альфу, то вперёд!
  if (GMode = slgmNormal) or (GMode = slgmOnlyAlpha) then
  begin
    if InputColor1.FAlphaBlend <> InputColor2.FAlphaBlend then
      a := Round(A4 - (A4 - B4) / GVectorLen * GVectorPos)
    else
      a := InputColor1.FAlphaBlend;
  end
end;

function TacSLCanvas32.GetPixelAValue(X, Y: Integer): Byte;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Result := Temp^.rgbReserved;
  end
  else
    Result := 0;
end;

function TacSLCanvas32.GetPixelBValue(X, Y: Integer): Byte;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Result := Temp^.rgbBlue;
  end
  else
    Result := 0;
end;

function TacSLCanvas32.GetSpeedPixelColor(X, Y: Integer): TColor;
// SwappedValue := PInteger(FStart + FDelta * Y + 4 * X )^;
asm
  imul ecx,[eax].FDeltaAddress
  add ecx,[eax].FStartAddress
  mov eax,[ecx+4*edx]
  bswap eax
  shr eax, 8
end;

function TacSLCanvas32.GetPixelColor(X, Y: Integer): TColor;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    { Temp := GetScanLine(Y);
      Inc(Temp, X);
      Result:= GetColor24(Temp^.rgbBlue, Temp^.rgbGreen, Temp^.rgbRed); }

    // Воспользуемся процедурой с ассемблерной вставкой
    Result := GetSpeedPixelColor(X, Y);
  end
  else
    Result := clBlack;
end;

function TacSLCanvas32.GetPixelGValue(X, Y: Integer): Byte;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Result := Temp^.rgbGreen;
  end
  else
    Result := 0;
end;

function TacSLCanvas32.GetPixelRValue(X, Y: Integer): Byte;
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Result := Temp^.rgbRed;
  end
  else
    Result := 0;
end;

function TacSLCanvas32.GetScanLine(Index: Integer): Pointer;
begin
  if (Index >= 0) and (Index < FHeight) then
  begin
    Result := FScanLines[Index];
  end
  else
    Result := nil;
end;

procedure TacSLCanvas32.PutPixel(X, Y: Integer);
var
  Pixel: PRGBQuad;
begin
  Pixel := PixelRGBA[X, Y];

  if Pixel = nil then
    Exit;

  if FPen.AlphaMode = slamNone then
  begin
    if FPen.PenMode = slpmNormal then
    begin
      Pixel^.rgbRed := FPen.RGBAColor.Red;
      Pixel^.rgbGreen := FPen.RGBAColor.Green;
      Pixel^.rgbBlue := FPen.RGBAColor.Blue;
    end
    else
    begin
      Pixel^.rgbRed := Pixel^.rgbRed xor FPen.RGBAColor.Red;
      Pixel^.rgbGreen := Pixel^.rgbGreen xor FPen.RGBAColor.Green;
      Pixel^.rgbBlue := Pixel^.rgbBlue xor FPen.RGBAColor.Blue;
    end;
  end
  else
  begin
    if FPen.FRGBAColor.FAlphaBlend = 255 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Pixel^.rgbRed := FPen.RGBAColor.Red;
        Pixel^.rgbGreen := FPen.RGBAColor.Green;
        Pixel^.rgbBlue := FPen.RGBAColor.Blue;
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed xor FPen.RGBAColor.Red;
        Pixel^.rgbGreen := Pixel^.rgbGreen xor FPen.RGBAColor.Green;
        Pixel^.rgbBlue := Pixel^.rgbBlue xor FPen.RGBAColor.Blue;
      end;
    end
    else if FPen.FRGBAColor.FAlphaBlend > 0 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Inc(Pixel^.rgbRed, (FPen.RGBAColor.AlphaBlend * (FPen.RGBAColor.Red - Pixel^.rgbRed)) shr 8);
        Inc(Pixel^.rgbGreen, (FPen.RGBAColor.AlphaBlend * (FPen.RGBAColor.Green - Pixel^.rgbGreen)) shr 8);
        Inc(Pixel^.rgbBlue, (FPen.RGBAColor.AlphaBlend * (FPen.RGBAColor.Blue - Pixel^.rgbBlue)) shr 8);
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbRed xor FPen.RGBAColor.Red) - Pixel^.rgbRed)) shr 8;
        Pixel^.rgbGreen := Pixel^.rgbGreen +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbGreen xor FPen.RGBAColor.Green) - Pixel^.rgbGreen)) shr 8;
        Pixel^.rgbBlue := Pixel^.rgbBlue +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbBlue xor FPen.RGBAColor.Blue) - Pixel^.rgbBlue)) shr 8;
      end
    end
  end
end;

procedure TacSLCanvas32.PutSpecialPixel(X, Y: Integer);
var
  Pixel: PRGBQuad;
begin
  Pixel := PixelRGBA[X, Y];

  if Pixel = nil then
    Exit;

  if FPen.AlphaMode = slamNone then
  begin
    if FPen.PenMode = slpmNormal then
    begin
      Pixel^.rgbRed := SpecialColorTemp.FRed;
      Pixel^.rgbGreen := SpecialColorTemp.FGreen;
      Pixel^.rgbBlue := SpecialColorTemp.FBlue;
    end
    else
    begin
      Pixel^.rgbRed := Pixel^.rgbRed xor SpecialColorTemp.FRed;
      Pixel^.rgbGreen := Pixel^.rgbGreen xor SpecialColorTemp.FGreen;
      Pixel^.rgbBlue := Pixel^.rgbBlue xor SpecialColorTemp.FBlue;
    end
  end
  else
  begin
    if FPen.FRGBAColor.FAlphaBlend = 255 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Pixel^.rgbRed := SpecialColorTemp.FRed;
        Pixel^.rgbGreen := SpecialColorTemp.FGreen;
        Pixel^.rgbBlue := SpecialColorTemp.FBlue;
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed xor SpecialColorTemp.FRed;
        Pixel^.rgbGreen := Pixel^.rgbGreen xor SpecialColorTemp.FGreen;
        Pixel^.rgbBlue := Pixel^.rgbBlue xor SpecialColorTemp.FBlue;
      end
    end
    else if FPen.FRGBAColor.FAlphaBlend > 0 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Inc(Pixel^.rgbRed, (FPen.FRGBAColor.AlphaBlend * (SpecialColorTemp.FRed - Pixel^.rgbRed)) shr 8);
        Inc(Pixel^.rgbGreen, (FPen.FRGBAColor.AlphaBlend * (SpecialColorTemp.FGreen - Pixel^.rgbGreen)) shr 8);
        Inc(Pixel^.rgbBlue, (FPen.FRGBAColor.AlphaBlend * (SpecialColorTemp.FBlue - Pixel^.rgbBlue)) shr 8);
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbRed xor SpecialColorTemp.FRed) - Pixel^.rgbRed)) shr 8;
        Pixel^.rgbGreen := Pixel^.rgbGreen +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbGreen xor SpecialColorTemp.FGreen) - Pixel^.rgbGreen)) shr 8;
        Pixel^.rgbBlue := Pixel^.rgbBlue +
          (FPen.RGBAColor.AlphaBlend * ((Pixel^.rgbBlue xor SpecialColorTemp.FBlue) - Pixel^.rgbBlue)) shr 8;
      end
    end
  end
end;

procedure TacSLCanvas32.Rectangle(Point1, Point2: TPoint);
begin
  Rectangle(Point1.X, Point1.Y, Point2.X, Point2.Y);
end;

procedure TacSLCanvas32.RendererPixel(X, Y: Integer; Source: PRGBQuad; Reverse: boolean);
var
  Pixel: PRGBQuad;
  AlphaBuffer: Byte;
begin
  Pixel := PixelRGBA[X, Y];

  if (Pixel = nil) or (Source = nil) then
    Exit;

  // Просто копируем но альфа переменную даже не трогаем
  if FBrush.FAlphaMode = slamNone then
  begin
    Pixel^.rgbRed := Source^.rgbRed;
    Pixel^.rgbGreen := Source^.rgbGreen;
    Pixel^.rgbBlue := Source^.rgbBlue;
  end
  else if FBrush.FAlphaMode = slamNormalAlpha then // Рисуем всё с альфой
  begin
    Inc(Pixel^.rgbRed, (FBrush.FRGBAColor.FAlphaBlend * (Source^.rgbRed - Pixel^.rgbRed)) shr 8);
    Inc(Pixel^.rgbGreen, (FBrush.FRGBAColor.FAlphaBlend * (Source^.rgbGreen - Pixel^.rgbGreen)) shr 8);
    Inc(Pixel^.rgbBlue, (FBrush.FRGBAColor.FAlphaBlend * (Source^.rgbBlue - Pixel^.rgbBlue)) shr 8);
  end
  else if FBrush.FAlphaMode = slamMask then // Рисуем по маске
  begin
    Inc(Pixel^.rgbRed, (Source^.rgbReserved * (Source^.rgbRed - Pixel^.rgbRed)) shr 8);
    Inc(Pixel^.rgbGreen, (Source^.rgbReserved * (Source^.rgbGreen - Pixel^.rgbGreen)) shr 8);
    Inc(Pixel^.rgbBlue, (Source^.rgbReserved * (Source^.rgbBlue - Pixel^.rgbBlue)) shr 8);
  end
  else if (FBrush.FAlphaMode = slamRed) or (FBrush.FAlphaMode = slamGreen) or (FBrush.FAlphaMode = slamBlue) or
    (FBrush.FAlphaMode = slamRejection) then
  // Делаем прозрачным указанный цвет
  begin
    if FBrush.FAlphaMode = slamRed then
      AlphaBuffer := ExtractNotRed(Source^.rgbRed, Source^.rgbGreen, Source^.rgbBlue)
    else if FBrush.FAlphaMode = slamGreen then
      AlphaBuffer := ExtractNotGreen(Source^.rgbRed, Source^.rgbGreen, Source^.rgbBlue)
    else if FBrush.FAlphaMode = slamBlue then
      AlphaBuffer := ExtractNotBlue(Source^.rgbRed, Source^.rgbGreen, Source^.rgbBlue)
    else if FBrush.FAlphaMode = slamRejection then
      AlphaBuffer := ExtractRejection(Source^.rgbRed, Source^.rgbGreen, Source^.rgbBlue);

    Inc(Pixel^.rgbRed, (AlphaBuffer * (Source^.rgbRed - Pixel^.rgbRed)) shr 8);
    Inc(Pixel^.rgbGreen, (AlphaBuffer * (Source^.rgbGreen - Pixel^.rgbGreen)) shr 8);
    Inc(Pixel^.rgbBlue, (AlphaBuffer * (Source^.rgbBlue - Pixel^.rgbBlue)) shr 8);
  end
  else if FBrush.FAlphaMode = slamRejection then
  begin
    Inc(Pixel^.rgbRed, (Source^.rgbReserved * (Source^.rgbRed - Pixel^.rgbRed)) shr 8);
    Inc(Pixel^.rgbGreen, (Source^.rgbReserved * (Source^.rgbGreen - Pixel^.rgbGreen)) shr 8);
    Inc(Pixel^.rgbBlue, (Source^.rgbReserved * (Source^.rgbBlue - Pixel^.rgbBlue)) shr 8);
  end
end;

procedure TacSLCanvas32.PutGradientPixel(X, Y: Integer);
var
  Pixel: PRGBQuad;
begin
  Pixel := PixelRGBA[X, Y];

  if Pixel = nil then
    Exit;

  if FPen.AlphaMode = slamNone then
  begin
    if FPen.PenMode = slpmNormal then
    begin
      Pixel^.rgbRed := GradientColorTemp.Red;
      Pixel^.rgbGreen := GradientColorTemp.Green;
      Pixel^.rgbBlue := GradientColorTemp.Blue;
    end
    else
    begin
      Pixel^.rgbRed := Pixel^.rgbRed xor GradientColorTemp.Red;
      Pixel^.rgbGreen := Pixel^.rgbGreen xor GradientColorTemp.Green;
      Pixel^.rgbBlue := Pixel^.rgbBlue xor GradientColorTemp.Blue;
    end;
  end
  else
  begin
    if GradientColorTemp.FAlphaBlend = 255 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Pixel^.rgbRed := GradientColorTemp.Red;
        Pixel^.rgbGreen := GradientColorTemp.Green;
        Pixel^.rgbBlue := GradientColorTemp.Blue;
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed xor GradientColorTemp.Red;
        Pixel^.rgbGreen := Pixel^.rgbGreen xor GradientColorTemp.Green;
        Pixel^.rgbBlue := Pixel^.rgbBlue xor GradientColorTemp.Blue;
      end;
    end
    else if GradientColorTemp.FAlphaBlend > 0 then
    begin
      if FPen.PenMode = slpmNormal then
      begin
        Inc(Pixel^.rgbRed, (GradientColorTemp.AlphaBlend * (GradientColorTemp.Red - Pixel^.rgbRed)) shr 8);
        Inc(Pixel^.rgbGreen, (GradientColorTemp.AlphaBlend * (GradientColorTemp.Green - Pixel^.rgbGreen)) shr 8);
        Inc(Pixel^.rgbBlue, (GradientColorTemp.AlphaBlend * (GradientColorTemp.Blue - Pixel^.rgbBlue)) shr 8);
      end
      else
      begin
        Pixel^.rgbRed := Pixel^.rgbRed +
          (GradientColorTemp.FAlphaBlend * ((Pixel^.rgbRed xor GradientColorTemp.FRed) - Pixel^.rgbRed)) shr 8;
        Pixel^.rgbGreen := Pixel^.rgbGreen +
          (GradientColorTemp.FAlphaBlend * ((Pixel^.rgbGreen xor GradientColorTemp.FGreen) - Pixel^.rgbGreen)) shr 8;
        Pixel^.rgbBlue := Pixel^.rgbBlue +
          (GradientColorTemp.FAlphaBlend * ((Pixel^.rgbBlue xor GradientColorTemp.FBlue) - Pixel^.rgbBlue)) shr 8;
      end
    end
  end
end;

procedure TacSLCanvas32.SetAllPixels(Red, Green, Blue, Alpha: Byte);
var
  Pixel: PRGBQuad;
  X, Y: Integer;
begin
  for X := 0 to FWidth - 1 do
  begin
    for Y := 0 to FHeight - 1 do
    begin
      Pixel := PixelRGBA[X, Y];
      if Pixel <> nil then
      begin
        Pixel.rgbRed := Red;
        Pixel.rgbGreen := Green;
        Pixel.rgbBlue := Blue;
        Pixel.rgbReserved := Alpha;
      end
    end
  end
end;

procedure TacSLCanvas32.SetAllPixels(Red, Green, Blue: Byte);
var
  X, Y: Integer;
begin
  for X := 0 to FWidth - 1 do
  begin
    for Y := 0 to FHeight - 1 do
    begin
      PixelColor[X, Y] := GetColor24(Red, Green, Blue);
    end
  end
end;

procedure TacSLCanvas32.SetAllPixels(Color: TColor);
var
  X, Y: Integer;
begin
  for X := 0 to FWidth - 1 do
  begin
    for Y := 0 to FHeight - 1 do
    begin
      PixelColor[X, Y] := Color;
    end
  end
end;

procedure TacSLCanvas32.PutBrushPixel(X, Y: Integer; InputColor: TacSLColor);
var
  Pixel: PRGBQuad;
begin
  Pixel := PixelRGBA[X, Y];

  if (Pixel = nil) or (not Assigned(InputColor)) then
    Exit;

  if FBrush.AlphaMode = slamNone then
  begin
    Pixel^.rgbRed := InputColor.FRed;
    Pixel^.rgbGreen := InputColor.FGreen;
    Pixel^.rgbBlue := InputColor.FBlue;
  end
  else
  begin
    if InputColor.FAlphaBlend = 255 then
    begin
      Pixel^.rgbRed := InputColor.FRed;
      Pixel^.rgbGreen := InputColor.FGreen;
      Pixel^.rgbBlue := InputColor.FBlue;
    end
    else if InputColor.FAlphaBlend > 0 then
    begin
      Inc(Pixel^.rgbRed, (InputColor.FAlphaBlend * (InputColor.FRed - Pixel^.rgbRed)) shr 8);
      Inc(Pixel^.rgbGreen, (InputColor.FAlphaBlend * (InputColor.FGreen - Pixel^.rgbGreen)) shr 8);
      Inc(Pixel^.rgbBlue, (InputColor.FAlphaBlend * (InputColor.FBlue - Pixel^.rgbBlue)) shr 8);
    end
  end
end;

procedure TacSLCanvas32.SetPixelRGBA(X, Y: Integer; const Value: PRGBQuad);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);

    if (Value <> nil) and (Value <> Temp) then
    begin
      Temp^.rgbRed := Value^.rgbRed;
      Temp^.rgbGreen := Value^.rgbGreen;
      Temp^.rgbBlue := Value^.rgbBlue;
      Temp^.rgbReserved := Value^.rgbReserved;
    end
  end
end;

procedure TacSLCanvas32.SetPixelAValue(X, Y: Integer; const Value: Byte);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Temp^.rgbReserved := Value;
  end
end;

procedure TacSLCanvas32.SetPixelBValue(X, Y: Integer; const Value: Byte);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Temp^.rgbBlue := Value;
  end
end;

procedure TacSLCanvas32.SetSpeedPixel(X, Y: Integer; const Value: TColor);
// PInteger(FStart + FDelta * Y + (X Shl 2))^ := SwappedValue
asm
  imul ecx,[eax].FDeltaAddress
  add ecx,[eax].FStartAddress
  mov eax, Value
  bswap eax
  shr eax, 8
  mov [ecx+4*edx],eax
end;

procedure TacSLCanvas32.SetPixelColor(X, Y: Integer; const Value: TColor);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    { Temp := GetScanLine(Y);
      Inc(Temp, X);
      Temp^.rgbRed:= Value and $0000FF;
      Temp^.rgbGreen:= (Value and $00FF00) shr 8;
      Temp^.rgbBlue:= (Value and $FF0000) shr 16; }

    // Воспользуемся процедурой с ассемблерной вставкой
    SetSpeedPixel(X, Y, Value);
  end
end;

procedure TacSLCanvas32.SetPixelGValue(X, Y: Integer; const Value: Byte);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Temp^.rgbGreen := Value;
  end
end;

procedure TacSLCanvas32.SetPixelRValue(X, Y: Integer; const Value: Byte);
var
  Temp: PRGBQuad;
begin
  if ((X >= 0) and (X < FWidth)) and ((Y >= 0) and (Y < FHeight)) then
  begin
    Temp := GetScanLine(Y);
    Inc(Temp, X);
    Temp^.rgbRed := Value;
  end
end;

procedure TacSLCanvas32.GradientFill(Point1, Point2: TPoint; Reverse: boolean; Style: TacSLGradientStyle);
begin
  GradientFill(Point1.X, Point1.Y, Point2.X, Point2.Y, Reverse, Style);
end;

{ TacSLPen }

constructor TacSLPen.Create;
begin
  inherited Create;

  GeneratorCounter := 0;

  FPenStyle := slpsContinuous;

  FGradientMode := slgmOnlyColor;

  FRGBAColor := TacSLColor.Create;
  FRGBAGradient := TacSLColor.Create;

  FAlphaMode := slamNone;

  FPenMode := slpmNormal;
end;

destructor TacSLPen.Destroy;
begin
  if Assigned(FRGBAColor) then
    FRGBAColor.Free;

  if Assigned(FRGBAGradient) then
    FRGBAGradient.Free;

  inherited;
end;

function TacSLPen.GenerateLine: boolean;
var
  GeneraneNumber: Byte;
begin
  GeneraneNumber := GetGenerator;

  if FPenStyle = slpsContinuous then
  begin
    Result := True
  end
  else if FPenStyle = slpsDots then // Result := True;
  begin                             // Result := False;
    if GeneratorCounter = 0 then
      Result := False
    else if GeneratorCounter = 1 then
      Result := False
    else if GeneratorCounter = 2 then
      Result := True
    else if GeneratorCounter = 3 then
      Result := False
    else if GeneratorCounter = 4 then
      Result := False
  end
  else if FPenStyle = slpsLines then
  begin
    if GeneratorCounter = 0 then
      Result := True
    else if GeneratorCounter = 1 then
      Result := True
    else if GeneratorCounter = 2 then
      Result := True
    else if GeneratorCounter = 3 then
      Result := True
    else if GeneratorCounter = 4 then
      Result := True
    else if GeneratorCounter = 5 then
      Result := True
    else if GeneratorCounter = 6 then
      Result := True
    else if GeneratorCounter = 7 then
      Result := True
    else if GeneratorCounter = 8 then
      Result := True
    else if GeneratorCounter = 9 then
      Result := True
    else if GeneratorCounter = 10 then
      Result := True
    else if GeneratorCounter = 11 then
      Result := True
    else if GeneratorCounter = 12 then
      Result := True
    else if GeneratorCounter = 13 then
      Result := True
    else if GeneratorCounter = 14 then
      Result := True
    else if GeneratorCounter = 15 then
      Result := False
    else if GeneratorCounter = 16 then
      Result := False
    else if GeneratorCounter = 17 then
      Result := False
    else if GeneratorCounter = 18 then
      Result := False
    else if GeneratorCounter = 19 then
      Result := False
    else if GeneratorCounter = 20 then
      Result := False
  end
  else if FPenStyle = slpsDotsLines then
  begin
    if GeneratorCounter = 0 then
      Result := True
    else if GeneratorCounter = 1 then
      Result := True
    else if GeneratorCounter = 2 then
      Result := True
    else if GeneratorCounter = 3 then
      Result := True
    else if GeneratorCounter = 4 then
      Result := True
    else if GeneratorCounter = 5 then
      Result := True
    else if GeneratorCounter = 6 then
      Result := True
    else if GeneratorCounter = 7 then
      Result := True
    else if GeneratorCounter = 8 then
      Result := True
    else if GeneratorCounter = 9 then
      Result := True
    else if GeneratorCounter = 10 then
      Result := True
    else if GeneratorCounter = 11 then
      Result := True
    else if GeneratorCounter = 12 then
      Result := True
    else if GeneratorCounter = 13 then
      Result := True
    else if GeneratorCounter = 14 then
      Result := True
    else if GeneratorCounter = 15 then
      Result := False
    else if GeneratorCounter = 16 then
      Result := False
    else if GeneratorCounter = 17 then
      Result := False
    else if GeneratorCounter = 18 then
      Result := False
    else if GeneratorCounter = 19 then
      Result := False
    else if GeneratorCounter = 20 then
      Result := True
    else if GeneratorCounter = 21 then
      Result := False
    else if GeneratorCounter = 22 then
      Result := False
    else if GeneratorCounter = 23 then
      Result := False
    else if GeneratorCounter = 24 then
      Result := False
    else if GeneratorCounter = 25 then
      Result := False
  end
  else if FPenStyle = slpsMicroLines then
  begin
    if GeneratorCounter = 0 then
      Result := True
    else if GeneratorCounter = 1 then
      Result := True
    else if GeneratorCounter = 2 then
      Result := True
    else if GeneratorCounter = 3 then
      Result := False
    else if GeneratorCounter = 4 then
      Result := False
    else if GeneratorCounter = 5 then
      Result := False
  end
end;

function TacSLPen.GetColor: TColor;
begin
  Result := GetColor24(FRGBAColor.Red, FRGBAColor.Green, FRGBAColor.Blue);
end;

function TacSLPen.GetGenerator: Byte;
begin
  Inc(GeneratorCounter);

  if GeneratorCounter <= GeneratorLength then
  begin
    Result := GeneratorCounter;
    Inc(GeneratorCounter);
  end
  else
  begin
    GeneratorCounter := 0;
    Result := GeneratorCounter;
  end;
end;

function TacSLPen.GetGradientColor: TColor;
begin
  Result := GetColor24(FRGBAGradient.Red, FRGBAGradient.Green, FRGBAGradient.Blue);
end;

procedure TacSLPen.SetColor(Value: TColor);
begin
  FRGBAColor.Red := Value and $0000FF;
  FRGBAColor.Green := (Value and $00FF00) shr 8;
  FRGBAColor.Blue := (Value and $FF0000) shr 16;
end;

procedure TacSLPen.SetGradientColor(Value: TColor);
begin
  FRGBAGradient.Red := Value and $0000FF;
  FRGBAGradient.Green := (Value and $00FF00) shr 8;
  FRGBAGradient.Blue := (Value and $FF0000) shr 16;
end;

procedure TacSLPen.SetPenStyle(const Value: TacSLPenStyle);
begin
  if FPenStyle = Value then
    Exit;

  FPenStyle := Value;

  GeneratorCounter := 0;

  if FPenStyle = slpsContinuous then
    GeneratorLength := 1
  else if FPenStyle = slpsDots then
    GeneratorLength := 4
  else if FPenStyle = slpsLines then
    GeneratorLength := 20
  else if FPenStyle = slpsDotsLines then
    GeneratorLength := 25
  else if FPenStyle = slpsMicroLines then
    GeneratorLength := 5;
end;

{ TacSLBrush }

constructor TacSLBrush.Create;
begin
  inherited Create;

  FBrushStyle := slbsClear;

  FGradientMode := slgmOnlyColor;

  FRGBAColor := TacSLColor.Create;
  FRGBAGradient := TacSLColor.Create;

  // Эти цвета заполняются специально для функции GradientFillQuadro
  FRGBAQuadroGradientLT := TacSLColor.Create;
  FRGBAQuadroGradientRT := TacSLColor.Create;
  FRGBAQuadroGradientLB := TacSLColor.Create;
  FRGBAQuadroGradientRB := TacSLColor.Create;

  FAlphaMode := slamNone;
end;

destructor TacSLBrush.Destroy;
begin
  if Assigned(FRGBAColor) then
    FRGBAColor.Free;

  if Assigned(FRGBAGradient) then
    FRGBAGradient.Free;

  if Assigned(FRGBAQuadroGradientLT) then
    FRGBAQuadroGradientLT.Free;
  if Assigned(FRGBAQuadroGradientRT) then
    FRGBAQuadroGradientRT.Free;
  if Assigned(FRGBAQuadroGradientLB) then
    FRGBAQuadroGradientLB.Free;
  if Assigned(FRGBAQuadroGradientRB) then
    FRGBAQuadroGradientRB.Free;

  inherited;
end;

function TacSLBrush.GetColor: TColor;
begin
  Result := GetColor24(FRGBAColor.Red, FRGBAColor.Green, FRGBAColor.Blue);
end;

function TacSLBrush.GetGradientColor: TColor;
begin
  Result := GetColor24(FRGBAGradient.Red, FRGBAGradient.Green, FRGBAGradient.Blue);
end;

procedure TacSLBrush.SetColor(Value: TColor);
begin
  FRGBAColor.Red := Value and $0000FF;
  FRGBAColor.Green := (Value and $00FF00) shr 8;
  FRGBAColor.Blue := (Value and $FF0000) shr 16;
end;

procedure TacSLBrush.SetGradientColor(Value: TColor);
begin
  FRGBAGradient.Red := Value and $0000FF;
  FRGBAGradient.Green := (Value and $00FF00) shr 8;
  FRGBAGradient.Blue := (Value and $FF0000) shr 16;
end;

{ TacSLColor }

procedure TacSLColor.Assign(Color: TacSLColor);
begin
  if Assigned(Color) then
  begin
    FRed := Color.FRed;
    FGreen := Color.FGreen;
    FBlue := Color.FBlue;
    FAlphaBlend := Color.FAlphaBlend;
  end
end;

constructor TacSLColor.Create;
begin
  inherited;

  FRed := 0;
  FGreen := 0;
  FBlue := 0;
  FAlphaBlend := 255;
end;

destructor TacSLColor.Destroy;
begin
  inherited;
end;

{ TacSLRecall }

constructor TacSLRecall.Create(APen: TacSLPen);
begin
  inherited Create;

  if Assigned(APen) then
  begin
    TempBrush := nil;
    BrushObject := nil;

    TempPen := TacSLPen.Create;
    TempPen.FPenStyle := APen.FPenStyle;
    TempPen.FRGBAColor.Assign(APen.FRGBAColor);
    TempPen.FRGBAGradient.Assign(APen.FRGBAGradient);
    TempPen.FAlphaMode := APen.FAlphaMode;
    TempPen.FPenMode := APen.FPenMode;
    TempPen.FGradientMode := APen.FGradientMode;
    TempPen.GeneratorCounter := APen.GeneratorCounter;
    TempPen.GeneratorLength := APen.GeneratorLength;
    PenObject := APen;
  end
  else
  begin
    TempPen := nil;
    TempBrush := nil;
    PenObject := nil;
    BrushObject := nil;
  end
end;

constructor TacSLRecall.Create(ABrush: TacSLBrush);
begin
  inherited Create;

  if Assigned(ABrush) then
  begin
    TempPen := nil;
    PenObject := nil;
    TempBrush := TacSLBrush.Create;
    TempBrush.FRGBAColor.Assign(ABrush.FRGBAColor);
    TempBrush.FRGBAGradient.Assign(ABrush.FRGBAGradient);
    TempBrush.FAlphaMode := ABrush.FAlphaMode;
    TempBrush.FBrushStyle := ABrush.FBrushStyle;
    TempBrush.FGradientMode := ABrush.FGradientMode;
    TempBrush.FRGBAQuadroGradientLT.Assign(ABrush.FRGBAQuadroGradientLT);
    TempBrush.FRGBAQuadroGradientRT.Assign(ABrush.FRGBAQuadroGradientRT);
    TempBrush.FRGBAQuadroGradientLB.Assign(ABrush.FRGBAQuadroGradientLB);
    TempBrush.FRGBAQuadroGradientRB.Assign(ABrush.FRGBAQuadroGradientRB);
    BrushObject := ABrush;
  end
  else
  begin
    TempPen := nil;
    TempBrush := nil;
    PenObject := nil;
    BrushObject := nil;
  end
end;

destructor TacSLRecall.Destroy;
begin
  if Assigned(TempPen) then
  begin
    PenObject.FPenStyle := TempPen.FPenStyle;
    PenObject.FRGBAColor.Assign(TempPen.FRGBAColor);
    PenObject.FRGBAGradient.Assign(TempPen.FRGBAGradient);
    PenObject.FAlphaMode := TempPen.FAlphaMode;
    PenObject.FPenMode := TempPen.FPenMode;
    PenObject.FGradientMode := TempPen.FGradientMode;
    PenObject.GeneratorCounter := TempPen.GeneratorCounter;
    PenObject.GeneratorLength := TempPen.GeneratorLength;
    TempPen.Free;
  end
  else if Assigned(TempBrush) then
  begin
    BrushObject.FRGBAColor.Assign(TempBrush.FRGBAColor);
    BrushObject.FRGBAGradient.Assign(TempBrush.FRGBAGradient);
    BrushObject.FAlphaMode := TempBrush.FAlphaMode;
    BrushObject.FBrushStyle := TempBrush.FBrushStyle;
    BrushObject.FGradientMode := TempBrush.FGradientMode;
    BrushObject.FRGBAQuadroGradientLT.Assign(TempBrush.FRGBAQuadroGradientLT);
    BrushObject.FRGBAQuadroGradientRT.Assign(TempBrush.FRGBAQuadroGradientRT);
    BrushObject.FRGBAQuadroGradientLB.Assign(TempBrush.FRGBAQuadroGradientLB);
    BrushObject.FRGBAQuadroGradientRB.Assign(TempBrush.FRGBAQuadroGradientRB);
    TempBrush.Free;
  end;

  inherited;
end;

procedure TacSLRecall.Free;
begin
  Destroy;
end;

end.
