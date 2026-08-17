unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, ComCtrls;

type
  TSdFileSortInfo = record
    Name: string;
    Size: Int64;
    Stamp: Int64;
  end;

  TSdFileSortArray = array of TSdFileSortInfo;

  TForm6 = class(TForm)
    FileListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    FileListBox2: TListBox;
    ComboBox1: TComboBox;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    StatusBar1: TStatusBar;
    ProgressBar1: TProgressBar;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ComboBox2: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FileListBox2Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FileListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    FBusy: Boolean;
    FLocalSizes: TStringList;
    FLocalStamps: TStringList;
    FRemoteSizes: TStringList;
    FRemoteStamps: TStringList;
    procedure SetBusy(AValue: Boolean);
    procedure SetStatus(const AText: string);
    procedure PopulateFolders;
    procedure RefreshPanels;
    procedure RefreshLocalFiles;
    procedure RefreshRemoteFiles;
    procedure SortFileItems(AItems: TStrings; ARemote: Boolean);
    procedure ApplyFileSort;
    function CachedInfoValue(AList: TStringList; const AName: string): Int64;
    function FileSizeText(AValue: Int64): string;
    procedure CollectSelectedItems(AList: TListBox; ADest: TStrings);
    function SelectedFolder: string;
    function LocalFolder: string;
    function RemoteFilePath(const AName: string): string;
    function UploadFile(const ALocalFile, ARemoteFile: string): Boolean;
    function DownloadFile(const ARemoteFile, ALocalFile: string): Boolean;
  public
  end;

var
  Form6: TForm6;

implementation

uses Unit1;

{$R *.dfm}

procedure SplitPipeText(const AText: string; ADest: TStrings);
var
  I: Integer;
  StartPos: Integer;
begin
  ADest.Clear;
  StartPos := 1;
  for I := 1 to Length(AText) do
    if AText[I] = '|' then
    begin
      ADest.Add(Copy(AText, StartPos, I - StartPos));
      StartPos := I + 1;
    end;
  ADest.Add(Copy(AText, StartPos, MaxInt));
end;

function HexByte(const AText: string; AIndex: Integer): Byte;
begin
  Result := StrToIntDef('$' + Copy(AText, AIndex, 2), 0);
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
  Caption := 'SD Explorer';
  ComboBox1.Style := csDropDownList;
  ComboBox2.Style := csDropDownList;
  if ComboBox2.Items.Count = 0 then
  begin
    ComboBox2.Items.Add('Unsort');
    ComboBox2.Items.Add('Name');
    ComboBox2.Items.Add('Date');
    ComboBox2.Items.Add('Size');
  end;
  ComboBox2.ItemIndex := 0;
  FileListBox1.Style := lbOwnerDrawFixed;
  FileListBox2.Style := lbOwnerDrawFixed;
  FLocalSizes := TStringList.Create;
  FLocalStamps := TStringList.Create;
  FRemoteSizes := TStringList.Create;
  FRemoteStamps := TStringList.Create;
  ProgressBar1.Min := 0;
  ProgressBar1.Max := 100;
  ProgressBar1.Position := 0;
  Form1.EditorProgress(ProgressBar1.Position);
  FBusy := False;
  Label4.Caption := 'No local file selected';
  Label5.Caption := 'No display file selected';
  SetStatus('Ready');
end;

procedure TForm6.FormDestroy(Sender: TObject);
begin
  FRemoteStamps.Free;
  FRemoteSizes.Free;
  FLocalStamps.Free;
  FLocalSizes.Free;
end;

procedure TForm6.FormShow(Sender: TObject);
begin
  try
    PopulateFolders;
    RefreshPanels;
  except
    on E: Exception do
      SetStatus('Open failed: ' + E.Message);
  end;
end;

procedure TForm6.SetBusy(AValue: Boolean);
begin
  FBusy := AValue;
  ComboBox1.Enabled := not AValue;
  ComboBox2.Enabled := not AValue;
  Button1.Enabled := not AValue;
  Button2.Enabled := not AValue;
  Button3.Enabled := not AValue;
  Button4.Enabled := not AValue;
  FileListBox1.Enabled := not AValue;
  FileListBox2.Enabled := not AValue;
  if not AValue then
    ProgressBar1.Position := 0;
    Form1.EditorProgress(ProgressBar1.Position);
  if AValue then
    Screen.Cursor := crHourGlass
  else
    Screen.Cursor := crDefault;
