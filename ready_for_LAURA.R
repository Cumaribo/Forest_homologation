# This code reviewed on 18/04/2022

getwd()

rm(list=ls())


install.packages('SDMTools','http://www.rforge.net/')
install.packages('quantreg')

install.packages('useful')
install.packages('diffeR')
install.packages('bcp')
install.packages('bfast')
install.packages('Kendall') 


install.packages("greenbrown", repos="http://R-Forge.R-project.org")

##############################
packs<-c('raster', 'rgdal', 'tidyverse', 'useful','diffeR', 'greenbrown', 'gdalUtils', 'gdalUtilities')
sapply(packs, require, character.only = TRUE) 


library(raster)
#library(forestChange)
#library(parallel)
#library(sf)
library(tidyverse)
#library(purrr)
library(furrr)
library(diffeR)
library(useful)
library(greenbrown)
library(data.table)


dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)
# unixtools::set.tempdir('/media/mnt/Ecosistemas_Colombia/tempfiledir')


# this function uses the package diffeR to compare between pairs of maps. It does not produce agreement maps, only contingency matrices. It works faster and does not require that both maps have pixels form all classes
#######################THIS IS THE FUNCTION THAT I NEED TO USE NOW (03/03/2021) Here we are, on 18/04/2022
# still messing with this thing, but i finally know where we're going. 



#1. Load the agreement maps:
  
hansen19<-raster('/media/mnt/Forest_Armonization/Armonized_nomsk/armonized_2019a.tif')

target<-'/media/mnt/Forest_Armonization/SMBYC_Data/cambio_2018_2019_v8_200707_3116.img'
reference. <-"/media/mnt/Forest_Armonization/mask_ideam90_17.tif"
dst.<-'/media/mnt/Forest_Armonization/cambio18_19.tif'
align_rasters(unaligned=target, reference=reference., dstfile=dst., nthreads=6, verbose= TRUE)


ideam19<-raster('/media/mnt/Forest_Armonization/cambio18_19.tif')

m<-c(1.9, 2.1, 5, 3.9, 4.1, 1)
m<-matrix(m, ncol=3, byrow=TRUE)
##### r
ideam19<-reclassify(ideam19, m)                                        # imagen a alienar
 
writeRaster(ideam19, 'ideamfnF2019.tif')


msk<-raster('/media/mnt2/BiomapCol_22/mask_colombia.tif')

m<-c(4.9, 5.1, 0, 0,0, NA)

m<-matrix(m, ncol=3, byrow=TRUE)
ideam19<-reclassify(ideam19, m)                                     

setwd('/media/mnt/Forest_Armonization/')


ideam19<-mask(ideam19, msk)
writeRaster(ideam19,'ideamfnF2019_rec.tif', overwrite=TRUE)

m<-c(NA, NA, 0)
m<-matrix(m, ncol=3, byrow=TRUE)

hansen19<-reclassify(hansen19, m)
hansen19<-mask(hansen19, msk)
writeRaster(hansen19,'hansen2019_bin.tif', overwrite=TRUE)


agg<-hansen19*ideam19

writeRaster(agg, 'aggForest_2019.tif')

comparer2 <- function(ideam1,ideam2, perc){
  test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
  return(test1)}

comparedata<- CompareClassification(ideam19, hansen19, names = list('Ideam_19'=c('no-Forest','forest', 'no-data'),
                                                                    'Hansen_19'=c('no-Forest','forest','no-data')), samplefrac = 1)
writeRaster(comparedata$raster, 'agg_for_19.tif')
write.csv(comparedata$table, file='cont_mat.csv')
