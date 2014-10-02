#!/bin/sh

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=~/software/mglib \
  -DIDLdoc_DIR=~/projects/idldoc/src \
  -Dmgunit_DIR=~/projects/mgunit/src \
  -Didlwave_DIR=~/software/idlwave \
  .
