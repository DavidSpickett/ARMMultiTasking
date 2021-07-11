ENTRY(_Reset)

SECTIONS {
 . = 0x80000;

 .text : {
   KEEP(*(.text.boot))
   *(.text*)
   *(.rodata*)
   . = ALIGN(8); /* align to pointer size (8 for AArch64) */
   _init_array = . ;
   *(.init_array*)
   _einit_array = . ;
   _etext = . ;
 }

 . = ALIGN(16);

 .data : {
   _data = . ;
   *(.data)
   *(.thread_vars)
   . = ALIGN(16);
   _edata = . ;
 }

 . = ALIGN(16); /* align 16 for AArch64 */
 . = . + 0xC00; /* 3kB of stack for kernel */
 stack_top = . ;

 .bss (NOLOAD) : {
   _bstart = . ;
   /* Thread structs go first! */
   *(.thread_structs)
   /* then the important zero init globals */
   *(.thread_vars_bss)
   *(.bss COMMON)
   /* Putting this first minimises waste on Arm/Thumb due to alignment below */
   *(.code_page_backing)
   /* AArch64 PIE requires that programs start on 4k alignemnt for adrp usage. */
   . = ALIGN(0x1000);
   /* on the end in case of weird stuff writing beyond */
   *(.code_page)
   . = ALIGN(16);
   _bend = . ;
 }

 /* Don't need unwinding info on Arm */
 /DISCARD/ : { *(.ARM.exidx* ) }
}
