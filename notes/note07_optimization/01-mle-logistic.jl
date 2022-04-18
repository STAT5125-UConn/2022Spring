# https://archive.ics.uci.edu/ml/datasets/census+income
import Downloads
url = "https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data"
path = Downloads.download(url, "adult.data")
using CSV, DataFrames
df = CSV.read(path, DataFrame, limit=10)
names(df)
df = CSV.read(path, DataFrame, header=false, limit=10)
df = CSV.read(path, DataFrame, header=false)
y = df.Column15 .== " >50K"
x = Matrix(df[!,Cols([1,3,5,12,13])])

url = "https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test"
path = Downloads.download(url, "adult.test")
dftest = CSV.read(path, DataFrame, limit=10)
fio = open(path, "r")
readline(fio)
dftest = CSV.read(path, DataFrame, limit=10, header=false, skipto=2)
dftest = CSV.read(path, DataFrame, header=false, skipto=2)
ytest = dftest.Column15 .== " >50K"
first(dftest.Column15, 10)
ytest = dftest.Column15 .== " >50K."
xtest = Matrix(dftest[!,Cols([1,3,5,12,13])])

# save cleaned data
nm = [string.("x",1:size(x, 2)); "y"]
CSV.write("train.csv", DataFrame([x y], nm))
CSV.write("test.csv", DataFrame([xtest ytest], nm))


# load cleaned data directly
using CSV, DataFrames, Optim, ForwardDiff, Statistics, LinearAlgebra
df = CSV.read("train.csv", DataFrame)
x = Array(df[!, 1:5])
y = Array(df[!, 6])
dftest = CSV.read("test.csv", DataFrame)
xtest = Array(dftest[!, 1:5])
ytest = Array(dftest[!, 6])

n, d = size(x)
ntest, dtest = size(xtest)

mean(y)
mean(ytest)
# classification on the test data
# totally naive prediction
pre_n = rand(ntest) .<= 0.5
mean(ytest .== pre_n)
# naive classification without using a regression model
p_n = mean(y)
pre_n = rand(ntest) .<= p_n
mean(ytest .== pre_n)

function getMLE(x, y)
    (n, d) = size(x)
    theta = zeros(d)
    # S = Array{Float64}(undef, n, d)
    S = similar(x)
    H = Array{Float64}(undef, d, d)
    loop = 1;
    Loop = 20;
    while loop <= Loop
        p = 1 ./ (1 .+ exp.(-vec(x * theta)))
        S = sum((y .- p) .* x, dims=1)
        H = - x' * (p .* (1 .- p) .* x)
        theta_new = theta .- H\S'
        if sum(abs.(S)) < 0.000001
            break
        end
        theta = theta_new
        loop += 1
        if loop == Loop
            println("Maximum iteration reached")
        end
    end
    # print("loop=$loop======\n")
    return vec(theta), H
end

# fit a model without intercept
res = getMLE(x, y)
η = xtest * res[1]
p = exp.(η) ./ (1 .+ exp.(η)) 
p = 1 ./ (1 .+ exp.(-η)) 
pre = p .>= 0.5
# classification with logistic regression
mean(ytest .== pre)

# fit a model with intercept
(n, d) = size(x)
res = getMLE([ones(n) x], y)
est = res[1]
η = est[1] .+ xtest * est[2:end]
p = 1 ./ (1 .+ exp.(-η)) 
pre = p .>= 0.5
# classification with logistic regression
mean(ytest .== pre)

# The standard error is available from the Newton's algorithm
V = -inv(res[2])
sd  =sqrt.(diag(V))
V ./ (sd .* sd')
[est sd]
t  = est ./ sd

# using Optim package

function lik(theta) 
    p = 1 ./ (1 .+ exp.(-x * theta))
    return -sum(y .* log.(p) .+ (1 .-y) .* log.(1 .- p))
end

using Optim
theta0 = zeros(d)
result = optimize(lik, theta0, Newton(); autodiff = :forward)
Optim.minimizer(result)

@time res = getMLE(x, y);
res[1]
lik(res[1])
lik(Optim.minimizer(result))
@time result = optimize(lik, theta0, Newton(); autodiff = :forward);
Optim.minimizer(result)
Optim.minimum(result)


using ForwardDiff

g = x -> ForwardDiff.gradient(lik, x)
h = x -> ForwardDiff.hessian(lik, x)

g(res[1])
h(res[1])
-res[2]
