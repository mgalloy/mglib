#!/bin/sh

if [ -d $1/api-userdocs ]; then
  echo "scp -r $1/api-userdocs docs.idldev.com/mglib"
else
  echo "run 'make userdoc' before uploading"
fi
