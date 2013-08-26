get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (GSL_INCLUDE_DIR AND GSL_LIBRARY_DIR)
  add_custom_command(
    OUTPUT mg_gsl.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "+${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -quiet -IDL_QUIET 1 -e \"mg_make_gsl_bindings, header_directory='${GSL_INCLUDE_DIR}', lib_directory='${GSL_LIBRARY_DIR}'\"
    DEPENDS
      mg_gsl_sf_ellint_bindings.h
      mg_gsl_sf_zeta_bindings.h
      mg_make_gsl_bindings.pro
  )
  add_custom_target(mg_gsl
    ALL
    DEPENDS
      ${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT})
  set_directory_properties(PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
      "mg_gsl.c;mg_gsl.dlm;mg_gsl.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}"
  )

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.${IDL_PLATFORM_EXT}.${IDL_DLL_EXT}
    DESTINATION lib/${DIRNAME}
  )
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm
    DESTINATION lib/${DIRNAME}
  )
endif ()
