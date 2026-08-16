#include <Arduino.h>
#include <ArduinoOTA.h>
#include <SD.h>
#include <SPI.h>
#include <TFT_eSPI.h>
#include <TJpg_Decoder.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <Preferences.h>
#include "gui_fonts.h"

#if __has_include("ota_secrets.h")
#include "ota_secrets.h"
#else
#define WIFI_SSID ""
#define WIFI_PASSWORD ""
#define OTA_PASSWORD ""
#endif

#ifndef WIFI_SSID
#define WIFI_SSID ""
#endif
#ifndef WIFI_PASSWORD
#define WIFI_PASSWORD ""
#endif
#ifndef WIFI_SSID_1
#define WIFI_SSID_1 WIFI_SSID
#endif
#ifndef WIFI_PASSWORD_1
#define WIFI_PASSWORD_1 WIFI_PASSWORD
#endif
#ifndef WIFI_SSID_2
#define WIFI_SSID_2 ""
#endif
#ifndef WIFI_PASSWORD_2
#define WIFI_PASSWORD_2 ""
#endif
#ifndef WIFI_SSID_3
#define WIFI_SSID_3 ""
#endif
#ifndef WIFI_PASSWORD_3
#define WIFI_PASSWORD_3 ""
#endif
#ifndef OTA_PASSWORD
#define OTA_PASSWORD ""
#endif

TFT_eSPI tft;

constexpr uint8_t BACKLIGHT_PIN = TFT_BL;
constexpr uint8_t HEARTBEAT_LED_PIN = 2;
constexpr uint8_t TOUCH_IRQ_PIN = TOUCH_IRQ;
constexpr uint8_t UI_UART_RX = 16;
constexpr uint8_t UI_UART_TX = 17;
constexpr uint8_t SD_CS_PIN = 27;
constexpr uint32_t SD_SPI_FREQUENCY = 4000000;
constexpr uint32_t UI_UART_BAUD = 115200;
constexpr uint16_t GUI_UDP_PORT = 4210;
constexpr size_t COMMAND_BUFFER_SIZE = 192;
constexpr uint16_t TOUCH_THRESHOLD = 250;
constexpr bool DISPLAY_INVERTED = true;
constexpr bool TOUCH_INVERT_X = true;
constexpr int16_t TOUCH_LEFT_EDGE_X_CORRECTION = 20;
constexpr int16_t TOUCH_CENTER_X_CORRECTION = 6;
constexpr int16_t TOUCH_CENTER_X_CORRECTION_RANGE = 140;
constexpr uint16_t COLOR_TRANSPARENT = 0x0001;
constexpr int16_t GFX_FONT_Y_CORRECTION = -3;
constexpr char OTA_HOSTNAME[] = "nxt-display";
constexpr uint32_t WIFI_CONNECT_TIMEOUT_MS = 5000;
constexpr uint32_t TOUCH_POLL_INTERVAL_MS = 25;
constexpr char STARTUP_CONFIG_PATH[] = "/startup.txt";
constexpr char WIFI_PREF_NAMESPACE[] = "nxtwifi";
constexpr char WIFI_PREF_LAST_SSID[] = "last_ssid";
constexpr size_t STARTUP_WIFI_COUNT = 3;
constexpr size_t STARTUP_TEXT_SIZE = 64;
constexpr int SD_FONT_ID_BASE = 100;
constexpr int SD_FONT_ID_MAX = 999;
constexpr char SD_FONT_DIR[] = "/fonts";
struct StartupWifiCredential {
  char ssid[STARTUP_TEXT_SIZE];
  char password[STARTUP_TEXT_SIZE];
};

struct StaticWifiCredential {
  const char *ssid;
  const char *password;
};

struct WifiAttempt {
  const char *ssid;
  const char *password;
  const char *source;
};

const StaticWifiCredential STATIC_WIFI[STARTUP_WIFI_COUNT] = {
  {WIFI_SSID_1, WIFI_PASSWORD_1},
  {WIFI_SSID_2, WIFI_PASSWORD_2},
  {WIFI_SSID_3, WIFI_PASSWORD_3}
};

StartupWifiCredential startupWifi[STARTUP_WIFI_COUNT];
char lastWifiSsid[STARTUP_TEXT_SIZE];
bool startupConfigLoaded = false;
bool startupScreenAvailable = false;
constexpr size_t MAX_UI_BUTTONS = 16;
constexpr size_t MAX_UI_TOUCH_CONTROLS = 16;
constexpr size_t MAX_SCENE_LINES = 96;
constexpr size_t BUTTON_LABEL_SIZE = 24;

struct UiButton {
  int id;
  int16_t x;
  int16_t y;
  int16_t w;
  int16_t h;
  uint16_t fill;
  uint16_t outline;
  uint16_t text;
  int lineWidth;
  int font;
  char hAlign;
  char vAlign;
  char label[BUTTON_LABEL_SIZE];
};

enum UiTouchKind {
  UI_TOUCH_TRACK,
  UI_TOUCH_SWITCH
};

struct UiTouchControl {
  UiTouchKind kind;
  int id;
  int16_t x;
  int16_t y;
  int16_t w;
  int16_t h;
  int value;
  int maximum;
  uint16_t track;
  uint16_t thumb;
  uint16_t element;
  uint16_t outline;
  int lineWidth;
  char orientation;
  uint16_t *background;
  size_t backgroundPixels;
};

struct SceneLine {
  char command[4];
  int id;
  char line[COMMAND_BUFFER_SIZE];
};

HardwareSerial UiSerial(2);
WiFiUDP GuiUdp;
char usbCommand[COMMAND_BUFFER_SIZE];
char uartCommand[COMMAND_BUFFER_SIZE];
char udpCommand[COMMAND_BUFFER_SIZE];
size_t usbCommandLength = 0;
size_t uartCommandLength = 0;
bool otaReady = false;
bool otaInProgress = false;
bool sdReady = false;
bool udpReady = false;
bool udpEventPeerReady = false;
bool resetRequested = false;
uint32_t resetAtMs = 0;
IPAddress udpEventPeerIp;
uint16_t udpEventPeerPort = 0;
uint16_t currentScreenColor = TFT_BLACK;
bool screenFillActive = false;
File sdUploadFile;
String sdUploadPath;
size_t sdUploadExpectedSize = 0;
size_t sdUploadWrittenSize = 0;
bool jpegClipActive = false;
int16_t jpegClipX = 0;
int16_t jpegClipY = 0;
int16_t jpegClipW = 0;
int16_t jpegClipH = 0;
int16_t jpegTargetX = 0;
int16_t jpegTargetY = 0;
int16_t jpegOutputZoom = 1;
int otaDisplayedPercent = -1;
UiButton uiButtons[MAX_UI_BUTTONS];
size_t uiButtonCount = 0;
UiTouchControl uiTouchControls[MAX_UI_TOUCH_CONTROLS];
size_t uiTouchControlCount = 0;
SceneLine sceneLines[MAX_SCENE_LINES];
size_t sceneLineCount = 0;
int pressedButtonIndex = -1;
int currentTouchButtonIndex = -1;
int pressedTouchControlIndex = -1;
int currentTouchControlIndex = -1;
uint16_t lastTouchX = 0;
uint16_t lastTouchY = 0;

const uint8_t ICON_PLAY[] PROGMEM = {
  0b00000000, 0b00000000,
  0b00011000, 0b00000000,
  0b00011100, 0b00000000,
  0b00011110, 0b00000000,
  0b00011111, 0b00000000,
  0b00011111, 0b10000000,
  0b00011111, 0b11000000,
  0b00011111, 0b11100000,
  0b00011111, 0b11100000,
  0b00011111, 0b11000000,
  0b00011111, 0b10000000,
  0b00011111, 0b00000000,
  0b00011110, 0b00000000,
  0b00011100, 0b00000000,
  0b00011000, 0b00000000,
  0b00000000, 0b00000000
};

const uint8_t ICON_STOP[] PROGMEM = {
  0b00000000, 0b00000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00111111, 0b11000000,
  0b00000000, 0b00000000
};

const uint8_t ICON_WIFI[] PROGMEM = {
  0b00000000, 0b00000000,
  0b00011111, 0b10000000,
  0b01100000, 0b01100000,
  0b10000000, 0b00010000,
  0b00011111, 0b10000000,
  0b00100000, 0b01000000,
  0b01000000, 0b00100000,
  0b00000111, 0b00000000,
  0b00001000, 0b10000000,
  0b00010000, 0b01000000,
  0b00000010, 0b00000000,
  0b00000111, 0b00000000,
  0b00000111, 0b00000000,
  0b00000010, 0b00000000,
  0b00000000, 0b00000000,
  0b00000000, 0b00000000
};

struct BitmapAsset {
  const char *name;
  uint8_t width;
  uint8_t height;
  const uint8_t *data;
};

const BitmapAsset BITMAP_ASSETS[] = {
  {"play", 16, 16, ICON_PLAY},
  {"stop", 16, 16, ICON_STOP},
  {"wifi", 16, 16, ICON_WIFI}
};

void drawScrollBar(int id, int x, int y, int w, int h, char orientation, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element);
void drawTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element);
void drawVerticalTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element);
void drawProgressBar(int id, int x, int y, int w, int h, int percent, uint16_t fill, uint16_t background, uint16_t outline);
void drawVerticalProgressBar(int id, int x, int y, int w, int h, int percent, uint16_t fill, uint16_t background, uint16_t outline);
void drawSwitch(int id, int x, int y, int w, int h, int state, uint16_t outline, uint16_t thumb, uint16_t track, uint16_t element, int lineWidth);
void drawTrackBarDirty(UiTouchControl &control, int oldValue, int newValue);
void drawAlignedTextBox(const char *text, int x, int y, int w, int h, uint16_t color,
                        uint16_t background, int font, char hAlign, char vAlign,
                        bool fillBackground);
bool processCommand(char *line, Print &reply);
bool loadStartupConfig();
void runStartupScreenScript();
void drawWifiStatus(const char *line1, const char *line2, uint16_t color);
void resetScene();

void resetSceneLines()
{
  sceneLineCount = 0;
}

int findSceneLine(const char *command, int id)
{
  for (size_t i = 0; i < sceneLineCount; ++i) {
    if (sceneLines[i].id == id && strcmp(sceneLines[i].command, command) == 0) {
      return static_cast<int>(i);
    }
  }
  return -1;
}

void storeSceneLine(const char *command, int id, const char *line)
{
  int index = findSceneLine(command, id);
  if (index < 0) {
    if (sceneLineCount >= MAX_SCENE_LINES) {
      Serial.printf("Scene registry full; %s|%d not stored\n", command, id);
      return;
    }
    index = static_cast<int>(sceneLineCount++);
  }

  strlcpy(sceneLines[index].command, command, sizeof(sceneLines[index].command));
  sceneLines[index].id = id;
  strlcpy(sceneLines[index].line, line ? line : "", sizeof(sceneLines[index].line));
}

bool replacePipeField(char *line, int fieldIndex, const char *value)
{
  char updated[COMMAND_BUFFER_SIZE];
  size_t out = 0;
  int currentField = 0;
  const char *p = line;

  updated[0] = '\0';
  while (*p != '\0' && out < sizeof(updated) - 1) {
    if (currentField == fieldIndex) {
      const char *v = value ? value : "";
      while (*v != '\0' && out < sizeof(updated) - 1) {
        updated[out++] = *v++;
      }
      while (*p != '\0' && *p != '|') {
        ++p;
      }
      if (*p == '|') {
        updated[out++] = *p++;
        ++currentField;
      }
      continue;
    }

    if (*p == '|') {
      ++currentField;
    }
    updated[out++] = *p++;
  }
  updated[out] = '\0';

  if (currentField < fieldIndex) {
    return false;
  }

  strlcpy(line, updated, COMMAND_BUFFER_SIZE);
  return true;
}

void updateSceneControlValue(const char *command, int id, int value)
{
  int index = findSceneLine(command, id);
  char valueText[16];
  if (index < 0) {
    return;
  }

  snprintf(valueText, sizeof(valueText), "%d", value);
  replacePipeField(sceneLines[index].line, 6, valueText);
}

void printSceneSnapshot(Print &stream)
{
  size_t lineCount = sceneLineCount + (screenFillActive ? 1 : 0);
  stream.print("OK|SS|BEGIN|");
  stream.println(lineCount);
  if (screenFillActive) {
    stream.printf("0x%04X\n", currentScreenColor);
  }
  for (size_t i = 0; i < sceneLineCount; ++i) {
    stream.println(sceneLines[i].line);
  }
  stream.println("OK|SS|END");
}

void resetTouchRegistry()
{
  for (size_t i = 0; i < uiTouchControlCount; ++i) {
    free(uiTouchControls[i].background);
    uiTouchControls[i].background = nullptr;
    uiTouchControls[i].backgroundPixels = 0;
  }
  uiButtonCount = 0;
  uiTouchControlCount = 0;
  pressedButtonIndex = -1;
  currentTouchButtonIndex = -1;
  pressedTouchControlIndex = -1;
  currentTouchControlIndex = -1;
}

void resetScene()
{
  resetTouchRegistry();
  resetSceneLines();
}

bool registerTouchControl(UiTouchKind kind, int id, int x, int y, int w, int h,
                           int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element,
                           uint16_t outline = TFT_BLACK, int lineWidth = 1, char orientation = 'H')
{
  char normalizedOrientation = static_cast<char>(toupper(static_cast<unsigned char>(orientation)));
  size_t controlIndex = uiTouchControlCount;
  for (size_t i = 0; i < uiTouchControlCount; ++i) {
    if (uiTouchControls[i].kind == kind && uiTouchControls[i].id == id &&
        (kind != UI_TOUCH_TRACK || uiTouchControls[i].orientation == normalizedOrientation)) {
      controlIndex = i;
      break;
    }
  }

  if (controlIndex == uiTouchControlCount) {
    if (uiTouchControlCount >= MAX_UI_TOUCH_CONTROLS) {
      Serial.printf("Touch registry full; id=%d is display-only\n", id);
      return false;
    }
    uiTouchControls[controlIndex].background = nullptr;
    uiTouchControls[controlIndex].backgroundPixels = 0;
    ++uiTouchControlCount;
  }

  UiTouchControl &control = uiTouchControls[controlIndex];
  if ((control.background != nullptr) &&
      (control.x != x || control.y != y || control.w != w || control.h != h ||
       control.kind != kind || control.id != id)) {
    free(control.background);
    control.background = nullptr;
    control.backgroundPixels = 0;
  }

  control.kind = kind;
  control.id = id;
  control.x = x;
  control.y = y;
  control.w = w;
  control.h = h;
  control.value = value;
  control.maximum = max(maximum, 1);
  control.track = track;
  control.thumb = thumb;
  control.element = element;
  control.outline = outline;
  control.lineWidth = constrain(lineWidth, 1, 4);
  control.orientation = normalizedOrientation;
  return true;
}

