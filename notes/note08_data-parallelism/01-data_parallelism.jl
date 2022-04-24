#' # A quick introduction to data parallelism in Julia
#' 
#' If you have a large collection of data and have to do similar
#' computations on each element,
#' [data parallelism](https://en.wikipedia.org/wiki/Data_parallelism) is
#' an easy way to speedup computation using multiple CPUs and machines as
#' well as GPU(s). 
#' 
#' We focus on thread-based parallelism. 
#' 
#' ## Starting `julia` with multiple threads
#' 
#' To use multi-threading in Julia, you need to start it with multiple
#' execution threads. You can start it with the `-t auto` option:
#' 
#' ```batch
#' $ julia -t auto
#' julia> Threads.nthreads()  # number of core you have
#' ```

Threads.nthreads()  # number of core you have

#' The command line option `-t` also takes the number of threads to be used. 
#' 
#' ```batch
#' $ julia -t 3
#' julia> Threads.nthreads()  # number of core you have
#' ```
#' 
#' ### Starting `julia` with multiple worker processes
#' 
#' To use
#' [Distributed.jl](https://docs.julialang.org/en/v1/stdlib/Distributed/)-based
#' parallelism, you need to setup multiple worker processes. You can start `julia` with `-p auto`. Distributed.jl also
#' lets you add worker processes after starting Julia with
#' `addprocs`:

using Distributed
nprocs()
addprocs(8)
nprocs()

#' ## Mapping
#' 
#' Recall how Julia's sequential `map` works:

map(string, 1:9, 'a':'i')
a1 = map(string, 1:9, 'a':'i')

#' We can simply replace it with
#' [`Folds.map`](https://github.com/JuliaFolds/Folds.jl) for thread-based
#' parallelism (see also
#' [other libraries](../../explanation/libraries/)):

using Folds
a2 = Folds.map(string, 1:9, 'a':'i')

#' Julia's standard library Distributed.jl contains
#' [`pmap`](https://docs.julialang.org/en/v1/stdlib/Distributed/#Distributed.pmap)
#' as a distributed version of `map`:

using Distributed
a3 = pmap(string, 1:9, 'a':'i')

#' In the above example, the inputs (`1:9` and `'a':'i'`) are too small for multi-threading to be useful. 

using BenchmarkTools
@btime map(string, 1:90000, 1:90000);
@btime Folds.map(string, 1:90000, 1:90000);
@btime pmap(string, 1:90000, 1:90000);

#' ### A slightly more practical example

using Random
Random.seed!(2022);
# survival probability of using the better strategy
function open_smart(n) 
    drawers = shuffle(1:n) # mutable array allocation
    opens = fill(n+1, n÷2) # mutable array allocation
    pardon = true
    for i in 1:n
        # opens = fill(n+1, n÷2)
        opens[1] = drawers[i]
        for j in 2:n÷2
            if opens[j-1] == i
                break
            else
               opens[j] = drawers[opens[j-1]]
            end
        end
        if !(i in opens)
            pardon = false
            break
        end
    end
    return pardon
end

n = 100
@time open_smart(n)
sum(open_smart(n) for i in 1:1000) / 1000

surv1(n) = sum(open_smart(n) for i in 1:1000) / 1000
@time s = map(surv1, 10:500); 
@time s = Folds.map(surv1, 10:500);

#' Note that the code for `open_smart` is suboptimal for Threaded parallelism since it allocates temporary mutable arrays allocates an object for each iteration. This is bad in particular in
#' threaded Julia code because it frequently invokes garbage collection. See [here](https://juliafolds.github.io/data-parallelism/tutorials/mutations/) for more explanations and remedies. 
#' 
#' ## Iterator comprehensions
#' 
#' Julia's
#' [iterator comprehension syntax](https://docs.julialang.org/en/v1/manual/arrays/#Generator-Expressions)
#' is a powerful tool for composing mapping, filtering, and flattening.
#' Recall that mapping can be written as an array or iterator
#' comprehension:

b1 = map(x -> x + 1, 1:3)
b2 = [x + 1 for x in 1:3]         # array comprehension
b3 = collect(x + 1 for x in 1:3)  # iterator comprehension

