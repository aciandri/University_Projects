# Economic time series analysis: Trade balance between Italy and China
This project contains a univariate economic time series analysis that aims to study the trend over time of the commercial trades (in euros) between Italy and China in the period 01/2006-11/2019.

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







