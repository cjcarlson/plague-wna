

setwd('/nfs/ccarlson-data/yersinia')

library(tidyverse)
library(embarcadero)

####

modelH <- readRDS('./2020Pipeline/Outputs/modelH.RDS')

partialsH <- partial(modelH, smooth=5, equal=TRUE, trace=FALSE, 
                    panels = TRUE)

modelW <- readRDS('./2020Pipeline/Outputs/modelW.RDS')

partialsW <- partial(modelW, smooth=5, equal=TRUE, trace=FALSE, 
                    panels = TRUE)

####

