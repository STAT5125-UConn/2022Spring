```julia
julia> using DataFrames
```

## Handling missing values

A singelton type `Missing` allows us to deal with missing values.

```julia
julia> missing
missing

julia> typeof(missing)
Missing
```

Arrays automatically create an appropriate union type.

```julia
julia> x = [1, 2, missing, 3]
4-element Vector{Union{Missing, Int64}}:
 1
 2
  missing
 3
```

`ismissing` checks if passed value is missing.

```julia
julia> ismissing(1)
false

julia> ismissing(missing)
true

julia> ismissing.(x)
4-element BitVector:
 0
 0
 1
 0
```

We can extract the type combined with Missing from a `Union` via `nonmissingtype`
(This is useful for arrays!)

```julia
julia> eltype(x)
Union{Missing, Int64}

julia> nonmissingtype(eltype(x))
Int64
```

`missing` comparisons produce `missing`.

```julia
julia> missing == missing
missing

julia> missing != missing
missing

julia> missing < missing
missing
```

This is also true when `missing`s are compared with values of other types.

```julia
julia> 1 == missing
missing

julia> 1 != missing
missing

julia> 1 < missing
missing
```

`isequal`, `isless`, and `===` produce results of type `Bool`. Notice that `missing` is considered greater than any numeric value.

```julia
julia> isequal(missing, missing)
true

julia> missing === missing
true

julia> isequal(1, missing)
false

julia> isless(10000, missing)
true

julia> isless(NaN, missing)
true
```

Many (not all) functions handle `missing`.

```julia
julia> map(x -> x(missing), [sin, cos, zero, sqrt]) # part 1
4-element Vector{Missing}:
 missing
 missing
 missing
 missing

julia> map(x -> x(missing, 1), [+, - , *, /, div]) # part 2
5-element Vector{Missing}:
 missing
 missing
 missing
 missing
 missing

julia> using Statistics # needed for mean

julia> map(x -> x([1,2,missing]), [minimum, maximum, extrema, mean, float]) # part 3
5-element Vector{Any}:
 missing
 missing
 (missing, missing)
 missing
 Union{Missing, Float64}[1.0, 2.0, missing]
```

`skipmissing` returns iterator skipping missing values. We can use `collect` and `skipmissing` to create an array that excludes these missing values.

```julia
julia> collect(skipmissing([1, missing, 2, missing]))
2-element Vector{Int64}:
 1
 2
```

Here we use `replace` to create a new array that replaces all missing values with some value (`NaN` in this case).

```julia
julia> x = [1.0, missing, 2.0, missing]
4-element Vector{Union{Missing, Float64}}:
 1.0
  missing
 2.0
  missing

julia> replace(x, missing=>NaN)
4-element Vector{Float64}:
   1.0
 NaN
   2.0
 NaN
```

Another way to do this:

```julia
julia> coalesce.([1.0, missing, 2.0, missing], NaN)
4-element Vector{Float64}:
   1.0
 NaN
   2.0
 NaN
```

There are also `replace!` and `recode!` functions that work in place.
Here is an example how you can to missing inputation in a data frame.

```julia
julia> df = DataFrame(a=[1,2,missing], b=["a", "b", missing])
3×2 DataFrame
 Row │ a        b
     │ Int64?   String?
─────┼──────────────────
   1 │       1  a
   2 │       2  b
   3 │ missing  missing
```

we change `df.a` vector in place.

```julia
julia> replace!(df.a, missing=>100)
3-element Vector{Union{Missing, Int64}}:
   1
   2
 100
```

Now we overwrite `df.b` with a new vector, because the replacement type is different than what `eltype(df.b)` accepts.

```julia
julia> df.b = coalesce.(df.b, 100)
3-element Vector{Any}:
    "a"
    "b"
 100

julia> df
3×2 DataFrame
 Row │ a       b
     │ Int64?  Any
─────┼─────────────
   1 │      1  a
   2 │      2  b
   3 │    100  100
```

You can use `unique` or `levels` to get unique values with or without missings, respectively.

