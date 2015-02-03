get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (WIN32 OR CYGWIN)
  set(SEP_CHAR ";")
else ()
  set(SEP_CHAR ":")
endif ()

if (ZEROMQ_INCLUDE_DIR AND ZEROMQ_LIBRARY_DIR)
  if (EXISTS ${ZEROMQ_INCLUDE_DIR} AND EXISTS ${ZEROMQ_LIBRARY_DIR})
    add_custom_command(
      OUTPUT mg_zeromq.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
      COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "\"+${CMAKE_SOURCE_DIR}/src${SEP_CHAR}<IDL_DEFAULT>\"" -quiet -IDL_QUIET 1 -e \"mg_make_zeromq_bindings, header_directory='${ZEROMQ_INCLUDE_DIR}', lib_directory='${ZEROMQ_LIBRARY_DIR}'\"
      DEPENDS
        mg_zeromq_bindings.h
        mg_make_zeromq_bindings.pro
    )
    add_custom_target(mg_zeromq
      ALL
      DEPENDS
        ${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT})
    set_directory_properties(PROPERTIES
      ADDITIONAL_MAKE_CLEAN_FILES
        "mg_zeromq.c;mg_zeromq.dlm;mg_zeromq.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}"
    )

    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
      DESTINATION lib/${DIRNAME}
    )
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm
      DESTINATION lib/${DIRNAME}
    )
  else ()
    message(WARNING "ZeroMQ library specified, but does not exist")
  endif ()
endif ()