void updateHeartbeat()
{
  constexpr uint16_t patternMs[] = {80, 120, 80, 720};
  constexpr bool ledState[] = {true, false, true, false};
  static uint8_t step = 0;
  static uint32_t lastChange = 0;

  uint32_t now = millis();
  if (now - lastChange < patternMs[step]) {
    return;
  }

  step = (step + 1) % (sizeof(patternMs) / sizeof(patternMs[0]));
  lastChange = now;
  digitalWrite(HEARTBEAT_LED_PIN, ledState[step] ? HIGH : LOW);
}

bool parseColorLiteral(const char *value, uint16_t &color)
{
  if (value == nullptr || value[0] == '\0') {
    return false;
  }
  char *end = nullptr;
  unsigned long parsed = strtoul(value, &end, 0);
  if (end == value || *end != '\0' || parsed > 0xFFFFUL) {
    return false;
  }
  color = static_cast<uint16_t>(parsed);
  return true;
}

void fillScreenFromScriptColor(uint16_t color)
{
  currentScreenColor = color;
  screenFillActive = true;
  tft.fillScreen(color);
  resetScene();
}

uint16_t parseColor(const char *value, uint16_t fallback)
{
  if (value == nullptr || value[0] == '\0') {
    return fallback;
  }

  char *end = nullptr;
  uint32_t color = strtoul(value, &end, 0);
  if (end == value) {
    return fallback;
  }

  return static_cast<uint16_t>(color);
}


uint8_t rgb565Luma(uint16_t color)
{
  uint8_t r = ((color >> 11) & 0x1F) << 3;
  uint8_t g = ((color >> 5) & 0x3F) << 2;
  uint8_t b = (color & 0x1F) << 3;
  return static_cast<uint8_t>((static_cast<uint16_t>(r) * 30 + static_cast<uint16_t>(g) * 59 + static_cast<uint16_t>(b) * 11) / 100);
}

uint16_t contrastRgb565(uint16_t color)
{
  return rgb565Luma(color) > 140 ? TFT_BLACK : TFT_WHITE;
}
uint16_t lightenRgb565(uint16_t color, uint8_t amount)
{
  amount = min<uint8_t>(amount, 100);
  uint8_t r = (color >> 11) & 0x1F;
  uint8_t g = (color >> 5) & 0x3F;
  uint8_t b = color & 0x1F;

  r += ((31 - r) * amount) / 100;
  g += ((63 - g) * amount) / 100;
  b += ((31 - b) * amount) / 100;

  return (static_cast<uint16_t>(r) << 11) | (static_cast<uint16_t>(g) << 5) | b;
}

int parseIntField(const char *value, int fallback = 0)
{
  if (value == nullptr || value[0] == '\0') {
    return fallback;
  }

  return atoi(value);
}

void parseJpegScale(const char *value, int &decoderScale, int &outputZoom)
{
  decoderScale = 1;
  outputZoom = 1;
  if (value == nullptr || value[0] == '\0' || strcmp(value, "1") == 0 || strcmp(value, "1/1") == 0) {
    return;
  }

  if (strcmp(value, "1/4") == 0) {
    decoderScale = 4;
    return;
  }
  if (strcmp(value, "1/2") == 0) {
    decoderScale = 2;
    return;
  }
  if (strcmp(value, "2/1") == 0) {
    outputZoom = 2;
    return;
  }
  if (strcmp(value, "4/1") == 0) {
    outputZoom = 4;
    return;
  }

  int legacy = parseIntField(value, 1);
  if (legacy == 2 || legacy == 4 || legacy == 8) {
    decoderScale = legacy;
  }
}

bool isNumericFontText(const char *text)
{
  if (text == nullptr) {
    return true;
  }

  for (const char *p = text; *p != '\0'; ++p) {
    char c = *p;
    bool supported = isDigit(c) || c == ' ' || c == '.' || c == ':' || c == '-' || c == '+';
    if (!supported) {
      return false;
    }
  }

  return true;
}

bool isSdFontId(int font)
{
  return font >= SD_FONT_ID_BASE && font <= SD_FONT_ID_MAX;
}

bool sdFontBaseNameForId(int font, String &fontBaseName)
{
  if (!sdReady || !isSdFontId(font)) {
    return false;
  }

  String fontPath = String(SD_FONT_DIR) + "/font" + font + ".vlw";
  if (!SD.exists(fontPath)) {
    return false;
  }

  fontBaseName = String(SD_FONT_DIR + 1) + "/font" + font;
  return true;
}

bool loadSdFontById(int font)
{
  String fontBaseName;
  if (!sdFontBaseNameForId(font, fontBaseName)) {
    return false;
  }

  tft.loadFont(fontBaseName, SD);
  return true;
}

int sdFontIdFromFileName(String name)
{
  int slash = name.lastIndexOf('/');
  if (slash >= 0) {
    name = name.substring(slash + 1);
  }
  name.toLowerCase();
  if (!name.endsWith(".vlw")) {
    return -1;
  }
  name = name.substring(0, name.length() - 4);
  if (!name.startsWith("font")) {
    return -1;
  }
  name = name.substring(4);
  if (name.length() == 0) {
    return -1;
  }
  for (int i = 0; i < name.length(); ++i) {
    if (!isDigit(name[i])) {
      return -1;
    }
  }
  int id = name.toInt();
  return isSdFontId(id) ? id : -1;
}

int resolveTextFont(const char *text, int requestedFont)
{
  if (isSdFontId(requestedFont)) {
    return requestedFont;
  }
  return constrain(requestedFont, 1, GUI_FONT_COUNT);
}

void mapCp1251ToRusFont(const char *text, char *out, size_t outSize)
{
  if (outSize == 0) {
    return;
  }

  size_t j = 0;
  if (text != nullptr) {
    for (size_t i = 0; text[i] != '\0' && j < outSize - 1; ++i) {
      uint8_t c = static_cast<uint8_t>(text[i]);
      if (c == 168) {
        c = 192;
      } else if (c == 184) {
        c = 193;
      } else if (c >= 192 && c <= 239) {
        c -= 48;
      } else if (c >= 240) {
        c -= 112;
      }
      out[j++] = static_cast<char>(c);
    }
  }
  out[j] = '\0';
}

void appendUtf8Codepoint(uint16_t cp, char *out, size_t outSize, size_t &j)
{
  if (cp < 0x80) {
    if (j + 1 < outSize) out[j++] = static_cast<char>(cp);
  } else if (cp < 0x800) {
    if (j + 2 < outSize) {
      out[j++] = static_cast<char>(0xC0 | (cp >> 6));
      out[j++] = static_cast<char>(0x80 | (cp & 0x3F));
    }
  } else {
    if (j + 3 < outSize) {
      out[j++] = static_cast<char>(0xE0 | (cp >> 12));
      out[j++] = static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
      out[j++] = static_cast<char>(0x80 | (cp & 0x3F));
    }
  }
}

void cp1251ToUtf8(const char *text, char *out, size_t outSize)
{
  if (outSize == 0) {
    return;
  }

  size_t j = 0;
  if (text != nullptr) {
    for (size_t i = 0; text[i] != '\0' && j < outSize - 1; ++i) {
      uint8_t c = static_cast<uint8_t>(text[i]);
      uint16_t cp = c;
      if (c == 0xA8) {
        cp = 0x0401;
      } else if (c == 0xB8) {
        cp = 0x0451;
      } else if (c == 0xB9) {
        cp = 0x2116;
      } else if (c >= 0xC0) {
        cp = 0x0410 + (c - 0xC0);
      }
      appendUtf8Codepoint(cp, out, outSize, j);
    }
  }
  out[j] = '\0';
}

void sendAck(Print &stream, const char *command, bool ok)
{
  stream.print(ok ? "OK|" : "ERR|");
  stream.println(command);
}

void sendReady(Print &stream)
{
  stream.println("ready");
}

void printHelp(Print &stream)
{
  stream.println("NXT Display commands (fields are separated by |):");
  stream.println("  HELP");
  stream.println("    Show this command list.");
  stream.println("  ?");
  stream.println("    Reply with ready.");
  stream.println("  SHOWIP");
  stream.println("    Reply with current Wi-Fi IP and UDP port.");
  stream.println("  RESET");
  stream.println("    Reply OK and restart ESP after a short delay.");
  stream.println("  SS");
  stream.println("    Return current scene snapshot as command lines with live values.");
  stream.println("  TF" );
  stream.println("    Show all loaded TFT_eSPI and GFX font samples." );
  stream.println("  FL" );
  stream.println("    List SD VLW fonts from /fonts. Font IDs start at 100." );
  stream.println("  CL|color");
  stream.println("    Clear screen. Example: CL|0x0000");
  stream.println("  BL|0/1");
  stream.println("    Backlight off/on. Example: BL|1");
  stream.println("  IV|0/1");
  stream.println("    Display inversion off/on. Example: IV|1");
  stream.println("  BT|id|x|y|w|h|label|fill|outline|text|line|font|H|V");
  stream.println("    Draw button. H=L/C/R, V=T/C/B. Optional fields default to 1|2|C|C.");
  stream.println("    Example: BT|1|20|20|120|50|OK|0x001F|0xFFFF|0xFFFF|2|2|C|C");
  stream.println("    Touch events: EV|BT|id|DOWN/UP/CLICK|x|y");
  stream.println("  BX|id|x|y|w|h|fill|outline|radius|line");
  stream.println("    Draw box. Use fill 0x0001 for no fill.");
  stream.println("  RR|id|x|y|w|h|fill|outline|radius|line");
  stream.println("    Draw rounded rectangle. Example: RR|1|10|10|100|40|0x0001|0xFFFF|8|2");
  stream.println("  TX|id|x|y|text|color|background|font|w|h|H|V");
  stream.println("    Draw text. Use background 0x0001 for transparency. H=L/C/R, V=T/C/B.");
  stream.println("    Example: TX|1|20|90|Hello|0xFFFF|0x0001|2|120|30|C|C");
  stream.println("  TW|id|x|y|w|h|title|text|fill|outline");
  stream.println("    Draw text window. Use fill 0x0001 for transparent body.");
  stream.println("  TR|id|x|y|w|h|value|max|track|thumb|element");
  stream.println("    Draw horizontal trackbar. Element is the filled track color; optional for old scripts.");
  stream.println("  PB|id|x|y|w|h|percent|fill|background|outline");
  stream.println("    Draw horizontal progress bar.");
  stream.println("  CC|id|x|y|diameter|fill|outline|line");
  stream.println("    Draw circle. Use fill 0x0001 for no fill.");
  stream.println("  SW|id|x|y|w|h|0/1|stroke|thumb|fill|element|line");
  stream.println("    Draw switch. Colors: stroke outline, thumb, inactive fill, active fill. Line is 1..4.");
  stream.println("  SB|id|x|y|w|h|H/V|value|max|track|thumb|element");
  stream.println("    Draw horizontal or vertical scrollbar.");
  stream.println("  BM|id|x|y|name|foreground|background|scale");
  stream.println("    Draw bitmap. Names: play, stop, wifi.");
  stream.println("    Use background 0x0001 for transparency.");
  stream.println("  SD");
  stream.println("    Show microSD status and capacity.");
  stream.println("  LS|path");
  stream.println("    List files in a microSD directory. Example: LS|/");
  stream.println("  FS|path");
  stream.println("    Show one microSD file size. Example: FS|/lcd2.jpg");
  stream.println("  FI|path");
  stream.println("    Show microSD file size and last-write timestamp.");
  stream.println("  RM|path");
  stream.println("    Delete one microSD file. Example: RM|/scripts/script1.nxt");
  stream.println("  SL");
  stream.println("    List scripts in /scripts. SL|path lists all files in path.");
  stream.println("  DL" );
  stream.println("    List microSD root directories for the desktop editor." );
  stream.println("  FL" );
  stream.println("    List /fonts/*.vlw as ID/name pairs. Examples: font100.vlw or 100.vlw." );
  stream.println("  FR|path|offset|len");
  stream.println("    Read a microSD file chunk as HEX. Example: FR|/scripts/demo.nxt|0|64");
  stream.println("  JPG|id|x|y|path|scale|srcX|srcY|srcW|srcH");
  stream.println("    Draw a JPEG or selected source area. Scale: 1/4, 1/2, 1/1, 2/1, 4/1.");
  stream.println("    Example: JPG|1|20|20|/icons/play.jpg|1/2|0|0|64|64");
  stream.println("  FW|path|size, FD|hex, FDO|offset|hex, FE");
  stream.println("    Write a file to microSD through serial.");
  stream.println("  SC|path");
  stream.println("    Run a text script from microSD. Example: SC|/scripts/demo.nxt");
  stream.println("Colors are RGB565 numbers, for example 0x0000 black and 0xFFFF white.");
}

void printSdStatus(Print &stream)
{
  if (!sdReady) {
    stream.println("SD|NOT_READY");
    return;
  }

  stream.printf("SD|READY|SIZE_MB|%llu|USED_MB|%llu\n",
                SD.cardSize() / (1024ULL * 1024ULL),
                SD.usedBytes() / (1024ULL * 1024ULL));
}

bool listSdDirectory(const char *path, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|sd_not_ready");
    return false;
  }

  const char *resolvedPath = path && path[0] ? path : "/";
  File directory = SD.open(resolvedPath);
  if (!directory || !directory.isDirectory()) {
    stream.print("ERR|sd_directory|");
    stream.println(resolvedPath);
    if (directory) {
      directory.close();
    }
    return false;
  }

  for (File entry = directory.openNextFile(); entry; entry = directory.openNextFile()) {
    stream.print(entry.isDirectory() ? "DIR|" : "FILE|");
    stream.print(entry.name());
    if (!entry.isDirectory()) {
      stream.print('|');
      stream.print(entry.size());
    }
    stream.println();
    entry.close();
  }

  directory.close();
  return true;
}

