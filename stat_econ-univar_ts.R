rm(list = ls())
################################################################################
##Libraries
################################################################################
library(forecast)
library(tseries)
library(tsoutliers)
library(urca) #unit root
source('~/Desktop/stat. eco./R-20200124/TSA-Predict-Functions.R', chdir = TRUE)
source('~/Desktop/stat. eco./R-20200124/CalendarEffects-Functions.R', chdir = TRUE)

################################################################################
## Read data
################################################################################

file.data <- "~/Desktop/STATEC relazione/dati ts-eco copia.csv"
data <- read.table(file = file.data, header=TRUE, sep = ";", check.names = FALSE, comment.char = "", na.strings = ".", dec=',')
data1=data[145:nrow(data),]
#### ts() object;
start1 <- as.numeric( c( substr(data$time[1], 1, 4), substr(data$time[1], 5, 6) ) )
start2=as.numeric( c( substr(data$time[145], 1, 4), substr(data$time[145], 5, 6) ) )
BC <- ts(data = data$BC, start = start1, frequency=12)
BC_2018=ts(data = data1$BC, start = start2, frequency=12)
data$time<- as.Date(x = as.character(data$time), format = "%Y%m%d")
#cal=.calendarEffects(data$time)
#cal <- cal[, c("Mon", "Tue", "Wed", "Thu", "Fri")]


################################################################################
## Preliminary analysis 
################################################################################

#### Ts plot, acf, pacf of the original series
par(mfrow = c(3,1))
plot(BC, main='bilancia commerciale (in miliardi di €)')
Acf(x = BC, type = "correlation", lag.max = 50) 
Acf(x = BC, type = "partial", lag.max = 50)


#DGP: RW + drift
df <- ur.df(y = BC, type = "trend", lags = 12, selectlags = "AIC")
summary(df)

#Value of test-statistic is: -2.9758 2.9968 4.4304 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau3 -3.99 -3.43 -3.13 accetto
#phi2  6.22  4.75  4.07 
#phi3  8.43  6.49  5.47 accetto
#goto 2 
#phi2 accetto goto DGP: RW
df <- ur.df(y = BC, type = "drift", lags = 12, selectlags = "AIC")
summary(df)

#Value of test-statistic is: -2.9268 4.3479 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau2 -3.46 -2.88 -2.57 accetto
#phi1  6.52  4.63  3.81 accetto
#####comment: UR

kpss.tau.1 <- ur.kpss(y = BC, type = "tau", lags = "long")
print( kpss.tau.1@teststat )
print( kpss.tau.1@cval )
#[1] 0.0734649
#                10pct  5pct 2.5pct  1pct
#critical values 0.119 0.146  0.176 0.216


kpss.mu.1 <- ur.kpss(y = BC, type = "mu", lags = "long")
print( kpss.mu.1@teststat )
print( kpss.mu.1@cval )
#[1] 0.1591109
#                10pct  5pct 2.5pct  1pct
#critical values 0.347 0.463  0.574 0.739
#i dati sono stabili



#Ts plot, acf, pacf of the diff(1) series
#par(mfrow=c(3,1))
#d1_BC <- diff(BC,1)
#plot(d1_BC, type='l')
#Acf(x = d1_BC, type = "correlation", lag.max = 50) 
#Acf(x = d1_BC, type = "partial", lag.max = 50)

#Ts plot, acf, pacf of the diff(12) series
d12_BC <-  diff(BC, 12) 
plot(d12_BC, type='l',xlab='tempo',ylab='', main='Andamento della bilancia commerciale')
Acf(x = d12_BC, type = "correlation", lag.max = 50, main='Bilancia commerciale') 
Acf(x = d12_BC, type = "partial", lag.max = 50, main='Bilancia commerciale')


#DGP: RW + drift
df <- ur.df(y = d12_BC, type = "trend", lags = 12, selectlags = "AIC")
summary(df)

#Value of test-statistic is: -3.5866 4.3027 6.4513 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau3 -3.99 -3.43 -3.13
#phi2  6.22  4.75  4.07
#phi3  8.43  6.49  5.47

