#include "port/raspi4/uart.h"

void invalid_entry() {
  // In case the UART isn't initialized
  uart_init();
  uart_puts("[Error] Invalid exception occurred\n");

  // Load and decode the exception
  unsigned long esr, elr, spsr, far;
  asm volatile(
      "mrs %[esr], esr_el1\n\t"
      "mrs %[elr], elr_el1\n\t"
      "mrs %[spsr], spsr_el1\n\t"
      "mrs %[far], far_el1\n\t"
      : [esr] "=r"(esr), [elr] "=r"(elr), [spsr] "=r"(spsr), [far] "=r"(far)::);

  // Decode exception type (some, not all. See ARM DDI0487G_a chapter D13.2.37)
  switch (esr >> 26) {
    case 0b000000:
      uart_puts("Unknown");
      break;
    case 0b000001:
      uart_puts("Trapped WFI/WFE");
      break;
    case 0b001110:
      uart_puts("Illegal execution");
      break;
    case 0b010101:
      uart_puts("System call");
      break;
    case 0b100000:
      uart_puts("Instruction abort, lower EL");
      break;
    case 0b100001:
      uart_puts("Instruction abort, same EL");
      break;
    case 0b100010:
      uart_puts("Instruction alignment fault");
      break;
    case 0b100100:
      uart_puts("Data abort, lower EL");
      break;
    case 0b100101:
      uart_puts("Data abort, same EL");
      break;
    case 0b100110:
      uart_puts("Stack alignment fault");
      break;
    case 0b101100:
      uart_puts("Floating point");
      break;
    default:
      uart_puts("Unknown");
      break;
  }
  // Decode data abort cause
  if (esr >> 26 == 0b100100 || esr >> 26 == 0b100101) {
    uart_puts(", ");
    switch ((esr >> 2) & 0x3) {
      case 0:
        uart_puts("Address size fault");
        break;
      case 1:
        uart_puts("Translation fault");
        break;
      case 2:
        uart_puts("Access flag fault");
        break;
      case 3:
        uart_puts("Permission fault");
        break;
    }
    switch (esr & 0x3) {
      case 0:
        uart_puts(" at level 0");
        break;
      case 1:
        uart_puts(" at level 1");
        break;
      case 2:
        uart_puts(" at level 2");
        break;
      case 3:
        uart_puts(" at level 3");
        break;
    }
  }

  // Dump registers
  uart_puts(":\n  ESR_EL1 ");
  uart_hex(esr >> 32);
  uart_hex(esr);
  uart_puts(" ELR_EL1 ");
  uart_hex(elr >> 32);
  uart_hex(elr);
  uart_puts("\n SPSR_EL1 ");
  uart_hex(spsr >> 32);
  uart_hex(spsr);
  uart_puts(" FAR_EL1 ");
  uart_hex(far >> 32);
  uart_hex(far);
  uart_puts("\n");

  while (1) {
    // do nothing
  }
}
