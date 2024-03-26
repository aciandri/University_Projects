# Past papers for the exam of Data Mining (2023)
This folder contains some of the past papers I independently carried out to prepare for the “Data Mining“ exam held by Professor Bruno Scarpa and supplied by the Statistical Department of the University of Padua.

The exam was composed of a theoretical part and a practical one (the files contained in this folder are some examples of exam-like tasks) to be done in about 3 hours total. I sustained the exam on 31/01/2024 and obtained a grade of 26/30 (the highest grade assigned for that test).

## Contents of the course
The "Data Mining" course focused on teaching how to face the new challenges in data analysis brought by technological advancement. For instance, the possibility of low-cost data gathering (e.g., through the development of automatic methods to collect data) often implies high dimensional datasets, which increase both the conceptual and computational complexity.

The main concepts introduced in the classes are described in the book "Data Analysis and Data Mining" written by A. Azzalini and B. Scarpa.

In summary, it introduced the following concepts and methods to deal with the issues.

#### Overfitting
It is excessive optimism in evaluating a prediction model: if inappropriate tools or methods are used when assessing the goodness of a prediction (for instance, if the model is evaluated on the same data used to compute the prediction), then we will find that models that follow non-structural local changes in the data (which therefore are not present in new data we want to predict) are considered very appropriate to make predictions. Therefore, this is highly misleading for an accurate assessment of a model's prediction abilities.

The course introduced 3 main ways to deal with it: training and test sets, cross-validation, and information criteria.

Other ways to deal with overfitting are:

- Dimensionality reduction (PCA, best subset selection, and automatic selection of the variables);
- Regularization methods (ridge regression model, lasso and adaptive lasso regression model, and elastic net model);
- Non-parametric models (K-NN, local regression and loess, regression and smoothing splines, and thin-plate splines and tensor-product splines).

#### Curse of dimensionality
We focused on the statistical curse of dimensionality, i.e., when using non-parametric methods in dealing with high-dimensional data, a high number of records is needed to get reliable results. As it is a problem closely tied to the absence of assumptions in a model, one way to deal with it is to integrate correct knowledge or assumptions in the model.

To overcome this problem, the following models were introduced (both in the classification and prediction contests):

- Additive Models and GAM;
- Projection Pursuit Regression;
- MARS (Multivariate Adaptive Regression Splines);
- Regression and classification trees;
- Neural Networks: only the simple one hidden layer neural network was implemented in R. We also got a theoretical introduction to how deep, convolutional, and recursive neural networks work.

We also received an introduction to conformal inference (e.g., split conformal and CQR) to compute marginal prediction intervals.

For classification problems, the following methods were also introduced:

- Logistic regression;
- Discriminant analysis (linear and quadratic);
- SVM;
- Combination of classifiers: Bagging, Random Forest, and Boosting (in particular, we studied the Ada boosting algorithm).

## Overview of the projects

### [PastPaper 07/2022 - occhi](https://github.com/aciandri/University_Projects/tree/main/data_mining-past_papers/PastPaper202207)
I worked on this past paper in November 2023 with some classmates of mine to prepare for the exam on "data mining". 

The task was to study whether eye movements are a good indicator of the sincerity of a person. The professor supplied us with a dataset containing 198 observations over 418 variables relative to some aggregated information about glances and fixations of the subjects (e.g., number, abscissa, duration, etc) over which were reported some indicators (e.g., mean, variance, etc). The data were gathered through an experiment in which 100 participants were asked to tell 2 stories in front of a camera (one true and one false). During the storytelling, the software collected the movements of the participant's eyes.

During this analysis, we proceeded with the following steps:
1. data cleaning: we deleted some variables (row indicator, leaker variables, redundant features, and constant variables) and imputed the missing values to their median.
2. Brief explorative analysis: we looked at the marginal distribution of the dependent variable (balanced dichotomic variable) and checked the correlations among the independent variables.
3. Models: we applied the ridge regression model, the adaptive lasso regression model (through pathwise coordinate descent), and a classification tree.