df <- ur.df(y = d12_BC, type = "drift", lags = 12, selectlags = "AIC")
summary(df)
#Value of test-statistic is: -3.6057 6.5034 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau2 -3.46 -2.88 -2.57
#phi1  6.52  4.63  3.81

kpss.tau.2 <- ur.kpss(y = d12_BC, type = "tau", lags = "long")
cat("\n-----\nTest1: KPSS with trend\n")
print( kpss.tau.2@teststat )
print( kpss.tau.2@cval )
 

kpss.mu.2 <- ur.kpss(y = d12_BC, type = "mu", lags = "long")
cat("\n-----\nTest1: KPSS with trend\n")
print( kpss.mu.2@teststat )
print( kpss.mu.2@cval )


#############################################################################
##ARIMA modeling
#############################################################################

#i dati sono stabili (il test kpss), quindi proviamo il modello con d=D=0
#ARIMA(1,0,3)X(0,0,3)[12]  AIC=26.95    AICc=27.87    BIC=51.9
#ARIMA(1,0,2)X(0,0,3)[12]  AIC=27.38    AICc=28.08    BIC=49.2
#ARIMA(1,0,1)X(0,0,3)[12]  AIC=25.43    AICc=25.95    BIC=44.13
#ARIMA(1,0,1)X(1,0,0)[12]  AIC=4.62     AICc=4.87     BIC=17.1
#ARIMA(1,0,1)X(2,0,0)[12]  AIC=-15.16   AICc=-14.79   BIC=0.43 OK

# il modello da auto.arima(BC)
#ARIMA(3,0,0)X(0,1,1)[12]  AIC=-53.75   AICc=-53.34   BIC=-38.53 OK

fit1 <- Arima(y = BC, order = c(1,0,1),
  seasonal = list(order = c(2,0,0), period = 12),
  fixed = NULL, method = "CSS-ML",  include.constant = FALSE)
print(summary(fit1))

fit2 <- Arima(y = BC, order = c(3,0,0),
  seasonal = list(order = c(0,1,1), period = 12),
  fixed = NULL, method = "CSS-ML",  include.constant = FALSE)
print(summary(fit2))


#### Analysis of outliers: ARIMA

## Extract settings
include.constant1 <- any( names(fit1$coef) %in% c("intercept", "drift") )
include.constant2 <- any( names(fit2$coef) %in% c("intercept", "drift") )
order1    <- c(1,0,1)
order2	  <- c(3,0,0)
seasonal1 <- list(order = c(2,0,0), period = 12)
seasonal2 <- list(order = c(0,1,1), period = 12)

## Fit
fit1.o <- tso(y = BC, xreg = NULL, 
  types = c("AO", "LS", "TC"), delta = 0.7, cval = 4, 
  maxit = 10, maxit.iloop = 100, maxit.oloop = 10, 
  tsmethod = "arima", 
  args.tsmethod = list( order = order1,  seasonal = seasonal1) )
  
fit2.o <- tso(y = BC, xreg = NULL, 
  types = c("AO", "LS", "TC"), delta = 0.7, cval = 4, 
  maxit = 10, maxit.iloop = 100, maxit.oloop = 10, 
  tsmethod = "arima", 
  args.tsmethod = list( order = order2,  seasonal = seasonal2) )

# abbiamo provato i due modelli con il codice di outliers e non hanno outliers


#############################################################
##Diagnostic
#############################################################

#### Useful quantities 
npar1  <- NROW(fit1$coef) 
npar2 = NROW(fit2$coef)
lag2   <- npar2 + c(1, 2, 5, 10, 15, 20)
lag1   <- npar1 + c(1, 2, 5, 10, 15, 20)

#### Select the model

res2 <- residuals(fit2)
res1 <- residuals(fit1)

resst1 <- ( res1 - mean(res1) ) / sqrt(fit1$sigma2) #residui standardizzati
resst2 <- ( res2 - mean(res2) ) / sqrt(fit2$sigma2)

