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
FILENAME="splitter-latest"
mkdir -p splitter
pushd splitter
rm -rf *
wget http://www.mkgmap.org.uk/download/$FILENAME.tar.gz
tar xvfz $FILENAME.tar.gz
rm $FILENAME.tar.gz
# dir name is not latest; it's the version number
# thus, get dir name to delete
FILENAME=$(ls -p | grep "/")
echo $FILENAME > 00_info.txt
mv $FILENAME/* .
rm -rf $FILENAME
popd

##############################################################################
# mkgmap
##############################################################################
FILENAME="mkgmap-latest"
mkdir -p mkgmap
pushd mkgmap
rm -rf *
wget http://www.mkgmap.org.uk/download/$FILENAME.tar.gz
tar xvfz $FILENAME.tar.gz
rm $FILENAME.tar.gz
# dir name is not latest; it's the version number
# thus, get dir name to delete
FILENAME=$(ls -p | grep "/")
echo $FILENAME > 00_info.txt
mv $FILENAME* .
rm -rf $FILENAME
popd

##############################################################################
# osm-extract/polygons
# polyconvert does not support gpx conversion from shell -> patch
##############################################################################
mkdir -p osm-extract
pushd osm-extract
mkdir -p polygons
pushd polygons
svn co http://svn.openstreetmap.org/applications/utils/osm-extract/polygons .
patch < ../../../polyconvert_mods.diff
popd
popd

##############################################################################
# ComputerTeddy style and typ files
##############################################################################
mkdir -p teddy
pushd teddy
#wget http://ftp5.gwdg.de/pub/misc/openstreetmap/teddynetz.de/latest/new/teddy.tgz
wget http://ftp5.gwdg.de/pub/misc/openstreetmap/teddynetz.de/latest/new/teddy.typ
mv teddy.typ teddy.TYP
#tar xvfz teddy.tgz
#rm teddy.tgz
popd

##############################################################################
# gpx2png
##############################################################################
mkdir -p gpx2png
pushd gpx2png
wget https://gitorious.org/tfscripts/openstreetmap/blobs/raw/master/gpx2png/gpx2png.pl
popd




popd