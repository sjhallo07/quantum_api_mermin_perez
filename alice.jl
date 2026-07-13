include("soberania_absoluta.jl")
using LinearAlgebra

# Definición inmutable de operadores
I_m = ComplexF64[1 0; 0 1]; X_m = ComplexF64[0 1; 1 0]
Y_m = ComplexF64[0 -im; im 0]; Z_m = ComplexF64[1 0; 0 -1]
I_final = kron(I_m, I_m)

# Construcción de la cuadrícula asegurando el tipo Matrix{Matrix}
grid = Matrix{Matrix{ComplexF64}}(undef, 3, 3)
grid[1,1]=kron(X_m, I_m); grid[1,2]=kron(I_m, X_m); grid[1,3]=kron(X_m, X_m)
grid[2,1]=kron(I_m, Z_m); grid[2,2]=kron(Z_m, I_m); grid[2,3]=kron(Z_m, Z_m)
grid[3,1]=kron(X_m, Z_m); grid[3,2]=kron(Z_m, X_m); grid[3,3]=kron(Y_m, Y_m)

function verificar()
    println("--- ALICE: Verificando Consistencia ---")
    for i in 1:3
        # Multiplicación matricial explícita
        res = grid[i,1] * grid[i,2] * grid[i,3]
        println("Fila $i: ", isapprox(res, I_final, atol=1e-10) ? "Correcta (+I)" : "Fallo")
    end
end

verificar()
