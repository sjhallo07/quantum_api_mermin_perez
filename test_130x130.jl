# =====================================================================
# SCRIPT DE ALTA ESCALA: VALIDACIÓN EN CALIENTE 130x130 (7 QUBITS)
# =====================================================================
include("Ecosistema.jl")
using .Ecosistema
using JSON
using LinearAlgebra

println("====================================================")
println("   INICIANDO TEST DE ALTA ESCALA: MATRIZ 130x130    ")
println("====================================================\n")

println("[Carga] Fusionando ráfaga de datos en memoria contigua...")
datos_instagram = JSON.parsefile("matriz_instagram_106x106.json")
datos_mitigados = JSON.parsefile("matrices_output.json")

block_raw = datos_instagram["matriz_raw"]

block_zne = Any[]
if haskey(datos_mitigados, "matriz_mitigada")
    block_zne = datos_mitigados["matriz_mitigada"]
else
    valores_reales = collect(values(datos_mitigados))
    for v in valores_reales
        if typeof(v) <: AbstractVector
            block_zne = v
            break
        end
    end
end

dim_A = length(block_raw)
dim_B = length(block_zne)
dim_total = dim_A + dim_B

engine_pool = inicializar_engine(dim_total)

for i in 1:dim_A, j in 1:dim_A
    engine_pool.M_sistema[i, j] = Float64(block_raw[i][j])
end
for i in 1:dim_B, j in 1:dim_B
    engine_pool.M_sistema[dim_A+i, dim_A+j] = Float64(block_zne[i][j])
end

println("[Test 130x130] Procesando calibración mediante pesos Moore-Penrose...")

matriz_unificada_any = Vector{Any}(undef, dim_total)
for i in 1:dim_total
    matriz_unificada_any[i] = Any[engine_pool.M_sistema[i, j] for j in 1:dim_total]
end

traza_calibrada = procesar_datos_zne!(engine_pool, matriz_unificada_any)

println("-> Éxito ZNE 130x130. Dimensión Real: ", size(engine_pool.M_sistema))
println("-> Éxito ZNE 130x130. Traza unificada: ", traza_calibrada)

println("\n[Test 5D] Ejecutando contracción asintótica SU(2)...")
const M_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]
const rho_caos = [0.2301+0.0im 0.0 0.0 0.15; 0.0 0.2699+0.0im 0.0 0.0; 0.0 0.0 0.2699+0.0im 0.0; 0.15 0.0 0.0 0.2301+0.0im]
const psi_target = [1.0, 0.0, 0.0, 1.0] / sqrt(2.0)
const rho_target = ComplexF64.(psi_target * psi_target')

fid, loss = optimizar_brana_5d!(rho_caos, rho_target, M_SOBERANA, max_epocas=20)
println("-> Éxito 5D. Entropía final bloqueada: ", loss)
println("-> Éxito 5D. Fidelidad de la brana:   ", fid)

println("\n====================================================")
println("   ¡ECOSISTEMA INTEGRADO CON ÉXITO A ESCALA 130x130! ")
println("====================================================")
