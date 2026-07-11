using LinearAlgebra

# 1. Definición de la Matriz 5D (Alice)
f = 0.55
M5 = [
    -f 0.1 0 0 0;
    0.1 f 0 0 0;
    0 0 f 0 0;
    0 0 0 f 0;
    0 0 0 0 f
]

# 2. Definición de la Matriz 4x4 (Qiskit CNOT)
M4 = [
    1 0 0 0;
    0 1 0 0;
    0 0 0 1;
    0 0 1 0
]

# 3. Definición de la Proyección (Bridge 5D -> 4D)
# Seleccionamos las primeras 4 filas y columnas
P = [I(4) zeros(4, 1)]

# Proyectamos la matriz de Alice al espacio de Qiskit
M_Alice_en_Qiskit = P * M5 * P'

# 4. Comunicación (Multiplicación de Operadores)
# ¿Cómo interactúa el payload de Alice con la compuerta de Qiskit?
Resultado = M_Alice_en_Qiskit * M4

println("=== INTERACCIÓN 5D -> 4D ===")
display(real.(Resultado))

println("\n=== TRAZA DE LA COMUNICACIÓN (Poder del sistema) ===")
println(tr(Resultado))
