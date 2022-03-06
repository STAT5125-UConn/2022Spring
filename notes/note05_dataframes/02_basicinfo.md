# Introduction to DataFrames

```julia
julia> using DataFrames
```

## Getting basic information about a data frame

Let's start by creating a `DataFrame` object, `x`, so that we can learn how to get information on that data frame.

```julia
julia> x = DataFrame(A = [1, 2], B = [1.0, missing], C = ["a", "b"])
2×3 DataFrame
 Row │ A      B          C
     │ Int64  Float64?   String
─────┼──────────────────────────
   1 │     1        1.0  a
   2 │     2  missing    b
```

The standard `size` function works to get dimensions of the `DataFrame`,

```julia
julia> size(x), size(x, 1), size(x, 2)
((2, 3), 2, 3)
```

as well as `nrow` and `ncol` from R.

```julia
julia> nrow(x), ncol(x)
(2, 3)
```

`describe` gives basic summary statistics of data in your `DataFrame` (check out the help of `describe` for information on how to customize shown statistics).

```julia
julia> describe(x)
3×7 DataFrame
 Row │ variable  mean    min  median  max  nmissing  eltype
     │ Symbol    Union…  Any  Union…  Any  Int64     Type
─────┼───────────────────────────────────────────────────────────────────────
   1 │ A         1.5     1    1.5     2           0  Int64
   2 │ B         1.0     1.0  1.0     1.0         1  Union{Missing, Float64}
   3 │ C                 a            b           0  String
```

you can limit the columns shown by `describe` using `cols` keyword argument

```julia
julia> describe(x, cols=1:2)
2×7 DataFrame
 Row │ variable  mean     min   median   max   nmissing  eltype                ⋯
     │ Symbol    Float64  Real  Float64  Real  Int64     Type                  ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ A             1.5   1        1.5   2           0  Int64                 ⋯
   2 │ B             1.0   1.0      1.0   1.0         1  Union{Missing, Float6
                                                                1 column omitted
```

`names` will return the names of all columns as strings

```julia
julia> names(x)
3-element Vector{String}:
 "A"
 "B"
 "C"
```

you can also get column names with a given `eltype`:

```julia
julia> names(x, String)
1-element Vector{String}:
 "C"
```

use `propertynames` to get a vector of `Symbol`s:

```julia
julia> propertynames(x)
3-element Vector{Symbol}:
 :A
 :B
 :C
```

using `eltype` on `eachcol(x)` returns element types of columns:

```julia
julia> eltype.(eachcol(x))
3-element Vector{Type}:
 Int64
 Union{Missing, Float64}
 String
```

Here we create some large `DataFrame`

```julia
julia> y = DataFrame(rand(1:10, 1000, 10), :auto)
1000×10 DataFrame
  Row │ x1     x2     x3     x4     x5     x6     x7     x8     x9     x10
      │ Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64
──────┼──────────────────────────────────────────────────────────────────────
    1 │     3      8      5      3      1      6      1      8     10      1
    2 │     8      8     10      6      3     10      5      8      6      9
    3 │     3      6     10      6      9      2      9      7      1      9
    4 │     6      5      4      8      9      8      3      9      6      1
    5 │     3      3     10     10      9      6      8      7      9      3
    6 │     3      4      1      4      1      2      9      2      4      6
    7 │     5      7      7      6      7      8      5      7      4      2
    8 │     8     10      1      2      3      6      7      4      7      4
  ⋮   │   ⋮      ⋮      ⋮      ⋮      ⋮      ⋮      ⋮      ⋮      ⋮      ⋮
  994 │     2      4      4      8      8      5      7     10     10      3
  995 │     8      9      9      7      4      6     10      8      2      2
  996 │     8     10      9     10      9      3      2     10      3      1
  997 │     9      2     10      5      8     10      4      5      5      6
  998 │     4      9      7      6      6      3      6      6      5      4
  999 │     1      8     10      2      8      4      4     10      5      4
 1000 │     1      2      9      6      5      2      3      2      9      8
                                                             985 rows omitted
```

and then we can use `first` to peek into its first few rows

