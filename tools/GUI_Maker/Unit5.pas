unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, jpeg;

type
  TForm5 = class(TForm)
    RichEdit1: TRichEdit;
    Panel1: TPanel;
    Label2: TLabel;
    ListBox1: TListBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FFilePopup: TPopupMenu;
    FDeleteMenuItem: TMenuItem;
    FUploadMenuItem: TMenuItem;
    FShowMenuItem: TMenuItem;
    FShowLcdMenuItem: TMenuItem;
    procedure EnsureFilePopup;
    procedure FilePopupPopup(Sender: TObject);
    procedure DeleteMenuItemClick(Sender: TObject);
    procedure UploadMenuItemClick(Sender: TObject);
    procedure ShowMenuItemClick(Sender: TObject);
    procedure ShowLcdMenuItemClick(Sender: TObject);
    procedure SplitPipe(const S: string; Parts: TStrings);
    procedure RefreshDirectories;
    procedure RefreshFiles;
    function SelectedSdPath: string;
    function DownloadFile(const ASdPath: string; ADest: TStream): Boolean;
    function DecodeTextStream(AStream: TStream): AnsiString;
    procedure ShowSelectedFile;
    procedure ShowTextStream(AStream: TStream);
    procedure ShowJpegStream(AStream: TStream);
  public
  end;

var
  Form5: TForm5;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm5.EnsureFilePopup;
begin
  if Assigned(FFilePopup) then
    Exit;

  FFilePopup := TPopupMenu.Create(Self);
  FFilePopup.OnPopup := FilePopupPopup;

  FDeleteMenuItem := TMenuItem.Create(FFilePopup);
  FDeleteMenuItem.Caption := 'Delete';
  FDeleteMenuItem.OnClick := DeleteMenuItemClick;
  FFilePopup.Items.Add(FDeleteMenuItem);

  FUploadMenuItem := TMenuItem.Create(FFilePopup);
  FUploadMenuItem.Caption := 'Upload';
  FUploadMenuItem.OnClick := UploadMenuItemClick;
  FFilePopup.Items.Add(FUploadMenuItem);

  FShowMenuItem := TMenuItem.Create(FFilePopup);
  FShowMenuItem.Caption := 'Show';
  FShowMenuItem.OnClick := ShowMenuItemClick;
  FFilePopup.Items.Add(FShowMenuItem);

  FShowLcdMenuItem := TMenuItem.Create(FFilePopup);
  FShowLcdMenuItem.Caption := 'Show from LCD';
  FShowLcdMenuItem.OnClick := ShowLcdMenuItemClick;
  FFilePopup.Items.Add(FShowLcdMenuItem);

  ListBox1.PopupMenu := FFilePopup;
end;

//======================================================
// Выполняет действие формы или редактора.
procedure TForm5.FilePopupPopup(Sender: TObject);
var
  Ext: string;
  IsScene, IsImage: Boolean;
begin
  Ext := LowerCase(ExtractFileExt(SelectedSdPath));
  IsScene := (Ext = '.nxt') or (Ext = '.txt');
  IsImage := (Ext = '.jpg') or (Ext = '.jpeg');
  FDeleteMenuItem.Visible := IsScene;
  FUploadMenuItem.Visible := IsScene;
  FShowMenuItem.Visible := IsImage;
  FShowLcdMenuItem.Visible := IsImage;
end;

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm5.DeleteMenuItemClick(Sender: TObject);
var
  Path, Reply: string;
