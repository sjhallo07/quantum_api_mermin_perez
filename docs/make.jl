using Documenter

makedocs(;
    sitename="Quantum API Mermin Pérez",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "") == "true",
        mathengine=MathJax3(),
        inventory_version="0.1.0",
    ),
    pages=[
        "Home" => "index.md",
        "Distributions references" => "distributions.md",
        "Wishart workflow" => "wishart.md",
        "Sudoku notes" => "sudoku.md",
    ],
    doctest=true,
    warnonly=Symbol[],
    checkdocs=:exports,
)

if get(ENV, "CI", "") == "true"
    deploydocs(;
        repo="github.com/sjhallo07/quantum_api_mermin_perez.git",
        branch="gh-pages",
        devbranch="main",
        push_preview=true,
    )
end
