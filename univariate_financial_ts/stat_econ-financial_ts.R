## DATE: February 2020
rm(list = ls())

################################################################################
##Libraries and function
################################################################################

####
library(tseries)  
library(sandwich)
library(lmtest)
library(urca)     ## For unit root
library(rugarch)  ## For GARCH models
library(FinTS)    ## For ArchTest
library(car)
library(forecast) ## For dm.test
library(xts)      ## For time stamps
library(quantmod) ## For downloading data

source('~/Desktop/progetto sta eco/TSA-Predict-Functions.R', chdir = TRUE)

################################################################################
## Functions 
################################################################################

.dist <- 
function(fit, x, type)
{
  #### Values for the pdf
  dist <- fit@model$modeldesc$distribution
  x1 <- fit@fit$coef["lambda"]
  lambda <- ifelse(is.na(x1), -0.5, x1)
  x1 <- fit@fit$coef["skew"]
  skew <- ifelse(is.na(x1), 1, x1)
  x1 <- fit@fit$coef["shape"]
  shape <- ifelse(is.na(x1), 1, x1)
  #### Compute
  if (type == "d")
  {
    ddist(distribution = dist, y = x, mu = 0, sigma = 1, 
      lambda = lambda, skew = skew, shape = shape)
  }
  else if (type == "q")
  {
    qdist(distribution = dist, p = x, mu = 0, sigma = 1, 
      lambda = lambda, skew = skew, shape = shape)
  }
  else
  {
    stop("Argument type must be 'd' or 'q'")
  }
}
# ------------------------------------------------------------------------------


.hist <- 
function(x, xlim, n = 200, breaks = 100, main = "")
{
  #### Histogram
  hist(x = x, breaks = breaks, freq = FALSE, xlim = xlim, main = main)
  #### Plot of the pdf
  x1 <- seq(from = xlim[1], to = xlim[2], length.out = n)
  pdf1 <- dnorm(x = x1, mean = mean(x), sd = sd(x))
  lines(x = x1, y = pdf1, col = "red", lwd = 2) 
}
# ------------------------------------------------------------------------------


.hist.fit <- 
function(fit, xlim, ylim = NULL, n = 200, breaks = 100, plot.norm = FALSE,
  main = "")
{
  #### Settings
  col <- c("red", "blue")
  #### Histogram
  hist(x = fit@fit$z, breaks = breaks, freq = FALSE, xlim = xlim, xlab = "z",
    ylim = ylim, main = main)
  #### Plot of the selected pdf
  x1 <- seq(from = xlim[1], to = xlim[2], length.out = n)
  pdf1 <- .dist(fit = fit, x = x1, type = "d")
  lines(x = x1, y = pdf1, col = col[1], lwd = 2)
  #### Add the Normal pdf
  if (plot.norm[1] & fit@model$modeldesc$distribution != "norm")
  {
    pdf2 <- dnorm(x = x1)
    lines(x = x1, y = pdf2, col = col[2], lwd = 2)
    #### Add legend
    legend <- c(fit@model$modeldesc$distribution, "norm")
    legend(x = "topright", legend = legend, 
      fill = col, col = col, border = "black", bty = "o")
  }
}
# ------------------------------------------------------------------------------


