#!/bin/sh

# location of bindgen utility, currently using the one here:
#   git@github.com:crabtw/rust-bindgen.git
BINDGEN_DIR=/Users/mgalloy/software/rust-bindgen/target/debug
BINDGEN=$BINDGEN_DIR/bindgen

# IDL location to find idl_export.h
IDL_DIR=/Applications/exelis/idl

# need to include stdio.h to know about FILE, so create a new idl_export.h with
# with the stdio.h include
echo "#include <stdio.h>" > idl_export.h
cat $IDL_DIR/external/include/idl_export.h >> idl_export.h

# according to the rust-bindgen README, we need to set DYLD_LIB_PATH to contain
# the clang library
DYLD_LIB_PATH=/Library/Developer/CommandLineTools/usr/lib

# generate the bindings
DYLD_LIBRARY_PATH=$DYLD_LIB_PATH $BINDGEN idl_export.h -o idl.rs
