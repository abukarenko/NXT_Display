#include <Arduino.h>
#include <ArduinoOTA.h>
#include <SD.h>
#include <SPI.h>
#include <TFT_eSPI.h>
#include <TJpg_Decoder.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include "gui_fonts.h"

#if __has_include("ota_secrets.h")
#include "ota_secrets.h"
#else
#define WIFI_SSID ""
#define WIFI_PASSWORD ""
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
constexpr uint32_t WIFI_CONNECT_TIMEOUT_MS = 15000;
constexpr uint32_t TOUCH_POLL_INTERVAL_MS = 25;
constexpr size_t MAX_UI_BUTTONS = 16;
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
  char label[BUTTON_LABEL_SIZE];
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
int pressedButtonIndex = -1;
int currentTouchButtonIndex = -1;
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

void drawScrollBar(int id, int x, int y, int w, int h, char orientation, int value, int maximum, uint16_t track, uint16_t thumb);
void drawTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb);
void drawProgressBar(int id, int x, int y, int w, int h, int percent, uint16_t fill, uint16_t background, uint16_t outline);
void drawSwitch(int id, int x, int y, int w, int h, int state, uint16_t knob, uint16_t outline, uint16_t onFill);
void drawAlignedTextBox(const char *text, int x, int y, int w, int h, uint16_t color,
                        uint16_t background, int font, char hAlign, char vAlign,
                        bool fillBackground);
bool processCommand(char *line, Print &reply);

const char *STARTUP_DEMO_SCRIPT[] = {
  "CL|0x2104",
  "TX|1|16|10|MASH3 GRBL|0xBFFF|0x2104|4",
  "BX|1|288|8|182|40|0xA965|0xFBEF|4",
  "TX|2|304|17|USB WAIT|0xFFFF|0xA965|2",
  "BX|2|10|54|225|46|0x18E3|0x0000|0",
  "BX|3|10|54|42|46|0x05FF|0x05FF|0",
  "TX|3|18|61|X|0x0000|0x05FF|9",
  "TX|4|96|60|+0.00|0xBFFF|0x18E3|4",
  "BX|4|245|54|225|46|0x18E3|0x0000|0",
  "BX|5|245|54|42|46|0x07E8|0x07E8|0",
  "TX|5|253|61|Y|0x0000|0x07E8|9",
  "TX|6|331|60|+0.00|0xBFFF|0x18E3|4",
  "BX|6|10|105|225|46|0x18E3|0x0000|0",
  "BX|7|10|105|42|46|0xF81F|0xF81F|0",
  "TX|7|18|112|Z|0x0000|0xF81F|9",
  "TX|8|96|111|+0.00|0xBFFF|0x18E3|4",
  "BX|8|245|105|225|46|0x18E3|0x0000|0",
  "BX|9|245|105|42|46|0xC600|0xC600|0",
  "TX|9|253|112|A|0x0000|0xC600|9",
  "TX|10|331|111|+0.00|0xBFFF|0x18E3|4",
  "TX|11|10|163|LIMITS|0xBFFF|0x2104|2",
  "BX|10|105|158|38|34|0x2104|0xBFFF|0",
  "TX|12|118|166|X|0xBFFF|0x2104|2",
  "BX|11|147|158|38|34|0x2104|0xBFFF|0",
  "TX|13|160|166|Y|0xBFFF|0x2104|2",
  "BX|12|189|158|38|34|0x2104|0xBFFF|0",
  "TX|14|202|166|Z|0xBFFF|0x2104|2",
  "BX|13|231|158|38|34|0x2104|0xBFFF|0",
  "TX|15|244|166|P|0xBFFF|0x2104|2",
  "TX|16|310|163|SPINDLE  0 RPM|0xFDD7|0x2104|2",
  "BX|14|55|199|185|40|0xF2B4|0x0000|0",
  "TX|17|89|205|ALARM|0x4000|0xF2B4|4",
  "BT|1|10|246|109|70|FLUID|0x21C7|0x863B|0xFFFF",
  "BT|2|127|246|109|70|SPINDLE|0x3146|0xDCD2|0xFFFF",
  "BT|3|244|246|109|70|PAUSE|0x4200|0xFE00|0xFFFF",
  "BT|4|361|246|109|70|UNLOCK|0x4000|0xF882|0xFFFF"
};

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

