
using LinearAlgebra
println("======================================================================")
println("   MOTOR QRE: CÁLCULO DE INTERACCIÓN MATERIA-RUIDO ENTRÓPICO         ")
println("======================================================================\n")
const epsilon = 0.1
psi = [1.0, 1.0, 1.0, 1.0] / 2.0
rho_pura = psi * psi'
Ruido_Entropico = [0.0 epsilon epsilon^2 epsilon^3; epsilon 0.0 epsilon epsilon^2; epsilon^2 epsilon 0.0 epsilon; epsilon^3 epsilon^2 epsilon 0.0]
rho_final = rho_pura + Ruido_Entropico
rho_final /= tr(rho_final)
valores_propios = eigvals(Hermitian(rho_final))
valores_propios = max.(valores_propios, 1e-15)
delta_S = -sum(p * log(p) for p in valores_propios)
println("🔮 Matriz de Estado Final Definida por la Materia (4x4):")
display(rho_final)
println("\n📊 Medición en la Interfaz (Measurement Sensors):")
println("-> Coherencia Inicial (Pura): Entropía S = 0.0")
println("-> Ruido Entrópico Inyectado (epsilon): ", epsilon)
println("-> Cálculo de Entropía Final (ΔS): ", round(delta_S, digits=6))
if delta_S > 0.0
    println("-> Estado del Sistema: DECOHERENCIA INDUCIDA - ESTADO FINAL FIJADO [✔]")
else
    println("-> Estado del Sistema: COHERENTE")
end
println("======================================================================")
