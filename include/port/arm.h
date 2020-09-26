#ifndef PORT_ARM_H
#define PORT_ARM_H

#include "port/arm_common.h"
#include <stddef.h>

typedef struct {
  size_t r0;
  size_t r1;
  size_t r2;
  size_t r3;
  size_t r4;
  size_t r5;
  size_t r6;
  size_t r7;
  size_t r8;
  size_t r9;
  size_t r10;
  size_t r11;
  size_t r12;
  /* stack pointer is in the thread struct */
  size_t lr;
  /* aka the exception mode lr */
  size_t pc;
  size_t cpsr;
  /* stack pointer is in thread struct
     We don't provide it here because modifying it
     would prevent the thread from resuming correctly.
  */
} __attribute__((packed)) RegisterContext;

#endif /* ifdef PORT_ARM_H */
