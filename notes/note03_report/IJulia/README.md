# Quick start of [IJulia](https://github.com/JuliaLang/IJulia.jl)

Install IJulia from the Julia REPL by pressing `]` to enter pkg mode and entering:

```
add IJulia
```

If you already have Python/Jupyter installed on your machine, this process will
also install a [kernel
specification](https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernelspecs)
that tells Jupyter how to launch Julia. You can then launch the notebook server
the usual way by running `jupyter notebook` in the terminal.

Alternatively, you can have IJulia create and manage its own Python/Jupyter installation.
To do this, type the following in Julia at the `julia>` prompt to launch the IJulia notebook in your browser:

```julia
using IJulia
notebook()
```

The first time you run `notebook()`, it will prompt you
for whether it should install Jupyter.  Hit enter to
have it use the [Conda.jl](https://github.com/Luthaf/Conda.jl)
package to install a minimal Python+Jupyter distribution (via
[Miniconda](http://conda.pydata.org/docs/install/quick.html)) that is
private to Julia (not in your `PATH`).
