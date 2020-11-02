+++
date = "2020-07-31"
title = "JuliaCon 2020: display, show and print – how Julia's display system works"
markdown_title = "JuliaCon 2020: `display`, `show` and `print` – how Julia's display system works"
var"layout-post" = nothing
tags = ["julia", "juliacon"]
rss = "Abstract, slides and a recording from my JuliaCon 2020 presentation titled *display, show and print – how Julia's display system works*"
+++

+++
# Dependent variables
website_descr = locvar("rss")
rss_pubdate = Date(locvar("date"))
+++

~~~
<h1><a href="{{ get_url }}">{{ markdown2html markdown_title }}</a></h1>
~~~

This is one of my presentations from JuliaCon 2020. The slides are available [here](slides), and a recording of the talk is available [here](https://youtu.be/S1Fb5oNhhbc).

## Abstract


When Julia finishes a computation and obtains a value the user is presented with the result. In the Julia REPL the result is usually represented as plain text. In other environments, such as in a Jupyter notebook, you sometimes see more rich representations, for example some values display as HTML, and others as images.

The main functions responsible for output in Julia are `display` and `show`. Usually `display` is the first method to be called when an object is presented to the user. The `display` function is implemented by displays such as the Julia REPL, the IDE or the notebook interface. Next, `display` requests output from `show` with a specific so-called MIME-type. Which MIME-types that are requested depends on what output the display is able to present back to the user. For example, the REPL mostly works with the `text/plain` MIME-type, and the notebook display supports multiple additional MIME-types, for example `image/png` for image output, `text/html` for HTML output, and so on. Given this rough overview the display system might seem rather simple, but there are many hidden complexities.

In order to take advantage of the rich display system and implement "pretty printing" for a custom type it is generally enough to implement methods of `show` with specific MIME-types. All types get a default text representation, but this can easily be overridden by implementing `show` with the `text/plain` MIME type. If the type can be represented in richer formats it is simple to add additional methods. For example, in order to support image output in a notebook it is enough to implement `show` with the `image/png` MIME type.

This talk will present how Julia's display system works and go through the process of taking an output object and generating output to present the user with. The talk will also examplify this process by discussing how to customize the output for your own types.

