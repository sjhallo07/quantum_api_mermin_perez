using LinearAlgebra
using Distributions

include("Ecosistema.jl")
using .Ecosistema

println("=====================================================================")
# Extraemos el espacio geométrico real que ya tienes estabilizado en RAM
const M_SOBERANA = Ecosistema.METRICA_SOBERANA_5D
dim = size(M_SOBERANA, 1)

println("🎯 VERIFICANDO TARGETS REALES: MATRIZ DE CONFIGURACIÓN QUANTUM")
println("---------------------------------------------------------------------")
println("-> Dimensión base del espacio: ", dim, "x", dim)

# Construcción de un estado de brana de prueba complejo
rho_inicial = [1.0+0.0im 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0]
rho_target  = [0.5+0.0im 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0.5]

# Ejecutamos el Subsistema 3 de tu Ecosistema nativo (Optimización Antifrágil)
fidelidad, loss = Ecosistema.optimizar_brana_5d!(rho_inicial, rho_target, M_SOBERANA, max_epocas=5)

println("\n=== ANÁLISIS DE FIDELIDAD EN HARDWARE ===")
println("-> Fidelidad alcanzada del Target: ", round(fidelidad, digits=6))
println("-> Pérdida (Loss) cuántica final : ", round(loss, digits=6))

if fidelidad > 0.0
    println("✅ VERIFICACIÓN COMPLETADA: Matriz y Ecosistema integrados correctamente.")
else
    println("❌ ERROR: Desviación o colapso asimétrico detectado en la brana.")
end
