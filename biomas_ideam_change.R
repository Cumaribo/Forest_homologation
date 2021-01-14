
# This code is used to download all the forest- no forest binary masks from the 
# Global forest cover Dataset by Hansen et al  using the package ForestChange.
#It  returns maps for each one of the thresholds between 70 and 100%. The next step is to load this, stack cut it by pieces and then carry out the comparson betwee nthe maps. Everything trough maps.
#It requires the package "greenbrown" available here:
http://greenbrown.r-forge.r-project.org
# Load libraries 
rm(list=ls())


setwd("/Volumes/tug76452/Ecosistemas_Colombia/hansen_ideam")

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
library(greenbrown)
library(data.table)

mun <- st_read('/Volumes/tug76452/Ecosistemas_Colombia/biomas_wgs84.shp')
labels <- (mun$BIOMA_IAvH)
mun <- as(mun, 'Spatial')
# split mun into list of independent polygons  
biomat <- mun%>%split(.$BIOMA_IAvH)
# attention, for memoy reasons, I had to split the thing in several stages, and thats why it. DON;'T FORGET to adjust this!!!!!!!!!!!!!
names <- as.list(mun$BIOMA_IAvH)
names <- map(1:length(names), function(x) as.character(names[[x]]))
namesu <- unlist(names)
namesu <- namesu[-7]
# load the ideam maps 
# listr <- list.files(".", "ideam_2017")
# ideam17 <- list()
# for(i in 1:length(listr)){
#   ideam17[[i]] <- raster(listr[i])}
# # stack the rasters to build a multi band rasterstack. 
# #load the masked Rasters
# 
# ideam17
listr <- list.files(".", "ideam_2010_")
listr <- listr[(88:483)]
listr <- listr[c(1:396)]
      
ideam10 <- list()
for(i in 1:length(listr)){
  ideam10[[i]] <- raster(listr[i])}
listr <- list.files(".", "ideam_2000")
listr <- listr[c(129:524)]
ideam00 <- list()
for(i in 1:length(listr)){
  ideam00[[i]] <- raster(listr[i])}

test <- function(ideam1, ideam2){
    extent(ideam1)==extent(ideam2)}
gtest <- map(1:length(ideam10), function(x) test(ideam00[[x]], ideam10[[x]]))
unlist(gtest)  
b#############################

comparer <- function(ideam1,ideam2,namesu., writeraster, plotAgMap){
  suma <- ideam1-ideam2
  #x.stats <- data.frame(x.mean=cellStats(suma, "mean"))
  #return(x.stats)}
  #if(x.stats==0){
  x.mean <- cellStats(ideam1, "mean")
  y.mean <- cellStats(ideam2, "mean")
  if(x.mean==0|y.mean==0){
    DT <-  data.table(
      change <-  c(0,0,0,100),
      no_change <-  c(0, ncell(ideam1), ncell(ideam1), 100),
      Sum <-  c(0, ncell(ideam1),ncell(ideam1), NA),
      UserAccuracy <-  c(100,100,NA,100)
    )
    kappa <- 1
    DT <- as.data.frame(DT)
    rownames(DT) <- c('change', 'no-change', 'Sum','ProducerAccuracy')
    colnames(DT) <- c('change', 'no-change', 'Sum','UserAccuracy')
    comparedata <- list(ideam1,DT,kappa)
    names(comparedata) <- c('raster', 'table', 'kappa')
    class(comparedata) <- "CompareClassification"
    if(writeraster==TRUE){
       writeRaster(comparedata$raster, paste(namesu., 'ag_ideam_2000_2010_x', sep='_'), format='GTiff', overwrite=TRUE)}
       rm(suma, x.mean, y.mean, DT, kappa)
     }
  #return(comparedata)}
  else  
    {comparedata<- CompareClassification(ideam1, ideam2, names = list('Ideam_2000'=c('no-Forest','forest'),'Ideam_2010'=c('no-Forest','forest')), samplefrac = 1)}
    if(writeraster==TRUE){
    writeRaster(comparedata$raster, paste(namesu., 'ag_ideam_2000_2010', sep='_'), format='GTiff', overwrite=TRUE)}
    if(plotAgMap==TRUE){
       plot(comparedata)}
    #table <- as.data.frame(test1$table)
return(comparedata$table)}
############################
setwd("/Volumes/tug76452/Ecosistemas_Colombia/hansen_ideam2")
namesu[251:300]
namesu[308:310]

namesu[35:37]
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
  plan(multisession, workers=12)
  options(future.globals.maxSize= mem_future)
c_test2 <- future_map(300:396, function(x) comparer(ideam00[[x]], ideam10[[x]], namesu[x], writeraster=TRUE, plotAgMap=FALSE))
names(c_test2) <- namesu

rm(c_test2)
rm(c_test2)
namesu[292:293]

dir()

ideam1 <- ideam00[[292]]
ideam2 <- ideam10[[292]]

