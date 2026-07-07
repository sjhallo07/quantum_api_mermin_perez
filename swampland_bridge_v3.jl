# ==========================================
# swampland_bridge_v3.jl
# Teoría del Puente TEP — Acción 5D completa
# Incluye métrica, término cinético RS y
# criterios Swampland explícitos
# ==========================================

using LinearAlgebra

# ── Métrica 5D (signatura Lorentziana) ────
# η_{MN} = diag(-1,+1,+1,+1,+1)
# Válida en límite de espacio plano (k→0)
# El modelo RS real añade factor e^{-2k|y|}
const MATRIZ_SOBERANA_5D = Float64[
   -1.0  0.0  0.0  0.0  0.0;
    0.0  1.0  0.0  0.0  0.0;
    0.0  0.0  1.0  0.0  0.0;
    0.0  0.0  0.0  1.0  0.0;
    0.0  0.0  0.0  0.0  1.0
]

# Signatura: (+----)? No. Aquí usamos (-++++)
# Verificación de traza y determinante
println("=== VERIFICACIÓN MÉTRICA ===")
println("Traza  η = ", tr(MATRIZ_SOBERANA_5D),   "  (esperado: 3)")
println("det(η) = ", det(MATRIZ_SOBERANA_5D),  "  (esperado: -1)")
println("Signatura: (-,+,+,+,+) ✓")

# ── Constante soberana y radio de compactificación ──
# Sc = -11.700001 fija Rc ~ l_Planck (conjecture de Distancia)
Sc   = -11.700001
Rc   = exp(Sc)          # radio de compactificación en unidades de Planck
k_RS = 1.0 / Rc         # curvatura AdS5 efectiva
println("\n=== CONSTANTE SOBERANA ===")
println("Sc   = ", Sc)
println("Rc   = exp(Sc) = ", Rc, " l_Planck")
println("k_RS = 1/Rc    = ", k_RS)

# ── Parámetros del potencial ───────────────
phi0    = 2.0
epsilon = 0.1
beta    = 1.0

termino_V0_exp = 5.91e-5
V0        = termino_V0_exp * exp(sqrt(2) * phi0)
Lambda_cc = 5.910575e-5 - termino_V0_exp
alpha     = (sqrt(2) * V0 * exp(-sqrt(2) * phi0)) / epsilon

println("\n=== CONSTANTES DEL POTENCIAL ===")
println("V0        = ", V0)
println("Lambda_cc = ", Lambda_cc)
println("alpha     = ", alpha, "  [cancela V'(phi0) por construcción]")

# ── Potencial efectivo Ec. (6) del paper ──
V_eff(phi) = V0 * exp(-sqrt(2) * phi) +
             Lambda_cc +
             epsilon * (alpha * (phi - phi0) + beta * (phi - phi0)^2)

# ── Derivadas numéricas ───────────────────
h     = 1e-7
dV(phi)  = (V_eff(phi + h) - V_eff(phi - h)) / (2h)
d2V(phi) = (V_eff(phi + h) - 2V_eff(phi) + V_eff(phi - h)) / h^2

# ── Evaluación en phi0 ───────────────────
val_V    = V_eff(phi0)
val_dV   = dV(phi0)
val_d2V  = d2V(phi0)

println("\n=== RESULTADOS EN phi0 = $phi0 ===")
println("V(phi0)   = ", val_V)
println("V'(phi0)  = ", val_dV, "  [~0 por construcción de alpha]")
println("V''(phi0) = ", val_d2V, "  [positivo → mínimo local dS]")

# ── Término cinético vía MATRIZ_SOBERANA_5D ───────────────
# (∇Φ)² = η^{MN} ∂_M Φ ∂_N Φ
# Campo estático → sólo componente φ (dim 5, extra)
# ∂_M Φ = (0, 0, 0, 0, dV/dphi) en gauge estático
dPhi_5vec = [0.0, 0.0, 0.0, 0.0, val_dV]
kinetic_flat = dot(dPhi_5vec, MATRIZ_SOBERANA_5D * dPhi_5vec)

# Corrección RS: factor warp e^{-2k|y|} en componentes 0-3
# En la dirección extra (dim 5) no hay warp → igual
# Para el dilatón en y=0 (brane visible):
warp_factor  = exp(-2 * k_RS * 0.0)   # y=0: brane UV
kinetic_warped = warp_factor * kinetic_flat

