#include "port/raspi4/gpio.h"
#include "port/raspi4/mbox.h"
#include "port/raspi4/mmio.h"

#include <stdint.h>

/* PL011 UART registers */
#define UART0_DR   ((volatile unsigned int*)(MMIO_BASE + 0x00201000))
#define UART0_FR   ((volatile unsigned int*)(MMIO_BASE + 0x00201018))
#define UART0_IBRD ((volatile unsigned int*)(MMIO_BASE + 0x00201024))
#define UART0_FBRD ((volatile unsigned int*)(MMIO_BASE + 0x00201028))
#define UART0_LCRH ((volatile unsigned int*)(MMIO_BASE + 0x0020102C))
#define UART0_CR   ((volatile unsigned int*)(MMIO_BASE + 0x00201030))
#define UART0_IMSC ((volatile unsigned int*)(MMIO_BASE + 0x00201038))
#define UART0_ICR  ((volatile unsigned int*)(MMIO_BASE + 0x00201044))

void uart_init() {
  // set up the UART clock
  // see https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
  // for more information
  uint32_t __attribute__((aligned(16))) m[9];
  m[0] = 9 * 4; // The size of the message (9 integers)
  m[1] = MBOX_REQUEST;
  m[2] = MBOX_TAG_SETCLKRATE; // set clock rate
  m[3] = 12;                  // the value length
  m[4] = 8;                   // The clock ID
  m[5] = 2;                   // UART clock
  m[6] = 4000000;             // 4Mhz
  m[7] = 0;                   // clear turbo
  m[8] = MBOX_TAG_LAST;
  mbox_call(MBOX_CH_PROP, m);

  // map UART0 to GPIO pins
  // You can see more information in BCM2711 Peripherals
  uint32_t r = *GPFSEL1;
  r &= ~((7 << 12) | (7 << 15)); // gpio14, gpio15 (FSEL14, FSEL15)
  r |= (4 << 12) | (4 << 15);    // alt0
  *GPFSEL1 = r;

  *UART0_ICR = 0x7FF; // clear interrupts
  *UART0_IBRD = 2;    // 115200 baud
  *UART0_FBRD = 11;
  *UART0_LCRH = 0x7 << 4; // 8n1, enable FIFOs
  *UART0_CR = 0x301;      // enable UART0
}

void uart_send(unsigned int c) {
  /* wait until we can send */
  do {
    asm volatile("nop");
  } while (*UART0_FR & 0x20);

  /* write the character to the buffer */
  *UART0_DR = c;
}

char uart_getc() {
  /* wait until something is in the buffer */
  do {
    asm volatile("nop");
  } while (*UART0_FR & 0x10);

  /* read it and return */
  char r = (char)(*UART0_DR);

  /* convert carrige return to newline */
  return r == '\r' ? '\n' : r;
}

void uart_puts(char* s) {
  while (*s) {
    /* convert newline to carrige return + newline */
    if (*s == '\n')
      uart_send('\r');
    uart_send(*s++);
  }
}

void uart_hex(unsigned int d) {
  unsigned int n;
  int c;
  for (c = 28; c >= 0; c -= 4) {
    // get highest tetrad
    n = (d >> c) & 0xF;
    // 0-9 => '0'-'9', 10-15 => 'A'-'F'
    n += n > 9 ? 0x37 : 0x30;
    uart_send(n);
  }
}
