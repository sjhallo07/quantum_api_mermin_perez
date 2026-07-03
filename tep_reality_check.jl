# ==============================================================================
# tep_reality_check.jl
# VALIDADOR: Comparativa entre Física Estándar vs. Teoría TEP
# ==============================================================================
using LinearAlgebra

println("========================================================================")
println("🔬 VALIDANDO LA BRECHA: Física Estándar (QM) vs. Teoría TEP")
println("========================================================================")

# Estado inicial: Singlete (Entrelazamiento máximo)
psi = [0.0, 1/sqrt(2), -1/sqrt(2), 0.0]

# Operadores de medición (Spin Z en el Qubit B)
# La física cuántica real prohíbe que medir A afecte a B instantáneamente.
sigma_z_B = [1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 -1]
valor_base = psi' * sigma_z_B * psi

# 1. UNIVERSO ESTÁNDAR (Física real)
# Aplicamos una rotación unitaria (física válida)
U_rotacion = [cos(0.5) -sin(0.5); sin(0.5) cos(0.5)]
psi_qm = kron(U_rotacion, I(2)) * psi
valor_qm = psi_qm' * sigma_z_B * psi_qm

# 2. UNIVERSO TEP (Simulación de Marcos Mora)
# Aplicamos el ataque no unitario (Weinberg term) + Renormalización
decay = 0.5 
psi_tep = [0.0, decay/sqrt(2), -1/sqrt(2), 0.0]
psi_tep = psi_tep / norm(psi_tep) # ¡Aquí es donde ocurre la magia!
valor_tep = psi_tep' * sigma_z_B * psi_tep

println("Valor Base (Entrelazamiento inicial): ", round(valor_base, digits=4))
println("Resultado Física Estándar (QM):        ", round(valor_qm, digits=4), " (Sin señal)")
println("Resultado TEP (Simulación):            ", round(valor_tep, digits=4), " (¡Señal detectada!)")
println("------------------------------------------------------------------------")

delta = abs(valor_tep - valor_qm)
println("Δ Diferencial de Realidad: ", round(delta, digits=4))

if delta > 0.01
    println("✅ VALIDACIÓN DE LA BRECHA: La simulación es consistente con TEP.")
    println("⚠️  OBSERVACIÓN: La 'señal' existe solo porque forzamos la renormalización.")
else
    println("❌ VALIDACIÓN: No hay diferencia. La física estándar se mantiene.")
end
println("========================================================================")
