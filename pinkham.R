#####PROVA DATI PINKHAM #######

rm(list = ls())
library(forecast)
library(tseries)
library(urca)
library(sandwich)
library(lmtest)
library(strucchange)

#################
### FUNZIONI #### 
#################

#PROF: DATI LAG ##
Xlag = function (x, p=0, ndrop=0) {
  if(p>0) {
    n = length(x)
    M = x
    for (i in 1:p) {
      M <- cbind(M, c(rep(NA,i),x[1:(n-i)]))
    }
    colnames(M) <- 0:p
    if(ndrop>0) M[1:ndrop,] <- NA
    return(M)
  } else {
    return(x)  
  }
}

## MODELLO ##
nlag_bic =  function (yname, xname, znames=NULL, maxlag, data) {
  if(length(znames)>0) {
    zstring <- paste("+",paste(znames,collapse="+",sep=""))
  } else {
    zstring <- ""
  }
  formOK <- paste(yname,"~Xlag(",xname,",p=",maxlag,",ndrop=",maxlag,")",zstring,sep="")
  modOK <- lm(formula(formOK),data=data)
  bicOK <- BIC(modOK)
  pTry <- pOK <- maxlag
  fine <- 0
  cat("p=",maxlag,". BIC: ",bicOK,sep="","\n")
  while(fine==0) {
    pTry <- pTry-1
    formTry <- paste(yname,"~Xlag(",xname,",p=",pTry,",ndrop=",maxlag,")",zstring,sep="")
    modTry <- lm(formula(formTry),data=data)
    bicTry <- BIC(modTry)
    cat("p=",pTry,". BIC: ",bicTry,sep="","\n")
    if(bicTry<bicOK) {
      modOK <- modTry
      bicOK <- bicTry
      pOK <- pTry
      if(pOK<=1) fine <- 1
    } else {
      fine <- 1  
    }
  }
  cat("Selected p=",pOK,sep="","\n")
  # ristimo il modello col p selezionato col numero massimo di osservazioni possibile (ndrop=0)
  form <- paste(yname,"~Xlag(",xname,",p=",pOK,",ndrop=0)",zstring,sep="")
  mod <- lm(formula(form),data=data)
  mod$call$formula <- form
  return(mod)
}

## QLR TEST ##
# t = dimensione campione
# m = modello
qlr2 <- function ( data, yname, xname, zstring, p){
  t = dim(data) [1]
  year = data$DATE
  tau1 = round(0.15 * t)
  tau2 = round(0.85 * t)
  tau = tau1
  dt = c()
  ff = c()
  l=0
  fMax = 0
  while( tau <= tau2) {
    dt = factor( c( rep( 1, round( tau ) ), rep( 2 , round ( t-tau ))))
    
    m1 = lm( yname ~ Xlag(xname , p,p ) + zstring, data=dati)
    m2 = lm( yname ~ dt/(Xlag(xname , p,p ) + zstring), data=dati)
    fTry= anova(m1,m2)$F[2]
    
    ff = c (ff, fTry)
    
    if ( fMax < fTry ) {
      fMax = fTry
      date=DATE[tau]
    }
    
    if (fTry>3.66) {
      print(year[tau])
      print(tau)
      print(fTry)
    }
    tau = tau + 1
  }
  plot( year[tau1:tau2], ff , type='l', main="QLR test", ylab="Statistica F", xlab="Tempo", xlim=c(1907,1960))
  print(l)
  return(fMax)
}

#-------------------------------------------------------------------------------

#######################
### CARICAMENTO DATI### 
#######################

file <- "~/Desktop/tesi/pinkham/a425_pinkham.csv"
dati=read.table(file, header=TRUE, sep=";")
start1 <- as.numeric( substr(dati$DATE[1], 1, 4) )
t = dim (dati) [1]

#################
### VARIABILI ###
#################

