# Map downloader. I intend to develop some way to download the maps that i need using 
# the thresahodls I extracted.

setwd("~/Documents/biomas_iavh/Matrices_Abril")

library(raster)
library(sf)
library(forestChange)
library(maptools)
library(tidyverse)

packs <- c('raster','rgdal','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtils','gdalUtilities','rgeos', 'viridis',
           'rasterVis','rlang', 'rasterDT', 'ecochange')

out.. <-  sapply(packs, require, character.only = TRUE)


gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
#load shapefiles


masked <- st_read('biomes_attributes_msk.shp')
labels <- (masked$biome)
masked <- as(masked, 'Spatial')
# split mun into list of independent polygons  
biomat <- masked%>%split(.$biome)

test <- biomat[[1]]
test <- as(test, 'Spatial')
plot(test)


thr <- test$thrshl


suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,18,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)

c(70,100)
?echanges
?seq
suppressWarnings(
  def <- echanges(pol,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = td,      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(70, 100),      # Umbral de treecover2000
                  change_vals = seq(0,15,5),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)