bool printSdFileSize(const char *path, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|fs|sd_not_ready");
    return false;
  }
  if (path == nullptr || path[0] == '\0') {
    stream.println("ERR|fs|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  File file = SD.open(resolvedPath, FILE_READ);
  if (!file || file.isDirectory()) {
    stream.print("ERR|fs|not_found|");
    stream.println(resolvedPath);
    if (file) {
      file.close();
    }
    return false;
  }

  stream.printf("OK|FS|%s|%u\n", resolvedPath.c_str(), static_cast<unsigned>(file.size()));
  file.close();
  return true;
}

bool printSdFileInfo(const char *path, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|fi|sd_not_ready");
    return false;
  }
  if (path == nullptr || path[0] == '\0') {
    stream.println("ERR|fi|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  File file = SD.open(resolvedPath, FILE_READ);
  if (!file || file.isDirectory()) {
    stream.print("ERR|fi|not_found|");
    stream.println(resolvedPath);
    if (file) {
      file.close();
    }
    return false;
  }

  const size_t fileSize = file.size();
  const time_t lastWrite = file.getLastWrite();
  stream.printf("OK|FI|%s|%u|%lu\n", resolvedPath.c_str(),
                static_cast<unsigned>(fileSize), static_cast<unsigned long>(lastWrite));
  file.close();
  return true;
}


bool deleteSdFile(const char *path, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|rm|sd_not_ready");
    return false;
  }
  if (path == nullptr || path[0] == '\0') {
    stream.println("ERR|rm|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  if (resolvedPath == "/") {
    stream.println("ERR|rm|bad_path|/");
    return false;
  }
  if (!SD.exists(resolvedPath)) {
    stream.print("ERR|rm|not_found|");
    stream.println(resolvedPath);
    return false;
  }

  File file = SD.open(resolvedPath, FILE_READ);
  if (file && file.isDirectory()) {
    file.close();
    stream.print("ERR|rm|is_directory|");
    stream.println(resolvedPath);
    return false;
  }
  if (file) {
    file.close();
  }

  if (!SD.remove(resolvedPath)) {
    stream.print("ERR|rm|delete_failed|");
    stream.println(resolvedPath);
    return false;
  }

  stream.printf("OK|RM|%s\n", resolvedPath.c_str());
  return true;
}
bool listSdDirectories(Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|dl|sd_not_ready");
    return false;
  }

  File directory = SD.open("/");
  if (!directory || !directory.isDirectory()) {
    stream.println("ERR|dl|open");
    if (directory) {
      directory.close();
    }
    return false;
  }

  stream.print("OK|DL|/");
  for (File entry = directory.openNextFile(); entry; entry = directory.openNextFile()) {
    if (entry.isDirectory()) {
      String name = entry.name();
      int slash = name.lastIndexOf('/');
      if (slash >= 0) {
        name = name.substring(slash + 1);
      }
      if (name.length() > 0 && name != "System Volume Information") {
        stream.print('|');
        stream.print('/');
        stream.print(name);
      }
    }
    entry.close();
  }
  stream.println();
  directory.close();
  return true;
}

bool listSdScripts(const char *path, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|sl|sd_not_ready");
    return false;
  }

  const char *resolvedPath = path && path[0] ? path : "/scripts";
  if (!SD.exists(resolvedPath)) {
    stream.println("OK|SL");
    return true;
  }

  File directory = SD.open(resolvedPath);
  if (!directory || !directory.isDirectory()) {
    stream.println("ERR|sl|open");
    if (directory) {
      directory.close();
    }
    return false;
  }

  stream.print("OK|SL");
  for (File entry = directory.openNextFile(); entry; entry = directory.openNextFile()) {
    if (!entry.isDirectory()) {
      String name = entry.name();
      int slash = name.lastIndexOf('/');
      if (slash >= 0) {
        name = name.substring(slash + 1);
      }
      String lower = name;
      lower.toLowerCase();
      if ((path && path[0]) || lower.endsWith(".nxt") || lower.endsWith(".txt")) {
        stream.print('|');
        stream.print(name);
      }
    }
    entry.close();
  }
  stream.println();
  directory.close();
  return true;
}

bool listSdFonts(Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|fl|sd_not_ready");
    return false;
  }

  if (!SD.exists(SD_FONT_DIR)) {
    stream.println("OK|FL");
    return true;
  }

  File directory = SD.open(SD_FONT_DIR);
  if (!directory || !directory.isDirectory()) {
    stream.println("ERR|fl|open");
    if (directory) {
      directory.close();
    }
    return false;
  }

  stream.print("OK|FL");
  for (File entry = directory.openNextFile(); entry; entry = directory.openNextFile()) {
    if (!entry.isDirectory()) {
      String name = entry.name();
      int id = sdFontIdFromFileName(name);
      if (id >= 0) {
        int slash = name.lastIndexOf('/');
        if (slash >= 0) {
          name = name.substring(slash + 1);
        }
        stream.print('|');
        stream.print(id);
        stream.print('|');
        stream.print(name);
      }
    }
    entry.close();
  }
  stream.println();
  directory.close();
  return true;
}

