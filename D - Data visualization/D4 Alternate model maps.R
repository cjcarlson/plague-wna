
library(embarcadero)
library(gridExtra)

# Change for each required map

setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt1/')

yearlys.W <- readRDS("yearlysW.RDS")

modelW <- readRDS("modelW.RDS")

summary(modelW)
tW <- 0.5431646 # Change this every time 

unstableW <- (sum(yearlys.W > tW)>0)

stableW <- (sum(yearlys.W > tW)==68)

meanW <- mean(yearlys.W)

threshW <- unstableW + stableW

threshW <- ratify(threshW)
rat <- levels(threshW)[[1]]
rat$classes <- c('None','Some','All')
levels(threshW) <- rat

#outline <- rasterToPolygons(meanW*0, dissolve=TRUE)
######################################

library(rasterVis)
library(rcartocolor)

lattice.options(layout.heights=list(bottom.padding=list(x=0), 
                                       top.padding=list(x=0)),   
                layout.widths=list(left.padding=list(x=0), 
                                      right.padding=list(x=0)))

cols <- carto_pal(10, "Temps")

l1 <- levelplot(meanW, 
                margin = F,
               at = seq(0, 1, 0.01), 
               par.strip.text=list(cex=0),
               xlab = NULL, ylab = NULL, 
               scales=list(alternating=FALSE),
               par.settings=rasterTheme(cols),
               maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))

resize = 0.983
grid.arrange(l1, 
             layout_matrix = rbind(c(1,NA)),
             widths = c(resize, 1-resize))


#########


setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt1/')
modelW <- readRDS("modelW.RDS")
varimp(modelW, plots = TRUE)


setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Human-Alt1/')
modelH <- readRDS("modelH.RDS")
varimp(modelH, plots = TRUE)