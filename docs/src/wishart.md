# Matrix-variate Wishart workflow

This page documents the matrix-variate `Wishart` workflow used in the current
Julia research codebase.

The workflow starts from an 8×8 positive-definite density-like matrix, then builds
an explicit matrix-variate distribution:

\[
X \sim \mathcal{W}_p(n, \Sigma)
\]

where:

- $p = 8$ is the matrix dimension,
- $n$ is the degrees of freedom,
- $\Sigma$ is the scale matrix.

## Repository pattern

The matrix workflow follows the same structure used in the project file:

1. Define the 8×8 scale matrix.
2. Build the `Wishart` distribution with `Wishart(9, Σ)`.
3. Sample from the distribution with `rand`.
4. Normalize the sampled matrix by its trace.
5. Evaluate the log-density using `logpdf`.

## Example code

```julia
using Distributions
using LinearAlgebra

const MATRIZ_DENSIDAD_8X8 = Float64[
    0.110  0.030  0.050  0.020  0.050  0.040  0.030  0.030;
    0.030  0.130  0.060  0.020  0.060  0.050  0.040  0.040;
    0.050  0.060  0.150  0.030  0.080  0.060  0.050  0.050;
    0.020  0.020  0.030  0.100  0.030  0.030  0.020  0.020;
    0.050  0.060  0.080  0.030  0.160  0.060  0.050  0.050;
    0.040  0.050  0.060  0.030  0.060  0.120  0.040  0.040;
    0.030  0.040  0.050  0.020  0.050  0.040  0.110  0.030;
    0.030  0.040  0.050  0.020  0.050  0.040  0.030  0.120
]

const DISTRIBUCION_ESTADISTICA_8D = Wishart(9, MATRIZ_DENSIDAD_8X8)

function muestrear_matriz_real()
    M_instancia = rand(DISTRIBUCION_ESTADISTICA_8D)
    return M_instancia / tr(M_instancia)
end

function evaluar_logpdf_matriz(matriz_observada::Matrix{Float64})
    size(matriz_observada) == (8, 8) || error("DimensionMismatch")
    return logpdf(DISTRIBUCION_ESTADISTICA_8D, matriz_observada + I * 1e-7)
end
```

## Related references

- [Distributions.jl stable docs](https://juliastats.org/Distributions.jl/stable/)
- [Matrix-variate distributions](https://juliastats.org/Distributions.jl/stable/matrix/)
- [Mixture models](https://juliastats.org/Distributions.jl/stable/mixture/)
- [Fitting models](https://juliastats.org/Distributions.jl/stable/fit/)
