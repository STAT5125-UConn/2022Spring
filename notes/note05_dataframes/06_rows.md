```julia
julia> using DataFrames, Statistics, Random
```

## Manipulating rows of DataFrame

### Selecting rows

```julia
julia> df = DataFrame(rand(4, 5), :auto)
4×5 DataFrame
 Row │ x1        x2          x3        x4        x5
     │ Float64   Float64     Float64   Float64   Float64
─────┼────────────────────────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897  0.454536  0.15646
   2 │ 0.436904  0.00757788  0.437236  0.66551   0.216375
   3 │ 0.673635  0.655518    0.446564  0.745665  0.315771
   4 │ 0.618931  0.528679    0.481977  0.693362  0.152118
```

using `:` as row selector will copy columns

```julia
julia> df[1:3, 1:3]
3×3 DataFrame
 Row │ x1        x2          x3
     │ Float64   Float64     Float64
─────┼────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897
   2 │ 0.436904  0.00757788  0.437236
   3 │ 0.673635  0.655518    0.446564
```

you can get a subset of rows of a data frame without copying using `view` to get a `SubDataFrame` 

```julia
julia> sdf = view(df, 1:3, 1:3)
3×3 SubDataFrame
 Row │ x1        x2          x3
     │ Float64   Float64     Float64
─────┼────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897
   2 │ 0.436904  0.00757788  0.437236
   3 │ 0.673635  0.655518    0.446564
```

you still have a detailed reference to the parent

```julia
julia> parent(sdf)
4×5 DataFrame
 Row │ x1        x2          x3        x4        x5
     │ Float64   Float64     Float64   Float64   Float64
─────┼────────────────────────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897  0.454536  0.15646
   2 │ 0.436904  0.00757788  0.437236  0.66551   0.216375
   3 │ 0.673635  0.655518    0.446564  0.745665  0.315771
   4 │ 0.618931  0.528679    0.481977  0.693362  0.152118

julia> parentindices(sdf)
(1:3, 1:3)
```

selecting a single row returns a `DataFrameRow` object which is also a view

```julia
julia> dfr = df[3, :]
DataFrameRow
 Row │ x1        x2        x3        x4        x5
     │ Float64   Float64   Float64   Float64   Float64
─────┼──────────────────────────────────────────────────
   3 │ 0.673635  0.655518  0.446564  0.745665  0.315771

julia> parent(dfr)
4×5 DataFrame
 Row │ x1        x2          x3        x4        x5
     │ Float64   Float64     Float64   Float64   Float64
─────┼────────────────────────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897  0.454536  0.15646
   2 │ 0.436904  0.00757788  0.437236  0.66551   0.216375
   3 │ 0.673635  0.655518    0.446564  0.745665  0.315771
   4 │ 0.618931  0.528679    0.481977  0.693362  0.152118

julia> parentindices(dfr)
(3, Base.OneTo(5))

julia> rownumber(dfr)
3
```

let us add a column to a data frame by assigning a scalar broadcasting

```julia
julia> df[!, :Z] .= 1
4-element Vector{Int64}:
 1
 1
 1
 1

julia> df
4×6 DataFrame
 Row │ x1        x2          x3        x4        x5        Z
     │ Float64   Float64     Float64   Float64   Float64   Int64
─────┼───────────────────────────────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897  0.454536  0.15646       1
   2 │ 0.436904  0.00757788  0.437236  0.66551   0.216375      1
   3 │ 0.673635  0.655518    0.446564  0.745665  0.315771      1
   4 │ 0.618931  0.528679    0.481977  0.693362  0.152118      1
```

Earlier we used `:` for column selection in a view (`SubDataFrame` and `DataFrameRow`).
In this case a view will have all columns of the parent after the parent is mutated.

```julia
julia> dfr
DataFrameRow
 Row │ x1        x2        x3        x4        x5        Z
     │ Float64   Float64   Float64   Float64   Float64   Int64
─────┼─────────────────────────────────────────────────────────
   3 │ 0.673635  0.655518  0.446564  0.745665  0.315771      1

julia> parent(dfr)
4×6 DataFrame
 Row │ x1        x2          x3        x4        x5        Z
     │ Float64   Float64     Float64   Float64   Float64   Int64
─────┼───────────────────────────────────────────────────────────
   1 │ 0.715835  0.0319075   0.512897  0.454536  0.15646       1
   2 │ 0.436904  0.00757788  0.437236  0.66551   0.216375      1
   3 │ 0.673635  0.655518    0.446564  0.745665  0.315771      1
   4 │ 0.618931  0.528679    0.481977  0.693362  0.152118      1

julia> parentindices(dfr)
(3, Base.OneTo(6))

julia> rownumber(dfr)
3
```

