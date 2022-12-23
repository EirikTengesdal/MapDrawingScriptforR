#### Map Drawing Script for R. NALS – Norway & Denmark -------------------------

#### Header --------------------------------------------------------------------
##
## Script title:    Map Drawing Script for R.
## Script subtitle: NALS – Norway & Denmark.
##
## Script purpose:  To generate maps intended for the papers 'Argument placement
##                  in Norwegian' (Lundquist & Tengesdal 2022, submitted) and
##                  'Argument placement in Danish' (Tengesdal & Larsson 2022,
##                  submitted). It can be tailored to generate desired maps and
##                  custom features.
##
## Author:          Eirik Tengesdal
##
## Email:           eirik@tengesdal.name | eirik.tengesdal@iln.uio.no
##
## Releases:        Version 2.0.1: 23.12.2022
##                  Version 2.0.0: 30.11.2022
## (DD.MM.YYYY)     Version 1.0.0: 06.08.2021
##
## Copyright:       © 2021–2022 Eirik Tengesdal
##
## Licence:         Licenced under the MIT License
##
## Acknowledgments: The script is inspired by several online resources, most
##                  importantly the following:
##                  https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html
##
## Citation:        Please cite the script if you use it. The following citation
##                  example could be used (but it should be customised according
##                  to relevant citation style in academic contexts, version
##                  number, and the Zenodo DOI address of the specific release):
##                  
##                  Tengesdal, Eirik. 2022. Map Drawing Script for R. NALS –
##                  Norway & Denmark (Version 2.0.0). [Software]. DOI:
##                  https://doi.org/10.5281/zenodo.5167688 [*use correct DOI*]
##
## Notes -----------------------------------------------------------------------
##
## Version 2.0.1:   • Removed Fosen from the CSV and thus from the map. Removed
##                    nudge_x and nudge_y arguments for Fosen in Norway plot.
## Version 2.0.0:   • Updated script to include other European countries, based
##                    on an improved script (yet to be made available in Github
##                    or Zenodo) used to create a map for another manuscript.
##                  • Consolidated two scripts (Norway & Denmark) into one.
##                  • Updated citation information and other details.
## Version 1.0.0:   • Initial script version. Created for generating a map for a
##                    publication, but it can be tailored in general.
##
## Troubleshooting: In case of problems, ensure that the packages are updated.
##                  For instance, an incorrect version of the sf package might
##                  cause an error message like: "Input must be a vector, not a
##                  `sfc_MULTIPOLYGON/sfc` object.".
##
#### Header end ----------------------------------------------------------------


#### Libraries -----------------------------------------------------------------
##### Main libraries -----------------------------------------------------------
library("ggplot2")    # For plotting map
library("ggspatial")  # For creating scale bar
library("ggrepel")    # For repelling text labels in the map
library("sf")         # For drawing maps
library("dplyr")      # For filtering, used for the input CSV; can be omitted
library("tidyr")      # For the function separate(), used for the input CSV;
                      # can be omitted
library("stringi")    # For transforming uppercase characters into lowercase,
                      # apart from the first occurrence
library("ggnewscale") # For an extra ggplot2 colour scale
library("ggpattern")  # For diagonal stripes in for grouping ("ID")
library("httr")       # For URL parsing and building
library("ows4R")      # For interfacing with WFS service
library("purrr")      # (For map_chr() (WFS interface); can be omitted)

##### Extrafont ----------------------------------------------------------------
# You can skip this step if you do not need a special font. Because of somewhat
# recent problems with the package, I devote some space for comments and hints.

library("extrafont")
# This package is used for importing non-standard fonts. After setting up the
# first time, it should be sufficient only to load this library, without going
# through the following steps.

#font_import(paths = "~\\template-nals\\fonts\\required") # Uncomment if needed
# Replace with the path to the folder that contains your desired fonts if you
# have it/them stored at a specific location.
# You should only need to do this once; can be commented out after importing.

#fonts() # Uncomment if needed
# This function lists fonts such that you can find the correct font name to be
# specified in the "family" argument below.

#extrafont::loadfonts(device = "win") # Uncomment if needed
# For Windows users.

#windowsFonts() # Uncomment if needed
# Check to find font name, to be called in the text_family argument. This is
# important, because the font name to be used in the script might not be
# identical to the font name itself.


# If you encounter an extrafont issue resulting in the warning "No FontName.
# Skipping.", try the solution that was suggested here:
# https://stackoverflow.com/questions/61204259/how-can-i-resolve-the-no-font-name-issue-when-importing-fonts-into-r-using-ext?noredirect=1#comment108274897_61204259
#
# I.e.: "Answer by 'cartoonist', 03.08.2021":
# "As it was mentioned by @Moritz Schwarz, the problem is traced to Rttf2pt1.
#
# According to a solution proposed here, downgrading it to 1.3.8 will fix the
# problem:
#
# library(extrafont)
# library(remotes)
# remotes::install_version("Rttf2pt1", version = "1.3.8")
# extrafont::font_import()"


##### Return R, RStudio and package version/citation information ---------------
citation()
RStudio.Version()
citation("ggplot2")
citation("ggspatial")
citation("ggrepel")
citation("sf")
citation("dplyr")
citation("tidyr")
citation("stringi")
citation("ggnewscale")
citation("ggpattern")
citation("extrafont")
citation("httr")
citation("ows4R")
citation("purrr")


#### Check whether RStudio renders UTF-8 characters as "�" (locale "C") --------
# Depending on several factors, like the RStudio version and the OS you are
# running, you might encounter an error reading/printing UTF-8 characters.
# Example: "Error: unexpected symbol in: ("�rjan","Pyht��""
data.frame("UTF-8_character_test"=c("Ørjan","Pyhtää"))
print(c("Ørjan","Pyhtää"))

