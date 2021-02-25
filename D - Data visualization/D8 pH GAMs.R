
library(ggplot2) # Test out individual relationships
library(embarcadero)
library(cowplot)
library(tidyverse)
library(reshape2)

setwd('/nfs/ccarlson-data/yersinia/2020Pipeline')

####

wild <- read_csv("./Inputs/NWDPdata.csv")

wild %>% ggplot(aes(x = ph, y = case)) + 
  geom_smooth(method = 'loess', color = 'black') + 
  xlab('Soil pH') + ylab('Density of positive cases (Loess smooth)') + 
  ggtitle('(A) Wildlife cases') +
  theme_bw() -> g1; g1

human <- read_csv("./Inputs/Humandata.csv")

human %>% ggplot(aes(x = ph, y = case)) + 
  geom_smooth(method = 'loess', color = 'black') + 
  xlab('Soil pH') + ylab('Density of positive cases (Loess smooth)') + 
  ggtitle('(B) Human cases') +
  theme_bw() -> g2; g2

library(patchwork)

g1 + g2


###########

summary(readRDS("./Wild-Alt2/modelW.RDS"))

summary(readRDS("./Wild-Alt3/modelW.RDS"))