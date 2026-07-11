using LinearAlgebra

# Estado |Ψ⁻⟩ que acabas de generar
psi = ComplexF64[0, -1/sqrt(2), 1/sqrt(2), 0]

# Matriz de Densidad (Outer product)
rho = psi * psi'

# La Traza de la matriz de densidad debe ser 1 (Regla de oro de la probabilidad)
# Si es 1, el estado es puro. Si es < 1, tienes ruido o decoherencia.
traza = tr(rho)

println("=== MATRIZ DE DENSIDAD (ρ) ===")
display(real.(rho))
println("\nTraza de la matriz: ", real(traza))