# If you encountered an error, the following suggestion might solve the problem:
#Sys.getlocale() # Uncomment if needed
#Sys.setlocale("LC_ALL",".utf8") # Uncomment if needed
#data.frame("Name"=c("Ørjan","Pyhtää")) # Uncomment if needed

# See:
# https://superuser.com/questions/1033088/is-it-possible-to-set-locale-of-a-windows-application-to-utf-8
# https://community.rstudio.com/t/warning-using-locale-code-page-other-than-65001-utf-8-may-cause-problems-after-r-4-2-update/140356/3


#### Data processing -----------------------------------------------------------
##### Download map data from GADM ----------------------------------------------
# The map data that this script mainly uses is downloaded from GADM: https://gadm.org/maps.html


# About GADM data [https://gadm.org/data.html] (last accessed 29 November 2022):

# "GADM data
# The current version is 4.1. It delimits 400,276 administrative areas.
#
# You can download the spatial data by country [https://gadm.org/download_country.html].
#
# Downloading by country is the recommended approach. You can also download the
# data for the entire world.
#
# Version 4.1 was released on 16 July 2022. New released are expected every
# three months.
# Older versions can be downloaded here [https://gadm.org/old_versions.html].
# A change log is under development [https://gadm.org/changelog.html].
#
# **The data are freely available for academic use and other non-commercial use.
# Redistribution, or commercial use is not allowed without prior permission.**
# See the license [https://gadm.org/license.html] for more details.
#
# © 2018-2022 GADM - license [https://gadm.org/license.html]"

# Regarding the "geopackage" file format [https://gadm.org/formats.html]:
# "The "geopackage" format is the a very good general spatial data file format
# (for vector data). It can be read by spatial packages in python and R (with
# the 'terra' or 'sf' package), and by GIS software such as QGIS and ArcGIS."


# I recommend using the GeoPackage data. The sf package can read this, and it
# contains all the layers (e.g., GADM: "level-0, level1, level2") that you
# otherwise would have to download as separate files.

##### Download map data of Norway from Geonorge.no -----------------------------
# If you wish to download a map dataset of Norway based on an official source
# (Kartverket), you could for instance consult the following URL (2021 data):
# https://kartkatalog.geonorge.no/metadata/norske-fylker-og-kommuner-illustrasjonsdata-2021-klippet-etter-kyst/f08fca3c-33ee-49b9-be9f-028ebba5e460

# "Datasettet inneholder fylker og kommuner for 2021 klippet etter kyst.
# Datasettet er klippet etter en forenklet kystlinje som avviker fra offisiell
# kystlinje, og egner seg til illustrasjonsbruk i liten målestokk."
# 
# My loose translation: "The dataset contains counties and municipalities for
# 2021, sliced by coast. The dataset is sliced based on a simplified shoreline
# that deviates from official shoreline, and is appropriate for illustrative
# usages in a small scale."

# You can download it directly via the Geonorge.no URL provided above, or
# through an API method. I downloaded the dataset in the GeoJSON format, and
# placed it in the folder that also contains the GADM files.

# Dataset constraints (last accessed 29 November 2022):
# "Use limitations: Datasettet er klippet etter forenklet kystlinje, noe som vil
# kunne begrense bruk på større målestokk. Utover dette foreligger ingen
# bruksbegrensninger
# Access constraints: Åpne data
# Use constraints: Lisens
# Licence: Creative Commons 0 [https://creativecommons.org/publicdomain/zero/1.0/]
# Other constraints: Datagrunnlaget er hentet fra datasettet "Administrative
# enheter" og brukerrestriksjoner følger dette datasettets restriksjoner.
# Security constraints: Ugradert"


##### Access map data of Finland via Statistics Finland interface --------------
# If you wish to download a map dataset of Finland based from an official
# source, you could for instance use the Statistics Finland interface. It
# provides open geographic data. The reason why I used this source for the
# current maps is that the GADM dataset for Finland was somewhat outdated w.r.t
# the municipalities (which were reorganised in, e.g., 2021). Below is an
# example of code that worked while accessing the data 29 November 2022;
# customisation might be necessary w.r.t. version number, address etc.

# I identified the desired layer of "Municipality-based statistical units"
# (i.e., "Municipalities 2022 (1:1 000 000)") through visualisation using
# the map service here: https://tilastokeskus-kartta.swgis.fi/?lang=en
# I then switched to Finnish language, and identified the Finnish label for the
# same layer, namely "Kunnat 2022 (1:1 000 000)".

# Further information:
# Collect sf object data from Statistics Finland, a governmental agency that
# provides a dataset corresponding to municipality borders, excluding the
# sea/water area ("Municipality-based statistical units";
# https://www.stat.fi/org/avoindata/paikkatietoaineistot_en.html).
 
# This takes into consideration the shorelines that the National Land Survey of
# Finland does not (its data set "Division into administrative areas (vector)"
# (https://www.maanmittauslaitos.fi/en/maps-and-spatial-data/professionals/product-descriptions/division-administrative-areas-vector)
# contains much information, "as well as a specification of the municipality's
# area into land and water area"; thus unsuitable for our purposes).
 
# It is also possible to download the map data through a URL address, see
# instructions here: https://www.stat.fi/static/media/uploads/org_en/avoindata/kartta-aineistojen_lataus_url-osoitteen_kautta_ohje_en.pdf
# (last accessed 29 November 2022.)
# Supported formats: SHAPE-ZIP (Format: Shapefile); csv (Format: CSV);
# json (Format: GeoJSON); kml (Format: KML)
 
