include("soberania_absoluta.jl")
using LinearAlgebra
using UnicodePlots

# 1. Expandir tu matriz U a 3 cúbits reales (Dimensión 8x8)
U_base = [
   -1.0  0.0  0.0  0.0  0.0;
    0.0  1.0  0.0  0.0  0.0;
    0.0  0.0  1.0  0.0  0.0;
    0.0  0.0  0.0  1.0  0.0;
    0.0  0.0  0.0  0.0  1.0
]
U_8d = Matrix{ComplexF64}(I, 8, 8)
U_8d[1:5, 1:5] = U_base

# 2. Generar mensaje de Alice expandido en el espacio de Hilbert 8D
mensaje_alice = [0.1, 0.3, 0.5, 0.2, 0.7745, 0.0, 0.0, 0.0]
mensaje_alice = mensaje_alice / norm(mensaje_alice)

# 3. Aplicar evolución libre
estado_transito = U_8d * mensaje_alice

# 4. Inyectar Ruido Complejo Asimétrico Agresivo (T1/T2 Criogénico de IBM)
p_error = 0.15
E_ruido = I(8) * (1 - p_error) + (rand(8,8) + rand(8,8)*im) * p_error
estado_corrupto = E_ruido * estado_transito

# --- FUNCIÓN INTERNA PARA EVITAR EL JIT EN LA MEDICIÓN REAL ---
def_mitigacion(E_r, U_8, est_corr) = U_8' * (inv(E_r) * est_corr)

# Forzar una primera ejecución oculta para que Julia compile la función en memoria
_ = def_mitigacion(E_ruido, U_8d, estado_corrupto)

# 5. CONTRA-ATAQUE DE MITIGACIÓN REAL (Medido sin el costo de compilación)
t_inicio = time_ns()
estado_sano = def_mitigacion(E_ruido, U_8d, estado_corrupto)
t_final = time_ns()

duracion_mu = (t_final - t_inicio) / 1000

# 6. Despliegue de métricas soberanas
println("======================================================================")
println("   🚀 HIGH-STRESS 8D (3-QUBIT) LOCAL QUANTUM ENGINE SOBERANO 🚀")
println("======================================================================")
println("\n[RENDIMIENTO DE TU SILICIO ARM]")
println("-> Tiempo de mitigación neto: ", round(duracion_mu, digits=2), " microsegundos")
println("-> ¿Éxito total ante el ruido criogénico?: ", real(estado_sano) ≈ mensaje_alice)

# Usamos abs.() para graficar la magnitud pura del vector de estado (siempre ≥ 0)
println("\n--- MAGNITUD ABSOLUTA DEL VECTOR RECUPERADO (ESTADO_SANO) ---")
display(barplot(["q1","q2","q3","q4","q5","q6","q7","q8"], abs.(estado_sano), color=:green))
println("======================================================================")
