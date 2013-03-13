get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

include_directories(".")

add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

if (APPLE)
  set_target_properties("${DLM_NAME}"
    PROPERTIES
      PREFIX ""
      SUFFIX ".${Idl_PLATFORM_EXT}.so"
  )
endif ()

find_library(ZLIB_LIBRARY
  NAMES z
  PATHS ${Idl_LIBRARY_PATH}
)

target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY} ${ZLIB_LIBRARY})

install(TARGETS ${DLM_NAME}
  RUNTIME DESTINATION lib/${DIRNAME}
  LIBRARY DESTINATION lib/${DIRNAME}
)
install(FILES "${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})

