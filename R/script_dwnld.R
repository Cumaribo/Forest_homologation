# Hansen forest  Map Downloader Using Ecochange and determining threshold from an attribute table. 

setwd("~/Documents/biomas_iavh/Matrices_Abril") #keep in mind for the documentation, remove after)


packs <- c('terra', 'raster','rgdal','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtils','gdalUtilities','rgeos', 'viridis',
           'rasterVis','rlang', 'rasterDT', 'ecochange')
out.. <-  sapply(packs, require, character.only = TRUE)

gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
#load Vector Data ROI
           # It uses the attribute table to extract data labeling and parameter definition information (name spatial unit) and splits in the different 
           # objects 
masked <- st_read('biomes_attributes_msk.shp')
labels <- (masked$biome)
#here, you need to filter and select the biome you need. You can filter sf objects with tidyverse)
masked <- masked%>%filter(biome=="casanare") # get the name of the missing Biome)

masked <- as(masked, 'Spatial')
# split mun into list of independent polygons. You don't need it 
#biomat <- masked%>%split(.$biome)

           #Run individual example (documentation R)
 test<- biomat[[i]]
           
suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,18,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)
