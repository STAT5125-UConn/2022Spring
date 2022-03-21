using DataFrames

#' ## Load and save DataFrames
#' Here we'll load CSV.jl to read and write CSV files, and demonstrate Arrow.jl and JDF.jl for therir specific formats.
using Arrow, CSV, JDF
using StatsPlots # for charts

#' Let's create a simple `DataFrame` for testing purposes,
x = DataFrame(A=[true, false, true], B=[1, 2, missing],
               C=[missing, "b", "c"], D=['a', missing, 'c'])

#' ### CSV.jl
#' Let's use `CSV` to save `x` to disk.
CSV.write("x1.csv", x)

#' Now we can see how it was saved by reading `x.csv`.
print(read("x1.csv", String))

#' We can also load it back.
y = CSV.read("x1.csv", DataFrame)

#' Note that when loading in a `DataFrame` from a `CSV` the column type for column `:D` has changed!
eltype.(eachcol(x))
eltype.(eachcol(y))

#' ### JDF.jl
#' [JDF.jl](https://github.com/xiaodaigh/JDF) is a relatively new package designed to serialize DataFrames. You can save a DataFrame with the `savejdf` function.
JDF.save("x.jdf", x)

#' To load the saved JDF file, one can use the `loadjdf` function
x_loaded = JDF.load("x.jdf") |> DataFrame
x_loaded = DataFrame(JDF.load("x.jdf"))

#' You can see that they are the same
isequal(x_loaded, x)

#' JDF.jl offers the ability to load only certain columns from disk to help with working with large files.
# Set up a JDFFile which is a on disk representation of `x` backed by JDF.jl
x_ondisk = jdf"x.jdf"

#' We can see all the names of `x` without loading it into memory
names(x_ondisk)

#' The below is an example of how to load only columns `:A` and `:D` 
xd = JDF.load(x_ondisk; cols = ["A", "D"]) |> DataFrame

#' ### Arrow.jl
#' Finally we use Apache Arrow format that allows, in particular, for data interchange with R or Python.
Arrow.write("x.arrow", x)
y = Arrow.Table("x.arrow") |> DataFrame
eltype.(eachcol(y))

#' Note that columns of `y` are immutable
y.A[1] = false

#' This is because `Arrow.Table` uses memory mapping and thus uses a custom vector types:
y.A
y.B

#' You can get standard Julia Base vectors by copying a data frame
y2 = copy(y)
y2.A
y2.B
y2.A[1] = false

#' ### Basic bechmarking
#' Next, we'll create some files, so be careful that you don't already have these files in your working directory!
#' In particular, we'll time how long it takes us to write a `DataFrame` with 10^3 rows and 10^5 columns.
bigdf = DataFrame(rand(Bool, 10^5, 1000), :auto)
bigdf[!, 1] = Int.(bigdf[!, 1])
bigdf[!, 2] = bigdf[!, 2] .+ 0.5
bigdf[!, 3] = string.(bigdf[!, 3], ", as string")

println("First run")
csvwrite1 = @elapsed @time CSV.write("bigdf1.csv", bigdf)
jdfwrite1 = @elapsed @time JDF.save("bigdf.jdf", bigdf)
arrowwrite1 = @elapsed @time Arrow.write("bigdf.arrow", bigdf)

println("Second run")
csvwrite2 = @elapsed @time CSV.write("bigdf1.csv", bigdf)
jdfwrite2 = @elapsed @time JDF.save("bigdf.jdf", bigdf)
arrowwrite2 = @elapsed @time Arrow.write("bigdf.arrow", bigdf)

groupedbar(
    repeat(["CSV.jl", "JDF.jl", "Arrow.jl"], inner = 2),
    [csvwrite1, csvwrite2, jdfwrite1, jdfwrite2, arrowwrite1, arrowwrite2],
    group = repeat(["1st", "2nd"], outer = 3),
    ylab = "Second",
    title = "Write Performance\nDataFrame: bigdf\nSize: $(size(bigdf))"
)

data_files = ["bigdf1.csv", "bigdf.arrow"]
df = DataFrame(file = data_files, size = getfield.(stat.(data_files), :size))
append!(df, DataFrame(file = "bigdf.jdf",
                      size=reduce((x,y)->x+y.size,
                                  stat.(joinpath.("bigdf.jdf",
                                               readdir("bigdf.jdf"))), init=0)))
sort!(df, :size)
@df df plot(:file, :size/1024^2, seriestype=:bar,
            title = "Format File Size (MB)", label="Size", ylab="MB")

println("First run")
csvread1 = @elapsed @time CSV.read("bigdf1.csv", DataFrame)
jdfread1 = @elapsed @time JDF.load("bigdf.jdf") |> DataFrame
arrowread1 = @elapsed @time df_tmp = Arrow.Table("bigdf.arrow") |> DataFrame
arrowread1copy = @elapsed @time copy(df_tmp)

println("Second run")
csvread2 = @elapsed @time CSV.read("bigdf1.csv", DataFrame)
jdfread2 = @elapsed @time JDF.load("bigdf.jdf") |> DataFrame
arrowread2 = @elapsed @time df_tmp = Arrow.Table("bigdf.arrow") |> DataFrame
arrowread2copy = @elapsed @time copy(df_tmp)

groupedbar(
    repeat(["CSV.jl", "JDF.jl.jl", "Arrow.jl", "Arrow.jl\ncopy"], inner = 2),
    [csvread1, csvread2, jdfread1, jdfread2, arrowread1, arrowread2, arrowread1+arrowread1copy, arrowread2+arrowread2copy],    
    group = repeat(["1st", "2nd"], outer = 4),
    ylab = "Second",
    title = "Read Performance\nDataFrame: bigdf\nSize: $(size(bigdf))"
)

# #' ### Using gzip compression

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("04_loadsave.jl", doctype="github")
