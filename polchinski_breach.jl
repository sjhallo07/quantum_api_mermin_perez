# ==========================================
# polchinski_breach.jl
# Simulador de la Brecha de Polchinski (Ataque No Unitario)
# ==========================================
using LinearAlgebra

println("======================================")
println("      ⚠️ BREACHING POLCHINSKI'S WALL ⚠️     ")
println("      (NON-UNITARY AMPLITUDE CHANGE)   ")
println("======================================")

# 1. ESTADO INICIAL
# Base computacional de 2 Qubits: |00>, |01>, |10>, |11>
# Estado Singlete Puro (Máximo Entrelazamiento): 1/sqrt(2) * |01> - 1/sqrt(2) * |10>
psi_initial = [0.0, 1/sqrt(2), -1/sqrt(2), 0.0]
norm_initial = norm(psi_initial)

# Operador observable sigma_z aplicado solo al Qubit B (I ⊗ σz)
# Mide el spin a lo largo del eje Z.
sigma_z_B = [1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 -1]

# Cálculo del valor esperado inicial <σz> en el Qubit B
exp_z_initial = psi_initial' * sigma_z_B * psi_initial

println("Initial State Norm: ", round(norm_initial, digits=1))
println("<σz> B (Initial): ", round(exp_z_initial, digits=1))
println("--------------------------------------")

# 2. EL ATAQUE NO UNITARIO
println("Applying local NON-UNITARY attack on Qubit A...")
# Simulamos el "hackeo" del software: Aplicamos un factor de decaimiento (0.5 al cuadrado) 
# sobre el estado en el que el Qubit A es 0, reduciendo su amplitud sin colapsar el sistema.
decay_factor = sqrt(0.5) 
psi_attacked = [0.0, decay_factor/sqrt(2), -1/sqrt(2), 0.0]

# Calculamos la nueva norma (la cual ya no es 1.0 porque violamos la mecánica cuántica estándar)
norm_attacked = norm(psi_attacked)
println("Attacked State Norm (Causal chain still holding): ", round(norm_attacked, digits=6))

# 3. RENORMALIZACIÓN GLOBAL
println("Forcing GLOBAL Renormalization (Breaking Polchinski's Wall)...")
# El sistema computacional corrige la probabilidad para que vuelva a sumar 100%
psi_final = psi_attacked / norm_attacked
norm_final = norm(psi_final)

# Cálculo del nuevo valor esperado en el Qubit B tras la renormalización forzada
exp_z_final = psi_final' * sigma_z_B * psi_final

println("Final State Norm (Causal chain broken): ", round(norm_final, digits=1))
println("<σz> B (After Attack + Reno): ", round(exp_z_final, digits=6))
println("--------------------------------------")

# 4. CÁLCULO DEL DELTA SUPERLUMÍNICO
delta = abs(exp_z_final - exp_z_initial)
println("Δ = |<σz>_1 - <σz>_0| = ", round(delta, digits=6))
println("======================================")
println("🚨 ALERTA: EL TELÉFONO DE EVERETT FUNCIONA 🚨")
println("Simulación de transmisión cuántica superlumínica completada.")
