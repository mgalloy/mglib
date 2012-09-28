get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

if (APPLE) 
  set_target_properties("${DLM_NAME}" 
    PROPERTIES 
      PREFIX ""
      SUFFIX ".so"
  )
endif ()

target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY})

add_subdirectory(bindings)
add_subdirectory(cidl)

install(FILES "${DLM_NAME}.dlm" DESTINATION lib/${DIRNAME})

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(PROGRAMS mg_use DESTINATION bin)
install(FILES .idldoc DESTINATION lib/${DIRNAME})
