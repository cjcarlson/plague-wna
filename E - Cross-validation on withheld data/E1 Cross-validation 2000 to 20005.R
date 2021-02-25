
library(embarcadero)

wild <- read.csv('/nfs/ccarlson-data/yersinia/2020Pipeline/Inputs/NWDPdata.csv')
human <- read.csv('/nfs/ccarlson-data/yersinia/2020Pipeline/Inputs/Humandata.csv')

modelW <- readRDS('/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/modelW.RDS')

wild.cut <- (wild %>% filter(!(yr %in% c(2000:2005))))
wild.test <- (wild %>% filter(yr %in% c(2000:2005)))

modelW.cut <- bart2(as.formula(paste(paste('case',paste(attr(modelW$fit$data@x, "term.labels"), 
                                                          collapse=' + '), sep = ' ~ '), 
                                       'yr', sep=' - ')),
                   data = wild.cut,
                   k = modelW$fit$model@node.prior@k,
                   power = modelW$fit$model@tree.prior@power,
                   base = modelW$fit$model@tree.prior@base,
                   keepTrees = TRUE)

pred.vector <- colMeans(pnorm(dbarts:::predict.bart(modelW.cut, wild.test[, attr(modelW.cut$fit@.xData$data@x, "term.labels")])))
true.vector <- wild.test$case
pred <- prediction(pred.vector, true.vector)
performance(na.omit(pred), "auc")@y.values

########

modelH <- readRDS('/nfs/ccarlson-data/yersinia/2020Pipeline/Outputs/modelH.RDS')

human.cut <- (human %>% filter(!(yr %in% c(2000:2005))))
human.test <- (human %>% filter(yr %in% c(2000:2005)))

modelH.cut <- bart2(as.formula(paste(paste('case',paste(attr(modelH$fit$data@x, "term.labels"), 
                                                        collapse=' + '), sep = ' ~ '), 
                                     'yr', sep=' - ')),
                    data = human.cut,
                    k = modelH$fit$model@node.prior@k,
                    power = modelH$fit$model@tree.prior@power,
                    base = modelH$fit$model@tree.prior@base,
                    keepTrees = TRUE)

pred.vector <- colMeans(pnorm(dbarts:::predict.bart(modelH.cut, human.test[, attr(modelH.cut$fit@.xData$data@x, "term.labels")])))
true.vector <- human.test$case
pred <- prediction(pred.vector, true.vector)
performance(na.omit(pred), "auc")@y.values
