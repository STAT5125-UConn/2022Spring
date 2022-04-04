#' # Plots

#' ## GR Examples
using Plots

#' ### Lines
#' A simple line plot of the columns.

fdat = Plots.fakedata(50, 5);
plot(fdat)
plot(fdat, w = 3)

#' The option `w=3` specify the line width. Here are examples with other commonly used options.

plot(fdat, title = "First figure", label = "Line " .* string.(collect(1:5)'),
     size = 1.2 .*(500, 300),
     lw = 3,
     # m=(3, :auto),
     markershape=[:circle :rect :star5 :diamond :utriangle],
     tickfontsize=12, xguidefontsize=12, yguidefontsize=12,
     legendfontsize=10, grid=true, thickness_scaling=1,
     xlabel="x1", ylabel="y", legend=:topleft
     )

# Possible markershape [:none, :auto, :circle, :rect, :star5, :diamond, :hexagon, :cross, :xcross, :utriangle, :dtriangle, :rtriangle, :ltriangle, :pentagon, :heptagon, :octagon, :star4, :star6, :star7, :star8, :vline, :hline, :+, :x].

xlabel!("My x label")
plot(fdat, ms=10, w=3, shape=:auto, c=:auto, ls=:auto)
plot(collect(1:20)', ms=10, shape=:auto, c=:auto, ls=:auto)

#' ### Functions, adding data, and animations

#' Plot multiple functions. You can also put the function first, or use the
#' form `plot(f, xmin, xmax)` where `f` is a Function or `AbstractVector{Function}`.

#' Get series data: `x, y = plt[i]`. Set series data: `plt[i] = (x,y)`. Add
#' to the series with `push!`/`append!`.

#' Easily build animations. (`convert` or `ffmpeg` must be available to
#' generate the animation.) Use command `gif(anim, filename, fps=15)` to
#' save the animation.

p = plot([sin, cos], zeros(0), leg = false, xlims = (0, 2π), ylims = (-1, 1))
anim = Animation()
for x = range(0, stop=2π, length=20)
    push!(p, x, Float64[sin(x), cos(x)])
    frame(anim)
end
gif(anim, "animation_example.gif", fps=20)

#' ### Parametric plots

#' Plot function pair (x(u), y(u)).

plot(sin, x-> sin(2x), 0, 2π, line=4, legend=false, fill=(0, :orange))
plot(x -> x, x-> sin(2x), 0, 2π, line=4, legend=true)

#' ### Colors

#' Access predefined palettes (or build your own with the `colorscheme`
#' method). Line/marker colors are auto-generated from the plot\'s palette,
#' unless overridden. Set the `z` argument to turn on series gradients.

dat = rand(11, 4);
plot(0:10:100, dat, w=3)
plot(0:10:100, dat, w=3, α=0.5)
plot(0:10:100, dat, w=3, fill=0, α=0.5)
plot(0:10:100, dat, w=3, fill=0, α=0.5, palette=cgrad(:grays))

# to continue
y = rand(100);
plot(y, seriestype=:scatter)
scatter(y)
scatter(y, zcolor = y)
scatter(y, zcolor = abs.(y .- 0.5))
scatter(y, zcolor = abs.(y .- 0.5), m = :star)
scatter(y, zcolor = abs.(y .- 0.5), m = :star, ms = 10abs.(y .- 0.5) .+ 4)

#' ### Global

#' Change the guides/background/limits/ticks. Convenience args `xaxis` and
#' `yaxis` allow you to pass a tuple or value which will be mapped to the
#' relevant args automatically. The `xaxis` below will be replaced with
#' `xlabel` and `xlims` args automatically during the preprocessing step.
#' You can also use shorthand functions: `title!`, `xaxis!`, `yaxis!`,
#' `xlabel!`, `ylabel!`, `xlims!`, `ylims!`, `xticks!`, `yticks!`

using Statistics
y = rand(20, 3); y[:,2] .+= 1; y[:,3] .+= 2;
plot(y)
plot(y, xaxis = ("XLABEL", (-5, 30), 0:2:20, :flip), background_color = RGB(0.9, 0.9, 0.9))
hline!(mean(y, dims = 1), line = (4, :dash, 0.6, [:lightgreen :green :darkgreen]))
vline!([5, 10])
title!("TITLE")
yaxis!("YLABEL")
yaxis!("YLABEL", :log10)
yaxis!("YLABEL", :log10, minorgrid = true)

#' ### Images

#' Plot an image. y-axis is set to flipped

using FileIO, Downloads
url = "https://brand.uconn.edu/wp-content/uploads/sites/2820/2019/08/husky-logo-lockup-circleR.jpg"
path = Downloads.download(url, "husky.jpg")
img = FileIO.load(path) # need ImageIO for .png and ImageMagick for .jpg
plot(img)
scatter!(range(0, 500, length=30), 100 .+ 300rand(30))

#' ### Arguments

#' Plot multiple series with different numbers of points. Mix arguments
#' that apply to all series (marker/markersize) with arguments unique to
#' each series (colors). Special arguments `line`, `marker`, and `fill`
#' will automatically figure out what arguments to set (for example, we are
#' setting the `linestyle`, `linewidth`, and `color` arguments with
#' `line`.) Note that we pass a matrix of colors, and this applies the
#' colors to each series.

ys = Vector[rand(10), rand(20)]
plot(ys, color = [:red :orange], line = (:dot, 9), marker = ([:hex :star], 12, 0.8, Plots.stroke(3, :gray)))

#' ### Build plot in pieces

#' Start with a base plot

plot(rand(100) ./ 3, reg = true, fill = (0, :green))

#' and add to it later.

scatter!(rand(100), markersize = 6, color = :orange)

#' ### Histogram

dat1, dat2 = randn(10000), randn(10000);
histogram(dat1)
histogram(dat1, nbins = 20)
histogram2d(dat1, dat2, nbins = 20)

#' ### Line types

linetypes = [:sticks :path :steppre :steppost :scatter];
n = length(linetypes);
y = rand(20, n) .+ repeat((1:n)', 20);
plot(y, line = (linetypes, 3), m=(:auto, 4), lab = map(string, linetypes), ms = 15)

#' ### Line styles

styles = filter((s->begin
                s in Plots.supported_styles()
            end), [:solid, :dash, :dot, :dashdot, :dashdotdot])
styles = reshape(styles, 1, length(styles)) # or use: `permutedims(styles)`
n = length(styles)
y = cumsum(randn(20, n), dims = 1)
plot(y, line = (3, styles), label = map(string, styles), m=:auto, legendtitle = "linestyle")

#' ### Marker types

markers = filter((m->begin
                m in Plots.supported_markers()
            end), Plots._shape_keys)
markers = permutedims(markers)
n = length(markers)
x = (range(0, stop = 10, length = n + 2))[2:end - 1]
y = repeat(reshape(reverse(x), 1, :), n, 1)
scatter(x, y, m = markers, markersize = 8, lab = map(string, markers), bg = :linen, xlim = (0, 10), ylim = (0, 10))

#' ### Bar

#' `x` is the midpoint of the bar. (todo: allow passing of edges instead of
#' midpoints)

bar(randn(99))
dat = reshape(1:20, 10, 2)
bar(dat, α=0.6)

#' ### Subplots

#' Use the `layout` keyword, and optionally the convenient `@layout` macro
#' to generate arbitrarily complex subplot layouts.

l = @layout([a{0.1h}; b [c; d e]])
plot(randn(100, 5))
plot(randn(100, 5), layout = l, t = [:line :histogram :scatter :steppre :bar], leg = false, ticks = nothing, border = :none)

#' ### Adding to subplots

#' Note here the automatic grid layout, as well as the order in which new
#' series are added to the plots.

plot(Plots.fakedata(100, 10), layout = 4, palette = cgrad.([:grays :blues :heat :lightrainbow]), bg_inside = [:orange :pink :darkblue :black])

plot!(Plots.fakedata(100, 10) .+ 10, seriestype=:scatter)

#' ### Annotations

#' The `annotations` keyword is used for text annotations in
#' data-coordinates. Pass in a tuple `(x, y, text)`, a vector of
#' annotations, each of which is a tuple of `x`, `y` and `text`. You can
#' position annotations using relative coordinates with the syntax
#' `((px, py), text)`, where for example `px=.25` positions the annotation
#' at `25%` of the subplot\'s axis width. `text` may be a simple `String`,
#' or a `PlotText` object, which can be built with the method
#' `text(string, attrs...)`. This wraps font and color attributes and
#' allows you to set text styling. `text` may also be a tuple
#' `(string, attrs...)` of arguments which are passed to `Plots.text`.

#' `annotate!(ann)` is shorthand for `plot!(; annotation=ann)`.

#' Series annotations are used for annotating individual data points. They
#' require only the annotation; x/y values are computed. Series annotations
#' require either plain `String`s or `PlotText` objects.

y = rand(10)
plot(y)
plot(y, annotations = (3, y[3], Plots.text("this is #3", :left)), leg = false)
annotate!([(5, y[5], ("this is #5", 16, :red, :center)), (10, y[10], ("this is #10", :right, 20, "courier"))])
scatter!(range(2, stop = 8, length = 6), rand(6), marker = (30, 0.2, :orange), series_annotations = ["series", "annotations", "map", "to", "series", Plots.text("data", :green)])

#' ### Custom Markers

#' A `Plots.Shape` is a light wrapper around vertices of a polygon. For
#' supported backends, pass arbitrary polygons as the marker shapes. Note:
#' The center is (0,0) and the size is expected to be rougly the area of
#' the unit circle.

verts = [(-1.0, 1.0), (-1.28, 0.6), (-0.2, -1.4), (0.2, -1.4), (1.28, 0.6), (1.0, 1.0), (-1.0, 1.0), (-0.2, -0.6), (0.0, -0.2), (-0.4, 0.6), (1.28, 0.6), (0.2, -1.4), (-0.2, -1.4), (0.6, 0.2), (-0.2, 0.2), (0.0, -0.2), (0.2, 0.2), (-0.2, -0.6)]
x = 0.1:0.2:0.9
y = 0.7 * rand(5) .+ 0.15
plot(x, y, line = (3, :dash, :lightblue), marker = (Shape(verts), 30, RGBA(0, 0, 0, 0.2)), bg = :pink, fg = :darkblue, xlim = (0, 1), ylim = (0, 1), leg = false)

#' ### Contours

#' Any value for fill works here. We first build a filled contour from a
#' function, then an unfilled contour from a matrix.

x = 1:0.5:20
y = 1:0.5:10
f(x, y) = (3x + y ^ 2) * abs(sin(x) + cos(y))

X = repeat(reshape(x, 1, :), length(y), 1)
Y = repeat(y, 1, length(x))
Z = map(f, X, Y)
# p1 = contour(x, y, f, fill = true)
p1 = contour(x, y, f)
p2 = contour(x, y, Z)
plot(p1, p2)

#' ### Pie

x = ["Nerds", "Hackers", "Scientists"]
y = [0.4, 0.35, 0.25]
pie(x, y, title = "The Julia Community", l = 0.5)

#' ### 3D

n = 100
ts = range(0, stop = 8π, length = n)
x = ts .* map(cos, ts)
x = ts .* cos.(ts)
y = (0.1ts) .* map(sin, ts)
z = 1:n
plot(x, y, z, zcolor = reverse(z), m = (10, 0.8, :blues, Plots.stroke(0)), leg = false, cbar = true, w = 5)
plot(x, y, z, m = (10, 0.8, :blues, Plots.stroke(0)), leg = false, cbar = true, w = 5)
plot!(zeros(n), zeros(n), 1:n, w = 10)

#' ### Groups and Subplots

group = rand(map(i->"group $(i)", 1:4), 100)
dat = rand(100)
plot(dat, layout = @layout([a b; c]), group=group, linetype = [:bar :scatter :steppre], linecolor = :match)

#' ### Polar Plots

Θ = range(0, stop = 1.5π, length = 100)
r = abs.(0.1 * randn(100) + sin.(3Θ))
plot(Θ, r, m = 2)
plot(Θ, r, proj = :polar, m = 2)

#' ### Heatmap, categorical axes, and aspect_ratio

xs = [string("x", i) for i = 1:10]
ys = [string("y", i) for i = 1:4]
z = float((1:4) * reshape(1:10, 1, :))
heatmap(xs, ys, z)
heatmap(xs, ys, z, aspect_ratio = 1)

#' ### Layouts, margins, label rotation, title location

using Plots.PlotMeasures
plot(rand(100, 6), layout = @layout([a b; c]), title = ["A" "B" "C"], titlelocation = :left, left_margin = [20mm 0mm], bottom_margin = 10px, xrotation = 60)
plot(rand(100, 6), layout = @layout([a b; c]), title = ["A" "B" "C"], titlelocation = :left, left_margin = [20mm 0mm], bottom_margin = 10px, xrotation = 90, yrotation=90)

#' ### Animation with subplots

#' The `layout` macro can be used to create an animation with subplots.

l = @layout([[a; b] c])
p = plot(plot([sin, cos], 1, ylims = (-1, 1), leg = false),
         scatter([atan, cos], 1, ylims = (-1, 1.5), leg = false),
         plot(log, 1, ylims = (0, 2), leg = false),
         layout = l, xlims = (1, 2π))
anim = Animation()
for x in range(1, stop = 2π, length = 20)
    plot(push!(p, x, Float64[sin(x), cos(x), atan(x), cos(x), log(x)]))
    frame(anim)
end
gif(anim, "animation_subplots.gif", fps=15)

#' ### Magic grid argument

#' The grid lines can be modified individually for each axis with the magic
#' `grid` argument.

x = rand(10)
p1 = plot(x, title = "Default looks")
p2 = plot(x, grid = (:y, :red, :dot, 2, 0.9), title = "Modified y grid")
p3 = plot(deepcopy(p2), title = "Add x grid")
xgrid!(p3, :on, :cadetblue, 2, :dashdot, 0.4)
plot(p1, p2, p3, layout = (1, 3), label = "", fillrange = 0, fillalpha = 0.3)

#' ### Framestyle

#' The style of the frame/axes of a (sub)plot can be changed with the
#' `framestyle` attribute. The default framestyle is `:axes`.

scatter(fill(randn(10), 6), fill(randn(10), 6), framestyle = [:box :semi :origin :zerolines :grid :none], title = [":box" ":semi" ":origin" ":zerolines" ":grid" ":none"], color = permutedims(1:6), layout = 6, label = "", markerstrokewidth = 0, ticks = -2:2)

#' ### Lines and markers with varying colors

#' You can use the `line_z` and `marker_z` properties to associate a color
#' with each line segment or marker in the plot.

t = range(0, stop = 1, length = 100)
θ = (6π) .* t
x = t .* cos.(θ)
y = t .* sin.(θ)
p1 = plot(x, y, linewidth = 3, line_z = t, legend = false)
p2 = scatter(x, y, marker_z = (+), color = :bluesreds, legend = false)
plot(p1, p2)

#' ### Unconnected lines using `missing` or `NaN`

#' Missing values and non-finite values, including `NaN`, are not plotted.
#' Instead, lines are separated into segments at these values.

(x, y) = ([1, 2, 2, 1, 1], [1, 2, 1, 2, 1])
plot(plot([rand(5); NaN; rand(5); NaN; rand(5)]),
     plot([1, missing, 2, 3], marker = true),
     plot([x; NaN; x .+ 2], [y; NaN; y .+ 1], arrow = 2),
     plot([1, 2 + 3im, Inf, 4im, 3, -Inf * im, 0, 3 + 3im], marker = true),
     legend = false)

#' ### Lens

#' A lens lets you easily magnify a region of a plot. x and y coordinates
#' refer to the to be magnified region and the via the `inset` keyword the
#' subplot index and the bounding box (in relative coordinates) of the
#' inset plot with the magnified plot can be specified. Additional
#' attributes count for the inset plot.

plot([(0, 0), (0, 0.9), (1, 0.9), (2, 1), (3, 0.9), (80, 0)], legend = :outertopright)
plot!([(0, 0), (0, 0.9), (2, 0.9), (3, 1), (4, 0.9), (80, 0)])
plot!([(0, 0), (0, 0.9), (3, 0.9), (4, 1), (5, 0.9), (80, 0)])
plot!([(0, 0), (0, 0.9), (4, 0.9), (5, 1), (6, 0.9), (80, 0)])
lens!([1, 6], [0.9, 1.1], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))

#' ### Linked axes

x = -5:0.1:5
plot(plot(x, x -> x^2), plot(x, x -> sin(x)), layout = 2, link = :y)

#' ### Error bars and array type recipes

struct Measurement <: Number
    val::Float64
    err::Float64
end
value(m::Measurement) =  m.val
uncertainty(m::Measurement) = m.err
@recipe function f(::Type{T}, m::T) where T <: AbstractArray{<:Measurement}
    if !(get(plotattributes, :seriestype, :path) in [:contour, :contourf, :contour3d, :heatmap, :surface, :wireframe, :image])
        error_sym = Symbol(plotattributes[:letter], :error)
        plotattributes[error_sym] = uncertainty.(m)
    end
    value.(m)
end
x = Measurement.(10 * sort(rand(10)), rand(10))
y = Measurement.(10 * sort(rand(10)), rand(10))
z = Measurement.(10 * sort(rand(10)), rand(10))
surf = Measurement.((1:10) .* (1:10)', rand(10, 10))

plot(scatter(x, [x y]), scatter(x, y, z), heatmap(x, y, surf),
     wireframe(x, y, surf), legend = :topleft)

#' ### Polar heatmaps

x = range(0, 2π, length = 9)
y = 0:4
z = (1:4) .+ (1:8)'
heatmap(x, y, z, projection = :polar)

#' ### 3D surface with axis guides

f(x, a) = 1 / x + a * x ^ 2
xs = collect(0.1:0.05:2.0)
as = collect(0.2:0.1:2.0)
x_grid = [x for x in xs for y in as]
a_grid = [y for x in xs for y in as]
plot(x_grid, a_grid, f.(x_grid, a_grid), seriestype = :surface, xlabel = "longer xlabel", ylabel = "longer ylabel", zlabel = "longer zlabel")

#' ### Images with custom axes

using FileIO
img = FileIO.load("husky.jpg")
# need ImageIO for .png and ImageMagick for .jpg
plot([-π, π], [-1, 1], reverse(img, dims = 1), yflip = false, aspect_ratio = :none)
plot!(sin, -π, π, lw = 3, color = :red)
scatter!(range(-π, π, length=100), rand(100))

#' ### Step Types

#' A comparison of the various step-like `seriestype`s

x = 1:5
y = [1, 2, 3, 2, 1]
# default(shape = :circle)
plot(plot(x, y, m=:circle, seriestype=:steppre, label="steppre"),
     plot(x, y, m=:circle, seriestype=:stepmid, label="stepmid"),
     plot(x, y, m=:circle, seriestype=:steppost, label="steppost"),
     layout = (3, 1))

#' ### Guide positions and alignment

dat = repeat(rand(10), inner = (1,4))
plot(dat, layout = 4, xguide = "x guide", yguide = "y guide",
     xguidefonthalign = [:left :right :right :left],
     yguidefontvalign = [:top :bottom :bottom :top],
     xguideposition = :top,
     yguideposition = [:right :left :right :left],
     ymirror = [false true true false],
     xmirror = [false false true true],
     legend = false)

#' ### 3D axis flip / mirror

using LinearAlgebra
scalefontsizes(0.4)
(x, y) = (collect(-6:0.5:10), collect(-8:0.5:8))
args = (x, y, (x, y)->sinc(norm([x, y]) / π))
kwargs = Dict(:xlabel => "x", :ylabel => "y", :zlabel => "z", :grid => true, :minorgrid => true)
plots = [wireframe(args..., title = "wire"; kwargs...)]
for ax in (:x, :y, :z)
    push!(plots, wireframe(args..., title = "wire-flip-$(ax)", xflip = ax == :x, yflip = ax == :y, zflip = ax == :z; kwargs...))
end
for ax in (:x, :y, :z)
    push!(plots, wireframe(args..., title = "wire-mirror-$(ax)", xmirror = ax == :x, ymirror = ax == :y, zmirror = ax == :z; kwargs...))
end
plt = plot(plots..., layout=@layout([_ ° _; ° ° °; ° ° °]), margin=0*Plots.px)
resetfontsizes()
plt

#' ## Lists of options

#' -   **Supported arguments**: `annotations`, `arrow`, `aspect_ratio`,
#'     `background_color`, `background_color_inside`,
#'     `background_color_legend`, `background_color_outside`,
#'     `background_color_subplot`, `bar_width`, `bins`, `bottom_margin`,
#'     `camera`, `color_palette`, `colorbar`, `colorbar_entry`,
#'     `colorbar_title`, `colorbar_titlefontcolor`,
#'     `colorbar_titlefontfamily`, `colorbar_titlefonthalign`,
#'     `colorbar_titlefontrotation`, `colorbar_titlefontsize`,
#'     `colorbar_titlefontvalign`, `contour_labels`, `discrete_values`,
#'     `fill_z`, `fillalpha`, `fillcolor`, `fillrange`, `flip`,
#'     `foreground_color`, `foreground_color_axis`,
#'     `foreground_color_border`, `foreground_color_grid`,
#'     `foreground_color_legend`, `foreground_color_subplot`,
#'     `foreground_color_text`, `framestyle`, `grid`, `gridalpha`,
#'     `gridlinewidth`, `gridstyle`, `group`, `guide`, `guidefontcolor`,
#'     `guidefontfamily`, `guidefonthalign`, `guidefontrotation`,
#'     `guidefontsize`, `guidefontvalign`, `html_output_format`,
#'     `inset_subplots`, `label`, `layout`, `left_margin`, `legend`,
#'     `legendfontcolor`, `legendfontfamily`, `legendfonthalign`,
#'     `legendfontrotation`, `legendfontsize`, `legendfontvalign`,
#'     `legendtitle`, `levels`, `lims`, `line_z`, `linealpha`, `linecolor`,
#'     `linestyle`, `linewidth`, `link`, `margin`, `marker_z`,
#'     `markeralpha`, `markercolor`, `markershape`, `markersize`,
#'     `markerstrokealpha`, `markerstrokecolor`, `markerstrokewidth`,
#'     `normalize`, `orientation`, `overwrite_figure`, `polar`, `primary`,
#'     `projection`, `quiver`, `ribbon`, `right_margin`, `scale`,
#'     `series_annotations`, `seriesalpha`, `seriescolor`, `seriestype`,
#'     `show`, `show_empty_bins`, `size`, `smooth`, `subplot`,
#'     `subplot_index`, `tick_direction`, `tickfontcolor`,
#'     `tickfontfamily`, `tickfonthalign`, `tickfontrotation`,
#'     `tickfontsize`, `tickfontvalign`, `ticks`, `title`,
#'     `titlefontcolor`, `titlefontfamily`, `titlefonthalign`,
#'     `titlefontrotation`, `titlefontsize`, `titlefontvalign`,
#'     `top_margin`, `weights`, `window_title`, `x`, `xdiscrete_values`,
#'     `xerror`, `xflip`, `xforeground_color_axis`,
#'     `xforeground_color_border`, `xforeground_color_grid`,
#'     `xforeground_color_text`, `xgrid`, `xgridalpha`, `xgridlinewidth`,
#'     `xgridstyle`, `xguide`, `xguidefontcolor`, `xguidefontfamily`,
#'     `xguidefonthalign`, `xguidefontrotation`, `xguidefontsize`,
#'     `xguidefontvalign`, `xlims`, `xlink`, `xscale`, `xtick_direction`,
#'     `xtickfontcolor`, `xtickfontfamily`, `xtickfonthalign`,
#'     `xtickfontrotation`, `xtickfontsize`, `xtickfontvalign`, `xticks`,
#'     `y`, `ydiscrete_values`, `yerror`, `yflip`,
#'     `yforeground_color_axis`, `yforeground_color_border`,
#'     `yforeground_color_grid`, `yforeground_color_text`, `ygrid`,
#'     `ygridalpha`, `ygridlinewidth`, `ygridstyle`, `yguide`,
#'     `yguidefontcolor`, `yguidefontfamily`, `yguidefonthalign`,
#'     `yguidefontrotation`, `yguidefontsize`, `yguidefontvalign`, `ylims`,
#'     `ylink`, `yscale`, `ytick_direction`, `ytickfontcolor`,
#'     `ytickfontfamily`, `ytickfonthalign`, `ytickfontrotation`,
#'     `ytickfontsize`, `ytickfontvalign`, `yticks`, `z`,
#'     `zdiscrete_values`, `zerror`, `zflip`, `zforeground_color_axis`,
#'     `zforeground_color_border`, `zforeground_color_grid`,
#'     `zforeground_color_text`, `zgrid`, `zgridalpha`, `zgridlinewidth`,
#'     `zgridstyle`, `zguide`, `zguidefontcolor`, `zguidefontfamily`,
#'     `zguidefonthalign`, `zguidefontrotation`, `zguidefontsize`,
#'     `zguidefontvalign`, `zlims`, `zlink`, `zscale`, `ztick_direction`,
#'     `ztickfontcolor`, `ztickfontfamily`, `ztickfonthalign`,
#'     `ztickfontrotation`, `ztickfontsize`, `ztickfontvalign`, `zticks`
#' -   **Supported values for linetype**: `:contour`, `:heatmap`, `:image`,
#'     `:mesh3d`, `:path`, `:path3d`, `:scatter`, `:scatter3d`, `:shape`,
#'     `:straightline`, `:surface`, `:volume`, `:wireframe`
#' -   **Supported values for linestyle**: `:auto`, `:dash`, `:dashdot`,
#'     `:dashdotdot`, `:dot`, `:solid`
#' -   **Supported values for marker**: `:+`, `:auto`, `:circle`, `:cross`,
#'     `:diamond`, `:dtriangle`, `:heptagon`, `:hexagon`, `:hline`,
#'     `:ltriangle`, `:none`, `:octagon`, `:pentagon`, `:rect`,
#'     `:rtriangle`, `:star4`, `:star5`, `:star6`, `:star7`, `:star8`,
#'     `:utriangle`, `:vline`, `:x`, `:xcross`

#+ eval=false; echo = false; results = "hidden"

using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("04-Plots_examples.jl", doctype="github")
