get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

find_package(OpenCL)

if (OpenCL_INCLUDE_DIRS AND OpenCL_LIBRARIES)
  if (EXISTS ${OpenCL_INCLUDE_DIRS} AND EXISTS ${OpenCL_LIBRARIES})
    include_directories(${OpenCL_INCLUDE_DIRS})

    configure_file("${DLM_NAME}.dlm.in" "${DLM_NAME}.dlm")
    add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c" "mg_hashtable.c")

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

    target_link_libraries("${DLM_NAME}" ${IDL_LIBRARY} ${OpenCL_LIBRARIES})

    install(TARGETS ${DLM_NAME}
      RUNTIME DESTINATION lib/${DIRNAME}
      LIBRARY DESTINATION lib/${DIRNAME}
    )
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})

    file(GLOB PRO_FILES "*.pro")
    install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
    file(GLOB CL_FILES "*.cl")
    install(FILES ${CL_FILES} DESTINATION lib/${DIRNAME})
    install(FILES .idldoc DESTINATION lib/${DIRNAME})
  else ()
    message(WARNING "OpenCL library specified, but does not exist")
  endif ()
endif ()


