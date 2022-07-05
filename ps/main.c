#include <stdint.h>
#include <ctype.h>

#include "xparameters.h"
#include "xscugic.h"
#include "xil_io.h"

#include "ps7_init.h"

#include "process_scan_code.h"
#include "kb_state.h"
#include "key_code.h"

static void ps2_rx_isr();

XScuGic interrupt_instance;

int main() {
  ps7_post_config();

  XScuGic_Config *interrupt_config;
  interrupt_config = XScuGic_LookupConfig(XPAR_PS7_DMA_NS_DEVICE_ID);

  XScuGic_CfgInitialize(&interrupt_instance, interrupt_config, interrupt_config->CpuBaseAddress);

  XScuGic_SetPriorityTriggerType(&interrupt_instance, XPAR_FABRIC_INQ_F2P_INTR, 0, 3);

  XScuGic_Connect(&interrupt_instance, XPAR_FABRIC_INQ_F2P_INTR, (Xil_InterruptHandler)ps2_rx_isr, NULL);

  XScuGic_Enable(&interrupt_instance, XPAR_FABRIC_INQ_F2P_INTR);

  Xil_ExceptionInit();
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, (void*)&interrupt_instance);
  Xil_ExceptionEnable();

  while (1);
}

static void ps2_rx_isr() {
  XScuGic_Disable(&interrupt_instance, XPAR_FABRIC_INQ_F2P_INTR);

  uint8_t scan_code = (Xil_In32(XPAR_M00_AXI_0_BASEADDR) >> 8) & 0xFF;
  key_code key;
  int action_required = process_scan_code(scan_code, &key);

  if (action_required) {
    if (GET_FLAG(key.flags, F_ASCII)) {
      bool shift = GET_FLAG(key.flags, F_SHIFT);
      bool caps  = GET_FLAG(key.flags, F_CAPS_LOCK);
    	bool use_shift = isalpha((int)key.noshift) ? shift != caps : shift;
	    outbyte(use_shift ? key.shift : key.noshift);
    } else {
      switch (key.symbol) {
        case ENTER:
          xil_printf("\n\r");
          break;
        case UP_ARROW:
          xil_printf("\33[A");
          break;
        case DOWN_ARROW:
          xil_printf("\33[B");
          break;
        case RIGHT_ARROW:
          xil_printf("\33[C");
          break;
        case LEFT_ARROW:
          xil_printf("\33[D");
          break;
      }
    }
  }

  XScuGic_Enable(&interrupt_instance, XPAR_FABRIC_INQ_F2P_INTR);
}
