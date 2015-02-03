get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (MARKDOWN_INCLUDE_DIR AND MARKDOWN_LIBRARY)
  if (EXISTS ${MARKDOWN_INCLUDE_DIR} AND EXISTS ${MARKDOWN_LIBRARY})
    include_directories(${MARKDOWN_INCLUDE_DIR})

    configure_file("${DLM_NAME}.dlm.in" "${DLM_NAME}.dlm")
    add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

    if (APPLE)
      set_target_properties("${DLM_NAME}"
        PROPERTIES
          SUFFIX ".${IDL_PLATFORM_EXT}.so"
      )
    endif ()

    set_target_properties("${DLM_NAME}"
      PROPERTIES
        PREFIX ""
    )

    target_link_libraries("${DLM_NAME}" ${IDL_LIBRARY} ${MARKDOWN_LIBRARY})

    install(TARGETS ${DLM_NAME}
      RUNTIME DESTINATION lib/${DIRNAME}
      LIBRARY DESTINATION lib/${DIRNAME}
    )
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})
  endif ()
endif ()

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})
