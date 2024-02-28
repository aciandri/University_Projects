# Bivariate time series analysis
This project contains a bivariate time series analysis that aims to study the relationship between advertisement expenses and sales. In particular, it's an analysis of the Pinkham case study.

I realized this analysis with the help of Professor Magrini of the University of Florence as part of my B.Sc. thesis: "Dynamic Linear Model for the estimation of Dynamic Causal Effects in the Economic Field" in 2020.

The thesis received a score of 3 out of 3 points during the evaluation.

## Overview
For this project, the Professor provided me with a dataset containing Lydia Pinkham's company's advertisement expenses and sales annual data from 1907 to 1960. As per the existing literature, the advertisement expenses process was considered as an exogenous factor .

This analysis shows that there exists a relevant causal effect of the advertisement expenses on the sales net of legislative changes, which has been accounted for through a dummy that identifies the Prohibition Era. The long-term effect of a one percent increase in the advertisement expenses on sales is about +0.7%. More precisely, net of legislative changes, the effect of a 1% increment of the exogenous factor has a decreasing time trend (+0.364% the same year, +0.174% at the first lag, +0.126% at the third trend).


## Main concepts
- Weak stationarity: it's the most relevant and desirable characteristic a time series can have. Simply put, we have stationarity when the first two moments of the distribution of the variables that compose the stochastic process don't depend on time, for intance, if we consider a Normal distribution, which is defined only by its two first moments (so mean, variance and covariance), under the hypothesis of stationarity the distribution remains the same throughout time.
- Di Fonzo-Lisi procedure: it's a procedure that involves multiple ADF (Augmented Dickey-Fuller) tests used to verify the stationarity of the process.
- Autocorrelation: it's the presence of a significant correlation among the variables that compose the same process, i.e. the process at time t is correlated with the process at time t+k.
- Integrated process of order 1: it's a non-stationary process, whose first difference is stationary, i.e. y_t - y_{t-1} is stationary.
- Dynamic Linear Model: it's a linear model that takes as depent variable a generic process y in time t and as independent variables the lags of another process x. The regression coefficients estimated through OLS coincide with the dynamic causal effects.
- BIC (Bayesian Information Criterion): it's a measure of the goodness of fit that takes into account the complexity of the model.
- HAC (Heteroskedasticity and Autocorrelation Consistent) estimator: it's an estimator of the variance and covariance matrix of the OLS estimators useful to account for the presence of autocorrelation among the residuals.
- QLR (Quandt Likelihood Ratio) test: it's a tool used to identify structural changes in the time series (i.e. changes in the regression function within the sample). It basically tries to identify sharp changes in the regression coefficients.

## Project Structure
Given the robust evidence underlying the hypothesis of unidirectional causality between advertisement expenses and sales, we've decided to focus on the relationship that links advertisement expenses (x) to sales (y). We proceeded with the following steps:
1. Graphic analysis and stationarity check: in this step, we applied a logarithmic transformation on both processes in order to reduce the potential heteroskedasticity and non-normality of the regression errors. After conducting a univariate graphical analysis and using the Di Fonzo-Lisi procedure, I found that both processes have an integration order of 1. However, due to the strong deterministic trend characterizing both series, I decided to transform the data into percentual variations before proceeding with the association study of the two processes.
2. Estimation of the Dynamic Linear Model: in this step, I created a dummy to account for the Prohibition Era. I then applied the model to the data examining a maximum of 10 lags. I then selected a model with 3 lags according to the BIC index. At the end of this step, we obtained a model with a determination coefficient equal to 0.527 and positive significant coefficients associated with lags 0, 1 and 3.
3. Model diagnostic: in this step, I carried out:

- a residual analysis: testing for homoskedasticity through graphical analysis and the White test, autocorrelation through the ACF (AutoCorrelation Function) and normality through the qq-plot. This analysis showed the absence of heteroskedasticity, autocorrelation and non-normality of the residuals.
-  a stability of the coefficients check: I used the QLR test to verify the absence of structural changes. The test spotted a structural change in 1918 (the year when the Wartime Prohibition Act was enforced). Therefore, I estimated two models (one for the period 1907-1917 and one for the period 1918-1960): the first one leads to a spurious relation (due to the scarce number of records it's based on), while the second one leads to similar results to the original one, but with a higher goodness of fit.
-  an evaluation of the model's predictive power: to do this, I used the MAPE (Mean Absolute Percentage Error), which estimates an error prediction equal to 6.105%. Therefore, the model has good predictive power.
