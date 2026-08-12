unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls, Spin, ColorGrd,
  jpeg, WinSock, IniFiles, Clipbrd;

type
  TIntegerArray = array of Integer;
  TByteArray = array of Byte;
  TColorField = (cfLine, cfText, cfBack, cfLcdBack);

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
    Name: string;
    FileName: string;
    Bitmaps: TByteArray;
    Glyphs: TGfxGlyphArray;
    First: Integer;
    Last: Integer;
    YAdvance: Integer;
    Loaded: Boolean;
  end;

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Bevel1: TBevel;
    ComboBox1: TComboBox;
    Button2: TButton;
    StaticText1: TStaticText;
    ColorGrid1: TColorGrid;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    StaticText2: TStaticText;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinEdit2: TSpinEdit;
    Label5: TLabel;
    SpinEdit3: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    SpinEdit4: TSpinEdit;
    Image1: TImage;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    SpinEdit5: TSpinEdit;
    Label14: TLabel;
    Shape2: TShape;
    Label15: TLabel;
    Label16: TLabel;
    SpinEdit6: TSpinEdit;
    StringGrid1: TStringGrid;
    Button3: TButton;
    Shape3: TShape;
    Label18: TLabel;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Shape4: TShape;
    Button1: TButton;
    Label20: TLabel;
    Image2: TImage;
    Image3: TImage;
    Label21: TLabel;
    Image4: TImage;
    Label10: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    TrackBar1: TTrackBar;
    ListBox1: TListBox;
    Button8: TButton;
    Button9: TButton;
    Shape1: TShape;
    Shape5: TShape;
    Button10: TButton;
    Button11: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit2: TEdit;
    Edit3: TEdit;
    Button12: TButton;
    Button13: TButton;
    StringGrid2: TStringGrid;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Label8: TLabel;
    Label9: TLabel;
    Label19: TLabel;
    Shape9: TShape;
    Label25: TLabel;
    Label26: TLabel;
    Shape10: TShape;
    CheckBox4: TCheckBox;
    ComboBox2: TComboBox;
    Label28: TLabel;
    ComboBox3: TComboBox;
    Label27: TLabel;
    Label29: TLabel;
    Edit4: TEdit;
    Label17: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button9Click(Sender: TObject);
    procedure Button8MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FPreview: TPaintBox;
    FPort: THandle;
    FSelectedRow: Integer;
    FDragging: Boolean;
    FResizing: Boolean;
    FDragStart: TPoint;
    FDragRect: TRect;
    FUdpSocket: TSocket;
    FPortMonitor: TTimer;
    FPortRxText: AnsiString;
    FLoadingInputs: Boolean;
    FSelectingRow: Boolean;
    FLcdBgColor: TColor;
    FLineTrack: TTrackBar;
    FLineTrackLabel: TLabel;
    FFontList: TListBox;
    FFontListLabel: TLabel;
    FClearLcdButton: TButton;
    FFontFiles: TStringList;
    FFontCache: TList;
    FActiveFontId: Integer;
    FActiveColorField: TColorField;
    FDefaultLineRgb: string;
    FDefaultFgRgb: string;
    FDefaultBgRgb: string;
    FDefaultLcdBgRgb: string;
    FNoColorLabels: array[TColorField] of TLabel;
    procedure InitGrid;
    procedure InitControls;
    procedure AddPaletteHandlers;
    procedure LoadEspFontList;
    procedure ApplyPreviewFont(AFontId: Integer);
    function GetPreviewFont(AFontId: Integer): TGfxFont;
    function LoadGfxFontFile(AFont: TGfxFont): Boolean;
    function GfxGlyphCode(AChar: AnsiChar): Integer;
    procedure GfxTextBounds(AFont: TGfxFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
    procedure DrawGfxText(AFont: TGfxFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
    function DrawGfxTextBox(const AText: string; const ARect: TRect; AHAlign, AVAlign: string; AColor: TColor): Boolean;
    procedure DrawAlignedPreviewText(const AText: string; const ARect: TRect; AHAlign, AVAlign: string);
    function SelectedHAlign: string;
    function SelectedVAlign: string;
    procedure SetAlignButtons(const AHAlign, AVAlign: string);
    function Rgb565Text(AColor: TColor): string;
    function Rgb565ToColor(const AText: string; ADefault: TColor): TColor;
    function IsNoColorRgb(const AText: string): Boolean;
    function ScriptFromRow(ARow: Integer): string;
    function SdRootPath: string;
    function SdCommandPathFromLocalPath(const AFileName: string): string;
    function LocalImagePathFromCommandPath(const APath: string): string;
    procedure OpenImageAreaEditor(ARow: Integer);
    procedure UpdateImageRowSize(ARow: Integer);
    function WaitSerialReply(const APrefix: string; ATimeoutMs: DWORD; var ALine: string): Boolean;
    function SendFileToEspSd(const ALocalFileName: string; var ASdPath: string): Boolean;
    function UploadImageRowToEsp(ARow: Integer): Boolean;
    function RowRect(ARow: Integer; var ARect: TRect): Boolean;
    procedure AddElement(const AKind: string);
    procedure AddScriptLine(const ALine: string);
    procedure DuplicateSelectedRow;
    procedure UpdateRowFromInputs(ARow: Integer);
    procedure LoadInputsFromRow(ARow: Integer);
    procedure UpdateDefaultColorsFromRow(ARow: Integer);
    procedure UpdateEditorControlStates;
    procedure SelectRow(ARow: Integer);
    procedure DeleteSelectedRow;
    procedure RepaintPreview;
    function DisplayPoint(AX, AY: Integer): TPoint;
    function HitRow(AX, AY: Integer; var AResize: Boolean): Integer;
    procedure SetRowRect(ARow: Integer; const ARect: TRect);
    function ConfigFilePath: string;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure SetActiveColorField(AField: TColorField);
    procedure RefreshColorFieldShapes;
    procedure EnsureNoColorLabels;
    procedure ApplyPaletteColorToActiveField(const ARgb: string; AColor: TColor);
    procedure ColorFieldMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SerialEnabled: Boolean;
    function UdpEnabled: Boolean;
    function EnsureUdpSocket(ABroadcast: Boolean): Boolean;
    procedure CloseUdpSocket;
    function UdpExchangeLine(const ALine, AHost: string; ABroadcast: Boolean; var AReply: string): Boolean;
    procedure PollUdpInput;
    function SendUdpLine(const ALine: string): Boolean;
    procedure SendSerialLine(const ALine: string);
    procedure SendLine(const ALine: string);
    function ScriptFilePath(const AFileName: string): string;
    procedure SaveDesignToFile(const AFileName: string);
    procedure LoadDesignFromFile(const AFileName: string);
    procedure SetPortStateColor(AColor: TColor);
    procedure SetUdpStateColor(AColor: TColor);
    function PortAlive: Boolean;
    procedure PollPortInput;
    procedure HandleRxLine(const ALine: string);
    procedure ApplyRts;
    procedure OpenClosePort;
    procedure ClosePort(AErrorState: Boolean = False);
    procedure PreviewPaint(Sender: TObject);
    procedure PreviewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PreviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PreviewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure PaletteGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PaletteGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ColorGridClick(Sender: TObject);
    procedure InputSpinChange(Sender: TObject);
    procedure TextEditChange(Sender: TObject);
    procedure RtsCheckClick(Sender: TObject);
    procedure UdpCheckClick(Sender: TObject);
    procedure LineTrackChange(Sender: TObject);

    procedure FontListClick(Sender: TObject);
    procedure AlignComboChange(Sender: TObject);
    procedure DoubleButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure DemoButtonClick(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure UploadButtonClick(Sender: TObject);
    procedure Shape4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowIpButtonClick(Sender: TObject);
    procedure PictureLoadButtonClick(Sender: TObject);
    procedure PicturePasteButtonClick(Sender: TObject);
    procedure PortMonitorTimer(Sender: TObject);
    procedure PaletteElementClick(Sender: TObject);
    procedure PaletteShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
  end;

var
  Form1: TForm1;

implementation

uses
  Unit2, Unit3;

{$R *.dfm}

//============================================================
//
const
  COL_SEL = 0;
  COL_CMD = 1;
  COL_ID = 2;
  COL_X = 3;
  COL_Y = 4;
  COL_W = 5;
  COL_H = 6;
  COL_TEXT = 7;
  COL_C1 = 8;
  COL_C2 = 9;
  COL_EXTRA = 10;
  COL_LINE = 11;
  COL_FONT = 12;
  COL_HALIGN = 13;
  COL_VALIGN = 14;
  COL_SRCX = 15;
  COL_SRCY = 16;
  COL_SRCW = 17;
  COL_SRCH = 18;
  PALETTE_COLS = 8;
  PALETTE_ROWS = 4;
  PALETTE_CELL_SIZE = 32;
  GFX_PREVIEW_Y_CORRECTION = -2;
  LEGACY_FONT_RUS_DIR = 'C:\Users\basachka\Documents\PlatformIO\Projects\Nextion_esp32\.pio\libdeps\esp32dev_ota\AdafruitGFXRusFonts\FontsRus';

  FONT_FILE_MAP: array[1..9] of string = (
    'FreeSans6.h',
    'FreeSans8.h',
    'FreeSans10.h',
    'FreeSans12.h',
    'FreeMono12.h',
    'FreeSansBold12.h',
    'FreeSansBold14.h',
    'FreeSansBold16.h',
    'FreeSansBold18.h'
  );
//======================================================
// Преобразует имя COM-порта в формат WinAPI для открытия порта.
function PortWinApiName(const APortName: string): string;
begin
  if Pos('\\.\', APortName) = 1 then
    Result := APortName
  else
    Result := '\\.\' + APortName;
end;
//======================================================
// Корректно определяет путь к папке размещения шрифтов, которые отобразятся на виртуальном дисплее.
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

//======================================================
// Возвращает цвет ячейки встроенной палитры по её индексу.
function PaletteCellColor(AIndex: Integer): TColor;
const
  COLORS: array[0..30] of TColor = (
    clBlack, $00000080, clGreen, $00008080,
    clNavy, clPurple, $00808000, clSilver,
    clGray, clRed, clLime, clYellow,
    clBlue, clFuchsia, clAqua, clWhite,
    $00004080, $000080FF, $0000C0FF, $004080FF,
    $00804000, $008080FF, $00008040, $0040C000,
    $00C08000, $00FFC080, $008000FF, $00FF0080,
    $00808040, $00404040, $00D8E9EC
  );
begin
  if (AIndex >= Low(COLORS)) and (AIndex <= High(COLORS)) then
    Result := COLORS[AIndex]
  else
    Result := clBtnFace;
end;

//======================================================
// Преобразует цвет Windows в текстовое RGB565 значение для ESP.
function ColorToRgb565Text(AColor: TColor): string;
var
  C: TColor;
  R: Integer;
  G: Integer;
  B: Integer;
  V: Integer;
begin
  C := ColorToRGB(AColor);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  V := ((R * 31 div 255) shl 11) or ((G * 63 div 255) shl 5) or (B * 31 div 255);
  Result := '0x' + IntToHex(V, 4);
end;

//======================================================
// Возвращает RGB565-текст цвета выбранной ячейки палитры.
function PaletteCellRgb565(AIndex: Integer): string;
begin
  Result := ColorToRgb565Text(PaletteCellColor(AIndex));
end;

//======================================================
// Инициализирует форму, рабочие структуры, сетевой стек и стартовое состояние редактора.
procedure TForm1.FormCreate(Sender: TObject);
var
  WsaData: TWSAData;
begin
  WSAStartup($0202, WsaData);
  FPort := INVALID_HANDLE_VALUE;
  FUdpSocket := INVALID_SOCKET;
  FPortMonitor := nil;
  FPortRxText := '';
  FLoadingInputs := False;
  FLcdBgColor := clBlack;
  FFontFiles := TStringList.Create;
  FFontCache := TList.Create;
  FActiveFontId := 2;
  FLineTrack := nil;
  FLineTrackLabel := nil;
  FFontList := nil;
  FFontListLabel := nil;
  FSelectedRow := 1;
  FDragging := False;
  FResizing := False;
  FActiveColorField := cfText;
  FDefaultLineRgb := '0xFFFF';
  FDefaultFgRgb := '0xFFFF';
  FDefaultBgRgb := '0x0001';
  FDefaultLcdBgRgb := Rgb565Text(FLcdBgColor);
  Caption := 'NXT GUI Maker';
  InitGrid;
  InitControls;
  AddPaletteHandlers;
  RepaintPreview;
end;

//======================================================
// Сохраняет настройки и освобождает ресурсы при закрытии приложения.
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  SaveSettings;
  ClosePort;
  CloseUdpSocket;
  for I := 0 to FFontCache.Count - 1 do
    TGfxFont(FFontCache[I]).Free;
  FFontCache.Free;
  FFontFiles.Free;
  WSACleanup;
end;

//======================================================
// Настраивает таблицу команд и её колонки.
procedure TForm1.InitGrid;
begin
  StringGrid1.ColCount := 19;
  StringGrid1.RowCount := 2;
  StringGrid1.FixedCols := 1;
  StringGrid1.FixedRows := 1;
  StringGrid1.Options := StringGrid1.Options + [goEditing] - [goRangeSelect, goRowSelect];
  StringGrid1.DefaultDrawing := False;
  StringGrid1.ScrollBars := ssBoth;
  StringGrid1.Cells[COL_SEL, 0] := '';
  StringGrid1.Cells[COL_CMD, 0] := 'cmd';
  StringGrid1.Cells[COL_ID, 0] := 'id';
  StringGrid1.Cells[COL_X, 0] := 'x';
  StringGrid1.Cells[COL_Y, 0] := 'y';
  StringGrid1.Cells[COL_W, 0] := 'w';
  StringGrid1.Cells[COL_H, 0] := 'h';
  StringGrid1.Cells[COL_TEXT, 0] := 'text/name';
  StringGrid1.Cells[COL_C1, 0] := 'color1';
  StringGrid1.Cells[COL_C2, 0] := 'color2';
  StringGrid1.Cells[COL_EXTRA, 0] := 'extra';
  StringGrid1.Cells[COL_LINE, 0] := 'line';
  StringGrid1.Cells[COL_FONT, 0] := 'font';
  StringGrid1.Cells[COL_HALIGN, 0] := 'ha';
  StringGrid1.Cells[COL_VALIGN, 0] := 'va';
  StringGrid1.Cells[COL_SRCX, 0] := 'sx';
  StringGrid1.Cells[COL_SRCY, 0] := 'sy';
  StringGrid1.Cells[COL_SRCW, 0] := 'sw';
  StringGrid1.Cells[COL_SRCH, 0] := 'sh';
  StringGrid1.ColWidths[COL_SEL] := 18;
  StringGrid1.ColWidths[COL_CMD] := 44;
  StringGrid1.ColWidths[COL_ID] := 28;
  StringGrid1.ColWidths[COL_X] := 38;
  StringGrid1.ColWidths[COL_Y] := 38;
  StringGrid1.ColWidths[COL_W] := 38;
  StringGrid1.ColWidths[COL_H] := 38;
  StringGrid1.ColWidths[COL_TEXT] := 92;
  StringGrid1.ColWidths[COL_C1] := 68;
  StringGrid1.ColWidths[COL_C2] := 68;
  StringGrid1.ColWidths[COL_EXTRA] := 58;
  StringGrid1.ColWidths[COL_LINE] := 36;
  StringGrid1.ColWidths[COL_FONT] := 38;
  StringGrid1.ColWidths[COL_HALIGN] := 28;
  StringGrid1.ColWidths[COL_VALIGN] := 28;
  StringGrid1.ColWidths[COL_SRCX] := 38;
  StringGrid1.ColWidths[COL_SRCY] := 38;
  StringGrid1.ColWidths[COL_SRCW] := 38;
  StringGrid1.ColWidths[COL_SRCH] := 38;
  StringGrid1.OnSelectCell := GridSelectCell;
  StringGrid1.OnMouseDown := GridMouseDown;
  StringGrid1.OnDrawCell := GridDrawCell;
  StringGrid1.OnSetEditText := GridSetEditText;
end;

//======================================================
// Создаёт и настраивает дополнительные элементы управления редактора.
procedure TForm1.InitControls;
var
  I: Integer;
begin
  FPreview := TPaintBox.Create(Self);
  FPreview.Parent := Self;
  FPreview.Left := Bevel1.Left;
  FPreview.Top := Bevel1.Top;
  FPreview.Width := Bevel1.Width;
  FPreview.Height := Bevel1.Height;
  FPreview.OnPaint := PreviewPaint;
  FPreview.OnMouseDown := PreviewMouseDown;
  FPreview.OnMouseMove := PreviewMouseMove;
  FPreview.OnMouseUp := PreviewMouseUp;
  Bevel1.Visible := False;

  for I := 1 to 20 do
    ComboBox1.Items.Add('COM' + IntToStr(I));
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('COM4');
  if ComboBox1.ItemIndex < 0 then
    ComboBox1.ItemIndex := 0;

  SpinEdit1.MaxValue := 480;
  SpinEdit2.MaxValue := 320;
  SpinEdit3.MaxValue := 480;
  SpinEdit4.MaxValue := 320;
  SpinEdit5.MaxValue := 80;
  SpinEdit6.MaxValue := 100;
  SpinEdit5.OnChange := InputSpinChange;
  SpinEdit6.OnChange := InputSpinChange;
  if Edit4.Text = 'Edit4' then
    Edit4.Text := 'Text';
  Edit4.OnChange := TextEditChange;

  Shape4.OnMouseDown := Shape4MouseDown;
  Button2.OnClick := SendButtonClick;
  Button5.OnClick := DoubleButtonClick;
  Button4.OnClick := DeleteButtonClick;
  Button6.OnClick := ClearButtonClick;
  Button10.OnClick := SaveButtonClick;
  Button11.OnClick := LoadButtonClick;
  Button7.OnClick := DemoButtonClick;
  Button1.OnClick := UploadButtonClick;
  Button3.OnClick := PictureLoadButtonClick;
  if Assigned(Button13) then
    Button13.OnClick := PicturePasteButtonClick;
  Button12.OnClick := ShowIpButtonClick;
  Shape6.OnMouseDown := ColorFieldMouseDown;
  Shape7.OnMouseDown := ColorFieldMouseDown;
  Shape8.OnMouseDown := ColorFieldMouseDown;
  Shape9.OnMouseDown := ColorFieldMouseDown;
  EnsureNoColorLabels;
  RefreshColorFieldShapes;
  ColorGrid1.Visible := False;
  ColorGrid1.OnClick := ColorGridClick;
  if Assigned(StringGrid2) then
  begin
    StringGrid2.ColCount := PALETTE_COLS;
    StringGrid2.RowCount := PALETTE_ROWS;
    StringGrid2.FixedCols := 0;
    StringGrid2.FixedRows := 0;
    StringGrid2.DefaultColWidth := PALETTE_CELL_SIZE;
    StringGrid2.DefaultRowHeight := PALETTE_CELL_SIZE;
    StringGrid2.ClientWidth := PALETTE_COLS * PALETTE_CELL_SIZE +
      (PALETTE_COLS + 1) * StringGrid2.GridLineWidth;
    StringGrid2.ClientHeight := PALETTE_ROWS * PALETTE_CELL_SIZE +
      (PALETTE_ROWS + 1) * StringGrid2.GridLineWidth;
    StringGrid2.DefaultDrawing := False;
    StringGrid2.ScrollBars := ssNone;
    StringGrid2.OnDrawCell := PaletteGridDrawCell;
    StringGrid2.OnMouseDown := PaletteGridMouseDown;
  end;
  CheckBox1.OnClick := RtsCheckClick;
  CheckBox3.OnClick := UdpCheckClick;

  if FindComponent('Button8') is TButton then
    FClearLcdButton := TButton(FindComponent('Button8'))
  else
  begin
    FClearLcdButton := TButton.Create(Self);
    FClearLcdButton.Parent := Self;
    FClearLcdButton.Left := Button1.Left + Button1.Width + 8;
    FClearLcdButton.Top := Button1.Top;
    FClearLcdButton.Width := 82;
    FClearLcdButton.Height := Button1.Height;
    FClearLcdButton.Caption := 'Clear LCD';
  end;
  FClearLcdButton.OnClick := nil;
  FClearLcdButton.OnMouseDown := Button8MouseDown;

  SpinEdit1.OnChange := InputSpinChange;
  SpinEdit2.OnChange := InputSpinChange;
  SpinEdit3.OnChange := InputSpinChange;
  SpinEdit4.OnChange := InputSpinChange;
  if FindComponent('TrackBar1') is TTrackBar then
    FLineTrack := TTrackBar(FindComponent('TrackBar1'))
  else
  begin
    FLineTrackLabel := TLabel.Create(Self);
    FLineTrackLabel.Parent := Self;
    FLineTrackLabel.Left := 848;
    FLineTrackLabel.Top := 240;
    FLineTrackLabel.Caption := 'Line';

    FLineTrack := TTrackBar.Create(Self);
    FLineTrack.Parent := Self;
    FLineTrack.Left := 840;
    FLineTrack.Top := 252;
    FLineTrack.Width := 80;
    FLineTrack.Height := 34;
  end;
  FLineTrack.Min := 1;
  FLineTrack.Max := 4;
  FLineTrack.Frequency := 1;
  FLineTrack.Position := 1;
  FLineTrack.OnChange := LineTrackChange;

  if FindComponent('ListBox1') is TListBox then
    FFontList := TListBox(FindComponent('ListBox1'))
  else
  begin
    FFontListLabel := TLabel.Create(Self);
    FFontListLabel.Parent := Self;
    FFontListLabel.Left := 840;
    FFontListLabel.Top := 300;
    FFontListLabel.Caption := 'ESP font';

    FFontList := TListBox.Create(Self);
    FFontList.Parent := Self;
    FFontList.Left := 840;
    FFontList.Top := 316;
    FFontList.Width := 80;
    FFontList.Height := 96;
  end;
  LoadEspFontList;
  FFontList.OnClick := FontListClick;
  ComboBox2.Style := csDropDownList;
  ComboBox3.Style := csDropDownList;
  ComboBox2.ItemIndex := 1;
  ComboBox3.ItemIndex := 1;
  ComboBox2.OnChange := AlignComboChange;
  ComboBox3.OnChange := AlignComboChange;
  SetPortStateColor(clGreen);
  SetUdpStateColor(clGreen);

  FPortMonitor := TTimer.Create(Self);
  FPortMonitor.Interval := 200;
  FPortMonitor.Enabled := False;
  FPortMonitor.OnTimer := PortMonitorTimer;
  LoadSettings;
end;

//======================================================
// Привязывает элементы палитры компонентов к обработчикам добавления.
procedure TForm1.AddPaletteHandlers;
begin
  StaticText1.Hint := 'TX';
  StaticText2.Hint := 'BT';
  Image1.Hint := 'SW';
  Image2.Hint := 'TR';
  Image3.Hint := 'PB';
  Shape2.Hint := 'CC';
  Shape3.Hint := 'BX';
  Shape10.Hint := 'RR';
  Label10.Hint := 'BT';
  Label11.Hint := 'TR';
  Label12.Hint := 'JPG';
  Label13.Hint := 'BX';
  Label15.Hint := 'CC';
  Label20.Hint := 'SW';
  Label21.Hint := 'PB';
  Label22.Hint := 'TX';
  Label26.Hint := 'RR';

  StaticText1.OnClick := PaletteElementClick;
  StaticText2.OnClick := PaletteElementClick;
  Image1.OnClick := PaletteElementClick;
  Image2.OnClick := PaletteElementClick;
  Image3.OnClick := PaletteElementClick;
  Shape2.OnMouseDown := PaletteShapeMouseDown;
  Shape3.OnMouseDown := PaletteShapeMouseDown;
  Shape10.OnMouseDown := PaletteShapeMouseDown;
  Label10.OnClick := PaletteElementClick;
  Label11.OnClick := PaletteElementClick;
  Label12.OnClick := PaletteElementClick;
  Label13.OnClick := PaletteElementClick;
  Label15.OnClick := PaletteElementClick;
  Label20.OnClick := PaletteElementClick;
  Label21.OnClick := PaletteElementClick;
  Label22.OnClick := PaletteElementClick;
  Label26.OnClick := PaletteElementClick;
end;

//======================================================
// Преобразует цвет VCL в строку RGB565 для команд дисплея.
function TForm1.Rgb565Text(AColor: TColor): string;
var
  C: TColor;
  R: Integer;
  G: Integer;
  B: Integer;
  V: Integer;
begin
  C := ColorToRGB(AColor);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  V := ((R * 31 div 255) shl 11) or ((G * 63 div 255) shl 5) or (B * 31 div 255);
  Result := '0x' + IntToHex(V, 4);
end;

//======================================================
// Проверяет, обозначает ли RGB565-строка отсутствие цвета.
function TForm1.IsNoColorRgb(const AText: string): Boolean;
begin
  Result := UpperCase(Trim(AText)) = '0X0001';
end;

//======================================================
// Преобразует RGB565-строку обратно в цвет VCL.
function TForm1.Rgb565ToColor(const AText: string; ADefault: TColor): TColor;
var
  S: string;
  V: Integer;
  R: Integer;
  G: Integer;
  B: Integer;
begin
  S := Trim(AText);
  if Pos('0x', LowerCase(S)) = 1 then
    S := '$' + Copy(S, 3, MaxInt);
  V := StrToIntDef(S, -1);
  if V < 0 then
  begin
    Result := ADefault;
    Exit;
  end;
  R := ((V shr 11) and $1F) * 255 div 31;
  G := ((V shr 5) and $3F) * 255 div 63;
  B := (V and $1F) * 255 div 31;
  Result := RGB(R, G, B);
end;

//======================================================
// Осветляет цвет на заданный процент для предпросмотра.
function LightenColor(AColor: TColor; Amount: Integer): TColor;
var
  C: TColor;
  R: Integer;
  G: Integer;
  B: Integer;
begin
  if Amount < 0 then
    Amount := 0;
  if Amount > 100 then
    Amount := 100;
  C := ColorToRGB(AColor);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  R := R + (255 - R) * Amount div 100;
  G := G + (255 - G) * Amount div 100;
  B := B + (255 - B) * Amount div 100;
  Result := RGB(R, G, B);
end;

//======================================================
// Разделяет командную строку на поля по символу вертикальной черты.
procedure SplitPipe(const S: string; Parts: TStrings);
var
  I: Integer;
  StartPos: Integer;
begin
  Parts.Clear;
  StartPos := 1;
  for I := 1 to Length(S) do
  begin
    if S[I] = '|' then
    begin
      Parts.Add(Copy(S, StartPos, I - StartPos));
      StartPos := I + 1;
    end;
  end;
  Parts.Add(Copy(S, StartPos, MaxInt));
end;

//======================================================
// Удаляет однострочные комментарии из текста C/C++.
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
// Извлекает блок в фигурных скобках после заданного маркера.
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
// Разбирает числовой массив из C/C++ текста.
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
// Загружает список доступных ESP/GFX шрифтов для выбора в редакторе.
procedure TForm1.LoadEspFontList;
var
  I: Integer;
  FileName: string;
  Font: TGfxFont;
begin
  FFontList.Items.Clear;
  FFontFiles.Clear;
  for I := 0 to FFontCache.Count - 1 do
    TGfxFont(FFontCache[I]).Free;
  FFontCache.Clear;

  for I := Low(FONT_FILE_MAP) to High(FONT_FILE_MAP) do
  begin
    FileName := FontsRusDir + '\' + FONT_FILE_MAP[I];
    FFontFiles.Add(FileName);
    Font := TGfxFont.Create;
    Font.Name := ChangeFileExt(FONT_FILE_MAP[I], '');
    Font.FileName := FileName;
    Font.Loaded := False;
    FFontCache.Add(Font);
    if FileExists(FileName) then
      FFontList.Items.Add(IntToStr(I) + ' ' + Font.Name)
    else
      FFontList.Items.Add(IntToStr(I) + ' missing ' + FONT_FILE_MAP[I]);
  end;

  if FFontList.Items.Count > 1 then
    FFontList.ItemIndex := 1
  else if FFontList.Items.Count > 0 then
    FFontList.ItemIndex := 0;
end;

//======================================================
// Применяет выбранный шрифт к виртуальному предпросмотру.
procedure TForm1.ApplyPreviewFont(AFontId: Integer);
begin
  FActiveFontId := AFontId;
end;

//======================================================
// Возвращает объект шрифта предпросмотра по его номеру.
function TForm1.GetPreviewFont(AFontId: Integer): TGfxFont;
begin
  Result := nil;
  if AFontId < 1 then
    AFontId := 1;
  if AFontId > FFontCache.Count then
    AFontId := FFontCache.Count;
  if AFontId < 1 then
    Exit;
  Result := TGfxFont(FFontCache[AFontId - 1]);
  if not Result.Loaded then
    LoadGfxFontFile(Result);
end;

//======================================================
// Загружает данные GFX-шрифта из файла для локальной отрисовки.
function TForm1.LoadGfxFontFile(AFont: TGfxFont): Boolean;
var
  SL: TStringList;
  Text: string;
  CleanText: string;
  BitmapBlock: string;
  GlyphBlock: string;
  FontBlock: string;
  Numbers: TIntegerArray;
  I: Integer;
  G: Integer;
begin
  Result := False;
  if AFont = nil then
    Exit;
  AFont.Loaded := True;
  if not FileExists(AFont.FileName) then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFont.FileName);
    Text := SL.Text;
  finally
    SL.Free;
  end;

  CleanText := RemoveLineComments(Text);
  BitmapBlock := ExtractBraceBlock(CleanText, 'Bitmaps');
  GlyphBlock := ExtractBraceBlock(CleanText, 'Glyphs');
  FontBlock := ExtractBraceBlock(CleanText, 'GFXfont');

  Numbers := ParseCNumbers(BitmapBlock);
  SetLength(AFont.Bitmaps, Length(Numbers));
  for I := 0 to High(Numbers) do
    AFont.Bitmaps[I] := Byte(Numbers[I] and $FF);

  Numbers := ParseCNumbers(GlyphBlock);
  SetLength(AFont.Glyphs, Length(Numbers) div 6);
  for G := 0 to High(AFont.Glyphs) do
  begin
    AFont.Glyphs[G].BitmapOffset := Numbers[G * 6 + 0];
    AFont.Glyphs[G].Width := Numbers[G * 6 + 1];
    AFont.Glyphs[G].Height := Numbers[G * 6 + 2];
    AFont.Glyphs[G].XAdvance := Numbers[G * 6 + 3];
    AFont.Glyphs[G].XOffset := Numbers[G * 6 + 4];
    AFont.Glyphs[G].YOffset := Numbers[G * 6 + 5];
  end;

  Numbers := ParseCNumbers(FontBlock);
  if Length(Numbers) >= 3 then
  begin
    AFont.First := Numbers[Length(Numbers) - 3];
    AFont.Last := Numbers[Length(Numbers) - 2];
    AFont.YAdvance := Numbers[Length(Numbers) - 1];
  end
  else
  begin
    AFont.First := $20;
    AFont.Last := AFont.First + Length(AFont.Glyphs) - 1;
    AFont.YAdvance := 16;
  end;

  Result := (Length(AFont.Bitmaps) > 0) and (Length(AFont.Glyphs) > 0);
end;

//======================================================
// Определяет код глифа GFX-шрифта для символа.
function TForm1.GfxGlyphCode(AChar: AnsiChar): Integer;
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
// Вычисляет границы строки, нарисованной GFX-шрифтом.
procedure TForm1.GfxTextBounds(AFont: TGfxFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
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
  if AFont = nil then
    Exit;

  CursorX := 0;
  HasPixels := False;
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

  if not HasPixels then
    AMaxX := CursorX;
end;

//======================================================
// Рисует строку GFX-шрифтом на виртуальном дисплее.
procedure TForm1.DrawGfxText(AFont: TGfxFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
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
            if (PX >= 0) and (PX < FPreview.Width) and (PY >= 0) and (PY < FPreview.Height) then
              FPreview.Canvas.Pixels[PX, PY] := AColor;
          end;
        end;
        Inc(BitIndex);
      end;
    Inc(CursorX, Glyph.XAdvance);
  end;
end;

//======================================================
// Рисует текст GFX-шрифтом внутри прямоугольной области с выравниванием.
function TForm1.DrawGfxTextBox(const AText: string; const ARect: TRect; AHAlign, AVAlign: string; AColor: TColor): Boolean;
var
  Font: TGfxFont;
  MinX: Integer;
  MinY: Integer;
  MaxX: Integer;
  MaxY: Integer;
  TextW: Integer;
  TextH: Integer;
  LeftPos: Integer;
  TopPos: Integer;
begin
  Result := False;
  Font := GetPreviewFont(FActiveFontId);
  if (Font = nil) or (Length(Font.Glyphs) = 0) then
    Exit;

  GfxTextBounds(Font, AText, MinX, MinY, MaxX, MaxY);
  TextW := MaxX - MinX;
  TextH := MaxY - MinY;

  AHAlign := UpperCase(Trim(AHAlign));
  AVAlign := UpperCase(Trim(AVAlign));

  if AHAlign = 'R' then
    LeftPos := ARect.Right - TextW - 6
  else if AHAlign = 'L' then
    LeftPos := ARect.Left + 6
  else
    LeftPos := ARect.Left + ((ARect.Right - ARect.Left) - TextW) div 2;

  if AVAlign = 'B' then
    TopPos := ARect.Bottom - TextH - 4
  else if AVAlign = 'T' then
    TopPos := ARect.Top + 4
  else
    TopPos := ARect.Top + ((ARect.Bottom - ARect.Top) - TextH) div 2;

  DrawGfxText(Font, AText, LeftPos - MinX, TopPos - MinY + GFX_PREVIEW_Y_CORRECTION, AColor);
  Result := True;
end;

//======================================================
// Выводит текст предпросмотра с текущим горизонтальным и вертикальным выравниванием.
procedure TForm1.DrawAlignedPreviewText(const AText: string; const ARect: TRect; AHAlign, AVAlign: string);
begin
  DrawGfxTextBox(AText, ARect, AHAlign, AVAlign, FPreview.Canvas.Font.Color);
end;

//======================================================
// Возвращает выбранное горизонтальное выравнивание текста.
function TForm1.SelectedHAlign: string;
begin
  case ComboBox2.ItemIndex of
    0: Result := 'L';
    2: Result := 'R';
  else
    Result := 'C';
  end;
end;

//======================================================
// Возвращает выбранное вертикальное выравнивание текста.
function TForm1.SelectedVAlign: string;
begin
  case ComboBox3.ItemIndex of
    0: Result := 'T';
    2: Result := 'B';
  else
    Result := 'C';
  end;
end;

//======================================================
// Устанавливает состояние списков выбора выравнивания по значениям строки.
procedure TForm1.SetAlignButtons(const AHAlign, AVAlign: string);
var
  H: string;
  V: string;
begin
  H := UpperCase(Trim(AHAlign));
  V := UpperCase(Trim(AVAlign));

  if H = 'L' then
    ComboBox2.ItemIndex := 0
  else if H = 'R' then
    ComboBox2.ItemIndex := 2
  else
    ComboBox2.ItemIndex := 1;

  if V = 'T' then
    ComboBox3.ItemIndex := 0
  else if V = 'B' then
    ComboBox3.ItemIndex := 2
  else
    ComboBox3.ItemIndex := 1;
end;

//======================================================
// Формирует команду ESP из одной строки таблицы редактора.
function TForm1.ScriptFromRow(ARow: Integer): string;
var
  Cmd: string;
  Orientation: string;
begin
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if Cmd = 'CL' then
    Result := 'CL|' + StringGrid1.Cells[COL_C1, ARow]
  else if Cmd = 'BT' then
    Result := Format('BT|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow], StringGrid1.Cells[COL_LINE, ARow],
       StringGrid1.Cells[COL_FONT, ARow], StringGrid1.Cells[COL_HALIGN, ARow],
       StringGrid1.Cells[COL_VALIGN, ARow]])
  else if Cmd = 'TX' then
    Result := Format('TX|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_FONT, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_HALIGN, ARow],
       StringGrid1.Cells[COL_VALIGN, ARow]])
  else if Cmd = 'TR' then
    Result := Format('TR|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       '100', StringGrid1.Cells[COL_C1, ARow],
       StringGrid1.Cells[COL_C2, ARow]])
  else if (Cmd = 'BX') or (Cmd = 'RR') then
    Result := Format('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [Cmd, StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_C1, ARow],
       StringGrid1.Cells[COL_C2, ARow], StringGrid1.Cells[COL_EXTRA, ARow],
       StringGrid1.Cells[COL_LINE, ARow]])
  else if Cmd = 'TW' then
    Result := Format('TW|%s|%s|%s|%s|%s|%s| |%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow]])
  else if Cmd = 'SB' then
  begin
    if StrToIntDef(StringGrid1.Cells[COL_H, ARow], 0) >=
      StrToIntDef(StringGrid1.Cells[COL_W, ARow], 0) then
      Orientation := 'V'
    else
      Orientation := 'H';
    Result := Format('SB|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], Orientation,
       StringGrid1.Cells[COL_TEXT, ARow], '100',
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow]])
  end
  else if Cmd = 'PB' then
    Result := Format('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [Cmd, StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow]])
  else if Cmd = 'SW' then
    Result := Format('SW|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow]])
  else if Cmd = 'CC' then
    Result := Format('CC|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_LINE, ARow]])
  else if Cmd = 'BM' then
    Result := Format('BM|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow]])
  else if Cmd = 'JPG' then
    Result := Format('JPG|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow], StringGrid1.Cells[COL_SRCX, ARow],
       StringGrid1.Cells[COL_SRCY, ARow], StringGrid1.Cells[COL_SRCW, ARow],
       StringGrid1.Cells[COL_SRCH, ARow]])
  else
    Result := '';
end;

//======================================================
// Возвращает локальную папку, соответствующую содержимому SD-карты.
function TForm1.SdRootPath: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\sd\');
end;

//======================================================
// Преобразует локальный путь файла в путь команды для SD-карты ESP.
function TForm1.SdCommandPathFromLocalPath(const AFileName: string): string;
var
  Root: string;
  FullName: string;
  TargetName: string;
begin
  Root := IncludeTrailingPathDelimiter(SdRootPath);
  FullName := ExpandFileName(AFileName);
  if Pos(UpperCase(Root), UpperCase(FullName)) = 1 then
    Result := Copy(FullName, Length(Root) + 1, MaxInt)
  else
  begin
    ForceDirectories(Root + 'images');
    TargetName := Root + 'images\' + ExtractFileName(FullName);
    if UpperCase(FullName) <> UpperCase(TargetName) then
      CopyFile(PChar(FullName), PChar(TargetName), False);
    Result := 'images\' + ExtractFileName(FullName);
  end;
  Result := '/' + StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

//======================================================
// Преобразует путь картинки из команды в локальный путь на компьютере.
function TForm1.LocalImagePathFromCommandPath(const APath: string): string;
var
  RelPath: string;
begin
  RelPath := Trim(APath);
  if RelPath = '' then
  begin
    Result := '';
    Exit;
  end;
  if (Length(RelPath) > 1) and (RelPath[2] = ':') then
    Result := RelPath
  else
  begin
    while (RelPath <> '') and ((RelPath[1] = '/') or (RelPath[1] = '\')) do
      Delete(RelPath, 1, 1);
    Result := IncludeTrailingPathDelimiter(SdRootPath) +
      StringReplace(RelPath, '/', '\', [rfReplaceAll]);
  end;
end;

//======================================================
// Открывает редактор области картинки для выбранной JPG-строки.
procedure TForm1.OpenImageAreaEditor(ARow: Integer);
var
  FileName: string;
  SrcX: Integer;
  SrcY: Integer;
  SrcW: Integer;
  SrcH: Integer;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  if UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow])) <> 'JPG' then
    Exit;

  FileName := LocalImagePathFromCommandPath(StringGrid1.Cells[COL_TEXT, ARow]);
  if not FileExists(FileName) then
  begin
    StatusBar1.SimpleText := 'Image file not found: ' + ExtractFileName(FileName);
    Exit;
  end;

  SrcX := StrToIntDef(StringGrid1.Cells[COL_SRCX, ARow], 0);
  SrcY := StrToIntDef(StringGrid1.Cells[COL_SRCY, ARow], 0);
  SrcW := StrToIntDef(StringGrid1.Cells[COL_SRCW, ARow], 0);
  SrcH := StrToIntDef(StringGrid1.Cells[COL_SRCH, ARow], 0);
  if Form3.ExecuteCrop(FileName, SrcX, SrcY, SrcW, SrcH) then
  begin
    if (SrcW < 4) or (SrcH < 4) then
    begin
      StatusBar1.SimpleText := 'Image area too small, selection ignored';
      Exit;
    end;
    StringGrid1.Cells[COL_SRCX, ARow] := IntToStr(SrcX);
    StringGrid1.Cells[COL_SRCY, ARow] := IntToStr(SrcY);
    StringGrid1.Cells[COL_SRCW, ARow] := IntToStr(SrcW);
    StringGrid1.Cells[COL_SRCH, ARow] := IntToStr(SrcH);
    UpdateImageRowSize(ARow);
    LoadInputsFromRow(ARow);
    StringGrid1.Invalidate;
    RepaintPreview;
  end;
end;

//======================================================
// Нормализует текст масштаба JPG к поддерживаемым значениям.
function NormalizeJpgScaleText(const AScale: string): string;
var
  S: string;
begin
  S := Trim(AScale);
  if (S = '1/4') or (S = '1/2') or (S = '1/1') or
    (S = '2/1') or (S = '4/1') then
    Result := S
  else if S = '1' then
    Result := '1/1'
  else if S = '2' then
    Result := '1/2'
  else if S = '4' then
    Result := '1/4'
  else
    Result := '1/1';
end;

//======================================================
// Преобразует текст масштаба JPG в числитель и знаменатель.
procedure JpgScaleRatio(const AScale: string; var ANumerator, ADenominator: Integer);
var
  S: string;
begin
  S := NormalizeJpgScaleText(AScale);
  if S = '1/4' then
  begin
    ANumerator := 1;
    ADenominator := 4;
  end
  else if S = '1/2' then
  begin
    ANumerator := 1;
    ADenominator := 2;
  end
  else if S = '2/1' then
  begin
    ANumerator := 2;
    ADenominator := 1;
  end
  else if S = '4/1' then
  begin
    ANumerator := 4;
    ADenominator := 1;
  end
  else
  begin
    ANumerator := 1;
    ADenominator := 1;
  end;
end;

//======================================================
// Пересчитывает размер JPG-элемента с учётом выбранной области и масштаба.
procedure TForm1.UpdateImageRowSize(ARow: Integer);
var
  Picture: TPicture;
  FileName: string;
  ScaleText: string;
  ScaleNum: Integer;
  ScaleDen: Integer;
  W: Integer;
  H: Integer;
  SrcW: Integer;
  SrcH: Integer;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  FileName := LocalImagePathFromCommandPath(StringGrid1.Cells[COL_TEXT, ARow]);
  if not FileExists(FileName) then
    Exit;
  ScaleText := NormalizeJpgScaleText(StringGrid1.Cells[COL_EXTRA, ARow]);
  JpgScaleRatio(ScaleText, ScaleNum, ScaleDen);
  StringGrid1.Cells[COL_EXTRA, ARow] := ScaleText;
  Picture := TPicture.Create;
  try
    try
      Picture.LoadFromFile(FileName);
      if (Picture.Width > 0) and (Picture.Height > 0) then
      begin
        SrcW := StrToIntDef(StringGrid1.Cells[COL_SRCW, ARow], 0);
        SrcH := StrToIntDef(StringGrid1.Cells[COL_SRCH, ARow], 0);
        if SrcW <= 0 then
          SrcW := Picture.Width;
        if SrcH <= 0 then
          SrcH := Picture.Height;
        W := (SrcW * ScaleNum + ScaleDen - 1) div ScaleDen;
        H := (SrcH * ScaleNum + ScaleDen - 1) div ScaleDen;
        if W < 1 then
          W := 1;
        if H < 1 then
          H := 1;
        StringGrid1.Cells[COL_W, ARow] := IntToStr(W);
        StringGrid1.Cells[COL_H, ARow] := IntToStr(H);
      end;
    except
      StatusBar1.SimpleText := 'Image load error: ' + ExtractFileName(FileName);
    end;
  finally
    Picture.Free;
  end;
end;

//======================================================
// Преобразует байт в двухсимвольную HEX-строку.
function HexByte(AValue: Byte): string;
const
  HexChars: array[0..15] of Char = '0123456789ABCDEF';
begin
  Result := HexChars[AValue shr 4] + HexChars[AValue and $0F];
end;

//======================================================
// Ожидает ответ ESP по serial с заданным префиксом.
function TForm1.WaitSerialReply(const APrefix: string; ATimeoutMs: DWORD; var ALine: string): Boolean;
var
  Buffer: array[0..127] of AnsiChar;
  ReadCount: DWORD;
  Chunk: AnsiString;
  P: Integer;
  StartedAt: DWORD;
begin
  Result := False;
  ALine := '';
  StartedAt := GetTickCount;
  repeat
    P := Pos(#10, string(FPortRxText));
    if P > 0 then
    begin
      ALine := Trim(Copy(string(FPortRxText), 1, P - 1));
      Delete(FPortRxText, 1, P);
      if ALine <> '' then
      begin
        HandleRxLine(ALine);
        if Pos(APrefix, ALine) = 1 then
        begin
          Result := True;
          Exit;
        end;
        if Pos('ERR|', UpperCase(ALine)) = 1 then
          Exit;
      end;
    end
    else
    begin
      ReadCount := 0;
      if not ReadFile(FPort, Buffer, SizeOf(Buffer), ReadCount, nil) then
      begin
        StatusBar1.SimpleText := 'Port read error: ' + ComboBox1.Text;
        ClosePort(True);
        Exit;
      end;
      if ReadCount > 0 then
      begin
        SetString(Chunk, PAnsiChar(@Buffer[0]), ReadCount);
        FPortRxText := FPortRxText + Chunk;
      end
      else
      begin
        Application.ProcessMessages;
        Sleep(5);
      end;
    end;
  until GetTickCount - StartedAt > ATimeoutMs;

  StatusBar1.SimpleText := 'Serial timeout waiting: ' + APrefix;
end;

//======================================================
// Передаёт локальный файл картинки на SD-карту ESP.
function TForm1.SendFileToEspSd(const ALocalFileName: string; var ASdPath: string): Boolean;
const
  CHUNK_SIZE = 64;
var
  Stream: TFileStream;
  Buffer: array[0..CHUNK_SIZE - 1] of Byte;
  ReadCount: Integer;
  I: Integer;
  HexLine: string;
  Sent: Integer;
  Percent: Integer;
  ReplyLine: string;
  ExpectedPrefix: string;
  MonitorWasEnabled: Boolean;
  UseUdp: Boolean;
  ChannelName: string;
  RemoteSize: Int64;

  function SendUploadLine(const ALine, AOkPrefix: string; ATimeoutMs: DWORD): Boolean;
  var
    Attempt: Integer;
  begin
   // Result := False;
    if UseUdp then
    begin
      for Attempt := 1 to 3 do
      begin
        Result := UdpExchangeLine(ALine, Trim(Edit2.Text), False, ReplyLine);
        if Result and (Pos(AOkPrefix, ReplyLine) = 1) then
          Exit;
        StatusBar1.SimpleText := 'UDP retry ' + IntToStr(Attempt) + ': ' + ReplyLine;
        StatusBar1.Update;
        Sleep(30);
      end;
    end
    else
    begin
      SendSerialLine(ALine);
      Result := WaitSerialReply(AOkPrefix, ATimeoutMs, ReplyLine);
    end;
    if Result and (Pos(AOkPrefix, ReplyLine) <> 1) then
      Result := False;
  end;

  function RemoteFileExists(var ARemoteSize: Int64): Boolean;
  var
    P: Integer;
    SizeText: string;
  begin
    Result := False;
    ARemoteSize := -1;
    ReplyLine := '';
    if not SendUploadLine('FS|' + ASdPath, 'OK|FS|', 1500) then
      Exit;

    P := LastDelimiter('|', ReplyLine);
    if P <= 0 then
      Exit;

    SizeText := Trim(Copy(ReplyLine, P + 1, MaxInt));
    ARemoteSize := StrToInt64Def(SizeText, -1);
    Result := ARemoteSize >= 0;
  end;

begin
  Result := False;
  UseUdp := UdpEnabled;
  if UseUdp then
    ChannelName := 'UDP'
  else
    ChannelName := 'COM';
  if (not UseUdp) and (FPort = INVALID_HANDLE_VALUE) then
  begin
    StatusBar1.SimpleText := 'Port is closed: ' + ComboBox1.Text;
    Exit;
  end;
  if not FileExists(ALocalFileName) then
  begin
    StatusBar1.SimpleText := 'Image file not found: ' + ExtractFileName(ALocalFileName);
    Exit;
  end;

  MonitorWasEnabled := False;
  Stream := TFileStream.Create(ALocalFileName, fmOpenRead or fmShareDenyWrite);
  try
    if not UseUdp then
    begin
      MonitorWasEnabled := Assigned(FPortMonitor) and FPortMonitor.Enabled;
      if Assigned(FPortMonitor) then
        FPortMonitor.Enabled := False;
      FPortRxText := '';
    end;

    StatusBar1.SimpleText := 'SD upload ' + ChannelName + ' start: ' +
      ASdPath + ' (' + IntToStr(Stream.Size) + ' bytes)';
    StatusBar1.Update;

    if RemoteFileExists(RemoteSize) then
    begin
      if CheckBox4.Enabled and CheckBox4.Checked then
      begin
        StatusBar1.SimpleText := 'SD upload overwrite: ' + ASdPath;
        StatusBar1.Update;
      end
      else
      begin
        StatusBar1.SimpleText := 'SD upload skipped, exists: ' + ASdPath;
        StatusBar1.Update;
        Result := True;
        Exit;
      end;
    end;

    if not SendUploadLine('FW|' + ASdPath + '|' + IntToStr(Stream.Size), 'OK|FW|', 3000) then
    begin
      StatusBar1.SimpleText := 'SD upload start failed: ' + ReplyLine;
      Exit;
    end;

    Sent := 0;
    repeat
      ReadCount := Stream.Read(Buffer, SizeOf(Buffer));
      if ReadCount > 0 then
      begin
        if UseUdp then
          HexLine := 'FDO|' + IntToStr(Sent) + '|'
        else
          HexLine := 'FD|';
        for I := 0 to ReadCount - 1 do
          HexLine := HexLine + HexByte(Buffer[I]);
        if UseUdp then
          ExpectedPrefix := 'OK|FDO|'
        else
          ExpectedPrefix := 'OK|FD|';
        if not SendUploadLine(HexLine, ExpectedPrefix, 3000) then
        begin
          StatusBar1.SimpleText := 'SD upload block failed: ' + ReplyLine;
          Exit;
        end;
        Inc(Sent, ReadCount);
        if Stream.Size > 0 then
          Percent := Sent * 100 div Stream.Size
        else
          Percent := 100;
        StatusBar1.SimpleText := 'SD upload ' + IntToStr(Percent) + '%: ' + ASdPath +
          ' ' + IntToStr(Sent) + '/' + IntToStr(Stream.Size);
        StatusBar1.Update;
        Application.ProcessMessages;
      end;
    until ReadCount = 0;

    if not SendUploadLine('FE', 'OK|FE|', 5000) then
    begin
      StatusBar1.SimpleText := 'SD upload finish failed: ' + ReplyLine;
      Exit;
    end;
    StatusBar1.SimpleText := 'SD upload done: ' + ASdPath;
    StatusBar1.Update;
    Result := True;
  finally
    if (not UseUdp) and Assigned(FPortMonitor) then
      FPortMonitor.Enabled := MonitorWasEnabled;
    Stream.Free;
  end;
end;

//======================================================
// Загружает файл JPG для выбранной строки, если это требуется.
function TForm1.UploadImageRowToEsp(ARow: Integer): Boolean;
var
  Cmd: string;
  SdPath: string;
  LocalFileName: string;
begin
  Result := True;
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if Cmd <> 'JPG' then
    Exit;
  if (not UdpEnabled) and (FPort = INVALID_HANDLE_VALUE) then
  begin
    StatusBar1.SimpleText := 'JPG SD upload skipped: COM closed';
    Exit;
  end;
  SdPath := Trim(StringGrid1.Cells[COL_TEXT, ARow]);
  LocalFileName := LocalImagePathFromCommandPath(SdPath);
  Result := SendFileToEspSd(LocalFileName, SdPath);
  if Result and (Trim(StringGrid1.Cells[COL_TEXT, ARow]) <> SdPath) then
  begin
    StringGrid1.Cells[COL_TEXT, ARow] := SdPath;
    Edit1.Text := ScriptFromRow(ARow);
    RepaintPreview;
  end;
end;

//======================================================
// Возвращает прямоугольник элемента строки на виртуальном дисплее.
function TForm1.RowRect(ARow: Integer; var ARect: TRect): Boolean;
var
  Cmd: string;
  X: Integer;
  Y: Integer;
  W: Integer;
  H: Integer;
  ScaleNum: Integer;
  ScaleDen: Integer;
  SrcW: Integer;
  SrcH: Integer;
begin
  Result := False;
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if Cmd = '' then
    Exit;
  X := StrToIntDef(StringGrid1.Cells[COL_X, ARow], 0);
  Y := StrToIntDef(StringGrid1.Cells[COL_Y, ARow], 0);
  W := StrToIntDef(StringGrid1.Cells[COL_W, ARow], 80);
  H := StrToIntDef(StringGrid1.Cells[COL_H, ARow], 24);
  if Cmd = 'CC' then
  begin
    H := W;
  end
  else if Cmd = 'BM' then
  begin
    W := StrToIntDef(StringGrid1.Cells[COL_EXTRA, ARow], 2) * 16;
    H := W;
  end
  else if Cmd = 'JPG' then
  begin
    SrcW := StrToIntDef(StringGrid1.Cells[COL_SRCW, ARow], 0);
    SrcH := StrToIntDef(StringGrid1.Cells[COL_SRCH, ARow], 0);
    if (SrcW > 0) and (SrcH > 0) then
    begin
      JpgScaleRatio(StringGrid1.Cells[COL_EXTRA, ARow], ScaleNum, ScaleDen);
      W := (SrcW * ScaleNum + ScaleDen - 1) div ScaleDen;
      H := (SrcH * ScaleNum + ScaleDen - 1) div ScaleDen;
    end;
  end;
  ARect := Rect(X, Y, X + W, Y + H);
  Result := True;
end;

//======================================================
// Добавляет новый элемент интерфейса в таблицу команд.
procedure TForm1.AddElement(const AKind: string);
var
  R: Integer;
begin
  if (StringGrid1.RowCount = 2) and (Trim(StringGrid1.Cells[COL_CMD, 1]) = '') then
    R := 1
  else
  begin
    R := StringGrid1.RowCount;
    StringGrid1.RowCount := StringGrid1.RowCount + 1;
  end;

  StringGrid1.Cells[COL_CMD, R] := AKind;
  StringGrid1.Cells[COL_ID, R] := IntToStr(R);
  StringGrid1.Cells[COL_X, R] := IntToStr(30 + R * 10);
  StringGrid1.Cells[COL_Y, R] := IntToStr(30 + R * 10);
  StringGrid1.Cells[COL_W, R] := '100';
  StringGrid1.Cells[COL_H, R] := '36';
  StringGrid1.Cells[COL_TEXT, R] := 'Text';
  StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
  StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
  StringGrid1.Cells[COL_EXTRA, R] := FDefaultFgRgb;
  StringGrid1.Cells[COL_LINE, R] := '1';
  StringGrid1.Cells[COL_FONT, R] := '2';
  StringGrid1.Cells[COL_HALIGN, R] := 'C';
  StringGrid1.Cells[COL_VALIGN, R] := 'C';

  if AKind = 'BT' then
  begin
    if Trim(Edit4.Text) <> '' then
      StringGrid1.Cells[COL_TEXT, R] := Edit4.Text
    else
      StringGrid1.Cells[COL_TEXT, R] := 'Button';
    StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_LINE, R] := '1';
  end
  else if AKind = 'TX' then
  begin
    if Trim(Edit4.Text) <> '' then
      StringGrid1.Cells[COL_TEXT, R] := Edit4.Text
    else
      StringGrid1.Cells[COL_TEXT, R] := 'Text';
    StringGrid1.Cells[COL_W, R] := '100';
    StringGrid1.Cells[COL_H, R] := '30';
    StringGrid1.Cells[COL_C1, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_FONT, R] := '2';
  end
  else if AKind = 'TR' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '50';
    StringGrid1.Cells[COL_W, R] := '180';
    StringGrid1.Cells[COL_H, R] := '36';
    StringGrid1.Cells[COL_C1, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := '100';
  end
  else if AKind = 'PB' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '50';
    StringGrid1.Cells[COL_W, R] := '180';
    StringGrid1.Cells[COL_H, R] := '32';
    StringGrid1.Cells[COL_C1, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultLineRgb;
  end
  else if AKind = 'SW' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '0';
    StringGrid1.Cells[COL_W, R] := '120';
    StringGrid1.Cells[COL_H, R] := '52';
    StringGrid1.Cells[COL_C1, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := '';
  end
  else if AKind = 'BM' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := 'play';
    StringGrid1.Cells[COL_C1, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := '2';
  end
  else if AKind = 'JPG' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '/lcd_a.jpg';
    StringGrid1.Cells[COL_W, R] := '120';
    StringGrid1.Cells[COL_H, R] := '80';
    StringGrid1.Cells[COL_EXTRA, R] := '1/1';
    StringGrid1.Cells[COL_SRCX, R] := '0';
    StringGrid1.Cells[COL_SRCY, R] := '0';
    StringGrid1.Cells[COL_SRCW, R] := '0';
    StringGrid1.Cells[COL_SRCH, R] := '0';
    UpdateImageRowSize(R);
  end
  else if AKind = 'BX' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '';
    StringGrid1.Cells[COL_W, R] := '120';
    StringGrid1.Cells[COL_H, R] := '60';
    StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_EXTRA, R] := '0';
    StringGrid1.Cells[COL_LINE, R] := '1';
  end
  else if AKind = 'RR' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '';
    StringGrid1.Cells[COL_W, R] := '120';
    StringGrid1.Cells[COL_H, R] := '60';
    StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_EXTRA, R] := '8';
    StringGrid1.Cells[COL_LINE, R] := '1';
  end
  else if AKind = 'CC' then
  begin
    StringGrid1.Cells[COL_W, R] := '36';
    StringGrid1.Cells[COL_H, R] := '36';
    StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_LINE, R] := '1';
  end;

  SelectRow(R);
end;

//======================================================
// Разбирает строку скрипта и добавляет её в таблицу редактора.
procedure TForm1.AddScriptLine(const ALine: string);
var
  Parts: TStringList;
  R: Integer;
  Cmd: string;

  function Part(Index: Integer; const Default: string = ''): string;
  begin
    if Index < Parts.Count then
      Result := Parts[Index]
    else
      Result := Default;
  end;

begin
  if (Trim(ALine) = '') or (Copy(Trim(ALine), 1, 1) = '#') then
    Exit;

  Parts := TStringList.Create;
  try
    SplitPipe(Trim(ALine), Parts);
    if Parts.Count = 0 then
      Exit;
    Cmd := UpperCase(Trim(Part(0)));
    if Cmd = '' then
      Exit;
    if (Cmd = 'C') or (Cmd = 'L') or (Cmd = 'I') or (Cmd = 'B') or
      (Cmd = 'W') or (Cmd = 'S') or (Cmd = 'T') then
      Exit;

    if (StringGrid1.RowCount = 2) and (Trim(StringGrid1.Cells[COL_CMD, 1]) = '') then
      R := 1
    else
    begin
      R := StringGrid1.RowCount;
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
    end;

    StringGrid1.Rows[R].Clear;
    StringGrid1.Cells[COL_CMD, R] := Cmd;
    StringGrid1.Cells[COL_ID, R] := Part(1, IntToStr(R));
    StringGrid1.Cells[COL_X, R] := Part(2, '0');
    StringGrid1.Cells[COL_Y, R] := Part(3, '0');
    StringGrid1.Cells[COL_W, R] := Part(4, '80');
    StringGrid1.Cells[COL_H, R] := Part(5, '24');
    StringGrid1.Cells[COL_TEXT, R] := Part(6, '');
    StringGrid1.Cells[COL_C1, R] := Part(7, '0xFFFF');
    StringGrid1.Cells[COL_C2, R] := Part(8, '0x0000');
    StringGrid1.Cells[COL_EXTRA, R] := Part(9, '0xFFFF');
    StringGrid1.Cells[COL_LINE, R] := '1';
    StringGrid1.Cells[COL_FONT, R] := '2';
    StringGrid1.Cells[COL_HALIGN, R] := 'C';
    StringGrid1.Cells[COL_VALIGN, R] := 'C';

    if Cmd = 'BT' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, 'Button');
      StringGrid1.Cells[COL_C1, R] := Part(7, '0x001F');
      StringGrid1.Cells[COL_C2, R] := Part(8, '0xFFFF');
      StringGrid1.Cells[COL_EXTRA, R] := Part(9, '0xFFFF');
      StringGrid1.Cells[COL_LINE, R] := Part(10, '1');
      StringGrid1.Cells[COL_FONT, R] := Part(11, '2');
      StringGrid1.Cells[COL_HALIGN, R] := Part(12, 'C');
      StringGrid1.Cells[COL_VALIGN, R] := Part(13, 'C');
    end
    else if Cmd = 'TX' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(4, 'Text');
      StringGrid1.Cells[COL_C1, R] := Part(5, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(6, '0x0001');
      StringGrid1.Cells[COL_FONT, R] := Part(7, '2');
      StringGrid1.Cells[COL_W, R] := Part(8, '100');
      StringGrid1.Cells[COL_H, R] := Part(9, '30');
      StringGrid1.Cells[COL_HALIGN, R] := Part(10, 'C');
      StringGrid1.Cells[COL_VALIGN, R] := Part(11, 'C');
    end
    else if Cmd = 'TR' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, '50');
      StringGrid1.Cells[COL_EXTRA, R] := Part(7, '100');
      StringGrid1.Cells[COL_C1, R] := Part(8, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(9, '0x07E0');
    end
    else if (Cmd = 'BX') or (Cmd = 'RR') then
    begin
      StringGrid1.Cells[COL_C1, R] := Part(6, '0x0001');
      StringGrid1.Cells[COL_C2, R] := Part(7, '0xFFFF');
      if Cmd = 'BX' then
        StringGrid1.Cells[COL_EXTRA, R] := Part(8, '0')
      else
        StringGrid1.Cells[COL_EXTRA, R] := Part(8, '8');
      StringGrid1.Cells[COL_LINE, R] := Part(9, '1');
    end
    else if Cmd = 'TW' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, 'Window');
      StringGrid1.Cells[COL_C1, R] := Part(8, '0x2104');
      StringGrid1.Cells[COL_C2, R] := Part(9, '0xFFFF');
    end
    else if Cmd = 'SB' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(7, '50');
      StringGrid1.Cells[COL_EXTRA, R] := Part(8, '100');
      StringGrid1.Cells[COL_C1, R] := Part(9, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(10, '0x07E0');
    end
    else if Cmd = 'SW' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, '0');
      StringGrid1.Cells[COL_C1, R] := Part(7, '0x8410');
      StringGrid1.Cells[COL_C2, R] := Part(8, '0x07E0');
      StringGrid1.Cells[COL_EXTRA, R] := '';
    end
    else if Cmd = 'CC' then
    begin
      StringGrid1.Cells[COL_H, R] := StringGrid1.Cells[COL_W, R];
      StringGrid1.Cells[COL_C1, R] := Part(5, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(6, '0x0000');
      StringGrid1.Cells[COL_LINE, R] := Part(7, '1');
    end
    else if Cmd = 'BM' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(4, 'play');
      StringGrid1.Cells[COL_C1, R] := Part(5, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(6, '0x0001');
      StringGrid1.Cells[COL_EXTRA, R] := Part(7, '2');
    end
    else if Cmd = 'JPG' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(4, '/lcd_a.jpg');
      StringGrid1.Cells[COL_EXTRA, R] := NormalizeJpgScaleText(Part(5, '1/1'));
      StringGrid1.Cells[COL_SRCX, R] := Part(6, '0');
      StringGrid1.Cells[COL_SRCY, R] := Part(7, '0');
      StringGrid1.Cells[COL_SRCW, R] := Part(8, '0');
      StringGrid1.Cells[COL_SRCH, R] := Part(9, '0');
      StringGrid1.Cells[COL_W, R] := '120';
      StringGrid1.Cells[COL_H, R] := '80';
      StringGrid1.Cells[COL_C1, R] := '';
      StringGrid1.Cells[COL_C2, R] := '';
      UpdateImageRowSize(R);
    end
    else if Cmd = 'CL' then
    begin
      StringGrid1.Cells[COL_C1, R] := Part(1, '0x0000');
    end;

    FSelectedRow := R;
  finally
    Parts.Free;
  end;
end;

//======================================================
// Дублирует текущую выбранную строку элемента.
procedure TForm1.DuplicateSelectedRow;
var
  R: Integer;
  C: Integer;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) or
    (Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]) = '') then
    Exit;

  R := StringGrid1.RowCount;
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  for C := 0 to StringGrid1.ColCount - 1 do
    StringGrid1.Cells[C, R] := StringGrid1.Cells[C, FSelectedRow];
  StringGrid1.Cells[COL_ID, R] := IntToStr(R);
  StringGrid1.Cells[COL_X, R] := IntToStr(StrToIntDef(StringGrid1.Cells[COL_X, R], 0) + 4);
  StringGrid1.Cells[COL_Y, R] := IntToStr(StrToIntDef(StringGrid1.Cells[COL_Y, R], 0) + 4);
  SelectRow(R);
end;

//======================================================
// Переносит значения полей редактора обратно в текущую строку таблицы.
procedure TForm1.UpdateRowFromInputs(ARow: Integer);
var
  Cmd: string;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  StringGrid1.Cells[COL_X, ARow] := IntToStr(SpinEdit1.Value);
  StringGrid1.Cells[COL_Y, ARow] := IntToStr(SpinEdit2.Value);
  if Cmd = 'JPG' then
  begin
    UpdateImageRowSize(ARow);
    LoadInputsFromRow(ARow);
  end
  else
  begin
    StringGrid1.Cells[COL_W, ARow] := IntToStr(SpinEdit3.Value);
    StringGrid1.Cells[COL_H, ARow] := IntToStr(SpinEdit4.Value);
    if Cmd = 'CC' then
      StringGrid1.Cells[COL_H, ARow] := StringGrid1.Cells[COL_W, ARow];
    if (Cmd = 'BT') or (Cmd = 'TX') then
      StringGrid1.Cells[COL_TEXT, ARow] := Edit4.Text;
    if (Cmd = 'TR') or (Cmd = 'PB') or (Cmd = 'SW') or (Cmd = 'SB') then
      StringGrid1.Cells[COL_TEXT, ARow] := IntToStr(SpinEdit6.Value);
    if Cmd = 'RR' then
      StringGrid1.Cells[COL_EXTRA, ARow] := IntToStr(SpinEdit5.Value);
  end;
  Edit1.Text := ScriptFromRow(ARow);
  RepaintPreview;
end;

//======================================================
// Включает или отключает элемент управления, если он существует.
procedure SetControlState(AControl: TControl; AEnabled: Boolean);
begin
  if Assigned(AControl) then
    AControl.Enabled := AEnabled;
end;

//======================================================
// Настраивает доступность полей редактора под выбранный тип элемента.
procedure TForm1.UpdateEditorControlStates;
var
  Cmd: string;
  HasRow: Boolean;
  HasPosition: Boolean;
  HasWidth: Boolean;
  HasHeight: Boolean;
  HasRound: Boolean;
  HasValue: Boolean;
  HasLine: Boolean;
  HasFont: Boolean;
  HasAlign: Boolean;
  HasPicture: Boolean;
  HasText: Boolean;
begin
  HasRow := (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) and
    (Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]) <> '');
  Cmd := '';
  if HasRow then
    Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]));

  HasPosition := HasRow and (Cmd <> 'CL');
  HasWidth := HasRow and (Cmd <> 'CL') and (Cmd <> 'BM');
  HasHeight := HasWidth and (Cmd <> 'CC');
  HasRound := HasRow and (Cmd = 'RR');
  HasValue := HasRow and ((Cmd = 'TR') or (Cmd = 'PB') or (Cmd = 'SW') or (Cmd = 'SB'));
  HasLine := HasRow and ((Cmd = 'BT') or (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC'));
  HasFont := HasRow and ((Cmd = 'TX') or (Cmd = 'BT'));
  HasAlign := HasFont;
  HasPicture := HasRow and (Cmd = 'JPG');
  HasText := HasRow and ((Cmd = 'BT') or (Cmd = 'TX'));

  SetControlState(Label3, HasPosition or HasWidth);
  SetControlState(Label1, HasPosition);
  SetControlState(Label4, HasPosition);
  SetControlState(SpinEdit1, HasPosition);
  SetControlState(SpinEdit2, HasPosition);

  SetControlState(Label5, HasWidth);
  SetControlState(Label6, HasWidth);
  SetControlState(Label7, HasHeight);
  SetControlState(SpinEdit3, HasWidth);
  SetControlState(SpinEdit4, HasHeight);

  SetControlState(Label14, HasRound);
  SetControlState(SpinEdit5, HasRound);

  SetControlState(Label16, HasValue);
  SetControlState(SpinEdit6, HasValue);

  SetControlState(Label23, HasLine);
  SetControlState(FLineTrackLabel, HasLine);
  SetControlState(FLineTrack, HasLine);

  SetControlState(Label24, HasFont);
  SetControlState(FFontListLabel, HasFont);
  SetControlState(FFontList, HasFont);
  SetControlState(Button9, HasFont);
  SetControlState(ComboBox2, HasAlign);
  SetControlState(ComboBox3, HasAlign);
  SetControlState(Edit4, HasText);

  SetControlState(Button3, True);
  SetControlState(Button13, True);
  SetControlState(CheckBox4, HasPicture);
end;

//======================================================
// Загружает параметры выбранной строки в элементы управления формы.
procedure TForm1.LoadInputsFromRow(ARow: Integer);
var
  FontId: Integer;
  Cmd: string;
  Radius: Integer;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  FLoadingInputs := True;
  try
    Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
    SpinEdit1.Value := StrToIntDef(StringGrid1.Cells[COL_X, ARow], 0);
    SpinEdit2.Value := StrToIntDef(StringGrid1.Cells[COL_Y, ARow], 0);
    SpinEdit3.Value := StrToIntDef(StringGrid1.Cells[COL_W, ARow], 0);
    SpinEdit4.Value := StrToIntDef(StringGrid1.Cells[COL_H, ARow], 0);
    if Cmd = 'RR' then
      Radius := StrToIntDef(StringGrid1.Cells[COL_EXTRA, ARow], 0)
    else
      Radius := 0;
    if Radius < 0 then
      Radius := 0;
    if Radius > 80 then
      Radius := 80;
    SpinEdit5.Value := Radius;
    if (Cmd = 'BT') or (Cmd = 'TX') then
      Edit4.Text := StringGrid1.Cells[COL_TEXT, ARow]
    else
      Edit4.Text := '';
    SpinEdit6.Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, ARow], 0);
    if Assigned(FLineTrack) then
      FLineTrack.Position := StrToIntDef(StringGrid1.Cells[COL_LINE, ARow], 1);
    if Assigned(FFontList) then
    begin
      FontId := StrToIntDef(StringGrid1.Cells[COL_FONT, ARow], 2);
      if FontId < 1 then
        FontId := 1;
      if FontId > FFontList.Items.Count then
        FontId := FFontList.Items.Count;
      FFontList.ItemIndex := FontId - 1;
    end;
    SetAlignButtons(StringGrid1.Cells[COL_HALIGN, ARow], StringGrid1.Cells[COL_VALIGN, ARow]);
    Edit1.Text := ScriptFromRow(ARow);
    UpdateEditorControlStates;
  finally
    FLoadingInputs := False;
  end;
