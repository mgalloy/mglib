set(DLM_NAME mg_markdown)

add_library("${DLM_NAME}" SHARED "${DLM_NAME}.c")

if (APPLE) 
  execute_process(
    COMMAND sh -c "dirname ${Idl_LIBRARY} | tr -d '\n'"
    OUTPUT_VARIABLE IDL_LIBDIR
  )
  set_target_properties("${DLM_NAME}" 
    PROPERTIES 
      LINK_FLAGS "-L${IDL_LIBDIR} -lidl"
      PREFIX ""
      SUFFIX ".so"
  )
endif ()

target_link_libraries("${DLM_NAME}" ${Idl_LIBRARY})