end;

procedure TForm6.SetStatus(const AText: string);
begin
  Caption := 'SD Explorer - ' + AText;
  if StatusBar1.Panels.Count > 0 then
    StatusBar1.Panels[0].Text := AText;
  if Assigned(Form1) then
    Form1.EditorStatus('SD Explorer: ' + AText);
end;

function TForm6.SelectedFolder: string;
begin
  Result := Trim(ComboBox1.Text);
  if (Result = '') or (Result[1] <> '/') then
    Result := '/';
  while (Length(Result) > 1) and (Result[Length(Result)] = '/') do
    Delete(Result, Length(Result), 1);
end;

function TForm6.LocalFolder: string;
var
  Root: string;
  RelativePath: string;
  Candidate: string;
begin
  Root := IncludeTrailingPathDelimiter(ExpandFileName(Form1.EditorSdRootPath));
  RelativePath := SelectedFolder;
  if RelativePath = '/' then
    RelativePath := ''
  else
    Delete(RelativePath, 1, 1);
  RelativePath := StringReplace(RelativePath, '/', '\', [rfReplaceAll]);
  Candidate := ExpandFileName(Root + RelativePath);
  if Pos(UpperCase(Root), UpperCase(IncludeTrailingPathDelimiter(Candidate))) <> 1 then
    raise Exception.Create('Folder is outside local SD root');
  ForceDirectories(Candidate);
  Result := Candidate;
end;

function TForm6.RemoteFilePath(const AName: string): string;
begin
  if SelectedFolder = '/' then
    Result := '/' + ExtractFileName(AName)
  else
    Result := SelectedFolder + '/' + ExtractFileName(AName);
end;

procedure TForm6.PopulateFolders;
var
  Reply: string;
  Parts: TStringList;
  SR: TSearchRec;
  Root: string;
  I: Integer;
  OldFolder: string;
  FolderName: string;
begin
  OldFolder := SelectedFolder;
  ComboBox1.Items.BeginUpdate;
  try
    ComboBox1.Items.Clear;
    ComboBox1.Items.Add('/');
    Root := IncludeTrailingPathDelimiter(Form1.EditorSdRootPath);
    ForceDirectories(Root);
    if FindFirst(Root + '*.*', faDirectory, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name <> '.') and
          (SR.Name <> '..') and (CompareText(SR.Name, 'System Volume Information') <> 0) then
          ComboBox1.Items.Add('/' + SR.Name);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;

    if Form1.EspExchange('DL', 'OK|DL|', 3000, Reply) then
    begin
      Parts := TStringList.Create;
      try
        SplitPipeText(Reply, Parts);
        for I := 2 to Parts.Count - 1 do
        begin
          FolderName := Trim(Parts[I]);
          if (FolderName <> '') and (ComboBox1.Items.IndexOf(FolderName) < 0) then
            ComboBox1.Items.Add(FolderName);
        end;
      finally
        Parts.Free;
      end;
    end;
  finally
    ComboBox1.Items.EndUpdate;
  end;
  I := ComboBox1.Items.IndexOf(OldFolder);
  if I < 0 then
    I := 0;
  ComboBox1.ItemIndex := I;
end;

procedure TForm6.RefreshLocalFiles;
var
  SR: TSearchRec;
  SearchPath: string;
begin
  FileListBox1.Items.BeginUpdate;
  try
    FileListBox1.Items.Clear;
    FLocalSizes.Clear;
    FLocalStamps.Clear;
    SearchPath := IncludeTrailingPathDelimiter(LocalFolder) + '*.*';
    if FindFirst(SearchPath, faAnyFile, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) = 0) then
        begin
          FileListBox1.Items.Add(SR.Name);
          FLocalSizes.Values[SR.Name] := IntToStr(SR.Size);
          FLocalStamps.Values[SR.Name] := IntToStr(SR.Time);
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  finally
    FileListBox1.Items.EndUpdate;
  end;
  Label4.Caption := 'No local file selected';
end;

procedure TForm6.RefreshRemoteFiles;
var
  Reply: string;
  Parts: TStringList;
  I: Integer;
  InfoParts: TStringList;
  RemoteName: string;
