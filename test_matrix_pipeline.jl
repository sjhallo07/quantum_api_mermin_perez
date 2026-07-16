# =====================================================================
# SCRIPT DE CONTROL: VALIDACIÓN INTEGRAL DEL PIPELINE MATRICIAL
# =====================================================================
include("Ecosistema.jl")
include("api_algebraica.jl")

using .Ecosistema
using .ApiMatricial
using LinearAlgebra
using Distributions
using Printf

println("====================================================")
println("   EJECUTANDO CONTROL DE CALIDAD: PIPELINE MATRIX   ")
println("====================================================\n")

# 1. Inicialización de un espacio denso complejo de 4x4 (2 Qubits)
println("[Pipeline] Inicializando motor denso en memoria estática...")
engine = inicializar_engine([4])

# 2. Inyección de una matriz de prueba aleatoria con ruido Wishart
matriz_base = Matrix{Float64}(I, 4, 4)
d_wishart = InverseWishart(6, matriz_base)
ruido_complejo = ComplexF64.(rand(d_wishart))

# Convertimos la matriz del muestreo en un vector compatible para la API
matriz_any = Vector{Any}(undef, 4)
for i in 1:4
    matriz_any[i] = Any[ruido_complejo[i, j] for j in 1:4]
end

# 3. Procesamiento y normalización estricta mediante el motor cuántico
traza_física = procesar_datos_zne!(engine, matriz_any)
println("-> Éxito. Traza normalizada del motor: ", traza_física)

# 4. Evaluación de la coherencia física real mediante la API Matricial
pureza = proyectar_sistema_algebraico!(engine)

# 5. Cálculo matricial avanzado: Entropía de Von Neumann S = -Tr(rho * log(rho))
println("\n[Métrica] Evaluando pérdida de información cuántica (Von Neumann)...")
autovalores = eigen(Hermitian(engine.M_sistema)).values

# Filtro numérico in-place para evitar logaritmos de cero (estabilidad asintótica)
entropia = 0.0
for λ in autovalores
    if λ > 1e-12
        global entropia -= λ * log2(λ)
    end
end

@printf("-> Entropía cuántica calculada: %.6f bits\n", entropia)

if pureza <= 1.0 && entropia >= 0.0
    println("\n[Resultado] ¡ENTORNO COMPLEMENTE MATRICIAL VERIFICADO CON ÉXITO!")
else
    println("\n[Resultado] Alerta: Anomalía en los límites del espacio de Hilbert.")
end
println("====================================================")
