# Weave

Weave is a scientific report generator/literate programming tool for the [Julia programming language](https://julialang.org/).
It resembles
[Pweave](http://mpastell.com/pweave),
[knitr](https://yihui.org/knitr/),
[R Markdown](https://rmarkdown.rstudio.com/),
and [Sweave](https://stat.ethz.ch/R-manual/R-patched/library/utils/doc/Sweave.pdf).

You can write your documentation and code in input document using Markdown, Noweb or ordinal Julia script syntax,
and then use `weave` function to execute code and generate an output document while capturing results and figures.

**Current features**

- Publish markdown directly to HTML and PDF using Julia or [Pandoc](https://pandoc.org/MANUAL.html)
- Execute code as in terminal or in a unit of code chunk
- Capture [Plots.jl](https://github.com/JuliaPlots/Plots.jl) or [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl) figures
- Supports various input format: Markdown, [Noweb](https://www.cs.tufts.edu/~nr/noweb/), [Jupyter Notebook](https://jupyter.org/), and ordinal Julia script
- Conversions between those input formats
- Supports various output document formats: HTML, PDF, GitHub markdown, Jupyter Notebook, MultiMarkdown, Asciidoc and reStructuredText
- Simple caching of results

**Citing Weave:** *Pastell, Matti. 2017. Weave.jl: Scientific Reports Using Julia. The Journal of Open Source Software. http://dx.doi.org/10.21105/joss.00204*


## Installation

You can install the latest release using Julia package manager:

```julia
using Pkg
Pkg.add("Weave")
```


## Usage

```julia
using Weave
weave("example_note01.jmd", doctype="github")

```
