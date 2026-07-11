using LinearAlgebra
using Printf

println("="^65)
println("⚛️ RETO OFICIAL DE UTILIDAD CUÁNTICA DE IBM (MODELO TFIM)")
println("="^65)

# Matrices de Pauli fundamentales
const Sz = Float64[1.0 0.0; 0.0 -1.0]
const Sx = Float64[0.0 1.0; 1.0 0.0]
const Id = Float64[1.0 0.0; 0.0 1.0]

function construir_hamiltoniano(N::Int, J::Float64, g::Float64)
    dim = 2^N
    H = zeros(Float64, dim, dim)
    
    # 1. Interacción entre vecinos más cercanos (Entrelazamiento J * Sz_i * Sz_{i+1})
    for i in 1:(N-1)
        term = 1.0
        for j in 1:N
            if j == i || j == i + 1
                term = kron(term, Sz)
            else
                term = kron(term, Id)
            end
        end
        H += J * term
    end
    
    # 2. Campo transversal (Superposición g * Sx_i)
    for i in 1:N
        term = 1.0
        for j in 1:N
            if j == i
                term = kron(term, Sx)
            else
                term = kron(term, Id)
            end
        end
        H += g * term
    end
    return H
end

# === CONFIGURACIÓN DE ESCALA CUÁNTICA ===
# N es el número de cúbits (espines). IBM Eagle procesa N = 127 de forma nativa.
N_cubits = 12  
J_interaccion = 1.0
g_campo = 0.5

println("🔮 Simulando un sistema de $N_cubits cúbits entrelazados...")
println("📊 Dimensión de la matriz cuántica en memoria: $(2^N_cubits) x $(2^N_cubits)")

try
    t_inicio = time()
    
    print("⏳ Pasos cuánticos: Construyendo matriz del Hamiltoniano... ")
    H = construir_hamiltoniano(N_cubits, J_interaccion, g_campo)
    println("Hecho.")
    
    print("🔬 Pasos cuánticos: Calculando los autovalores de energía clásica... ")
    # Encontramos los niveles de energía cuántica reales mediante diagonalización exacta
    energias = eigen(H).values
    
    t_final = time()
    duracion = t_final - t_inicio
    
    println("Hecho.")
    println("\n🏆 ¡RESULTADO DE LA SIMULACIÓN COMPLETA!")
    @printf("🌌 Energía del estado fundamental (Ground State): %.6f\n", energias[1])
    @printf("⏱️ Tiempo de cómputo clásico: %.4f segundos\n", duracion)
    
catch e
    println("\n💥 EL SISTEMA EXPONENCIAL DEVASTÓ TU HARDWARE:")
    println(e)
end
println("="^65)
