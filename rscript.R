library("RSQLite")
#library("GGally")
#library(class)
library(randomForest)
con = dbConnect(drv="SQLite",dbname="/home/odroid/tinkering/historic.db")
alltables = dbListTables(con)
alltables
p1 = dbGetQuery( con,'SELECT time(date) as tod,date,atemp,stemp,moist,rad,lwater,water FROM messwerte WHERE water == 0 OR water == 1;' )
p1$date <- as.POSIXct(p1$date,tz="GMT")
atp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(atemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(stemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT count(*) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == 1",sep=""))$ret}))
p1
data <- cbind(p1,atp24,stp24,w24)
data$water <- as.factor(data$water)
summary(data)
summary(data[3:11][-6])

data <- data[complete.cases(data),]
smp_size <- floor(0.75 * nrow(data))
set.seed(123)
train_ind <- sample(seq_len(nrow(data)), size = smp_size)
train <- data[train_ind, ]
test <- data[-train_ind, ][-8]
ctest <- data[-train_ind, ][11][,1]

train$w24 <- as.factor(train$w24)

fit <- randomForest(w24 ~ moist + rad + lwater + atp24 + stp24, data=train)

importance(fit)
table(ctest,predict(fit,test))

p2 = dbGetQuery( con,'SELECT * FROM messwerte WHERE water == -1 ORDER BY date DESC LIMIT 1;')
p2$date <- as.POSIXct(p2$date,tz="GMT")
atp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(atemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
stp24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(stemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret}))
w24 <- as.numeric(apply(p2,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT count(*) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == 1",sep=""))$ret}))
curr <- cbind(p2,atp24,stp24,w24)

pre <- predict(fit,p2)

print(paste("decicion: ",pre))
print(paste("real: ",curr$w24))

#knn(train,test,cf,k=3)
#table(cftest,knn(train,test,cf,k=3))

#pdf()
#ggpairs(data[3:11])
#dev.off()

# SELECT avg(stemp) FROM messwerte WHERE date > datetime('now','-24 hour') AND water == -1;
# SELECT time(date) as tod,date,atemp,stemp,moist,rad,lwater,water FROM messwerte WHERE water == 0 OR water == 1;

#apply(p1,MARGIN=1,function(x){dbGetQuery(con,paste("SELECT avg(stemp) as ret FROM messwerte WHERE date > datetime('",x['date'],"','-24 hour') AND date < datetime('",x['date'],"') AND water == -1",sep=""))$ret})
