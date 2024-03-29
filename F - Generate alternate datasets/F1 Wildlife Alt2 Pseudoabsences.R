
#library(gbm)
library(dismo)
library(dbarts)
library(embarcadero)
library(velox)

library(tidyverse)
nwdp <- read_csv('C:/Users/cjcar/Desktop/plague data download 1May2019.csv')

nwdp$CollectionDate <- lubridate::dmy(nwdp$CollectionDate)
nwdp$year <- lubridate::year(nwdp$CollectionDate)

nwdp %>% filter(ScientificName %in% c('canis latrans',
                                      'Canis latrans',
                                      'Canis Latrans',
                                      'CANIS LATRANS')) -> nwdp

for(i in 2000:2017) {
  
  nwdp %>% filter(year==i) -> sub 
  if(nrow(sub)>0) {
    env <- stackmaker[[i-1949]]
    
    pres <- sub[sub$PlagueResults=='Positive',]
    abs <- randomPoints(elev, n=320)
    
    p.pts <- data.frame(cbind(1,raster::extract(env,pres[,c('Longitude','Latitude')])))
    a.pts <- data.frame(cbind(0,raster::extract(env,abs[,c('x','y')])))
    data <- rbind(p.pts,a.pts)
    data$yr <- i
    
    if(i==2000){big <- data} else {big <- rbind(big,data)}
    print(i)
  }
}

big <- data.frame(big)

###############

colnames(big) <- c('case','rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                   'tmin','tmean','tmax','ppt','ppt.n','tmp.n','yr')

set.seed(69)
big <- rbind(big %>% filter(case==0) %>% sample_n(nrow(big %>% filter(case==1))),
             big %>% filter(case==1))

big <- na.omit(big)

write.csv(big, '~/Github/meridian100/Pipeline2020/NWDPpseudo.csv')

