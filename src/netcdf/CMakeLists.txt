get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (NETCDF_INCLUDE_DIR AND NETCDF_LIBRARY AND HDF5_LIBRARY AND HDF5_LA_LIBRARY AND CURL_LIBRARY AND SZ_LIBRARY AND Z_LIBRARY)
  if (EXISTS ${NETCDF_INCLUDE_DIR} AND EXISTS ${NETCDF_LIBRARY} AND EXISTS ${HDF5_LIBRARY} AND EXISTS ${HDF5_LA_LIBRARY} AND EXISTS ${CURL_LIBRARY} AND EXISTS ${SZ_LIBRARY} AND EXISTS ${Z_LIBRARY})
    include_directories(${NETCDF_INCLUDE_DIR})

    configure_file("${DLM_NAME}.dlm.in" "${DLM_NAME}.dlm")
    add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

    if (UNIX)
      set_target_properties("${DLM_NAME}"
        PROPERTIES
          SUFFIX ".${IDL_PLATFORM_EXT}.so"
      )
    endif ()

    set_target_properties("${DLM_NAME}"
      PROPERTIES
        PREFIX ""
    )

    target_link_libraries("${DLM_NAME}"
                          ${IDL_LIBRARY}
                          ${NETCDF_LIBRARY}
                          ${HDF5_LIBRARY}
                          ${HDF5_LA_LIBRARY}
                          ${CURL_LIBRARY}
                          ${SZ_LIBRARY}
                          ${Z_LIBRARY})

    install(TARGETS ${DLM_NAME}
      RUNTIME DESTINATION lib/${DIRNAME}
      LIBRARY DESTINATION lib/${DIRNAME}
    )
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})
  endif ()
endif ()

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES netcdf.bmp DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})
