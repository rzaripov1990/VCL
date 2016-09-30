unit QBCommon;

interface

type
  QBArrString = array of String;

var
  InitDll: boolean = false; // Bass Init Loaded

type
  // ---------- QBASSTagItem ------------
  QBASSTagItem = record
    FileName: string;
    Ext: string;
    Title: string;
    Album: string;
    Artist: string;
    Comment: string;
    CueSheet: string;
    Lyrics: string;
    Genre: string;
    Year: string;
    Cue: boolean;
  end;

implementation

end.
