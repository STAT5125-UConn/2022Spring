using DataFrames
#' ## Joining DataFrames
#' ### Preparing DataFrames for a join
x = DataFrame(ID=[1,2,3,4,missing], name = ["Alice", "Bob", "Conor", "Dave","Zed"])
y = DataFrame(id=[1,2,5,6,missing], age=[21,22,23,24,99])
#' Rules for the `on` keyword argument:
#' * a single `Symbol` or string if joining on one column with the same name, e.g. `on=:id`
#' * a `Pair` of `Symbol`s or string if joining on one column with different names, e.g. `on=:id=>:id2`
#' * a vector of `Symbol`s or strings if joining on multiple columns with the same name, e.g. `on=[:id1, :id2]`
#' * a vector of `Pair`s of `Symbol`s or strings if joining on multiple columns with the same name, e.g. `on=[:a1=>:a2, :b1=>:b2]`
#' * a vector containing a combination of `Symbol`s or strings or `Pair` of `Symbol`s or strings, e.g. `on=[:a1=>:a2, :b1]`
#' ### Standard joins: inner, left, right, outer, semi, anti
innerjoin(x, y, on=:ID=>:id) # missing is not allowed to join-on by default
innerjoin(x, y, on=:ID=>:id, matchmissing=:equal) # in general not recommended
innerjoin(x, y, on=:ID=>:id, matchmissing=:notequal)
leftjoin(x, y, on="ID"=>"id", matchmissing=:notequal)
rightjoin(x, y, on=:ID=>:id, matchmissing=:notequal)
# rightjoin(x, y, on=:ID=>:id, matchmissing=:equal)
outerjoin(x, y, on=:ID=>:id, matchmissing=:equal)

#' ### Cross join
#' (here no `on` argument)
a = DataFrame(x=[1,2])
b = DataFrame(y=["a","b","c"])
crossjoin(a, b)

#' ### Complex cases of joins
x = DataFrame(id1=[1,1,2,2,missing,missing],
              id2=[1,11,2,21,missing,99],
              name = ["Alice", "Bob", "Conor", "Dave","Zed", "Zoe"])
y = DataFrame(id1=[1,1,3,3,missing,missing],
              id2=[11,1,31,3,missing,999],
              age = [21,22,23,24,99, 100])

innerjoin(x, y, on=[:id1, :id2], matchmissing=:notequal) # joining on two columns
outerjoin(x, y, on=:id1, makeunique=true, indicator=:source, matchmissing=:equal)

#+ eval=false; echo = false; results = "hidden"
using Weave
set_chunk_defaults!(:term => true)
ENV["GKSwstype"]="nul"
weave("08_joins.jl", doctype="github")