#' The iterator comprehension can be executed with threads by using
#' [`Folds.collect`](https://github.com/JuliaFolds/Folds.jl):

b4 = Folds.collect(x + 1 for x in 1:3)

#' Note that more complex composition of mapping, filtering, and
#' flattening can also be executed in parallel:

c1 = Folds.collect(y for x in 1:5 if isodd(x) for y in 1:x)

#' [`Transducers.dcollect`](https://juliafolds.github.io/Transducers.jl/dev/reference/manual/#Transducers.dcollect)
#' is for using iterator comprehensions with a distributed backend:

using Transducers
c2 = dcollect(y for x in 1:5 if isodd(x) for y in 1:x)

#' ## Pre-defined reductions
#' 
#' Functions such as `sum`, `prod`, `maximum`, and `all` are the examples
#' of *reduction* (aka
#' [*fold*](https://en.wikipedia.org/wiki/Fold_(higher-order_function)))[^1]
#' that can be parallelized.  They are very powerful tools when combined
#' with iterator comprehensions.  Using Folds.jl, a sum of an iterator
#' created by the comprehension syntax

n = 1_000_000
ed1(n) = sum(x + 1 for x in 1:n)
# can easily be parallelized by
ed2(n) = Folds.sum(x + 1 for x in 1:n)

#' For the full list of pre-defined reductions and other parallelized
#' functions, type `Folds.` and press TAB in the REPL.
#' `map` and `collect` are also fold.
#' Let's take another look at the prisoner example.

n = 100

surv1(n) = sum(open_smart(n) for i in 1:1000) / 1000
surv2(n) = Folds.sum(open_smart(n) for i in 1:1000) / 1000
@time surv1(n)
@time surv2(n)

@time s = map(surv1, 10:500); 
@time s = map(surv2, 10:500); 
@time s = Folds.map(surv1, 10:500); 
@time s = Folds.map(surv2, 10:500);

#' ## Manual reductions
#' 
#' For non-trivial parallel computations, you need to write a custom
#' reduction.  [FLoops.jl](https://github.com/JuliaFolds/FLoops.jl)
#' provides a concise set of syntax for writing custom reductions.  For
#' example, this is how to compute sums of two quantities in one sweep:

using FLoops

@floop for (x, y) in zip(1:3, 1:2:6)
    a = x + y
    b = x - y
    @reduce(s += a, t += b)
end
(s, t)

#' In this example, we do not initialize `s` and `t`; but it is not a
#' typo.  In parallel sum, the only reasonable value of the initial state
#' of the accumulators like `s` and `t` is zero.  So, `@reduce(s += a, t
#' += b)` works as if `s` and `t` are initialized to appropriate type of
#' zero.  However, since there are many zeros in Julia (`0::Int`,
#' `0.0::Float64`, `(0x00 + 0x00im)::Complex{UInt8}`, ...), `s` and `t`
#' are undefined if the input collection (i.e., the value of `xs` in `for
#' x in xs`) is empty.
#' 
#' To control the type of the accumulators and also to avoid
#' `UndefVarError` in the empty case, you can set the initial value
#' with `accumulator = initial_value op input` syntax

@floop for (x, y) in zip(1:3, 1:2:6)
    a = x + y
    b = x - y
    @reduce(s2 = 0.0 + a, t2 = 0 + b)
end
(s2, t2)

#' ### Parallel `findmin`/`findmax` with `@reduce() do`
#' 
#' `@reduce() do` syntax is the most flexible way in FLoops.jl for
#' expressing custom reductions.  It is very useful when one variable can
#' influence other variable(s) in reduction (e.g., index and value in the
#' example below).  Note also that `@reduce` can be used multiple times
#' in the loop body.  Here is a way to compute `findmin` and `findmax`
#' in parallel:

@floop for (i, x) in pairs([0, 1, 3, 2])
    @reduce() do (imin = -1; i), (xmin = Inf; x)
        if xmin > x
            xmin = x
            imin = i
        end
    end
    @reduce() do (imax = -1; i), (xmax = -Inf; x)
        if xmax < x
            xmax = x
            imax = i
        end
    end
end

@show imin xmin imax xmax
