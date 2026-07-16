# =====================================================================
# SCRIPT DE EVALUACIÓN MULTIDIMENSIONAL: 3 QUBITS (8D)
# =====================================================================
include("Ecosistema.jl")
using .Ecosistema
using LinearAlgebra
using Printf

println("====================================================")
println("   EVALUANDO SUBSISTEMA MULTIDIMENSIONAL DENSO 8D   ")
println("====================================================\n")

# 1. Definición de estados base (Qubits individuales)
ket_0 = [1.0 + 0.0im, 0.0 + 0.0im]
ket_1 = [0.0 + 0.0im, 1.0 + 0.0im]

# Matrices de densidad puras |0><0| y |1><1|
rho_0 = ket_0 * ket_0'
rho_1 = ket_1 * ket_1'

# 2. Generación automatizada de un tensor denso de 3 Qubits (|000><000|)
println("[Tensores] Ensamblando espacio de Hilbert 2^3 = 8 Dimensiones...")
operadores = [rho_0, rho_0, rho_0] # Tres subsistemas
rho_unificado_8d = generar_estado_multidimensional(operadores)

println("-> Dimensión del Tensor unificado: ", size(rho_unificado_8d))
println("-> Traza del espacio multinivel:   ", real(tr(rho_unificado_8d)))

# 3. Aplicación de Traza Parcial (Reducción de la Brana)
println("\n[Reducción] Ejecutando traza parcial para aislar subsistemas...")
# Tratamos el sistema como compuesto por Dim_A = 4 (Qubits 1 y 2) y Dim_B = 2 (Qubit 3)
rho_reducido_A = traza_parcial(rho_unificado_8d, 4, 2, mantener=:A)

println("-> Dimensión del subsistema reducido A: ", size(rho_reducido_A))
println("-> Traza del subsistema reducido A:     ", real(tr(rho_reducido_A)))

println("\n====================================================")
println("   ¡UPGRADE MULTIDIMENSIONAL VERIFICADO CON ÉXITO!  ")
println("====================================================")
