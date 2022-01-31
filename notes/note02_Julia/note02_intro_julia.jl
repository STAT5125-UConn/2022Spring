#' # A short introduction to Julia

#' ## Some useful commands in Julia REPL:

#' - ? (enters help mode);
#' - ; (enters system shell mode);
#' - ] (enters package manager mode);
#' - Ctrl-c (interrupts computations);
#' - Ctrl-d (exits Julia);
#' - Ctrl-l clears screen;
#' - putting ; after the expression will disable showing its value in REPL.

#' ## Examples of some essential functions:
pwd() # get current working directory
# change directory to /home/ossifragus/Dropbox/teaching/5125/note02_Julia/
cd("/home/ossifragus/Dropbox/teaching/5125/notes/note02_Julia/")
# For Mac and Linux, use this format 
# cd("/home/ossifragus/Dropbox/teaching/5125/notes/note02_Julia/");
# for Windows, use this format 
# cd("C:\\Users\\hwzq7\\Dropbox\\teaching\\5125\\notes\\note02_Julia"). 

#' execute source file
include("pi.jl") 

#' exit Julia
#+ eval=false
exit()

#' ## Strings
#' String operations:
"Hi " * "there!"       # string concatenation
"Ho " ^ 3              # repeat string
string("a = ", 123.3)  # create using print function
repr(123.3)            # fetch value of show function to a string
occursin("CD", "ABCD") # check if the second string contains the first
"\"\n\t\$"             # C-like escaping in strings, new \$ escape
x = 123
"$x + 3 = $(x+3)"      # unescaped $ is used for interpolation

"\$199"                # to get a $ symbol you must escape it
s = "abc"              # a string of type String
chop(s)                # remove last character from s, returns a SubString

#' ## Vector and Matrix
#' Define a vector
x = [121, 98, 95, 94, 102, 106, 112, 120, 108, 109]
#' Define a matrix
xx = [123 2 3]
#' Define a character vector
w = ["F","M","M","F","F","M","M","F","M","M"]

#' Use `.` to broadcast. For example, define y to be the log transformation of x.
y = log.(x)

#' Construct a 10 by 2 matrix, with columns x and y combine by columns
mat = hcat(x, y)
mat = [x y]
#' Combine by rows
[x; y]
#' The following will create an array of arrays with length 2
tmp = [x, y, "a", 'a']

#' Add another row to the data set
new = [100 log(100)]
mat2 = vcat(mat, new)
[mat; new]
#' Check the dimension of a matrix
size(mat2)
#' The number of columns of a matrix
size(mat2, 2)
#' The number of rows of a matrix
size(mat2, 1)
#' Value in the third row and the second column of mat
mat[3,2]
#' The first three rows of mat
mat[1:3, :]
#' The second column of mat
mat[:, 2]
#' Exclude the second row
mat[setdiff(1:end, 2), :]
#' Exclude the second column
mat[:,setdiff(1:end, 2)]

setdiff(1:8, [3, 5])

# 't' will be removed
setdiff([1, 3, "true", 't', rand(3)], "true")

# "true" will be removed
setdiff([1, 3, "true", 't', rand(3)], ["true"])

#' Take a look at the first 5 rows. The function view does not make copy of the elements of dat, but dat[1:5, :] create a new 5 by 8 matrix.
dat1 = mat[1:5, 1:2]
dat2 = view(mat, 1:5, 1:2)

dat1[1,1] = 0
dat2[1,1] = 0

#' ## Arithmetics and simple functions
x .+ y
z = x .- y
x .* y
2x
x.^2
2 .^x
Int128(2).^x

#' Summation of all the elements in x
sum(x)
#' Summation of the 2nd, 3rd and the 5th elements of x
sum(x[[2,3,5]])
#' Product of all the elements in x
convert.(Int128, [1, 2])
Int128[1, 5]
prod(x)
prod(Int128.(x))
prod(convert.(Int128, x))
BigInt.(x)
BigInt(10)^1000
BigFloat(0.1)^1000
#' Product of all the elements in x except the first two
prod(convert.(Int128, x[3:end]))

#' logic operation
sum(x) > 10
#' number of "F" in the vector w
sum(w.=="F")
#' returns 1 if true and 0 if false
x[1]>10 ? 1 : 0
#' another example
a = 2
a>10 ? println("hello") : println("Hi")

#' There are standard programming constructs:
if false    # if clause requires Bool test
    🍎 = 1
elseif 1 == 2
    🍑 = 2
