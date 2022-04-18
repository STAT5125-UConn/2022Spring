#' ## Unconstrained Optimization

#' First, we load Optim and define the Rosenbrock function:
using Optim
f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2

#' Once we've defined this function, we can find the minimizer (the input that minimizes the objective) and the minimum (the value of the objective at the minimizer) using any of our favorite optimization algorithms. With a function defined,
#' we just specify an initial point `x` and call `optimize` with a starting point `x0`:

x0 = [0.0, 0.0]
res = optimize(f, x0)
Optim.minimizer(res)

#' *Note*: it is important to pass `initial_x` as an array. If your problem is one-dimensional, you have to wrap it in an array. An easy way to do so is to write `optimize(x->f(first(x)), [initial_x])` which make sure the input is an array, but the anonymous function automatically passes the first (and only) element onto your given `f`.

#' Optim will default to using the Nelder-Mead method in the multivariate case, as we did not provide a gradient. This can also
#' be explicitly specified using:

optimize(f, x0, NelderMead())

#' Other solvers are available. Below, we use L-BFGS, a quasi-Newton method that requires a gradient.
#' If we pass `f` alone, Optim will construct an approximate gradient for us using central finite differencing:

res = optimize(f, x0, LBFGS())
Optim.minimizer(res)

#' For better performance and greater precision, you can pass your own gradient function.
#' For the Rosenbrock example, the analytical gradient can be shown to be:
function g!(G, x)
    G[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
    G[2] = 200.0 * (x[2] - x[1]^2)
end

#' You simply pass `g!` together with `f` to use the gradient:
res = optimize(f, g!, x0, LBFGS())
Optim.minimizer(res)

#' If your objective is written in all Julia code with no special calls to external (that is non-Julia) libraries, you can also use automatic differentiation, by using the `autodiff` keyword and setting it to `:forward`:
res = optimize(f, x0, LBFGS(); autodiff = :forward)
Optim.minimizer(res)

#' In addition to providing gradients, you can provide a Hessian function `h!` as well. In our current case this is:
function h!(H, x)
    H[1, 1] = 2.0 - 400.0 * x[2] + 1200.0 * x[1]^2
    H[1, 2] = -400.0 * x[1]
    H[2, 1] = -400.0 * x[1]
    H[2, 2] = 200.0
end

#' Now we can use Newton's method for optimization by running (which defaults to `Newton()`, since a Hessian function was provided.):
res = optimize(f, g!, h!, x0)
Optim.minimizer(res)


#' You can also use automatic differentiation but you need to specific the `Newton()` for Newton's method.

res = optimize(f, x0, Newton(); autodiff = :forward)

#' For methods that do not require gradient, it will be ignored:
res = optimize(f, g!, x0, SimulatedAnnealing())
Optim.minimizer(res)
#' For methods that do not require Hessian, it will be ignored:
optimize(f, g!, h!, x0, LBFGS())

res = optimize(f, g!, h!, x0, GradientDescent())
Optim.minimizer(res)

#' ## Box Constrained Optimization

#' A primal interior-point algorithm for simple "box" constraints (lower and upper bounds) is available. Reusing our Rosenbrock example from above, boxed minimization is performed as follows:

lower = [1.25, -2.1]
upper = [Inf, Inf]
initial_x = [2.0, 2.0]
inner_optimizer = GradientDescent()
results = optimize(f, g!, lower, upper, initial_x, Fminbox(inner_optimizer))
Optim.minimizer(results)

results = optimize(f, g!, lower, upper, initial_x, Fminbox(LBFGS()))
#' ## Minimizing a univariate function on a bounded interval

f_univariate(x) = 2x^2+3x+1
res = optimize(f_univariate, -2.0, 1.0)
Optim.minimizer(res)
res = optimize(f_univariate, 0, 1.0)
Optim.minimizer(res)

#' ## Obtaining results
res = optimize(f, x0, Newton(); autodiff = :forward)

#'  If we can't remember what method we used, we simply use
summary(res)

#' Get the minimizer and minimum of the objective functions
Optim.minimizer(res)
Optim.minimum(res)

#' Go back to the audit income example


#' ### Complete list of functions
#' A complete list of functions can be found below.

#' Defined for all methods:

#' * `summary(res)`
#' * `minimizer(res)`
#' * `minimum(res)`
#' * `iterations(res)`
#' * `iteration_limit_reached(res)`
#' * `trace(res)`
#' * `x_trace(res)`
#' * `f_trace(res)`
#' * `f_calls(res)`
#' * `converged(res)`

#' Defined for univariate optimization:

#' * `lower_bound(res)`
#' * `upper_bound(res)`
#' * `x_lower_trace(res)`
#' * `x_upper_trace(res)`
#' * `rel_tol(res)`
#' * `abs_tol(res)`

#' Defined for multivariate optimization:

#' * `g_norm_trace(res)`
#' * `g_calls(res)`
#' * `x_converged(res)`
#' * `f_converged(res)`
#' * `g_converged(res)`
#' * `initial_state(res)`

#' ## Input types
#' Most users will input `Vector`'s as their `initial_x`'s, and get an `Optim.minimizer(res)` out that is also a vector. For zeroth and first order methods, it is also possible to pass in matrices, or even higher dimensional arrays. The only restriction imposed by leaving the `Vector` case is, that it is no longer possible to use finite difference approximations or automatic differentiation. Second order methods (variants of Newton's method) do not support this more general input type.

#' ## Notes on convergence flags and checks
#' Currently, it is possible to access a minimizer using `Optim.minimizer(result)` even if
#' all convergence flags are `false`. This means that the user has to be a bit careful when using
#' the output from the solvers. It is advised to include checks for convergence if the minimizer
#' or minimum is used to carry out further calculations.

#' A related note is that first and second order methods makes a convergence check
#' on the gradient before entering the optimization loop. This is done to prevent
#' line search errors if `initial_x` is a stationary point. Notice, that this is only
#' a first order check. If `initial_x` is any type of stationary point, `g_converged`
#' will be true. This includes local minima, saddle points, and local maxima. If `iterations` is `0`
#' and `g_converged` is `true`, the user needs to keep this point in mind.
