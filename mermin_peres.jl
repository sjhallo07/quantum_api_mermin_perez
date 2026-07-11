using LinearAlgebra

# 1. Definición pura de los operadores básicos
I = ComplexF64[1 0; 0 1]
X = ComplexF64[0 1; 1 0]
Y = ComplexF64[0 -1im; 1im 0]
Z = ComplexF64[1 0; 0 -1]

# 2. Definición del Cuadrado de Mermin-Peres (9 Operadores)
# Filas
r1 = [kron(I, Z), kron(Z, I), kron(Z, Z)]
r2 = [kron(X, I), kron(I, X), kron(X, X)]
r3 = [kron(X, Z), kron(Z, X), kron(Y, Y)]

# 3. Verificación Algebraica de Filas (Producto debe ser ± I)
println("=== VERIFICACION DE FILAS ===")
for (i, row) in enumerate([r1, r2, r3])
    prod = row[1] * row[2] * row[3]
    println("Fila $i producto: \n", real.(prod))
end

# 4. Columnas
c1 = [r1[1], r2[1], r3[1]]
c2 = [r1[2], r2[2], r3[2]]
c3 = [r1[3], r2[3], r3[3]]

# 5. Verificación Algebraica de Columnas
println("\n=== VERIFICACION DE COLUMNAS ===")
for (i, col) in enumerate([c1, c2, c3])
    prod = col[1] * col[2] * col[3]
    println("Columna $i producto: \n", real.(prod))
end
