# Credit card fraud detection

This project was developed by two classmates of mine (Ellada Aslanova and Shireesha Pothuganti) and I in 2021 for the "Fundamentals of Information Systems" exam, which was held by Professors Silvello and Di Nunzio and provided by the Mathematical Department for the course in Data Science.

This project was evaluated with a score of 3 points out of 4.

## Overview

For this project, the Professors provided us with a dataset containing transactions made by credit cards in September 2013 by European cardholders that occurred in two days. It contains 492 frauds out of 284,807 transactions, so the dataset is highly unbalanced (only 0.172% of all transactions are frauds).

The task was to design and build a system that automatically recognizes a fraudulent transaction.

## Installation

Provide instructions on how to install and set up your project. List any dependencies.

## Usage

Explain how to use your project. Provide code examples or commands for common use cases.

## Screenshots/Demos

Include screenshots or GIFs showcasing your project. Optionally, provide links to live demos.

## Main concepts

- PCA (Principal Components Analysis): it's one of the most common techniques used to reduce the dimensionality of the data, ergo the number of features analyzed. This is particularly useful when the data available are high dimensional. It selects the principal components (which are basically linear combinations of the original variables) that explain the most variance of the variables.
- IV (Information Value): it's a technique used in feature selection, which ranks the variables according to their importance for the prediction process. It is based on the WOE (Weight Of Evidence), which is an indicator of the predictive power of an independent variable on the dependent one often used in financial data analysis. Therefore, the procedure bins the variables into buckets according to the quantity of information they deliver to a potential classification model through Monotonic Binning, which is a data preparation technique widely used in scorecard development that converts numerical variables into categorical ones by creating bins that have a monotonic relationship with the target.
- VIF (Variance Inflation Factor): it's a measure of the increase of variance of the OLS (Ordinary Least Squares) coefficients caused by collinearity.
- SMOTE (Synthetic Minority Oversampling Technique): it's a technique that oversamples the records that belong to the minority class in order to overcome the problem posed by the fact that the data are unbalanced.
- Accuracy score: it's an indicator of the goodness of the prediction or classification computed dividing the number of correct predictions made by the model by the total number of predictions.
- F1-score: it's an indicator of the goodness of the prediction or classification computed as the harmonic mean of the model's precision (proportion of true positive predictions over the number of predicted positives) and recall (proportion of truw positive predictions over the number of actual positives).


## Project Structure

The Python notebook uploaded here contains all the steps conducted to implement the system:
1. EDA (Explorative Data Analysis): in this step we had a first look at the data, evaluating the differences between fraudulent and non-fraudulent transactions and studying the correlation among the variables (presented through a heatplot) and their dispersion.
2. Data cleaning: in this step, we dealt with missing values, duplicated rows, and outliers. We proceeded to delete the rows containing missing values and duplicated rows. For the former, I wrote the functions out_cleaner and change (viewable in chunk 15): it could've been done more easily, but the high number of observations present in the dataset made it very time-consuming.
3. Features selection: in this step, we computed the IV: for some variables the informative value was sospiciously high (according to Shiddiqi, values higher than 0.5 can be considered sospicious, as they're too good to be true). We then computed the VIF and decided to delete the variable relative to the amount of the transaction.
4. Training and validation: in this step, we applied the SMOTE and divided our data into two parts: 80% of the records were assigned to the train set and 20% to the test set. We then applied two models: logistic regression and XGBoost to classify our observations, which were evaluated according to the accuracy score and the F1-score.

Explain the structure of your project, highlighting the purpose of major directories or files.

## Contributing

If open to contributions, explain how others can contribute to the project.

## License

Specify the license under which your project is distributed.

## Contact Information

Provide your contact information or a way for interested parties to reach out to you.

## Acknowledgments

Give credit to any third-party libraries, tools, or resources you used.
