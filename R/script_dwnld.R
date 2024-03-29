
                                        # Hansen forest  Map Downloader Using Ecochange and determining threshold from an attribute table. 

setwd("~/Documents/biomas_iavh/Matrices_Abril") #keep in mind for the documentation, remove after)
#setwd('/Users/sputnik/Documents/biomas_iavh/Biomas IAvH')
packs <- c('terra', 'raster','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass',
           'rasterVis','rlang', 'rasterDT', 'ecochange')

#out.. <-  sapply(packs, install.packages, character.only = TRUE)
out.. <-  sapply(packs, require, character.only = TRUE)

#gdalUtils::gdal_setInstallation()
#valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
setwd('~/Forest_Armonization/FINAL_HANSEN/output_armonization')

getwd()

#load Vector Data ROI
           # It uses the attribute table to extract data labeling and parameter definition information (name spatial unit) and splits in the different 
           # objects 
masked <- st_read('biomes_attributes_msk.shp')
#masked <- st_read('/Users/sputnik/Documents/biomas_iavh/Final_results_Codename_Abril/biomes_attributes_msk.shp')
masked <- st_transform(masked,crs=4326)


masked


st_crs(masked) <- 4326

                                        #here, you need to filter and select the biome you need. You can filter sf objects with tidyverse)
masked <- masked%>%subset(!is.na(accurcy))
labels <- (masked$biome)


masked <- as(masked, 'Spatial')
# split mun into list of independent polygons. You don't need it 
#biomat <- masked%>%split(.$biome)

biomat <- masked%>%split(.$biome)
           #Run individual example (documentation R)
<<<<<<< HEAD
                                        #with one polygon

test <- biomat[[1]]

=======
#with one polygon
test <- biomat[[1]]           
>>>>>>> 95da32ec57ae801abeb4b38478dc52db087cca55
suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,18,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)

#with a list of polygons
<<<<<<< HEAD
   def <- map(1:1, function(x) echanges(biomat[[x]],   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
=======
#suppressWarnings(
  def <- map(1:10, function(x) echanges(biomat[[x]],   # polígono 
                  lyrs = c('treecover2000','lossyear'),
                  #eco = 'treecover2000',
                  #change = 'lossyear',      # nombres de las capas
>>>>>>> 95da32ec57ae801abeb4b38478dc52db087cca55
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(biomat[[x]]$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,21,1),      # en este caso, los años de pérdida, 
                  mc.cores = 7)     # número de núcleos, solo funciona en sistema linux
<<<<<<< HEAD
             )



biomat[[1]]


rm(biomat)

biomat[[1]]

st_crs(biomat[[1]])



st_crs(masked)

$thrshld



rlang::last_error()
=======
)

  raster_list <- list()
  for (i in seq_along(def)) {
    raster_list[[i]] <- def[[i]]
  }  
  
def. <- map(1:def[[1]], stack)


biomat[[1]]$thrshld
>>>>>>> 95da32ec57ae801abeb4b38478dc52db087cca55
