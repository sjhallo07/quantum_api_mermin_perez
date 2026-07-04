# =================================================================
# ENTORNO INTERACTIVO DE RESOLUCIÓN Y VALIDACIÓN QUANTUM SUDOKU
# =================================================================
using Random

symbols = ["-1", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", 
           "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]

soberana = [
  "-1" "0" "0" "0" "0";
   "0" "1" "0" "0" "0";
   "0" "0" "1" "0" "0";
   "0" "0" "0" "1" "0";
   "0" "0" "0" "0" "1"
]

solution_grid = fill(".", 25, 25)

# 1. Reconstrucción determinista del tejido espacial completo
for I in 0:4
    for J in 0:4
        block_type = (I + J) % 5 + 1
        if I == 2 && J == 2
            for i in 1:5, j in 1:5
                solution_grid[10+i, 10+j] = soberana[i, j]
            end
        else
            offset = (block_type - 1) * 5
            for i in 1:5, j in 1:5
                shift_idx = ((i - 1) * 2 + (j - 1) + I * 3 + J * 1) % 5 + 1
                r_coord = I * 5 + i
                c_coord = J * 5 + j
                if !(11 <= r_coord <= 15 && 11 <= c_coord <= 15)
                    solution_grid[r_coord, c_coord] = symbols[offset + shift_idx]
                end
            end
        end
    end
end

# 2. Generación del reto (Fijamos una semilla aleatoria para consistencia)
Random.seed!(42) 
challenge_grid = copy(solution_grid)
porcentaje_borrado = 0.80

for r in 1:25
    for c in 1:25
        if 11 <= r <= 15 && 11 <= c <= 15 continue end
        if rand() < porcentaje_borrado
            challenge_grid[r, c] = "."
        end
    end
end

function print_sudoku(matrix)
    for i in 1:25
        if i % 5 == 1 && i > 1 println("-" ^ 110) end
        for j in 1:25
            if j % 5 == 1 && j > 1 print("|  ") end
            print(rpad(matrix[i, j], 3))
        end
        println()
    end
end

# 3. Analizador de argumentos de ejecución en consola
modo = length(ARGS) > 0 ? lowercase(ARGS[1]) : "challenge"

if modo == "solve"
    println("=== SOLUCIÓN DE LA CONDICIÓN DE CONTORNO (SUDOKU RESUELTO) ===")
    print_sudoku(solution_grid)
elseif modo == "challenge"
    println("=== RETO SUDOKU GIGANTE 25x25 (DIFICULTAD: HARD) ===")
    println("Pistas iniciales: Matriz Soberana Central + 20% del tejido exterior disperso.\n")
    print_sudoku(challenge_grid)
else
    println("Parámetro inválido. Usa 'challenge' para ver el reto o 'solve' para la solución.")
end
