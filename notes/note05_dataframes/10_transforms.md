```julia
julia> using DataFrames
```

## Split-apply-combine

### Grouping a data frame

```julia
julia> x = DataFrame(id=[1,2,3,4,1,2,3,4], id2=[1,2,1,2,1,2,1,2], v=rand(8))
8×3 DataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     2      2  0.547894
   3 │     3      1  0.0878364
   4 │     4      2  0.805686
   5 │     1      1  0.0373405
   6 │     2      2  0.849607
   7 │     3      1  0.172853
   8 │     4      2  0.0639657

julia> groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (2 rows): id = 1
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
⋮
Last Group (2 rows): id = 4
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     4      2  0.805686
   2 │     4      2  0.0639657

julia> # groupby(x, [])
       gx2 = groupby(x, [:id, :id2])
GroupedDataFrame with 4 groups based on keys: id, id2
First Group (2 rows): id = 1, id2 = 1
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
⋮
Last Group (2 rows): id = 4, id2 = 2
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     4      2  0.805686
   2 │     4      2  0.0639657

julia> parent(gx2) # get the parent DataFrame
8×3 DataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     2      2  0.547894
   3 │     3      1  0.0878364
   4 │     4      2  0.805686
   5 │     1      1  0.0373405
   6 │     2      2  0.849607
   7 │     3      1  0.172853
   8 │     4      2  0.0639657

julia> vcat(gx2...) # back to the DataFrame, but in a different order of rows than the original
8×3 DataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
   3 │     2      2  0.547894
   4 │     2      2  0.849607
   5 │     3      1  0.0878364
   6 │     3      1  0.172853
   7 │     4      2  0.805686
   8 │     4      2  0.0639657

julia> DataFrame(gx2) # the same
8×3 DataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
   3 │     2      2  0.547894
   4 │     2      2  0.849607
   5 │     3      1  0.0878364
   6 │     3      1  0.172853
   7 │     4      2  0.805686
   8 │     4      2  0.0639657

julia> # DataFrame(gx2, keepkeys=false) # drop grouping columns when creating a data frame
       groupcols(gx2) # vector of names of grouping variables
2-element Vector{Symbol}:
 :id
 :id2

julia> valuecols(gx2) # and non-grouping variables
1-element Vector{Symbol}:
 :v

julia> groupindices(gx2) # group indices in parent(gx2)
8-element Vector{Union{Missing, Int64}}:
 1
 2
 3
 4
 1
 2
 3
 4

julia> kgx2 = keys(gx2)
4-element DataFrames.GroupKeys{GroupedDataFrame{DataFrame}}:
 GroupKey: (id = 1, id2 = 1)
 GroupKey: (id = 2, id2 = 2)
 GroupKey: (id = 3, id2 = 1)
 GroupKey: (id = 4, id2 = 2)
```

You can index into a `GroupedDataFrame` like to a vector or to a dictionary.
The second form acceps `GroupKey`, `NamedTuple` or a `Tuple`

```julia
julia> gx2
GroupedDataFrame with 4 groups based on keys: id, id2
First Group (2 rows): id = 1, id2 = 1
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
⋮
Last Group (2 rows): id = 4, id2 = 2
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     4      2  0.805686
   2 │     4      2  0.0639657

julia> k = keys(gx2)[1]
GroupKey: (id = 1, id2 = 1)

julia> ntk = NamedTuple(k)
(id = 1, id2 = 1)

julia> tk = Tuple(k)
(1, 1)
```

the operations below produce the same result and are fast

```julia
julia> gx2[1]
2×3 SubDataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405

julia> gx2[k]
2×3 SubDataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405

julia> gx2[ntk]
2×3 SubDataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405

julia> gx2[tk]
2×3 SubDataFrame
 Row │ id     id2    v
     │ Int64  Int64  Float64
─────┼─────────────────────────
   1 │     1      1  0.788152
   2 │     1      1  0.0373405
```

handling missing values

