using CoverageControllers
using Documenter

DocMeta.setdocmeta!(CoverageControllers, :DocTestSetup, :(using CoverageControllers); recursive=true)

makedocs(;
    modules=[CoverageControllers],
    authors="Devansh Ramgopal Agrawal <devansh@umich.edu> and contributors",
    sitename="CoverageControllers.jl",
    format=Documenter.HTML(;
        canonical="https://dev10110.github.io/CoverageControllers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dev10110/CoverageControllers.jl",
    devbranch="main",
)
