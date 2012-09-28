get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/dist_tools/${DIRNAME})
