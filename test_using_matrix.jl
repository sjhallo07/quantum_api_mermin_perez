# =====================================================================
# SCRIPT DE CONTROL TOTAL: UPGRADE COMPLETO CON "USING MATRIX"
# PARCHE: Estabilización de la Distribución Matricial Estocástica.
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
mutable struct MotorBypass
    M_sistema::Matrix{ComplexF64}
end

println("[Bypass] Estructurando contenedor nativo M_sistema de $(dim_total)x$(dim_total)...")
M_estatica = zeros(ComplexF64, dim_total, dim_total)

for i in 1:dim_total
    for j in 1:dim_total
        if i <= dim_A && j <= dim_A
            M_estatica[i, j] = ComplexF64(block_raw[i][j])
        elseif i > dim_A && j > dim_A
            M_estatica[i, j] = ComplexF64(block_zne[i - dim_A][j - dim_A])
        else
            M_estatica[i, j] = 0.0 + 0.0im
        end
    end
end

engine_pool = MotorBypass(M_estatica / tr(M_estatica))
traza_calibrada = tr(engine_pool.M_sistema)
println("-> Éxito Motor. Traza física del espacio de Hilbert: ", traza_calibrada)

# 3. INYECCIÓN DE RUIDO MULTIVARIADO CONTINUO (DISTRIBUCIÓN DE WISHART ESTABLE)
println("\n[Distributions] Modelando fluctuaciones asimétricas sobre 130x130...")
matriz_identidad = Matrix{Float64}(I, dim_total, dim_total)

# Usamos la distribución de Wishart (Grados de libertad > dimensión) para asegurar estabilidad cuántica
grados_libertad = dim_total + 2 # 132
dist_wishart = Wishart(grados_libertad, matriz_identidad / grados_libertad)
ruido_asimetrico = ComplexF64.(rand(dist_wishart))

# Acoplamos el ruido estocástico de forma controlada (5% de perturbación)
engine_pool.M_sistema .= 0.95 .* engine_pool.M_sistema .+ 0.05 .* ruido_asimetrico
engine_pool.M_sistema ./= tr(engine_pool.M_sistema) # Re-normalización de seguridad

# 4. EXTRACCIÓN DE PROPIEDADES MEDIANTE LA API MATRICIAL
pureza = proyectar_sistema_algebraico!(engine_pool)

# 5. CÁLCULO DE ENTROPÍA DE VON NEUMANN A GRAN ESCALA
println("\n[Métrica] Evaluando entropía de Von Neumann (Pérdida de bits cuánticos)...")
autovalores = eigen(engine_pool.M_sistema).values

entropia = 0.0
for λ in autovalores
    magnitud_λ = abs(λ)
    if magnitud_λ > 1e-12  # Filtro de estabilidad asintótica para evitar singularidades
        global entropia -= magnitud_λ * log2(magnitud_λ)
    end
end

@printf("-> Entropía cuántica total a escala 130x130: %.6f bits\n", entropia)

println("\n====================================================")
println("   ¡VALIDACIÓN DE ENFOQUE MATRICIAL FINALIZADA!     ")
println("====================================================")