end;

//======================================================
// Синхронизирует четыре цветовых поля с цветами выбранного элемента.
procedure TForm1.UpdateDefaultColorsFromRow(ARow: Integer);
var
  Cmd: string;
  C1: string;
  C2: string;
  Extra: string;

  procedure SetLine(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultLineRgb := AValue;
  end;

  procedure SetText(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultFgRgb := AValue;
  end;

  procedure SetFill(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultBgRgb := AValue;
  end;

  procedure SetScreen(const AValue: string);
  begin
    if Trim(AValue) <> '' then
    begin
      FDefaultLcdBgRgb := AValue;
      if IsNoColorRgb(AValue) then
        FLcdBgColor := clBlack
      else
        FLcdBgColor := Rgb565ToColor(AValue, FLcdBgColor);
    end;
  end;

begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;

  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  C1 := Trim(StringGrid1.Cells[COL_C1, ARow]);
  C2 := Trim(StringGrid1.Cells[COL_C2, ARow]);
  Extra := Trim(StringGrid1.Cells[COL_EXTRA, ARow]);

  if Cmd = 'CL' then
    SetScreen(C1)
  else if Cmd = 'BT' then
  begin
    SetFill(C1);
    SetLine(C2);
    SetText(Extra);
  end
  else if Cmd = 'TX' then
  begin
    SetText(C1);
    SetFill(C2);
  end
  else if (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC') or (Cmd = 'TW') then
  begin
    SetFill(C1);
    SetLine(C2);
  end
  else if (Cmd = 'TR') or (Cmd = 'SB') or (Cmd = 'SW') then
  begin
    SetLine(C1);
    SetFill(C2);
  end
  else if Cmd = 'PB' then
  begin
    SetFill(C1);
    SetLine(Extra);
  end
  else if Cmd = 'BM' then
  begin
    SetText(C1);
    SetFill(C2);
  end;

  RefreshColorFieldShapes;
end;

//======================================================
// Выбирает строку таблицы и обновляет предпросмотр и панели свойств.
procedure TForm1.SelectRow(ARow: Integer);
begin
  if FSelectingRow then
    Exit;
  if ARow < 1 then
    ARow := 1;
  if ARow >= StringGrid1.RowCount then
    ARow := StringGrid1.RowCount - 1;
  FSelectingRow := True;
  try
    FSelectedRow := ARow;
    StringGrid1.Row := ARow;
    LoadInputsFromRow(ARow);
    UpdateDefaultColorsFromRow(ARow);
    StringGrid1.Invalidate;
    RepaintPreview;
  finally
    FSelectingRow := False;
  end;
end;

//======================================================
// Удаляет выбранную строку и выбирает ближайший оставшийся элемент.
procedure TForm1.DeleteSelectedRow;
var
  R: Integer;
  NextRow: Integer;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  NextRow := FSelectedRow;
  for R := FSelectedRow to StringGrid1.RowCount - 2 do
    StringGrid1.Rows[R].Assign(StringGrid1.Rows[R + 1]);
  if StringGrid1.RowCount > 2 then
    StringGrid1.RowCount := StringGrid1.RowCount - 1
  else
    StringGrid1.Rows[1].Clear;
  if NextRow >= StringGrid1.RowCount then
    NextRow := StringGrid1.RowCount - 1;
  SelectRow(NextRow);
end;

//======================================================
// Запрашивает перерисовку виртуального дисплея.
procedure TForm1.RepaintPreview;
begin
  if Assigned(FPreview) then
    FPreview.Invalidate;
end;

//======================================================
// Переводит координаты мыши предпросмотра в координаты LCD 480x320.
function TForm1.DisplayPoint(AX, AY: Integer): TPoint;
begin
  Result.X := Round(AX * 480 / FPreview.Width);
  Result.Y := Round(AY * 320 / FPreview.Height);
end;

//======================================================
// Определяет строку элемента под курсором на виртуальном дисплее.
function TForm1.HitRow(AX, AY: Integer; var AResize: Boolean): Integer;
var
  R: Integer;
  Rc: TRect;
  P: TPoint;
begin
  Result := -1;
  AResize := False;
  P := DisplayPoint(AX, AY);
  for R := StringGrid1.RowCount - 1 downto 1 do
    if RowRect(R, Rc) and PtInRect(Rc, P) then
    begin
      AResize := PtInRect(Rect(Rc.Right - 10, Rc.Bottom - 10, Rc.Right + 1, Rc.Bottom + 1), P);
      Result := R;
      Exit;
    end;
end;

//======================================================
// Записывает изменённые координаты и размер элемента в строку таблицы.
procedure TForm1.SetRowRect(ARow: Integer; const ARect: TRect);
var
  W: Integer;
  H: Integer;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top;
  if W < 8 then
    W := 8;
  if H < 8 then
    H := 8;
  StringGrid1.Cells[COL_X, ARow] := IntToStr(ARect.Left);
  StringGrid1.Cells[COL_Y, ARow] := IntToStr(ARect.Top);
  if UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow])) = 'JPG' then
    UpdateImageRowSize(ARow)
  else
  begin
    StringGrid1.Cells[COL_W, ARow] := IntToStr(W);
    StringGrid1.Cells[COL_H, ARow] := IntToStr(H);
  end;
  LoadInputsFromRow(ARow);
  RepaintPreview;
end;

//======================================================
// Возвращает полный путь к файлу скрипта рядом с программой.
function TForm1.ScriptFilePath(const AFileName: string): string;
begin
  Result := ExtractFilePath(ParamStr(0)) + AFileName;
end;

//======================================================
// Возвращает полный путь к ini-файлу настроек редактора.
function TForm1.ConfigFilePath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'NXTGUIMaker.ini';
end;

//======================================================
// Выбирает активное цветовое поле stroke/text/fill/screen.
procedure TForm1.SetActiveColorField(AField: TColorField);
begin
  FActiveColorField := AField;
  RefreshColorFieldShapes;
end;

//======================================================
// Создаёт подписи No color поверх цветовых полей при необходимости.
procedure TForm1.EnsureNoColorLabels;
var
  Field: TColorField;
begin
  for Field := Low(TColorField) to High(TColorField) do
  begin
    if not Assigned(FNoColorLabels[Field]) then
    begin
      FNoColorLabels[Field] := TLabel.Create(Self);
      FNoColorLabels[Field].Parent := Self;
      FNoColorLabels[Field].AutoSize := False;
      FNoColorLabels[Field].Alignment := taCenter;
      FNoColorLabels[Field].Layout := tlCenter;
      FNoColorLabels[Field].Transparent := True;
      FNoColorLabels[Field].Caption := 'No color';
      FNoColorLabels[Field].Font.Color := clGray;
      FNoColorLabels[Field].Font.Style := [fsBold];
      FNoColorLabels[Field].OnMouseDown := ColorFieldMouseDown;
      FNoColorLabels[Field].Visible := False;
    end;
  end;
end;

//======================================================
// Перерисовывает четыре цветовых поля и фон виртуального LCD.
procedure TForm1.RefreshColorFieldShapes;

  procedure SetupShape(AShape: TShape; AField: TColorField; const ARgb: string);
  begin
    if IsNoColorRgb(ARgb) then
    begin
      AShape.Brush.Color := clGray;
      AShape.Brush.Style := bsDiagCross;
    end
    else
    begin
      AShape.Brush.Style := bsSolid;
      AShape.Brush.Color := Rgb565ToColor(ARgb, AShape.Brush.Color);
    end;

    if FActiveColorField = AField then
    begin
      AShape.Pen.Color := clRed;
      AShape.Pen.Width := 3;
    end
    else
    begin
      if IsNoColorRgb(ARgb) then
        AShape.Pen.Color := clGray
      else
        AShape.Pen.Color := clBlack;
      AShape.Pen.Width := 1;
    end;

    if Assigned(FNoColorLabels[AField]) then
    begin
      FNoColorLabels[AField].SetBounds(AShape.Left, AShape.Top, AShape.Width, AShape.Height);
      FNoColorLabels[AField].Visible := IsNoColorRgb(ARgb);
      if FNoColorLabels[AField].Visible then
        FNoColorLabels[AField].BringToFront;
    end;
  end;

begin
  EnsureNoColorLabels;
  SetupShape(Shape6, cfLine, FDefaultLineRgb);
  SetupShape(Shape7, cfText, FDefaultFgRgb);
  SetupShape(Shape8, cfBack, FDefaultBgRgb);
  SetupShape(Shape9, cfLcdBack, FDefaultLcdBgRgb);
  if IsNoColorRgb(FDefaultLcdBgRgb) then
  begin
    Shape1.Brush.Color := clBlack;
    Shape1.Pen.Color := clBlack;
  end
  else
  begin
    Shape1.Brush.Color := Rgb565ToColor(FDefaultLcdBgRgb, Shape1.Brush.Color);
    Shape1.Pen.Color := Shape1.Brush.Color;
  end;
end;

//======================================================
// Применяет выбранный цвет палитры к активному цветовому полю и строке.
procedure TForm1.ApplyPaletteColorToActiveField(const ARgb: string; AColor: TColor);
var
  Cmd: string;
  HasRow: Boolean;
begin
  Cmd := '';
  HasRow := (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount);
  if HasRow then
    Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]));

  case FActiveColorField of
    cfLine:
      begin
        FDefaultLineRgb := ARgb;
        if HasRow then
        begin
          if Cmd = 'PB' then
            StringGrid1.Cells[COL_EXTRA, FSelectedRow] := ARgb
          else if (Cmd = 'TR') or (Cmd = 'SB') or (Cmd = 'SW') then
            StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb
          else
            StringGrid1.Cells[COL_C2, FSelectedRow] := ARgb;
        end;
      end;
    cfText:
      begin
        FDefaultFgRgb := ARgb;
        if HasRow then
        begin
          if Cmd = 'BT' then
            StringGrid1.Cells[COL_EXTRA, FSelectedRow] := ARgb
          else
            StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb;
        end;
      end;
    cfBack:
      begin
        FDefaultBgRgb := ARgb;
        if HasRow then
        begin
          if (Cmd = 'TX') or (Cmd = 'BM') or (Cmd = 'TR') or
            (Cmd = 'SB') or (Cmd = 'SW') then
            StringGrid1.Cells[COL_C2, FSelectedRow] := ARgb
          else
            StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb;
        end;
      end;
    cfLcdBack:
      begin
        FDefaultLcdBgRgb := ARgb;
        if IsNoColorRgb(ARgb) then
          FLcdBgColor := clBlack
        else
          FLcdBgColor := AColor;
        if HasRow and (Cmd = 'CL') then
          StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb;
      end;
  end;

  RefreshColorFieldShapes;
  if Assigned(StringGrid2) then
    StringGrid2.Invalidate;
  if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
  begin
    Edit1.Text := ScriptFromRow(FSelectedRow);
    LoadInputsFromRow(FSelectedRow);
  end;
  RepaintPreview;
  SaveSettings;
