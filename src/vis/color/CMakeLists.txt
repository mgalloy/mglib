get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
file(GLOB TBL_FILES "*.tbl")
file(GLOB PNG_FILES "*.png")
file(GLOB PNG_FILES "*.dat")

install(FILES ${PRO_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${TBL_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${PNG_FILES} DESTINATION lib/vis/${DIRNAME})
install(FILES ${DAT_FILES} DESTINATION lib/vis/${DIRNAME})

install(DIRECTORY cpt-city DESTINATION lib/vis/${DIRNAME})