```julia
julia> first(y, 5)
5×10 DataFrame
 Row │ x1     x2     x3     x4     x5     x6     x7     x8     x9     x10
     │ Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64
─────┼──────────────────────────────────────────────────────────────────────
   1 │     3      8      5      3      1      6      1      8     10      1
   2 │     8      8     10      6      3     10      5      8      6      9
   3 │     3      6     10      6      9      2      9      7      1      9
   4 │     6      5      4      8      9      8      3      9      6      1
   5 │     3      3     10     10      9      6      8      7      9      3
```

and `last` to see its bottom rows.

```julia
julia> last(y, 3)
3×10 DataFrame
 Row │ x1     x2     x3     x4     x5     x6     x7     x8     x9     x10
     │ Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64
─────┼──────────────────────────────────────────────────────────────────────
   1 │     4      9      7      6      6      3      6      6      5      4
   2 │     1      8     10      2      8      4      4     10      5      4
   3 │     1      2      9      6      5      2      3      2      9      8
```

Using `first` and `last` without number of rows will return a first/last `DataFrameRow` in the `DataFrame`

```julia
julia> first(y)
DataFrameRow
 Row │ x1     x2     x3     x4     x5     x6     x7     x8     x9     x10
     │ Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64
─────┼──────────────────────────────────────────────────────────────────────
   1 │     3      8      5      3      1      6      1      8     10      1

julia> last(y)
DataFrameRow
  Row │ x1     x2     x3     x4     x5     x6     x7     x8     x9     x10
      │ Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64  Int64
──────┼──────────────────────────────────────────────────────────────────────
 1000 │     1      2      9      6      5      2      3      2      9      8
```

### Most elementary get and set operations

Given the `DataFrame` `x` we have created earlier, here are various ways to grab one of its columns as a `Vector`.

```julia
julia> x
2×3 DataFrame
 Row │ A      B          C
     │ Int64  Float64?   String
─────┼──────────────────────────
   1 │     1        1.0  a
   2 │     2  missing    b

julia> tmp = x.A
2-element Vector{Int64}:
 1
 2

julia> x.A, x[!, 1], x[!, :A] # all get the vector stored in our DataFrame without copying it
([1, 2], [1, 2], [1, 2])

julia> x."A", x[!, "A"] # the same using string indexing
([1, 2], [1, 2])

julia> x[:, 1] # note that this creates a copy
2-element Vector{Int64}:
 1
 2

julia> tmp = x[:, 1]
2-element Vector{Int64}:
 1
 2

julia> x[:, 1] === x[:, 1]
false
```

To grab one row as a `DataFrame`, we can index as follows.

```julia
julia> x[1:1, :]
1×3 DataFrame
 Row │ A      B         C
     │ Int64  Float64?  String
─────┼─────────────────────────
   1 │     1       1.0  a

julia> x[1, :] # this produces a DataFrameRow which is treated as 1-dimensional object similar to a NamedTuple
DataFrameRow
 Row │ A      B         C
     │ Int64  Float64?  String
─────┼─────────────────────────
   1 │     1       1.0  a
```

We can grab a single cell or element with the same syntax to grab an element of an array.

```julia
julia> x[1, 1]
1
```

or a new `DataFrame` that is a subset of rows and columns

```julia
julia> x[1:2, 1:2]
2×2 DataFrame
 Row │ A      B
     │ Int64  Float64?
─────┼──────────────────
   1 │     1        1.0
   2 │     2  missing
```

You can also use `Regex` to select columns and `Not` from InvertedIndices.jl both to select rows and columns

```julia
julia> x[Not(1), r"A"]
1×1 DataFrame
 Row │ A
     │ Int64
─────┼───────
   1 │     2

julia> x[!, Not(1)] # ! indicates that underlying columns are not copied
2×2 DataFrame
 Row │ B          C
     │ Float64?   String
─────┼───────────────────
   1 │       1.0  a
   2 │ missing    b

julia> x[:, Not(1)] # : means that the columns will get copied
2×2 DataFrame
 Row │ B          C
     │ Float64?   String
─────┼───────────────────
   1 │       1.0  a
   2 │ missing    b
```

Assignment of a scalar to a data frame can be done in ranges using broadcasting:

```julia
julia> x[1:2, 1:2] .= 1
2×2 SubDataFrame
 Row │ A      B
     │ Int64  Float64?
─────┼─────────────────
   1 │     1       1.0
   2 │     1       1.0

julia> x
2×3 DataFrame
 Row │ A      B         C
     │ Int64  Float64?  String
─────┼─────────────────────────
   1 │     1       1.0  a
   2 │     1       1.0  b
```