#### Ts plot, acf, pacf, Ljung-Box of residuals
par(mfrow = c(1,2))
main1 <- "residui - ARIMA(1,0,1)(2,0,0)[12]"
main2 <- 'residui - ARIMA(3,0,0)(0,1,1)[12]'
x1 <- res1
x2=res2
plot(x1, type = "l", main = main1)
plot(x2, type='l', main=main2)

par(mfrow=c(2,2))
Acf(x = x1, type = "correlation", lag.max=50, main=main1)
Acf(x = x1, type = "partial", lag.max=50, main=main1)
Acf(x = x2, type = "correlation", lag.max=50, main=main2)

Acf(x = x2, type = "partial", lag.max=50, main=main2)
print( mapply(FUN = Box.test, lag = lag1, 
  MoreArgs = list(x = x1, type = "Ljung-Box", fitdf = npar1)) ) #LB test
print( mapply(FUN = Box.test, lag = lag2, 
  MoreArgs = list(x = x2, type = "Ljung-Box", fitdf = npar2)) )

### Ts plot, acf, pacf, Ljung-Box of residuals^2
#ARIMA(1,0,1)(2,0,0)12
par(mfrow = c(2,2))
main1 <- "residui^2 - ARIMA(1,0,1)(2,0,0)[12]"
x1 <- res1^2
#plot(x1, type = "l", main = main)
Acf(x = x1, type = "correlation", lag.max=50,main=main1)
Acf(x = x1, type = "partial", lag.max=50, main=main1)

print( mapply(FUN = Box.test, lag = lag1, 
  MoreArgs = list(x = x1, type = "Ljung-Box", fitdf = npar1)) ) #LB test
  
#ARIMA(3,0,0)(0,1,1)12
main2 <- "residui^2 - ARIMA(3,0,0)(0,1,1)[12]"
x2 <- res2^2
#plot(x2, type = "l", main = main)
Acf(x = x2, type = "correlation", lag.max=50,main=main2)
Acf(x = x2, type = "partial", lag.max=50, main=main2)

print( mapply(FUN = Box.test, lag = lag2, 
  MoreArgs = list(x = x2, type = "Ljung-Box", fitdf = npar2)) )
  

### Ts plot, acf, pacf, Ljung-Box of |residuals|
#ARIMA(1,0,1)(2,0,0)12
par(mfrow = c(2,2))
main1 <- "|residui| - ARIMA(1,0,1)(2,0,0)[12]"
x1 <- abs(res1)
#plot(x1, type = "l", main = main)
Acf(x = x1, type = "correlation", lag.max=50,main=main1)
Acf(x = x1, type = "partial", lag.max=50, main=main1)

print( mapply(FUN = Box.test, lag = lag1, 
  MoreArgs = list(x = x1, type = "Ljung-Box", fitdf = npar1)) ) #LB test
#ARIMA(3,0,0)(0,1,1)12
main2 <- "|residui| - ARIMA(3,0,0)(0,1,1)[12]"
x2 <- abs(res2)
#plot(x2, type = "l", main = main)
Acf(x = x2, type = "correlation", lag.max=50,main=main2)
Acf(x = x2, type = "partial", lag.max=50, main=main2)

print( mapply(FUN = Box.test, lag = lag2, 
  MoreArgs = list(x = x2, type = "Ljung-Box", fitdf = npar2)) )
  

#### Unconditional distribution of residuals
#ARIMA(1,0,1)(2,0,0)12
par(mfrow = c(1,2))
hist(x = resst1, main = "residui - ARIMA(1,0,1)(2,0,0)[12]", breaks=25, freq=FALSE, xlab='')
x1 <- seq(from = min(resst1), to = max(resst1)+1, length.out = 100) 
lines(x = x1, y = dnorm(x = x1, mean = 0, sd = 1), col = "red")
qqnorm(y = resst1, main = "Normal Q-Q Plot - ARIMA(1,0,1)(2,0,0)[12]", xlab = "Theoretical Quantiles", ylab = "Sample Quantiles", plot.it = TRUE)
abline(a = 0, b = 1)

print( jarque.bera.test(x = res1) )