.qqplot.fit <- 
function(fit)
{
  #### Compute
  zemp <- sort(fit@fit$z)
  ####
  n <- NROW(zemp)
  p <- seq(from = 1 / (n + 1), by = 1 / (n + 1), length.out = n)  
  zth  <- .dist(fit = fit, x = p, type = "q")
  #### Plot
  qqplot(x = zth, y = zemp, plot.it = TRUE, xlab = "Theoretical quantiles",
    ylab = "Empirical quantiles")
  abline(a = 0, b = 1, col = "red")
}
# ------------------------------------------------------------------------------
.fgarch.2.gjr <- 
function(fit)
{
  #### Extract
  vmodel <- fit@model$modeldesc$vmodel
  vsubmodel <- fit@model$modeldesc$vsubmodel
  
  ####
  if ( vmodel == "fGARCH" )
  {
    #### Extract
    est   <- fit@fit$coef
    vcov  <- fit@fit$cvar
    vcovR <- fit@fit$robust.cvar
    np <- NROW(est)
    #### Extract
    pattern <- "alpha"
    ind  <- which( substr(x = names(est), 1, nchar(pattern)) == pattern )
    alpha <- est[ind]
    inda <- ind
    pattern <- "eta1"
    ind  <- which( substr(x = names(est), 1, nchar(pattern)) == pattern )    
    eta1 <- est[ind]
    inde <- ind
    ####
    matcoef <- fit@fit$matcoef
    robust.matcoef <- fit@fit$robust.matcoef

    ####
    if (vsubmodel == "GJRGARCH")
    { 
      #### Extract
      alpha.s <- alpha * (1 - eta1)^2 
      gamma.s <- 4 * alpha * eta1
      ####
      D <- diag(np)
      D[cbind(inda, inda)] <- (1 - eta1)^2
      D[cbind(inda, inde)] <- -2 * alpha * (1 - eta1)
      D[cbind(inde, inda)] <- 4 * eta1
      D[cbind(inde, inde)] <- 4 * alpha
    }
    else if (vsubmodel == "TGARCH")
    {
      #### Extract
      alpha.s <- alpha * (1 - eta1) 
      gamma.s <- 2 * alpha * eta1
      ####
      D <- diag(np)
      D[cbind(inda, inda)] <- 1 - eta1
      D[cbind(inda, inde)] <- - alpha
      D[cbind(inde, inda)] <- 2 * eta1
      D[cbind(inde, inde)] <- 2 * alpha
    }
    
    ####
    est[inda] <- alpha.s
    est[inde] <- gamma.s
    vcov  <- tcrossprod(D %*% vcov, D) 
    vcovR <- tcrossprod(D %*% vcovR, D) 

    ####
    se  <- sqrt( abs( diag(vcov) ) )
    t   <- est / se
    pv  <- 2 * ( 1 - pnorm( abs(t) ) ) 
    x1 <- matcoef
    x1[, " Estimate"] <- est
    x1[, " Std. Error"] <- se
    x1[, " t value"] <- t
    x1[, "Pr(>|t|)"] <- pv
    matcoef <- x1
    ####
    se  <- sqrt( abs( diag(vcovR) ) )
    t  <- est / se
    pv <- 2 * ( 1 - pnorm( abs(t) ) ) 
    x1 <- robust.matcoef
    x1[, " Estimate"] <- est
    x1[, " Std. Error"] <- se
    x1[, " t value"] <- t
    x1[, "Pr(>|t|)"] <- pv
    robust.matcoef <- x1
  
    #### Rename eta1 -> gamma
    pattern <- "eta1"
    x1 <- names(est)
    ind <- substr(x = x1, 1, nchar(pattern)) == pattern
    x1[ind] <- paste0("gamma", 
      substr(x = x1[ind], start = nchar(pattern) + 1, stop = 1000))
    names(est) <- rownames(matcoef) <- rownames(robust.matcoef) <- x1
  }
  
  #### Answer
  list(coef = est, 
    se.coef = matcoef[, " Std. Error"], robust.se.coef = robust.matcoef[, " Std. Error"], 
    tval = matcoef[, " t value"], robust.tval = robust.matcoef[, " t value"], 
    matcoef = matcoef, robust.matcoef = robust.matcoef, 
    cvar = vcov, robust.cvar = vcovR) 
}
# ------------------------------------------------------------------------------

.DieboldMariano1=function(e1, e2, h, power, msg = "")
{
  #### Compute
  x1 <- dm.test(e1 = e1, e2 = e2, alternative='less', h = h, power = power)
  #### Print
  if ( msg != "" )
  {
    cat(msg,
      "Horiz:", x1$parameter["Forecast horizon"], 
      ", Loss fct pow:", x1$parameter["Loss function power"], 
      ", Stat (L1-L2):", x1$statistic, "\n")
  }
  #### Answer
  x1
}
# ------------------------------------------------------------------------------
.garmanklass <-
function(data, sd = TRUE)
{
  #### Auxiliary
  nobs  <- NROW(data)

  #### Intradaily
  ## Extract
  coef <- data$Adjusted / data$Close
  H1 <- log( data$High * coef )
  L1 <- log( data$Low * coef )
  O1 <- log( data$Open * coef )
  C1 <- log( data$Close * coef )
  u1 <- H1 - O1
  d1 <- L1 - O1
  c1 <- C1 - O1
  ## Values
  x <- 0.511 * (u1 - d1)^2 +
    (-0.019) * (c1 * (u1 + d1) - 2 * u1 * d1) +
    (-0.383) * c1^2
  
  #### Overnight adjustment
  retco <- c(NA, log( data$Open[-1] / data$Close[-nobs] ) )
  retoc <- log( data$Close / data$Open )
  x1 <- sum( retco^2, na.rm = TRUE); x2 <- sum( retoc^2, na.rm = TRUE )  
  f  <- x1 / (x1 + x2)
  f[f < 0.01] <- 0.01; f[f > 0.99] <- 0.99
  a <- 0.12
  x <- a * retco^2 / f + ( (1 - a) / (1 - f) ) * x
  
  #### Answer
  if ( sd ) { 1.034 * sqrt( x ) } else { x }
}
# ------------------------------------------------------------------------------

