get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

if (TRE_INCLUDE_DIR AND TRE_LIBRARY)
  include_directories(${TRE_INCLUDE_DIR})

  add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

  if (APPLE)
    set_target_properties("${DLM_NAME}"
      PROPERTIES
        PREFIX ""
        SUFFIX ".so"
    )
  endif ()

  target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY} ${TRE_LIBRARY})

  install(TARGETS ${DLM_NAME}
    RUNTIME DESTINATION lib/${DIRNAME}
    LIBRARY DESTINATION lib/${DIRNAME}
  )
  install(FILES "${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})
endif ()

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES big.txt DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})

