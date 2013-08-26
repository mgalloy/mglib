#!/bin/sh

rm -rf build

rm -rf _CPack_Packages
rm -f  CPackConfig.cmake
rm -f  CPackSourceConfig.cmake
rm -f  install_manifest.txt

rm -f CMakeCache.txt

rm -f  cmake_install.cmake
rm -rf CMakeFiles

rm -rf src/CMakeFiles
rm -f  src/cmake_install.cmake

SRCDIRS="analysis cmdline_tools collection cula dist_tools envi fileio googlevoice gsl hdf hdf5 indices install_tools introspection itools markdown misc net netcdf objects profiling save strings templating textmarkup updater vis widgets zlib"

for d in $SRCDIRS; do
  rm -rf src/$d/CMakeFiles
  rm -f  src/$d/cmake_install.cmake
done

VISDIRS="animation animation/animators animation/easing animation/utils color directgraphics flow geometry googlechart graphs images misc objectgraphics povray surfaces tables text treemaps util vtk x3d"

for d in $VISDIRS; do
  rm -rf src/vis/$d/CMakeFiles
  rm -f  src/vis/$d/cmake_install.cmake
done