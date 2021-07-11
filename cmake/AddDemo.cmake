function(add_demo NAME MAX_THREADS)
  __add_demo(${NAME} "log" ${MAX_THREADS})
endfunction()

function(add_demo_expect_test NAME MAX_THREADS)
  __add_demo(${NAME} "expect" ${MAX_THREADS})
endfunction()

function(add_demo_no_test NAME MAX_THREADS)
  __add_demo(${NAME} "none" ${MAX_THREADS})
endfunction()

function(__add_demo NAME TEST_TYPE MAX_THREADS)
  # TODO: source file properties are only visible to the current CMakeLists.txt
  # Really, we shouldn't be using this hack. Instead using the normal compiler detection
  # mechanisms.
  set( ASM_SOURCES ${KERNEL_SOURCES} )
  list( FILTER ASM_SOURCES INCLUDE REGEX ".*\.(s|S)$" )
  set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE C)

  add_executable ( ${NAME} ${CMAKE_SOURCE_DIR}/demos/${NAME}/${NAME}.c ${KERNEL_SOURCES} )
  target_compile_definitions(${NAME} PRIVATE MAX_THREADS=${MAX_THREADS})

  target_link_libraries(${NAME} PRIVATE "-Wl,-T,${CMAKE_SOURCE_DIR}/linker/${LINKER_SCRIPT},-lgcc,-lc,-N,--build-id=none")

  add_custom_command(TARGET ${NAME} PRE_BUILD
    COMMAND eval "${CMAKE_C_COMPILER} --version | head -n 1"
    VERBATIM)
  add_dependencies(make_demos ${NAME})

  if (NOT BP_LOWER STREQUAL "raspi4")
    add_custom_target(run_${NAME})
    add_dependencies(run_${NAME} ${NAME})

    add_custom_command(TARGET run_${NAME} POST_BUILD
      COMMAND eval "${QEMU}${NAME}"
     VERBATIM)

    add_custom_target(debug_${NAME})
    add_dependencies(debug_${NAME} ${NAME})

    add_custom_command(TARGET debug_${NAME} POST_BUILD
      COMMAND eval "${QEMU}${NAME} -s -S"
      VERBATIM)
  else()
    # Generate kernel images
    add_custom_command(TARGET ${NAME} POST_BUILD
      COMMAND eval "${PREFIX}objcopy -O binary ${NAME} kernel8.img"
     VERBATIM)
  endif()

  if(NOT TEST_TYPE STREQUAL "none")
    # This could be done with add_test, but then we wouldn't see the failure output.
    add_custom_target(test_${NAME} ALL)
    add_dependencies(test_${NAME} ${NAME})

    # Run qemu with serial output into a log file.
    # If it exited unexpectedly print the log and fail the test.
    # Most often happens on a UBSAN failure.
    set(QEMU_GET_LOG
      "${QEMU}${NAME} -serial file:${NAME}_got.log > /dev/null 2>&1 || (cat ${NAME}_got.log && exit 1)")

    if(TEST_TYPE STREQUAL "log")
      add_custom_command(TARGET test_${NAME} POST_BUILD
        # If Qemu runs successfully then diff the serial output and expected output
        COMMAND eval "${QEMU_GET_LOG}"
        COMMAND diff ${CMAKE_SOURCE_DIR}/demos/${NAME}/expected.log ${NAME}_got.log
        VERBATIM)
    elseif(TEST_TYPE STREQUAL "expect")
      add_custom_command(TARGET test_${NAME} POST_BUILD
        COMMAND eval "${QEMU_GET_LOG}"
        COMMAND ${CMAKE_SOURCE_DIR}/demos/${NAME}/expected.exp
        VERBATIM)
    else()
      message(FATAL_ERROR "Unknown testing type \"${TEST_TYPE}\" for demo \"${NAME}\"")
    endif()
  endif(NOT TEST_TYPE STREQUAL "none")
endfunction(__add_demo)
