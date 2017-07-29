get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
set(DLM_NAME mg_${DIRNAME})

file(GLOB PRO_FILES "*.pro")

add_subdirectory(data)
add_subdirectory(estimators)
add_subdirectory(metrics)
add_subdirectory(model_selection)
add_subdirectory(transformers)

install(FILES ${PRO_FILES} DESTINATION lib/${DIRNAME})
install(FILES .idldoc DESTINATION lib/${DIRNAME})