bool readSdFileChunk(const char *path, size_t offset, size_t requestedSize, Print &stream)
{
  if (!sdReady) {
    stream.println("ERR|fr|sd_not_ready");
    return false;
  }
  if (path == nullptr || path[0] == '\0') {
    stream.println("ERR|fr|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  File file = SD.open(resolvedPath, FILE_READ);
  if (!file || file.isDirectory()) {
    stream.print("ERR|fr|not_found|");
    stream.println(resolvedPath);
    if (file) {
      file.close();
    }
    return false;
  }

  size_t totalSize = file.size();
  if (requestedSize < 1) {
    requestedSize = 1;
  }
  if (requestedSize > 64) {
    requestedSize = 64;
  }
  if (offset > totalSize) {
    offset = totalSize;
  }

  file.seek(offset);
  static const char hex[] = "0123456789ABCDEF";
  stream.printf("OK|FR|%s|%u|%u|", resolvedPath.c_str(), static_cast<unsigned>(offset), static_cast<unsigned>(totalSize));
  size_t sent = 0;
  while (sent < requestedSize && file.available()) {
    uint8_t value = static_cast<uint8_t>(file.read());
    stream.write(hex[value >> 4]);
    stream.write(hex[value & 0x0F]);
    ++sent;
  }
  stream.println();
  file.close();
  return true;
}


bool jpegOutput(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t *pixels)
{
  int zoom = max<int>(1, jpegOutputZoom);
  int32_t clipLeft = 0;
  int32_t clipTop = 0;
  int32_t clipRight = tft.width();
  int32_t clipBottom = tft.height();
  if (jpegClipActive) {
    clipLeft = max<int32_t>(clipLeft, jpegClipX);
    clipTop = max<int32_t>(clipTop, jpegClipY);
    clipRight = min<int32_t>(clipRight, jpegClipX + jpegClipW);
    clipBottom = min<int32_t>(clipBottom, jpegClipY + jpegClipH);
  }

  int32_t blockLeft = jpegTargetX + (static_cast<int32_t>(x) - jpegTargetX) * zoom;
  int32_t blockTop = jpegTargetY + (static_cast<int32_t>(y) - jpegTargetY) * zoom;
  int32_t blockRight = blockLeft + static_cast<int32_t>(w) * zoom;
  int32_t blockBottom = blockTop + static_cast<int32_t>(h) * zoom;

  if (blockRight <= clipLeft || blockBottom <= clipTop || blockLeft >= clipRight || blockTop >= clipBottom) {
    return true;
  }

  int16_t visibleLeft = max<int32_t>(blockLeft, clipLeft);
  int16_t visibleTop = max<int32_t>(blockTop, clipTop);
  int16_t visibleRight = min<int32_t>(blockRight, clipRight);
  int16_t visibleBottom = min<int32_t>(blockBottom, clipBottom);
  uint16_t visibleWidth = visibleRight - visibleLeft;
  uint16_t visibleHeight = visibleBottom - visibleTop;
  uint16_t sourceLeft = (visibleLeft - blockLeft) / zoom;
  uint16_t sourceTop = (visibleTop - blockTop) / zoom;

  if (zoom == 1) {
    for (uint16_t row = 0; row < visibleHeight; ++row) {
      uint16_t *rowPixels = pixels + (sourceTop + row) * w + sourceLeft;
      tft.pushImage(visibleLeft, visibleTop + row, visibleWidth, 1, rowPixels);
    }
    return true;
  }

  static uint16_t scaledRow[256];
  if (visibleWidth > sizeof(scaledRow) / sizeof(scaledRow[0])) {
    return true;
  }
  for (uint16_t row = 0; row < visibleHeight; ++row) {
    uint16_t srcRow = (visibleTop + row - blockTop) / zoom;
    for (uint16_t col = 0; col < visibleWidth; ++col) {
      uint16_t srcCol = (visibleLeft + col - blockLeft) / zoom;
      scaledRow[col] = pixels[srcRow * w + srcCol];
    }
    tft.pushImage(visibleLeft, visibleTop + row, visibleWidth, 1, scaledRow);
  }
  return true;
}

bool drawSdJpeg(int id, int x, int y, const char *path, const char *scaleText,
                int srcX, int srcY, int srcW, int srcH, Print &reply)
{
  int decoderScale = 1;
  int outputZoom = 1;
  if (!sdReady) {
    reply.println("ERR|jpg|sd_not_ready");
    return false;
  }

  if (path == nullptr || path[0] == '\0') {
    reply.println("ERR|jpg|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  if (!SD.exists(resolvedPath)) {
    reply.print("ERR|jpg|not_found|");
    reply.println(resolvedPath);
    return false;
  }

  parseJpegScale(scaleText, decoderScale, outputZoom);

  int drawX = x;
  int drawY = y;
  jpegTargetX = x;
  jpegTargetY = y;
  jpegOutputZoom = outputZoom;
  jpegClipActive = srcW > 0 && srcH > 0;
  if (jpegClipActive) {
    jpegClipX = x;
    jpegClipY = y;
    jpegClipW = max(1, (srcW + decoderScale - 1) / decoderScale * outputZoom);
    jpegClipH = max(1, (srcH + decoderScale - 1) / decoderScale * outputZoom);
    drawX = x - (srcX / decoderScale);
    drawY = y - (srcY / decoderScale);
  }

  TJpgDec.setJpgScale(decoderScale);
  JRESULT result = TJpgDec.drawSdJpg(drawX, drawY, resolvedPath);
  jpegClipActive = false;
  jpegOutputZoom = 1;
  if (result != JDR_OK) {
    reply.printf("ERR|jpg|decode|%d|%s\n", static_cast<int>(result), resolvedPath.c_str());
    return false;
  }

  Serial.printf("GUI JPEG %d rendered path=%s scale=%s\n", id, resolvedPath.c_str(),
                scaleText ? scaleText : "1/1");
  return true;
}

bool ensureSdParentDirectory(const String &path)
{
  int slash = path.lastIndexOf('/');
  if (slash <= 0) {
    return true;
  }

  String current;
  String parent = path.substring(0, slash);
  int start = 1;
  while (start < parent.length()) {
    int next = parent.indexOf('/', start);
    String part = next < 0 ? parent.substring(start) : parent.substring(start, next);
    if (part.length() > 0) {
      current += '/';
      current += part;
      if (!SD.exists(current) && !SD.mkdir(current)) {
        return false;
      }
    }
    if (next < 0) {
      break;
    }
    start = next + 1;
  }
  return true;
}

int hexNibble(char value)
{
  if (value >= '0' && value <= '9') {
    return value - '0';
  }
  if (value >= 'A' && value <= 'F') {
    return value - 'A' + 10;
  }
  if (value >= 'a' && value <= 'f') {
    return value - 'a' + 10;
  }
  return -1;
}

bool beginSdUpload(const char *path, size_t expectedSize, Print &reply)
{
  if (!sdReady) {
    reply.println("ERR|fw|sd_not_ready");
    return false;
  }
  if (path == nullptr || path[0] == '\0') {
    reply.println("ERR|fw|missing_path");
    return false;
  }

  if (sdUploadFile) {
    sdUploadFile.close();
  }

  sdUploadPath = path[0] == '/' ? String(path) : String('/') + path;
  sdUploadExpectedSize = expectedSize;
  sdUploadWrittenSize = 0;

  if (!ensureSdParentDirectory(sdUploadPath)) {
    reply.print("ERR|fw|mkdir|");
    reply.println(sdUploadPath);
    return false;
  }

  if (SD.exists(sdUploadPath)) {
    SD.remove(sdUploadPath);
  }

  sdUploadFile = SD.open(sdUploadPath, FILE_WRITE);
  if (!sdUploadFile) {
    reply.print("ERR|fw|open|");
    reply.println(sdUploadPath);
    return false;
  }

  reply.printf("OK|FW|%s|%u\n", sdUploadPath.c_str(), static_cast<unsigned>(sdUploadExpectedSize));
  return true;
}

bool writeSdUploadHex(const char *hexData, Print &reply)
{
  uint8_t buffer[64];
  size_t count = 0;

  if (!sdUploadFile) {
    reply.println("ERR|fd|not_open");
    return false;
  }
  if (hexData == nullptr) {
    reply.println("ERR|fd|missing_data");
    return false;
  }

  size_t len = strlen(hexData);
  if ((len & 1) != 0 || len > sizeof(buffer) * 2) {
    reply.println("ERR|fd|invalid_length");
    return false;
  }

  for (size_t i = 0; i < len; i += 2) {
    int hi = hexNibble(hexData[i]);
    int lo = hexNibble(hexData[i + 1]);
    if (hi < 0 || lo < 0) {
      reply.println("ERR|fd|invalid_hex");
      return false;
    }
    buffer[count++] = static_cast<uint8_t>((hi << 4) | lo);
  }

  if (count > 0 && sdUploadFile.write(buffer, count) != count) {
    reply.println("ERR|fd|write");
    sdUploadFile.close();
    return false;
  }
  sdUploadWrittenSize += count;
  reply.printf("OK|FD|%u\n", static_cast<unsigned>(sdUploadWrittenSize));
  return true;
}

bool decodeUploadHex(const char *hexData, uint8_t *buffer, size_t bufferSize, size_t &count, Print &reply)
{
  count = 0;
  if (hexData == nullptr) {
    reply.println("ERR|fd|missing_data");
    return false;
  }

  size_t len = strlen(hexData);
  if ((len & 1) != 0 || len > bufferSize * 2) {
    reply.println("ERR|fd|invalid_length");
    return false;
  }

  for (size_t i = 0; i < len; i += 2) {
    int hi = hexNibble(hexData[i]);
    int lo = hexNibble(hexData[i + 1]);
    if (hi < 0 || lo < 0) {
      reply.println("ERR|fd|invalid_hex");
      return false;
    }
    buffer[count++] = static_cast<uint8_t>((hi << 4) | lo);
  }
  return true;
}

bool writeSdUploadHexAt(size_t expectedOffset, const char *hexData, Print &reply)
{
  uint8_t buffer[64];
  size_t count = 0;

  if (!sdUploadFile) {
    reply.println("ERR|fdo|not_open");
    return false;
  }
  if (!decodeUploadHex(hexData, buffer, sizeof(buffer), count, reply)) {
    return false;
  }

  if (expectedOffset < sdUploadWrittenSize) {
    if (expectedOffset + count <= sdUploadWrittenSize) {
      reply.printf("OK|FDO|%u\n", static_cast<unsigned>(sdUploadWrittenSize));
      return true;
    }
    reply.printf("ERR|fdo|overlap|%u|%u\n",
                 static_cast<unsigned>(expectedOffset),
                 static_cast<unsigned>(sdUploadWrittenSize));
    return false;
  }

  if (expectedOffset != sdUploadWrittenSize) {
    reply.printf("ERR|fdo|offset|%u|%u\n",
                 static_cast<unsigned>(expectedOffset),
                 static_cast<unsigned>(sdUploadWrittenSize));
    return false;
  }

  if (count > 0 && sdUploadFile.write(buffer, count) != count) {
    reply.println("ERR|fdo|write");
    sdUploadFile.close();
    return false;
  }
  sdUploadWrittenSize += count;
  reply.printf("OK|FDO|%u\n", static_cast<unsigned>(sdUploadWrittenSize));
  return true;
}

bool endSdUpload(Print &reply)
{
  if (!sdUploadFile) {
    reply.println("ERR|fe|not_open");
    return false;
  }

  sdUploadFile.flush();
  sdUploadFile.close();

  if (sdUploadExpectedSize != 0 && sdUploadWrittenSize != sdUploadExpectedSize) {
    reply.printf("ERR|fe|size|%u|%u\n",
                 static_cast<unsigned>(sdUploadWrittenSize),
                 static_cast<unsigned>(sdUploadExpectedSize));
    return false;
  }

  reply.printf("OK|FE|%s|%u\n", sdUploadPath.c_str(), static_cast<unsigned>(sdUploadWrittenSize));
  sdUploadPath = "";
  sdUploadExpectedSize = 0;
  sdUploadWrittenSize = 0;
  return true;
}

bool runSdScript(const char *path, Print &reply)
{
  if (!sdReady) {
    reply.println("ERR|script|sd_not_ready");
    return false;
  }

  if (path == nullptr || path[0] == '\0') {
    reply.println("ERR|script|missing_path");
    return false;
  }

  String resolvedPath = path[0] == '/' ? String(path) : String('/') + path;
  if (!SD.exists(resolvedPath)) {
    reply.print("ERR|script|not_found|");
    reply.println(resolvedPath);
    return false;
  }

  File script = SD.open(resolvedPath, FILE_READ);
  if (!script || script.isDirectory()) {
    reply.print("ERR|script|open|");
    reply.println(resolvedPath);
    if (script) {
      script.close();
    }
    return false;
  }

  char buffer[COMMAND_BUFFER_SIZE];
  size_t len = 0;
  uint32_t lineNumber = 1;
  bool ok = true;
  bool screenSectionActive = false;
  bool sawScreenSection = false;

  auto executeLine = [&]() {
    buffer[len] = '\0';
    char *start = buffer;
    while (*start != '\0' && isspace(static_cast<unsigned char>(*start))) {
      ++start;
    }

    char *end = start + strlen(start);
    while (end > start && isspace(static_cast<unsigned char>(*(end - 1)))) {
      --end;
    }
    *end = '\0';

    if (start[0] == '\0' || start[0] == '#' || start[0] == ';') {
      return true;
    }

    char *equals = strchr(start, '=');
    char *pipe = strchr(start, '|');
    if (equals != nullptr && (pipe == nullptr || equals < pipe)) {
      char key[24];
      size_t keyLen = min(static_cast<size_t>(equals - start), sizeof(key) - 1);
      memcpy(key, start, keyLen);
      key[keyLen] = '\0';
      char *keyStart = key;
      while (*keyStart != '\0' && isspace(static_cast<unsigned char>(*keyStart))) {
        ++keyStart;
      }
      char *keyEnd = keyStart + strlen(keyStart);
      while (keyEnd > keyStart && isspace(static_cast<unsigned char>(*(keyEnd - 1)))) {
        --keyEnd;
      }
      *keyEnd = '\0';
      for (char *p = keyStart; *p != '\0'; ++p) {
        *p = static_cast<char>(toupper(static_cast<unsigned char>(*p)));
      }
      if (strcmp(keyStart, "SCREEN") == 0) {
        screenSectionActive = true;
        sawScreenSection = true;
      }
      return true;
    }

    if (sawScreenSection && !screenSectionActive) {
      return true;
    }

    char commandBuffer[COMMAND_BUFFER_SIZE];
    strlcpy(commandBuffer, start, sizeof(commandBuffer));
    if (!processCommand(commandBuffer, reply)) {
      reply.printf("ERR|script|line|%lu|%s\n", static_cast<unsigned long>(lineNumber), start);
      return false;
    }
    return true;
  };

  while (script.available()) {
    char c = static_cast<char>(script.read());
    if (c == '\r') {
      continue;
    }
    if (c == '\n') {
      ok = executeLine();
      if (!ok) {
        break;
      }
      len = 0;
      ++lineNumber;
      continue;
    }
    if (len >= sizeof(buffer) - 1) {
      reply.printf("ERR|script|line_too_long|%lu\n", static_cast<unsigned long>(lineNumber));
      ok = false;
      break;
    }
    buffer[len++] = c;
  }

  if (ok && len > 0) {
    ok = executeLine();
  }

  script.close();
  if (ok) {
    reply.printf("OK|SC|%s\n", resolvedPath.c_str());
  }
  return ok;
}

void setBacklight(bool enabled)
{
  if (BACKLIGHT_PIN == 255) {
    return;
  }

  digitalWrite(BACKLIGHT_PIN, enabled ? TFT_BACKLIGHT_ON : !TFT_BACKLIGHT_ON);
}

void blinkBacklightAtBoot()
{
  if (BACKLIGHT_PIN == 255) {
    return;
  }

  setBacklight(true);
}

String trimStartupLine(String line)
{
  line.trim();
  return line;
}

void setStartupText(char *dest, size_t destSize, const String &value)
{
  if (dest == nullptr || destSize == 0) {
    return;
  }
  strlcpy(dest, value.c_str(), destSize);
}

void clearStartupWifi()
{
  for (size_t i = 0; i < STARTUP_WIFI_COUNT; ++i) {
    startupWifi[i].ssid[0] = '\0';
    startupWifi[i].password[0] = '\0';
  }
}

bool loadStartupConfig()
{
  clearStartupWifi();
  startupConfigLoaded = false;
  startupScreenAvailable = false;

  if (!sdReady) {
    Serial.println("Startup config skipped: SD not ready");
    return false;
  }

  File config = SD.open(STARTUP_CONFIG_PATH, FILE_READ);
  if (!config) {
    Serial.printf("Startup config not found: %s\n", STARTUP_CONFIG_PATH);
    return false;
  }

  while (config.available()) {
    String line = trimStartupLine(config.readStringUntil('\n'));
    if (line.length() == 0 || line[0] == ';') {
      continue;
    }

    int equalsPos = line.indexOf('=');
    if (equalsPos < 0) {
      continue;
    }

    String key = trimStartupLine(line.substring(0, equalsPos));
    String value = trimStartupLine(line.substring(equalsPos + 1));
    key.toUpperCase();

    if (key == "SCREEN") {
      startupScreenAvailable = true;
      break;
    }

    int slot = -1;
    bool passwordField = false;
    if (key == "SSID") {
      slot = 0;
    } else if (key == "PASS") {
      slot = 0;
      passwordField = true;
    } else if (key == "SSID1") {
      slot = 1;
    } else if (key == "PASS1") {
      slot = 1;
      passwordField = true;
    } else if (key == "SSID2") {
      slot = 2;
    } else if (key == "PASS2") {
      slot = 2;
      passwordField = true;
    }

    if (slot >= 0 && slot < static_cast<int>(STARTUP_WIFI_COUNT)) {
      if (passwordField) {
        setStartupText(startupWifi[slot].password, sizeof(startupWifi[slot].password), value);
      } else {
        setStartupText(startupWifi[slot].ssid, sizeof(startupWifi[slot].ssid), value);
      }
      startupConfigLoaded = true;
    }
  }

  config.close();
  Serial.printf("Startup config loaded: wifi=%s screen=%s\n", startupConfigLoaded ? "yes" : "no",
                startupScreenAvailable ? "yes" : "no");
  return startupConfigLoaded || startupScreenAvailable;
}

void drawWifiStatus(const char *line1, const char *line2, uint16_t color)
{
  setBacklight(true);
  tft.fillScreen(TFT_BLACK);
  tft.setTextDatum(MC_DATUM);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.drawString("NXT Display", tft.width() / 2, 70, 4);
  tft.setTextColor(color, TFT_BLACK);
  tft.drawString(line1 ? line1 : "Wi-Fi", tft.width() / 2, 140, 4);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.drawString(line2 ? line2 : "", tft.width() / 2, 190, 2);
}

void drawWifiProgress(uint32_t elapsedMs)
{
  constexpr int16_t barX = 40;
  constexpr int16_t barY = 225;
  constexpr int16_t barW = 400;
  constexpr int16_t barH = 22;
  constexpr int16_t inset = 3;
  int16_t filledW = static_cast<int16_t>(((barW - inset * 2) *
                                          min(elapsedMs, WIFI_CONNECT_TIMEOUT_MS)) /
                                         WIFI_CONNECT_TIMEOUT_MS);

  tft.drawRoundRect(barX, barY, barW, barH, 5, TFT_WHITE);
  tft.fillRoundRect(barX + inset, barY + inset, barW - inset * 2, barH - inset * 2, 3, TFT_DARKGREY);
  if (filledW > 0) {
    tft.fillRect(barX + inset, barY + inset, filledW, barH - inset * 2, TFT_SKYBLUE);
  }
}

void drawWifiConnected(const char *ssid)
{
  setBacklight(true);
  String ipText = WiFi.localIP().toString();
  int ipScale = 2;
  if (tft.textWidth(ipText, 4) * ipScale > tft.width() - 20) {
    ipScale = 1;
  }

  tft.fillScreen(TFT_BLACK);
  tft.setTextDatum(MC_DATUM);
  tft.setTextSize(1);
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.drawString("WI-FI CONNECTED", tft.width() / 2, 38, 4);
  tft.setTextColor(TFT_LIGHTGREY, TFT_BLACK);
  tft.drawString("SSID", tft.width() / 2, 88, 2);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.drawString(ssid ? ssid : "", tft.width() / 2, 116, 2);
  tft.setTextColor(TFT_LIGHTGREY, TFT_BLACK);
  tft.drawString("IP ADDRESS", tft.width() / 2, 170, 2);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.setTextSize(ipScale);
  tft.drawString(ipText, tft.width() / 2, 225, 4);
  tft.setTextSize(1);
  delay(3000);
}


void runStartupScreenScript()
{
  if (!sdReady || !startupScreenAvailable) {
    return;
  }

  File config = SD.open(STARTUP_CONFIG_PATH, FILE_READ);
  if (!config) {
    return;
  }

  bool inScreen = false;
  uint32_t scriptLine = 0;
  while (config.available()) {
    String line = trimStartupLine(config.readStringUntil('\n'));
    if (line.length() == 0 || line[0] == ';') {
      continue;
    }

    if (!inScreen) {
      int equalsPos = line.indexOf('=');
      if (equalsPos >= 0) {
        String key = trimStartupLine(line.substring(0, equalsPos));
        key.toUpperCase();
        if (key == "SCREEN") {
          inScreen = true;
        }
      }
      continue;
    }

    char commandBuffer[COMMAND_BUFFER_SIZE];
    strlcpy(commandBuffer, line.c_str(), sizeof(commandBuffer));
    if (!processCommand(commandBuffer, Serial)) {
      Serial.printf("Startup screen command failed at line %lu: %s\n", static_cast<unsigned long>(scriptLine + 1),
                    line.c_str());
    }
    ++scriptLine;
  }

  config.close();
  Serial.printf("Startup screen script executed: %lu command(s)\n", static_cast<unsigned long>(scriptLine));
}
void drawOtaProgress(unsigned int percent, const char *status, uint16_t statusColor)
{
  percent = min(percent, 100U);

  constexpr int16_t barX = 50;
  constexpr int16_t barY = 176;
  constexpr int16_t barWidth = 380;
  constexpr int16_t barHeight = 32;
  constexpr int16_t barInset = 4;
  constexpr int16_t percentY = 118;

  bool firstDraw = otaDisplayedPercent < 0;
  if (firstDraw) {
    tft.fillScreen(TFT_BLACK);
    tft.setTextDatum(MC_DATUM);
    tft.setTextColor(TFT_CYAN, TFT_BLACK);
    tft.drawString("OTA UPDATE", tft.width() / 2, 64, 4);
    tft.drawRoundRect(barX, barY, barWidth, barHeight, 6, TFT_WHITE);
    tft.fillRoundRect(barX + barInset, barY + barInset, barWidth - 2 * barInset, barHeight - 2 * barInset, 3, TFT_DARKGREY);

    tft.setTextColor(statusColor, TFT_BLACK);
    tft.drawString(status, tft.width() / 2, 250, 2);
  }

  if (static_cast<int>(percent) != otaDisplayedPercent) {
    char percentText[8];
    snprintf(percentText, sizeof(percentText), "%u%%", percent);

    tft.fillRect(170, percentY - 25, 140, 50, TFT_BLACK);
    tft.setTextDatum(MC_DATUM);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.drawString(percentText, tft.width() / 2, percentY, 4);

    int16_t innerWidth = barWidth - 2 * barInset;
    int16_t previousWidth = otaDisplayedPercent > 0 ? (innerWidth * otaDisplayedPercent) / 100 : 0;
    int16_t filledWidth = (innerWidth * percent) / 100;
    if (filledWidth > previousWidth) {
      tft.fillRect(barX + barInset + previousWidth, barY + barInset, filledWidth - previousWidth, barHeight - 2 * barInset, TFT_GREEN);
    }

    otaDisplayedPercent = static_cast<int>(percent);
  }

  if (!firstDraw && (percent == 100 || statusColor == TFT_RED)) {
    tft.fillRect(30, 232, 420, 36, TFT_BLACK);
    tft.setTextDatum(MC_DATUM);
    tft.setTextColor(statusColor, TFT_BLACK);
    tft.drawString(status, tft.width() / 2, 250, 2);
  }
}

bool loadLastWifiSsid()
{
  lastWifiSsid[0] = '\0';
  Preferences prefs;
  if (!prefs.begin(WIFI_PREF_NAMESPACE, true)) {
    Serial.println("Wi-Fi last SSID: NVS open failed");
    return false;
  }

  String saved = prefs.getString(WIFI_PREF_LAST_SSID, "");
  prefs.end();
  if (saved.length() == 0) {
    return false;
  }

  saved.toCharArray(lastWifiSsid, sizeof(lastWifiSsid));
  Serial.printf("Wi-Fi last SSID loaded: %s\n", lastWifiSsid);
  return lastWifiSsid[0] != '\0';
}

void saveLastWifiSsid(const char *ssid)
{
  if (ssid == nullptr || ssid[0] == '\0') {
    return;
  }
  if (strcmp(lastWifiSsid, ssid) == 0) {
    return;
  }

  Preferences prefs;
  if (!prefs.begin(WIFI_PREF_NAMESPACE, false)) {
    Serial.println("Wi-Fi last SSID: NVS save open failed");
    return;
  }
  prefs.putString(WIFI_PREF_LAST_SSID, ssid);
  prefs.end();
  strlcpy(lastWifiSsid, ssid, sizeof(lastWifiSsid));
  Serial.printf("Wi-Fi last SSID saved: %s\n", lastWifiSsid);
}

const char *findPasswordForSsid(const char *ssid)
{
  if (ssid == nullptr || ssid[0] == '\0') {
    return nullptr;
  }

  for (size_t i = 0; i < STARTUP_WIFI_COUNT; ++i) {
    if (startupWifi[i].ssid[0] != '\0' && strcmp(startupWifi[i].ssid, ssid) == 0) {
      return startupWifi[i].password;
    }
  }
  for (size_t i = 0; i < STARTUP_WIFI_COUNT; ++i) {
    if (STATIC_WIFI[i].ssid[0] != '\0' && strcmp(STATIC_WIFI[i].ssid, ssid) == 0) {
      return STATIC_WIFI[i].password;
    }
  }
  return nullptr;
}

bool addWifiAttempt(WifiAttempt *attempts, size_t maxAttempts, size_t &count, const char *ssid, const char *password, const char *source)
{
  if (ssid == nullptr || ssid[0] == '\0' || count >= maxAttempts) {
    return false;
  }

  for (size_t i = 0; i < count; ++i) {
    if (strcmp(attempts[i].ssid, ssid) == 0) {
      return false;
    }
  }

  attempts[count].ssid = ssid;
  attempts[count].password = password ? password : "";
  attempts[count].source = source ? source : "wifi";
  ++count;
  return true;
}


void startOta()
{
  constexpr size_t MAX_WIFI_ATTEMPTS = 1 + STARTUP_WIFI_COUNT + STARTUP_WIFI_COUNT;
  WifiAttempt attempts[MAX_WIFI_ATTEMPTS];
  size_t attemptCount = 0;

  bool hasLastWifi = loadLastWifiSsid();
  if (hasLastWifi) {
    const char *lastPassword = findPasswordForSsid(lastWifiSsid);
    if (lastPassword != nullptr) {
      addWifiAttempt(attempts, MAX_WIFI_ATTEMPTS, attemptCount, lastWifiSsid, lastPassword, "last");
    } else {
      Serial.printf("Wi-Fi last SSID skipped, password not configured: %s\n", lastWifiSsid);
    }
  }

  for (size_t i = 0; i < STARTUP_WIFI_COUNT; ++i) {
    addWifiAttempt(attempts, MAX_WIFI_ATTEMPTS, attemptCount, startupWifi[i].ssid, startupWifi[i].password, "sd");
  }
  for (size_t i = 0; i < STARTUP_WIFI_COUNT; ++i) {
    addWifiAttempt(attempts, MAX_WIFI_ATTEMPTS, attemptCount, STATIC_WIFI[i].ssid, STATIC_WIFI[i].password, "static");
  }

  if (attemptCount == 0) {
    drawWifiStatus("Wi-Fi not configured", "startup.txt or ota_secrets.h", TFT_RED);
    Serial.println("OTA disabled: configure startup.txt or include/ota_secrets.h");
    return;
  }

  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.setHostname(OTA_HOSTNAME);

  for (size_t i = 0; i < attemptCount && WiFi.status() != WL_CONNECTED; ++i) {
    const char *ssid = attempts[i].ssid;
    const char *password = attempts[i].password;

    char statusLine[96];
    snprintf(statusLine, sizeof(statusLine), "Wi-Fi %s %u/%u", attempts[i].source, static_cast<unsigned>(i + 1),
             static_cast<unsigned>(attemptCount));
    drawWifiStatus(statusLine, ssid, TFT_YELLOW);

    WiFi.disconnect(true, true);
    delay(100);
    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false);
    WiFi.setHostname(OTA_HOSTNAME);
    WiFi.begin(ssid, password ? password : "");

    Serial.printf("Connecting to Wi-Fi for OTA [%u/%u, %s]: %s", static_cast<unsigned>(i + 1),
                  static_cast<unsigned>(attemptCount), attempts[i].source, ssid);
    uint32_t startedAt = millis();
    uint32_t lastProgressUpdate = 0;
    while (WiFi.status() != WL_CONNECTED && millis() - startedAt < WIFI_CONNECT_TIMEOUT_MS) {
      uint32_t elapsed = millis() - startedAt;
      if (elapsed - lastProgressUpdate >= 100) {
        drawWifiProgress(elapsed);
        lastProgressUpdate = elapsed;
      }
      delay(50);
      if (elapsed % 250 < 50) {
        Serial.print('.');
      }
    }
    Serial.println();
  }

  if (WiFi.status() != WL_CONNECTED) {
    drawWifiStatus("Wi-Fi failed", "all configured networks", TFT_RED);
    Serial.println("OTA unavailable: Wi-Fi connection timed out for all configured networks");
    return;
  }

  saveLastWifiSsid(WiFi.SSID().c_str());
  drawWifiConnected(WiFi.SSID().c_str());

  ArduinoOTA.setHostname(OTA_HOSTNAME);
  if (OTA_PASSWORD[0] != '\0') {
    ArduinoOTA.setPassword(OTA_PASSWORD);
  }

  ArduinoOTA.onStart([]() {
    otaInProgress = true;
    otaDisplayedPercent = -1;
    setBacklight(true);
    drawOtaProgress(0, "Receiving firmware...", TFT_YELLOW);
    Serial.println("OTA update started");
  });
  ArduinoOTA.onEnd([]() {
    drawOtaProgress(100, "Update complete. Restarting...", TFT_GREEN);
    Serial.println("\nOTA update finished");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    unsigned int percent = total ? (progress * 100U) / total : 0U;
    if (percent == 100U || otaDisplayedPercent < 0 || static_cast<int>(percent) >= otaDisplayedPercent + 5) {
      drawOtaProgress(percent, "Receiving firmware...", TFT_YELLOW);
      Serial.printf("OTA progress: %u%%\r", percent);
    }
  });
  ArduinoOTA.onError([](ota_error_t error) {
    otaInProgress = false;
    drawOtaProgress(otaDisplayedPercent < 0 ? 0U : static_cast<unsigned int>(otaDisplayedPercent), "OTA ERROR", TFT_RED);
    Serial.printf("\nOTA error %u\n", error);
  });

  ArduinoOTA.begin();
  otaReady = true;
  udpReady = GuiUdp.begin(GUI_UDP_PORT) == 1;
  Serial.printf("OTA ready: %s.local, SSID=%s, IP=%s\n", OTA_HOSTNAME, WiFi.SSID().c_str(),
                WiFi.localIP().toString().c_str());
  Serial.printf("GUI UDP %s: port %u\n", udpReady ? "ready" : "error", GUI_UDP_PORT);
}


void drawButton(int id, int x, int y, int w, int h, const char *label, uint16_t fill,
                uint16_t outline, uint16_t text, int lineWidth, int font,
                char hAlign, char vAlign)
{
  lineWidth = constrain(lineWidth, 1, 4);
  tft.fillRoundRect(x, y, w, h, 6, fill);
  for (int i = 0; i < lineWidth; ++i) {
    tft.drawRoundRect(x + i, y + i, w - i * 2, h - i * 2, max(0, 6 - i), outline);
  }
  drawAlignedTextBox(label, x, y, w, h, text, fill, font, hAlign, vAlign, false);

  size_t buttonIndex = uiButtonCount;
  for (size_t i = 0; i < uiButtonCount; ++i) {
    if (uiButtons[i].id == id) {
      buttonIndex = i;
      break;
    }
  }

  if (buttonIndex == uiButtonCount) {
    if (uiButtonCount >= MAX_UI_BUTTONS) {
      Serial.printf("Button registry full; id=%d is display-only\n", id);
      return;
    }
    ++uiButtonCount;
  }

  UiButton &button = uiButtons[buttonIndex];
  button.id = id;
  button.x = x;
  button.y = y;
  button.w = w;
  button.h = h;
  button.fill = fill;
  button.outline = outline;
  button.text = text;
  button.lineWidth = lineWidth;
  button.font = font;
  button.hAlign = hAlign;
  button.vAlign = vAlign;
  strlcpy(button.label, label ? label : "", sizeof(button.label));

  Serial.printf("GUI button %d rendered\n", id);
}

void drawBox(int id, int x, int y, int w, int h, uint16_t fill, uint16_t outline, int radius, int lineWidth)
{
  lineWidth = constrain(lineWidth, 1, 4);
  radius = constrain(radius, 0, min(w, h) / 2);
  bool transparentFill = fill == 0x0001;
  if (radius > 0) {
    if (!transparentFill) {
      tft.fillRoundRect(x, y, w, h, radius, fill);
    }
    for (int i = 0; i < lineWidth; ++i) {
      tft.drawRoundRect(x + i, y + i, w - i * 2, h - i * 2, max(0, radius - i), outline);
    }
  } else {
    if (!transparentFill) {
      tft.fillRect(x, y, w, h, fill);
    }
    for (int i = 0; i < lineWidth; ++i) {
      tft.drawRect(x + i, y + i, w - i * 2, h - i * 2, outline);
    }
  }

  Serial.printf("GUI box %d rendered\n", id);
}

void drawFontTest()
{
  resetTouchRegistry();

  tft.fillScreen(TFT_BLACK);
  tft.setTextDatum(TL_DATUM);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.drawString("TF - loaded TFT_eSPI fonts", 8, 2, 2);

  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.drawString("F1", 8, 24, 2);
  tft.drawString("AaBbCcDd 012345", 42, 28, 1);

  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.drawString("F2", 8, 43, 2);
  tft.drawString("AaBbCcDd 012345", 42, 43, 2);

  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.drawString("F4", 8, 65, 2);
  tft.drawString("AaBbCcDd 012345", 42, 60, 4);

  tft.setTextColor(TFT_ORANGE, TFT_BLACK);
  tft.drawString("F6", 8, 96, 2);
  tft.drawString("012345", 42, 86, 6);

  tft.setTextColor(TFT_MAGENTA, TFT_BLACK);
  tft.drawString("F7", 8, 148, 2);
  tft.drawString("012345", 42, 138, 7);

  tft.setTextColor(TFT_SKYBLUE, TFT_BLACK);
  tft.drawString("F8", 8, 218, 2);
  tft.drawString("012345", 42, 188, 8);

  tft.setTextColor(TFT_LIGHTGREY, TFT_BLACK);
  tft.drawString("B18", 8, 286, 2);
  tft.setFreeFont(guiFontById(9)->font);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.drawString("AaBb 0123", 52, 280);
  tft.setTextFont(1);
}

void drawTextWindow(int id, int x, int y, int w, int h, const char *title, const char *text, uint16_t fill, uint16_t outline)
{
  bool transparentFill = fill == 0x0001;
  char mappedTitle[COMMAND_BUFFER_SIZE];
  char mappedText[COMMAND_BUFFER_SIZE];
  mapCp1251ToRusFont(title, mappedTitle, sizeof(mappedTitle));
  mapCp1251ToRusFont(text, mappedText, sizeof(mappedText));
  if (!transparentFill) {
    tft.fillRoundRect(x, y, w, h, 6, fill);
  }
  tft.drawRoundRect(x, y, w, h, 6, outline);
  if (!transparentFill) {
    tft.fillRoundRect(x + 3, y + 3, w - 6, 26, 4, outline);
  }

  tft.setTextDatum(ML_DATUM);
  if (transparentFill) {
    tft.setTextColor(TFT_WHITE);
  } else {
    tft.setTextColor(TFT_WHITE, outline);
  }
  tft.drawString(mappedTitle, x + 10, y + 16, 2);

  if (transparentFill) {
    tft.setTextColor(TFT_WHITE);
  } else {
    tft.setTextColor(TFT_WHITE, fill);
  }
  tft.setTextDatum(TL_DATUM);
  tft.setTextWrap(true);
  tft.drawString(mappedText, x + 10, y + 42, 2);

  Serial.printf("GUI window %d rendered\n", id);
}

void drawScrollBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element)
{
  drawScrollBar(id, x, y, w, h, h >= w ? 'V' : 'H', value, maximum, track, thumb, element);
}

void drawScrollBar(int id, int x, int y, int w, int h, char orientation, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element)
{
  maximum = max(maximum, 1);
  value = constrain(value, 0, maximum);

  tft.fillRoundRect(x, y, w, h, 4, track);
  tft.drawRoundRect(x, y, w, h, 4, TFT_DARKGREY);

  if (orientation == 'V' || orientation == 'v') {
    int thumbHeight = max(18, h / 5);
    int travel = max(1, h - thumbHeight - 4);
    int thumbY = y + 2 + (travel * value) / maximum;
    if (thumbY > y + 2) {
      tft.fillRoundRect(x + 2, y + 2, w - 4, thumbY - (y + 2), 4, element);
    }
    tft.fillRoundRect(x + 2, thumbY, w - 4, thumbHeight, 4, thumb);
  } else {
    int thumbWidth = max(18, w / 5);
    int travel = max(1, w - thumbWidth - 4);
    int thumbX = x + 2 + (travel * value) / maximum;
    if (thumbX > x + 2) {
      tft.fillRoundRect(x + 2, y + 2, thumbX - (x + 2), h - 4, 4, element);
    }
    tft.fillRoundRect(thumbX, y + 2, thumbWidth, h - 4, 4, thumb);
  }

  Serial.printf("GUI scroll %d rendered\n", id);
}

void drawTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element)
{
  maximum = max(maximum, 1);
  value = constrain(value, 0, maximum);

  h = max(h, 4);
  w = max(w, h);
  int trackHeight = max(2, h / 2);
  int trackY = y + (h - trackHeight) / 2;
  int radius = max(2, trackHeight / 2);
  int knobRadius = h / 2;
  int travel = max(1, w - h);
  int knobX = x + knobRadius + (travel * value) / maximum;
  int knobY = y + h / 2;
  uint16_t filledTrack = element;

  if (!registerTouchControl(UI_TOUCH_TRACK, id, x, y, w, h, value, maximum, track, thumb, element, TFT_BLACK, 1, 'H')) {
    tft.fillRect(x, y, w, h, currentScreenColor);
  }
  tft.fillRoundRect(x, trackY, w, trackHeight, radius, track);
  tft.fillRoundRect(x, trackY, max(trackHeight, knobX - x), trackHeight, radius, filledTrack);
  tft.fillCircle(knobX, knobY, knobRadius, thumb);
  tft.drawCircle(knobX, knobY, knobRadius, TFT_BLACK);

  Serial.printf("GUI track %d rendered value=%d max=%d\n", id, value, maximum);
}

void drawVerticalTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb, uint16_t element)
{
  maximum = max(maximum, 1);
  value = constrain(value, 0, maximum);

  w = max(w, 4);
  h = max(h, w);
  int trackWidth = max(2, w / 2);
  int trackX = x + (w - trackWidth) / 2;
  int radius = max(2, trackWidth / 2);
  int knobRadius = w / 2;
  int travel = max(1, h - w);
  int knobX = x + w / 2;
  int knobY = y + h - knobRadius - (travel * value) / maximum;
  uint16_t filledTrack = element;

  if (!registerTouchControl(UI_TOUCH_TRACK, id, x, y, w, h, value, maximum, track, thumb, element, TFT_BLACK, 1, 'V')) {
    tft.fillRect(x, y, w, h, currentScreenColor);
  }
  tft.fillRoundRect(trackX, y, trackWidth, h, radius, track);
  tft.fillRoundRect(trackX, knobY, trackWidth, y + h - knobY, radius, filledTrack);
  tft.fillCircle(knobX, knobY, knobRadius, thumb);
  tft.drawCircle(knobX, knobY, knobRadius, TFT_BLACK);

  Serial.printf("GUI vertical track %d rendered value=%d max=%d\n", id, value, maximum);
}
int trackKnobX(const UiTouchControl &control, int value)
{
  int maximum = max(control.maximum, 1);
  int h = max<int>(control.h, 4);
  int w = max<int>(control.w, h);
  int knobRadius = h / 2;
  int travel = max(1, w - h);
  return control.x + knobRadius + (travel * constrain(value, 0, maximum)) / maximum;
}

