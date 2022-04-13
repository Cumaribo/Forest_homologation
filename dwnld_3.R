
remove.packages('raster')

remove.packages(c('rgdal','sp','stringi', 'raster'))

detach(package:ggplot2,unload=TRUE)
detach(package:raster,unload=TRUE)



install.packages(c('raster', 'rgdal'))


.libPaths()

library(raster)
library(rgdal)
library(forestChange)
library(parallel)
library(sf)
library(tidyverse)
library(purrr)
library(furrr)
library(diffeR)
library(useful)
library(ecochange)

gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))


p_unlock()

install.packages('pacman')
library(pacman)
year. <- 19

test1 <- map(1:length(perc2), function(x) echanges(mun, lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                                                          path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                                                          eco_range = c(perc2[x],100),      # Umbral de treecover2000
                                                          change_vals = year.,      # en este caso, los años de pérdida,
                                                          mc.cores = 6)     # número de núcleos, solo funciona en sistema linux
             )
future_map(1:length(perc2), function(x) writeRaster(test1[[x]], paste(year., 'cum', perc2[x], sep='_'), format='GTiff')) 

getwd()

def

test1

getwd()


mun <- st_read('/storage/home/TU/tug76452//Ecosistemas_Colombia/ContornoColombia.geojson')
mun <- mun[!st_is_empty(mun),,drop=FALSE]

                                        #make sure that your vectorfile is in crs=WGS84, as this is the one of the gobal forest dataset.
                                        # if necessary, use this to reproject:
                                        #mun <- spTransform(mun, crs='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
                                        #Do not do this here, it messes with the encoding of accents!!!!!!!!!!!!!!!!!!!!
                                        #Sys.setlocale(locale="C")
                                        # # convert map into spatial polygon dataframe.
mun <- st_make_valid(mun)
mun <- as(mun, 'Spatial')


                                        # # create vector withe the threshold you want to iterate.
                                       # # Warning, this process requires a lot of temp memory, so make sure to have enough storage space or split your process in smaller chuncks
######################
perc2 <- c(94,93)

,92,91,90)#,85,80,75,70,65,60,55,50,40,30,20)
                                        # # this creates a vector of names from the vector
perccar <- as.character(perc2)
                                        # # set a temporary working folder.

                                        #this is the function to  use if there is enough storage space (runs in the lab, but not in Nimbus
                                        # because Nimbus):

dir.create('tempfiledir2')
tempdir=paste(getwd(),'tempfiledir2', sep="/")
rasterOptions(tmpdir=tempdir)

year.=2019
test_map <- map(1:length(perccar), function(x) FCMask(mun, year=year., cummask=TRUE, perc=perc2[x]:100, mc.cores=14))
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=6)
options(future.globals.maxSize= mem_future)
 future <- map(1:length(test_map), function(x) writeRaster(test_map[[x]], paste(year., 'cum', perccar[x], sep='_'), format='GTiff')) 

year.=2019
perc. <- 95

band1 <- FCMask(mun, year., cummask=TRUE, perc=perc., mc.cores=6)
writeRaster(band1, paste(year., 'cum', perc., sep='_'), format='GTiff')

test_map


install.packages("sf")

## Second, install ecochange
install.packages("ecochange")

## the package will install dependencies in the next vector excepting the last three ones (they are suggested deps)
depends <- c("raster","rgeos","stats","ggplot2","sf","gdalUtils","readr","rgdal","parallel","curl","gdalUtilities","graphics","rvest","landscapemetrics","sp","tibble","utils","xml2","dplyr","R.utils","httr","getPass","methods","rlang","forcats","lattice","rasterDT","data.table","viridis","knitr","rmarkdown","rasterVis")

## check depends status
packsStatus <- sapply(depends, require, character.only = TRUE)

## Install suggests
suggests <- c('knitr', 'rmarkdown', 'rasterVis') 
sapply(suggests, install.packages, character.only = TRUE)


## check depends and suggests status
packsStatus <- sapply(depends, require, character.only = TRUE)
all(packsStatus)#TRUE



##Example
require("ecochange")


load(system.file('cchaira_roi.RData',package = 'ecochange'))

ebv <- echanges(cchaira_roi,
                lyrs = c('treecover2000','lossyear'),
                change_vals = seq(19,20,1))#,
mc.cores= 10)


updateR()
update.packages(ask = FALSE)

