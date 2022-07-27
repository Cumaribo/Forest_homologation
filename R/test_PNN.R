packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf','gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 'ecochange', 'furrr')
out.. <-  sapply(packs, require, character.only = TRUE)


install.packages('nplyr')
library(parallel)
#setwd('/storage/home/TU/tug76452/Forest_Armonization')
#lab
setwd('/media/mnt/Forest_Armonization')


dir.create('tempfiledir')
                                        #obtain string with the path
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#Set the memory limit for parallel running
mem_future <- 5000*1024^2 #this is toset the limit to 5GB
plan(multisession, workers=7)
options(future.globals.maxSize= mem <- future)

td <- getwd()
#Load vector data as SF
# 1 . Set files

shps <- list.files('/media/mnt/Forest_Armonization/SINAP_areas/', pattern='shp')
shps <- map(1:length(shps), function(x) str_sub(shps[x], start=1, end=9))
shps <- unlist(shps)
setwd('/media/mnt/Forest_Armonization/SINAP_areas/')
# st_read
sfs <- map(1:6, function(x) st_read('.', shps[x]))

#3 Load template to rasterize
temp <- raster('/media/mnt2/BiomapCol_22/mask_colombia.tif')

#temp2 <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/msk_SMBYC.tif')
#4. Reproject to the crs of the template
sfs <- map(1:6, function(x) st_transform(sfs[[x]], crs(temp)))
#5 Add numeric attribute to rasterize
sfs <- map(1:length(sfs), function(x) mutate(sfs[[x]], type = case_when(NIVEL2 == 'Aguas Continentales' ~ 1,
                                          NIVEL2 == 'Aguas Maritimas' ~ 2, 
                                          NIVEL2 == 'Areas Abiertas, sin o con poca Vegetacion' ~3,
                                          NIVEL2 == 'Areas Agricolas Heterogeneas' ~ 4,
                                          NIVEL2 == 'Areas con Vegetacion Herbacea y/o Arbustiva' ~ 5,
                                          NIVEL2 == 'Areas Humedas Continentales' ~ 6,
                                          NIVEL2 == 'Areas Humedas Costeras' ~ 7,
                                          NIVEL2 == 'Bosques' ~8,
                                          NIVEL2 == 'Cultivos Permanentes' ~9,
                                          NIVEL2 == 'Nubes' ~ 10,
                                          NIVEL2 == 'Pastos'~ 11,
                                          NIVEL2 == 'Zonas Industriales o Comerciales y Redes de Comunicacion' ~ 12,
                                          NIVEL2 == 'Zonas Verdes Artificializadas, no Agricolas' ~ 13)))
#Fix name of sfs[[6]]
sfs[[6]] <- sfs[[6]]%>%mutate(NOMBRE = NOM)
#test to nest. However this is a list not a tidy object, andbtw, the number and names of the attributes is different, as 
                                        #well as the order. This would require some extra work. Let us keep it like this.
# Next to fix: learn how to nest the lists
 #sfs_nest <- sfs%>%group_by(.$NOMBRE)%>%nest()

#the whole problem is that the datesats are not equal. BTW i am a moron, just needed to drop the attributes i did not need and keep only the ones of forest no forest and the geom. =
# the rest can go awaY!!!!

#Extract Vector with the names of the PNN (surely will need them in a moment)
names. <- unique(sfs[[1]][["NOMBRE"]])
names. <- sort(names.)
names. <- sub(" ", "_", names.) # had to run this 4 times to get rid of all the spaces 
#sfs. <- unlist(sfs)

#Split by PNN
#Map inside a map
sfs <- map(sfs, . %>% split(.$NOMBRE))


#load harmonized masked 
mskwd <- '/media/mnt2/BiomapCol_22/Maps_hansen/Armonized_msk'

tiffes <- list.files(mskwd, pattern='.tif')
#select the specific years

tiffes <- tiffes[-c(1:5)]
tiffes <- tiffes[c(3,8,13,16,18,19)]
                                        # set vector to name rasters per year.
