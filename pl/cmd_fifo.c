#include "xparameters.h"
#include "xil_io.h"

#include "cmd_fifo.h"

void queue_command(cmd_fifo *fifo, uint8_t command, bool has_data_byte, uint8_t data_byte) {
  fifo->buffer[fifo->write_head % CMD_BUFFER_SIZE] = command;
  fifo->write_head++;

  if (has_data_byte) {
    fifo->buffer[fifo->write_head % CMD_BUFFER_SIZE] = data_byte;
    fifo->write_head++;
  }

  Xil_Out8((UINTPTR)XPAR_M00_AXI_0_BASEADDR, fifo->buffer[fifo->read_head % CMD_BUFFER_SIZE]);
}
