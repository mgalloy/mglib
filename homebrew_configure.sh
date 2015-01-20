#!/bin/sh

# using static libtre.a requires adding an --enable-static flag to the tre
# formula in /usr/local/Library/Formula/tre.rb

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX:FILEPATH=~/software/mglib \
  -DMARKDOWN_INCLUDE_DIR:FILEPATH=/usr/local/include \
  -DMARKDOWN_LIBRARY:FILEPATH=/usr/local/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR:FILEPATH=/usr/local/include \
  -DTRE_LIBRARY:FILEPATH=/usr/local/lib/libtre.a \
  -DGSL_INCLUDE_DIR:FILEPATH=/usr/local/include \
  -DGSL_LIBRARY_DIR:FILEPATH=/usr/local/lib \
  -DZEROMQ_INCLUDE_DIR:FILEPATH=/usr/local/include \
  -DZEROMQ_LIBRARY_DIR:FILEPATH=/usr/local/lib \
  -DIDLdoc_DIR:FILEPATH=~/projects/idldoc/src \
  -Dmgunit_DIR:FILEPATH=~/projects/mgunit/src \
  -Didlwave_DIR:FILEPATH=~/software/idlwave \
  ..

