# =====================================================================
# SCRIPT DISTRIBUIDO: PROTOCOLO DE ENLACE CON MUESTREO MATRICIAL
# =====================================================================
include("Ecosistema.jl")
using .Ecosistema
using LinearAlgebra
using Distributions  # Integración de la librería de distribuciones matriciales
using Printf

println("====================================================")
println("   INICIANDO ENLACE CUÁNTICO CON MUESTREO (8D)     ")
println("====================================================\n")

# 1. Crear un estado entrelazado base GHZ de 3 Qubits (8 Dimensiones)
ghz_vector = zeros(ComplexF64, 8)
ghz_vector[1] = 1.0 / sqrt(2.0)  # Estado |000>
ghz_vector[8] = 1.0 / sqrt(2.0)  # Estado |111>
rho_red = ghz_vector * ghz_vector'

# 2. Generación de ruido denso estocástico usando una distribución matricial
println("[Distributions] Modelando fluctuación térmica del canal...")
dim_red = 8
grados_libertad = dim_red + 2

# Matriz identidad base para el muestreo Wishart
matriz_escala = real(I)
d_wishart = InverseWishart(grados_libertad, matriz_escala)

# Extraemos una matriz aleatoria real de la distribución y la llevamos al campo complejo
ruido_estocastico = ComplexF64.(rand(d_wishart))

# 3. Distribución con degradación estocástica en la red
println("[Distribución] Transmitiendo a través de ruido Wishart denso...")
rho_red_ruidosa = rho_red + 0.05 * ruido_estocastico
rho_red_ruidosa ./= tr(rho_red_ruidosa) # Garantizar Traza = 1.0

# 4. Aislamiento del enlace local Alice-Bob mediante Traza Parcial
println("\n[Aislamiento] Extrayendo sub-brana Alice-Bob local...")
rho_alice_bob = traza_parcial(rho_red_ruidosa, 4, 2, mantener=:A)
pureza_enlace = real(tr(rho_alice_bob * rho_alice_bob))

@printf("-> Dimensión del canal local: (%d, %d)\n", size(rho_alice_bob, 1), size(rho_alice_bob, 2))
@printf("-> Pureza real bajo fluctuación matricial: %.6f\n", pureza_enlace)

println("\n====================================================")
println("   ¡MUESTREO DISTRIBUIDO MATRICIAL CON ÉXITO!       ")
println("====================================================")
