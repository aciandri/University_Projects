# Past paper 07/2022 : occhi
I worked on this past paper with some classmates of mine in November 2023 to prepare for the exam.

## Task description
A cognitive neuroscience study aims to understand whether eye movement allows us to identify whether a person is lying or being sincere.

If this was possible, the research results could for example be used in forensics or provide suggestions for neuromarketing.

In an experiment, 100 participants were asked to tell two stories in front of a camera, one true (class=0) and another invented (class=1). During the telling of each story, the software collected the movements of the participant's eye. The instantaneous eye movement information was then synthesized into several indicators.
These refer, separately, to “gazes” or “fixations”.
Fixations are defined as a gaze in which the eyes stop for a minimum of 100 milliseconds.

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






