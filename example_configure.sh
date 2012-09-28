#!/bin/sh

cmake \
  -DCMAKE_INSTALL_PREFIX=~/projects/mglib-install \
  -DMARKDOWN_INCLUDE_DIR=/usr/local/include \
  -DMARKDOWN_LIBRARY=/usr/local/lib/libmarkdown.a \
  -DTRE_INCLUDE_DIR=/usr/local/include \
  -DTRE_LIBRARY=/usr/local/lib/libtre.dylib \
  ../mglib