end;

//======================================================
// Обрабатывает выбор цветового поля и назначение No color правой кнопкой.
procedure TForm1.ColorFieldMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Field: TColorField;
  Found: Boolean;
begin
  Field := cfText;
  Found := True;
  if Sender = Shape6 then
    Field := cfLine
  else if Sender = Shape7 then
    Field := cfText
  else if Sender = Shape8 then
    Field := cfBack
  else if Sender = Shape9 then
    Field := cfLcdBack
  else if Sender = FNoColorLabels[cfLine] then
    Field := cfLine
  else if Sender = FNoColorLabels[cfText] then
    Field := cfText
  else if Sender = FNoColorLabels[cfBack] then
    Field := cfBack
  else if Sender = FNoColorLabels[cfLcdBack] then
    Field := cfLcdBack
  else
    Found := False;

  if not Found then
    Exit;

  if Button = mbLeft then
    SetActiveColorField(Field)
  else if Button = mbRight then
  begin
    SetActiveColorField(Field);
    ApplyPaletteColorToActiveField('0x0001', clBtnFace);
  end;
end;

//======================================================
// Загружает сохранённые настройки редактора из ini-файла.
procedure TForm1.LoadSettings;
var
  Ini: TIniFile;
  PortName: string;
  LcdBgRgb: string;
