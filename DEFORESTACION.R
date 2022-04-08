# CALCULATING DEFORESTATION
# AUTHOR: VICTORIA SARMIENTO
# CREATED: Summer 2021-JAN 2022# 
# UPDATED: JERONIMO RODRIGUEZ/ 2022 APRIL 

#Necesary packages-------------------------------------------------------
library(raster)
library(rgdal)
library(sp)

#This needs to be converted into using gdal or terra. Not raster anymore 

# Setting working directory and temporary folder -----------------------------------------


#1. Cargar los raster de Bosque Armonizados de Hansen ------------
#Estos son los raster procesados por Jeronimo usando Hansen
# Set list of rasters to process
tiffs <- list.files('.'pattern='tif')
#load rasters
tiffs1<-list()
for(i in (1:length(tiffs)){
  tiffs1[i]<-tiffs[i]
  }

#3. Set biannual forest loss calculation ------
def<-function(t1, t2){
  floss<-(foct1 - foct2)
  return(floss)
  }
#4 Run the function over the list 
    ydef<-future(map(2:(length(tiffs1)-1), function(x) def(tiffs1[[x]],tiffs1[[x+1]])) 
    

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

