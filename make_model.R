library("RSQLite")
library(randomForest)
library(nnet)
con = dbConnect(drv="SQLite",dbname="/home/odroid/tinkering/historic.db")
p1 = dbGetQuery( con,'SELECT strftime("%H", date)+strftime("%M", date)/60.0 as tod,date,atemp,stemp,moist,rad,lwater,water FROM messwerte WHERE date < datetime("now","-24 hour");' )
p1$date <- as.POSIXct(p1$date,tz="GMT")
atp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(atemp*(1-(julianday('",x['date'],"')-julianday(date))))/sum(1-(julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
atp25 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(atemp*((julianday('",x['date'],"')-julianday(date))))/sum((julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(stemp*(1-(julianday('",x['date'],"')-julianday(date))))/sum(1-(julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum((1-(julianday(datetime('",x['date'],"'))-julianday(date)))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND (water == 1 OR water == 2)",sep=""))$ret}))
mw24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT count(*) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND (water == 1 OR water == 0);",sep=""))$ret}))
data <- cbind(p1,atp24,stp24,w24,mw24,atp25)
data <- data[which(data$mw24 > 0),]
data$water <- as.factor(data$water)

data <- data[complete.cases(data),]
smp_size <- floor(0.95 * nrow(data))
set.seed(123)
train_ind <- sample(seq_len(nrow(data)), size = smp_size)
train <- data[train_ind, ]
test <- data[-train_ind, ][-8]
ctest <- data[-train_ind, ][11][,1]

#train$w24 <- as.factor(train$w24)

fit <- randomForest(w24 ~ atemp + stemp + moist + rad  + atp24 + atp25 + stp24 + tod, data=train)
neural <- nnet(w24 ~ atemp + stemp + moist + rad  + atp24 + stp24 + tod, data=train,size=20,linout=T, maxit = 500)

importance(fit)
table(round(ctest),round(predict(fit,test)))
table(round(ctest),round(predict(neural, test )))

save(fit,neural,file="/home/odroid/tinkering/fit.RData")
