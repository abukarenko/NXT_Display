#include <Arduino.h>
#include <SPI.h>
#include <TFT_eSPI.h>

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
constexpr uint16_t BITMAP_TRANSPARENT = 0x0001;

HardwareSerial UiSerial(2);
char usbCommand[COMMAND_BUFFER_SIZE];
char uartCommand[COMMAND_BUFFER_SIZE];
size_t usbCommandLength = 0;
size_t uartCommandLength = 0;

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
  "CL|0x0000",
  "TW|1|18|16|444|64|NXT Display|UART command renderer|0x0010|0x07FF",
  "TX|1|102|32|ESP32 GUI DISPLAY|0xFFFF|0x0010|4",
  "TX|2|142|60|BT TX TW SB BM demo|0xFFFF|0x0010|2",
  "BM|3|382|24|wifi|0x07FF|0x0001|2",
  "BT|1|44|110|132|48|START|0x0320|0x07E0|0xFFFF",
  "BM|1|70|118|play|0xFFFF|0x0001|2",
  "BT|2|196|110|132|48|STOP|0x7800|0xF800|0xFFFF",
  "BM|2|222|118|stop|0xFFFF|0x0001|2",
  "BT|3|348|110|88|48|OK|0x001F|0x07FF|0xFFFF",
  "TW|2|36|186|372|92|Status|Script demo executed through parser.|0x4208|0x0010",
  "SB|1|424|186|14|92|V|35|100|0x0000|0x07FF",
  "SB|2|36|284|372|14|H|70|100|0x0000|0xFD20"
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
  requestedFont = constrain(requestedFont, 1, 8);

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

void drawButton(int id, int x, int y, int w, int h, const char *label, uint16_t fill, uint16_t outline, uint16_t text)
{
  tft.fillRoundRect(x, y, w, h, 6, fill);
  tft.drawRoundRect(x, y, w, h, 6, outline);
  tft.setTextDatum(MC_DATUM);
  tft.setTextColor(text, fill);
  tft.drawString(label, x + w / 2, y + h / 2, 2);

  Serial.printf("GUI button %d rendered\n", id);
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
      if (pixelOn || background != BITMAP_TRANSPARENT) {
        tft.fillRect(x + col * scale, y + row * scale, scale, scale, color);
      }
    }
  }

  Serial.printf("GUI bitmap %d rendered asset=%s\n", id, asset->name);
}

void drawTextLabel(int id, int x, int y, const char *text, uint16_t color, uint16_t background, int font)
{
  int resolvedFont = resolveTextFont(text, font);

  tft.setTextDatum(TL_DATUM);
  tft.setTextColor(color, background);
  tft.drawString(text, x, y, resolvedFont);

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

  if (strcmp(command, "C") == 0 || strcmp(command, "CL") == 0) {
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    tft.fillScreen(color);
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
    uint16_t background = parseColor(strtok(nullptr, "|"), BITMAP_TRANSPARENT);
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

  Serial.println("Commands: IV|1, BL|1, CL|color, BT|id|x|y|w|h|label|fill|outline|text, TX|id|x|y|text|color|bg|font, TW|id|x|y|w|h|title|text|fill|outline, SB|id|x|y|w|h|H/V|value|max|track|thumb, BM|id|x|y|name|fg|bg|scale");
}

void loop()
{
  setBacklight(true);
  updateHeartbeat();
  readCommandStream(Serial, usbCommand, usbCommandLength);
  readCommandStream(UiSerial, uartCommand, uartCommandLength);
}
