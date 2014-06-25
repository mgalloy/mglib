#!/bin/sh

if [ -d $1/api-userdocs ]; then
  cmd="scp -r $1/api-userdocs idldev.com:~/docs.idldev.com/mglib"
  $cmd
else
  echo "run 'make userdoc' before uploading"
fi
