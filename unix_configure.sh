#!/bin/sh

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$HOME/software/mglib \
  -DMARKDOWN_INCLUDE_DIR=$HOME/include \
  -DMARKDOWN_LIBRARY=$HOME/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR=$HOME/include \
  -DTRE_LIBRARY=$HOME/lib/libtre.a \
  -DGSL_INCLUDE_DIR=$HOME/include \
  -DGSL_LIBRARY_DIR=$HOME/lib \
  -DIDLdoc_DIR=~/projects/idldoc/src \
  -Dmgunit_DIR=~/projects/mgunit/src \
  -Didlwave_DIR=~/software/idlwave \
  ..

