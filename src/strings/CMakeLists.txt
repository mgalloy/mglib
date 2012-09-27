set(DLM_NAME mg_strings)

if (TRE_INCLUDE_DIR AND TRE_LIBRARY)
  include_directories(${TRE_INCLUDE_DIR})
  
  add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

  if (APPLE) 
    set_target_properties("${DLM_NAME}" 
      PROPERTIES 
        PREFIX ""
        SUFFIX ".so"
    )
  endif ()

  target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY} ${TRE_LIBRARY})
endif ()
