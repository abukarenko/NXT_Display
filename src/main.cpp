#include <Arduino.h>
#include <ArduinoOTA.h>
#include <SPI.h>
#include <TFT_eSPI.h>
#include <WiFi.h>
#include <FontsRus/FreeSansBold18.h>

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
constexpr uint32_t UI_UART_BAUD = 115200;
constexpr size_t COMMAND_BUFFER_SIZE = 192;
constexpr uint16_t TOUCH_THRESHOLD = 250;
constexpr bool DISPLAY_INVERTED = true;
constexpr bool TOUCH_INVERT_X = true;
constexpr int16_t TOUCH_LEFT_EDGE_X_CORRECTION = 20;
constexpr int16_t TOUCH_CENTER_X_CORRECTION = 6;
constexpr int16_t TOUCH_CENTER_X_CORRECTION_RANGE = 140;
constexpr int16_t LARGE_FONT_X_CORRECTION = 3;
constexpr int16_t LARGE_FONT_Y_CORRECTION = 4;
constexpr uint16_t COLOR_TRANSPARENT = 0x0001;
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
char usbCommand[COMMAND_BUFFER_SIZE];
char uartCommand[COMMAND_BUFFER_SIZE];
size_t usbCommandLength = 0;
size_t uartCommandLength = 0;
bool otaReady = false;
bool otaInProgress = false;
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
bool processCommand(char *line, Stream &reply);

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

int parseIntField(const char *value, int fallback = 0)
{
  if (value == nullptr || value[0] == '\0') {
    return fallback;
  }

  return atoi(value);
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
  requestedFont = constrain(requestedFont, 1, 9);

  if ((requestedFont == 6 || requestedFont == 7 || requestedFont == 8) && !isNumericFontText(text)) {
    return 4;
  }

  return requestedFont;
}

void sendAck(Stream &stream, const char *command, bool ok)
{
  stream.print(ok ? "OK|" : "ERR|");
  stream.println(command);
}

void printHelp(Stream &stream)
{
  stream.println("NXT Display commands (fields are separated by |):");
  stream.println("  HELP or ?");
  stream.println("    Show this command list.");
  stream.println("  TF");
  stream.println("    Show all loaded TFT_eSPI and GFX font samples.");
  stream.println("  CL|color");
  stream.println("    Clear screen. Example: CL|0x0000");
  stream.println("  BL|0/1");
  stream.println("    Backlight off/on. Example: BL|1");
  stream.println("  IV|0/1");
  stream.println("    Display inversion off/on. Example: IV|1");
  stream.println("  BT|id|x|y|w|h|label|fill|outline|text");
  stream.println("    Draw button. Example: BT|1|20|20|120|50|OK|0x001F|0xFFFF|0xFFFF");
  stream.println("    Touch events: EV|BT|id|DOWN/UP/CLICK|x|y");
  stream.println("  BX|id|x|y|w|h|fill|outline|radius");
  stream.println("    Draw filled box. Example: BX|1|10|10|100|40|0x2104|0xFFFF|4");
  stream.println("  TX|id|x|y|text|color|background|font");
  stream.println("    Draw text. Use background 0x0001 for transparency.");
  stream.println("    Example: TX|1|20|90|Hello|0xFFFF|0x0001|2");
  stream.println("  TW|id|x|y|w|h|title|text|fill|outline");
  stream.println("    Draw text window.");
  stream.println("  SB|id|x|y|w|h|H/V|value|max|track|thumb");
  stream.println("    Draw horizontal or vertical scrollbar.");
  stream.println("  BM|id|x|y|name|foreground|background|scale");
  stream.println("    Draw bitmap. Names: play, stop, wifi.");
  stream.println("    Use background 0x0001 for transparency.");
  stream.println("Colors are RGB565 numbers, for example 0x0000 black and 0xFFFF white.");
  stream.println("Legacy aliases: C, L, I, B, W, S, T.");
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
  Serial.printf("OTA ready: %s.local, IP=%s\n", OTA_HOSTNAME, WiFi.localIP().toString().c_str());
}

