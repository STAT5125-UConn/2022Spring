```julia
julia> using DataFrames, BenchmarkTools
```

## Manipulating columns of a `DataFrame`

### Renaming columns

Let's start with a `DataFrame` of `Bool`s that has default column names.

```julia
julia> x = DataFrame(rand(Bool, 3, 4), :auto)
3×4 DataFrame
 Row │ x1     x2     x3     x4
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

With `rename`, we create new `DataFrame`; here we rename the column `:x1` to `:A`. (`rename` also accepts collections of Pairs.)

```julia
julia> rename(x, :x1 => :A)
3×4 DataFrame
 Row │ A      x2     x3     x4
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

With `rename!` we do an in place transformation. 
This time we've applied a function to every column name (note that the function gets a column names as a string).

```julia
julia> rename!(c -> c^2, x)
3×4 DataFrame
 Row │ x1x1   x2x2   x3x3   x4x4
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

We can also change the name of a particular column without knowing the original.
Here we change the name of the third column, creating a new `DataFrame`.

```julia
julia> rename(x, 3 => :third)
3×4 DataFrame
 Row │ x1x1   x2x2   third  x4x4
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

If we pass a vector of names to `rename!`, we can change the names of all variables.

```julia
julia> rename!(x, [:a, :b, :c, :d])
3×4 DataFrame
 Row │ a      b      c      d
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true

julia> rename!(x, string.('a':'d'))
3×4 DataFrame
 Row │ a      b      c      d
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

We get an error when we try to provide duplicate names

```julia
julia> rename(x, fill(:a, 4))
Error: ArgumentError: Duplicate variable names: :a. Pass makeunique=true to make them unique using a suffix automatically.
```

unless we pass `makeunique=true`, which allows us to handle duplicates in passed names.

```julia
julia> rename(x, fill(:a, 4), makeunique=true)
3×4 DataFrame
 Row │ a      a_1    a_2    a_3
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true
```

### Reordering columns

We can reorder the `names(x)` vector as needed.

```julia
julia> x[:, names(x)[[2,4,1,3]]]
3×4 DataFrame
 Row │ b      d      a      c
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │ false   true   true   true
   2 │ false  false  false  false
   3 │ false   true  false  false

julia> x[!, names(x)[[2,4,1,3]]]
3×4 DataFrame
 Row │ b      d      a      c
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │ false   true   true   true
   2 │ false  false  false  false
   3 │ false   true  false  false
```

Also `select!` can be used to achieve this in place (or `select` to perform a copy):

```julia
julia> x
3×4 DataFrame
 Row │ a      b      c      d
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true  false   true   true
   2 │ false  false  false  false
   3 │ false  false  false   true

julia> select!(x, 4:-1:1)
3×4 DataFrame
 Row │ d      c      b      a
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true   true  false   true
   2 │ false  false  false  false
   3 │  true  false  false  false

julia> x
3×4 DataFrame
 Row │ d      c      b      a
     │ Bool   Bool   Bool   Bool
─────┼────────────────────────────
   1 │  true   true  false   true
   2 │ false  false  false  false
   3 │  true  false  false  false
```

### Merging/adding columns

```julia
julia> x = DataFrame([(i,j) for i in 1:3, j in 1:4], :auto)
3×4 DataFrame
 Row │ x1      x2      x3      x4
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)
```

With `hcat` we can merge two `DataFrame`s. Also [x y] syntax is supported but only when DataFrames have unique column names.

```julia
julia> hcat(x, x, makeunique=true)
3×8 DataFrame
 Row │ x1      x2      x3      x4      x1_1    x2_1    x3_1    x4_1
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 1)  (1, 2)  (1, 3)  (1, 4)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 1)  (2, 2)  (2, 3)  (2, 4)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 1)  (3, 2)  (3, 3)  (3, 4)
```

A column can also be added in the middle with a specialized in place method `insertcols!`. Let's add `:newcol` to the `DataFrame` `x`.

```julia
julia> insertcols!(x, 2, "newcol" => [1,2,3])
3×5 DataFrame
 Row │ x1      newcol  x2      x3      x4
     │ Tuple…  Int64   Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)       1  (1, 2)  (1, 3)  (1, 4)
   2 │ (2, 1)       2  (2, 2)  (2, 3)  (2, 4)
   3 │ (3, 1)       3  (3, 2)  (3, 3)  (3, 4)
