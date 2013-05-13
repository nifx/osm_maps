osm_maps
========

The Makefile describes the procedure to generate a routable map for GARMIN
navigation systems based on OSM.

The starting point for this script were different available scripts on the
internet. I tested several available gmapsupp.img files available. Every
map has different advantages and disadvantages. In my case, the major
disadvantages was that my "nüvi" supports only 4GB sd cards whereas the
most European cards are bigger. Thus, it was necessary to get a solution
to generate own maps with appropriate areas to fit on 4GB sd cards.

On my "nüvi", the cards from "aio" are working best:
http://wiki.openstreetmap.org/wiki/DE:All_in_one_Garmin_Map

The only problem for me was to understand the proviced script files. It
was not possible for me, to build my own map out of these scripts.

The scripts provided by Computerteddy are really easy to understand and
limited to the stuff really needed. It's quite easy to generate a working
map with these scripts. The problem with this map is that in bigger cities
(I tested it with only one), most of the streets during the address search
are not found. But the streets are found at the municipalities instead of
the city. This behaviour differs from the map generated by "aio".

Thus, I started using the scripts from Computerteddy and tried to adapt them
to get a map where the streets are found at the city instead of the
municipality.

Computerteddy uses the "--location-autofill=is_in,nearest" and does not use
the "--bounds". By removing the "--location-autofill" parameter and adding
"--bounds=/home/nico/Development/osm/bounds_20130420" fixes that problem.

The files for the bounds parameter could be downloaded at
"http://www.navmaps.eu/boundaries.html"

At XXX is described, that using "--bounds", one should use
"--location-autofill=bounds", but I can't find a difference at the produced map.

Thus, I omit the "location-autofill" parameter, as recommended at
http://wiki.openstreetmap.org/wiki/Mkgmap/help/options ( see
--location-autofill description)


Next steps:
- improve Makefile to be more independant (directories, etc.)
- find a way to cut a region out of a bigger osm file
- self generated boundaries


To use gpx2png, several perl modules are necessary. For example to install
Math::Trig, simply try: cpan install Math::Trig