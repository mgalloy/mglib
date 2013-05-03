project(mglib)
set(VERSION_MAJOR "1")
set(VERSION_MINOR "0")
set(VERSION_PATCH "0")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# required version of CMake
cmake_minimum_required(VERSION 2.8.3)
cmake_policy(SET CMP0017 NEW)

set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/mgcmake/Modules
  ${CMAKE_ROOT}/Modules
  ${CMAKE_MODULE_PATH}
)

find_package(Git)
if (GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
    OUTPUT_VARIABLE REVISION
  )
else ()
  set(REVISION "")
endif ()

find_package(IDL REQUIRED)

# always need IDL's include files
include_directories(${Idl_INCLUDE_DIR})

add_subdirectory(src)

file(GLOB_RECURSE PRO_FILES "src/*.pro")
file(GLOB_RECURSE C_FILES "src/*.c")
file(GLOB_RECURSE DLM_FILES "src/*.dlm")
file(GLOB_RECURSE SAV_FILES "src/*.sav")
file(GLOB_RECURSE IDLDOC_FILES "src/*.idldoc")


add_custom_target(doc
  COMMAND ${Idl_EXECUTABLE} -e mg_doc_library
)

add_custom_target(userdoc
  COMMAND ${Idl_EXECUTABLE} -e mg_userdoc_library
)

add_custom_target(dcdoc
  COMMAND ${Idl_EXECUTABLE} -e mg_dcdoc_library
)

add_custom_target(unit
  COMMAND ${Idl_EXECUTABLE} -quiet -IDL_QUIET 1 -e mg_run_unittests 2> /dev/null
)

set_directory_properties(PROPERTIES
  ADDITIONAL_MAKE_CLEAN_FILES "api-docs;api-userdocs;api-dcdocs;mglib-test-results.html")


# setup installer

if (WIN32)
  set(CPACK_GENERATOR ZIP)
else ()
  set(CPACK_GENERATOR TGZ)
endif ()

string(TOLOWER "${CMAKE_SYSTEM_NAME}" MGLIB_SYSTEM_NAME)
set(MGLIB_PACKAGE_VERSION "${VERSION}.${REVISION}")
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${MGLIB_PACKAGE_VERSION}-${MGLIB_SYSTEM_NAME}")

include(CPack)


install(FILES COPYING.rst INSTALL.rst README.rst DESTINATION .)
install(
  FILES
    mg_doc_library.pro
    mg_userdoc_library.pro
  DESTINATION .
)
install(DIRECTORY api-docs DESTINATION .)
install(DIRECTORY api-userdocs DESTINATION .)


add_custom_target(dist
  COMMAND ${CMAKE_MAKE_PROGRAM} package
  COMMENT "custom target to create distribution")
add_dependencies(dist doc userdoc)
