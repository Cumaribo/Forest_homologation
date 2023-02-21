
                                        # Hansen forest  Map Downloader Using Ecochange and determining threshold from an attribute table. 

setwd("~/Documents/biomas_iavh/Matrices_Abril") #keep in mind for the documentation, remove after)


packs <- c('terra', 'raster','rgdal','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtilities','rgeos',
           'rasterVis','rlang', 'rasterDT', 'ecochange')

#out.. <-  sapply(packs, install.packages, character.only = TRUE)
out.. <-  sapply(packs, require, character.only = TRUE)



gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))

setwd('~/Forest_Armonization/FINAL_HANSEN/output_armonization')

getwd()

#load Vector Data ROI
           # It uses the attribute table to extract data labeling and parameter definition information (name spatial unit) and splits in the different 
           # objects 
masked <- st_read('biomes_attributes_msk.shp')
labels <- (masked$biome)

                                        #here, you need to filter and select the biome you need. You can filter sf objects with tidyverse)
masked <- masked%>%subset(!is.na(accurcy))
masked <- as(masked, 'Spatial')
# split mun into list of independent polygons. You don't need it 
#biomat <- masked%>%split(.$biome)

biomat <- masked%>%split(.$biome)


           #Run individual example (documentation R)
#with one polygon           
suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,18,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)

#with a list of polygons
suppressWarnings(
  def <- map(1:length(masked, function(x) echanges(biomat[[x]],   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(biomat[[x]]$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,21,1),      # en este caso, los años de pérdida, 
                  mc.cores = 7)     # número de núcleos, solo funciona en sistema linux
))


biomat[[1]]$thrshld