```julia
julia> unique([1, missing, 2, missing])
3-element Vector{Union{Missing, Int64}}:
 1
  missing
 2

julia> levels([1, missing, 2, missing])
2-element Vector{Int64}:
 1
 2
```

In this next example, we convert `x` to `y` with `allowmissing`, where `y` has a type that accepts missings.

```julia
julia> x = [1,2,3]
3-element Vector{Int64}:
 1
 2
 3

julia> y = allowmissing(x)
3-element Vector{Union{Missing, Int64}}:
 1
 2
 3
```

Then, we convert back with `disallowmissing`. This would fail if `y` contained missing values!

```julia
julia> z = disallowmissing(y)
3-element Vector{Int64}:
 1
 2
 3

julia> x
3-element Vector{Int64}:
 1
 2
 3

julia> y
3-element Vector{Union{Missing, Int64}}:
 1
 2
 3

julia> z
3-element Vector{Int64}:
 1
 2
 3
```

`disallowmissing` has `error` keyword argument that can be used to decide how it should behave when it encounters a column that actually contains a `missing` value

```julia
julia> df = allowmissing(DataFrame(ones(2,3), :auto))
2×3 DataFrame
 Row │ x1        x2        x3
     │ Float64?  Float64?  Float64?
─────┼──────────────────────────────
   1 │      1.0       1.0       1.0
   2 │      1.0       1.0       1.0

julia> df[1,1] = missing
missing

julia> df
2×3 DataFrame
 Row │ x1         x2        x3
     │ Float64?   Float64?  Float64?
─────┼───────────────────────────────
   1 │ missing         1.0       1.0
   2 │       1.0       1.0       1.0

julia> eltype.(eachcol(df))
3-element Vector{Union}:
 Union{Missing, Float64}
 Union{Missing, Float64}
 Union{Missing, Float64}

julia> disallowmissing(df) # an error is thrown
Error: ArgumentError: Missing value found in column :x1 in row 1

julia> df = disallowmissing(df, error=false) # column :x1 is left untouched as it contains missing
2×3 DataFrame
 Row │ x1         x2       x3
     │ Float64?   Float64  Float64
─────┼─────────────────────────────
   1 │ missing        1.0      1.0
   2 │       1.0      1.0      1.0

julia> eltype.(eachcol(df))
3-element Vector{Type}:
 Union{Missing, Float64}
 Float64
 Float64
```

In this next example, we show that the type of each column in `x` is initially `Int64`. After using `allowmissing!` to accept missing values in columns 1 and 3, the types of those columns become `Union{Int64,Missing}`.

```julia
julia> x = DataFrame(rand(Int, 2,3), :auto)
2×3 DataFrame
 Row │ x1                    x2                    x3
     │ Int64                 Int64                 Int64
─────┼──────────────────────────────────────────────────────────────────
   1 │  7969605439420759373  -8732967858023966886  -6718652640797218395
   2 │ -6867439846840780762   5492839018338682965   -372689442312839483

julia> println("Before: ", eltype.(eachcol(x)))
Before: DataType[Int64, Int64, Int64]

julia> allowmissing!(x, 1) # make first column accept missings
2×3 DataFrame
 Row │ x1                    x2                    x3
     │ Int64?                Int64                 Int64
─────┼──────────────────────────────────────────────────────────────────
   1 │  7969605439420759373  -8732967858023966886  -6718652640797218395
   2 │ -6867439846840780762   5492839018338682965   -372689442312839483

julia> allowmissing!(x, :x3) # make :x3 column accept missings
2×3 DataFrame
 Row │ x1                    x2                    x3
     │ Int64?                Int64                 Int64?
─────┼──────────────────────────────────────────────────────────────────
   1 │  7969605439420759373  -8732967858023966886  -6718652640797218395
   2 │ -6867439846840780762   5492839018338682965   -372689442312839483

julia> println("After: ", eltype.(eachcol(x)))
After: Type[Union{Missing, Int64}, Int64, Union{Missing, Int64}]
```

In this next example, we'll use `completecases` to find all the rows of a `DataFrame` that have complete data.

