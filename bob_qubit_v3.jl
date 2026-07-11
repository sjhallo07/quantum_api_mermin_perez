using LinearAlgebra
using SHA

# === MATRICES DE PAULI Y FONDO NEUTRO ===
const MATRIZ_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]

const I2 = [1.0 0.0; 0.0 1.0]
const X  = [0.0 1.0; 1.0 0.0]
const Z  = [1.0 0.0; 0.0 -1.0]
const Y  = [0.0 -1.0im; 1.0im 0.0]

# Cuadrado Mágico de Mermin-Peres (Operadores entrelazados reales)
const CuadradoMP = [
    (kron(X, I2), kron(I2, X), kron(X, X)),
    (kron(I2, Z), kron(Z, I2), kron(Z, Z)),
    (kron(X, Z),  kron(Z, X),  kron(Y, Y))
]

println("=== [BOB] RECEPTOR CUÁNTICO V3 (CÁLCULO ALGEBRAICO REAL) ===")

print("Ingrese DATA_PAYLOAD: ")
data = readline()
print("Ingrese CHECKSUM: ")
chk = readline()

println("\nVerificando integridad criptográfica (SHA-256)...")

if bytes2hex(sha256(data)) == chk
    println("[BOB] ¡Integridad verificada! Despertando operadores matriciales...")
    
    parts = split(data, ",")
    f = parse(Int, parts[1])
    c = parse(Int, parts[2])

    # === LA FÍSICA REAL EN ACCIÓN (Cero condicionales if para el cálculo) ===
    
    # 1. Multiplicamos todas las matrices de la Fila elegida por Alice
    Fila_Alice = CuadradoMP[f][1] * CuadradoMP[f][2] * CuadradoMP[f][3]
    
    # 2. Multiplicamos todas las matrices de la Columna elegida por Bob
    Columna_Bob = CuadradoMP[1][c] * CuadradoMP[2][c] * CuadradoMP[3][c]

    # 3. Calculamos el Contexto Global (Cruce de Fila y Columna)
    Contexto_Conjunto = Fila_Alice * Columna_Bob

    # 4. Extraemos el valor colapsado tomando la Traza de la matriz resultante
    # Como el resultado es I o -I (matrices 4x4), la traza será 4 o -4. Dividimos entre 4.
    resultado_cuantico = round(Int, real(tr(Contexto_Conjunto) / 4))

    # Filtro del Fondo Neutro (Se mantiene tu arquitectura)
    filtro = abs(det(MATRIZ_SOBERANA))
    resultado_final = round(Int, resultado_cuantico * filtro)

    println("--------------------------------------------------")
    println("[ÁLGEBRA] Producto de la Fila $f resultó en: Identidad Positiva")
    if c == 3
        println("[ÁLGEBRA] Producto de la Columna $c resultó en: IDENTIDAD NEGATIVA (-I)")
    else
        println("[ÁLGEBRA] Producto de la Columna $c resultó en: Identidad Positiva")
    end
    println("--------------------------------------------------")
    println("[BOB] Resultado final de la medición: ", resultado_final)
    
    if resultado_final == -1
        println("\n¡ANOMALÍA CUÁNTICA DEMOSTRADA MATEMÁTICAMENTE!")
        println("El código no tiene condicionales para este cálculo. El -1 nació puramente de la multiplicación de las matrices de Pauli.")
    end
else
    println("\nERROR: Integridad física comprometida. El hash SHA-256 no coincide.")
end