Assignment of a vector of length equal to the number of assigned rows using broadcasting

```julia
julia> x[1:2, 1:2] .= [1,2]
2×2 SubDataFrame
 Row │ A      B
     │ Int64  Float64?
─────┼─────────────────
   1 │     1       1.0
   2 │     2       2.0

julia> x
2×3 DataFrame
 Row │ A      B         C
     │ Int64  Float64?  String
─────┼─────────────────────────
   1 │     1       1.0  a
   2 │     2       2.0  b
```

Assignment or of another data frame of matching size and column names, again using broadcasting:

```julia
julia> x[1:2, 1:2] .= DataFrame([5 6; 7 8], [:A, :B])
2×2 SubDataFrame
 Row │ A      B
     │ Int64  Float64?
─────┼─────────────────
   1 │     5       6.0
   2 │     7       8.0

julia> x
2×3 DataFrame
 Row │ A      B         C
     │ Int64  Float64?  String
─────┼─────────────────────────
   1 │     5       6.0  a
   2 │     7       8.0  b
```

**Caution**
With `df[!, :col]` and `df.col` syntax you get a direct (non copying) access to a column of a data frame.
This is potentially unsafe as you can easily corrupt data in the `df` data frame if you resize, sort, etc. the column obtained in this way.
Therefore such access should be used with caution.
Similarly `df[!, cols]` when `cols` is a collection of columns produces a new data frame that holds the same (not copied) columns as the source `df` data frame. Similarly, modifying the data frame obtained via `df[!, cols]` might cause problems with the consistency of `df`.
The `df[:, :col]` and `df[:, cols]` syntaxes always copy columns so they are safe to use (and should generally be preferred except for performance or memory critical use cases).
Here are examples of how `Cols` and `Between` can be used to select columns of a data frame.

```julia
julia> x = DataFrame(rand(4, 5), :auto)
4×5 DataFrame
 Row │ x1         x2         x3        x4         x5
     │ Float64    Float64    Float64   Float64    Float64
─────┼─────────────────────────────────────────────────────
   1 │ 0.733314   0.814962   0.496613  0.990206   0.212823
   2 │ 0.900435   0.0279961  0.531634  0.253292   0.359452
   3 │ 0.0565348  0.332653   0.971727  0.0164934  0.118184
   4 │ 0.530151   0.353267   0.129737  0.369511   0.306846

julia> x[:, Between(:x2, :x4)]
4×3 DataFrame
 Row │ x2         x3        x4
     │ Float64    Float64   Float64
─────┼────────────────────────────────
   1 │ 0.814962   0.496613  0.990206
   2 │ 0.0279961  0.531634  0.253292
   3 │ 0.332653   0.971727  0.0164934
   4 │ 0.353267   0.129737  0.369511

julia> x[:, Cols("x1", Between("x2", "x4"))]
4×4 DataFrame
 Row │ x1         x2         x3        x4
     │ Float64    Float64    Float64   Float64
─────┼───────────────────────────────────────────
   1 │ 0.733314   0.814962   0.496613  0.990206
   2 │ 0.900435   0.0279961  0.531634  0.253292
   3 │ 0.0565348  0.332653   0.971727  0.0164934
   4 │ 0.530151   0.353267   0.129737  0.369511
```

### Views

You can simply create a view of a `DataFrame` (it is more efficient than creating a materialized selection). Here are the possible return value options.

```julia
julia> @view x[1:2, 1]
2-element view(::Vector{Float64}, 1:2) with eltype Float64:
 0.7333139956538027
 0.9004349696363928

julia> @view x[1,1]
0-dimensional view(::Vector{Float64}, 1) with eltype Float64:
0.7333139956538027

julia> @view x[1, 1:2] # a DataFrameRow, the same as for x[1, 1:2] without a view
DataFrameRow
 Row │ x1        x2
     │ Float64   Float64
─────┼────────────────────
   1 │ 0.733314  0.814962

julia> @view x[1:2, 1:2] # a SubDataFrame
2×2 SubDataFrame
 Row │ x1        x2
     │ Float64   Float64
─────┼─────────────────────
   1 │ 0.733314  0.814962
   2 │ 0.900435  0.0279961
```