begin
  if not FileExists(ConfigFilePath) then
    Exit;
  Ini := TIniFile.Create(ConfigFilePath);
  try
    PortName := Ini.ReadString('Connection', 'ComPort', ComboBox1.Text);
    if ComboBox1.Items.IndexOf(PortName) < 0 then
      ComboBox1.Items.Add(PortName);
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(PortName);
    CheckBox1.Checked := Ini.ReadBool('Connection', 'Rts', CheckBox1.Checked);
    CheckBox2.Checked := Ini.ReadBool('Connection', 'ComEnabled', CheckBox2.Checked);
    CheckBox3.Checked := Ini.ReadBool('Connection', 'UdpEnabled', CheckBox3.Checked);
    CheckBox4.Checked := Ini.ReadBool('Upload', 'RewriteImage', CheckBox4.Checked);
    Edit2.Text := Ini.ReadString('Connection', 'UdpIp', Edit2.Text);
    Edit3.Text := Ini.ReadString('Connection', 'UdpPort', Edit3.Text);
    FDefaultLineRgb := Ini.ReadString('Colors', 'Stroke',
      Ini.ReadString('Colors', 'Line', FDefaultLineRgb));
    FDefaultFgRgb := Ini.ReadString('Colors', 'Text',
      Ini.ReadString('Colors', 'Foreground', FDefaultFgRgb));
    FDefaultBgRgb := Ini.ReadString('Colors', 'Fill',
      Ini.ReadString('Colors', 'Back',
      Ini.ReadString('Colors', 'Background', FDefaultBgRgb)));
    LcdBgRgb := Ini.ReadString('Colors', 'Screen',
      Ini.ReadString('Colors', 'LcdBackground', Rgb565Text(Shape1.Brush.Color)));
    FDefaultLcdBgRgb := LcdBgRgb;
    if IsNoColorRgb(LcdBgRgb) then
      Shape1.Brush.Color := clBlack
    else
      Shape1.Brush.Color := Rgb565ToColor(LcdBgRgb, Shape1.Brush.Color);
    Shape1.Pen.Color := Shape1.Brush.Color;
    FLcdBgColor := Shape1.Brush.Color;
    if (StringGrid1.RowCount > 1) and (Trim(StringGrid1.Cells[COL_CMD, 1]) = '') then
    begin
      StringGrid1.Cells[COL_C1, 1] := FDefaultFgRgb;
      StringGrid1.Cells[COL_C2, 1] := FDefaultBgRgb;
    end;
    RefreshColorFieldShapes;
    UdpCheckClick(CheckBox3);
  finally
    Ini.Free;
  end;
