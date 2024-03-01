# Economic time series analysis: Trade balance between Italy and China
This project contains a univariate economic time series analysis that aims to study the trend over time of the commercial trade (in euros) between Italy and China in the period 01/2006-11/2019.

I realized this analysis as part of a group project carried on by me and my former classmate Dai Xuanye in 2020 for the "Economic Statistics" course, held by Professor Cipollini and provided by the Statistics Department of the University of Florence. For this project, the Professor supplied us with some useful functions written by him that you can find at the start of the project.

The exam, which was composed of an oral exam and a project, was graded as 30/30 by the Professor.

## Overview
For this project, we extracted the data of interest from the Eurostat dataset "International trade in goods - detailed data: EU trade since 1988 by CN8": we analyzed the monthly imports and exports expressed in euros between Italy and China in the time window 01/2006-11/2019, which allowed us to compute the trade balance.

Our goal was to predict the future trend of the trade balance between Italy and China, based on the data collected between January 2006 and November 2019.

We started with a preliminary analysis of the time series, noting the absence of a linear trend and the presence of strong annual seasonality. In this first phase, we also performed two tests for unit roots using the Di Fonzo–Lisi procedure and the KPSS test, from which we found the absence of unit roots in the process and, therefore, the stationarity of the process.

Considering this, we then identified and estimated two models: an ARIMA(1,0,1)(2,0,0)12 and an ARIMA(3,0,0)(0, 1,1)12, which turned out to adapt quite well to the data.

Finally, we computed the ex-ante forecasts: from these, we can observe a general trend that does not seem to vary much from last year's. Furthermore, the results of the ex-post forecasts show that the models have good predictive capabilities, even though sometimes they tend to slightly overestimate. 
All these considerations are, however, subject to high uncertainty due to the epidemic caused by the Coronavirus, which has infected thousands of people and rendered a great part of the population and markets inoperative. This precariousness, however, could have just secondary effects on the forecasts made, as both exports and imports will probably decrease in the coming months.

## Main concepts
- Weak stationarity: it's the most relevant and desirable characteristic a time series can have. Simply put, we have stationarity when the first two moments of the distribution of the variables that compose the stochastic process don't depend on time, for instance, if we consider a Normal distribution, which is defined only by its two first moments (so mean, variance and covariance), under the hypothesis of stationarity the distribution remains the same throughout time.
- Di Fonzo-Lisi procedure: it's a procedure that involves multiple ADF (Augmented Dickey-Fuller) tests used to verify the stationarity of the process.
- Autocorrelation: it's the presence of a significant correlation among the variables that compose the same process, i.e. the process at time t is correlated with the process at time t+k.
- Integrated process of order 1: it's a non-stationary process, whose first difference is stationary, i.e. y_t - y_{t-1} is stationary.
- BIC (Bayesian Information Criterion): it's a measure of the goodness of fit that takes into account the complexity of the model.
- AR(p): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of its past.
- MA(q): it's a simple statistical model used in time series analysis that writes the present value of the process as the linear combination of White Noise Processes (i.e. non-autocorrelated processes with mean 0).
- ARIMA (p,q):  it's a statistical model used in time series analysis that applies a linear combination of the AR(p) and MA(q) structure on the first difference of the series.
- Ex-ante predictions: they're based on all the available observations to make predictions for the next periods of time.
- Ex-post predictions: they're based on part of the dataset to make predictions for the remaining records and involve 5 steps:
    1. model estimation;
    2. prediction;
    3. comparison of the true value with the predicted one;
    4. update of the information in t+1 and step 2;
    5. stop when reaching the last record and computation of error measures.

## Project Structure
### 1. EDA
In this step, we gained a first graphical description of the phenomenon: the graph of the series doesn't show any signs of a deterministic trend, but the analysis of ACF (AutoCorrelation Function) and PACF (Partial AutoCorrelation Function) indicate uncertainty about the stationarity of the series.

Therefore, we performed a Di Fonzo-Lisi procedure and KPSS test to test the presence of unit roots: their results are conflicting, as the ADF tests confirm the presence of unit roots, while the KPSS test affirms that there isn't sufficient empirical evidence to reject the null hypothesis of stationarity of the process.

We then adjusted the series for seasonality through 12th differences and tested for stationarity through the KPSS test, which, in this case, showed stationarity.

### 2. Model estimation and residuals analysis
In this step, given the conflicting results obtained in the previous phase, we chose to fit two models:

- ARIMA(1,0,1)(2,0,0)12 (stationary) ;
- ARIMA(3,0,0) (0,1,1)12 (non-stationary) .

Both models didn't show any outliers.

We then verified that the residuals are similar to a White Noise(0, sigma2), through plots, ACF, LB tests, density distribution, qq-plot and JB test. According to these tools, both models seem to be appropriate to describe the data.

### 3. Prediction
In this step, we made both ex-ante and ex-post predictions.

- Ex-ante: they show a reversed U trend, which could be associated either with an increase of imports (maybe joined with a reduction of exports) in the first phase followed by its decrease or an increment in exports or with a decrease in exports in the first phase followed by its increase or decrease in imports. The predictions supplied by the two models are similar.
- Ex-post 12 steps ahead: both models produce good predictions.







