# =====================================================================
# SCRIPT DE CONTROL TOTAL: UPGRADE COMPLETO CON "USING MATRIX"
# =====================================================================
include("Ecosistema.jl")
include("api_algebraica.jl")

using .Ecosistema
using .ApiMatricial
using LinearAlgebra
using Distributions
using JSON
using Printf

println("====================================================")
println("   INICIANDO TEST GLOBAL: ENFOQUE MATRIX PURA       ")
println("====================================================\n")

# 1. CARGA DE BLOQUES EXPERIMENTALES DESDE EL REPOSITORIO
println("[Carga] Extrayendo ráfagas de datos en bloques...")
datos_instagram = JSON.parsefile("matriz_instagram_106x106.json")
datos_mitigados = JSON.parsefile("matrices_output.json")

block_raw = datos_instagram["matriz_raw"]
global block_zne = Any[]
if haskey(datos_mitigados, "matriz_mitigada_clean")
    global block_zne = datos_mitigados["matriz_mitigada_clean"]
else
    valores_reales = collect(values(datos_mitigados))
    for v in valores_reales
        if typeof(v) <: AbstractVector
            global block_zne = v
            break
        end
    end
end

dim_A = length(block_raw)
dim_B = length(block_zne)
dim_total = dim_A + dim_B # 130 exactos

# 2. INSTANCIACIÓN MATRICIAL COMPLEJA EN MEMORIA ESTÁTICA
engine_pool = inicializar_engine([dim_total])

# Construcción de la matriz unificada densa
matriz_unificada_any = Vector{Any}(undef, dim_total)
for i in 1:dim_total
    fila = Vector{Any}(undef, dim_total)
    for j in 1:dim_total
        if i <= dim_A && j <= dim_A
            fila[j] = ComplexF64(block_raw[i][j])
        elseif i > dim_A && j > dim_A
            fila[j] = ComplexF64(block_zne[i - dim_A][j - dim_A])
        else
            fila[j] = 0.0 + 0.0im
        end
    end
    matriz_unificada_any[i] = fila
end

# 3. NORMALIZACIÓN CUÁNTICA IN-PLACE
traza_calibrada = procesar_datos_zne!(engine_pool, matriz_unificada_any)
println("-> Éxito Motor. Traza física del espacio de Hilbert: ", traza_calibrada)

# 4. INYECCIÓN DE RUIDO MULTIVARIADO CONTINUO (DISTRIBUCIÓN MATRICIAL)
println("\n[Distributions] Modelando fluctuaciones asimétricas sobre 130x130...")
# Usamos una distribución MatrixBeta para simular el comportamiento de un disipador cuántico
matriz_identidad = Matrix{Float64}(I, dim_total, dim_total)
dist_beta = MatrixBeta(dim_total, 5.0, 5.0)
ruido_asimetrico = ComplexF64.(rand(dist_beta))

# Acoplamos el ruido estocástico de forma controlada (5% de perturbación)
engine_pool.M_sistema .= 0.95 .* engine_pool.M_sistema .+ 0.05 .* ruido_asimetrico
engine_pool.M_sistema ./= tr(engine_pool.M_sistema) # Re-normalización de seguridad

# 5. EXTRACCIÓN DE PROPIEDADES MEDIANTE LA API MATRICIAL
pureza = proyectar_sistema_algebraico!(engine_pool)

# 6. CÁLCULO DE ENTROPÍA DE VON NEUMANN A GRAN ESCALA
println("\n[Métrica] Evaluando entropía de Von Neumann (Pérdida de bits cuánticos)...")
autovalores = eigen(Hermitian(engine_pool.M_sistema)).values

entropia = 0.0
for λ in autovalores
    if λ > 1e-12  # Filtro de estabilidad asintótica para evitar singularidades
        global entropia -= λ * log2(λ)
    end
end

@printf("-> Entropía cuántica total a escala 130x130: %.6f bits\n", entropia)

println("\n====================================================")
println("   ¡VALIDACIÓN DE ENFOQUE MATRICIAL FINALIZADA!     ")
println("====================================================")
