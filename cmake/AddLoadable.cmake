# Only here for the shell demo
function(add_loadable_no_test PARENT NAME)
  __add_loadable(${PARENT} ${NAME} OFF OFF)
endfunction(add_loadable_no_test)

function(add_loadable PARENT NAME)
  __add_loadable(${PARENT} ${NAME} OFF ON)
endfunction(add_loadable)

function(add_shared_loadable PARENT NAME)
  __add_loadable(${PARENT} ${NAME} ON ON)
endfunction(add_shared_loadable)

function(__add_loadable PARENT NAME PIE TEST)
  # Enable loading in the parent kernel
  if( BP_LOWER STREQUAL "arm" )
    set( CODE_PAGE_SIZE 9216 )
  elseif( BP_LOWER STREQUAL "thumb" )
    set( CODE_PAGE_SIZE 7168 )
  elseif( BP_LOWER STREQUAL "aarch64" )
    # Due to ardp alignment etc., we need more room
    set( CODE_PAGE_SIZE 11264 )
  elseif( BP_LOWER STREQUAL "raspi4" )
    set( CODE_PAGE_SIZE 11264 )
  else()
    message(FATAL_ERROR "Can't set CODE_PAGE_SIZE for \"${BP_LOWER}\".")
  endif()

  target_compile_definitions(${PARENT} PRIVATE CODE_PAGE_SIZE=${CODE_PAGE_SIZE})
  # Need elf parser
  target_sources(${PARENT} PRIVATE ${CMAKE_SOURCE_DIR}/src/kernel/elf.c)

  add_executable(${NAME} ${CMAKE_SOURCE_DIR}/demos/${PARENT}/${NAME}.c)
  add_dependencies(${NAME} ${PARENT})

  set(LINK_CMD "-Wl,--defsym=code_page_size=${CODE_PAGE_SIZE},--build-id=none,")
  if(PIE)
    target_compile_options(${NAME} PRIVATE -fpie -shared -fPIC)
    target_link_libraries(${NAME} PRIVATE "${LINK_CMD}-T,${CMAKE_SOURCE_DIR}/linker/pie_loadable.ld,-pie,-shared")
    if(SANITIZERS)
      target_sources(${NAME} PRIVATE ${CMAKE_SOURCE_DIR}/src/common/ubsan.c)
    endif()
  else()
    target_link_libraries(${NAME} PRIVATE "${LINK_CMD}-T,${CMAKE_SOURCE_DIR}/linker/loadable.ld,--just-symbols=${PARENT}")
  endif()

  # TODO: not ideal, we end up building them during the lit run
  add_dependencies(run_${PARENT} ${NAME})
  if(TEST)
    add_dependencies(test_${PARENT} ${NAME})
  endif()
  add_dependencies(debug_${PARENT} ${NAME})
endfunction(__add_loadable)
