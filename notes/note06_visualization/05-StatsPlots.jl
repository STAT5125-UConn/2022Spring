#' ## Plot Recipes and Recipe Libraries
#' 
#' Plotting recipes are extensions to the Plots.jl framework. They add:
#' 
#' 1. New `plot` commands via **user recipes**.
#' 2. Default interpretations of Julia types as plotting data via **type recipes**.
#' 3. New functions for generating plots via **plot recipes**.
#' 4. New series types via **series recipes**.
#' 
#' Recipes are included in many recipe libraries. We will introduce StatsPlots.jl which adds a bunch of recipes including:
#' 
#' 1. a type recipe for `Distribution`s;
#' 2. a plot recipe for marginal histograms;
#' 3. a bunch of new statistical plot series.
#' 
#' Besides recipes, StatsPlots.jl also provides a specialized macro from plotting directly from data tables.
#' 
#' ### Using User Recipes
#' 
#' A user recipe says how to interpret plotting commands on a new data type.
#' In this case, StatsPlots.jl thus has a macro `@df` which allows you to plot
#' a `DataFrame` directly by using the column names. 
#' 
#' Without StatsPlots.jl:

using DataFrames, Plots
df = DataFrame(a = 1:10, b = 10 * rand(10), c = 10 * rand(10))
plot(df.a, [df.b df.c])

#' With StatsPlots.jl: Plot the DataFrame by declaring the points by the column names

# Pkg.add("StatsPlots")
using StatsPlots # Required for the DataFrame user recipe
@df df plot(:a, [:b :c])

#' Notice there's not much you have to do here: all of the commands from before
#' (attributes, series types, etc.) will still work on this data:

@df df scatter(:a, :b, title = "My DataFrame Scatter Plot!") # x = :a, y = :b

#' ### Using a Type Recipe
#' 
#' In addition, StatsPlots.jl extends Distributions.jl by adding a type recipe
#' for its distribution types, so they can be directly interpreted as plotting
#' data:

using Distributions
plot(Normal(3, 5), lw = 3)

#' Thus type recipes are a very convenient way to plot a specialized type which
#' requires no more intervention!
#' 
#' ### Using Plot Recipes
#' 
#' StatsPlots.jl adds the `marginhist` multiplot via a plot recipe. 

df = DataFrame(x = randn(1000), y = randn(1000))
@df df marginalhist(:x, :y)
@df df marginalhist(:x, :y, bins=(10, 10))

#' ### Using Series Recipes
#' 
#' StatsPlots.jl also introduces new series recipes. The key is that you don't have
#' to do anything differently: after `using StatsPlots` you can simply use those
#' new series recipes as though they were built into the plotting libraries. Let's
#' use the Violin plot on some random data:

y = randn(100, 4) # Four series of 100 points each
histogram(y[:,1], normalize=true)
density(y[:,1])
violin(["y1"], y[:,1])
boxplot!(["y1"], y[:,1])
violin(["Series 1" "Series 2" "Series 3" "Series 4"], y, leg = false)

#' and we can add a `boxplot` on top using the same mutation commands as before:

boxplot!(["Series 1" "Series 2" "Series 3" "Series 4"], y, leg = false)

#' ## Additional Addons To Try
#' 
#' Inside a `@df` macro call, the `cols` utility function can be used to refer to a range of columns:

df = DataFrame(a = 1:10, b = 10 .* rand(10), c = 10 .* rand(10))
@df df plot(:a, cols(2:3), color = [:red :blue])

using RDatasets
school = RDatasets.dataset("mlmRev","Hsb82")
@df school density(:MAch, group = :Sx)
@df school density(:MAch, group = (:Sx, :Sector), legend = :topleft)

x, y = randn(1000), randn(1000);
marginalkde(x, x+y, levels=20)