```

If you want to insert the same column name several times `makeunique=true` is needed as usual.

```julia
julia> insertcols!(x, 2, :newcol => [1,2,4], makeunique=true)
3×6 DataFrame
 Row │ x1      newcol_1  newcol  x2      x3      x4
     │ Tuple…  Int64     Int64   Tuple…  Tuple…  Tuple…
─────┼──────────────────────────────────────────────────
   1 │ (1, 1)         1       1  (1, 2)  (1, 3)  (1, 4)
   2 │ (2, 1)         2       2  (2, 2)  (2, 3)  (2, 4)
   3 │ (3, 1)         4       3  (3, 2)  (3, 3)  (3, 4)
```

Let's use `insertcols!` to append a column in place (note that we dropped the index at which we insert the column).

```julia
julia> insertcols!(x, :A => [1,2,3])
3×7 DataFrame
 Row │ x1      newcol_1  newcol  x2      x3      x4      A
     │ Tuple…  Int64     Int64   Tuple…  Tuple…  Tuple…  Int64
─────┼─────────────────────────────────────────────────────────
   1 │ (1, 1)         1       1  (1, 2)  (1, 3)  (1, 4)      1
   2 │ (2, 1)         2       2  (2, 2)  (2, 3)  (2, 4)      2
   3 │ (3, 1)         4       3  (3, 2)  (3, 3)  (3, 4)      3
```

Note that `insertcols!` can be used to insert several columns to a data frame at once and that it performs broadcasting if needed:

```julia
julia> df = DataFrame(a = [1, 2, 3])
3×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3

julia> insertcols!(df, :b => "x", :c => 'a':'c', :d => Ref([1,2,3]))
3×4 DataFrame
 Row │ a      b       c     d
     │ Int64  String  Char  Array…
─────┼────────────────────────────────
   1 │     1  x       a     [1, 2, 3]
   2 │     2  x       b     [1, 2, 3]
   3 │     3  x       c     [1, 2, 3]
```

Interestingly we can emulate `hcat` mutating the data frame in-place using `insertcols!`:

```julia
julia> df1 = DataFrame(a=[1,2])
2×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2

julia> df2 = DataFrame(b=[2,3], c=[3,4])
2×2 DataFrame
 Row │ b      c
     │ Int64  Int64
─────┼──────────────
   1 │     2      3
   2 │     3      4

julia> hcat(df1, df2)
2×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     2      3      4

julia> df1 # df1 is not touched
2×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2

julia> insertcols!(df1, pairs(eachcol(df2))...)
2×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     2      3      4

julia> df1 # now we have changed df1
2×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     2      3      4
```

### Subsetting/removing columns

Let's create a new `DataFrame` `x` and show a few ways to create DataFrames with a subset of `x`'s columns.

```julia
julia> x = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)
3×5 DataFrame
 Row │ x1      x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)
```

First we could do this by index:

```julia
julia> x[:, [1,2,4,5]] # use ! instead of : for non-copying operation
3×4 DataFrame
 Row │ x1      x2      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 4)  (3, 5)
```

or by column name:

```julia
julia> x[:, [:x1, :x4]]
3×2 DataFrame
 Row │ x1      x4
     │ Tuple…  Tuple…
─────┼────────────────
   1 │ (1, 1)  (1, 4)
   2 │ (2, 1)  (2, 4)
   3 │ (3, 1)  (3, 4)
```

We can also choose to keep or exclude columns by `Bool` (we need a vector whose length is the number of columns in the original `DataFrame`).

```julia
julia> x[:, [true, false, true, false, true]]
3×3 DataFrame
 Row │ x1      x3      x5
     │ Tuple…  Tuple…  Tuple…
