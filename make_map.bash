#!/bin/bash


usage() {
echo ""
echo -ne "usage:"
echo -e "\tcut polygon out of map and generate garmin image + png file:"
echo -e "\t$0 -c my.poly -o europe.osm.pbf"
echo ""
echo -e "\tgenerate garmin image out of complete map"
echo -e "\t$0 -o europe.osm.pbf"
echo ""
echo -e "\tgenerate png file from polygon only (fast)"
echo -e "\t$0 -c my.poly"
}


##############################################################################
# save working directory, needed to find other stuff
##############################################################################
HOME=$PWD


##############################################################################
# set variables to tools binaries
##############################################################################
SPLITTER=$HOME/tools/splitter/splitter.jar
MKGMAP=$HOME/tools/mkgmap/mkgmap.jar
OSMOSIS=$HOME/tools/osmosis/bin/osmosis
OSMFILTER=$HOME/tools/osmfilter/osmfilter32
OSMCONVERT=$HOME/tools/osmconvert/osmconvert32


##############################################################################
# set maximum Java heap size (for mkgmap)
##############################################################################
MEM_USAGE=-Xmx4000m


##############################################################################
# define style and typ file locations
##############################################################################
#STYLE_FILE=$HOME/tools/teddy/teddy
TYP_FILE=$HOME/tools/teddy/teddy.TYP
FAMILY_ID=42


##############################################################################
# set variables to select build step; 0=false
# these variables are set using options during script call
##############################################################################
DO_BOUNDS=0
DO_CUT=0
DO_SPLIT=0
DO_MKGMAP=0
DO_PNG=0


##############################################################################
# getopts
# -p png
# -c cut polygon out of map (implicit -p)
# -o osm.pbf file
##############################################################################
while getopts "c:o:" OPTION
do
  case $OPTION in
    c)  # cut region using poly file
	POLYFILE=$HOME/$OPTARG
	echo "using $POLYFILE"
	DO_CUT=1
	DO_PNG=1
	;;
    o)  # osm.pbf file
	DO_BOUNDS=1
	DO_SPLIT=1
	DO_MKGMAP=1
	OSM_PBF=$HOME/$OPTARG
	echo "using $OSM_PBF"
	;;
 
    # Unknown option. No need for an error, getopts informs
    # the user itself.
    \?) exit 1;;
  esac
done

if [ $# -ne 2 ] && [ $# -ne 4 ]
then
usage
exit 1
fi


##############################################################################
# if no poly file selected, the input for splitter is the complete map
# otherwise, splitter uses the reduced map as input
##############################################################################
if [ $DO_CUT = 1 ]; then
INPUT_SPLITTER=$HOME/tmp/reduced_map/reduced.osm.pbf
else
INPUT_SPLITTER=$OSM_PBF
fi


##############################################################################
# if no osm.pbf file is given, but poly file and png,
# generate png out of poly (is fast) and omit cutting
##############################################################################
if [ $DO_MKGMAP = 0 ]; then
DO_CUT=0
fi


##############################################################################
# generate tmp directory for processing stuff
##############################################################################
mkdir -p tmp
pushd tmp


##############################################################################
# pre-process bounds, necessary for address search index
# could also be done with pbf after osmosis to save time
##############################################################################
if [ $DO_BOUNDS = 1 ]; then
echo "Pre-process boundaries"
mkdir -p bounds
pushd bounds
$OSMCONVERT $OSM_PBF --out-o5m >temp.o5m

$OSMFILTER temp.o5m --keep-nodes= \
--keep-ways-relations="boundary=administrative =postal_code postal_code=" \
--out-o5m > temp-boundaries.o5m

java $MEM_USAGE -cp $MKGMAP \
uk.me.parabola.mkgmap.reader.osm.boundary.BoundaryPreprocessor \
temp-boundaries.o5m \
temp_bounds
popd
fi


##############################################################################
# cut selected polygon out of bigger map
##############################################################################
if [ $DO_CUT = 1 ]; then
echo "Cutting polygon out of map"
mkdir -p reduced_map
pushd reduced_map
$OSMOSIS --read-pbf $OSM_PBF --bounding-polygon file=$POLYFILE --write-pbf reduced.osm.pbf omitmetadata=true
popd
fi


##############################################################################
# split tiles so that mkgmap can process it
##############################################################################
if [ $DO_SPLIT = 1 ]; then
echo "Start splitter"
mkdir -p splitter
pushd splitter
java $MEM_USAGE -jar $SPLITTER --cache=./tmp --output=xml --max-nodes=800000 $INPUT_SPLITTER
popd
fi


##############################################################################
# mkgmap
##############################################################################
# Teddy:
# --location-autofill=is_in,nearest
# --bounds not used!!
# me:
# --bounds=/home/nico/Development/osm/bounds_20130420 (add only this works also)
# --location-autofill=bounds (add this, no change??)
#/home/nico/Development/osm/own_stuff/boundary/local/
#/home/nico/Development/osm/bounds_20130420
#--style-file=$STYLE_FILE \
if [ $DO_MKGMAP = 1 ]; then
java $MEM_USAGE -jar $MKGMAP \
--keep-going \
--family-id=$FAMILY_ID \
--reduce-point-density=4 \
--merge-lines \
--generate-sea=multipolygon,extend-sea-sectors,close-gaps=6000,floodblocker \
--bounds=$HOME/tmp/bounds/temp_bounds \
--add-pois-to-areas \
--remove-short-arcs \
--country-name=GERMANY \
--country-abbr=GER \
--family-name="OSM Map" \
--description="OSM Map from NiF - "`date +%F` \
--area-name=DACH \
--gmapsupp \
--tdbfile \
--latin1 \
--net \
--route \
--index \
--name-tag-list='name:de,name,name:latin,name:en' \
splitter/*.osm.gz $TYP_FILE
fi


##############################################################################
# make png to check polygon
##############################################################################
if [ $DO_PNG = 1 ]; then
mkdir -p png
pushd png
perl $HOME/tools/osm-extract/polygons/polyconvert.pl $POLYFILE > temp.gpx
perl $HOME/tools/gpx2png/gpx2png.pl temp.gpx
fi


##############################################################################
# leaving tmp directory
##############################################################################
popd


##############################################################################
# copy output
# therefore, generate subfolder in output with current date+time
# a text file will be added (00_info.txt) to provide information about
# how this script was called
##############################################################################
mkdir -p output
pushd output
OUTPUT_DIR=$(date +%Y%m%d_%H%M%S)
mkdir $OUTPUT_DIR
pushd $OUTPUT_DIR

echo "These output files were generated with the following parameters:" > 00_info.txt
echo "" >> 00_info.txt

if [ $DO_PNG = 1 ]; then
mv $HOME/tmp/png/map.png .
echo "polyfile: "$POLYFILE >> 00_info.txt
fi

if [ $DO_MKGMAP = 1 ]; then
mv $HOME/tmp/gmapsupp.img .

mkdir tdb
pushd tdb
find $HOME/tmp/ -maxdepth 1 -type f -exec mv {} . \;
popd

echo "osm_pbf: "$OSM_PBF >> 00_info.txt
fi

popd


##############################################################################
# finished :-)
##############################################################################
echo "finished"