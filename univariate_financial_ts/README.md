# Univariate financial time series analysis:Alibaba Group Holding Limited case study
This project contains a univariate financial time series analysis that aims to study the trend over time of the daily closing prices of the financial title “Alibaba Group Holding Limited (BABA)” during the period 19/09/2014 – 31/01/2020. The aim of this project was to predict the future trend of the stock.

I realized this analysis as part of a group project carried on by me and my former classmate Dai Xuanye in 2020 for the "Economic Statistics" course, held by Professor Cipollini and provided by the Statistics Department of the University of Florence.

The exam, which was composed of an oral exam and a project, was graded as 30/30 by the Professor.

## Overview
For this project, we used the dataset about the financial title “Alibaba Group Holding Limited (BABA)” supplied by the website “YAHOO! Finance”.

The goal of this analysis was to predict the future trends of the company's stocks. 

In order to do this, we started with an EDA, in which both the Di Fonzo-Lisi procedure and the KPSS tests confirmed the absence of non-stationarity of the series. Afterwards, we've proceeded with a performance analysis through the graphical analysis of ARMA residuals and ARCH test,from which it was found that there is a heteroskedasticity which seems to "vanish" quickly: this is probably due to the fact that the time series contains few observations.

We then proceeded to estimate the model, starting from the simple GARCH, whose standardized residuals presented a peak at lag=1 and showed correlation.
We then tried using different GARCH models jointly with an AR(1) or MA(1). By doing the Mincer Zarnowitz Diagnostics and the Diebold Mariano test, it turned out that the MA(1) – T-GARCH(1,1) model gives significantly better predictions than the others. Analyzing this model in more detail, we found it to have modest correlations between the residuals and stable and significant parameters (except one).

We then obtained, through this model, 10 forecasts that suggest a constant trend of the stock over time (a result that could be biased, as it does not take into account the epidemic brought by the Coronavirus) and a volatility that slowly decreases the further away the prediction go since the last observation.




e descrivono le quotazioni giornaliere dell’azienda (espresse in USD) dal 19/09/2014 al 31/01/2020, per un totale di 1351 osservazioni.
Le variabili sono:
- Date: data di rilevazione;
- Open: prezzo di apertura;
- High: prezzo massimo;
- Low: prezzo minimo;
- Close: prezzo di chiusura;
- Adjusted: prezzi “Close” aggiustati per i dividendi;
- Volume: numero di azioni scambiate nel giorno considerato.
