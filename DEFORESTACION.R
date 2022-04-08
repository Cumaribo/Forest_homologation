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
path=("Y:/ViktoriaShare/BioMapCol/Deforestation_rasters")
setwd(path)
dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#1. Cargar los raster de Bosque Armonizados de Hansen ------------
#Estos son los raster procesados por Jeronimo usando Hansen
H2018 <- raster("Y:/Shared_summer_21/Maps_hansen/Armomized_nomsk/armonized_2018a.tif")
H2017<- raster("Y:/Shared_summer_21/Maps_hansen/Armomized_nomsk/armonized_2017a.tif")

#2. Reclassify each Hansen raster to convert NA values into Zeros ------
# bc the values of the raster are only 1 and NA, and to calculate forest lost 
# we need binary rasters of 0 and 1. 
#*** IMPORTANTE REVISAR SI PARA CALCULAR
# PERDIDA (RESTAR) ES NECESARIO RECLASIFICAR NA POR CERO. PORQUE PARA HACER MERGE
# LOS RASTER NO DEBEN TENER VALORES DE CERO. LOS CEROS ENMASCARAN LOS OTROS VALORES.
# CUANDO SE SOBRELAPAN LOS RASTER, EL ULTIMO RASTER QUEDARA ENCIMA DE TODOS LOS DEMAS.
# Es decir que si se dejan los ceros, estos se sobrelaparan con los rasters que 
#quedan debajo y es como si eliminaran los valores de 1 de los otros rasters. 

m <- c(NA, NA, 0)
m <- matrix(m, ncol=3, byrow=TRUE)
H2018 <- reclassify(H2018,m)
H2017 <- reclassify(H2017,m)


#3. Calculate Forest loss between years ------
D17 <- H2017 - H2018
D16 <- H2016 - H2017
plot(D16)

#4. Reclasificar rasters en caso de que alguno tenga valores -1. ------- 
#Este valor representa ganancia, pero hay que descartarlo porque lo que nos importa es 
# lo que se perdio. 
g <- c(-Inf, 0, NA)
g <- matrix(g, ncol=3, byrow=TRUE)
D16 <- reclassify(D16, g)

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