Note that `parent` and `parentindices` refer to the true source of data for a `DataFrameRow` and `rownumber` refers to row number in the direct object that was used to create `DataFrameRow`

```julia
julia> df = DataFrame(a=1:4)
4×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3
   4 │     4

julia> dfv = view(df, [3,2], :)
2×1 SubDataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     3
   2 │     2

julia> dfr = dfv[1, :]
DataFrameRow
 Row │ a
     │ Int64
─────┼───────
   3 │     3

julia> parent(dfr)
4×1 DataFrame
 Row │ a
     │ Int64
─────┼───────
   1 │     1
   2 │     2
   3 │     3
   4 │     4

julia> parentindices(dfr)
(3, Base.OneTo(1))

julia> rownumber(dfr)
1
```

### Reordering rows

We create some random data frame (and hope that `x.x` is not sorted :), which is quite likely with 12 rows)

```julia
julia> x = DataFrame(id=1:12, x = rand(12), y = [zeros(6); ones(6)])
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     1  0.900875      0.0
   2 │     2  0.968368      0.0
   3 │     3  0.36922       0.0
   4 │     4  0.917361      0.0
   5 │     5  0.692075      0.0
   6 │     6  0.605523      0.0
   7 │     7  0.186458      1.0
   8 │     8  0.329368      1.0
   9 │     9  0.86356       1.0
  10 │    10  0.621728      1.0
  11 │    11  0.389045      1.0
  12 │    12  0.740577      1.0
```

check if a DataFrame or a subset of its columns is sorted

```julia
julia> issorted(x)
true

julia> issorted(x, :x)
false
```

we sort x in place

```julia
julia> sort!(x, :x)
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     7  0.186458      1.0
   2 │     8  0.329368      1.0
   3 │     3  0.36922       0.0
   4 │    11  0.389045      1.0
   5 │     6  0.605523      0.0
   6 │    10  0.621728      1.0
   7 │     5  0.692075      0.0
   8 │    12  0.740577      1.0
   9 │     9  0.86356       1.0
  10 │     1  0.900875      0.0
  11 │     4  0.917361      0.0
  12 │     2  0.968368      0.0
```

now we create a new DataFrame

```julia
julia> y = sort(x, :id)
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     1  0.900875      0.0
   2 │     2  0.968368      0.0
   3 │     3  0.36922       0.0
   4 │     4  0.917361      0.0
   5 │     5  0.692075      0.0
   6 │     6  0.605523      0.0
   7 │     7  0.186458      1.0
   8 │     8  0.329368      1.0
   9 │     9  0.86356       1.0
  10 │    10  0.621728      1.0
  11 │    11  0.389045      1.0
  12 │    12  0.740577      1.0
```

here we sort by two columns, first is decreasing, second is increasing

```julia
julia> sort(x, [:y, :x], rev=[true, false])
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     7  0.186458      1.0
   2 │     8  0.329368      1.0
   3 │    11  0.389045      1.0
   4 │    10  0.621728      1.0
   5 │    12  0.740577      1.0
   6 │     9  0.86356       1.0
   7 │     3  0.36922       0.0
   8 │     6  0.605523      0.0
   9 │     5  0.692075      0.0
  10 │     1  0.900875      0.0
  11 │     4  0.917361      0.0
  12 │     2  0.968368      0.0

julia> sort(x, [order(:y, rev=true), :x]) # the same as above
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     7  0.186458      1.0
   2 │     8  0.329368      1.0
   3 │    11  0.389045      1.0
   4 │    10  0.621728      1.0
   5 │    12  0.740577      1.0
   6 │     9  0.86356       1.0
   7 │     3  0.36922       0.0
   8 │     6  0.605523      0.0
   9 │     5  0.692075      0.0
  10 │     1  0.900875      0.0
  11 │     4  0.917361      0.0
  12 │     2  0.968368      0.0
```

now we try some more fancy sorting stuff

```julia
julia> sort(x, [order(:y, rev=true), order(:x, by = v -> -v)])
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     9  0.86356       1.0
   2 │    12  0.740577      1.0
   3 │    10  0.621728      1.0
   4 │    11  0.389045      1.0
   5 │     8  0.329368      1.0
   6 │     7  0.186458      1.0
   7 │     2  0.968368      0.0
   8 │     4  0.917361      0.0
   9 │     1  0.900875      0.0
  10 │     5  0.692075      0.0
  11 │     6  0.605523      0.0
  12 │     3  0.36922       0.0
```

