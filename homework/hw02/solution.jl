#' Problem 1
using Random; Random.seed!(2022);
n = 100
x = randexp(n)
y = x .+ randn(n)
vx = sum(x.^2) / (n-1) - sum(x)^2 / n / (n-1)
vy = sum(y.^2) / (n-1) - sum(y)^2 / n / (n-1)
cv = sum(x .* y) / (n-1) - sum(x) .* sum(y) / n / (n-1)
cr = cv / sqrt(vx * vy)

#' Problem 2
using DelimitedFiles
dat = readdlm("triangle.csv", ',');
s = 0
for i in eachrow(dat)
    global s
    tmp = sort!(i)
    if sum(tmp[1:2]) > tmp[3]
        s += 1
    end
end
@show s;

#+ eval=false; echo = false; results = "hidden"
using Weave
weave("solution.jl", doctype="github")
