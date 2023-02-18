
# #Question for stackexchange::
# # create test raster
# ras1 <- raster(ncol=5,nrow=5) 
# pol1 = st_sfc(st_polygon(list(cbind(c(0,3,3,0,0),c(0,0,3,3,0)))))
# h = st_sf(r = 5, pol1)
# h1 = st_sf(r = 6, pol1)
# h <- st_crs(h, crs=st_crs(ras1))
# hr <- fasterize(h, ras1, field='r')
# plot(hr)
# 
# pol2 = st_sfc(st_polygon(list(cbind(c(4,5,5,4,4),c(4,4,5,5,4)))))
# g = st_sf(r = 5, pol2)
# g1 = st_sf(r = 6, pol2)
# 
# #add the other part (transform the tables into agreement tables)
# agg1