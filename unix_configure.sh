#!/bin/sh

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=$HOME/software/mglib \
  -DMARKDOWN_INCLUDE_DIR:PATH=$HOME/include \
  -DMARKDOWN_LIBRARY:FILEPATH=$HOME/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR:PATH=$HOME/include \
  -DTRE_LIBRARY:FILEPATH=$HOME/lib/libtre.a \
  -DGSL_INCLUDE_DIR:PATH=$HOME/include \
  -DGSL_LIBRARY_DIR:PATH=$HOME/lib \
  -DIDLdoc_DIR:PATH=~/projects/idldoc/src \
  -Dmgunit_DIR:PATH=~/projects/mgunit/src \
  -Didlwave_DIR:PATH=~/software/idlwave \
  ..

