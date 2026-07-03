using SHA

# 1. Definimos los parámetros del sistema
N, K = 25, 5

# 2. Generamos la Matriz Soberana (Lógica autocontenida)
solucion = zeros(Int, N, N)
for i in 1:N, j in 1:N
    solucion[i, j] = 1 + (K * ((i-1) % K) + floor(Int, (i-1) / K) + (j-1)) % N
end

# 3. Creamos el sello
matriz_data = string(solucion)
hash_matriz = bytes2hex(sha256(matriz_data))

open("matriz_soberana.seal", "w") do f; write(f, hash_matriz); end

println("✅ Matriz Soberana (25x25) generada.")
println("Firma de Integridad (SHA-256): $hash_matriz")
