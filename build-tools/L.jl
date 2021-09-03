import Franklin, LiveServer
# Swap out the highlight.js library for prerendering
Franklin.HIGHLIGHTJS[] = get(ENV, "HIGHLIGHTJS", "highlight.js")


function on_write(pg, vars; output_path=nothing)
    output_path === nothing && return
    if endswith(output_path, "highlight-julia/index.html")
        l = length(pg)
        r = r"""^<div class="toggle-code-new">
        </p>
        <pre><code"""m
        s = """<div class="toggle-code-new">
        <pre><code"""
        pg = replace(pg, r => s)
        l′ = length(pg)
        r = r"""</code></pre>
            <p>
            </div>
            </div>"""m
        s = """</code></pre>
            </div>
            </div>"""
        pg = replace(pg, r => s)
        l′′ = length(pg)
        @assert div(l - l′, 5) == div(l′ - l′′, 4)
        @assert l - l′ > 0
        write(output_path, pg)
    end
    return nothing
end
