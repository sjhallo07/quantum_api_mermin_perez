# Distributions.jl references

This project uses the JuliaStats `Distributions.jl` ecosystem for matrix-variate
and statistical modeling workflows. The main reference pages are:

- [Distributions.jl stable documentation](https://juliastats.org/Distributions.jl/stable/)
- [Matrix-variate distributions](https://juliastats.org/Distributions.jl/stable/matrix/)
- [Mixture models](https://juliastats.org/Distributions.jl/stable/mixture/)
- [Fitting and parameter estimation](https://juliastats.org/Distributions.jl/stable/fit/)

## Repository context

The current Julia workflow is centered on matrix-valued simulation and validation.
In that context, the most relevant pieces are:

- `Wishart` for matrix-valued density modeling
- `logpdf` for score evaluation against an observed matrix
- `rand` for generating matrix samples

## Minimal example

```julia
using Distributions
using LinearAlgebra

M = Matrix{Float64}(I, 2, 2)
println(tr(M))
```
