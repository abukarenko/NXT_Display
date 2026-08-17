unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls, Spin, ColorGrd,
  jpeg, WinSock, IniFiles, Clipbrd, XPMan, Buttons, Menus;

type
  TIntegerArray = array of Integer;
  TByteArray = array of Byte;
  TColorField = (cfLine, cfText, cfBack, cfLcdBack, cfElement);

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

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Bevel1: TBevel;
    ComboBox1: TComboBox;
    Button2: TButton;
    SelectorText: TImage;
    ColorGrid1: TColorGrid;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    SelectorButton: TImage;
    Label4: TLabel;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    SpinEdit4: TSpinEdit;
    SelectorSwitch: TImage;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    SpinEdit5: TSpinEdit;
    Label14: TLabel;
    SelectorCircle: TImage;
    Label15: TLabel;
    Label16: TLabel;
    SpinEdit6: TSpinEdit;
    StringGrid1: TStringGrid;
    Button3: TButton;
    SelectorBox: TImage;
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
    SelectorSlider: TImage;
    SelectorProgress: TImage;
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
    SelectorRoundRect: TImage;
    CheckBox4: TCheckBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Label27: TLabel;
    Label29: TLabel;
    Edit4: TEdit;
    Label17: TLabel;
    ColorDialog1: TColorDialog;
    Label30: TLabel;
    Shape11: TShape;
    CheckBox5: TCheckBox;
    ComboBox4: TComboBox;
    Label31: TLabel;
    Button16: TButton;
    Button17: TButton;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    ComboBox5: TComboBox;
    Button18: TButton;
    ProgressBar1: TProgressBar;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    ComboBox6: TComboBox;
    Label36: TLabel;
    Label3: TLabel;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    Label5: TLabel;
    Label28: TLabel;
    ProgressBar2: TProgressBar;
    Button14: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button9Click(Sender: TObject);
    procedure Button8MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure OrientationCheckClick(Sender: TObject);
    procedure ColorThemeChange(Sender: TObject);
    procedure JpgScaleComboChange(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure Button18Click(Sender: TObject);
  private
    FPreview: TPaintBox;
    FPort: THandle;
    FSelectedRow: Integer;
    FDragging: Boolean;
    FResizing: Boolean;
    FDragStart: TPoint;
    FDragRect: TRect;
    FUdpSocket: TSocket;
    FUdpLastProbeTick: DWORD;
    FUdpLastOkTick: DWORD;
    FUdpBusy: Boolean;
    FUdpLossShown: Boolean;
    FLastPopupText: string;
    FLastPopupTick: DWORD;
    FSdScriptsLastTick: DWORD;
    FRefreshingSdScripts: Boolean;
    FPortMonitor: TTimer;
    FPortMonitorBusy: Boolean;
    FPortRxText: AnsiString;
    FLoadingInputs: Boolean;
    FLoadingTheme: Boolean;
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
    FDefaultElementRgb: string;
    FComponentColorPopup: TPopupMenu;
    FThemeColorsItem: TMenuItem;
    FCopyColorsItem: TMenuItem;
    FPasteColorsItem: TMenuItem;
    FDisplayPopup: TPopupMenu;
    FLoadDisplayItem: TMenuItem;
    FUploadDisplayItem: TMenuItem;
    FCreateScriptItem: TMenuItem;
    FClearDisplayItem: TMenuItem;
    FThemePopup: TPopupMenu;
    FApplyThemeAllItem: TMenuItem;
    FColorClipboardValues: array[TColorField] of string;
    FColorClipboardHas: array[TColorField] of Boolean;
    FColorClipboardValid: Boolean;
    FColorClipboardFont: string;
    FColorClipboardHasFont: Boolean;
    FLastStatusText: string;
    SimpleText: string;
    FNoColorLabels: array[TColorField] of TLabel;
    procedure InitGrid;
    procedure InitControls;
    procedure SetStatus(const AText: string);
    procedure SetSdProgress(AValue: Integer);
    procedure SetImageProgress(AValue: Integer);
    procedure UpdateMainStatusBar;
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure AddPaletteHandlers;
    procedure LoadEspFontList;
    procedure ApplyPreviewFont(AFontId: Integer);
    function GetPreviewFont(AFontId: Integer): TGfxFont;
    function FontListIndexById(AFontId: Integer): Integer;
    procedure EnsureSdFontListItem(AFontId: Integer; const AName: string);
    function LoadGfxFontFile(AFont: TGfxFont): Boolean;
    function LocalVlwFontPath(AFontId: Integer): string;
    function LoadVlwFontFile(const AFileName: string): TVlwFont;
    function VlwGlyphCode(AChar: AnsiChar): Integer;
    function FindVlwGlyph(AFont: TVlwFont; ACode: Integer; var AGlyph: TVlwGlyph): Boolean;
    procedure VlwTextBounds(AFont: TVlwFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
    procedure DrawVlwText(AFont: TVlwFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
    function DrawVlwTextBox(AFontId: Integer; const AText: string; const ARect: TRect; AHAlign, AVAlign: string; AColor: TColor): Boolean;
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
    function IsRgb565Text(const AText: string): Boolean;
    function ScreenFillScriptLine: string;
    function IsScreenFillRow(ARow: Integer): Boolean;
    procedure EnsureScreenFillRow;
    function ScriptFromRow(ARow: Integer): string;
    function SdRootPath: string;
    function SdCommandPathFromLocalPath(const AFileName: string): string;
    function LocalImagePathFromCommandPath(const APath: string): string;
    procedure OpenImageAreaEditor(ARow: Integer);
    procedure UpdateImageRowSize(ARow: Integer);
    function WaitSerialReply(const APrefix: string; ATimeoutMs: DWORD; var ALine: string): Boolean;
    function SendFileToEspSd(const ALocalFileName: string; var ASdPath: string;
      AProgressLabel: TLabel = nil; AForceOverwrite: Boolean = False): Boolean;
    function RemoteSdFileSize(const ASdPath: string; var ASize: Int64): Boolean;
    function EnsureEspSdFont(AFontId: Integer): Boolean;
    function UploadImageRowToEsp(ARow: Integer;
      AForceOverwrite: Boolean = False): Boolean;
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
    procedure ApplyColorTheme(AThemeIndex: Integer);
    function RowColorValue(ARow: Integer; AField: TColorField;
      var AValue: string): Boolean;
    procedure SetRowColorValue(ARow: Integer; AField: TColorField;
      const AValue: string);
    function ThemeDefaultColor(AField: TColorField): string;
    procedure RefreshSelectedColorRow;
    procedure ThemeColorsMenuClick(Sender: TObject);
    procedure CopyColorsMenuClick(Sender: TObject);
    procedure PasteColorsMenuClick(Sender: TObject);
    function RowSupportsFont(ARow: Integer): Boolean;
    function RequestDisplaySnapshot(ADest: TStrings): Boolean;
    procedure LoadFromDisplayMenuClick(Sender: TObject);
    procedure UploadToDisplayMenuClick(Sender: TObject);
    procedure CreateScriptMenuClick(Sender: TObject);
    procedure ClearDisplayMenuClick(Sender: TObject);
    procedure ApplyThemeAllMenuClick(Sender: TObject);
    function ColorFieldAppliesToCommand(AField: TColorField; const ACmd: string): Boolean;
    procedure SetActiveColorField(AField: TColorField);
    procedure RefreshColorFieldShapes;
    procedure DrawComponentPaletteImage(AImage: TImage; const AKind: string);
    procedure RefreshComponentPaletteImages;
    procedure EnsureNoColorLabels;
    procedure ApplyPaletteColorToActiveField(const ARgb: string; AColor: TColor);
    procedure ColorFieldMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function SerialEnabled: Boolean;
    function UdpEnabled: Boolean;
    function EnsureUdpSocket(ABroadcast: Boolean): Boolean;
    procedure CloseUdpSocket;
    function UdpExchangeLine(const ALine, AHost: string; ABroadcast: Boolean;
      var AReply: string; const AExpectedPrefix: string = '';
      ATimeoutMs: DWORD = 3000; AShowTimeoutError: Boolean = True): Boolean;
    function ExchangeEspLine(const ALine, AOkPrefix: string; ATimeoutMs: DWORD; var AReply: string): Boolean;
    procedure RefreshSdScriptList;
    function NextSdScriptFileName: string;
    procedure SaveDesignToStrings(ADest: TStrings);
    procedure LoadDesignFromStrings(ASource: TStrings; const AName: string);
    procedure PollUdpInput;
    procedure ProbeUdpStatus;
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
    procedure ShowErrorPopup(const AText: string);
    procedure MarkUdpAlive;
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
    procedure SendScriptToSdClick(Sender: TObject);
    procedure LoadScriptFromSdClick(Sender: TObject);
    procedure RefreshSdScriptsClick(Sender: TObject);
    procedure Shape4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowIpButtonClick(Sender: TObject);
    procedure PictureLoadButtonClick(Sender: TObject);
    procedure PicturePasteButtonClick(Sender: TObject);
    procedure PortMonitorTimer(Sender: TObject);
    procedure PaletteElementClick(Sender: TObject);
    procedure PicturePaletteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  public
    function EspExchange(const ALine, AOkPrefix: string; ATimeoutMs: DWORD;
      var AReply: string): Boolean;
    procedure EditorStatus(const AText: string);
    procedure EditorProgress(AValue: Integer);
    function EditorSdRootPath: string;
  end;

var
  Form1: TForm1;

implementation

uses
  Unit2, Unit3, Unit4, Unit5, Unit6;

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
  PALETTE_COLOR_COUNT = 32;
  GFX_PREVIEW_Y_CORRECTION = -2;
  DEFAULT_PALETTE_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of TColor = (
    clBlack, $00000080, clGreen, $00008080,
    clNavy, clPurple, $00808000, clSilver,
    clGray, clRed, clLime, clYellow,
    clBlue, clFuchsia, clAqua, clWhite,
    $00004080, $000080FF, $0000C0FF, $004080FF,
    $00804000, $008080FF, $00008040, $0040C000,
    $00C08000, $00FFC080, $008000FF, $00FF0080,
    $00808040, $00404040, $00D8E9EC, clWhite
  );
  NEON_THEME_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of LongWord = (
    $05070D, $0B1020, $111827, $1F2937, $374151, $6B7280, $D1D5DB, $F8FAFC,
    $00F5FF, $00FF9C, $39FF14, $FFF500, $FF7A00, $FF2D95, $D946EF, $8B5CF6,
    $2563EB, $00B8D9, $14B8A6, $22C55E, $84CC16, $EAB308, $F97316, $EF4444,
    $F43F5E, $EC4899, $A855F7, $6366F1, $0EA5E9, $06B6D4, $10B981, $FFFFFF
  );
  DARK_THEME_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of LongWord = (
    $0B0F14, $111827, $1F2937, $273449, $374151, $4B5563, $9CA3AF, $F3F4F6,
    $3B82F6, $2563EB, $06B6D4, $14B8A6, $10B981, $22C55E, $84CC16, $EAB308,
    $F59E0B, $F97316, $EF4444, $F43F5E, $EC4899, $D946EF, $A855F7, $8B5CF6,
    $6366F1, $64748B, $94A3B8, $CBD5E1, $E2E8F0, $F8FAFC, $000000, $FFFFFF
  );
  LIGHT_THEME_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of LongWord = (
    $FFFFFF, $F8FAFC, $F1F5F9, $E2E8F0, $CBD5E1, $94A3B8, $64748B, $0F172A,
    $2563EB, $0284C7, $0891B2, $0D9488, $059669, $16A34A, $65A30D, $CA8A04,
    $D97706, $EA580C, $DC2626, $E11D48, $DB2777, $C026D3, $9333EA, $7C3AED,
    $4F46E5, $475569, $334155, $1E293B, $0F172A, $FEF3C7, $DCFCE7, $DBEAFE
  );
  PURPLE_THEME_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of LongWord = (
    $120A24, $1E1038, $2D1854, $3B1D6B, $512A86, $6D3AA8, $A78BFA, $F5F3FF,
    $7C3AED, $8B5CF6, $A855F7, $C026D3, $D946EF, $EC4899, $F43F5E, $FB7185,
    $C4B5FD, $DDD6FE, $EDE9FE, $F5D0FE, $FBCFE8, $67E8F9, $22D3EE, $06B6D4,
    $14B8A6, $34D399, $A3E635, $FACC15, $FB923C, $F87171, $94A3B8, $FFFFFF
  );
  OCEAN_THEME_COLORS: array[0..PALETTE_COLOR_COUNT - 1] of LongWord = (
    $031A26, $062B3A, $0B3C4C, $0E5266, $126A80, $1D8299, $7DD3FC, $E0F2FE,
    $0EA5E9, $0284C7, $0369A1, $06B6D4, $22D3EE, $67E8F9, $14B8A6, $0D9488,
    $10B981, $34D399, $A7F3D0, $84CC16, $EAB308, $F59E0B, $F97316, $EF4444,
    $F43F5E, $EC4899, $8B5CF6, $6366F1, $64748B, $94A3B8, $CBD5E1, $FFFFFF
  );

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

var
  PaletteColors: array[0..PALETTE_COLOR_COUNT - 1] of TColor;
  Numbers: TIntegerArray;
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
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'fonts';
end;

//======================================================
// Заполняет редактируемую палитру начальными цветами.
procedure InitDefaultPaletteColors;
var
  I: Integer;
begin
  for I := 0 to PALETTE_COLOR_COUNT - 1 do
    PaletteColors[I] := DEFAULT_PALETTE_COLORS[I];
end;

//======================================================
// Возвращает цвет ячейки редактируемой палитры по её индексу.
function PaletteCellColor(AIndex: Integer): TColor;
begin
  if (AIndex >= 0) and (AIndex < PALETTE_COLOR_COUNT) then
    Result := PaletteColors[AIndex]
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
  FUdpLossShown := False;
  FLastPopupText := '';
  FLastPopupTick := 0;
  FPortMonitor := nil;
  FPortMonitorBusy := False;
  FPortRxText := '';
  FLastStatusText := 'Ready';
  FLoadingInputs := False;
  FLoadingTheme := False;
  FComponentColorPopup := nil;
  FDisplayPopup := nil;
  FThemePopup := nil;
  FColorClipboardValid := False;
  FColorClipboardHasFont := False;
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
  FDefaultElementRgb := '0xFFE0';
  FSdScriptsLastTick := 0;
  FRefreshingSdScripts := False;
  Caption := 'GUI Maker';
  InitGrid;
  InitControls;
  AddPaletteHandlers;
  EnsureScreenFillRow;
  SelectRow(1);
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
var
  C: Integer;
begin
  StringGrid1.ColCount := 19;
  StringGrid1.RowCount := 2;
  StringGrid1.FixedCols := 0;
  StringGrid1.FixedRows := 0;
  StringGrid1.Options := StringGrid1.Options - [goEditing, goRangeSelect] + [goRowSelect];
  StringGrid1.DefaultDrawing := False;
  StringGrid1.ScrollBars := ssVertical;
  StringGrid1.Font.Name := 'Consolas';
  StringGrid1.Font.Size := 8;
  StringGrid1.DefaultRowHeight := 18;
  StringGrid1.RowHeights[0] := 0;
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
  StringGrid1.ColWidths[COL_SEL] := 12;
  StringGrid1.ColWidths[COL_CMD] := 30;
  StringGrid1.ColWidths[COL_ID] := 445;
  for C := COL_X to StringGrid1.ColCount - 1 do
    StringGrid1.ColWidths[C] := 0;
  StringGrid1.OnSelectCell := GridSelectCell;
  StringGrid1.OnMouseDown := GridMouseDown;
  StringGrid1.OnDrawCell := GridDrawCell;
  StringGrid1.OnSetEditText := nil;
end;

//======================================================
// Меняет значение SpinEdit колесом мыши, Shift ускоряет шаг.
procedure TForm1.AppMessage(var Msg: TMsg; var Handled: Boolean);
var
  Control: TWinControl;
  Edit: TSpinEdit;
  Delta: Integer;
  Step: Integer;
  NewValue: Integer;
begin
  if Msg.message <> WM_MOUSEWHEEL then
    Exit;
  Control := FindVCLWindow(Msg.pt);
  if not (Control is TSpinEdit) then
    Exit;
  Edit := TSpinEdit(Control);
  if not Edit.Enabled then
    Exit;

  Step := 1;
  if GetKeyState(VK_SHIFT) < 0 then
    Step := 10;
  Delta := SmallInt(HIWORD(Msg.wParam)) div WHEEL_DELTA;
  if Delta = 0 then
  begin
    if SmallInt(HIWORD(Msg.wParam)) > 0 then
      Delta := 1
    else
      Delta := -1;
  end;

  NewValue := Edit.Value + Delta * Step;
  if Edit.MaxValue <> Edit.MinValue then
  begin
    if NewValue < Edit.MinValue then
      NewValue := Edit.MinValue;
    if NewValue > Edit.MaxValue then
      NewValue := Edit.MaxValue;
  end;
  Edit.Value := NewValue;
  if Edit.CanFocus then
    Edit.SetFocus;
  Handled := True;
end;
//======================================================
// Создаёт и настраивает элементы управления формы.
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

  FComponentColorPopup := TPopupMenu.Create(Self);
  FThemeColorsItem := TMenuItem.Create(FComponentColorPopup);
  FThemeColorsItem.Caption := 'Цвета темы';
  FThemeColorsItem.OnClick := ThemeColorsMenuClick;
  FComponentColorPopup.Items.Add(FThemeColorsItem);
  FCopyColorsItem := TMenuItem.Create(FComponentColorPopup);
  FCopyColorsItem.Caption := 'Копировать цвета';
  FCopyColorsItem.OnClick := CopyColorsMenuClick;
  FComponentColorPopup.Items.Add(FCopyColorsItem);
  FPasteColorsItem := TMenuItem.Create(FComponentColorPopup);
  FPasteColorsItem.Caption := 'Вставить цвета';
  FPasteColorsItem.OnClick := PasteColorsMenuClick;
  FComponentColorPopup.Items.Add(FPasteColorsItem);

  FDisplayPopup := TPopupMenu.Create(Self);
  FLoadDisplayItem := TMenuItem.Create(FDisplayPopup);
  FLoadDisplayItem.Caption := 'Load from display';
  FLoadDisplayItem.OnClick := LoadFromDisplayMenuClick;
  FDisplayPopup.Items.Add(FLoadDisplayItem);
  FUploadDisplayItem := TMenuItem.Create(FDisplayPopup);
  FUploadDisplayItem.Caption := 'Upload to display';
  FUploadDisplayItem.OnClick := UploadToDisplayMenuClick;
  FDisplayPopup.Items.Add(FUploadDisplayItem);
  FCreateScriptItem := TMenuItem.Create(FDisplayPopup);
  FCreateScriptItem.Caption := 'Create script';
  FCreateScriptItem.OnClick := CreateScriptMenuClick;
  FDisplayPopup.Items.Add(FCreateScriptItem);
  FClearDisplayItem := TMenuItem.Create(FDisplayPopup);
  FClearDisplayItem.Caption := 'Clear display';
  FClearDisplayItem.OnClick := ClearDisplayMenuClick;
  FDisplayPopup.Items.Add(FClearDisplayItem);

  FThemePopup := TPopupMenu.Create(Self);
  FApplyThemeAllItem := TMenuItem.Create(FThemePopup);
  FApplyThemeAllItem.Caption := 'Назначить для всех';
  FApplyThemeAllItem.OnClick := ApplyThemeAllMenuClick;
  FThemePopup.Items.Add(FApplyThemeAllItem);
  ComboBox5.PopupMenu := FThemePopup;

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
  SpinEdit7.MaxValue := 10000;
  SpinEdit8.MaxValue := 10000;
  SpinEdit7.OnChange := InputSpinChange;
  SpinEdit8.OnChange := InputSpinChange;
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
  Button14.OnClick := ApplyThemeAllMenuClick;
  Shape6.OnMouseDown := ColorFieldMouseDown;
  Shape7.OnMouseDown := ColorFieldMouseDown;
  Shape8.OnMouseDown := ColorFieldMouseDown;
  Shape9.OnMouseDown := ColorFieldMouseDown;
  Shape11.OnMouseDown := ColorFieldMouseDown;
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
  CheckBox7.OnClick := OrientationCheckClick;
  CheckBox8.OnClick := OrientationCheckClick;
  ComboBox4.Style := csDropDownList;
  ComboBox4.Items.Clear;
  ComboBox4.ItemIndex := -1;
  ComboBox4.OnDropDown := RefreshSdScriptsClick;
  ComboBox4.OnChange := LoadScriptFromSdClick;
  ProgressBar1.Min := 0;
  ProgressBar1.Max := 100;
  ProgressBar1.Position := 0;
  ProgressBar2.Min := 0;
  ProgressBar2.Max := 100;
  ProgressBar2.Position := 0;
  ComboBox5.Style := csDropDownList;
  ComboBox5.Items.Clear;
  ComboBox5.Items.Add('Neon');
  ComboBox5.Items.Add('Dark');
  ComboBox5.Items.Add('Light');
  ComboBox5.Items.Add('Purple');
  ComboBox5.Items.Add('Ocean');
  ComboBox5.ItemIndex := 1;
  ComboBox5.OnChange := ColorThemeChange;
  ComboBox6.Style := csDropDownList;
  ComboBox6.Items.Clear;
  ComboBox6.Items.Add('1/4');
  ComboBox6.Items.Add('1/2');
  ComboBox6.Items.Add('1/1');
  ComboBox6.Items.Add('2/1');
  ComboBox6.Items.Add('4/1');
  ComboBox6.ItemIndex := ComboBox6.Items.IndexOf('1/1');
  ComboBox6.OnChange := JpgScaleComboChange;

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
  if StatusBar1.Panels.Count >= 4 then
  begin
    StatusBar1.Panels[0].Width := 190;
    StatusBar1.Panels[1].Width := 245;
    StatusBar1.Panels[2].Width := 420;
    StatusBar1.Panels[3].Width := 190;
  end;
  Application.OnMessage := AppMessage;
  InitDefaultPaletteColors;
  ApplyColorTheme(ComboBox5.ItemIndex);
  LoadSettings;
  UpdateMainStatusBar;
end;


//======================================================
// Выводит служебные сообщения в окно лога Form4.Memo1.
procedure TForm1.SetStatus(const AText: string);
begin
  SimpleText := AText;
  FLastStatusText := AText;
  UpdateMainStatusBar;
  if Assigned(Form4) then
    Form4.AddMessage(AText);
end;

//======================================================
procedure TForm1.SetSdProgress(AValue: Integer);
begin
  if not Assigned(ProgressBar1) then
    Exit;
  if AValue < 0 then
    AValue := 0;
  if AValue > 100 then
    AValue := 100;
  ProgressBar1.Position := AValue;
  ProgressBar1.Update;
end;

//======================================================
procedure TForm1.SetImageProgress(AValue: Integer);
begin
  if not Assigned(ProgressBar2) then
    Exit;
  if AValue < 0 then
    AValue := 0;
  if AValue > 100 then
    AValue := 100;
  ProgressBar2.Position := AValue;
  ProgressBar2.Update;
end;

//======================================================
// Обновляет четыре панели состояния главной формы актуальными данными.
procedure TForm1.UpdateMainStatusBar;
var
  ThemeText: string;
  SceneCount: Integer;
begin
  if not Assigned(StatusBar1) or (StatusBar1.Panels.Count < 4) then
    Exit;

  if FPort <> INVALID_HANDLE_VALUE then
    StatusBar1.Panels[0].Text := ComboBox1.Text + ' connected, 115200'
  else if CheckBox2.Checked then
    StatusBar1.Panels[0].Text := ComboBox1.Text + ' disconnected'
  else
    StatusBar1.Panels[0].Text := 'COM disabled';

  if UdpEnabled then
  begin
    if (FUdpLastOkTick <> 0) and (GetTickCount - FUdpLastOkTick < 4000) then
      StatusBar1.Panels[1].Text := 'UDP ' + Trim(Edit2.Text) + ':' +
        Trim(Edit3.Text) + ' online'
    else
      StatusBar1.Panels[1].Text := 'UDP ' + Trim(Edit2.Text) + ':' +
        Trim(Edit3.Text) + ' waiting';
  end
  else
    StatusBar1.Panels[1].Text := 'UDP disabled';

  StatusBar1.Panels[2].Text := FLastStatusText;
  if ComboBox5.ItemIndex >= 0 then
    ThemeText := ComboBox5.Text
  else
    ThemeText := 'custom';
  SceneCount := StringGrid1.RowCount - 2;
  if SceneCount < 0 then
    SceneCount := 0;
  StatusBar1.Panels[3].Text := 'Items ' + IntToStr(SceneCount) +
    ' | ' + ThemeText;
end;
//======================================================
// Draws a live theme-colored component sample into a palette image.
procedure TForm1.DrawComponentPaletteImage(AImage: TImage; const AKind: string);
var
  B: TBitmap;
  R: TRect;
  Kind: string;
  LineColor: TColor;
  TextColor: TColor;
  FillColor: TColor;
  ElementColor: TColor;
  ScreenColor: TColor;
  MidX: Integer;
  MidY: Integer;
  Radius: Integer;
  TrackHeight: Integer;
  BarRect: TRect;
  S: string;

  procedure FillSampleRect(const ARect: TRect; AColor: TColor);
  begin
    B.Canvas.Brush.Style := bsSolid;
    B.Canvas.Brush.Color := AColor;
    B.Canvas.FillRect(ARect);
  end;

begin
  if not Assigned(AImage) then
    Exit;
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    B.Width := AImage.Width;
    B.Height := AImage.Height;
    ScreenColor := Rgb565ToColor(FDefaultLcdBgRgb, clBlack);
    LineColor := Rgb565ToColor(FDefaultLineRgb, clWhite);
    TextColor := Rgb565ToColor(FDefaultFgRgb, clWhite);
    FillColor := Rgb565ToColor(FDefaultBgRgb, ScreenColor);
    ElementColor := Rgb565ToColor(FDefaultElementRgb, clLime);
    FillSampleRect(Rect(0, 0, B.Width, B.Height), ScreenColor);
    R := Rect(1, 1, B.Width - 1, B.Height - 1);
    Kind := UpperCase(AKind);

    B.Canvas.Pen.Style := psSolid;
    B.Canvas.Pen.Width := 1;
    B.Canvas.Pen.Color := LineColor;
    B.Canvas.Brush.Style := bsSolid;
    B.Canvas.Brush.Color := FillColor;

    if Kind = 'BT' then
    begin
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
      B.Canvas.Font.Color := TextColor;
      B.Canvas.Font.Style := [fsBold];
      S := 'Button';
      B.Canvas.TextOut((B.Width - B.Canvas.TextWidth(S)) div 2,
        (B.Height - B.Canvas.TextHeight(S)) div 2, S);
    end
    else if Kind = 'TX' then
    begin
      if not IsNoColorRgb(FDefaultBgRgb) then
        FillSampleRect(R, FillColor);
      B.Canvas.Font.Color := TextColor;
      B.Canvas.Font.Style := [fsBold];
      S := 'Text';
      B.Canvas.TextOut((B.Width - B.Canvas.TextWidth(S)) div 2,
        (B.Height - B.Canvas.TextHeight(S)) div 2, S);
    end
    else if Kind = 'SW' then
    begin
      Radius := (R.Bottom - R.Top) div 2;
      TrackHeight := (R.Bottom - R.Top) div 14;
      if TrackHeight < 2 then
        TrackHeight := 2;
      MidY := (R.Top + R.Bottom) div 2;
      MidX := R.Left + Radius;

      B.Canvas.Brush.Color := FillColor;
      B.Canvas.Pen.Width := TrackHeight;
      B.Canvas.Pen.Color := FillColor;
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom,
        R.Bottom - R.Top, R.Bottom - R.Top);
      B.Canvas.Pen.Width := 1;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.Brush.Style := bsClear;
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom,
        R.Bottom - R.Top, R.Bottom - R.Top);
      B.Canvas.Brush.Style := bsSolid;
      B.Canvas.Brush.Color := TextColor;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.Ellipse(MidX - Radius + TrackHeight * 2,
        MidY - Radius + TrackHeight * 2,
        MidX + Radius - TrackHeight * 2,
        MidY + Radius - TrackHeight * 2);
    end
    else if Kind = 'PB' then
    begin
      B.Canvas.Brush.Color := FillColor;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
      FillSampleRect(Rect(R.Left + 2, R.Top + 2,
        R.Right - 2, R.Bottom - 2), FillColor);
      FillSampleRect(Rect(R.Left + 2, R.Top + 2,
        R.Left + 2 + (R.Right - R.Left - 4) div 2,
        R.Bottom - 2), ElementColor);
      B.Canvas.Brush.Style := bsClear;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
      B.Canvas.Brush.Style := bsSolid;
    end
    else if Kind = 'TR' then
    begin
      MidY := (R.Top + R.Bottom) div 2;
      TrackHeight := (R.Bottom - R.Top) div 2;
      if TrackHeight < 2 then
        TrackHeight := 2;
      Radius := (R.Bottom - R.Top) div 2;
      if Radius < 1 then
        Radius := 1;
      MidX := (R.Left + R.Right) div 2;
      BarRect := Rect(R.Left, MidY - TrackHeight div 2,
        R.Right, MidY - TrackHeight div 2 + TrackHeight);

      B.Canvas.Brush.Color := LineColor;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.RoundRect(BarRect.Left, BarRect.Top, BarRect.Right,
        BarRect.Bottom, TrackHeight, TrackHeight);
      B.Canvas.Brush.Color := ElementColor;
      B.Canvas.Pen.Color := ElementColor;
      B.Canvas.RoundRect(BarRect.Left, BarRect.Top, MidX,
        BarRect.Bottom, TrackHeight, TrackHeight);
      B.Canvas.Brush.Color := FillColor;
      B.Canvas.Pen.Color := clBlack;
      B.Canvas.Ellipse(MidX - Radius, MidY - Radius,
        MidX + Radius, MidY + Radius);
    end
    else if Kind = 'BX' then
    begin
      if IsNoColorRgb(FDefaultBgRgb) then
        B.Canvas.Brush.Style := bsClear;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.Rectangle(R);
    end
    else if Kind = 'RR' then
    begin
      if IsNoColorRgb(FDefaultBgRgb) then
        B.Canvas.Brush.Style := bsClear;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 10, 10);
    end
    else if Kind = 'CC' then
    begin
      if IsNoColorRgb(FDefaultBgRgb) then
        B.Canvas.Brush.Style := bsClear;
      B.Canvas.Pen.Color := LineColor;
      B.Canvas.Ellipse(R);
    end;

    AImage.Picture.Bitmap.Assign(B);
  finally
    B.Free;
  end;
