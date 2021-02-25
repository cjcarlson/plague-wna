
library(devtools)
library(elevatr)
library(raster)
library(readr)
library(rgeos)
#library(rgdal) 
library(fasterize)
library(sf)

#######################################################################
#1. GENERATE EACH COMPONENT LAYER

# Mammals

setwd('C:/Users/cjcar/Dropbox/PlagueWNA/Layers/')
rodents <- raster('RodentRichness.tif')
rodents <- trim(rodents)

blank <- rodents*0

# Climate layers

setwd('./PRISM climate layers/')

pasty <- function(x) {raster(paste(paste(paste('./',x,sep=''),x,sep='/'),'bil',sep='.'))}

tmin <- list.files(pattern="tmin")
tmin <- stack(lapply(tmin,pasty))

tmean <- list.files(pattern="tmean")
tmean <- stack(lapply(tmean,pasty))

tmax <- list.files(pattern="tmax")
tmax <- stack(lapply(tmax,pasty))

ppt <- list.files(pattern="ppt")
ppt <- stack(lapply(ppt,pasty))

tmin <- projectRaster(tmin, blank)
tmin <- tmin+blank

tmean <- projectRaster(tmean, blank)
tmean <- tmean+blank

tmax <- projectRaster(tmax, blank)
tmax <- tmax+blank

ppt <- projectRaster(ppt, blank)
ppt <- ppt+blank

# Some new code for generating anomalies

tmean.norm <- (tmean-mean(tmean))/calc(tmean,var)
ppt.norm <- (ppt-mean(ppt))/calc(ppt,var)

# SoilGrids and other soil

setwd('C:/Users/cjcar/Dropbox/PlagueWNA/Layers/SoilGridsCLayer')
# ^ If it's just SoilGrids, it'll point to A Layer.

soil.layers <- stack(raster('CEC-resample.tif'),
                     raster('ph-resample.tif'),
                     raster('sand-resample.tif'),
                     raster('clay-resample.tif'),
                     raster('organic-resample.tif'))
soil.layers <- trim(soil.layers)

iron <- raster('C:/Users/cjcar/Dropbox/PlagueWNA/kriged-iron.tif') + rodents*0
calcium <- raster('C:/Users/cjcar/Dropbox/PlagueWNA/kriged-calcium.tif') + rodents*0
sodium <- raster('C:/Users/cjcar/Dropbox/PlagueWNA/kriged-sodium.tif') + rodents*0

soil.layers <- stack(soil.layers,iron)
soil.layers <- stack(soil.layers,calcium)
soil.layers <- stack(soil.layers,sodium)

soil.layers@crs <- rodents@crs

# Elevation

library(elevatr)
elev <- elevatr::get_elev_raster(locations = rodents, z=6)
elev <- resample(elev,rodents)
elev <- elev + rodents*0
elev <- projectRaster(elev,soil.layers)

#######################################################################
#2. GENERATE AN OBJECT OF ANNUAL LAYERS

rodents@crs <- soil.layers@crs

stack.year <- function(yr) {
  
  stack.fixed <- stack(rodents,soil.layers,elev)
  year.guys <- stack(tmin[[yr-1949]],
                     tmean[[yr-1949]],
                     tmax[[yr-1949]],
                     ppt[[yr-1949]],
                     ppt.norm[[yr-1949]],
                     tmean.norm[[yr-1949]])
  pred <- stack(stack.fixed,year.guys)
  
  names(pred) <- c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                   'tmin','tmean','tmax','ppt','ppt.n','tmp.n')
  return(pred)
  
}

stackmaker <- lapply(c(1950:2017), function(x){print('one down')
  stack.year(x)})

write_rds(stackmaker, '~/Github/meridian100/Pipeline2020/stackmaker.RDS')