```julia
julia> using DataFrames
```

## Joining DataFrames
### Preparing DataFrames for a join

```julia
julia> x = DataFrame(ID=[1,2,3,4,missing], name = ["Alice", "Bob", "Conor", "Dave","Zed"])
5×2 DataFrame
 Row │ ID       name
     │ Int64?   String
─────┼─────────────────
   1 │       1  Alice
   2 │       2  Bob
   3 │       3  Conor
   4 │       4  Dave
   5 │ missing  Zed

julia> y = DataFrame(id=[1,2,5,6,missing], age=[21,22,23,24,99])
5×2 DataFrame
 Row │ id       age
     │ Int64?   Int64
─────┼────────────────
   1 │       1     21
   2 │       2     22
   3 │       5     23
   4 │       6     24
   5 │ missing     99
```


Rules for the `on` keyword argument:
* a single `Symbol` or string if joining on one column with the same name, e.g. `on=:id`
* a `Pair` of `Symbol`s or string if joining on one column with different names, e.g. `on=:id=>:id2`
* a vector of `Symbol`s or strings if joining on multiple columns with the same name, e.g. `on=[:id1, :id2]`
* a vector of `Pair`s of `Symbol`s or strings if joining on multiple columns with the same name, e.g. `on=[:a1=>:a2, :b1=>:b2]`
* a vector containing a combination of `Symbol`s or strings or `Pair` of `Symbol`s or strings, e.g. `on=[:a1=>:a2, :b1]`
### Standard joins: inner, left, right, outer, semi, anti

```julia
julia> innerjoin(x, y, on=:ID=>:id) # missing is not allowed to join-on by default
Error: ArgumentError: missing values in key columns are not allowed when matchmissing == :error

julia> innerjoin(x, y, on=:ID=>:id, matchmissing=:equal)
3×3 DataFrame
 Row │ ID       name    age
     │ Int64?   String  Int64
─────┼────────────────────────
   1 │       1  Alice      21
   2 │       2  Bob        22
   3 │ missing  Zed        99

julia> innerjoin(x, y, on=:ID=>:id, matchmissing=:notequal)
2×3 DataFrame
 Row │ ID      name    age
     │ Int64?  String  Int64
─────┼───────────────────────
   1 │      1  Alice      21
   2 │      2  Bob        22

julia> leftjoin(x, y, on="ID"=>"id", matchmissing=:notequal)
5×3 DataFrame
 Row │ ID       name    age
     │ Int64?   String  Int64?
─────┼──────────────────────────
   1 │       1  Alice        21
   2 │       2  Bob          22
   3 │       3  Conor   missing
   4 │       4  Dave    missing
   5 │ missing  Zed     missing

julia> rightjoin(x, y, on=:ID=>:id, matchmissing=:notequal)
5×3 DataFrame
 Row │ ID       name     age
     │ Int64?   String?  Int64
─────┼─────────────────────────
   1 │       1  Alice       21
   2 │       2  Bob         22
   3 │       5  missing     23
   4 │       6  missing     24
   5 │ missing  missing     99

julia> # rightjoin(x, y, on=:ID=>:id, matchmissing=:equal)
       outerjoin(x, y, on=:ID=>:id, matchmissing=:equal)
7×3 DataFrame
 Row │ ID       name     age
     │ Int64?   String?  Int64?
─────┼───────────────────────────
   1 │       1  Alice         21
   2 │       2  Bob           22
   3 │ missing  Zed           99
   4 │       3  Conor    missing
   5 │       4  Dave     missing
   6 │       5  missing       23
   7 │       6  missing       24
```


### Cross join
(here no `on` argument)

```julia
julia> a = DataFrame(x=[1,2])
2×1 DataFrame
 Row │ x
     │ Int64
─────┼───────
   1 │     1
   2 │     2

julia> b = DataFrame(y=["a","b","c"])
3×1 DataFrame
 Row │ y
     │ String
─────┼────────
   1 │ a
   2 │ b
   3 │ c

julia> crossjoin(a, b)
6×2 DataFrame
 Row │ x      y
     │ Int64  String
─────┼───────────────
   1 │     1  a
   2 │     1  b
   3 │     1  c
   4 │     2  a
   5 │     2  b
   6 │     2  c
```


### Complex cases of joins

```julia
julia> x = DataFrame(id1=[1,1,2,2,missing,missing],
                     id2=[1,11,2,21,missing,99],
                     name = ["Alice", "Bob", "Conor", "Dave","Zed", "Zoe"])
6×3 DataFrame
 Row │ id1      id2      name
     │ Int64?   Int64?   String
─────┼──────────────────────────
   1 │       1        1  Alice
   2 │       1       11  Bob
   3 │       2        2  Conor
   4 │       2       21  Dave
   5 │ missing  missing  Zed
   6 │ missing       99  Zoe

julia> y = DataFrame(id1=[1,1,3,3,missing,missing],
                     id2=[11,1,31,3,missing,999],
                     age = [21,22,23,24,99, 100])
6×3 DataFrame
 Row │ id1      id2      age
     │ Int64?   Int64?   Int64
─────┼─────────────────────────
   1 │       1       11     21
   2 │       1        1     22
   3 │       3       31     23
   4 │       3        3     24
   5 │ missing  missing     99
   6 │ missing      999    100

julia> innerjoin(x, y, on=[:id1, :id2], matchmissing=:notequal) # joining on two columns
2×4 DataFrame
 Row │ id1     id2     name    age
     │ Int64?  Int64?  String  Int64
─────┼───────────────────────────────
   1 │      1      11  Bob        21
   2 │      1       1  Alice      22

julia> outerjoin(x, y, on=:id1, makeunique=true, indicator=:source, matchmissing=:equal)
12×6 DataFrame
 Row │ id1      id2      name     id2_1    age      source
     │ Int64?   Int64?   String?  Int64?   Int64?   String
─────┼─────────────────────────────────────────────────────────
   1 │       1        1  Alice         11       21  both
   2 │       1       11  Bob           11       21  both
   3 │       1        1  Alice          1       22  both
   4 │       1       11  Bob            1       22  both
   5 │ missing  missing  Zed      missing       99  both
   6 │ missing       99  Zoe      missing       99  both
   7 │ missing  missing  Zed          999      100  both
   8 │ missing       99  Zoe          999      100  both
   9 │       2        2  Conor    missing  missing  left_only
  10 │       2       21  Dave     missing  missing  left_only
  11 │       3  missing  missing       31       23  right_only
  12 │       3  missing  missing        3       24  right_only
```

