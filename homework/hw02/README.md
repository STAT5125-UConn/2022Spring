# hw02

## Step 1 (Due on Friday February 18, 2022, 20:00 EDT)

Submission link: https://classroom.github.com/a/MnJwYv3n

### 1. Sum square difference
Run the following code to generate data $$x$$ and $$y$$. 

```julia
using Random; Random.seed!(2022);
n = 100
x = randexp(n)
y = x .+ randn(n)
```
**Without** `using` any additional packages, write your own code to calculate the [Pearson sample correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient) between $$x$$ and $$y$$.

$$
r_{xy} = \frac{\sum_{i=1}^n (x_i - \bar{x})(y_i - \bar{y})}
{\sqrt{\sum_{i=1}^n (x_i - \bar{x})^2}\sqrt{\sum_{i=1}^n (y_i - \bar{y})^2}},
$$

where $$\bar{x}$$ and $$\bar{y}$$ are the sample means of $$x$$ and $$y$$. 


### 2. Check valid triangle

The file [triangle.csv](./triangle.csv) contains 100000 rows of three numbers. Find the number of rows such that the three numbers can make triangles if we take them as side lengths of a triangle.

## Step 2 (Due on Monday February 02/21 at 8:00 PM ET) 

- Give another two students (to be specified in the FeedbackList.md) access to your submission repository so that they can push their feedback to it.

- Fill the feedback forms on another two students' work and push the forms to their homework repositories that they give you access to. 

