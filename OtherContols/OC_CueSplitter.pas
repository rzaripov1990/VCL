unit OC_CueSplitter;

interface

uses Classes, SysUtils;

type
  TCueItem = record
    Performer: string;
    Title: string;
    BeginIndex: LongWord;
    EndIndex: LongWord;
  end;

  TZMSCueSplitter = class(TComponent)
  private
    FItems: array of TCueItem;
    FCueData: TStringList;
    FCueFile: string;
    FCurrentItem: Byte;
    FAlbum: string;
    FPerformer: string;
    FYear: string;
    FGenre: string;
    FComment: string;
    FItemsCount: Byte;
    FDuration: Integer;
    procedure ParseCue(const SL: TStringList);
    procedure SetCurrentItem(ci: Byte);
    function GetAlbum: string;
    function GetPerformer: string;
    function GetTitle: string;
    function GetItemsCount: Byte;
    function GetTime: LongWord;
    function GetYear: string;
    function GetGenre: string;
    function GetComment: string;
  public
    destructor Destroy; override;
    constructor Create(aOwner: TComponent); override;
    property ItemsCount: Byte read GetItemsCount;
    property CurrentItem: Byte read FCurrentItem write SetCurrentItem;
    property Album: string read GetAlbum;
    property Performer: string read GetPerformer;
    property Title: string read GetTitle;
    property Time: LongWord read GetTime;
    property Duration: Integer read FDuration write FDuration;
    property Year: string read GetYear;
    property Genre: string read GetGenre;
    property Comment: string read GetComment;

    function LoadCueFile(const fn: string): boolean;
    function LoadCueData(const fd: string): boolean;
  published
    property CueFileName: string read FCueFile;
  end;

implementation

constructor TZMSCueSplitter.Create(aOwner: TComponent);
begin
  inherited;
  FCueData := TStringList.Create;
end;

destructor TZMSCueSplitter.Destroy;
begin
  FreeAndNil(FCueData);
  FItems := nil;
  inherited;
end;

procedure TZMSCueSplitter.ParseCue(const SL: TStringList);
const
  beforeTracks = 1;
  NewTrack = 2;
var
  State: Integer;
  i, p, apos: Integer;
  Min, sec, millisec: Integer;

  function ExtractString(const S: string; pos: Integer): string;
  var
    i: Integer;
    ksp: Boolean;
  begin
    Result := '';
    ksp := False;
    for i := pos to Length(S) do
    begin
      if S[i] < Char(33) then
      begin
        if ksp then
          Result := Result + S[i];
      end
      else
      begin
        if S[i] = '"' then
          ksp := True
        else
          Result := Result + S[i];
      end;
    end;
  end;

  function ExtractDigits(const S: string; var pos: Integer): string;
  var
    i: Integer;
    ind: Boolean;
  begin
    Result := '';
    ind := False;
    for i := pos to Length(S) do
    begin
      if
{$IFDEF UNICODE}
      CharInSet(S[i], ['0'..'9'])
{$ELSE}
      S[i] in ['0'..'9']
{$ENDIF} then
      begin
        ind := True;
        Result := Result + S[i];
      end
      else
      begin
        if ind then
        begin
          pos := i;
          Exit;
        end;
      end;
    end;
  end;

