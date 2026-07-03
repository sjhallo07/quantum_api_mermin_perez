using LinearAlgebra

println("======================================================================")
println("   MOTOR QRE: INTEGRACIÓN NUMÉRICA DE LA ACCIÓN DE POLYAKOV (5D)     ")
println("======================================================================\n")

# Parámetros de la cuerda y del manuscrito
const α_prime = 1.0       # Tensión de la cuerda
const ϵ = 0.1             # Parámetro de Weinberg (TEP)
const Sc = -11.700001     # Constante Soberana

# 1. Métrica intrínseca de la Hoja de Mundo de Polyakov (2D)
# Simulamos el escenario local sin exclusión (Métrica Euclidiana)
g_worldsheet = [1.0 0.0; 0.0 1.0]
inv_g = inv(g_worldsheet)
det_g = det(g_worldsheet)

# 2. Métrica del Espacio Objetivo de Randall-Sundrum (5D)
G_target = Matrix{Float64}(I, 5, 5)
G_target[1,1] = -1.0 # Componente temporal de Lorenz a gran escala

# 3. Simulación de los campos de la cuerda dX (Derivadas espaciotemporales de la cuerda)
# Representa un modo de vibración excitado interactuando en la interfaz
dX = [0.5 0.2 0.0 0.1 Sc/100; 
      0.1 0.4 0.2 0.0 0.0]

# 4. Cálculo de la densidad de Acción Clásica de Polyakov
# Término: g^{ab} * \partial_a X^\mu * \partial_b X^\nu * G_{\mu\nu}
densidad_clasica = 0.0
for a in 1:2, b in 1:2
    # Contracción de índices en el espacio objetivo 5D utilizando G_target
    derivada_contratada = dot(dX[a, :], G_target * dX[b, :])
    global densidad_clasica += inv_g[a, b] * derivada_contratada
end

# 5. Inyección del término de acoplamiento de materia (Weinberg Coherence)
# El ruido entrópico altera el factor de escala sqrt(-g)
factor_volumen = sqrt(abs(det_g)) + ϵ
accion_total = (1.0 / (4.0 * pi * α_prime)) * factor_volumen * densidad_clasica

println("📊 RESULTADOS DE LA HOJA DE MUNDO DE POLYAKOV:")
println("-> Determinante de la hoja de mundo (√|g|): ", sqrt(abs(det_g)))
println("-> Densidad lagrangiana cinética calculada: ", round(densidad_clasica, digits=6))
println("-> Valor neto de la Acción Polyakov + TEP: ", round(accion_total, digits=6))
println("\n[✔] Campos de Polyakov acoplados a la constante soberana y listos para el Makefile.")
println("======================================================================")