# Add the desired "outputFormat=" parameter.
# Example: https://geo.stat.fi/geoserver/tilastointialueet/wfs?service=wfs&request=GetFeature&typename=tilastointialueet%3Akunta1000k&outputFormat=json

# Terms of Use (as of 29 November 2022):
# "Unless otherwise separately stated in connection with the product, data or
# service concerned, Statistics Finland is the producer of the data and the
# owner of the copyright.
#
# The Creative Commons Attribution 4.0 International [https://creativecommons.org/licenses/by/4.0/deed.en]
# licence is applied to Statistics Finland's open data materials and the public
# content of the online service. This is a licence according to the JHS 189
# recommendation for open data files in public administration. It gives the
# right to copy, edit and redistribute data either in original or modified form.
# The material can also be combined to other data and used for both commercial
# and non-commercial purposes.
#
# A reference to the Creative Commons Attribution 4.0 International [https://creativecommons.org/licenses/by/4.0/deed.en]
# licence and a hyperlink to the licence must be attached to the open data
#
# Example: Postal code area boundaries, Statistics Finland The material was
# downloaded from Statistics Finland's interface service on 13 October 2017 with
# the licence CC BY 4.0 [https://creativecommons.org/licenses/by/4.0/deed.en].
#
# The original source and the date of the material version must be named when
# the material is used (details in italics when required):
#
# Example: Statistics Finland, [name of statistics/product or service],
# [date referred]
#
# The user accepts these Terms of Use by receiving, downloading or otherwise
# making use of the material.
#
# The copyrights to photographs and illustrative images belong to the producers
# or Statistics Finland. The use of such material is always subject to a
# separate agreement.
#
# The Terms of Use for data produced as assignments and chargeable services are
# specified for each agreement. The data of other producers are subject to their
# Terms of Use."

# Original source and the date of the material version produced in this script:
# Statistics Finland, *Municipality-based statistical units*. The material was
# downloaded from Statistics Finland's interface service on 23 December 2022
# with the licence Attribution 4.0 International (CC BY 4.0) 
# [https://creativecommons.org/licenses/by/4.0/deed.en].

# Retrieve Finnish municipality data:
wfs_municipalities <- "https://geo.stat.fi/geoserver/tilastointialueet/wfs"
municipalities_client <- ows4R::WFSClient$new(wfs_municipalities,
  serviceVersion = "2.0.0" # (It might be necessary to check serviceVersion manually at time of request)
)
municipalities_client$getFeatureTypes(pretty = TRUE) # Locate desired municipality layer (unspecified year = same year [2022] as at the time of request?): "title" == "Kunnat (1:1 000 000)" -> "name" == "tilastointialueet:kunta1000k"
url <- httr::parse_url(wfs_municipalities)
url$query <- list(
  service = "wfs",
  # version = "2.0.0", # Optional
  request = "GetFeature",
  typename = "tilastointialueet:kunta1000k"
)
request <- httr::build_url(url)
Finland_municipalities <- read_sf(request)

# Harmonise to WGS 84 format, at municipality level:
Finland_municipalities_wgs84 = sf::st_transform(Finland_municipalities, "EPSG:4326")

# Create one sf object for the whole of Finland, based on the municipalities
# object:
Finland_dissolved_wgs84 <- rmapshaper::ms_dissolve(Finland_municipalities_wgs84)


###### Alternative functions ---------------------------------------------------
# Here are some alternative functions to the approach above, that can be used in
# general, based on: https://inbo.github.io/tutorials/tutorials/spatial_wfs_services/

# An alternative to "bwk_client$getFeatureTypes(pretty = TRUE)":
# bwk_client$getFeatureTypes() %>%
#   purrr::map_chr(function(x){x$getTitle()})

# List all available fields for the layer "tilastointialueet:kunta1000k":
# bwk_client$
#   describeFeatureType(typeName = "tilastointialueet:kunta1000k") %>%
#   purrr::map_chr(function(x){x$getName()})

# Obtain a character vector naming all available operations of the WFS:
# bwk_client$
#   getCapabilities()$
#   getOperationsMetadata()$
#   getOperations() %>%
#   purrr::map_chr(function(x){x$getName()})

# Extract the available output formats:
# bwk_client$
#   getCapabilities()$
#   getOperationsMetadata()$
#   getOperations() %>%
#   purrr::map(function(x){x$getParameters()}) %>%
#   purrr::pluck(3, "outputFormat")

# Extract the bounding boxes for all layers:
# bwk_client$
#   getCapabilities()$ 
#   getFeatureTypes() %>%  
#   purrr::map(function(x){x$getBoundingBox()})

# Get the abstract, containing information about the contents of the layer
# (only works if "Abstract" is available – it is not in the current dataset):
# bwk_client$
#   getCapabilities()$
#   getFeatureTypes() %>%
#   purrr::map_chr(function(x){x$getAbstract()})


##### Create sf objects for countries and Europe -------------------------------
# The code below can be simplified by setting the path for the folder containing
# the datasets (e.g., .gpkg, .json), as has been done here.

# If you desire other countries, you must provide this yourself.

getwd()
#setwd("C:\\Users\\eirikten\\Dropbox (UiO)\\RStudio\\Maps\\") # Customise as needed
setwd("G:\\Dropbox (UiO)\\RStudio\\Maps\\") # Customise as needed

# "sf::st_layers()" returns the layer names in a map dataset.


###### Norway ------------------------------------------------------------------
# Create these sf objects if you wish to use GADM data instead of the official
# Norwegian datasets from Kartverket (municipalities and counties):
# sf::st_layers("gadm41_NOR.gpkg")
# Norway_sf0 <- sf::st_read("gadm41_NOR.gpkg", layer = "ADM_ADM_0")
# Norway_sf1 <- sf::st_read("gadm41_NOR.gpkg", layer = "ADM_ADM_1")

