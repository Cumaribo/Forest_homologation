# CALCULATING DEFORESTATION
# AUTHOR: VICTORIA SARMIENTO
# CREATED: Summer 2021-JAN 2022# 
# UPDATED: JERONIMO RODRIGUEZ/ 2022 APRIL 

#Necesary packages-------------------------------------------------------
library(raster)
library(rgdal)
library(sp)
library(tidyverse)
library(furrr)
#This needs to be converted into using gdal or terra. Not raster anymore 


                                        # Setting working directory and temporary folder -----------------------------------------
path=("/storage/home/TU/tug76452/biotablero/binary/Container_tmp")
setwd(path)

#path=("/storage/home/TU/tug76452/biotablero/binary/outputs")
#setwd(path)

#Set temporary folder. Here it is key!Troop
dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#1. Cargar los raster de Bosque Armonizados de Hansen ------------
#Estos son los raster procesados por Jeronimo usando Hansen

tiffs<-list.files('.', pattern='tif')

tiffs <- tiffs[c(14:18)]

r.list<-list()
for(i in 1:(length(tiffs)-1)){
  r.list[i]<-raster(tiffs[i])
}

r.list2<-list()

for(i in 2:length(tiffs)){
  r.list2[i]<-raster(tiffs[i])
}
r.list2 <- r.list2[-1]

r.list[[4]]
r.list2[[4]]

floss <-function(raso, rasi){
    def <- raso-rasi
    return(def)}


mem_future <- 5000*1024^2 #this is toset the limit to 5GB
plan(multisession, workers=4)
 options(future.globals.maxSize= mem_future)

reclv <- c(14:18)

mult_one <- function(var1, var2)
{
    def <- var1*var2
    return(def)
}

tiffs

namer <- map(1:length(tiffs), function(x) substr(tiffs[x], 8,11))
namer <- unlist(namer)
namer <- namer[-1]


path=("/storage/home/TU/tug76452/biotablero/binary/outputs")
setwd(path)

#2. Calculate Forest loss between years ------
#dir.create('outputs')

#wd=paste(getwd(),'outputs', sep="/")
#setwd(wd)

getwd()

                                        #4. Reclasificar rasters en caso de que alguno tenga valores -1. ------- 
#Este valor representa ganancia, pero hay que descartarlo porque lo que nos importa es 
# lo que se perdio. 

#The complicated issue here is that running all at anoce has been a problem (memory) and when running by batvhes i get all kinds of issues (stupiud errors, memory, and last but not least, knowimng the right position is an issue (the indeces to map the functions)

deforest <- map(1:length(r.list), function(x) floss(r.list[[x]],r.list2[[x]]))
                                        # Reclassify values by the year offorest loss
deforest <-map(1:length(deforest), function(x) mult_one(deforest[[x]], reclv[x]))
                                        # save rasters
map(1:length(deforest), function(x) writeRaster(deforest[[x]], paste('def_2',namer[x], sep='_'), format='GTiff', overwrite=TRUE))







writeRaster(deforest[[1]], paste('def_2',namer[1], sep='_'), format='GTiff', overwrite=TRUE)

deforest[[1]]
namer[1]

deforest



r.list

r.list<-list()
for(i in 1:length(tiffs)){
    r.list[i]<-raster(tiffs[i])
}
deforest <-map(1:length(r.list), function(x) mult_one(r.list[[x]], reclv[x]))
tiffs <- map(1:length(tiffs), function(x) substr(tiffs[x], 8,11))
namer <- unlist(namer)
map(1:length(deforest), function(x) writeRaster(deforest[[x]], paste('def_2',namer[x], sep='_'), format='GTiff', overwrite=TRUE))


reclv


r.list

getwd()

deforest <- do.call(


#5. Guardar raster Deforestacion. Estos raster tendrán valores 0-1. En mi flujo
# de trabajo en el siguiente paso para hacer Merge, tuve que reclasificarlos 
# por segunda vez en 1-NA, para remover los ceros. 
writeRaster(D17, filename = "Defores2017_2018", format="GTiff", overwrite=TRUE)

#6. Merge deforestation rasters ---------
# To merge rasters, I have to take into account the values of the band. 
# Zeros values will mask any other value. In areas of overlap the last raster 
# will be copied over earlier ones. 

#When I created the deforestation maps between two years I reclassified them into
# 0-1, to remove negative values (-1, those were forest gain). However, I could have
# converted them into NA, rather than zero, but not sure if that works. 

#6.1 RECLASSIFY 0-1 into 1 - NA. 
#That way only pixels with one will be added up. 
library(furrr) #This library is for mapping functions
#Sets the amount of memory available for running in parallel 
mem_future <- 30000*1024^2 #this is to set the limit to 30GB (the first term, 1000=1gb, 2000=2gb and so on)
options(future.globals.maxSize= mem_future)
#Sets the number of cores that you are going to use. I recommend the total number of cores -2 
plan(multisession, workers=6)

#Load one deforestation raster and Check the values of the raster
d1 <- raster("Defores2000_2001.tif")
#freq(d1)
#unique(d1)
#plot(d1)

#Create a list with the names of the tiffs using a common element
tifs <- list.files(".", "Defores")
#Create an empty list as a container
rasters <- list()
#Load Deforestation maps
#this will create a list of independent rasters
for(i in 1:length(tifs)){
  rasters[i] <- raster(tifs[i])
}

#check the raster list and get a sense on how are organized and its values
rasters

m<- c(-Inf, 0.1, NA)
rcl <- matrix(m, ncol=3, byrow=TRUE)
D18 <- reclassify(rasters[[18]], rcl) #Empezar por Defores2017-2018
D17<- reclassify(rasters[[17]], rcl)

#Merge
#Cuando se hace merge, el elemento 1 de la lista es el que queda encima de todo
# Por eso empiezo a hacer merge
# desde el ultimo año de perdida de bosque (2018-2017), para quede quede encima 
#e  ir adicionando los siguientes años hacia atrás

A1 <- merge(D18, D17)
A2 <- merge(A1, D16)

plot(A1)

writeRaster(A17, filename="Defores2000_2018.tif", overwrite=TRUE)