### Adding new columns to a data frame

```julia
julia> df = DataFrame()
0×0 DataFrame
```

using `setproperty!`

```julia
julia> x = [1, 2, 3]
3-element Vector{Int64}:
 1
 2
 3

julia> df.a = x
3-element Vector{Int64}:
 1
 2
 3

julia> df
3×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3

julia> df.a === x # no copy is performed
true
```

using `setindex!`

```julia
julia> df[!, :b] = x
3-element Vector{Int64}:
 1
 2
 3

julia> df[:, :c] = x
3-element Vector{Int64}:
 1
 2
 3

julia> df
3×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      1
   2 │     2      2      2
   3 │     3      3      3

julia> df.b === x # no copy
true

julia> df.c === x # copy
false

julia> df[!, :d] .= x
3-element Vector{Int64}:
 1
 2
 3

julia> df[:, :e] .= x
3-element Vector{Int64}:
 1
 2
 3

julia> df
3×5 DataFrame
 Row │ a      b      c      d      e
     │ Int64  Int64  Int64  Int64  Int64
─────┼───────────────────────────────────
   1 │     1      1      1      1      1
   2 │     2      2      2      2      2
   3 │     3      3      3      3      3

julia> df.d === x, df.e === x # both copy, so in this case `!` and `:` has the same effect
(false, false)
```

note that in our data frame columns `:a` and `:b` store the vector `x` (not a copy)

```julia
julia> df.a === df.b === x
true
```

This can lead to silent errors. For example this code leads to a bug (note that calling `pairs` on `eachcol(df)` creates an iterator of (column name, column) pairs):

```julia
julia> for (n, c) in pairs(eachcol(df))
           println("$n: ", pop!(c))
       end
a: 3
b: 2
c: 3
d: 3
e: 3
```

note that for column `:b` we printed `2` as `3` was removed from it when we used `pop!` on column `:a`.
Such mistakes sometimes happen. Because of this DataFrames.jl performs consistency checks before doing an expensive operation (most notably before showing a data frame).

```julia
julia> df
Error: AssertionError: Data frame is corrupt: length of column :c (2) does not match length of column 1 (1). The column vector has likely been resized unintentionally (either directly or because it is shared with another data frame).
```

We can investigate the columns to find out what happend:

```julia
julia> collect(pairs(eachcol(df)))
5-element Vector{Pair{Symbol, AbstractVector}}:
 :a => [1]
 :b => [1]
 :c => [1, 2]
 :d => [1, 2]
 :e => [1, 2]
```

The output confirms that the data frame `df` got corrupted.
DataFrames.jl supports a complete set of `getindex`, `getproperty`, `setindex!`, `setproperty!`, `view`, broadcasting, and broadcasting assignment operations. The details are explained here: http://juliadata.github.io/DataFrames.jl/latest/lib/indexing/.

### Comparisons

```julia
julia> using DataFrames

julia> df = DataFrame(rand(2,3), :auto)
2×3 DataFrame
 Row │ x1        x2        x3
     │ Float64   Float64   Float64
─────┼──────────────────────────────
   1 │ 0.836769  0.121399  0.752035
   2 │ 0.796256  0.436199  0.845539

julia> df2 = copy(df)
2×3 DataFrame
 Row │ x1        x2        x3
     │ Float64   Float64   Float64
─────┼──────────────────────────────
   1 │ 0.836769  0.121399  0.752035
   2 │ 0.796256  0.436199  0.845539

julia> df == df2 # compares column names and contents
true
```

create a minimally different data frame and use `isapprox` for comparison

```julia
julia> df3 = df2 .+ eps()
2×3 DataFrame
 Row │ x1        x2        x3
     │ Float64   Float64   Float64
─────┼──────────────────────────────
   1 │ 0.836769  0.121399  0.752035
   2 │ 0.796256  0.436199  0.845539

julia> df == df3
false

julia> isapprox(df, df3)
true

julia> isapprox(df, df3, atol = eps()/2)
false
```

`missings` are handled as in Julia Base

```julia
julia> df = DataFrame(a=missing)
1×1 DataFrame
 Row │ a
     │ Missing
─────┼─────────
   1 │ missing

julia> df == df
missing

julia> df === df
true

julia> isequal(df, df)
true
```