this is how you can reorder rows (here randomly)

```julia
julia> x[shuffle(1:12), :]
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     4  0.917361      0.0
   2 │     6  0.605523      0.0
   3 │     3  0.36922       0.0
   4 │     2  0.968368      0.0
   5 │    12  0.740577      1.0
   6 │     1  0.900875      0.0
   7 │     7  0.186458      1.0
   8 │     9  0.86356       1.0
   9 │     8  0.329368      1.0
  10 │    10  0.621728      1.0
  11 │    11  0.389045      1.0
  12 │     5  0.692075      0.0
```

 it is also easy to swap rows using broadcasted assignment

```julia
julia> sort!(x, :id)
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │     1  0.900875      0.0
   2 │     2  0.968368      0.0
   3 │     3  0.36922       0.0
   4 │     4  0.917361      0.0
   5 │     5  0.692075      0.0
   6 │     6  0.605523      0.0
   7 │     7  0.186458      1.0
   8 │     8  0.329368      1.0
   9 │     9  0.86356       1.0
  10 │    10  0.621728      1.0
  11 │    11  0.389045      1.0
  12 │    12  0.740577      1.0

julia> x[[1,10],:] .= x[[10,1],:]
2×3 SubDataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │    10  0.621728      1.0
   2 │     1  0.900875      0.0

julia> x
12×3 DataFrame
 Row │ id     x         y
     │ Int64  Float64   Float64
─────┼──────────────────────────
   1 │    10  0.621728      1.0
   2 │     2  0.968368      0.0
   3 │     3  0.36922       0.0
   4 │     4  0.917361      0.0
   5 │     5  0.692075      0.0
   6 │     6  0.605523      0.0
   7 │     7  0.186458      1.0
   8 │     8  0.329368      1.0
   9 │     9  0.86356       1.0
  10 │     1  0.900875      0.0
  11 │    11  0.389045      1.0
  12 │    12  0.740577      1.0
```

### Merging/adding rows

```julia
julia> x = DataFrame(rand(3, 5), :auto)
3×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
```

merge by rows - data frames must have the same column names; the same is `vcat`

```julia
julia> [x; x]
6×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
```

you can efficiently `vcat` a vector of `DataFrames` using `reduce`

```julia
julia> reduce(vcat, [x, x, x])
9×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   7 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   8 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   9 │ 0.195147  0.790216  0.729115  0.133245   0.516307
```

`vcat` is still possible as it does column name matching

```julia
julia> y = x[:, reverse(names(x))]
3×5 DataFrame
 Row │ x5        x4         x3        x2        x1
     │ Float64   Float64    Float64   Float64   Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.118531  0.132017   0.683445  0.992654  0.926134
   2 │ 0.279868  0.0316353  0.619288  0.39618   0.524474
   3 │ 0.516307  0.133245   0.729115  0.790216  0.195147

julia> vcat(x, y)
6×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307

julia> vcat(y, x)
6×5 DataFrame
 Row │ x5        x4         x3        x2        x1
     │ Float64   Float64    Float64   Float64   Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.118531  0.132017   0.683445  0.992654  0.926134
   2 │ 0.279868  0.0316353  0.619288  0.39618   0.524474
   3 │ 0.516307  0.133245   0.729115  0.790216  0.195147
   4 │ 0.118531  0.132017   0.683445  0.992654  0.926134
   5 │ 0.279868  0.0316353  0.619288  0.39618   0.524474
   6 │ 0.516307  0.133245   0.729115  0.790216  0.195147
```

but column names must still match

