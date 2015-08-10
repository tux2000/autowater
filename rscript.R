library("RSQLite")
#library("GGally")
#library(class)
library(randomForest)
con = dbConnect(drv="SQLite",dbname="/home/odroid/tinkering/historic.db")

load(file="/home/odroid/tinkering/fit.RData")
importance(fit)

p2 = dbGetQuery( con,'SELECT * FROM messwerte WHERE water == -1 ORDER BY date DESC LIMIT 1;')
p2$date <- as.POSIXct(p2$date,tz="GMT")
atp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(atemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(stemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT count(*) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND (water == 1 or water == 2)",sep=""))$ret}))
curr <- cbind(p2,atp24,stp24,w24)

pre <- predict(fit,p2)

print(paste("decicion: ",pre))
print(paste("real: ",curr$w24))


