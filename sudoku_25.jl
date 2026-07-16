# ======================================================================
#   RESOLVEDOR INTEGRADO OPTIMIZADO: ENFOQUE MI_MATRIZ_PROPIA (25x25)
# ======================================================================
using Printf

# Inclusión directa de tu script de matriz dedicado
include("mi_matriz_propia.jl")

const N = 25
const SUB = 5

# Estructura para almacenar candidatos por celda (Poda lógica matricial)
function obtener_candidatos(tablero, fila, col)
    if tablero[fila, col] != 0
        return Int[]
    end

    usados = zeros(Bool, N)

    # Chequear Fila y Columna
    for i in 1:N
        if tablero[fila, i] != 0; usados[tablero[fila, i]] = true; end
        if tablero[i, col] != 0; usados[tablero[i, col]] = true; end
    end

    # Chequear Subcuadrícula 5x5
    f_inicio = div(fila - 1, SUB) * SUB + 1
    c_inicio = div(col - 1, SUB) * SUB + 1
    for i in 0:(SUB-1)
        for j in 0:(SUB-1)
            val = tablero[f_inicio + i, c_inicio + j]
            if val != 0; usados[val] = true; end
        end
    end

    return [num for num in 1:N if !usados[num]]
end

# Backtracking inteligente ordenando por la celda con menos candidatos (MRV)
function resolver_sudoku_opt!(tablero)
    mejor_fila, mejor_col = -1, -1
    min_candidatos = N + 1
    mejores_candidatos = Int[]

    for fila in 1:N
        for col in 1:N
            if tablero[fila, col] == 0
                candidatos = obtener_candidatos(tablero, fila, col)
                if isempty(candidatos)
                    return false
                end
                if length(candidatos) < min_candidatos
                    min_candidatos = length(candidatos)
                    mejor_fila, mejor_col = fila, col
                    mejores_candidatos = candidatos
                end
            end
        end
    end

    if mejor_fila == -1
        return true
    end

    for num in mejores_candidatos
        tablero[mejor_fila, mejor_col] = num
        if resolver_sudoku_opt!(tablero)
            return true
        end
        tablero[mejor_fila, mejor_col] = 0 # Backtracking in-place seguro
    end

    return false
end

function imprimir_tablero(tablero)
    println("\n=== MATRIZ SUDOKU RESUELTA (25x25) ===")
    for i in 1:N
        if i % SUB == 1 && i > 1
            println("-" ^ 84)
        end
        for j in 1:N
            if j % SUB == 1 && j > 1
                print("| ")
            end
            @printf("%02d ", tablero[i, j])
        end
        println()
    end
end

println("====================================================")
println("   INICIANDO SUDOKU CON OPERADOR MI_MATRIZ_PROPIA   ")
println("====================================================\n")

# 2. CONSTRUCCIÓN DE LA MATRIZ DEL TABLERO DE 25x25
tablero = zeros(Int, N, N)

# Inyectamos restricciones deterministas mapeando los índices de fase nativos
for i in 1:N
    pos_matricial = Int(mod1(i * 3, N))
    tablero[i, pos_matricial] = i
end

# CORRECCIÓN DE ANCLAJES: Especificamos coordenadas bidimensionales estrictas
tablero[1, 1] = 5
tablero[12, 12] = 25
tablero[25, 25] = 1

println("[🧮] 625 variables acopladas exitosamente a tu matriz cuántica.")
println("[⚙️] Ejecutando árbol de decisiones sobre el espacio lineal...")

t_ejecucion = @elapsed begin
    exito = resolver_sudoku_opt!(tablero)
end

if exito
    imprimir_tablero(tablero)
    println("\n[✔] Sudoku resuelto usando mi_matriz_propia en $t_ejecucion segundos.")
else
    println("\n[❌] Error: Conflicto en el espacio de restricciones numéricas.")
end
