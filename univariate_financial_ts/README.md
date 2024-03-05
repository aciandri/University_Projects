# Univariate financial time series analysis: Alibaba Group Holding Limited case study
This project consists of a univariate financial time series analysis that aims to study the trend of the daily closing prices of the financial title "Alibaba Group Holding Limited (BABA)" over time. Specifically, we used the data referred to the period 19/09/2014-31/01/2020. This project aimed to predict the future trend of the stock.

I realized this analysis as part of a group project carried on by me and my former classmate Dai Xuanye in 2020 for the "Economic Statistics" course, held by Professor Cipollini and provided by the Statistics Department of the University of Florence. For this project, the Professor supplied us with some useful functions written by him that you can find at the start of the project.

The final exam involved an oral exam and a project and was graded as 30/30 by the Professor.

## Overview
For this project, we used the daily closing prices dataset of the financial title “Alibaba Group Holding Limited (BABA)” supplied by the website “YAHOO! Finance”.

The goal of this analysis was to study the daily closing prices and predict the future trends of the company's stocks. 

We began carrying out an EDA (Exploratory Data Analysis) and determined the non-stationarity of the series through the KPSS test and the Di Fonzo-Lisi procedure.
Afterward, we conducted a performance analysis on the log returns and estimated the following models:

 - ARMA(1,1): the residuals analysis and an ARCH test showed the presence of heteroskedasticity, which seems to "vanish" quickly.
 - simple GARCH: its standardized residuals showed a peak at lag=1 and the presence of correlation.
 - GARCH models jointly with an AR(1) or MA(1): the Mincer Zarnowitz Diagnostics and the Diebold-Mariano test showed that the MA(1) – T-GARCH(1,1) model gives significantly better predictions than the others. Analyzing this model in more detail, we found modest correlations between the residuals and generally stable and significant parameters.

We then used the MA(1) – T-GARCH(1,1) model to obtain 10 forecasts. They show a constant trend of the stock over time (a result that could be biased, as it does not take into account the epidemic brought by the Coronavirus) and a volatility that slowly decreases the further away the prediction goes since the last observation.

## Main concepts
- (Weak) stationarity: a time series is called stationary if its first two moments don't depend on time. For instance, if we consider a Normal distribution, which is defined only by its two first moments (so mean, variance and covariance), under the hypothesis of stationarity the distribution remains the same throughout time.
- Di Fonzo-Lisi procedure: it's a procedure that involves multiple ADF (Augmented Dickey-Fuller) tests used to verify the stationarity of the process.
- Autocorrelation: it's the presence of a significant correlation among the variables that compose the same process, i.e. the process at time t is correlated with the process at time t+k.
- Integrated process of order 1: it's a non-stationary process, whose first difference is stationary, i.e. y_t - y_{t-1} is stationary.
- Dynamic Linear Model: it's a linear model that takes as a dependent variable a generic process y in time t and as independent variables the lags of another process x. The regression coefficients estimated through OLS coincide with the dynamic causal effects.
- BIC (Bayesian Information Criterion): it's a measure of the goodness of fit that takes into account the complexity of the model.
- AR(p): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of its past.
- MA(q): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of White Noise Processes (i.e. of non-autocorrelated processes with mean 0).
- ARMA (p,q):  it's a statistical model used in time series analysis that linearly combines the AR(p) and MA(q) structure.
- GARCH(Generalized Autoregressive Conditional Heteroskedasticity): it's a statistical model used in time series analysis to characterize and predict the volatility of financial returns by incorporating autoregressive and moving average components for the conditional variance.
- ARCH (AutoRegressive Conditional Heteroskedasticity) test: it tests the null hypothesis of homoskedasticity.
- KPSS test: it tests the null hypothesis of trend-stationarity around the trend of the time series.
- Mincer Zarnowitz Diagnostics: it's a useful tool to verify the ability of the model to generate unbiased predictions.
-  Diebold-Mariano test: it tests the null hypothesis that the models generate similar predictions.

## Project Structure
### 1. EDA
We began the analysis by doing a graphical analysis of the series. The graphs and ACF (AutoCorrelation Function) and PACF (Partial AutoCorrelation Function) show non-stationarity, which doesn't go away through the first difference or logarithmic transformation.

We then applied the Di Fonzo-Lisi procedure and the KPSS test, which confirmed the non-stationarity of the series. 

### 2. Performance analysis
Usually, in financial time series analysis, we're interested in analyzing the price variations. Therefore, we applied a log-variations transformation to the prices (also known as log-returns).

The new series shows significant correlations (ACF, PACF and LB test) and non-normality (histogram of the distribution, qq-plot and Jarque-Bera test).

### 3. Model estimation
In this step, we've applied:
- ARMA(1,1) model:  it showed high serial correlations among the absolute and quadratic residuals. Therefore, the residuals are not White Noise processes. We then used the ARCH test to verify homoskedasticity, which shows short-lived volatility (probably due to the small number of observations of the series).
- GARCH(1,1) model: its coefficients indicate the stationarity of the process and the standardized residuals show a high correlation at lag = 1. 
- AR(1) - S-GARCH(1,1); MA(1) - GJR-GARCH(1,1); MA(1)-TGARCH(1,1): we've compared these models through their outputs and the news impact curve. Both of these instruments seem to indicate the presence of a leverage effect. We then applied the Mincer-Zarnowitz diagnostic, which showed that the MA(1) - T-GARCH provides significantly better predictions than the other models tested.

### 4. Diagnostic analysis
In this step, we executed a diagnostic analysis of the MA(1)-TGARCH model:
1. residual analysis: we analyzed the ACF and LB tests of the residuals and their quadratic and absolute value. Furthermore, we created a qq-plot and a histogram of the residuals distribution density, that show a leptokurtic trend and a deviation from the Normal distribution on the right tail.
2. ARCH test: there is no GARCH effect.
3. Leverage effect: there is no significant leverage effect.

### 5. Predictions
In this step, we used the MA(1)-TGARCH model and:
- applied a Nyblom test to verify the stability of the parameters;
- computed 10 steps ahead forecasts.

The forecast suggests a constant trend of the stock over time (a result that could be biased, as it does not account for the epidemic brought by the Coronavirus) and volatility that slowly decreases the further away the prediction goes since the last observation.