begin
  FileListBox2.Items.Clear;
  FRemoteSizes.Clear;
  FRemoteStamps.Clear;
  ProgressBar1.Position := 0;
  Form1.EditorProgress(ProgressBar1.Position);
  Label5.Caption := 'No display file selected';
  if not Form1.EspExchange('SL|' + SelectedFolder, 'OK|SL', 5000, Reply) then
  begin
    SetStatus('Display SD refresh failed: ' + Reply);
    Exit;
  end;
  Parts := TStringList.Create;
  try
    SplitPipeText(Reply, Parts);
    for I := 2 to Parts.Count - 1 do
      if Trim(Parts[I]) <> '' then
        FileListBox2.Items.Add(Trim(Parts[I]));
  finally
    Parts.Free;
  end;
  InfoParts := TStringList.Create;
  try
    for I := 0 to FileListBox2.Items.Count - 1 do
    begin
      RemoteName := RemoteFilePath(FileListBox2.Items[I]);
      if Form1.EspExchange('FI|' + RemoteName, 'OK|FI|', 2500, Reply) then
      begin
        SplitPipeText(Reply, InfoParts);
        if InfoParts.Count >= 5 then
        begin
          FRemoteSizes.Values[FileListBox2.Items[I]] := Trim(InfoParts[3]);
          FRemoteStamps.Values[FileListBox2.Items[I]] := Trim(InfoParts[4]);
        end;
      end;
      if FileListBox2.Items.Count > 0 then
        ProgressBar1.Position := ((I + 1) * 100) div FileListBox2.Items.Count;
        Form1.EditorProgress(ProgressBar1.Position);
      SetStatus('Reading display SD: ' + IntToStr(I + 1) + '/' +
        IntToStr(FileListBox2.Items.Count));
    end;
  finally
    InfoParts.Free;
  end;
  if FileListBox2.Items.Count > 0 then
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
  FileListBox2.Invalidate;
end;

procedure TForm6.RefreshPanels;
begin
  if FBusy then
    Exit;
  RefreshLocalFiles;
  RefreshRemoteFiles;
  SetStatus(SelectedFolder + ': local ' + IntToStr(FileListBox1.Items.Count) +
    ', display ' + IntToStr(FileListBox2.Items.Count));
  if ComboBox2.ItemIndex > 0 then
    ApplyFileSort;
end;

procedure TForm6.ComboBox1Change(Sender: TObject);
begin
  RefreshPanels;
end;

procedure TForm6.SortFileItems(AItems: TStrings; ARemote: Boolean);
var
  Files: TSdFileSortArray;
  I, J: Integer;
  Temp: TSdFileSortInfo;
  SwapNeeded: Boolean;
begin
  SetLength(Files, AItems.Count);
  for I := 0 to AItems.Count - 1 do
  begin
    Files[I].Name := AItems[I];
    if ARemote then
    begin
      Files[I].Size := CachedInfoValue(FRemoteSizes, Files[I].Name);
      Files[I].Stamp := CachedInfoValue(FRemoteStamps, Files[I].Name);
    end
    else
    begin
      Files[I].Size := CachedInfoValue(FLocalSizes, Files[I].Name);
      Files[I].Stamp := CachedInfoValue(FLocalStamps, Files[I].Name);
    end;
  end;

  for I := 0 to High(Files) - 1 do
    for J := I + 1 to High(Files) do
    begin
      case ComboBox2.ItemIndex of
        2: SwapNeeded := (Files[J].Stamp > Files[I].Stamp) or
          ((Files[J].Stamp = Files[I].Stamp) and
           (CompareText(Files[J].Name, Files[I].Name) < 0));
        3: SwapNeeded := (Files[J].Size > Files[I].Size) or
          ((Files[J].Size = Files[I].Size) and
           (CompareText(Files[J].Name, Files[I].Name) < 0));
      else
        SwapNeeded := CompareText(Files[J].Name, Files[I].Name) < 0;
      end;
      if SwapNeeded then
      begin
        Temp := Files[I];
        Files[I] := Files[J];
        Files[J] := Temp;
      end;
    end;

  AItems.BeginUpdate;
  try
    AItems.Clear;
    for I := 0 to High(Files) do
      AItems.Add(Files[I].Name);
  finally
    AItems.EndUpdate;
  end;
end;

procedure TForm6.ApplyFileSort;
begin
  if ComboBox2.ItemIndex <= 0 then
    Exit;
  SetStatus('Sorting by ' + ComboBox2.Items[ComboBox2.ItemIndex] + '...');
  SortFileItems(FileListBox1.Items, False);
  SortFileItems(FileListBox2.Items, True);
  SetStatus('Sorted by ' + ComboBox2.Items[ComboBox2.ItemIndex]);
