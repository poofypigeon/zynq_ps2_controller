#include <stdint.h>
#include <stdbool.h>

#include "xparameters.h"
#include "xil_io.h"

#include "kb_state.h"
#include "cmd_fifo.h"
#include "process_scan_code.h"

// --- KNOWN LIMITATIONS ---
// > No handling of held keys
// > No support for most host commands 
// > No overflow protections on command fifo 

static kb_state kb   = { 0 };
static cmd_fifo fifo = { 0 };

// Small state machine for scr/num/caps lock toggle behaviour
//   Toggle-on occurs on make of enabling key press
//   Toggle-off occurs on break of disabling key press
static void toggle_lock(uint8_t flag) {
  bool *s_key;
  switch (flag) {
    case F_SCROLL_LOCK:
      s_key = &kb.s_scroll_lock;
      break;
    case F_NUM_LOCK:
      s_key = &kb.s_num_lock;
      break;
    case F_CAPS_LOCK:
      s_key = &kb.s_caps_lock;
      break;
  }

  if (*s_key == 0) {
    if (kb.s_break) {
      *s_key = 1;
    } else {
      SET_FLAG(kb.flag_vector, flag, 1);
    }
  } else if (*s_key == 1) {
    if (kb.s_break) {
      SET_FLAG(kb.flag_vector, flag, 0);
      *s_key = 0;
    }
  }

  kb.s_break   = false;
  kb.s_escaped = false;

  if (*s_key == 0)
    queue_command(&fifo, CMD_SET_LED, true, kb.flag_vector & 0x07);
}

int process_scan_code(uint8_t scan_code, key_code* mapping) {
  *mapping = (key_code){ 0 };

  switch (scan_code) {
    // Handle host-to-device transactions
    case CMD_ACK:
      fifo.read_head++;
      if (fifo.read_head != fifo.write_head)
        Xil_Out8((UINTPTR)XPAR_M00_AXI_0_BASEADDR, fifo.buffer[fifo.read_head % CMD_BUFFER_SIZE]);
      else
        fifo.read_head = fifo.write_head = 0;
      return 0;
    case CMD_RESEND:
      Xil_Out8((UINTPTR)XPAR_M00_AXI_0_BASEADDR, fifo.buffer[fifo.write_head]);
      return 0;
    // State altering scan codes
    case BREAK_SCAN_CODE:
      kb.s_break = true;
      return 0;
    case ESCAPE_SCAN_CODE:
      kb.s_escaped = true;
      return 0;
  }

  // Decode scan code via look up table
  key_code key = (kb.s_escaped)
    ? escaped_scan_code_lut[scan_code]
    : scan_code_lut[scan_code];

  // Process modifier keys
  if (key.flags == NO_ASCII) {
    switch (key.symbol) {
      case SHIFT_LEFT:
      case SHIFT_RIGHT:
        SET_FLAG(kb.flag_vector, F_SHIFT, !kb.s_break);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case CTRL_LEFT:
      case CTRL_RIGHT:
        SET_FLAG(kb.flag_vector, F_CTRL, !kb.s_break);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case ALT_LEFT:
      case ALT_RIGHT:
        SET_FLAG(kb.flag_vector, F_ALT, !kb.s_break);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case SUPER_LEFT:
      case SUPER_RIGHT:
        SET_FLAG(kb.flag_vector, F_SUPER, !kb.s_break);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case SCROLL_LOCK:
        toggle_lock(F_SCROLL_LOCK);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case NUM_LOCK:
        toggle_lock(F_NUM_LOCK);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
      case CAPS_LOCK:
        toggle_lock(F_CAPS_LOCK);
        kb.s_break   = false;
        kb.s_escaped = false;
        return 0;
    }
  }

  // Return raw ascii and symbols to be interpreted
  if (!kb.s_break) {
    key.flags |= kb.flag_vector;
    *mapping = key;
	  kb.s_escaped = false;
    return 1;
  } 

	kb.s_break   = false;
	kb.s_escaped = false;
  return 0;
}
