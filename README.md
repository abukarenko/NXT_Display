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

### GPIO summary

| GPIO | TFT | TOUCH | SD | SPK |
| --- | --- | --- | --- | --- |
| GPIO4 | RST | — | — | — |
| GPIO5 | CS | — | — | — |
| GPIO18 | SCK | TCK | SCK | — |
| GPIO19 | — | TDO | MISO | — |
| GPIO21 | D/C | — | — | — |
| GPIO22 | — | TCS | — | — |
| GPIO23 | SDI | TDI | MOSI | — |
| GPIO25 | — | — | — | Signal |
| GPIO27 | — | — | CS | — |
| GPIO32 | BL | — | — | — |
| GPIO34 | — | PEN | — | — |

`GPIO25` is reserved for an optional speaker or buzzer output. For a passive piezo buzzer, speaker or any load requiring more than a small GPIO current, use a transistor/MOSFET driver and a shared GND; do not drive a low-impedance speaker directly from the ESP32 pin. TFT `SDO` remains disconnected.

`GPIO16` and `GPIO17` remain assigned to GUI UART RX/TX, and `GPIO2` remains reserved for the onboard heartbeat LED.

Default baud rate: `115200`.

USB Serial accepts the same commands, which is convenient for testing from the PlatformIO monitor. When Wi-Fi is connected, GUI commands are also accepted over UDP port `4210`.

## Command protocol

Each command is one text line ending with `\n`. Fields are separated by `|`. Command names are case-insensitive.

Colors are RGB565 values. Decimal values and hexadecimal values such as `0x001F` are accepted. `0x0000` is black and `0xFFFF` is white. For GUI elements that support transparency, `0x0001` means transparent/no fill.

Most successful drawing commands reply with `OK|<original command>`. An unknown command replies with `ERR|<original command>`.

### Protocol parameter reference

The display runs in landscape orientation with a logical drawing area of **480 × 320 pixels**. The origin is the upper-left corner.

```text
(0,0) --------------------------> X
  |
  |
  |
  v
  Y
```

Coordinates are expressed in pixels. For normal on-screen objects:

- `x` — left edge of an object.
- `y` — top edge of an object.
- `w` — object width.
- `h` — object height.
- `diameter` — circle diameter.

Typical visible ranges are `x = 0..479` and `y = 0..319`. Width and height should normally keep the object inside the 480 × 320 drawing area. The parser does not require every object to remain fully inside the screen, so the sender should perform layout validation when necessary.

#### Object ID

Most GUI objects contain an integer `id` field:

```text
COMMAND|id|...
```

The ID identifies an object inside its command/control type. Sending the same type and the same ID again replaces its registered definition and redraws it at the new position/value.

Example:

```text
TX|5|20|20|RPM 1000|0xFFFF|0x0000|2
TX|5|20|20|RPM 1250|0xFFFF|0x0000|2
```

The second `TX|5` becomes the current scene definition for text object 5. This is important for the `SS` scene snapshot command.

For interactive controls, IDs are also included in returned touch events:

```text
EV|BT|3|CLICK|150|270
EV|TR|2|CHANGE|67|220|180
```

#### RGB565 colors

Colors use a 16-bit RGB565 value:

```text
RRRRRGGGGGGBBBBB
```

Common values:

| Color | RGB565 |
| --- | --- |
| Black | `0x0000` |
| White | `0xFFFF` |
| Red | `0xF800` |
| Green | `0x07E0` |
| Blue | `0x001F` |
| Yellow | `0xFFE0` |
| Cyan | `0x07FF` |
| Magenta | `0xF81F` |

Values may be sent in hexadecimal or decimal form:

```text
CL|0x001F
CL|31
```

Both commands select the same blue RGB565 color.

`0x0001` has a special meaning in commands that support transparency. It means **do not paint the background/fill** rather than drawing color value 1.

Examples:

```text
TX|1|20|20|Transparent text|0xFFFF|0x0001|2
BX|1|10|10|100|40|0x0001|0xFFFF|0|2
CC|1|200|100|50|0x0001|0xFFFF|2
```

#### Fonts

The `font` field uses IDs `1..9`:

