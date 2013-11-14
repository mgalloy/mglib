#!/bin/sh

VERSION=$1

# make the Doc Center docs
make dcdoc

# remove ls.pro and reference to it
rm -f api-dcdocs/ls.html
sed '/ls.html/d' api-dcdocs/idldoc-index.csv > api-dcdocs/mglib-index.csv
rm -f api-dcdocs/idldoc-index.csv

# delete old zip file
rm -f mglib-doccenter.tar.gz
rm -rf mglib-doccenter

# create the zip file
cp -r api-dcdocs mglib-doccenter
tar cfzv mglib-doccenter-$VERSION.tar.gz mglib-doccenter
rm -rf mglib-doccenter