```julia
julia> x = DataFrame(id = [missing, 5, 1, 3, missing], x = 1:5)
5×2 DataFrame
 Row │ id       x
     │ Int64?   Int64
─────┼────────────────
   1 │ missing      1
   2 │       5      2
   3 │       1      3
   4 │       3      4
   5 │ missing      5

julia> groupby(x, :id) # by default groups include mising values and are not sorted
GroupedDataFrame with 4 groups based on key: id
First Group (1 row): id = 1
 Row │ id      x
     │ Int64?  Int64
─────┼───────────────
   1 │      1      3
⋮
Last Group (2 rows): id = missing
 Row │ id       x
     │ Int64?   Int64
─────┼────────────────
   1 │ missing      1
   2 │ missing      5

julia> groupby(x, :id, sort=true, skipmissing=true) # but we can change it
GroupedDataFrame with 3 groups based on key: id
First Group (1 row): id = 1
 Row │ id      x
     │ Int64?  Int64
─────┼───────────────
   1 │      1      3
⋮
Last Group (1 row): id = 5
 Row │ id      x
     │ Int64?  Int64
─────┼───────────────
   1 │      5      2
```

### Performing transformations by group using `combine`, `select`, `select!`, `transform`, and `transform!`

```julia
julia> using Statistics

julia> using Pipe

julia> # ENV["LINES"] = 15 # reduce the number of rows in the output
       x = DataFrame(id=rand('a':'d', 100), v=rand(100))
100×2 DataFrame
 Row │ id    v
     │ Char  Float64
─────┼─────────────────
   1 │ a     0.87743
   2 │ a     0.399395
   3 │ a     0.553806
   4 │ b     0.0605387
   5 │ d     0.914898
   6 │ a     0.676006
   7 │ c     0.416111
   8 │ a     0.402844
  ⋮  │  ⋮        ⋮
  94 │ b     0.328505
  95 │ a     0.0152568
  96 │ d     0.833487
  97 │ a     0.468008
  98 │ b     0.439362
  99 │ a     0.049321
 100 │ a     0.341828
        85 rows omitted

julia> # apply a function to each group of a data frame
       # combine keeps as many rows as are returned from the function
       @pipe x |> groupby(_, :id) |> combine(_, :v=>mean)
4×2 DataFrame
 Row │ id    v_mean
     │ Char  Float64
─────┼────────────────
   1 │ a     0.570961
   2 │ b     0.456567
   3 │ d     0.511691
   4 │ c     0.384864

julia> a = groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (30 rows): id = 'a'
 Row │ id    v
     │ Char  Float64
─────┼─────────────────
   1 │ a     0.87743
   2 │ a     0.399395
   3 │ a     0.553806
   4 │ a     0.676006
   5 │ a     0.402844
   6 │ a     0.951736
   7 │ a     0.208852
   8 │ a     0.991147
  ⋮  │  ⋮        ⋮
  23 │ a     0.913868
  24 │ a     0.342693
  25 │ a     0.535416
  26 │ a     0.575342
  27 │ a     0.0152568
  28 │ a     0.468008
  29 │ a     0.049321
  30 │ a     0.341828
        14 rows omitted
⋮
Last Group (16 rows): id = 'c'
 Row │ id    v
     │ Char  Float64
─────┼─────────────────
   1 │ c     0.416111
   2 │ c     0.68094
   3 │ c     0.43992
   4 │ c     0.144842
   5 │ c     0.349104
   6 │ c     0.0685128
   7 │ c     0.405401
   8 │ c     0.182291
   9 │ c     0.319109
  10 │ c     0.745278
  11 │ c     0.0136477
  12 │ c     0.0164793
  13 │ c     0.527299
  14 │ c     0.24355
  15 │ c     0.737938
  16 │ c     0.867397

julia> combine(a, :v=>mean)
4×2 DataFrame
 Row │ id    v_mean
     │ Char  Float64
─────┼────────────────
   1 │ a     0.570961
   2 │ b     0.456567
   3 │ d     0.511691
   4 │ c     0.384864

julia> x.id2 = axes(x, 1)
Base.OneTo(100)

julia> # select and transform keep as many rows as are in the source data frame and in correct order
       # additionally transform keeps all columns from the source
       @pipe x |> groupby(_, :id) |> transform(_, :v=>mean)
100×4 DataFrame
 Row │ id    v          id2    v_mean
     │ Char  Float64    Int64  Float64
─────┼──────────────────────────────────
   1 │ a     0.87743        1  0.570961
   2 │ a     0.399395       2  0.570961
   3 │ a     0.553806       3  0.570961
   4 │ b     0.0605387      4  0.456567
   5 │ d     0.914898       5  0.511691
   6 │ a     0.676006       6  0.570961
   7 │ c     0.416111       7  0.384864
   8 │ a     0.402844       8  0.570961
  ⋮  │  ⋮        ⋮        ⋮       ⋮
  94 │ b     0.328505      94  0.456567
  95 │ a     0.0152568     95  0.570961
  96 │ d     0.833487      96  0.511691
  97 │ a     0.468008      97  0.570961
  98 │ b     0.439362      98  0.456567
  99 │ a     0.049321      99  0.570961
 100 │ a     0.341828     100  0.570961
                         85 rows omitted

julia> a = groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (30 rows): id = 'a'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ a     0.87743        1
   2 │ a     0.399395       2
   3 │ a     0.553806       3
   4 │ a     0.676006       6
   5 │ a     0.402844       8
   6 │ a     0.951736       9
   7 │ a     0.208852      16
   8 │ a     0.991147      22
  ⋮  │  ⋮        ⋮        ⋮
  23 │ a     0.913868      82
  24 │ a     0.342693      83
  25 │ a     0.535416      86
  26 │ a     0.575342      90
  27 │ a     0.0152568     95
  28 │ a     0.468008      97
  29 │ a     0.049321      99
  30 │ a     0.341828     100
               14 rows omitted
⋮
Last Group (16 rows): id = 'c'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ c     0.416111       7
   2 │ c     0.68094       10
   3 │ c     0.43992       15
   4 │ c     0.144842      20
   5 │ c     0.349104      38
   6 │ c     0.0685128     44
   7 │ c     0.405401      51
   8 │ c     0.182291      52
   9 │ c     0.319109      54
  10 │ c     0.745278      57
  11 │ c     0.0136477     58
  12 │ c     0.0164793     63
  13 │ c     0.527299      67
  14 │ c     0.24355       72
  15 │ c     0.737938      81
  16 │ c     0.867397      91

julia> transform(a, :v=>mean)
100×4 DataFrame
 Row │ id    v          id2    v_mean
     │ Char  Float64    Int64  Float64
─────┼──────────────────────────────────
   1 │ a     0.87743        1  0.570961
   2 │ a     0.399395       2  0.570961
   3 │ a     0.553806       3  0.570961
   4 │ b     0.0605387      4  0.456567
   5 │ d     0.914898       5  0.511691
   6 │ a     0.676006       6  0.570961
   7 │ c     0.416111       7  0.384864
   8 │ a     0.402844       8  0.570961
  ⋮  │  ⋮        ⋮        ⋮       ⋮
  94 │ b     0.328505      94  0.456567
  95 │ a     0.0152568     95  0.570961
  96 │ d     0.833487      96  0.511691
  97 │ a     0.468008      97  0.570961
  98 │ b     0.439362      98  0.456567
  99 │ a     0.049321      99  0.570961
 100 │ a     0.341828     100  0.570961
                         85 rows omitted

julia> # note that combine reorders rows by group of GroupedDataFrame
       @pipe x |> groupby(_, :id) |> combine(_, :id2, :v=>mean)
100×3 DataFrame
 Row │ id    id2    v_mean
     │ Char  Int64  Float64
─────┼───────────────────────
   1 │ a         1  0.570961
   2 │ a         2  0.570961
   3 │ a         3  0.570961
   4 │ a         6  0.570961
   5 │ a         8  0.570961
   6 │ a         9  0.570961
   7 │ a        16  0.570961
   8 │ a        22  0.570961
  ⋮  │  ⋮      ⋮       ⋮
  94 │ c        57  0.384864
  95 │ c        58  0.384864
  96 │ c        63  0.384864
  97 │ c        67  0.384864
  98 │ c        72  0.384864
  99 │ c        81  0.384864
 100 │ c        91  0.384864
              85 rows omitted

julia> a = groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (30 rows): id = 'a'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ a     0.87743        1
   2 │ a     0.399395       2
   3 │ a     0.553806       3
   4 │ a     0.676006       6
   5 │ a     0.402844       8
   6 │ a     0.951736       9
   7 │ a     0.208852      16
   8 │ a     0.991147      22
  ⋮  │  ⋮        ⋮        ⋮
  23 │ a     0.913868      82
  24 │ a     0.342693      83
  25 │ a     0.535416      86
  26 │ a     0.575342      90
  27 │ a     0.0152568     95
  28 │ a     0.468008      97
  29 │ a     0.049321      99
  30 │ a     0.341828     100
               14 rows omitted
⋮
Last Group (16 rows): id = 'c'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ c     0.416111       7
   2 │ c     0.68094       10
   3 │ c     0.43992       15
   4 │ c     0.144842      20
   5 │ c     0.349104      38
   6 │ c     0.0685128     44
   7 │ c     0.405401      51
   8 │ c     0.182291      52
   9 │ c     0.319109      54
  10 │ c     0.745278      57
  11 │ c     0.0136477     58
  12 │ c     0.0164793     63
  13 │ c     0.527299      67
  14 │ c     0.24355       72
  15 │ c     0.737938      81
  16 │ c     0.867397      91

julia> combine(a, :id2, :v=>mean)
100×3 DataFrame
 Row │ id    id2    v_mean
     │ Char  Int64  Float64
─────┼───────────────────────
   1 │ a         1  0.570961
   2 │ a         2  0.570961
   3 │ a         3  0.570961
   4 │ a         6  0.570961
   5 │ a         8  0.570961
   6 │ a         9  0.570961
   7 │ a        16  0.570961
   8 │ a        22  0.570961
  ⋮  │  ⋮      ⋮       ⋮
  94 │ c        57  0.384864
  95 │ c        58  0.384864
  96 │ c        63  0.384864
  97 │ c        67  0.384864
  98 │ c        72  0.384864
  99 │ c        81  0.384864
 100 │ c        91  0.384864
              85 rows omitted

julia> # we give a custom name for the result column
       @pipe x |> groupby(_, :id) |> combine(_, :v=>mean=>:res)
4×2 DataFrame
 Row │ id    res
     │ Char  Float64
─────┼────────────────
   1 │ a     0.570961
   2 │ b     0.456567
   3 │ d     0.511691
   4 │ c     0.384864

julia> a = groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (30 rows): id = 'a'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ a     0.87743        1
   2 │ a     0.399395       2
   3 │ a     0.553806       3
   4 │ a     0.676006       6
   5 │ a     0.402844       8
   6 │ a     0.951736       9
   7 │ a     0.208852      16
   8 │ a     0.991147      22
  ⋮  │  ⋮        ⋮        ⋮
  23 │ a     0.913868      82
  24 │ a     0.342693      83
  25 │ a     0.535416      86
  26 │ a     0.575342      90
  27 │ a     0.0152568     95
  28 │ a     0.468008      97
  29 │ a     0.049321      99
  30 │ a     0.341828     100
               14 rows omitted
⋮
Last Group (16 rows): id = 'c'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ c     0.416111       7
   2 │ c     0.68094       10
   3 │ c     0.43992       15
   4 │ c     0.144842      20
   5 │ c     0.349104      38
   6 │ c     0.0685128     44
   7 │ c     0.405401      51
   8 │ c     0.182291      52
   9 │ c     0.319109      54
  10 │ c     0.745278      57
  11 │ c     0.0136477     58
  12 │ c     0.0164793     63
  13 │ c     0.527299      67
  14 │ c     0.24355       72
  15 │ c     0.737938      81
  16 │ c     0.867397      91

julia> combine(a, :v=>mean=>:res)
4×2 DataFrame
 Row │ id    res
     │ Char  Float64
─────┼────────────────
   1 │ a     0.570961
   2 │ b     0.456567
   3 │ d     0.511691
   4 │ c     0.384864

julia> # you can have multiple operations
       @pipe x |> groupby(_, :id) |> combine(_, :v=>mean=>:res1, :v=>sum=>:res2, nrow=>:n)
4×4 DataFrame
 Row │ id    res1      res2      n
     │ Char  Float64   Float64   Int64
─────┼─────────────────────────────────
   1 │ a     0.570961  17.1288      30
   2 │ b     0.456567  11.8707      26
   3 │ d     0.511691  14.3273      28
   4 │ c     0.384864   6.15782     16

julia> a = groupby(x, :id)
GroupedDataFrame with 4 groups based on key: id
First Group (30 rows): id = 'a'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ a     0.87743        1
   2 │ a     0.399395       2
   3 │ a     0.553806       3
   4 │ a     0.676006       6
   5 │ a     0.402844       8
   6 │ a     0.951736       9
   7 │ a     0.208852      16
   8 │ a     0.991147      22
  ⋮  │  ⋮        ⋮        ⋮
  23 │ a     0.913868      82
  24 │ a     0.342693      83
  25 │ a     0.535416      86
  26 │ a     0.575342      90
  27 │ a     0.0152568     95
  28 │ a     0.468008      97
  29 │ a     0.049321      99
  30 │ a     0.341828     100
               14 rows omitted
⋮
Last Group (16 rows): id = 'c'
 Row │ id    v          id2
     │ Char  Float64    Int64
─────┼────────────────────────
   1 │ c     0.416111       7
   2 │ c     0.68094       10
   3 │ c     0.43992       15
   4 │ c     0.144842      20
   5 │ c     0.349104      38
   6 │ c     0.0685128     44
   7 │ c     0.405401      51
   8 │ c     0.182291      52
   9 │ c     0.319109      54
  10 │ c     0.745278      57
  11 │ c     0.0136477     58
  12 │ c     0.0164793     63
  13 │ c     0.527299      67
  14 │ c     0.24355       72
  15 │ c     0.737938      81
  16 │ c     0.867397      91

julia> combine(a, :v=>mean=>:res1, :v=>sum=>:res2, nrow=>:n)
4×4 DataFrame
 Row │ id    res1      res2      n
     │ Char  Float64   Float64   Int64
─────┼─────────────────────────────────
   1 │ a     0.570961  17.1288      30
   2 │ b     0.456567  11.8707      26
   3 │ d     0.511691  14.3273      28
   4 │ c     0.384864   6.15782     16
```