########
## Arguments:
## object:        an object created by ugarchfit()
## n.ahead:       number of steps ahead
## t:             time from which to start forecasts (it must be <= length(y))
## fixed.n.ahead: whether the number of steps ahead is retained fixed
## data:          Data used to compute predictions. 
##                Use this argument if we want to get forecasts beyond the 
##                estimation period (in this case it must be 
##                NROW(data) > NROW(object@model$modeldata$data)).  
##
########
.predict <- 
function(object, n.ahead, t, 
  data = NULL, fixed.n.ahead = TRUE, alpha = NULL)
{
  #### Extract
  y <- if (NROW(data) == 0)
  {
    xts(x = object@model$modeldata$data, 
      order.by = object@model$modeldata$index)
  }
  else
  {
    data
  }
  nobs <- NROW(y)
  tStart <- t
  alpha <- alpha[1]
  
  #### Check
  if ( n.ahead <= 0 )
  {
    stop("Argument 'n.ahead' must be a positive integer")
  } 
  if ( t > nobs )
  {
    stop("Argument 't' must be <= NROW(y)")
  }
  if ( NROW(alpha) > 0 && alpha >= 0.5 )
  {
    stop("Argument 'alpha' must be lower than 0.5")
  }

  #### Adjust
  n.ahead <- round(n.ahead[1])

  #### Manage the model to rebuild the specification
  spec <- getspec(object)
  setfixed(spec) <- as.list(coef(object))  
  
  #### n.ahead not fixed
  if (!fixed.n.ahead)
  {
    #### Forecast
    forc <- ugarchforecast(fitORspec = spec, n.ahead = n.ahead, 
      n.roll = 0, data = y, out.sample = nobs - t)
    #### Extract
    time1 <- tStart : (tStart + n.ahead - 1) 
    mu    <- forc@forecast$seriesFor
    sigma <- forc@forecast$sigmaFor
    if ( NROW(alpha) > 0 )
    {
      q1 <- quantile(forc, probs = alpha / 2)
      q2 <- quantile(forc, probs = 1 - alpha / 2)
    }
  }
  else
  {
    #### Forecast
    forc <- ugarchforecast(fitORspec = spec, n.ahead = n.ahead, 
      n.roll = nobs - t, data = y, out.sample = nobs - t)
    #### Extract
    time1 <- (tStart - 1 + n.ahead) : (nobs - 1 + n.ahead)
    mu    <- forc@forecast$seriesFor[n.ahead, ]
    sigma <- forc@forecast$sigmaFor[n.ahead, ]
    if ( NROW(alpha) > 0 )
    {
      q1 <- quantile(forc, probs = alpha / 2)[n.ahead, ]
      q2 <- quantile(forc, probs = 1 - alpha / 2)[n.ahead, ]
    }
  }

  #### Join
  pred1 <- cbind(t = time1, pred = as.numeric(mu), 
    se = as.numeric(sigma))
  if ( NROW(alpha) > 0 )
  {
    pred1 <- cbind(pred1, left = q1, right = q2)
  }
  
  #### Answer
  list( n.ahead = n.ahead, fixed.n.ahead = fixed.n.ahead, alpha = alpha, 
    pred = as.data.frame(pred1) )
}


################################################################################
## Read data
################################################################################

file.data <- '~/Desktop/STATEC relazione/ts-fin-BABA.csv'
data <- read.table(file = file.data, header=TRUE, sep = ",", check.names = FALSE, comment.char = "", na.strings = ".")

#### Add variables
data <- data.frame(data, 
  cc.ret = c(NA, diff(log(data$Close))), 
  gkVol = .garmanklass(data = data, sd = TRUE),
check.names = TRUE)

#### Extract period
ind <- as.Date(x = "2014-09-19") <= as.Date(x = data$Date)
data <- data[ind, , drop = FALSE]

#### Extract variables
#### Extract variables
time  <- as.Date(x = data$Date)
y    <- data$Close
ylog <- log(y)


################################################################################
## Analysis of prices
################################################################################

#### Auxiliary quantities
nobs <- NROW(y)

#### Plots
par(mfrow = c(2,2))
plot(x = time, y = y,  xlab = "", ylab = "", type = "l", main = "Prezzi di chiusura")
plot(x = time, y = ylog, xlab = "", ylab = "", type = "l", main = " Ln(prezzi di chiusura)")


#### Serial correlation
par(mfrow = c(2,1))
Acf(x = ylog, lag.max = 100, type = "correlation", main = "Price")
Acf(x = ylog, lag.max = 100, type = "partial", main = "Price")
## Apparent non-stationarity

