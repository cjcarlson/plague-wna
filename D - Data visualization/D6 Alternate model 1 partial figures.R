

setwd('/nfs/ccarlson-data/yersinia')

library(tidyverse)
library(embarcadero)

###

modelH <- readRDS('./2020Pipeline/Human-Alt1/modelH.RDS')

partialsH <- partial(modelH, smooth=5, equal=TRUE, trace=FALSE, 
                     panels = TRUE)

ggsave('./2020Pipeline/Human-Alt1/Human-Alt1 Partials.pdf', width = 17, height = 17)

modelW <- readRDS('./2020Pipeline/Wild-Alt1/modelW.RDS')

partialsW <- partial(modelW, smooth=5, equal=TRUE, trace=FALSE, 
                     panels = TRUE)

ggsave('./2020Pipeline/Wild-Alt1/Wild-Alt1 Partials.pdf', width = 17, height = 17)

####