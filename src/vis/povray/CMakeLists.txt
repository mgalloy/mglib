get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
file(GLOB PNG_FILES "*.png")

install(FILES ${PRO_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${PNG_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES mg_povray_mpidl.tt cow-example.mov DESTINATION lib/vis/${DIRNAME})