| ID | Font |
| --- | --- |
| `1` | FreeSans6 |
| `2` | FreeSans8 |
| `3` | FreeSans10 |
| `4` | FreeSans12 |
| `5` | FreeMono12 |
| `6` | FreeSansBold12 |
| `7` | FreeSansBold14 |
| `8` | FreeSansBold16 |
| `9` | FreeSansBold18 |

Example:

```text
TX|1|20|20|Small|0xFFFF|0x0000|1
TX|2|20|60|Large|0xFFFF|0x0000|9
```

Use `TF` on the display to see samples of the installed fonts.

#### Text alignment

Commands `BT` and `TX` can use horizontal and vertical alignment fields.

Horizontal `H`:

| Value | Meaning |
| --- | --- |
| `L` | Left |
| `C` | Center |
| `R` | Right |

Vertical `V`:

| Value | Meaning |
| --- | --- |
| `T` | Top |
| `C` | Center |
| `B` | Bottom |

Example — centered text inside a 160 × 40 area:

```text
TX|10|20|100|CENTER|0xFFFF|0x0000|4|160|40|C|C
```

For `TX`, if `w` and `h` are omitted/zero, the supplied `x,y` act as the text origin. When a box size is supplied, alignment is applied inside that box.

#### Line width and radius

`line` controls outline thickness where supported. The current renderer constrains line width to a small practical range; values `1..4` should be used.

`radius` controls the corner radius for `BX`/`RR`:

```text
BX|1|20|20|120|50|0x001F|0xFFFF|0|1
RR|2|20|80|120|50|0x001F|0xFFFF|10|2
```

`radius=0` produces square corners. A larger value produces rounded corners.

#### Value, maximum and percent

`TR` and `SB` use `value` plus `max`:

```text
TR|1|40|100|200|28|25|100|0x4208|0xFFE0
```

Here the track bar value is 25 of 100. Values are constrained by the renderer to `0..max`; a non-positive maximum is internally replaced with a usable minimum.

`PB` uses a percentage:

```text
PB|1|40|150|200|20|75|0x07E0|0x0000|0xFFFF
```

This displays 75%.

`SW` uses a binary state:

```text
SW|1|40|200|70|32|0|0x4208|0x07E0
SW|1|40|200|70|32|1|0x4208|0x07E0
```

`0` means off/left, `1` means on/right.

#### Text fields and separator limitation

The pipe character `|` is the protocol field separator. It therefore cannot currently be embedded directly inside ordinary text fields such as `label`, `title` or `text`.

For example, use:

```text
TX|1|20|20|A / B|0xFFFF|0x0000|2
```

rather than trying to send `A|B` as one text field.

#### Command length

The firmware command buffer is currently 192 bytes including the terminating zero. Keep an individual command line comfortably below this limit, especially commands containing long text or file paths.

### Command summary

Every `Example` cell below contains a complete command that can be sent as-is. The exact field order and the meaning of every parameter are documented after the tables.

#### System and diagnostics

| Command | Description | Example | Notes |
| --- | --- | --- | --- |
| `?` | Check that the display is ready. | `?` | Replies with `ready`. |
| `HELP` | Print the firmware command list. | `HELP` | The reply is sent to the requesting interface. |
| `SHOWIP` | Read network connection details. | `SHOWIP` | Returns IP, SSID, UDP port and host name. |
| `RESET` | Restart the ESP32. | `RESET` | Replies `OK|RESET`, then restarts after a short delay. |
| `SS` | Get the registered scene snapshot. | `SS` | Returns replayable commands between `BEGIN` and `END` markers. |
| `TF` | Draw samples of all installed fonts. | `TF` | Replaces the visible screen contents but is not stored as a scene object. |

#### Display control

| Command | Description | Example | Notes |
| --- | --- | --- | --- |
| `CL` | Clear the screen with a color. | `CL|0x0000` | Also resets the registered GUI scene. |
| `BL` | Control the display backlight. | `BL|1` | `0` = off, non-zero = on. |
| `IV` | Control display color inversion. | `IV|1` | `0` = off, non-zero = on. |

#### GUI drawing

