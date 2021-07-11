.section ".text.boot"

.globl _Reset
_Reset:
  // read cpu id, stop every core that is not core 0
  mrs x1, mpidr_el1
  and x1, x1, #3
  cbz x1, on_core_0

on_other_cores:
  // cpu id > 0, stop
  wfe
  b on_other_cores

on_core_0:
  // cpu id == 0
  // set initial stack pointer
  ldr x1, =stack_top
  
  // get the current EL
  mrs x0, CurrentEL
  and x0, x0, #12 // clear reserved bits
  
  // branch if we are running at EL2?
  cmp x0, #12
  bne at_el2

  // If we are using the default firmware of Raspberry Pi
  // We should run at EL2 at beginning. The following code
  // should never be executed. It is just for completeness
  mov x2, #0x5b1
  msr scr_el3, x2
  mov x2, #0x3c9
  msr spsr_el3, x2
  adr x2, at_el2
  msr elr_el3, x2
  eret
  
at_el2:
  // branch if we are running at EL1
  cmp x0, #4
  beq at_el1

  msr sp_el1, x1

  // enable CNTP for EL1
  mrs x0, cnthctl_el2
  orr x0, x0, #3
  msr cnthctl_el2, x0
  msr cntvoff_el2, xzr

  // enable AArch64 in EL1
  mov x0, #(1 << 31) // AArch64
  msr hcr_el2, x0
  mrs x0, hcr_el2

  // We enable FP / SIMD here to make sure that we can 
  // access FPSR register later when saving the PState
  mov x0, #(3 << 20)
  msr cpacr_el1, x0
  isb

  // Setup SCTLR access
  mov x2, #0x0800
  movk x2, #0x30d0, lsl #16
  msr sctlr_el1, x2

  // set up exception handlers
  ldr x2, =el1_table
  msr vbar_el1, x2

  // change execution level to EL1
  mov x2, #0x3c4
  msr spsr_el2, x2
  adr x2, at_el1
  msr elr_el2, x2
  eret

at_el1:
  ldr x1, =stack_top
  mov sp, x1
  
  // jump to C code, should not return
  bl entry

  // for failsafe, halt this core too
  b on_other_cores

  .macro ventry label
    .align 7
    b \label
  .endm

.align 11
el1_table:
  ventry invalid_entry // Synchronous EL1t
  ventry invalid_entry // IRQ EL1t
  ventry invalid_entry // FIQ EL1t
  ventry invalid_entry // Error EL1t
  
  ventry invalid_entry // Synchronous EL1h
  ventry invalid_entry // IRQ EL1h
  ventry invalid_entry // FIQ EL1h
  ventry invalid_entry // Error EL1h
  
  ventry handle_svc // Synchronous 64-bit EL0
  ventry invalid_entry // IRQ 64-bit EL0
  ventry invalid_entry // FIQ 64-bit EL0
  ventry invalid_entry // Error 64-bit EL0
  
  ventry invalid_entry // Synchronous 32-bit EL0
  ventry invalid_entry // IRQ 32-bit EL0
  ventry invalid_entry // FIQ 32-bit EL0
  ventry invalid_entry // Error 32-bit EL0