end;

//======================================================
// Refreshes every component selector after a theme/default color change.
procedure TForm1.RefreshComponentPaletteImages;
begin
  DrawComponentPaletteImage(SelectorButton, 'BT');
  DrawComponentPaletteImage(SelectorText, 'TX');
  DrawComponentPaletteImage(SelectorSwitch, 'SW');
  DrawComponentPaletteImage(SelectorProgress, 'PB');
  DrawComponentPaletteImage(SelectorSlider, 'TR');
  DrawComponentPaletteImage(SelectorBox, 'BX');
  DrawComponentPaletteImage(SelectorRoundRect, 'RR');
  DrawComponentPaletteImage(SelectorCircle, 'CC');
end;
//======================================================
// Привязывает элементы палитры компонентов к обработчикам добавления.
procedure TForm1.AddPaletteHandlers;
begin
  SelectorButton.SetBounds(SelectorButton.Left, SelectorButton.Top, 40, 24);
  SelectorText.SetBounds(SelectorText.Left, SelectorText.Top, 40, 24);
  SelectorSwitch.SetBounds(SelectorSwitch.Left, SelectorSwitch.Top, 40, 24);
  SelectorProgress.SetBounds(SelectorProgress.Left, SelectorProgress.Top, 40, 24);
  SelectorSlider.SetBounds(SelectorSlider.Left, SelectorSlider.Top, 40, 24);
  SelectorBox.SetBounds(SelectorBox.Left, SelectorBox.Top, 40, 24);
  SelectorRoundRect.SetBounds(SelectorRoundRect.Left, SelectorRoundRect.Top, 40, 24);
  SelectorCircle.SetBounds(SelectorCircle.Left, SelectorCircle.Top, 40, 40);
  Image4.SetBounds(Image4.Left, Image4.Top, 64, 64);
  Image4.Stretch := True;
  Image4.Proportional := True;
  Image4.Center := True;

  SelectorButton.Hint := 'BT';
  SelectorText.Hint := 'TX';
  SelectorSwitch.Hint := 'SW';
  SelectorProgress.Hint := 'PB';
  SelectorSlider.Hint := 'TR';
  SelectorBox.Hint := 'BX';
  SelectorRoundRect.Hint := 'RR';
  SelectorCircle.Hint := 'CC';
  Image4.Hint := 'JPG';
  Image4.ShowHint := True;
  Image4.Cursor := crHandPoint;
  Label10.Hint := 'BT';
  Label11.Hint := 'TR';
  Label12.Hint := 'JPG';
  Label13.Hint := 'BX';
  Label15.Hint := 'CC';
  Label20.Hint := 'SW';
  Label21.Hint := 'PB';
  Label22.Hint := 'TX';
  Label26.Hint := 'RR';

  SelectorButton.OnClick := PaletteElementClick;
  SelectorText.OnClick := PaletteElementClick;
  SelectorSwitch.OnClick := PaletteElementClick;
  SelectorProgress.OnClick := PaletteElementClick;
  SelectorSlider.OnClick := PaletteElementClick;
  SelectorBox.OnClick := PaletteElementClick;
  SelectorRoundRect.OnClick := PaletteElementClick;
  SelectorCircle.OnClick := PaletteElementClick;
  Image4.OnClick := nil;
  Image4.OnMouseDown := PicturePaletteMouseDown;
  Label10.OnClick := PaletteElementClick;
  Label11.OnClick := PaletteElementClick;
  Label12.OnClick := PaletteElementClick;
  Label13.OnClick := PaletteElementClick;
  Label15.OnClick := PaletteElementClick;
  Label20.OnClick := PaletteElementClick;
  Label21.OnClick := PaletteElementClick;
  Label22.OnClick := PaletteElementClick;
  Label26.OnClick := PaletteElementClick;
  RefreshComponentPaletteImages;
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
// Проверяет, является ли строка RGB565-цветом вида 0x1234.
function TForm1.IsRgb565Text(const AText: string): Boolean;
var
  I: Integer;
  S: string;
begin
  S := UpperCase(Trim(AText));
  Result := False;
  if Pos('0X', S) = 1 then
    S := Copy(S, 3, MaxInt);
  if (Length(S) < 1) or (Length(S) > 4) then
    Exit;
  for I := 1 to Length(S) do
    if not (S[I] in ['0'..'9', 'A'..'F']) then
      Exit;
  Result := True;
end;

//======================================================
// Возвращает первую строку скрипта с цветом заливки экрана.
function TForm1.ScreenFillScriptLine: string;
begin
  if IsNoColorRgb(FDefaultLcdBgRgb) then
    Result := ''
  else
    Result := 'CL|' + FDefaultLcdBgRgb;
end;

//======================================================
// Проверяет, является ли строка служебной строкой заливки LCD.
function TForm1.IsScreenFillRow(ARow: Integer): Boolean;
begin
  Result := ARow = 1;
end;

//======================================================
// Создаёт или обновляет постоянную первую строку заливки LCD.
procedure TForm1.EnsureScreenFillRow;
var
  C: Integer;
  FillLine: string;
begin
  if StringGrid1.RowCount < 2 then
    StringGrid1.RowCount := 2;
  FillLine := ScreenFillScriptLine;
  for C := 0 to StringGrid1.ColCount - 1 do
    StringGrid1.Cells[C, 1] := '';
  StringGrid1.Cells[COL_CMD, 1] := 'CL';
  StringGrid1.Cells[COL_TEXT, 1] := FillLine;
  StringGrid1.Cells[COL_C1, 1] := FDefaultLcdBgRgb;
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
  NextSdFontId: Integer;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
  procedure AddSdFontsFromDir(const ADir: string; var ANextSdFontId: Integer);
  var
    SR: TSearchRec;
    Mask: string;
    BaseName: string;
    IdText: string;
    FontId: Integer;
  begin
    if not DirectoryExists(ADir) then
      Exit;
    Mask := IncludeTrailingPathDelimiter(ADir) + '*.vlw';
    if FindFirst(Mask, faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) = 0 then
          begin
            BaseName := LowerCase(ChangeFileExt(SR.Name, ''));
            FontId := 0;
            if Copy(BaseName, 1, 4) = 'font' then
            begin
              IdText := Copy(BaseName, 5, MaxInt);
              FontId := StrToIntDef(IdText, 0);
            end;
            if FontId < 100 then
              Continue
            else if FontId >= ANextSdFontId then
              ANextSdFontId := FontId + 1;
            EnsureSdFontListItem(FontId, SR.Name);
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

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
      FFontList.Items.AddObject(IntToStr(I) + ' ' + Font.Name, TObject(Pointer(I)))
    else
      FFontList.Items.AddObject(IntToStr(I) + ' missing ' + FONT_FILE_MAP[I], TObject(Pointer(I)));
  end;

  NextSdFontId := 100;
  AddSdFontsFromDir(IncludeTrailingPathDelimiter(SdRootPath) + 'fonts', NextSdFontId);

  if FFontList.Items.Count > 1 then
    FFontList.ItemIndex := 1
  else if FFontList.Items.Count > 0 then
    FFontList.ItemIndex := 0;
end;

