# Quantum API Mermin Pérez

This documentation site is built with Documenter.jl and demonstrates a
Markdown + LaTeX documentation workflow for the Julia workspace.

The repository already contains proof-oriented Julia research scripts such as
sudoku_25.jl, so the docs can describe the solver workflow without forcing a
large refactor of the existing project layout.

## Minimal math example

The following equation is rendered by Documenter using MathJax:

\[
\sum_{i=1}^{25}\sum_{j=1}^{25} \delta_{ij} = 25
\]

## Doctest example

```jldoctest
julia> 2 + 2
4
```
