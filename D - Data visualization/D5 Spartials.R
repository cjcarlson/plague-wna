
library(rasterVis)
library(rcartocolor)
library(gridExtra)
library(embarcadero)

modelH <- readRDS("/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/modelH.RDS")
sH <- spartial(modelH, envs = stackmaker[[1]], smooth = 5)
saveRDS(sH, '/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/spartialsH.RDS')

modelW <- readRDS("/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/modelW.RDS")
sW <- spartial(modelW, envs = stackmaker[[1]], smooth = 5)
saveRDS(sW, '/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/spartialsW.RDS')


# sH <- readRDS('/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/spartialsH.RDS')
# sW <- readRDS('/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/spartialsW.RDS')

sH <- sH[[order(varimp(modelH)$varimps, decreasing = TRUE)]]
sW <- sW[[order(varimp(modelW)$varimps, decreasing = TRUE)]]


lattice.options(layout.heights=list(bottom.padding=list(x=0), 
                                    top.padding=list(x=0)),   
                layout.widths=list(left.padding=list(x=0), 
                                   right.padding=list(x=0)))

cols <- carto_pal(10, "Temps")

p.strip <- list(cex=1.2, lines=1)

l1 <- levelplot(sH, 
                margin = F,
                #at = seq(0, 1, 0.01), 
                #par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols),
                maxpixels = 4e6,
                names.attr=names(sH), 
                par.strip.text=p.strip) #+ 
 # layer(sp.polygons(outline, col = 'black',
 #                   fill=NA))

resize = 0.983
grid.arrange(l1, 
             layout_matrix = rbind(c(1,NA)),
             widths = c(resize, 1-resize))

l2 <- levelplot(sW, 
                margin = F,
                #at = seq(0, 1, 0.01), 
                #par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols),
                maxpixels = 4e6,
                names.attr=names(sW), 
                par.strip.text=p.strip) #+ 
# layer(sp.polygons(outline, col = 'black',
#                   fill=NA))

resize = 0.983
grid.arrange(l2, 
             layout_matrix = rbind(c(1,NA)),
             widths = c(resize, 1-resize))
