#ifndef COMMON_TRACE_H
#define COMMON_TRACE_H

#include <stddef.h>
#include <stdint.h>
#include "port/port.h"

void print_register_context(RegisterContext ctx);

typedef struct {
  const char* name;
  void* start;
  void* end;
} Symbol;

void print_backtrace(RegisterContext ctx, const Symbol* symbols,
                     size_t num_symbols);

#endif /* ifdef COMMON_TRACE_H */
