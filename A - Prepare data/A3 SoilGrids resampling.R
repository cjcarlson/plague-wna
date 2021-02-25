
setwd('C:/Users/cjcar/Dropbox/PlagueWNA/Layers/SoilGrids')

clippy <- 0*raster('C:/Users/cjcar/Dropbox/PlagueWNA/Layers/RodentRichness.tif')

clay <- raster('CLYPPT_M_sl1_250m.tif')
clay.clip <- crop(clay, clippy)
clay.sample <- resample(clay.clip, clippy)
clay.sample <- sum(clay.sample,clippy,na.rm=FALSE)
writeRaster(clay.sample,'clay-resample.tif',overwrite=TRUE)

org <- raster('ORCDRC_M_sl1_250m.tif')
org.clip <- crop(org, clippy)
org.sample <- resample(org.clip, clippy)
org.sample <- sum(org.sample,clippy,na.rm=FALSE)
writeRaster(org.sample,'organic-resample.tif',overwrite=TRUE)

snd <- raster('SNDPPT_M_sl1_250m.tif')
snd.clip <- crop(snd, clippy)
snd.sample <- resample(snd.clip, clippy)
snd.sample <- sum(snd.sample,clippy,na.rm=FALSE)
writeRaster(snd.sample,'sand-resample.tif',overwrite=TRUE)

phi <- raster('PHIHOX_M_sl1_250m.tif')
phi.clip <- crop(phi, clippy)
phi.sample <- resample(phi.clip, clippy)
phi.sample <- sum(phi.sample,clippy,na.rm=FALSE)
writeRaster(phi.sample,'ph-resample.tif',overwrite=TRUE)

chex <- raster('CECSOL_M_sl1_250m.tif')
chex.clip <- crop(chex, clippy)
chex.sample <- resample(chex.clip, clippy)
chex.sample <- sum(chex.sample,clippy,na.rm=FALSE)
writeRaster(chex.sample,'CEC-resample.tif',overwrite=TRUE)