years <- unlist(map(1:length(tiffes), function(x) str_sub(tiffes[x], start=8, end=15)))

                                        #load rasters masks 
harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(paste(mskwd,tiffes[i], sep='/'))}
#load mask (fill NAs, i think i have it somewhere but can't recall where)

 m <- c(-Inf, Inf, 0)
 m <- matrix(m,ncol=3,byrow=TRUE)
 temp <- reclassify(temp,m)
 writeRaster(temp, 'mask_01.tif')
 #already saved!!!!
 temp <- raster('mask_01.tif')
 
 # crop the template raster
# # for some reason future_map s not working on the Mac. Find out why
# # I already created this it's on media/mnt/Forest_Armonization/SINAP_areas

map(1:length(harm), function(x) writeRaster(harm[[x]], paste('bin_masked', years[x], sep= '_')))
# 
# ((mc.preschedule = TRUE, mc.set.seed = TRUE,
#                              mc.silent = FALSE, mc.cores = getOption("mc.cores", 6L),
#                              mc.cleanup = TRUE, mc.allow.recursive = TRUE, affinity.list = NULL))

tiffes <- list.files('.', pattern='harm_bin')
#select the specific years
harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(tiffes[i])}

#crop and mask (what?)for each of the PNN. to be able to rasterize. (name_pmm.tif)
temp <-map(1:length(sfs), function(x)  crop(temp, extent(sfs[[1]][[x]]))) 
temp <-map(1:length(sfs), function(x)  mask(temp[[x]], sfs[[1]][[x]])) 

# for each year. Data rasterized (each one is each park)

# sfs. <- sfs%>%select(NOMBRE)
# %>% group_by(PERIODO)%>%map(1:length(temp), function(x)fasterize(., temp[[x]], field ='type'))
# sfs <- map(sfs, ~map(fasterize))
# I have wasted twodaysa here trying to find out how to map this shit, BTW, I don't know why future stopped working!!!!!    
#Nada que puedo. Es algo ocmo agrupar y volver a hacer, pero nada que lo logro.
sfs1 <- map(sfs ~map2(., temp, fasterize(., temp, field= 'type')))
          

#datos PNN rasterizados por lugar y por a~no. Lo que no necesito                         
sfs1 <- map(1:6, function(x) fasterize(sfs[[1]][[x]], temp[[x]], field='type')) #2002
sfs2 <- map(1:6, function(x) fasterize(sfs[[2]][[x]], temp[[x]], field='type')) #2007
sfs3 <- map(1:6, function(x) fasterize(sfs[[3]][[x]], temp[[x]], field='type')) #2012
sfs4 <- map(1:6, function(x) fasterize(sfs[[4]][[x]], temp[[x]], field='type')) #2015
sfs5 <- map(1:6, function(x) fasterize(sfs[[5]][[x]], temp[[x]], field='type')) #2017
sfs6 <- map(1:6, function(x) fasterize(sfs[[6]][[x]], temp[[x]], field='type')) #2018

# I have to be able to run this as a single thing, but have not been succesful yet. 

#crop/mask 
#No he podido. Mapas harmonizados por lugar y por a~no. Esto l otnegoque poder hacer en mapa
harm. <- map2(harm,temp, ~(.harm, .extent(temp)))


harm1 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[1]]))) #El Tuparro
harm1 <- map(1:length(harm1),function(x) mask(harm1[[x]], temp[[1]]))

harm2 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[2]]))) #Los Nevados 
harm2 <- map(1:length(harm),function(x) mask(harm2[[x]], temp[[2]]))

harm3 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[3]]))) #Sanquianga
harm3 <- map(1:length(harm),function(x) mask(harm3[[x]], temp[[3]]))

harm4 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[4]]))) #Serrania de Chiribiquete 
harm4 <- map(1:length(harm4),function(x) mask(harm4[[x]], temp[[4]]))

harm5 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[5]]))) #Sierra Nevada de Santa Marta
harm5 <- map(1:length(harm5),function(x) mask(harm5[[x]], temp[[5]]))

harm6 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[6]]))) #Tayrona
harm6 <- map(1:length(harm6),function(x) mask(harm6[[x]], temp[[6]]))