```julia
julia> vcat(x, y[:, 1:3])
Error: ArgumentError: column(s) x1 and x2 are missing from argument(s) 2

julia> vcat(x, y[:, 1:3], cols=:intersect)
6×3 DataFrame
 Row │ x3        x4         x5
     │ Float64   Float64    Float64
─────┼───────────────────────────────
   1 │ 0.683445  0.132017   0.118531
   2 │ 0.619288  0.0316353  0.279868
   3 │ 0.729115  0.133245   0.516307
   4 │ 0.683445  0.132017   0.118531
   5 │ 0.619288  0.0316353  0.279868
   6 │ 0.729115  0.133245   0.516307

julia> vcat(x, y[:, 1:3], cols=:union)
6×5 DataFrame
 Row │ x1              x2              x3        x4         x5
     │ Float64?        Float64?        Float64   Float64    Float64
─────┼───────────────────────────────────────────────────────────────
   1 │       0.926134        0.992654  0.683445  0.132017   0.118531
   2 │       0.524474        0.39618   0.619288  0.0316353  0.279868
   3 │       0.195147        0.790216  0.729115  0.133245   0.516307
   4 │ missing         missing         0.683445  0.132017   0.118531
   5 │ missing         missing         0.619288  0.0316353  0.279868
   6 │ missing         missing         0.729115  0.133245   0.516307

julia> vcat(x, y[:, 1:3], cols=[:x1, :x5])
6×2 DataFrame
 Row │ x1              x5
     │ Float64?        Float64
─────┼──────────────────────────
   1 │       0.926134  0.118531
   2 │       0.524474  0.279868
   3 │       0.195147  0.516307
   4 │ missing         0.118531
   5 │ missing         0.279868
   6 │ missing         0.516307
```

`append!` modifies `x` in place

```julia
julia> append!(x, x)
6×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
```

here column names must match exactly unless `cols` keyword argument is passed

```julia
julia> append!(x, y)
9×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   7 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   8 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   9 │ 0.195147  0.790216  0.729115  0.133245   0.516307
```

standard `repeat` function works on rows; also `inner` and `outer` keyword arguments are accepted

```julia
julia> repeat(x, 2)
18×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   7 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   8 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
  ⋮  │    ⋮         ⋮         ⋮          ⋮         ⋮
  12 │ 0.195147  0.790216  0.729115  0.133245   0.516307
  13 │ 0.926134  0.992654  0.683445  0.132017   0.118531
  14 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
  15 │ 0.195147  0.790216  0.729115  0.133245   0.516307
  16 │ 0.926134  0.992654  0.683445  0.132017   0.118531
  17 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
  18 │ 0.195147  0.790216  0.729115  0.133245   0.516307
                                           3 rows omitted
```

`push!` adds one row to `x` at the end; one must pass a correct number of values unless `cols` keyword argument is passed

```julia
julia> push!(x, 1:5)
10×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   7 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   8 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   9 │ 0.195147  0.790216  0.729115  0.133245   0.516307
  10 │ 1.0       2.0       3.0       4.0        5.0

julia> x
10×5 DataFrame
 Row │ x1        x2        x3        x4         x5
     │ Float64   Float64   Float64   Float64    Float64
─────┼───────────────────────────────────────────────────
   1 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   2 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   3 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   4 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   5 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   6 │ 0.195147  0.790216  0.729115  0.133245   0.516307
   7 │ 0.926134  0.992654  0.683445  0.132017   0.118531
   8 │ 0.524474  0.39618   0.619288  0.0316353  0.279868
   9 │ 0.195147  0.790216  0.729115  0.133245   0.516307
  10 │ 1.0       2.0       3.0       4.0        5.0
```

### Subsetting/removing rows

```julia
julia> x = DataFrame(id=1:10, val='a':'j')
10×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e
   6 │     6  f
   7 │     7  g
   8 │     8  h
   9 │     9  i
  10 │    10  j
```

by using indexing

```julia
julia> x[1:2, :]
2×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
```

a single row selection creates a `DataFrameRow`

```julia
julia> x[1, :]
DataFrameRow
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
```

but this is a `DataFrame`

```julia
julia> x[1:1, :]
1×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
```

the same but a view

```julia
julia> view(x, 1:2, :)
2×2 SubDataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
```

selects columns 1 and 2

```julia
julia> view(x, :, 1:2)
10×2 SubDataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e
   6 │     6  f
   7 │     7  g
   8 │     8  h
   9 │     9  i
  10 │    10  j
```

indexing by `Bool`, exact length math is required

```julia
julia> x[repeat([true, false], 5), :]
5×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     3  c
   3 │     5  e
   4 │     7  g
   5 │     9  i
```

alternatively we can also create a view

```julia
julia> view(x, repeat([true, false], 5), :)
5×2 SubDataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     3  c
   3 │     5  e
   4 │     7  g
   5 │     9  i
```

we can delete one row in place

```julia
julia> delete!(x, 7)
9×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e
   6 │     6  f
   7 │     8  h
   8 │     9  i
   9 │    10  j
```

or a collection of rows, also in place

```julia
julia> delete!(x, 6:7)
7×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e
   6 │     9  i
   7 │    10  j
```

