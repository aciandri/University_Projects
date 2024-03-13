# Social demography project: education & number of children 
This project contains a social demographic analysis conducted using STATA that aims to study the association between the educational level and the number of children at the end of the reproductive age. Researchers have conducted various studies to inquire about the relation between education and the number of children throughout time, often reaching conflicting conclusions. The most recent ones didn't show any relevant association between the two variables. Therefore, in this report, I wanted to test this link net to control and intervening variables.

I worked on this analysis in 2020 for the "Social Demography" course, provided by the Statistics Department of the University of Florence.

The exam was composed of an oral exam and the project and received a score of 28 out of 30 points during the evaluation.

## Overview
For this project, I used a European Social Values (EVS) dataset containing  cross-national and longitudinal data collected through surveys in 1981-2008. It involved information about people's outlook on work, family, religion, politics and society collected over 166 502 observations divided in 4 waves.

I began selecting the records of interest and constructing the variables relevant to this analysis. Then, I conducted an univariate and bivariate graphic analysis of the variables and applied a regression model to the data. 

The results show a significant quadratic effect of the educational level on the number of children at the end of the reproductive age.

The full results and analysis are presented in the pdf report uploaded in this fold (in Italian).

## Project structure
The STATA code uploaded here contains all the steps conducted for the analysis:
### 1. Select records
I selected the observations that referred to women between the ages of 40 and 75 and, therefore, remained with 47 444 records.
### 2. Variables creation and selection
Since the features concerning the number of children changed throughout the different waves, I created a new variable to account for this feature and used it as the dependent variable of the analysis. I selected the continuous variable that pertains to the educational level as the independent variable. Both these features contained a limited number of missing values, which were, therefore, deleted.

I used the following as control variables:

- geographic area (grouped into 5 classes according to the type of welfare provided by the country);
- age;
- religiosity (as more educated women could have more nonconformal values, which, according to the Second Demographic Transition theory, are associated with lower fertility);
- gender equality (measured by the survey question: “Jobs are scarce: giving men priority”).

I used the following as intervening variables:

- income;
- age at first child: more educated women tend to delay the pregnancy due to career aspirations, which can limit their available time frame for having children. However, in some countries, there have been recoveries of postponed births among more educated women at an older age.
- partner's educational level;
- domestic labor division (measured by the survey question: “Men should take the same responsibility for home and children”).
- job.  

### 3. EDA: Graphical univariate analysis
In this step, I studied univariate marginal distributions of all the variables included in the analysis.

### 4. Multivariate analysis
In this step, I analyzed the bivariate and multivariate linear regression models, ergo the gross and net effects of the independent variable on the dependent one. In the latter, I also tried to insert quadratic and interaction effects.

I selected the following model:
![image](https://github.com/aciandri/University_Projects/assets/161453657/64e28ddc-e445-4835-b962-32a9e0a20c4b)

### Conclusions
This analysis showed a highly significant direct quadratic effect of education on the number of children at the end of the reproductive age: it shows a decrease of 0.0859 for each additional year of school up to approximately the age of 28 at the end of their studies, and then an increase of 0.00143 for higher ages (in line with the most recent evidence).

Furthermore, I found that:
- Women with a higher income tend to have more children net of the other variables studied. 
- Religious beliefs and gender equality opinions have a positive impact on the number of children a person has. 
- The delay in age at which one has their first child has been linked with a decrease in the number of children. 
- A highly significant negative interaction between the independent variable and the age at birth of the first child: as the latter increases, the effect of an extra year of education on the number of children decreases by 0.0498 points percentage, and the quadratic one increases by 0.0000623 percentage points.
- The analysis highlighted differences among the areas of residence: in general, all the zones observed presented a higher number of children per woman at the end of the reproductive age compared to Eastern Europe (which was used as the reference category), but only in Northern European and Central European countries this difference was statistically significant.
- Contrary to what was initially assumed, the results showed that as the partner's level of education increases, the number of children decreases.
- It seems that those who present a weaker opinion  (“agree” and “disagree”) on the topic “men should take the same responsibility for home and children”, tend to have fewer children on average than those who have a more "extreme" position ("agree strongly" and "disagree strongly"): if they agree with the statement, but with an intensity of less strong opinion, the difference with “agree strongly” is significant.
- With regard to the variable "job", taking "intermediate positions" as the reference category, women who carry out all other types of work have on average a higher number of children at the end of their reproductive age.








