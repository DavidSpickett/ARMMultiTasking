#include "common/serial_port.h"
#include "port/raspi4/uart.h"
#include <stdint.h>

static void rpi_serial_init() {
  uart_init();
}

static void rpi_serial_putchar(int c) {
  if (c == '\n')
    uart_send('\r');
  uart_send(c);
}

SerialPort serial_port = {
    .init = rpi_serial_init,
    .putchar = rpi_serial_putchar,
};
