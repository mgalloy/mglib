#!/bin/sh

git submodule update --init --recursive
cd mgcmake; git checkout master; git pull origin master
