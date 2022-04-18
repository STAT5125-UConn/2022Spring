# Homework 5

## Step 1 (Due on Monday April 25 at 8:00 PM ET)

Submission link: https://classroom.github.com/a/Ip78qBFa

### Q1

In an article titled "[Zero correlation between state homicide rate
and state gun laws](https://www.washingtonpost.com/news/volokh-conspiracy/wp/2015/10/06/zero-correlation-between-state-homicide-rate-and-state-gun-laws/)", Eugene Volokh examined the relationship between the total number of gun deaths (per 100,000 people) and gun laws. He used the "Brady score', which represents how difficult it is to obtain a gun in a state.
A low Brady scores means a low level of gun restrictions (so it is easier to obtain a gun), and a high score means that it is harder to get a gun (i.e. there are stricter gun laws).
The data set, available in the file [guns.csv](./guns.csv), contains the following variables:

- State: State name
- HomicideRate: Number of homicide death per 100,000 people
- GunAccidentRate: Number of gun accident death per 100,000 people
- Sum: The summation of homicide rate and gun accident rate
- BradyScore: The Brady score represents how difficult it is to obtain a gun in a state.
- BradyLetter: Discretized letter interpretation of Brady Score
- BradyLH: Discretized Brady Score in to low (L) and high (H).

Answer the following questions.

1. Create a plot showing Eugene Volokh's opinion of zero correlation between state homicide rate and state gun laws. Clearly label the x-axis and y-axis.

2. Create a pie plot to present the frequency of the discretized letter interpretation of Brady Score (BradyLetter).

3. Create a plot with two overlay histograms for homicide death rate -- one for the low Brady Score group and the other for the high Brady Score group.

4. Create a plot with two boxplots for gun accident rate -- one for the low Brady Score group and the other for the high Brady Score group.

5. Create a scatter plot for the Brady Score, label all the points by the corresponding states, and use color of the points to show the homicide rate. Control the parameters to make the figure look nicer, e.g, make sure the font of the state names are not too small or too large. 

### Q2

A famous example of Simpson's paradox is a study of gender bias among graduate school admissions to University of California, Berkeley. In 1973 UC Berkeley was sued for sex-discrimination. Here are the overall numbers for the six largest departments in fall admission of 1973: among the 2691 men applicants 1198 were admitted while among the 1835 women applicants 557 were admitted. This shows that men were more likely than women to be admitted, and the difference was so significant. To see which departments were mainly responsible for this gender bias, the data were broke open according to each departments as shown below.

| Department | Men Applicants | Men Admitted | Women Applicants | Women Admitted |
| ---------- | -------------- | ------------ | ---------------- | -------------- |
| A          | 825            | 512          | 108              | 89             |
| B          | 560            | 353          | 25               | 17             |
| C          | 325            | 120          | 593              | 202            |
| D          | 417            | 138          | 375              | 131            |
| E          | 191            | 53           | 393              | 94             |
| F          | 373            | 22           | 341              | 24             |

Things get strange after we divide the data according different departments. For the six departments, four of them accepted women more than men. The reason is that women tended to apply to more competitive departments with low admission rates even among qualified applicants, whereas men tended to apply to less competitive departments with high admission rates among the qualified applicants.

Create figure(s) using the Berkeley data to illustrate and interpret the aforementioned paradox. Note that there is no right or wrong for your answer to this question. Just try to be creative and explain your visualization(s).

## Step 2 (Due on Friday April 22 at 8:00 PM ET)

Give another two students (to be specified in the FeedbackList.md) access to your submission repository so that they can push their feedback to it.

Fill the feedback forms on another two students' work and push the forms to their homework repositories that they give you access to. 
