#!/bin/sh

git submodule foreach --recursive git pull
git pull