```julia
julia> x = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])
4×2 DataFrame
 Row │ A        B
     │ Int64?   String?
─────┼──────────────────
   1 │       1  A
   2 │ missing  B
   3 │       3  missing
   4 │       4  C

julia> println("Complete cases:\n", completecases(x))
Complete cases:
Bool[1, 0, 0, 1]

julia> x[completecases(x),:]
2×2 DataFrame
 Row │ A       B
     │ Int64?  String?
─────┼─────────────────
   1 │      1  A
   2 │      4  C
```

We can use `dropmissing` or `dropmissing!` to remove the rows with incomplete data from a `DataFrame` and either create a new `DataFrame` or mutate the original in-place.

```julia
julia> y = dropmissing(x)
2×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  A
   2 │     4  C

julia> dropmissing!(x)
2×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  A
   2 │     4  C

julia> x
2×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  A
   2 │     4  C

julia> y
2×2 DataFrame
 Row │ A      B
     │ Int64  String
─────┼───────────────
   1 │     1  A
   2 │     4  C
```

When we call `describe` on a `DataFrame` with dropped missing values, the columns do not allow missing values any more by default.

```julia
julia> describe(x)
2×7 DataFrame
 Row │ variable  mean    min  median  max  nmissing  eltype
     │ Symbol    Union…  Any  Union…  Any  Int64     DataType
─────┼────────────────────────────────────────────────────────
   1 │ A         2.5     1    2.5     4           0  Int64
   2 │ B                 A            C           0  String
```

Alternatively you can pass `disallowmissing` keyword argument to `dropmissing` and `dropmissing!`

```julia
julia> x = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])
4×2 DataFrame
 Row │ A        B
     │ Int64?   String?
─────┼──────────────────
   1 │       1  A
   2 │ missing  B
   3 │       3  missing
   4 │       4  C

julia> dropmissing!(x, disallowmissing=false)
2×2 DataFrame
 Row │ A       B
     │ Int64?  String?
─────┼─────────────────
   1 │      1  A
   2 │      4  C
```

### Making functions `missing`-aware

If we have a function that does not handle `missing` values we can wrap it using `passmissing` function so that if any of its positional arguments is missing we will get a `missing` value in return. In the example below we change how `string` function behaves:

```julia
julia> string(missing)
"missing"

julia> string(missing, " ", missing)
"missing missing"

julia> string(1,2,3)
"123"

julia> lift_string = passmissing(string)
(::Missings.PassMissing{typeof(string)}) (generic function with 2 methods)

julia> lift_string(missing)
missing

julia> lift_string(missing, " ", missing)
missing

julia> lift_string(1,2,3)
"123"
```

### Aggregating rows containing missing values

Create an example data frame containing missing values:

```julia
julia> df = DataFrame(a = [1,missing,missing], b=[1,2,3])
3×2 DataFrame
 Row │ a        b
     │ Int64?   Int64
─────┼────────────────
   1 │       1      1
   2 │ missing      2
   3 │ missing      3
```

If we just run `sum` on the rows we get two missing entries:

```julia
julia> sum.(eachrow(df))
3-element Vector{Union{Missing, Int64}}:
 2
  missing
  missing
```

One can apply `skipmissing` on the rows to avoid this problem:

```julia
julia> sum.(skipmissing.(eachrow(df)))
3-element Vector{Int64}:
 2
 2
 3
```

The last row contains only missing values

```julia
julia> df = DataFrame(a = [1,missing,missing], b=[1,2,missing])
3×2 DataFrame
 Row │ a        b
     │ Int64?   Int64?
─────┼──────────────────
   1 │       1        1
   2 │ missing        2
   3 │ missing  missing

julia> sum.(skipmissing.(eachrow(df)))
Error: ArgumentError: reducing over an empty collection is not allowed

julia> sum.(eachrow(ismissing.(df)))
3-element Vector{Int64}:
 0
 1
 2

julia> df[sum.(eachrow(ismissing.(df))) .< ncol(df),:]
2×2 DataFrame
 Row │ a        b
     │ Int64?   Int64?
─────┼─────────────────
   1 │       1       1
   2 │ missing       2
```