5:arbustos
7: bosques
#Reclassify harmonized to the same types of PNN

#set reclass matrix
#  m <- c(7,9,8.1, 1) 
#  m <- matrix(m, ncol=3,byrow=TRUE)
#  
# harm1 <- map(harm1, reclassify, m) #El Tuparro
# harm2 <- map(harm2, reclassify, m) #Los Nevados
# harm3 <- map(harm3, reclassify, m) #Sanquianga
# harm4 <- map(harm4, reclassify, m) #Serrania de Chiribiquete
# harm5 <- map(harm5, reclassify, m) #Sierra Nevada de Santa Marta
# harm6 <- map(harm6, reclassify, m) #Tayrona

#

 m <- c(0.9, )
sfsf1 <- (list(sfs1[[1]],sfs2[[1]],sfs3[[1]],sfs4[[1]],sfs5[[1]],sfs6[[1]])) # El Tuparro 
sfsf2 <- (list(sfs1[[2]],sfs2[[2]],sfs3[[2]],sfs4[[2]],sfs5[[2]],sfs6[[2]])) # Los Nevados  
sfsf3 <- (list(sfs1[[3]],sfs2[[3]],sfs3[[3]],sfs4[[3]],sfs5[[3]],sfs6[[3]])) # Sanquianga 
sfsf4 <- (list(sfs1[[4]],sfs2[[4]],sfs3[[4]],sfs4[[4]],sfs5[[4]],sfs6[[4]])) # Serrania de Chiribiquete El tupparo 
sfsf5 <- (list(sfs1[[5]],sfs2[[5]],sfs3[[5]],sfs4[[5]],sfs5[[5]],sfs6[[5]])) # Sierra Nevada de Santa Marta 
sfsf6 <- (list(sfs1[[6]],sfs2[[6]],sfs3[[6]],sfs4[[6]],sfs5[[6]],sfs6[[6]])) # Tayrona  
#no he podido
sfsf <- map2(1:length(sfsf), function(x) list(sfsf[[x]][[x]]))


harm1[[1]]
sfsf1[[1]]


library(diffeR)
library(greenbrown)


years. <- years
#Extract Sq cont. matrices

compdiff <- function(ref,tar, perc){
  cont_t <- crosstabm(ref, tar, percent=perc, population=NULL)
  return(cont_t)}

agg1 <- map(1:length(harm1), function(x) compdiff(harm1[[x]], sfsf1[[x]], perc =  TRUE))
agg1p <- map(1:length(harm1), function(x) compdiff(harm1[[x]], sfsf1[[x]], perc =  FALSE))

agg2 <- map(1:length(harm1), function(x) compdiff(harm2[[x]], sfsf2[[x]], perc =  TRUE))
agg2p <- map(1:length(harm1), function(x) compdiff(harm2[[x]], sfsf2[[x]], perc =  FALSE))

agg3 <- map(1:length(harm3), function(x) compdiff(harm3[[x]], sfsf3[[x]], perc =  TRUE))
agg3p <- map(1:length(harm3), function(x) compdiff(harm3[[x]], sfsf3[[x]], perc =  FALSE))

agg4 <- map(1:length(harm4), function(x) compdiff(harm4[[x]], sfsf4[[x]], perc =  TRUE))
agg4p <- map(1:length(harm4), function(x) compdiff(harm4[[x]], sfsf4[[x]], perc =  FALSE))

agg5 <- map(1:length(harm5), function(x) compdiff(harm5[[x]], sfsf5[[x]], perc =  TRUE))
agg5p <- map(1:length(harm5), function(x) compdiff(harm5[[x]], sfsf5[[x]], perc =  FALSE))

agg6 <- map(1:length(harm6), function(x) compdiff(harm6[[x]], sfsf6[[x]], perc =  TRUE))
agg6p <- map(1:length(harm6), function(x) compdiff(harm6[[x]], sfsf6[[x]], perc =  FALSE))
 #Homologue Classes. 


save(agg1, file='agg1.RData')
save(agg1p, file='agg1p.RData')

