#!/bin/sh

# using static libtre.a requires adding an --enable-static flag to the tre
# formula in /usr/local/Library/Formula/tre.rb

cmake \
  -DCMAKE_INSTALL_PREFIX=$HOME/projects/mglib-install \
  -DMARKDOWN_INCLUDE_DIR=$HOME/include \
  -DMARKDOWN_LIBRARY=$HOME/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR=$HOME/include \
  -DTRE_LIBRARY=$HOME/lib/libtre.a \
  -DGSL_INCLUDE_DIR=$HOME/include \
  -DGSL_LIBRARY_DIR=$HOME/lib \
  -DIDLdoc_DIR=~/projects/idldoc/src \
  -Dmgunit_DIR=~/projects/mgunit/src \
  .

