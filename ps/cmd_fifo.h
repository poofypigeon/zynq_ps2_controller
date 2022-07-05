#ifndef CMD_FIFO_H
#define HOST_COMMAND_H

#include <stdbool.h>

#define CMD_BUFFER_SIZE 16

typedef struct {
  uint8_t buffer[CMD_BUFFER_SIZE];
  uint8_t write_head;
  uint8_t read_head;
} cmd_fifo;

#define CMD_SET_LED 0xED
#define CMD_ACK     0xFA
#define CMD_RESEND  0xFE

void queue_command(cmd_fifo *fifo, uint8_t command, bool has_data_byte, uint8_t data_byte);

#endif // HOST_COMMAND_H
