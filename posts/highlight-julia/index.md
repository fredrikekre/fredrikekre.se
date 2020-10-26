+++
date = "2020-10-27"
title = "Improved syntax highlighting for Julia on the web"
html_title = "Improved syntax highlighting for Julia on the web"
var"layout-post" = nothing
tags = ["highlight.js", "javascript", "julia", "open source"]
hascode = true
+++

~~~
<h1><a href="{{ get_url }}">{{ fill html_title }}</a></h1>
~~~


In the process of writing another post I looked into how to properly syntax highlight Julia code on a website like this. The static site generator [Franklin.jl](https://franklinjl.org/), used for this website, enables syntax highlighting using the JavaScript library [highlight.js](https://highlightjs.org/). However, I wasn't quite happy with the result so I decided to spend the weekend trying to improve it~~~<sup>not a conscious decision, I spent way too much time on this...</sup>~~~. Highlight.js is also used by many other tools, for example: [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl), the documentation generator used by Julia and a majority of the package ecosystem; [Discourse](https://www.discourse.org/), the platform hosting Julia's [discussion forum](https://discourse.julialang.org/); and [StackOverflow](https://stackoverflow.com/questions/tagged/julia). My hope is that the improvements presented in this post will eventually reach those platforms, among others, and benefit readers of Julia code everywhere.

I am not sure this post is of general interest -- it merely presents the changes that I made -- but, since I had almost all content written already for debugging my poor JavaScript coding, I decided to do some finishing touches and publish it. In hindsight it was probably a good idea since I found numerous corner cases that wasn't handled correctly.

## TL;DR: highlight.js

Before continuing I think it is good to have a basic overview of what highlight.js does. At the core highlight.js is a "labeler" which, given a snippet of code, tries to label all the words/operators/symbols/etc with an appropriate tag. The tags are language agnostic categories such as `keyword`, `number`, `string`, `literal`, etc. The full list, and their intended usage can be seen [here](https://highlightjs.readthedocs.io/en/latest/css-classes-reference.html). The labeling is done using regular expressions, with the help of some language specific rules and lists of keywords. Given that it is not a full fledged parser it can be tricky to correctly label everything.

When everything has been labeled it is just a matter of selecting a color scheme that assigns color and/or text style to each tag. There are a bunch of styles available on the [demo page](https://highlightjs.org/static/demo/). For this post I use a modified version of the `Gruvbox Dark` theme. Since the number of tags is limited it is also very easy to create your own theme, or, as I did for this post, modify an existing one.

*The focus for the rest of the post is on the tagging itself and not the specific styling.* Consider using your browsers developer tools to inspect the code snippets to better understand which patterns in the code are being tagged, and with which tag the are labeled with.

## Status Quo

Lets look at an example comparing Julia with C using the current release of highlight.js (version 10.3.1):

```julia-old
function main(who::Union{String,Nothing} = nothing)
    if who === nothing
        who = "world"
    end
    print(stdout, "hello, $(who)!\n")
    return nothing
end
```
```c
#include <stdio.h>
int main(int argc, char *argv[]) {
    char *who = "world";
    if (argc > 1) {
        who = argv[1];
    }
    fprintf(stdout, "hello, %s!\n", who);
    return 0;
}
```

Overall the Julia output is quite good for this example: keywords such as `function`, `if`, `return` and `end` are tagged as keywords; strings are recognized as `string`s; `nothing` is tagged as `literal`; and string interpolation is tagged as `subst`. However, when looking into the details, and in particular when comparing to the C example, it is evident that the syntax highlighter for Julia is not as sophisticated as the one for C. In particular, the C highlighter recognized `int main(int argc, char *argv[])` as a function definition (tagged as `function`) with `main` tagged as `title` and `argc`, `*argv[]` tagged as `params` -- surely the same can be achieved for Julia too!

You might also note that `Nothing` was not recognized in the Julia example. This turned out to be because the internal lists of keyword and constants had not been updated in some time. Updating these was purely a mechanical task and the patch is in fact already [merged upstream](https://github.com/highlightjs/highlight.js/pull/2781).

## Improvements to the Julia syntax highlighter

Enough talking -- on to the fun stuff! The sections below simply demonstrates all the changes that I made, with some comments. Every code snippet can be toggled in their upper right corner to compare with the "old" highlighting. Once again I encourage you to inspect the snippets using the browser developer tools, it can be quite informative!

### Infix operators and assignment

Infix operators and assignment are now tagged. Assignment and the short-circuiting control-flow operators `&&` and `||` are tagged as `keyword`:

\codetoggle{
x = y && (z || q)
}

Initially I had all operators tagged as `keyword`, since this is what many other highlighters do, but I settled on tagging them as `built_in`:

\codetoggle{
x + y    x - y    x * y    x ≤ y    x ∈ y    x ⊗ y
x == y   x <= y   x >= y   x != y   x === y  x !== y
}

Tagging assignment and operators differently has the extra benefit of making it clear that *update-and-assign* operators really are two things:

\codetoggle{
x += y    x -= y    x *= y    x //= y    x /= y
x \= y    x ^= y    x ÷= y    x %= y     x <<= y
x >>>= y  x >>= y   x &= y    x ⊻= y
}

### Contextual highlighting of types

Highlight.js has a predefined list of types associated with the `julia` language. This include, for example, `String`, `Int`, `Vector` and `Union`. When these words are encountered they are tagged with the `type` tag (previously mislabeled with the `built_in` tag). In Julia, however, user-defined types are first class citizens, and usually there is no point in distinguishing them from the built-in types. Obviously the highlighter can not be taught to recognize all types out there, but in Julia there are certain context in which the content must be types. By teaching the highlighter about these contexts it is possible to unconditionally tag it with the `type` tag.

Here are some examples of such contexts. Note, in particular, that the user-defined type `UserType` is correctly tagged.

Any word directly attached to `{...}`:
\codetoggle{
x = Vector{Int}
x = UserType{Int}
}

Right hand side of `::`
\codetoggle{
x::Int
x::UserType
x::Union{String, Nothing}
x::AbstractArray{UserType, 3}
x::AbstractArray{UserType{T}, 3}
}

Right and left hand side of `<:` and `>:`
\codetoggle{
Int <: String
Int <: UserType
UserType <: String

Int >: String
Int >: UserType
UserType >: String
}

After `where`:
\codetoggle{
Vector{Int} where Int
Vector{UserType} where UserType
}

Fortunately the contexts above should cover the vast majority of cases -- while types sometimes show up in other contexts it is not very common. The list of built-ins keyword is still useful in other contexts, for example in
\codetoggle{
x = UserType
x = UserType{T}
x = Vector
x = Vector{T}
}
it is difficult to tell if the lonely `UserType` is a type or a regular variable, but `Vector` is still tagged. However, using a pre-defined list is not always correct either, since Julia allows for things like this:
\codetoggle{
Vector = 123
}

where `Vector` is wrongly tagged. Perhaps contextual highlighting has sufficiently good coverage that the pre-defined list should be ignored completely?

### Type definitions

Type names are tagged as `class`, here are some examples:
\codetoggle{
struct Struct
    x::Int
    y::Union{String,UserType}
end

struct Struct <: AbstractStruct
    x::Int
    y::UserType
end

struct Struct{T} <: AbstractStruct{T}
    x::Int
    y::Union{String,UserType}
end

mutable struct MutableStruct
    x::UserType
end

mutable struct MutableStruct{T} <: AbstractVector{T}
    x::String
end

abstract type AbstractType end
abstract type A{T} <: AbstractVector{T} end
abstract type AbstractType <: Integer end

primitive type PrimitiveType 32 end
primitive type PrimitiveType <: Integer 8 end
}

Note that the contextual highlighting of types does a great job here -- it correctly found all the types!

### Function definitions

Function names in function definitions are tagged as `title`, and the function parameters are tagged as `params`:

\codetoggle{
function sayhi(who::String = "world")
    println("hello, " who)
end

function sayhi(who::T) where T <: AbstractString
    println("hello, " who)
end

function Base.print(who::T) where T
    println("hello, " who)
end

saybye(who::String = "world") = println("goodbye, ", who)
saybye(who::T) where T <: AbstractString = println("goodbye, ", who)
Base.print(who::T) where T = println("goodbye, ", who)
}

Typed constructors are also tagged as function definitions

\codetoggle{
struct MyStruct{T}
    x::T
    function MyStruct(x::T) where T
        return new{T}(x)
    end
    function MyStruct{T}(x) where T
        return new(x)
    end
end
}

### Function calls

The name of functions that are called is tagged with `built_in`. Technically not all functions are "built-in"s, of course, but I like that they are tagged regardless of who happened to define them; the core language, a package or me. It also finds function calls when broadcasting. Example:

\codetoggle{
sayhi("world")
sayhi.(["world", "mom"])
}


### Miscellaneous

Here is a list of miscellaneous minor changes and bugfixes that I found while working on the rest.

Literal regular expressions, `r"..."` and `r"""..."""` are now tagged as `regexp` instead of `string`:
\codetoggle{
r = r"single line regex"
r = r"""
multiline
regex
"""
}

Multiline `Cmd` literals `` ``` ... ``` `` are detected as a single block instead of three separate literals (no visual effect, but appreciate the fix!):
\codetoggle{
cmd = ```
julia --startup-file=no
      -e 'println("hello, world")'
```
}

Symbols are tagged as `symbol` (this one was tricky since the same pattern is also used for literal ranges):
\codetoggle{
x = :symbol
x = f(:symbol)
x = 1:notsymbol
x = x:notsymbol
x = x:notsymbol(y)

# :( technically valid Julia, but never seen such strange things
x = "hello" :symbol
x = Z{T} :symbol
}

Some literal characters that were not recognized as such are now tagged as `string`:
\codetoggle{
x = '\r'
x = '\n'
x = '\$'
x = '\\'
x = 'a' # reference
}

`!` is now allowed in variable names, and thus also recognized in the context of finding function definitions and function calls. In other contexts it is tagged as an operator:
\codetoggle{
f!(x) = x
f!(x)
}

When `!` is used in other contexts, it is tagged as an operator (`built_in`):
\codetoggle{
if !x
    # ...
end
}

`?` and `:` are also tagged as operators (`built_in`):
\codetoggle{
x ? "hello" : "world"
}

### REPL highlighting

Highlight.js also support highlighting of Julia REPL code using `julia-repl` as the language tag. This language definition is very simple -- it [literally](https://github.com/highlightjs/highlight.js/blob/21b146644e15ba2b101341da0d3e4dc61db53056/src/languages/julia-repl.js#L29-L38) just detects the `julia>` prompt, strips the proper amount of leading whitespace, and processes the result using the regular `julia` language implementation. This means that improved REPL highlighting is obtained "for free":

```julia-repl
julia> function sayhello(who::S) where S <: AbstractString
           println("hello, ", who)
       end
sayhello (generic function with 1 method)

julia> sayhello("world")
hello, world
```

## Concluding remarks

In this post I have presented some changes to the julia language syntax highlighter in the highlight.js library. In my opinion they are all strict improvements, and my plan is to submit as much as possible to the upstream project. In the meantime you can either use this file: [`julia.highlight.js`](/assets/julia.highlight.js), which contain the `julia` and `julia-repl` languages, or build from source using [this branch](https://github.com/fredrikekre/highlight.js/tree/fe/julia-unleashed) on my fork if you need compile with more languages included.

Lets rewind and look at the example from the beginning of the post once again. While it doesn't exercise all of the changes, I hope you agree with me that the new markup is an improvement!

\codetoggle{
function main(who::Union{String,Nothing} = nothing)
    if who === nothing
        who = "world"
    end
    print(stdout, "hello, $(who)!\n")
    return nothing
end
}

Finally, to get a feeling of how the new syntax highlighter perform and behave in "real life", let's look at some Julia package code. To this end I copied verbatim the entire implementation of the [StarWarsArrays.jl](https://github.com/giordano/StarWarsArrays.jl) package, written by [Mosè Giordano](https://github.com/giordano). I believe it exercise almost all of the major changes that I made:

\codetoggle{
# Copyright (c) 2019 Mosè Giordano
# MIT License (https://github.com/giordano/StarWarsArrays.jl/blob/master/LICENSE.md)

module StarWarsArrays

export StarWarsArray, OriginalOrder, MacheteOrder

# Orders
abstract type StarWarsOrder end
struct OriginalOrder <: StarWarsOrder end
struct MacheteOrder <: StarWarsOrder end

# Exception
struct StarWarsError <: Exception
    i::Any
    order::Any
end

function Base.showerror(io::IO, err::StarWarsError)
    print(io, "StarWarsError: there is no episode $(err.i)" * "in $(err.order)")
end

# The main struct
struct StarWarsArray{T,N,P<:AbstractArray,O<:StarWarsOrder} <: AbstractArray{T,N}
    parent::P
end
function StarWarsArray(p::P, order::Type{<:StarWarsOrder}=OriginalOrder) where {T,N,P<:AbstractArray{T,N}}
    StarWarsArray{T,N,P,order}(p)
end

machete_view_index(i) = range(1, stop=i)
function StarWarsArray(p::P, order::Type{MacheteOrder}) where {T,N,P<:AbstractArray{T,N}}
    StarWarsArray{T,N,P,order}(view(p, machete_view_index.(size(p) .- 1)...))
end

order(::StarWarsArray{T,N,P,O}) where {T,N,P,O} = O

# Indexing
function index(i::Int, ::Int, ::Type{OriginalOrder})
    if 4 <= i <= 6
        return i - 3
    elseif 1 <= i <= 3
        return i + 3
    else
        return i
    end
end
function index(i::Int, size::Int, order::Type{MacheteOrder})
    if 4 <= i <= 5
        return i - 3
    elseif 2 <= i <= 3
        return i + 1
    elseif  6 <= i <= size + 1
        return i - 1
    elseif i == 1
        throw(StarWarsError(i,order))
    else
        return i
    end
end

# Get the parent
Base.parent(A::StarWarsArray) = A.parent

# Get the size
Base.size(A::StarWarsArray{T,N,P,O}) where {T,N,P,O} = size(parent(A))

# Get the elements
Base.getindex(A::StarWarsArray, i::Int) =
    getindex(parent(A), index(i, length(parent(A)), order(A)))
Base.getindex(A::StarWarsArray{T,N}, i::Vararg{Int,N}) where {T,N} =
    getindex(parent(A), index.(i, size(parent(A)), order(A))...)
Base.setindex!(A::StarWarsArray, v, i::Int) =
    setindex!(parent(A), v, index(i, length(parent(A)), order(A)))
Base.setindex!(A::StarWarsArray{T,N}, v, i::Vararg{Int,N}) where {T,N} =
    setindex!(parent(A), v, index.(i, size(parent(A)), order(A))...)

# Showing.  Note: this is awful, but it does what I want
Base.show(io::IO, m::MIME"text/plain", A::StarWarsArray{T,N,P,MacheteOrder}) where {T,N,P} =
    show(io, m,
         view(parent(A),
              map(i->StarWarsArrays.index.(i .+ 1, length(A), MacheteOrder),
                  StarWarsArrays.machete_view_index.(size(A)))...))

end # module
}



~~~
<style>
.toggle-code-wrap input ~ .toggle-code-new {
     display: none;
}
.toggle-code-wrap input:checked ~ .toggle-code-new {
    display: block;
}
.toggle-code-wrap input ~ .toggle-code-old {
     display: block;
}
.toggle-code-wrap input:checked ~ .toggle-code-old {
    display: none;
}

.toggle-code-wrap input, .toggle-code-wrap label {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  display: inline-block;
  width: 30px;
  height: 17px;
}
.toggle-code-wrap input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-code-wrap .slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  -webkit-transition: .2s;
  transition: .2s;
}
.toggle-code-wrap .slider:before {
  position: absolute;
  content: "";
  height: 13px;
  width: 13px;
  left: 2px;
  bottom: 2px;
  background-color: white;
  -webkit-transition: .2s;
  transition: .2s;
}

.toggle-code-wrap input:checked ~ label.switch .slider {
  background-color: #2196F3;
  background-color: #458;
}

.toggle-code-wrap input:checked ~ label.switch .slider:before {
  -webkit-transform: translateX(13px);
  -ms-transform: translateX(13px);
  transform: translateX(13px);
}

/* Rounded sliders */
.toggle-code-wrap .slider.round {
  border-radius: 8px;
}
.toggle-code-wrap .slider.round:before {
  border-radius: 50%;
}
</style>

~~~
