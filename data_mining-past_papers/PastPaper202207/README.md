# Past paper 07/2022 : occhi
I worked on this past paper with some classmates of mine in November 2023 to prepare for the exam.

**Please take into account the small amount of time available when reading the analysis.**

## Task description
A cognitive neuroscience study aims to understand whether eye movement allows us to identify whether a person is lying or being sincere.

If this was possible, the research results could for example be used in forensics or provide suggestions for neuromarketing.

In an experiment, 100 participants were asked to tell two stories in front of a camera, one true (class=0) and another invented (class=1). During the telling of each story, the software collected the movements of the participant's eye. The instantaneous eye movement information was then synthesized into several indicators.
These refer, separately, to “gazes” or “fixations”.
Fixations are defined as a gaze in which the eyes stop for at least 100 milliseconds.

The occhi.csv dataset includes some results of the experiment.
For each fixation, the software provides the abscissa and ordinate positions and their duration, while for the glances the abscissa, ordinate, and instant of time in which the observations are recorded.

To simplify the analysis, the research group aggregated the information related to all the glances and fixations of each story using some
indicators:
- number (n),
- abscissa (x),
- ordinate (y),
- duration (duration),
- distance (horizontal: dx, vertical: dy, euclidean: deuclidean),
- time interval (dtime),
- speed (horizontal: speed_x, vertical: speed_y, directional: speed_euclidean),
- acceleration (horizontal: acc_x, vertical: acc_y, directional: acc_euclidean).

For each of these indicators, the following characteristics were recorded: mean, median, variance, standard deviation, maximum, minimum, and sum.

In order to have a measure that considered the specific effect of each participant, the researchers also recomputed all the variables for the subject without distinguishing between truthful stories and false stories, obtaining an average profile for each participant (_baseline_).
For each variable, the difference of the observed variables with the average profile (_baseline_) for each participant was then obtained. These quantities are reported in the dataset and indicated with the prefix subj.

Finally, some information is available on the participant (gender, age) and the experiment (tester_id, tester_quality_grade_x, tester_quality_grade_y).

## Project structure
### 1 - Data cleaning and dataset preparation
The dataset used contained 198 observations over 418 variables. In order to prepare the dataset for the analysis, the following operations were carried out:
- The following variables were eliminated:
    * “index”, as the row indicator;
    * “item_id”, as a leaker variable.
    * “tester_display_id”, as it contains redundant information (already present in the “tester-id”);
    * deviation from the subject's baseline variables, as the participant's effect is not of interest: in reality, we do not have a baseline;
    * the variance and the median variables: the dataset contains the standard deviation and the mean, therefore the two deleted variables contain redundant information. The latter contained similar information to the median variable, which, although a robust indicator, was not available for all the variables and it was therefore considered more reasonable to consider the mean.
    * “study_id”, as it is not useful for the purpose of the study;
- There were 64 constant variables, which were eliminated.
- The variables are divided into quantitative and qualitative and variables that have less than 6 unique values ​​are transformed into factors. At the end of this step, we therefore had 4 qualitative explanatory variables and 130 quantitative variables.
- We checked for missing values and found 12 relating to 6 people. We then looked at the age distribution in the sample and found that it is highly asymmetric: it was decided to impute the values ​​to the median, i.e. 23 years.

At the end of these operations, the resulting dataset to be used for the analysis was composed of 198 observations over 135 variables.
In order to manage the overfitting problem, given the small number of observations available, we decided to carry out a 4-fold cross-validation. Since it was not reasonable to assume independence between observations belonging to the same subject, we assigned the observations relating to the same subject to the same fold.

### 2 - Brief explorative analysis
In this step, we looked at the marginal distribution of the dependent variable (i.e., class) and found it to be a balanced dichotomic variable.
We also noticed the presence of high correlations (more than 0.95) among 94 variables. Therefore, in the next steps of the analysis, we focused on models that are not highly negatively impacted by the presence of collinearity.

### 3 - Models
In this step, we estimated and evaluated the accuracy score for some models:

- Regularized models:
  * Ridge regression model: We started by considering the ridge estimator (penalty in L2 norm), created precisely to manage the collinearity between the explanatory variables. We executed the following steps:
    1. we started by estimating the model on all the data and using a grid of regularization parameters that takes 150 values ​​between exp(-15) and exp(4).
    2. We then carried out a 4-fold cross-validation procedure, saving the errors computed for each lambda value of the grid at each iteration.
    3. We computed the error average for each value of lambda and, according to this result, chose $\lambda =7.36064e-05$. The accuracy score of this method is 0.5502.
  * Adaptive lasso regression model: we then estimated a lasso linear model (penalized in L1 norm) using a process similar to the one described above for ridge regression. To overcome the collinearity problem, which would lead to the violation of the irrepresentable condition (and therefore to the possibility of obtaining an incorrect variable selection), we applied an adaptive lasso. We used the inverse of the ridge regression coefficients in absolute value as the penalization factor.
We used a lambda grid containing 150 values ​​between exp(-8) and exp(10) and selected $\lambda = 0.0029$. The model has an accuracy equal to 0.5913.
Being a normalization L1 norm, this model automatically selects the most relevant variables: in this case, it chose a model with 78 terms, including the intercept.
- Classification tree: given that the data refers to characteristics of gaze and fixations, it may be reasonable to consider the importance of interactions (e.g., a specific movement could indicate different things based on its variation). It was, therefore, decided to proceed with the analysis of a classification tree, a model known to overemphasize interactions:
  1. Growth process: we started estimating a complete tree on all the data, setting the minimum number of observations per leaf equal to 2 and the minimum deviance to allow a subdivision (split) equal to 0.00001 in the growth process, to make the tree grow as deep as possible.
  2. Pruning phase: we used a 4-fold cross-validation operation to select the optimal tree size. The errors obtained were then combined through the average and selected a tree of size 2 according to the accuracy maximization criterion.
  3. Following the growth and pruning procedures (aimed respectively at minimizing the residual deviance and avoiding overfitting of the model), the resulting tree has an accuracy equal to 0.5406 and selected 2 features: the average duration of the fixations and the sum of the ordinates of the glances.

In conclusion, none of these models seemed to indicate that eye movements are a good indicator of the sincerity of a person.







