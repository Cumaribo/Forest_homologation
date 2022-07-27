#This scripts sets the environment

#Load greenbrown from source
#load libraries.
packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf',
           'diffeR', 'greenbrown', 'gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 
           'ecochange', 'furrr')
out.. <-  sapply(packs, install.packages, character.only = TRUE)
out.. <-  sapply(packs, require, character.only = TRUE)

#Set temp directory (optional)
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#Set the memory limit for parallel running
# Today, 25/07/2022 future_map is not working on Mac or Linux. Find out why. 
mem_future <- 5000*1024^2 #this is to set the limit to 5GB
plan(multisession, workers=7)
options(future.globals.maxSize= mem <- future)