#y=c()
#for(i in 1:nrow(dati)){y[i]=dati$SALES[i]/dati$SALES[1]}
y=ts(data=log(dati$SALES), start=start1)
x=ts(log(dati$ADVERTISING), start=start1)
z=dati$PROHIBITION

#decidiamo di lavorare non sul numero indice vero e proprio, ma sul suo logaritmo.
#Questa è una procedura molto diffusa, e serve a far sì che si possa dare un’interpretazione 
#più naturale ai numeri di cui è composta la serie,  visto che lesue differenze prime sono più 
#o meno variazioni percentuali

# slides
y_s = ts (data=dati$SALES, start=start1)
plot(y_s, type='l', ylab='Vendite e pubblicità', xlab = 'Tempo', ylim = c(400, 3500))
x_s = ts(data=dati$ADVERTISING, start=start1)
lines(x_s, col = 'blue')
legend ('topright',legend=c('Vendite', 'Pubblicità'), lty=1,
        col=c("black","blue"))

##### SALES #####

## GRAFICI Y ##
plot(y, type='l', ylab="Logaritmo delle vendite", xlab="Tempo")#, main="Andamento del logaritmo delle vendite nel tempo")
abline(v=1919)
abline(v=1933)

cbind(dati$DATE, y)

## ADF Y  ##
df1_y <- ur.df(y = y , type="trend" , selectlags = "AIC")
summary(df1_y)
df2_y <- ur.df(y = y , type = "drift", selectlags = "AIC")
summary(df2_y)
##Si hanno radici unitarie

##TRASFORMAZIONE Y ##
dati$yOK <- c(NA,ts(diff(y), start=start1))
attach(dati)
plot(DATE,yOK, type='l', ylab="Differenze prime di log(Y)", xlab="Tempo")#, main="Andamento delle differenze prime del logaritmo di Y nel tempo")
abline(h=0)

## ADF Y TRASFORMATA ##
df_yOK <- ur.df(y = yOK[-1] , type = "trend", selectlags = "AIC")
summary(df_yOK)
#stazionaria

###### ADVERTISMENT #####

## GRAFICI X ##
plot(x, type='l', ylab="Logaritmo della spesa pubblicità", xlab="Tempo")#, main="Andamento del logaritmo della spesa in pubblicità nel tempo")

## ADF X ##
df1_x <- ur.df(y = x , type = "trend", selectlags = "AIC")
summary(df1_x)
df2_x <- ur.df(y = x , type = "drift", selectlags = "AIC")
summary(df2_x)
##Si hanno radici unitarie

#TRASFORMAZIONE X ##
dati$xOK <- c(NA, ts(diff(x), start=start1))
attach(dati)
plot(DATE,xOK, type='l', ylab="Differenze prime di log(X)",xlab="Tempo", main="Andamento delle differenze prime del logaritmo di X nel tempo")
abline(h=0)

## ADF X ##
df_xOK <- ur.df(y = xOK[-1] , type = "trend", selectlags = "AIC")
summary(df_xOK)
##Non si hanno radici unitarie

## pubblicità e vendite
par(mfrow=c(1,1))
plot(DATE, 100*xOK, type="l", xlab="Tempo", ylab="Variazione percentuale")
lines(DATE, 100*yOK, type='l', col='blue')
abline(h=0, col='grey', lwd=2)
legend("topright", legend=c( 'Pubblicità','Vendite'), fill=c('blue', 'black'))

y_ni = c()
x_ni = c()
for(i in 1:nrow(dati)){y_ni[i]=dati$SALES[i]/dati$SALES[1]} #numero indice a base fissa vendite
for(i in 1:nrow(dati)){x_ni[i]=dati$ADVERTISING[i]/dati$ADVERTISING[1]} #numero indice a base fissa pubblicità
plot(DATE, y_ni, type='l', ylab="N.I. delle vendite e della pubblicità", xlab="Tempo", ylim = c( .5,3.5))
lines(DATE, x_ni, type='l', col='blue')
legend("topright", legend=c('Pubblicità','Vendite'), fill=c('blue', 'black'))

