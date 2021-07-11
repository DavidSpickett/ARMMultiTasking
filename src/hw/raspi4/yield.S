#include "common/svc_calls.h"

.set TIMER_AMOUNT, 100000

.macro CHECK_SVC code, handler
  mov x1, #\code
  cmp x0, x1
  beq \handler
.endm

.macro CURRENT_IN_X20_NEXT_IN_X21
  // Deliberatley callee saved so we can call the scheduler easily
  ldr x20, =current_thread
  ldr x21, =next_thread
.endm

.macro NEXT_EQUAL_CURRENT
  CURRENT_IN_X20_NEXT_IN_X21
  ldr x20, [x20]
  str x20, [x21] // next_thread = current_thread
.endm

.macro SAVE_CURRENT_THREAD
  msr SPSel, #0 // Use user stack

  /* Save all registers to user stack */
  stp x0,  x1,  [sp, #-16]!

  mrs x0, FPSR              // Restore these second to last
  mrs x1, SPSR_EL1          // so we have temp regs x0/x1 to msr from
  stp x0, x1,   [sp, #-16]!

  /* Save the PC we are switching from */
  mrs x1, ELR_EL1

  stp x1,  x2,  [sp, #-16]! // PC included here
  stp x3,  x4,  [sp, #-16]!
  stp x5,  x6,  [sp, #-16]!
  stp x7,  x8,  [sp, #-16]!
  stp x9,  x10, [sp, #-16]!
  stp x11, x12, [sp, #-16]!
  stp x13, x14, [sp, #-16]!
  stp x15, x16, [sp, #-16]!
  stp x17, x18, [sp, #-16]!
  stp x19, x20, [sp, #-16]!
  stp x21, x22, [sp, #-16]!
  stp x23, x24, [sp, #-16]!
  stp x25, x26, [sp, #-16]!
  stp x27, x28, [sp, #-16]!
  stp x29, x30, [sp, #-16]!

  CURRENT_IN_X20_NEXT_IN_X21

  /* Save stack pointer */
  ldr x1, [x20]        // x1 = current_thread
  mov x3, sp
  str x3, [x1], #8     // current_thread->stack_ptr=sp
.endm

.macro DISABLE_TIMER
  mov x0, #2                 // Disable timer and mask interrupt
  msr CNTV_CTL_EL0, x0
.endm

.macro CALL_KERNEL function
  msr SPSel, #1        // Use kernel's stack
  bl  \function
.endm

/* Having this as a seperate handler is easier than
   finding the exact right register to read.
   Since I'm not sure what would happen if there
   were a pending timer int, and we happened to hit
   an SVC at the same time. We might lose the SVC.
*/
.global handle_timer
handle_timer:
  SAVE_CURRENT_THREAD
  DISABLE_TIMER

  /* Set next to NULL to run the scheduler */
  mov x0, #0
  ldr x1, =next_thread
  str x0, [x1] // next_thread = NULL

  b load_next_thread

.global handle_svc
handle_svc:
  SAVE_CURRENT_THREAD

  /* See what brought us here. */
  mrs x0, ESR_EL1
  lsr x0, x0, #26    // check exception code
  mov x1, #0x15      // SVC
  cmp x0, x1
  beq check_svc
  b .                // unknown source

check_svc:
  mrs x0, ESR_EL1    // Reload then check svc code
  mov x1, #0xFFFF    // mask to get code
  and x0, x0, x1

  CHECK_SVC svc_thread_switch, load_next_thread
  CHECK_SVC svc_disable_timer, disable_timer
  CHECK_SVC svc_enable_timer, enable_timer
  CHECK_SVC svc_syscall, generic_syscall
  b .                // unknown SVC

generic_syscall:
  CALL_KERNEL k_handle_syscall
  b load_next_thread

enable_timer:
  mrs x0, CNTVCT_EL0     // Get current count
  ldr x1, =TIMER_AMOUNT
  add x1, x0, x1
  msr CNTV_CVAL_EL0, x1  // New target is some point in the future
  mov x0, #1
  msr CNTV_CTL_EL0, x0 // Set enable bit
  b finalise_timer
disable_timer:
  DISABLE_TIMER
finalise_timer:
  NEXT_EQUAL_CURRENT
  b load_next_thread

.global load_first_thread
load_first_thread:
  // Kernel calls this so no current thread to save
  b load_next_thread

load_next_thread:
  CURRENT_IN_X20_NEXT_IN_X21
  // If next_thread is null then we need to run the scheduler
  ldr x6, [x21]        // x0 = next_thread
  mov x1, #0
  cmp x6, x1
  bne actually_load_thread

  // Otherwise pick a new thread and do housekeeping
  CALL_KERNEL do_scheduler   // This will set next_thread
  ldr x6, [x21]              // Get new next_thread

actually_load_thread:
  /* Either we ran the code above, or kernel jumped here
     to run setup_thread. Either way we want to set EL0_SP */
  msr SPSel, #0            // Back to user stack
  str x6, [x20]            // current_thread = next_thread
  mov x12, #0              // Set next to null for next switch to call scheduler
  str x12, [x21]           // next_thread = NULL
  ldr x20, [x20]           // x20 = current_thread
  ldr x3, [x20], #8        // x3 = current_thread->stack_ptr
  mov sp, x3

  /* Restore all registers of the new thread
     (even init state threads have a blank context
      to restore)
  */
  ldp x29, x30, [sp], #16
  ldp x27, x28, [sp], #16
  ldp x25, x26, [sp], #16
  ldp x23, x24, [sp], #16
  ldp x21, x22, [sp], #16
  ldp x19, x20, [sp], #16
  ldp x17, x18, [sp], #16
  ldp x15, x16, [sp], #16
  ldp x13, x14, [sp], #16
  ldp x11, x12, [sp], #16
  ldp x9,  x10, [sp], #16
  ldp x7,  x8,  [sp], #16
  ldp x5,  x6,  [sp], #16
  ldp x3,  x4,  [sp], #16
  ldp x1,  x2,  [sp], #16

  /* x1 = restore PC */
  msr ELR_EL1, x1

  /* This is FPSR/SPSR */
  ldp x0, x1, [sp], #16
  msr FPSR, x0
  msr SPSR_EL1, x1

  /* Actual x0 and x1 */
  ldp x0, x1, [sp], #16

  eret

.global signal_handler_wrapper
signal_handler_wrapper:
  // x0 = signal, x1 = handler
  blr x1
  svc svc_thread_switch
.global signal_handler_wrapper_end
signal_handler_wrapper_end:
  nop

.global get_context
get_context:
  // x0 = destination pointer
  stp x19, x20, [x0], #16
  stp x21, x22, [x0], #16
  stp x23, x24, [x0], #16
  stp x25, x26, [x0], #16
  stp x27, x28, [x0], #16
  stp x29, x30, [x0], #16
  mov x1, sp
  // Default pc is current lr
  stp x1, x30, [x0], #16
  ret

.global set_context
set_context:
  // x0 = source pointer
  ldp x19, x20, [x0], #16
  ldp x21, x22, [x0], #16
  ldp x23, x24, [x0], #16
  ldp x25, x26, [x0], #16
  ldp x27, x28, [x0], #16
  ldp x29, x30, [x0], #16
  // pc and sp
  ldp x1,  x2,  [x0], #16
  mov sp, x1
  br x2

.global set_context_from_stack_address
set_context_from_stack_address:
  ldp x0, x1, [sp], #16
  b set_context

.macro SWAP reg1, reg2
  ldp x1, x2, [x0]
  stp \reg1, \reg2, [x0], #16
  mov \reg1, x1
  mov \reg2, x2
.endm

.global swap_context
swap_context:
  // x0 = location of ctx to swap to
  SWAP x19, x20
  SWAP x21, x22
  SWAP x23, x24
  SWAP x25, x26
  SWAP x27, x28

  // Load x29, x30/lr
  ldp x3, x4, [x0]
  // Store current
  stp x29, x30, [x0], #16
  mov x29, x3
  // Don't move new lr just yet

  // Load new sp/pc
  ldp x1, x2, [x0]
  mov x3, sp
  // Store current sp/lr (used as the new pc)
  stp x3, x30, [x0], #16
  // Now we can set the new lr
  mov x30, x4
  // Set new sp
  mov sp, x1

  // Reset x0 to be arg1 of new function
  sub x0, x0, #14*8
  br x2
