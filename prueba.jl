using LinearAlgebra

# 1. El Protocolo (Leyes de la Física)
I_m = ComplexF64[1 0; 0 1]; X_m = ComplexF64[0 1; 1 0]
Y_m = ComplexF64[0 -im; im 0]; Z_m = ComplexF64[1 0; 0 -1]

grid = [
    kron(X_m, I_m) kron(I_m, X_m) kron(X_m, X_m);
    kron(I_m, Z_m) kron(Z_m, I_m) kron(Z_m, Z_m);
    kron(X_m, Z_m) kron(Z_m, X_m) kron(Y_m, Y_m)
]

# 2. La prueba explícita (Espectro)
function ejecutar_observacion(nombre)
    println("--- $nombre observando el Cuadrado Mágico ---")
    
    # Observación de Columna 3 (La prueba de la contradicción)
    prod_col3 = grid[1,3] * grid[2,3] * grid[3,3]
    vals = real(eigvals(prod_col3))
    
    println("Producto Columna 3 (Autovalores): ", round.(vals, digits=1))
    
    if all(vals .< 0)
        println("Resultado: Observada Anti-Identidad (-I).")
        println("CONCLUSIÓN: El sistema es Contextual.")
    end
end

ejecutar_observacion(ARGS[1])
