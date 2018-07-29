project(mglib)
set(VERSION_MAJOR "1")
set(VERSION_MINOR "2")
set(VERSION_PATCH "0")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

# required version of CMake
cmake_minimum_required(VERSION 3.1.3)
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
find_package(idlwave)

# always need IDL's include files
include_directories(${IDL_INCLUDE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/dist_tools)

add_subdirectory(src)
add_subdirectory(scripts)

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
    COMMENT build developer API documentation
  )

  add_custom_target(userdoc
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_userdoc_library -args ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT build user API documentation
  )

  find_package(LATEX)

  set(TEX_BASENAME "index")
  set(TEX_CLEAN_FILES "${TEX_BASENAME}.log;${TEX_BASENAME}.aux;${TEX_BASENAME}.idx;${TEX_BASENAME}.out;${TEX_BASENAME}.toc;${TEX_BASENAME}.blg")

  if (PDFLATEX_COMPILER)
    get_filename_component(LATEX_BINDIR "${PDFLATEX_COMPILER}" PATH)
    set(XELATEX_COMPILER "${LATEX_BINDIR}/xelatex")
  endif ()

  if (EXISTS "${XELATEX_COMPILER}")
    message(STATUS "Generating docs with ${XELATEX_COMPILER}")

    set(TEX_CMD TEXINPUTS="${IDLdoc_DIR}/resources:" ${XELATEX_COMPILER} -interaction=batchmode ${CMAKE_CURRENT_BINARY_DIR}/api-bookdocs/index.tex)

    set_directory_properties(PROPERTIES
      ADDITIONAL_MAKE_CLEAN_FILES "${TEX_CLEAN_FILES}"
    )

    add_custom_target(bookdoc
      COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_bookdoc_library -args ${CMAKE_CURRENT_SOURCE_DIR}\; cd ${CMAKE_CURRENT_BINARY_DIR}/api-bookdocs\; ${TEX_CMD}\; ${TEX_CMD}\; ${TEX_CMD}
      COMMENT build user API documentation in LaTeX
    )
  endif ()

  add_custom_target(upload_userdoc
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/upload_userdoc.sh ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT upload user documentation to idldev.com:~/docs.idldev.com/mglib
  )

  add_custom_target(dcdoc
    COMMAND ${IDL_EXECUTABLE} -IDL_STARTUP "\"\"" -IDL_PATH "+${CMAKE_CURRENT_SOURCE_DIR}/src${SEP_CHAR}${CMAKE_CURRENT_SOURCE_DIR}${SEP_CHAR}+${IDLdoc_DIR}${SEP_CHAR}\"<IDL_DEFAULT>\"" -e mg_dcdoc_library -args ${CMAKE_CURRENT_SOURCE_DIR}
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
  ADDITIONAL_MAKE_CLEAN_FILES "api-docs;api-userdocs;api-dcdocs;api-bookdocs;mglib-test-results.html")

if (idlwave_FOUND)
  configure_file("idlwave_catalog.cmake.in" "idlwave_catalog.cmake" @ONLY)
  add_custom_target(idlwave_catalog
    COMMAND ${idlwave_DIR}/idlwave_catalog -v mglib
    WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib)
endif ()

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

configure_file(idlpackage.json.in idlpackage.json @ONLY)
install(FILES
          ${CMAKE_CURRENT_BINARY_DIR}/idlpackage.json
        DESTINATION .)

install(FILES
          LICENSE
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
