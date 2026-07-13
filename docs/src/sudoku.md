# Sudoku notes

This page documents the 25×25 Sudoku solver workflow as a representative example
for the current Julia research codebase.

The solver in sudoku_25.jl uses a backtracking strategy with logical candidate
pruning. The main rule family is:

\[
\forall r,c:\quad \text{cell}(r,c) \in \{1, \dots, 25\}
\]

And every row, column, and 5×5 subgrid must contain each symbol exactly once.

## Example of the constraint model

```julia
const N = 25
const SUB = 5
```