##grangertest(xOK~yOK, order=3, data=dati)
##grangertest(yOK~xOK, order=3, data=dati)
##m1=nlag_bic("xOK", "yOK", "z", maxlag=10, data=dati )

#########################
### SCELTA NUMERO LAG ###
#########################

## AUTOMATICO ##
m1=nlag_bic("yOK", "xOK", "z", maxlag=10, data=dati ) #5
summary(m1)

m2=nlag_bic("yOK", "xOK", "z", maxlag=5, data=dati ) #3 lags
summary(m2)

## A MANO ##
m1=lm(yOK~Xlag(xOK, 10, 10 ) + z, data=dati)
summary(m1)

m2=lm(yOK~Xlag(xOK, 9, 9 ) + z, data=dati)
summary(m2)

m3=lm(yOK~Xlag(xOK, 8,8 ) + z, data=dati)
summary(m3)

m4=lm(yOK~Xlag(xOK, 7,7 ) + z, data=dati)
summary(m4)

m5=lm(yOK~Xlag(xOK, 6,6 ) + z, data=dati)
summary(m5)

m6=lm(yOK~Xlag(xOK, 5,5 ) + z, data=dati)
summary(m6)

m7=lm(yOK~Xlag(xOK, 4, 4 ) + z, data=dati)
summary(m7)

m8=lm(yOK~Xlag(xOK, 3, 3 ) + z, data=dati)
summary(m8)

mOK=m8


######################
### MODELLO FINALE ###
######################
summary(mOK)
coeff = mOK$coefficients
int_conf=confint(mOK, level=0.95)
mOK_data=cbind(coeff, int_conf[,1], int_conf[,2], c(NA, seq(from=0, to=4, by=1)))
mOK_data
par(mfrow=c(1,2))

plot( mOK_data[(2:5),4], mOK_data[(2:5),1], type="l", main="Coefficienti del modello con 3 ritardi", xlab="Ritardi", ylab="Moltiplicatori dinamici", ylim=c(-.1,.5))
abline(h=0, col="grey")
lines( mOK_data[(2:5),4],mOK_data[(2:5),2], col="blue", lty=2)
lines( mOK_data[(2:5),4],mOK_data[(2:5),3], col="blue", lty=2)


coeff_cumulati = c()
for(i in 1:length(mOK$coefficients)){ 
  if(i==1 | i==2){ 
    coeff_cumulati[i]=mOK$coefficients[i]
  } else {
    coeff_cumulati[i]=coeff_cumulati[i-1]+mOK$coefficients[i]
  }
}
mOK_coeff=cbind(coeff, coeff_cumulati)
plot(c(0:3),coeff_cumulati[2:5], type="l", main="Coefficienti cumulati del modello con 3 ritardi", xlab="Ritardi", ylab="Moltiplicatori dinamici cumulati", ylim = c(0.3, .8))

#intervalli di confidenza cumulati
m_cov=vcov(mOK)
var_cum = c()
cnt=1
while(cnt <= dim(m_cov)[1]){
  if(cnt==1 ) {
    var_cum[cnt]=m_cov[cnt,cnt]
    cnt=cnt+1
  }else{
    var_cum[cnt]=var_cum[cnt-1]+m_cov[cnt,cnt]+2*m_cov[cnt,cnt-1]
    cnt=cnt+1
  }
}

lower = c()
higher = c()
for ( i in 1 : dim(mOK_coeff)[1]){
  lower = append( lower, (mOK_coeff[ i , 2 ] - qnorm(.975) * sqrt( var_cum[ i ] / dim(mOK_coeff)[1])))
  higher = append( higher, (mOK_coeff[ i , 2 ] + qnorm(.975) * sqrt( var_cum[ i ] / dim(mOK_coeff)[1])))
}
lines(c(0:3),higher[2:5], type='l', col="blue", lty=2)
lines(c(0:3),lower[2:5], type='l', col="blue", lty=2)


