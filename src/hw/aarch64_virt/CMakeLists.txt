set( KERNEL_SOURCES ${KERNEL_SOURCES}
  ${CMAKE_SOURCE_DIR}/src/hw/arm_common/port.c
  ${CMAKE_SOURCE_DIR}/src/hw/arm_common/gic.c
  ${CMAKE_SOURCE_DIR}/src/hw/driver/virt_serial.c
  ${CMAKE_SOURCE_DIR}/src/hw/aarch64_virt/port.c
  ${CMAKE_SOURCE_DIR}/src/hw/aarch64_virt/startup.s
  ${CMAKE_SOURCE_DIR}/src/hw/aarch64_virt/yield.S
)

set( PREFIX       "aarch64-none-elf-" )
# Don't generate NEON
set( PLATFORM     "-mcpu=cortex-a57 -mgeneral-regs-only" )
set( QEMU         "qemu-system-aarch64 -M virt -cpu cortex-a57 -m 1M -nographic -semihosting -device loader,file=" )
# O3 LTO UBSAN trace demo needs some extra
set( STACK_SIZE 3 )
set( LINKER_SCRIPT "kernel_virt.ld" )
