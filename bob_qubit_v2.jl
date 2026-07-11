using LinearAlgebra
using SHA

# === MATRIZ SOBERANA (Fondo Neutro 5D) ===
const MATRIZ_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]

println("=== [BOB] RECEPTOR CUÁNTICO V2 (SHA-256) ===")

print("Ingrese DATA_PAYLOAD: ")
data = readline()
print("Ingrese CHECKSUM: ")
chk = readline()

println("\nVerificando integridad del Fondo Neutro (SHA-256)...")

# Validación criptográfica multiplataforma
if bytes2hex(sha256(data)) == chk
    println("[BOB] ¡Integridad criptográfica verificada! Procesando Qubit...")

    # Extraer las dimensiones del payload validado
    parts = split(data, ",")
    f = parse(Int, parts[1])
    c = parse(Int, parts[2])

    # Procesar colapso de la celda de Mermin-Peres
    filtro = abs(det(MATRIZ_SOBERANA))
    resultado = (f == 3 && c == 3) ? -1 : 1
    resultado_final = round(Int, resultado * filtro)

    println("--------------------------------------------------")
    println("[BOB] Resultado final de la medición: ", resultado_final)
    println("¡Éxito! Transmisión Air-Gap completada con seguridad inmutable.")
else
    println("\nERROR: Integridad física comprometida. El hash SHA-256 no coincide.")
end
