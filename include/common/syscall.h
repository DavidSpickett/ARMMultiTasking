/* Generated by scripts/gen_syscalls.py */
// clang-format off
#ifndef COMMON_SYSCALL_H
#define COMMON_SYSCALL_H

#include <stddef.h>

typedef enum {
  /* [[[cog
  import cog
  from scripts.syscalls import syscalls
  for n, syscall in enumerate(syscalls):
    cog.outl("syscall_{} = {}, // ?".format(syscall, n))
  ]]] */
  syscall_add_thread = 0,
  syscall_get_thread_property = 1,
  syscall_set_thread_property = 2,
  syscall_get_kernel_config = 3,
  syscall_set_kernel_config = 4,
  syscall_yield = 5,
  syscall_get_msg = 6,
  syscall_send_msg = 7,
  syscall_thread_wait = 8,
  syscall_thread_wake = 9,
  syscall_thread_cancel = 10,
  syscall_mutex = 11,
  syscall_condition_variable = 12,
  syscall_open = 13,
  syscall_read = 14,
  syscall_write = 15,
  syscall_lseek = 16,
  syscall_remove = 17,
  syscall_close = 18,
  syscall_exit = 19,
  syscall_malloc = 20,
  syscall_realloc = 21,
  syscall_free = 22,
  syscall_list_dir = 23,
  /* [[[end]]] */
  syscall_eol,
} Syscall;

#endif /* ifdef COMMON_SYSCALL_H */
