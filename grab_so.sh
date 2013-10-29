#!/bin/sh

# calling syntax:
#
#   grab_so.sh [build_dir]
#
# for example
#
#   grab_so.sh build

ORIG_LOCATION=$PWD

# set for out-of-place build
if [ -z "$1" ]; then
  LOCATION=src
else
  LOCATION=$1/src
  cd $1
fi

echo "Grabbing so's from $LOCATION..."
SO_TARFILE=`uname`.so.tar.gz
SO_FILES="src/*/mg_*.so src/vis/*/mg_*.so"
BASENAMES=`basename $SO_FILES`

cmd="tar -c -v -z -f $ORIG_LOCATION/$SO_TARFILE $SO_FILES"
#echo $cmd
$cmd #&> /dev/null

echo "Created $ORIG_LOCATION/$SO_TARFILE"