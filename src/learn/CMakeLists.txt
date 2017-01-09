get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB PRO_FILES "*.pro")
file(GLOB DATA_FILES "*.csv")
install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES ${DATA_FILES} DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})
