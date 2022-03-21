```julia
julia> using DataFrames
```

## Reshaping DataFrames
### Wide to long

```julia
julia> x = DataFrame(id=[1,2,3,4], id2=[1,1,2,2], M1=[11,12,13,14], M2=[111,112,113,114])
4×4 DataFrame
 Row │ id     id2    M1     M2
     │ Int64  Int64  Int64  Int64
─────┼────────────────────────────
   1 │     1      1     11    111
   2 │     2      1     12    112
   3 │     3      2     13    113
   4 │     4      2     14    114

julia> stack(x, [:M1, :M2], :id) # first pass measure variables and then id-variable
8×3 DataFrame
 Row │ id     variable  value
     │ Int64  String    Int64
─────┼────────────────────────
   1 │     1  M1           11
   2 │     2  M1           12
   3 │     3  M1           13
   4 │     4  M1           14
   5 │     1  M2          111
   6 │     2  M2          112
   7 │     3  M2          113
   8 │     4  M2          114
```


add `view=true` keyword argument to make a view; in that case columns of the resulting data frame share memory with columns of the source data frame, so the operation is potentially unsafe

```julia
julia> # optionally you can rename columns
       stack(x, ["M1", "M2"], "id", variable_name="key", value_name="observed")
8×3 DataFrame
 Row │ id     key     observed
     │ Int64  String  Int64
─────┼─────────────────────────
   1 │     1  M1            11
   2 │     2  M1            12
   3 │     3  M1            13
   4 │     4  M1            14
   5 │     1  M2           111
   6 │     2  M2           112
   7 │     3  M2           113
   8 │     4  M2           114
```


if second argument is omitted in `stack` , all other columns are assumed to be the id-variables

```julia
julia> stack(x, Not([:id, :id2]))
8×4 DataFrame
 Row │ id     id2    variable  value
     │ Int64  Int64  String    Int64
─────┼───────────────────────────────
   1 │     1      1  M1           11
   2 │     2      1  M1           12
   3 │     3      2  M1           13
   4 │     4      2  M1           14
   5 │     1      1  M2          111
   6 │     2      1  M2          112
   7 │     3      2  M2          113
   8 │     4      2  M2          114

julia> stack(x, Not([1, 2])) # you can use index instead of symbol
8×4 DataFrame
 Row │ id     id2    variable  value
     │ Int64  Int64  String    Int64
─────┼───────────────────────────────
   1 │     1      1  M1           11
   2 │     2      1  M1           12
   3 │     3      2  M1           13
   4 │     4      2  M1           14
   5 │     1      1  M2          111
   6 │     2      1  M2          112
   7 │     3      2  M2          113
   8 │     4      2  M2          114

julia> x = DataFrame(id = [1,1,1], id2=['a','b','c'], a1 = rand(3), a2 = rand(3))
3×4 DataFrame
 Row │ id     id2   a1         a2
     │ Int64  Char  Float64    Float64
─────┼──────────────────────────────────
   1 │     1  a     0.0304411  0.864017
   2 │     1  b     0.992844   0.787174
   3 │     1  c     0.213685   0.946907
```


 if `stack` is not passed any measure variables by default numeric variables (Float type) are selected as measures

```julia
julia> stack(x)
6×4 DataFrame
 Row │ id     id2   variable  value
     │ Int64  Char  String    Float64
─────┼──────────────────────────────────
   1 │     1  a     a1        0.0304411
   2 │     1  b     a1        0.992844
   3 │     1  c     a1        0.213685
   4 │     1  a     a2        0.864017
   5 │     1  b     a2        0.787174
   6 │     1  c     a2        0.946907
```


here all columns are treated as measures:

```julia
julia> stack(DataFrame(rand(3,2), :auto))
6×2 DataFrame
 Row │ variable  value
     │ String    Float64
─────┼────────────────────
   1 │ x1        0.468665
   2 │ x1        0.284543
   3 │ x1        0.387644
   4 │ x2        0.148392
   5 │ x2        0.645338
   6 │ x2        0.462205

julia> df = DataFrame(rand(3,2), :auto)
3×2 DataFrame
 Row │ x1         x2
     │ Float64    Float64
─────┼─────────────────────
   1 │ 0.0929769  0.443311
   2 │ 0.0363852  0.56913
   3 │ 0.687495   0.582143

julia> df.key = [1,1,1]
3-element Vector{Int64}:
 1
 1
 1

julia> mdf = stack(df) # duplicates in key are silently accepted
6×3 DataFrame
 Row │ key    variable  value
     │ Int64  String    Float64
─────┼────────────────────────────
   1 │     1  x1        0.0929769
   2 │     1  x1        0.0363852
   3 │     1  x1        0.687495
   4 │     1  x2        0.443311
   5 │     1  x2        0.56913
   6 │     1  x2        0.582143
```


### Long to wide

```julia
julia> x = DataFrame(id = [1,1,1], id2=['a','b','c'], a1 = rand(3), a2 = rand(3))
3×4 DataFrame
 Row │ id     id2   a1        a2
     │ Int64  Char  Float64   Float64
─────┼─────────────────────────────────
   1 │     1  a     0.283399  0.72243
   2 │     1  b     0.891929  0.221137
   3 │     1  c     0.572949  0.699536

julia> y = stack(x)
6×4 DataFrame
 Row │ id     id2   variable  value
     │ Int64  Char  String    Float64
─────┼─────────────────────────────────
   1 │     1  a     a1        0.283399
   2 │     1  b     a1        0.891929
   3 │     1  c     a1        0.572949
   4 │     1  a     a2        0.72243
   5 │     1  b     a2        0.221137
   6 │     1  c     a2        0.699536

julia> unstack(y, :id2, :variable, :value) # standard unstack with a specified key
3×3 DataFrame
 Row │ id2   a1        a2
     │ Char  Float64?  Float64?
─────┼──────────────────────────
   1 │ a     0.283399  0.72243
   2 │ b     0.891929  0.221137
   3 │ c     0.572949  0.699536

julia> unstack(y, :variable, :value) # all other columns are treated as keys
3×4 DataFrame
 Row │ id     id2   a1        a2
     │ Int64  Char  Float64?  Float64?
─────┼─────────────────────────────────
   1 │     1  a     0.283399  0.72243
   2 │     1  b     0.891929  0.221137
   3 │     1  c     0.572949  0.699536

julia> # all columns other than named :variable and :value are treated as keys
       unstack(y)
3×4 DataFrame
 Row │ id     id2   a1        a2
     │ Int64  Char  Float64?  Float64?
─────┼─────────────────────────────────
   1 │     1  a     0.283399  0.72243
   2 │     1  b     0.891929  0.221137
   3 │     1  c     0.572949  0.699536
```