//======================================================
// Находит строку списка шрифтов по реальному ESP ID.
//======================================================
// Находит строку списка шрифтов по реальному ESP ID.
function TForm1.FontListIndexById(AFontId: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if not Assigned(FFontList) then
    Exit;
  for I := 0 to FFontList.Items.Count - 1 do
    if Integer(FFontList.Items.Objects[I]) = AFontId then
    begin
      Result := I;
      Exit;
    end;
end;

//======================================================
// Добавляет SD-шрифт в список, не смешивая его ID с индексом строки.
procedure TForm1.EnsureSdFontListItem(AFontId: Integer; const AName: string);
var
  Index: Integer;
  Caption: string;
begin
  if not Assigned(FFontList) then
    Exit;
  if AFontId < 100 then
    Exit;

  Caption := IntToStr(AFontId) + ' SD ' + AName;
  Index := FontListIndexById(AFontId);
  if Index < 0 then
    FFontList.Items.AddObject(Caption, TObject(Pointer(AFontId)))
  else
    FFontList.Items[Index] := Caption;
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
  try
    if AFontId >= 100 then
      Exit;
    if AFontId < 1 then
      AFontId := 1;
    if AFontId > FFontCache.Count then
      AFontId := FFontCache.Count;
    if AFontId < 1 then
      Exit;

    Result := TGfxFont(FFontCache[AFontId - 1]);
    if Result = nil then
      Exit;
    if not Result.Loaded then
      if not LoadGfxFontFile(Result) then
        Result := nil;
  except
    on E: Exception do
    begin
      Result := nil;
      SetStatus('Preview font error: ' + E.Message);
    end;
  end;
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
 // Numbers: TIntegerArray;
  I: Integer;
  G: Integer;
begin
  Result := False;
  try
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
  except
    on E: Exception do
    begin
      if AFont <> nil then
      begin
        SetLength(AFont.Bitmaps, 0);
        SetLength(AFont.Glyphs, 0);
        SetStatus('Font load error: ' + ExtractFileName(AFont.FileName) + ' - ' + E.Message);
      end
      else
        SetStatus('Font load error: ' + E.Message);
      Result := False;
    end;
  end;
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
// Возвращает локальный путь к VLW-шрифту SD по его ESP ID.
function TForm1.LocalVlwFontPath(AFontId: Integer): string;
var
  FileName: string;
begin
  Result := '';
  if AFontId < 100 then
    Exit;

  FileName := 'font' + IntToStr(AFontId) + '.vlw';
  Result := IncludeTrailingPathDelimiter(SdRootPath) + 'fonts\' + FileName;
  if not FileExists(Result) then
    Result := '';
end;

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
function ReadBeInt32(AStream: TStream): Integer;
var
  B: array[0..3] of Byte;
begin
  AStream.ReadBuffer(B, 4);
  Result := (Integer(B[0]) shl 24) or (Integer(B[1]) shl 16) or
    (Integer(B[2]) shl 8) or Integer(B[3]);
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function SignedVlwByte(AValue: Integer): Integer;
begin
  AValue := AValue and $FF;
  if AValue >= $80 then
    Result := AValue - $100
  else
    Result := AValue;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function SignedVlwWord(AValue: Integer): Integer;
begin
  AValue := AValue and $FFFF;
  if AValue >= $8000 then
    Result := AValue - $10000
  else
    Result := AValue;
end;

//======================================================
// Обрабатывает выбор и отображение цветов палитры.
function BlendVlwColor(ABackground, AForeground: TColor; AAlpha: Byte): TColor;
var
  BR, BG, BB: Integer;
  FR, FG, FB: Integer;
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
    (BR * (255 - AAlpha) + FR * AAlpha) div 255,
    (BG * (255 - AAlpha) + FG * AAlpha) div 255,
    (BB * (255 - AAlpha) + FB * AAlpha) div 255);
end;

//======================================================
// Загружает локальный VLW-шрифт для предпросмотра VLCD.
function TForm1.LoadVlwFontFile(const AFileName: string): TVlwFont;
var
  Stream: TFileStream;
  GlyphCount: Integer;
  I: Integer;
  BitmapPtr: Integer;
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
    Result.SpaceWidth := Result.YAdvance * 2 div 7;
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
      Result.Glyphs[I].DY := SignedVlwWord(ReadBeInt32(Stream));
      Result.Glyphs[I].DX := SignedVlwByte(ReadBeInt32(Stream));
      ReadBeInt32(Stream);
      Result.Glyphs[I].BitmapOffset := BitmapPtr;
      Inc(BitmapPtr, Result.Glyphs[I].Width * Result.Glyphs[I].Height);
    end;

    BitmapSize := Stream.Size - (24 + GlyphCount * 28);
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
function TForm1.VlwGlyphCode(AChar: AnsiChar): Integer;
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
function TForm1.FindVlwGlyph(AFont: TVlwFont; ACode: Integer; var AGlyph: TVlwGlyph): Boolean;
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
procedure TForm1.VlwTextBounds(AFont: TVlwFont; const AText: string; var AMinX, AMinY, AMaxX, AMaxY: Integer);
var
  I, Code, CursorX, X1, Y1, X2, Y2: Integer;
  Glyph: TVlwGlyph;
  HasPixels: Boolean;
begin
  AMinX := 0; AMinY := 0; AMaxX := 0; AMaxY := 0;
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
      AMinX := X1; AMinY := Y1; AMaxX := X2; AMaxY := Y2;
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
procedure TForm1.DrawVlwText(AFont: TVlwFont; const AText: string; ABaselineX, ABaselineY: Integer; AColor: TColor);
var
  I, Code, CursorX, XX, YY, PX, PY, BitmapIndex: Integer;
  Glyph: TVlwGlyph;
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
            if (PX >= 0) and (PX < FPreview.Width) and (PY >= 0) and (PY < FPreview.Height) then
              FPreview.Canvas.Pixels[PX, PY] := BlendVlwColor(FLcdBgColor, AColor, Alpha);
          end;
        end;
      end;
    Inc(CursorX, Glyph.XAdvance);
  end;
end;

//======================================================
// Работает со шрифтами и отрисовкой текста предпросмотра.
function TForm1.DrawVlwTextBox(AFontId: Integer; const AText: string; const ARect: TRect; AHAlign, AVAlign: string; AColor: TColor): Boolean;
var
  Font: TVlwFont;
  FontPath: string;
  MinX, MinY, MaxX, MaxY, TextW, TextH, LeftPos, TopPos: Integer;
begin
  Result := False;
  FontPath := LocalVlwFontPath(AFontId);
  if FontPath = '' then
    Exit;
  Font := LoadVlwFontFile(FontPath);
  try
    if (Font = nil) or (Length(Font.Glyphs) = 0) then
      Exit;
    VlwTextBounds(Font, AText, MinX, MinY, MaxX, MaxY);
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
    DrawVlwText(Font, AText, LeftPos - MinX, TopPos - MinY + GFX_PREVIEW_Y_CORRECTION, AColor);
    Result := True;
  finally
    Font.Free;
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
  if FActiveFontId >= 100 then
  begin
    Result := DrawVlwTextBox(FActiveFontId, AText, ARect, AHAlign, AVAlign, AColor);
    Exit;
  end;
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
  if IsScreenFillRow(ARow) then
  begin
    Result := ScreenFillScriptLine;
    Exit;
  end;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if Cmd = 'CL' then
    Result := ''
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
  else if (Cmd = 'TR') or (Cmd = 'VT') then
    Result := Format('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [Cmd, StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       '100', StringGrid1.Cells[COL_C1, ARow],
       StringGrid1.Cells[COL_C2, ARow], StringGrid1.Cells[COL_EXTRA, ARow]])
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
    Result := Format('SB|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], Orientation,
       StringGrid1.Cells[COL_TEXT, ARow], '100',
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow]])
  end
  else if (Cmd = 'PB') or (Cmd = 'VP') then
    Result := Format('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [Cmd, StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_C2, ARow],
       StringGrid1.Cells[COL_EXTRA, ARow]])
  else if Cmd = 'SW' then
    Result := Format('SW|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s',
      [StringGrid1.Cells[COL_ID, ARow], StringGrid1.Cells[COL_X, ARow],
       StringGrid1.Cells[COL_Y, ARow], StringGrid1.Cells[COL_W, ARow],
       StringGrid1.Cells[COL_H, ARow], StringGrid1.Cells[COL_TEXT, ARow],
       StringGrid1.Cells[COL_C1, ARow], StringGrid1.Cells[COL_FONT, ARow],
       StringGrid1.Cells[COL_C2, ARow], StringGrid1.Cells[COL_EXTRA, ARow],
       StringGrid1.Cells[COL_LINE, ARow]])
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
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'sd';
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

function NormalizeJpgScaleText(const AScale: string): string; forward;

//======================================================
// Открывает редактор области картинки для выбранной JPG-строки.
procedure TForm1.OpenImageAreaEditor(ARow: Integer);
var
  FileName: string;
  SrcX: Integer;
  SrcY: Integer;
  SrcW: Integer;
  SrcH: Integer;
  ScaleText: string;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  if UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow])) <> 'JPG' then
    Exit;

  FileName := LocalImagePathFromCommandPath(StringGrid1.Cells[COL_TEXT, ARow]);
  if not FileExists(FileName) then
  begin
//    StatusBar1.SimpleText := 'Image file not found: ' + ExtractFileName(FileName);
    SimpleText := 'Image file not found: ' + ExtractFileName(FileName);
///    Form4.Memo1.Lines.Add(SimpleText);
    Exit;
  end;

  SrcX := StrToIntDef(StringGrid1.Cells[COL_SRCX, ARow], 0);
  SrcY := StrToIntDef(StringGrid1.Cells[COL_SRCY, ARow], 0);
  SrcW := StrToIntDef(StringGrid1.Cells[COL_SRCW, ARow], 0);
  SrcH := StrToIntDef(StringGrid1.Cells[COL_SRCH, ARow], 0);
  ScaleText := NormalizeJpgScaleText(StringGrid1.Cells[COL_EXTRA, ARow]);
  if Form3.ExecuteCropWithJpgScale(FileName, SrcX, SrcY, SrcW, SrcH,
    ScaleText) then
  begin
    StringGrid1.Cells[COL_EXTRA, ARow] := NormalizeJpgScaleText(ScaleText);
    if (SrcW < 4) or (SrcH < 4) then
    begin
      SetStatus('Image area too small, selection ignored');
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
  SrcX: Integer;
  SrcY: Integer;
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
        SrcX := StrToIntDef(StringGrid1.Cells[COL_SRCX, ARow], 0);
        SrcY := StrToIntDef(StringGrid1.Cells[COL_SRCY, ARow], 0);
        if SrcX < 0 then SrcX := 0;
        if SrcY < 0 then SrcY := 0;
        if SrcX >= Picture.Width then SrcX := Picture.Width - 1;
        if SrcY >= Picture.Height then SrcY := Picture.Height - 1;
        SrcW := StrToIntDef(StringGrid1.Cells[COL_SRCW, ARow], 0);
        SrcH := StrToIntDef(StringGrid1.Cells[COL_SRCH, ARow], 0);
        if SrcW <= 0 then
          SrcW := Picture.Width - SrcX;
        if SrcH <= 0 then
          SrcH := Picture.Height - SrcY;
        if SrcX + SrcW > Picture.Width then
          SrcW := Picture.Width - SrcX;
        if SrcY + SrcH > Picture.Height then
          SrcH := Picture.Height - SrcY;
        if SrcW < 1 then SrcW := 1;
        if SrcH < 1 then SrcH := 1;
        StringGrid1.Cells[COL_SRCX, ARow] := IntToStr(SrcX);
        StringGrid1.Cells[COL_SRCY, ARow] := IntToStr(SrcY);
        StringGrid1.Cells[COL_SRCW, ARow] := IntToStr(SrcW);
        StringGrid1.Cells[COL_SRCH, ARow] := IntToStr(SrcH);
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
      SetStatus('Image load error: ' + ExtractFileName(FileName));
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
// Преобразует два HEX-символа в байт.
function HexPairByte(const AText: string; AIndex: Integer): Byte;
var
  Hi: Integer;
  Lo: Integer;

//======================================================
// Вспомогательная функция разбора, преобразования или расчёта.
  function Nibble(C: Char): Integer;
  begin
    if C in ['0'..'9'] then
      Result := Ord(C) - Ord('0')
    else if C in ['A'..'F'] then
      Result := Ord(C) - Ord('A') + 10
    else if C in ['a'..'f'] then
      Result := Ord(C) - Ord('a') + 10
    else
      Result := 0;
  end;
begin
  Hi := Nibble(AText[AIndex]);
  Lo := Nibble(AText[AIndex + 1]);
  Result := Byte((Hi shl 4) or Lo);
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
        SetStatus('Port read error: ' + ComboBox1.Text);
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

  SetStatus('Serial timeout waiting: ' + APrefix);
end;

//======================================================
// Передаёт локальный файл картинки на SD-карту ESP.
//======================================================
// Возвращает размер файла на SD ESP через FS|path.
function TForm1.RemoteSdFileSize(const ASdPath: string; var ASize: Int64): Boolean;
var
  Reply: string;
  P: Integer;
begin
  Result := False;
  ASize := -1;
  if not ExchangeEspLine('FS|' + ASdPath, 'OK|FS|', 1500, Reply) then
    Exit;
  P := LastDelimiter('|', Reply);
  if P <= 0 then
    Exit;
  ASize := StrToInt64Def(Trim(Copy(Reply, P + 1, MaxInt)), -1);
  Result := ASize >= 0;
end;

//======================================================
// Проверяет наличие VLW-шрифта на SD ESP и при необходимости загружает его.
function TForm1.EnsureEspSdFont(AFontId: Integer): Boolean;
var
  LocalFile: string;
  SdPath: string;
  RemoteSize: Int64;
  LocalSize: Int64;
  RewriteFont: Boolean;
  SR: TSearchRec;
