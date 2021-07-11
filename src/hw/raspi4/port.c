#include "port/port.h"
#include "common/print.h"

void platform_init_register_context(RegisterContext* regs) {
  // Run in EL0
  regs->spsr_el1 = 0;
}

void print_register_context(const RegisterContext* ctx) {
  printf("       x0: 0x%16X   x1: 0x%16X  x2: 0x%16X  x3: 0x%16X\n"
         "       x4: 0x%16X   x5: 0x%16X  x6: 0x%16X  x7: 0x%16X\n"
         "       x8: 0x%16X   x9: 0x%16X x10: 0x%16X x11: 0x%16X\n"
         "      x12: 0x%16X  x13: 0x%16X x14: 0x%16X x15: 0x%16X\n"
         "      x16: 0x%16X  x17: 0x%16X x18: 0x%16X x19: 0x%16X\n"
         "      x20: 0x%16X  x21: 0x%16X x22: 0x%16X x23: 0x%16X\n"
         "      x24: 0x%16X  x25: 0x%16X x26: 0x%16X x27: 0x%16X\n"
         "      x28: 0x%16X  x29: 0x%16X x30: 0x%16X  pc: 0x%16X\n"
         " spsr_el1: 0x%16X fpsr: 0x%16X\n",
         ctx->x0, ctx->x1, ctx->x2, ctx->x3, ctx->x4, ctx->x5, ctx->x6, ctx->x7,
         ctx->x8, ctx->x9, ctx->x10, ctx->x11, ctx->x12, ctx->x13, ctx->x14,
         ctx->x15, ctx->x16, ctx->x17, ctx->x18, ctx->x19, ctx->x20, ctx->x21,
         ctx->x22, ctx->x23, ctx->x24, ctx->x25, ctx->x26, ctx->x27, ctx->x28,
         ctx->x29, ctx->x30, ctx->pc, ctx->spsr_el1, ctx->fpsr);
}