end;

procedure TForm6.ComboBox2Change(Sender: TObject);
begin
  if FBusy then
    Exit;
  if ComboBox2.ItemIndex <= 0 then
    RefreshPanels
  else
  begin
    SetBusy(True);
    try
      ApplyFileSort;
    finally
      SetBusy(False);
    end;
  end;
end;

function TForm6.CachedInfoValue(AList: TStringList;
  const AName: string): Int64;
var
  I: Integer;
begin
  Result := -1;
  I := AList.IndexOfName(AName);
  if I >= 0 then
    Result := StrToInt64Def(AList.ValueFromIndex[I], -1);
end;

function TForm6.FileSizeText(AValue: Int64): string;
begin
  if AValue < 0 then
    Result := '?'
  else if AValue < 1024 then
    Result := IntToStr(AValue) + ' B'
  else if AValue < 1024 * 1024 then
    Result := FormatFloat('0.0', AValue / 1024) + ' KB'
  else
    Result := FormatFloat('0.0', AValue / (1024 * 1024)) + ' MB';
end;

procedure TForm6.FileListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  SizeValue: Int64;
  TextValue: string;
begin
  ListBox := TListBox(Control);
  if (Index < 0) or (Index >= ListBox.Items.Count) then
    Exit;
  if odSelected in State then
  begin
    ListBox.Canvas.Brush.Color := clHighlight;
    ListBox.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    ListBox.Canvas.Brush.Color := ListBox.Color;
    ListBox.Canvas.Font.Color := ListBox.Font.Color;
  end;
  ListBox.Canvas.FillRect(Rect);
  if Control = FileListBox1 then
    SizeValue := CachedInfoValue(FLocalSizes, ListBox.Items[Index])
  else
    SizeValue := CachedInfoValue(FRemoteSizes, ListBox.Items[Index]);
  TextValue := ListBox.Items[Index] + '  (' + FileSizeText(SizeValue) + ')';
  ListBox.Canvas.TextOut(Rect.Left + 2, Rect.Top + 1, TextValue);
end;

procedure TForm6.CollectSelectedItems(AList: TListBox; ADest: TStrings);
var
  I: Integer;
begin
  ADest.Clear;
  for I := 0 to AList.Items.Count - 1 do
    if AList.Selected[I] then
      ADest.Add(AList.Items[I]);
  if (ADest.Count = 0) and (AList.ItemIndex >= 0) then
    ADest.Add(AList.Items[AList.ItemIndex]);
end;

function TForm6.UploadFile(const ALocalFile, ARemoteFile: string): Boolean;
const
  BLOCK_SIZE = 128;
var
  Stream: TFileStream;
  Buffer: array[0..BLOCK_SIZE - 1] of Byte;
  ReadCount: Integer;
  I: Integer;
  HexText: string;
  Reply: string;
  LastPercent: Integer;
  Percent: Integer;
  BlockOffset: Int64;
begin
  Result := False;
  Stream := TFileStream.Create(ALocalFile, fmOpenRead or fmShareDenyWrite);
  try
    if not Form1.EspExchange('FW|' + ARemoteFile + '|' + IntToStr(Stream.Size),
      'OK|FW|', 5000, Reply) then
    begin
      SetStatus('Upload start failed: ' + Reply);
      Exit;
    end;
    LastPercent := -1;
    repeat
      BlockOffset := Stream.Position;
      ReadCount := Stream.Read(Buffer, SizeOf(Buffer));
      if ReadCount <= 0 then
        Break;
      HexText := '';
      for I := 0 to ReadCount - 1 do
        HexText := HexText + IntToHex(Buffer[I], 2);
      if not Form1.EspExchange('FDO|' + IntToStr(BlockOffset) + '|' + HexText,
        'OK|FDO|', 5000, Reply) then
      begin
        SetStatus('Upload block failed: ' + Reply);
        Exit;
      end;
      if Stream.Size > 0 then
        Percent := (Stream.Position * 100) div Stream.Size
      else
        Percent := 100;
      ProgressBar1.Position := Percent;
      Form1.EditorProgress(ProgressBar1.Position);
      if Percent <> LastPercent then
      begin
        LastPercent := Percent;
        SetStatus('Uploading ' + ExtractFileName(ALocalFile) + ': ' +
          IntToStr(Percent) + '%');
      end;
      Application.ProcessMessages;
    until Stream.Position >= Stream.Size;
    if not Form1.EspExchange('FE', 'OK|FE|', 8000, Reply) then
    begin
      SetStatus('Upload finish failed: ' + Reply);
      Exit;
    end;
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
    Result := True;
  finally
    Stream.Free;
  end;
