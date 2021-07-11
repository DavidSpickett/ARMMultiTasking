#ifndef PORT_RASPI4_UART_H
#define PORT_RASPI4_UART_H

void uart_init();
void uart_send(unsigned int c);
char uart_getc();
void uart_puts(char* s);
void uart_hex(unsigned int c);

#endif /* PORT_RASPI4_UART_H */
