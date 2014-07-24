project(mglib)
set(VERSION_MAJOR "1")
set(VERSION_MINOR "0")
set(VERSION_PATCH "0")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# required version of CMake
cmake_minimum_required(VERSION 2.8.3)
cmake_policy(SET CMP0017 NEW)
if (POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif ()

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

include(${CMAKE_SOURCE_DIR}/mgcmake/GetDate.cmake)
LONG_TODAY(mglib_BUILD_DATE)
message(STATUS "Build date = ${mglib_BUILD_DATE}")

find_package(IDL REQUIRED)
find_package(IDLdoc)
find_package(mgunit)


# always need IDL's include files
include_directories(${IDL_INCLUDE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/dist_tools)

add_subdirectory(src)

file(GLOB_RECURSE PRO_FILES "src/*.pro")
file(GLOB_RECURSE C_FILES "src/*.c")
file(GLOB_RECURSE DLM_FILES "src/*.dlm")
file(GLOB_RECURSE SAV_FILES "src/*.sav")
file(GLOB_RECURSE IDLDOC_FILES "src/*.idldoc")


if (WIN32 OR CYGWIN)
  set(SEP_CHAR ";")
else ()
  set(SEP_CHAR ":")
endif ()

if (IDLdoc_FOUND)
  add_custom_target(doc
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_doc_library -args ${CMAKE_CURRENT_SOURCE_DIR}
  )

  add_custom_target(userdoc
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_userdoc_library -args ${CMAKE_CURRENT_SOURCE_DIR}
  )

  add_custom_target(upload_userdoc
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/upload_userdoc.sh ${CMAKE_CURRENT_BINARY_DIR}
  )

  add_custom_target(dcdoc
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "+${CMAKE_CURRENT_SOURCE_DIR}/lib${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_dcdoc_library -args ${CMAKE_CURRENT_SOURCE_DIR}
  )

  add_custom_target(dcdoc_dist
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/make_dc_dist.sh ${VERSION}
  )
endif ()

if (mgunit_FOUND)
  add_custom_target(unit
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/unit${SEP_CHAR}+${mgunit_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -quiet -e mg_run_unittests
  )
endif ()

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

install(FILES
          COPYING.rst
          INSTALL.rst
          README.rst
        DESTINATION .)
install(DIRECTORY
          examples
        DESTINATION .)

if (IDLdoc_FOUND)
  install(DIRECTORY ${CMAKE_BINARY_DIR}/api-docs DESTINATION . OPTIONAL)
  install(DIRECTORY ${CMAKE_BINARY_DIR}/api-userdocs DESTINATION . OPTIONAL)
endif ()

if (mgunit_FOUND)
  install(DIRECTORY unit DESTINATION .)
endif ()

add_custom_target(dist
  COMMAND ${CMAKE_MAKE_PROGRAM} package
  COMMENT "custom target to create distribution")

if (IDLdoc_FOUND)
  add_dependencies(dist doc userdoc)
endif ()
