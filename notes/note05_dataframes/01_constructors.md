Let's get started by loading the `DataFrames` package.

```julia
julia> using DataFrames, Random
```

## Constructors and conversion

### Constructors

In this section, you'll see many ways to create a `DataFrame` using the `DataFrame()` constructor.
First, we could create an empty DataFrame,

```julia
julia> DataFrame()
0×0 DataFrame
```

Or we could call the constructor using keyword arguments to add columns to the `DataFrame`.

```julia
julia> DataFrame(A=1:3, B=rand(3), C=1)
3×3 DataFrame
 Row │ A      B         C
     │ Int64  Float64   Int64
─────┼────────────────────────
   1 │     1  0.420931      1
   2 │     2  0.293834      1
   3 │     3  0.865057      1
```

note in column `:fixed` that scalars get automatically broadcasted.
We can create a `DataFrame` from a dictionary, in which case keys from the dictionary will be sorted to create the `DataFrame` columns.

```julia
julia> x = Dict("A" => [1,2], "B" => [true, false], "C" => Ref([1,1]))
Dict{String, Any} with 3 entries:
  "B" => Bool[1, 0]
  "A" => [1, 2]
  "C" => RefValue{Vector{Int64}}([1, 1])

julia> DataFrame(x)
2×3 DataFrame
 Row │ A      B      C
     │ Int64  Bool   Array…
─────┼──────────────────────
   1 │     1   true  [1, 1]
   2 │     2  false  [1, 1]
```

This time we used `Ref` to protect a vector from being treated as a column and forcing broadcasting it into every row of `:fixed` column (note that the `[1,1]` vector is aliased in each row).
Rather than explicitly creating a dictionary first, as above, we could pass `DataFrame` arguments with the syntax of dictionary key-value pairs. 
Note that in this case, we use `Symbol`s to denote the column names and arguments are not sorted. For example, `:A`, the symbol, produces `A`, the name of the first column here:

```julia
julia> DataFrame(:A => [1,2], :B => [true, false], :C => "const")
2×3 DataFrame
 Row │ A      B      C
     │ Int64  Bool   String
─────┼──────────────────────
   1 │     1   true  const
   2 │     2  false  const
```

Although, in general, using `Symbol`s rather than strings to denote column names is preferred (as it is faster) DataFrames.jl accepts passing strings as column names, so this also works:

```julia
julia> DataFrame("A" => [1,2], "B" => [true, false], "C" => "const")
2×3 DataFrame
 Row │ A      B      C
     │ Int64  Bool   String
─────┼──────────────────────
   1 │     1   true  const
   2 │     2  false  const
```

Here we create a `DataFrame` from a vector of vectors, and each vector becomes a column.

```julia
julia> DataFrame([rand(3) for i in 1:3], :auto)
3×3 DataFrame
 Row │ x1        x2        x3
     │ Float64   Float64   Float64
─────┼───────────────────────────────
   1 │ 0.42415   0.91463   0.0489503
   2 │ 0.106551  0.16399   0.914248
   3 │ 0.686146  0.782556  0.428198

julia> DataFrame([rand(3) for i in 1:3], [:x1, :x2, :x3])
3×3 DataFrame
 Row │ x1         x2        x3
     │ Float64    Float64   Float64
─────┼───────────────────────────────
   1 │ 0.616703   0.511671  0.193199
   2 │ 0.782546   0.750684  0.780684
   3 │ 0.0937097  0.877059  0.818856

julia> DataFrame([rand(3) for i in 1:3], ["x1", "x2", "x3"])
3×3 DataFrame
 Row │ x1        x2         x3
     │ Float64   Float64    Float64
─────┼───────────────────────────────
   1 │ 0.725239  0.0418962  0.457064
   2 │ 0.565953  0.185739   0.771212
   3 │ 0.824918  0.44494    0.139442
```

As you can see you either pass a vector of column names as a second argument or `:auto` in which case column names are generated automatically.
In particular it is not allowed to pass a vector of scalars to `DataFrame` constructor.
Here we create a `DataFrame` from a matrix,

```julia
julia> DataFrame(rand(3,4), :auto)
3×4 DataFrame
 Row │ x1         x2        x3        x4
     │ Float64    Float64   Float64   Float64
─────┼───────────────────────────────────────────
   1 │ 0.54568    0.17215   0.25142   0.00745948
   2 │ 0.26344    0.654107  0.47841   0.108141
   3 │ 0.0212506  0.92445   0.760503  0.698005
```

and here we do the same but also pass column names.

```julia
julia> DataFrame(rand(3,4), Symbol.('a':'d'))
3×4 DataFrame
 Row │ a         b         c         d
     │ Float64   Float64   Float64   Float64
─────┼─────────────────────────────────────────
   1 │ 0.300539  0.26653   0.266305  0.623649
   2 │ 0.415258  0.768572  0.879349  0.0933718
   3 │ 0.940432  0.172783  0.68629   0.927208
```

or

```julia
julia> DataFrame(rand(3,4), string.('a':'d'))
3×4 DataFrame
 Row │ a          b         c          d
     │ Float64    Float64   Float64    Float64
─────┼──────────────────────────────────────────
   1 │ 0.463366   0.180265  0.708926   0.919003
   2 │ 0.604623   0.850169  0.0721133  0.749769
   3 │ 0.0499226  0.944881  0.211113   0.45164
```

This is how you can create a data frame with no rows, but with predefined columns and their types:

```julia
julia> DataFrame(A=Int[], B=Float64[], C=String[])
0×3 DataFrame
```

Finally, we can create a `DataFrame` by copying an existing `DataFrame`.
Note that `copy` also copies the vectors.