else
    💔 = 3
end        # after this 💔 = 3, and 🍎 and 🍑 are undefined

#' As showed above, Julia support unicode characters. 
#' Greek letters can be input like LaTeX, e.g., 
α = 0.05
β = 0.8
#' See this link for a list of tab completion of LaTeX style input:
#' https://docs.julialang.org/en/v1/manual/unicode-input/

#' ## Statistics
using Statistics
#' Calculate the sample mean (average)
mean(x)
#' Calculate the sample standard deviation
std(x)
#' Calculate the correlation of y and x
y = x .+ 10randn(length(x))
cor(y,x)
#' Compute the median of x
median(x)
#' Compute the 90th percentile of x
quantile(x, 0.9)
#' compute the 0th, 25th, 50th, 75th, 100th percentiles of x
quantile(x, [0.0, 0.25, 0.5, 0.75, 1.0])

#' ## Importing and Exporting data in delimited format
using DelimitedFiles
#' Make sure the data is in the working directory, or you can change the directory to where the data is saved, using `cd(path)`. 
#' For Mac and Linux, use this format 
#' `path = "/home/ossifragus/Dropbox/teaching/5125/notes/note02_Julia"`; 
#' for Windows, use this format 
#' `path = "c:\\Users\\ossifragus\\Dropbox\\teaching\\5125\\notes\\note02_Julia"`. 
dat = readdlm("USairpollution.csv", ',', Any, '\n')
dat = readdlm("USairpollution.csv", ',')
dat = readdlm("USairpollution.csv", ',', header=true)
dat = readdlm("USairpollution.csv", ',', skipstart=1)
#' The complete director can also be used.
dat = readdlm("/home/ossifragus/Dropbox/teaching/5125/notes/note02_Julia/USairpollution.csv", ',', skipstart=1)
#' Export dat
writedlm("dataNew.csv", dat, ",")
writedlm("dataNew.csv", dat)

#' ### DataFrames
#' `DataFrams` and `CSV` are very useful packages.
#' Run the following code for the first time to install these packages.
#+ eval=false
using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")
#' It needs precompiling for the first time use.
using DataFrames, CSV
dat1 = CSV.read("USairpollution.csv", DataFrame)
#' Export dat
CSV.write("data1.csv", dat1)

#' ## Random number generation
#' rand is the base random generation function.
using Random, Distributions, Statistics # load packages
Random.seed!(8) # set seed of random
#' Generate a 10 by 1 vector of random numbers from U(0, 1)
rand(10)
#' Generate a 3 by 4 matrix of random numbers from U(0, 1)
rand(3, 4)
#' Generate a 3 by 4 matrix of random numbers from N(0, 1)
randn(3, 4)
#' Generate a 3 by 4 matrix of random numbers from EXP(1)
randexp(3, 4)

#' A convention in Julia: appending ! to names of functions that modify their arguments.
a = rand(1:9, 9)
sort(a)
sort!(a)

#' Use the Distributions package, we can define various distributions and generate randoms from them. For example, generate 100 data points from $N(\mu=0, \sigma^2=2^2)$.
x = rand(Normal(0, 2), 100)
#' Check the mean and standard deviation
(mean(x), std(x))

#' Generate 10 data points from multivariate normal distribution $N\bigg\{\mu=\binom{0}{3}, \Sigma=\begin{pmatrix}1&2\\2&5\end{pmatrix}\bigg\}$. Note that julia support unicode variables (https://docs.julialang.org/en/v1/manual/unicode-input/).
μ = [0; 9]
Σ = [1.0 2; 2 5]
mvn = MvNormal(μ, Σ)
x = rand(mvn, 1000)
#' Check the sample mean vector
mean(x, dims=2)
#' and the sample covariance matrix
# cov(x')
cov(x, dims=2)

