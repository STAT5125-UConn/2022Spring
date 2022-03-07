#' # Introduction to DataFrames
using DataFrames
#' ## Getting basic information about a data frame
#' Let's start by creating a `DataFrame` object, `x`, so that we can learn how to get information on that data frame.
x = DataFrame(A = [1, 2], B = [1.0, missing], C = ["a", "b"])
#' The standard `size` function works to get dimensions of the `DataFrame`,
x = DataFrame(rand(100, 50), :auto)
size(x), size(x, 1), size(x, 2)
#' as well as `nrow` and `ncol` from R.
nrow(x), ncol(x)
#' `describe` gives basic summary statistics of data in your `DataFrame` (check out the help of `describe` for information on how to customize shown statistics).
describe(x)
#' you can limit the columns shown by `describe` using `cols` keyword argument
describe(x, cols=1:2)
#' `names` will return the names of all columns as strings
names(x)
#' you can also get column names with a given `eltype`:
names(x, String)
#' use `propertynames` to get a vector of `Symbol`s:
propertynames(x)
#' using `eltype` on `eachcol(x)` returns element types of columns:
eltype.(eachcol(x))
#' Here we create some large `DataFrame`
y = DataFrame(rand(1:10, 1000, 10), :auto)
#' and then we can use `first` to peek into its first few rows
first(y, 5)
#' and `last` to see its bottom rows.
last(y, 3)
#' Using `first` and `last` without number of rows will return a first/last `DataFrameRow` in the `DataFrame`
first(y)
last(y)

#' ### Most elementary get and set operations
#' Given the `DataFrame` `x` we have created earlier, here are various ways to grab one of its columns as a `Vector`.
x
tmp = x.A
x.A, x[!, 1], x[!, :A] # all get the vector stored in our DataFrame without copying it
x."A", x[!, "A"] # the same using string indexing
x."a and b"
x[!, "a and b"]
x[:, 1] # note that this creates a copy
tmp1 = x[:, 1]
tmp2 = x[!, 1]
tmp1 === x.A
tmp2 === x.A
x[:, 1] === x[:, 1]
x[!, 1] === x[!, 1]
#' To grab one row as a `DataFrame`, we can index as follows.
x[1:1, :]
x[1, :] # this produces a DataFrameRow which is treated as 1-dimensional object similar to a NamedTuple
#' We can grab a single cell or element with the same syntax to grab an element of an array.
x[1, 1]
#' or a new `DataFrame` that is a subset of rows and columns
x[1:2, 1:2]
#' You can also use `Regex` to select columns and `Not` from InvertedIndices.jl both to select rows and columns
x[Not(1), r"A"]
x[!, Not(1)] # ! indicates that underlying columns are not copied
x[:, Not(1)] # : means that the columns will get copied
#' Assignment of a scalar to a data frame can be done in ranges using broadcasting:
x[1:2, 1:2] .= 1
x
#' Assignment of a vector of length equal to the number of assigned rows using broadcasting
x[1:2, 1:2] .= [1,2]
x
#' Assignment or of another data frame of matching size and column names, again using broadcasting:
x[1:2, 1:2] .= DataFrame([5 6; 7 8], [:A, :B])
x
#' **Caution**
#' With `df[!, :col]` and `df.col` syntax you get a direct (non copying) access to a column of a data frame.
#' This is potentially unsafe as you can easily corrupt data in the `df` data frame if you resize, sort, etc. the column obtained in this way.
#' Therefore such access should be used with caution.
#' Similarly `df[!, cols]` when `cols` is a collection of columns produces a new data frame that holds the same (not copied) columns as the source `df` data frame. Similarly, modifying the data frame obtained via `df[!, cols]` might cause problems with the consistency of `df`.
#' The `df[:, :col]` and `df[:, cols]` syntaxes always copy columns so they are safe to use (and should generally be preferred except for performance or memory critical use cases).
#' Here are examples of how `Cols` and `Between` can be used to select columns of a data frame.
x = DataFrame(rand(4, 5), :auto)
x[:, Between(:x2, :x4)]
x[:, 2:4]
x[:, Cols("x1", Between("x2", "x4"))]
#' ### Views
#' You can simply create a view of a `DataFrame` (it is more efficient than creating a materialized selection). Here are the possible return value options.
@view x[1:2, 1]
@view x[1,1]
@view x[1, 1:2] # a DataFrameRow, the same as for x[1, 1:2] without a view
@view x[1:2, 1:2] # a SubDataFrame
#' ### Adding new columns to a data frame
df = DataFrame()
#' using `setproperty!`
x = [1, 2, 3]
df.a = x
df
df.a === x # no copy is performed
#' using `setindex!`
df[!, :b] = x
df[:, :c] = x
df
df.b === x # no copy
df.c === x # copy
df[!, :d] .= x
df[:, :e] .= x
df
df.d === x, df.e === x # both copy, so in this case `!` and `:` has the same effect
#' note that in our data frame columns `:a` and `:b` store the vector `x` (not a copy)
df.a === df.b === x
#' This can lead to silent errors. For example this code leads to a bug (note that calling `pairs` on `eachcol(df)` creates an iterator of (column name, column) pairs):
for (n, c) in pairs(eachcol(df))
    println("$n: ", pop!(c))
end
#' note that for column `:b` we printed `2` as `3` was removed from it when we used `pop!` on column `:a`.
#' Such mistakes sometimes happen. Because of this DataFrames.jl performs consistency checks before doing an expensive operation (most notably before showing a data frame).
df
#' We can investigate the columns to find out what happend:
collect(pairs(eachcol(df)))
#' The output confirms that the data frame `df` got corrupted.
#' DataFrames.jl supports a complete set of `getindex`, `getproperty`, `setindex!`, `setproperty!`, `view`, broadcasting, and broadcasting assignment operations. The details are explained here: http://juliadata.github.io/DataFrames.jl/latest/lib/indexing/.
#' ### Comparisons
df = DataFrame(rand(2,3), :auto)
df2 = copy(df)
df == df2 # compares column names and contents
#' create a minimally different data frame and use `isapprox` for comparison
df3 = df2 .+ eps()
df == df3
isapprox(df, df3)
isapprox(df, df3, atol = eps()/2)
#' `missings` are handled as in Julia Base
df = DataFrame(a=missing)
df == df
df === df
isequal(df, df)

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("02_basicinfo.jl", doctype="github")