begin
  Result := True;
  if AFontId < 100 then
    Exit;

  LocalFile := LocalVlwFontPath(AFontId);
  if LocalFile = '' then
  begin
    SetStatus('Local font not found: font' + IntToStr(AFontId) + '.vlw');
    Exit;
  end;

  SdPath := '/fonts/font' + IntToStr(AFontId) + '.vlw';
  RewriteFont := Assigned(CheckBox6) and CheckBox6.Checked;
  LocalSize := -1;
  if FindFirst(LocalFile, faAnyFile, SR) = 0 then
  begin
    LocalSize := SR.Size;
    FindClose(SR);
  end;

  if RewriteFont then
  begin
    Result := SendFileToEspSd(LocalFile, SdPath);
    Exit;
  end;

  if RemoteSdFileSize(SdPath, RemoteSize) then
  begin
    if (LocalSize >= 0) and (RemoteSize <> LocalSize) then
      SetStatus('Font size differs on ESP, enable Rewrite font: ' + SdPath)
    else
      SetStatus('Font already on ESP SD: ' + SdPath);
    Exit;
  end;

  if MessageDlg('Шрифт ' + ExtractFileName(LocalFile) + ' отсутствует на SD ESP. Загрузить?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Result := SendFileToEspSd(LocalFile, SdPath)
  else
    SetStatus('Font upload skipped: ' + SdPath);
end;

//======================================================
// Работает с файлами на локальной папке SD и SD-карте ESP.
function TForm1.SendFileToEspSd(const ALocalFileName: string; var ASdPath: string;
  AProgressLabel: TLabel; AForceOverwrite: Boolean): Boolean;
label
  RestartTransfer;
const
  CHUNK_SIZE = 64;
  UDP_CHUNK_SIZE = 48;
  UDP_BLOCK_DELAY_MS = 8;
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
  BlockSize: Integer;

  procedure SetTransferProgress(AValue: Integer);
  begin
    if Pos('/images/', LowerCase(ASdPath)) = 1 then
      SetImageProgress(AValue)
    else
      SetSdProgress(AValue);
  end;

//======================================================
// После таймаута UDP заново начинает весь файл через открытый COM.
// Последний UDP-блок мог дойти до ESP при потере ответа, поэтому
// продолжать с предполагаемого смещения небезопасно.
  function SwitchUploadToCom: Boolean;
  begin
    Result := UseUdp and (FPort <> INVALID_HANDLE_VALUE) and PortAlive;
    if not Result then
      Exit;
    UseUdp := False;
    ChannelName := 'COM';
    MonitorWasEnabled := Assigned(FPortMonitor) and FPortMonitor.Enabled;
    if Assigned(FPortMonitor) then
      FPortMonitor.Enabled := False;
    FPortRxText := '';
    SetStatus('UDP lost. Restarting SD upload through COM: ' + ASdPath);
    if Assigned(Form4) and Assigned(Form4.Memo1) then
      Form4.Memo1.Update;
    Application.ProcessMessages;
  end;

//======================================================
// Возвращает вычисленное значение для работы формы.
  function SendUploadLine(const ALine, AOkPrefix: string; ATimeoutMs: DWORD): Boolean;
  var
    Attempt: Integer;
    ReplyMatches: Boolean;
  begin
   // Result := False;
    if UseUdp then
    begin
      for Attempt := 1 to 3 do
      begin
        Result := UdpExchangeLine(ALine, Trim(Edit2.Text), False, ReplyLine,
          AOkPrefix, ATimeoutMs, False);
        if Pos('OK|FDO|', UpperCase(AOkPrefix)) = 1 then
          ReplyMatches := CompareText(AOkPrefix, ReplyLine) = 0
        else
          ReplyMatches := Pos(AOkPrefix, ReplyLine) = 1;
        if Result and ReplyMatches then
          Exit;
        if Pos('ERR|', UpperCase(ReplyLine)) = 1 then
          Exit;
        SetStatus('UDP retry ' + IntToStr(Attempt) + ': ' + ReplyLine);
        if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;
        Sleep(30);
      end;
      if not Result then
        ShowErrorPopup('UDP upload failed after 3 retries: ' + ASdPath);
    end
    else
    begin
      SendSerialLine(ALine);
      Result := WaitSerialReply(AOkPrefix, ATimeoutMs, ReplyLine);
    end;
    if Result and (Pos(AOkPrefix, ReplyLine) <> 1) then
      Result := False;
  end;

//======================================================
// Возвращает вычисленное значение для работы формы.
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
  SetTransferProgress(0);
  UseUdp := UdpEnabled;
  if UseUdp then
    ChannelName := 'UDP'
  else
    ChannelName := 'COM';
  if (not UseUdp) and (FPort = INVALID_HANDLE_VALUE) then
  begin
    SetStatus('Port is closed: ' + ComboBox1.Text);
    Exit;
  end;
  if not FileExists(ALocalFileName) then
  begin
    SetStatus('SD upload file not found: ' + ExtractFileName(ALocalFileName));
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

    SetStatus('SD upload ' + ChannelName + ' start: ' +
      ASdPath + ' (' + IntToStr(Stream.Size) + ' bytes)');
    if Assigned(AProgressLabel) then
    begin
      AProgressLabel.Caption := '0%';
      AProgressLabel.Update;
    end;
    if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;

    if RemoteFileExists(RemoteSize) then
    begin
      if AForceOverwrite or
        ((Pos('/fonts/', LowerCase(ASdPath)) = 1) and Assigned(CheckBox6) and CheckBox6.Checked) then
      begin
        SetStatus('SD upload overwrite: ' + ASdPath);
        if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;
      end
      else
      begin
        SetStatus('SD upload skipped, exists: ' + ASdPath);
        if Assigned(AProgressLabel) then
        begin
          AProgressLabel.Caption := '100%';
          AProgressLabel.Update;
        end;
        SetTransferProgress(100);
        if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;
        Result := True;
        Exit;
      end;
    end;

RestartTransfer:
    Stream.Position := 0;
    Sent := 0;
    if UseUdp then
      BlockSize := UDP_CHUNK_SIZE
    else
      BlockSize := CHUNK_SIZE;
    SetTransferProgress(0);
    if Assigned(AProgressLabel) then
    begin
      AProgressLabel.Caption := '0%';
      AProgressLabel.Update;
    end;
    if not SendUploadLine('FW|' + ASdPath + '|' + IntToStr(Stream.Size), 'OK|FW|', 3000) then
    begin
      if SwitchUploadToCom then
        goto RestartTransfer;
      SetStatus('SD upload start failed: ' + ReplyLine);
      Exit;
    end;

    repeat
      ReadCount := Stream.Read(Buffer, BlockSize);
      if ReadCount > 0 then
      begin
        if UseUdp then
          HexLine := 'FDO|' + IntToStr(Sent) + '|'
        else
          HexLine := 'FD|';
        for I := 0 to ReadCount - 1 do
          HexLine := HexLine + HexByte(Buffer[I]);
        if UseUdp then
          ExpectedPrefix := 'OK|FDO|' + IntToStr(Sent + ReadCount)
        else
          ExpectedPrefix := 'OK|FD|';
        if not SendUploadLine(HexLine, ExpectedPrefix, 3000) then
        begin
          if SwitchUploadToCom then
            goto RestartTransfer;
          SetStatus('SD upload block failed: ' + ReplyLine);
          Exit;
        end;
        Inc(Sent, ReadCount);
        if Stream.Size > 0 then
          Percent := Sent * 100 div Stream.Size
        else
          Percent := 100;
        SetTransferProgress(Percent);
        SetStatus('SD upload ' + IntToStr(Percent) + '%: ' + ASdPath +
          ' ' + IntToStr(Sent) + '/' + IntToStr(Stream.Size));
        if Assigned(AProgressLabel) then
        begin
          AProgressLabel.Caption := IntToStr(Percent) + '%';
          AProgressLabel.Update;
        end;
        if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;
        Application.ProcessMessages;
        if UseUdp then
          Sleep(UDP_BLOCK_DELAY_MS);
      end;
    until ReadCount = 0;

    if not SendUploadLine('FE', 'OK|FE|', 5000) then
    begin
      if SwitchUploadToCom then
        goto RestartTransfer;
      SetStatus('SD upload finish failed: ' + ReplyLine);
      Exit;
    end;
    SetTransferProgress(100);
    SetStatus('SD upload done: ' + ASdPath);
    if Assigned(AProgressLabel) then
    begin
      AProgressLabel.Caption := '100%';
      AProgressLabel.Update;
    end;
    if Assigned(Form4) and Assigned(Form4.Memo1) then Form4.Memo1.Update;
    Result := True;
  finally
    if (not UseUdp) and Assigned(FPortMonitor) then
      FPortMonitor.Enabled := MonitorWasEnabled;
    Stream.Free;
  end;
end;

//======================================================
// Загружает файл JPG для выбранной строки, если это требуется.
function TForm1.UploadImageRowToEsp(ARow: Integer;
  AForceOverwrite: Boolean): Boolean;
var
  Cmd: string;
  SdPath: string;
  LocalFileName: string;
begin
  Result := True;
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  if IsScreenFillRow(ARow) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if Cmd <> 'JPG' then
    Exit;
  if (not UdpEnabled) and (FPort = INVALID_HANDLE_VALUE) then
  begin
    SetStatus('JPG SD upload skipped: COM closed');
    Exit;
  end;
  SdPath := Trim(StringGrid1.Cells[COL_TEXT, ARow]);
  LocalFileName := LocalImagePathFromCommandPath(SdPath);
  Result := SendFileToEspSd(LocalFileName, SdPath, nil, AForceOverwrite);
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
  if IsScreenFillRow(ARow) then
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
  R, ItemIndex, XPos, YPos, W, H, MaxX, MaxY: Integer;
begin
  EnsureScreenFillRow;
  R := StringGrid1.RowCount;
  StringGrid1.RowCount := StringGrid1.RowCount + 1;

  StringGrid1.Cells[COL_CMD, R] := AKind;
  StringGrid1.Cells[COL_ID, R] := IntToStr(R - 1);
  StringGrid1.Cells[COL_X, R] := '20';
  StringGrid1.Cells[COL_Y, R] := '20';
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
    StringGrid1.Cells[COL_TEXT, R] := 'Button';
    StringGrid1.Cells[COL_C1, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_LINE, R] := '1';
  end
  else if AKind = 'TX' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := 'Text';
    StringGrid1.Cells[COL_W, R] := '100';
    StringGrid1.Cells[COL_H, R] := '30';
    StringGrid1.Cells[COL_C1, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_FONT, R] := '2';
  end
  else if (AKind = 'TR') or (AKind = 'VT') then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '50';
    if AKind = 'VT' then
    begin
      StringGrid1.Cells[COL_W, R] := '36';
      StringGrid1.Cells[COL_H, R] := '180';
    end
    else
    begin
      StringGrid1.Cells[COL_W, R] := '180';
      StringGrid1.Cells[COL_H, R] := '36';
    end;
    StringGrid1.Cells[COL_C1, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultElementRgb;
  end
  else if (AKind = 'PB') or (AKind = 'VP') then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '50';
    if AKind = 'VP' then
    begin
      StringGrid1.Cells[COL_W, R] := '32';
      StringGrid1.Cells[COL_H, R] := '180';
    end
    else
    begin
      StringGrid1.Cells[COL_W, R] := '180';
      StringGrid1.Cells[COL_H, R] := '32';
    end;
    StringGrid1.Cells[COL_C1, R] := FDefaultElementRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultLineRgb;
  end
  else if AKind = 'SW' then
  begin
    StringGrid1.Cells[COL_TEXT, R] := '0';
    StringGrid1.Cells[COL_W, R] := '65';
    StringGrid1.Cells[COL_H, R] := '28';
    StringGrid1.Cells[COL_C1, R] := FDefaultLineRgb;
    StringGrid1.Cells[COL_FONT, R] := FDefaultFgRgb;
    StringGrid1.Cells[COL_C2, R] := FDefaultBgRgb;
    StringGrid1.Cells[COL_EXTRA, R] := FDefaultElementRgb;
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

  // Place new components on a compact grid and keep the whole element on LCD.
  ItemIndex := R - 1;
  XPos := 20 + (ItemIndex mod 10) * 20;
  YPos := 20 + ((ItemIndex div 10) mod 8) * 20;
  W := StrToIntDef(StringGrid1.Cells[COL_W, R], 1);
  H := StrToIntDef(StringGrid1.Cells[COL_H, R], 1);
  MaxX := 480 - W;
  MaxY := 320 - H;
  if MaxX < 0 then MaxX := 0;
  if MaxY < 0 then MaxY := 0;
  if XPos > MaxX then XPos := MaxX;
  if YPos > MaxY then YPos := MaxY;
  StringGrid1.Cells[COL_X, R] := IntToStr(XPos);
  StringGrid1.Cells[COL_Y, R] := IntToStr(YPos);

  SelectRow(R);
end;

//======================================================
// Разбирает строку скрипта и добавляет её в таблицу редактора.
procedure TForm1.AddScriptLine(const ALine: string);
var
  Parts: TStringList;
  R: Integer;
  Cmd: string;

//======================================================
// Возвращает вычисленное значение для работы формы.
  function Part(Index: Integer; const Default: string = ''): string;
  begin
    if Index < Parts.Count then
      Result := Parts[Index]
    else
      Result := Default;
  end;

begin
  if (Trim(ALine) = '') or (Copy(Trim(ALine), 1, 1) = '#') or
    (Copy(Trim(ALine), 1, 1) = ';') then
    Exit;

  Parts := TStringList.Create;
  try
    SplitPipe(Trim(ALine), Parts);
    if Parts.Count = 0 then
      Exit;
    Cmd := UpperCase(Trim(Part(0)));
    if Cmd = '' then
      Exit;
    if (Parts.Count = 1) and IsRgb565Text(Cmd) then
    begin
      FDefaultLcdBgRgb := Cmd;
      if IsNoColorRgb(Cmd) then
        FLcdBgColor := clBlack
      else
        FLcdBgColor := Rgb565ToColor(Cmd, FLcdBgColor);
      EnsureScreenFillRow;
      RefreshColorFieldShapes;
      Exit;
    end;
    if Cmd = 'CL' then
    begin
      FDefaultLcdBgRgb := Part(1, FDefaultLcdBgRgb);
      if IsNoColorRgb(FDefaultLcdBgRgb) then
        FLcdBgColor := clBlack
      else
        FLcdBgColor := Rgb565ToColor(FDefaultLcdBgRgb, FLcdBgColor);
      EnsureScreenFillRow;
      RefreshColorFieldShapes;
      Exit;
    end;
    if (Cmd = 'C') or (Cmd = 'L') or (Cmd = 'I') or (Cmd = 'B') or
      (Cmd = 'W') or (Cmd = 'S') or (Cmd = 'T') then
      Exit;

    EnsureScreenFillRow;
    R := StringGrid1.RowCount;
    StringGrid1.RowCount := StringGrid1.RowCount + 1;

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
    else if (Cmd = 'TR') or (Cmd = 'VT') then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, '50');
      StringGrid1.Cells[COL_C1, R] := Part(8, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(9, '0x07E0');
      StringGrid1.Cells[COL_EXTRA, R] := Part(10, FDefaultElementRgb);
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
      StringGrid1.Cells[COL_C1, R] := Part(9, '0xFFFF');
      StringGrid1.Cells[COL_C2, R] := Part(10, '0x07E0');
      StringGrid1.Cells[COL_EXTRA, R] := Part(11, FDefaultElementRgb);
    end
    else if Cmd = 'SW' then
    begin
      StringGrid1.Cells[COL_TEXT, R] := Part(6, '0');
      StringGrid1.Cells[COL_C1, R] := Part(7, '0x8410');
      if Parts.Count >= 12 then
      begin
        StringGrid1.Cells[COL_FONT, R] := Part(8, FDefaultFgRgb);
        StringGrid1.Cells[COL_C2, R] := Part(9, '0x07E0');
        StringGrid1.Cells[COL_EXTRA, R] := Part(10, FDefaultElementRgb);
        StringGrid1.Cells[COL_LINE, R] := Part(11, '1');
      end
      else
      begin
        StringGrid1.Cells[COL_FONT, R] := FDefaultFgRgb;
        StringGrid1.Cells[COL_C2, R] := Part(8, '0x07E0');
        StringGrid1.Cells[COL_EXTRA, R] := Part(9, FDefaultElementRgb);
      end;
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
    IsScreenFillRow(FSelectedRow) or
    (Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]) = '') then
    Exit;

  R := StringGrid1.RowCount;
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  for C := 0 to StringGrid1.ColCount - 1 do
    StringGrid1.Cells[C, R] := StringGrid1.Cells[C, FSelectedRow];
  StringGrid1.Cells[COL_ID, R] := IntToStr(R - 1);
  StringGrid1.Cells[COL_X, R] := IntToStr(StrToIntDef(StringGrid1.Cells[COL_X, R], 0) + 4);
  StringGrid1.Cells[COL_Y, R] := IntToStr(StrToIntDef(StringGrid1.Cells[COL_Y, R], 0) + 4);
  SelectRow(R);
end;

