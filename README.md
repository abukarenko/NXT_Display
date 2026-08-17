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

USB Serial accepts the same commands, which is convenient for testing from the PlatformIO monitor. When Wi-Fi is connected, GUI commands are also accepted over UDP port `4210`.

## Command protocol

Each command is one text line ending with `\n`. Fields are separated by `|`. Command names are case-insensitive.

Colors are RGB565 values. Decimal values and hexadecimal values such as `0x001F` are accepted. `0x0000` is black and `0xFFFF` is white. For GUI elements that support transparency, `0x0001` means transparent/no fill.

Most successful drawing commands reply with `OK|<original command>`. An unknown command replies with `ERR|<original command>`.

### System and diagnostics

| Command | Description | Example |
| --- | --- | --- |
| `HELP` | Print the complete command list to the requesting interface. | `HELP` |
| `?` | Connection/ready check. Replies with `ready`. | `?` |
| `SHOWIP` | Return current Wi-Fi IP, SSID, UDP port and host name. | `SHOWIP` |
| `RESET` | Reply with `OK|RESET` and restart the ESP32 after a short delay. | `RESET` |
| `SS` | Return the current scene snapshot as command lines, including current interactive control values. | `SS` |
| `TF` | Show the loaded TFT_eSPI/GFX font samples on the display. | `TF` |

`SHOWIP` reply format:

```text
IP|192.168.1.50|SSID|mywifi|PORT|4210|HOST|nxt-display
```

`SS` returns the scene between markers:

```text
OK|SS|BEGIN|3
CL|0x0000
TX|1|20|20|READY|0xFFFF|0x0000|2
SW|1|20|80|70|32|1|0x4208|0x07E0
OK|SS|END
```

### Display control

| Command | Description | Example |
| --- | --- | --- |
| `CL|color` | Clear the screen with `color` and reset the registered GUI scene. | `CL|0x0000` |
| `BL|0/1` | Backlight off/on. | `BL|1` |
| `IV|0/1` | Display inversion off/on. | `IV|1` |

### GUI drawing commands

| Command | Description | Example |
| --- | --- | --- |
| `BT|id|x|y|w|h|label|fill|outline|text|line|font|H|V` | Draw a touch button. `H=L/C/R`, `V=T/C/B`. Optional tail fields default to line `1`, font `2`, centered alignment. | `BT|1|20|20|120|50|OK|0x001F|0xFFFF|0xFFFF|2|2|C|C` |
| `BX|id|x|y|w|h|fill|outline|radius|line` | Draw a filled/outlined box. Set `fill=0x0001` for no fill. | `BX|1|10|10|120|50|0x2104|0xFFFF|0|1` |
| `RR|id|x|y|w|h|fill|outline|radius|line` | Draw a rectangle using the same renderer as `BX`; normally used with a non-zero corner radius. | `RR|1|10|10|100|40|0x0001|0xFFFF|8|2` |
| `TX|id|x|y|text|color|background|font|w|h|H|V` | Draw a text label. `background=0x0001` gives transparent text background. If `w/h` are supplied, alignment can be selected with `H` and `V`. | `TX|1|20|90|Hello|0xFFFF|0x0001|2|120|30|C|C` |
| `TW|id|x|y|w|h|title|text|fill|outline` | Draw a text window with title and body. `fill=0x0001` makes the body transparent. | `TW|1|20|140|280|120|Status|System ready|0x4208|0x001F` |
| `SB|id|x|y|w|h|H/V|value|max|track|thumb` | Draw a horizontal or vertical scroll bar. | `SB|1|300|150|12|120|V|50|100|0x0000|0x07FF` |
| `TR|id|x|y|w|h|value|max|track|thumb` | Draw an interactive horizontal track bar. | `TR|1|40|220|220|28|35|100|0x4208|0xFFE0` |
| `PB|id|x|y|w|h|percent|fill|background|outline` | Draw a horizontal progress bar. | `PB|1|40|260|220|20|75|0x07E0|0x0000|0xFFFF` |
| `CC|id|x|y|diameter|fill|outline|line` | Draw a circle. Set `fill=0x0001` for outline only. | `CC|1|350|80|48|0xF800|0xFFFF|2` |
| `SW|id|x|y|w|h|0/1|track|thumb` | Draw an interactive switch. `0` = off/left, `1` = on/right. | `SW|1|350|150|70|32|1|0x4208|0x07E0` |
| `BM|id|x|y|name|foreground|background|scale` | Draw a built-in monochrome bitmap. `background=0x0001` enables transparency. | `BM|1|30|30|wifi|0x07FF|0x0001|2` |

Built-in bitmap names:

