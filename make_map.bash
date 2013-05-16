#!/bin/bash


##############################################################################
# save working directory, needed to find other stuff
##############################################################################
HOME=$PWD


##############################################################################
# polygon files
##############################################################################
POLYFILE=$HOME/poly/germany_czech-republic_austria_switzerland_italy_liechtenstein.poly
#POLYFILE=$HOME/poly/germany_france_portugal_spain_andorra_belgium_luxembourg_monaco_netherlands.poly
#POLYFILE=$HOME/poly/illinois_wisconsin_michigan_new-york_ontario_indiana_new-jersey_ohio_pennsylvania.poly
#POLYFILE=$HOME/poly/arizona_utah_nevada_california.poly


##############################################################################
# set variables to tools binaries
##############################################################################
SPLITTER=$HOME/tools/splitter/splitter.jar
MKGMAP=$HOME/tools/mkgmap/mkgmap.jar
OSMOSIS=$HOME/tools/osmosis/bin/osmosis
OSMFILTER=$HOME/tools/osmfilter/osmfilter32
OSMCONVERT=$HOME/tools/osmconvert/osmconvert32


##############################################################################
# define style and typ file locations
##############################################################################
STYLE_FILE=$HOME/tools/teddy/teddy
TYP_FILE=$HOME/tools/teddy/teddy.TYP
FAMILY_ID=42


##############################################################################
# set variables to select build step default to false (=0)
##############################################################################
DO_PNG=0
DO_BOUNDS=0
DO_MKGMAP=0
DO_SPLIT=0
DO_CUT=0


##############################################################################
# stuff to organize in a different way
# this section will be removed later
##############################################################################
INPUT_TEST=/home/nico/Development/osm/osm_pbf/bayern-latest.osm.pbf
INPUT_EUROPE=/home/nico/Development/osm/nif_osm_maps/dach++.osm.pbf
INPUT=$INPUT_EUROPE
INPUT_SPLITTER=/home/nico/Development/osm/osm_pbf/06052013/europe-latest.osm.pbf


##############################################################################
# getopts
# -p png
# -b bounds
# -m mkgmap
# -s split
# -c cut polygon out of map
# -a all
##############################################################################
while getopts "apbr:sm" OPTION
do
  case $OPTION in
    p)  echo "P"
	DO_PNG=1
	;;
    b)  echo "B"
	DO_BOUNDS=1
	;;
    m)  echo "M"
	DO_MKGMAP=1
	;;
    s)  echo "S"
	DO_SPLIT=1
	;;
    c)  echo "C: $OPTARG"
	DO_CUT=1
	;;
    a)	echo "A"
	DO_PNG=1
	DO_BOUNDS=1
	DO_MKGMAP=1
	DO_SPLIT=1
	DO_CUT=1
	;;
 
    # Unknown option. No need for an error, getopts informs
    # the user itself.
    \?) exit 1;;
  esac
done


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
$OSMCONVERT $INPUT_SPLITTER --out-o5m >temp.o5m

$OSMFILTER temp.o5m --keep-nodes= \
--keep-ways-relations="boundary=administrative =postal_code postal_code=" \
--out-o5m > temp-boundaries.o5m

java -cp $MKGMAP \
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
#$OSMOSIS --read-pbf $INPUT_EUROPE --bb left=0.5 right=19.3 bottom=35.9 top=58.2 --write-pbf dach++.osm.pbf omitmetadata=true
$OSMOSIS --read-pbf $INPUT_SPLITTER --bounding-polygon file=$POLYFILE --write-pbf reduced.osm.pbf omitmetadata=true
popd
fi


##############################################################################
# split tiles so that mkgmap can process it
##############################################################################
if [ $DO_SPLIT = 1 ]; then
java -Xmx1500m -jar $SPLITTER --cache=./tmp --output=xml --max-nodes=800000 reduced_map/reduced.osm.pbf
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
if [ $DO_MKGMAP = 1 ]; then
java -Xmx1500m -jar $MKGMAP \
--keep-going \
--family-id=$FAMILY_ID \
--style-file=$STYLE_FILE \
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
--latin1 \
--net \
--route \
--index \
--name-tag-list='name:de,name,name:latin,name:en' \
*.osm.gz $TYP_FILE
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


popd