//======================================================
// Переносит значения полей редактора обратно в текущую строку таблицы.
procedure TForm1.UpdateRowFromInputs(ARow: Integer);
var
  Cmd: string;
  ScaleNum, ScaleDen: Integer;
  SrcW, SrcH: Integer;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  if IsScreenFillRow(ARow) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  StringGrid1.Cells[COL_X, ARow] := IntToStr(SpinEdit1.Value);
  StringGrid1.Cells[COL_Y, ARow] := IntToStr(SpinEdit2.Value);
  if Cmd = 'JPG' then
  begin
    StringGrid1.Cells[COL_SRCX, ARow] := IntToStr(SpinEdit7.Value);
    StringGrid1.Cells[COL_SRCY, ARow] := IntToStr(SpinEdit8.Value);
    JpgScaleRatio(StringGrid1.Cells[COL_EXTRA, ARow], ScaleNum, ScaleDen);
    SrcW := (SpinEdit3.Value * ScaleDen + ScaleNum - 1) div ScaleNum;
    SrcH := (SpinEdit4.Value * ScaleDen + ScaleNum - 1) div ScaleNum;
    if SrcW < 1 then SrcW := 1;
    if SrcH < 1 then SrcH := 1;
    StringGrid1.Cells[COL_SRCW, ARow] := IntToStr(SrcW);
    StringGrid1.Cells[COL_SRCH, ARow] := IntToStr(SrcH);
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
    if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'PB') or (Cmd = 'VP') or
      (Cmd = 'SW') or (Cmd = 'SB') then
      StringGrid1.Cells[COL_TEXT, ARow] := IntToStr(SpinEdit6.Value);
      if (Cmd = 'BT') or (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC') or (Cmd = 'SW') then
      begin
        if Assigned(FLineTrack) then
          StringGrid1.Cells[COL_LINE, ARow] := IntToStr(FLineTrack.Position);
      end;
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
  HasValue := HasRow and ((Cmd = 'TR') or (Cmd = 'VT') or
    (Cmd = 'PB') or (Cmd = 'VP') or (Cmd = 'SW') or (Cmd = 'SB'));
  HasLine := HasRow and ((Cmd = 'BT') or (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC') or (Cmd = 'SW'));
  HasFont := HasRow and ((Cmd = 'TX') or (Cmd = 'BT'));
  HasAlign := HasFont;
  HasPicture := HasRow and (Cmd = 'JPG');
  HasText := HasRow and ((Cmd = 'BT') or (Cmd = 'TX'));

  SetControlState(Label1, HasPosition);
  SetControlState(Label4, HasPosition);
  SetControlState(SpinEdit1, HasPosition);
  SetControlState(SpinEdit2, HasPosition);

  SetControlState(Label6, HasWidth);
  SetControlState(Label7, HasHeight);
  SetControlState(SpinEdit3, HasWidth);
  SetControlState(SpinEdit4, HasHeight);

  SetControlState(Label3, HasPicture);
  SetControlState(Label5, HasPicture);

  SetControlState(Label14, HasRound);
  SetControlState(SpinEdit5, HasRound);

  SetControlState(Label16, HasValue);
  SetControlState(SpinEdit6, HasValue);

  Label23.Visible := False;
  SetControlState(Label28, HasLine);
  SetControlState(FLineTrackLabel, HasLine);
  SetControlState(FLineTrack, HasLine);

  SetControlState(Label24, HasFont);
  SetControlState(FFontListLabel, HasFont);
  SetControlState(FFontList, HasFont);
  SetControlState(Button9, HasFont);
  SetControlState(Label27, HasAlign);
  SetControlState(Label29, HasAlign);
  SetControlState(ComboBox2, HasAlign);
  SetControlState(ComboBox3, HasAlign);
  SetControlState(Label17, HasText);
  SetControlState(Edit4, HasText);

  SetControlState(Button3, HasPicture);
  SetControlState(Button13, HasPicture);
  SetControlState(CheckBox4, HasPicture);
  SetControlState(Label36, HasPicture);
  SetControlState(ComboBox6, HasPicture);
  SetControlState(SpinEdit7, HasPicture);
  SetControlState(SpinEdit8, HasPicture);
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
    if (Cmd = 'TR') or (Cmd = 'VT') then
      CheckBox8.Checked := Cmd = 'VT';
    if (Cmd = 'PB') or (Cmd = 'VP') then
      CheckBox7.Checked := Cmd = 'VP';
    SpinEdit1.Value := StrToIntDef(StringGrid1.Cells[COL_X, ARow], 0);
    SpinEdit2.Value := StrToIntDef(StringGrid1.Cells[COL_Y, ARow], 0);
    SpinEdit3.Value := StrToIntDef(StringGrid1.Cells[COL_W, ARow], 0);
    SpinEdit4.Value := StrToIntDef(StringGrid1.Cells[COL_H, ARow], 0);
    if Cmd = 'JPG' then
    begin
      SpinEdit7.Value := StrToIntDef(StringGrid1.Cells[COL_SRCX, ARow], 0);
      SpinEdit8.Value := StrToIntDef(StringGrid1.Cells[COL_SRCY, ARow], 0);
    end
    else
    begin
      SpinEdit7.Value := 0;
      SpinEdit8.Value := 0;
    end;
    if Cmd = 'JPG' then
      ComboBox6.ItemIndex := ComboBox6.Items.IndexOf(
        NormalizeJpgScaleText(StringGrid1.Cells[COL_EXTRA, ARow]))
    else
      ComboBox6.ItemIndex := ComboBox6.Items.IndexOf('1/1');
    if ComboBox6.ItemIndex < 0 then
      ComboBox6.ItemIndex := ComboBox6.Items.IndexOf('1/1');
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
      if FontId >= 100 then
        EnsureSdFontListItem(FontId, 'font' + IntToStr(FontId) + '.vlw');
      FontId := FontListIndexById(FontId);
      if FontId < 0 then
        FontId := FontListIndexById(2);
      FFontList.ItemIndex := FontId;
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

//======================================================
// Выполняет действие формы или редактора.
  procedure SetLine(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultLineRgb := AValue;
  end;

//======================================================
// Выполняет действие формы или редактора.
  procedure SetText(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultFgRgb := AValue;
  end;

//======================================================
// Выполняет действие формы или редактора.
  procedure SetFill(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultBgRgb := AValue;
  end;

//======================================================
// Выполняет действие формы или редактора.
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

//======================================================
// Выполняет действие формы или редактора.
  procedure SetElement(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      FDefaultElementRgb := AValue;
  end;

begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;

  if IsScreenFillRow(ARow) then
  begin
    RefreshColorFieldShapes;
    Exit;
  end;

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
  else if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') then
  begin
    SetLine(C1);
    SetFill(C2);
    SetElement(Extra);
  end
  else if Cmd = 'SW' then
  begin
    SetLine(C1);
    SetText(StringGrid1.Cells[COL_FONT, ARow]);
    SetFill(C2);
    SetElement(Extra);
  end
  else if (Cmd = 'PB') or (Cmd = 'VP') then
  begin
    SetElement(C1);
    SetFill(C2);
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
  if IsScreenFillRow(FSelectedRow) then
  begin
    FDefaultLcdBgRgb := '0x0001';
    FLcdBgColor := clBlack;
    EnsureScreenFillRow;
    RefreshColorFieldShapes;
    Edit1.Text := ScriptFromRow(FSelectedRow);
    RepaintPreview;
    Exit;
  end;
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
  HitRc: TRect;
  ResizeRc: TRect;
  P: TPoint;
begin
  Result := -1;
  AResize := False;
  P := DisplayPoint(AX, AY);
  for R := StringGrid1.RowCount - 1 downto 1 do
    if RowRect(R, Rc) then
    begin
      ResizeRc := Rect(Rc.Right - 10, Rc.Bottom - 10,
        Rc.Right + 4, Rc.Bottom + 4);
      if PtInRect(ResizeRc, P) then
      begin
        AResize := True;
        Result := R;
        Exit;
      end;
      HitRc := Rc;
      InflateRect(HitRc, 2, 2);
      if PtInRect(HitRc, P) then
      begin
        Result := R;
        Exit;
      end;
    end;
end;

//======================================================
// Записывает изменённые координаты и размер элемента в строку таблицы.
procedure TForm1.SetRowRect(ARow: Integer; const ARect: TRect);
var
  W: Integer;
  H: Integer;
  ScaleNum: Integer;
  ScaleDen: Integer;
  SrcW: Integer;
  SrcH: Integer;
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
  begin
    JpgScaleRatio(StringGrid1.Cells[COL_EXTRA, ARow], ScaleNum, ScaleDen);
    SrcW := (W * ScaleDen + ScaleNum - 1) div ScaleNum;
    SrcH := (H * ScaleDen + ScaleNum - 1) div ScaleNum;
    if SrcW < 1 then SrcW := 1;
    if SrcH < 1 then SrcH := 1;
    StringGrid1.Cells[COL_SRCW, ARow] := IntToStr(SrcW);
    StringGrid1.Cells[COL_SRCH, ARow] := IntToStr(SrcH);
    UpdateImageRowSize(ARow);
  end
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
  Result := ExtractFilePath(ParamStr(0)) + 'GUIMaker.ini';
end;

//======================================================
// Определяет, применимо ли цветовое поле к выбранному типу элемента.
function TForm1.ColorFieldAppliesToCommand(AField: TColorField; const ACmd: string): Boolean;
var
  Cmd: string;
begin
  Cmd := UpperCase(Trim(ACmd));
  Result := True;
  if Cmd = 'BT' then
    Result := (AField = cfLine) or (AField = cfText) or (AField = cfBack)
  else if (Cmd = 'TX') or (Cmd = 'BM') then
    Result := (AField = cfText) or (AField = cfBack)
  else if (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC') or (Cmd = 'TW') then
    Result := (AField = cfLine) or (AField = cfBack)
  else if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') or
    (Cmd = 'PB') or (Cmd = 'VP') then
    Result := (AField = cfLine) or (AField = cfBack) or (AField = cfElement)
  else if Cmd = 'SW' then
    Result := (AField = cfLine) or (AField = cfText) or (AField = cfBack) or (AField = cfElement)
  else if Cmd = 'CL' then
    Result := AField = cfLcdBack
  else if Cmd = 'JPG' then
    Result := False;
end;
//======================================================
// Выбирает активное цветовое поле stroke/text/fill/screen.
procedure TForm1.SetActiveColorField(AField: TColorField);
var
  Cmd: string;
begin
  Cmd := '';
  if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
    Cmd := StringGrid1.Cells[COL_CMD, FSelectedRow];
  if not ColorFieldAppliesToCommand(AField, Cmd) then
    Exit;
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
var
  Cmd: string;

//======================================================
// Выполняет действие формы или редактора.
  procedure SetupShape(AShape: TShape; AField: TColorField; const ARgb: string);
  var
    FieldEnabled: Boolean;
  begin
    FieldEnabled := ColorFieldAppliesToCommand(AField, Cmd);
    AShape.Enabled := FieldEnabled;
    if not FieldEnabled then
    begin
      AShape.Brush.Style := bsSolid;
      AShape.Brush.Color := clBtnFace;
    end
    else if IsNoColorRgb(ARgb) then
    begin
      AShape.Brush.Color := clGray;
      AShape.Brush.Style := bsDiagCross;
    end
    else
    begin
      AShape.Brush.Style := bsSolid;
      AShape.Brush.Color := Rgb565ToColor(ARgb, AShape.Brush.Color);
    end;

    if (FActiveColorField = AField) and FieldEnabled then
    begin
      AShape.Pen.Color := clRed;
      AShape.Pen.Width := 3;
    end
    else
    begin
      if not FieldEnabled then
        AShape.Pen.Color := clGray
      else if IsNoColorRgb(ARgb) then
        AShape.Pen.Color := clGray
      else
        AShape.Pen.Color := clBlack;
      AShape.Pen.Width := 1;
    end;

    if Assigned(FNoColorLabels[AField]) then
    begin
      FNoColorLabels[AField].SetBounds(AShape.Left, AShape.Top, AShape.Width, AShape.Height);
      FNoColorLabels[AField].Enabled := FieldEnabled;
      FNoColorLabels[AField].Visible := FieldEnabled and IsNoColorRgb(ARgb);
      if FNoColorLabels[AField].Visible then
        FNoColorLabels[AField].BringToFront;
    end;
  end;

//======================================================
// Выполняет действие формы или редактора.
  procedure SetupFieldLabel(ALabel: TLabel; AField: TColorField);
  begin
    if not Assigned(ALabel) then
      Exit;
    ALabel.Enabled := ColorFieldAppliesToCommand(AField, Cmd);
    if ALabel.Enabled then
      ALabel.Font.Color := clWindowText
    else
      ALabel.Font.Color := clGray;
  end;

//======================================================
// Show the current RGB565 value below its color preview shape.
  procedure SetupColorValueLabel(ALabel: TLabel; AField: TColorField;
    const ARgb: string);
  begin
    if not Assigned(ALabel) then
      Exit;
    ALabel.Caption := UpperCase(ARgb);
    SetupFieldLabel(ALabel, AField);
  end;
begin
  EnsureNoColorLabels;
  Cmd := '';
  if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
    Cmd := StringGrid1.Cells[COL_CMD, FSelectedRow];
  if not ColorFieldAppliesToCommand(FActiveColorField, Cmd) then
  begin
    if ColorFieldAppliesToCommand(cfLine, Cmd) then
      FActiveColorField := cfLine
    else if ColorFieldAppliesToCommand(cfBack, Cmd) then
      FActiveColorField := cfBack
    else if ColorFieldAppliesToCommand(cfElement, Cmd) then
      FActiveColorField := cfElement
    else if ColorFieldAppliesToCommand(cfText, Cmd) then
      FActiveColorField := cfText
    else if ColorFieldAppliesToCommand(cfLcdBack, Cmd) then
      FActiveColorField := cfLcdBack;
  end;
  SetupShape(Shape6, cfLine, FDefaultLineRgb);
  SetupShape(Shape7, cfText, FDefaultFgRgb);
  SetupShape(Shape8, cfBack, FDefaultBgRgb);
  SetupShape(Shape9, cfLcdBack, FDefaultLcdBgRgb);
  SetupShape(Shape11, cfElement, FDefaultElementRgb);
  SetupFieldLabel(Label8, cfLine);
  SetupFieldLabel(Label9, cfText);
  SetupFieldLabel(Label19, cfBack);
  SetupFieldLabel(Label25, cfLcdBack);
  SetupFieldLabel(Label30, cfElement);
  SetupColorValueLabel(Label32, cfLine, FDefaultLineRgb);
  SetupColorValueLabel(Label33, cfText, FDefaultFgRgb);
  SetupColorValueLabel(Label34, cfBack, FDefaultBgRgb);
  SetupColorValueLabel(Label35, cfElement, FDefaultElementRgb);
  RefreshComponentPaletteImages;
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


    if not ColorFieldAppliesToCommand(FActiveColorField, Cmd) then
      Exit;
  case FActiveColorField of
    cfLine:
      begin
        FDefaultLineRgb := ARgb;
        if HasRow then
        begin
          if (Cmd = 'PB') or (Cmd = 'VP') then
            StringGrid1.Cells[COL_EXTRA, FSelectedRow] := ARgb
          else if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') or (Cmd = 'SW') then
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
          else if Cmd = 'SW' then
            StringGrid1.Cells[COL_FONT, FSelectedRow] := ARgb
          else
            StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb;
        end;
      end;
    cfBack:
      begin
        FDefaultBgRgb := ARgb;
        if HasRow then
        begin
          if (Cmd = 'TX') or (Cmd = 'BM') or (Cmd = 'TR') or (Cmd = 'VT') or
            (Cmd = 'SB') or (Cmd = 'SW') or (Cmd = 'PB') or (Cmd = 'VP') then
            StringGrid1.Cells[COL_C2, FSelectedRow] := ARgb
          else
            StringGrid1.Cells[COL_C1, FSelectedRow] := ARgb;
        end;
      end;
    cfElement:
      begin
        FDefaultElementRgb := ARgb;
        if HasRow then
        begin
          if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') or (Cmd = 'SW') then
            StringGrid1.Cells[COL_EXTRA, FSelectedRow] := ARgb
          else if (Cmd = 'PB') or (Cmd = 'VP') then
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
        if HasRow and ((Cmd = 'CL') or IsScreenFillRow(FSelectedRow)) then
          EnsureScreenFillRow;
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
  else if Sender = Shape11 then
    Field := cfElement
  else if Sender = FNoColorLabels[cfLine] then
    Field := cfLine
  else if Sender = FNoColorLabels[cfText] then
    Field := cfText
  else if Sender = FNoColorLabels[cfBack] then
    Field := cfBack
  else if Sender = FNoColorLabels[cfLcdBack] then
    Field := cfLcdBack
  else if Sender = FNoColorLabels[cfElement] then
    Field := cfElement
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
// Возвращает цвет компонента в смысловом поле Stroke/Text/Fill/Element.
function TForm1.RowColorValue(ARow: Integer; AField: TColorField;
  var AValue: string): Boolean;
var
  Cmd: string;
begin
  Result := False;
  AValue := '';
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));

  if Cmd = 'CL' then
  begin
    if AField = cfLcdBack then
      AValue := StringGrid1.Cells[COL_C1, ARow]
    else
      Exit;
  end
  else if Cmd = 'BT' then
    case AField of
      cfLine: AValue := StringGrid1.Cells[COL_C2, ARow];
      cfText: AValue := StringGrid1.Cells[COL_EXTRA, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C1, ARow];
    else
      Exit;
    end
  else if (Cmd = 'TX') or (Cmd = 'BM') then
    case AField of
      cfText: AValue := StringGrid1.Cells[COL_C1, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C2, ARow];
    else
      Exit;
    end
  else if (Cmd = 'BX') or (Cmd = 'RR') or (Cmd = 'CC') or (Cmd = 'TW') then
    case AField of
      cfLine: AValue := StringGrid1.Cells[COL_C2, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C1, ARow];
    else
      Exit;
    end
  else if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') then
    case AField of
      cfLine: AValue := StringGrid1.Cells[COL_C1, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C2, ARow];
      cfElement: AValue := StringGrid1.Cells[COL_EXTRA, ARow];
    else
      Exit;
    end
  else if (Cmd = 'PB') or (Cmd = 'VP') then
    case AField of
      cfLine: AValue := StringGrid1.Cells[COL_EXTRA, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C2, ARow];
      cfElement: AValue := StringGrid1.Cells[COL_C1, ARow];
    else
      Exit;
    end
  else if Cmd = 'SW' then
    case AField of
      cfLine: AValue := StringGrid1.Cells[COL_C1, ARow];
      cfText: AValue := StringGrid1.Cells[COL_FONT, ARow];
      cfBack: AValue := StringGrid1.Cells[COL_C2, ARow];
      cfElement: AValue := StringGrid1.Cells[COL_EXTRA, ARow];
    else
      Exit;
    end
  else
    Exit;

  AValue := Trim(AValue);
  Result := AValue <> '';
end;

//======================================================
// Назначает компоненту цвет по смысловому полю, независимо от типа команды.
procedure TForm1.SetRowColorValue(ARow: Integer; AField: TColorField;
  const AValue: string);
var
  Cmd: string;
begin
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) or (Trim(AValue) = '') then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  if not ColorFieldAppliesToCommand(AField, Cmd) then
    Exit;

  case AField of
    cfLine:
      if (Cmd = 'PB') or (Cmd = 'VP') then
        StringGrid1.Cells[COL_EXTRA, ARow] := AValue
      else if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') or (Cmd = 'SW') then
        StringGrid1.Cells[COL_C1, ARow] := AValue
      else
        StringGrid1.Cells[COL_C2, ARow] := AValue;
    cfText:
      if Cmd = 'BT' then
        StringGrid1.Cells[COL_EXTRA, ARow] := AValue
      else if Cmd = 'SW' then
        StringGrid1.Cells[COL_FONT, ARow] := AValue
      else
        StringGrid1.Cells[COL_C1, ARow] := AValue;
    cfBack:
      if (Cmd = 'TX') or (Cmd = 'BM') or (Cmd = 'TR') or (Cmd = 'VT') or
        (Cmd = 'SB') or (Cmd = 'SW') or (Cmd = 'PB') or (Cmd = 'VP') then
        StringGrid1.Cells[COL_C2, ARow] := AValue
      else
        StringGrid1.Cells[COL_C1, ARow] := AValue;
    cfElement:
      if (Cmd = 'TR') or (Cmd = 'VT') or (Cmd = 'SB') or (Cmd = 'SW') then
        StringGrid1.Cells[COL_EXTRA, ARow] := AValue
      else if (Cmd = 'PB') or (Cmd = 'VP') then
        StringGrid1.Cells[COL_C1, ARow] := AValue;
    cfLcdBack:
      if Cmd = 'CL' then
        StringGrid1.Cells[COL_C1, ARow] := AValue;
  end;
end;

//======================================================
// Возвращает стандартный цвет активной темы для указанного поля.
function TForm1.ThemeDefaultColor(AField: TColorField): string;
var
  Rgb24: LongWord;
begin
  case AField of
    cfLine: Result := FDefaultLineRgb;
    cfText: Result := FDefaultFgRgb;
    cfBack: Result := FDefaultBgRgb;
    cfLcdBack: Result := FDefaultLcdBgRgb;
  else
    Result := FDefaultElementRgb;
  end;
  Rgb24 := 0;
  case ComboBox5.ItemIndex of
    0: case AField of
         cfLine: Rgb24 := $00F5FF; cfText: Rgb24 := $F8FAFC;
         cfBack: Rgb24 := $111827; cfElement: Rgb24 := $39FF14;
         cfLcdBack: Rgb24 := $05070D;
       end;
    1: case AField of
         cfLine: Rgb24 := $64748B; cfText: Rgb24 := $F3F4F6;
         cfBack: Rgb24 := $1F2937; cfElement: Rgb24 := $3B82F6;
         cfLcdBack: Rgb24 := $0B0F14;
       end;
    2: case AField of
         cfLine: Rgb24 := $334155; cfText: Rgb24 := $0F172A;
         cfBack: Rgb24 := $F1F5F9; cfElement: Rgb24 := $2563EB;
         cfLcdBack: Rgb24 := $FFFFFF;
       end;
    3: case AField of
         cfLine: Rgb24 := $A78BFA; cfText: Rgb24 := $F5F3FF;
         cfBack: Rgb24 := $2D1854; cfElement: Rgb24 := $D946EF;
         cfLcdBack: Rgb24 := $120A24;
       end;
    4: case AField of
         cfLine: Rgb24 := $22D3EE; cfText: Rgb24 := $E0F2FE;
         cfBack: Rgb24 := $0B3C4C; cfElement: Rgb24 := $14B8A6;
         cfLcdBack: Rgb24 := $031A26;
       end;
  else
    Exit;
  end;
  Result := ColorToRgb565Text(RGB((Rgb24 shr 16) and $FF,
    (Rgb24 shr 8) and $FF, Rgb24 and $FF));
end;

//======================================================
// Обновляет таблицу, свойства и VLCD после замены цветов компонента.
procedure TForm1.RefreshSelectedColorRow;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  UpdateDefaultColorsFromRow(FSelectedRow);
  LoadInputsFromRow(FSelectedRow);
  Edit1.Text := ScriptFromRow(FSelectedRow);
  StringGrid1.Invalidate;
  RepaintPreview;
  SaveSettings;
end;

//======================================================
// Назначает выбранному компоненту стандартные цвета текущей темы.
procedure TForm1.ThemeColorsMenuClick(Sender: TObject);
var
  Field: TColorField;
  Dummy: string;
begin
  for Field := Low(TColorField) to High(TColorField) do
    if RowColorValue(FSelectedRow, Field, Dummy) then
      SetRowColorValue(FSelectedRow, Field, ThemeDefaultColor(Field));
  RefreshSelectedColorRow;
  SetStatus('Theme colors applied');
end;

//======================================================
// Копирует смысловые цвета выбранного компонента во внутренний буфер.
procedure TForm1.CopyColorsMenuClick(Sender: TObject);
var
  Field: TColorField;
begin
  FColorClipboardValid := False;
  FColorClipboardHasFont := RowSupportsFont(FSelectedRow);
  if FColorClipboardHasFont then
  begin
    FColorClipboardFont := Trim(StringGrid1.Cells[COL_FONT, FSelectedRow]);
    FColorClipboardHasFont := FColorClipboardFont <> '';
  end;
  for Field := Low(TColorField) to High(TColorField) do
  begin
    FColorClipboardHas[Field] := RowColorValue(FSelectedRow, Field,
      FColorClipboardValues[Field]);
    if FColorClipboardHas[Field] then
      FColorClipboardValid := True;
  end;
  FColorClipboardValid := FColorClipboardValid or FColorClipboardHasFont;
  if FColorClipboardValid then
    SetStatus('Component colors copied');
end;

//======================================================
// Вставляет совместимые цвета из внутреннего буфера в выбранный компонент.
procedure TForm1.PasteColorsMenuClick(Sender: TObject);
var
  Field: TColorField;
  Dummy: string;
begin
  if not FColorClipboardValid then
    Exit;
  for Field := Low(TColorField) to High(TColorField) do
    if FColorClipboardHas[Field] and
      RowColorValue(FSelectedRow, Field, Dummy) then
      SetRowColorValue(FSelectedRow, Field, FColorClipboardValues[Field]);
  if FColorClipboardHasFont and RowSupportsFont(FSelectedRow) then
    StringGrid1.Cells[COL_FONT, FSelectedRow] := FColorClipboardFont;
  RefreshSelectedColorRow;
  SetStatus('Component colors pasted');
end;

//======================================================
// Проверяет, использует ли компонент выбираемый шрифт ESP.
function TForm1.RowSupportsFont(ARow: Integer): Boolean;
var
  Cmd: string;
begin
  Result := False;
  if (ARow < 1) or (ARow >= StringGrid1.RowCount) then
    Exit;
  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, ARow]));
  Result := (Cmd = 'BT') or (Cmd = 'TX');
end;

//======================================================
// Запрашивает у ESP снимок текущей сцены командой SS.
function TForm1.RequestDisplaySnapshot(ADest: TStrings): Boolean;
var
  Reply: string;
  Line: string;
  RawLines: TStringList;
  ExpectedCount: Integer;
  I: Integer;
  BeginIndex: Integer;
  EndIndex: Integer;
  MonitorWasEnabled: Boolean;
begin
  Result := False;
  ADest.Clear;
  ExpectedCount := -1;

  if UdpEnabled then
  begin
    if not UdpExchangeLine('SS', Trim(Edit2.Text), False, Reply) then
      Exit;
    RawLines := TStringList.Create;
    try
      RawLines.Text := Reply;
      BeginIndex := -1;
      EndIndex := -1;
      for I := 0 to RawLines.Count - 1 do
      begin
        Line := Trim(RawLines[I]);
        if Pos('OK|SS|BEGIN|', Line) = 1 then
        begin
          BeginIndex := I;
          ExpectedCount := StrToIntDef(Copy(Line,
            Length('OK|SS|BEGIN|') + 1, MaxInt), -1);
        end
        else if Line = 'OK|SS|END' then
          EndIndex := I;
      end;
      if (BeginIndex < 0) or (EndIndex <= BeginIndex) or (ExpectedCount < 0) then
      begin
        SetStatus('Bad display snapshot reply');
        Exit;
      end;
      for I := BeginIndex + 1 to EndIndex - 1 do
        if ADest.Count < ExpectedCount then
          ADest.Add(Trim(RawLines[I]));
    finally
      RawLines.Free;
    end;
  end
  else
  begin
    if FPort = INVALID_HANDLE_VALUE then
    begin
      SetStatus('Open COM or enable UDP first');
      Exit;
    end;
    MonitorWasEnabled := Assigned(FPortMonitor) and FPortMonitor.Enabled;
    if Assigned(FPortMonitor) then
      FPortMonitor.Enabled := False;
    try
      SendSerialLine('SS');
      if not WaitSerialReply('OK|SS|BEGIN|', 5000, Line) then
        Exit;
      ExpectedCount := StrToIntDef(Copy(Line,
        Length('OK|SS|BEGIN|') + 1, MaxInt), -1);
      if ExpectedCount < 0 then
      begin
        SetStatus('Bad display snapshot header');
        Exit;
      end;
      for I := 0 to ExpectedCount - 1 do
      begin
        if not WaitSerialReply('', 5000, Line) then
          Exit;
        ADest.Add(Line);
      end;
      if not WaitSerialReply('OK|SS|END', 5000, Line) then
        Exit;
    finally
      if Assigned(FPortMonitor) then
        FPortMonitor.Enabled := MonitorWasEnabled;
    end;
  end;

  if ADest.Count <> ExpectedCount then
  begin
    SetStatus('Incomplete display snapshot: ' + IntToStr(ADest.Count) + '/' +
      IntToStr(ExpectedCount));
    Exit;
  end;
  Result := True;
end;

//======================================================
// Загружает текущую сцену ESP обратно в редактор.
procedure TForm1.LoadFromDisplayMenuClick(Sender: TObject);
var
  SceneLines: TStringList;
begin
  SceneLines := TStringList.Create;
  try
    if RequestDisplaySnapshot(SceneLines) then
    begin
      LoadDesignFromStrings(SceneLines, 'display');
      SetStatus('Loaded from display: ' + IntToStr(SceneLines.Count) + ' lines');
    end;
  finally
    SceneLines.Free;
  end;
end;

//======================================================
// Отправляет весь макет редактора на ESP.
procedure TForm1.UploadToDisplayMenuClick(Sender: TObject);
begin
  UploadButtonClick(Sender);
end;

//======================================================
procedure TForm1.CreateScriptMenuClick(Sender: TObject);
begin
  SendScriptToSdClick(Sender);
end;

//======================================================
// Очищает физический дисплей текущим цветом фона.
procedure TForm1.ClearDisplayMenuClick(Sender: TObject);
begin
  Button8MouseDown(FPreview, mbLeft, [], 0, 0);
end;

//======================================================
// Применяет выбранную тему ко всем цветным компонентам макета.
procedure TForm1.ApplyThemeAllMenuClick(Sender: TObject);
var
  R: Integer;
  Field: TColorField;
  Dummy: string;
  HasColors: Boolean;
  ChangedCount: Integer;
begin
  if ComboBox5.ItemIndex < 0 then
  begin
    SetStatus('Select color theme first');
    Exit;
  end;

  ApplyColorTheme(ComboBox5.ItemIndex);
  ChangedCount := 0;
  for R := 1 to StringGrid1.RowCount - 1 do
  begin
    HasColors := False;
    for Field := Low(TColorField) to High(TColorField) do
      if RowColorValue(R, Field, Dummy) then
      begin
        SetRowColorValue(R, Field, ThemeDefaultColor(Field));
        HasColors := True;
      end;
    if HasColors and not IsScreenFillRow(R) then
      Inc(ChangedCount);
  end;

  RefreshSelectedColorRow;
  if Assigned(StringGrid2) then
    StringGrid2.Invalidate;
  SaveSettings;
  SetStatus('Theme applied to all: ' + IntToStr(ChangedCount) + ' components');
end;

//======================================================
// Применяет готовую цветовую тему к палитре и цветам новых компонентов.
procedure TForm1.ApplyColorTheme(AThemeIndex: Integer);
var
  I: Integer;
  Rgb24: LongWord;

  function ThemeColor(AIndex: Integer): LongWord;
  begin
    case AThemeIndex of
      0: Result := NEON_THEME_COLORS[AIndex];
      1: Result := DARK_THEME_COLORS[AIndex];
      2: Result := LIGHT_THEME_COLORS[AIndex];
      3: Result := PURPLE_THEME_COLORS[AIndex];
      4: Result := OCEAN_THEME_COLORS[AIndex];
    else
      Result := DARK_THEME_COLORS[AIndex];
    end;
  end;

  function ToColor(AValue: LongWord): TColor;
  begin
    Result := RGB((AValue shr 16) and $FF, (AValue shr 8) and $FF,
      AValue and $FF);
  end;

  procedure SetDefaults(AStroke, AText, AFill, AElement, AScreen: LongWord);
  begin
    FDefaultLineRgb := ColorToRgb565Text(ToColor(AStroke));
    FDefaultFgRgb := ColorToRgb565Text(ToColor(AText));
    FDefaultBgRgb := ColorToRgb565Text(ToColor(AFill));
    FDefaultElementRgb := ColorToRgb565Text(ToColor(AElement));
    FDefaultLcdBgRgb := ColorToRgb565Text(ToColor(AScreen));
    FLcdBgColor := ToColor(AScreen);
  end;

begin
  if (AThemeIndex < 0) or (AThemeIndex > 4) then
    Exit;

  for I := 0 to PALETTE_COLOR_COUNT - 1 do
  begin
    Rgb24 := ThemeColor(I);
    PaletteColors[I] := ToColor(Rgb24);
  end;

  case AThemeIndex of
    0: SetDefaults($00F5FF, $F8FAFC, $111827, $39FF14, $05070D);
    1: SetDefaults($64748B, $F3F4F6, $1F2937, $3B82F6, $0B0F14);
    2: SetDefaults($334155, $0F172A, $F1F5F9, $2563EB, $FFFFFF);
    3: SetDefaults($A78BFA, $F5F3FF, $2D1854, $D946EF, $120A24);
    4: SetDefaults($22D3EE, $E0F2FE, $0B3C4C, $14B8A6, $031A26);
  end;

  Shape1.Brush.Color := FLcdBgColor;
  Shape1.Pen.Color := FLcdBgColor;
  EnsureScreenFillRow;
  RefreshColorFieldShapes;
  if Assigned(StringGrid2) then
    StringGrid2.Invalidate;
  RepaintPreview;
end;

//======================================================
// Обрабатывает выбор цветовой темы в выпадающем списке.
procedure TForm1.ColorThemeChange(Sender: TObject);
begin
  if FLoadingTheme or (ComboBox5.ItemIndex < 0) then
    Exit;
  ApplyColorTheme(ComboBox5.ItemIndex);
  SaveSettings;
  SetStatus('Color theme: ' + ComboBox5.Text);
end;

//======================================================
// Загружает сохранённые настройки редактора из ini-файла.
procedure TForm1.LoadSettings;
var
  Ini: TIniFile;
  PortName: string;
  LcdBgRgb: string;
  ThemeName: string;
  ThemeIndex: Integer;
  I: Integer;
  Key: string;
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
    if Assigned(CheckBox6) then
      CheckBox6.Checked := Ini.ReadBool('Upload', 'RewriteFont', CheckBox6.Checked);
    Edit2.Text := Ini.ReadString('Connection', 'UdpIp', Edit2.Text);
    Edit3.Text := Ini.ReadString('Connection', 'UdpPort', Edit3.Text);
    for I := 0 to PALETTE_COLOR_COUNT - 1 do
    begin
      Key := 'Cell' + Format('%.2d', [I]);
      PaletteColors[I] := Rgb565ToColor(Ini.ReadString('Palette', Key,
        ColorToRgb565Text(PaletteColors[I])), PaletteColors[I]);
    end;
    FDefaultLineRgb := Ini.ReadString('Colors', 'Stroke',
      Ini.ReadString('Colors', 'Line', FDefaultLineRgb));
    FDefaultFgRgb := Ini.ReadString('Colors', 'Text',
      Ini.ReadString('Colors', 'Foreground', FDefaultFgRgb));
    FDefaultBgRgb := Ini.ReadString('Colors', 'Fill',
      Ini.ReadString('Colors', 'Back',
      Ini.ReadString('Colors', 'Background', FDefaultBgRgb)));
    FDefaultElementRgb := Ini.ReadString('Colors', 'Element', FDefaultElementRgb);
    ThemeName := Ini.ReadString('Colors', 'Theme', ComboBox5.Text);
    ThemeIndex := ComboBox5.Items.IndexOf(ThemeName);
    FLoadingTheme := True;
    try
      ComboBox5.ItemIndex := ThemeIndex;
    finally
      FLoadingTheme := False;
    end;
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
  I: Integer;
begin
  Ini := TIniFile.Create(ConfigFilePath);
  try
    Ini.WriteString('Connection', 'ComPort', ComboBox1.Text);
    Ini.WriteBool('Connection', 'Rts', CheckBox1.Checked);
    Ini.WriteBool('Connection', 'ComEnabled', CheckBox2.Checked);
    Ini.WriteBool('Connection', 'UdpEnabled', CheckBox3.Checked);
    Ini.WriteBool('Upload', 'RewriteImage', CheckBox4.Checked);
    if Assigned(CheckBox6) then
      Ini.WriteBool('Upload', 'RewriteFont', CheckBox6.Checked);
    Ini.WriteString('Connection', 'UdpIp', Edit2.Text);
    Ini.WriteString('Connection', 'UdpPort', Edit3.Text);
    Ini.WriteString('Colors', 'Stroke', FDefaultLineRgb);
    Ini.WriteString('Colors', 'Text', FDefaultFgRgb);
    Ini.WriteString('Colors', 'Fill', FDefaultBgRgb);
    Ini.WriteString('Colors', 'Screen', FDefaultLcdBgRgb);
    Ini.WriteString('Colors', 'Element', FDefaultElementRgb);
    if ComboBox5.ItemIndex >= 0 then
      Ini.WriteString('Colors', 'Theme', ComboBox5.Items[ComboBox5.ItemIndex]);
    for I := 0 to PALETTE_COLOR_COUNT - 1 do
      Ini.WriteString('Palette', 'Cell' + Format('%.2d', [I]),
        ColorToRgb565Text(PaletteColors[I]));
    Ini.WriteString('WiFi', 'SSID', Ini.ReadString('WiFi', 'SSID', ''));
    Ini.WriteString('WiFi', 'Password', Ini.ReadString('WiFi', 'Password', ''));
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
      SetStatus('UDP socket error');
      ShowErrorPopup('UDP socket error');
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
    FUdpLastProbeTick := 0;
    FUdpLastOkTick := 0;
    FUdpBusy := False;
  end;
end;

//======================================================
// Выполняет один командный обмен с ESP по активному каналу.
function TForm1.ExchangeEspLine(const ALine, AOkPrefix: string; ATimeoutMs: DWORD; var AReply: string): Boolean;
begin
  AReply := '';
  if UdpEnabled then
  begin
    Result := UdpExchangeLine(ALine, Trim(Edit2.Text), False, AReply,
      AOkPrefix, ATimeoutMs);
    if Result and (AOkPrefix <> '') and (Pos(AOkPrefix, AReply) <> 1) then
      Result := False;
    Exit;
  end;

  if FPort = INVALID_HANDLE_VALUE then
  begin
    Result := False;
    Exit;
  end;
  SendSerialLine(ALine);
  Result := WaitSerialReply(AOkPrefix, ATimeoutMs, AReply);
  if Result and (AOkPrefix <> '') and (Pos(AOkPrefix, AReply) <> 1) then
    Result := False;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
function TForm1.EspExchange(const ALine, AOkPrefix: string; ATimeoutMs: DWORD;
  var AReply: string): Boolean;
begin
  Result := ExchangeEspLine(ALine, AOkPrefix, ATimeoutMs, AReply);
end;

//======================================================
// Показывает текущее состояние операции пользователю.
procedure TForm1.EditorStatus(const AText: string);
begin
  SetStatus(AText);
end;

//======================================================
procedure TForm1.EditorProgress(AValue: Integer);
begin
  SetSdProgress(AValue);
end;

//======================================================
// Возвращает корень локального зеркала SD для вспомогательных форм.
function TForm1.EditorSdRootPath: string;
begin
  Result := SdRootPath;
end;

//======================================================
// Сохраняет текущую таблицу команд в переданный список строк.
procedure TForm1.SaveDesignToStrings(ADest: TStrings);
var
  R: Integer;
  Line: string;
begin
  ADest.Clear;
  EnsureScreenFillRow;
  for R := 1 to StringGrid1.RowCount - 1 do
  begin
    Line := Trim(ScriptFromRow(R));
    if Line <> '' then
      ADest.Add(Line)
    else if IsScreenFillRow(R) then
      ADest.Add('');
  end;
end;

//======================================================
// Загружает строки скрипта в таблицу редактора.
procedure TForm1.LoadDesignFromStrings(ASource: TStrings; const AName: string);
var
  I: Integer;
begin
  FDefaultLcdBgRgb := '0x0001';
  FLcdBgColor := clBlack;
  StringGrid1.RowCount := 2;
  StringGrid1.Rows[1].Clear;
  FSelectedRow := 1;
  EnsureScreenFillRow;
  for I := 0 to ASource.Count - 1 do
    AddScriptLine(ASource[I]);
  EnsureScreenFillRow;
  SelectRow(1);
  SetStatus('Loaded ' + AName + ': ' + IntToStr(ASource.Count) + ' lines');
end;

//======================================================
// Обновляет ComboBox4 списком скриптов из /scripts на SD ESP.
procedure TForm1.RefreshSdScriptList;
var
  Reply: string;
  Parts: TStringList;
  I: Integer;
  OldName: string;
begin
  if FRefreshingSdScripts then
    Exit;
  if (not UdpEnabled) and (FPort = INVALID_HANDLE_VALUE) then
    Exit;

  FSdScriptsLastTick := GetTickCount;
  FRefreshingSdScripts := True;
  try
    if not ExchangeEspLine('SL|/scripts', 'OK|SL', 5000, Reply) then
    begin
      SetStatus('SD scripts refresh failed: ' + Reply);
      Exit;
    end;
    OldName := ComboBox4.Text;
    Parts := TStringList.Create;
    try
      SplitPipe(Reply, Parts);
      ComboBox4.Items.BeginUpdate;
      try
        ComboBox4.Items.Clear;
        for I := 2 to Parts.Count - 1 do
          if Trim(Parts[I]) <> '' then
            ComboBox4.Items.Add(Trim(Parts[I]));
      finally
        ComboBox4.Items.EndUpdate;
      end;
      if ComboBox4.Items.IndexOf(OldName) >= 0 then
        ComboBox4.ItemIndex := ComboBox4.Items.IndexOf(OldName)
      else if ComboBox4.Items.Count > 0 then
        ComboBox4.ItemIndex := 0
      else
        ComboBox4.Text := '';
    finally
      Parts.Free;
    end;
  finally
    FRefreshingSdScripts := False;
  end;
end;

//======================================================
// Подбирает следующее имя scriptN.nxt по списку из ComboBox4.
//======================================================
// Обновляет список скриптов с SD по кнопке Refresh.
procedure TForm1.RefreshSdScriptsClick(Sender: TObject);
begin
  FSdScriptsLastTick := GetTickCount;
  RefreshSdScriptList;
  if ComboBox4.Items.Count > 0 then
    SetStatus('SD scripts refreshed: ' + IntToStr(ComboBox4.Items.Count))
  else
    SetStatus('SD scripts list is empty');
end;

//======================================================
// Формирует, сохраняет или загружает строки NXT-скрипта.
function TForm1.NextSdScriptFileName: string;
var
  I: Integer;
  N: Integer;
  Candidate: string;
  Used: Boolean;
begin
  RefreshSdScriptList;
  N := 1;
  repeat
    Candidate := 'script' + IntToStr(N) + '.nxt';
    Used := False;
    for I := 0 to ComboBox4.Items.Count - 1 do
      if CompareText(ExtractFileName(Trim(ComboBox4.Items[I])), Candidate) = 0 then
      begin
        Used := True;
        Break;
      end;
    if not Used then
    begin
      Result := Candidate;
      Exit;
    end;
    Inc(N);
  until False;
end;

//======================================================
// Отправляет текущий дизайн на SD ESP в /scripts/scriptN.nxt.
procedure TForm1.SendScriptToSdClick(Sender: TObject);
var
  SL: TStringList;
  TempName: string;
  SdPath: string;
  FileName: string;
begin
  FileName := NextSdScriptFileName;
  if FileName = '' then
    Exit;
  SL := TStringList.Create;
  try
    SaveDesignToStrings(SL);
    TempName := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'nxt_sd_script.tmp';
    SL.SaveToFile(TempName);
    SdPath := '/scripts/' + FileName;
    if SendFileToEspSd(TempName, SdPath, nil, True) then
    begin
      RefreshSdScriptList;
      if ComboBox4.Items.IndexOf(FileName) >= 0 then
        ComboBox4.ItemIndex := ComboBox4.Items.IndexOf(FileName);
      SetStatus('Script saved: ' + FileName);
//      SimpleText := 'Script saved to SD: ' + SdPath;      Form4.Memo1.Lines.Add(SimpleText);

    end;
    DeleteFile(TempName);
  finally
    SL.Free;
  end;
end;

//======================================================
// Загружает выбранный в ComboBox4 скрипт с SD ESP в редактор.
procedure TForm1.LoadScriptFromSdClick(Sender: TObject);
var
  ScriptName: string;
  SdPath: string;
  Reply: string;
  Parts: TStringList;
  HexText: string;
  Offset: Integer;
  TotalSize: Integer;
  I: Integer;
  B: Byte;
  Stream: TMemoryStream;
  SL: TStringList;
begin
  if FRefreshingSdScripts then
    Exit;
  ScriptName := Trim(ComboBox4.Text);
  if ScriptName = '' then
  begin
    SetStatus('Select SD script first');
    Exit;
  end;
  if Pos('/', ScriptName) = 1 then
    SdPath := ScriptName
  else
    SdPath := '/scripts/' + ScriptName;

  SetSdProgress(0);
  Offset := 0;
  TotalSize := -1;
  Stream := TMemoryStream.Create;
  Parts := TStringList.Create;
  try
    repeat
      if not ExchangeEspLine('FR|' + SdPath + '|' + IntToStr(Offset) + '|64', 'OK|FR|', 2000, Reply) then
      begin
        SetStatus('SD script read failed: ' + Reply);
        Exit;
      end;
      Parts.Clear;
      SplitPipe(Reply, Parts);
      if Parts.Count < 6 then
      begin
        SetStatus('Bad SD script reply: ' + Reply);
        Exit;
      end;
      TotalSize := StrToIntDef(Parts[4], TotalSize);
      HexText := Trim(Parts[5]);
      I := 1;
      while I < Length(HexText) do
      begin
        B := HexPairByte(HexText, I);
        Stream.WriteBuffer(B, 1);
        Inc(I, 2);
      end;
      Inc(Offset, Length(HexText) div 2);
      if TotalSize > 0 then
        SetSdProgress(Offset * 100 div TotalSize);
    until (TotalSize >= 0) and (Offset >= TotalSize);
    SetSdProgress(100);

    Stream.Position := 0;
    SL := TStringList.Create;
    try
      SL.LoadFromStream(Stream);
      LoadDesignFromStrings(SL, ScriptName);
      SetStatus('Loaded from SD to VLCD: ' + SdPath);
    finally
      SL.Free;
    end;
  finally
    Parts.Free;
    Stream.Free;
  end;
end;
//======================================================
// Сохраняет текущую таблицу команд в текстовый файл скрипта.
procedure TForm1.SaveDesignToFile(const AFileName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SaveDesignToStrings(SL);
    SL.SaveToFile(ScriptFilePath(AFileName));
    SetStatus('Saved ' + AFileName + ': ' + IntToStr(SL.Count) + ' lines');
  finally
    SL.Free;
  end;
end;

//======================================================
// Загружает скрипт из файла в таблицу команд.
procedure TForm1.LoadDesignFromFile(const AFileName: string);
var
  SL: TStringList;
begin
  if not FileExists(ScriptFilePath(AFileName)) then
  begin
    SetStatus('File not found: ' + AFileName);
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(ScriptFilePath(AFileName));
    LoadDesignFromStrings(SL, AFileName);
  finally
    SL.Free;
  end;
end;

//======================================================
// Отправляет одну команду по UDP и ожидает ответ ESP.
function TForm1.UdpExchangeLine(const ALine, AHost: string; ABroadcast: Boolean;
  var AReply: string; const AExpectedPrefix: string; ATimeoutMs: DWORD;
  AShowTimeoutError: Boolean): Boolean;
var
  Addr: TSockAddrIn;
  FromAddr: TSockAddrIn;
  FromLen: Integer;
  HostText: AnsiString;
  Data: AnsiString;
  Buffer: array[0..8191] of AnsiChar;
  Port: Integer;
  ReadCount: Integer;
  StartedAt: DWORD;
  ReceivedLine: string;
begin
  Result := False;
  AReply := '';
  if ATimeoutMs < 250 then
    ATimeoutMs := 250;

  HostText := AnsiString(Trim(AHost));
  Port := StrToIntDef(Trim(Edit3.Text), 4210);
  if (HostText = '') or (Port <= 0) or (Port > 65535) then
  begin
    SetUdpStateColor(clGray);
    SetStatus('UDP address error');
    Exit;
  end;

  if not EnsureUdpSocket(ABroadcast) then
    Exit;

  // Discard replies left by earlier probes. Otherwise an old IP/SS/SL packet
  // can be mistaken for the answer to the file command sent below.
  repeat
    FromLen := SizeOf(FromAddr);
    ReadCount := recvfrom(FUdpSocket, Buffer, SizeOf(Buffer) - 1, 0,
      FromAddr, FromLen);
  until ReadCount <= 0;

  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);
  Addr.sin_addr.S_addr := inet_addr(PAnsiChar(HostText));
  if Addr.sin_addr.S_addr = INADDR_NONE then
  begin
    SetUdpStateColor(clGray);
    SetStatus('UDP IP error: ' + string(HostText));
    Exit;
  end;

  FUdpBusy := True;
  try
    Data := AnsiString(ALine);
    if sendto(FUdpSocket, PAnsiChar(Data)^, Length(Data), 0, Addr, SizeOf(Addr)) <> Length(Data) then
    begin
      CloseUdpSocket;
      SetUdpStateColor(clGray);
      SetStatus('UDP send error');
      if AShowTimeoutError then
      begin
        FUdpLossShown := True;
        ShowErrorPopup('UDP connection lost: send error');
      end;
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
        MarkUdpAlive;
        if Pos('ERR|', UpperCase(ReceivedLine)) = 1 then
        begin
          AReply := ReceivedLine;
          HandleRxLine(ReceivedLine);
          Break;
        end;
        if Pos('EV|', UpperCase(ReceivedLine)) = 1 then
        begin
          SetUdpStateColor(clLime);
          HandleRxLine(ReceivedLine);
          Continue;
        end;
        if (AExpectedPrefix <> '') and
          (((Pos('OK|FDO|', UpperCase(AExpectedPrefix)) = 1) and
            (CompareText(AExpectedPrefix, ReceivedLine) <> 0)) or
           ((Pos('OK|FDO|', UpperCase(AExpectedPrefix)) <> 1) and
            (Pos(AExpectedPrefix, ReceivedLine) <> 1))) then
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
    until GetTickCount - StartedAt > ATimeoutMs;

    if Result then
      SetUdpStateColor(clLime)
    else if Pos('ERR|', UpperCase(AReply)) = 1 then
      SetUdpStateColor(clLime)
    else
    begin
      SetUdpStateColor(clGray);
      AReply := 'timeout';
      SetStatus('UDP no reply: ' + string(HostText));
      if AShowTimeoutError then
      begin
        FUdpLossShown := True;
        ShowErrorPopup('UDP connection lost: ' + string(HostText) + ':' +
          IntToStr(Port));
      end;
    end;
  finally
    FUdpBusy := False;
  end;
end;

//======================================================
// Считывает асинхронные UDP-события от ESP.
procedure TForm1.PollUdpInput;
var
  FromAddr: TSockAddrIn;
  FromLen: Integer;
  Buffer: array[0..8191] of AnsiChar;
  ReadCount: Integer;
  Line: string;
begin
  if FUdpBusy or (not UdpEnabled) or (FUdpSocket = INVALID_SOCKET) then
    Exit;

  repeat
    FromLen := SizeOf(FromAddr);
    ReadCount := recvfrom(FUdpSocket, Buffer, SizeOf(Buffer) - 1, 0, FromAddr, FromLen);
      if ReadCount > 0 then
      begin
        Buffer[ReadCount] := #0;
        Line := Trim(string(Buffer));
        if Line <> '' then
        begin
          MarkUdpAlive;
          SetUdpStateColor(clLime);
          HandleRxLine(Line);
        end;
      end;
  until ReadCount <= 0;
end;

//======================================================
// Тихо проверяет доступность ESP по UDP и обновляет индикатор Shape5.
procedure TForm1.ProbeUdpStatus;
var
  Addr: TSockAddrIn;
  HostText: AnsiString;
  Data: AnsiString;
  Port: Integer;
  NowTick: DWORD;
begin
  if not UdpEnabled then
    Exit;
  NowTick := GetTickCount;
  if FUdpBusy or (NowTick - FUdpLastProbeTick < 3000) then
    Exit;
  FUdpLastProbeTick := NowTick;

  HostText := AnsiString(Trim(Edit2.Text));
  Port := StrToIntDef(Trim(Edit3.Text), 4210);
  if (HostText = '') or (Port <= 0) or (Port > 65535) then
  begin
    SetUdpStateColor(clGray);
    Exit;
  end;
  if not EnsureUdpSocket(False) then
  begin
    SetUdpStateColor(clGray);
    Exit;
  end;

  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);
  Addr.sin_addr.S_addr := inet_addr(PAnsiChar(HostText));
  if Addr.sin_addr.S_addr = INADDR_NONE then
  begin
    SetUdpStateColor(clGray);
    Exit;
  end;

  FUdpBusy := True;
  try
    Data := AnsiString('SHOWIP');
    if sendto(FUdpSocket, PAnsiChar(Data)^, Length(Data), 0, Addr, SizeOf(Addr)) <> Length(Data) then
    begin
      CloseUdpSocket;
      SetUdpStateColor(clGray);
      FUdpLossShown := True;
      ShowErrorPopup('UDP connection lost: send error');
      Exit;
    end;
    if (FUdpLastOkTick = 0) or (GetTickCount - FUdpLastOkTick > 6000) then
    begin
      SetUdpStateColor(clGray);
      if not FUdpLossShown then
      begin
        FUdpLossShown := True;
        ShowErrorPopup('UDP connection lost: ' + string(HostText) + ':' +
          IntToStr(Port));
      end;
    end
    else
      SetUdpStateColor(clLime);
  finally
    FUdpBusy := False;
  end;
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
    SetStatus('UDP RX: ' + Trim(Reply));
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
    SetStatus('Port is closed: ' + ComboBox1.Text);
    Exit;
  end;
  if not PortAlive then
  begin
    SetStatus('Port lost before write: ' + ComboBox1.Text);
    ClosePort(True);
    Exit;
  end;
  Data := AnsiString(ALine + #13#10);
  if (not WriteFile(FPort, PAnsiChar(Data)^, Length(Data), Written, nil)) or
    (Written <> DWORD(Length(Data))) then
  begin
    SetStatus('Port write error: ' + ComboBox1.Text);
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
      SetStatus('Port is closed: ' + ComboBox1.Text);
  end;

  if UdpEnabled then
    Sent := SendUdpLine(ALine) or Sent;

  if not Sent then
    SetStatus('No active output channel');
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
      SetStatus('Port read error: ' + ComboBox1.Text);
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
      // SD directory listings can be several kilobytes long and arrive in
      // multiple serial chunks. Keep an incomplete line until its LF arrives.
      if Length(FPortRxText) > 65535 then
      begin
        SetStatus('RX line too long');
        FPortRxText := '';
      end;
    end;
  until ReadCount = 0;
end;

//======================================================
// Показывает важную ошибку один раз, не создавая каскад одинаковых окон.
procedure TForm1.ShowErrorPopup(const AText: string);
var
  Text: string;
  NowTick: DWORD;
begin
  Text := Trim(AText);
  if Text = '' then
    Exit;
  NowTick := GetTickCount;
  if (Text = FLastPopupText) and (NowTick - FLastPopupTick < 2000) then
    Exit;
  FLastPopupText := Text;
  FLastPopupTick := NowTick;
  ShowMessage(Text);
end;

//======================================================
// Отмечает любой принятый UDP-пакет как подтверждение живого соединения.
procedure TForm1.MarkUdpAlive;
begin
  FUdpLastOkTick := GetTickCount;
  FUdpLossShown := False;
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
  SetStatus('RX: ' + ALine);
  // FS is an existence check before Upload. A missing file means that it must
  // be uploaded and is not an error during normal operation.
  if Pos('ERR|FS|NOT_FOUND|', UpperCase(Trim(ALine))) = 1 then
    Exit;
  if Pos('ERR|', UpperCase(Trim(ALine))) = 1 then
  begin
    ShowErrorPopup(Trim(ALine));
    Exit;
  end;
  Parts := TStringList.Create;
  try
    SplitPipe(Trim(ALine), Parts);
    if (Parts.Count >= 2) and (UpperCase(Parts[0]) = 'IP') then
    begin
      Edit2.Text := Parts[1];
      CheckBox3.Checked := True;
      SetUdpStateColor(clLime);
      SaveSettings;
      SetStatus('ESP IP: ' + Edit2.Text);
    end;
    if (Parts.Count >= 4) and (UpperCase(Parts[0]) = 'EV') then
    begin
      Kind := UpperCase(Parts[1]);
      IdText := Parts[2];
      EventName := UpperCase(Parts[3]);
      if ((Kind = 'TR') or (Kind = 'VT') or (Kind = 'SW')) and
        (Parts.Count >= 7) then
      begin
        ValueText := Parts[4];
        SetStatus('Touch ' + Kind + ' #' + IdText + ' ' +
          EventName + ' = ' + ValueText);
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
        SetStatus('Touch BT #' + IdText + ' ' + EventName);
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
      SetStatus('RTS set error: ' + ComboBox1.Text);
      ClosePort(True);
      Exit;
    end;
    SetStatus('RTS set: ' + ComboBox1.Text);
  end
  else
  begin
    if not EscapeCommFunction(FPort, CLRRTS) then
    begin
      SetStatus('RTS clear error: ' + ComboBox1.Text);
      ClosePort(True);
      Exit;
    end;
    SetStatus('RTS clear: ' + ComboBox1.Text);
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
    SetStatus('Port open error: ' + ComboBox1.Text);
    Exit;
  end;

  FillChar(Dcb, SizeOf(Dcb), 0);
  Dcb.DCBlength := SizeOf(Dcb);
  if not GetCommState(FPort, Dcb) then
  begin
    SetStatus('Port state error: ' + ComboBox1.Text);
    ClosePort(True);
    Exit;
  end;
  Dcb.BaudRate := 115200;
  Dcb.ByteSize := 8;
  Dcb.Parity := NOPARITY;
  Dcb.StopBits := ONESTOPBIT;
  if not SetCommState(FPort, Dcb) then
  begin
    SetStatus('Port setup error: ' + ComboBox1.Text);
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
  SetStatus('Opened ' + ComboBox1.Text + ', 115200 baud');
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
    SetStatus('Closed ' + ComboBox1.Text);
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
  ThumbColor: TColor;
  Value: Integer;
  LineWidth: Integer;
  Radius: Integer;
  TrackHeight: Integer;
  KnobRadius: Integer;
  KnobX: Integer;
  KnobY: Integer;
  BarRc: TRect;
  ThumbSize: Integer;
  Travel: Integer;
  ThumbPos: Integer;
  InsetX: Integer;
  InsetY: Integer;
  SrcRc: TRect;
  Picture: TPicture;
  ImageFileName: string;

//======================================================
// Выполняет действие формы или редактора.
  procedure DrawClippedGraphic(AGraphic: TGraphic; const ADest, ASource: TRect);
  var
    VisibleRc: TRect;
    SourceRc: TRect;
    BaseSrc: TRect;
    Bitmap: TBitmap;
    DestW: Integer;
    DestH: Integer;

//======================================================
// Возвращает вычисленное значение для работы формы.
    function IMax(A, B: Integer): Integer;
    begin
      if A > B then
        Result := A
      else
        Result := B;
    end;

//======================================================
// Возвращает вычисленное значение для работы формы.
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
    else if (Cmd = 'TR') or (Cmd = 'VT') then
    begin
      Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, R], 50);
      if Value < 0 then
        Value := 0;
      if Value > 100 then
        Value := 100;

      if Cmd = 'VT' then
      begin
        TrackHeight := (DrawRc.Right - DrawRc.Left) div 2;
        if TrackHeight < 2 then
          TrackHeight := 2;
        KnobRadius := (DrawRc.Right - DrawRc.Left) div 2;
        if KnobRadius < 1 then
          KnobRadius := 1;
        KnobX := DrawRc.Left + (DrawRc.Right - DrawRc.Left) div 2;
        KnobY := DrawRc.Bottom - KnobRadius -
          ((DrawRc.Bottom - DrawRc.Top - KnobRadius * 2) * Value div 100);
        BarRc := Rect(KnobX - TrackHeight div 2, DrawRc.Top,
          KnobX - TrackHeight div 2 + TrackHeight, DrawRc.Bottom);
        FPreview.Canvas.Pen.Color := C1;
        FPreview.Canvas.Brush.Color := C1;
        FPreview.Canvas.RoundRect(BarRc.Left, BarRc.Top, BarRc.Right, BarRc.Bottom,
          TrackHeight, TrackHeight);
        FPreview.Canvas.Pen.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.Brush.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.RoundRect(BarRc.Left, KnobY, BarRc.Right, BarRc.Bottom,
          TrackHeight, TrackHeight);
      end
      else
      begin
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
        FPreview.Canvas.Pen.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.Brush.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.RoundRect(BarRc.Left, BarRc.Top, KnobX, BarRc.Bottom,
          TrackHeight, TrackHeight);
      end;
      FPreview.Canvas.Pen.Color := clBlack;
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.Ellipse(KnobX - KnobRadius, KnobY - KnobRadius,
        KnobX + KnobRadius, KnobY + KnobRadius);
    end
    else if Cmd = 'SB' then
    begin
      Value := StrToIntDef(StringGrid1.Cells[COL_TEXT, R], 50);
      if Value < 0 then
        Value := 0;
      if Value > 100 then
        Value := 100;
      InsetX := Round(2 * Sx);
      if InsetX < 1 then
        InsetX := 1;
      InsetY := Round(2 * Sy);
      if InsetY < 1 then
        InsetY := 1;

      FPreview.Canvas.Brush.Color := C1;
      FPreview.Canvas.Pen.Color := clDkGray;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right,
        DrawRc.Bottom, 8, 8);

      if (DrawRc.Bottom - DrawRc.Top) >= (DrawRc.Right - DrawRc.Left) then
      begin
        ThumbSize := (DrawRc.Bottom - DrawRc.Top) div 5;
        if ThumbSize < Round(18 * Sy) then
          ThumbSize := Round(18 * Sy);
        Travel := DrawRc.Bottom - DrawRc.Top - ThumbSize - InsetY * 2;
        if Travel < 1 then
          Travel := 1;
        ThumbPos := DrawRc.Top + InsetY + Travel * Value div 100;

        if ThumbPos > DrawRc.Top + InsetY then
        begin
          FPreview.Canvas.Brush.Color := Rgb565ToColor(
            StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
          FPreview.Canvas.Pen.Color := FPreview.Canvas.Brush.Color;
          FPreview.Canvas.RoundRect(DrawRc.Left + InsetX,
            DrawRc.Top + InsetY, DrawRc.Right - InsetX, ThumbPos, 8, 8);
        end;
        FPreview.Canvas.Brush.Color := C2;
        FPreview.Canvas.Pen.Color := C2;
        FPreview.Canvas.RoundRect(DrawRc.Left + InsetX, ThumbPos,
          DrawRc.Right - InsetX, ThumbPos + ThumbSize, 8, 8);
      end
      else
      begin
        ThumbSize := (DrawRc.Right - DrawRc.Left) div 5;
        if ThumbSize < Round(18 * Sx) then
          ThumbSize := Round(18 * Sx);
        Travel := DrawRc.Right - DrawRc.Left - ThumbSize - InsetX * 2;
        if Travel < 1 then
          Travel := 1;
        ThumbPos := DrawRc.Left + InsetX + Travel * Value div 100;

        if ThumbPos > DrawRc.Left + InsetX then
        begin
          FPreview.Canvas.Brush.Color := Rgb565ToColor(
            StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
          FPreview.Canvas.Pen.Color := FPreview.Canvas.Brush.Color;
          FPreview.Canvas.RoundRect(DrawRc.Left + InsetX,
            DrawRc.Top + InsetY, ThumbPos, DrawRc.Bottom - InsetY, 8, 8);
        end;
        FPreview.Canvas.Brush.Color := C2;
        FPreview.Canvas.Pen.Color := C2;
        FPreview.Canvas.RoundRect(ThumbPos, DrawRc.Top + InsetY,
          ThumbPos + ThumbSize, DrawRc.Bottom - InsetY, 8, 8);
      end;
    end
    else if (Cmd = 'PB') or (Cmd = 'VP') then    begin
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
      if Cmd = 'VP' then
        FPreview.Canvas.FillRect(Rect(DrawRc.Left + 2,
          DrawRc.Bottom - 2 - (DrawRc.Bottom - DrawRc.Top - 4) * Value div 100,
          DrawRc.Right - 2, DrawRc.Bottom - 2))
      else
        FPreview.Canvas.FillRect(Rect(DrawRc.Left + 2, DrawRc.Top + 2,
          DrawRc.Left + 2 + (DrawRc.Right - DrawRc.Left - 4) * Value div 100,
          DrawRc.Bottom - 2));
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

      LineWidth := StrToIntDef(StringGrid1.Cells[COL_LINE, R], 1);
      if LineWidth < 1 then
        LineWidth := 1;
      if LineWidth > 4 then
        LineWidth := 4;
      ThumbColor := Rgb565ToColor(StringGrid1.Cells[COL_FONT, R], clWhite);
      FPreview.Canvas.Brush.Color := C2;
      FPreview.Canvas.Pen.Width := TrackHeight;
      FPreview.Canvas.Pen.Color := C2;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom,
        DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      if Value <> 0 then
      begin
        FPreview.Canvas.Brush.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.Pen.Color := Rgb565ToColor(StringGrid1.Cells[COL_EXTRA, R], LightenColor(C2, 45));
        FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top,
          KnobX + KnobRadius, DrawRc.Bottom,
          DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      end;

      FPreview.Canvas.Pen.Width := LineWidth;
      FPreview.Canvas.Pen.Color := C1;
      FPreview.Canvas.Brush.Style := bsClear;
      FPreview.Canvas.RoundRect(DrawRc.Left, DrawRc.Top, DrawRc.Right, DrawRc.Bottom,
        DrawRc.Bottom - DrawRc.Top, DrawRc.Bottom - DrawRc.Top);
      FPreview.Canvas.Pen.Width := 1;
      FPreview.Canvas.Brush.Style := bsSolid;
      FPreview.Canvas.Brush.Color := ThumbColor;
      FPreview.Canvas.Pen.Color := C1;
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
  Field: TColorField;
  Value: string;
  HasColors: Boolean;
  CanPaste: Boolean;
  PopupPoint: TPoint;
begin
  R := HitRow(X, Y, Resize);
  if R < 0 then
  begin
    if Button = mbRight then
    begin
      PopupPoint := FPreview.ClientToScreen(Point(X, Y));
      FDisplayPopup.Popup(PopupPoint.X, PopupPoint.Y);
    end;
    Exit;
  end;
  SelectRow(R);
  if Button = mbRight then
  begin
    HasColors := False;
    CanPaste := False;
    for Field := Low(TColorField) to High(TColorField) do
    begin
      if RowColorValue(R, Field, Value) then
      begin
        HasColors := True;
        if FColorClipboardValid and FColorClipboardHas[Field] then
          CanPaste := True;
      end;
    end;
    FThemeColorsItem.Enabled := HasColors;
    FCopyColorsItem.Enabled := HasColors;
    FPasteColorsItem.Enabled := HasColors and CanPaste;
    PopupPoint := FPreview.ClientToScreen(Point(X, Y));
    FComponentColorPopup.Popup(PopupPoint.X, PopupPoint.Y);
    Exit;
  end;
  if Button <> mbLeft then
    Exit;
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
  CellText: string;
begin
  if (ARow = 0) or (ACol > COL_ID) then
    Exit;

  if ARow = FSelectedRow then
  begin
    StringGrid1.Canvas.Brush.Color := clHighlight;
    StringGrid1.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    StringGrid1.Canvas.Brush.Color := clWindow;
    StringGrid1.Canvas.Font.Color := clWindowText;
  end;

  StringGrid1.Canvas.FillRect(Rect);
  StringGrid1.Canvas.Pen.Color := clBtnShadow;
  StringGrid1.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
  StringGrid1.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);

  if (ACol = COL_SEL) and (ARow = FSelectedRow) and
    (Trim(StringGrid1.Cells[COL_CMD, ARow]) <> '') then
  begin
    Points[0] := Point(Rect.Left + 3, Rect.Top + 4);
    Points[1] := Point(Rect.Left + 3, Rect.Bottom - 5);
    Points[2] := Point(Rect.Right - 3, Rect.Top + (Rect.Bottom - Rect.Top) div 2);
    StringGrid1.Canvas.Brush.Color := clHighlightText;
    StringGrid1.Canvas.Pen.Color := clHighlightText;
    StringGrid1.Canvas.Polygon(Points);
    Exit;
  end;

  if ACol = COL_CMD then
    CellText := IntToStr(ARow)
  else if ACol = COL_ID then
    CellText := ScriptFromRow(ARow)
  else
    CellText := '';

  if CellText <> '' then
  begin
    TextRect := Rect;
    InflateRect(TextRect, -3, -1);
    DrawText(StringGrid1.Canvas.Handle, PChar(CellText), -1,
      TextRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

//======================================================
// Проверяет введённое значение таблицы и обновляет предпросмотр.
procedure TForm1.GridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
var
  LineWidth: Integer;
  FontId: Integer;
  ScaleNum, ScaleDen: Integer;
  SrcW, SrcH, OutW, OutH: Integer;
  AlignValue: string;
  Cmd: string;
begin
  if ARow > 0 then
  begin
    if IsScreenFillRow(ARow) then
    begin
      EnsureScreenFillRow;
      Edit1.Text := ScriptFromRow(ARow);
      RefreshColorFieldShapes;
      Exit;
    end;
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
      if (FontId > 9) and (FontId < 100) then
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
      (ACol = COL_W) or (ACol = COL_H) or (ACol = COL_SRCX) or
      (ACol = COL_SRCY) or (ACol = COL_SRCW) or (ACol = COL_SRCH)) then
    begin
      if ACol = COL_EXTRA then
        StringGrid1.Cells[COL_EXTRA, ARow] := NormalizeJpgScaleText(Value);
      if (ACol = COL_W) or (ACol = COL_H) then
      begin
        OutW := StrToIntDef(StringGrid1.Cells[COL_W, ARow], 1);
        OutH := StrToIntDef(StringGrid1.Cells[COL_H, ARow], 1);
        if ACol = COL_W then OutW := StrToIntDef(Value, OutW);
        if ACol = COL_H then OutH := StrToIntDef(Value, OutH);
        if OutW < 1 then OutW := 1;
        if OutH < 1 then OutH := 1;
        JpgScaleRatio(StringGrid1.Cells[COL_EXTRA, ARow], ScaleNum, ScaleDen);
        SrcW := (OutW * ScaleDen + ScaleNum - 1) div ScaleNum;
        SrcH := (OutH * ScaleDen + ScaleNum - 1) div ScaleNum;
        StringGrid1.Cells[COL_SRCW, ARow] := IntToStr(SrcW);
        StringGrid1.Cells[COL_SRCH, ARow] := IntToStr(SrcH);
      end;
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
    if CellRgb = UpperCase(Trim(FDefaultElementRgb)) then
    begin
      if LabelText <> '' then
        LabelText := LabelText + '/';
      LabelText := LabelText + 'EL';
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
// Назначает цвет из палитры или меняет цвет ячейки правым кликом.
procedure TForm1.PaletteGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  C: Integer;
  R: Integer;
  Index: Integer;
  RgbText: string;
begin
  StringGrid2.MouseToCell(X, Y, C, R);
  if (C < 0) or (R < 0) then
    Exit;
  Index := R * PALETTE_COLS + C;
  if (Index < 0) or (Index >= PALETTE_COLOR_COUNT) then
    Exit;

  if Button = mbRight then
  begin
    ColorDialog1.Color := PaletteCellColor(Index);
    if ColorDialog1.Execute then
    begin
      PaletteColors[Index] := ColorDialog1.Color;
      StringGrid2.Invalidate;
      SaveSettings;
    end;
    Exit;
  end;

  if Button <> mbLeft then
    Exit;
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
// Applies the selected JPEG decoder/output scale to the current JPG row.
procedure TForm1.JpgScaleComboChange(Sender: TObject);
var
  ScaleText: string;
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  if UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'JPG' then
    Exit;
  ScaleText := NormalizeJpgScaleText(ComboBox6.Text);
  StringGrid1.Cells[COL_EXTRA, FSelectedRow] := ScaleText;
  UpdateImageRowSize(FSelectedRow);
  FLoadingInputs := True;
  try
    SpinEdit3.Value := StrToIntDef(StringGrid1.Cells[COL_W, FSelectedRow], 1);
    SpinEdit4.Value := StrToIntDef(StringGrid1.Cells[COL_H, FSelectedRow], 1);
    Edit1.Text := ScriptFromRow(FSelectedRow);
  finally
    FLoadingInputs := False;
  end;
  StringGrid1.Invalidate;
  RepaintPreview;
end;
//======================================================
// Обновляет строку элемента при изменении числовых полей.
procedure TForm1.InputSpinChange(Sender: TObject);
var
  ParsedValue: Integer;
begin
  if FLoadingInputs then
    Exit;
  if (Sender is TSpinEdit) and
    not TryStrToInt(Trim(TSpinEdit(Sender).Text), ParsedValue) then
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
var
  FontId: Integer;
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;
  if (FFontList.ItemIndex >= 0) and (FFontList.ItemIndex < FFontList.Items.Count) then
  begin
    FontId := Integer(FFontList.Items.Objects[FFontList.ItemIndex]);
    StringGrid1.Cells[COL_FONT, FSelectedRow] := IntToStr(FontId);
  end;
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Позволяет заменить файл GFX-шрифта для предпросмотра.
procedure TForm1.Button9Click(Sender: TObject);
var
  FontId: Integer;
  FontIndex: Integer;
  CurrentFile: string;
  SelectedFile: string;
  SdPath: string;
  LocalFontsDir: string;
  OldFont: TGfxFont;
  NewFont: TGfxFont;
begin
  if not Assigned(FFontList) then
    Exit;
  if (FFontList.ItemIndex < 0) or (FFontList.ItemIndex >= FFontList.Items.Count) then
    Exit;

  FontId := Integer(FFontList.Items.Objects[FFontList.ItemIndex]);
  if FontId < 1 then
    FontId := 1;

  if FontId <= FFontFiles.Count then
    CurrentFile := FFontFiles[FontId - 1]
  else
    CurrentFile := '';

  Form2.InitialFile := CurrentFile;
  if Form2.ShowModal <> mrOk then
    Exit;
  SelectedFile := Form2.SelectedFile;

  if Form2.SdPushRequested then
  begin
    FontId := Form2.SelectedSdFontId;
    SdPath := '/fonts/font' + IntToStr(FontId) + '.vlw';
    Form2.Show;
    Form2.Update;
    try
      if SendFileToEspSd(SelectedFile, SdPath, Form2.Label8) then
      begin
        LocalFontsDir := IncludeTrailingPathDelimiter(SdRootPath) + 'fonts';
        ForceDirectories(LocalFontsDir);
        SelectedFile := IncludeTrailingPathDelimiter(LocalFontsDir) + 'font' + IntToStr(FontId) + '.vlw';
        if AnsiCompareFileName(Form2.SelectedFile, SelectedFile) <> 0 then
          CopyFile(PChar(Form2.SelectedFile), PChar(SelectedFile), False);
        EnsureSdFontListItem(FontId, 'font' + IntToStr(FontId) + '.vlw');
      FontIndex := FontListIndexById(FontId);
      if FontIndex >= 0 then
        FFontList.ItemIndex := FontIndex;
      if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
      begin
        StringGrid1.Cells[COL_FONT, FSelectedRow] := IntToStr(FontId);
        Edit1.Text := ScriptFromRow(FSelectedRow);
      end;
      RepaintPreview;
      SetStatus('SD font selected: ' + ExtractFileName(SelectedFile) + ' -> ' + SdPath);
          end;
    finally
      Form2.Hide;
    end;
    Exit;
  end;

  if LowerCase(ExtractFileExt(SelectedFile)) <> '.h' then
  begin
    SetStatus('Use Push SD for VLW fonts: ' + ExtractFileName(SelectedFile));
    Exit;
  end;

  if FontId > FFontFiles.Count then
    FontId := 1;
  if FontId < 1 then
    Exit;

  FFontFiles[FontId - 1] := SelectedFile;
  OldFont := TGfxFont(FFontCache[FontId - 1]);
  OldFont.Free;
  NewFont := TGfxFont.Create;
  NewFont.Name := ChangeFileExt(ExtractFileName(SelectedFile), '');
  NewFont.FileName := SelectedFile;
  NewFont.Loaded := False;
  FFontCache[FontId - 1] := NewFont;

  FFontList.Items[FontListIndexById(FontId)] := IntToStr(FontId) + ' ' + NewFont.Name;
  FFontList.ItemIndex := FontListIndexById(FontId);
  if (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) then
  begin
    StringGrid1.Cells[COL_FONT, FSelectedRow] := IntToStr(FontId);
    Edit1.Text := ScriptFromRow(FSelectedRow);
  end;
  RepaintPreview;
  SetStatus('Preview font selected: ' + ExtractFileName(SelectedFile));
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
    FUdpLastOkTick := GetTickCount;
    FUdpLossShown := False;
    SetUdpStateColor(clLime);
    if Assigned(FPortMonitor) then
      FPortMonitor.Enabled := True;
  end
  else
  begin
    CloseUdpSocket;
    FUdpLossShown := False;
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
  EnsureScreenFillRow;
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
    Line := Trim(ScreenFillScriptLine);
    if Line = '' then
      Exit;
    SendLine(Line);
    RepaintPreview;
    if FPort <> INVALID_HANDLE_VALUE then
      SetStatus('LCD clear sent: ' + Line);
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
    SetStatus('Line sent: ' + Trim(Edit1.Text));
end;

//======================================================
// Отправляет весь текущий скрипт на ESP.
procedure TForm1.UploadButtonClick(Sender: TObject);
var
  R: Integer;
  Line: string;
  Count: Integer;
  TotalCount: Integer;
  Cmd: string;
  ImageKey: string;
  SelectedImageKey: string;
  FontKey: string;
  FontId: Integer;
  ProcessedImages: TStringList;
  ProcessedFonts: TStringList;
begin
  if SerialEnabled and (FPort = INVALID_HANDLE_VALUE) and not UdpEnabled then
  begin
    SetStatus('Port is closed: ' + ComboBox1.Text);
    Exit;
  end;
  if (FPort <> INVALID_HANDLE_VALUE) and not PortAlive then
  begin
    SetStatus('Port lost before upload: ' + ComboBox1.Text);
    ClosePort(True);
    Exit;
  end;
  if (not SerialEnabled) and (not UdpEnabled) then
  begin
    SetStatus('No active output channel');
    Exit;
  end;

  ProcessedImages := TStringList.Create;
  ProcessedFonts := TStringList.Create;
  try
    Count := 0;
    EnsureScreenFillRow;
    TotalCount := 0;
    for R := 1 to StringGrid1.RowCount - 1 do
      if Trim(ScriptFromRow(R)) <> '' then
        Inc(TotalCount);
    SetSdProgress(0);
    SelectedImageKey := '';
    if Assigned(CheckBox4) and CheckBox4.Enabled and CheckBox4.Checked and
      (FSelectedRow >= 1) and (FSelectedRow < StringGrid1.RowCount) and
      (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) = 'JPG') then
    begin
      SelectedImageKey := LowerCase(Trim(
        StringGrid1.Cells[COL_TEXT, FSelectedRow]));
      SelectedImageKey := StringReplace(SelectedImageKey, '\', '/',
        [rfReplaceAll]);
    end;

    for R := 1 to StringGrid1.RowCount - 1 do
    begin
      Line := Trim(ScriptFromRow(R));
      if Line = '' then
        Continue;

      Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, R]));
      FontId := StrToIntDef(Trim(StringGrid1.Cells[COL_FONT, R]), 0);
      if FontId >= 100 then
      begin
        FontKey := IntToStr(FontId);
        if ProcessedFonts.IndexOf(FontKey) < 0 then
        begin
          if not EnsureEspSdFont(FontId) then
            Exit;
          ProcessedFonts.Add(FontKey);
        end;
      end;
      if Cmd = 'JPG' then
      begin
        ImageKey := LowerCase(Trim(StringGrid1.Cells[COL_TEXT, R]));
        ImageKey := StringReplace(ImageKey, '\', '/', [rfReplaceAll]);
        if ProcessedImages.IndexOf(ImageKey) < 0 then
        begin
          if not UploadImageRowToEsp(R,
            (SelectedImageKey <> '') and (ImageKey = SelectedImageKey)) then
            Exit;
          ProcessedImages.Add(ImageKey);
        end;
      end;

      Line := Trim(ScriptFromRow(R));
      if Line = '' then
        Continue;
      SendLine(Line);
      if SerialEnabled and (not UdpEnabled) and (FPort = INVALID_HANDLE_VALUE) then
        Exit;
      Inc(Count);
      if TotalCount > 0 then
        SetSdProgress(Count * 100 div TotalCount);
      Sleep(10);
      Application.ProcessMessages;
    end;

    SetSdProgress(100);
    SetStatus('Upload sent: ' + IntToStr(Count) + ' lines');
  finally
    ProcessedFonts.Free;
    ProcessedImages.Free;
  end;
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
    SetStatus('Open COM first for SHOWIP');
    Exit;
  end;
  SendSerialLine('SHOWIP');
  SetStatus('SHOWIP sent via COM');
end;

//======================================================
// Выбирает файл JPG и привязывает его к выбранному элементу.
procedure TForm1.PictureLoadButtonClick(Sender: TObject);
var
  Dialog: TOpenDialog;
  SourceJpg: TJPEGImage;
  EspJpg: TJPEGImage;
  Bitmap: TBitmap;
  TargetDir: string;
  TargetPath: string;
begin
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) or
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'JPG') then
  begin
    SetStatus('Select an Image component first');
    Exit;
  end;

  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title := 'Select image for SD';
    Dialog.Filter := 'JPEG images (*.jpg;*.jpeg)|*.jpg;*.jpeg|All files (*.*)|*.*';
    Dialog.InitialDir := SdRootPath;
    if Dialog.Execute then
    begin
      TargetDir := IncludeTrailingPathDelimiter(SdRootPath) + 'images\';
      ForceDirectories(TargetDir);
      TargetPath := TargetDir +
        ChangeFileExt(ExtractFileName(Dialog.FileName), '.jpg');

      SourceJpg := TJPEGImage.Create;
      EspJpg := TJPEGImage.Create;
      Bitmap := TBitmap.Create;
      try
        SourceJpg.LoadFromFile(Dialog.FileName);
        Bitmap.Assign(SourceJpg);
        EspJpg.Assign(Bitmap);
        EspJpg.CompressionQuality := 90;
        EspJpg.ProgressiveEncoding := False;
        EspJpg.Smoothing := True;
        EspJpg.SaveToFile(TargetPath);
      finally
        Bitmap.Free;
        EspJpg.Free;
        SourceJpg.Free;
      end;

      StringGrid1.Cells[COL_TEXT, FSelectedRow] :=
        SdCommandPathFromLocalPath(TargetPath);
      if Trim(StringGrid1.Cells[COL_EXTRA, FSelectedRow]) = '' then
        StringGrid1.Cells[COL_EXTRA, FSelectedRow] := '1/1'
      else
        StringGrid1.Cells[COL_EXTRA, FSelectedRow] :=
          NormalizeJpgScaleText(StringGrid1.Cells[COL_EXTRA, FSelectedRow]);
      UpdateImageRowSize(FSelectedRow);
      LoadInputsFromRow(FSelectedRow);
      StringGrid1.Invalidate;
      RepaintPreview;
      SetStatus('Image saved locally: ' +
        StringGrid1.Cells[COL_TEXT, FSelectedRow] + ' (use Upload to send)');
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
    SetStatus('Clipboard has no bitmap image');
    Exit;
  end;

  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) or
    (UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow])) <> 'JPG') then
  begin
    SetStatus('Select an Image component first');
    Exit;
  end;

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
        SetStatus('Clipboard image area too small, paste ignored');
        Exit;
      end;

      Form3.RenderSelectionToBitmap(Cropped);
      OutW := Cropped.Width;
      OutH := Cropped.Height;
      if (OutW < 4) or (OutH < 4) then
      begin
        SetStatus('Clipboard image area too small, paste ignored');
        Exit;
      end;

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

      SetStatus('Clipboard image saved: ' +
        StringGrid1.Cells[COL_TEXT, FSelectedRow] + ' (use Upload to send)');
    except
      on E: Exception do
        SetStatus('Clipboard paste failed: ' + E.Message);
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
  if FPortMonitorBusy then
    Exit;
  FPortMonitorBusy := True;
  try
    if UdpEnabled then
    begin
      PollUdpInput;
      ProbeUdpStatus;
    end;

    if FPort <> INVALID_HANDLE_VALUE then
    begin
      if not PortAlive then
      begin
        SetStatus('Port lost: ' + ComboBox1.Text);
        ClosePort(True);
        Exit;
      end;
      PollPortInput;
    end;
    if (ComboBox4.Items.Count = 0) and (not FRefreshingSdScripts) and
      (not FUdpBusy) and (GetTickCount - FSdScriptsLastTick >= 5000) and
      (UdpEnabled or (FPort <> INVALID_HANDLE_VALUE)) then
      RefreshSdScriptList;
    UpdateMainStatusBar;
  finally
    FPortMonitorBusy := False;
  end;