int resolveTextFont(const char *text, int requestedFont)
{
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
  stream.println("  TF");
  stream.println("    Show all loaded TFT_eSPI and GFX font samples.");
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
  stream.println("  TR|id|x|y|w|h|value|max|track|thumb");
  stream.println("    Draw horizontal trackbar.");
  stream.println("  PB|id|x|y|w|h|percent|fill|background|outline");
  stream.println("    Draw horizontal progress bar.");
  stream.println("  CC|id|x|y|diameter|fill|outline|line");
  stream.println("    Draw circle. Use fill 0x0001 for no fill.");
  stream.println("  SW|id|x|y|w|h|0/1|knob|outline|onfill");
  stream.println("    Draw switch. 0 is off/left, 1 is on/right.");
  stream.println("  SB|id|x|y|w|h|H/V|value|max|track|thumb");
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
  stream.println("  JPG|id|x|y|path|scale|srcX|srcY|srcW|srcH");
  stream.println("    Draw a JPEG or selected source area. Scale: 1/4, 1/2, 1/1, 2/1, 4/1.");
  stream.println("    Example: JPG|1|20|20|/icons/play.jpg|1/2|0|0|64|64");
  stream.println("  FW|path|size, FD|hex, FE");
  stream.println("    Write a file to microSD through serial.");
  stream.println("  SC|path");
  stream.println("    Run a text script from microSD. Example: SC|/scripts/demo.nxt");
  stream.println("Colors are RGB565 numbers, for example 0x0000 black and 0xFFFF white.");
  stream.println("Legacy aliases: C, L, I, B, W, S, T.");
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

    if (start[0] == '\0' || start[0] == '#') {
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

void startOta()
{
  if (WIFI_SSID[0] == '\0') {
    Serial.println("OTA disabled: configure include/ota_secrets.h");
    return;
  }

  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.setHostname(OTA_HOSTNAME);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.printf("Connecting to Wi-Fi for OTA: %s", WIFI_SSID);
  uint32_t startedAt = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startedAt < WIFI_CONNECT_TIMEOUT_MS) {
    delay(250);
    Serial.print('.');
  }
  Serial.println();

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("OTA unavailable: Wi-Fi connection timed out");
    return;
  }

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
  Serial.printf("OTA ready: %s.local, IP=%s\n", OTA_HOSTNAME, WiFi.localIP().toString().c_str());
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
  uiButtonCount = 0;
  pressedButtonIndex = -1;
  currentTouchButtonIndex = -1;

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

void drawScrollBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb)
{
  drawScrollBar(id, x, y, w, h, h >= w ? 'V' : 'H', value, maximum, track, thumb);
}

void drawScrollBar(int id, int x, int y, int w, int h, char orientation, int value, int maximum, uint16_t track, uint16_t thumb)
{
  maximum = max(maximum, 1);
  value = constrain(value, 0, maximum);

  tft.fillRoundRect(x, y, w, h, 4, track);
  tft.drawRoundRect(x, y, w, h, 4, TFT_DARKGREY);

  if (orientation == 'V' || orientation == 'v') {
    int thumbHeight = max(18, h / 5);
    int travel = max(1, h - thumbHeight - 4);
    int thumbY = y + 2 + (travel * value) / maximum;
    tft.fillRoundRect(x + 2, thumbY, w - 4, thumbHeight, 4, thumb);
  } else {
    int thumbWidth = max(18, w / 5);
    int travel = max(1, w - thumbWidth - 4);
    int thumbX = x + 2 + (travel * value) / maximum;
    tft.fillRoundRect(thumbX, y + 2, thumbWidth, h - 4, 4, thumb);
  }

  Serial.printf("GUI scroll %d rendered\n", id);
}

void drawTrackBar(int id, int x, int y, int w, int h, int value, int maximum, uint16_t track, uint16_t thumb)
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
  uint16_t filledTrack = lightenRgb565(thumb, 45);

  tft.fillRoundRect(x, trackY, w, trackHeight, radius, track);
  tft.fillRoundRect(x, trackY, max(trackHeight, knobX - x), trackHeight, radius, filledTrack);
  tft.fillCircle(knobX, knobY, knobRadius, thumb);
  tft.drawCircle(knobX, knobY, knobRadius, TFT_BLACK);

  Serial.printf("GUI track %d rendered value=%d max=%d\n", id, value, maximum);
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

