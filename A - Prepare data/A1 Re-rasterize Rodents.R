library(fasterize)
library(sf)
library(rgdal)

setwd('C:/Users/cjcar/Dropbox/PlagueWNA/Layers')
setwd('./PRISM climate layers/')

pasty <- function(x) {raster(paste(paste(paste('./',x,sep=''),x,sep='/'),'bil',sep='.'))}

tmin <- list.files(pattern="tmin")
tmin <- stack(lapply(tmin,pasty))
blank <- tmin[[1]]*0

mammal <- readOGR('C:/Users/cjcar/Downloads/TERRESTRIAL_MAMMALS/TERRESTRIAL_MAMMALS.shp')
mammal <- mammal[mammal$order_=='RODENTIA',]
mammal <- st_as_sf(mammal)

mammal.r <- fasterize(mammal, blank, fun='count')
mammal.r <- mammal.r + blank

mammal.r <- crop(mammal.r, extent(-130, -95, 10, 49))

# COME BACK TO THIS LINE
# IF YOU WANT TO RE-EXTENT THE MAP
     
writeRaster(mammal.r, 
            'C:/Users/cjcar/Dropbox/PlagueWNA/Layers/RodentRichness.tif',
            overwrite=TRUE)
