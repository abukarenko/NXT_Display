unit Unit2;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  Spin, FileCtrl;

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

  TVlwGlyph = record
    Unicode: Integer;
    Width: Integer;
    Height: Integer;
    XAdvance: Integer;
    DX: Integer;
    DY: Integer;
    BitmapOffset: Integer;
  end;

  TVlwGlyphArray = array of TVlwGlyph;

  TVlwFont = class
  public
    FileName: string;
    Bitmaps: TByteArray;
    Glyphs: TVlwGlyphArray;
    Ascent: Integer;
    Descent: Integer;
    YAdvance: Integer;
    SpaceWidth: Integer;
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
    Button3: TButton;
    Label8: TLabel;
    Edit2: TEdit;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FrameSizeChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    FFont: TGfxFont;
    FVlwFont: TVlwFont;
    FInitialFile: string;
    FSelectedFile: string;
    FAutoSizeFrame: Boolean;
    FLoadingFrameSize: Boolean;
    FSdPushRequested: Boolean;
    FSelectedSdFontId: Integer;
    FFontPaths: TStringList;
    FSdFontIds: TIntegerArray;
    FExtraFontDir: string;
    procedure LoadFontList;
    procedure AddFontItem(const ACaption, AFileName: string; ASdFontId: Integer);
    procedure AddVlwFontsFromDir(const ADir: string; var ANextSdFontId: Integer);
    procedure LoadSelectedFont;
    procedure AutoUpdateFrameSize;
    procedure SetFrameSize(AWidth, AHeight: Integer);
    function LoadGfxFontFile(const AFileName: string): TGfxFont;
    function LoadVlwFontFile(const AFileName: string): TVlwFont;
    function GfxGlyphCode(AChar: AnsiChar): Integer;
    function VlwGlyphCode(AChar: AnsiChar): Integer;
    function FindVlwGlyph(AFont: TVlwFont; ACode: Integer; var AGlyph: TVlwGlyph): Boolean;
    procedure GfxTextBounds(AFont: TGfxFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
    procedure VlwTextBounds(AFont: TVlwFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
    procedure DrawGfxText(AFont: TGfxFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
    procedure DrawVlwText(AFont: TVlwFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
  public
    property InitialFile: string read FInitialFile write FInitialFile;
    property SelectedFile: string read FSelectedFile;
    property SdPushRequested: Boolean read FSdPushRequested;
    property SelectedSdFontId: Integer read FSelectedSdFontId;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

const
  GFX_PREVIEW_Y_CORRECTION = -2;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function FontsRusDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'fonts';
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function SmoothFontsDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'sd' + PathDelim + 'fonts';
end;
//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
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

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
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

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
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

//======================================================
// Инициализирует форму и связывает обработчики.
procedure TForm2.FormCreate(Sender: TObject);
begin
  Button1.Enabled := False;
  Button1.Default := False;
  Button3.Enabled := False;
  FFont := nil;
  FVlwFont := nil;
  FAutoSizeFrame := True;
  FLoadingFrameSize := False;
  FSdPushRequested := False;
  FSelectedSdFontId := 0;
  FFontPaths := TStringList.Create;
    ListBox1.Sorted := False;
SpinEdit3.MaxValue := 480;
  SpinEdit4.MaxValue := 320;
end;

//======================================================
// Освобождает ресурсы формы.
procedure TForm2.FormDestroy(Sender: TObject);
begin
  FFont.Free;
  FVlwFont.Free;
  FFontPaths.Free;
end;

//======================================================
// Обновляет данные формы перед показом.
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

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.AddFontItem(const ACaption, AFileName: string; ASdFontId: Integer);
var
  N: Integer;
begin
  ListBox1.Items.Add(ACaption);
  FFontPaths.Add(AFileName);
  N := Length(FSdFontIds);
  SetLength(FSdFontIds, N + 1);
  FSdFontIds[N] := ASdFontId;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.AddVlwFontsFromDir(const ADir: string; var ANextSdFontId: Integer);
var
  SR: TSearchRec;
  Mask: string;
  FullName: string;
begin
  if not DirectoryExists(ADir) then
    Exit;

  Mask := IncludeTrailingBackslash(ADir) + '*.vlw';
  if FindFirst(Mask, faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr and faDirectory) = 0 then
      begin
        FullName := IncludeTrailingBackslash(ADir) + SR.Name;
        if FFontPaths.IndexOf(FullName) < 0 then
        begin
          AddFontItem('[SD ' + IntToStr(ANextSdFontId) + '] ' + SR.Name, FullName, ANextSdFontId);
          Inc(ANextSdFontId);
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.LoadFontList;
var
  SR: TSearchRec;
  Path: string;
  Dir: string;
  Index: Integer;
  NextSdFontId: Integer;

  procedure AddGfxFontsFromDir(const ADir: string; const APrefix: string);
  var
    SearchPath: string;
    FullName: string;
  begin
    if not DirectoryExists(ADir) then
      Exit;
    SearchPath := IncludeTrailingBackslash(ADir) + '*.h';
    if FindFirst(SearchPath, faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) = 0 then
          begin
            FullName := IncludeTrailingBackslash(ADir) + SR.Name;
            if FFontPaths.IndexOf(FullName) < 0 then
              AddFontItem(APrefix + SR.Name, FullName, 0);
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

begin
  ListBox1.Items.Clear;
  FFontPaths.Clear;
  SetLength(FSdFontIds, 0);

  AddGfxFontsFromDir(FontsRusDir, '');

  NextSdFontId := 100;
  AddVlwFontsFromDir(SmoothFontsDir, NextSdFontId);

  Dir := Trim(FExtraFontDir);
  if Dir = '' then
    Dir := Trim(Edit2.Text);
  if (Dir <> '') and DirectoryExists(Dir) then
  begin
    AddGfxFontsFromDir(Dir, '[DIR] ');
    AddVlwFontsFromDir(Dir, NextSdFontId);
  end;

  Index := FFontPaths.IndexOf(FInitialFile);
  if (Index < 0) and (FSelectedFile <> '') then
    Index := FFontPaths.IndexOf(FSelectedFile);
  if (Index < 0) and (ListBox1.Items.Count > 0) then
    Index := 0;
  if Index >= 0 then
  begin
    ListBox1.ItemIndex := Index;
    LoadSelectedFont;
  end
  else
  begin
    FFont.Free;
    FFont := nil;
    FVlwFont.Free;
    FVlwFont := nil;
    PaintBox1.Invalidate;
  end;
end;
//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.ListBox1Click(Sender: TObject);
begin
  FAutoSizeFrame := True;
  LoadSelectedFont;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.Edit1Change(Sender: TObject);
begin
  FAutoSizeFrame := True;
  AutoUpdateFrameSize;
  PaintBox1.Invalidate;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.Button1Click(Sender: TObject);
begin
  FSdPushRequested := False;
  FSelectedSdFontId := 0;
  if ListBox1.ItemIndex >= 0 then
  begin
    FSelectedFile := FFontPaths[ListBox1.ItemIndex];
    if (ListBox1.ItemIndex <= High(FSdFontIds)) and (FSdFontIds[ListBox1.ItemIndex] >= 100) then
      FSelectedSdFontId := FSdFontIds[ListBox1.ItemIndex];
    ModalResult := mrOk;
  end;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.Button3Click(Sender: TObject);
begin
  FSdPushRequested := False;
  FSelectedSdFontId := 0;
  if (ListBox1.ItemIndex < 0) or (ListBox1.ItemIndex >= FFontPaths.Count) then
    Exit;
  if (ListBox1.ItemIndex > High(FSdFontIds)) or (FSdFontIds[ListBox1.ItemIndex] < 100) then
  begin
    Label8.Caption := 'Select .vlw font';
    Exit;
  end;

  FSelectedFile := FFontPaths[ListBox1.ItemIndex];
  FSelectedSdFontId := FSdFontIds[ListBox1.ItemIndex];
  FSdPushRequested := True;
  Label8.Caption := '0%';
  ModalResult := mrOk;
end;
//======================================================
// Открывает выбор каталога шрифтов для дополнительного просмотра.
procedure TForm2.Button4Click(Sender: TObject);
var
  Dir: string;
begin
  Dir := Trim(Edit2.Text);
  if Dir = '' then
    Dir := ExtractFilePath(ParamStr(0));
  if SelectDirectory('Папка шрифтов', '', Dir) then
  begin
    FExtraFontDir := Dir;
    Edit2.Text := Dir;
    LoadFontList;
  end;
end;

//======================================================
// Перечитывает список шрифтов из стандартных и выбранной папки.
procedure TForm2.Button5Click(Sender: TObject);
begin
  FExtraFontDir := Trim(Edit2.Text);
  LoadFontList;
end;
//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.LoadSelectedFont;
var
  Ext: string;
begin
  FFont.Free;
  FFont := nil;
  FVlwFont.Free;
  FVlwFont := nil;
  if (ListBox1.ItemIndex >= 0) and (ListBox1.ItemIndex < FFontPaths.Count) then
  begin
    Ext := LowerCase(ExtractFileExt(FFontPaths[ListBox1.ItemIndex]));
    if Ext = '.h' then
      FFont := LoadGfxFontFile(FFontPaths[ListBox1.ItemIndex])
    else if Ext = '.vlw' then
      FVlwFont := LoadVlwFontFile(FFontPaths[ListBox1.ItemIndex]);
  end;
  AutoUpdateFrameSize;
  PaintBox1.Invalidate;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.CheckBox1Click(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm2.FrameSizeChange(Sender: TObject);
begin
  if FLoadingFrameSize then
    Exit;
  FAutoSizeFrame := False;
  PaintBox1.Invalidate;
end;

//======================================================
// Выполняет действие формы или редактора.
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

//======================================================
// Выполняет действие формы или редактора.
procedure TForm2.AutoUpdateFrameSize;
var
  MinX: Integer;
  MinY: Integer;
  MaxX: Integer;
  MaxY: Integer;
  TextW: Integer;
  TextH: Integer;
begin
  if not FAutoSizeFrame then
    Exit;
  if (FFont = nil) and (FVlwFont = nil) then
    Exit;

  if FFont <> nil then
    GfxTextBounds(FFont, Edit1.Text, MinX, MinY, MaxX, MaxY)
  else
    VlwTextBounds(FVlwFont, Edit1.Text, MinX, MinY, MaxX, MaxY);
  TextW := MaxX - MinX;
  TextH := MaxY - MinY;
  if TextW < 0 then
    TextW := 0;
  if TextH < 0 then
    TextH := 0;

  SetFrameSize(TextW + 16, TextH + 10);
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
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

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
function ReadBeInt32(Stream: TStream): Integer;
var
  B: array[0..3] of Byte;
begin
  Result := 0;
  if Stream.Read(B, SizeOf(B)) <> SizeOf(B) then
    Exit;
  Result := (Integer(B[0]) shl 24) or (Integer(B[1]) shl 16) or
    (Integer(B[2]) shl 8) or Integer(B[3]);
end;

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
function SignedByte(AValue: Integer): Integer;
begin
  AValue := AValue and $FF;
  if AValue >= 128 then
    Result := AValue - 256
  else
    Result := AValue;
end;

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
function SignedWord(AValue: Integer): Integer;
begin
  AValue := AValue and $FFFF;
  if AValue >= 32768 then
    Result := AValue - 65536
  else
    Result := AValue;
end;

//======================================================
// Обрабатывает выбор и отображение цветов палитры.
function BlendColor(ABackground, AForeground: TColor; AAlpha: Byte): TColor;
var
  BR: Integer;
  BG: Integer;
  BB: Integer;
  FR: Integer;
  FG: Integer;
  FB: Integer;
begin
  ABackground := ColorToRGB(ABackground);
  AForeground := ColorToRGB(AForeground);
  BR := GetRValue(ABackground);
  BG := GetGValue(ABackground);
  BB := GetBValue(ABackground);
  FR := GetRValue(AForeground);
  FG := GetGValue(AForeground);
  FB := GetBValue(AForeground);
  Result := RGB(
    (FR * AAlpha + BR * (255 - AAlpha)) div 255,
    (FG * AAlpha + BG * (255 - AAlpha)) div 255,
    (FB * AAlpha + BB * (255 - AAlpha)) div 255);
end;
//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
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

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
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

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
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

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function TForm2.LoadVlwFontFile(const AFileName: string): TVlwFont;
var
  Stream: TFileStream;
  GlyphCount: Integer;
  I: Integer;
  BitmapPtr: Integer;
  TotalSize: Integer;
  BitmapSize: Integer;
begin
  Result := TVlwFont.Create;
  Result.FileName := AFileName;
  if not FileExists(AFileName) then
    Exit;

  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    GlyphCount := ReadBeInt32(Stream);
    ReadBeInt32(Stream);
    ReadBeInt32(Stream);
    ReadBeInt32(Stream);
    Result.Ascent := ReadBeInt32(Stream);
    Result.Descent := ReadBeInt32(Stream);
    Result.YAdvance := Result.Ascent + Result.Descent;
    Result.SpaceWidth := (Result.Ascent + Result.Descent) * 2 div 7;
    if Result.SpaceWidth < 1 then
      Result.SpaceWidth := 4;

    if GlyphCount < 0 then
      GlyphCount := 0;
    if GlyphCount > 4096 then
      GlyphCount := 4096;
    SetLength(Result.Glyphs, GlyphCount);
    BitmapPtr := 24 + GlyphCount * 28;
    for I := 0 to GlyphCount - 1 do
    begin
      Result.Glyphs[I].Unicode := ReadBeInt32(Stream);
      Result.Glyphs[I].Height := ReadBeInt32(Stream) and $FF;
      Result.Glyphs[I].Width := ReadBeInt32(Stream) and $FF;
      Result.Glyphs[I].XAdvance := ReadBeInt32(Stream) and $FF;
      Result.Glyphs[I].DY := SignedWord(ReadBeInt32(Stream));
      Result.Glyphs[I].DX := SignedByte(ReadBeInt32(Stream));
      ReadBeInt32(Stream);
      Result.Glyphs[I].BitmapOffset := BitmapPtr;
      Inc(BitmapPtr, Result.Glyphs[I].Width * Result.Glyphs[I].Height);
    end;

    TotalSize := Stream.Size;
    if BitmapPtr > TotalSize then
      BitmapPtr := TotalSize;
    BitmapSize := TotalSize - (24 + GlyphCount * 28);
    if BitmapSize < 0 then
      BitmapSize := 0;
    SetLength(Result.Bitmaps, BitmapSize);
    Stream.Position := 24 + GlyphCount * 28;
    if BitmapSize > 0 then
      Stream.ReadBuffer(Result.Bitmaps[0], BitmapSize);
    for I := 0 to High(Result.Glyphs) do
      Dec(Result.Glyphs[I].BitmapOffset, 24 + GlyphCount * 28);
  finally
    Stream.Free;
  end;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function TForm2.VlwGlyphCode(AChar: AnsiChar): Integer;
var
  C: Integer;
begin
  C := Ord(AChar);
  if C = 168 then
    Result := $0401
  else if C = 184 then
    Result := $0451
  else if C = 185 then
    Result := $2116
  else if C >= 192 then
    Result := $0410 + (C - 192)
  else
    Result := C;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function TForm2.FindVlwGlyph(AFont: TVlwFont; ACode: Integer; var AGlyph: TVlwGlyph): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AFont = nil then
    Exit;
  for I := 0 to High(AFont.Glyphs) do
    if AFont.Glyphs[I].Unicode = ACode then
    begin
      AGlyph := AFont.Glyphs[I];
      Result := True;
      Exit;
    end;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.VlwTextBounds(AFont: TVlwFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
var
  I: Integer;
  Code: Integer;
  CursorX: Integer;
  X1: Integer;
  Y1: Integer;
  X2: Integer;
  Y2: Integer;
  Glyph: TVlwGlyph;
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
    Code := VlwGlyphCode(AnsiChar(AText[I]));
    if Code = 32 then
    begin
      Inc(CursorX, AFont.SpaceWidth);
      Continue;
    end;
    if not FindVlwGlyph(AFont, Code, Glyph) then
      Continue;
    X1 := CursorX + Glyph.DX;
    Y1 := -Glyph.DY;
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
  if not HasPixels then
    AMaxX := CursorX;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
procedure TForm2.DrawVlwText(AFont: TVlwFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
var
  I: Integer;
  Code: Integer;
  CursorX: Integer;
  Glyph: TVlwGlyph;
  XX: Integer;
  YY: Integer;
  PX: Integer;
  PY: Integer;
  BitmapIndex: Integer;
  Alpha: Byte;
begin
  if AFont = nil then
    Exit;
  CursorX := 0;
  for I := 1 to Length(AText) do
  begin
    Code := VlwGlyphCode(AnsiChar(AText[I]));
    if Code = 32 then
    begin
      Inc(CursorX, AFont.SpaceWidth);
      Continue;
    end;
    if not FindVlwGlyph(AFont, Code, Glyph) then
      Continue;
    for YY := 0 to Glyph.Height - 1 do
      for XX := 0 to Glyph.Width - 1 do
      begin
        BitmapIndex := Glyph.BitmapOffset + YY * Glyph.Width + XX;
        if (BitmapIndex >= 0) and (BitmapIndex <= High(AFont.Bitmaps)) then
        begin
          Alpha := AFont.Bitmaps[BitmapIndex];
          if Alpha <> 0 then
          begin
            PX := ABaselineX + CursorX + Glyph.DX + XX;
            PY := ABaselineY - Glyph.DY + YY;
            if (PX >= 0) and (PX < PaintBox1.Width) and (PY >= 0) and (PY < PaintBox1.Height) then
              PaintBox1.Canvas.Pixels[PX, PY] := BlendColor(clBlack, AColor, Alpha);
          end;
        end;
      end;
    Inc(CursorX, Glyph.XAdvance);
  end;
end;
//======================================================
// Рисует или обрабатывает виртуальный LCD и область предпросмотра.
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

  if (FFont = nil) and (FVlwFont = nil) then
    Exit;

  if FFont <> nil then
    GfxTextBounds(FFont, Edit1.Text, MinX, MinY, MaxX, MaxY)
  else
    VlwTextBounds(FVlwFont, Edit1.Text, MinX, MinY, MaxX, MaxY);
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
  if FFont <> nil then
    DrawGfxText(FFont, Edit1.Text, BaseX, BaseY, clWhite)
  else if FVlwFont <> nil then
    DrawVlwText(FVlwFont, Edit1.Text, BaseX, BaseY, clWhite);
end;

end.
