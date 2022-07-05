#ifndef SCAN_CODE_LUT_H
#define SCAN_CODE_LUT_H

#include "key_code.h"

#define BREAK_SCAN_CODE  0xF0
#define ESCAPE_SCAN_CODE 0xE0

#define ASCII    0x80
#define NO_ASCII 0x00

#define ASCII_ESCAPE    '\33'
#define ASCII_BACKSPACE '\10'
#define ASCII_TAB       '\11'
#define ASCII_DELETE    '\177'

static const uint8_t PRINT_SCREEN_MAKE[]  = { 0xE0, 0x12, 0xE0, 0x7C, 0x00 };
static const uint8_t PRINT_SCREEN_BREAK[] = { 0xE0, 0xF0, 0x7C, 0xE0, 0xF0, 0x12, 0x00};
static const uint8_t PAUSE[]              = { 0xE1, 0x14, 0x77, 0xE1, 0xF0, 0x14, 0xE0, 0x77, 0x00 };

static const key_code scan_code_lut[256] = {
  // modifiers
  [0x12] = { .flags = NO_ASCII, .symbol = SHIFT_LEFT  },
  [0x59] = { .flags = NO_ASCII, .symbol = SHIFT_RIGHT },
  [0x14] = { .flags = NO_ASCII, .symbol = CTRL_LEFT   },
  [0x11] = { .flags = NO_ASCII, .symbol = ALT_LEFT    },
  [0x7E] = { .flags = NO_ASCII, .symbol = SCROLL_LOCK },
  [0x58] = { .flags = NO_ASCII, .symbol = CAPS_LOCK   },
  [0x77] = { .flags = NO_ASCII, .symbol = NUM_LOCK    },
  // whitespace
  [0x76] = { .flags = ASCII, .noshift = ASCII_ESCAPE,    .shift = ASCII_ESCAPE    },
  [0x66] = { .flags = ASCII, .noshift = ASCII_BACKSPACE, .shift = ASCII_BACKSPACE },
  [0x0D] = { .flags = ASCII, .noshift = ASCII_TAB,       .shift = ASCII_TAB       },
  [0x29] = { .flags = ASCII, .noshift = ' ',             .shift = ' '             },
  [0x5A] = { .flags = NO_ASCII, .symbol = ENTER },
  // function keys
  [0x05] = { .flags = NO_ASCII, .symbol = F1  },
  [0x06] = { .flags = NO_ASCII, .symbol = F2  },
  [0x04] = { .flags = NO_ASCII, .symbol = F3  },
  [0x0C] = { .flags = NO_ASCII, .symbol = F4  },
  [0x03] = { .flags = NO_ASCII, .symbol = F5  },
  [0x0B] = { .flags = NO_ASCII, .symbol = F6  },
  [0x83] = { .flags = NO_ASCII, .symbol = F7  },
  [0x0A] = { .flags = NO_ASCII, .symbol = F8  },
  [0x01] = { .flags = NO_ASCII, .symbol = F9  },
  [0x09] = { .flags = NO_ASCII, .symbol = F10 },
  [0x78] = { .flags = NO_ASCII, .symbol = F11 },
  [0x07] = { .flags = NO_ASCII, .symbol = F12 },
  // alpha
  [0x15] = { .flags = ASCII, .noshift = 'q', .shift = 'Q' },
  [0x1D] = { .flags = ASCII, .noshift = 'w', .shift = 'W' },
  [0x24] = { .flags = ASCII, .noshift = 'e', .shift = 'E' },
  [0x2D] = { .flags = ASCII, .noshift = 'r', .shift = 'R' },
  [0x2C] = { .flags = ASCII, .noshift = 't', .shift = 'T' },
  [0x35] = { .flags = ASCII, .noshift = 'y', .shift = 'Y' },
  [0x3C] = { .flags = ASCII, .noshift = 'u', .shift = 'U' },
  [0x43] = { .flags = ASCII, .noshift = 'i', .shift = 'I' },
  [0x44] = { .flags = ASCII, .noshift = 'o', .shift = 'O' },
  [0x4D] = { .flags = ASCII, .noshift = 'p', .shift = 'P' },
  [0x1C] = { .flags = ASCII, .noshift = 'a', .shift = 'A' },
  [0x1B] = { .flags = ASCII, .noshift = 's', .shift = 'S' },
  [0x23] = { .flags = ASCII, .noshift = 'd', .shift = 'D' },
  [0x2B] = { .flags = ASCII, .noshift = 'f', .shift = 'F' },
  [0x34] = { .flags = ASCII, .noshift = 'g', .shift = 'G' },
  [0x33] = { .flags = ASCII, .noshift = 'h', .shift = 'H' },
  [0x3B] = { .flags = ASCII, .noshift = 'j', .shift = 'J' },
  [0x42] = { .flags = ASCII, .noshift = 'k', .shift = 'K' },
  [0x4B] = { .flags = ASCII, .noshift = 'l', .shift = 'L' },
  [0x1A] = { .flags = ASCII, .noshift = 'z', .shift = 'Z' },
  [0x22] = { .flags = ASCII, .noshift = 'x', .shift = 'X' },
  [0x21] = { .flags = ASCII, .noshift = 'c', .shift = 'C' },
  [0x2A] = { .flags = ASCII, .noshift = 'v', .shift = 'V' },
  [0x32] = { .flags = ASCII, .noshift = 'b', .shift = 'B' },
  [0x31] = { .flags = ASCII, .noshift = 'n', .shift = 'N' },
  [0x3A] = { .flags = ASCII, .noshift = 'm', .shift = 'M' },
  // numeric
  [0x16] = { .flags = ASCII, .noshift = '1', .shift = '!' },
  [0x1E] = { .flags = ASCII, .noshift = '2', .shift = '@' },
  [0x26] = { .flags = ASCII, .noshift = '3', .shift = '#' },
  [0x25] = { .flags = ASCII, .noshift = '4', .shift = '$' },
  [0x2E] = { .flags = ASCII, .noshift = '5', .shift = '%' },
  [0x36] = { .flags = ASCII, .noshift = '6', .shift = '^' },
  [0x3D] = { .flags = ASCII, .noshift = '7', .shift = '&' },
  [0x3E] = { .flags = ASCII, .noshift = '8', .shift = '*' },
  [0x46] = { .flags = ASCII, .noshift = '9', .shift = '(' },
  [0x45] = { .flags = ASCII, .noshift = '0', .shift = ')' },
  // symbols
  [0x0E] = { .flags = ASCII, .noshift = '`', .shift = '~' },
  [0x4E] = { .flags = ASCII, .noshift = '-', .shift = '_' },
  [0x55] = { .flags = ASCII, .noshift = '=', .shift = '+' },
  [0x54] = { .flags = ASCII, .noshift = '[', .shift = '{' },
  [0x5B] = { .flags = ASCII, .noshift = ']', .shift = '}' },
  [0x4C] = { .flags = ASCII, .noshift = ';', .shift = ':' },
  [0x41] = { .flags = ASCII, .noshift = ',', .shift = '<' },
  [0x49] = { .flags = ASCII, .noshift = '.', .shift = '>' },
  [0x4A] = { .flags = ASCII, .noshift = '/', .shift = '?' },
  [0x52] = { .flags = ASCII, .noshift = '\'',.shift = '"' },
  [0x5D] = { .flags = ASCII, .noshift = '\\',.shift = '|' },
  // numpad
  [0x7C] = { .flags = ASCII, .noshift = '*', .shift = '*' },
  [0x7B] = { .flags = ASCII, .noshift = '-', .shift = '-' },
  [0x69] = { .flags = ASCII, .noshift = '1', .shift = '1' },
  [0x72] = { .flags = ASCII, .noshift = '2', .shift = '2' },
  [0x7A] = { .flags = ASCII, .noshift = '3', .shift = '3' },
  [0x6B] = { .flags = ASCII, .noshift = '4', .shift = '4' },
  [0x73] = { .flags = ASCII, .noshift = '5', .shift = '5' },
  [0x74] = { .flags = ASCII, .noshift = '6', .shift = '6' },
  [0x6C] = { .flags = ASCII, .noshift = '7', .shift = '7' },
  [0x75] = { .flags = ASCII, .noshift = '8', .shift = '8' },
  [0x7D] = { .flags = ASCII, .noshift = '9', .shift = '9' },
  [0x70] = { .flags = ASCII, .noshift = '0', .shift = '0' },
  [0x79] = { .flags = ASCII, .noshift = '+', .shift = '+' },
  [0x71] = { .flags = ASCII, .noshift = '.', .shift = '.' }
};