Additional notes:

* `select!` and `transform!` perform operations in-place
* The general syntax for transformation is `source_columns => function => target_column`
* if you pass multiple columns to a function they are treated as positional arguments
* `ByRow` and `AsTable` work exactly like discussed for operations on data frames in 05_columns.ipynb
* you can automatically groupby again the result of `combine`, `select` etc. by passing `ungroup=false` keyword argument to them
* similarly `keepkeys` keyword argument allows you to drop grouping columns from the resulting data frame
  It is also allowed to pass a function to all these functions (also - as a special case, as a first argument). In this case the return value can be a table. In particular it allows for an easy dropping of groups if you return an empty table from the function.
  If you pass a function you can use a `do` block syntax. In case of passing a function it gets a `SubDataFrame` as its argument.
  Here is an example:

```julia
julia> combine(groupby(x, :id)) do sdf
           n = nrow(sdf)
           n < 25 ? DataFrame() : DataFrame(n=n) # drop groups with low number of rows
       end
3×2 DataFrame
 Row │ id    n
     │ Char  Int64
─────┼─────────────
   1 │ a        30
   2 │ b        26
   3 │ d        28
```

You can also produce multiple columns in a single operation, e.g.:

```julia
julia> df = DataFrame(id=[1,1,2,2], val=[1,2,3,4])
4×2 DataFrame
 Row │ id     val
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     1      2
   3 │     2      3
   4 │     2      4

julia> @pipe df |> groupby(_, :id) |> combine(_, :val => (x -> [x]) => AsTable)
2×3 DataFrame
 Row │ id     x1     x2
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4

julia> a = groupby(df, :id)
GroupedDataFrame with 2 groups based on key: id
First Group (2 rows): id = 1
 Row │ id     val
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     1      2
⋮
Last Group (2 rows): id = 2
 Row │ id     val
     │ Int64  Int64
─────┼──────────────
   1 │     2      3
   2 │     2      4

julia> combine(a, :val => (x -> [x]) => AsTable)
2×3 DataFrame
 Row │ id     x1     x2
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4

julia> @pipe df |> groupby(_, :id) |> combine(_, :val => (x -> [x]) => [:c1, :c2])
2×3 DataFrame
 Row │ id     c1     c2
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4

julia> a = groupby(df, :id)
GroupedDataFrame with 2 groups based on key: id
First Group (2 rows): id = 1
 Row │ id     val
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     1      2
⋮
Last Group (2 rows): id = 2
 Row │ id     val
     │ Int64  Int64
─────┼──────────────
   1 │     2      3
   2 │     2      4

julia> combine(a, :val => (x -> [x]) => [:c1, :c2])
2×3 DataFrame
 Row │ id     c1     c2
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4
```