#ARIMA(3,0,0)(0,1,1)12
par(mfrow = c(1,2))
hist(x = resst2, main = "residui - ARIMA(3,0,0)(0,1,1)[12]", breaks=25, freq=FALSE, xlab='')
x2 <- seq(from = min(resst2), to = max(resst2)+1, length.out = 100) 
lines(x = x2, y = dnorm(x = x2, mean = 0, sd = 1), col = "red")
qqnorm(y = resst2, main = "Normal Q-Q Plot - ARIMA(3,0,0)(0,1,1)[12]", xlab = "Theoretical Quantiles", ylab = "Sample Quantiles", plot.it = TRUE)
abline(a = 0, b = 1)

print( jarque.bera.test(x = res2) )


################################################################################
## Predictions
################################################################################


################################
## Ex-ante (genuine) forecasts: from 1 to H steps ahead
################################

## Settings
H <- 12
par(mfrow = c(1,2))
pred1 <- predict(object = fit1, n.ahead = H, newreg = NULL, se.fit = TRUE)
U <- pred1$pred + 2*pred1$se
L <- pred1$pred - 2*pred1$se
ts.plot(BC_2018,pred1$pred,U,L,col=c(1,2,4,4),lty=c(1,1,2,2), main='previsione ex-ante - ARIMA(1,0,1)(2,0,0)[12]', ylab='Bilancia Commerciale')

pred2 <- predict(object = fit2, n.ahead = H, newreg = NULL, se.fit = TRUE)
U <- pred2$pred + 2*pred2$se
L <- pred2$pred - 2*pred2$se
ts.plot(BC_2018,pred2$pred,U,L,col=c(1,2,4,4),lty=c(1,1,2,2), main='previsione ex-ante - ARIMA(3,0,0)(0,1,1)[12]', ylab='Bilancia Commerciale')

################################
## Ex-post forecasts: all made 1-step ahead
################################

##ARIMA(1,0,1)(2,0,0)[12]
#### Extracts last year
## J months ago
J <- 12
## t1 = t corresponding to J months ago
t1 <- NROW(BC) - J

#### Sequence of 1-step ahead forecasts
H <- 1 
pred1.2 <- .predict(object = fit1, n.ahead = H, t = t1, y = BC, fixed.n.ahead = TRUE)
##  Naive
predn.1.1 <- BC[(t1 - J + 1) : t1]
predn.1.2 <- BC[t1 : (NROW(BC)-1)]

#### Error Measures
pred1.mean <- pred1.2$pred[, "mean"]
em1.2  <- .ErrorMeasures(y = BC, fit = pred1.2$pred[,"mean"])
emn.1.1  <- .ErrorMeasures(y = BC, fit = predn.1.1)

ErrorMeas <- data.frame( model = c("Arima", "Naive"), h = 1, rbind( em1.2, emn.1.1, deparse.level = 0 ) ) 
print( ErrorMeas )

ind  <- (NROW(BC) - J + 1) : NROW(BC)
ind1 <- 1 : NROW(ind)
x1 <- .pred.bands(pred = pred1.2, alpha = 0.05)
par(mfrow = c(1,1))
time <- data$time[ind]
plot(x = time, y = BC[ind], xlab = "time", ylab = "index", 
  main = "Forecasts of the past 12 months", 
  ylim = range(x1$lower[ind1], x1$upper[ind1]))
lines(x = time, y = x1$mean[ind1],  col = "red")
lines(x = time, y = x1$lower[ind1], col = "red", lty = "dotted")
 lines(x = time, y = x1$upper[ind1], col = "red", lty = "dotted")
lines(x = time, y = predn.1.1[ind1],  col = "blue", lty = "solid")


##ARIMA(3,0,0)(0,1,1)[12]
#### Extracts last year
## J months ago
J <- 12
## t1 = t corresponding to J months ago
t1 <- NROW(BC) - J

#### Sequence of 1-step ahead forecasts
H <- 1 
pred2.2 <- .predict(object = fit2, n.ahead = H, t = t1, y = BC, fixed.n.ahead = TRUE)
##  Naive: Same month, previous year
predn.2.1 <- BC[(t1 - J + 1) : t1]
predn.2.2 <- BC[t1 : (NROW(BC)-1)]

