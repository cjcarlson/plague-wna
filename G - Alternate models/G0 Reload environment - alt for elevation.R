
library(devtools)
library(dismo)
library(elevatr)
library(embarcadero)
library(fasterize)
library(raster)
library(rgeos)
#library(rgdal) 
library(sf)
library(sp)
library(tidyverse)

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


setwd('/nfs/ccarlson-data/yersinia/Layers')

################################################

## Rodent richness

rodents <- raster('RodentRichness.tif')
rodents <- trim(rodents)

blank <- rodents*0

## Climate layers straight from PRISM

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

## Climatic anomalies

tmean.norm <- (tmean-mean(tmean))/calc(tmean,var)
ppt.norm <- (ppt-mean(ppt))/calc(ppt,var)

## Soil covariates

setwd('/nfs/ccarlson-data/yersinia/Layers/SoilGridsCLayer')

soil.layers <- stack(raster('CEC-resample.tif'),
                     raster('ph-resample.tif'),
                     raster('sand-resample.tif'),
                     raster('clay-resample.tif'),
                     raster('organic-resample.tif'))
soil.layers <- trim(soil.layers)

iron <- raster('kriged-iron.tif')
iron <- iron + rodents*0

calcium <- raster('kriged-calcium.tif')
calcium <- calcium + rodents*0

sodium <- raster('kriged-sodium.tif')
sodium <- sodium + rodents*0

soil.layers <- stack(soil.layers,iron)
soil.layers <- stack(soil.layers,calcium)
soil.layers <- stack(soil.layers,sodium)
soil.layers@crs <- rodents@crs

## Elevation

elev <- raster('/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt3/elevDummy.tif')

## All the layers

stackmaker <- lapply(c(1950:2017), function(x){print(paste(x))
  stack.year(x)})

################################################