void drawButton(int id, int x, int y, int w, int h, const char *label, uint16_t fill, uint16_t outline, uint16_t text)
{
  tft.fillRoundRect(x, y, w, h, 6, fill);
  tft.drawRoundRect(x, y, w, h, 6, outline);
  tft.setTextDatum(MC_DATUM);
  tft.setTextColor(text, fill);
  tft.drawString(label, x + w / 2, y + h / 2, 2);

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

void drawBox(int id, int x, int y, int w, int h, uint16_t fill, uint16_t outline, int radius)
{
  radius = constrain(radius, 0, min(w, h) / 2);
  if (radius > 0) {
    tft.fillRoundRect(x, y, w, h, radius, fill);
    tft.drawRoundRect(x, y, w, h, radius, outline);
  } else {
    tft.fillRect(x, y, w, h, fill);
    tft.drawRect(x, y, w, h, outline);
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
  tft.setFreeFont(&FreeSansBold18pt8b);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.drawString("AaBb 0123", 52, 280);
  tft.setTextFont(1);
}

void drawTextWindow(int id, int x, int y, int w, int h, const char *title, const char *text, uint16_t fill, uint16_t outline)
{
  tft.fillRoundRect(x, y, w, h, 6, fill);
  tft.drawRoundRect(x, y, w, h, 6, outline);
  tft.fillRoundRect(x + 3, y + 3, w - 6, 26, 4, outline);

  tft.setTextDatum(ML_DATUM);
  tft.setTextColor(TFT_WHITE, outline);
  tft.drawString(title, x + 10, y + 16, 2);

  tft.setTextColor(TFT_WHITE, fill);
  tft.setTextDatum(TL_DATUM);
  tft.setTextWrap(true);
  tft.drawString(text, x + 10, y + 42, 2);

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

void drawTextLabel(int id, int x, int y, const char *text, uint16_t color, uint16_t background, int font)
{
  int resolvedFont = resolveTextFont(text, font);

  if (resolvedFont == 4) {
    x += LARGE_FONT_X_CORRECTION;
    y += LARGE_FONT_Y_CORRECTION;
  }

  tft.setTextDatum(TL_DATUM);
  if (background == COLOR_TRANSPARENT) {
    tft.setTextColor(color);
  } else {
    tft.setTextColor(color, background);
  }
  if (resolvedFont == 9) {
    tft.setFreeFont(&FreeSansBold18pt8b);
    tft.drawString(text, x, y);
    tft.setTextFont(1);
  } else {
    tft.drawString(text, x, y, resolvedFont);
  }

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

bool processCommand(char *line, Stream &reply)
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

  if (strcmp(command, "HELP") == 0 || strcmp(command, "?") == 0) {
    printHelp(reply);
    return true;
  }

  if (strcmp(command, "TF") == 0) {
    drawFontTest();
    sendAck(reply, original, true);
    return true;
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

  if (strcmp(command, "BX") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    uint16_t fill = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    uint16_t outline = parseColor(strtok(nullptr, "|"), fill);
    int radius = parseIntField(strtok(nullptr, "|"), 0);
    drawBox(id, x, y, w, h, fill, outline, radius);
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
    drawButton(id, x, y, w, h, label ? label : "", fill, outline, text);
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

  if (strcmp(command, "T") == 0 || strcmp(command, "TX") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    char *text = strtok(nullptr, "|");
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_WHITE);
    uint16_t background = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    int font = parseIntField(strtok(nullptr, "|"), 2);
    drawTextLabel(id, x, y, text ? text : "", color, background, font);
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
  pinMode(TFT_CS, OUTPUT);
  digitalWrite(TFT_CS, HIGH);
  pinMode(TFT_MISO, INPUT_PULLUP);
  SPI.begin(TFT_SCLK, TFT_MISO, TFT_MOSI, TFT_CS);

  if (BACKLIGHT_PIN != 255) {
    pinMode(BACKLIGHT_PIN, OUTPUT);
    blinkBacklightAtBoot();
  }

  tft.init();
  tft.setRotation(3);
  tft.invertDisplay(DISPLAY_INVERTED);
  setBacklight(true);
  drawStartupScreen();
  setBacklight(true);
  startOta();

  Serial.println("Commands: IV|1, BL|1, CL|color, BT|id|x|y|w|h|label|fill|outline|text, TX|id|x|y|text|color|bg|font, TW|id|x|y|w|h|title|text|fill|outline, SB|id|x|y|w|h|H/V|value|max|track|thumb, BM|id|x|y|name|fg|bg|scale");
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
}
