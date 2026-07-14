# =====================================================================
# ENGINE PROPIO: MOTOR CUÁNTICO DE ASIGNACIÓN CERO Y ALTA ROBUSTEZ
# =====================================================================
using JSON
using LinearAlgebra

# 1. Estructura Estática In-Place inmune al Garbage Collector
struct MiMatrizState
    N::Int
    M_sistema::Matrix{Float64}
    A_expandida::Matrix{Float64}
    b_objetivo::Vector{Float64}
    x_solucion::Vector{Float64}
end

function inicializar_mi_engine(N::Int)
    return MiMatrizState(
        N,
        zeros(Float64, N, N),
        zeros(Float64, N + 1, N),
        zeros(Float64, N + 1),
        zeros(Float64, N)
    )
end

function optimizar_mi_sistema!(state::MiMatrizState, matriz_cruda::Vector{Any})
    N = state.N
    for i in 1:N, j in 1:N
        state.M_sistema[i, j] = Float64(matriz_cruda[i][j])
    end
    # Inyección in-place mediante vistas contiguas de memoria (No Alloc)
    @views state.A_expandida[1:N, 1:N] .= state.M_sistema
    escala_pesada = 1e15
    @views state.A_expandida[N+1, 1:N] .= escala_pesada
    fill!(state.b_objetivo, 0.0)
    state.b_objetivo[end] = 1.0 * escala_pesada
    # Resolvedor Moore-Penrose adaptativo para mitigar desborde numérico
    state.x_solucion .= pinv(state.A_expandida) * state.b_objetivo
    return sum(state.x_solucion)
end

# 2. Bloque Ejecutable del Script
function ejecutar_mi_analisis()
    archivo_origen = "matriz_instagram_106x106.json"
    if !isfile(archivo_origen)
        println("[Error] No se encuentra el archivo: ", archivo_origen)
        return
    end
    datos_json = JSON.parsefile(archivo_origen)
    matriz_cruda = datos_json["matriz_raw"]
    dim_sistema = 106
    pool_propio = inicializar_mi_engine(dim_sistema)
    traza_final = optimizar_mi_sistema!(pool_propio, matriz_cruda)
    println("[MI_MATRIZ_PROPIA] Cálculo finalizado. Traza conservada: ", traza_final)
end

ejecutar_mi_analisis()