| Command | Description | Example | Notes |
| --- | --- | --- | --- |
| `BT` | Draw a touch button. | `BT|1|20|20|120|50|OK|0x001F|0xFFFF|0xFFFF|2|2|C|C` | Produces `EV|BT` touch events. |
| `BX` | Draw a box. | `BX|1|10|10|120|50|0x2104|0xFFFF|0|1` | `fill=0x0001` disables filling. |
| `RR` | Draw a rounded rectangle. | `RR|2|20|80|120|50|0x001F|0xFFFF|10|2` | Uses the same renderer as `BX`; set a non-zero radius. |
| `TX` | Draw a text label. | `TX|1|20|90|Hello|0xFFFF|0x0001|2|120|30|C|C` | `background=0x0001` is transparent. |
| `TW` | Draw a titled text window. | `TW|1|20|140|280|120|Status|System ready|0x4208|0x001F` | Title and body are separate text fields. |
| `SB` | Draw a scroll bar. | `SB|1|300|150|12|120|V|50|100|0x0000|0x07FF` | Display-only; `H` or `V` orientation. |
| `TR` | Draw an interactive track bar. | `TR|1|40|220|220|28|35|100|0x4208|0xFFE0` | Produces `EV|TR` touch events. |
| `PB` | Draw a progress bar. | `PB|1|40|260|220|20|75|0x07E0|0x0000|0xFFFF` | Percentage is constrained to `0..100`. |
| `CC` | Draw a circle. | `CC|1|350|80|48|0xF800|0xFFFF|2` | `fill=0x0001` draws no fill. |
| `SW` | Draw an interactive switch. | `SW|1|20|80|70|32|1|0x4208|0x07E0` | Produces `EV|SW`; `0` = off, `1` = on. |
| `BM` | Draw a built-in monochrome bitmap. | `BM|1|30|30|wifi|0x07FF|0x0001|2` | Names: `play`, `stop`, `wifi`. |

#### microSD and files

| Command | Description | Example | Notes |
| --- | --- | --- | --- |
| `SD` | Read microSD status and capacity. | `SD` | Reports readiness, total capacity and used space. |
| `LS` | List a directory. | `LS|/images` | The path must name a directory on the microSD card. |
| `FS` | Read a file size. | `FS|/images/neon1.jpg` | Returns the size of one file. |
| `SC` | Execute a command script. | `SC|/script100.nxt` | Runs one protocol command per script line. |
| `JPG` | Draw a JPEG from microSD. | `JPG|2|80|40|/images/neon1.jpg|1/2` | Optional source rectangle fields select part of the image. |
| `FW` | Start writing a file. | `FW|/script100.nxt|34` | `size` is the exact expected byte count. |
| `FD` | Append hexadecimal bytes. | `FD|4A50477C327C38307C3430` | Two hexadecimal characters encode one byte. |
| `FDO` | Write bytes at an expected offset. | `FDO|0|4A50477C327C38307C3430` | The offset must match the current write position. |
| `FE` | Finish the current file upload. | `FE` | Closes the file and validates the final size. |

### Detailed command syntax

Fields are separated by `|`. The format lines below show the required field order; fields in square brackets are optional.

#### System and diagnostic commands

##### `?` — ready check

```text
?
```

No parameters. The display replies with `ready`.

##### `HELP` — command list

```text
HELP
```

No parameters. Prints the command list to the interface that sent the request.

##### `SHOWIP` — network information

```text
SHOWIP
```

No parameters. Reply format:

```text
IP|192.168.1.50|SSID|mywifi|PORT|4210|HOST|nxt-display
```

##### `RESET` — restart

```text
RESET
```

No parameters. The ESP32 acknowledges the request before restarting.

##### `SS` — scene snapshot

```text
SS
```

No parameters. The response contains the number of stored command lines and the lines needed to reconstruct the scene:

```text
OK|SS|BEGIN|3
CL|0x0000
TX|1|20|20|READY|0xFFFF|0x0000|2
SW|1|20|80|70|32|1|0x4208|0x07E0
OK|SS|END
```

`SS` reads the scene; restore it by sending the returned lines back in the same order.

