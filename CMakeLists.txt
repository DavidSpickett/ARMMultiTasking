project(MultiTaskingDemo)
cmake_minimum_required( VERSION 3.7 )
set( CMAKE_EXPORT_COMPILE_COMMANDS ON )

set( BUILD_PLATFORM "arm" CACHE STRING "Architecture to build for." )
set( OPT_LEVEL "3" CACHE STRING "Compiler optmisation level." )
option( SANITIZERS "Enable UBSAN" OFF )
option( LTO "Enable link time optimisation." OFF )
option( CCACHE "Enable ccache." ON )
set( SEMIHOSTING ON )
set( STACK_SIZE 2 ) # In KB

string( TOLOWER "${BUILD_PLATFORM}" BP_LOWER )

if(CCACHE)
  find_program(CCACHE_FOUND ccache)
  if(NOT CCACHE_FOUND)
    message(FATAL_ERROR "ccache not found!")
  endif()
  message(STATUS "ccache is enabled")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set( KERNEL_SOURCES )
add_subdirectory(src)

if( BP_LOWER STREQUAL "arm" )
  include(src/hw/arm_virt/CMakeLists.txt)
elseif( BP_LOWER STREQUAL "aarch64" )
  include(src/hw/aarch64_virt/CMakeLists.txt)
elseif( BP_LOWER STREQUAL "thumb" )
  include(src/hw/thumb_lm3s6965evb/CMakeLists.txt)
elseif( BP_LOWER STREQUAL "raspi4" )
  include(src/hw/raspi4/CMakeLists.txt)
else()
  message(FATAL_ERROR "Invalid platform \"${BP_LOWER}\". \
  Expected one of \"arm\", \"thumb\", \"aarch64\", \"raspi4\".")
endif()

set( CMAKE_C_COMPILER "${PREFIX}gcc" )
set( CMAKE_CXX_COMPILER "${PREFIX}g++" )

set( CFLAGS "-DSTACK_SIZE=${STACK_SIZE} -g3 -O${OPT_LEVEL} -Wall -Werror -Wextra")

# Ignore lto type mismatch error which triggers at O0 for UBSAN handlers
# I *think*, due to https://gcc.gnu.org/bugzilla/show_bug.cgi?id=78562#c6
if(SANITIZERS AND LTO)
  set( CFLAGS "${CFLAGS} -Wno-error=lto-type-mismatch")
endif()

# -fno-common to disallow variables being present in multiple compliaton units
set( CFLAGS "${CFLAGS} -ffreestanding -nostdlib -fno-common" )
add_definitions( -DSRC_ROOT=\"${CMAKE_SOURCE_DIR}\" )

if(LTO)
  set( CFLAGS "${CFLAGS} -flto -ffunction-sections" )
endif()

if(SANITIZERS)
  set( CFLAGS "${CFLAGS} -fsanitize=undefined" )
endif(SANITIZERS)

if(SEMIHOSTING)
  set( CFLAGS "${CFLAGS} -DSEMIHOSTING_ENABLED" )
endif(SEMIHOSTING)

set( CMAKE_C_FLAGS "${PLATFORM} ${CFLAGS} -std=gnu11" )
set( CMAKE_CXX_FLAGS "${PLATFORM} ${CFLAGS} -fno-rtti -fno-exceptions -fno-unwind-tables -std=c++11" )

message(STATUS "BUILD_PLATFORM is ${BP_LOWER}")
message(STATUS "OPT_LEVEL is -O${OPT_LEVEL}")
message(STATUS "SANITIZERS are ${SANITIZERS}")
message(STATUS "LTO is ${LTO}")
message(STATUS "STACK_SIZE is ${STACK_SIZE}KB")
message(STATUS "SEMIHOSTING is ${SEMIHOSTING}")
message(STATUS "LINKER_SCRIPT is ${LINKER_SCRIPT}")

# Convenient build target for CI
add_custom_target(make_demos)

include(cmake/AddDemo.cmake)
include(cmake/AddLoadable.cmake)

add_subdirectory(demos)
