
library(ggplot2) # Test out individual relationships
library(embarcadero)
library(cowplot)
library(tidyverse)
library(reshape2)

setwd('/nfs/ccarlson-data/yersinia')

####

modelW <- readRDS('./2020Pipeline/Outputs/modelW.RDS')

#modelW <- bart(wild[,attr(modelW$fit$data@x, "term.labels")],wild[,'case'], keeptrees = TRUE)

p2 <- pd2bart(modelW, xind=c('sand','clay'),
              levs = list(c(seq(from = 0, to = 100, by = 5)), c(seq(from = 0, to = 100, by = 5))))

testdf <- cbind(as.matrix(expand.grid(p2$levs[[1]],p2$levs[[2]])), t(p2$fd))
testdf <- data.frame(testdf)
meltdf <- reshape::melt(testdf, id=c("Var1","Var2")) # This step isn't working
colnames(meltdf) <- c('sand','clay','iter','partial')
meltdf$silt <- 100-(meltdf$sand + meltdf$clay)
meltdf$partial <- pnorm(meltdf$partial)
meltdf <- meltdf[meltdf$silt >= 0, ]


partialBreaks <- seq(from = 0, to = 1, by = 0.025)

library(ggtern)
# 
# ggtern(meltdf,aes(sand,clay,silt,value=partial)) + 
#   geom_interpolate_tern(
#     data = meltdf,
#     mapping = aes(
#       value = partial,color=..level..
#     ),
#     method=lm,   # <<<<<< SPECIFY METHOD HERE <<<<<<<
#     formula = expand.formula(value ~ cubicS(x,y) + quad(x,y)),
#     base = "identity",
#     breaks = partialBreaks,
#     lwd=1.5
#   ) + theme_bw() + theme_showarrows() + labs(color='Probability') 

library(Ternary)

head(meltdf)

backup <- meltdf
meltdf %>% group_by(sand, silt, clay) %>% summarize(partial = mean(partial)) -> meltdf

# 
# fixer <- function(a,b,c) {
#   a <- a*100
#   b <- b*100
#   c <- c*100
#   
#   sandnum <- meltdf$sand[which.min(abs(meltdf$sand - a))]
#   sandrows <- which(meltdf$sand == sandnum)
#   
#   claynum <- meltdf$clay[which.min(abs(meltdf$clay - b))]
#   clayrows <- which(meltdf$clay == claynum)
#   
#   siltnum <- meltdf$silt[which.min(abs(meltdf$silt - c))]
#   siltrows <- which(meltdf$silt == siltnum)
#   
#   goodrows = intersect(intersect(sandrows, clayrows), siltrows)
#   return(mean(meltdf$partial[goodrows]))
# }
# 
# TernaryPlot(alab = 'a', blab = 'b', clab = 'c')
# values <- TernaryPointValues(fixer, resolution = 24L)
# ColourTernary(values)
# TernaryContour(fixer, resolution = 36L)
# 

meltdf %>% as.data.frame() -> meltdf

TernaryPlot(atip = "Clay",
            btip = "Sand",
            ctip = "Silt")


spectrumBins <- 10
mySpectrum <- viridisLite::viridis(spectrumBins)
binnedReflectance <- cut(meltdf$partial, spectrumBins)
dat_col <- mySpectrum[binnedReflectance]

TernaryPoints(meltdf[, c('clay', 'sand', 'silt')],
              col = dat_col,
              pch = 16,
              cex = 2
)

legend('topright', col = mySpectrum[levels(binnedReflectance) %in% binnedReflectance], pch = 16, 
       legend = sort(unique(binnedReflectance)),
       title = 'Partial effect', bty = 'n', cex = 1)