######### ADF tests using the Di Fonzo-Lisi procedure
cat("\n-----------------------------------------------------------------
  Unit root analysis following the Di Fonzo-Lisi procedure\n")
#### (DGP:   RW + drift (+ other possible stationary terms); 
##    Model: AR(1) + Trend (+ other possible stationary terms))
df.1 <- ur.df(y = ylog, type = "trend", lags = 20, selectlags = "AIC")
print( summary(df.1) )
#Value of test-statistic is: -2.4006 2.2485 2.9235 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau3 -3.96 -3.41 -3.12 accetta
#phi2  6.09  4.68  4.03 accetta
#phi3  8.27  6.25  5.34 accetta
#### Commento: Accetta per tau3, accetta per Phi3 -> goto2
##   Accetta per Phi2. Secondo la procedura
##   (DGP:   RW (+ altri possibili termini stazionari); 
##   Model: AR(1) + constant (+ altri possibili termini stazionari))

#### (DGP:   RW (+ altri possibili termini stazionari); 
##    Model: AR(1) + constant (+ altri possibili termini stazionari))
df.2 <- ur.df(y = ylog, type = "drift", lags = 20, selectlags = "AIC")
cat("\n-----\nTest1: ADF with drift\n")
print( summary(df.2) )
#Value of test-statistic is: -1.0081 0.9561 
#Critical values for test statistics: 
#      1pct  5pct 10pct
#tau2 -3.43 -2.86 -2.57 accetta
#phi1  6.43  4.59  3.78 accetta
#### Commento: Accetta per tau2, Accetta per Phi1 -> Unit root
# i dati non sono stazionari

summary(ur.kpss(ylog, type = "tau", lags ="long",use.lag = NULL))
summary(ur.kpss(ylog, type = "mu", lags ="long",use.lag = NULL)) #  UR
# i dati non sono stazionari 

################################################################################
## Preliminary analyses of log-returns
################################################################################
## Rimuovi 1st obs perché manca
yret <- xts(x = 100 * data$cc.ret, order.by = time)[-1]

######## Preliminary analysis
cat("\n-----------------------------------------------------------------
  Preliminary analysis of log-returns\n")
#### Time series
par(mfrow = c(1,1))
plot(yret,  main = "Returns", xlab = "", ylab = "", type = "l")
####  Commenti:
## 1) I rendimenti giornalieri si spostano attorno a una media vicina allo zero in modo simile a un WN;
## 2) Ci sono periodi con diversa variabilità attorno alla media (a volte alto, a volte basso)

#### Serial correlation
par(mfrow = c(2,1))
Acf(x = yret, lag.max = 100, type = "correlation", main = "Returns")
Acf(x = yret, lag.max = 100, type = "partial", main = "Returns")
cat("\nLjung-Box statistics on log-returns\n")
print( mapply(FUN = Box.test, lag = c(2, 5, 10, 15, 20, 30, 50), 
  MoreArgs = list(x = yret, type = "Ljung-Box", fitdf = 0) ) )
 
#### Unconditional distribution
par(mfrow = c(1,2))
.hist(x = yret, xlim = c(-10, 10), n = 200, breaks = 200, main = "Returns")
qqnorm(y = (yret - mean(yret)) / sd(yret))
abline(a = 0, b = 1, col = "red")
cat("\nJarque-Bera statistics on log-returns")
print( jarque.bera.test(x = yret) )

################################################################################
## ARMA
################################################################################
cat("\n-----------------------------------------------------------------
  ARMA on log-returns\n")

spec0 <- arfimaspec(mean.model = list(armaOrder = c(1,1), 
  include.mean = TRUE, external.regressors = NULL), 
  distribution.model = "std") 
fit0 <- arfimafit(spec = spec0, data = yret, 
  solver = "solnp")
## Store the number of parameters
np0 <- NROW(fit0@fit$coef)
## Some statistics
cat( "\nInformation Criteria" )
print( infocriteria(fit0) )
print( infocriteria(fit0) )
cat("\nMatcoef\n")
print( fit0@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit0@fit$robust.matcoef )


#### ACF of residuals, abs residuals and squared residuals
res <- as.numeric( residuals(fit0) )
par(mfrow = c(3,1))
Acf(x = res, lag.max = 100, type = "correlation", main = "Returns")
Acf(x = abs(res), lag.max = 100, type = "correlation", main = "|res|")
Acf(x = res^2, lag.max = 100, type = "correlation", main = "expression(res^2)")

#### Commenti:
## 1) Ampia correlazione seriale di residui assoluti e quadrati;
## 2) i valori assoluti sono più correlati dei quadrati.
##Conclusione: i residui non sono WN. Poiché i residui sono simili al serie storiche originali, anche l'originale non è un WN.

#### Another diagnostic: the ARCH test
cat("\n-----------------------------------------------------------------
  ARCH based preliminary analyses\n")
cat("ARCH test on demeaned log-returns\n")

print( mapply(FUN = ArchTest, lags = c(4, 8, 12, 16), 
   MoreArgs = list(x = yret, demean = TRUE)) )
                                  

################################################################################
## ARCH/GARCH modeling
################################################################################
####
cat("\n-----------------------------------------------------------------
  GARCH on log-returns\n")

#### Simple GARCH
spec1 <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1), 
  submodel = NULL, external.regressors = NULL, variance.targeting = FALSE), 
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit1 <- ugarchfit(spec = spec1, data = yret, solver = "solnp")
## Store the number of parameters
np1 <- NROW(fit1@fit$coef)
## Some statistics
cat( "\nInformation Criteria" )
print( infocriteria(fit1) )
cat("\nMatcoef\n")
print( fit1@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit1@fit$robust.matcoef )

#### Diagnostics: Use standardized residuals
par(mfrow = c(3,1))
Acf(x = fit1@fit$z, lag.max = 100, type = "correlation", main = "z")

#non va bene: aggiungo un ARMA

#### ARMA+Simple GARCH
spec2 <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1), 
  submodel = NULL, external.regressors = NULL, variance.targeting = FALSE), 
  mean.model = list(armaOrder = c(1,0), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit2 <- ugarchfit(spec = spec2, data = yret, solver = "solnp")
## Store the number of parameters
np2 <- NROW(fit2@fit$coef)
## Some statistics
cat( "\nInformation Criteria AR(1) S GARCH" )
print( infocriteria(fit2) )
cat("\nMatcoef\n")
print( fit2@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit2@fit$robust.matcoef )


#### Diagnostics: Use standardized residuals
par(mfrow = c(3,1))
Acf(x = fit2@fit$z, lag.max = 100, type = "correlation", main = "z")
Acf(x = abs(fit2@fit$z), lag.max = 100, type = "correlation", main = "|z|")
Acf(x = fit2@fit$z^2, lag.max = 100, type = "correlation", main = expression(z^2))
cat("\nLjung-Box statistics on z residuals\n")
print( mapply(FUN = Box.test, lag = np2 + c(1, 2, 5, 10,15,20), 
  MoreArgs = list(x = fit2@fit$z, type = "Ljung-Box", fitdf = np2) ) )   
cat("\nLjung-Box statistics on |z residuals|\n")
print( mapply(FUN = Box.test, lag = np2 + c(1, 2, 5, 10,15,20), 
  MoreArgs = list(x = abs(fit2@fit$z), type = "Ljung-Box", fitdf = np2) ) )
cat("\nLjung-Box statistics on (z residuals)^2\n")
print( mapply(FUN = Box.test, lag = np2 + c(1, 2, 5, 10, 15, 20), 
  MoreArgs = list(x = fit2@fit$z^2, type = "Ljung-Box", fitdf = np2) ) )
  


###ARCH test
cat("\nARCH test on standardized residuals\n")
print( mapply(FUN = ArchTest, lags = c(4, 8, 12, 16), 
  MoreArgs = list(x = fit2@fit$z, demean = TRUE)) )
 #### Comment: all is fine
par(mfrow = c(1,2))
xlim <- c(-5, 5)
.hist.fit(fit = fit1, xlim = xlim, ylim = c(0,0.55), n = 200, breaks = 100, 
  plot.norm = TRUE, main = "")
.qqplot.fit(fit = fit2)

#### Stability check
cat("\nStability check (Nyblom test)\n")
print( nyblom(fit2) )

#### Leverage check
cat("\nSign bias test\n")
print( signbias(fit2) )

#OK
#CONFRONTO IL MODELLO CON GJR GARCH E T GARCH

#### This can be verified in an explicit modeling -> gjrGARCH in place of sGARCH
spec3 <- ugarchspec(variance.model = list(model = "gjrGARCH", garchOrder = c(1, 1), 
  submodel = NULL, external.regressors = NULL, variance.targeting = FALSE), 
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit3 <- ugarchfit(spec = spec3, data = yret, solver = "solnp")
np3=NROW(fit3@fit$coef)
## Some statistics
cat( "\nInformation Criteria" )
print( infocriteria(fit3) )
cat("\nMatcoef\n")
print( fit3@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit3@fit$robust.matcoef )

Acf(x = fit3@fit$z, lag.max = 100, type = "correlation", main = "z")

#### ARMA+GJR GARCH
spec4 <- ugarchspec(variance.model = list(model = "gjrGARCH", garchOrder = c(1,1), 
  submodel = NULL, external.regressors = NULL, variance.targeting = FALSE), 
  mean.model = list(armaOrder = c(0,1), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit4 <- ugarchfit(spec = spec4, data = yret, solver = "solnp")
## Store the number of parameters
np4 <- NROW(fit4@fit$coef)
## Some statistics
cat( "\nInformation Criteria MA(1) GJR GARCH" )
print( infocriteria(fit4) )
cat("\nMatcoef\n")
print( fit4@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit4@fit$robust.matcoef )


#### Diagnostics: Use standardized residuals
par(mfrow = c(3,1))
Acf(x = fit4@fit$z, lag.max = 100, type = "correlation", main = "z")
Acf(x = abs(fit4@fit$z), lag.max = 100, type = "correlation", main = "|z|")
Acf(x = fit4@fit$z^2, lag.max = 100, type = "correlation", main = expression(z^2))
cat("\nLjung-Box statistics on z residuals GJR\n")
print( mapply(FUN = Box.test, lag = np4 + c(1, 2, 5, 16, 26, 30), 
  MoreArgs = list(x = fit4@fit$z, type = "Ljung-Box", fitdf = np4) ) )
  #p.value   0.05890385       0.1518526        0.05856383       0.008813263      0.02946507       0.05573059   
cat("\nLjung-Box statistics on |z residuals|\n")
print( mapply(FUN = Box.test, lag = np4 + c(1, 2, 5, 15, 25, 30), 
  MoreArgs = list(x = abs(fit4@fit$z), type = "Ljung-Box", fitdf = np4) ) )
cat("\nLjung-Box statistics on (z residuals)^2\n")
print( mapply(FUN = Box.test, lag = np4 + c(1, 2, 5, 15, 25, 30), 
  MoreArgs = list(x = fit4@fit$z^2, type = "Ljung-Box", fitdf = np4) ) ) 


###ARCH test
#cat("\nARCH test on standardized residuals\n")
#print( mapply(FUN = ArchTest, lags = c(4, 8, 12, 16), 
#  MoreArgs = list(x = fit2@fit$z, demean = TRUE)) )
#par(mfrow = c(1,2))
#xlim <- c(-5, 5)
#.hist.fit(fit = fit2, xlim = xlim, ylim = c(0,0.55), n = 200, breaks = 100, 
#  plot.norm = TRUE, main = "")
#.qqplot.fit(fit = fit2)
#### Stability check
#cat("\nStability check (Nyblom test)\n")
#print( nyblom(fit2) )
#$IndividualStat
 #            [,1]
#mu     0.18154548
#omega  0.10503237
#alpha1 0.10486943
#beta1  0.09411971
#gamma1 0.18452082
#shape  0.40485094

#$JointStat
#[1] 1.488106

#$IndividualCritical
#  10%    5%    1% 
#0.353 0.470 0.748 

#$JointCritical
# 10%   5%   1% 
#1.49 1.68 2.12 
#stabili


#### TGARCH (using fGARCH) 
spec7 <- ugarchspec(variance.model = list(model = "fGARCH", garchOrder = c(1, 1), 
  submodel = "TGARCH", external.regressors = NULL, variance.targeting = FALSE),  
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit7 <- ugarchfit(spec = spec7, data = yret, solver = "solnp")
## Store the number of parameters
np7 <- NROW(fit7@fit$coef)


#### Use standardized residuals!
par(mfrow = c(3,1))
Acf(x = fit7@fit$z, lag.max = 100, type = "correlation", main = "z")
#aggiungo MA(1)

spec6 <- ugarchspec(variance.model = list(model = "fGARCH", garchOrder = c(1, 1), 
  submodel = "TGARCH", external.regressors = NULL, variance.targeting = FALSE),  
  mean.model = list(armaOrder = c(0,1), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit6 <- ugarchfit(spec = spec6, data = yret, solver = "solnp")
## Store the number of parameters
np6 <- NROW(fit6@fit$coef)
## Some statistics
cat( "\nInformation Criteria MAA(1) TGARCH" )
print( infocriteria(fit6) )
cat("\nMatcoef\n")
print( fit6@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit6@fit$robust.matcoef )


####  standardized residuals
par(mfrow = c(3,1))
Acf(x = fit6@fit$z, lag.max = 100, type = "correlation", main = "z")
Acf(x = fit6@fit$z, lag.max = 100, type = "partial", main = "z")
Acf(x = abs(fit6@fit$z), lag.max = 100, type = "correlation", main = "|z|")
Acf(x = fit6@fit$z^2, lag.max = 100, type = "correlation", main = expression(z^2))
cat("\nLjung-Box statistics on z residuals\n")
print( mapply(FUN = Box.test, lag = np6 + c(2, 5, 10, 15, 20, 30, 50), 
  MoreArgs = list(x = fit6@fit$z, type = "Ljung-Box", fitdf = np6) ) )  
cat("\nLjung-Box statistics on |z residuals|\n")
print( mapply(FUN = Box.test, lag = np6 + c(1, 2, 5, 10, 15, 20), 
  MoreArgs = list(x = abs(fit6@fit$z), type = "Ljung-Box", fitdf = np6) ) )
cat("\nLjung-Box statistics on (z residuals)^2\n")
print( mapply(FUN = Box.test, lag = np6 + c(1, 2, 5, 10, 15, 20), 
  MoreArgs = list(x = fit6@fit$z^2, type = "Ljung-Box", fitdf = np6) ) )
 ####
stop()
###ARCH test
cat("\nARCH test on standardized residuals\n")
print( mapply(FUN = ArchTest, lags = c(4, 8, 12, 16), 
  MoreArgs = list(x = fit2@fit$z, demean = TRUE)) )
  
###Distribuzione residui standardizzati
par(mfrow = c(1,2))
xlim <- c(-5, 5)
.hist.fit(fit = fit2, xlim = xlim, ylim = c(0,0.55), n = 200, breaks = 100, 
  plot.norm = TRUE, main = "residui")
.qqplot.fit(fit = fit2)

#### Leverage check
print( signbias(fit6) )


#### Compare the News Impact Curves (sGARCH vs gjrGARCH vs MA(1)-TGARCH)
ni2 <- newsimpact(z = NULL, fit2)
ni4 <- newsimpact(z = NULL, fit4)
ni6 <- newsimpact(z = NULL, fit6)
legend <- c("AR(1) - Simple-GARCH", "MA(1) - GJR-GARCH", "MA(1) - T-GARCH")
col  <- c("black", "red", "blue")
ylim <- range( ni2$zy, ni4$zy, ni6$zy)
par(mfrow = c(1,1), mar = c(4, 4.5, 3, 1) + 0.1)
plot(x = ni2$zx, y = ni2$zy, ylab = ni2$yexpr, xlab = ni2$xexpr, type = "l", 
  ylim = ylim, main = "News Impact Curve", col = col[1])
lines(x = ni4$zx, y = ni4$zy, col = col[2])
lines(x = ni6$zx, y = ni6$zy, col = col[3])
legend(x = "topright", y = NULL, legend = legend, border = FALSE, col = col, 
  lty = 1, text.col = col)


#

#### Stability check
cat("\nStability check (Nyblom test)\n")
print( nyblom(fit6) )

#$IndividualStat
#             [,1]
#mu     0.18430905
#ma1    0.10866633
#omega  0.07805289
#alpha1 0.09134530
#beta1  0.07244155
#eta11  0.69247549
#shape  0.35061298
#$JointStat
#[1] 1.852373
#$IndividualCritical
#  10%    5%    1% 
#0.353 0.470 0.748 
#$JointCritical
# 10%   5%   1% 
#1.69 1.90 2.35 

################################################################################
## Alternative GARCH formulations: iGARCH
################################################################################

#### IGARCH 
spec5 <- ugarchspec(variance.model = list(model = "iGARCH", garchOrder = c(1, 1), 
  submodel = NULL, external.regressors = NULL, variance.targeting = FALSE),  
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE, arfima = FALSE, 
  external.regressors = NULL, archex = FALSE), distribution.model = "std")
fit5 <- ugarchfit(spec = spec5, data = yret, solver = "solnp")
## Some statistics
cat( "\nInformation Criteria" )
print( infocriteria(fit5) )
cat("\nMatcoef\n")
print( fit5@fit$matcoef )
cat("\nRobust matcoef\n")
print( fit5@fit$robust.matcoef )

## Check alpha1 + beta1

################################################################################
## Forecasting ability
##
## Details: 
##  1. Volatility estimates from GARCH are compared with an external benchmark: 
##    the Garman-Klass volatility, a measure of volatility less noisy than 
##    squared returns (note that a GARCH, at the end, is a model of squared or 
##    absolute returns).
##  2. The section below shows IS (in-sample) forecasts, in the sense that the
##    forecasting period is included in the estimation period. More genuine OOS
##    (out-of-sample) forecasts should be considered in the comparison
##   
################################################################################

#### External benchmark
##   Remove one obs because we remove 1st (missing) obs from yret
y  <- data$gkVol[-1] * 100
time <- time[-1]

#### To give an idea ****
par(mfrow = c(1,1))
plot(x = time, y = y, type = "l")
lines(x = time, y = fit6@fit$sigma, col = "red")
lines(x = time, y = fit1@fit$sigma, col = "blue")

#### Error measures
cat("---------------------------------------------------------------------", 
  "\nError measures\n")
ErrorMeas <- data.frame(
  measure = c("Volatility", "Volatility", "Volatility", "Volatility", 
    "Variance", "Variance", "Variance", "Variance"), 
  model = c("GARCH", "GJR-GARCH", "T-GARCH", "IGARCH", 
    "GARCH", "GJR-GARCH", "T-GARCH", "IGARCH"), 
  rbind( 
    .ErrorMeasures(y = y,   fit = fit2@fit$sigma,   naive = "mean"), 
    .ErrorMeasures(y = y,   fit = fit4@fit$sigma,   naive = "mean"), 
    .ErrorMeasures(y = y,   fit = fit6@fit$sigma,   naive = "mean"), 
    .ErrorMeasures(y = y,   fit = fit5@fit$sigma,   naive = "mean"), 
    .ErrorMeasures(y = y^2, fit = fit2@fit$sigma^2, naive = "mean"), 
    .ErrorMeasures(y = y^2, fit = fit4@fit$sigma^2, naive = "mean"), 
    .ErrorMeasures(y = y^2, fit = fit6@fit$sigma^2, naive = "mean"), 
    .ErrorMeasures(y = y^2, fit = fit5@fit$sigma^2, naive = "mean") ) ) 
print( ErrorMeas )

#Error measures
#     measure     model          ME       MAE      RMSE        MPE      MAPE     RMSPE     ScMAE    ScRMSE
#1 Volatility     GARCH  0.06111964 0.6429293 0.9405554 -0.1398313 0.3432634 0.4572381 0.8684120 0.9242298
#2 Volatility GJR-GARCH  0.05523440 0.6272028 0.9165556 -0.1338458 0.3338630 0.4406171 0.8471700 0.9006466
#3 Volatility   T-GARCH  0.07098214 0.6266322 0.9196897 -0.1269487 0.3316139 0.4373652 0.8463993 0.9037262
#4 Volatility    IGARCH -0.04565521 0.6637112 0.9440618 -0.1923990 0.3687325 0.4973912 0.8964823 0.9276754
#5   Variance     GARCH  1.16481299 3.0857544 6.6011990 -0.4887294 0.8213080 1.2923015 0.8161256 0.9736698
#6   Variance GJR-GARCH  1.10302696 3.0156271 6.4903904 -0.4618350 0.7905826 1.2207864 0.7975782 0.9573256
#7   Variance   T-GARCH  1.17988673 3.0123536 6.5154329 -0.4451856 0.7810580 1.2083020 0.7967124 0.9610194
#8   Variance    IGARCH  0.65013556 3.1795311 6.5272037 -0.6321960 0.9213240 1.4719580 0.8409278 0.9627555


#### Mincer-Zarnowitz forecasting diagnostics
cat("---------------------------------------------------------------------", 
  "\nMincer-Zarnowitz\n" )
.MincerZarnowitz(y = y, fit = fit2@fit$sigma, msg = "AR(1) S GARCH\n")
#       F stat: 3.033876 , df: ( 2 , 1348 ), p-value: 0.04845749 
# (HC)  F stat: 2.232178 , df: ( 2 , 1348 ), p-value: 0.107691 
# (HAC) F stat: 1.042664 , df: ( 2 , 1348 ), p-value: 0.3527984 
.MincerZarnowitz(y = y, fit = fit4@fit$sigma, msg = "MA(1) GJR-GARCH\n") 
#       F stat: 3.141061 , df: ( 2 , 1348 ), p-value: 0.04355351 
# (HC)  F stat: 2.617542 , df: ( 2 , 1348 ), p-value: 0.07335299 
# (HAC) F stat: 1.229849 , df: ( 2 , 1348 ), p-value: 0.2926646   
.MincerZarnowitz(y = y, fit = fit6@fit$sigma, msg = "MA(1) T-GARCH\n")
#       F stat: 5.881788 , df: ( 2 , 1348 ), p-value: 0.002861893 
# (HC)  F stat: 4.076659 , df: ( 2 , 1348 ), p-value: 0.01717364 
# (HAC) F stat: 2.241522 , df: ( 2 , 1348 ), p-value: 0.1066927 
.MincerZarnowitz(y = y, fit = fit5@fit$sigma, msg = "I-GARCH\n")
#       F stat: 4.072576 , df: ( 2 , 1348 ), p-value: 0.01724348 
# (HC)  F stat: 2.99275 , df: ( 2 , 1348 ), p-value: 0.05048268 
# (HAC) F stat: 1.365761 , df: ( 2 , 1348 ), p-value: 0.2555393  


#### Diebold-Mariano forecasting comparison
cat("---------------------------------------------------------------------", 
  "\nDiebold-Mariano comparison\n\n")
## Volatility
cat("Volatility\n")
h <- 1
e2 <- y - fit2@fit$sigma #AR(1) SGARCH(1,1)
e4 <- y - fit4@fit$sigma #MA(1) GJR-GARCH(1,1)
e6 <- y - fit6@fit$sigma #MA(1) T GARCH
e5 <- y - fit5@fit$sigma #IGARCH
.DieboldMariano(e1 = e2, e2 = e4, h = h, power = 1, msg = "s GARCH vs GJR-GARCH ->")
.DieboldMariano(e1 = e2, e2 = e4, h = h, power = 2, msg = "s GARCH vs GJR-GARCH ->")
.DieboldMariano(e1 = e2, e2 = e6, h = h, power = 1, msg = "s GARCH vs T-GARCH ->")
.DieboldMariano(e1 = e2, e2 = e6, h = h, power = 2, msg = "s GARCH vs T-GARCH ->")
.DieboldMariano1(e1 = e6, e2 = e2, h = h, power = 1, msg = "T-GARCH vs s GARCH (less)  ->")
.DieboldMariano1(e1 = e6, e2 = e2, h = h, power = 2, msg = "T-GARCH vs s GARCH (less)  ->")
.DieboldMariano(e1 = e6, e2 = e4, h = h, power = 1, msg = "T-GARCH vs GJR-GARCH    ->")
.DieboldMariano(e1 = e6, e2 = e4, h = h, power = 2, msg = "T-GARCH vs GJR-GARCH    ->")
.DieboldMariano(e1 = e6, e2 = e4, h = h, power = 1, msg = "T-GARCH vs GJR-GARCH (less)   ->")
.DieboldMariano(e1 = e6, e2 = e4, h = h, power = 2, msg = "T-GARCH vs GJR-GARCH  (less)  ->")
.DieboldMariano(e1 = e4, e2 = e5, h = h, power = 1, msg = "GJR-GARCH vs IGARCH    ->")
.DieboldMariano(e1 = e4, e2 = e5, h = h, power = 2, msg = "GJR-GARCH vs IGARCH    ->")
.DieboldMariano1(e1 = e4, e2 = e5, h = h, power = 1, msg = "GJR-GARCH vs IGARCH (less)   ->")
.DieboldMariano1(e1 = e4, e2 = e5, h = h, power = 2, msg = "GJR-GARCH vs IGARCH (less)   ->")

#Volatility
#s GARCH vs GJR-GARCH -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): 1.845297 
#s GARCH vs GJR-GARCH -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): 1.470619 
#s GARCH vs T-GARCH -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): 3.240267 
#s GARCH vs T-GARCH -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): 2.59558 
#T-GARCH vs s GARCH (less)  -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): -3.240267 
#T-GARCH vs s GARCH (less)  -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): -2.59558 
#T-GARCH vs GJR-GARCH    -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): -2.607879 
#T-GARCH vs GJR-GARCH    -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): -3.398714 
#T-GARCH vs GJR-GARCH (less)   -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): -2.607879 
#T-GARCH vs GJR-GARCH  (less)  -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): -3.398714 
#GJR-GARCH vs IGARCH    -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): -4.516144 
#GJR-GARCH vs IGARCH    -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): -2.098542 
#GJR-GARCH vs IGARCH (less)   -> Horiz: 1 , Loss fct pow: 1 , Stat (L1-L2): -4.516144 
#GJR-GARCH vs IGARCH (less)   -> Horiz: 1 , Loss fct pow: 2 , Stat (L1-L2): -2.098542 
  

################################################################################
## Forecasts using rugarch
################################################################################

#### Settings
H <- 10

#### Arguments to pay attention
## data
## out.sample
## n.roll
#### Rule:
## last t in info = NROW(data) - out.sample

#### 1) ex-ante, h = 1:H
forc1 <- ugarchforecast(fitORspec = fit6, n.ahead = H, 
  data = NULL, out.sample = 0, n.roll = 0)
print(forc1)
plot(forc1)


#### 2) ex-post, h = 1:H at t = 1350 -> check date 1350
spec1x <- getspec(fit6)
setfixed(spec1x) <- as.list(coef(fit6))
# forc2a <- ugarchforecast(fitORspec = spec1x, n.ahead = H, 
#  data = yret[1:1350, , drop = FALSE])
forc2 <- ugarchforecast(fitORspec = spec1x, n.ahead = H, 
  data = yret, out.sample = NROW(yret) - 1350, n.roll = 0)