save(agg2, file='agg2.RData')
save(agg2p, file='agg2p.RData')

save(agg3, file='agg3.RData')
save(agg3p, file='agg3p.RData')

save(agg4, file='agg4.RData')
save(agg4p, file='agg4p.RData')

save(agg5, file='agg5.RData')
save(agg5p, file='agg5p.RData')

save(agg6, file='agg6.RData')
save(agg6p, file='agg6p.RData')



years. <- unlist(map(1:length(tiffes), function(x) str_sub(tiffes[x], start=10, end=17)))




#Extract maps 
m <- c(0.9, 7.1, 0, 7.9, 8.1, 1, 8.9, Inf, 0)
m <- matrix(m, ncol=3, byrow=TRUE)
sfsf1 <- (list(sfs1[[1]],sfs2[[1]],sfs3[[1]],sfs4[[1]],sfs5[[1]],sfs6[[1]])) # El Tuparro 
sfsf2 <- (list(sfs1[[2]],sfs2[[2]],sfs3[[2]],sfs4[[2]],sfs5[[2]],sfs6[[2]])) # Los Nevados  
sfsf3 <- (list(sfs1[[3]],sfs2[[3]],sfs3[[3]],sfs4[[3]],sfs5[[3]],sfs6[[3]])) # Sanquianga 
sfsf4 <- (list(sfs1[[4]],sfs2[[4]],sfs3[[4]],sfs4[[4]],sfs5[[4]],sfs6[[4]])) # Serrania de Chiribiquete El tupparo 
sfsf5 <- (list(sfs1[[5]],sfs2[[5]],sfs3[[5]],sfs4[[5]],sfs5[[5]],sfs6[[5]])) # Sierra Nevada de Santa Marta 
sfsf6 <- (list(sfs1[[6]],sfs2[[6]],sfs3[[6]],sfs4[[6]],sfs5[[6]],sfs6[[6]])) # Tayrona  
#no he podido
sfsf1 <- map(1:length(sfsf1), function(x) reclassify(sfsf1[[x]], m))
sfsf2 <- map(1:length(sfsf2), function(x) reclassify(sfsf2[[x]], m))
sfsf3 <- map(1:length(sfsf3), function(x) reclassify(sfsf3[[x]], m))
sfsf4 <- map(1:length(sfsf4), function(x) reclassify(sfsf4[[x]], m))
sfsf5 <- map(1:length(sfsf5), function(x) reclassify(sfsf5[[x]], m))
sfsf6 <- map(1:length(sfsf6), function(x) reclassify(sfsf6[[x]], m))

sfsf1[[1]]


compgb <- function(ref,tar,names, years){#}, plotAgMap){
  comparedata<- CompareClassification(ref, tar, names = list('GLAD_ARM'=c('No bosque',  'bosque'),'PNN'=c('no bosque', 'bosque')), samplefrac = 1)
  #if(writeraster==TRUE){
    writeRaster(comparedata$raster, paste(names., years, sep='_'), overwrite=TRUE)
    return(comparedata$table)}

# compgb <- function(ref,tar,names, years, writeraster, plotAgMap){
#   comparedata<- CompareClassification(ref, tar, names = list('GLAD_ARM'=c('Aguas Continentales','Aguas Maritimas', 
#                                                                           'Areas Abiertas, sin o con poca Vegetacion','Areas Agricolas Heterogeneas',
#                                                                           'Areas con Vegetacion Herbacea y/o Arbustiva',
#                                                                           'Areas Humedas Continentales',
#                                                                           'Bosques','Cultivos Permanentes',
#                                                                           'Nubes', 'Pastos','Zonas Industriales o Comerciales y Redes de Comunicacion',
#                                                                           'Zonas Verdes Artificializadas, no Agricolas'),'PNN'=c('Aguas Continentales','Aguas Maritimas', 
#                                                                                                                                  'Areas Abiertas, sin o con poca Vegetacion','Areas Agricolas Heterogeneas',
#                                                                                                                                  'Areas con Vegetacion Herbacea y/o Arbustiva',
#                                                                                                                                  'Areas Humedas Continentales',
#                                                                                                                                  'Bosques','Cultivos Permanentes',
#                                                                                                                                  'Nubes', 'Pastos','Zonas Industriales o Comerciales y Redes de Comunicacion',
#                                                                                                                                  'Zonas Verdes Artificializadas, no Agricolas')), samplefrac = 1)
#   if(writeraster==TRUE){
#     writeRaster(comparedata$raster, paste(names., years, sep='_'), overwrite=TRUE)}
# if(plotAgMap==TRUE){
#   plot(comparedata)}
#   return(comparedata$table)}