int trackKnobY(const UiTouchControl &control, int value)
{
  int maximum = max(control.maximum, 1);
  int w = max<int>(control.w, 4);
  int h = max<int>(control.h, w);
  int knobRadius = w / 2;
  int travel = max(1, h - w);
  return control.y + h - knobRadius - (travel * constrain(value, 0, maximum)) / maximum;
}
void restoreTouchBackgroundRect(const UiTouchControl &control, int rx, int ry, int rw, int rh)
{
  int left = constrain(rx, static_cast<int>(control.x), static_cast<int>(control.x + control.w));
  int top = constrain(ry, static_cast<int>(control.y), static_cast<int>(control.y + control.h));
  int right = constrain(rx + rw, static_cast<int>(control.x), static_cast<int>(control.x + control.w));
  int bottom = constrain(ry + rh, static_cast<int>(control.y), static_cast<int>(control.y + control.h));
  int width = right - left;
  int height = bottom - top;
  if (width <= 0 || height <= 0) {
    return;
  }

  if (control.background == nullptr || control.backgroundPixels == 0) {
    tft.fillRect(left, top, width, height, currentScreenColor);
    return;
  }

  int localX = left - control.x;
  int localY = top - control.y;
  for (int row = 0; row < height; ++row) {
    uint16_t *line = control.background + (localY + row) * control.w + localX;
    tft.pushImage(left, top + row, width, 1, line);
  }
}

void drawTrackBarDirty(UiTouchControl &control, int oldValue, int newValue)
{
  if (control.orientation == 'V') {
    tft.fillRect(control.x, control.y, control.w, control.h, currentScreenColor);
    drawVerticalTrackBar(control.id, control.x, control.y, control.w, control.h,
                         newValue, control.maximum, control.track, control.thumb, control.element);
    return;
  }

  int h = max<int>(control.h, 4);
  int w = max<int>(control.w, h);
  int trackHeight = max(2, h / 2);
  int trackY = control.y + (h - trackHeight) / 2;
  int radius = max(2, trackHeight / 2);
  int knobRadius = h / 2;
  int oldKnobX = trackKnobX(control, oldValue);
  int newKnobX = trackKnobX(control, newValue);
  int knobY = control.y + h / 2;
  int dirtyLeft = min(oldKnobX, newKnobX) - knobRadius - 5;
  int dirtyRight = max(oldKnobX, newKnobX) + knobRadius + 5;
  uint16_t filledTrack = control.element;

  tft.fillCircle(oldKnobX, knobY, knobRadius + 1, currentScreenColor);

  int trackLeft = max(static_cast<int>(control.x), dirtyLeft);
  int trackRight = min(static_cast<int>(control.x + w), dirtyRight);
  if (trackRight > trackLeft) {
    tft.fillRect(trackLeft, trackY, trackRight - trackLeft, trackHeight, control.track);
  }

  int fillRight = max(control.x + trackHeight, newKnobX);
  int filledLeft = max(static_cast<int>(control.x), dirtyLeft);
  int filledRight = min(fillRight, dirtyRight);
  if (filledRight > filledLeft) {
    tft.fillRect(filledLeft, trackY, filledRight - filledLeft, trackHeight, filledTrack);
  }

  tft.fillCircle(newKnobX, knobY, knobRadius, control.thumb);
  tft.drawCircle(newKnobX, knobY, knobRadius, TFT_BLACK);
}

void drawProgressBar(int id, int x, int y, int w, int h, int percent, uint16_t fill, uint16_t background, uint16_t outline)
{
  percent = constrain(percent, 0, 100);
  w = max(w, 4);
  h = max(h, 4);

  int radius = min(5, h / 3);
  int innerX = x + 2;
  int innerY = y + 2;
  int innerW = max(1, w - 4);
  int innerH = max(1, h - 4);
  int fillW = (innerW * percent) / 100;

  tft.fillRoundRect(x, y, w, h, radius, background);
  tft.fillRoundRect(innerX, innerY, innerW, innerH, max(1, radius - 1), background);
  if (fillW > 0) {
    if (fillW >= innerW) {
      tft.fillRoundRect(innerX, innerY, innerW, innerH, max(1, radius - 1), fill);
    } else {
      tft.fillRect(innerX, innerY, fillW, innerH, fill);
    }
  }
  tft.drawRoundRect(x, y, w, h, radius, outline);

  Serial.printf("GUI progress %d rendered percent=%d\n", id, percent);
}

void drawVerticalProgressBar(int id, int x, int y, int w, int h, int percent, uint16_t fill, uint16_t background, uint16_t outline)
{
  percent = constrain(percent, 0, 100);
  w = max(w, 4);
  h = max(h, 4);

  int radius = min(5, w / 3);
  int innerX = x + 2;
  int innerY = y + 2;
  int innerW = max(1, w - 4);
  int innerH = max(1, h - 4);
  int fillH = (innerH * percent) / 100;
  int fillY = innerY + innerH - fillH;

  tft.fillRoundRect(x, y, w, h, radius, background);
  tft.fillRoundRect(innerX, innerY, innerW, innerH, max(1, radius - 1), background);
  if (fillH > 0) {
    if (fillH >= innerH) {
      tft.fillRoundRect(innerX, innerY, innerW, innerH, max(1, radius - 1), fill);
    } else {
      tft.fillRect(innerX, fillY, innerW, fillH, fill);
    }
  }
  tft.drawRoundRect(x, y, w, h, radius, outline);

  Serial.printf("GUI vertical progress %d rendered percent=%d\n", id, percent);
}
void drawSwitch(int id, int x, int y, int w, int h, int state, uint16_t outline, uint16_t thumb, uint16_t track, uint16_t element, int lineWidth)
{
  state = state == 0 ? 0 : 1;
  h = max(h, 8);
  w = max(w, h * 2);
  lineWidth = constrain(lineWidth, 1, 4);

  int radius = h / 2;
  int border = max(2, h / 14);
  int knobRadius = max(2, (h - border * 4) / 2);
  int knobY = y + h / 2;
  int enabledKnobInset = max(5, border * 2);
  int knobX = state ? (x + w - radius - enabledKnobInset) : (x + radius);
  uint16_t filledTrack = element;

  if (!registerTouchControl(UI_TOUCH_SWITCH, id, x, y, w, h, state, 1, track, thumb, element, outline, lineWidth)) {
    tft.fillRect(x, y, w, h, currentScreenColor);
  }
  tft.fillRoundRect(x, y, w, h, radius, track);
  if (state) {
    tft.fillRoundRect(x, y, w, h, radius, filledTrack);
  }
  for (int i = 0; i < lineWidth; ++i) {
    tft.drawRoundRect(x + i, y + i, w - i * 2, h - i * 2, max(0, radius - i), outline);
  }
  tft.fillCircle(knobX, knobY, knobRadius, thumb);
  tft.drawCircle(knobX, knobY, knobRadius, outline);

  Serial.printf("GUI switch %d rendered state=%d\n", id, state);
}

void drawCircleComponent(int id, int x, int y, int d, uint16_t fill, uint16_t outline, int lineWidth)
{
  lineWidth = constrain(lineWidth, 1, 4);
  d = max(d, 2);
  int radius = d / 2;
  int cx = x + radius;
  int cy = y + radius;

  if (fill != 0x0001) {
    tft.fillCircle(cx, cy, radius, fill);
  }
  for (int i = 0; i < lineWidth; ++i) {
    tft.drawCircle(cx, cy, max(1, radius - i), outline);
  }

  Serial.printf("GUI circle %d rendered\n", id);
}

const BitmapAsset *findBitmapAsset(const char *name)
{
  if (name == nullptr) {
    return nullptr;
  }

  for (const BitmapAsset &asset : BITMAP_ASSETS) {
    if (strcmp(asset.name, name) == 0) {
      return &asset;
    }
  }

  return nullptr;
}

void drawMonoBitmapAsset(int id, int x, int y, const char *name, uint16_t foreground, uint16_t background, int scale)
{
  const BitmapAsset *asset = findBitmapAsset(name);
  if (asset == nullptr) {
    Serial.printf("GUI bitmap %d missing asset=%s\n", id, name ? name : "");
    return;
  }

  scale = constrain(scale, 1, 8);
  int bytesPerRow = (asset->width + 7) / 8;

  for (uint8_t row = 0; row < asset->height; row++) {
    for (uint8_t col = 0; col < asset->width; col++) {
      uint8_t packed = pgm_read_byte(asset->data + row * bytesPerRow + col / 8);
      bool pixelOn = (packed & (0x80 >> (col % 8))) != 0;
      uint16_t color = pixelOn ? foreground : background;
      if (pixelOn || background != COLOR_TRANSPARENT) {
        tft.fillRect(x + col * scale, y + row * scale, scale, scale, color);
      }
    }
  }

  Serial.printf("GUI bitmap %d rendered asset=%s\n", id, asset->name);
}

char parseHorizontalAlign(const char *value, char fallback = 'C')
{
  if (value == nullptr || value[0] == '\0') {
    return fallback;
  }
  char align = static_cast<char>(toupper(static_cast<unsigned char>(value[0])));
  return (align == 'L' || align == 'C' || align == 'R') ? align : fallback;
}

char parseVerticalAlign(const char *value, char fallback = 'C')
{
  if (value == nullptr || value[0] == '\0') {
    return fallback;
  }
  char align = static_cast<char>(toupper(static_cast<unsigned char>(value[0])));
  return (align == 'T' || align == 'C' || align == 'B') ? align : fallback;
}

uint8_t textDatumForAlign(char hAlign, char vAlign)
{
  if (vAlign == 'T') {
    if (hAlign == 'L') return TL_DATUM;
    if (hAlign == 'R') return TR_DATUM;
    return TC_DATUM;
  }
  if (vAlign == 'B') {
    if (hAlign == 'L') return BL_DATUM;
    if (hAlign == 'R') return BR_DATUM;
    return BC_DATUM;
  }
  if (hAlign == 'L') return ML_DATUM;
  if (hAlign == 'R') return MR_DATUM;
  return MC_DATUM;
}

int alignedTextX(int x, int w, char hAlign)
{
  if (w <= 0) {
    return x;
  }
  if (hAlign == 'L') return x + 4;
  if (hAlign == 'R') return x + w - 4;
  return x + w / 2;
}

int alignedTextY(int y, int h, char vAlign)
{
  if (h <= 0) {
    return y;
  }
  if (vAlign == 'T') return y + 4;
  if (vAlign == 'B') return y + h - 4;
  return y + h / 2;
}

void drawAlignedTextBox(const char *text, int x, int y, int w, int h, uint16_t color,
                        uint16_t background, int font, char hAlign, char vAlign,
                        bool fillBackground)
{
  int resolvedFont = resolveTextFont(text, font);
  char mappedText[COMMAND_BUFFER_SIZE];
  mapCp1251ToRusFont(text, mappedText, sizeof(mappedText));
  int drawX = alignedTextX(x, w, hAlign);
  int drawY = alignedTextY(y, h, vAlign);

  if (fillBackground && background != COLOR_TRANSPARENT && w > 0 && h > 0) {
    tft.fillRect(x, y, w, h, background);
  }

  tft.setTextDatum((w > 0 && h > 0) ? textDatumForAlign(hAlign, vAlign) : TL_DATUM);
  if (background == COLOR_TRANSPARENT) {
    tft.setTextColor(color);
  } else {
    tft.setTextColor(color, background);
  }
  if (isSdFontId(resolvedFont) && loadSdFontById(resolvedFont)) {
    char utf8Text[COMMAND_BUFFER_SIZE * 3];
    cp1251ToUtf8(text, utf8Text, sizeof(utf8Text));
    tft.drawString(utf8Text, drawX, drawY);
    tft.unloadFont();
    tft.setTextFont(1);
    return;
  }

  const GuiFontEntry *guiFont = guiFontById(resolvedFont);
  if (guiFont != nullptr) {
    tft.setFreeFont(guiFont->font);
    tft.drawString(mappedText, drawX, drawY + GFX_FONT_Y_CORRECTION);
    tft.setTextFont(1);
  } else {
    tft.drawString(mappedText, drawX, drawY, resolvedFont);
  }
}

