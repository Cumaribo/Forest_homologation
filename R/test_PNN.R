packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf','gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 'ecochange', 'furrr')
out.. <-  sapply(packs, require, character.only = TRUE)


setwd('/storage/home/TU/tug76452/Forest_Armonization')


dir.create('tempfiledir')
                                        #obtain string with the path
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#  Load 0 background raster   to rasterize
temp <- raster('/storage/home/TU/tug76452/Forest_Armonization/bin_masked/msk_0.tif')#load harmonized masked 
mskwd <- '/storage/share/BiomapCol_22/Maps_hansen/Armonized_msk'

tiffes <- list.files(mskwd, pattern='.tif')
#select the specific years

tiffes <- tiffes[-c(1:6)]
tiffes <- tiffes[c(3,8,13,16,18,19)]
                                        # set vector to name rasters per year.
years <- unlist(map(1:length(tiffes), function(x) str_sub(tiffes[x], start=8, end=15)))


harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(paste(mskwd,tiffes[i], sep='/'))}
#load mask (fill NAs, i think i have it somewhere but can't recall where)
# crop the template raster
# for some reason future_map s not working on the Mac. Find out why

mem_future <- 5000*1024^2 #this is toset the limit to 5GB
 plan(multisession, workers=6)
 options(future.globals.maxSize= mem <- future)

harm <- map(1:length(harm), function(x) raster::merge(harm[[x]], temp))
binwd <- '/storage/home/TU/tug76452/Forest_Armonization'
setwd(binwd)
map(1:length(harm), function(x) writeRaster(harm[[x]], paste('bin_masked', years[x], sep= '_')))

dir()

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