## RESIDUI ##

res=mOK$residuals
res2=c(rep(NA,4),res^2)
scres=res=c(rep(NA,4),scale(res))

## grafici ##

plot(DATE[5:54],res[5:54], type='l', main="(i) Andamento dei residui nel tempo", xlab="Tempo", ylab="Residui")
abline(h=0)

plot(fitted(mOK), res[5:54], xlab="Valori adattati", ylab="Residui", main="(ii) Residui contro i valori adattati")
abline(h=0)

par(mfrow=c(1,1))
acf(res[5:54], main='', ylab='Autocorrelazione', xlab='Ritardi')

#test Ljung Box
npar1=NROW(coeff)
lag1<- npar1 + c(1, 2, 5, 10, 15)
print( mapply(FUN = Box.test, lag = lag1, 
              MoreArgs = list(x = res, type = "Ljung-Box", fitdf = npar1)) )
#no autocorrelazione

par(mfrow=c(1,1))
qqnorm(scale(res), main='', ylab='Quantili campionari', xlab='Quantili teorici')
abline(0,1, col="red")
cbind(DATE, scres)

#prova autocorrelazione
#ar(res) #no autocorrelazione

#test White
m1res = lm( res2 ~ xOK + z)
summary(m1res)

#F test non significativo

## QLR TEST ##

qlr2(dati, yOK, xOK, z, 3)
#rotture strutturali
mp1 = lm( yOK [1:11] ~ Xlag( xOK[1:11], 3, 3)+z[1:11], data=dati)
summary(mp1)

mp2 = lm( yOK [12:54] ~ Xlag( xOK[12:54], 3, 3) + z[12:54], data=dati)
summary(mp2)

#test wald
wald = function (m1, m2){
  nom=(m1$coefficients-m2$coefficients)
  den=(sqrt ( diag ( sqrt(vcov ( m1 )) )+ diag ( sqrt(vcov ( m2 )))))
  z = nom / den
  return( 2 * pnorm( - abs( z )))
}

wald(mp1, mOK)
wald(mp2, mOK)

## CAPACITA' PREDITTIVA
y = dati$SALES
pred = c()
for (i in 1:t-4){
  pred[i] = exp(mOK$fitted.values[i]+log(y[i+4-1])+0.5*summary(mOK)$sigma^2)
}

mape=function(xoss, xpred){100*mean(abs((xoss-xpred)/xoss))}
mape(y[5:t], pred)

plot(DATE[5:54], y[5:54], type="l", ylab='Vendite', xlab='Tempo', ylim=c(900,3600))
lines(DATE[5:54], pred, type='l', col="blue", )
legend("topright", legend=c('Valori osservati', 'Valori previsti'), fill=c('black', 'blue'))


#forma log
pl <-function(x,c=1,b=1){c*x^b}
xseq <- seq(0,5,length=100)
plot(xseq, sapply(xseq,pl,b=1.3), type="l", col="blue",
     ylab="", xlab="", cex.axis=1.1, cex.lab=1.2)
lines(xseq, sapply(xseq,pl,b=0.5), col="red")
lines(xseq, sapply(xseq,pl,b=1))
legend("topleft", legend=paste("β1 = ",c(0.5,1,1.3), sep=""), lty=1,
       col=c("red","black","blue"), cex=1.2, bty="n")
legend ('left', legend=paste("β*=", 0, sep=''),lty=1,
        col='white', cex=1.2, bty="n")

#slides
plot(y, type='l', ylab="Logaritmo delle vendite e della pubblicità", xlab="Tempo", ylim= c(5.85, 8.1))
lines(x, type ='l', col='blue')
legend ('bottomright',legend=c('Vendite', 'Pubblicità'), lty=1,
        col=c("black","blue"))




