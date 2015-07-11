get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

find_package(Plasma)

if (WIN32 OR CYGWIN)
  set(SEP_CHAR ";")
else ()
  set(SEP_CHAR ":")
endif ()

if (PLASMA_FOUND)
  if (EXISTS ${PLASMA_INCLUDE_DIR} AND EXISTS ${PLASMA_LIBRARY_DIR})
    add_custom_command(
      OUTPUT mg_plasma.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
      COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "\"+${CMAKE_SOURCE_DIR}/src${SEP_CHAR}<IDL_DEFAULT>\"" -quiet -IDL_QUIET 1 -e \"mg_make_plasma_bindings, header_directory='${PLASMA_INCLUDE_DIR}', lib_directory='${PLASMA_LIBRARY_DIR}'\"
      DEPENDS
        mg_plasma_bindings.h
        mg_make_plasma_bindings.pro
    )
    add_custom_target(mg_plasma
      ALL
      DEPENDS
        ${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT})
    set_directory_properties(PROPERTIES
      ADDITIONAL_MAKE_CLEAN_FILES
        "mg_plasma.c;mg_plasma.dlm;mg_plasma.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}"
    )

    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
      DESTINATION lib/${DIRNAME}
    )
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm
      DESTINATION lib/${DIRNAME}
    )
  else ()
    message(WARNING "Plasma library specified, but does not exist")
  endif ()
endif ()