─────┼────────────────────────
   1 │ (1, 1)  (1, 3)  (1, 5)
   2 │ (2, 1)  (2, 3)  (2, 5)
   3 │ (3, 1)  (3, 3)  (3, 5)
```

Here we create a single column `DataFrame`,

```julia
julia> x[:, [:x1]]
3×1 DataFrame
 Row │ x1
     │ Tuple…
─────┼────────
   1 │ (1, 1)
   2 │ (2, 1)
   3 │ (3, 1)
```

and here we access the vector contained in column `:x1`.

```julia
julia> x[!, :x1] # use : instead of ! to copy
3-element Vector{Tuple{Int64, Int64}}:
 (1, 1)
 (2, 1)
 (3, 1)
```

x.x1 # the same

We could grab the same vector by column number

```julia
julia> x[!, 1]
3-element Vector{Tuple{Int64, Int64}}:
 (1, 1)
 (2, 1)
 (3, 1)

julia> x[!, [1]]
3×1 DataFrame
 Row │ x1
     │ Tuple…
─────┼────────
   1 │ (1, 1)
   2 │ (2, 1)
   3 │ (3, 1)
```

Note that getting a single column returns it without copying while creating a new `DataFrame` performs a copy of the column

```julia
julia> x[!, 1] === x[!, [1]]
false
```

you can also use `Regex`, `All`, `Between` and `Not` from InvertedIndies.jl for column selection:

```julia
julia> # x[!, r"[12]"]
       x[!, Not(1)]
3×4 DataFrame
 Row │ x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 2)  (3, 3)  (3, 4)  (3, 5)

julia> x[!, Between(:x2, :x4)]
3×3 DataFrame
 Row │ x2      x3      x4
     │ Tuple…  Tuple…  Tuple…
─────┼────────────────────────
   1 │ (1, 2)  (1, 3)  (1, 4)
   2 │ (2, 2)  (2, 3)  (2, 4)
   3 │ (3, 2)  (3, 3)  (3, 4)

julia> x[!, Cols(:x1, Between(:x3, :x5))]
3×4 DataFrame
 Row │ x1      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 3)  (3, 4)  (3, 5)

julia> select(x, :x1, Between(:x3, :x5), copycols=false) # the same as above
3×4 DataFrame
 Row │ x1      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 3)  (3, 4)  (3, 5)
```

you can use `select` and `select!` functions to select a subset of columns from a data frame. `select` creates a new data frame and `select!` operates in place

```julia
julia> df = copy(x)
3×5 DataFrame
 Row │ x1      x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)

julia> df2 = select(df, [1, 2])
3×2 DataFrame
 Row │ x1      x2
     │ Tuple…  Tuple…
─────┼────────────────
   1 │ (1, 1)  (1, 2)
   2 │ (2, 1)  (2, 2)
   3 │ (3, 1)  (3, 2)

julia> select(df, Not([1, 2]))
3×3 DataFrame
 Row │ x3      x4      x5
     │ Tuple…  Tuple…  Tuple…
─────┼────────────────────────
   1 │ (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 3)  (3, 4)  (3, 5)
```

by default `select` copies columns

```julia
julia> df2[!, 1] === df[!, 1]
false

julia> df2[!, 1] == df[!, 1]
true
```

this can be avoided by using `copycols=false` keyword argument

```julia
julia> df2 = select(df, [1, 2], copycols=false)
3×2 DataFrame
 Row │ x1      x2
     │ Tuple…  Tuple…
─────┼────────────────
   1 │ (1, 1)  (1, 2)
   2 │ (2, 1)  (2, 2)
   3 │ (3, 1)  (3, 2)

julia> df2[!, 1] === df[!, 1]
true
```

using `select!` will modify the source data frame

```julia
julia> select!(df, [1,2])
3×2 DataFrame
 Row │ x1      x2
     │ Tuple…  Tuple…
─────┼────────────────
   1 │ (1, 1)  (1, 2)
   2 │ (2, 1)  (2, 2)
   3 │ (3, 1)  (3, 2)