end;

//======================================================
// Сохраняет текущие настройки редактора в ini-файл.
procedure TForm1.SaveSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ConfigFilePath);
  try
    Ini.WriteString('Connection', 'ComPort', ComboBox1.Text);
    Ini.WriteBool('Connection', 'Rts', CheckBox1.Checked);
    Ini.WriteBool('Connection', 'ComEnabled', CheckBox2.Checked);
    Ini.WriteBool('Connection', 'UdpEnabled', CheckBox3.Checked);
    Ini.WriteBool('Upload', 'RewriteImage', CheckBox4.Checked);
    Ini.WriteString('Connection', 'UdpIp', Edit2.Text);
    Ini.WriteString('Connection', 'UdpPort', Edit3.Text);
    Ini.WriteString('Colors', 'Stroke', FDefaultLineRgb);
    Ini.WriteString('Colors', 'Text', FDefaultFgRgb);
    Ini.WriteString('Colors', 'Fill', FDefaultBgRgb);
    Ini.WriteString('Colors', 'Screen', FDefaultLcdBgRgb);
  finally
    Ini.Free;
  end;
end;

//======================================================
// Проверяет, включена ли отправка команд через serial.
function TForm1.SerialEnabled: Boolean;
begin
  Result := CheckBox2.Checked;
end;

//======================================================
// Проверяет, включена ли отправка команд через UDP.
function TForm1.UdpEnabled: Boolean;
begin
  Result := CheckBox3.Checked;
end;

//======================================================
// Создаёт и настраивает UDP-сокет для команд и событий ESP.
function TForm1.EnsureUdpSocket(ABroadcast: Boolean): Boolean;
var
  Opt: Integer;
  NonBlocking: u_long;
begin
  Result := FUdpSocket <> INVALID_SOCKET;
  if not Result then
  begin
    FUdpSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if FUdpSocket = INVALID_SOCKET then
    begin
      SetUdpStateColor(clGray);
      StatusBar1.SimpleText := 'UDP socket error';
      Exit;
    end;

    NonBlocking := 1;
    ioctlsocket(FUdpSocket, FIONBIO, NonBlocking);
    Result := True;
  end;

  if ABroadcast then
  begin
    Opt := 1;
    setsockopt(FUdpSocket, SOL_SOCKET, SO_BROADCAST, PAnsiChar(@Opt), SizeOf(Opt));
  end;
end;

//======================================================
// Закрывает UDP-сокет редактора.
procedure TForm1.CloseUdpSocket;
begin
  if FUdpSocket <> INVALID_SOCKET then
  begin
    closesocket(FUdpSocket);
    FUdpSocket := INVALID_SOCKET;
  end;
end;

//======================================================
// Сохраняет текущую таблицу команд в текстовый файл скрипта.
procedure TForm1.SaveDesignToFile(const AFileName: string);
var
  SL: TStringList;
  R: Integer;
  Line: string;
begin
  SL := TStringList.Create;
  try
    for R := 1 to StringGrid1.RowCount - 1 do
    begin
      Line := Trim(ScriptFromRow(R));
      if Line <> '' then
        SL.Add(Line);
    end;
    SL.SaveToFile(ScriptFilePath(AFileName));
    StatusBar1.SimpleText := 'Saved ' + AFileName + ': ' + IntToStr(SL.Count) + ' lines';
  finally
    SL.Free;
  end;
end;

//======================================================
// Загружает скрипт из файла в таблицу команд.
procedure TForm1.LoadDesignFromFile(const AFileName: string);
var
  SL: TStringList;
  I: Integer;
begin
  if not FileExists(ScriptFilePath(AFileName)) then
  begin
    StatusBar1.SimpleText := 'File not found: ' + AFileName;
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(ScriptFilePath(AFileName));
    StringGrid1.RowCount := 2;
    StringGrid1.Rows[1].Clear;
    FSelectedRow := 1;
    for I := 0 to SL.Count - 1 do
      AddScriptLine(SL[I]);
    if (StringGrid1.RowCount > 1) and (Trim(StringGrid1.Cells[COL_CMD, 1]) <> '') then
      SelectRow(1)
    else
      SelectRow(1);
    StatusBar1.SimpleText := 'Loaded ' + AFileName + ': ' + IntToStr(SL.Count) + ' lines';
  finally
    SL.Free;
  end;
end;

//======================================================
// Отправляет одну команду по UDP и ожидает ответ ESP.
function TForm1.UdpExchangeLine(const ALine, AHost: string; ABroadcast: Boolean; var AReply: string): Boolean;
var
  Addr: TSockAddrIn;
  FromAddr: TSockAddrIn;
  FromLen: Integer;
  HostText: AnsiString;
  Data: AnsiString;
  Buffer: array[0..511] of AnsiChar;
  Port: Integer;
  ReadCount: Integer;
  StartedAt: DWORD;
  ReceivedLine: string;
