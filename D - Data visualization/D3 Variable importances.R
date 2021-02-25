
setwd("C:/Users/cjcar/Dropbox/PlagueLake")

library(embarcadero)

modelH <- readRDS("modelH.RDS")
modelW <- readRDS("modelW.RDS")

varimp(modelH, plots = TRUE)
varimp(modelW, plots = TRUE)

summary(modelH)
summary(modelW)
