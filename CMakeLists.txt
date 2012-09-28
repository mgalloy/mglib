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

install(FILES COPYING INSTALL README DESTINATION .)
