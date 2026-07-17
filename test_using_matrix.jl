# =====================================================================
# SCRIPT DE CONTROL TOTAL: UPGRADE COMPLETO CON "USING MATRIX"
# PARCHE: Estabilización de la Distribución Matricial Estocástica.
# =====================================================================
include("Ecosistema.jl")
include("api_algebraica.jl")

using .Ecosistema
using .ApiMatricial
using Distributions
using JSON
using Printf

# ALGORITMO QR NATIVO POR ROTACIONES DE GIVENS (LIBRE DE LINEARALGEBRA)
function diagonalizar_qr_nativo(A::Matrix{ComplexF64}; max_iter=80, tol=1e-10)
    n = size(A, 1)
    T = copy(A)
    for iter in 1:max_iter
        for i in 1:(n-1)
            for j in (i+1):n
                if abs(T[j, i]) > tol
                    r = hypot(abs(T[i, i]), abs(T[j, i]))
                    c = T[i, i] / r
                    s = T[j, i] / r
                    for k in i:n
                        tau1 = T[i, k]
                        tau2 = T[j, k]
                        T[i, k] = c * tau1 + s * tau2
                        T[j, k] = -conj(s) * tau1 + conj(c) * tau2
                    end
                    for k in 1:min(j+1, n)
                        tau1 = T[k, i]
                        tau2 = T[k, j]
                        T[k, i] = conj(c) * tau1 + conj(s) * tau2
                        T[k, j] = -s * tau1 + c * tau2
                    end
                end
            end
        end
        sub_sum = sum(abs(T[k+1, k]) for k in 1:(n-1))
        if sub_sum < tol break end
    end
    return [real(T[i, i]) for i in 1:n]
end

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
dim_total = dim_A + dim_B

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

traza_inicial = sum(M_estatica[i, i] for i in 1:dim_total)
engine_pool = MotorBypass(M_estatica / traza_inicial)

traza_calibrada = sum(engine_pool.M_sistema[i, i] for i in 1:dim_total)
println("-> Éxito Motor. Traza física del espacio de Hilbert: ", traza_calibrada)

# 3. INYECCIÓN DE RUIDO MULTIVARIADO CONTINUO (DISTRIBUCIÓN DE WISHART ESTABLE)
println("\n[Distributions] Modelando fluctuaciones asimétricas sobre 130x130...")
matriz_identidad = zeros(Float64, dim_total, dim_total)
for i in 1:dim_total
    matriz_identidad[i, i] = 1.0
end

grados_libertad = dim_total + 2
dist_wishart = Wishart(grados_libertad, matriz_identidad / grados_libertad)
ruido_asimetrico = ComplexF64.(rand(dist_wishart))

engine_pool.M_sistema .= 0.95 .* engine_pool.M_sistema .+ 0.05 .* ruido_asimetrico
traza_ruido = sum(engine_pool.M_sistema[i, i] for i in 1:dim_total)
engine_pool.M_sistema ./= traza_ruido

# 4. EXTRACCIÓN DE PROPIEDADES MEDIANTE LA API MATRICIAL (ÁMBITO CALIFICADO)
pureza = ApiMatricial.proyectar_sistema_algebraico!(engine_pool)

# 5. CÁLCULO DE ENTROPÍA DE VON NEUMANN A GRAN ESCALA
println("\n[Métrica] Evaluando entropía de Von Neumann (Pérdida de bits cuánticos)...")

M_normalizada = copy(engine_pool.M_sistema)
traza_real = sum(real(M_normalizada[i, i]) for i in 1:size(M_normalizada, 1))
if abs(traza_real) > 1e-12
    M_normalizada ./= traza_real
end

autovalores_estables = diagonalizar_qr_nativo(M_normalizada)

entropia = 0.0
for λ in autovalores_estables
    if 1e-10 < λ <= 1.0
        global entropia -= λ * log2(λ)
    end
end

println("====================================================")
@printf("-> Entropía cuántica corregida (0 a log2(130)): %.6f bits\n", entropia)
println("====================================================")