void drawTextLabel(int id, int x, int y, int w, int h, const char *text,
                   uint16_t color, uint16_t background, int font, char hAlign, char vAlign)
{
  int resolvedFont = resolveTextFont(text, font);
  drawAlignedTextBox(text, x, y, w, h, color, background, resolvedFont, hAlign, vAlign, true);

  Serial.printf("GUI text %d rendered font=%d\n", id, resolvedFont);
}

uint16_t correctTouchX(uint16_t x)
{
  int32_t corrected = x;
  int32_t halfWidth = tft.width() / 2;

  if (corrected < halfWidth) {
    corrected += (TOUCH_LEFT_EDGE_X_CORRECTION * (halfWidth - corrected)) / halfWidth;
  }

  int32_t distanceFromCenter = abs(corrected - halfWidth);
  if (distanceFromCenter < TOUCH_CENTER_X_CORRECTION_RANGE) {
    corrected += (TOUCH_CENTER_X_CORRECTION * (TOUCH_CENTER_X_CORRECTION_RANGE - distanceFromCenter)) / TOUCH_CENTER_X_CORRECTION_RANGE;
  }

  return constrain(corrected, 0, tft.width() - 1);
}

bool readTouchPoint(uint16_t &x, uint16_t &y)
{
  if (!tft.getTouch(&x, &y, TOUCH_THRESHOLD)) {
    return false;
  }

  x = constrain(x, 0, tft.width() - 1);
  y = constrain(y, 0, tft.height() - 1);

  if (TOUCH_INVERT_X) {
    x = tft.width() - 1 - x;
  }

  x = correctTouchX(x);
  return true;
}

int findTouchedButton(uint16_t x, uint16_t y)
{
  for (int i = static_cast<int>(uiButtonCount) - 1; i >= 0; --i) {
    const UiButton &button = uiButtons[i];
    if (x >= button.x && x < button.x + button.w && y >= button.y && y < button.y + button.h) {
      return i;
    }
  }
  return -1;
}

int findTouchedControl(uint16_t x, uint16_t y)
{
  for (int i = static_cast<int>(uiTouchControlCount) - 1; i >= 0; --i) {
    const UiTouchControl &control = uiTouchControls[i];
    if (x >= control.x && x < control.x + control.w && y >= control.y && y < control.y + control.h) {
      return i;
    }
  }
  return -1;
}

int touchValueForControl(const UiTouchControl &control, uint16_t x, uint16_t y)
{
  if (control.kind == UI_TOUCH_SWITCH) {
    return x >= control.x + control.w / 2 ? 1 : 0;
  }

  if (control.orientation == 'V') {
    int knobRadius = max(1, control.w / 2);
    int travel = max(1, control.h - control.w);
    int relativeY = constrain(control.y + control.h - knobRadius - static_cast<int>(y), 0, travel);
    return (relativeY * max(control.maximum, 1)) / travel;
  }

  int knobRadius = max(1, control.h / 2);
  int travel = max(1, control.w - control.h);
  int relativeX = constrain(static_cast<int>(x) - control.x - knobRadius, 0, travel);
  return (relativeX * max(control.maximum, 1)) / travel;
}

void drawButtonPressedState(int buttonIndex, bool pressed)
{
  if (buttonIndex < 0 || buttonIndex >= static_cast<int>(uiButtonCount)) {
    return;
  }

  UiButton button = uiButtons[buttonIndex];
  if (!pressed) {
    drawButton(button.id, button.x, button.y, button.w, button.h, button.label,
               button.fill, button.outline, button.text, button.lineWidth,
               button.font, button.hAlign, button.vAlign);
    return;
  }

  int ringWidth = constrain(min(button.w, button.h) / 5, 5, 10);
  uint16_t ringColor = contrastRgb565(button.fill);
  uint16_t innerColor = ringColor == TFT_BLACK ? TFT_WHITE : TFT_BLACK;
  for (int i = 0; i < ringWidth; ++i) {
    int radius = max(1, 6 - min(i, 5));
    tft.drawRoundRect(button.x + i, button.y + i,
                      button.w - i * 2, button.h - i * 2,
                      radius, ringColor);
  }
  for (int i = ringWidth; i < ringWidth + 2; ++i) {
    int radius = max(1, 6 - min(i, 5));
    tft.drawRoundRect(button.x + i, button.y + i,
                      button.w - i * 2, button.h - i * 2,
                      radius, innerColor);
  }
}

void writeButtonEvent(Stream &stream, const UiButton &button, const char *event, uint16_t x, uint16_t y)
{
  stream.print("EV|BT|");
  stream.print(button.id);
  stream.print('|');
  stream.print(event);
  stream.print('|');
  stream.print(x);
  stream.print('|');
  stream.println(y);
}

void sendUdpEventLine(const String &line)
{
  if (!udpReady || !udpEventPeerReady || udpEventPeerPort == 0) {
    return;
  }

  GuiUdp.beginPacket(udpEventPeerIp, udpEventPeerPort);
  GuiUdp.print(line);
  GuiUdp.endPacket();
}

void emitButtonEvent(int buttonIndex, const char *event, uint16_t x, uint16_t y)
{
  if (buttonIndex < 0 || buttonIndex >= static_cast<int>(uiButtonCount)) {
    return;
  }

  const UiButton &button = uiButtons[buttonIndex];
  writeButtonEvent(Serial, button, event, x, y);
  writeButtonEvent(UiSerial, button, event, x, y);
  sendUdpEventLine(String("EV|BT|") + button.id + "|" + event + "|" + x + "|" + y + "\n");
}

const char *touchControlKindName(const UiTouchControl &control)
{
  if (control.kind == UI_TOUCH_SWITCH) {
    return "SW";
  }
  return control.orientation == 'V' ? "VT" : "TR";
}

void writeTouchControlEvent(Stream &stream, const UiTouchControl &control,
                            const char *event, uint16_t x, uint16_t y)
{
  stream.print("EV|");
  stream.print(touchControlKindName(control));
  stream.print('|');
  stream.print(control.id);
  stream.print('|');
  stream.print(event);
  stream.print('|');
  stream.print(control.value);
  stream.print('|');
  stream.print(x);
  stream.print('|');
  stream.println(y);
}

void emitTouchControlEvent(int controlIndex, const char *event, uint16_t x, uint16_t y)
{
  if (controlIndex < 0 || controlIndex >= static_cast<int>(uiTouchControlCount)) {
    return;
  }

  const UiTouchControl &control = uiTouchControls[controlIndex];
  writeTouchControlEvent(Serial, control, event, x, y);
  writeTouchControlEvent(UiSerial, control, event, x, y);
  sendUdpEventLine(String("EV|") + touchControlKindName(control) + "|" +
                   control.id + "|" + event + "|" + control.value + "|" + x + "|" + y + "\n");
}

void redrawTouchControl(int controlIndex)
{
  if (controlIndex < 0 || controlIndex >= static_cast<int>(uiTouchControlCount)) {
    return;
  }

  const UiTouchControl control = uiTouchControls[controlIndex];
  if (control.kind == UI_TOUCH_TRACK) {
    if (control.orientation == 'V') {
      drawVerticalTrackBar(control.id, control.x, control.y, control.w, control.h,
                           control.value, control.maximum, control.track, control.thumb, control.element);
    } else {
      drawTrackBar(control.id, control.x, control.y, control.w, control.h,
                   control.value, control.maximum, control.track, control.thumb, control.element);
    }
  } else {
    drawSwitch(control.id, control.x, control.y, control.w, control.h,
               control.value, control.outline, control.thumb, control.track, control.element,
               control.lineWidth);
  }
}

void updatePressedTouchControl(uint16_t x, uint16_t y, const char *eventName)
{
  if (pressedTouchControlIndex < 0 ||
      pressedTouchControlIndex >= static_cast<int>(uiTouchControlCount)) {
    return;
  }

  UiTouchControl &control = uiTouchControls[pressedTouchControlIndex];
  int newValue = touchValueForControl(control, x, y);
  if (control.kind == UI_TOUCH_TRACK) {
    if (newValue != control.value || strcmp(eventName, "DOWN") == 0) {
      int oldValue = control.value;
      control.value = newValue;
      updateSceneControlValue(touchControlKindName(control), control.id, newValue);
      drawTrackBarDirty(control, oldValue, newValue);
      emitTouchControlEvent(pressedTouchControlIndex, eventName, x, y);
    }
  }
}

void updateTouchButtons()
{
  static uint32_t lastPoll = 0;
  uint32_t now = millis();
  if (now - lastPoll < TOUCH_POLL_INTERVAL_MS) {
    return;
  }
  lastPoll = now;

  uint16_t x;
  uint16_t y;
  if (!readTouchPoint(x, y)) {
    if (pressedButtonIndex >= 0) {
      drawButtonPressedState(pressedButtonIndex, false);
      emitButtonEvent(pressedButtonIndex, "UP", lastTouchX, lastTouchY);
      if (currentTouchButtonIndex == pressedButtonIndex) {
        emitButtonEvent(pressedButtonIndex, "CLICK", lastTouchX, lastTouchY);
      }
    }
    if (pressedTouchControlIndex >= 0) {
      if (pressedTouchControlIndex < static_cast<int>(uiTouchControlCount) &&
          currentTouchControlIndex == pressedTouchControlIndex &&
          uiTouchControls[pressedTouchControlIndex].kind == UI_TOUCH_SWITCH) {
        uiTouchControls[pressedTouchControlIndex].value =
          uiTouchControls[pressedTouchControlIndex].value == 0 ? 1 : 0;
        updateSceneControlValue(touchControlKindName(uiTouchControls[pressedTouchControlIndex]),
                                uiTouchControls[pressedTouchControlIndex].id,
                                uiTouchControls[pressedTouchControlIndex].value);
        redrawTouchControl(pressedTouchControlIndex);
        emitTouchControlEvent(pressedTouchControlIndex, "CHANGE", lastTouchX, lastTouchY);
      }
      emitTouchControlEvent(pressedTouchControlIndex, "UP", lastTouchX, lastTouchY);
      if (currentTouchControlIndex == pressedTouchControlIndex) {
        emitTouchControlEvent(pressedTouchControlIndex, "CLICK", lastTouchX, lastTouchY);
      }
    }
    pressedButtonIndex = -1;
    currentTouchButtonIndex = -1;
    pressedTouchControlIndex = -1;
    currentTouchControlIndex = -1;
    return;
  }

  lastTouchX = x;
  lastTouchY = y;
  currentTouchButtonIndex = findTouchedButton(x, y);
  currentTouchControlIndex = currentTouchButtonIndex < 0 ? findTouchedControl(x, y) : -1;

  if (pressedButtonIndex < 0 && currentTouchButtonIndex >= 0) {
    pressedButtonIndex = currentTouchButtonIndex;
    drawButtonPressedState(pressedButtonIndex, true);
    emitButtonEvent(pressedButtonIndex, "DOWN", x, y);
    return;
  }

  if (pressedTouchControlIndex < 0 && currentTouchControlIndex >= 0) {
    pressedTouchControlIndex = currentTouchControlIndex;
    emitTouchControlEvent(pressedTouchControlIndex, "DOWN", x, y);
    updatePressedTouchControl(x, y, "CHANGE");
    return;
  }

  if (pressedTouchControlIndex >= 0) {
    updatePressedTouchControl(x, y, "CHANGE");
  }
}

void drawStartupScreen()
{
  setBacklight(true);
  resetScene();
  currentScreenColor = TFT_BLACK;
  tft.fillScreen(TFT_BLACK);
}

