# Univariate financial time series analysis:Alibaba Group Holding Limited case study
This project contains a univariate financial time series analysis that aims to study the trend over time of the daily closing prices of the financial title “Alibaba Group Holding Limited (BABA)” during the period 19/09/2014 – 31/01/2020. The aim of this project was to predict the future trend of the stock.

I realized this analysis as part of a group project carried on by me and my former classmate Dai Xuanye in 2020 for the "Economic Statistics" course, held by Professor Cipollini and provided by the Statistics Department of the University of Florence.

The exam, which was composed of an oral exam and a project, was graded as 30/30 by the Professor.

## Overview
For this project, we used the dataset about the financial title “Alibaba Group Holding Limited (BABA)” supplied by the website “YAHOO! Finance”.

The goal of this analysis was to predict the future trends of the company's stocks. 

In order to do this, we started with an EDA (Exploratory Data Analysis), in which both the Di Fonzo-Lisi procedure and the KPSS tests confirmed the absence of non-stationarity of the series. Afterwards, we've proceeded with a performance analysis through the graphical analysis of ARMA residuals and ARCH test,from which it was found that there is a heteroskedasticity which seems to "vanish" quickly: this is probably due to the fact that the time series contains few observations.

We then proceeded to estimate the model, starting from the simple GARCH, whose standardized residuals presented a peak at lag=1 and showed correlation.
We then tried using different GARCH models jointly with an AR(1) or MA(1). By doing the Mincer Zarnowitz Diagnostics and the Diebold-Mariano test, it turned out that the MA(1) – T-GARCH(1,1) model gives significantly better predictions than the others. Analyzing this model in more detail, we found it to have modest correlations between the residuals and stable and significant parameters (except one).

We then obtained, through this model, 10 forecasts that suggest a constant trend of the stock over time (a result that could be biased, as it does not take into account the epidemic brought by the Coronavirus) and a volatility that slowly decreases the further away the prediction go since the last observation.

## Main concepts
- Weak stationarity: it's the most relevant and desirable characteristic a time series can have. Simply put, we have stationarity when the first two moments of the distribution of the variables that compose the stochastic process don't depend on time, for intance, if we consider a Normal distribution, which is defined only by its two first moments (so mean, variance and covariance), under the hypothesis of stationarity the distribution remains the same throughout time.
- Di Fonzo-Lisi procedure: it's a procedure that involves multiple ADF (Augmented Dickey-Fuller) tests used to verify the stationarity of the process.
- Autocorrelation: it's the presence of a significant correlation among the variables that compose the same process, i.e. the process at time t is correlated with the process at time t+k.
- Integrated process of order 1: it's a non-stationary process, whose first difference is stationary, i.e. y_t - y_{t-1} is stationary.
- Dynamic Linear Model: it's a linear model that takes as depent variable a generic process y in time t and as independent variables the lags of another process x. The regression coefficients estimated through OLS coincide with the dynamic causal effects.
- BIC (Bayesian Information Criterion): it's a measure of the goodness of fit that takes into account the complexity of the model.
- AR(p): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of its past.
- MA(q): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of White Noise Processes (i.e. of non autocorrelated processes with mean 0).
- ARMA (p,q):  it's a statistical model used in time series analysis that linearily combine the AR(p) and MA(q) structure.
- GARCH(Generalized Autoregressive Conditional Heteroskedasticity): it's a statistical model used in time series analysis to characterize and predict the volatility of financial returns by incorporating autoregressive and moving average components for the conditional variance.
- ARCH (AutoRegressive Conditional Heteroskedasticy) test: it tests the null hypothesis of homoskedasticity.
- KPSS test: it tests the null hypothesis of trend-stationarity around the trend of the time series.
- Mincer Zarnowitz Diagnostics: it's a useful tool to verify the ability of the model to generate unbiased predictions.
-  Diebold-Mariano test: it tests the null hypothesis that the models generate similar predictions.






