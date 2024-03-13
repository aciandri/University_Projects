# Bivariate time series analysis: Pinkham case study
This project studies the relationship between advertising expenses and sales in the Pinkham case study through a bivariate time series analysis.

I realized this analysis with the help of Professor Magrini of the University of Florence as part of my B.Sc. thesis: "Dynamic Linear Model for the estimation of Dynamic Causal Effects in the Economic Field" in 2020.

The thesis scored 3 out of 3 points during the evaluation.

## Overview
For this project, the Professor provided me with a dataset containing Lydia Pinkham's company's annual advertisement expenses and sales data from 1907 to 1960. As per the existing literature, the advertisement expenses process was considered an exogenous factor.

This analysis showed a relevant causal effect of the advertisement expenses on the sales, net of legislative changes, which have been accounted for through a dummy that identifies the Prohibition Era. The sales increase associated with a 1% growth in advertisement expenses was estimated to be around 0.7% in the long run. Furthermore, net of legislative changes, this effect showed a decreasing time trend (+0.364% the same year, +0.174% at the first lag, +0.126% at the third trend).


## Main concepts
- (Weak) stationarity: it's one of the most relevant and desirable characteristics a time series can have. Simply put, the process is said to be stationary when its first two moments don't depend on time: for instance, if we consider a Normal distribution, which is defined only by its two first moments (i.e., mean, variance and covariance), under the hypothesis of stationarity the distribution remains the same throughout time.
- Di Fonzo-Lisi procedure: it's a procedure that involves multiple ADF (Augmented Dickey-Fuller) tests used to verify the stationarity of the process.
- Autocorrelation: it refers to the presence of correlation among the variables that make up the process. In other words, the process at time t is correlated with the process at time t+k.
- Integrated process of order 1: it's a non-stationary process, whose first difference is stationary, i.e., $y_t - y_{t-1}$ is stationary.
- Dynamic Linear Model: it's a linear model that models a generic process $y$ in time t as a linear combination of the lags of another process $x$. The regression coefficients estimated through OLS coincide with the dynamic causal effects.
- BIC (Bayesian Information Criterion): it's a measure of the goodness of fit that penalizes for the complexity of the model.
- HAC (Heteroskedasticity and Autocorrelation Consistent) estimator: it's an estimator of the variance and covariance matrix of the OLS estimators that account for the autocorrelation among the residuals.
- QLR (Quandt Likelihood Ratio) test: it's a tool used to identify structural changes in the time series (i.e., changes in the regression function within the sample): basically, it tries to identify sharp changes in the regression coefficients.

## Project Structure
Given the robust evidence underlying the hypothesis of unidirectional causality between advertisement expenses and sales, we've decided to focus on the relationship that links advertisement expenses (x) to sales (y). I proceeded with the following steps:
### 1. Graphic analysis and stationarity check
In this step, I applied a logarithmic transformation on both processes to reduce the potential heteroskedasticity and non-normality of the regression errors. After conducting a univariate graphical analysis and using the Di Fonzo-Lisi procedure, I found that both processes have an integration order of 1. However, due to the presence of a strong deterministic trend characterizing both series, I decided to transform the data into percentual variations before proceeding with the association study of the two processes.
### 2. Estimation of the Dynamic Linear Model
In this step, I created a dummy to consider the information about the Prohibition Era. I then fit the Dynamic Linear Model to the data, examining a maximum of 10 lags. I then used the BIC to choose the optimal number of lags to insert into the model.

At the end of this step, I obtained a model with a determination coefficient equal to 0.527 and positive significant coefficients associated with lags 0, 1, and 3.

### 3. Model diagnostic: 
In this step, I carried out the following analysis:

- residual analysis: I tested for homoskedasticity through graphical analysis and the White test, autocorrelation through the ACF (AutoCorrelation Function), and normality through the qq-plot. This analysis showed the absence of heteroskedasticity, autocorrelation, and non-normality of the residuals.
- stability of the coefficients check: I used the QLR test to verify the absence of structural changes. The test spotted a structural change in 1918 (the year when the Wartime Prohibition Act was enforced). Therefore, I estimated two models (one for the period 1907-1917 and one for the period 1918-1960): the first one leads to a spurious relation (due to the scarce number of records it's based on), while the second one leads to similar results to the original one, but with a higher goodness of fit.
- evaluation of the model's predictive power: I computed the MAPE (Mean Absolute Percentage Error), which estimates an error prediction equal to 6.105%. Therefore, the model has good predictive power.