### Aggregation of a data frame using `mapcols`

```julia
julia> x = DataFrame(rand(10, 10), :auto)
10×10 DataFrame
 Row │ x1         x2         x3        x4        x5        x6        x7        ⋯
     │ Float64    Float64    Float64   Float64   Float64   Float64   Float64   ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 0.832722   0.0721982  0.701226  0.909106  0.709557  0.661371  0.328824  ⋯
   2 │ 0.316074   0.940022   0.959194  0.55815   0.520087  0.739064  0.0169929
   3 │ 0.972984   0.384554   0.698192  0.322473  0.609766  0.951336  0.334443
   4 │ 0.0949054  0.244623   0.465502  0.943385  0.851823  0.198792  0.306153
   5 │ 0.353529   0.0372626  0.189819  0.552051  0.952565  0.89066   0.307563  ⋯
   6 │ 0.8602     0.686413   0.156375  0.183011  0.677268  0.761964  0.566883
   7 │ 0.587753   0.930285   0.380452  0.479815  0.220562  0.165599  0.318603
   8 │ 0.106945   0.578883   0.313543  0.759899  0.25679   0.220681  0.267038
   9 │ 0.122191   0.415331   0.93809   0.357298  0.684558  0.542676  0.568009  ⋯
  10 │ 0.278408   0.1563     0.3996    0.360462  0.979013  0.071382  0.694684
                                                               3 columns omitted

julia> mapcols(mean, x)
1×10 DataFrame
 Row │ x1        x2        x3        x4        x5        x6        x7        x ⋯
     │ Float64   Float64   Float64   Float64   Float64   Float64   Float64   F ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 0.452571  0.444587  0.520199  0.542565  0.646199  0.520353  0.370919  0 ⋯
                                                               3 columns omitted
```

