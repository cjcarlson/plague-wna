

setwd('/nfs/ccarlson-data/yersinia')

library(tidyverse)
library(embarcadero)

####

wild <- read.csv('./2020Pipeline/Inputs/NWDPdata.csv')
wild$ppt <- log(wild$ppt)
wild <- na.omit(wild)

head(wild)

modelW <- readRDS('./2020Pipeline/Outputs/modelW.RDS')

modelW.ri <- rbart_vi(as.formula(paste(paste('case',paste(attr(modelW$fit$data@x, "term.labels"), 
                                             collapse=' + '), sep = ' ~ '), 
                                             'yr', sep=' - ')),
                      data = wild,
                      group.by = wild[,'yr'],
                      n.chains = 1,
                      k = modelW$fit$model@node.prior@k,
                      power = modelW$fit$model@tree.prior@power,
                      base = modelW$fit$model@tree.prior@base,
                      keepTrees = TRUE)

invisible(modelW.ri$fit[[1]]$state)

plot.ri(modelW.ri)
ggsave('./2020Pipeline/Outputs/modelWri.pdf', width = 6, height = 6)

test2 <- lapply(c(1:68),function(i) { 
  x <- stackmaker[[i]]
  x$ppt <- log(x$ppt)
  names(x) <- c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                'tmin','tmean','tmax','ppt','ppt.n','tmp.n')
  print(i)
  predict(modelW.ri, stack(x[[attr(modelW.ri$fit[[1]]$data@x, "term.labels")]]), splitby=20,
          ri.data=(i+1949), 
          ri.name='yr',
          ri.pred=FALSE)
})

yearlys.W.ri <- stack(test2)
meanW.ri <- mean(yearlys.W.ri[[1:68]])

time <- 1:nlayers(yearlys.W.ri) 
fun=function(x) { if (is.na(x[1])){ NA } else { m = lm(x ~ time); summary(m)$coefficients[2] }}
risk.slope.W.ri=calc(yearlys.W.ri, fun)
plot(risk.slope.W.ri)

setwd('./2020Pipeline/Outputs')
saveRDS(modelW.ri, 'modelWri.RDS')
saveRDS(yearlys.W.ri, 'yearlysWri.RDS')
