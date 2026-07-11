using LinearAlgebra

# 1. El Mensaje como Vector de Estado (72-dimensional)
# Codificamos "I m ROYAL" (9 caracteres * 8 bits)
msg_binary = [0,1,0,0,1,0,0,1, 0,0,1,0,0,0,0,0, 0,1,1,0,1,1,0,1, 0,0,1,0,0,0,0,0, 0,1,0,1,0,0,1,0, 0,1,0,0,1,1,1,1, 0,1,0,1,1,0,0,1, 0,1,0,0,0,0,0,1, 0,1,0,0,1,1,0,0]
V_raw = Float64.(msg_binary)

# 2. El Operador de Alice (Matriz de Codificación/Restricción)
# Creamos una matriz de permutación circular para 'restringir' la data
n = length(V_raw)
Alice = zeros(n, n)
for i in 1:n
    Alice[i, mod1(i + 3, n)] = 1.0 
end

# 3. La Comunicación (Alice envía el estado codificado)
V_codificado = Alice * V_raw

# 4. El Proceso de Bob (Función Nativa: Inversión del Operador)
# Bob aplica Alice' (Adjoint/Inverse) para decodificar sin saber el contenido
Bob = Alice'
V_recuperado = Bob * V_codificado

# Verificación de integridad
println("=== PROCESAMIENTO DE BOB ===")
println("Integridad del Estado (V_raw == V_recuperado): ", V_raw ≈ V_recuperado)
println("\n=== VECTOR DECODIFICADO ===")
println(Int.(V_recuperado))
