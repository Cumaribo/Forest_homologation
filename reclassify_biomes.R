rm(list=ls())

library(raster)
library(tidyverse)
library(furrr)
library(sf)
dir()


library(ecochange)



setwd("~/Documents/biomas_iavh/Matrices_Abril")
masked <- st_read('biomes_msk2.shp')
masked <- (masked%>%filter(thrshld !='NA', drop=TRUE))
labels <- (masked$biome)
rm(masked)

setwd("~/Documents/biomas_iavh/Builder_f")
files <- list.files('.', 'har')
b=9
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=14)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 20000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))



setwd("~/Documents/biomas_iavh/Builder_f")
files <- list.files('.', 'har')
b=3
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=14)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 20000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))
setwd("~/Documents/biomas_iavh/Builder_f")
files <- list.files('.', 'har')
b=7
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=12)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 20000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))
setwd("~/Documents/biomas_iavh/Builder_f")
files <- list.files('.', 'har')
b=8
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=14)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 20000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
# band <- future_map(1:length(band), function(x) projectRaster(band[[x]], crs=crs(mierda)))
# band <- future_map(1:length(band), function(x) round(band[[x]], digits = 0))
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))
b=9
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=12)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 10000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
# band <- future_map(1:length(band), function(x) projectRaster(band[[x]], crs=crs(mierda)))
# band <- future_map(1:length(band), function(x) round(band[[x]], digits = 0))
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))


b=7
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=12)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 10000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))
b=8
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=12)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 10000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
# band <- future_map(1:length(band), function(x) projectRaster(band[[x]], crs=crs(mierda)))
# band <- future_map(1:length(band), function(x) round(band[[x]], digits = 0))
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))
b=9
band <- list()
for(i in 1:length(files)){
  band[i] <- raster(files[i], band=b)
}
plan(multisession, workers=12)
m <- c(-Inf, 0.9, NA, 1, 100.1, 1, 101, Inf, NA)
m <- matrix(m, ncol=3, byrow=TRUE)
band <-future_map(1:length(band), function(x) reclassify(band[[x]], m))
bndcnt <- list()
for(i in 1:length(band)){
  bndcnt[i] <- nlayers(band[[i]])
}
unlist(bndcnt)
band
mem_future <- 10000*1024^2 #thi
options(future.globals.maxSize= mem_future)
setwd("~/Documents/biomas_iavh/builder_f2")
# band <- future_map(1:length(band), function(x) projectRaster(band[[x]], crs=crs(mierda)))
# band <- future_map(1:length(band), function(x) round(band[[x]], digits = 0))
future_map(1:length(band), function(x) writeRaster(band[[x]], paste(labels[x], 'bnd', b, sep='_'), format='GTiff', overwrite=TRUE))


band[1:50]

mierda <- raster('/Users/sputnik/Documents/Zonobioma Humedo Tropical Micay_ag_hansen_2010_17_99.tif')
crs(mierda)
crs <- list()
for(i in 1:length(band)){
  crs[i] <- crs(band[[i]])
}
 unlist(cr`1:100s
crs[301:379]
        

 crs
 
 rm(band)

paste(labels[1], 'bnd', b, sep='_')

bnd1 <- raster()

merged <- stack('Merged_1.tif')

rm(image1, image2, image3, image4, image5)

rcl


 plot(merged[[1]])
?echanges


