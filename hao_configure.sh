#!/bin/sh

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=~/software/mglib \
  -DIDL_ROOT_DIR:PATH=/opt/share/idl8.6/idl86 \
  -DIDLdoc_DIR:PATH=~/projects/idldoc/src \
  -Dmgunit_DIR:PATH=~/projects/mgunit/src \
  -Didlwave_DIR:PATH=~/software/idlwave \
  ..
