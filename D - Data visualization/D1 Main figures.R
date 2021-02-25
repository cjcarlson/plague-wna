
library(embarcadero)
library(gridExtra)

setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/')

yearlys.H <- readRDS("yearlysH.RDS")
yearlys.W <- readRDS("yearlysW.RDS")

modelH <- readRDS("modelH.RDS")
modelW <- readRDS("modelW.RDS")

summary(modelW)
tW <- 0.539247

summary(modelH)
tH <- 0.5029236

unstableW <- (sum(yearlys.W > tW)>0)
unstableH <- (sum(yearlys.H > tH)>0)

stableW <- (sum(yearlys.W > tW)==68)
stableH <- (sum(yearlys.H > tH)==68)

meanW <- mean(yearlys.W)
meanH <- mean(yearlys.H)
means <- stack(meanH, meanW)

threshW <- unstableW + stableW
threshH <- unstableH + stableH

threshW <- ratify(threshW)
rat <- levels(threshW)[[1]]
rat$classes <- c('None','Some','All')
levels(threshW) <- rat

threshH <- ratify(threshH)
rat <- levels(threshH)[[1]]
rat$classes <- c('None','Some','All')
levels(threshH) <- rat

thresh <- stack(threshH, threshW)

######################################

library(rasterVis)
library(rcartocolor)

lattice.options(layout.heights=list(bottom.padding=list(x=0), 
                                       top.padding=list(x=0)),   
                layout.widths=list(left.padding=list(x=0), 
                                      right.padding=list(x=0)))

cols <- carto_pal(10, "Temps")

l1 <- levelplot(means, 
               at = seq(0, 1, 0.01), 
               par.strip.text=list(cex=0),
               xlab = NULL, ylab = NULL, 
               scales=list(alternating=FALSE),
               par.settings=rasterTheme(cols),
               maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))
 
library(LaCroixColoR)

cols2 <- rev(lacroix_palette("Coconut",n=6))[c(4,3,2)]

l2 <- levelplot(thresh, 
                par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols2),
                maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))

lay <- rbind(c(1,NA),c(2,2))

resize = 0.983
grid.arrange(l1, l2, layout_matrix = lay,
             ncol = 2,
             widths = c(resize, 1 - resize))


######################################

overlap <- unstableW + unstableH*2
plot(overlap)

overlap <- ratify(overlap)
rat <- levels(overlap)[[1]]
rat$classes <- c('No risk','Human','Wildlife','Both')
levels(overlap) <- rat

library(awtools)

col1 <- rev(lacroix_palette("Coconut",n=6))[c(4)]
col2 <- awtools::a_palette[c(2,6,1)]

cols3 <- c(col1, col2)  

outline <- rasterToPolygons(overlap*0, dissolve=TRUE)

levelplot(overlap,
          par.strip.text=list(cex=0),
          xlab = NULL, ylab = NULL, 
          scales=list(alternating=FALSE),
          par.settings=rasterTheme(cols3),
          maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))

################################

yearlys.H.ri <- readRDS('yearlysHri.RDS')
yearlys.W.ri <- readRDS('yearlysWri.RDS')

time <- 1:68 

fun = function(x) { if (is.na(x[1])){ NA } else 
{ m = lm(x ~ time); summary(m)$coefficients[2] }}

risk.slope.H = calc(yearlys.H, fun)
risk.slope.H.ri = calc(yearlys.H.ri, fun)
risk.slope.W = calc(yearlys.W, fun)
risk.slope.W.ri = calc(yearlys.W.ri, fun)

slopes <- stack(risk.slope.H,
                risk.slope.H.ri,
                risk.slope.W,
                risk.slope.W.ri)*68*100

diverge0 <- function(p, ramp) {
  # p: a trellis object resulting from rasterVis::levelplot
  # ramp: the name of an RColorBrewer palette (as character), a character 
  #       vector of colour names to interpolate, or a colorRampPalette.
  require(RColorBrewer)
  require(rasterVis)
  if(length(ramp)==1 && is.character(ramp) && ramp %in% 
     row.names(brewer.pal.info)) {
    ramp <- suppressWarnings(colorRampPalette(rev(brewer.pal(11, ramp))))
  } else if(length(ramp) > 1 && is.character(ramp) && all(ramp %in% colors())) {
    ramp <- colorRampPalette(ramp)
  } else if(!is.function(ramp)) 
    stop('ramp should be either the name of a RColorBrewer palette, ', 
         'a vector of colours to be interpolated, or a colorRampPalette.')
  rng <- range(p$legend[[1]]$args$key$at)
  s <- seq(-max(abs(rng)), max(abs(rng)), len=1001)
  i <- findInterval(rng[which.min(abs(rng))], s)
  zlim <- switch(which.min(abs(rng)), `1`=i:(1000+1), `2`=1:(i+1))
  p$legend[[1]]$args$key$at <- s[zlim]
  p[[grep('^legend', names(p))]][[1]]$args$key$col <- ramp(1000)[zlim[-length(zlim)]]
  p$panel.args.common$col.regions <- ramp(1000)[zlim[-length(zlim)]]
  p
}

mapTheme <- rasterTheme(#region = cols,
  layout.widths = list(right.padding = 10),
  axis.line = list(col = "transparent"),
  tick = list(col = 'transparent'))

l4 <- levelplot(slopes,
          par.strip.text=list(cex=0),
          xlab = NULL, ylab = NULL, 
          scales=list(alternating=FALSE),
          maxpixels = 4e6) + 
     layer(sp.polygons(outline, col = 'black',
                    fill=NA))