```julia
julia> x = DataFrame(a=1:2, b='a':'b')
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> y = x
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> (x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
(true, true, true, true)

julia> y = copy(x)
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> (x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
(false, true, true, false)
```

Calling `DataFrame` on a `DataFrame` object works like `copy`.

```julia
julia> x = DataFrame(a=1:2, b='a':'b')
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> y = DataFrame(x)
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> (x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
(false, true, true, false)
```

You can avoid copying of columns of a data frame (if it is possible) by passing `copycols=false` keyword argument:

```julia
julia> x = DataFrame(a=1:2, b='a':'b')
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> y = DataFrame(x, copycols=false)
2×2 DataFrame
 Row │ a      b
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b

julia> (x === y), isequal(x, y), (x.a == y.a), (x.a === y.a)
(false, true, true, true)
```

The same rule applies to other constructors

```julia
julia> a = [1, 2, 3]
3-element Vector{Int64}:
 1
 2
 3

julia> df1 = DataFrame(a=a)
3×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3

julia> df2 = DataFrame(a=a, copycols=false)
3×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3

julia> df1.a === a, df2.a === a
(false, true)
```

You can create a similar uninitialized `DataFrame` based on an original one:

```julia
julia> x = DataFrame(a=1, b=1.0)
1×2 DataFrame
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     1      1.0

julia> similar(x)
1×2 DataFrame
 Row │ a                b
     │ Int64            Float64
─────┼───────────────────────────────
   1 │ 140220920732272  6.92783e-310
```

number of rows in a new DataFrame can be passed as a second argument

```julia
julia> similar(x, 0)
0×2 DataFrame

julia> similar(x, 2)
2×2 DataFrame
 Row │ a                b
     │ Int64            Float64
─────┼─────────────────────────────
   1 │ 140218796149200  2.122e-314
   2 │ 140220920729608  5.0e-324
```

You can also create a new `DataFrame` from `SubDataFrame` or `DataFrameRow` (discussed in detail later in the tutorial; in particular although `DataFrameRow` is considered a 1-dimensional object similar to a `NamedTuple` it gets converted to a 1-row `DataFrame` for convinience)

```julia
julia> sdf = view(x, [1,1], :)
2×2 SubDataFrame
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     1      1.0
   2 │     1      1.0

julia> typeof(sdf)
SubDataFrame{DataFrame, DataFrames.Index, Vector{Int64}}
```

    SubDataFrame{DataFrame, DataFrames.Index, Vector{Int64}}

```julia
julia> DataFrame(sdf)
2×2 DataFrame
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     1      1.0
   2 │     1      1.0

julia> dfr = x[1, :]
DataFrameRow
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     1      1.0

julia> DataFrame(dfr)
1×2 DataFrame
 Row │ a      b
     │ Int64  Float64
─────┼────────────────
   1 │     1      1.0
```

### Conversion to a matrix

Let's start by creating a `DataFrame` with two rows and two columns.

```julia
julia> x = DataFrame(x=1:2, y=["A", "B"])
2×2 DataFrame
 Row │ x      y
     │ Int64  String
─────┼───────────────
   1 │     1  A
   2 │     2  B
```

We can create a matrix by passing this `DataFrame` to `Matrix` or `Array`.

```julia
julia> Matrix(x)
2×2 Matrix{Any}:
 1  "A"
 2  "B"

julia> Array(x)
2×2 Matrix{Any}:
 1  "A"
 2  "B"
```

This would work even if the `DataFrame` had some `missing`s:

```julia
julia> x = DataFrame(x=1:2, y=[missing,"B"])
2×2 DataFrame
 Row │ x      y
     │ Int64  String?
─────┼────────────────
   1 │     1  missing
   2 │     2  B

julia> Matrix(x)
2×2 Matrix{Any}:
 1  missing
 2  "B"
```

In the two previous matrix examples, Julia created matrices with elements of type `Any`. We can see more clearly that the type of matrix is inferred when we pass, for example, a `DataFrame` of integers to `Matrix`, creating a 2D `Array` of `Int64`s:

```julia
julia> x = DataFrame(x=1:2, y=3:4)
2×2 DataFrame
 Row │ x      y
     │ Int64  Int64
─────┼──────────────
   1 │     1      3
   2 │     2      4

julia> Matrix(x)
2×2 Matrix{Int64}:
 1  3
 2  4
```

In this next example, Julia correctly identifies that `Union` is needed to express the type of the resulting `Matrix` (which contains `missing`s).

```julia
julia> x = DataFrame(x=1:2, y=[missing,4])
2×2 DataFrame
 Row │ x      y
     │ Int64  Int64?
─────┼────────────────
   1 │     1  missing
   2 │     2        4

julia> Matrix(x)
2×2 Matrix{Union{Missing, Int64}}:
 1   missing
 2  4
```

### Handling of duplicate column names

We can pass the `makeunique` keyword argument to allow passing duplicate names (they get deduplicated)

```julia
julia> df = DataFrame(:a=>1, :a=>2, :a_1=>3; makeunique=true)
1×3 DataFrame
 Row │ a      a_2    a_1
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
```

Otherwise, duplicates are not allowed.

```julia
julia> df = DataFrame(:a=>1, :a=>2, :a_1=>3)
Error: ArgumentError: Duplicate variable names: :a. Pass makeunique=true to make them unique using a suffix automatically.
```

Finally you can use `empty` and `empty!` functions to remove all rows from a data frame:

```julia
julia> empty(df)
0×3 DataFrame

julia> empty!(df)
0×3 DataFrame
```