begin
  Path := SelectedSdPath;
  if Path = '' then
    Exit;
  if MessageDlg('Delete file ' + Path + '?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    Exit;
  if Form1.EspExchange('RM|' + Path, 'OK|RM|', 2500, Reply) then
  begin
    Form1.EditorStatus('Deleted: ' + Path);
    RefreshFiles;
  end
  else
    Form1.EditorStatus('Delete failed: ' + Reply);
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.UploadMenuItemClick(Sender: TObject);
var
  Path, Reply: string;
begin
  Path := SelectedSdPath;
  if Path = '' then
    Exit;
  if Form1.EspExchange('SC|' + Path, 'OK|SC|', 5000, Reply) then
    Form1.EditorStatus('Scene uploaded: ' + Path)
  else
    Form1.EditorStatus('Scene upload failed: ' + Reply);
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.ShowMenuItemClick(Sender: TObject);
begin
  ShowSelectedFile;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.ShowLcdMenuItemClick(Sender: TObject);
var
  Path, Reply: string;
begin
  Path := SelectedSdPath;
  if Path = '' then
    Exit;
  if Form1.EspExchange('JPG|9999|0|0|' + Path + '|1', 'OK|JPG|',
    5000, Reply) then
    Form1.EditorStatus('LCD image: ' + Path)
  else
    Form1.EditorStatus('LCD image failed: ' + Reply);
end;

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
procedure TForm5.SplitPipe(const S: string; Parts: TStrings);
var
  I, StartPos: Integer;
begin
  Parts.Clear;
  StartPos := 1;
  for I := 1 to Length(S) do
    if S[I] = '|' then
    begin
      Parts.Add(Copy(S, StartPos, I - StartPos));
      StartPos := I + 1;
    end;
  Parts.Add(Copy(S, StartPos, MaxInt));
end;

//======================================================
// Обновляет и показывает содержимое файлового менеджера SD.
procedure TForm5.RefreshDirectories;
var
  Reply, Previous: string;
  Parts: TStringList;
  I, Index: Integer;
begin
  Previous := ComboBox1.Text;
  if not Form1.EspExchange('DL', 'OK|DL|', 2500, Reply) then
  begin
    Form1.EditorStatus('SD folder list failed: ' + Reply);
    Exit;
  end;

  Parts := TStringList.Create;
  try
    SplitPipe(Reply, Parts);
    ComboBox1.Items.BeginUpdate;
    try
      ComboBox1.Items.Clear;
      for I := 2 to Parts.Count - 1 do
        if Trim(Parts[I]) <> '' then
          ComboBox1.Items.Add(Trim(Parts[I]));
    finally
      ComboBox1.Items.EndUpdate;
    end;
  finally
    Parts.Free;
  end;

  Index := ComboBox1.Items.IndexOf(Previous);
  if (Index < 0) and (ComboBox1.Items.Count > 0) then
    Index := 0;
  ComboBox1.ItemIndex := Index;
  RefreshFiles;
end;

//======================================================
// Обновляет и показывает содержимое файлового менеджера SD.
procedure TForm5.RefreshFiles;
var
  Reply: string;
  Parts: TStringList;
  I: Integer;
begin
  ListBox1.Items.Clear;
  RichEdit1.Clear;
  Image1.Picture.Assign(nil);
  if Trim(ComboBox1.Text) = '' then
    Exit;

  if not Form1.EspExchange('SL|' + Trim(ComboBox1.Text), 'OK|SL', 8000, Reply) then
  begin
    Form1.EditorStatus('SD file list failed: ' + Reply);
    Exit;
  end;

  Parts := TStringList.Create;
  try
    SplitPipe(Reply, Parts);
    for I := 2 to Parts.Count - 1 do
      if Trim(Parts[I]) <> '' then
        ListBox1.Items.Add(Trim(Parts[I]));
  finally
    Parts.Free;
  end;
  Form1.EditorStatus(Format('SD: %s, %d file(s)',
    [ComboBox1.Text, ListBox1.Items.Count]));
end;

//======================================================
// Работает с файлами на локальной папке SD и SD-карте ESP.
function TForm5.SelectedSdPath: string;
var
  Folder: string;
begin
  Result := '';
  if ListBox1.ItemIndex < 0 then
    Exit;
  Folder := Trim(ComboBox1.Text);
  if Folder = '/' then
    Result := '/' + ListBox1.Items[ListBox1.ItemIndex]
  else
    Result := Folder + '/' + ListBox1.Items[ListBox1.ItemIndex];
end;

//======================================================
// Работает с файлами на локальной папке SD и SD-карте ESP.
function TForm5.DownloadFile(const ASdPath: string; ADest: TStream): Boolean;
var
  Reply, HexText: string;
  Parts: TStringList;
  Offset, TotalSize, I, Value: Integer;
  B: Byte;
begin
  Result := False;
  Form1.EditorProgress(0);
  Offset := 0;
  TotalSize := -1;
  ADest.Size := 0;
  Parts := TStringList.Create;
  try
    repeat
      if not Form1.EspExchange('FR|' + ASdPath + '|' + IntToStr(Offset) + '|64',
        'OK|FR|', 2500, Reply) then
      begin
        Form1.EditorStatus('SD read failed: ' + Reply);
        Exit;
      end;
      SplitPipe(Reply, Parts);
      if Parts.Count < 6 then
      begin
        Form1.EditorStatus('Bad FR reply: ' + Reply);
        Exit;
      end;
      TotalSize := StrToIntDef(Parts[4], -1);
      HexText := Trim(Parts[5]);
      I := 1;
      while I < Length(HexText) do
      begin
        Value := StrToIntDef('$' + Copy(HexText, I, 2), -1);
        if Value < 0 then
          Exit;
        B := Byte(Value);
        ADest.WriteBuffer(B, 1);
        Inc(I, 2);
      end;
      Inc(Offset, Length(HexText) div 2);
      if TotalSize > 0 then
        Form1.EditorProgress((Offset * 100) div TotalSize);
    until (TotalSize >= 0) and (Offset >= TotalSize);
    Form1.EditorProgress(100);
    ADest.Position := 0;
    Result := True;
  finally
    Parts.Free;
  end;
end;

//======================================================
// Выполняет действие формы или редактора.
procedure TForm5.ShowTextStream(AStream: TStream);
begin
  Image1.Visible := False;
  RichEdit1.Visible := True;
  RichEdit1.Text := DecodeTextStream(AStream);
end;

//======================================================
// Обновляет и показывает содержимое файлового менеджера SD.
function TForm5.DecodeTextStream(AStream: TStream): AnsiString;
const
  MB_ERR_INVALID_CHARS = $00000008;
var
  Raw: AnsiString;
  Wide: WideString;
  RawPtr: PAnsiChar;
  RawLength, WideLength: Integer;
begin
  Result := '';
  AStream.Position := 0;
  RawLength := AStream.Size;
  if RawLength <= 0 then
    Exit;

  SetLength(Raw, RawLength);
  AStream.ReadBuffer(Raw[1], RawLength);
  if (Length(Raw) >= 3) and
    (Byte(Raw[1]) = $EF) and (Byte(Raw[2]) = $BB) and
    (Byte(Raw[3]) = $BF) then
    Delete(Raw, 1, 3);

  if Raw = '' then
    Exit;
  RawPtr := PAnsiChar(Raw);
  WideLength := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
    RawPtr, Length(Raw), nil, 0);
  if WideLength <= 0 then
  begin
    Result := Raw;
    Exit;
  end;

  SetLength(Wide, WideLength);
  MultiByteToWideChar(CP_UTF8, 0, RawPtr, Length(Raw),
    PWideChar(Wide), WideLength);
  Result := AnsiString(Wide);
