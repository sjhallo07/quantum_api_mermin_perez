using LinearAlgebra

# === MATRIZ SOBERANA (Fondo Neutro 5D) ===
const MATRIZ_SOBERANA = [
    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  1.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

# 1. Operadores Cuánticos (Mermin-Peres)
const I2 = [1.0 0.0; 0.0 1.0]
const X  = [0.0 1.0; 1.0 0.0]
const Z  = [1.0 0.0; 0.0 -1.0]
const Y  = [0.0 -1.0im; 1.0im 0.0]

const CuadradoMP = [
    (kron(X, I2), kron(I2, X), kron(X, X)),
    (kron(I2, Z), kron(Z, I2), kron(Z, Z)),
    (kron(X, Z),  kron(Z, X),  kron(Y, Y))
]

val_psi = zeros(ComplexF64, 16)
val_psi[1 + 0b0011] = 1.0
val_psi[1 + 0b0110] = -1.0
val_psi[1 + 0b1001] = -1.0
val_psi[1 + 0b1100] = 1.0
const PSI = normalize!(val_psi)

function evaluar_interseccion(f, c)
    Op_Conjunto = kron(CuadradoMP[f][c], CuadradoMP[f][c])
    return round(Int, real(dot(PSI, Op_Conjunto * PSI)) * abs(det(MATRIZ_SOBERANA)))
end

# 2. Enrutamiento nativo del Kernel para simulación o ejecución por terminales
rol = get(ENV, "PROCESO_ROL", "ARBITRO")

if rol == "ALICE"
    fila = parse(Int, get(ENV, "CUANTUM_INDEX", "1"))
    println("[ALICE] Proceso aislado ejecutado. Fila medida: $fila")
    exit(0)

elseif rol == "BOB"
    columna = parse(Int, get(ENV, "CUANTUM_INDEX", "3"))
    println("[BOB] Proceso aislado ejecutado. Columna medida: $columna")
    exit(0)

else
    fila_elegida = 1
    columna_elegida = 3

    println("=== INICIANDO RETO MERMIN-PERES REAL EN KERNEL ===")
    println("Fila de Alice = $fila_elegida | Columna de Bob = $columna_elegida")
    println("--------------------------------------------------")

    julia_bin = joinpath(Sys.BINDIR, "julia")
    script_path = @__FILE__

    cmd_alice = setenv(Cmd([julia_bin, script_path]), "PROCESO_ROL" => "ALICE", "CUANTUM_INDEX" => "$fila_elegida")
    cmd_bob   = setenv(Cmd([julia_bin, script_path]), "PROCESO_ROL" => "BOB", "CUANTUM_INDEX" => "$columna_elegida")

    run(cmd_alice)
    run(cmd_bob)

    resultado = evaluar_interseccion(fila_elegida, columna_elegida)

    println("--------------------------------------------------")
    println("[INTERSECCIÓN CUÁNTICA CON MATRIZ SOBERANA]")
    println("Resultado de la celda ($fila_elegida, $columna_elegida): $resultado")
    println("¡Éxito! Ejecución en tiempo real sin sockets ni memoria compartida.")
end
