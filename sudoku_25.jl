include("Hilbert/mi_matriz_propia.jl")
struct SudokuTableroVisual; titular::String; cedula::String; tag_global::String; dim::Int; sub_dim::Int; end
const MOTOR_VISUAL = SudokuTableroVisual("Marcos Alejandro Mora Abreu", "V-14915920", "ROYAL MATRIX", 25, 5)
function es_valido_25x25(tablero::Matrix{Int}, fila::Int, col::Int, num::Int)::Bool
    for i in 1:25; if tablero[fila, i] == num || tablero[i, col] == num return false; end; end
    ifil = fila - (fila - 1) % 5; icol = col - (col - 1) % 5
    for r in 0:4; for c in 0:4; if tablero[ifil + r, icol + c] == num return false; end; end; end; return true
end
function resolver_sudoku_mrv!(tablero::Matrix{Int})::Bool
    m_op = 26; mf = -1; mc = -1
    for r in 1:25; for c in 1:25; if tablero[r, c] == 0
        op = 0; for num in 1:25; if es_valido_25x25(tablero, r, c, num) op += 1; end; end
        if op < m_op; m_op = op; mf = r; mc = c; end
    end; end; end
    if mf == -1 return true; end
    for num in 1:25; if es_valido_25x25(tablero, mf, mc, num)
        tablero[mf, mc] = num; if resolver_sudoku_mrv!(tablero) return true; end; tablero[mf, mc] = 0
    end; end; return false
end
function imprimir_tablero_25x25(tablero::Matrix{Int})
    println("\n" * "-"^70)
    for r in 1:25; for c in 1:25; val = tablero[r, c]; print(val < 10 ? "  $val" : " $val"); if c % 5 == 0 && c < 25 print(" |"); end; end; println()
    if r % 5 == 0 && r < 25 println("-"^39 * "+" * "-"^30); end; end; println("-"^70 * "\n")
end
function ejecutar_juego_visual(config::SudokuTableroVisual)
    dv, Sc, Ss, tp, validado = Main.ejecutar_api_soberana(Main.REGISTRO_SABER)
    tb = zeros(Int, 25, 25); for i in 1:25; tb[i, i] = i; end
    tb[1, 2] = 6; tb[2, 1] = 7; tb[5, 10] = 12; tb[10, 5] = 18
    exito = resolver_sudoku_mrv!(tb)
    if exito; println("¡SUDOKU RESOLVED!"); imprimir_tablero_25x25(tb); end
    return exito && validado
end
ejecutar_juego_visual(MOTOR_VISUAL)
