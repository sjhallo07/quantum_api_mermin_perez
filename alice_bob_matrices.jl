using LinearAlgebra

# Bases fundamentales (Matrices de Pauli)
I = ComplexF64[1 0; 0 1]
X = ComplexF64[0 1; 1 0]
Z = ComplexF64[1 0; 0 -1]

# El "Imperio": Estado entrelazado inicial
Phi = ComplexF64[1, 0, 0, 1] / sqrt(2)

# ALICE y BOB como matrices (Operadores)
# Alice aplica X al Qubit 1, Bob aplica Z al Qubit 2
Alice = kron(X, I)
Bob   = kron(I, Z)

# La "Acción" del sistema (La composición de los operadores)
# Observa: El orden aquí es crucial si Alice y Bob no conmutan
Operacion_Global = Alice * Bob

# Evolución del estado
Estado_Final = Operacion_Global * Phi

# Verificación de la "Locura" (Entrelazamiento post-interacción)
# Calculamos la matriz de densidad reducida para ver si siguen entrelazados
Densidad = Estado_Final * Estado_Final'
# (Traza parcial del Qubit 2)
# Si el resultado es I/2, siguen entrelazados.
println("=== ESTADO FINAL DEL SISTEMA ===")
display(Estado_Final)

println("\n=== SIGNATURA DE LA INTERACCION (Operacion_Global * Operacion_Global') ===")
display(real.(Operacion_Global * Operacion_Global'))
