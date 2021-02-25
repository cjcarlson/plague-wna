library(sp)
library(rgdal)
library(raster)

setwd('C:/Users/cjcar/Documents/Github/meridian100/Raw data')
point.data <- read.csv('western USA-edit.csv')

counties <- readOGR(layer='CountiesNoHole',dsn='.')
counties[490,grepl('YEAR', colnames(counties@data))] <- 0
counties[490,'TOTAL'] <- 0

sp.point <- SpatialPointsDataFrame(point.data[,1:2], point.data[,3:59])
sp.point@proj4string <- counties@proj4string

j = 1 
set.seed(10) # Added this - worth a double check, threw an error once without but stochastically?
for (year in 1950:2005) {
  for (co in 1:nrow(counties@data)) {
    if(counties@data[co,year-1940]>0) {
      s.sub <- spsample(counties[co,],n=counties@data[co,year-1940], "random")
      s.sub <- SpatialPointsDataFrame(s.sub@coords,data=data.frame(year=rep(year,counties@data[co,year-1940])))
      if (j == 1) { s <- s.sub} else {s <- bind(s, s.sub)}
      j <- j+1
    }
  }}

#plot(counties,col=(counties$TOTAL>0))
#points(s,col='red',pch=16)

county.raster <- fasterize::fasterize(sf::st_as_sf(readOGR(layer='CountiesNoHole',dsn='.')), rodents)

for(i in 1950:2005) {
  
  sub <- s[s$year==i,]
  abs <- randomPoints(county.raster, n=7)
  env <- stackmaker[[i-1949]]
  
  p.pts <- data.frame(cbind(1,raster::extract(env,sub)))
  a.pts <- data.frame(cbind(0,raster::extract(env,abs)))
  data <- rbind(p.pts,a.pts)
  data$yr <- i
  
  if(i==1950){big <- data} else {big <- rbind(big,data)}
  print(i)
}

big <- data.frame(big)

colnames(big) <- c('case','rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                   'tmin','tmean','tmax','ppt','ppt.n','tmp.n','yr')

#set.seed(69)
#big <- rbind(big %>% filter(case==0) %>% sample_n(nrow(big %>% filter(case==1))),
#             big %>% filter(case==1))
# ^ this may have been flipped off at some point, strategically - maybe reverse if results get weird

write.csv(big, 'C:/Users/cjcar/Documents/GitHub/meridian100/Pipeline2020/Humandata.csv')
