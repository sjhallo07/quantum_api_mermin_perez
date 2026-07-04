using Printf
using LinearAlgebra

# 1. Definimos la matriz original del script
M = [
  0.25   0.35  0.26  0.251;
  0.35   0.25  0.35  0.26 ;
  0.26   0.35  0.25  0.35 ;
  0.251  0.26  0.35  0.25
]

println("======================================================================")
println("   MOTOR QRE: RENORMALIZACION ESTRICTA DE LA MATRIZ DE DENSIDAD")
println("======================================================================")

traza_inicial = tr(M)
@printf("-> Traza Inicial Detectada: %.4f (Estado Divergente)\n", traza_inicial)

# 2. Forzamos la normalización física (Dividir cada elemento por la traza)
M_real = M / traza_inicial

traza_final = tr(M_real)
@printf("-> Traza Final Forzada (∑ Probabilidades): %.4f (Estado Fisico Real)\n", traza_final)

println("\n🔮 Matriz de Densidad Cuántica Renormalizada (4x4):")
for i in 1:4
    println(@sprintf("[ %.4f  %.4f  %.4f  %.4f ]", M_real[i,1], M_real[i,2], M_real[i,3], M_real[i,4]))
end

# 3. Verificación de pureza espectral (Autovalores)
autovalores = eigvals(M_real)
println("\n📊 Analisis de Autovalores (Espectro del Estado):")
for (idx, val) in enumerate(autovalores)
    @printf("  λ%d = %.4f\n", idx, val)
end

# Comprobación de consistencia cuántica
if any(val -> val < -1e-9, autovalores)
    println("\n⚠️ AVISO: La matriz contiene autovalores negativos. Representa un estado virtual inestable.")
else
    println("\n✅ ESTADO VALIDO: La matriz es definida positiva. Es matematicamente realizable.")
end
println("======================================================================")
