#!/bin/bash

# save working directory
HOME=$(PWD)

# tools
SPLITTER=$(HOME)/tools/splitter/splitter.jar
MKGMAP=$(HOME)/tools/mkgmap/mkgmap.jar
OSMOSIS=$(HOME)/tools/osmosis/bin/osmosis
OSMFILTER=$(HOME)/tools/osmfilter/osmfilter32
OSMCONVERT=$(HOME)/tools/osmconvert/osmconvert32

# style and typ file
STYLE_FILE=$(HOME)/tools/teddy/teddy
TYP_FILE=$(HOME)/tools/teddy/teddy.TYP
FAMILY_ID=42

# polygons
#POLYFILE=$(HOME)/poly/germany_czech-republic_austria_switzerland_italy_liechtenstein.poly
#POLYFILE=$(HOME)/poly/germany_france_portugal_spain_andorra_belgium_luxembourg_monaco_netherlands.poly
#POLYFILE=$(HOME)/poly/illinois_wisconsin_michigan_new-york_ontario_indiana_new-jersey_ohio_pennsylvania.poly
POLYFILE=$(HOME)/poly/arizona_utah_nevada_california.poly

INPUT_TEST=/home/nico/Development/osm/osm_pbf/bayern-latest.osm.pbf
INPUT_EUROPE=/home/nico/Development/osm/nif_osm_maps/dach++.osm.pbf
INPUT=$(INPUT_EUROPE)

INPUT_SPLITTER=/home/nico/Development/osm/osm_pbf/06052013/europe-latest.osm.pbf


all: tmp osmosis splitter mkgmap

tmp:
	mkdir -p tmp; \
	pushd tmp; \

bounds:
	pushd tmp ; \
	mkdir -p bounds; \
	pushd bounds; \
	$(OSMCONVERT) $(INPUT_EUROPE) --out-o5m >temp.o5m ; \
	$(OSMFILTER) temp.o5m --keep-nodes= \
	--keep-ways-relations="boundary=administrative =postal_code postal_code=" \
	--out-o5m > temp-boundaries.o5m ; \
	java -cp $(MKGMAP) \
	uk.me.parabola.mkgmap.reader.osm.boundary.BoundaryPreprocessor \
	temp-boundaries.o5m \
	temp_bounds; \
	popd; \
	popd; \

#$(OSMOSIS) --read-pbf $(INPUT_EUROPE) --bb left=0.5 right=19.3 bottom=35.9 top=58.2 --write-pbf dach++.osm.pbf omitmetadata=true
osmosis:
	$(OSMOSIS) --read-pbf $(INPUT_SPLITTER) --bounding-polygon file=$(POLYFILE) --write-pbf dach++.osm.pbf omitmetadata=true

splitter:
	pushd tmp ; \
	java -Xmx1500m -jar $(SPLITTER) --cache=./tmp --output=xml --max-nodes=800000 $(INPUT) ; \
	popd; \

# Teddy:
# --location-autofill=is_in,nearest
# --bounds not used!!
# me:
# --bounds=/home/nico/Development/osm/bounds_20130420 (add only this works also)
# --location-autofill=bounds (add this, no change??)
#/home/nico/Development/osm/own_stuff/boundary/local/
#/home/nico/Development/osm/bounds_20130420
mkgmap:
	pushd tmp ; \
	java -Xmx1500m -jar $(MKGMAP) \
	--keep-going \
	--family-id=$(FAMILY_ID) \
	--style-file=$(STYLE_FILE) \
	--reduce-point-density=4 \
	--merge-lines \
	--generate-sea=multipolygon,extend-sea-sectors,close-gaps=6000,floodblocker \
	--bounds=/home/nico/Development/osm/nif_osm_maps/tmp/bounds/temp_bounds \
	--add-pois-to-areas \
	--remove-short-arcs \
	--country-name=GERMANY \
	--country-abbr=GER \
	--family-name="OSM DE" \
	--description="DACH von NiF - "`date +%F` \
	--area-name=DACH \
	--gmapsupp \
	--latin1 \
	--net \
	--route \
	--index \
	--name-tag-list='name:de,name,name:latin,name:en' \
	*.osm.gz $(TYP_FILE) ; \
	popd; \

png:
	pushd tmp ; \
	mkdir -p png ;\
	pushd png ;\
	perl $(HOME)/tools/osm-extract/polygons/polyconvert.pl $(POLYFILE) > temp.gpx ; \
	perl $(HOME)/tools/gpx2png/gpx2png.pl temp.gpx ;\
	popd; \
	popd; \

	
