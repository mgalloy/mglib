#!/bin/sh

# using static libtre.a requires adding an --enable-static flag to the tre
# formula in /usr/local/Library/Formula/tre.rb

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=~/software/mglib \
  -DMARKDOWN_INCLUDE_DIR=/usr/local/include \
  -DMARKDOWN_LIBRARY=/usr/local/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR=/usr/local/include \
  -DTRE_LIBRARY=/usr/local/lib/libtre.a \
  -DGSL_INCLUDE_DIR=/usr/local/include \
  -DGSL_LIBRARY_DIR=/usr/local/lib \
  ..

