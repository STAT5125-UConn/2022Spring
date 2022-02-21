#' Problem 1
#+ term=false
using Random; Random.seed!(2022);
n = 100
x = randexp(n)
y = x .+ randn(n)
sum(y)

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
weave("juliaExample.jl")
