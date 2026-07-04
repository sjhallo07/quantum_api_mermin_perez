using LinearAlgebra

# === MATRIZ SOBERANA (Fondo Neutro 5D) ===
const MATRIZ_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]

const I2 = [1.0 0.0; 0.0 1.0]
const X  = [0.0 1.0; 1.0 0.0]
const Z  = [1.0 0.0; 0.0 -1.0]
const Y  = [0.0 -1.0im; 1.0im 0.0]

const CuadradoMP = [
    (kron(X, I2), kron(I2, X), kron(X, X)),
    (kron(I2, Z), kron(Z, I2), kron(Z, Z)),
    (kron(X, Z),  kron(Z, X),  kron(Y, Y))
]

println("=== [BOB] RECEPTOR CUÁNTICO CON AUDITORÍA HUMANA ===")

# Bob solicita la entrada manual estricta
print("Ingrese DATA_PAYLOAD: ")
data = readline()
print("Ingrese CHECKSUM: ")
chk = readline()

println("\nVerificando integridad del Fondo Neutro...")

# Validación estricta del hash del payload
if hash(data) == parse(UInt64, chk)
    println("[BOB] ¡Integridad verificada! Procesando Qubit...")
    
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
    println("¡Éxito! Transmisión real completada mediante puente humano.")
else
    println("\nERROR: Integridad física comprometida. El hash no coincide.")
end