##### `TF` — font test

```text
TF
```

No parameters. Draws samples for font IDs `1..9`.

#### Display commands

##### `CL` — clear screen

```text
CL|color
```

- `color` — RGB565 screen color, for example `0x0000` for black.
- The command clears all registered scene objects, then stores itself as the first scene line.

Example:

```text
CL|0x0000
```

##### `BL` — backlight

```text
BL|enabled
```

- `enabled` — `0` turns the backlight off; any non-zero value turns it on.

Example:

```text
BL|1
```

##### `IV` — display inversion

```text
IV|enabled
```

- `enabled` — `0` disables inversion; any non-zero value enables it.

Example:

```text
IV|1
```

#### GUI commands

Most GUI commands start with these fields:

- `id` — integer object identifier within that command type. Sending the same command type and ID replaces its scene definition.
- `x`, `y` — upper-left position in pixels.
- `w`, `h` — width and height in pixels.
- `fill`, `outline`, `text`, `background`, `track`, `thumb`, `foreground` — RGB565 colors.

##### `BT` — touch button

```text
BT|id|x|y|w|h|label|fill|outline|text|line|font|H|V
```

- `id` — button identifier returned in `EV|BT` events.
- `x`, `y` — button position.
- `w`, `h` — button size and touch area.
- `label` — button caption; it cannot contain `|`.
- `fill` — button background color.
- `outline` — border color.
- `text` — caption color.
- `line` — border thickness; use `1..4`.
- `font` — font ID `1..9`.
- `H` — horizontal caption alignment: `L`, `C` or `R`.
- `V` — vertical caption alignment: `T`, `C` or `B`.

Example:

```text
BT|1|20|20|120|50|OK|0x001F|0xFFFF|0xFFFF|2|2|C|C
```

##### `BX` / `RR` — box or rounded rectangle

```text
BX|id|x|y|w|h|fill|outline|radius|line
RR|id|x|y|w|h|fill|outline|radius|line
```

- `id` — object identifier.
- `x`, `y` — rectangle position.
- `w`, `h` — rectangle size.
- `fill` — fill color; `0x0001` means no fill.
- `outline` — border color.
- `radius` — corner radius; `0` makes square corners.
- `line` — border thickness; use `1..4`.

Examples:

```text
BX|1|10|10|120|50|0x2104|0xFFFF|0|1
RR|2|20|80|120|50|0x001F|0xFFFF|10|2
```

##### `TX` — text label

```text
TX|id|x|y|text|color|background|font[|w|h|H|V]
```

- `id` — text object identifier.
- `x`, `y` — text origin, or upper-left corner of the optional alignment box.
- `text` — displayed text; it cannot contain `|`.
- `color` — text color.
- `background` — text background; `0x0001` means transparent.
- `font` — font ID `1..9`.
- `w`, `h` — optional alignment-box size. Use `0` or omit them for origin-based drawing.
- `H` — optional horizontal alignment: `L`, `C` or `R`.
- `V` — optional vertical alignment: `T`, `C` or `B`.

Example:

```text
TX|1|20|90|Hello|0xFFFF|0x0001|2|120|30|C|C
```

##### `TW` — text window

```text
TW|id|x|y|w|h|title|text|fill|outline
```

- `id` — window identifier.
- `x`, `y` — window position.
- `w`, `h` — window size.
- `title` — title-bar text; it cannot contain `|`.
- `text` — body text; it cannot contain `|`.
- `fill` — body background color; `0x0001` requests transparent fill.
- `outline` — frame and title color.

Example:

```text
TW|1|20|140|280|120|Status|System ready|0x4208|0x001F
```

##### `SB` — scroll bar

```text
SB|id|x|y|w|h|orientation|value|max|track|thumb
```

- `id` — scroll-bar identifier.
- `x`, `y` — scroll-bar position.
- `w`, `h` — scroll-bar size.
- `orientation` — `H` for horizontal or `V` for vertical.
- `value` — current position.
- `max` — maximum position; use a positive value.
- `track` — track color.
- `thumb` — thumb color.

Example:

```text
SB|1|300|150|12|120|V|50|100|0x0000|0x07FF
```

