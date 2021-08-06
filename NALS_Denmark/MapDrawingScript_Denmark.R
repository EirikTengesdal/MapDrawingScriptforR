##### Map Drawing Script for R. NALS – Denmark #####
##### This script was created for generating the map in the paper 'Argument Placement in Danish' (Tengesdal, 2021, manuscript for NALS). #####

# © 2021 Eirik Tengesdal
# Licensed under the MIT License.


#### Acknowledgments ####
# The script is inspired by several online resources, most importantly the following: https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html


#### Package installation ####
# Install the following packages if needed; comment out if already installed. I have used RStudio for this.

install.packages(c("ggplot2",
                   "ggspatial",
                   "ggrepel",
                   "sf",
                   "dplyr",
                   "tidyr",
                   "extrafont"))


#### Libraries ####
### Extrafont – for using specific fonts that are not readily available in R. You can skip this step if you do not need a special font. ###

library("extrafont")
# For importing non-standard fonts. After setting up the first time, it should be sufficient only to load this library, without going through the next steps.

font_import(paths = "~\\template-nals\\fonts\\required")
# Replace with the path to the folder that contains your desired fonts. You should only need to do this once; after importing, you can comment this out.

fonts()
# This function lists fonts such that you can find the correct font name to be specified in the "family" argument below.

loadfonts(device = "win")
# For Windows users.

windowsFonts()
# Check to find font name, to be called in the text_family argument. This is important, because the font name to be used in the script might not be identical to the font name itself.

### Other libraries ###

library("ggplot2")    # For plotting
theme_set(theme_bw()) # A ggplot2 function for creating maps without prespecified formatting.
library("ggspatial")  # For creating scale bar.
library("ggrepel")    # For repelling text labels in the map.
library("sf")         # For drawing maps.
library("dplyr")      # For filtering, used for the input CSV; can be omitted.
library("tidyr")      # For the function separate(), used for the input CSV; can be omitted.


##### DRAW MAP #####
#### RETRIEVE GEOMETRIC MAP DATA FROM GADM ####
# The use of GADM data (https://gadm.org/maps.html) are subject to license. As of 05.08.2021, the conditions are:
# "The data are freely available for academic use and other non-commercial use. Redistribution, or commercial use, is not allowed without prior permission. Using the data to create maps for academic publishing is allowed."

# I recommend using the Geopackage data. The sf package can read this, and it contains all the layers ("level-0, level1, level2") that you otherwise will have to download as separate files.


##### DENMARK MAP #####
setwd("C:\\Users\\eirikten\\Dropbox (UiO)\\RStudio\\Maps")
# Replace with relevant working directory. Place the other files within the working directory to avoid having to specify another path later (e.g., for the CSV file).

st_layers("gadm36_DNK.gpkg")
# Display the available layers. Here, I used the Geopackage data from GADM, which contains 3 layers for Denmark.

Denmark_sf0 <- st_read("gadm36_DNK.gpkg", layer = "gadm36_DNK_0")
# Select the relevant layer. For this map, I only want the country outline, which is layer 0, and I assigned this to Denmark_sf0.

ggplot(data = Denmark_sf0) +
  geom_sf()
# Plot for the map of Denmark without any customisation. This step can be run to verify that the map data are drawable.


#### DATA - Denmark - data points ####
# Note that some operations are unnecessary and can be commented out.

# Read the CSV file which contains the coördinates (Format = Column A: Stad, 'Place'; Column B: Koordinatar_WGS84, 'Coördinates_WGS84'; pasted from GeoHack without formatting for ease of input).

Denmark_DP <- read.csv("Denmark_DP.csv", sep = ";", check.names = FALSE)
#Denmark_DP <- read.csv("Denmark_DP.csv", sep = ";", encoding = "UTF-8", check.names = FALSE)
# Replace with relevant path. The UTF-8 encoding might be needed for the special characters 'æ' and 'ø' included in the CSV.

Denmark_DP <- tidyr::separate(Denmark_DP, Koordinatar_WGS84, into = c("Latitude", "Longitude"), sep = ",")
# tidyr function for separating the longitude and latitude coördinates that were separated by a comma in the input CSV, now into separate columns.

Denmark_DP[c("Longitude","Latitude")] <- lapply(Denmark_DP[c("Longitude","Latitude")], as.numeric)
# The longitude and latitude columns must be numeric for geom_sf().

Denmark_DP <- sf::st_as_sf(Denmark_DP, coords = c("Longitude","Latitude"), remove = FALSE, crs = 4326, agr = "constant")
# Create a new geometry column that combines the coördinates, enabling the usage of st_to_sf(). See more explanation for the attributes here: https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html

names(Denmark_DP)[1] <- "Place"
# Rename the input 'Stad' to 'Place', without changing the input CSV file.

Denmark_DP[2,1] <- "Copenhagen"
# Rename 'København' to 'Copenhagen', without changing the input CSV file.

str(Denmark_DP)
# Display string for confirmation.


#### DATA POINT APPEARANCE ####
Denmark_DP_sf <- geom_sf(data = Denmark_DP, size = 4, shape = 21, color = "darkred", fill = "red")
# geom_sf() is necessary. The attributes are called already here to facilitate making changes to the point appearance, especially if you want to use the same points in several plots with identical formatting.
# For an overview of point shapes, see for instance: http://www.sthda.com/english/wiki/ggplot2-point-shapes


##### PLOTTING #####
Denmark_plot <- ggplot(data = Denmark_sf0) +
  geom_sf(color = "#7DAADC", fill = "#7DAADC") +
  Denmark_DP_sf +
  theme_void() +
  theme(panel.background = element_rect("#DCE1EB")) +
  geom_text_repel(data = Denmark_DP, aes(x = Longitude, y = Latitude, label = Place, family = "Gentium Book Basic"),
                  size = 5,
                  nudge_x = c(0,1.5),
                  nudge_y = c(0.5,0)) +
  annotation_scale(location = "bl", width_hint = 0.3, text_family = "Gentium Book Basic")

Denmark_plot

# I visually determined using the preview function in 'Save as image...' that the following output export dimensions for this plot appear satisfactory: width = 693; height = 557. I saved the plot in the Scalable Vector Graphics (SVG) format. For PDF and automatising the process, see for instance: https://www.pmassicotte.com/post/removing-borders-around-ggplot2-graphs/

#### TROUBLESHOOTING ####
# In the event of problems, make sure that your packages are updated.
# For instance, an outdated version of the sf package might produce an error message like "Input must be a vector, not a `sfc_MULTIPOLYGON/sfc` object.".
