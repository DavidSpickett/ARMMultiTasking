set( KERNEL_SOURCES ${KERNEL_SOURCES}
  ${CMAKE_SOURCE_DIR}/src/hw/arm_common/port.c
  ${CMAKE_SOURCE_DIR}/src/hw/arm_common/gic.c
  ${CMAKE_SOURCE_DIR}/src/hw/driver/raspi4_serial.c
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/port.c
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/startup.s
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/yield.S
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/yield.S
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/uart.c
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/mbox.c
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/exception.c
  ${CMAKE_SOURCE_DIR}/src/hw/raspi4/libs/string.c
)

set( PREFIX       "aarch64-none-elf-" )
# Don't generate NEON
set( PLATFORM     "-mcpu=cortex-a72 -mgeneral-regs-only -mstrict-align" )
# O3 LTO UBSAN trace demo needs some extra
set( STACK_SIZE 3 )
set( LINKER_SCRIPT "kernel_rpi.ld" )
set( SEMIHOSTING OFF )