# Norwegian municipalities, based on Kartverket/Geodata.no:
Norway_municipalities2021 <- sf::st_read("kommuner2021.json")

# Harmonise to WGS 84 format, at municipality level:
Norway_municipalities2021_wgs84 <- sf::st_transform(
  Norway_municipalities2021,
  "EPSG:4326"
)

# Norwegian counties, based on Kartverket/Geodata.no:
Norway_counties2021 <- sf::st_read("fylker2021.json")

# Harmonise to WGS 84 format, at county level:
Norway_counties2021_wgs84 <- sf::st_transform(Norway_counties2021, "EPSG:4326")

# Create one WGS 84 sf object for the whole of Norway based on the counties:
Norway_dissolved_wgs84 <- rmapshaper::ms_dissolve(Norway_counties2021_wgs84)

###### Denmark -----------------------------------------------------------------
sf::st_layers("gadm41_DNK.gpkg")
Denmark_sf0 <- sf::st_read("gadm41_DNK.gpkg", layer = "ADM_ADM_0")

###### Sweden ------------------------------------------------------------------
sf::st_layers("gadm41_SWE.gpkg")
Sweden_sf0 <- sf::st_read("gadm41_SWE.gpkg", layer = "ADM_ADM_0")

###### Finland -----------------------------------------------------------------
# Create these sf objects if you wish to use the GADM data instead of the
# official Finnish data from Statistics Finland (municipalities and country):

#sf::st_layers("gadm41_FIN.gpkg")
#Finland_sf0 <- sf::st_read("gadm41_FIN.gpkg", layer = "ADM_ADM_0")

#sf::st_layers("gadm41_FIN.gpkg")
#Finland_sf4 <- sf::st_read("gadm41_FIN.gpkg", layer = "ADM_ADM_4")

# Finnish municipalities with Swedish language:
# These lists of Fenno-Swedish municipalities are based on information from
# the Finnish website Kuntaliitto – Kommunförbundet, last accessed 29 November
# 2022: Nortamo, Emilia Mattsson & Mattias Lindroth. (2022, 11 January).
# *Tvåspråkiga kommuner och tvåspråkighet*. Kommunförbundet.
# https://www.kommunforbundet.fi/kommuner-och-samkommuner/tvasprakiga-kommuner

# Because there were issues with the GADM dataset, a corresponding municipality
# filtering code that works with GADM is not given below.

# "namn" is based on the name reported by Kommunförbundet. "kunta" is my manual
# "namn" search in Finland_municipalities_wgs84, which I copied and pasted here.

# First, list all Fenno-Swedish municipalities apart from those in Åland:
FINSWE_m <- data.frame(
  "namn" = c(
    "Borgå",
    "Esbo",
    "Grankulla",
    "Hangö",
    "Helsingfors",
    "Ingå",
    "Kyrkslätt",
    "Lappträsk",
    "Lojo",
    "Lovisa",
    "Mörskom",
    "Pyttis",
    "Raseborg",
    "Sibbo",
    "Sjundeå",
    "Vanda",
    "Kimitoön",
    "Pargas",
    "Åbo",
    "Jakobstad",
    "Karleby",
    "Kaskö",
    "Korsholm",
    "Korsnäs",
    "Kristinestad",
    "Kronoby",
    "Larsmo",
    "Malax",
    "Nykarleby",
    "Närpes",
    "Pedersöre",
    "Vasa",
    "Vörå"
  ),
  "kunta" = c(
    "638",
    "049",
    "235",
    "078",
    "091",
    "149",
    "257",
    "407",
    "444",
    "434",
    "504",
    "624",
    "710",
    "753",
    "755",
    "092",
    "322",
    "445",
    "853",
    "598",
    "272",
    "231",
    "499",
    "280",
    "287",
    "288",
    "440",
    "475",
    "893",
    "545",
    "599",
    "905",
    "946"
  )
)

# Now, list all municipalities in Åland:
Aaland_m <- data.frame(
  "namn" = c(
    "Jomala",
    "Hammarland",
    "Eckerö",
    "Finström",
    "Geta",
    "Saltvik",
    "Sund",
    "Lemland",
    "Lumparland",
    "Vårdö",
    "Kumlinge",
    "Brändö",
    "Sottunga",
    "Föglö",
    "Kökar",
    "Mariehamn"
  ),
  "kunta" = c(
    "170",
    "076",
    "043",
    "060",
    "065",
    "736",
    "771",
    "417",
    "438",
    "941",
    "295",
    "035",
    "766",
    "062",
    "318",
    "478"
  )
)

# Check contents:
FINSWE_m
Aaland_m

# Filter the FINSWE municipalities:
Finland_FINSWE_municipalities_wgs84 <- Finland_municipalities_wgs84 %>%
  filter(kunta %in% FINSWE_m$kunta)

# Filter the Åland municipalities:
Aaland_municipalities_wgs84 <- Finland_municipalities_wgs84 %>%
  filter(kunta %in% Aaland_m$kunta)

# Check whether the kunta numbers were correctly copied, i.e., no missing names:
FINSWE_m %>%
  filter(namn %in% Finland_FINSWE_municipalities_wgs84$namn) 
Aaland_m %>%
  filter(namn %in% Aaland_municipalities_wgs84$namn)

# Merge the two sf objects into one containing all Fenno-Swedish municipalities:
Finland_all_FINSWE_m_wgs84 <- rbind(
  Finland_FINSWE_municipalities_wgs84,
  Aaland_municipalities_wgs84
)

# Shape the data from 49 individual MULTIPOLYGONs into one MULTIPOLYGON:
Finland_all_FINSWE_m_wgs84 <- rmapshaper::ms_dissolve(Finland_all_FINSWE_m_wgs84)

