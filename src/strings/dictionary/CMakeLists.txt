get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

install(FILES big.txt DESTINATION lib/strings/${DIRNAME})
install(FILES spell_hash.sav DESTINATION lib/strings/${DIRNAME})
