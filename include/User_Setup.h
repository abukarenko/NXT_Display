#pragma once

// ESP32 + ILI9488 SPI display configuration for TFT_eSPI.
// Change only this file if your display is wired to different pins.

#define ILI9488_DRIVER

#define TFT_MOSI 23
// GPIO19 is used by the touch controller TDO.
// Leave the display SDO pin disconnected if it blocks the shared MISO line.
#define TFT_MISO 19
#define TFT_SCLK 18
#define TFT_CS    5
#define TFT_DC   21
#define TFT_RST   4

// Backlight pin. Set to -1 if the module backlight is wired directly to power.
#define TFT_BL   32
#define TFT_BACKLIGHT_ON HIGH

// Resistive touch controller, common on ILI9488 modules as XPT2046.
#define TOUCH_CS 22
#define TOUCH_IRQ 34

#define LOAD_GLCD
#define LOAD_FONT2
#define LOAD_FONT4
#define LOAD_FONT6
#define LOAD_FONT7
#define LOAD_FONT8
#define LOAD_GFXFF
#define SMOOTH_FONT

#define SPI_FREQUENCY       27000000
#define SPI_READ_FREQUENCY  16000000
#define SPI_TOUCH_FREQUENCY 250000