###### Interim test plot -------------------------------------------------------
ggplot() +
  geom_sf(data = Norway_dissolved_wgs84) +
  geom_sf(data = Denmark_sf0) +
  geom_sf(data = Sweden_sf0) +
  geom_sf(data = Finland_dissolved_wgs84) +
  geom_sf(data = Finland_all_FINSWE_m_wgs84) # Adds a manually defined "layer" of Fenno-Swedish municipalities

###### Iceland -----------------------------------------------------------------
sf::st_layers("gadm41_ISL.gpkg")
Iceland_sf0 <- sf::st_read("gadm41_ISL.gpkg", layer = "ADM_ADM_0")

###### Faroe Islands -----------------------------------------------------------
sf::st_layers("gadm41_FRO.gpkg")
FaroeIslands_sf0 <- sf::st_read("gadm41_FRO.gpkg", layer = "ADM_ADM_0")

###### Svalbard and Jan Mayen --------------------------------------------------
sf::st_layers("gadm41_SJM.gpkg")
Svalbard_JanMayen_sf0 <- sf::st_read("gadm41_SJM.gpkg", layer = "ADM_ADM_0")

###### Estonia -----------------------------------------------------------------
sf::st_layers("gadm41_EST.gpkg")
Estonia_sf0 <- sf::st_read("gadm41_EST.gpkg", layer = "ADM_ADM_0")

###### United Kingdom ----------------------------------------------------------
sf::st_layers("gadm41_GBR.gpkg")
GreatBritain_sf0 <- sf::st_read("gadm41_GBR.gpkg", layer = "ADM_ADM_0")

###### Ireland -----------------------------------------------------------------
sf::st_layers("gadm41_IRL.gpkg")
Ireland_sf0 <- sf::st_read("gadm41_IRL.gpkg", layer = "ADM_ADM_0")

###### Isle of Man -------------------------------------------------------------
sf::st_layers("gadm41_IMN.gpkg")
IsleofMan_sf0 <- sf::st_read("gadm41_IMN.gpkg", layer = "ADM_ADM_0")

###### Latvia ------------------------------------------------------------------
sf::st_layers("gadm41_LVA.gpkg")
Latvia_sf0 <- sf::st_read("gadm41_LVA.gpkg", layer = "ADM_ADM_0")

###### Lithuania ---------------------------------------------------------------
sf::st_layers("gadm41_LTU.gpkg")
Lithuania_sf0 <- sf::st_read("gadm41_LTU.gpkg", layer = "ADM_ADM_0")

###### Russia ------------------------------------------------------------------
sf::st_layers("gadm41_RUS.gpkg")
Russia_sf0 <- sf::st_read("gadm41_RUS.gpkg", layer = "ADM_ADM_0")

###### Germany -----------------------------------------------------------------
sf::st_layers("gadm41_DEU.gpkg")
Germany_sf0 <- sf::st_read("gadm41_DEU.gpkg", layer = "ADM_ADM_0")

###### Poland ------------------------------------------------------------------
sf::st_layers("gadm41_POL.gpkg")
Poland_sf0 <- sf::st_read("gadm41_POL.gpkg", layer = "ADM_ADM_0")

###### Netherlands -------------------------------------------------------------
sf::st_layers("gadm41_NLD.gpkg")
Netherlands_sf0 <- sf::st_read("gadm41_NLD.gpkg", layer = "ADM_ADM_0")


##### sf object manipulation ---------------------------------------------------
# Harmonise sf objects with divergent structures and contents, to enable
# subsequent merger into "Europe_sf0":

Norway_dissolved_wgs84 <- Norway_dissolved_wgs84 %>%
  rename("geom" = "geometry") %>%
  rename("GID_0" = "rmapshaperid") %>%
  mutate("COUNTRY" = "Norway", .before = "geom") %>%
  mutate("GID_0" = "NOR")

Finland_dissolved_wgs84 <- Finland_dissolved_wgs84 %>%
  rename("GID_0" = "rmapshaperid") %>%
  mutate("COUNTRY" = "Finland", .before = "geom") %>%
  mutate("GID_0" = "FIN")

Finland_all_FINSWE_m_wgs84 <- Finland_all_FINSWE_m_wgs84 %>%
  rename("GID_0" = "rmapshaperid") %>%
  mutate("COUNTRY" = "Fenno-Swedish", .before = "geom") %>% # Arbitrary name
  mutate("GID_0" = "FINSWE") # Arbitrary name

# Given the chosen method for plotting data below, the complex sf object created
# below should contain all desired and relevant individual countries that will
# or might be visible on the plot.

# Merge desired and relevant individual countries into a complex sf object:
Europe_sf0 <- rbind(
  Norway_dissolved_wgs84, Denmark_sf0, Sweden_sf0,
  Finland_dissolved_wgs84, Iceland_sf0, FaroeIslands_sf0,
  Svalbard_JanMayen_sf0, Estonia_sf0, GreatBritain_sf0,
  Ireland_sf0, IsleofMan_sf0, Latvia_sf0, Lithuania_sf0,
  Russia_sf0, Germany_sf0, Poland_sf0, Netherlands_sf0,
  Finland_all_FINSWE_m_wgs84
)

# Uncomment if desired:
# Europe_simplified_sf0 <- rbind(
#   Norway_dissolved_wgs84, Denmark_sf0,
#   Sweden_sf0, Finland_dissolved_wgs84, Iceland_sf0,
#   FaroeIslands_sf0, GreatBritain_sf0, Ireland_sf0,
#   IsleofMan_sf0, Estonia_sf0, Latvia_sf0,
#   Lithuania_sf0, Germany_sf0, Poland_sf0,
#   Netherlands_sf0, Finland_all_FINSWE_m_wgs84
# )