begin
  if FItemsCount > 0 then
    Exit;
  FPerformer := '';
  FAlbum := '';
  FYear := '';
  FGenre := '';
  FComment := '';
  SetLength(FItems, 255);
  FItemsCount := 0;
  State := beforeTracks;
  for i := 0 to SL.Count - 1 do
  begin
    case State of
      beforeTracks:
        begin
          p := Pos('PERFORMER', SL.Strings[i]);
          if p > 0 then
          begin
            FPerformer := string(ExtractString(SL.Strings[i], p + 9));
          end;
          p := Pos('TITLE', SL.Strings[i]);
          if p > 0 then
          begin
            FAlbum := string(ExtractString(SL.Strings[i], p + 5));
          end;
          p := Pos('GENRE', SL.Strings[i]);
          if p > 0 then
          begin
            FGenre := string(ExtractString(SL.Strings[i], p + 5));
          end;
          p := Pos('COMMENT', SL.Strings[i]);
          if p > 0 then
          begin
            FComment := string(ExtractString(SL.Strings[i], p + 7));
          end;
          p := Pos('DATE', SL.Strings[i]);
          if p > 0 then
          begin
            apos := p + 4;
            FYear := string(ExtractDigits(SL.Strings[i], apos));
          end;
          p := Pos('YEAR', SL.Strings[i]);
          if p > 0 then
          begin
            apos := p + 4;
            FYear := string(ExtractDigits(SL.Strings[i], apos));
          end;
          p := Pos('TRACK', SL.Strings[i]);
          if p > 0 then
          begin
            State := NewTrack;
            FItems[FItemsCount].BeginIndex := 0;
            FItems[FItemsCount].EndIndex := 0;
            FItems[FItemsCount].Performer := FPerformer;
            Inc(FItemsCount);
          end;
        end;
      NewTrack:
        begin
          p := Pos('INDEX', SL.Strings[i]);
          if p > 0 then
          begin
            apos := p + 5;
            if StrToInt(ExtractDigits(SL.Strings[i], apos)) = 0 then
            begin
              if FItemsCount > 1 then
              begin
                Inc(apos);
                Min := StrToInt(ExtractDigits(SL.Strings[i], apos));
                Inc(apos);
                Sec := StrToInt(ExtractDigits(SL.Strings[i], apos));
                Inc(apos);
                MilliSec := Round(StrToInt(ExtractDigits(SL.Strings[i], apos)) *
                  1000 / 75);
                MilliSec := Min * 60000 + Sec * 1000 + MilliSec;
                FItems[FItemsCount - 2].EndIndex := MilliSec;
              end;
            end
            else
            begin
              Inc(apos);
              Min := StrToInt(ExtractDigits(SL.Strings[i], apos));
              Inc(apos);
              Sec := StrToInt(ExtractDigits(SL.Strings[i], apos));
              Inc(apos);
              MilliSec := Round(StrToInt(ExtractDigits(SL.Strings[i], apos)) *
                1000 / 75);
              MilliSec := Min * 60000 + Sec * 1000 + MilliSec;
              FItems[FItemsCount - 1].BeginIndex := MilliSec;
              if FItemsCount > 1 then
                if FItems[FItemsCount - 2].EndIndex = 0 then
                  FItems[FItemsCount - 2].EndIndex := MilliSec;
            end;
          end;
          p := Pos('PERFORMER', SL.Strings[i]);
          if p > 0 then
          begin
            FItems[FItemsCount - 1].Performer :=
              string(ExtractString(SL.Strings[i], p + 9));
          end;
          p := Pos('TITLE', SL.Strings[i]);
          if p > 0 then
          begin
            FItems[FItemsCount - 1].Title := string(ExtractString(SL.Strings[i],
              p + 5));
          end;
          p := Pos('TRACK', SL.Strings[i]);
          if p > 0 then
          begin
            FItems[FItemsCount].BeginIndex := 0;
            FItems[FItemsCount].EndIndex := 0;
            FItems[FItemsCount].Performer := FPerformer;
            Inc(FItemsCount);
          end;
        end;
    end;
  end;
end;

procedure TZMSCueSplitter.SetCurrentItem(ci: Byte);
begin
  ParseCue(FCueData);
  if (ci = 0) or (ci < ItemsCount) then
    FCurrentItem := ci
  else
    raise Exception.Create('Item index out of bounds');
end;

function TZMSCueSplitter.GetItemsCount;
begin
  ParseCue(FCueData);
  Result := FItemsCount;
end;

function TZMSCueSplitter.GetAlbum;
begin
  ParseCue(FCueData);
  Result := FAlbum;
end;

function TZMSCueSplitter.GetYear;
begin
  ParseCue(FCueData);
  Result := FYear;
end;

function TZMSCueSplitter.GetGenre;
begin
  ParseCue(FCueData);
  Result := FGenre;
end;

function TZMSCueSplitter.GetComment;
begin
  ParseCue(FCueData);
  Result := FComment;
end;

function TZMSCueSplitter.GetPerformer;
begin
  ParseCue(FCueData);
  Result := FItems[FCurrentItem].Performer;
end;

function TZMSCueSplitter.GetTitle;
begin
  ParseCue(FCueData);
  Result := FItems[FCurrentItem].Title;
end;

function TZMSCueSplitter.GetTime;
var
  EI: LongWord;
begin
  ParseCue(FCueData);
  if FItems[FCurrentItem].EndIndex = 0 then
  begin
    if FDuration > 0 then
    begin
      EI := FDuration * 1000;
      Result := (EI - FItems[FCurrentItem].BeginIndex) div 1000;
    end
    else
      Result := 0;
  end
  else
    Result := (FItems[FCurrentItem].EndIndex - FItems[FCurrentItem].BeginIndex)
      div 1000;
end;

function TZMSCueSplitter.LoadCueData(const fd: string): boolean;
begin
  Result := false;
  FItems := nil;
  FItemsCount := 0;
  FCurrentItem := 0;
  FCueData.Clear;
  FCueFile := '';
  FCueData.Text := fd;
  Result := true;
end;

function TZMSCueSplitter.LoadCueFile(const fn: string): boolean;
begin
  Result := false;
  FItems := nil;
  FItemsCount := 0;
  FCurrentItem := 0;
  FCueData.Clear;
  if FileExists(fn) then
  begin
    FCueFile := fn;
    FCueData.LoadFromFile(fn);
    Result := true;
  end;
end;

end.

