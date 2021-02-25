

setwd('/nfs/ccarlson-data/yersinia')

library(tidyverse)
library(embarcadero)

####

human <- read.csv('./2020Pipeline/Inputs/Humandata.csv')
human$ppt <- log(human$ppt)
human <- na.omit(human)

head(human)

modelH <- readRDS('./2020Pipeline/Outputs/modelH.RDS')

modelH.ri <- rbart_vi(as.formula(paste(paste('case',paste(attr(modelH$fit$data@x, "term.labels"), 
                                             collapse=' + '), sep = ' ~ '), 
                                             'yr', sep=' - ')),
                      data = human,
                      group.by = human[,'yr'],
                      n.chains = 1,
                      k = modelH$fit$model@node.prior@k,
                      power = modelH$fit$model@tree.prior@power,
                      base = modelH$fit$model@tree.prior@base,
                      keepTrees = TRUE)

invisible(modelH.ri$fit[[1]]$state)

plot.ri(modelH.ri)
ggsave('./2020Pipeline/Outputs/modelHri.pdf', width = 6, height = 6)

test2 <- lapply(c(1:68),function(i) { 
  x <- stackmaker[[i]]
  x$ppt <- log(x$ppt)
  names(x) <- c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                'tmin','tmean','tmax','ppt','ppt.n','tmp.n')
  print(i)
  predict(modelH.ri, stack(x[[attr(modelH.ri$fit[[1]]$data@x, "term.labels")]]), splitby=20,
          ri.data=(i+1949), 
          ri.name='yr',
          ri.pred=FALSE)
  })

yearlys.H.ri <- stack(test2)
meanH.ri <- mean(yearlys.H.ri[[1:68]])

time <- 1:nlayers(yearlys.H.ri) 
fun=function(x) { if (is.na(x[1])){ NA } else { m = lm(x ~ time); summary(m)$coefficients[2] }}
risk.slope.H.ri=calc(yearlys.H.ri, fun)
plot(risk.slope.H.ri)

setwd('./2020Pipeline/Outputs/')
saveRDS(modelH.ri, 'modelHri.RDS')
saveRDS(yearlys.H.ri, 'yearlysHri.RDS')