### Mapping rows and columns using `eachcol` and `eachrow`

```julia
julia> map(mean, eachcol(x)) # map a function over each column and return a vector
10-element Vector{Float64}:
 0.45257118783073
 0.4445871748953844
 0.5201992991956359
 0.542565039257149
 0.6461990293938424
 0.5203525233966235
 0.37091919765034065
 0.447096846466688
 0.4934476913783305
 0.6350001160476961

julia> # an iteration returns a Pair with column name and values
       foreach(c -> println(c[1], ": ", mean(c[2])), pairs(eachcol(x)))
x1: 0.45257118783073
x2: 0.4445871748953844
x3: 0.5201992991956359
x4: 0.542565039257149
x5: 0.6461990293938424
x6: 0.5203525233966235
x7: 0.37091919765034065
x8: 0.447096846466688
x9: 0.4934476913783305
x10: 0.6350001160476961

julia> # now the returned value is DataFrameRow which works as a NamedTuple but is a view to a parent DataFrame
       map(r -> r.x1/r.x2, eachrow(x))
10-element Vector{Float64}:
 11.533831410892144
  0.3362415564583734
  2.5301591467499156
  0.38796644619576853
  9.487497838829526
  1.2531806519870232
  0.6317989311832436
  0.18474300543290842
  0.2942025282655917
  1.7812420867552643

julia> # it prints like a data frame, only the caption is different so that you know the type of the object
       er = eachrow(x)
10×10 DataFrameRows
 Row │ x1         x2         x3        x4        x5        x6        x7        ⋯
     │ Float64    Float64    Float64   Float64   Float64   Float64   Float64   ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 0.832722   0.0721982  0.701226  0.909106  0.709557  0.661371  0.328824  ⋯
   2 │ 0.316074   0.940022   0.959194  0.55815   0.520087  0.739064  0.0169929
   3 │ 0.972984   0.384554   0.698192  0.322473  0.609766  0.951336  0.334443
   4 │ 0.0949054  0.244623   0.465502  0.943385  0.851823  0.198792  0.306153
   5 │ 0.353529   0.0372626  0.189819  0.552051  0.952565  0.89066   0.307563  ⋯
   6 │ 0.8602     0.686413   0.156375  0.183011  0.677268  0.761964  0.566883
   7 │ 0.587753   0.930285   0.380452  0.479815  0.220562  0.165599  0.318603
   8 │ 0.106945   0.578883   0.313543  0.759899  0.25679   0.220681  0.267038
   9 │ 0.122191   0.415331   0.93809   0.357298  0.684558  0.542676  0.568009  ⋯
  10 │ 0.278408   0.1563     0.3996    0.360462  0.979013  0.071382  0.694684
                                                               3 columns omitted

julia> er.x1 # you can access columns of a parent data frame directly
10-element Vector{Float64}:
 0.832721793256604
 0.3160743784840815
 0.9729840104367511
 0.09490537190959802
 0.3535292316067833
 0.8602000054898018
 0.5877527802589152
 0.1069446372583992
 0.12219134770416118
 0.278408321902204

julia> # it prints like a data frame, only the caption is different so that you know the type of the object
       ec = eachcol(x)
10×10 DataFrameColumns
 Row │ x1         x2         x3        x4        x5        x6        x7        ⋯
     │ Float64    Float64    Float64   Float64   Float64   Float64   Float64   ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 0.832722   0.0721982  0.701226  0.909106  0.709557  0.661371  0.328824  ⋯
   2 │ 0.316074   0.940022   0.959194  0.55815   0.520087  0.739064  0.0169929
   3 │ 0.972984   0.384554   0.698192  0.322473  0.609766  0.951336  0.334443
   4 │ 0.0949054  0.244623   0.465502  0.943385  0.851823  0.198792  0.306153
   5 │ 0.353529   0.0372626  0.189819  0.552051  0.952565  0.89066   0.307563  ⋯
   6 │ 0.8602     0.686413   0.156375  0.183011  0.677268  0.761964  0.566883
   7 │ 0.587753   0.930285   0.380452  0.479815  0.220562  0.165599  0.318603
   8 │ 0.106945   0.578883   0.313543  0.759899  0.25679   0.220681  0.267038
   9 │ 0.122191   0.415331   0.93809   0.357298  0.684558  0.542676  0.568009  ⋯
  10 │ 0.278408   0.1563     0.3996    0.360462  0.979013  0.071382  0.694684
                                                               3 columns omitted

julia> ec.x1 # you can access columns of a parent data frame directly
10-element Vector{Float64}:
 0.832721793256604
 0.3160743784840815
 0.9729840104367511
 0.09490537190959802
 0.3535292316067833
 0.8602000054898018
 0.5877527802589152
 0.1069446372583992
 0.12219134770416118
 0.278408321902204
```

### Transposing

you can transpose a data frame using `permutedims`:

```julia
julia> df = DataFrame(reshape(1:12, 3, 4), :auto)
3×4 DataFrame
 Row │ x1     x2     x3     x4
     │ Int64  Int64  Int64  Int64
─────┼────────────────────────────
   1 │     1      4      7     10
   2 │     2      5      8     11
   3 │     3      6      9     12

julia> df.names = ["a", "b", "c"]
3-element Vector{String}:
 "a"
 "b"
 "c"

julia> permutedims(df, :names)
4×4 DataFrame
 Row │ names   a      b      c
     │ String  Int64  Int64  Int64
─────┼─────────────────────────────
   1 │ x1          1      2      3
   2 │ x2          4      5      6
   3 │ x3          7      8      9
   4 │ x4         10     11     12
```
