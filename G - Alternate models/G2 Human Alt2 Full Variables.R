
setwd('/nfs/ccarlson-data/yersinia')

########

human <- read.csv('./2020Pipeline/Inputs/Humandata.csv')
human$ppt <- log(human$ppt)
human <- na.omit(human)

ggplot(human, aes(x=ph, y=case)) + geom_point() + geom_smooth()

## run model 

modelH <- bart(x.train = human[,c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                             'tmin','tmean','tmax','ppt','ppt.n','tmp.n')],
               y.train = human[,'case'],
               keeptrees = TRUE)

modelH <- retune(modelH)
invisible(modelH$fit$state)

summary(modelH)

## do predictions

test <- lapply(stackmaker, function(x) {
  x$ppt <- log(x$ppt)
  names(x) <- c('rodent','cec','ph','sand','clay','orgc','Fe','Ca','Na','elev',
                'tmin','tmean','tmax','ppt','ppt.n','tmp.n')
  print('another one done')
  predict(modelH, x, splitby=50)}) 

yearlys.H <- stack(test)

saveRDS(modelH, '/nfs/ccarlson-data/yersinia/2020Pipeline/Human-Alt1/modelH.RDS')
saveRDS(yearlys.H, '/nfs/ccarlson-data/yersinia/2020Pipeline/Human-Alt1/yearlysH.RDS')

# Partials

setwd('/nfs/ccarlson-data/yersinia/2020Pipeline/Human-Alt1/')

for (name in attr(modelH$fit$data@x, "term.labels")) {
  partial(modelH, x.vars=name, smooth=5, equal=TRUE, trace=FALSE)
  ggsave(paste(name, 'H.pdf', sep=''), width = 6, height = 6)
}

## look at some trends

meanH <- mean(yearlys.H) 

time <- 1:nlayers(yearlys.H) 

fun = function(x) { if (is.na(x[1])){ NA } else 
                  { m = lm(x ~ time); summary(m)$coefficients[2] }}
risk.slope.H=calc(yearlys.H, fun)
plot(risk.slope.H)
