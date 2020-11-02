+++
date = "2019-07-23"
title = "JuliaCon 2019: Pkg, Project.toml, Manifest.toml and Environments"
var"layout-post" = nothing
tags = ["julia", "juliacon"]
rss = "Abstract, slides and a recording from my JuliaCon 2019 presentation titled: *Pkg, Project.toml, Manifest.toml and Environments*"
+++

+++
# Dependent variables
website_descr = replace(locvar("rss"), "*" => "")
rss_pubdate = Date(locvar("date"))
+++

~~~
<h1><a href="{{ get_url }}">{{ markdown2html title }}</a></h1>
~~~

This is one of my presentations from JuliaCon 2019. The slides are available [here](https://docs.google.com/presentation/d/e/2PACX-1vT6XYlWB0bxAoRIz4wRG9nRGktugbTBAglNXHvOIUPfZhSSYaT5iXqfIn0ISaUjtyrXDw3Jk03PxVK8/pub?start=false&loop=false&delayms=3000), and a recording of the talk is available [here](https://youtu.be/q-LV4zoxc-E).

## Abstract

Julia's new package manager, [`Pkg`](https://github.com/JuliaLang/Pkg.jl) (codename `Pkg3`), was released together with version 1.0 of the Julia language. The new package manager is a complete rewrite of the old one, and solves many of the problems observed in the old version. One major feature of the new package manager is the concept of _package environments_, which can be described as independent, sandboxed, sets of packages.

A package environment is represented by a `Project.toml` and `Manifest.toml` file pair. These files keep track of what packages, and what versions, are available in a given environment. Since environments are "cheap", just two files, they can be used liberally. It is often useful to create new environments for every new coding project, instead of installing packages on the global level. Since the package manager modifies the current project, e.g. when adding, removing or updating packages, there is no risk for these operations to mess up other environments.

The fact that exact versions of packages in the environment is being recorded means that Julia has reproducibility built-in. As long as the `Project.toml` and `Manifest.toml` file pair is available it is possible to replicate exactly the same package environment. Some typical use cases include being able to replicate the same package environment on a different machine, and being able to go back in time and run some old code which might require some old versions of packages.

In this presentation we will discuss how environments work, how they interact with the package manager and Julia's code loading, and how to effectively use them. Hopefully you will be more comfortable working with, and seeing the usefulness of, environments after this presentation.
