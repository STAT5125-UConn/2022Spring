#' # Introduction
#' HaiYing Wang, at `j import Dates; Dates.Date(Dates.now())`

#' This an example of a julia script that can be published using
#' [Weave](http://weavejl.mpastell.com/dev/usage/).
#' The script can be executed normally using Julia
#' or published to HTML or pdf with Weave.
#' Text is written in markdown in lines starting with "`#'` " and code
#' is executed and results are included in the published document.

#' You can create HTML or pdf file using the weave command as follows:
#' ```julia
#' using Weave
#' #HTML
#' weave("example.jl", out_path="output/")
#' #pdf
#' weave("example.jl", out_path="output/", doctype="md2pdf")
#' ```

#' Chunk Options can be specified using a line starting with "`#+`".
#' ```julia
#' #+ eval=false; echo = false; term=true; 
#' rand(10, 5)
#' ```

#' <!--
#' using Pkg
#' "Plots" ∉ keys(Pkg.project().dependencies) && Pkg.add("Plots");
#' "DataFrames" ∉ keys(Pkg.project().dependencies) && Pkg.add("DataFrames");
#' ## The Joy of Julia
#' -->

#' ## Some useful commands in Julia REPL:

#' - ? (enters help mode);
#' - ; (enters system shell mode);
#' - ] (enters package manager mode);
#' - Ctrl-c (interrupts computations);
#' - Ctrl-d (exits Julia);
#' - Ctrl-l clears screen;
#' - putting ; after the expression will disable showing its value in REPL.

#' ## Examples of some essential functions:

#' Loops and comprehensions rebind variables on each iteration, so they are 
#' safe to use then creating closures in iteration:
#+ term=true
Fs = Array{Any}(undef, 2)
for i in 1:2
    Fs[i] = () -> i
end
Fs[1](), Fs[2]() # (1, 2)

#' ## Plotting
#' There are several plotting packages for Julia like Plots.jl (which is
#' an umbrella packages for several plotting backends). Here we show how to use it
#' (version 1.13.2):
#+ term=true
using Plots
using Random
Random.seed!(1) # make the plot reproducible
x, y = 1:100, randn(100)
plot(x, y) # line plot
scatter(x, y) # scatter plot
histogram(y)

#' ## Working with tabular data

#' There are multiple packages supporting tabular data for the Julia language.
#' Here we will show how DataFrames.jl package can be used.
#+ term=true;
using DataFrames
df = DataFrame(x=y, y=y) 
first(df, 5)
# print first 5 rows of a data frame; use the last function for last rows

#+ eval=false; echo = false; results = "hidden"
using Weave
ENV["GKSwstype"]="nul"
using ElectronDisplay; ElectronDisplay.CONFIG.focus = false
# get_chunk_defaults()
set_chunk_defaults!(:term => true)
weave("example.jl", doctype="github")
weave("example.jl", doctype="github", out_path="output/")
weave("example.jl", out_path="output/")
weave("example.jl", out_path="output/", doctype="md2pdf")
# ENV["GKSwstype"]="gksqt"
