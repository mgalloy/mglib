get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
file(GLOB DOT_FILES "*.dot")

install(FILES ${PRO_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${DOT_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES graphs.idldoc DESTINATION lib/vis/${DIRNAME})
