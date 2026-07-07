# ======================================================================
#   RESOLVEDOR OPTIMIZADO DE SUDOKU GIGANTE (25x25) EN JULIA
# ======================================================================
using Printf
using Random

const N = 25
const SUB = 5

# Estructura para almacenar candidatos por celda (Poda lógica)
function obtener_candidatos(tablero, fila, col)
    if tablero[fila, col] != 0
        return Int[]
    end
    
    usados = zeros(Bool, N)
    
    # 1. Chequear Fila y Columna
    for i in 1:N
        if tablero[fila, i] != 0; usados[tablero[fila, i]] = true; end
        if tablero[i, col] != 0; usados[tablero[i, col]] = true; end
    end
    
    # 2. Chequear Subcuadrícula 5x5
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

# Backtracking inteligente ordenando por la celda con menos candidatos (MRV - Minimum Remaining Values)
function resolver_sudoku_opt!(tablero)
    mejor_fila, mejor_col = -1, -1
    min_candidatos = N + 1
    mejores_candidatos = Int[]
    
    # Encontrar la celda más restringida para podar el árbol de búsqueda
    for fila in 1:N
        for col in 1:N
            if tablero[fila, col] == 0
                candidatos = obtener_candidatos(tablero, fila, col)
                if isempty(candidatos)
                    return false # Callejón sin salida
                end
                if length(candidatos) < min_candidatos
                    min_candidatos = length(candidatos)
                    mejor_fila, mejor_col = fila, col
                    mejores_candidatos = candidatos
                end
            end
        end
    end
    
    # Si no hay celdas vacías, el Sudoku está resuelto
    if mejor_fila == -1
        return true
    end
    
    # Probar candidatos ordenados
    for num in mejores_candidatos
        tablero[mejor_fila, mejor_col] = num
        if resolver_sudoku_opt!(tablero)
            return true
        end
        tablero[mejor_fila, mejor_col] = 0 # Backtracking
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

# Inicializar matriz e inyectar pistas aleatorias controladas (consistentes)
Random.seed!(1234)
tablero = zeros(Int, N, N)

# Añadir unas cuantas pistas consistentes para arrancar la simulación
tablero[1, 1] = 5
tablero[12, 12] = 25
tablero[25, 25] = 1

println("[🧮] Espacio cuántico/matriz linealizado para N=25 (625 variables).")
println("[⚙️] Procesando restricciones del árbol de decisiones...")

t_ejecucion = @elapsed begin
    exito = resolver_sudoku_opt!(tablero)
end

if exito
    imprimir_tablero(tablero)
    println("\n[✔] Sudoku 25x25 resuelto de manera óptima en $t_ejecucion segundos.")
else
    println("\n[❌] Error: Conflicto en el espacio de restricciones numéricas.")
end
