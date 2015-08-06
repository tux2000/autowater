library("RSQLite")
library(randomForest)
con = dbConnect(drv="SQLite",dbname="/home/odroid/tinkering/historic.db")
p1 = dbGetQuery( con,'SELECT time(date) as tod,date,atemp,stemp,moist,rad,lwater,water FROM messwerte WHERE date < datetime("now","-24 hour");' )
p1$date <- as.POSIXct(p1$date,tz="GMT")
atp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(atemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(stemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT count(*) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == 1",sep=""))$ret}))
data <- cbind(p1,atp24,stp24,w24)
data$water <- as.factor(data$water)

data <- data[complete.cases(data),]
smp_size <- floor(0.95 * nrow(data))
set.seed(123)
train_ind <- sample(seq_len(nrow(data)), size = smp_size)
train <- data[train_ind, ]
test <- data[-train_ind, ][-8]
ctest <- data[-train_ind, ][11][,1]

#train$w24 <- as.factor(train$w24)

fit <- randomForest(w24 ~ atemp + stemp + moist + rad  + atp24 + stp24, data=train)

importance(fit)
table(ctest,predict(fit,test))

save(fit,file="/home/odroid/tinkering/fit.RData")