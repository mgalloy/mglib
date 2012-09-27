set(DLM_NAME mg_flow)

add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

if (APPLE) 
  set_target_properties("${DLM_NAME}" 
    PROPERTIES 
      PREFIX ""
      SUFFIX ".so"
  )
endif ()

target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY})