#' * `levels=N` can be used to set the number of contour levels (default 10); levels are evenly-spaced in the cumulative probability mass.
#' * `clip=((-xl, xh), (-yl, yh))` (default `((-3, 3), (-3, 3))`) can be used to adjust the bounds of the plot.  Clip values are expressed as multiples of the `[0.16-0.5]` and `[0.5,0.84]` percentiles of the underlying 1D distributions (these would be 1-sigma ranges for a Gaussian).
#' marginalkde(x, x+y, levels=20)
#' 
#' ## corrplot and cornerplot
#' 
#' This plot type shows the correlation among input variables. The marker color in scatter plots reveal the degree of correlation. Pass the desired colorgradient to `markercolor`. With the default gradient positive correlations are blue, neutral are yellow and negative are red. In the 2d-histograms the color gradient show the frequency of points in that bin (as usual controlled by `seriescolor`).

M = randn(1000,4);
M[:,2] .+= 0.8sqrt.(abs.(M[:,1])) .- 0.5M[:,3] .+ 5;
M[:,3] .-= 0.7M[:,1].^2 .+ 2;
corrplot(M, label = ["x$i" for i=1:4])
cornerplot(M)
cornerplot(M, compact=true)

#' Asymmetric violin or dot plots can be created using the `side` keyword (`:both` - default,`:right` or `:left`):

singers = RDatasets.dataset("lattice", "singer")
singers_moscow = deepcopy(singers)
singers_moscow[!, :Height] = singers_moscow[!, :Height] .+ 5
@df singers violin(string.(:VoicePart), :Height, side=:right, linewidth=0, label="Scala")
@df singers_moscow violin!(string.(:VoicePart), :Height, side=:left, linewidth=0, label="Moscow")

#' ## Equal-area histograms
#' 
#' The ea-histogram is an alternative histogram implementation, where every 'box' in the histogram contains the same number of sample points and all boxes have the same area. Areas with a higher density of points thus get higher boxes. This type of histogram shows spikes well, but may oversmooth in the tails. The y axis is not intuitively interpretable.

a = [randn(100); randn(100) .+ 3; randn(100) ./ 2 .+ 3]
p1 = histogram(a)
p2 = ea_histogram(a, bins = :scott, fillalpha = 0.4)
plot(p1, p2, layout=(1, 2))

#' ## AndrewsPlot
#' 
#' [AndrewsPlots](https://en.wikipedia.org/wiki/Andrews_plot) are a way to visualize structure in high-dimensional data by depicting each row of an array or table as a line that varies with the values in columns. 

iris = dataset("datasets", "iris")
@df iris andrewsplot(:Species, cols(1:4), legend = :topleft)
andrewsplot(reshape(1:15, 3,5))

#' Distributions

using Distributions
plot(Normal(3,5), fill=(0, .5,:orange))

dist = Gamma(2)
scatter(dist, leg=false)
bar!(dist, func=cdf, alpha=0.3)

bin1 = Binomial(20, 0.5)
bin2 = Binomial(10, 0.1)
bin3 = Binomial(10, 0.9)
p1 = bar(bin1, func=pdf, label="Bin$(params(bin1))", legend=:topleft)
p2 = bar(bin2, func=pdf, label="Bin$(params(bin2))", legend=:top)
bar!(bin3, func=pdf, label="Bin$(params(bin3))")
plot(p1, p2, size=0.8 .*(1000, 500))

p3 = plot(Normal(5, 1), label="N(5, 1)")
plot!(Normal(5, 3), label="N(5, 3)")
p4 = plot(Normal(15, 1), label="N(15, 1)")
plot(p3, p4, size=0.4.*(1200, 500))

d = Normal()
p1 = plot(d, func=cdf, -4, 4, label="N(0, 1)", legend=:topleft)
p1 = plot(x->x, x->cdf(d,x), -4, 4, label="N(0, 1)", legend=:topleft)
d = Binomial(10, 0.5)
p2 = plot(d, func=cdf, 0, 10, label="Bin(10, 0.5)", legend=:topleft, linetype=:steppost)
# p2 = plot(x->x, x->cdf(d,x), 0, 10, label="Bin(10, 0.5)", legend=:topleft, linetype=:steppre, m=:star)
p2 = plot(0:10, cdf.(d,0:10), label="Bin(10, 0.5)", legend=:topleft, linetype=:steppost, m=:circle)
# plot!(0:10, cdf.(d,0:10), seriestype=:scatter,label="")
plot(p1, p2, size=0.7 .*(1000, 500))

