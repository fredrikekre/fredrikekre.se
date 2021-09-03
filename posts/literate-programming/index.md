+++
date = "2019-07-23"
title = "JuliaCon 2019: Literate programming with Literate.jl"
var"layout-post" = nothing
tags = ["julia", "juliacon"]
rss = "Abstract, slides and a recording from my JuliaCon 2019 presentation titled: *Literate programming with Literate.jl*"

# Dependent variables
website_description = replace(rss, "*" => "")
rss_pubdate = Date(date)
+++

~~~
<h1><a href="{{ get_url }}">{{ markdown2html title }}</a></h1>
~~~

This is one of my presentations from JuliaCon 2019. The slides are available [here](slides), and a recording of the talk is available [here](https://youtu.be/Tfp1WEdYfqk).

## Abstract


Literate programming was introduced by Donald Knuth in 1984 and is described as an _explanation of the program logic in a natural language, interspersed with traditional source code_. [`Literate.jl`](https://github.com/fredrikekre/Literate.jl) is a simple Julia package that can be used for literate programming. The original purpose was to facilitate writing example programs for documenting Julia packages.

Julia packages are often showcased and documented using "example notebooks". Notebooks are great for this purpose since they contain both input source code, descriptive markdown and rich output like plots and figures, and, from the description above, notebooks can be considered a form of literate programming. One downside with notebooks is that they are a pain to deal with in version control systems like git, since they contain lots of extra data. A small change to the notebook thus often results in a large and complicated diff, which makes it harder to review the actual changes. Another downside is that notebooks require external tools, like [Jupyter](https://jupyter.org/) and [`IJulia.jl`](https://github.com/JuliaLang/IJulia.jl) to be used effectively.

With `Literate.jl` is is possible to dynamically generate notebooks from a simple source file. The source file is a regular `.jl` file, where comments are used for describing the interspersed code snippets. This means that, for basic usage, there are no new syntax to learn in order to use `Literate.jl`, basically any valid Julia source file can be used as a source file. This solves the problem with notebooks described in the previous section, since the notebook itself does not need to be checked into version control -- it is just the source text file that is needed. `Literate.jl` can also, from the _same_ input source file, generate markdown files to be used with e.g. [`Documenter.jl`](https://github.com/JuliaDocs/Documenter.jl) to produce HTML pages in the package documentation. This makes it easy to maintain both a notebook and HTML version of examples, since they are based on the same source file.

This presentation will briefly cover the `Literate.jl` syntax, and show examples of how `Literate.jl` can be used.
