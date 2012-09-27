get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

add_subdirectory(animators)
add_subdirectory(easing)
add_subdirectory(utils)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib/vis/${DIRNAME})