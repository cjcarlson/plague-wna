
layerA <- read.csv('C:/Users/cjcar/Dropbox/PlagueWNA/Appendix_3a_Ahorizon_18Sept2013.csv')

layerA$A_Ca <- as.character(layerA$A_Ca)
layerA$A_Fe <- as.character(layerA$A_Fe)
layerA$A_Na <- as.character(layerA$A_Na)

layerA$A_Ca[layerA$A_Ca == 'N.S.'] <- NA
layerA$A_Ca[layerA$A_Ca == 'INS'] <- 0
layerA$A_Ca[layerA$A_Ca == '<0.01'] <- 0
layerA$A_Ca <- as.numeric(as.character(layerA$A_Ca))

layerA$A_Fe[layerA$A_Fe == 'N.S.'] <- NA
layerA$A_Fe[layerA$A_Fe == 'INS'] <- 0
layerA$A_Fe[layerA$A_Fe == '<0.01'] <- 0
layerA$A_Fe <- as.numeric(as.character(layerA$A_Fe))

layerA$A_Na[layerA$A_Na == 'N.S.'] <- NA
layerA$A_Na[layerA$A_Na == 'INS'] <- 0
layerA$A_Na[layerA$A_Na == '<0.01'] <- 0
layerA$A_Na <- as.numeric(as.character(layerA$A_Na))

library(sp)
soilpts <- SpatialPointsDataFrame(layerA[,c("Longitude", "Latitude")], 
                               layerA[,c('A_Fe', 'A_Ca', 'A_Na')])

library(raster)
blank <- raster('C:/Users/cjcar/Dropbox/PlagueWNA/Layers/RodentRichness.tif')*0
blank <- as(blank, "SpatialPixelsDataFrame")
crs(blank) <- NA

library(automap)

#Perform ordinary kriging and store results inside object of type "autoKrige" "list" 
kriging_result = autoKrige(A_Fe~1, soilpts[complete.cases(soilpts$A_Fe),], blank)
plot(kriging_result)

kresult <- raster(kriging_result$krige_output)
writeRaster(kresult, 'C:/Users/cjcar/Dropbox/PlagueWNA/kriged-iron.tif',
            overwrite=TRUE)




#Perform ordinary kriging and store results inside object of type "autoKrige" "list" 
kriging_result = autoKrige(A_Ca~1, soilpts[complete.cases(soilpts$A_Ca),], blank)
plot(kriging_result)

kresult <- raster(kriging_result$krige_output)
writeRaster(kresult, 'C:/Users/cjcar/Dropbox/PlagueWNA/kriged-calcium.tif',
            overwrite=TRUE)




#Perform ordinary kriging and store results inside object of type "autoKrige" "list" 
kriging_result = autoKrige(A_Na~1, soilpts[complete.cases(soilpts$A_Na),], blank)
plot(kriging_result)

kresult <- raster(kriging_result$krige_output)
writeRaster(kresult, 'C:/Users/cjcar/Dropbox/PlagueWNA/kriged-sodium.tif',
            overwrite=TRUE)

