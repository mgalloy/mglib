#!/bin/sh

git submodule update --init --recursive
cd mgcmake; git pull origin master