you can also create a new `DataFrame` when deleting rows using `Not` indexing

```julia
julia> x[Not(1:2), :]
5×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     3  c
   2 │     4  d
   3 │     5  e
   4 │     9  i
   5 │    10  j

julia> x
7×2 DataFrame
 Row │ id     val
     │ Int64  Char
─────┼─────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e
   6 │     9  i
   7 │    10  j
```

now we move to row filtering

```julia
julia> x = DataFrame([1:4, 2:5, 3:6], :auto)
4×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     2      3      4
   3 │     3      4      5
   4 │     4      5      6
```

create a new `DataFrame` where filtering function operates on `DataFrameRow`

```julia
julia> filter(x -> x.x1 > 2.5, x)
2×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     3      4      5
   2 │     4      5      6

julia> a = filter(r -> r.x1 > 2.5, x, view=true) # the same but as a view
2×3 SubDataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     3      4      5
   2 │     4      5      6

julia> filter(:x1 => >(2.5), x)
2×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     3      4      5
   2 │     4      5      6
```

in place modification of `x`, an example with `do`-block syntax

```julia
julia> filter!(x) do r
           if r.x1 > 2.5
               return r.x2 < 4.5
           end
           r.x3 < 3.5
       end
2×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     3      4      5
```

A common operation is selection of rows for which a value in a column is contained in a given set. Here are a few ways in which you can achieve this.

```julia
julia> df = DataFrame(x=1:12, y=mod1.(1:12, 4))
12×2 DataFrame
 Row │ x      y
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     2      2
   3 │     3      3
   4 │     4      4
   5 │     5      1
   6 │     6      2
   7 │     7      3
   8 │     8      4
   9 │     9      1
  10 │    10      2
  11 │    11      3
  12 │    12      4
```

We select rows for which column `y` has value `1` or `4`.

```julia
julia> filter(row -> row.y in [1,4], df)
6×2 DataFrame
 Row │ x      y
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     4      4
   3 │     5      1
   4 │     8      4
   5 │     9      1
   6 │    12      4

julia> filter(:y => in([1,4]), df)
6×2 DataFrame
 Row │ x      y
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     4      4
   3 │     5      1
   4 │     8      4
   5 │     9      1
   6 │    12      4

julia> df[in.(df.y, Ref([1,4])), :]
6×2 DataFrame
 Row │ x      y
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     4      4
   3 │     5      1
   4 │     8      4
   5 │     9      1
   6 │    12      4

julia> 1:3 .∈ Ref([1, 2])
3-element BitVector:
 1
 1
 0
```

DataFrames.jl also provides a `subset` function that works on whole columns and allows for multiple conditions:

```julia
julia> x = DataFrame([1:4, 2:5, 3:6], :auto)
4×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
   2 │     2      3      4
   3 │     3      4      5
   4 │     4      5      6

julia> subset(x, :x1 => x -> x .< mean(x), :x2 => ByRow(<(2.5)))
1×3 DataFrame
 Row │ x1     x2     x3
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      2      3
```

Similarly an in-place `subset!` function is provided.

### Deduplicating

```julia
julia> x = DataFrame(A=[1,2], B=["x","y"])
2×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  x
   2 │     2  y

julia> append!(x, x)
4×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  x
   2 │     2  y
   3 │     1  x
   4 │     2  y

julia> x.C = 1:4
1:4

julia> x
4×3 DataFrame
 Row │ A      B       C
     │ Int64  String  Int64
─────┼──────────────────────
   1 │     1  x           1
   2 │     2  y           2
   3 │     1  x           3
   4 │     2  y           4
```

get first unique rows for given index

```julia
julia> unique(x, [1,2])
2×3 DataFrame
 Row │ A      B       C
     │ Int64  String  Int64
─────┼──────────────────────
   1 │     1  x           1
   2 │     2  y           2
```

now we look at whole rows

```julia
julia> unique(x)
4×3 DataFrame
 Row │ A      B       C
     │ Int64  String  Int64
─────┼──────────────────────
   1 │     1  x           1
   2 │     2  y           2
   3 │     1  x           3
   4 │     2  y           4
```

get indicators of non-unique rows

```julia
julia> nonunique(x, :A)
4-element Vector{Bool}:
 0
 0
 1
 1
```

modify `x` in place

```julia
julia> unique!(x, :B)
2×3 DataFrame
 Row │ A      B       C
     │ Int64  String  Int64
─────┼──────────────────────
   1 │     1  x           1
   2 │     2  y           2
```