begin
  Result := False;
  AReply := '';

  HostText := AnsiString(Trim(AHost));
  Port := StrToIntDef(Trim(Edit3.Text), 4210);
  if (HostText = '') or (Port <= 0) or (Port > 65535) then
  begin
    SetUdpStateColor(clGray);
    StatusBar1.SimpleText := 'UDP address error';
    Exit;
  end;

  if not EnsureUdpSocket(ABroadcast) then
    Exit;

  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);
  Addr.sin_addr.S_addr := inet_addr(PAnsiChar(HostText));
  if Addr.sin_addr.S_addr = INADDR_NONE then
  begin
    SetUdpStateColor(clGray);
    StatusBar1.SimpleText := 'UDP IP error: ' + string(HostText);
    Exit;
  end;

  Data := AnsiString(ALine);
  if sendto(FUdpSocket, PAnsiChar(Data)^, Length(Data), 0, Addr, SizeOf(Addr)) <> Length(Data) then
  begin
    CloseUdpSocket;
    SetUdpStateColor(clGray);
    StatusBar1.SimpleText := 'UDP send error';
    Exit;
  end;

  StartedAt := GetTickCount;
  repeat
    FromLen := SizeOf(FromAddr);
    ReadCount := recvfrom(FUdpSocket, Buffer, SizeOf(Buffer) - 1, 0, FromAddr, FromLen);
    if ReadCount > 0 then
    begin
      Buffer[ReadCount] := #0;
      ReceivedLine := Trim(string(Buffer));
      if Pos('EV|', UpperCase(ReceivedLine)) = 1 then
      begin
        HandleRxLine(ReceivedLine);
        Continue;
      end;
      AReply := ReceivedLine;
      Result := True;
      Break;
    end;
    Application.ProcessMessages;
    Sleep(10);
  until GetTickCount - StartedAt > 3000;

  if Result then
    SetUdpStateColor(clLime)
  else
  begin
    SetUdpStateColor(clGray);
    AReply := 'timeout';
    StatusBar1.SimpleText := 'UDP no reply: ' + string(HostText);
  end;
end;

//======================================================
// Считывает асинхронные UDP-события от ESP.
procedure TForm1.PollUdpInput;
var
  FromAddr: TSockAddrIn;
  FromLen: Integer;
  Buffer: array[0..511] of AnsiChar;
  ReadCount: Integer;
  Line: string;
begin
  if (not UdpEnabled) or (FUdpSocket = INVALID_SOCKET) then
    Exit;

  repeat
    FromLen := SizeOf(FromAddr);
    ReadCount := recvfrom(FUdpSocket, Buffer, SizeOf(Buffer) - 1, 0, FromAddr, FromLen);
    if ReadCount > 0 then
    begin
      Buffer[ReadCount] := #0;
      Line := Trim(string(Buffer));
      if Line <> '' then
        HandleRxLine(Line);
    end;
  until ReadCount <= 0;
end;

//======================================================
// Отправляет строку команды по UDP.
function TForm1.SendUdpLine(const ALine: string): Boolean;
var
  Reply: string;
begin
  Result := False;
  if not UdpEnabled then
    Exit;
  Result := UdpExchangeLine(ALine, Trim(Edit2.Text), False, Reply);
  if Result and (Reply <> '') then
    StatusBar1.SimpleText := 'UDP RX: ' + Trim(Reply);
end;

//======================================================
// Отправляет строку команды по serial-порту.
procedure TForm1.SendSerialLine(const ALine: string);
var
  Data: AnsiString;
  Written: DWORD;
begin
  if ALine = '' then
    Exit;
  if FPort = INVALID_HANDLE_VALUE then
  begin
    StatusBar1.SimpleText := 'Port is closed: ' + ComboBox1.Text;
    Exit;
  end;
  if not PortAlive then
  begin
    StatusBar1.SimpleText := 'Port lost before write: ' + ComboBox1.Text;
    ClosePort(True);
    Exit;
  end;
  Data := AnsiString(ALine + #13#10);
  if (not WriteFile(FPort, PAnsiChar(Data)^, Length(Data), Written, nil)) or
    (Written <> DWORD(Length(Data))) then
  begin
    StatusBar1.SimpleText := 'Port write error: ' + ComboBox1.Text;
    ClosePort(True);
  end;
end;

//======================================================
// Отправляет команду через выбранные каналы связи.
procedure TForm1.SendLine(const ALine: string);
var
  Sent: Boolean;
begin
  if ALine = '' then
    Exit;

  Sent := False;
  if SerialEnabled then
  begin
    if FPort <> INVALID_HANDLE_VALUE then
    begin
      SendSerialLine(ALine);
      Sent := FPort <> INVALID_HANDLE_VALUE;
    end
    else if not UdpEnabled then
      StatusBar1.SimpleText := 'Port is closed: ' + ComboBox1.Text;
  end;

  if UdpEnabled then
    Sent := SendUdpLine(ALine) or Sent;

  if not Sent then
    StatusBar1.SimpleText := 'No active output channel';
end;

//======================================================
// Изменяет цвет индикатора состояния COM-порта.
procedure TForm1.SetPortStateColor(AColor: TColor);
begin
  Shape4.Brush.Color := AColor;
end;

//======================================================
// Изменяет цвет индикатора состояния UDP-соединения.
procedure TForm1.SetUdpStateColor(AColor: TColor);
begin
  Shape5.Brush.Color := AColor;
end;

//======================================================
// Проверяет, доступен ли открытый COM-порт.
function TForm1.PortAlive: Boolean;
var
  Errors: DWORD;
  Stat: TComStat;
begin
  Result := False;
  if FPort = INVALID_HANDLE_VALUE then
    Exit;
  FillChar(Stat, SizeOf(Stat), 0);
  Errors := 0;
  Result := ClearCommError(FPort, Errors, @Stat);
end;

//======================================================
// Считывает накопленные строки ответа из serial-порта.
procedure TForm1.PollPortInput;
var
  Buffer: array[0..127] of AnsiChar;
  ReadCount: DWORD;
  Chunk: AnsiString;
  P: Integer;
  Line: string;
begin
  if FPort = INVALID_HANDLE_VALUE then
    Exit;

  repeat
    ReadCount := 0;
    if not ReadFile(FPort, Buffer, SizeOf(Buffer), ReadCount, nil) then
    begin
      StatusBar1.SimpleText := 'Port read error: ' + ComboBox1.Text;
      ClosePort(True);
      Exit;
    end;

    if ReadCount > 0 then
    begin
      SetString(Chunk, PAnsiChar(@Buffer[0]), ReadCount);
      FPortRxText := FPortRxText + Chunk;
      P := Pos(#10, string(FPortRxText));
      while P > 0 do
      begin
        Line := Trim(Copy(string(FPortRxText), 1, P - 1));
        Delete(FPortRxText, 1, P);
        if Line <> '' then
          HandleRxLine(Line);
        P := Pos(#10, string(FPortRxText));
      end;
      if Length(FPortRxText) > 200 then
      begin
        StatusBar1.SimpleText := 'RX: ' + string(FPortRxText);
        FPortRxText := '';
      end;
    end;
  until ReadCount = 0;
end;

//======================================================
// Обрабатывает входящую строку от ESP и обновляет состояние D7.
procedure TForm1.HandleRxLine(const ALine: string);
var
  Parts: TStringList;
  Kind: string;
  EventName: string;
  IdText: string;
  ValueText: string;
  R: Integer;
begin
  StatusBar1.SimpleText := 'RX: ' + ALine;
  Parts := TStringList.Create;
  try
    SplitPipe(Trim(ALine), Parts);
    if (Parts.Count >= 2) and (UpperCase(Parts[0]) = 'IP') then
    begin
      Edit2.Text := Parts[1];
      CheckBox3.Checked := True;
      SetUdpStateColor(clLime);
      SaveSettings;
      StatusBar1.SimpleText := 'ESP IP: ' + Edit2.Text;
    end;
    if (Parts.Count >= 4) and (UpperCase(Parts[0]) = 'EV') then
    begin
      Kind := UpperCase(Parts[1]);
      IdText := Parts[2];
      EventName := UpperCase(Parts[3]);
      if ((Kind = 'TR') or (Kind = 'SW')) and (Parts.Count >= 7) then
      begin
        ValueText := Parts[4];
        StatusBar1.SimpleText := 'Touch ' + Kind + ' #' + IdText + ' ' +
          EventName + ' = ' + ValueText;
        if EventName = 'CHANGE' then
        begin
          for R := 1 to StringGrid1.RowCount - 1 do
          begin
            if (UpperCase(Trim(StringGrid1.Cells[COL_CMD, R])) = Kind) and
              (Trim(StringGrid1.Cells[COL_ID, R]) = IdText) then
            begin
              StringGrid1.Cells[COL_TEXT, R] := ValueText;
              if R = FSelectedRow then
                LoadInputsFromRow(R)
              else
                Edit1.Text := ScriptFromRow(FSelectedRow);
              RepaintPreview;
              Break;
            end;
          end;
        end;
      end
      else if (Kind = 'BT') and (Parts.Count >= 6) then
        StatusBar1.SimpleText := 'Touch BT #' + IdText + ' ' + EventName;
    end;
  finally
    Parts.Free;
  end;
end;

//======================================================
// Устанавливает или снимает RTS на открытом COM-порту.
procedure TForm1.ApplyRts;
begin
  if FPort = INVALID_HANDLE_VALUE then
    Exit;

  if CheckBox1.Checked then
  begin
    if not EscapeCommFunction(FPort, SETRTS) then
    begin
      StatusBar1.SimpleText := 'RTS set error: ' + ComboBox1.Text;
      ClosePort(True);
      Exit;
    end;
    StatusBar1.SimpleText := 'RTS set: ' + ComboBox1.Text;
  end
  else
  begin
    if not EscapeCommFunction(FPort, CLRRTS) then
    begin
      StatusBar1.SimpleText := 'RTS clear error: ' + ComboBox1.Text;
      ClosePort(True);
      Exit;
    end;
    StatusBar1.SimpleText := 'RTS clear: ' + ComboBox1.Text;
  end;
end;

//======================================================
// Открывает или закрывает выбранный COM-порт.
procedure TForm1.OpenClosePort;
var
  Dcb: TDCB;
  Timeouts: TCommTimeouts;
begin
  if FPort <> INVALID_HANDLE_VALUE then
  begin
    ClosePort;
    Exit;
  end;

  FPort := CreateFile(PChar(PortWinApiName(ComboBox1.Text)), GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if FPort = INVALID_HANDLE_VALUE then
  begin
    SetPortStateColor(clGray);
    StatusBar1.SimpleText := 'Port open error: ' + ComboBox1.Text;
    Exit;
  end;

  FillChar(Dcb, SizeOf(Dcb), 0);
  Dcb.DCBlength := SizeOf(Dcb);
  if not GetCommState(FPort, Dcb) then
  begin
    StatusBar1.SimpleText := 'Port state error: ' + ComboBox1.Text;
    ClosePort(True);
    Exit;
  end;
  Dcb.BaudRate := 115200;
  Dcb.ByteSize := 8;
  Dcb.Parity := NOPARITY;
  Dcb.StopBits := ONESTOPBIT;
  if not SetCommState(FPort, Dcb) then
  begin
    StatusBar1.SimpleText := 'Port setup error: ' + ComboBox1.Text;
    ClosePort(True);
    Exit;
  end;
  FillChar(Timeouts, SizeOf(Timeouts), 0);
  Timeouts.ReadIntervalTimeout := 20;
  Timeouts.ReadTotalTimeoutConstant := 1;
  Timeouts.WriteTotalTimeoutConstant := 300;
  SetCommTimeouts(FPort, Timeouts);
  ApplyRts;
  if FPort = INVALID_HANDLE_VALUE then
    Exit;
  SetPortStateColor(clLime);
  FPortRxText := '';
  if Assigned(FPortMonitor) then
    FPortMonitor.Enabled := True;
  StatusBar1.SimpleText := 'Opened ' + ComboBox1.Text + ', 115200 baud';
end;

//======================================================
// Закрывает COM-порт и обновляет состояние интерфейса.
procedure TForm1.ClosePort(AErrorState: Boolean = False);
begin
  if Assigned(FPortMonitor) then
    FPortMonitor.Enabled := UdpEnabled;
  if FPort <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FPort);
    FPort := INVALID_HANDLE_VALUE;
  end;
  FPortRxText := '';
  if AErrorState then
  begin
    SetPortStateColor(clGray);
  end
  else
  begin
    SetPortStateColor(clGreen);
    StatusBar1.SimpleText := 'Closed ' + ComboBox1.Text;
  end;
end;

//======================================================
// Рисует виртуальный LCD и все элементы текущего скрипта.
procedure TForm1.PreviewPaint(Sender: TObject);
var
  R: Integer;
  Rc: TRect;
  Sx: Double;
  Sy: Double;
  DrawRc: TRect;
  Cmd: string;
  C1: TColor;
  C2: TColor;
  Value: Integer;
  LineWidth: Integer;
  Radius: Integer;
  TrackHeight: Integer;
  KnobRadius: Integer;
  KnobX: Integer;
  KnobY: Integer;
  BarRc: TRect;
  SrcRc: TRect;
  Picture: TPicture;
  ImageFileName: string;

  procedure DrawClippedGraphic(AGraphic: TGraphic; const ADest, ASource: TRect);
  var
    VisibleRc: TRect;
    SourceRc: TRect;
    BaseSrc: TRect;
    Bitmap: TBitmap;
    DestW: Integer;
    DestH: Integer;

    function IMax(A, B: Integer): Integer;
    begin
      if A > B then
        Result := A
      else
        Result := B;
    end;

    function IMin(A, B: Integer): Integer;
    begin
      if A < B then
        Result := A
      else
        Result := B;
    end;
  begin
    if (AGraphic = nil) or AGraphic.Empty then
      Exit;

    DestW := ADest.Right - ADest.Left;
    DestH := ADest.Bottom - ADest.Top;
    if (DestW <= 0) or (DestH <= 0) then
      Exit;

    VisibleRc := Rect(
      IMax(ADest.Left, 0),
      IMax(ADest.Top, 0),
      IMin(ADest.Right, FPreview.Width),
      IMin(ADest.Bottom, FPreview.Height));
    if (VisibleRc.Left >= VisibleRc.Right) or (VisibleRc.Top >= VisibleRc.Bottom) then
      Exit;

    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := AGraphic.Width;
      Bitmap.Height := AGraphic.Height;
      Bitmap.Canvas.Brush.Color := clBlack;
      Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
      Bitmap.Canvas.Draw(0, 0, AGraphic);

      BaseSrc := ASource;
      if BaseSrc.Left < 0 then
        BaseSrc.Left := 0;
      if BaseSrc.Top < 0 then
        BaseSrc.Top := 0;
      if BaseSrc.Right > Bitmap.Width then
        BaseSrc.Right := Bitmap.Width;
      if BaseSrc.Bottom > Bitmap.Height then
        BaseSrc.Bottom := Bitmap.Height;
      if (BaseSrc.Right <= BaseSrc.Left) or (BaseSrc.Bottom <= BaseSrc.Top) then
        BaseSrc := Rect(0, 0, Bitmap.Width, Bitmap.Height);

      SourceRc.Left := BaseSrc.Left + MulDiv(VisibleRc.Left - ADest.Left, BaseSrc.Right - BaseSrc.Left, DestW);
      SourceRc.Top := BaseSrc.Top + MulDiv(VisibleRc.Top - ADest.Top, BaseSrc.Bottom - BaseSrc.Top, DestH);
      SourceRc.Right := BaseSrc.Left + MulDiv(VisibleRc.Right - ADest.Left, BaseSrc.Right - BaseSrc.Left, DestW);
      SourceRc.Bottom := BaseSrc.Top + MulDiv(VisibleRc.Bottom - ADest.Top, BaseSrc.Bottom - BaseSrc.Top, DestH);
      FPreview.Canvas.CopyRect(VisibleRc, Bitmap.Canvas, SourceRc);
    finally
      Bitmap.Free;
    end;
  end;
begin
  FPreview.Canvas.Brush.Color := ColorToRGB(FLcdBgColor);
  FPreview.Canvas.FillRect(Rect(0, 0, FPreview.Width, FPreview.Height));
  Sx := FPreview.Width / 480;
  Sy := FPreview.Height / 320;

  for R := 1 to StringGrid1.RowCount - 1 do
  begin
    if not RowRect(R, Rc) then
      Continue;
    DrawRc := Rect(Round(Rc.Left * Sx), Round(Rc.Top * Sy), Round(Rc.Right * Sx), Round(Rc.Bottom * Sy));
    Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, R]));
    C1 := Rgb565ToColor(StringGrid1.Cells[COL_C1, R], clWhite);
    C2 := Rgb565ToColor(StringGrid1.Cells[COL_C2, R], clGray);

    if Cmd = 'TX' then
    begin
      ApplyPreviewFont(StrToIntDef(StringGrid1.Cells[COL_FONT, R], 2));
      FPreview.Canvas.Font.Color := C1;
      if not IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
      begin
        FPreview.Canvas.Brush.Color := C2;
        FPreview.Canvas.FillRect(DrawRc);
      end;
      if not IsNoColorRgb(StringGrid1.Cells[COL_C1, R]) then
        DrawAlignedPreviewText(StringGrid1.Cells[COL_TEXT, R], DrawRc,
          StringGrid1.Cells[COL_HALIGN, R], StringGrid1.Cells[COL_VALIGN, R]);
    end
    else if Cmd = 'BT' then
    begin
      LineWidth := StrToIntDef(StringGrid1.Cells[COL_LINE, R], 1);
      if LineWidth < 1 then
        LineWidth := 1;
      if LineWidth > 4 then
        LineWidth := 4;
      if IsNoColorRgb(StringGrid1.Cells[COL_C1, R]) then
        FPreview.Canvas.Brush.Style := bsClear
      else
      begin
        FPreview.Canvas.Brush.Style := bsSolid;
        FPreview.Canvas.Brush.Color := C1;
      end;
      if IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
        FPreview.Canvas.Pen.Style := psClear
      else
      begin
        FPreview.Canvas.Pen.Style := psSolid;
        FPreview.Canvas.Pen.Color := C2;
      end;
      FPreview.Canvas.Pen.Width := LineWidth;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom, 10, 10);
      FPreview.Canvas.Pen.Width := 1;
      FPreview.Canvas.Pen.Style := psSolid;
      FPreview.Canvas.Brush.Style := bsSolid;
      ApplyPreviewFont(StrToIntDef(StringGrid1.Cells[COL_FONT, R], 2));
      FPreview.Canvas.Font.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], clWhite);
      if not IsNoColorRgb(StringGrid1.Cells[COL_EXTRA, R]) then
        DrawAlignedPreviewText(StringGrid1.Cells[COL_TEXT, R], DrawRc,
          StringGrid1.Cells[COL_HALIGN, R], StringGrid1.Cells[COL_VALIGN, R]);
    end
    else if Cmd = 'TW' then
    begin
      if IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
        FPreview.Canvas.Pen.Style := psClear
      else
      begin
        FPreview.Canvas.Pen.Style := psSolid;
        FPreview.Canvas.Pen.Color := C2;
      end;
      if IsNoColorRgb(StringGrid1.Cells[COL_C1, R]) then
        FPreview.Canvas.Brush.Style := bsClear
      else
      begin
        FPreview.Canvas.Brush.Style := bsSolid;
        FPreview.Canvas.Brush.Color := C1;
      end;
      FPreview.Canvas.Rectangle(DrawRc);
      FPreview.Canvas.Pen.Style := psSolid;
      FPreview.Canvas.Brush.Style := bsSolid;
      FPreview.Canvas.Font.Color := clWhite;
      if not IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
        FPreview.Canvas.TextOut(DrawRc.Left + 6, DrawRc.Top + 6, StringGrid1.Cells[COL_TEXT, R]);
    end
    else if (Cmd = 'BX') or (Cmd = 'RR') then
    begin
      LineWidth := StrToIntDef(StringGrid1.Cells[COL_LINE, R], 1);
      if LineWidth < 1 then
        LineWidth := 1;
      if LineWidth > 4 then
        LineWidth := 4;
      if Cmd = 'RR' then
      begin
        Radius := StrToIntDef(StringGrid1.Cells[COL_EXTRA, R], 0);
        if Radius < 0 then
          Radius := 0;
      end
      else
        Radius := 0;
      if IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
        FPreview.Canvas.Pen.Style := psClear
      else
      begin
        FPreview.Canvas.Pen.Style := psSolid;
        FPreview.Canvas.Pen.Color := C2;
      end;
      FPreview.Canvas.Pen.Width := LineWidth;
      if IsNoColorRgb(StringGrid1.Cells[COL_C1, R]) then
        FPreview.Canvas.Brush.Style := bsClear
      else
      begin
        FPreview.Canvas.Brush.Style := bsSolid;
        FPreview.Canvas.Brush.Color := C1;
      end;
      if Radius > 0 then
        FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom,
          Radius * 2, Radius * 2)
      else
        FPreview.Canvas.Rectangle(DrawRc);
      FPreview.Canvas.Pen.Width := 1;
      FPreview.Canvas.Pen.Style := psSolid;
      FPreview.Canvas.Brush.Style := bsSolid;
    end
    else if Cmd = 'CC' then
    begin
      LineWidth := StrToIntDef(StringGrid1.Cells[COL_LINE, R], 1);
      if LineWidth < 1 then
        LineWidth := 1;
      if LineWidth > 4 then
        LineWidth := 4;
      if IsNoColorRgb(StringGrid1.Cells[COL_C2, R]) then
        FPreview.Canvas.Pen.Style := psClear
      else
      begin
        FPreview.Canvas.Pen.Style := psSolid;
        FPreview.Canvas.Pen.Color := C2;
      end;
      FPreview.Canvas.Pen.Width := LineWidth;
      if IsNoColorRgb(StringGrid1.Cells[COL_C1, R]) then
        FPreview.Canvas.Brush.Style := bsClear
      else
      begin
        FPreview.Canvas.Brush.Style := bsSolid;
        FPreview.Canvas.Brush.Color := C1;
      end;
      FPreview.Canvas.Ellipse(DrawRc);
      FPreview.Canvas.Pen.Width := 1;
      FPreview.Canvas.Pen.Style := psSolid;
      FPreview.Canvas.Brush.Style := bsSolid;
    end
    else if Cmd = 'TR' then
    begin
      Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, R], 50);
      if Value < 0 then
        Value := 0;
      if Value > 100 then
        Value := 100;

      TrackHeight := (DrawRc.Bottom - DrawRc.Top) div 2;
      if TrackHeight < 2 then
        TrackHeight := 2;
      KnobRadius := (DrawRc.Bottom - DrawRc.Top) div 2;
      if KnobRadius < 1 then
        KnobRadius := 1;
      KnobX := DrawRc.Left + KnobRadius +
        ((DrawRc.Right - DrawRc.Left - KnobRadius * 2) * Value div 100);
      KnobY := DrawRc.Top + (DrawRc.Bottom - DrawRc.Top) div 2;
      BarRc := Rect(DrawRc.Left, KnobY - TrackHeight div 2,
        DrawRc.Right, KnobY - TrackHeight div 2 + TrackHeight);

      FPreview.Canvas.Pen.Color := C1;
      FPreview.Canvas.Brush.Color := C1;
      FPreview.Canvas.RoundRect(BarRc.Left, BarRc.Top, BarRc.Right, BarRc.Bottom,
        TrackHeight, TrackHeight);
      FPreview.Canvas.Pen.Color := LightenColor(C2, 45);
      FPreview.Canvas.Brush.Color := LightenColor(C2, 45);
      FPreview.Canvas.RoundRect(BarRc.Left, BarRc.Top, KnobX, BarRc.Bottom,
        TrackHeight, TrackHeight);
      FPreview.Canvas.Pen.Color := clBlack;
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.Ellipse(KnobX - KnobRadius, KnobY - KnobRadius,
        KnobX + KnobRadius, KnobY + KnobRadius);
    end
    else if Cmd = 'PB' then
    begin
      Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, R], 50);
      if Value < 0 then
        Value := 0;
      if Value > 100 then
        Value := 100;
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.Pen.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], clYellow);
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom, 8, 8);
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.FillRect(Rect(DrawRc.Left + 2, DrawRc.Top + 2, DrawRc.Right - 2, DrawRc.Bottom - 2));
      FPreview.Canvas.Brush.Color := C1;
      FPreview.Canvas.Pen.Color := C1;
      FPreview.Canvas.FillRect(Rect(DrawRc.Left + 2, DrawRc.Top + 2,
        DrawRc.Left + 2 + (DrawRc.Right - DrawRc.Left - 4) * Value div 100, DrawRc.Bottom - 2));
      FPreview.Canvas.Pen.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], clYellow);
      FPreview.Canvas.Brush.Style := bsClear;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom, 8, 8);
      FPreview.Canvas.Brush.Style := bsSolid;
    end
    else if Cmd = 'SW' then
    begin
      Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, R], 1);
      KnobRadius := (DrawRc.Bottom - DrawRc.Top) div 2;
      TrackHeight := (DrawRc.Bottom - DrawRc.Top) div 14;
      if TrackHeight < 2 then
        TrackHeight := 2;
      if Value = 0 then
        KnobX := DrawRc.Left + KnobRadius
      else
        KnobX := DrawRc.Right - KnobRadius;
      KnobY := DrawRc.Top + (DrawRc.Bottom - DrawRc.Top) div 2;

      FPreview.Canvas.Brush.Color := C1;
      FPreview.Canvas.Pen.Width := TrackHeight;
      FPreview.Canvas.Pen.Color := C1;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom,
        DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      if Value <> 0 then
      begin
        FPreview.Canvas.Brush.Color := LightenColor(C2, 45);
        FPreview.Canvas.Pen.Color := LightenColor(C2, 45);
        FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top,
          KnobX + KnobRadius, DrawRc.Bottom,
          DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      end;

      FPreview.Canvas.Pen.Width := TrackHeight;
      FPreview.Canvas.Pen.Color := C1;
      FPreview.Canvas.Brush.Style := bsClear;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom,
        DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      FPreview.Canvas.Pen.Width := 1;
      FPreview.Canvas.Brush.Style := bsSolid;
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.Pen.Color := clBlack;
      FPreview.Canvas.Ellipse(KnobX - KnobRadius + TrackHeight * 2,
        KnobY - KnobRadius + TrackHeight * 2,
        KnobX + KnobRadius - TrackHeight * 2,
        KnobY + KnobRadius - TrackHeight * 2);
    end
    else if Cmd = 'BM' then
    begin
      if (Image4.Picture.Graphic <> nil) and (not Image4.Picture.Graphic.Empty) then
        FPreview.Canvas.StretchDraw(DrawRc, Image4.Picture.Graphic)
      else
      begin
        FPreview.Canvas.Brush.Color := C1;
        FPreview.Canvas.Pen.Color := C2;
        FPreview.Canvas.Rectangle(DrawRc);
        FPreview.Canvas.TextOut(DrawRc.Left + 2, DrawRc.Top + 2, StringGrid1.Cells[COL_TEXT, R]);
      end;
    end
    else if Cmd = 'JPG' then
    begin
      ImageFileName := LocalImagePathFromCommandPath(StringGrid1.Cells[COL_TEXT, R]);
      if FileExists(ImageFileName) then
      begin
        Picture := TPicture.Create;
        try
          try
            Picture.LoadFromFile(ImageFileName);
            SrcRc := Rect(StrToIntDef(StringGrid1.Cells[COL_SRCX, R], 0),
              StrToIntDef(StringGrid1.Cells[COL_SRCY, R], 0),
              StrToIntDef(StringGrid1.Cells[COL_SRCX, R], 0) + StrToIntDef(StringGrid1.Cells[COL_SRCW, R], 0),
              StrToIntDef(StringGrid1.Cells[COL_SRCY, R], 0) + StrToIntDef(StringGrid1.Cells[COL_SRCH, R], 0));
            if (SrcRc.Right <= SrcRc.Left) or (SrcRc.Bottom <= SrcRc.Top) then
              SrcRc := Rect(0, 0, Picture.Width, Picture.Height);
            DrawClippedGraphic(Picture.Graphic, DrawRc, SrcRc);
          except
            FPreview.Canvas.Brush.Color := clBlack;
            FPreview.Canvas.Pen.Color := clRed;
            FPreview.Canvas.Rectangle(DrawRc);
            FPreview.Canvas.Font.Color := clRed;
            FPreview.Canvas.TextOut(DrawRc.Left + 2, DrawRc.Top + 2, ExtractFileName(ImageFileName));
          end;
        finally
          Picture.Free;
        end;
      end
      else
      begin
        FPreview.Canvas.Brush.Color := clBlack;
        FPreview.Canvas.Pen.Color := clRed;
        FPreview.Canvas.Rectangle(DrawRc);
        FPreview.Canvas.Font.Color := clRed;
        FPreview.Canvas.TextOut(DrawRc.Left + 2, DrawRc.Top + 2, StringGrid1.Cells[COL_TEXT, R]);
      end;
    end;

    if R = FSelectedRow then
    begin
      FPreview.Canvas.Brush.Style := bsClear;
      FPreview.Canvas.Pen.Color := clYellow;
      FPreview.Canvas.Rectangle(DrawRc);
      FPreview.Canvas.Brush.Style := bsSolid;
    end;
  end;