years. <- years

gbr1 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # El Tuparro
gbr2 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # Los Nevados
gbr3 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # Sanquianga
gbr4 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # Serrania de Chiribiquete
gbr5 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # Sierra Nevada
gbr6 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # Tayrona


save(gbr1=, file= 'gbr1.RData')
save(gbr2=, file= 'gbr2.RData')
save(gbr3=, file= 'gbr3.RData')
save(gbr4=, file= 'gbr4.RData')
save(gbr5=, file= 'gbr5.RData')
save(gbr6=, file= 'gbr6.RData')

gbr6 <- map(6:6, function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x], writeraster=TRUE, plotAgMap = TRUE)) # Tayrona



NIVEL2 == 'Aguas Continentales' ~ 1,
NIVEL2 == 'Aguas Maritimas' ~ 2, 
NIVEL2 == 'Areas Abiertas, sin o con poca Vegetacion' ~3,
NIVEL2 == 'Areas Agricolas Heterogeneas' ~ 4,
NIVEL2 == 'Areas con Vegetacion Herbacea y/o Arbustiva' ~ 5,
NIVEL2 == 'Areas Humedas Continentales' ~ 6,
NIVEL2 == 'Areas Humedas Costeras' ~ 7,
NIVEL2 == 'Bosques' ~8,
NIVEL2 == 'Cultivos Permanentes' ~9,
NIVEL2 == 'Nubes' ~ 10,
NIVEL2 == 'Pastos'~ 11,
NIVEL2 == 'Zonas Industriales o Comerciales y Redes de Comunicacion' ~ 12,
NIVEL2 == 'Zonas Verdes Artificializadas, no Agricolas' ~ 13)))
plot(harm5[[1]])

#count pixels
freq(harm5[[1]], useNA= 'no')

sfs1

map(1:length(harm1), function(x) writeRaster(harm1[[x]],paste('harm1_bin', years[x], sep='_'))) 
map(1:length(harm2), function(x) writeRaster(harm2[[x]],paste('harm2_bin', years[x], sep='_')))
map(1:length(harm3), function(x) writeRaster(harm3[[x]],paste('harm3_bin', years[x], sep='_')))
map(1:length(harm4), function(x) writeRaster(harm4[[x]],paste('harm4_bin', years[x], sep='_')))
map(1:length(harm5), function(x) writeRaster(harm5[[x]],paste('harm5_bin', years[x], sep='_')))
map(1:length(harm6), function(x) writeRaster(harm6[[x]],paste('harm6_bin', years[x], sep='_'))) 


sfs1[[1]]

harm1[[1]]

harm1

[[1]]

map(1:length(temp), function(x) writeRaster(temp[[x]], paste(names[x], 'msk.tif', sep='_')))


plot(temp[[5]])


sort(names)
# create test raster
ras1 <- raster(ncol=5,nrow=5) 
pol1 = st_sfc(st_polygon(list(cbind(c(0,3,3,0,0),c(0,0,3,3,0)))))
h = st_sf(r = 5, pol1)
h1 = st_sf(r = 6, pol1)
h <- st_crs(h, crs=st_crs(ras1))
hr <- fasterize(h, ras1, field='r')
plot(hr)

pol2 = st_sfc(st_polygon(list(cbind(c(4,5,5,4,4),c(4,4,5,5,4)))))
g = st_sf(r = 5, pol2)
g1 = st_sf(r = 6, pol2)



#add the other part (transform the tables into agreement tables)