| Name | Meaning |
| --- | --- |
| `play` | Play icon |
| `stop` | Stop icon |
| `wifi` | Wi-Fi icon |

### Touch events

Buttons and interactive controls report events on USB Serial, UART2 and, after a UDP peer has sent a command, back to that UDP peer.

Button event format:

```text
EV|BT|id|DOWN|x|y
EV|BT|id|UP|x|y
EV|BT|id|CLICK|x|y
```

Example:

```text
EV|BT|1|CLICK|74|268
```

Track bar and switch event format:

```text
EV|TR|id|event|value|x|y
EV|SW|id|event|value|x|y
```

Track bars can report `DOWN`, `CHANGE`, `UP` and `CLICK`. Switches report their state change with `CHANGE` and also produce touch events.

### microSD commands

| Command | Description | Example |
| --- | --- | --- |
| `SD` | Return microSD readiness, capacity and used space. | `SD` |
| `LS|path` | List files in a microSD directory. | `LS|/` |
| `FS|path` | Return the size of one file. | `FS|/icons/play.jpg` |
| `SC|path` | Run a text command script from microSD. | `SC|/scripts/demo.nxt` |
| `JPG|id|x|y|path|scale|srcX|srcY|srcW|srcH` | Draw a JPEG from microSD. Optional source rectangle fields allow only part of the image to be rendered. | `JPG|1|20|20|/icons/play.jpg|1/2|0|0|64|64` |
| `FW|path|size` | Begin writing a file to microSD. `size` is the expected file size in bytes. | `FW|/data.bin|1024` |
| `FD|hex` | Append a block of hexadecimal byte data to the file opened by `FW`. | `FD|48656C6C6F` |
| `FDO|offset|hex` | Write hexadecimal byte data at the expected file offset. | `FDO|0|48656C6C6F` |
| `FE` | Finish/close the current microSD file upload. | `FE` |

Preferred JPEG scale values:

| Scale | Result |
| --- | --- |
| `1/4` | decode at quarter size |
| `1/2` | decode at half size |
| `1/1` | native size |
| `2/1` | 2× output zoom |
| `4/1` | 4× output zoom |

The older numeric JPEG scale values `2`, `4`, and `8` are also accepted as decoder downscale factors.

Example using the full JPEG:

```text
JPG|2|80|40|/icons/play.jpg|1/1
```

Example drawing a selected source area:

```text
JPG|3|100|60|/images/panel.jpg|1/2|40|20|160|120
```

Baseline JPEG files are the safest choice; progressive JPEG is not supported by the decoder.

### Example command sequence

```text
?
CL|0x0000
TX|1|20|20|NXT Display|0xFFFF|0x0000|4
BT|1|40|80|120|42|START|0x0400|0x07E0|0xFFFF|2|2|C|C
TR|1|40|150|220|28|50|100|0x4208|0xFFE0
SW|1|40|205|70|32|0|0x4208|0x07E0
PB|1|40|260|220|20|75|0x07E0|0x0000|0xFFFF
BM|1|330|30|wifi|0x07FF|0x0001|2
SS
```

The startup demo is stored as command strings in firmware and is executed through the same parser as USB Serial, UART2 and UDP input. This keeps the built-in demo behavior aligned with the external protocol.

## Local SD card image

The repository contains an `sd` folder that mirrors the physical microSD card.
Prepare images and scripts there on the desktop, then copy the contents of
`sd` to the root of the card.

Recommended layout:

```text
sd/icons    -> /icons
sd/images   -> /images
sd/scripts  -> /scripts
```

Scripts are plain text files with one GUI command per line. Empty lines and
lines starting with `#` are ignored. A script can be started from serial/UART:

```text
SC|/scripts/demo.nxt
```

## Build and upload

```powershell
C:\Users\basachka\.platformio\penv\Scripts\pio.exe run
C:\Users\basachka\.platformio\penv\Scripts\pio.exe run -t upload
```

# OTA updates

1. Copy `include/ota_secrets.example.h` to `include/ota_secrets.h`, enter up to three Wi-Fi profiles (`WIFI_SSID_1` through `WIFI_SSID_3`) and an OTA password. Empty profiles are skipped. The local secrets file is ignored by Git.
2. Upload the firmware once over USB with the `esp32dev` environment.
3. At startup the display shows each Wi-Fi connection attempt for up to 5 seconds. After a successful connection it shows the selected SSID and IP address. Confirm in the serial monitor that `OTA ready: nxt-display.local` is printed.
4. Upload subsequent builds with the `esp32dev_ota` environment.

If `OTA_PASSWORD` is not empty, the OTA upload script reads it from the ignored `include/ota_secrets.h` file automatically.
