# Credit card fraud detection
This project contains a classification analysis that aims to identify fraudulent credit card transactions.

Me and two former classmates of mine (Ellada Aslanova and Shireesha Pothuganti) realized this analysis in 2021 for the "Fundamentals of Information Systems" exam. The course was held by Professors Silvello and Di Nunzio and was provided by the Mathematical Department of the University of Padua for the course in Data Science.

The project scored 3 out of 4 points during the evaluation.

## Overview

For this project, the Professors provided us with a dataset containing transactions made in two days in September 2013 by credit cards by European cardholders. It's made up of 31 features (28 were computed through PCA) collected over 284,807 transactions. The dataset is highly unbalanced, as only 0.172% of all transactions are frauds.

The task was to design and build a system that automatically recognizes a fraudulent transaction. In order to achieve this, we executed an EDA (Explorative Data Analysis), data cleaning, and feature selection operations. We then applied the SMOTE and split the observations between train and test sets. 
To classify the records, we used two models:
- Logistic regression: a parametric generalized linear model characterized by a logit link function, which makes it an appropriate model for the analysis.
- XGBoost (Extreme Gradient Boosting): a semi-parametric method that combines the results given by different weaker models. It aims to minimize the classification error learning from the mistakes made by each weaker model.

We evaluated model performance using the accuracy score and found that the dataset variables had good predictive power.

## Main concepts

- PCA (Principal Components Analysis): it's one of the most common techniques used to reduce the dimensionality of the data, ergo the number of features analyzed. It is especially useful when the data available are high dimensional, as it selects the principal components (linear combinations of the original variables) that explain the most variance of the features.
- IV (Information Value): it's a technique used in feature selection, that ranks the variables according to their importance for the prediction process. It is based on the WOE (Weight Of Evidence), which is an indicator of the predictive power of a variable often used in financial data analysis. Therefore, the procedure bins the variables into buckets according to the quantity of information they deliver to a potential classification model through Monotonic Binning (a data preparation technique widely used in scorecard development that converts numerical variables into categorical ones by creating bins that have a monotonic relationship with the target).
- VIF (Variance Inflation Factor): it's a measure of the increase of the variance of the OLS (Ordinary Least Squares) coefficients caused by collinearity.
- SMOTE (Synthetic Minority Oversampling Technique): it's a technique that oversamples the records that belong to the minority class to overcome the problem posed by unbalanced datasets.
- Accuracy score: it's an indicator of the goodness of the classification computed by dividing the number of correct predictions made by the model by the total number of predictions.
- F1-score: it's an indicator of the goodness of the classification computed as the harmonic mean of the model's precision (proportion of true positives over the number of predicted positives) and recall (proportion of true positives over the number of actual positives).


## Project Structure

The Python notebook uploaded here contains all the steps conducted to implement the system:
1. EDA (Explorative Data Analysis): in this step, we evaluated the differences between fraudulent and non-fraudulent transactions, studied the correlations among the variables using a heat plot, and analyzed their dispersion.
2. Data cleaning: in this step, we dealt with missing values, duplicated rows, and outliers. We found no missing values and deleted the duplicated rows. To address the issue posed by the outliers, I created two functions - out_cleaner and change (you can view them in chunk 15), that remove observations that fell outside the InterQuartile Range (IQR). 
3. Features selection: in this step, we computed the IV (since we had no way of interpreting the features, we deemed it best to proceed in this way): for some variables, the Informative Value was suspiciously high. We then computed the VIF and decided to delete the variable "amount" of the transaction as it was considered "too good" and, therefore, a potential leaker.
4. Training and validation: in this step, we applied the SMOTE and divided our data into two parts: 80% of the records were assigned to the train set and 20% to the test set. We then applied logistic regression and XGBoost to classify our observations and evaluated their results according to the accuracy score and the F1-score.
5. Conclusions: we concluded the appropriateness of the selected features, as both models showed good accuracy (logistic regression: 0.9414; XGBoost: 0.9991).

## Enhancements and Learnings

In this section, I'd like to highlight some potential improvements I'd make in the work we've conducted in 2021, based on the knowledge I've gained since then:

- Given that the variables were computed through PCA, showing the heat plot and studying the correlation among the variables could've been avoided.
- I would've looked more in-depth at the outliers, as they could potentially be interesting cases to study, instead of just deleting them all.
- I wouldn't have deleted the feature "Amount" as I don't see any relevant reason why it would be considered a leaker.
- To overcome the problem of unbalanced data, given the high number of records available, I would've rather undersampled than oversampled. Furthermore, using the oversampling techniques with such a low number of positive cases could lead to overfitting, i.e. the models could recognize non-structural patterns as leads to identify the class of interest.
- The evaluation of the models was mainly based on the accuracy score. However, its use in unbalanced datasets where the goal is to identify minority cases can be misleading, as it depends on both the true positives and the true negatives. Therefore, a model that classifies all the observations as negatives would show a high accuracy score, but it wouldn't be valuable for the analysis objective. It would've been better to evaluate the models according to the F1-score.
- The results reported on the confusion matrix are suspiciously high, suggesting that there might be a leaker variable among the ones produced through PCA. Since the variables aren't interpretable in any way, a possible solution could be to fit a Classification Tree and analyze (and eventually remove) the variable selected for the root of the binary tree.
- Given that the dimensionality of the data is not small, I would've applied a forward hybrid stepwise selection to select the variables used in the logistic regression model and try to fit other models (for instance, a Random Forest, which combines the results of weaker models and it's a good instrument for prediction and feature selection). 






