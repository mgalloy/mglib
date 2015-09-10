#!/bin/sh

if [ -d .git ]; then
  echo "Retrieving mgcmake via GitHub using git..."
  git submodule update --init --recursive
  cd mgcmake; git checkout master; git pull origin master
else
  echo "Retrieving mgcmake via downloading from GitHub..."
  wget https://github.com/mgalloy/mgcmake/archive/master.zip
  unzip master.zip
  rm master.zip
  rmdir mgcmake
  mv mgcmake-master mgcmake
fi
