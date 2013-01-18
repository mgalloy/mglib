get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES summer2011.xml athletic.xml athletic-thumbnail.png
  DESTINATION lib/${DIRNAME}
)