static const key_code escaped_scan_code_lut[128] = {
  [0x4A] = { .flags = ASCII,    .noshift = '/',          .shift = '/'          },
  [0x71] = { .flags = ASCII,    .noshift = ASCII_DELETE, .shift = ASCII_DELETE },
  [0x5A] = { .flags = NO_ASCII, .symbol  = ENTER       },
  [0x14] = { .flags = NO_ASCII, .symbol  = CTRL_RIGHT  },
  [0x11] = { .flags = NO_ASCII, .symbol  = ALT_RIGHT   },
  [0x1F] = { .flags = NO_ASCII, .symbol  = SUPER_LEFT  },
  [0x27] = { .flags = NO_ASCII, .symbol  = SUPER_RIGHT },
  [0x2F] = { .flags = NO_ASCII, .symbol  = MENUS       },
  [0x70] = { .flags = NO_ASCII, .symbol  = INSERT      },
  [0x7D] = { .flags = NO_ASCII, .symbol  = PAGE_UP     },
  [0x7A] = { .flags = NO_ASCII, .symbol  = PAGE_DOWN   },
  [0x6C] = { .flags = NO_ASCII, .symbol  = HOME        },
  [0x69] = { .flags = NO_ASCII, .symbol  = END         },
  [0x75] = { .flags = NO_ASCII, .symbol  = UP_ARROW    },
  [0x72] = { .flags = NO_ASCII, .symbol  = DOWN_ARROW  },
  [0x6B] = { .flags = NO_ASCII, .symbol  = LEFT_ARROW  },
  [0x74] = { .flags = NO_ASCII, .symbol  = RIGHT_ARROW }
};

#endif // SCAN_CODE_LUT_H

