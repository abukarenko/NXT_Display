unit Unit2;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  Spin;

type
  TIntegerArray = array of Integer;
  TByteArray = array of Byte;

  TGfxGlyph = record
    BitmapOffset: Integer;
    Width: Integer;
    Height: Integer;
    XAdvance: Integer;
    XOffset: Integer;
    YOffset: Integer;
  end;

  TGfxGlyphArray = array of TGfxGlyph;

  TGfxFont = class
  public
    FileName: string;
    Bitmaps: TByteArray;
    Glyphs: TGfxGlyphArray;
    First: Integer;
    Last: Integer;
    YAdvance: Integer;
  end;

  TForm2 = class(TForm)
    ListBox1: TListBox;
    Edit1: TEdit;
    PaintBox1: TPaintBox;
    Button1: TButton;
    Button2: TButton;
    Label6: TLabel;
    SpinEdit3: TSpinEdit;
    Label7: TLabel;
    SpinEdit4: TSpinEdit;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FrameSizeChange(Sender: TObject);
  private
    FFont: TGfxFont;
    FInitialFile: string;
    FSelectedFile: string;
    FAutoSizeFrame: Boolean;
    FLoadingFrameSize: Boolean;
    procedure LoadFontList;
    procedure LoadSelectedFont;
    procedure AutoUpdateFrameSize;
    procedure SetFrameSize(AWidth, AHeight: Integer);
    function LoadGfxFontFile(const AFileName: string): TGfxFont;
    function GfxGlyphCode(AChar: AnsiChar): Integer;
    procedure GfxTextBounds(AFont: TGfxFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
    procedure DrawGfxText(AFont: TGfxFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
  public
    property InitialFile: string read FInitialFile write FInitialFile;
    property SelectedFile: string read FSelectedFile;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

const
  GFX_PREVIEW_Y_CORRECTION = -2;
  LEGACY_FONT_RUS_DIR = 'C:\Users\basachka\Documents\PlatformIO\Projects\Nextion_esp32\.pio\libdeps\esp32dev_ota\AdafruitGFXRusFonts\FontsRus';

function FontsRusDir: string;
var
  Candidate: string;
begin
  Candidate := ExpandFileName(ExtractFilePath(ParamStr(0)) +
    '..\..\.pio\libdeps\esp32dev_ota\AdafruitGFXRusFonts\FontsRus');
  if DirectoryExists(Candidate) then
    Result := Candidate
  else
    Result := LEGACY_FONT_RUS_DIR;
end;

function RemoveLineComments(const S: string): string;
var
  I: Integer;
  InComment: Boolean;
begin
  Result := '';
  I := 1;
  InComment := False;
  while I <= Length(S) do
  begin
    if InComment then
    begin
      if S[I] in [#10, #13] then
      begin
        InComment := False;
        Result := Result + S[I];
      end;
      Inc(I);
      Continue;
    end;
    if (S[I] = '/') and (I < Length(S)) and (S[I + 1] = '/') then
    begin
      InComment := True;
      Inc(I, 2);
      Continue;
    end;
    Result := Result + S[I];
    Inc(I);
  end;
end;

function ExtractBraceBlock(const S, Marker: string): string;
var
  P: Integer;
  B: Integer;
  E: Integer;
begin
  Result := '';
  P := Pos(Marker, S);
  if P = 0 then
    Exit;
  B := P;
  while (B <= Length(S)) and (S[B] <> '{') do
    Inc(B);
  if B > Length(S) then
    Exit;
  E := B + 1;
  while E < Length(S) do
  begin
    if (S[E] = '}') and (S[E + 1] = ';') then
      Break;
    Inc(E);
  end;
  if E >= Length(S) then
    Exit;
  Result := Copy(S, B + 1, E - B - 1);
end;

function ParseCNumbers(const S: string): TIntegerArray;
var
  I: Integer;
  Start: Integer;
  Token: string;
  Value: Integer;
begin
  SetLength(Result, 0);
  I := 1;
  while I <= Length(S) do
  begin
    while (I <= Length(S)) and not (S[I] in ['-', '0'..'9']) do
      Inc(I);
    if I > Length(S) then
      Break;
    Start := I;
    if S[I] = '-' then
      Inc(I);
    if (I + 1 <= Length(S)) and (S[I] = '0') and (UpCase(S[I + 1]) = 'X') then
    begin
      Inc(I, 2);
      while (I <= Length(S)) and (UpCase(S[I]) in ['0'..'9', 'A'..'F']) do
        Inc(I);
    end
    else
      while (I <= Length(S)) and (S[I] in ['0'..'9']) do
        Inc(I);
    Token := Copy(S, Start, I - Start);
    if Pos('0x', LowerCase(Token)) > 0 then
      Token := StringReplace(LowerCase(Token), '0x', '$', []);
    Value := StrToIntDef(Token, 0);
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Value;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FFont := nil;
  FAutoSizeFrame := True;
  FLoadingFrameSize := False;
  SpinEdit3.MaxValue := 480;
  SpinEdit4.MaxValue := 320;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FFont.Free;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  FLoadingFrameSize := True;
  try
    FAutoSizeFrame := True;
    CheckBox1.Checked := True;
    LoadFontList;
  finally
    FLoadingFrameSize := False;
  end;
  AutoUpdateFrameSize;
  PaintBox1.Invalidate;
end;

procedure TForm2.LoadFontList;
var
  SR: TSearchRec;
  Path: string;
  Index: Integer;
begin
  ListBox1.Items.Clear;
  Path := FontsRusDir + '\*.h';
  if FindFirst(Path, faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr and faDirectory) = 0 then
        ListBox1.Items.Add(SR.Name);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  ListBox1.Sorted := True;

  Index := ListBox1.Items.IndexOf(ExtractFileName(FInitialFile));
  if (Index < 0) and (ListBox1.Items.Count > 0) then
    Index := 0;
  if Index >= 0 then
  begin
    ListBox1.ItemIndex := Index;
    LoadSelectedFont;
  end;
end;

procedure TForm2.ListBox1Click(Sender: TObject);
begin
  FAutoSizeFrame := True;
  LoadSelectedFont;
end;

procedure TForm2.Edit1Change(Sender: TObject);
begin
  FAutoSizeFrame := True;
  AutoUpdateFrameSize;
  PaintBox1.Invalidate;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then
  begin
    FSelectedFile := FontsRusDir + '\' + ListBox1.Items[ListBox1.ItemIndex];
    ModalResult := mrOk;
  end;
end;

procedure TForm2.LoadSelectedFont;
begin
  FFont.Free;
  FFont := nil;
  if ListBox1.ItemIndex >= 0 then
    FFont := LoadGfxFontFile(FontsRusDir + '\' + ListBox1.Items[ListBox1.ItemIndex]);
  AutoUpdateFrameSize;
  PaintBox1.Invalidate;
end;

procedure TForm2.CheckBox1Click(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TForm2.FrameSizeChange(Sender: TObject);
begin
  if FLoadingFrameSize then
    Exit;
  FAutoSizeFrame := False;
  PaintBox1.Invalidate;
end;

procedure TForm2.SetFrameSize(AWidth, AHeight: Integer);
begin
  if AWidth < 1 then
    AWidth := 1;
  if AHeight < 1 then
    AHeight := 1;
  if AWidth > SpinEdit3.MaxValue then
    AWidth := SpinEdit3.MaxValue;
  if AHeight > SpinEdit4.MaxValue then
    AHeight := SpinEdit4.MaxValue;

  FLoadingFrameSize := True;
  try
    SpinEdit3.Value := AWidth;
    SpinEdit4.Value := AHeight;
  finally
    FLoadingFrameSize := False;
  end;
end;

procedure TForm2.AutoUpdateFrameSize;
var
  MinX: Integer;
  MinY: Integer;
  MaxX: Integer;
  MaxY: Integer;
  TextW: Integer;
  TextH: Integer;
begin
  if (not FAutoSizeFrame) or (FFont = nil) then
    Exit;

  GfxTextBounds(FFont, Edit1.Text, MinX, MinY, MaxX, MaxY);
  TextW := MaxX - MinX;
  TextH := MaxY - MinY;
  if TextW < 0 then
    TextW := 0;
  if TextH < 0 then
    TextH := 0;

  SetFrameSize(TextW + 16, TextH + 10);
end;

function TForm2.LoadGfxFontFile(const AFileName: string): TGfxFont;
var
  SL: TStringList;
  Text: string;
  CleanText: string;
  Numbers: TIntegerArray;
  I: Integer;
  G: Integer;
begin
  Result := TGfxFont.Create;
  Result.FileName := AFileName;
  if not FileExists(AFileName) then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFileName);
    Text := SL.Text;
  finally
    SL.Free;
  end;

  CleanText := RemoveLineComments(Text);

  Numbers := ParseCNumbers(ExtractBraceBlock(CleanText, 'Bitmaps'));
  SetLength(Result.Bitmaps, Length(Numbers));
  for I := 0 to High(Numbers) do
    Result.Bitmaps[I] := Byte(Numbers[I] and $FF);

  Numbers := ParseCNumbers(ExtractBraceBlock(CleanText, 'Glyphs'));
  SetLength(Result.Glyphs, Length(Numbers) div 6);
  for G := 0 to High(Result.Glyphs) do
  begin
    Result.Glyphs[G].BitmapOffset := Numbers[G * 6 + 0];
    Result.Glyphs[G].Width := Numbers[G * 6 + 1];
    Result.Glyphs[G].Height := Numbers[G * 6 + 2];
    Result.Glyphs[G].XAdvance := Numbers[G * 6 + 3];
    Result.Glyphs[G].XOffset := Numbers[G * 6 + 4];
    Result.Glyphs[G].YOffset := Numbers[G * 6 + 5];
  end;

  Numbers := ParseCNumbers(ExtractBraceBlock(CleanText, 'GFXfont'));
  if Length(Numbers) >= 3 then
  begin
    Result.First := Numbers[Length(Numbers) - 3];
    Result.Last := Numbers[Length(Numbers) - 2];
    Result.YAdvance := Numbers[Length(Numbers) - 1];
  end
  else
  begin
    Result.First := $20;
    Result.Last := Result.First + Length(Result.Glyphs) - 1;
    Result.YAdvance := 16;
  end;
end;

function TForm2.GfxGlyphCode(AChar: AnsiChar): Integer;
var
  C: Integer;
begin
  C := Ord(AChar);
  if C = 168 then
    Result := 192
  else if C = 184 then
    Result := 193
  else if (C >= 192) and (C <= 239) then
    Result := C - 48
  else if (C >= 240) and (C <= 255) then
    Result := C - 112
  else
    Result := C;
end;

procedure TForm2.GfxTextBounds(AFont: TGfxFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
var
  I: Integer;
  Code: Integer;
  Index: Integer;
  CursorX: Integer;
  X1: Integer;
  Y1: Integer;
  X2: Integer;
  Y2: Integer;
  Glyph: TGfxGlyph;
  HasPixels: Boolean;
begin
  AMinX := 0;
  AMinY := 0;
  AMaxX := 0;
  AMaxY := 0;
  CursorX := 0;
  HasPixels := False;
  if AFont = nil then
    Exit;
  for I := 1 to Length(AText) do
  begin
    Code := GfxGlyphCode(AnsiChar(AText[I]));
    Index := Code - AFont.First;
    if (Index < 0) or (Index > High(AFont.Glyphs)) then
      Continue;
    Glyph := AFont.Glyphs[Index];
    X1 := CursorX + Glyph.XOffset;
    Y1 := Glyph.YOffset;
    X2 := X1 + Glyph.Width;
    Y2 := Y1 + Glyph.Height;
    if not HasPixels then
    begin
      AMinX := X1;
      AMinY := Y1;
      AMaxX := X2;
      AMaxY := Y2;
      HasPixels := True;
    end
    else
    begin
      if X1 < AMinX then AMinX := X1;
      if Y1 < AMinY then AMinY := Y1;
      if X2 > AMaxX then AMaxX := X2;
      if Y2 > AMaxY then AMaxY := Y2;
    end;
    Inc(CursorX, Glyph.XAdvance);
  end;
end;

procedure TForm2.DrawGfxText(AFont: TGfxFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
var
  I: Integer;
  Code: Integer;
  Index: Integer;
  CursorX: Integer;
  Glyph: TGfxGlyph;
  BitIndex: Integer;
  ByteIndex: Integer;
  BitMask: Byte;
  XX: Integer;
  YY: Integer;
  PX: Integer;
  PY: Integer;
begin
  if AFont = nil then
    Exit;
  CursorX := 0;
  AColor := ColorToRGB(AColor);
  for I := 1 to Length(AText) do
  begin
    Code := GfxGlyphCode(AnsiChar(AText[I]));
    Index := Code - AFont.First;
    if (Index < 0) or (Index > High(AFont.Glyphs)) then
      Continue;
    Glyph := AFont.Glyphs[Index];
    BitIndex := 0;
    for YY := 0 to Glyph.Height - 1 do
      for XX := 0 to Glyph.Width - 1 do
      begin
        ByteIndex := Glyph.BitmapOffset + (BitIndex div 8);
        if (ByteIndex >= 0) and (ByteIndex <= High(AFont.Bitmaps)) then
        begin
          BitMask := $80 shr (BitIndex mod 8);
          if (AFont.Bitmaps[ByteIndex] and BitMask) <> 0 then
          begin
            PX := ABaselineX + CursorX + Glyph.XOffset + XX;
            PY := ABaselineY + Glyph.YOffset + YY;
            if (PX >= 0) and (PX < PaintBox1.Width) and (PY >= 0) and (PY < PaintBox1.Height) then
              PaintBox1.Canvas.Pixels[PX, PY] := AColor;
          end;
        end;
        Inc(BitIndex);
      end;
    Inc(CursorX, Glyph.XAdvance);
  end;
end;

procedure TForm2.PaintBox1Paint(Sender: TObject);
var
  MinX: Integer;
  MinY: Integer;
  MaxX: Integer;
  MaxY: Integer;
  TextW: Integer;
  TextH: Integer;
  FrameW: Integer;
  FrameH: Integer;
  FrameLeft: Integer;
  FrameTop: Integer;
  BaseX: Integer;
  BaseY: Integer;
begin
  PaintBox1.Canvas.Brush.Color := clBlack;
  PaintBox1.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
  PaintBox1.Canvas.Pen.Color := clGray;
  PaintBox1.Canvas.Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);

  if FFont = nil then
    Exit;

  GfxTextBounds(FFont, Edit1.Text, MinX, MinY, MaxX, MaxY);
  TextW := MaxX - MinX;
  TextH := MaxY - MinY;
  if TextW < 0 then
    TextW := 0;
  if TextH < 0 then
    TextH := 0;

  FrameW := SpinEdit3.Value;
  FrameH := SpinEdit4.Value;
  if FrameW <= 0 then
    FrameW := TextW + 16;
  if FrameH <= 0 then
    FrameH := TextH + 10;
  if FrameW > PaintBox1.Width - 8 then
    FrameW := PaintBox1.Width - 8;
  if FrameH > PaintBox1.Height - 8 then
    FrameH := PaintBox1.Height - 8;

  FrameLeft := (PaintBox1.Width - FrameW) div 2;
  FrameTop := (PaintBox1.Height - FrameH) div 2;

  if CheckBox1.Checked then
  begin
    PaintBox1.Canvas.Brush.Style := bsClear;
    PaintBox1.Canvas.Pen.Color := clLime;
    PaintBox1.Canvas.Rectangle(FrameLeft, FrameTop, FrameLeft + FrameW, FrameTop + FrameH);
    PaintBox1.Canvas.Brush.Style := bsSolid;
  end;

  BaseX := FrameLeft + (FrameW - TextW) div 2 - MinX;
  BaseY := FrameTop + (FrameH - TextH) div 2 - MinY + GFX_PREVIEW_Y_CORRECTION;
  DrawGfxText(FFont, Edit1.Text, BaseX, BaseY, clWhite);
end;

end.