test1 <- CompareClassification(ideam1, ideam2, names = list('Ideam_2000'=c('no-Forest','forest'),'Ideam_2010'=c('no-Forest','forest')), samplefrac = 1)

save(c_test2,file= 'contingency_2010_281_290.RData')
c_test2 <- c_test2[-1]
c_test2

c_test2 <- rbind(c_test2, c_test3)

rm(c_test2)
namesu[300]
###############Use DiffeR because for some reason that i don´t know, greenbrown stopped working and i don't know waht the problem is

comparer2 <- function(ideam1,ideam2, perc){
  ideam_t <- ideam1
  hansen_t <- ideam2
  # mem_future <- 1000*1024^2 #this is toset the limit to 1GB
  # plan(multisession, workers=14)
  # options(future.globals.maxSize= mem_future)
  test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
  differences <-  diffTablej(test1, digits = 2, analysis = 'error')
  return(list(test1, differences))}

mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=13)
options(future.globals.maxSize= mem_future)
_
diff_mat <- future_map(1:396, function(x) comparer2(ideam10[[x]], ideam17[[x]], perc=FALSE))


ncell(ideam1)


compare1 <-CompareClassification(ideam10[[179]], ideam17[[179]],names = list('Ideam_2010'=c('no-Forest','forest'),'Ideam_2017'=c('no-Forest','forest')), samplefrac = 1)




table1 <- map(1:length(compare1), function(x) as.data.frame(compare1[[x]]$table))
compare1

names(table1) <- namesu[31:60]
save(table, file='contingengcy_2000_17Ideam_31_60.RData'

compare1

future_map(1:length(compare1), function(x) writeRaster(compare1[[x]]$raster, paste(namesu[x], 'ag_ideam_2010_2017', sep='_'), format='GTiff', overwrite=TRUE)) 


compare2 <-future_map(31:397, function(x)  CompareClassification(ideam10[[x]], ideam17[[x]],
                                                    table2 <- map(1:length(compare2), function(x) as.data.frame(compare1[[x]]$table))



                                                    
                                                                 
future_map(1:length(compare1), function(x) writeRaster(compare1[[x]]$raster, paste(namesu[x], 'ag_ideam_2010_2017', sep='_'), format='GTiff', overwrite=TRUE)) 



table <- map(1:length(compare1), function(x) as.data.frame(compare1[[x]]$table))

names(table) <- namesu[1:6]


length(table)


length(ideam17)

save(table, file='contingency_2000_17Ideam_first6.RData')

table

compare1

getwd()

namesu

(compare1[[1]]$raster)

  mem_future <- 1000*1024^2 #this is toset the limit to 1GB
  plan(multisession, workers=8)
  options(future.globals.maxSize= mem_future)
test_stats <- function(ideam1, ideam2){
    suma <- ideam1-ideam2
    (x.stats <- data.frame(x.mean=cellStats(suma, 'mean')))
    return(x.stats)}

compare_test <- future_map(1:length(ideam10), function(x) test_stats(ideam10[[x]], ideam17[[x]]))





compare1


compare_test
unlist(compare_test)


compare_test <- CompareClassification(ideam10[[1]],ideam17[[1]], names = list('Ideam_2010'=c('no-Forest','forest'),'Ideam_2017'=c('no-Forest','forest')), samplefrac = 1) 


dir()
hansen <- list()
listr <- list.files(".", "masked")
# load the Ideam rasters
for(i in 1:length(listr)){
  hansen[[i]] <- stack(listr[i])}

# Invert the bands because R
inversor <- function(test){
test <- stack(test[[2:30]], test[[1]])}
hansen <- future_map(1:length(hansen), function(x) inversor(hansen[[x]]))

hansen[[1]]
#Compare maps

?CompareClassification

mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=13)
options(future.globals.maxSize= mem_future)





diff_mat <- map(97:116, function(x) comparer(ideam[[x]], hansen[[x]], perc=FALSE))
diff_mat2 <- diff_mat





#diff_mat67 <- comparer(ideam=ideam[[67]], hansen=hansen[[69]], perc=FALSE)

labels1 <- labels[97:116]
names(diff_mat2) <- labels1

save(diff_mat2, file='differences_biomas_97_116.Rdata')
write.csv(diff_mat, file='diff_mat_66.csv')

plot()

ideam_e <- map(1:length(ideam), function(x) extent(ideam[[x]]))
hansen_e <- map(1:length(ideam), function(x) extent(hansen[[x]]))
compared <- compare.list(ideam_e, hansen_e)
biomat[[67]]

extent(ideam[[67]])
extent(hansen[[69]])


save(diff_mat, file='differences_biomas_perc.Rdata')
write_csv(diff_mat, 'diff_mat_perc.csv', col_names = TRUE)


plot(biomat[[1]])
plot(ideam[[1]])
plot(hansen[[1]][[1]])