l4 <- diverge0(l4, 'RdBu')
l4


#########################################

meanWr <- mean(yearlys.W.ri)
meanHr <- mean(yearlys.H.ri)
meansr <- stack(meanHr, meanWr)

l5 <- levelplot(meansr, 
                at = seq(0, 1, 0.01), 
                par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols),
                maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))

#########################################

source("/nfs/ccarlson-data/yersinia/2020Pipeline/C0 Reload environment.R")

temps <- lapply(c(1:68), function(i) {stackmaker[[i]]$tmean})
ppts <- lapply(c(1:68), function(i) {stackmaker[[i]]$ppt})
tempsa <- lapply(c(1:68), function(i) {stackmaker[[i]]$tmp.n})
pptsa <- lapply(c(1:68), function(i) {stackmaker[[i]]$ppt.n})

temp.slope = calc(stack(temps), fun)
ppts.slope = calc(stack(ppts), fun)

cols <- carto_pal(10, "Temps")

l6 <- levelplot(temp.slope*68, 
                par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                margin = FALSE,
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols),
                maxpixels = 4e6) + 
  layer(sp.polygons(outline, col = 'black',
                    fill=NA))

l6 <- diverge0(l6, 'RdBu')

l7 <- levelplot(ppts.slope*68, 
                par.strip.text=list(cex=0),
                xlab = NULL, ylab = NULL, 
                margin = FALSE,
                scales=list(alternating=FALSE),
                par.settings=rasterTheme(cols),
                maxpixels = 4e6) + 
layer(sp.polygons(outline, col = 'black',
                  fill=NA))

l7 <- diverge0(l7, 'RdBu')

mean(na.omit(values(temp.slope)))*68
mean(na.omit(values(ppts.slope)))*68

################################################

rodents <- raster('/nfs/ccarlson-data/yersinia/Layers/RodentRichness.tif')
rodents <- trim(rodents)
elev <- elevatr::get_elev_raster(rodents,z=6)
elev <- resample(elev,rodents)
elev <- elev + rodents*0

dfH <- data.frame(change = values(risk.slope.H)*100*68)
dfH.ri <- data.frame(change = values(risk.slope.H.ri)*100*68)
dfW <- data.frame(change = values(risk.slope.W)*100*68)
dfW.ri <- data.frame(change = values(risk.slope.W.ri)*100*68)

dfH$elev <- values(elev)
dfH.ri$elev <- values(elev)
dfW$elev <- values(elev)
dfW.ri$elev <- values(elev)

dfH$source = 'human'
dfH.ri$source = 'human'
dfW$source = 'wildlife'
dfW.ri$source = 'wildlife'

dfH$ri = 'BART'
dfH.ri$ri = 'riBART'
dfW$ri = 'BART'
dfW.ri$ri = 'riBART'

df <- rbind(dfH, dfH.ri, dfW, dfW.ri)

df$source <- factor(df$source)
df$ri <- factor(df$ri)


df %>%
  group_by(ri, source) %>%
  summarise(Mean = mean(na.omit(change))) -> df2

df %>% 
  ggplot(aes(change)) + 
  facet_grid( source ~ ri)+ 
  #cowplot::theme_cowplot() +
  geom_density(fill = "lightgray") + 
  #xlim(-30, 30) +
  theme_bw()  +
  geom_vline(aes(xintercept = 0), linetype = 1) + 
  geom_vline(data=df2, mapping = aes(xintercept = Mean), 
             linetype = 2, col='red') +  
  scale_y_sqrt() +
  xlab('% change') + ylab('Density of pixels (root-transformed)') + 
  theme(axis.title.y = element_text(vjust = 5, hjust = 0.5),
        axis.title.x = element_text(vjust = -3),
        plot.margin=unit(c(0.1,0.2,0.6,1.3),"cm")) -> g

######################

df %>% 
  ggplot(aes(x = elev, y = change)) + theme_bw() + 
  geom_point(alpha = 0.005, col = 'light grey') + 
  geom_smooth() + 
  facet_grid(source ~ ri) +
  xlab('Elevation (m)') + ylab('Total % change (1950-2017)')


library(awtools)

df %>% filter(ri == 'riBART') %>% 
  ggplot(aes(x = elev, y = change, group = source, color = source)) + theme_bw() +
  geom_smooth(method = 'gam') + 
  scale_color_manual(values = c("#8E5D9F", awtools::a_palette[c(2)])) + # purple reconstruction not fixed above
  xlab('Elevation (m)') + ylab('Total % change (1950-2017)') + 
  labs(colour = NULL) +
  theme(legend.position = c(0.13, 0.88),
        axis.title.x=element_text(vjust = -2),
        axis.title.y=element_text(vjust = 2),
        plot.margin = margin(1, 1, 1, 1, "cm"))
                     
########################

library(embarcadero)

wild <- read.csv('/nfs/ccarlson-data/yersinia/2020Pipeline/Inputs/NWDPdata.csv')
wild$ppt <- log(wild$ppt)
wild <- na.omit(wild)

g1 <- varimp.diag(wild[,c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                    'tmin','tmean','tmax','ppt','ppt.n','tmp.n')],
            wild[,'case'],
            iter = 200)

human <- read.csv('/nfs/ccarlson-data/yersinia/2020Pipeline/Inputs/Humandata.csv')
human$ppt <- log(human$ppt)
human <- na.omit(human)

varimp.diag(human[,c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                    'tmin','tmean','tmax','ppt','ppt.n','tmp.n')],
            human[,'case'],
            iter = 200)
