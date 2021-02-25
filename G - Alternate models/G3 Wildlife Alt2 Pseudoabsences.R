
setwd('/nfs/ccarlson-data/yersinia')

library(tidyverse)
library(embarcadero)

#stackmaker <- readRDS('./2020Pipeline/Inputs/stackmaker.RDS')

########

wild <- read.csv('./2020Pipeline/Inputs/NWDPpseudo.csv')
wild$ppt <- log(wild$ppt)
wild <- na.omit(wild)

ggplot(wild, aes(x=ph, y=case)) + geom_point() + geom_smooth()

## run model 

modelW <- bart.step(wild[,c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                            'tmin','tmean','tmax','ppt','ppt.n','tmp.n')],wild[,'case'],
                    full = FALSE,
                    iter.step = 200)
modelW <- retune(modelW)
invisible(modelW$fit$state)

summary(modelW)

## do predictions

test <- lapply(stackmaker, function(x) {
  x$ppt <- log(x$ppt)
  names(x) <- c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                'tmin','tmean','tmax','ppt','ppt.n','tmp.n')
  print('another one done')
  predict(modelW, x, splitby=50)}) 

yearlys.W <- stack(test)

saveRDS(modelW, '/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt2/modelW.RDS')
saveRDS(yearlys.W, '/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt2/yearlysW.RDS')

# Partials

setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Wild-Alt2/')

for (name in attr(modelW$fit$data@x, "term.labels")) {
  partial(modelW, x.vars=name, smooth=5, equal=TRUE, trace=FALSE)
  ggsave(paste(name, 'W.pdf', sep=''), width = 6, height = 6)
}

## look at some trends

meanW <- mean(yearlys.W) 

time <- 1:nlayers(yearlys.W) 

fun = function(x) { if (is.na(x[1])){ NA } else 
                  { m = lm(x ~ time); summary(m)$coefficients[2] }}
risk.slope.W=calc(yearlys.W, fun)
plot(risk.slope.W)

