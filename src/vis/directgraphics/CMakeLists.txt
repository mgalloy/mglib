get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
file(GLOB CSV_FILES "*.csv")
file(GLOB PNG_FILES "*.png")

install(FILES ${PRO_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${CSV_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${PNG_FILES} DESTINATION lib/vis/${DIRNAME})
