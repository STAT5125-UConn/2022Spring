# use Julia 1.7 for reproducibility
using LinearAlgebra, Random, Statistics
using FLoops, CSV, DataFrames
BLAS.set_num_threads(1)

path = "../note07_optimization/train.csv"
df = CSV.read(path, DataFrame)
y = Array(df[!, 6])
n = length(y)
x = [ones(n) Array(df[!, 1:5])]
d = size(x, 2)

function getMLE(x, y)
    (n, d) = size(x)
    beta = zeros(d)
    S = Array{Float64}(undef, n, d)
    H = Array{Float64}(undef, d, d)
    loop = 1;
    Loop = 20;
    while loop <= Loop
        p = 1 ./ (1 .+ exp.(-vec(x * beta)))
        S = sum((y .- p) .* x, dims=1)
        H = - x' * (p .* (1 .- p) .* x)
        beta_new = beta .- H\S'
        if sum(abs.(S)) < 0.000001
            break
        end
        beta = beta_new
        loop += 1
    end
    return vec(beta)
end

function simu(rpt; x=x, y=y)
    n, d = size(x)
    Beta = Array{Float64}(undef, d, rpt);
    # @floop ThreadedEx() for i in 1:rpt
    for i in 1:rpt
        idx = rand(1:n, n)
        xb = view(x, idx,:)
        yb = view(y, idx)
        Beta[:,i] = getMLE(xb, yb)
    end
    return Beta
end

Random.seed!(2022)
@time Beta = simu(1000);
print(sum(Beta))

# using Optim
using Optim, ForwardDiff
function lik(beta; x=x, y=y) 
    p = 1 ./ (1 .+ exp.(-x * beta))
    return -sum(y .* log.(p) .+ (1 .-y) .* log.(1 .- p))
end

getmle = function(x, y)
    n, d = size(x)
    lik_local(beta) = lik(beta, x=x, y=y)
    res = optimize(lik_local, zeros(d), Newton(); autodiff=:forward)
    return Optim.minimizer(res)
end
@time b = getmle(x, y)

function simuO(rpt; x=x, y=y)
    n, d = size(x)
    Beta = Array{Float64}(undef, d, rpt);
    # @floop ThreadedEx() for i in 1:rpt
    for i in 1:rpt
        idx = rand(1:n, n)
        xb = view(x, idx,:)
        yb = view(y, idx)
        Beta[:,i] = getmle(xb, yb)
    end
    return Beta
end
simuO(1)

Random.seed!(2022)
@time Beta = simuO(20);
print(sum(Beta))