#' ## Plot
#' Create a histogram. The first plot takes a long time. 
using Plots
histogram(x[1, :])
#' Plot the two components of x.
plot(x')
#' Create a scatter plot
plot(x[1, :], x[2, :], seriestype=:scatter)

#' ## Loops
x = 1:10
collect(x)
s = 0
for i in 1:length(x)
    global
    s += x[i]
end

i = 1
while true
    global i += 1
    if i > 10
        break
    end
end

for x in 1:10    # x in collection, can also use = here instead of in
    if 3 < x < 6
        continue # skip one iteration
    end
    println(x)
end              # x is defined in the inner scope of the loop

#' Create arrays using for loop
[x^2 for x in 1:5]
[i+j for i in 1:3, j in 2:6]
ρ, p = 0.6, 7
[ρ^abs(i-j) for i in 1:p, j in 1:p]
#' Of course, there are other ways to create arrays
ρ.^abs.((1:p) .- (1:p)')
(1:p) .- (1:p)'

#' ## Self-defined functions
function fsum(x)
    n = length(x)
    s = 0
    for i in 1:n
        s += x[i]
    end
    return s
end
fsum(x)

f(x, y = 10) = x .+ y # one line definition of a new function

function f(x, y=10) # the same as above
    x + y
end

#' ## Measure performance with `@time` and pay attention to memory allocation
#' A useful tool for measuring performance is the `@time`.
x = rand(1000);
function sum_global()
    s = 0.0
    for i in x
        s += i
    end
    return s
end;

@time sum_global()

@time sum_global()

#' On the first call (`@time sum_global()`) the function gets compiled. (If you've not yet used `@time`
#' in this session, it will also compile functions needed for timing.)  You should not take the results
#' of this run seriously. For the second run, note that in addition to reporting the time, it also
#' indicated that a significant amount of memory was allocated. We are here just computing a sum over all elements in
#' a vector of 64-bit floats so there should be no need to allocate memory (at least not on the heap which is what `@time` reports).

#' Unexpected memory allocation is almost always a sign of some problem with your code, usually a
#' problem with type-stability or creating many small temporary arrays.
#' Consequently, in addition to the allocation itself, it's very likely
#' that the code generated for your function is far from optimal. Take such indications seriously
#' and follow the advice below.
#' 
#' If we instead pass `x` as an argument to the function it no longer allocates memory
#' (the allocation reported below is due to running the `@time` macro in global scope)
#' and is significantly faster after the first call:
x = rand(1000);

function sum_arg(x)
    s = 0.0
    for i in x
        s += i
    end
    return s
end;

@time sum_arg(x)

@time sum_arg(x)

#' The 1 allocation seen is from running the `@time` macro itself in global scope. If we instead run
#' the timing in a function, we can see that indeed no allocations are performed:

time_sum(x) = @time sum_arg(x);

time_sum(x)

#' For more serious benchmarking, consider the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl)
#' package which among other things evaluates the function multiple times in order to reduce noise.

#' See https://docs.julialang.org/en/v1/manual/performance-tips/ for more performance tips. 

#' As an additional example, calculate

#' $S=\sum_{i=1}^p\sum_{j=1}^p\rho^{|i-j|},$
#' for $\rho=0.5$, $p=1000$.
ρ, p = 0.5, 1000
@time S = sum([ρ^abs(i-j) for i in 1:p, j in 1:p])
@time S = sum(ρ.^abs.(1(1:p) .- (1:p)'))

function findS(ρ, p)
    S = 0 
    for i in 1:p, j in 1:p
        S += ρ^abs(i-j)
    end
    return S
end
@time findS(ρ, p)

using FLoops
function findS_F(ρ, p)
    S = 0 
    @floop for i in 1:p, j in 1:p
        @reduce(S += ρ^abs(i-j))
    end
    return S
end
@time findS_F(ρ, p)

# Threads.nthreads()
# export JULIA_NUM_THREADS=4

# using LinearAlgebra
# BLAS.set_num_threads(1)
# ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ())

#' ## Interact with R using the RCall package
#+ eval=false
using Pkg
Pkg.add("RCall")
#+ eval=true
using RCall
#' After loading the package, in julia REPL, press $ to activate the R REPL mode and the R prompt will be shown; press backspace to leave R REPL mode. 

#' Generate data from a linear model
using Random
Random.seed!(2021);
n = 10
X = randn(n, 2)
b = [2.0, 3.0]
y = X * b .+ randn(n)
#' Calculate the least square estimate using
b̂ = inv(X' * X) * (X' * y)
b̂ = (X'X) \ (X'y) # it calculates (X' * X) \ (X' * y)
#' or simply
b̂ = X \ y
#' Do NOT use 
b̂ = inv(X' * X) * X' * y

#' Note that X and y are julia variables. @rput sends y and X to R with the same names
@rput y
@rput X

#' Fit a model in R
R"mod <- lm(y ~ X-1)"
R"summary(mod)"

#' You can have multiple lines of R code
R"""
mod2 = lm(y~X)
summary(mod2)
"""

#' To retrieve a variable from R, use @rget. For example,
R"z <- y * 3"
@rget z
