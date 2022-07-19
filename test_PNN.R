packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf','gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 'ecochange', 'furrr')
out.. <-  sapply(packs, require, character.only = TRUE)

setwd('/Users/sputnik/Documents/bosque-nobosque/SINAP_areas')

td <- getwd
#Load vector data as SF
# 1 . Set files
shps <- list.files('/Users/sputnik/Documents/bosque-nobosque/SINAP_areas', pattern='shp')
#leave this here. 
shps <- map(1:length(shps), function(x) str_sub(shps[x], start=1, end=9))
shps <- unlist(shps)
# st_reas
sfs <- map(1:6, function(x) st_read('.', shps[x]))

#3 Load template to rasterize
temp <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/msk_SMBYC.tif')
temp2 <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/msk_SMBYC.tif')
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
#test to nest. However this is a list not a tidy object, andbtw, the number and names of the attributes is differnet, as 
#well as the order. This would require some extra work. Let us keep it like this 

#Extract Vector with the names of the PNN (surely will need them in a moment)
names <- unique(sfs[[1]][["NOMBRE"]])
names <- sort(names)
#load harmonized masked 

sfs <- map(sfs, . %>% split(.$NOMBRE))
sfs[[1]]           
#######           
sfs. <- unlist(sfs)
#######

mskwd <- '/Users/sputnik/Documents/bosque-nobosque/masked_armonized_2022'

tiffes <- list.files(mskwd, pattern='.tif')
#select the specific years
tiffes <- tiffes[c(3,8,13,16,18,19)]
#load them
harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(paste(mskwd,tiffes[i], sep='/'))}
#load mask (fill NAs, i think i have it somewhere but can't recall where)
m <- c(-Inf, Inf, 0)
m <- matrix(m,ncol=3,byrow=TRUE)
temp <- reclassify(temp,m)
writeRaster(temp, 'mask_col_0.tif')

harm <- map(1:length(harm), function(x) merge(harm[[x]], temp))
# crop the template raster
# for some reason future_map s not working on the Mac. Find out why
# mem_future <- 5000*1024^2 #this is toset the limit to 5GB
# plan(multisession, workers=6)
# options(future.globals.maxSize= mem <- future)

#crop and mask for each of the PNN
temp <-map(1:length(sfs1), function(x)  crop(temp, extent(sfs1[[x]]))) 
temp <-map(1:length(sfs1), function(x)  mask(temp[[x]], sfs1[[x]])) 


sfs1 <- map(1:6, function(x) fasterize(sfs1[[x]], temp[[x]], field='type'))
sfs2 <- map(1:6, function(x) fasterize(sfs2[[x]], temp[[x]], field='type'))
sfs3 <- map(1:6, function(x) fasterize(sfs3[[x]], temp[[x]], field='type'))
sfs4 <- map(1:6, function(x) fasterize(sfs4[[x]], temp[[x]], field='type'))
sfs5 <- map(1:6, function(x) fasterize(sfs5[[x]], temp[[x]], field='type'))
sfs6 <- map(1:6, function(x) fasterize(sfs6[[x]], temp[[x]], field='type'))
#harm <- do.call(stack, harm)

harm <- map(1:length(temp),function(x) crop(harm[[x]], extent(temp[[x]])))
harm <- map(1:length(temp),function(x) mask(harm[[x]], temp[[x]]))


map(1:length(temp), function(x) writeRaster(temp[[x]], paste(names[x], 'msk.tif', sep='_')))


plot(temp[[5]])


sort(names)
