using LinearAlgebra
using Distributions
using Printf

# Enlazamos las matrices e infraestructura sellada inmutable
include("soberania_absoluta.jl")

println("\n=====================================================")
println("🔬 AUDITORÍA RADICAL: OBSERVANDO EL RUIDO DEL ENTORNO")
println("=====================================================")

"""
Calcula la Entropía de Von Neumann: S = -Tr(rho * log(rho))
Mide cuánta sintonía cuántica se ha perdido y transformado en ruido clásico.
"""
function calcular_entropia_von_neumann(rho::Matrix{Float64})
    # CORRECCIÓN: 'eigvals' es el método nativo correcto de LinearAlgebra en Julia
    evals = eigvals(Hermitian(rho))
    
    entropia = 0.0
    for λ in evals
        # Regularizamos para evitar el log(0) si hay estados puros o valores límite
        if λ > 1e-12
            entropia -= λ * log(λ)
        end
    end
    return entropia
end

"""
Calcula la Pureza del Estado: P = Tr(rho^2)
P = 1.0 -> Estado Cuántico Puro (Sintonía Total, Cero Ruido)
P = 0.125 -> Estado Máximamente Mezclado (Ruido Blanco Absoluto en 8D)
"""
function calcular_pureza(rho::Matrix{Float64})
    return real(tr(rho^2))
end

# --- INICIO DEL MONITOREO EN TIEMPO REAL ---
println("Muestreando 10 estados instantáneos de la fluctuación Wishart de fondo...")
println("Analizando la degradación de la fase en el Espacio de Hilbert 8D...\n")

println("Muestra # |   Pureza (Tr(ρ²))   | Entropía Von Neumann |  Fluctuación Traza")
println("--------------------------------------------------------------------------")

for i in 1:10
    # Obtenemos la matriz estocástica real devuelta por Distributions.jl
    rho_ruido = SoberaniaCuantica.muestrear_matriz_real()
    
    pureza = calcular_pureza(rho_ruido)
    entropia = calcular_entropia_von_neumann(rho_ruido)
    check_traza = real(tr(rho_ruido))
    
    @printf("   [%02d]   |       %.6f      |       %.6f       |      %.6f\n", 
            i, pureza, entropia, check_traza)
end

println("--------------------------------------------------------------------------")
println("⚠️ ANÁLISIS GEOMÉTRICO (Cuerdas/Frontera):")
println("Si la entropía es mayor a 0, la cuerda holográfica se ha desconectado")
println("de la frontera cuántica y está interactuando con el ruido térmico del interior.")
println("=====================================================\n")
