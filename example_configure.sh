#!/bin/sh

# using static libtre.a requires adding an --enable-static flag to the tre
# formula in /usr/local/Library/Formula/tre.rb

cmake \
  -DCMAKE_INSTALL_PREFIX=~/projects/mglib-install \
  -DMARKDOWN_INCLUDE_DIR=/usr/local/include \
  -DMARKDOWN_LIBRARY=/usr/local/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR=/usr/local/include \
  -DTRE_LIBRARY=/usr/local/lib/libtre.a \
  -DGSL_INCLUDE_DIR=/usr/local/include/gsl \
  -DGSL_LIBRARY_DIR=/usr/local/lib \
  .