julia> df == df2
true
```

Here we create a copy of `x` and delete the 3rd column from the copy with `select!` and `Not`.

```julia
julia> z = copy(x)
3×5 DataFrame
 Row │ x1      x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)

julia> select!(z, Not(3))
3×4 DataFrame
 Row │ x1      x2      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 4)  (3, 5)
```

alternatively we can achieve the same by using the `select` function

```julia
julia> select(x, Not(3))
3×4 DataFrame
 Row │ x1      x2      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 4)  (3, 5)
```

### Views

Note, that you can also create a view of a `DataFrame` when we want a subset of its columns:

```julia
julia> @btime x[:, [1,3,5]]
  956.103 ns (22 allocations: 2.03 KiB)
3×3 DataFrame
 Row │ x1      x3      x5
     │ Tuple…  Tuple…  Tuple…
─────┼────────────────────────
   1 │ (1, 1)  (1, 3)  (1, 5)
   2 │ (2, 1)  (2, 3)  (2, 5)
   3 │ (3, 1)  (3, 3)  (3, 5)

julia> @btime @view x[:, [1,3,5]]
  193.263 ns (3 allocations: 256 bytes)
3×3 SubDataFrame
 Row │ x1      x3      x5
     │ Tuple…  Tuple…  Tuple…
─────┼────────────────────────
   1 │ (1, 1)  (1, 3)  (1, 5)
   2 │ (2, 1)  (2, 3)  (2, 5)
   3 │ (3, 1)  (3, 3)  (3, 5)
```

### Modify column by name

```julia
julia> x = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)
3×5 DataFrame
 Row │ x1      x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)
```

We can use the following syntax to add a new column at the end of a `DataFrame`.

```julia
julia> x[!, :A] = [1,2,3]
3-element Vector{Int64}:
 1
 2
 3

julia> x
3×6 DataFrame
 Row │ x1      x2      x3      x4      x5      A
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…  Int64
─────┼───────────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)      1
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)      2
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)      3
```

A new column name will be added to our `DataFrame` with the following syntax as well:

```julia
julia> x.B = 11:13
11:13

julia> x
3×7 DataFrame
 Row │ x1      x2      x3      x4      x5      A      B
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…  Int64  Int64
─────┼──────────────────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)      1     11
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)      2     12
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)      3     13
```

### Find column name

```julia
julia> x = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)
3×5 DataFrame
 Row │ x1      x2      x3      x4      x5
     │ Tuple…  Tuple…  Tuple…  Tuple…  Tuple…
─────┼────────────────────────────────────────
   1 │ (1, 1)  (1, 2)  (1, 3)  (1, 4)  (1, 5)
   2 │ (2, 1)  (2, 2)  (2, 3)  (2, 4)  (2, 5)
   3 │ (3, 1)  (3, 2)  (3, 3)  (3, 4)  (3, 5)
```

We can check if a column with a given name exists via

```julia
julia> hasproperty(x, :x1)
true
```

and determine its index via

```julia
julia> columnindex(x, :x2)
2
```

### Advanced ways of column selection

these are most useful for non-standard column names (e.g. containing spaces)

```julia
julia> df = DataFrame()
0×0 DataFrame

julia> df.x1 = 1:3
1:3

julia> df[!, "column 2"] = 4:6
4:6

julia> df
3×2 DataFrame
 Row │ x1     column 2
     │ Int64  Int64
─────┼─────────────────
   1 │     1         4
   2 │     2         5
   3 │     3         6

julia> df."column 2"
3-element Vector{Int64}:
 4
 5
 6

julia> df[:, "column 2"]
3-element Vector{Int64}:
 4
 5
 6
```

or you can interpolate column name using `:()` syntax

```julia
julia> for n in names(df)
           println(n, "\n", df.:($n), "\n")
       end
x1
[1, 2, 3]