##### Create subsets for NALS countries and areas ------------------------------
NALS_subset <- subset(
  Europe_sf0,
  COUNTRY == "Denmark" | COUNTRY == "Norway" | COUNTRY == "Sweden" | COUNTRY == "Iceland" | COUNTRY == "Faroe Islands" | COUNTRY == "Fenno-Swedish"
)
Europe_excl_NALS <- subset(
  Europe_sf0,
  COUNTRY != "Denmark" & COUNTRY != "Norway" & COUNTRY != "Sweden" & COUNTRY != "Iceland" & COUNTRY != "Faroe Islands" & COUNTRY != "Fenno-Swedish"
)


###### Norway subset -----------------------------------------------------------
# (See this for information about left_join-ing: https://github.com/tidyverse/dplyr/issues/2833)
tibble_obj_NOR <- tibble(
  COUNTRY = c("Denmark", "Norway", "Sweden", "Iceland", "Faroe Islands", "Fenno-Swedish"),
  ID = c("North Germanic area", "Norway", "North Germanic area", "North Germanic area", "North Germanic area", "North Germanic area")
)
NALS_subset_NOR <- NALS_subset %>%
  left_join(tibble_obj_NOR, by = "COUNTRY")

# Check Norway subset for the Norwegian NALS map:
ggplot() +
  geom_sf(data = NALS_subset_NOR)


###### Denmark subset ----------------------------------------------------------
tibble_obj_DNK <- tibble(
  COUNTRY = c("Denmark", "Norway", "Sweden", "Iceland", "Faroe Islands", "Fenno-Swedish"),
  ID = c("Denmark", "North Germanic area", "North Germanic area", "North Germanic area", "North Germanic area", "North Germanic area")
)
NALS_subset_DNK <- NALS_subset %>%
  left_join(tibble_obj_DNK, by = "COUNTRY")

# Check Denmark subset for the Danish NALS map (should plot identically as with
# NALS_subset_NOR):
ggplot() +
  geom_sf(data = NALS_subset_DNK)


#### General plot formatting ---------------------------------------------------
##### Font ---------------------------------------------------------------------
# (Check available font options, cf. the "Extrafont" subsection above.)
my_font <- "Gentium Book Basic" # Customise if desired

##### General map theme customisation ------------------------------------------
# Check theme attributes if desired:
#theme_get()

# Setting the following options makes several steps in the ggplot() unnecessary:
theme_update(
  text = element_text(size = 12, family = my_font),
  legend.text = element_text(size = 12)
)

# For geom_text_repel text size: X * 0.36
# (cf.: https://stackoverflow.com/questions/25061822/ggplot-geom-text-font-size-control)


#### Create NALS map of Norway -------------------------------------------------
##### Data – Norway – NWD data point coördinates -------------------------------
# Here, data point coördinates are imported from CSV files.

#NWD_NOR_DP_coordinates <- read.csv("C:\\Users\\eirikten\\Dropbox (UiO)\\PhD\\NALS-artiklar\\NWD_NOR_DP_coordinates.csv", sep = ";", fileEncoding = "UTF-8-BOM", check.names = FALSE)
NWD_NOR_DP_coordinates <- read.csv("G:\\Dropbox (UiO)\\PhD\\NALS-artiklar\\NWD_NOR_DP_coordinates.csv", sep = ";", fileEncoding = "UTF-8-BOM", check.names = FALSE)

# Separate and move the comma-separated latitude and longitude values in the
# 'Koordinatar_WGS84' column into two corresponding columns:
NWD_NOR_DP_coordinates <- separate(NWD_NOR_DP_coordinates, Koordinatar_WGS84, into = c("Latitude", "Longitude"), sep = ",")
NWD_NOR_DP_coordinates[c("Longitude", "Latitude")] <- lapply(NWD_NOR_DP_coordinates[c("Longitude", "Latitude")], as.numeric)

# Merge the coördinates into a geometry column, to be sf compatible (see https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html):
NWD_NOR_DP_coordinates <- st_as_sf(NWD_NOR_DP_coordinates, coords = c("Longitude", "Latitude"), remove = FALSE, crs = 4326, agr = "constant")

# If desired, rename column names and/or add parameters:
NWD_NOR_DP_coordinates <- NWD_NOR_DP_coordinates %>%
  rename("Place" = "Stad") %>%
  mutate("Type" = "Participant home town/county/self-defined dialect", .after = "geometry") %>%
  mutate("fillcolour" = "red") %>%
  mutate("colourcolour" = "darkred")

# Check sf/data.frame object:
str(NWD_NOR_DP_coordinates)

##### Data – Norway – NWD recording location coördinates -----------------------
#NWD_NOR_RL_coordinates <- read.csv("C:\\Users\\eirikten\\Dropbox (UiO)\\PhD\\NALS-artiklar\\NWD_NOR_RL_coordinates.csv", sep = ";", fileEncoding = "UTF-8-BOM", check.names = FALSE)
NWD_NOR_RL_coordinates <- read.csv("G:\\Dropbox (UiO)\\PhD\\NALS-artiklar\\NWD_NOR_RL_coordinates.csv", sep = ";", fileEncoding = "UTF-8-BOM", check.names = FALSE)

# Separate and move the comma-separated latitude and longitude values in the
# 'Koordinatar_WGS84' column into two corresponding columns:
NWD_NOR_RL_coordinates <- separate(NWD_NOR_RL_coordinates, Koordinatar_WGS84, into = c("Latitude", "Longitude"), sep = ",")
NWD_NOR_RL_coordinates[c("Longitude", "Latitude")] <- lapply(NWD_NOR_RL_coordinates[c("Longitude", "Latitude")], as.numeric)

