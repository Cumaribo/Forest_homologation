packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf','gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 'ecochange', 'furrr')
out.. <-  sapply(packs, require, character.only = TRUE)


setwd('/storage/home/TU/tug76452/Forest_Armonization')



dir.create('tempfiledir')
                                        #obtain string with the path
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)


td <- getwd()
#Load vector data as SF
# 1 . Set files

shps <- list.files('/storage/home/TU/tug76452/Forest_Armonization/SINAP_areas/', pattern='shp')
shps <- map(1:length(shps), function(x) str_sub(shps[x], start=1, end=9))
shps <- unlist(shps)
setwd('/storage/home/TU/tug76452/Forest_Armonization/SINAP_areas/')
# st_read
sfs <- map(1:6, function(x) st_read('.', shps[x]))

#3 Load template to rasterize
temp <- raster('/storage/share/BiomapCol_22/mask_colombia.tif')

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
#test to nest. However this is a list not a tidy object, andbtw, the number and names of the attributes is differnet, as 
                                        #well as the order. This would require some extra work. Let us keep it like this
# Next to fix: learn how to nest the lists
 #sfs_nest <- sfs%>%group_by(.$NOMBRE)%>%nest()

sfs. <- unlist(sfs)

#Split by PNN
sfs1 <- sfs[[1]]%>%split(.$NOMBRE)
sfs2 <- sfs[[2]]%>%split(.$NOMBRE)
sfs3 <- sfs[[3]]%>%split(.$NOMBRE)
sfs4 <- sfs[[4]]%>%split(.$NOMBRE)
sfs5 <- sfs[[5]]%>%split(.$NOMBRE)
sfs6 <- sfs[[6]]%>%split(.$NOMBRE)

#Map inside a map
sfs. <- map(sfs, . %>% split(.$NOMBRE))


sfs.[[1]][2]

sfs1[[1]]


#Extract Vector with the names of the PNN (surely will need them in a moment)
names <- unique(sfs[[1]][["NOMBRE"]])
names <- sort(names)
#load harmonized masked 
mskwd <- '/storage/share/BiomapCol_22/Maps_hansen/Armonized_msk'

tiffes <- list.files(mskwd, pattern='.tif')
#select the specific years

tiffes <- tiffes[-c(1:5)]
tiffes <- tiffes[c(3,8,13,16,18,19)]
                                        # set vector to name rasters per year.
years <- unlist(map(1:length(tiffes), function(x) str_sub(tiffes[x], start=8, end=15)))

                                        #load rasters masks 
getwd()

harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(paste(mskwd,tiffes[i], sep='/'))}
#load mask (fill NAs, i think i have it somewhere but can't recall where)

m <- c(-Inf, Inf, 0)
m <- matrix(m,ncol=3,byrow=TRUE)
temp <- reclassify(temp,m)

# crop the template raster
# for some reason future_map s not working on the Mac. Find out why
 mem_future <- 5000*1024^2 #this is toset the limit to 5GB
 plan(multisession, workers=6)
 options(future.globals.maxSize= mem <- future)

harm <- map(1:length(harm), function(x) raster::merge(harm[[x]], temp))

#crop and mask for each of the PNN
temp <-map(1:length(sfs1), function(x)  crop(temp, extent(sfs1[[x]]))) 
temp <-map(1:length(sfs1), function(x)  mask(temp[[x]], sfs1[[x]])) 

                                        #what is this

# for each year. Data rasterized (each one is each park)

sfs1 <- map(1:6, function(x) fasterize(sfs1[[x]], temp[[x]], field='type'))
sfs2 <- map(1:6, function(x) fasterize(sfs2[[x]], temp[[x]], field='type'))
sfs3 <- map(1:6, function(x) fasterize(sfs3[[x]], temp[[x]], field='type'))
sfs4 <- map(1:6, function(x) fasterize(sfs4[[x]], temp[[x]], field='type'))
sfs5 <- map(1:6, function(x) fasterize(sfs5[[x]], temp[[x]], field='type'))
sfs6 <- map(1:6, function(x) fasterize(sfs6[[x]], temp[[x]], field='type'))
#harm <- do.call(stack, harm)

sfs. <- map(sfs., . %>% fasterize(.$sfs., ))
sfs.1<-map( 

                                        # split  Harmonized by each one per year. This is the kind of process that i need to nest, because so far I have to cp+v each time,  looks awful and is very inefficient, but anyway.
                                        # SEE, Iit gets really confusing



                                        #convert names list from factor into character. Subsitute " " with "_"
names <-  sub(" ", "_", names)

map(1:length(harm), function(x) writeRaster(harm[[x]],paste('harm_bin', years[x], sep='_'))) 

getwd()

tiffes


                                            
let us solve this the right way. 

each sfs list matches to each harm list. 

harm1 <- map(1:length(temp),function(x) crop(harm[[1]], extent(temp[[x]])))
harm1 <- map(1:length(temp),function(x) mask(harm1[[x]], temp[[x]]))
harm2 <- map(1:length(temp),function(x) crop(harm[[2]], extent(temp[[x]])))
harm2 <- map(1:length(temp),function(x) mask(harm2[[x]], temp[[x]]))
harm3 <- map(1:length(temp),function(x) crop(harm[[3]], extent(temp[[x]])))
harm3 <- map(1:length(temp),function(x) mask(harm3[[x]], temp[[x]]))
harm4 <- map(1:length(temp),function(x) crop(harm[[4]], extent(temp[[x]])))
harm4 <- map(1:length(temp),function(x) mask(harm4[[x]], temp[[x]]))
harm5 <- map(1:length(temp),function(x) crop(harm[[5]], extent(temp[[x]])))
harm5 <- map(1:length(temp),function(x) mask(harm5[[x]], temp[[x]]))
harm6 <- map(1:length(temp),function(x) crop(harm[[6]], extent(temp[[x]])))
harm6 <- map(1:length(temp),function(x) mask(harm6[[x]], temp[[x]]))
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
