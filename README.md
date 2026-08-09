# NXT_Display

PlatformIO project for an ESP32 used as a smart display controller for an SPI ILI9488 screen.

The idea is similar to Nextion HMI modules: the main device sends short commands over a data line, and the ESP32 draws GUI elements locally. This keeps the external protocol compact while buttons, windows, scroll bars, labels, and other widgets are rendered by the ESP32.

## Hardware

### Display module

![4 inch ILI9488 touch display](pictures/4INCH_ILI9488+Touch.jpeg)

Common red 4.0 inch SPI ILI9488 board with resistive touch and a microSD socket.

### ESP32 board

![ESP32 DevKit v1](pictures/esp32devKit1.png)

Target board: ESP32 DevKit v1 / `esp32dev`.

## Default wiring

### ILI9488 display

This pinout is for the common red 4.0 inch ILI9488 SPI board with resistive touch.

| Board label | ESP32 pin |
| --- | --- |
| CS | GPIO5 |
| RST | GPIO4 |
| D/C | GPIO21 |
| SDI | GPIO23 |
| SCK | GPIO18 |
| BL | GPIO32 |
| SDO | leave disconnected |
| VDD | 3.3V |
| GND | GND |

If your display uses other pins, edit `include/User_Setup.h`.

GPIO2 is reserved for the onboard blue heartbeat LED on ESP32 DevKit v1.

### Resistive touch

| Board label | ESP32 pin |
| --- | --- |
| TCK | GPIO18 |
| TCS | GPIO22 |
| TDI | GPIO23 |
| TDO | GPIO19 |
| PEN | GPIO34 |

The display `SDO` pin can block the shared MISO line on this red board. Leave display `SDO` disconnected and connect only touch `TDO` to `GPIO19`.

### microSD

The microSD socket shares the SPI clock and data lines with the display and touch controller. Each device has its own chip-select line.

| Board label | ESP32 pin | Shared with |
| --- | --- | --- |
| SCK | GPIO18 | TFT + touch |
| MISO | GPIO19 | Touch |
| MOSI | GPIO23 | TFT + touch |
| CS | GPIO27 | Dedicated microSD CS |
| GND | GND | — |
| VCC | 3.3V | — |

Current chip-select lines: TFT `GPIO5`, touch `GPIO22`, microSD `GPIO27`.

### GUI command UART

| Signal | ESP32 pin |
| --- | --- |
| UART2 RX | GPIO16 |
| UART2 TX | GPIO17 |
| GND | GND |

Default baud rate: `115200`.

USB Serial also accepts the same commands, which is convenient for testing from the PlatformIO monitor.

## Command protocol

Each command is one text line ending with `\n`. Fields are separated by `|`.

Colors are RGB565 values. You can send decimal values or hex values such as `0x001F`.

| Command | Meaning |
| --- | --- |
| `CL|color` | Clear screen |
| `BT|id|x|y|w|h|label|fill|outline|text` | Draw button |
| `TW|id|x|y|w|h|title|text|fill|outline` | Draw text window |
| `SB|id|x|y|w|h|H/V|value|max|track|thumb` | Draw scroll bar |
| `TX|id|x|y|text|color|background|font` | Draw text label |
| `BM|id|x|y|name|foreground|background|scale` | Draw built-in bitmap |
| `JPG|id|x|y|path|scale` | Draw a JPEG file from microSD; scale is 1, 2, 4, or 8 |
| `SD` | Show microSD status and capacity |
| `LS|path` | List files in a microSD directory |
| `BL|1` / `BL|0` | Backlight on/off |
| `IV|1` / `IV|0` | Display inversion on/off |

The older one-letter commands `C`, `B`, `W`, `S`, `T`, `L`, and `I` are still accepted for compatibility.

Built-in bitmap names:

| Name | Meaning |
| --- | --- |
| `play` | Play icon |
| `stop` | Stop icon |
| `wifi` | Wi-Fi icon |

Use background color `0x0001` to keep bitmap or text background transparent.

The startup demo is stored as command strings in firmware and is executed through the same parser as USB Serial and UART2 input. This keeps the built-in demo behavior aligned with the external protocol.

Examples:

```text
CL|0x0000
BT|1|40|80|120|42|START|0x0400|0x07E0|0xFFFF
TW|1|20|150|280|120|Status|System ready|0x4208|0x001F
SB|1|300|150|12|120|V|50|100|0x0000|0x07FF
TX|1|30|300|Hello ESP32|0xFFE0|0x0000|4
BM|1|30|30|wifi|0x07FF|0x0001|2
JPG|2|80|40|/icons/play.jpg|1
```

Store JPEG assets in a directory such as `/icons` on the microSD card. Baseline JPEG files are the safest choice; progressive JPEG is not supported by the decoder. The image is drawn at its native size divided by the selected scale, with `x` and `y` specifying its top-left corner.

## Build and upload

```powershell
C:\Users\basachka\.platformio\penv\Scripts\pio.exe run
C:\Users\basachka\.platformio\penv\Scripts\pio.exe run -t upload
```
# OTA updates

1. Copy `include/ota_secrets.example.h` to `include/ota_secrets.h` and enter the Wi-Fi credentials and an OTA password. The local secrets file is ignored by Git.
2. Upload the firmware once over USB with the `esp32dev` environment.
3. Confirm in the serial monitor that `OTA ready: nxt-display.local` is printed.
4. Upload subsequent builds with the `esp32dev_ota` environment.

If `OTA_PASSWORD` is not empty, the OTA upload script reads it from the ignored `include/ota_secrets.h` file automatically.
