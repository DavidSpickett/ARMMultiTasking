#!/usr/bin/python3

from textwrap import dedent

syscalls = """\
add_thread
get_thread_property
set_thread_property
get_kernel_config
set_kernel_config
yield
get_msg
send_msg
thread_wait
thread_wake
thread_cancel
mutex
condition_variable
open
read
write
lseek
remove
close
exit
malloc
realloc
free
list_dir""".split()

print(dedent("""\
/* Generated by scripts/gen_syscalls.py */
// clang-format off
#ifndef COMMON_SYSCALL_H
#define COMMON_SYSCALL_H

#ifdef __ASSEMBLER__
#ifdef __aarch64__
#define FNADDR .quad
#else
#define FNADDR .word
#endif"""))

for call in syscalls:
    print("  FNADDR k_{}".format(call))
# Some padding to catch off by something errors (only for asm)
for i in range(4):
    print("  FNADDR k_invalid_syscall")

print(dedent("""\
#else

#include <stddef.h>

typedef enum {"""))
first, rest = syscalls[0], syscalls[1:]
print("  syscall_{} = 0,".format(first))
for call in rest:
    print("  syscall_{},".format(call))

print(dedent("""\
  syscall_eol,
} Syscall;"""))
print()

print(dedent("""
      #endif /* ifdef __ASSEMBLER__ */
      #endif /* ifdef COMMON_SYSCALL_H */"""))