column 2
[4, 5, 6]
```

### Working on a collection of columns

When using `eachcol` of a data frame the resulting object retains reference to its parent and e.g. can be queried with `getproperty`

```julia
julia> df = DataFrame(reshape(1:12, 3, 4), :auto)
3×4 DataFrame
 Row │ x1     x2     x3     x4
     │ Int64  Int64  Int64  Int64
─────┼────────────────────────────
   1 │     1      4      7     10
   2 │     2      5      8     11
   3 │     3      6      9     12

julia> ec_df = eachcol(df)
3×4 DataFrameColumns
 Row │ x1     x2     x3     x4
     │ Int64  Int64  Int64  Int64
─────┼────────────────────────────
   1 │     1      4      7     10
   2 │     2      5      8     11
   3 │     3      6      9     12

julia> ec_df[1]
3-element Vector{Int64}:
 1
 2
 3

julia> ec_df.x1
3-element Vector{Int64}:
 1
 2
 3
```

### Transforming columns

We will get to this subject later in 10_transforms.ipynb notebook, but here let us just note that `select`, `select!`, `transform`, `transform!` and `combine` functions allow to generate new columns based on the old columns of a data frame.
The general rules are the following:

* `select` and `transform` always return the number of rows equal to the source data frame, while `combine` returns any number of rows (`combine` is allowed to *combine* rows of the source data frame)
* `transform` retains columns from the old data frame
* `select!` and `transform!` are in-place versions of `select` and `transform`

```julia
julia> df = DataFrame(reshape(1:12, 3, 4), :auto)
3×4 DataFrame
 Row │ x1     x2     x3     x4
     │ Int64  Int64  Int64  Int64
─────┼────────────────────────────
   1 │     1      4      7     10
   2 │     2      5      8     11
   3 │     3      6      9     12
```

Here we add a new column `:res` that is a sum of columns `:x1` and `:x2`. A general syntax of transformations of this kind is:

source_columns => function_to_apply => target_column_name

then `function_to_apply` gets columns selected by `source_columns` as positional arguments.

```julia
julia> transform(df, [:x1, :x2] => (./) => :res)
3×5 DataFrame
 Row │ x1     x2     x3     x4     res
     │ Int64  Int64  Int64  Int64  Float64
─────┼─────────────────────────────────────
   1 │     1      4      7     10     0.25
   2 │     2      5      8     11     0.4
   3 │     3      6      9     12     0.5

julia> transform(df, [:x1, :x2] => ByRow(/) => :res)
3×5 DataFrame
 Row │ x1     x2     x3     x4     res
     │ Int64  Int64  Int64  Int64  Float64
─────┼─────────────────────────────────────
   1 │     1      4      7     10     0.25
   2 │     2      5      8     11     0.4
   3 │     3      6      9     12     0.5
```

One can omit passing `target_column_name` in which case it is automatically generated:

```julia
julia> using Statistics

julia> combine(df, [:x1, :x2] => cor)
1×1 DataFrame
 Row │ x1_x2_cor
     │ Float64
─────┼───────────
   1 │       1.0
```

Note that `combine` allowed the number of columns in the resulting data frame to be changed. If we used `select` instead it would automatically broadcast the return value to match the number of rouws of the source:

```julia
julia> select(df, [:x1, :x2] => cor)
3×1 DataFrame
 Row │ x1_x2_cor
     │ Float64
─────┼───────────
   1 │       1.0
   2 │       1.0
   3 │       1.0
```

If you want to apply some function on each row of the source wrap it in `ByRow`:

```julia
julia> select(df, :x1, :x2, [:x1, :x2] => ByRow(string))
3×3 DataFrame
 Row │ x1     x2     x1_x2_string
     │ Int64  Int64  String
─────┼────────────────────────────
   1 │     1      4  14
   2 │     2      5  25
   3 │     3      6  36
```

Finally you can conveninently create multiple columns with one function, e.g.:

```julia
julia> select(df, :x1, :x1 => ByRow(x -> [x^2, x^3]) => ["x1²", "x1³"])
3×3 DataFrame
 Row │ x1     x1²    x1³
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      1
   2 │     2      4      8
   3 │     3      9     27
```