end;

//======================================================
// Switches the selected slider/progress component between horizontal and vertical.
procedure TForm1.OrientationCheckClick(Sender: TObject);
var
  Cmd, NewCmd, OldWidth: string;
begin
  if FLoadingInputs then
    Exit;
  if (FSelectedRow < 1) or (FSelectedRow >= StringGrid1.RowCount) then
    Exit;

  Cmd := UpperCase(Trim(StringGrid1.Cells[COL_CMD, FSelectedRow]));
  NewCmd := Cmd;
  if (Sender = CheckBox8) and ((Cmd = 'TR') or (Cmd = 'VT')) then
  begin
    if CheckBox8.Checked then
      NewCmd := 'VT'
    else
      NewCmd := 'TR';
  end
  else if (Sender = CheckBox7) and ((Cmd = 'PB') or (Cmd = 'VP')) then
  begin
    if CheckBox7.Checked then
      NewCmd := 'VP'
    else
      NewCmd := 'PB';
  end;

  if NewCmd = Cmd then
    Exit;
  StringGrid1.Cells[COL_CMD, FSelectedRow] := NewCmd;
  OldWidth := StringGrid1.Cells[COL_W, FSelectedRow];
  StringGrid1.Cells[COL_W, FSelectedRow] := StringGrid1.Cells[COL_H, FSelectedRow];
  StringGrid1.Cells[COL_H, FSelectedRow] := OldWidth;
  LoadInputsFromRow(FSelectedRow);
  Edit1.Text := ScriptFromRow(FSelectedRow);
  RepaintPreview;
end;

//======================================================
// Добавляет выбранный тип компонента из панели элементов.
procedure TForm1.PaletteElementClick(Sender: TObject);
var
  Kind: string;
begin
  Kind := UpperCase(TControl(Sender).Hint);
  if (Kind = 'TR') and CheckBox8.Checked then
    Kind := 'VT'
  else if (Kind = 'PB') and CheckBox7.Checked then
    Kind := 'VP';

  AddElement(Kind);
end;

//======================================================
// Adds an Image component immediately when the palette picture is pressed.
procedure TForm1.PicturePaletteMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    AddElement('JPG');
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm1.Button16Click(Sender: TObject);
begin
form4.show;
Form4.Memo1.Lines.Clear;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm1.Button17Click(Sender: TObject);
begin
form5.ShowModal;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
form1.Refresh;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
form6.showmodal;
end;

end.
