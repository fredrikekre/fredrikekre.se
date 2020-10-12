<!-- RSS settings -->
<!--
@def website_title = "Fredrik Ekre"
@def website_descr = "Example website using Franklin"
@def website_url   = "http://localhost:8000/"
-->

<!-- Exclude everything that is not explicitly in include -->
@def include = ["_assets/", "_css/", "_libs/", "_layout/", "index.html", "404.md", "posts/", "about/"]
@def ignore = setdiff([isfile(x) ? x : x * "/" for x in readdir()], globvar("include"))


<!-- Theme specific options -->
<!-- @def title = "Fredrik Ekre" -->
@def sitename = "Fredrik Ekre"
@def author.name = "Fredrik Ekre"

<!-- Social icons -->
@def social = (
        github = "https://github.com/fredrikekre",
    )

<!-- Logo -->
@def logo.mark = "\$"
@def logo.text = "cd /home/fredrik"

<!-- Menu -->
@def menu = [
        (name = "Posts", url = "/posts/"),
        #(name = "Research", url = "/research/"),
        (name = "About", url = "/about/"),
    ]