# Merge the coördinates into a geometry column, to be sf compatible (see https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html):
NWD_NOR_RL_coordinates <- st_as_sf(NWD_NOR_RL_coordinates, coords = c("Longitude", "Latitude"), remove = FALSE, crs = 4326, agr = "constant")

# If desired, rename column names and/or add parameters:
NWD_NOR_RL_coordinates <- NWD_NOR_RL_coordinates %>%
  rename("Place" = "Stad") %>%
  mutate("Type" = "Recording location", .after = "geometry") %>%
  mutate("fillcolour" = "blue") %>%
  mutate("colourcolour" = "darkblue")

# Check sf/data.frame object:
str(NWD_NOR_RL_coordinates)

##### Data point formatting ----------------------------------------------------
# These three objects can be skipped if specified directly in the ggplot().
#NWD_NOR_DP_coordinates_sf <- geom_sf(data = NWD_NOR_DP_coordinates, size = 5, shape = 21, aes(colour = as.factor(Type), fill = as.factor(Type)), show.legend = TRUE)
#NWD_NOR_RL_coordinates_sf <- geom_sf(data = NWD_NOR_RL_coordinates, size = 5, shape = 21, aes(colour = as.factor(Type), fill = as.factor(Type)), show.legend = TRUE)

# Merge the two coördinate objects into one, and format if desired:
NWD_NOR_coordinates <- rbind(NWD_NOR_DP_coordinates, NWD_NOR_RL_coordinates)
#NWD_NOR_coordinates_sf <- geom_sf(data = NWD_NOR_coordinates, size = 5, shape = 21, aes(colour = as.factor(Type), fill = as.factor(Type)), show.legend = TRUE)


##### Plot NALS map of Norway --------------------------------------------------
# "#E4F4FF" -> Very pale blue: Sea + border of other than NALS countries
# "#D9DCE6" -> Light grayish blue: Fill of other than NALS countries
# "#7DAADC" -> Very soft blue: Diagonal stripes of NALS countries
# "#436B95" -> Dark moderate blue: Border of main NALS country(-ies) of interest
# "#79ABDC" -> Soft blue: Fill of main NALS country(-ies) of interest
# Customise the colours if desired.
# 
# panel.border = element_rect(fill = NA) –> Creates the black panel border
# guide = guide_legend(order = n) -> Lets you control the elements' legend order

NALSNorwayPlot <- ggplot() +
  geom_sf(
    data = Europe_excl_NALS,
    colour = "#E4F4FF",
    fill = "#D9DCE6"
  ) +
  ggpattern::geom_sf_pattern(
    data = NALS_subset_NOR,
    aes(
      fill = ID,
      colour = ID,
      pattern_density = ID,
      geometry = geom
    ),
    pattern = "stripe",
    pattern_fill = "#7DAADC",
    pattern_colour = "#7DAADC",
    pattern_spacing = 0.01,
    pattern_angle = 45
  ) + # Set these values manually
  theme_void() +
  theme(
    panel.background = element_rect("#E4F4FF"),
    panel.border = element_rect(fill = NA)
  ) +
  scale_colour_manual(values = c("Norway" = "#436B95", "North Germanic area" = "#7DAADC"), limits = c("Norway", "North Germanic area"), guide = guide_legend(order = 2)) +
  scale_fill_manual(values = c("Norway" = "#79ABDC", "North Germanic area" = "white"), limits = c("Norway", "North Germanic area"), guide = guide_legend(order = 2)) +
  scale_pattern_density_manual(values = c("Norway" = 0, "North Germanic area" = 0.01), limits = c("Norway", "North Germanic area"), guide = guide_legend(order = 2)) + # Set these values manually
  new_scale_colour() +
  new_scale_fill() +
  geom_sf(
    data = NWD_NOR_coordinates,
    size = 5,
    shape = 21,
    aes(
      colour = as.factor(Type),
      fill = as.factor(Type)
    )
  ) + # Set these values manually
  geom_label_repel(
    data = NWD_NOR_coordinates,
    aes(x = Longitude, y = Latitude, label = Place),
    family = my_font,
    size = 12 * 0.36,
    nudge_x = c(0, 0, 5, 6, -2.5, -4, 5, -3, -4, 6, 0, 4, -1),
    nudge_y = c(-0.8, 1, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.8, 0, 1)
  ) + # Set these values manually
  scale_colour_manual(values = c("Participant home town/county/self-defined dialect" = "darkred", "Recording location" = "darkblue"), guide = guide_legend(order = 1)) + # Set these values manually
  scale_fill_manual(values = c("Participant home town/county/self-defined dialect" = "red", "Recording location" = "blue"), guide = guide_legend(order = 1)) + # Set these values manually
  coord_sf(xlim = c(2.5, 32.5), ylim = c(57.3, 72), expand = FALSE) + # Set these values manually
  theme(
    text = element_text(family = my_font),
    legend.title = element_blank(),
    legend.position = c(0.24, 0.92) # Set these values manually
  ) +
  annotation_scale(location = "br", width_hint = 0.3, text_family = my_font) # Set these values manually

NALSNorwayPlot

ggsave(paste0("NALS_Norway_", format(Sys.time(), "%Y.%m.%d_%H-%M"), ".png"),
  plot = NALSNorwayPlot,
  dpi = 600,
  width = 6.70,
  height = 7.65
)

# I visually determined using the preview function that the output export
# dimensions should be: width = 670; height = 765. I saved in 600 DPI PNG. For
# PDF and automising the process, see, e.g.,: https://www.pmassicotte.com/posts/2019-12-20-removing-borders-around-ggplot2-graphs/


