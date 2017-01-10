get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB PRO_FILES "*.pro")
file(GLOB CSV_FILES "*.csv")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES ${CSV_FILES} DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})
