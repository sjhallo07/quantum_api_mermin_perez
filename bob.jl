using LinearAlgebra

# La misma definición del protocolo (La Verdad local de Bob)
I_m = ComplexF64[1 0; 0 1]; X_m = ComplexF64[0 1; 1 0]
Y_m = ComplexF64[0 -im; im 0]; Z_m = ComplexF64[1 0; 0 -1]
I_final = kron(I_m, I_m)

grid = Matrix{Matrix{ComplexF64}}(undef, 3, 3)
grid[1,1]=kron(X_m, I_m); grid[1,2]=kron(I_m, X_m); grid[1,3]=kron(X_m, X_m)
grid[2,1]=kron(I_m, Z_m); grid[2,2]=kron(Z_m, I_m); grid[2,3]=kron(Z_m, Z_m)
grid[3,1]=kron(X_m, Z_m); grid[3,2]=kron(Z_m, X_m); grid[3,3]=kron(Y_m, Y_m)

function verificar()
    println("--- BOB: Observación Independiente ---")
    for j in 1:3
        # Multiplicación matricial explícita
        res = grid[1,j] * grid[2,j] * grid[3,j]
        target = (j == 3) ? -I_final : I_final
        println("Columna $j: ", isapprox(res, target, atol=1e-10) ? "Correcta (±I)" : "Fallo")
    end
end

verificar()