d = Normal(0, 1)
plot(d, -3.5, 3.5, legend=false, size=0.9.*(500, 300),
     grid=false, ylim=(-0.03, 0.4), # background_color=:red,
     axis=false, ticks=false)
plot!(d, -3.5, 1, fill=(0, 0.5, :blue))
plot!([-3.5, -1], [0.29, 0.1])
hline!([0])
annotate!(-2.5, 0.3, "\$p=P(X\\leq x_p)\$")
annotate!(1.1, -0.01, "\$x_p\$") 
annotate!(2.2, 0.2, "\$X\\sim N(\\mu,\\ \\sigma)\$")

# plot(x->x, x->pdf(d,x), -3.5, 3.5, legend=false, size=0.9.*(500, 300),
#      grid=false, ylim=(-0.03, 0.4), # background_color=:red,
#      axis=false, ticks=false)
# plot!(x->x, x->pdf(d,x), -3.5, 1, fill=(0, 0.5, :blue))
# plot!([-3.5, -1], [0.29, 0.1])
# hline!([0])
# annotate!(-2.5, 0.3, "\$p=P(X\\leq X_p)\$")
# annotate!(1.1, -0.01, "\$X_p\$") 
# annotate!(2.2, 0.2, "\$X\\sim N(\\mu,\\ \\sigma)\$")

#' 
#' ### Quantile-Quantile plots
#' 
#' The `qqplot` function compares the quantiles of two distributions, and accepts either a vector of sample values or a `Distribution`. The `qqnorm` is a shorthand for comparing a distribution to the normal distribution. If the distributions are similar the points will be on a straight line.

x, y, z = rand.((Normal(), Cauchy(), Normal()), 100)

# m = length(x)
# xs = sort(x)
# p = collect((1:m ).- 0.5) ./ m
# qz = quantile(z, p)
# p1 = plot(xs, qz, seriestype=:scatter, legend=false)
# p2 = qqplot(x, z)
# plot(p1, p2)

# qqplot of two samples, show a fitted regression line
qqplot(x, y, qqline = :fit)
qqplot(x, z, qqline = :fit)

#' compare with a Cauchy distribution fitted to y; pass an instance (e.g. Normal(0,1)) to compare with a specific distribution

qqplot(Normal, 1 .+ 2x)
qqplot(Normal(0, 1), 1 .+ 2x)
qqplot(Cauchy, x)
qqplot(Cauchy, y)
# the :R default line passes through the 1st and 3rd quartiles of the distribution
qqnorm(x, qqline = :R)

using Random
Random.seed!(0);
n = 200;
x = randn(n);
y1 = 1 .+ 1.5randn(n);
y2 = 1.5randn(n);
y3 = rand(TDist(3), n);
y4 = randn(n);
y5 = 1 .+ randn(n);
y = [y1 y2 y3 y4 y5];
plot(qqplot(x, y1, title="x~N(0,1), y~N(1,1.5²)"),
     qqplot(x, y2, title="x~N(0,1), y~N(0,1.5²)"),
     qqplot(x, y3, title="x~N(0,1), y~T(df=3)"),
     qqplot(x, y4, title="x~N(0,1), y~N(0,1)"),
     qqplot(x, y5, title="x~N(0,1), y~N(1,1)"), size=6 .* (150, 100))
# savefig("eqq_label.pdf")

#' ## Grouped Bar plots

dat = rand(10,3)
groupedbar(dat, bar_position=:stack, bar_width=0.7)
groupedbar(dat, bar_width=0.7)

#' This is the default:

groupedbar(dat, bar_position = :dodge, bar_width=0.7)

#' The `group` syntax is also possible in combination with `groupedbar`:

ctg = repeat(["Category 1", "Category 2"], inner = 5)
nam = repeat("G" .* string.(1:5), outer = 2)
dat = rand(5, 2)
groupedbar(nam, dat, group = ctg, xlabel = "Groups", ylabel = "Scores",
        title = "Scores by group and category", bar_width = 0.67,
        lw = 0, framestyle = :box)

#+ eval=false; echo = false; results = "hidden"

using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("05-StatsPlots.jl", doctype="github")
