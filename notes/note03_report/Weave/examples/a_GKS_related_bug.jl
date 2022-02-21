#' # Plot
# using InteractiveUtils
x = rand(2, 10)
#' Create a histogram.
using Plots
p1 = plot(x[1,:])
#' Create a scatter plot
p2 = plot(x[1,:], x[2,:])
#' Create a scatter plot
p3 = plot(x[1,:])

#+ eval=false; echo = false; results = "hidden"
using Weave
ENV["GKSwstype"]="nul"
weave("a_GKS_related_bug.jl", out_path="output/")
# weave("00.jl", out_path="output/", doctype="github")
using ElectronDisplay; ElectronDisplay.CONFIG.focus = false
