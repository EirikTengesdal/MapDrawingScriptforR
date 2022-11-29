# Map Drawing Script for R. NALS – Norway & Denmark.
This repository contains an R script designed to draw maps using *sf* objects and coördinates. Changes to the script and repository might be implemented in the future.

I encourage people to adapt the script to create maps for their own purposes. It is possible to manipulate many factors, thus allowing for substantial customisation.

## About Map Drawing Script for R. NALS – Norway & Denmark.
This script was made to generate maps intended for the papers *Argument placement in Norwegian* (Lundquist & Tengesdal 2022, submitted) and *Argument placement in Danish* (Tengesdal & Larsson 2022, submitted). The maps shown below can be reproduced using the archived script and associated files.

![NALS_Norway.png](https://github.com/EirikTengesdal/MapDrawingScriptforR/blob/main/NALS/NALS_Norway.png)
![NALS_Denmark.png](https://github.com/EirikTengesdal/MapDrawingScriptforR/blob/main/NALS/NALS_Denmark.png)

### Contents
* R script
* Data points and recording location coördinates, CSV files
* Example maps

### About the script and data points
The script basically plots a map using geometric data retrieved from [GADM (Global Administrative Areas; note the license conditions)](https://gadm.org/license.html) and other sources mentioned in the script, which in the case of Denmark provides [the whole country of Denmark](https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_DNK_gpkg.zip). Many other geometric data are compatible with the *sf* package. The script was created to draw a map of Denmark and display the relevant locations where fieldwork data collection for the [Nordic Word Order Database](https://www.hf.uio.no/iln/english/about/organization/text-laboratory/projects/nwd/index.html) took place.

Version 1.0.0 of the script was tailored for creating the NALS map of Norway. Here, other data sources were used in addition to GADM, see more information in the R script file. The two script files were consolidated into the one available in the repository now.

For ease of input, the script loads a CSV file that contains coördinates for the data points that are displayed on the map. The script ensures that the fieldwork location coördinates (i.e., data points) are manipulated such that it is possible to plot them in accordance with the coördinate system with WGS84 datum. Several graphical customisations of colours, font types, annotation scale etc. are achieved through additional functions. The coördinates were mainly collected from [GeoHack](https://geohack.toolforge.org/) via corresponding Wikipedia articles, and verified, and, if applicable, changed, using information from Google Maps.

The data points file can be altered such that other types of coördinate sets can be entered and thus be integrated into a map. It is also possible to leave out data points altogether from the script, and only draw a map.

## Software
The following software has been used in the making of this script:

* Microsoft® Excel® 2021 MSO (latest run version: 2210 Build 16.0.15726.20188) 64-bit
* RStudio (latest run version: 2022.7.1.554)
* R (latest run version: 4.1.2)
  * R packages (latest run version numbers within parentheses):
	  * ggplot2 (3.4.0)
	  * ggspatial (1.1.6)
	  * ggrepel (0.9.1)
	  * sf (1.0.8)
	  * dplyr (1.0.10)
	  * tidyr (1.2.1)
	  * stringi (1.7.8)
	  * ggnewscale (0.4.7)
	  * ggpattern (1.0.1)
	  * extrafont (0.18)
	  * httr (1.4.4)
	  * ows4R (0.3.2)
	  * purrr (0.3.4)

The following packages were crucial for the drawings (the other packages were important data manipulation tools):

* ggplot2
* ggspatial
* ggrepel
* ggnewscale
* ggpattern
* sf

## History
**Version 2.0.0** (2022.11.30): Updated script to include other European countries, based on an improved script (yet to be made available in Github or Zenodo) 					used to create a map for another manuscript. Consolidated two scripts (Norway & Denmark) into one. Updated citation information 				and other details. Deleted "NALS_Denmark" repository folder. Added new files to repository.

**Version 1.0.0** (2021.08.06): Added repository to GitHub. Included script for NALS_Denmark.

## Citation information
Please cite the script if you use it. The following citation example could be used (but it should be customised according to relevant citation style in academic contexts, version number, and the Zenodo DOI address of the specific release):

Tengesdal, Eirik. 2022. Map Drawing Script for R. NALS – Norway & Denmark (Version 2.0.0). [Software]. DOI: https://doi.org/10.5281/zenodo.7379009

Example of BibTeX entry:
```
@software{Tengesdal_MapDrawingScriptforR_2021,
  author       = {Tengesdal, Eirik},
  title        = {{Map Drawing Script for R. NALS – Norway & Denmark [Software]}},
  year         = {2022},
  publisher    = {Zenodo},
  version      = {2.0.0},
  doi          = {https://doi.org/10.5281/zenodo.7379009}
}
```

Please note that the following Concept DOI represents all of the versions of the record, and will currently resolve to the landing page of the latest version of the record: https://doi.org/10.5281/zenodo.5167687

The recommended practice is to cite a specific version of the repository. Find the relevant Version DOI at Zenodo, for instance via the Concept DOI above.

## Funding
Parts of this work has been funded by the Research Council of Norway project *Variation and Change in the Scandinavian Verb Phrase* (project number: 250755, PI: Ida Larsson).

## DOI
[![DOI](https://zenodo.org/badge/393439333.svg)](https://zenodo.org/badge/latestdoi/393439333)

## License and copyright
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

© 2021–2022 Eirik Tengesdal

Licensed under the [MIT License](LICENSE).

## Contact
Eirik Tengesdal  
Department of Linguistics and Scandinavian Studies, University of Oslo  
eirik.tengesdal@iln.uio.no / eirik@tengesdal.name  
ORCID iD: [0000-0003-0599-8925](https://orcid.org/0000-0003-0599-8925)