##### `TR` — interactive track bar

```text
TR|id|x|y|w|h|value|max|track|thumb
```

- `id` — control identifier returned in `EV|TR` events.
- `x`, `y` — track-bar position.
- `w`, `h` — track-bar size and touch area.
- `value` — current value.
- `max` — maximum value; use a positive value.
- `track` — track color.
- `thumb` — thumb color.

Example:

```text
TR|1|40|220|220|28|35|100|0x4208|0xFFE0
```

##### `PB` — progress bar

```text
PB|id|x|y|w|h|percent|fill|background|outline
```

- `id` — progress-bar identifier.
- `x`, `y` — progress-bar position.
- `w`, `h` — progress-bar size.
- `percent` — filled amount, constrained to `0..100`.
- `fill` — completed-area color.
- `background` — unfilled-area color.
- `outline` — border color.

Example:

```text
PB|1|40|260|220|20|75|0x07E0|0x0000|0xFFFF
```

##### `CC` — circle

```text
CC|id|x|y|diameter|fill|outline|line
```

- `id` — circle identifier.
- `x`, `y` — upper-left corner of the circle bounding box.
- `diameter` — circle diameter in pixels.
- `fill` — fill color; `0x0001` means no fill.
- `outline` — outline color.
- `line` — outline thickness; use `1..4`.

Example:

```text
CC|1|350|80|48|0xF800|0xFFFF|2
```

##### `SW` — interactive switch

```text
SW|id|x|y|w|h|state|track|thumb
```

- `id` — switch identifier returned in `EV|SW` events.
- `x`, `y` — switch position.
- `w`, `h` — switch size and touch area.
- `state` — `0` for off/left or `1` for on/right.
- `track` — switch track color.
- `thumb` — switch thumb color.

Example:

```text
SW|1|20|80|70|32|1|0x4208|0x07E0
```

##### `BM` — built-in bitmap

```text
BM|id|x|y|name|foreground|background|scale
```

- `id` — bitmap identifier.
- `x`, `y` — bitmap position.
- `name` — built-in asset name: `play`, `stop` or `wifi`.
- `foreground` — set-pixel color.
- `background` — background color; `0x0001` means transparent.
- `scale` — integer pixel scale.

Example:

```text
BM|1|30|30|wifi|0x07FF|0x0001|2
```

#### Touch event formats

Touch events are output messages, not commands sent to the display.

| Event | Description | Example | Notes |
| --- | --- | --- | --- |
| `EV|BT` | Button event. | `EV|BT|1|CLICK|74|268` | Events: `DOWN`, `UP`, `CLICK`. |
| `EV|TR` | Track-bar event. | `EV|TR|2|CHANGE|67|220|180` | Includes the current value. |
| `EV|SW` | Switch event. | `EV|SW|3|CHANGE|1|350|132` | Includes the new binary state. |

```text
EV|BT|id|event|x|y
EV|TR|id|event|value|x|y
EV|SW|id|event|value|x|y
```

- `id` — ID of the touched control.
- `event` — touch phase. Buttons use `DOWN`, `UP`, `CLICK`; track bars can also use `CHANGE`; switches report the toggled state with `CHANGE`.
- `value` — current `TR` value or `SW` state.
- `x`, `y` — touch coordinates.

#### microSD and file commands

##### `SD` — card status

```text
SD
```

No parameters. Reports whether microSD is ready and returns capacity/usage information.

##### `LS` — list directory

```text
LS|path
```

- `path` — directory path on microSD, for example `/` or `/images`.

Example:

```text
LS|/images
```

##### `FS` — file size

```text
FS|path
```

- `path` — full file path on microSD.

Example:

```text
FS|/images/neon1.jpg
```

##### `SC` — run script

```text
SC|path
```

- `path` — path to a text script on microSD.
- Each non-empty line is processed as one normal command. Lines beginning with `#` are ignored.

Example:

```text
SC|/script100.nxt
```

##### `JPG` — draw JPEG

```text
JPG|id|x|y|path|scale[|srcX|srcY|srcW|srcH]
```

