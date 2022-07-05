#ifndef KEY_CODE_H
#define KEY_CODE_H

typedef struct {
  uint8_t flags;
  union {
    uint8_t symbol;
    struct {
      char noshift;
      char shift;
    };
  };
} key_code;

typedef enum {
  ENTER,
  F1, F2, F3,
  F4, F5, F6,
  F7, F8, F9,
  F10, F11, F12,
  HOME,
  END,
  INSERT,
  PAGE_UP,
  PAGE_DOWN,
  UP_ARROW,
  DOWN_ARROW,
  LEFT_ARROW,
  RIGHT_ARROW,
  SHIFT_LEFT,
  SHIFT_RIGHT,
  CTRL_LEFT,
  CTRL_RIGHT,
  ALT_LEFT,
  ALT_RIGHT,
  SUPER_LEFT,
  SUPER_RIGHT,
  SCROLL_LOCK,
  NUM_LOCK,
  CAPS_LOCK,
  MENUS,
  PRINT_SCREEN,
  PAUSE_BREAK
} key_symbols;

#endif // KEY_CODE_H
