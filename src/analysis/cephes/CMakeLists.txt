get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB C_FILES "*.c")

configure_file("${DLM_NAME}.dlm.in" "${DLM_NAME}.dlm")
add_library("${DLM_NAME}" SHARED "${C_FILES}")

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

target_link_libraries("${DLM_NAME}" ${IDL_LIBRARY})

install(TARGETS ${DLM_NAME}
  RUNTIME DESTINATION lib/analysis/${DIRNAME}
  LIBRARY DESTINATION lib/analysis/${DIRNAME}
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${DLM_NAME}.dlm" DESTINATION lib/analysis/${DIRNAME})

#file(GLOB PRO_FILES "*.pro")
#install(FILES ${PRO_FILES} DESTINATION lib/analysis/${DIRNAME})
