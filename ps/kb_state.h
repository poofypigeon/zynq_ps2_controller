#ifndef KB_STATE_H
#define KB_STATE_H

#include <stdint.h>
#include <stdbool.h>

#define F_SCROLL_LOCK 0
#define F_NUM_LOCK    1
#define F_CAPS_LOCK   2
#define F_SHIFT       3
#define F_CTRL        4
#define F_ALT         5
#define F_SUPER       6
#define F_ASCII       7

typedef struct {
  uint8_t flag_vector;

  bool s_break;
  bool s_escaped;

  bool s_scroll_lock;
  bool s_num_lock;
  bool s_caps_lock;
} kb_state;

#define SET_FLAG(byte, bit, value)        \
  do {                                    \
    byte &= ~(1 << bit);                  \
    byte |= value << bit;                 \
  } while(0)

#define GET_FLAG(byte, bit) ((byte & (1 << bit)) != 0)

#endif // KB_STATE_H
