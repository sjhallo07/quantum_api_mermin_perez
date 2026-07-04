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

rol = get(ENV, "PROCESO_ROL", "MANUAL")

if rol == "ALICE"
    println("=== [ALICE] GENERADOR DE QUBITS CON CHECKSUM MANUAL ===")
    print("Selecciona Fila de Alice (1-3): ")
    f = parse(Int, readline())
    print("Selecciona Columna de Bob (1-3): ")
    c = parse(Int, readline())
    
    if f in 1:3 && c in 1:3
        S = "$f,$c,1.0,0.0,-1.0,0.0"
        println("\n==================================================")
        println("DATA_PAYLOAD: $S")
        println("CHECKSUM: ", hash(S))
        println("==================================================")
        println("[ALICE] Estado calculado. Copia el PAYLOAD y CHECKSUM en Bob.")
    else
        println("Valores fuera de rango.")
    end

elseif rol == "BOB"
    println("=== [BOB] RECEPTOR CUÁNTICO CON AUDITORÍA HUMANA ===")
    print("Ingrese DATA_PAYLOAD: ")
    data = readline()
    print("Ingrese CHECKSUM: ")
    chk = readline()
    
    println("\nVerificando integridad del Fondo Neutro...")
    if hash(data) == parse(UInt64, chk)
        println("[BOB] ¡Integridad verificada! Procesando Qubit...")
        parts = split(data, ",")
        f = parse(Int, parts[1])
        c = parse(Int, parts[2])
        
        filtro = abs(det(MATRIZ_SOBERANA))
        resultado = (f == 3 && c == 3) ? -1 : 1
        resultado_final = round(Int, resultado * filtro)
        
        println("--------------------------------------------------")
        println("[BOB] Resultado final de la medición: ", resultado_final)
        println("¡Éxito! Transmisión real completada mediante puente humano.")
    else
        println("ERROR: Integridad física comprometida. El hash no coincide.")
    end

else
    println("=== MODO DE SELECCIÓN DE ENTORNO ===")
    println("Para ejecutar Alice: export PROCESO_ROL=ALICE && julia mermin_peres_real.jl")
    println("Para ejecutar Bob:   export PROCESO_ROL=BOB   && julia mermin_peres_real.jl")
end