end;

//======================================================
// Выполняет действие формы или редактора.
procedure TForm5.ShowJpegStream(AStream: TStream);
var
  Jpg: TJPEGImage;
begin
  Jpg := TJPEGImage.Create;
  try
    AStream.Position := 0;
    Jpg.LoadFromStream(AStream);
    Image1.Picture.Assign(Jpg);
    RichEdit1.Visible := False;
    Image1.Visible := True;
  finally
    Jpg.Free;
  end;
end;

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm5.ShowSelectedFile;
var
  Path, Ext: string;
  Stream: TMemoryStream;
begin
  Path := SelectedSdPath;
  if Path = '' then
    Exit;
  Stream := TMemoryStream.Create;
  try
    if not DownloadFile(Path, Stream) then
      Exit;
    Ext := LowerCase(ExtractFileExt(Path));
    try
      if (Ext = '.jpg') or (Ext = '.jpeg') then
        ShowJpegStream(Stream)
      else
        ShowTextStream(Stream);
      Form1.EditorStatus(Format('Loaded %s (%d bytes)', [Path, Stream.Size]));
    except
      on E: Exception do
        Form1.EditorStatus('File preview error: ' + E.Message);
    end;
  finally
    Stream.Free;
  end;
end;

//======================================================
// Обновляет данные формы перед показом.
procedure TForm5.FormShow(Sender: TObject);
begin
  EnsureFilePopup;
  RefreshDirectories;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.Button1Click(Sender: TObject);
begin
  RefreshDirectories;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.ComboBox1Change(Sender: TObject);
begin
  RefreshFiles;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.ListBox1Click(Sender: TObject);
begin
  ShowSelectedFile;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm5.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  if Button <> mbRight then
    Exit;
  Index := ListBox1.ItemAtPos(Point(X, Y), True);
  if Index >= 0 then
    ListBox1.ItemIndex := Index
  else
    ListBox1.ItemIndex := -1;
end;

end.
