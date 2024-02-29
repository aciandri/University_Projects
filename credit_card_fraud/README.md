# Credit card fraud detection
This project contains a classification analysis that aims to identify fraudulent credit card transactions.

Me and two classmates of mine (Ellada Aslanova and Shireesha Pothuganti) realized this analysis in 2021 for the "Fundamentals of Information Systems" exam, which was held by Professors Silvello and Di Nunzio and provided by the Mathematical Department for the course in Data Science.

The project received a score of 3 out of 4 points during the evaluation.

## Overview

For this project, the Professors provided us with a dataset containing transactions made by credit cards in September 2013 by European cardholders that occurred in two days. It contains 31 features (28 of which were computed through PCA) collected over 284,807 transactions. The dataset is highly unbalanced, as only 0.172% of all transactions are frauds.

The task was to design and build a system that automatically recognizes a fraudulent transaction. In order to achieve this, we executed an EDA, data cleaning and feature selection operations. We then applied the SMOTE and split the observations between train and test sets. 
To classify the records, we used two models:
- Logistic regression: a parametric generalized linear model which is characterized by a logit link function, which makes the model appropriate for the analysis of binomial dependent variables.
- XGBoost (Extreme Gradient Boosting): a semi-parametric method based on the combination of the results of different weaker models, that aims to minimize the classification error: in every iteration, it constructs a weak model, which learns from the mistakes made by the former one.

The results are evaluated mainly through the accuracy score, which shows a good predictive power of the variables considered in the dataset.

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
3. Features selection: in this step, we computed the IV (given the fact that we had no way of interpreting the features, this was considered the best way of selecting the variables): for some variables the informative value was suspiciously high (according to Shiddiqi, values higher than 0.5 can be considered suspicious, as they're too good to be true). We then computed the VIF and decided to delete the variable relative to the amount of the transaction as it was considered "too good" and therefore a potential leaker.
4. Training and validation: in this step, we applied the SMOTE and divided our data into two parts: 80% of the records were assigned to the train set and 20% to the test set. We then applied two models: logistic regression and XGBoost to classify our observations, which were evaluated according to the accuracy score and the F1-score.
5. Conclusions: we concluded the appropriateness of the features selected, as both models showed good values of accuracy (logistic regression: 0.9414; XGBoost: 0.9991).

## Enhancements and Learnings

As the project was elaborated at the start of my M.Sc. course, I'd like to highlight some potential improvement I'd make in the work we've conducted, based on the knowledge I've gained since then:

- Given that the variables were computed through PCA, showing the heatplot and studying the correlation among the variables could've been avoided.
- I would've looked more in-depth at the outliers, as they could potentially be interesting cases to study, instead of just deleting them all.
- I wouldn't have deleted the feature "Amount", as I don't see any relevant reason why it would be considered a leaker.
- To overcome the problem of unbalanced data, given the high number of records available, I would've rather undersampled than oversampled. Furthermore using the oversampling techniques with such a low number of positive cases could lead to overfitting, i.e. the models could recognize non-structural patterns as patterns to identify the class of interest.
- The evaluation of the models was based mainly on the accuracy score. However, in reality, it can be misleading as our goal was to identify the fraudulent cases in a very unbalanced dataset: the index depends on both the sum of true positives and true negatives, therefore in the case of unbalanced data a model that classify all the observations as negatives would show a high accuracy score, but it would be useless for the goal of the analysis. It would've been better to evaluate the models according to the F1-score.
- The results reported on the confusion matrix are suspiciously high, which suggest there might be a leaker variable among the ones produced through PCA. Since the variables aren't interpretable in any way, a possible solution could be to adapt a Classification Tree and analyze (and eventually remove) the variable selected for the root of the binary tree.
- Given that the dimensionality of the data is not small, I would've applied a forward hybrid stepwise selection to select the variables for the logistic regression model and analyzed the data through other models (for instance, a Random Forest, which is based on the combination of weaker models and it's a good instrument for prediction and feature selection). 






