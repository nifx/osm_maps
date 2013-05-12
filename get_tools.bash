#!/bin/bash

mkdir -p tools
pushd tools
rm -rf *

##############################################################################
# osmosis
##############################################################################
mkdir -p osmosis
pushd osmosis
rm -rf *
wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
tar xvfz osmosis-latest.tgz
chmod a+x bin/osmosis
popd

##############################################################################
# osmconvert
##############################################################################
mkdir -p osmconvert
pushd osmconvert
rm -rf *
wget http://m.m.i24.cc/osmconvert32
chmod a+x osmconvert32
popd

##############################################################################
# osmfilter
##############################################################################
mkdir -p osmfilter
pushd osmfilter
rm -rf *
wget http://m.m.i24.cc/osmfilter32
chmod a+x osmfilter32
popd

##############################################################################
# splitter
##############################################################################
FILENAME="splitter-r304"
mkdir -p splitter
pushd splitter
rm -rf *
wget http://www.mkgmap.org.uk/download/$FILENAME.tar.gz
tar xvfz $FILENAME.tar.gz
rm $FILENAME.tar.gz
mv $FILENAME/* .
rm -rf $FILENAME
popd

##############################################################################
# mkgmap
##############################################################################
FILENAME="mkgmap-r2596"
mkdir -p mkgmap
pushd mkgmap
rm -rf *
wget http://www.mkgmap.org.uk/download/$FILENAME.tar.gz
tar xvfz $FILENAME.tar.gz
rm $FILENAME.tar.gz
mv $FILENAME/* .
rm -rf $FILENAME
popd

popd