bool processCommand(char *line, Print &reply)
{
  char original[COMMAND_BUFFER_SIZE];
  strlcpy(original, line, sizeof(original));

  char *command = strtok(line, "|");
  if (command == nullptr) {
    return false;
  }

  for (char *p = command; *p != '\0'; ++p) {
    *p = static_cast<char>(toupper(static_cast<unsigned char>(*p)));
  }

  uint16_t scriptColor = 0;
  if (parseColorLiteral(command, scriptColor)) {
    fillScreenFromScriptColor(scriptColor);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "?") == 0) {
    sendReady(reply);
    return true;
  }

  if (strcmp(command, "HELP") == 0) {
    printHelp(reply);
    return true;
  }

  if (strcmp(command, "RESET") == 0) {
    reply.println("OK|RESET");
    resetRequested = true;
    resetAtMs = millis() + 200;
    return true;
  }

  if (strcmp(command, "SS") == 0) {
    printSceneSnapshot(reply);
    return true;
  }

  if (strcmp(command, "SHOWIP") == 0) {
    reply.print("IP|");
    reply.print(WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "0.0.0.0");
    reply.print("|SSID|");
    reply.print(WiFi.status() == WL_CONNECTED ? WiFi.SSID() : "");
    reply.print("|PORT|");
    reply.print(GUI_UDP_PORT);
    reply.print("|HOST|");
    reply.println(OTA_HOSTNAME);
    return true;
  }

  if (strcmp(command, "TF") == 0) {
    drawFontTest();
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "FL") == 0) {
    return listSdFonts(reply);
  }

  if (strcmp(command, "SD") == 0) {
    printSdStatus(reply);
    return sdReady;
  }

  if (strcmp(command, "LS") == 0) {
    char *path = strtok(nullptr, "|");
    bool ok = listSdDirectory(path, reply);
    if (ok) {
      sendAck(reply, original, true);
    }
    return ok;
  }

  if (strcmp(command, "FS") == 0) {
    char *path = strtok(nullptr, "|");
    return printSdFileSize(path, reply);
  }

  if (strcmp(command, "FI") == 0) {
    char *path = strtok(nullptr, "|");
    return printSdFileInfo(path, reply);
  }

  if (strcmp(command, "RM") == 0) {
    char *path = strtok(nullptr, "|");
    return deleteSdFile(path, reply);
  }


  if (strcmp(command, "SL") == 0) {
    char *path = strtok(nullptr, "|");
    return listSdScripts(path, reply);
  }

  if (strcmp(command, "DL") == 0) {
    return listSdDirectories(reply);
  }

  if (strcmp(command, "FR") == 0) {
    char *path = strtok(nullptr, "|");
    char *offsetText = strtok(nullptr, "|");
    char *sizeText = strtok(nullptr, "|");
    size_t offset = offsetText ? static_cast<size_t>(strtoul(offsetText, nullptr, 10)) : 0;
    size_t requestedSize = sizeText ? static_cast<size_t>(strtoul(sizeText, nullptr, 10)) : 64;
    return readSdFileChunk(path, offset, requestedSize, reply);
  }
  if (strcmp(command, "JPG") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    char *path = strtok(nullptr, "|");
    char *scaleText = strtok(nullptr, "|");
    int srcX = parseIntField(strtok(nullptr, "|"), 0);
    int srcY = parseIntField(strtok(nullptr, "|"), 0);
    int srcW = parseIntField(strtok(nullptr, "|"), 0);
    int srcH = parseIntField(strtok(nullptr, "|"), 0);
    bool ok = drawSdJpeg(id, x, y, path, scaleText, srcX, srcY, srcW, srcH, reply);
    if (ok) {
      storeSceneLine("JPG", id, original);
      sendAck(reply, original, true);
    }
    return ok;
  }

  if (strcmp(command, "FW") == 0) {
    char *path = strtok(nullptr, "|");
    char *sizeText = strtok(nullptr, "|");
    size_t expectedSize = sizeText ? static_cast<size_t>(strtoul(sizeText, nullptr, 10)) : 0;
    return beginSdUpload(path, expectedSize, reply);
  }

  if (strcmp(command, "FD") == 0) {
    char *hexData = strtok(nullptr, "|");
    return writeSdUploadHex(hexData, reply);
  }

  if (strcmp(command, "FDO") == 0) {
    char *offsetText = strtok(nullptr, "|");
    char *hexData = strtok(nullptr, "|");
    size_t expectedOffset = offsetText ? static_cast<size_t>(strtoul(offsetText, nullptr, 10)) : 0;
    return writeSdUploadHexAt(expectedOffset, hexData, reply);
  }

  if (strcmp(command, "FE") == 0) {
    return endSdUpload(reply);
  }

  if (strcmp(command, "SC") == 0) {
    char *path = strtok(nullptr, "|");
    return runSdScript(path, reply);
  }

  if (strcmp(command, "CL") == 0) {
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    fillScreenFromScriptColor(color);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "BL") == 0) {
    int enabled = parseIntField(strtok(nullptr, "|"), 1);
    setBacklight(enabled != 0);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "IV") == 0) {
    int enabled = parseIntField(strtok(nullptr, "|"), 1);
    tft.invertDisplay(enabled != 0);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "BX") == 0 || strcmp(command, "RR") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    uint16_t outline = parseColor(strtok(nullptr, "|"), fill);
    int radius = parseIntField(strtok(nullptr, "|"), 0);
    int lineWidth = parseIntField(strtok(nullptr, "|"), 1);
    drawBox(id, x, y, w, h, fill, outline, radius, lineWidth);
    storeSceneLine(command, id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "BT") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    char *label = strtok(nullptr, "|");
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_BLUE);
    uint16_t outline = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t text = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    int lineWidth = parseIntField(strtok(nullptr, "|"), 1);
    int font = parseIntField(strtok(nullptr, "|"), 2);
    char hAlign = parseHorizontalAlign(strtok(nullptr, "|"), 'C');
    char vAlign = parseVerticalAlign(strtok(nullptr, "|"), 'C');
    drawButton(id, x, y, w, h, label ? label : "", fill, outline, text,
               lineWidth, font, hAlign, vAlign);
    storeSceneLine("BT", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "TW") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    char *title = strtok(nullptr, "|");
    char *text = strtok(nullptr, "|");
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_DARKGREY);
    uint16_t outline = parseColor(strtok(nullptr, "|"), TFT_NAVY);
    drawTextWindow(id, x, y, w, h, title ? title : "", text ? text : "", fill, outline);
    storeSceneLine("TW", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "SB") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    char orientation = h >= w ? 'V' : 'H';
    char *orientationField = strtok(nullptr, "|");
    orientation = orientationField && orientationField[0] ? orientationField[0] : orientation;
    int value = parseIntField(strtok(nullptr, "|"));
    int maximum = parseIntField(strtok(nullptr, "|"), 100);
    uint16_t track = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    uint16_t thumb = parseColor(strtok(nullptr, "|"), TFT_CYAN);
    uint16_t element = parseColor(strtok(nullptr, "|"), lightenRgb565(thumb, 45));
    drawScrollBar(id, x, y, w, h, orientation, value, maximum, track, thumb, element);
    storeSceneLine("SB", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "TR") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int value = parseIntField(strtok(nullptr, "|"));
    int maximum = parseIntField(strtok(nullptr, "|"), 100);
    uint16_t track = parseColor(strtok(nullptr, "|"), TFT_DARKGREY);
    uint16_t thumb = parseColor(strtok(nullptr, "|"), TFT_YELLOW);
    uint16_t element = parseColor(strtok(nullptr, "|"), lightenRgb565(thumb, 45));
    drawTrackBar(id, x, y, w, h, value, maximum, track, thumb, element);
    storeSceneLine("TR", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "VT") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int value = parseIntField(strtok(nullptr, "|"));
    int maximum = parseIntField(strtok(nullptr, "|"), 100);
    uint16_t track = parseColor(strtok(nullptr, "|"), TFT_DARKGREY);
    uint16_t thumb = parseColor(strtok(nullptr, "|"), TFT_YELLOW);
    uint16_t element = parseColor(strtok(nullptr, "|"), lightenRgb565(thumb, 45));
    drawVerticalTrackBar(id, x, y, w, h, value, maximum, track, thumb, element);
    storeSceneLine("VT", id, original);
    sendAck(reply, original, true);
    return true;
  }
  if (strcmp(command, "PB") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int percent = parseIntField(strtok(nullptr, "|"));
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_GREEN);
    uint16_t background = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t outline = parseColor(strtok(nullptr, "|"), TFT_YELLOW);
    drawProgressBar(id, x, y, w, h, percent, fill, background, outline);
    storeSceneLine("PB", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "VP") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int percent = parseIntField(strtok(nullptr, "|"));
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_GREEN);
    uint16_t background = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t outline = parseColor(strtok(nullptr, "|"), TFT_YELLOW);
    drawVerticalProgressBar(id, x, y, w, h, percent, fill, background, outline);
    storeSceneLine("VP", id, original);
    sendAck(reply, original, true);
    return true;
  }
  if (strcmp(command, "CC") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int d = parseIntField(strtok(nullptr, "|"), 24);
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t outline = parseColor(strtok(nullptr, "|"), fill);
    int lineWidth = parseIntField(strtok(nullptr, "|"), 1);
    drawCircleComponent(id, x, y, d, fill, outline, lineWidth);
    storeSceneLine("CC", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "SW") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int state = parseIntField(strtok(nullptr, "|"));
        char *strokeText = strtok(nullptr, "|");
    char *thumbText = strtok(nullptr, "|");
    char *fillText = strtok(nullptr, "|");
    char *elementText = strtok(nullptr, "|");
    char *lineText = strtok(nullptr, "|");
    uint16_t outline = parseColor(strokeText, TFT_DARKGREY);
    uint16_t thumb = parseColor(thumbText, TFT_GREEN);
    uint16_t track;
    uint16_t element;
    int lineWidth;
    if (lineText != nullptr) {
      track = parseColor(fillText, TFT_DARKGREY);
      element = parseColor(elementText, lightenRgb565(thumb, 45));
      lineWidth = parseIntField(lineText, 1);
    } else {
      track = outline;
      element = parseColor(fillText, lightenRgb565(thumb, 45));
      lineWidth = 1;
    }
    drawSwitch(id, x, y, w, h, state, outline, thumb, track, element, lineWidth);
    storeSceneLine("SW", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "TX") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    char *text = strtok(nullptr, "|");
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t background = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    int font = parseIntField(strtok(nullptr, "|"), 2);
    int w = parseIntField(strtok(nullptr, "|"), 0);
    int h = parseIntField(strtok(nullptr, "|"), 0);
    char hAlign = parseHorizontalAlign(strtok(nullptr, "|"), w > 0 ? 'C' : 'L');
    char vAlign = parseVerticalAlign(strtok(nullptr, "|"), h > 0 ? 'C' : 'T');
    drawTextLabel(id, x, y, w, h, text ? text : "", color, background, font, hAlign, vAlign);
    storeSceneLine("TX", id, original);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "BM") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    char *name = strtok(nullptr, "|");
    uint16_t foreground = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t background = parseColor(strtok(nullptr, "|"), COLOR_TRANSPARENT);
    int scale = parseIntField(strtok(nullptr, "|"), 2);
    drawMonoBitmapAsset(id, x, y, name ? name : "", foreground, background, scale);
    storeSceneLine("BM", id, original);
    sendAck(reply, original, true);
    return true;
  }

  sendAck(reply, original, false);
  return false;
}

void readCommandStream(Stream &stream, char *buffer, size_t &length)
{
  while (stream.available()) {
    char c = static_cast<char>(stream.read());

    if (c == '\r') {
      continue;
    }

    if (c == '\n') {
      buffer[length] = '\0';
      if (length > 0) {
        processCommand(buffer, stream);
      }
      length = 0;
      continue;
    }

    if (length < COMMAND_BUFFER_SIZE - 1) {
      buffer[length++] = c;
    } else {
      length = 0;
      stream.println("ERR|buffer_overflow");
    }
  }
}

void readUdpCommands()
{
  if (!udpReady) {
    return;
  }

  int packetSize = GuiUdp.parsePacket();
  if (packetSize <= 0) {
    return;
  }

  int readCount = GuiUdp.read(udpCommand, sizeof(udpCommand) - 1);
  if (readCount <= 0) {
    return;
  }
  udpCommand[readCount] = '\0';
  udpEventPeerIp = GuiUdp.remoteIP();
  udpEventPeerPort = GuiUdp.remotePort();
  udpEventPeerReady = true;

  char *line = udpCommand;
  while (*line != '\0' && isspace(static_cast<unsigned char>(*line))) {
    ++line;
  }
  char *end = line + strlen(line);
  while (end > line && isspace(static_cast<unsigned char>(*(end - 1)))) {
    --end;
  }
  *end = '\0';
  if (*line == '\0') {
    return;
  }

  GuiUdp.beginPacket(GuiUdp.remoteIP(), GuiUdp.remotePort());
  processCommand(line, GuiUdp);
  GuiUdp.endPacket();
}

void setup()
{
  Serial.begin(115200);
  UiSerial.begin(UI_UART_BAUD, SERIAL_8N1, UI_UART_RX, UI_UART_TX);
  delay(200);
  Serial.println();
  Serial.println("Starting ESP32 GUI command renderer");
  Serial.printf("UART2 RX=%u TX=%u baud=%lu\n", UI_UART_RX, UI_UART_TX, UI_UART_BAUD);

  pinMode(HEARTBEAT_LED_PIN, OUTPUT);
  digitalWrite(HEARTBEAT_LED_PIN, LOW);
  pinMode(TOUCH_IRQ_PIN, INPUT);
  pinMode(TOUCH_CS, OUTPUT);
  digitalWrite(TOUCH_CS, HIGH);
  pinMode(SD_CS_PIN, OUTPUT);
  digitalWrite(SD_CS_PIN, HIGH);
  pinMode(TFT_CS, OUTPUT);
  digitalWrite(TFT_CS, HIGH);
  pinMode(TFT_MISO, INPUT_PULLUP);
  SPI.begin(TFT_SCLK, TFT_MISO, TFT_MOSI, TFT_CS);

  if (BACKLIGHT_PIN != 255) {
    pinMode(BACKLIGHT_PIN, OUTPUT);
    blinkBacklightAtBoot();
  }

  sdReady = SD.begin(SD_CS_PIN, SPI, SD_SPI_FREQUENCY) && SD.cardType() != CARD_NONE;
  printSdStatus(Serial);

  tft.init();
  tft.setRotation(3);
  tft.invertDisplay(DISPLAY_INVERTED);
  TJpgDec.setSwapBytes(true);
  TJpgDec.setCallback(jpegOutput);
  setBacklight(true);
  drawStartupScreen();
  loadStartupConfig();
  startOta();
  runStartupScreenScript();

  Serial.println("Commands: ?, HELP, SHOWIP, RESET, SS, TF, FL, SD, LS|path, FS|path, FI|path, RM|path, SL, FR|path|offset|len, FW|path|size, FD|hex, FDO|offset|hex, FE, SC|path, JPG|id|x|y|path|scale|srcX|srcY|srcW|srcH, IV|1, BL|1, CL|color, BT|id|x|y|w|h|label|fill|outline|text|line|font|H|V, BX|id|x|y|w|h|fill|outline|radius|line, RR|id|x|y|w|h|fill|outline|radius|line, TX|id|x|y|text|color|bg|font|w|h|H|V, TW|id|x|y|w|h|title|text|fill|outline, TR|id|x|y|w|h|value|max|track|thumb|element, VT|id|x|y|w|h|value|max|track|thumb|element, PB|id|x|y|w|h|percent|fill|background|outline, VP|id|x|y|w|h|percent|fill|background|outline, CC|id|x|y|diameter|fill|outline|line, SW|id|x|y|w|h|0/1|stroke|thumb|fill|element|line, SB|id|x|y|w|h|H/V|value|max|track|thumb|element, BM|id|x|y|name|fg|bg|scale");
  sendReady(Serial);
  sendReady(UiSerial);
}

void loop()
{
  setBacklight(true);
  updateHeartbeat();
  if (otaReady) {
    ArduinoOTA.handle();
    if (otaInProgress) {
      delay(1);
      return;
    }
  }
  if (resetRequested && static_cast<int32_t>(millis() - resetAtMs) >= 0) {
    Serial.println("RESET now");
    Serial.flush();
    UiSerial.println("RESET now");
    UiSerial.flush();
    delay(20);
    ESP.restart();
  }
  updateTouchButtons();
  readCommandStream(Serial, usbCommand, usbCommandLength);
  readCommandStream(UiSerial, uartCommand, uartCommandLength);
  readUdpCommands();
}