end;

//======================================================
// Начинает выбор, перемещение или изменение размера элемента на VLCD.
procedure TForm1.PreviewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Resize: Boolean;
  R: Integer;
begin
  if Button <> mbLeft then
    Exit;
  R := HitRow(X, Y, Resize);
  if R < 0 then
    Exit;
  SelectRow(R);
  if (ssDouble in Shift) and
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, R])) = 'JPG') then
  begin
    OpenImageAreaEditor(R);
    Exit;
  end;
  FDragStart := DisplayPoint(X, Y);
  RowRect(R, FDragRect);
  FDragging := not Resize;
  FResizing := Resize;
end;

//======================================================
// Обрабатывает перемещение мыши и перетаскивание элемента на VLCD.
procedure TForm1.PreviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  Dx: Integer;
  Dy: Integer;
  Rc: TRect;
  Resize: Boolean;
begin
  if FDragging or FResizing then
  begin
    P := DisplayPoint(X, Y);
    Dx := P.X - FDragStart.X;
    Dy := P.Y - FDragStart.Y;
    Rc := FDragRect;
    if FDragging then
      OffsetRect(Rc, Dx, Dy)
    else
    begin
      Rc.Right := Rc.Right + Dx;
      Rc.Bottom := Rc.Bottom + Dy;
    end;
    SetRowRect(FSelectedRow, Rc);
  end
  else
  begin
    HitRow(X, Y, Resize);
    if Resize then
      FPreview.Cursor := crSizeNWSE
    else
      FPreview.Cursor := crDefault;
  end;
end;

//======================================================
// Завершает перетаскивание или изменение размера элемента на VLCD.
procedure TForm1.PreviewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  FResizing := False;
end;

//======================================================
// Обрабатывает выбор ячейки таблицы и выбирает соответствующую строку.
procedure TForm1.GridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  if (ARow > 0) and not FSelectingRow then
    SelectRow(ARow);
end;

//======================================================
// Выбирает строку таблицы по клику мыши.
procedure TForm1.GridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col: Integer;
  Row: Integer;
begin
  StringGrid1.MouseToCell(X, Y, Col, Row);
  if Row > 0 then
    SelectRow(Row);
end;

//======================================================
// Рисует ячейки таблицы команд и маркер выбранной строки.
procedure TForm1.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Points: array[0..2] of TPoint;
  TextRect: TRect;
begin
  if (ARow = 0) or (ACol = COL_SEL) then
  begin
    StringGrid1.Canvas.Brush.Color := clBtnFace;
    StringGrid1.Canvas.Font.Color := clWindowText;
  end
  else
  begin
    StringGrid1.Canvas.Brush.Color := clWindow;
    StringGrid1.Canvas.Font.Color := clWindowText;
  end;

  StringGrid1.Canvas.FillRect(Rect);
  StringGrid1.Canvas.Pen.Color := clSilver;
  StringGrid1.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);

  if (ACol = COL_SEL) and (ARow > 0) and (ARow = FSelectedRow) and
    (Trim(StringGrid1.Cells[COL_CMD, ARow]) <> '') then
  begin
    Points[0] := Point(Rect.Left + 5, Rect.Top + 3);
    Points[1] := Point(Rect.Left + 5, Rect.Bottom - 4);
    Points[2] := Point(Rect.Right - 4, Rect.Top + (Rect.Bottom - Rect.Top) div 2);
    StringGrid1.Canvas.Brush.Color := clBlack;
    StringGrid1.Canvas.Pen.Color := clBlack;
    StringGrid1.Canvas.Polygon(Points);
    Exit;
  end;

  if ACol <> COL_SEL then
  begin
    TextRect := Rect;
    InflateRect(TextRect, -3, -1);
    DrawText(StringGrid1.Canvas.Handle, PChar(StringGrid1.Cells[ACol, ARow]), -1,
      TextRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

//======================================================
// Проверяет введённое значение таблицы и обновляет предпросмотр.
procedure TForm1.GridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
var
  LineWidth: Integer;
  FontId: Integer;
  AlignValue: string;
  Cmd: string;
begin
  if ARow > 0 then
  begin
    Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
    if ACol = COL_LINE then
    begin
      LineWidth := StrToIntDef(Value, 1);
      if LineWidth < 1 then
        LineWidth := 1;
      if LineWidth > 4 then
        LineWidth := 4;
      if Value <> IntToStr(LineWidth) then
        StringGrid1.Cells[COL_LINE, ARow] := IntToStr(LineWidth);
    end;
    if ACol = COL_FONT then
    begin
      FontId := StrToIntDef(Value, 2);
      if FontId < 1 then
        FontId := 1;
      if FontId > 9 then
        FontId := 9;
      if Value <> IntToStr(FontId) then
        StringGrid1.Cells[COL_FONT, ARow] := IntToStr(FontId);
    end;
    if (ACol = COL_HALIGN) or (ACol = COL_VALIGN) then
    begin
      AlignValue := UpperCase(Copy(Trim(Value), 1, 1));
      if ACol = COL_HALIGN then
      begin
        if Pos(AlignValue, 'LCR') = 0 then
          AlignValue := 'C';
      end
      else
      begin
        if Pos(AlignValue, 'TCB') = 0 then
          AlignValue := 'C';
      end;
      if Value <> AlignValue then
        StringGrid1.Cells[ACol, ARow] := AlignValue;
    end;
    if (Cmd = 'JPG') and ((ACol = COL_TEXT) or (ACol = COL_EXTRA) or
      (ACol = COL_SRCX) or (ACol = COL_SRCY) or (ACol = COL_SRCW) or (ACol = COL_SRCH)) then
    begin
      if ACol = COL_EXTRA then
        StringGrid1.Cells[COL_EXTRA, ARow] := NormalizeJpgScaleText(Value);
      UpdateImageRowSize(ARow);
    end;
    FSelectedRow := ARow;
    LoadInputsFromRow(ARow);
    UpdateDefaultColorsFromRow(ARow);
    StringGrid1.Invalidate;
    RepaintPreview;
  end;
end;

//======================================================
// Рисует ячейку цветовой палитры и метки назначенных цветов.
procedure TForm1.PaletteGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Index: Integer;
  CellRgb: string;
  LabelText: string;
  TextSize: TSize;
  TextBg: TColor;
  TextRgb: TColor;
  Brightness: Integer;
begin
  Index := ARow * PALETTE_COLS + ACol;
  StringGrid2.Canvas.Brush.Color := PaletteCellColor(Index);
  StringGrid2.Canvas.FillRect(Rect);
  StringGrid2.Canvas.Pen.Color := clBlack;
  StringGrid2.Canvas.Rectangle(Rect);

  LabelText := '';
  begin
    CellRgb := UpperCase(PaletteCellRgb565(Index));
    if CellRgb = UpperCase(Trim(FDefaultLineRgb)) then
      LabelText := 'ST';
    if CellRgb = UpperCase(Trim(FDefaultFgRgb)) then
    begin
      if LabelText <> '' then
        LabelText := LabelText + '/';
      LabelText := LabelText + 'TX';
    end;
    if CellRgb = UpperCase(Trim(FDefaultBgRgb)) then
    begin
      if LabelText <> '' then
        LabelText := LabelText + '/';
      LabelText := LabelText + 'FL';
    end;
    if CellRgb = UpperCase(Trim(FDefaultLcdBgRgb)) then
    begin
      if LabelText <> '' then
        LabelText := LabelText + '/';
      LabelText := LabelText + 'SC';
    end;
  end;

  if LabelText <> '' then
  begin
    StringGrid2.Canvas.Font.Style := [fsBold];
    TextBg := PaletteCellColor(Index);
    TextRgb := ColorToRGB(TextBg);
    Brightness := GetRValue(TextRgb) * 30 + GetGValue(TextRgb) * 59 +
      GetBValue(TextRgb) * 11;
    if Brightness < 12800 then
      StringGrid2.Canvas.Font.Color := clWhite
    else
      StringGrid2.Canvas.Font.Color := clRed;
    SetBkMode(StringGrid2.Canvas.Handle, TRANSPARENT);
    TextSize := StringGrid2.Canvas.TextExtent(LabelText);
    StringGrid2.Canvas.TextOut(Rect.Left + (Rect.Right - Rect.Left - TextSize.cx) div 2,
      Rect.Top + (Rect.Bottom - Rect.Top - TextSize.cy) div 2, LabelText);
    StringGrid2.Canvas.Font.Style := [];
  end;
end;

//======================================================
// Назначает цвет из палитры активному цветовому полю.
procedure TForm1.PaletteGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  C: Integer;
  R: Integer;
  Index: Integer;
  RgbText: string;
begin
  if Button <> mbLeft then
    Exit;
  StringGrid2.MouseToCell(X, Y, C, R);
  if (C < 0) or (R < 0) then
    Exit;
  Index := R * PALETTE_COLS + C;
  RgbText := PaletteCellRgb565(Index);
  ApplyPaletteColorToActiveField(RgbText, PaletteCellColor(Index));
end;

//======================================================
// Применяет цвет старого ColorGrid к выбранному элементу.
procedure TForm1.ColorGridClick(Sender: TObject);
var
  Cmd: string;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]));
  if Cmd = 'BT' then
  begin
    StringGrid1.Cells[COL_C1, FSelectedRow] := Rgb565Text(ColorGrid1.BackgroundColor);
    StringGrid1.Cells[COL_C2, FSelectedRow] := Rgb565Text(ColorGrid1.ForegroundColor);
    StringGrid1.Cells[COL_EXTRA, FSelectedRow] := Rgb565Text(ColorGrid1.ForegroundColor);
    FDefaultFgRgb := StringGrid1.Cells[COL_C1, FSelectedRow];
    FDefaultBgRgb := StringGrid1.Cells[COL_C2, FSelectedRow];
  end
  else
  begin
    StringGrid1.Cells[COL_C1, FSelectedRow] := Rgb565Text(ColorGrid1.ForegroundColor);
    StringGrid1.Cells[COL_C2, FSelectedRow] := Rgb565Text(ColorGrid1.BackgroundColor);
    FDefaultFgRgb := StringGrid1.Cells[COL_C1, FSelectedRow];
    FDefaultBgRgb := StringGrid1.Cells[COL_C2, FSelectedRow];
  end;
  Edit1.Text := ScriptFromRow(FSelectedRow);
  LoadInputsFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Обновляет строку элемента при изменении числовых полей.
