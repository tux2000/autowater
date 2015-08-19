library("RSQLite")
#library("GGally")
#library(class)
library(randomForest)
library(nnet)
con = dbConnect(drv="SQLite",dbname="/home/odroid/tinkering/historic.db")

load(file="/home/odroid/tinkering/fit.RData")
importance(fit)

p2 = dbGetQuery( con,'SELECT strftime("%H", date)+strftime("%M", date)/60.0 as tod,date,atemp,stemp,moist,rad,lwater,water FROM messwerte WHERE water == -1 ORDER BY date DESC LIMIT 1;')
p2$date <- as.POSIXct(p2$date,tz="GMT")
atp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(atemp*(1-(julianday('",x['date'],"')-julianday(date))))/sum(1-(julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
atp25 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(atemp*((julianday('",x['date'],"')-julianday(date))))/sum((julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum(stemp*(1-(julianday('",x['date'],"')-julianday(date))))/sum(1-(julianday('",x['date'],"')-julianday(date))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT sum((1-(julianday(datetime('",x['date'],"'))-julianday(date)))) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND (water == 1 or water == 2)",sep=""))$ret}))
curr <- cbind(p2,atp24,stp24,w24,atp25)

pre <- predict(fit,p2)
prenn <- predict(neural,p2)

print(paste("decicion: ",pre))
print(paste("neural: ",prenn))
print(paste("real: ",curr$w24))