void drawSwitch(int id, int x, int y, int w, int h, int state, uint16_t knob, uint16_t outline, uint16_t onFill)
{
  state = state == 0 ? 0 : 1;
  h = max(h, 8);
  w = max(w, h * 2);

  int radius = h / 2;
  int border = max(2, h / 14);
  int knobRadius = max(2, (h - border * 4) / 2);
  int knobY = y + h / 2;
  int knobX = state ? (x + w - radius) : (x + radius);

  tft.fillRoundRect(x, y, w, h, radius, state ? onFill : TFT_BLACK);
  tft.drawRoundRect(x, y, w, h, radius, outline);
  for (int i = 1; i < border; i++) {
    tft.drawRoundRect(x + i, y + i, w - i * 2, h - i * 2, max(1, radius - i), outline);
  }
  tft.fillCircle(knobX, knobY, knobRadius, knob);
  tft.drawCircle(knobX, knobY, knobRadius, TFT_BLACK);

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

void drawButtonPressedState(int buttonIndex, bool pressed)
{
  if (buttonIndex < 0 || buttonIndex >= static_cast<int>(uiButtonCount)) {
    return;
  }

  const UiButton &button = uiButtons[buttonIndex];
  uint16_t color = pressed ? TFT_WHITE : button.outline;
  tft.drawRoundRect(button.x, button.y, button.w, button.h, 6, color);
  tft.drawRoundRect(button.x + 1, button.y + 1, button.w - 2, button.h - 2, 5, color);
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

void emitButtonEvent(int buttonIndex, const char *event, uint16_t x, uint16_t y)
{
  if (buttonIndex < 0 || buttonIndex >= static_cast<int>(uiButtonCount)) {
    return;
  }

  const UiButton &button = uiButtons[buttonIndex];
  writeButtonEvent(Serial, button, event, x, y);
  writeButtonEvent(UiSerial, button, event, x, y);
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
    pressedButtonIndex = -1;
    currentTouchButtonIndex = -1;
    return;
  }

  lastTouchX = x;
  lastTouchY = y;
  currentTouchButtonIndex = findTouchedButton(x, y);

  if (pressedButtonIndex < 0 && currentTouchButtonIndex >= 0) {
    pressedButtonIndex = currentTouchButtonIndex;
    drawButtonPressedState(pressedButtonIndex, true);
    emitButtonEvent(pressedButtonIndex, "DOWN", x, y);
  }
}

void drawStartupScreen()
{
  setBacklight(true);

  for (const char *scriptLine : STARTUP_DEMO_SCRIPT) {
    char commandBuffer[COMMAND_BUFFER_SIZE];
    strlcpy(commandBuffer, scriptLine, sizeof(commandBuffer));
    processCommand(commandBuffer, Serial);
  }
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

  if (strcmp(command, "?") == 0) {
    sendReady(reply);
    return true;
  }

  if (strcmp(command, "HELP") == 0) {
    printHelp(reply);
    return true;
  }

  if (strcmp(command, "SHOWIP") == 0) {
    reply.print("IP|");
    reply.print(WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "0.0.0.0");
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

  if (strcmp(command, "C") == 0 || strcmp(command, "CL") == 0) {
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    tft.fillScreen(color);
    uiButtonCount = 0;
    pressedButtonIndex = -1;
    currentTouchButtonIndex = -1;
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "L") == 0 || strcmp(command, "BL") == 0) {
    int enabled = parseIntField(strtok(nullptr, "|"), 1);
    setBacklight(enabled != 0);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "I") == 0 || strcmp(command, "IV") == 0) {
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
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "B") == 0 || strcmp(command, "BT") == 0) {
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
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "W") == 0 || strcmp(command, "TW") == 0) {
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
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "S") == 0 || strcmp(command, "SB") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    char orientation = h >= w ? 'V' : 'H';
    if (strcmp(command, "SB") == 0) {
      char *orientationField = strtok(nullptr, "|");
      orientation = orientationField && orientationField[0] ? orientationField[0] : orientation;
    }
    int value = parseIntField(strtok(nullptr, "|"));
    int maximum = parseIntField(strtok(nullptr, "|"), 100);
    uint16_t track = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    uint16_t thumb = parseColor(strtok(nullptr, "|"), TFT_CYAN);
    drawScrollBar(id, x, y, w, h, orientation, value, maximum, track, thumb);
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
    drawTrackBar(id, x, y, w, h, value, maximum, track, thumb);
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
    uint16_t knob = parseColor(strtok(nullptr, "|"), TFT_GREEN);
    uint16_t outline = parseColor(strtok(nullptr, "|"), TFT_YELLOW);
    uint16_t onFill = parseColor(strtok(nullptr, "|"), 0x8E66);
    drawSwitch(id, x, y, w, h, state, knob, outline, onFill);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "T") == 0 || strcmp(command, "TX") == 0) {
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
  setBacklight(true);
  startOta();

  Serial.println("Commands: HELP, SD, LS|path, JPG|id|x|y|path|scale|srcX|srcY|srcW|srcH, FW|path|size, FD|hex, FE, SC|path, IV|1, BL|1, CL|color, BT|id|x|y|w|h|label|fill|outline|text|line|font|H|V, TX|id|x|y|text|color|bg|font|w|h|H|V, TW|id|x|y|w|h|title|text|fill|outline, RR|id|x|y|w|h|fill|outline|radius|line, TR|id|x|y|w|h|value|max|track|thumb, PB|id|x|y|w|h|percent|fill|background|outline, CC|id|x|y|diameter|fill|outline|line, SW|id|x|y|w|h|0/1|knob|outline|onfill, SB|id|x|y|w|h|H/V|value|max|track|thumb, BM|id|x|y|name|fg|bg|scale");
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
  updateTouchButtons();
  readCommandStream(Serial, usbCommand, usbCommandLength);
  readCommandStream(UiSerial, uartCommand, uartCommandLength);
  readUdpCommands();
}
