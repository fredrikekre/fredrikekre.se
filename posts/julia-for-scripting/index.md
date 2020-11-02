+++
date = "2020-07-29"
title = "JuliaCon 2020: Julia for scripting"
var"layout-post" = nothing
tags = ["julia", "juliacon"]
rss = "Abstract, slides and a recording from my JuliaCon 2020 presentation titled: *Julia for scripting*"
+++

+++
# Dependent variables
website_descr = replace(locvar("rss"), "*" => "")
rss_pubdate = Date(locvar("date"))
+++

~~~
<h1><a href="{{ get_url }}">{{ markdown2html title }}</a></h1>
~~~

This is one of my presentations from JuliaCon 2020. The slides are available [here](slides), and a recording of the talk is available [here](https://youtu.be/IuwxE3m0_QQ).

## Abstract


The "scripting workflow", i.e. starting Julia, execute a code snippet, and then exit, is often not the recommended method for Julia code. One reason for this is that Julia is a just-in-time (JIT) compiled language, and the first call to a function is usually a lot slower than subsequent calls due to compilation. In a setting such as scripting there might only be one call to a function before exiting Julia. Spending time compiling the function might not be worth it in such a case, unless the faster runtime makes up for it. A simple example is a script that defines a single function, calls it, and then exits.

The recommended Julia workflow is instead to keep a single Julia session alive for as long as possible, and reuse it for multiple tasks. Even though two tasks A and B are not directly related, they may both use, for example, arrays. Thus, after performing task A we have already compiled some array methods, and task B will benefit from that, with reduced compilation time as the result. This interaction is something that scripting can not take advantage of, since compiled methods are forgotten when exiting Julia.

The problems presented above have two obvious possible solutions: (i) spend less time compiling and (ii) store compiled methods and make them available in future sessions. For the first option we can use Julias interpreter and only compile whats necessary. This is often a great solution for very short-running tasks, and requires nothing extra, just some command line flags to Julia. The second option is a bit more involved (although nowadays pretty easy using the [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl) package), however, it can completely elimitate runtime compilation. The downside is that the compiled and cached methods live in a separate file that needs to be bundled with the script.

This talk will discuss how Julia can be used for scripting, present some tips and tricks on how to make scripting more viable, and show some succesful examples of the two solutions presented above.

