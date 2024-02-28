# Credit card fraud detection

This project was developed by two classmates of mine (Ellada Aslanova and Shireesha Pothuganti) and I in 2021 for the "Fundamentals of Information Systems" exam, which was held by Professors Silvello and Di Nunzio and provided by the Mathematical Department for the course in Data Science.

This project was evaluated with a score of 3 points out of 4.

## Overview

For this project, the Professors provided us with a dataset containing transactions made by credit cards in September 2013 by European cardholders that occurred in two days. It contains 492 frauds out of 284,807 transactions, so the dataset is highly unbalanced (only 0.172% of all transactions are frauds).

The task was to design and build a system that automatically recognizes a fraudulent transaction.

## Main concepts

- PCA (Principal Components Analysis): it's one of the most common techniques used to reduce the dimensionality of the data, ergo the number of features analyzed. This is particularly useful when the data available are high dimensional. It selects the principal components (which are basically linear combinations of the original variables) that explain the most variance of the variables.
- IV (Information Value): it's a technique used in feature selection, which ranks the variables according to their importance for the prediction process. It is based on the WOE (Weight Of Evidence), which is an indicator of the predictive power of an independent variable on the dependent one often used in financial data analysis. Therefore, the procedure bins the variables into buckets according to the quantity of information they deliver to a potential classification model through Monotonic Binning, which is a data preparation technique widely used in scorecard development that converts numerical variables into categorical ones by creating bins that have a monotonic relationship with the target.
- VIF (Variance Inflation Factor): it's a measure of the increase of variance of the OLS (Ordinary Least Squares) coefficients caused by collinearity.
- SMOTE (Synthetic Minority Oversampling Technique): it's a technique that oversamples the records that belong to the minority class to overcome the problem posed by the fact that the data are unbalanced.
- Accuracy score: it's an indicator of the goodness of the prediction or classification computed by dividing the number of correct predictions made by the model by the total number of predictions.
- F1-score: it's an indicator of the goodness of the prediction or classification computed as the harmonic mean of the model's precision (proportion of true positive predictions over the number of predicted positives) and recall (proportion of true positive predictions over the number of actual positives).


## Project Structure

The Python notebook uploaded here contains all the steps conducted to implement the system:
1. EDA (Explorative Data Analysis): in this step, we evaluated the differences between fraudulent and non-fraudulent transactions, studied the correlation between variables using a heatplot, and analyzed their dispersion.
2. Data cleaning: in this step, we dealt with missing values, duplicated rows, and outliers. We found no missing values and proceeded to delete the duplicated rows. To address the issue, I created two functions - out_cleaner and change (you can view them in chunk 15). These functions were designed to remove observations that fell outside the InterQuartile Range (IQR). Due to the large number of observations in the dataset, this operation would have been very time-consuming if brought out in simpler ways.
3. Features selection: in this step, we computed the IV (given the fact that we had no way of interpreting the features, this was considered the best way of selecting the variables): for some variables the informative value was suspiciously high (according to Shiddiqi, values higher than 0.5 can be considered suspicious, as they're too good to be true). We then computed the VIF and decided to delete the variable relative to the amount of the transaction.
4. Training and validation: in this step, we applied the SMOTE and divided our data into two parts: 80% of the records were assigned to the train set and 20% to the test set. We then applied two models: logistic regression and XGBoost to classify our observations, which were evaluated according to the accuracy score and the F1-score.
5. Conclusions: we concluded the appropriateness of the features selected, as both models showed good values of accuracy (logistic regression: 0.9414; XGBoost: 0.9991).

## Corrections

As the project was elaborated at the start of my M.Sc. course, I'd like to make some notes on the work we've conducted:

- Given that the variables were computed through PCA, showing the heatplot and studying the correlation among the variables could've been avoided.
- I would've looked more in-depth at the outliers, as they could potentially be interesting cases to study, instead of just deleting them all.
- I wouldn't have deleted the feature "Amount", as I wouldn't have considered it a leaker variable.
- To overcome the problem of unbalanced data, given the high number of records available, I would've rather undersampled than oversampled.
- The evaluation of the models was based mainly on the accuracy score, but, in reality, it can be misleading as our goal was to identify the fraudulent cases: on the numerator, it has the sum of true positives and true negatives, therefore in the case of unbalanced data a model that classify all the observations as negatives would show a high accuracy score, but it would be useless for the goal of the analysis. It would've been better to evaluate the models according to the F1-score.
- The results reported on the confusion matrix are suspiciously high: there might be a leaker variable among the ones produced through PCA.
- I would've applied a forward hybrid stepwise selection to select the variables for the logistic regression model and analyzed the data through other models (for instance, a Random Forest). 