procedure TForm1.InputSpinChange(Sender: TObject);
begin
  if FLoadingInputs then
    Exit;
  UpdateRowFromInputs(FSelectedRow);
end;

//======================================================
// Обновляет текст кнопки или надписи после изменения поля Edit4.
procedure TForm1.TextEditChange(Sender: TObject);
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  if (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'BT') and
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'TX') then
    Exit;
  StringGrid1.Cells[COL_TEXT, FSelectedRow] := Edit4.Text;
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Обновляет толщину линии выбранного элемента.
procedure TForm1.LineTrackChange(Sender: TObject);
var
  LineWidth: Integer;
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  LineWidth := TTrackBar(Sender).Position;
  if LineWidth < 1 then
    LineWidth := 1;
  if LineWidth > 4 then
    LineWidth := 4;
  StringGrid1.Cells[COL_LINE, FSelectedRow] := IntToStr(LineWidth);
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;


//======================================================
// Обновляет шрифт выбранного текстового элемента.
procedure TForm1.FontListClick(Sender: TObject);
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  StringGrid1.Cells[COL_FONT, FSelectedRow] := IntToStr(FFontList.ItemIndex + 1);
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Позволяет заменить файл GFX-шрифта для предпросмотра.
procedure TForm1.Button9Click(Sender: TObject);
var
  FontId: Integer;
  CurrentFile: string;
  SelectedFile: string;
  OldFont: TGfxFont;
  NewFont: TGfxFont;
begin
  if not Assigned(FFontList) then
    Exit;

  FontId := FFontList.ItemIndex + 1;
  if FontId < 1 then
    FontId := 1;
  if FontId > FFontFiles.Count then
    FontId := FFontFiles.Count;
  if FontId < 1 then
    Exit;

  CurrentFile := FFontFiles[FontId - 1];
  Form2.InitialFile := CurrentFile;
  if Form2.ShowModal <> mrOk then
    Exit;
  SelectedFile := Form2.SelectedFile;

  FFontFiles[FontId - 1] := SelectedFile;
  OldFont := TGfxFont(FFontCache[FontId - 1]);
  OldFont.Free;
  NewFont := TGfxFont.Create;
  NewFont.Name := ChangeFileExt(ExtractFileName(SelectedFile), '');
  NewFont.FileName := SelectedFile;
  NewFont.Loaded := False;
  FFontCache[FontId - 1] := NewFont;

  FFontList.Items[FontId - 1] := IntToStr(FontId) + ' ' + NewFont.Name;
  FFontList.ItemIndex := FontId - 1;
  if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
  begin
    StringGrid1.Cells[COL_FONT, FSelectedRow] := IntToStr(FontId);
    Edit1.Text := ScriptFromRow(FSelectedRow);
  end;
  RepaintPreview;
  StatusBar1.SimpleText := 'Preview font selected: ' + ExtractFileName(SelectedFile);
end;

//======================================================
// Обновляет выравнивание текста выбранного элемента после выбора в списке.
procedure TForm1.AlignComboChange(Sender: TObject);
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  StringGrid1.Cells[COL_HALIGN, FSelectedRow] := SelectedHAlign;
  StringGrid1.Cells[COL_VALIGN, FSelectedRow] := SelectedVAlign;
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Обрабатывает переключение RTS.
procedure TForm1.RtsCheckClick(Sender: TObject);
begin
  ApplyRts;
end;

//======================================================
// Обрабатывает включение или отключение UDP-режима.
procedure TForm1.UdpCheckClick(Sender: TObject);
begin
  if CheckBox3.Checked then
  begin
    SetUdpStateColor(clLime);
    if Assigned(FPortMonitor) then
      FPortMonitor.Enabled := True;
  end
  else
  begin
    CloseUdpSocket;
    SetUdpStateColor(clGreen);
    if (FPort = INVALID_HANDLE_VALUE) and Assigned(FPortMonitor) then
      FPortMonitor.Enabled := False;
  end;
end;

//======================================================
// Обрабатывает кнопку дублирования выбранного элемента.
procedure TForm1.DoubleButtonClick(Sender: TObject);
begin
  DuplicateSelectedRow;
end;

//======================================================
// Обрабатывает кнопку удаления выбранного элемента.
procedure TForm1.DeleteButtonClick(Sender: TObject);
begin
  DeleteSelectedRow;
end;

//======================================================
// Очищает список элементов редактора.
procedure TForm1.ClearButtonClick(Sender: TObject);
begin
  StringGrid1.RowCount := 2;
  StringGrid1.Rows[1].Clear;
  SelectRow(1);
end;

//======================================================
// Сохраняет текущий скрипт кнопкой Save.
procedure TForm1.SaveButtonClick(Sender: TObject);
begin
  SaveDesignToFile('current.txt');
end;

//======================================================
// Загружает текущий скрипт кнопкой Load.
procedure TForm1.LoadButtonClick(Sender: TObject);
begin
  LoadDesignFromFile('current.txt');
end;

//======================================================
// Обрабатывает кнопку Clear LCD и отправку очистки экрана.
procedure TForm1.Button8MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Line: string;
begin
  if Button = mbLeft then
  begin
    FLcdBgColor := Rgb565ToColor(FDefaultLcdBgRgb, Shape1.Brush.Color);
    Shape1.Brush.Color := FLcdBgColor;
    Shape1.Pen.Color := Shape1.Brush.Color;
    Line := 'CL|' + FDefaultLcdBgRgb;
    SendLine(Line);
    RepaintPreview;
    if FPort <> INVALID_HANDLE_VALUE then
      StatusBar1.SimpleText := 'LCD clear sent: ' + Line;
  end;
end;

//======================================================
// Загружает демонстрационный скрипт.
procedure TForm1.DemoButtonClick(Sender: TObject);
begin
  LoadDesignFromFile('demo.txt');
end;

//======================================================
// Отправляет одну текущую команду на ESP.
procedure TForm1.SendButtonClick(Sender: TObject);
begin
  SendLine(Trim(Edit1.Text));
  if FPort <> INVALID_HANDLE_VALUE then
    StatusBar1.SimpleText := 'Line sent: ' + Trim(Edit1.Text);
end;

//======================================================
// Отправляет весь текущий скрипт на ESP.
procedure TForm1.UploadButtonClick(Sender: TObject);
var
  R: Integer;
  Line: string;
  Count: Integer;
begin
  if SerialEnabled and (FPort = INVALID_HANDLE_VALUE) and not UdpEnabled then
  begin
    StatusBar1.SimpleText := 'Port is closed: ' + ComboBox1.Text;
    Exit;
  end;
  if (FPort <> INVALID_HANDLE_VALUE) and not PortAlive then
  begin
    StatusBar1.SimpleText := 'Port lost before upload: ' + ComboBox1.Text;
    ClosePort(True);
    Exit;
  end;
  if (not SerialEnabled) and (not UdpEnabled) then
  begin
    StatusBar1.SimpleText := 'No active output channel';
    Exit;
  end;

  Count := 0;
  FLcdBgColor := Shape1.Brush.Color;
  SendLine('CL|' + Rgb565Text(Shape1.Brush.Color));
  Sleep(20);
  Application.ProcessMessages;
  for R := 1 to StringGrid1.RowCount - 1 do
  begin
    Line := Trim(ScriptFromRow(R));
    if Line = '' then
      Continue;
    if not UploadImageRowToEsp(R) then
      Exit;
    Line := Trim(ScriptFromRow(R));
    if Line = '' then
      Continue;
    SendLine(Line);
    if SerialEnabled and (not UdpEnabled) and (FPort = INVALID_HANDLE_VALUE) then
      Exit;
    Inc(Count);
    Sleep(10);
    Application.ProcessMessages;
  end;

  StatusBar1.SimpleText := 'Upload sent: ' + IntToStr(Count) + ' lines';
end;


//======================================================
// Открывает или закрывает COM-порт двойным кликом по индикатору.
procedure TForm1.Shape4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (ssDouble in Shift) then
    OpenClosePort;
end;

//======================================================
// Запрашивает у ESP IP-адрес для UDP-соединения.
procedure TForm1.ShowIpButtonClick(Sender: TObject);
begin
  if FPort = INVALID_HANDLE_VALUE then
  begin
    StatusBar1.SimpleText := 'Open COM first for SHOWIP';
    Exit;
  end;
  SendSerialLine('SHOWIP');
  StatusBar1.SimpleText := 'SHOWIP sent via COM';
end;

//======================================================
// Выбирает файл JPG и привязывает его к выбранному элементу.
procedure TForm1.PictureLoadButtonClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) or
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'JPG') then
    AddElement('JPG');

  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title := 'Select image for SD';
    Dialog.Filter := 'JPEG images (*.jpg;*.jpeg)|*.jpg;*.jpeg|All files (*.*)|*.*';
    Dialog.InitialDir := SdRootPath;
    if Dialog.Execute then
    begin
      StringGrid1.Cells[COL_TEXT, FSelectedRow] := SdCommandPathFromLocalPath(Dialog.FileName);
      if Trim(StringGrid1.Cells[COL_EXTRA, FSelectedRow]) = '' then
        StringGrid1.Cells[COL_EXTRA, FSelectedRow] := '1/1'
      else
        StringGrid1.Cells[COL_EXTRA, FSelectedRow] :=
          NormalizeJpgScaleText(StringGrid1.Cells[COL_EXTRA, FSelectedRow]);
      UpdateImageRowSize(FSelectedRow);
      LoadInputsFromRow(FSelectedRow);
      StringGrid1.Invalidate;
      RepaintPreview;
      StatusBar1.SimpleText := 'Image selected: ' + StringGrid1.Cells[COL_TEXT, FSelectedRow];
      if FPort <> INVALID_HANDLE_VALUE then
        UploadImageRowToEsp(FSelectedRow);
    end;
  finally
    Dialog.Free;
  end;
end;

//======================================================
// Вставляет картинку из буфера обмена в JPG-элемент.
procedure TForm1.PicturePasteButtonClick(Sender: TObject);
var
  Bitmap: TBitmap;
  Cropped: TBitmap;
  Jpg: TJPEGImage;
  TempDir: array[0..MAX_PATH] of Char;
  TempFileName: string;
  TargetDir: string;
  TargetFileName: string;
  TargetPath: string;
  SrcX: Integer;
  SrcY: Integer;
  SrcW: Integer;
  SrcH: Integer;
  ScalePercent: Integer;
  OutW: Integer;
  OutH: Integer;
  N: Integer;
begin
  if (not Clipboard.HasFormat(CF_BITMAP)) and (not Clipboard.HasFormat(CF_DIB)) then
  begin
    StatusBar1.SimpleText := 'Clipboard has no bitmap image';
    Exit;
  end;

  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) or
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'JPG') then
    AddElement('JPG');

  Bitmap := TBitmap.Create;
  Cropped := TBitmap.Create;
  Jpg := TJPEGImage.Create;
  try
    try
      Bitmap.Assign(Clipboard);
      if (Bitmap.Width <= 0) or (Bitmap.Height <= 0) then
        raise Exception.Create('empty clipboard bitmap');

      GetTempPath(SizeOf(TempDir), TempDir);
      TempFileName := IncludeTrailingPathDelimiter(StrPas(TempDir)) +
        'nxt_clipboard_preview.bmp';
      Bitmap.SaveToFile(TempFileName);

      SrcX := 0;
      SrcY := 0;
      SrcW := Bitmap.Width;
      SrcH := Bitmap.Height;
      ScalePercent := 100;
      if not Form3.ExecuteCropWithScale(TempFileName, SrcX, SrcY, SrcW, SrcH, ScalePercent) then
        Exit;

      if (SrcW < 4) or (SrcH < 4) then
      begin
        StatusBar1.SimpleText := 'Clipboard image area too small, paste ignored';
        Exit;
      end;
      if SrcW < 1 then
        SrcW := 1;
      if SrcH < 1 then
        SrcH := 1;

      if ScalePercent < 1 then
        ScalePercent := 1;
      OutW := MulDiv(SrcW, ScalePercent, 100);
      OutH := MulDiv(SrcH, ScalePercent, 100);
      if OutW < 1 then
        OutW := 1;
      if OutH < 1 then
        OutH := 1;

      Cropped.PixelFormat := pf24bit;
      Cropped.Width := OutW;
      Cropped.Height := OutH;
      Cropped.Canvas.CopyRect(Rect(0, 0, OutW, OutH), Bitmap.Canvas,
        Rect(SrcX, SrcY, SrcX + SrcW, SrcY + SrcH));

      TargetDir := IncludeTrailingPathDelimiter(SdRootPath) + 'images\';
      ForceDirectories(TargetDir);
      TargetFileName := FormatDateTime('yyyymmdd_hhnnss_zzz', Now);
      TargetPath := TargetDir + 'paste_' + TargetFileName + '.jpg';
      N := 1;
      while FileExists(TargetPath) do
      begin
        Inc(N);
        TargetPath := TargetDir + 'paste_' + TargetFileName + '_' + IntToStr(N) + '.jpg';
      end;

      Jpg.Assign(Cropped);
      Jpg.CompressionQuality := 90;
      Jpg.SaveToFile(TargetPath);

      StringGrid1.Cells[COL_TEXT, FSelectedRow] := SdCommandPathFromLocalPath(TargetPath);
      StringGrid1.Cells[COL_EXTRA, FSelectedRow] := '1/1';
      StringGrid1.Cells[COL_SRCX, FSelectedRow] := '0';
      StringGrid1.Cells[COL_SRCY, FSelectedRow] := '0';
      StringGrid1.Cells[COL_SRCW, FSelectedRow] := IntToStr(OutW);
      StringGrid1.Cells[COL_SRCH, FSelectedRow] := IntToStr(OutH);
      UpdateImageRowSize(FSelectedRow);
      LoadInputsFromRow(FSelectedRow);
      StringGrid1.Invalidate;
      RepaintPreview;

      StatusBar1.SimpleText := 'Clipboard image saved: ' +
        StringGrid1.Cells[COL_TEXT, FSelectedRow];
      if (FPort <> INVALID_HANDLE_VALUE) or UdpEnabled then
        UploadImageRowToEsp(FSelectedRow);
    except
      on E: Exception do
        StatusBar1.SimpleText := 'Clipboard paste failed: ' + E.Message;
    end;
  finally
    if TempFileName <> '' then
      DeleteFile(PChar(TempFileName));
    Jpg.Free;
    Cropped.Free;
    Bitmap.Free;
  end;
end;

//======================================================
// Периодически опрашивает COM и UDP входящие события.
procedure TForm1.PortMonitorTimer(Sender: TObject);
begin
  if UdpEnabled then
    PollUdpInput;

  if FPort <> INVALID_HANDLE_VALUE then
  begin
    if not PortAlive then
    begin
      StatusBar1.SimpleText := 'Port lost: ' + ComboBox1.Text;
      ClosePort(True);
      Exit;
    end;
    PollPortInput;
  end;
end;

//======================================================
// Добавляет выбранный тип компонента из панели элементов.
procedure TForm1.PaletteElementClick(Sender: TObject);
begin
  if UpperCase(TControl(Sender).Hint) = 'JPG' then
  begin
    AddElement('JPG');
    PictureLoadButtonClick(Sender);
  end
  else
    AddElement(TControl(Sender).Hint);
end;

//======================================================
// Добавляет фигуру из панели элементов по клику мыши.
procedure TForm1.PaletteShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    AddElement(TControl(Sender).Hint);
end;

end.
