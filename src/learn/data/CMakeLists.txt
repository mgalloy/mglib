get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB PRO_FILES "*.pro")
file(GLOB DATA_FILES "*.csv")
install(FILES ${PRO_FILES} DESTINATION lib/learn/${DIRNAME})
install(FILES ${DATA_FILES} DESTINATION lib/learn/${DIRNAME})
install(FILES .idldoc DESTINATION lib/learn/${DIRNAME})
