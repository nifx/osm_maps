#!/bin/bash

SPLITTER=java -Xmx1500m -jar /home/nico/Development/osm/splitter/splitter-r299/splitter.jar
MKGMAP=java -Xmx1500m -jar /home/nico/Development/osm/mkgmap/mkgmap-r2540/mkgmap.jar
OSMOSIS=/home/nico/Development/osm/osmosis/bin/osmosis

INPUT_TEST=/home/nico/Development/osm/osm_pbf/bayern-latest.osm.pbf
INPUT_EUROPE=/home/nico/Development/osm/nif_osm_maps/dach++.osm.pbf
INPUT=$(INPUT_EUROPE)

POLYFILE=/home/nico/Development/osm/poly/d_a_self.poly

STYLE_FILE=/home/nico/Development/osm/computerteddy/OSM_sicherung_gauss_130425/teddy
#STYLE_FILE=/home/nico/Development/osm/computerteddy/OSM_sicherung_gauss_130425/teddy.heiko
#STYLE_FILE=/home/nico/Development/osm/own_stuff/styles/test_style
#STYLE_FILE=/home/nico/Development/osm/own_stuff3/styles/basemap_style
#STYLE_FILE=/home/nico/Development/osm/test1/aiostyles/basemap_style

TYP_FILE=/home/nico/Development/osm/computerteddy/OSM_sicherung_gauss_130425/teddy.TYP
FAMILY_ID=42
#TYP_FILE=/home/nico/Development/osm/test1/aiostyles/basemap.TYP
#FAMILY_ID=4


all: tmp osmosis splitter mkgmap

tmp:
	mkdir -p tmp; \
	pushd tmp; \


#$(OSMOSIS) --read-pbf $(INPUT_EUROPE) --bb left=0.5 right=19.3 bottom=35.9 top=58.2 --write-pbf dach++.osm.pbf omitmetadata=true
osmosis:
	$(OSMOSIS) --read-pbf $(INPUT_EUROPE) --bounding-polygon file=$(POLYFILE) --write-pbf dach++.osm.pbf omitmetadata=true

splitter:
	pushd tmp ; \
	$(SPLITTER) --cache=./tmp --output=xml --max-nodes=800000 $(INPUT) ; \
	popd; \

# Teddy:
# --location-autofill=is_in,nearest
# --bounds not used!!
# me:
# --bounds=/home/nico/Development/osm/bounds_20130420 (add only this works also)
# --location-autofill=bounds (add this, no change??)
#/home/nico/Development/osm/own_stuff/boundary/local/
mkgmap:
	pushd tmp ; \
	$(MKGMAP) \
	--keep-going \
	--family-id=$(FAMILY_ID) \
	--style-file=$(STYLE_FILE) \
	--reduce-point-density=4 \
	--merge-lines \
	--generate-sea=multipolygon,extend-sea-sectors,close-gaps=6000,floodblocker \
	--bounds=/home/nico/Development/osm/own_stuff/boundary/local/ \
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
