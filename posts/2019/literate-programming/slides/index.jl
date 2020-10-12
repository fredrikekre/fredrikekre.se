# name: titlepage

# class: middle, centre

# # Literate.jl
# ## Simple package for literate programming in Julia
# Fredrik Ekre, JuliaCon 2019
# .right[![](logo.png)]

# ---

# # What is literate programming?

# Definition from Wikipedia:

# > Literate programming is a programming paradigm [...] in which a program is given as an
# > explanation of the program logic in a natural language, interspersed
# > with snippets of macros and traditional source code, from which a compilable source
# > code can be generated.

# --

# Loosely translated by me:

# > A program with readable comments that explain the code.

# ---

# name: motivation-want

# # Motivation -- What do I want?
#
# - Documenting packages by examples, cf. "example notebooks"
#
#
# - Examples should be easily testable on CI (no outdated examples)
#
#
# - Multiple output formats:
#   - Markdown/HTML pages
#   - Jupyter notebooks
#   - Julia script files
#
#
# - Minimal maintenance -- one source, one place to make changes
#

# ---

# name: motivation-problem

# # Motivation -- What's the problem?

# - Maintaining multiple outputs is difficult and they will diverge
# - Notebooks are *really* bad in version control like `git`
#   - small changes result in unreadable and unreviewable diffs
#     ![](nb-diff.png)
#   - too "rich" format, includes large objects like images
#     (often in multiple formats)

# ---

# name: goals

# # Design goals

# A `Literate.jl` source file should
#
# - have simple syntax that Julia users are familiar with
#
#
# - be valid Julia syntax, e.g. a `.jl` file that can be `include`d
#
#
# - be able to produce multiple outputs -- markdown files, notebooks and regular scripts

# ---

# name: goals

# # Design goals

# A `Literate.jl` source file should
#
# - have simple syntax that Julia users are familiar with: Julia syntax!
#
#
# - be valid Julia syntax, e.g. a `.jl` file that can be `include`d: Everything that is not code behind Julia comments (`# `)
#
#
# - be able to produce multiple outputs -- markdown files, notebooks and regular scripts: Multiple source transformations


# ---

# name: offer

# # What does `Literate.jl` offer?
#
# `Literate.jl` provides three functions:
#
# - `Literate.markdown`:
#   Transforms the source file to a markdown file, to be used with e.g. Documenter
#
#
# - `Literate.notebook`:
#   Transforms the source file to a Jupyter notebook
#
#
# - `Literate.script`:
#   Transforms the source file to a "pure" Julia script file
#

# ---

# # Example of a source file
# The following code block is an example source file, and also the source block for the upcoming slide
# ```julia
# # # Example of a `Literate.jl` source file
# #
# # This is a Julia comment, so this is treated as markdown input.
# # Here is some **bold text**, and some *text in italic*.
# # Let's create a function in a Julia code block
#
# f(x) = 2 * exp(x)
# g(x) = 2 * log(x)
#
# # If we plot `f` and `g` with e.g. Plots.jl, the output will be captured
#
# using Plots
# x = range(0.0, stop = 2.0, length = 100)
# plot(x, [f.(x) g.(x)]; labels = ["f(x) = 2exp(x)" "g(x) = 2log(x)"], legend = :topleft)
# ```
#
# The upcoming two slides are the output of the the above example.

# ---

# # Example of a `Literate.jl` source file
#
# This is a Julia comment, so this is treated as markdown input.
# Here is some **bold text**, and some *text in italic*.
# Let's create a function in a Julia code block

f(x) = 2 * exp(x)
g(x) = 2 * log(x)

# ---

# If we plot `f` and `g` with e.g. Plots.jl, the output will be captured

using Plots
x = range(0.0, stop = 2.0, length = 100)
plot(x, [f.(x) g.(x)]; labels = ["f(x) = 2exp(x)" "g(x) = 2log(x)"], legend = :topleft)

# ---

# # Usage in the wild -- `Optim.jl`
#
# `Optim.jl` (package for minimization) uses Literate for some examples in the documentation.
#
# - [Source file](https://github.com/JuliaNLSolvers/Optim.jl/blob/master/docs/src/examples/ipnewton_basics.jl)
#
#
# - [HTML output](https://julianlsolvers.github.io/Optim.jl/stable/#examples/generated/ipnewton_basics/)
#


# ---

# # Usage in the wild -- `@cormullion`'s blog
#
# Generated with Literate.jl + Thibaut Lienart's (`@tlienart`) [JuDoc.jl](https://github.com/tlienart/JuDoc.jl) package
#
# - [Source file](https://github.com/cormullion/cormullion.github.io/blob/master/src/source/pentachoron.jl)
#
#
# - [HTML output](https://cormullion.github.io/pub/2019-04-03-pentachoron.html)
#

# ---

# # Usage in the wild -- This presentation
#
# This presentation is generated with `Literate.jl`, and turned into slides
# using Pietro Vertechi's (`@piever`) [Remark.jl](https://github.com/piever/Remark.jl) package.

# ---

# # Thanks for listening!

# ---


