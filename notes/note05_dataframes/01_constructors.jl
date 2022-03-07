#' Let's get started by loading the `DataFrames` package.
using DataFrames, Random
#' ## Constructors and conversion
#' ### Constructors
#' In this section, you'll see many ways to create a `DataFrame` using the `DataFrame()` constructor.
#' First, we could create an empty DataFrame,
DataFrame()
#' Or we could call the constructor using keyword arguments to add columns to the `DataFrame`.
DataFrame(A=1:3, B=rand(3), C=1)
#' note in column `:fixed` that scalars get automatically broadcasted.
#' We can create a `DataFrame` from a dictionary, in which case keys from the dictionary will be sorted to create the `DataFrame` columns.
x = Dict("A" => [1,2], "B" => [true, false], "C" => Ref([1,1]))
DataFrame(x)
#' This time we used `Ref` to protect a vector from being treated as a column and forcing broadcasting it into every row of `:fixed` column (note that the `[1,1]` vector is aliased in each row).
#' Rather than explicitly creating a dictionary first, as above, we could pass `DataFrame` arguments with the syntax of dictionary key-value pairs. 
#' Note that in this case, we use `Symbol`s to denote the column names and arguments are not sorted. For example, `:A`, the symbol, produces `A`, the name of the first column here:
DataFrame(:A => [1,2], :B => [true, false], :C => "const")
#' Although, in general, using `Symbol`s rather than strings to denote column names is preferred (as it is faster) DataFrames.jl accepts passing strings as column names, so this also works:
DataFrame("A" => [1,2], "B" => [true, false], "C" => "const")
#' Here we create a `DataFrame` from a vector of vectors, and each vector becomes a column.
DataFrame([rand(3) for i in 1:3], :auto)
DataFrame([rand(3) for i in 1:3], [:x1, :x2, :x3])
DataFrame([rand(3) for i in 1:3], ["x1", "x2", "x3"])
#' As you can see you either pass a vector of column names as a second argument or `:auto` in which case column names are generated automatically.
#' In particular it is not allowed to pass a vector of scalars to `DataFrame` constructor.
#' Here we create a `DataFrame` from a matrix,
DataFrame(rand(3,4), :auto)
#' and here we do the same but also pass column names.
DataFrame(rand(3,4), Symbol.('a':'d'))
#' or
DataFrame(rand(3,4), string.('a':'d'))
#' This is how you can create a data frame with no rows, but with predefined columns and their types:
DataFrame(A=Int[], B=Float64[], C=String[])
#' Finally, we can create a `DataFrame` by copying an existing `DataFrame`.
#' Note that `copy` also copies the vectors.
x = DataFrame(a=1:2, b='a':'b')
y = x
(x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
y = copy(x)
(x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
#' Calling `DataFrame` on a `DataFrame` object works like `copy`.
x = DataFrame(a=1:2, b='a':'b')
y = DataFrame(x)
(x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
#' You can avoid copying of columns of a data frame (if it is possible) by passing `copycols=false` keyword argument:
x = DataFrame(a=1:2, b='a':'b')
y = DataFrame(x, copycols=false)
(x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
#' The same rule applies to other constructors
a = [1, 2, 3]
df1 = DataFrame(a=a)
df2 = DataFrame(a=a, copycols=false)
df1.a === a, df2.a === a
#' You can create a similar uninitialized `DataFrame` based on an original one:
x = DataFrame(a=1, b=1.0)
similar(x)
#' number of rows in a new DataFrame can be passed as a second argument
similar(x, 0)
similar(x, 2)
#' You can also create a new `DataFrame` from `SubDataFrame` or `DataFrameRow` (discussed in detail later in the tutorial; in particular although `DataFrameRow` is considered a 1-dimensional object similar to a `NamedTuple` it gets converted to a 1-row `DataFrame` for convinience)
sdf = view(x, [1,1], :)
typeof(sdf)
#'     SubDataFrame{DataFrame, DataFrames.Index, Vector{Int64}}
DataFrame(sdf)
x[[1], :]
dfr = x[1, :]
DataFrame(dfr)
#' ### Conversion to a matrix
#' Let's start by creating a `DataFrame` with two rows and two columns.
x = DataFrame(x=1:2, y=["A", "B"])
#' We can create a matrix by passing this `DataFrame` to `Matrix` or `Array`.
Matrix(x)
Array(x)
#' This would work even if the `DataFrame` had some `missing`s:
x = DataFrame(x=1:2, y=[missing,"B"])
Matrix(x)
#' In the two previous matrix examples, Julia created matrices with elements of type `Any`. We can see more clearly that the type of matrix is inferred when we pass, for example, a `DataFrame` of integers to `Matrix`, creating a 2D `Array` of `Int64`s:
x = DataFrame(x=1:2, y=3:4)
Matrix(x)
#' In this next example, Julia correctly identifies that `Union` is needed to express the type of the resulting `Matrix` (which contains `missing`s).
x = DataFrame(x=1:2, y=[missing,4])
Matrix(x)
#' ### Handling of duplicate column names
#' We can pass the `makeunique` keyword argument to allow passing duplicate names (they get deduplicated)
df = DataFrame(:a=>1, :a=>2, :a_1=>3; makeunique=true)
#' Otherwise, duplicates are not allowed.
df = DataFrame(:a=>1, :a=>2, :a_1=>3)
#' Finally you can use `empty` and `empty!` functions to remove all rows from a data frame:
empty(df)
empty!(df)

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("01_constructors.jl", doctype="github")