- `id` — JPEG scene-object identifier.
- `x`, `y` — destination position on the display.
- `path` — JPEG path on microSD.
- `scale` — `1/4`, `1/2`, `1/1`, `2/1` or `4/1`. Older decoder factors `2`, `4`, `8` are also accepted.
- `srcX`, `srcY` — optional source-area origin.
- `srcW`, `srcH` — optional source-area size. Use positive values to enable source clipping.
- Baseline JPEG is supported; progressive JPEG is not supported.

Examples:

```text
JPG|2|80|40|/images/neon1.jpg|1/2
JPG|3|100|60|/images/panel.jpg|1/2|40|20|160|120
```

##### `FW` — begin file write

```text
FW|path|size
```

- `path` — destination file path on microSD.
- `size` — exact expected file size in bytes.

Example:

```text
FW|/script100.nxt|34
```

##### `FD` — append hexadecimal data

```text
FD|hex
```

- `hex` — an even-length hexadecimal string; every pair is one output byte.
- The data is appended at the current upload position.

Example:

```text
FD|4A50477C327C38307C3430
```

##### `FDO` — write at expected offset

```text
FDO|offset|hex
```

- `offset` — expected current byte offset in the open upload.
- `hex` — an even-length hexadecimal byte string.
- The command rejects an unexpected offset, which helps detect missing or repeated blocks.

Example:

```text
FDO|0|4A50477C327C38307C3430
```

##### `FE` — finish file write

```text
FE
```

No parameters. Closes the active upload and checks the number of written bytes against the `FW` size.

### Protocol examples / Recipes

The following recipes are complete command lines that can be sent over USB Serial, UART2 or UDP. Send each line separately and terminate serial/UART commands with `\n`.

#### Button with `CLICK` handling

Create a button with ID `1`:

```text
BT|1|20|250|140|50|START|0x001F|0xFFFF|0xFFFF|2|4|C|C
```

A complete tap produces `DOWN`, `UP` and `CLICK`. Run the application action only after the matching `CLICK` event:

```text
EV|BT|1|DOWN|72|274
EV|BT|1|UP|72|274
EV|BT|1|CLICK|72|274
```

Host-side handling rule: when the fields are `EV|BT|1|CLICK|...`, start the requested operation. The final two fields are the touch coordinates and are not needed when the button ID is sufficient.

#### RPM indicator updated by ID

Draw a fixed-size value area so the opaque background clears the previous number:

```text
TX|10|20|20|RPM: 1250|0xFFFF|0x0000|8|220|50|L|C
```

Update the indicator by sending another `TX` command with the same ID `10`:

```text
TX|10|20|20|RPM: 2875|0xFFFF|0x0000|8|220|50|L|C
```

The second command replaces the registered `TX|10` scene entry, so `SS` returns only the current RPM definition.

#### X/Y/Z coordinate block

Use one stable text ID per coordinate:

```text
TX|20|20|80|X: +012.50|0xF800|0x0000|5|180|32|L|C
TX|21|20|116|Y: -003.25|0x07E0|0x0000|5|180|32|L|C
TX|22|20|152|Z: +101.80|0x001F|0x0000|5|180|32|L|C
```

Update only the values that changed, retaining their IDs and geometry:

```text
TX|20|20|80|X: +013.10|0xF800|0x0000|5|180|32|L|C
TX|22|20|152|Z: +101.75|0x001F|0x0000|5|180|32|L|C
```

#### Track bar with a separate value label

Create track bar `2` and text label `30`:

```text
TR|2|40|210|260|32|35|100|0x4208|0xFFE0
TX|30|320|210|35|0xFFFF|0x0000|6|100|32|C|C
```

Dragging the thumb can produce events such as:

```text
EV|TR|2|DOWN|35|131|226
EV|TR|2|CHANGE|67|214|226
EV|TR|2|UP|67|214|226
EV|TR|2|CLICK|67|214|226
```

The format is `EV|TR|id|event|value|x|y`. On `EV|TR|2|CHANGE`, read field 5 as the new value and update only the separate label:

```text
TX|30|320|210|67|0xFFFF|0x0000|6|100|32|C|C
```

