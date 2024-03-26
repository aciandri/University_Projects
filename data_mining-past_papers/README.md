# Past papers for the exam of Data Mining (2023)
This folder contains some of the past papers I independently carried out to prepare for the “Data Mining“ exam held by Professor Bruno Scarpa and supplied by the Statistical Department of the University of Padua.

The exam was composed of a theoretical part and a practical one (the files contained in this folder are some examples of exam-like tasks) and had to be executed in about 3 hours total. I sustained the exam on 31/01/2024 and obtained a score of 26/30 (the highest grade assigned for that test).

## Contents of the course
The "Data Mining" course was focused on teaching how to face the new challenges brought by technological advancement in data analysis, for instance, the possibility of low-cost data gathering (e.g. through the development of automatic methods to collect data) often implies high dimensional datasets, which increase both the conceptual and computational complexity.

The main concepts introduced in the classes are contained in the book "Data Analysis and Data Mining" written by A. Azzalini and B. Scarpa.

In summary, it introduced the following concepts and methods to deal with the issues.

#### Overfitting
It is excessive optimism in evaluating a prediction model: if inappropriate tools/methods are used when assessing the goodness of a prediction (for instance, if the model is evaluated on the same data used to compute the prediction), then we will find that models that follow non-structural local changes in the data (which therefore are not present in new data we want to predict) are considered very appropriate to make predictions. Therefore, this is highly deceptive for a correct assessment of the prediction abilities of a model.

The course introduced 3 main ways to deal with it: training and test sets, cross-validation, and information criteria.

Other ways to deal with overfitting are:

- Dimensionality reduction (PCA, best subset selection, and automatic selection of the variables);
- Regularization methods (ridge regression model, lasso and adaptive lasso regression model, and elastic net model);
- Non-parametric models (K-NN, local regression and loess, regression and smoothing splines, and thin-plate splines and tensor-product splines).

#### Curse of dimensionality
We focused on the statistical curse of dimensionality, i.e. when using non-parametric methods in dealing with high-dimensional data, a high number of records is needed to get reliable results. As it is a problem closely tied to the absence of assumptions in a model, one way to deal with it is to integrate correct knowledge or assumptions in the model.

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







