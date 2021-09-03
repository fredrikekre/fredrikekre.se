+++
date = "2021-04-19"
markdown_title = "Project specific Julia configuration with `direnv`"
var"layout-post" = nothing
tags = ["direnv", "julia", "open-source"]
hascode = true
rss = "Improve your workflow with direnv: this post describes how direnv can be used effectively together with Julia."

# Dependent variables
title = replace(markdown_title, "`" => "")
website_description = rss
rss_pubdate = Date(date)
+++


~~~
<h1><a href="{{ get_url }}">{{ markdown2html markdown_title }}</a></h1>
~~~

I heard about [`direnv`](https://direnv.net/) the first time a couple of years ago, but it wasn't until the past autumn that I seriously looked into it and tried it out. Now that I have used it for a just over half a year I can say that `direnv` has become a huge quality-of-life improvement to my development workflow. `direnv` was recently discussed in the Julia community chat and it was my understanding that not many people were aware of it, or what it can be used for. Therefore I wanted to briefly present `direnv` in this post with the focus on how to use `direnv` effectively together with Julia.

## Brief introduction to `direnv`

This post is not meant to be a comprehensive guide to `direnv`, but in order to fully appreciate the rest of the post it is good to have a general understanding of what `direnv` does. For installation and initial configuration refer to the [official documentation](https://direnv.net/).

`direnv` is a shell extension that automatically loads (and unloads!) environment variables depending on configuration in the current directory. Before each shell prompt `direnv` checks for an `.envrc` file, and, if it exists, spawns a sub-shell where `direnv`'s standard library (the *stdlib*) and the `.envrc` file is loaded. `direnv` monitors any changes to the environment, and re-exports the changes to the original shell.

Let's look at an example: create a directory `my-project` with a file `.envrc` which sets the environment variable `HELLO`:

```bash
~$ tree -a
.
└── my-project
    └── .envrc

1 directory, 1 file

~$ cat my-project/.envrc
export HELLO=world
```

Let's first verify that the variable is not set, and then, when we `cd` to the directory containing the `.envrc` file, `direnv` should set the variable:

```bash
~$ echo $HELLO

~$ cd my-project
direnv: error /home/fredrik/my-project/.envrc is blocked.
Run `direnv allow` to approve its content
```

An error -- what happened here? `direnv` comes with a built in security mechanism that blocks execution of `.envrc` files which have not been manually approved -- we wouldn't want to accidentally execute unknown code by just `cd`ing to a directory with a file `.envrc`. After making sure the content of `.envrc` is legit we can approve the file with the `direnv allow` command, as the error message suggest. This is not needed the next time we enter this directory, unless the file has been modified.

```bash
~/my-project$ direnv allow
direnv: loading ~/my-project/.envrc
direnv: export +HELLO
```

Success! `direnv` reports that the file was found and loaded, and that the variable `HELLO` has been re-exported. We can verify that it has the expected value:

```bash
~/my-project$ echo $HELLO
world
```

If we step out of this directory, `direnv` will unload the changes, and the `HELLO` variable is reset to its original value (unset in this case):

```bash
$ cd ..
direnv: unloading

~$ echo $HELLO

```


## Configuring Julia with `direnv`

Let's have a look at how `direnv` can be used together with Julia. A good start is to look at the [Environment Variables section](https://docs.julialang.org/en/v1/manual/environment-variables/) in the manual. However, it is not only things listed there that might be useful for Julia configuration. In the following sections I will describe the things I have found most useful.


### Julia version management

Sometimes it is useful to configure a specific Julia version for a project. In a series of pull requests ([#665](https://github.com/direnv/direnv/pull/665), [#666](https://github.com/direnv/direnv/pull/666), [#667](https://github.com/direnv/direnv/pull/667)) I added the `use julia X.Y.Z` command to the `direnv` stdlib to make it very simple to load a specific version of Julia (requires `direnv` version 2.22.0 or newer). For example, to load Julia version 1.6 simply put the following in the `.envrc` file:

```bash
use julia 1.6
```

Under the hood `direnv` modifies `PATH` (and some other variables) such that the specified Julia version is at the top to make sure that `julia` points to the correct version:

```bash
$ cat .envrc
use julia 1.6

$ julia --version
julia version 1.6.0

$ cat .envrc
use julia 1.5

$ julia --version
julia version 1.5.4
```

The only required configuration is to define the variable `JULIA_VERSIONS` first, which should point to a directory of Julia installs. In my case I have Julia versions installed to `/opt/julia`:

```bash
$ tree -L 1 /opt/julia/
/opt/julia/
├── julia-1.0
├── julia-1.1
├── julia-1.2
├── julia-1.3
├── julia-1.4
├── julia-1.5
└── julia-1.6
```
and thus put:
```bash
JULIA_VERSIONS="/opt/julia"
```

in my global configuration file, the `direnvrc` file (by default located at `~/.config/direnv/direnvrc`). By default the prefix `julia-` is used when `direnv` looks for the specified version, but this can be changed by setting `JULIA_VERSION_PREFIX`, see the [documentation](https://direnv.net/man/direnv-stdlib.1.html#codeuse-julia-ltversiongtcode) for more details. As an example, if you use the [`asdf`](https://asdf-vm.com/) version manager to install Julia you will find that `asdf` installs versions into `~/.asdf/installs/julia/X.Y.Z`, i.e. to directories without the `julia-` prefix. In that case you can put the following in `direnvrc`:
```bash
JULIA_VERSIONS="$HOME/.asdf/installs/julia"
JULIA_VERSION_PREFIX=""
```

### Package environments

Before discussing how `direnv` can be used to control the package environment it is good to understand how Julia's package loading work. The command `import Example` will prompt Julia to look for a package named `Example` in the *load path*. The load path is essentially a list of package environments where Julia should look for what `Example` means in the current configuration, e.g. which package and which version that should be loaded. The load path is expanded from the global variable `LOAD_PATH`, where the default configuration looks like this:

```julia-repl
julia> LOAD_PATH
3-element Vector{String}:
 "@"
 "@v#.#"
 "@stdlib"

julia> Base.load_path() # expansion of LOAD_PATH
2-element Vector{String}:
 "/home/fredrik/.julia/environments/v1.6/Project.toml"
 "/opt/julia/julia-1.6/share/julia/stdlib/v1.6"
```

`@` expands to the *active project* which is configured with the `--project` command line flag, the [`JULIA_PROJECT`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_PROJECT) environment variable, or with `Pkg.activate` (in the example above it is unset). `@v#.#` expands to the default global package environment for the current Julia version, and `@stdlib` expands to the Julia standard library. When trying to import a package called `Example` Julia will look in each of the entries of the load path and the first occurance of a package called `Example` will be loaded.

It is quite common to use a project-local package environment in Julia. This reduces the risk of running into package incompatibilities and helps with reproducibility. The two most common ways to make sure the local package environment is used is to either start Julia with `julia --project`, or use `Pkg.activate(pwd())`. This will make sure the first entry in `LOAD_PATH` expands to the current directory. `direnv` makes it very easy to enable this behavior by default by putting `layout julia` in the `.envrc` file:

```bash
layout julia
```

This command sets the environment variable `JULIA_PROJECT` to the current directory automatically and there is no risk of forgetting to use `--project` or `Pkg.activate`.

As hinted to above the load path is a stack of environments and it is possible to load packages from any entry. In some cases, for example if reproducibility is important, you might want to be even more strict and only allow packages from a single environment. This can be achieved by configuring the [`JULIA_LOAD_PATH`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_LOAD_PATH) environment variable directly. The global variable `LOAD_PATH` is initialized from the `JULIA_LOAD_PATH` variable (with default values discussed above). For example, the following (in `.envrc`) makes sure there is only a single entry, the project in the current directory, in the load path:

```bash
export JULIA_LOAD_PATH="${PWD}"
```

Another usecase is to build a custom stack of environments. Here is an example which puts allows loading of packages from the environment in the current directory, packages from a sub-environment called `devtools`, and packages from the standard library:

```bash
export JULIA_LOAD_PATH="${PWD}:${PWD}/devtools:@stdlib"
```


### Julia command line options

Since the `.envrc` is just a Bash script it is possible to use side effects from its execution. We can define the following function in `direnvrc` (for global usage), or in `.envrc`, to configure project specific Julia command line options:

```bash
julia_args() {
    # Create a bin directory
    mkdir -p bin
    # Create a wrapper script to call julia with the arguments
    echo "#!/bin/bash
    exec $(which julia) "$@" \"\$@\"
    " > bin/julia
    # Make it executable
    chmod +x bin/julia
    # Make sure bin is in PATH
    PATH_add bin
}
```
This function creates a wrapper script in the `bin` directory which launches Julia with the specified command line options. From `.envrc` it is used as follows:
```bash
# Configure a Julia version
use julia 1.6

# Configure command line options
julia_args --threads=4 --check-bounds=no --optimize=3
```

Simply invoking `julia` now uses the command line options specifiec in the `.envrc` file:
```bash
$ julia -E 'Threads.nthreads()'
4
```

### Project specific history

To keep a project specific REPL history file it is possible to define the [`JULIA_HISTORY`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_HISTORY) environment variable in the `.envrc` file:

```bash
export JULIA_HISTORY=${PWD}/repl_history.jl
```

### Julia with `direnv` in VSCode

In order to use `direnv` with [VSCode](https://code.visualstudio.com/) and the [Julia extension](https://www.julia-vscode.org/) there are some extra configuration needed. The reason for this is that the extension does not launch Julia through the shell, and we can thus not rely on direnv's auto-loading of the environment. In addition, the extension spawns multiple julia processes: one for the language server protocol, and one for evaluating user-code. It is only the latter which is of interest to configure using direnv. Fortunately, `direnv` provides an `exec` command that can be used to load a `.envrc` file and then execute a command. This can be utilized by pointing the `Julia: Executable Path` extension setting to the following executable wrapper script:

```bash
#!/bin/bash

# Absolute path to the direnv executable
DIRENV=/opt/direnv/direnv
# Tell direnv about bash; needed if bash is not in PATH
export DIRENV_BASH=/bin/bash

# Prepend PATH with a fallback julia
JULIA_PATH=/opt/julia/julia-1.6/bin
export PATH="${JULIA_PATH}:${PATH}"

if [ -z "${JULIA_LANGUAGESERVER}" ]; then
    # REPL process; use direnv exec to load .envrc file
    exec "${DIRENV}" exec "${PWD}" julia "${@}"
else
    # Language Server process; exec the fallback julia
    exec julia "${@}"
fi
```

This looks a bit convoluted but it is pretty simple. First we set up the absolute path to `direnv` and configure `direnv`'s Bash path with the `DIRENV_BASH` environment variable. This is important since we are not in control of how this script is invoked, and, in particular, `PATH` might not be what we expect. Next, a fallback julia location is prepended to `PATH`. This fallback will be used by the language server process (and by the user process unless a different julia location is configured in the `.envrc` file). Finally, we inspect the `JULIA_LANGUAGESERVER` variable, which tells us whether we are currently launching the language server process or not. For the user process we launch julia through `direnv exec` and for the language server process the fallback julia, that was previously configured, is `exec`d.

Let's verify that it worked using the following `.envrc` file:

```bash
export HELLO=world
```

After approving the file (`direnv allow` in an embedded or external terminal) we launch a Julia REPL process with the `Julia: Start REPL` command:

```julia-repl
direnv: loading ~/dev/Example/.envrc
julia>
```

From the output we see that direnv found the `.envrc` file and loaded it and we can verify that the `HELLO` variable defined in the file is set:

```julia-repl
direnv: loading ~/dev/Example/.envrc
julia> ENV["HELLO"]
"world"
```

## Concluding remarks

In this post I have presented `direnv` and how it can be used to configure Julia. `direnv` is, of course, very useful for other things too, such as project local API keys etc. Most of the things presented in the post are things that I use daily, and that I feel have improved my workflow very much. I really recommend you to try `direnv`, and I hope you will find it useful!