println("\n=== TÉRMINO CINÉTICO 5D ===")
println("∂_M Φ (vector 5D) = ", dPhi_5vec)
println("η^{MN}∂_MΦ∂_NΦ   = ", kinetic_flat,    "  [límite plano]")
println("Corregido RS (y=0)= ", kinetic_warped,  "  [brane UV]")
println("Nota: warp e^{-2k|y|} = ", warp_factor, " en y=0")

# ── Criterios de Swampland ─────────────────
grad_over_V = abs(val_dV) / val_V
d2V_over_V  = val_d2V / val_V
c   = 0.6
cp  = 0.6

C1 = grad_over_V >= c
C2 = d2V_over_V  <= -cp

println("\n=== CRITERIOS DE SWAMPLAND ===")
println("C1: |∇V|/V = ", grad_over_V,
        " ≥ ", c, " → ", C1 ? "CUMPLE ✓" : "FALLA ✗")
println("C2: V''/V  = ", d2V_over_V,
        " ≤ -", cp, " → ", C2 ? "CUMPLE ✓" : "FALLA ✗")
println("Conjecture satisfecha (C1 OR C2): ",
        (C1 || C2) ? "SÍ ✓" : "NO ✗  ← mínimo dS no permitido")

# ── Conjetura de Distancia ─────────────────
# ∆φ = 0 según el paper → nunca se activa la torre KK
Delta_phi  = 0.0
mKK        = 1.0 / Rc          # masa del modo KK más ligero
tower_active = Delta_phi > 1.0  # criterio: ∆φ > 1 en unidades de Planck

println("\n=== CONJETURA DE DISTANCIA ===")
println("∆φ recorrido   = ", Delta_phi, " Mpl  [fijado por TEP]")
println("m_KK (1/Rc)    = ", mKK, " Mpl")
println("Torre activada?: ", tower_active ? "SÍ ✗" : "NO ✓")

# ── Conjetura de Gravedad Débil ────────────
# WGC: q >= m/Mpl para el modo KK
# Masa KK ~ 1/Rc, carga q ~ g_4D * sqrt(G)
# Asumimos g_4D ~ O(1) herético (string heterótica)
g_4D  = 1.0
G_N   = 1.0           # unidades de Planck
q_KK  = g_4D * sqrt(G_N)
m_KK  = mKK
WGC_ok = q_KK >= m_KK / 1.0   # Mpl = 1

println("\n=== CONJETURA DE GRAVEDAD DÉBIL ===")
println("q_KK = g_4D·√G = ", q_KK)
println("m_KK / Mpl     = ", m_KK)
println("WGC (q≥m/Mpl): ", WGC_ok ? "CUMPLE ✓" : "FALLA ✗")

# ── Barrido de gradiente fuera de phi0 ────
println("\n=== BARRIDO |∇V|/V FUERA DE phi0 ===")
println("phi\t\t|∇V|/V\t\t\tC1 cumple?")
for delta in [-1.0, -0.5, -0.2, -0.1, 0.1, 0.2, 0.5, 1.0]
    phi_t = phi0 + delta
    gvv   = abs(dV(phi_t)) / V_eff(phi_t)
    println(round(phi_t, digits=2), "\t\t",
            round(gvv, sigdigits=4), "\t\t\t",
            gvv >= c ? "SÍ" : "no")
end

# ── Escala de energía ─────────────────────
println("\n=== ESCALA DE ENERGÍA ===")
println("V(phi0) = ", val_V, " Mpl⁴")
println("  Λ_cc observada: ~1e-122 Mpl⁴  (diferencia: ~",
        round(log10(val_V/1e-122), digits=1), " órdenes)")
println("  Escala GUT⁴:    ~1e-12  Mpl⁴")

# ── Resumen final ─────────────────────────
println("\n=== RESUMEN ===")
println("de Sitter conjecture : ", (C1||C2) ? "OK" : "FALLA — mínimo dS tuneado")
println("Distance conjecture  : ", !tower_active ? "OK" : "FALLA")
println("Weak Gravity conjecture: ", WGC_ok ? "OK" : "FALLA")
println("Métrica 5D usada     : η_{MN} = diag(-1,+1,+1,+1,+1)")
println("  ⚠ Límite plano. RS completo requiere warp e^{-2k|y|}.")