#### Create NALS map of Denmark ------------------------------------------------
##### Data – Denmark - NWD data point/recording locations coördinates ----------
# Here, data point coördinates are imported from CSV files.

NWD_DNK_DP_coordinates <- read.csv("G:\\Dropbox (UiO)\\PhD\\NALS-artiklar\\NWD_DNK_DP_coordinates.csv", sep = ";", fileEncoding = "UTF-8-BOM", check.names = FALSE)

# Separate and move the comma-separated latitude and longitude values in the
# 'Koordinatar_WGS84' column into two corresponding columns:
NWD_DNK_DP_coordinates <- tidyr::separate(NWD_DNK_DP_coordinates,
  Koordinatar_WGS84,
  into = c("Latitude", "Longitude"), sep = ","
)
NWD_DNK_DP_coordinates[c("Longitude", "Latitude")] <- lapply(
  NWD_DNK_DP_coordinates[c("Longitude", "Latitude")],
  as.numeric
)

# Merge the coördinates into a geometry column, to be sf compatible (see https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html):
NWD_DNK_DP_coordinates <- sf::st_as_sf(NWD_DNK_DP_coordinates,
  coords = c("Longitude", "Latitude"), remove = FALSE, crs = 4326, agr = "constant"
)

# If desired, rename column names and/or add parameters:
NWD_DNK_DP_coordinates <- NWD_DNK_DP_coordinates %>%
  rename("Place" = "Stad") %>%
  mutate("Type" = "Recording location", .after = "geometry") %>%
  mutate("fillcolour" = "red") %>%
  mutate("colourcolour" = "darkred")

# Check sf/data.frame object:
str(NWD_DNK_DP_coordinates)


##### Data point formatting ----------------------------------------------------
# This object can be skipped if specified directly in the ggplot().
# NWD_DNK_DP_coordinates_sf <- geom_sf(
#   data = NWD_DNK_DP_coordinates, size = 5,
#   shape = 21, color = "darkred", fill = "red"
# )


##### Plot NALS map of Denmark -------------------------------------------------
# "#E4F4FF" -> Very pale blue: Sea + border of other than NALS countries
# "#D9DCE6" -> Light grayish blue: Fill of other than NALS countries
# "#7DAADC" -> Very soft blue: Diagonal stripes of NALS countries
# "#436B95" -> Dark moderate blue: Border of main NALS country(-ies) of interest
# "#79ABDC" -> Soft blue: Fill of main NALS country(-ies) of interest
# Customise the colours if desired.
# 
# panel.border = element_rect(fill = NA) –> Creates the black panel border
# guide = guide_legend(order = n) -> Lets you control the elements' legend order

NALSDenmarkPlot <- ggplot() +
  geom_sf(
    data = Europe_excl_NALS,
    colour = "#E4F4FF",
    fill = "#D9DCE6"
  ) +
  ggpattern::geom_sf_pattern(
    data = NALS_subset_DNK,
    aes(
      fill = ID,
      colour = ID,
      pattern_density = ID,
      geometry = geom
    ),
    pattern = "stripe",
    pattern_fill = "#7DAADC",
    pattern_colour = "#7DAADC",
    pattern_spacing = 0.01,
    pattern_angle = 45
  ) + # Set these values manually
  theme_void() +
  theme(
    panel.background = element_rect("#E4F4FF"),
    panel.border = element_rect(fill = NA)
  ) +
  scale_colour_manual(values = c("Denmark" = "#436B95", "North Germanic area" = "#7DAADC"), limits = c("Denmark", "North Germanic area"), guide = guide_legend(order = 2)) +
  scale_fill_manual(values = c("Denmark" = "#79ABDC", "North Germanic area" = "white"), limits = c("Denmark", "North Germanic area"), guide = guide_legend(order = 2)) +
  scale_pattern_density_manual(values = c("Denmark" = 0, "North Germanic area" = 0.01), limits = c("Denmark", "North Germanic area"), guide = guide_legend(order = 2)) + # Set these values manually
  new_scale_colour() +
  new_scale_fill() +
  geom_sf(
    data = NWD_DNK_DP_coordinates,
    size = 5,
    shape = 21,
    aes(
      colour = as.factor(Type),
      fill = as.factor(Type)
    )
  ) +
  geom_label_repel(
    data = NWD_DNK_DP_coordinates,
    aes(x = Longitude, y = Latitude, label = Place),
    size = 12 * 0.36,
    nudge_x = c(0, 1.05),
    nudge_y = c(0.25, 0),
    family = my_font
  ) + # Set these values manually
  scale_colour_manual(values = c("Recording location" = "darkred"), guide = guide_legend(order = 1)) + # Set these values manually
  scale_fill_manual(values = c("Recording location" = "red"), guide = guide_legend(order = 1)) + # Set these values manually
  coord_sf(xlim = c(7.7, 15.6), ylim = c(54.4, 57.9), expand = FALSE) + # Set these values manually
  theme(
    text = element_text(family = my_font),
    legend.title = element_blank(),
    legend.position = c(0.115, 0.92) # Set these values manually
  ) +
  annotation_scale(location = "br", width_hint = 0.3, text_family = my_font) # Set these values manually

NALSDenmarkPlot

ggsave(paste0("NALS_Danmark_", format(Sys.time(), "%Y.%m.%d_%H-%M"), ".png"),
  plot = NALSDenmarkPlot,
  dpi = 600,
  width = 7.12,
  height = 5.66
)

# I visually determined using the preview function that the output export
# dimensions should be: width = 712; height = 566. I saved in 600 DPI PNG. For
# PDF and automising the process, see, e.g.,: https://www.pmassicotte.com/posts/2019-12-20-removing-borders-around-ggplot2-graphs/
