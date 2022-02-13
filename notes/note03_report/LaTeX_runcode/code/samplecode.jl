using Plots
using Random
Random.seed!(1) # make the plot reproducible
x, y = 1:100, randn(100)
plot(x, y) # line plot
savefig("tmp/randomplot.pdf")

Fs = Array{Any}(undef, 2)
for i in 1:2
    Fs[i] = () -> i
end
res = (Fs[1](), Fs[2]()) # (1, 2)
