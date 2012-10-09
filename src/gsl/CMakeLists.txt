get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (GSL_INCLUDE_DIR AND GSL_LIBRARY_DIR)
  add_custom_command(
    OUTPUT mg_gsl.${Idl_PLATFORM_EXT}.${Idl_DLL_EXT}
    COMMAND idl -quiet -IDL_QUIET 1 -e \"mg_make_gsl_bindings, header_directory='${GSL_INCLUDE_DIR}', lib_directory='${GSL_LIBRARY_DIR}'\"
    DEPENDS
      mg_gsl_sf_ellint_bindings.h
      mg_gsl_sf_zeta_bindings.h
      mg_make_gsl_bindings.pro
  )
  add_custom_target(mg_gsl
    ALL
    DEPENDS
      mg_gsl.${Idl_PLATFORM_EXT}.${Idl_DLL_EXT})
  set_directory_properties(PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES
      "mg_gsl.c;mg_gsl.dlm;mg_gsl.${Idl_PLATFORM_EXT}.${Idl_DLL_EXT}"
  )
endif ()
file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})

