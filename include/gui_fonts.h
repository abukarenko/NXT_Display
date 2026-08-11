#pragma once

#include <FontsRus/FreeMono12.h>
#include <FontsRus/FreeSans6.h>
#include <FontsRus/FreeSans8.h>
#include <FontsRus/FreeSans10.h>
#include <FontsRus/FreeSans12.h>
#include <FontsRus/FreeSansBold12.h>
#include <FontsRus/FreeSansBold14.h>
#include <FontsRus/FreeSansBold16.h>
#include <FontsRus/FreeSansBold18.h>

struct GuiFontEntry {
  uint8_t id;
  const char *name;
  const GFXfont *font;
};

constexpr uint8_t GUI_FONT_COUNT = 9;

const GuiFontEntry GUI_FONTS[GUI_FONT_COUNT] = {
  {1, "FreeSans6", &FreeSans6pt8b},
  {2, "FreeSans8", &FreeSans8pt8b},
  {3, "FreeSans10", &FreeSans10pt8b},
  {4, "FreeSans12", &FreeSans12pt8b},
  {5, "FreeMono12", &FreeMono12pt8b},
  {6, "FreeSansBold12", &FreeSansBold12pt8b},
  {7, "FreeSansBold14", &FreeSansBold14pt8b},
  {8, "FreeSansBold16", &FreeSansBold16pt8b},
  {9, "FreeSansBold18", &FreeSansBold18pt8b},
};

inline const GuiFontEntry *guiFontById(int id)
{
  for (uint8_t i = 0; i < GUI_FONT_COUNT; ++i) {
    if (GUI_FONTS[i].id == id) {
      return &GUI_FONTS[i];
    }
  }
  return &GUI_FONTS[1];
}
