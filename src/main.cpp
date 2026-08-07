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

HardwareSerial UiSerial(2);
char usbCommand[COMMAND_BUFFER_SIZE];
char uartCommand[COMMAND_BUFFER_SIZE];
size_t usbCommandLength = 0;
size_t uartCommandLength = 0;

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
  maximum = max(maximum, 1);
  value = constrain(value, 0, maximum);

  tft.fillRoundRect(x, y, w, h, 4, track);
  tft.drawRoundRect(x, y, w, h, 4, TFT_DARKGREY);

  if (h >= w) {
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

void drawTextLabel(int id, int x, int y, const char *text, uint16_t color, uint16_t background, int font)
{
  tft.setTextDatum(TL_DATUM);
  tft.setTextColor(color, background);
  tft.drawString(text, x, y, font);

  Serial.printf("GUI text %d rendered\n", id);
}

void drawTouchPanel()
{
  tft.fillRoundRect(36, 286, 372, 26, 5, TFT_BLACK);
  tft.drawRoundRect(36, 286, 372, 26, 5, TFT_DARKGREY);
  tft.setTextDatum(MC_DATUM);
  tft.setTextColor(TFT_ORANGE, TFT_BLACK);
  tft.drawString("Touch test: press screen", 222, 299, 2);
}

uint16_t readXpt2046Raw(uint8_t command)
{
  digitalWrite(TFT_CS, HIGH);
  digitalWrite(TOUCH_CS, LOW);
  delayMicroseconds(5);
  SPI.beginTransaction(SPISettings(SPI_TOUCH_FREQUENCY, MSBFIRST, SPI_MODE0));
  SPI.transfer(command);
  uint16_t hi = SPI.transfer(0x00);
  uint16_t lo = SPI.transfer(0x00);
  SPI.endTransaction();
  delayMicroseconds(5);
  digitalWrite(TOUCH_CS, HIGH);

  uint16_t value = (hi << 8) | lo;
  return (value >> 3) & 0x0FFF;
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

void drawStartupScreen()
{
  setBacklight(true);
  tft.fillScreen(TFT_BLACK);
  tft.setTextDatum(MC_DATUM);

  tft.fillRoundRect(18, 16, 444, 64, 8, TFT_NAVY);
  tft.drawRoundRect(18, 16, 444, 64, 8, TFT_CYAN);
  tft.setTextColor(TFT_WHITE, TFT_NAVY);
  tft.drawString("ESP32 GUI DISPLAY", 240, 40, 4);
  tft.drawString("UART command renderer", 240, 66, 2);

  drawButton(1, 44, 110, 132, 48, "START", TFT_DARKGREEN, TFT_GREEN, TFT_WHITE);
  drawButton(2, 196, 110, 132, 48, "STOP", TFT_MAROON, TFT_RED, TFT_WHITE);
  drawButton(3, 348, 110, 88, 48, "OK", TFT_BLUE, TFT_CYAN, TFT_WHITE);
  drawTextWindow(1, 36, 186, 372, 92, "Status", "Ready for GUI commands over USB Serial or UART2.", TFT_DARKGREY, TFT_NAVY);
  drawScrollBar(1, 424, 186, 14, 92, 35, 100, TFT_BLACK, TFT_CYAN);

  drawTouchPanel();
}

bool processCommand(char *line, Stream &reply)
{
  char original[COMMAND_BUFFER_SIZE];
  strlcpy(original, line, sizeof(original));

  char *command = strtok(line, "|");
  if (command == nullptr) {
    return false;
  }

  if (strcmp(command, "C") == 0) {
    uint16_t color = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    tft.fillScreen(color);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "L") == 0) {
    int enabled = parseIntField(strtok(nullptr, "|"), 1);
    setBacklight(enabled != 0);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "I") == 0) {
    int enabled = parseIntField(strtok(nullptr, "|"), 1);
    tft.invertDisplay(enabled != 0);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "B") == 0) {
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

  if (strcmp(command, "W") == 0) {
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

  if (strcmp(command, "S") == 0) {
    int id = parseIntField(strtok(nullptr, "|"));
    int x = parseIntField(strtok(nullptr, "|"));
    int y = parseIntField(strtok(nullptr, "|"));
    int w = parseIntField(strtok(nullptr, "|"));
    int h = parseIntField(strtok(nullptr, "|"));
    int value = parseIntField(strtok(nullptr, "|"));
    int maximum = parseIntField(strtok(nullptr, "|"), 100);
    uint16_t track = parseColor(strtok(nullptr, "|"), TFT_BLACK);
    uint16_t thumb = parseColor(strtok(nullptr, "|"), TFT_CYAN);
    drawScrollBar(id, x, y, w, h, value, maximum, track, thumb);
    sendAck(reply, original, true);
    return true;
  }

  if (strcmp(command, "T") == 0) {
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

void updateTouchTest()
{
  static uint32_t lastTouchPrint = 0;
  static uint32_t lastIdlePrint = 0;
  static uint16_t lastX = 0;
  static uint16_t lastY = 0;
  static bool hadTouch = false;

  uint16_t rawX = 0;
  uint16_t rawY = 0;
  uint16_t x = 0;
  uint16_t y = 0;
  uint16_t z = tft.getTouchRawZ();
  int misoIdle = digitalRead(TFT_MISO);
  uint16_t directX = readXpt2046Raw(0xD0);
  uint16_t directY = readXpt2046Raw(0x90);
  uint16_t directZ1 = readXpt2046Raw(0xB0);
  uint16_t directZ2 = readXpt2046Raw(0xC0);
  int misoAfter = digitalRead(TFT_MISO);
  bool touched = tft.getTouch(&x, &y, TOUCH_THRESHOLD);
  tft.getTouchRaw(&rawX, &rawY);

  if (millis() - lastIdlePrint > 1000) {
    lastIdlePrint = millis();
    Serial.printf("TOUCH_RAW rawX=%u rawY=%u z=%u irq=%d touched=%d directX=%u directY=%u z1=%u z2=%u miso=%d/%d\n",
                  rawX, rawY, z, digitalRead(TOUCH_IRQ_PIN), touched ? 1 : 0, directX, directY, directZ1, directZ2, misoIdle, misoAfter);
  }

  if (!touched) {
    if (hadTouch) {
      drawTouchPanel();
      hadTouch = false;
    }
    if (z > 50 && millis() - lastTouchPrint > 120) {
      lastTouchPrint = millis();
      tft.fillRoundRect(36, 286, 372, 26, 5, TFT_BLACK);
      tft.drawRoundRect(36, 286, 372, 26, 5, TFT_ORANGE);
      tft.setTextDatum(MC_DATUM);
      tft.setTextColor(TFT_ORANGE, TFT_BLACK);
      tft.drawString("raw=" + String(rawX) + "," + String(rawY) + " z=" + String(z) + " no calib", 222, 299, 2);
      Serial.printf("TOUCH_RAW_ACTIVE rawX=%u rawY=%u z=%u irq=%d directX=%u directY=%u z1=%u z2=%u miso=%d/%d\n",
                    rawX, rawY, z, digitalRead(TOUCH_IRQ_PIN), directX, directY, directZ1, directZ2, misoIdle, misoAfter);
    }
    return;
  }

  hadTouch = true;
  x = constrain(x, 0, tft.width() - 1);
  y = constrain(y, 0, tft.height() - 1);
  if (TOUCH_INVERT_X) {
    x = tft.width() - 1 - x;
  }
  x = correctTouchX(x);

  if (abs(static_cast<int>(x) - static_cast<int>(lastX)) > 2 || abs(static_cast<int>(y) - static_cast<int>(lastY)) > 2) {
    if (lastX < tft.width() && lastY < tft.height()) {
      tft.drawCircle(lastX, lastY, 6, TFT_BLACK);
    }
    tft.drawCircle(x, y, 6, TFT_YELLOW);
    tft.drawPixel(x, y, TFT_RED);
    lastX = x;
    lastY = y;
  }

  if (millis() - lastTouchPrint > 120) {
    lastTouchPrint = millis();
    tft.fillRoundRect(36, 286, 372, 26, 5, TFT_BLACK);
    tft.drawRoundRect(36, 286, 372, 26, 5, TFT_YELLOW);
    tft.setTextDatum(MC_DATUM);
    tft.setTextColor(TFT_YELLOW, TFT_BLACK);
    tft.drawString("x=" + String(x) + " y=" + String(y) + " raw=" + String(rawX) + "," + String(rawY) + " z=" + String(z), 222, 299, 2);

    Serial.printf("TOUCH x=%u y=%u rawX=%u rawY=%u z=%u irq=%d\n", x, y, rawX, rawY, z, digitalRead(TOUCH_IRQ_PIN));
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

  Serial.println("Commands: I|1, I|0, L|1, L|0, C|color, B|id|x|y|w|h|label|fill|outline|text, W|id|x|y|w|h|title|text|fill|outline");
}

void loop()
{
  setBacklight(true);
  updateHeartbeat();
  updateTouchTest();
  readCommandStream(Serial, usbCommand, usbCommandLength);
  readCommandStream(UiSerial, uartCommand, uartCommandLength);
}
