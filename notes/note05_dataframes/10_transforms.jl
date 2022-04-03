using DataFrames
#' ## Split-apply-combine
#' ### Grouping a data frame
x = DataFrame(id=[1,2,3,4,1,2,3,4], id2=[1,2,1,2,1,2,1,2], v=rand(8))
groupby(x, :id)
# groupby(x, [])
gx2 = groupby(x, [:id, :id2])
parent(gx2) # get the parent DataFrame 
vcat(gx2...) # back to the DataFrame, but in a different order of rows than the original
DataFrame(gx2) # the same
# DataFrame(gx2, keepkeys=false) # drop grouping columns when creating a data frame
groupcols(gx2) # vector of names of grouping variables
valuecols(gx2) # and non-grouping variables
groupindices(gx2) # group indices in parent(gx2)
kgx2 = keys(gx2)
#' You can index into a `GroupedDataFrame` like to a vector or to a dictionary.
#' The second form acceps `GroupKey`, `NamedTuple` or a `Tuple`
gx2
k = keys(gx2)[1]
ntk = NamedTuple(k)
tk = Tuple(k)
#' the operations below produce the same result and are fast
gx2[1]
gx2[k]
gx2[ntk]
gx2[tk]
#' handling missing values
x = DataFrame(id = [missing, 5, 1, 3, missing], x = 1:5)
groupby(x, :id) # by default groups include mising values and are not sorted
groupby(x, :id, sort=true, skipmissing=true) # but we can change it
#' ### Performing transformations by group using `combine`, `select`, `select!`, `transform`, and `transform!`

using Statistics, Pipe
# ENV["LINES"] = 15 # reduce the number of rows in the output
x = DataFrame(id=rand('a':'d', 100), v=rand(100))
# apply a function to each group of a data frame
# combine keeps as many rows as are returned from the function
@pipe x |> groupby(_, :id) |> combine(_, :v=>mean)

a = groupby(x, :id)
combine(a, :v=>mean)

# select and transform keep as many rows as are in the source data frame and in correct order
# additionally transform keeps all columns from the source
@pipe x |> groupby(_, :id) |> transform(_, :v=>mean)
a = groupby(x, :id)
transform(a, :v=>mean)
# note that combine reorders rows by group of GroupedDataFrame
x.id2 = axes(x, 1)
@pipe x |> groupby(_, :id) |> combine(_, :id2, :v=>mean)
a = groupby(x, :id)
combine(a, :id2, :v=>mean)
# we give a custom name for the result column
@pipe x |> groupby(_, :id) |> combine(_, :v=>mean=>:res)
a = groupby(x, :id)
combine(a, :v=>mean=>:res)
# you can have multiple operations
@pipe x |> groupby(_, :id) |> combine(_, :v=>mean=>:res1, :v=>sum=>:res2, nrow=>:n)
a = groupby(x, :id)
combine(a, :v=>mean=>:res1, :v=>sum=>:res2, nrow=>:n)

#' Additional notes:
#' * `select!` and `transform!` perform operations in-place
#' * The general syntax for transformation is `source_columns => function => target_column`
#' * if you pass multiple columns to a function they are treated as positional arguments
#' * `ByRow` and `AsTable` work exactly like discussed for operations on data frames in 05_columns.ipynb
#' * you can automatically groupby again the result of `combine`, `select` etc. by passing `ungroup=false` keyword argument to them
#' * similarly `keepkeys` keyword argument allows you to drop grouping columns from the resulting data frame
#' It is also allowed to pass a function to all these functions (also - as a special case, as a first argument). In this case the return value can be a table. In particular it allows for an easy dropping of groups if you return an empty table from the function.
#' If you pass a function you can use a `do` block syntax. In case of passing a function it gets a `SubDataFrame` as its argument.
#' Here is an example:
combine(groupby(x, :id)) do sdf
    n = nrow(sdf)
    n < 25 ? DataFrame() : DataFrame(n=n) # drop groups with low number of rows
end

#' You can also produce multiple columns in a single operation, e.g.:
df = DataFrame(id=[1,1,2,2], val=[1,2,3,4])
@pipe df |> groupby(_, :id) |> combine(_, :val => (x -> [x]) => AsTable)
a = groupby(df, :id)
combine(a, :val => (x -> [x]) => AsTable)

@pipe df |> groupby(_, :id) |> combine(_, :val => (x -> [x]) => [:c1, :c2])
a = groupby(df, :id)
combine(a, :val => (x -> [x]) => [:c1, :c2])

#' ### Aggregation of a data frame using `mapcols`
x = DataFrame(rand(10, 10), :auto)
mapcols(mean, x)
#' ### Mapping rows and columns using `eachcol` and `eachrow`
map(mean, eachcol(x)) # map a function over each column and return a vector
# an iteration returns a Pair with column name and values
foreach(c -> println(c[1], ": ", mean(c[2])), pairs(eachcol(x)))
# now the returned value is DataFrameRow which works as a NamedTuple but is a view to a parent DataFrame
map(r -> r.x1/r.x2, eachrow(x))
# it prints like a data frame, only the caption is different so that you know the type of the object
er = eachrow(x)
er.x1 # you can access columns of a parent data frame directly
# it prints like a data frame, only the caption is different so that you know the type of the object
ec = eachcol(x)
ec.x1 # you can access columns of a parent data frame directly
#' ### Transposing
#' you can transpose a data frame using `permutedims`:
df = DataFrame(reshape(1:12, 3, 4), :auto)
df.names = ["a", "b", "c"]
permutedims(df, :names)

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("10_transforms.jl", doctype="github")
