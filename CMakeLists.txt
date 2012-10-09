project(mglib)
set(VERSION_MAJOR "1")
set(VERSION_MINOR "0")
set(VERSION_PATCH "0")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# required version of CMake
cmake_minimum_required(VERSION 2.8.3)

set(CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/CMake/Modules
    ${CMAKE_ROOT}/Modules
    ${CMAKE_MODULE_PATH}
    )

find_package(IDL REQUIRED)

# always need IDL's include files
include_directories(${Idl_INCLUDE_DIR})

add_subdirectory(src)

file(GLOB_RECURSE PRO_FILES "src/*.pro")
file(GLOB_RECURSE C_FILES "src/*.c")
file(GLOB_RECURSE DLM_FILES "src/*.dlm")
file(GLOB_RECURSE SAV_FILES "src/*.sav")
file(GLOB_RECURSE IDLDOC_FILES "src/*.idldoc")

add_custom_command(
  OUTPUT api-docs/index.html
  COMMAND idl -e mg_doc_library
  DEPENDS ${PRO_FILES} ${DLM_FILES} ${SAV_FILES} ${IDLDOC_FILES}
)
add_custom_target(doc DEPENDS api-docs/index.html)

add_custom_command(
  OUTPUT api-userdocs/index.html
  COMMAND idl -e mg_userdoc_library
  DEPENDS ${PRO_FILES} ${DLM_FILES} ${SAV_FILES} ${IDLDOC_FILES}
)
add_custom_target(userdoc DEPENDS api-userdocs/index.html)

add_custom_command(
  OUTPUT api-dcdocs/idldoc-index.csv
  COMMAND idl -e mg_dcdoc_library
  DEPENDS ${PRO_FILES} ${DLM_FILES}
)
add_custom_target(dcdoc DEPENDS api-dcdocs/idldoc-index.csv)

add_custom_command(
 OUTPUT mglib-test-results.html
 COMMAND idl -quiet -IDL_QUIET 1 -e mg_run_unittests 2> /dev/null
 DEPENDS ${PRO_FILES} ${C_FILES} ${DLM_FILES}
)
add_custom_target(unit DEPENDS mglib-test-results.html)

set_directory_properties(PROPERTIES
  ADDITIONAL_MAKE_CLEAN_FILES "api-docs;api-userdocs;api-dcdocs;mglib-test-results.html")

install(FILES COPYING INSTALL README DESTINATION .)
install(
  FILES
    mg_doc_library.pro
    mg_doc_userlibrary.pro
  DESTINATION .
)
install(DIRECTORY api-docs DESTINATION api-docs)
install(DIRECTORY api-userdocs DESTINATION api-userdocs)
