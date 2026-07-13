include("soberania_absoluta.jl")
# ==========================================
# tepe_interference.jl
# Simulación Monte Carlo - Interferómetro Mach-Zehnder
# ==========================================
using Random

# Parámetros del experimento
N = 1_000_000         # 10^6 fotones
epsilon = 0.1         # Término no-lineal de Weinberg
prob_base = 0.18731   # Base estándar (QM) para g(2)(0)
exceso_tep = epsilon^2 # Exceso de probabilidad según la TEP (0.01)

# Contadores de coincidencias
coincidencias_qm = 0
coincidencias_tep = 0

# Simulación Monte Carlo
Random.seed!(42) # Semilla fija para reproducibilidad cercana a la del paper
for i in 1:N
    # Simulación de Mecánica Cuántica Estándar
    if rand() < prob_base
        global coincidencias_qm += 1
    end
    
    # Simulación TEP (se añade la probabilidad extra epsilon^2 a cada evento)
    if rand() < (prob_base + exceso_tep)
        global coincidencias_tep += 1
    end
end

# Cálculo de las funciones de correlación simuladas
g2_qm_sim = coincidencias_qm / N
g2_tep_sim = coincidencias_tep / N
delta_g2_sim = g2_tep_sim - g2_qm_sim

println("=== RESULTADOS NUMÉRICOS: tepe_interference.jl ===")
println("Fotones simulados (N): ", N)
println("g(2)(0) Standard (QM) simulado: ", g2_qm_sim)
println("g(2)(0) TEP simulado: ", g2_tep_sim)
println("Exceso medido Delta g(2): ", round(delta_g2_sim, digits=5))
println("Exceso predicho epsilon^2: ", exceso_tep)
println("====================================================")