end;

function TForm6.DownloadFile(const ARemoteFile, ALocalFile: string): Boolean;
var
  Stream: TFileStream;
  Reply: string;
  Parts: TStringList;
  TotalSize: Int64;
  Offset: Int64;
  HexText: string;
  I: Integer;
  B: Byte;
  LastPercent: Integer;
  Percent: Integer;
  DestDir: string;
  TempFile: string;
  SavedStream: TFileStream;
  SaveError: DWORD;
begin
  Result := False;
  if not Form1.EspExchange('FS|' + ARemoteFile, 'OK|FS|', 3000, Reply) then
  begin
    SetStatus('Remote file not found: ' + Reply);
    Exit;
  end;
  TotalSize := StrToInt64Def(Copy(Reply, LastDelimiter('|', Reply) + 1, MaxInt), -1);
  if TotalSize < 0 then
  begin
    SetStatus('Bad remote file size');
    Exit;
  end;
  DestDir := ExtractFileDir(ExpandFileName(ALocalFile));
  if not DirectoryExists(DestDir) then
    if not ForceDirectories(DestDir) then
    begin
      SetStatus('Cannot create local folder: ' + DestDir);
      Exit;
    end;
  if not DirectoryExists(DestDir) then
  begin
    SetStatus('Local folder not found: ' + DestDir);
    Exit;
  end;

  TempFile := ExpandFileName(ALocalFile) + '.part';
  if FileExists(TempFile) then
    SysUtils.DeleteFile(TempFile);
  Stream := nil;
  Parts := TStringList.Create;
  try
    Stream := TFileStream.Create(TempFile, fmCreate);
    Offset := 0;
    LastPercent := -1;
    while Offset < TotalSize do
    begin
      if not Form1.EspExchange('FR|' + ARemoteFile + '|' + IntToStr(Offset) + '|64',
        'OK|FR|', 5000, Reply) then
      begin
        SetStatus('Download block failed: ' + Reply);
        Exit;
      end;
      SplitPipeText(Reply, Parts);
      if Parts.Count < 6 then
      begin
        SetStatus('Bad download block');
        Exit;
      end;
      HexText := Trim(Parts[5]);
      I := 1;
      while I < Length(HexText) do
      begin
        B := HexByte(HexText, I);
        Stream.WriteBuffer(B, 1);
        Inc(I, 2);
      end;
      Inc(Offset, Length(HexText) div 2);
      if TotalSize > 0 then
        Percent := (Offset * 100) div TotalSize
      else
        Percent := 100;
      ProgressBar1.Position := Percent;
      Form1.EditorProgress(ProgressBar1.Position);
      if Percent <> LastPercent then
      begin
        LastPercent := Percent;
        SetStatus('Downloading ' + ExtractFileName(ALocalFile) + ': ' +
          IntToStr(Percent) + '%');
      end;
      if HexText = '' then
        Break;
    end;
    Result := Offset = TotalSize;
    if not Result then
      SetStatus('Download incomplete');
  finally
    Parts.Free;
    Stream.Free;
    if (not Result) and FileExists(TempFile) then
      SysUtils.DeleteFile(TempFile);
  end;
  if Result then
  begin
    if not MoveFileEx(PChar(TempFile), PChar(ExpandFileName(ALocalFile)),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
    begin
      SaveError := GetLastError;
      Result := False;
      SetStatus('Cannot save local file (' + IntToStr(SaveError) + '): ' +
        SysErrorMessage(SaveError));
      if FileExists(TempFile) then
        SysUtils.DeleteFile(TempFile);
    end;
  end;
  if Result then
  begin
    SavedStream := nil;
    try
      SavedStream := TFileStream.Create(ExpandFileName(ALocalFile),
        fmOpenRead or fmShareDenyNone);
      Result := SavedStream.Size = TotalSize;
      if not Result then
        SetStatus('Saved file size mismatch: ' + IntToStr(SavedStream.Size) +
          ' of ' + IntToStr(TotalSize) + ' bytes');
    finally
      SavedStream.Free;
    end;
  end;
  if Result then
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
end;

procedure TForm6.Button1Click(Sender: TObject);
var
  Queue: TStringList;
  I: Integer;
  LocalName: string;
  RemoteName: string;
  DoneCount: Integer;
begin
  if FBusy then
    Exit;
  Queue := TStringList.Create;
  CollectSelectedItems(FileListBox1, Queue);
  if Queue.Count = 0 then
  begin
    Queue.Free;
    Exit;
  end;
  DoneCount := 0;
  SetBusy(True);
  try
    for I := 0 to Queue.Count - 1 do
    begin
      LocalName := IncludeTrailingPathDelimiter(LocalFolder) + Queue[I];
      RemoteName := RemoteFilePath(Queue[I]);
      SetStatus('Upload queue ' + IntToStr(I + 1) + '/' +
        IntToStr(Queue.Count) + ': ' + Queue[I]);
      try
        if FileExists(LocalName) and UploadFile(LocalName, RemoteName) then
          Inc(DoneCount);
      except
        on E: Exception do
          SetStatus('Upload failed: ' + Queue[I] + ' - ' + E.Message);
      end;
      ProgressBar1.Position := ((I + 1) * 100) div Queue.Count;
      Form1.EditorProgress(ProgressBar1.Position);
    end;
    SetStatus('Upload queue completed: ' + IntToStr(DoneCount) + '/' +
      IntToStr(Queue.Count));
  finally
    SetBusy(False);
    RefreshRemoteFiles;
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
    SetStatus('Upload queue completed: ' + IntToStr(DoneCount) + '/' +
      IntToStr(Queue.Count));
    Queue.Free;
  end;
end;

procedure TForm6.Button2Click(Sender: TObject);
var
  Queue: TStringList;
  I: Integer;
  SelectedName: string;
  RemoteName: string;
  LocalName: string;
  DoneCount: Integer;
begin
  if FBusy then
    Exit;
  Queue := TStringList.Create;
  CollectSelectedItems(FileListBox2, Queue);
  if Queue.Count = 0 then
  begin
    Queue.Free;
    Exit;
  end;
  DoneCount := 0;
  SetBusy(True);
  try
    for I := 0 to Queue.Count - 1 do
    begin
      SelectedName := Queue[I];
      RemoteName := RemoteFilePath(SelectedName);
      LocalName := IncludeTrailingPathDelimiter(LocalFolder) + SelectedName;
      if FileExists(LocalName) and
        (MessageDlg('Replace local file ' + SelectedName + '?',
          mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
        Continue;
      SetStatus('Download queue ' + IntToStr(I + 1) + '/' +
        IntToStr(Queue.Count) + ': ' + SelectedName);
      try
        if DownloadFile(RemoteName, LocalName) then
          Inc(DoneCount);
      except
        on E: Exception do
          SetStatus('Download failed: ' + SelectedName + ' - ' + E.Message);
      end;
      ProgressBar1.Position := ((I + 1) * 100) div Queue.Count;
      Form1.EditorProgress(ProgressBar1.Position);
    end;
    SetStatus('Download queue completed: ' + IntToStr(DoneCount) + '/' +
      IntToStr(Queue.Count));
  finally
    SetBusy(False);
    RefreshLocalFiles;
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
    Queue.Free;
  end;
end;

procedure TForm6.Button3Click(Sender: TObject);
var
  Queue: TStringList;
  I: Integer;
  RemoteName: string;
  LocalName: string;
  Reply: string;
  SyncLocal: Boolean;
  Answer: Integer;
  DoneCount: Integer;
begin
  if FBusy then
    Exit;
  Queue := TStringList.Create;
  CollectSelectedItems(FileListBox2, Queue);
  if Queue.Count = 0 then
  begin
    Queue.Free;
    Exit;
  end;
  if MessageDlg('Remove ' + IntToStr(Queue.Count) +
    ' selected file(s) from display SD?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
  begin
    Queue.Free;
    Exit;
  end;
  Answer := MessageDlg('Also remove matching file(s) from the virtual SD ' +
    'to keep both folders synchronized?', mtConfirmation,
    [mbYes, mbNo, mbCancel], 0);
  if Answer = mrCancel then
  begin
    Queue.Free;
    Exit;
  end;
  SyncLocal := Answer = mrYes;
  DoneCount := 0;
  SetBusy(True);
  try
    for I := 0 to Queue.Count - 1 do
    begin
      RemoteName := RemoteFilePath(Queue[I]);
      SetStatus('Delete queue ' + IntToStr(I + 1) + '/' +
        IntToStr(Queue.Count) + ': ' + Queue[I]);
      try
        if Form1.EspExchange('RM|' + RemoteName, 'OK|RM|', 5000, Reply) then
        begin
          Inc(DoneCount);
          if SyncLocal then
          begin
            LocalName := IncludeTrailingPathDelimiter(LocalFolder) + Queue[I];
            if FileExists(LocalName) then
              SysUtils.DeleteFile(LocalName);
          end;
        end
        else
          SetStatus('Remove failed: ' + Queue[I] + ' - ' + Reply);
      except
        on E: Exception do
          SetStatus('Remove failed: ' + Queue[I] + ' - ' + E.Message);
      end;
      ProgressBar1.Position := ((I + 1) * 100) div Queue.Count;
      Form1.EditorProgress(ProgressBar1.Position);
    end;
    SetStatus('Delete queue completed: ' + IntToStr(DoneCount) + '/' +
      IntToStr(Queue.Count));
  finally
    SetBusy(False);
    RefreshLocalFiles;
    RefreshRemoteFiles;
    ProgressBar1.Position := 100;
    Form1.EditorProgress(ProgressBar1.Position);
    SetStatus('Delete queue completed: ' + IntToStr(DoneCount) + '/' +
      IntToStr(Queue.Count));
    Queue.Free;
  end;
end;

procedure TForm6.Button4Click(Sender: TObject);
begin
  if FBusy then
    Exit;
  RefreshRemoteFiles;
  SetStatus('Display SD refreshed: ' + SelectedFolder + ', ' +
    IntToStr(FileListBox2.Items.Count) + ' files');
end;

procedure TForm6.FileListBox1Click(Sender: TObject);
var
  FileName: string;
  SR: TSearchRec;
  Data: TWin32FileAttributeData;
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;
  CreatedText: string;
begin
  Label4.Caption := 'No local file selected';
  if FileListBox1.ItemIndex < 0 then
    Exit;
  FileName := IncludeTrailingPathDelimiter(LocalFolder) +
    FileListBox1.Items[FileListBox1.ItemIndex];
  if not FileExists(FileName) then
    Exit;
  CreatedText := 'unknown date';
  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @Data) and
    FileTimeToLocalFileTime(Data.ftCreationTime, LocalFileTime) and
    FileTimeToSystemTime(LocalFileTime, SystemTime) then
    CreatedText := FormatDateTime('dd.mm.yyyy hh:nn:ss',
      SystemTimeToDateTime(SystemTime));
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  try
    Label4.Caption := IntToStr(SR.Size) + ' bytes | created ' + CreatedText;
  finally
    FindClose(SR);
  end;
end;

procedure TForm6.FileListBox2Click(Sender: TObject);
var
  RemoteName: string;
  Reply: string;
  Parts: TStringList;
  SizeText: string;
  Epoch: Int64;
  DateText: string;
begin
  Label5.Caption := 'No display file selected';
  if FileListBox2.ItemIndex < 0 then
    Exit;
  RemoteName := RemoteFilePath(FileListBox2.Items[FileListBox2.ItemIndex]);
  Parts := TStringList.Create;
  try
    if Form1.EspExchange('FI|' + RemoteName, 'OK|FI|', 2500, Reply) then
    begin
      SplitPipeText(Reply, Parts);
      if Parts.Count >= 5 then
      begin
        SizeText := Trim(Parts[3]);
        Epoch := StrToInt64Def(Trim(Parts[4]), 0);
        if Epoch > 0 then
          DateText := FormatDateTime('dd.mm.yyyy hh:nn:ss',
            EncodeDate(1970, 1, 1) + Epoch / 86400)
        else
          DateText := 'unknown date';
        Label5.Caption := SizeText + ' bytes | modified ' + DateText;
        Exit;
      end;
    end;

    if Form1.EspExchange('FS|' + RemoteName, 'OK|FS|', 2500, Reply) then
    begin
      SizeText := Copy(Reply, LastDelimiter('|', Reply) + 1, MaxInt);
      Label5.Caption := Trim(SizeText) + ' bytes | date needs firmware update';
    end
    else
      Label5.Caption := 'File information unavailable';
  finally
    Parts.Free;
  end;
end;

end.