#### Error Measures
pred2.mean <- pred2.2$pred[, "mean"]
em2.2  <- .ErrorMeasures(y = BC, fit = pred2.2$pred[,"mean"], naive = 12)
emn.2.1  <- .ErrorMeasures(y = BC, fit = predn.2.1, naive = 12)

ErrorMeas <- data.frame( model = c("Arima", "Naive"), h = 1, rbind( em2.2, emn.2.1, deparse.level = 0 ) ) 
print( ErrorMeas )

ind  <- (NROW(BC) - J + 1) : NROW(BC)
ind1 <- 1 : NROW(ind)
x2 <- .pred.bands(pred = pred2.2, alpha = 0.05)
par(mfrow = c(1,1))
time <- data$time[ind]
plot(x = time, y = BC[ind], xlab = "time", ylab = "index", 
  main = "Forecasts of the past 12 months", 
  ylim = range(x1$lower[ind1], x1$upper[ind1])) 
lines(x = time, y = x2$mean[ind1],  col = "red")
lines(x = time, y = x2$lower[ind1], col = "red", lty = "dotted")
 lines(x = time, y = x2$upper[ind1], col = "red", lty = "dotted")
lines(x = time, y = predn.2.1[ind1],  col = "blue", lty = "solid")

################################
## Ex-post forecasts:
################################

#### Sequence of h-step ahead (h = 1, ..., H) forecasts
##ARIMA(1,0,1)(2,0,0)[12]
H <- 12 
pred1.h <- .predict(object = fit1, n.ahead = H, t = t1, y = BC, fixed.n.ahead = FALSE)


ErrorMeas <- data.frame( model = c("Arima", "Naive"), h = 12, rbind( em1.2, emn.1.1, deparse.level = 0 ) ) 
print( ErrorMeas )



##ARIMA(3,0,0)(0,1,1)[12]
#### Extracts last year
H <- 12
pred2.h <- .predict(object = fit2, n.ahead = H, t = t1, y = BC, fixed.n.ahead = FALSE)

ErrorMeas <- data.frame( model = c("Arima", "Naive"), h = 12, rbind( em2.2, emn.2.1, deparse.level = 0 ) ) 
print( ErrorMeas )
par(mfrow = c(1,2))

##ARIMA(1,0,1)(2,0,0)[12]
ind  <- (NROW(BC) - J + 1) : NROW(BC)
ind1 <- 1 : NROW(ind)
x1 <- .pred.bands(pred = pred1.h, alpha = 0.05)
par(mfrow = c(1,1))
time <- data$time[ind]
plot(x = time, y = BC[ind], xlab = "time", ylab = "index", 
  main = "Forecasts of the past 12 months - ARIMA(1,0,1)(2,0,0)[12]", 
  ylim = range(x1$lower[ind1], x1$upper[ind1]))
lines(x = time, y = x1$mean[ind1],  col = "red")
lines(x = time, y = x1$lower[ind1], col = "red", lty = "dotted")
 lines(x = time, y = x1$upper[ind1], col = "red", lty = "dotted")
lines(x = time, y = predn.1.1[ind1],  col = "blue", lty = "solid")


##ARIMA(3,0,0)(0,1,1)[12]
ind  <- (NROW(BC) - J + 1) : NROW(BC)
ind1 <- 1 : NROW(ind)
x2 <- .pred.bands(pred = pred2.h, alpha = 0.05)
par(mfrow = c(1,1))
time <- data$time[ind]
plot(x = time, y = BC[ind], xlab = "time", ylab = "index", 
  main = "Forecasts of the past 12 months- ARIMA(3,0,0)(0,1,1)[12]", 
  ylim = range(x1$lower[ind1], x1$upper[ind1])) 
lines(x = time, y = x2$mean[ind1],  col = "red")
lines(x = time, y = x2$lower[ind1], col = "red", lty = "dotted")
 lines(x = time, y = x2$upper[ind1], col = "red", lty = "dotted")
lines(x = time, y = predn.2.1[ind1],  col = "blue", lty = "solid")
