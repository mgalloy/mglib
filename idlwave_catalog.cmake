#execute_process(COMMAND ${idlwave_DIR}/idlwave_catalog -v mglib
#                WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib)

message(STATUS ${idlwave_DIR}/idlwave_catalog -v mglib)
message(STATUS ${CMAKE_INSTALL_PREFIX}/lib)

message(STATUS "CPACK_PACKAGE_DIRECTORY = ${CPACK_PACKAGE_DIRECTORY}")