The firmware redraws `TR|2` and updates its stored scene value while the user drags it, so echoing another `TR` command is unnecessary.

#### Switch with `EV|SW`

Create switch `3` in the off state:

```text
TX|31|300|80|POWER|0xFFFF|0x0000|4|100|32|C|C
SW|3|315|116|70|32|0|0x4208|0x07E0
```

A completed tap toggles the state inside the firmware. A typical off-to-on sequence is:

```text
EV|SW|3|DOWN|0|350|132
EV|SW|3|CHANGE|1|350|132
EV|SW|3|UP|1|350|132
EV|SW|3|CLICK|1|350|132
```

The format is `EV|SW|id|event|value|x|y`. Treat `EV|SW|3|CHANGE|1|...` as the authoritative new state. The firmware has already redrawn the switch and changed the stored `SW|3` line used by `SS`.

#### Progress bar

Create progress bar `4` at 0%:

```text
PB|4|40|270|300|24|0|0x07E0|0x2104|0xFFFF
```

Update it with the same ID; `percent` is constrained by the renderer to `0..100`:

```text
PB|4|40|270|300|24|42|0x07E0|0x2104|0xFFFF
PB|4|40|270|300|24|100|0x07E0|0x2104|0xFFFF
```

#### JPEG from microSD

Check that the card is ready, then draw a baseline JPEG from it:

```text
SD
JPG|5|260|20|/images/logo.jpg|1/1
```

Draw a source rectangle beginning at `(40,20)`, 160 × 120 pixels, decoded at half size:

```text
JPG|6|260|80|/images/panel.jpg|1/2|40|20|160|120
```

`JPG` is registered in the scene only after a successful draw. Keep the file at the same microSD path when a saved scene will later be replayed.

#### Simple full control screen

This sequence builds a complete 480 × 320 control screen. `CL` starts a new scene and removes all previously registered objects:

```text
CL|0x0000
TX|1|0|8|MOTOR CONTROL|0xFFFF|0x0000|8|480|42|C|C
TX|10|20|62|RPM: 1250|0xFFE0|0x0000|8|250|48|L|C
TX|31|330|62|POWER|0xFFFF|0x0000|4|110|32|C|C
SW|3|350|98|70|32|0|0x4208|0x07E0
TX|32|20|140|SPEED|0xFFFF|0x0000|4|100|30|L|C
TR|2|20|174|300|32|35|100|0x4208|0xFFE0
TX|30|340|174|35|0xFFFF|0x0000|6|100|32|C|C
PB|4|20|226|420|22|35|0x07E0|0x2104|0xFFFF
BT|1|20|266|140|44|START|0x001F|0xFFFF|0xFFFF|2|4|C|C
BT|2|320|266|120|44|STOP|0xF800|0xFFFF|0xFFFF|2|4|C|C
```

Handle `EV|BT|1|CLICK|...` as Start, `EV|BT|2|CLICK|...` as Stop, `EV|TR|2|CHANGE|value|...` as the speed setpoint, and `EV|SW|3|CHANGE|value|...` as the power state. Update `TX|10`, `TX|30` and `PB|4` with the same IDs as live values change.

#### Get and restore a scene with `SS`

Request the current registered scene:

```text
SS
```

The response is a count plus replayable command lines:

```text
OK|SS|BEGIN|4
CL|0x0000
TX|10|20|20|RPM: 2875|0xFFFF|0x0000|8|220|50|L|C
TR|2|40|210|260|32|67|100|0x4208|0xFFE0
SW|3|315|116|70|32|1|0x4208|0x07E0
OK|SS|END
```

To save a scene on the host, store only the lines between the markers. To restore it after reset or reconnect, send those lines back in the same order, one command per line:

```text
CL|0x0000
TX|10|20|20|RPM: 2875|0xFFFF|0x0000|8|220|50|L|C
TR|2|40|210|260|32|67|100|0x4208|0xFFE0
SW|3|315|116|70|32|1|0x4208|0x07E0
```

`SS` itself only returns a snapshot; it does not accept scene data. Replaying the returned commands performs the restoration. Current `TR` and `SW` values are included because touch changes update their stored scene definitions.

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
