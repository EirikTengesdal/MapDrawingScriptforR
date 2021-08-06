# Map Drawing Script for R
This repository contains an R script designed to draw maps using *sf* objects and coördinates. More scripts will be added to this repository in the future.

I encourage people to adapt the script to create maps for their purposes. It is possible to manipulate many factors, thus allowing for substantial customisation.

## About NALS – Denmark
This script was used to create the map in the paper *Argument Placement in Danish* (Tengesdal, 2021, manuscript for [NALS](https://journals.uio.no/index.php/NALS/index)). The map shown below can be reproduced using the archived script and associated files.

![NALS_Denmark_GitHub.svg](https://github.com/EirikTengesdal/MapDrawingScriptforR/blob/main/NALS_Denmark/NALS_Denmark_GitHub.svg)

### Contents
* R script
* Data points, CSV file
* Example map

### About the script and data points
The script basically plots a map using geometric data retrieved from [GADM (Global Administrative Areas; note the license conditions)](https://gadm.org/license.html), which in this case provides [the whole country of Denmark](https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_DNK_gpkg.zip). Many other geometric data are compatible with the *sf* package. The script was created to draw a map of Denmark and display the relevant locations where fieldwork data collection for the [Nordic Word Order Database](https://www.hf.uio.no/iln/english/about/organization/text-laboratory/projects/nwd/index.html) took place.

For ease of input, the script loads a CSV file that contains coördinates for the data points that are displayed on the map. The script ensures that the fieldwork location coördinates (i.e., data points) are manipulated such that it is possible to plot them in accordance with the coördinate system with WGS84 datum. Several graphical customisations of colours, font types, annotation scale etc. are achieved through additional functions. The coördinates were collected from [GeoHack](https://geohack.toolforge.org/) via corresponding Wikipedia articles, and verified, and, if applicable, changed, using information from Google Maps.

The data points file can be altered such that other types of coördinate sets can be entered and thus be integrated into a map. It is also possible to leave out data points altogether from the script, and only draw a map.

## Software
The following software has been used in the making of this script:

* Microsoft® Excel® 2016 (latest run version: 16.0.5173.1000) 32-bit
* RStudio (latest run version: 1.3.1093)
* R (latest run version: 4.0.4)
  * R packages (latest run version numbers within parentheses):
	  * ggplot2 (3.3.3)
	  * ggspatial (1.1.5)
	  * ggrepel (0.9.1)
	  * sf (0.9.8)
	  * dplyr (1.0.2)
	  * tidyr (1.1.2)
	  * extrafont (0.17)

The following packages were crucial for the drawings (the other packages were important data manipulation tools):

* ggplot2
* ggspatial
* ggrepel
* sf

## History
**Version 1.0.0** (2021.08.06): Added repository to GitHub. Included script for NALS_Denmark.

## Citation information
Please cite the script if you use it. The following citation example could be used (but it should be customised according to relevant citation style):

Tengesdal, Eirik. 2021. Map Drawing Script for R (Version 1.0.0). [Software]. Available from https://github.com/EirikTengesdal/MapDrawingScriptforR

Example of BibTeX entry:
```
@misc{Tengesdal2021_MapDrawingScriptforR,
    title   = {{Map Drawing Script for R (Version 1.0.0). [Software]}},
    author  = {Tengesdal, Eirik},
    url     = {https://github.com/EirikTengesdal/MapDrawingScriptforR},
    year    = {2021}
}
```

## Funding
Parts of this work has been funded by the Research Council of Norway project *Variation and Change in the Scandinavian Verb Phrase* (project number: 250755, PI: Ida Larsson).

## License and copyright
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

© 2021 Eirik Tengesdal

Licensed under the [MIT License](LICENSE).

## Contact
Eirik Tengesdal  
Department of Linguistics and Scandinavian Studies, University of Oslo  
eirik.tengesdal@iln.uio.no / eirik@tengesdal.name  
ORCID iD: [0000-0003-0599-8925](https://orcid.org/0000-0003-0599-8925)
