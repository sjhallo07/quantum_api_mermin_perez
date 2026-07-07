# ==========================================
# swampland_bridge_v2.jl
# Validación de la Teoría del Puente TEP
# Versión revisada: criterios explícitos
# ==========================================

# ── Parámetros ────────────────────────────
phi0    = 2.0
epsilon = 0.1
beta    = 1.0

# ── Reconstrucción de constantes ──────────
termino_V0_exp = 5.91e-5
V0       = termino_V0_exp * exp(sqrt(2) * phi0)
Lambda_cc = 5.910575e-5 - termino_V0_exp

# alpha se elige para anular V'(phi0) por construcción:
#   V'(phi0) = -sqrt(2)*V0*exp(-sqrt(2)*phi0) + epsilon*alpha = 0
alpha = (sqrt(2) * V0 * exp(-sqrt(2) * phi0)) / epsilon

println("=== CONSTANTES DERIVADAS ===")
println("V0        = ", V0)
println("Lambda_cc = ", Lambda_cc)
println("alpha     = ", alpha, "  [TUNEADO para V'(phi0)=0 por construcción]")

# ── Potencial efectivo ────────────────────
V_eff(phi) = V0 * exp(-sqrt(2) * phi) +
             Lambda_cc +
             epsilon * (alpha * (phi - phi0) + beta * (phi - phi0)^2)

# ── Derivadas numéricas (diferencias centrales) ───
h    = 1e-7
dV(phi)  = (V_eff(phi + h) - V_eff(phi - h)) / (2h)
d2V(phi) = (V_eff(phi + h) - 2V_eff(phi) + V_eff(phi - h)) / h^2

# ── Evaluación en phi0 ───────────────────
val_V    = V_eff(phi0)
val_dV   = dV(phi0)
val_d2V  = d2V(phi0)
grad_over_V = abs(val_dV) / val_V

println("\n=== RESULTADOS EN phi0 = ", phi0, " ===")
println("V(phi0)         = ", val_V)
println("V'(phi0)        = ", val_dV, "  [~0: artefacto de construcción, no resultado físico]")
println("|∇V|/V en phi0  = ", grad_over_V)
println("V''(phi0)       = ", val_d2V, "  [positivo → mínimo local]")

# ── Verificación analítica de V''(phi0) ──
d2V_analitica = 2 * V0 * exp(-sqrt(2) * phi0) + 2 * epsilon * beta
println("\n  Verificación analítica V''(phi0) = ", d2V_analitica)
println("    = 2·V0·e^{-√2·phi0} + 2·ε·β")
println("    = ", 2 * V0 * exp(-sqrt(2) * phi0), " + ", 2 * epsilon * beta)

# ── Criterios de Swampland (refined dS conjecture) ───────────────────
# Se exige AL MENOS UNO de:
#   C1: |∇V|/V ≥ c       (c ~ 0.6 en unidades de Planck)
#   C2: min eigenvalue Hess(V)/V ≤ -c'   (c' ~ 0.6)
c  = 0.6
cp = 0.6

C1 = grad_over_V >= c
C2 = (val_d2V / val_V) <= -cp

println("\n=== CRITERIOS DE SWAMPLAND ===")
println("C1: |∇V|/V = ", grad_over_V, " ≥ ", c, " → ", C1 ? "CUMPLE ✓" : "FALLA ✗")
println("C2: V''/V  = ", val_d2V / val_V, " ≤ -", cp, " → ", C2 ? "CUMPLE ✓" : "FALLA ✗")
println("Conjecture satisfecha: ", (C1 || C2) ? "SÍ ✓" : "NO ✗  ← mínimo dS no permitido")

# ── Barrido fuera del punto crítico ──────
println("\n=== GRADIENTE FUERA DE phi0 (barrido) ===")
println("phi\t\t|∇V|/V\t\tC1 cumple?")
for delta in [-1.0, -0.5, -0.2, -0.1, 0.1, 0.2, 0.5, 1.0]
    phi_test = phi0 + delta
    v   = V_eff(phi_test)
    gvv = abs(dV(phi_test)) / v
    println(round(phi_test, digits=2), "\t\t",
            round(gvv, sigdigits=4), "\t\t",
            gvv >= c ? "SÍ" : "no")
end

# ── Escala de energía ─────────────────────
println("\n=== ESCALA DE ENERGÍA (Mpl = 1) ===")
println("V(phi0) = ", val_V, " Mpl^4")
println("  Constante cosmológica observada: ~1e-122 Mpl^4")
println("  Escala GUT^4:                   ~1e-12  Mpl^4")
println("  → V está entre escalas EW y GUT, NO es CC-like (diferencia: ~", round(log10(val_V / 1e-122), digits=0), " órdenes de magnitud)")
EOFjulia swampland_bridge_v2.jl
cat << 'EOF' > swampland_bridge_v2.jl
# ==========================================
# swampland_bridge_v2.jl
# Validación de la Teoría del Puente TEP
# Versión revisada: criterios explícitos
# ==========================================

# ── Parámetros ────────────────────────────
phi0    = 2.0
epsilon = 0.1
beta    = 1.0

# ── Reconstrucción de constantes ──────────
termino_V0_exp = 5.91e-5
V0       = termino_V0_exp * exp(sqrt(2) * phi0)
Lambda_cc = 5.910575e-5 - termino_V0_exp

# alpha se elige para anular V'(phi0) por construcción:
#   V'(phi0) = -sqrt(2)*V0*exp(-sqrt(2)*phi0) + epsilon*alpha = 0
alpha = (sqrt(2) * V0 * exp(-sqrt(2) * phi0)) / epsilon

println("=== CONSTANTES DERIVADAS ===")
println("V0        = ", V0)
println("Lambda_cc = ", Lambda_cc)
println("alpha     = ", alpha, "  [TUNEADO para V'(phi0)=0 por construcción]")

# ── Potencial efectivo ────────────────────
V_eff(phi) = V0 * exp(-sqrt(2) * phi) +
             Lambda_cc +
             epsilon * (alpha * (phi - phi0) + beta * (phi - phi0)^2)

# ── Derivadas numéricas (diferencias centrales) ───
h    = 1e-7
dV(phi)  = (V_eff(phi + h) - V_eff(phi - h)) / (2h)
d2V(phi) = (V_eff(phi + h) - 2V_eff(phi) + V_eff(phi - h)) / h^2

# ── Evaluación en phi0 ───────────────────
val_V    = V_eff(phi0)
val_dV   = dV(phi0)
val_d2V  = d2V(phi0)
grad_over_V = abs(val_dV) / val_V

println("\n=== RESULTADOS EN phi0 = ", phi0, " ===")
println("V(phi0)         = ", val_V)
println("V'(phi0)        = ", val_dV, "  [~0: artefacto de construcción, no resultado físico]")
println("|∇V|/V en phi0  = ", grad_over_V)
println("V''(phi0)       = ", val_d2V, "  [positivo → mínimo local]")

# ── Verificación analítica de V''(phi0) ──
d2V_analitica = 2 * V0 * exp(-sqrt(2) * phi0) + 2 * epsilon * beta
println("\n  Verificación analítica V''(phi0) = ", d2V_analitica)
println("    = 2·V0·e^{-√2·phi0} + 2·ε·β")
println("    = ", 2 * V0 * exp(-sqrt(2) * phi0), " + ", 2 * epsilon * beta)

# ── Criterios de Swampland (refined dS conjecture) ───────────────────
# Se exige AL MENOS UNO de:
#   C1: |∇V|/V ≥ c       (c ~ 0.6 en unidades de Planck)
#   C2: min eigenvalue Hess(V)/V ≤ -c'   (c' ~ 0.6)
c  = 0.6
cp = 0.6

C1 = grad_over_V >= c
C2 = (val_d2V / val_V) <= -cp

println("\n=== CRITERIOS DE SWAMPLAND ===")
println("C1: |∇V|/V = ", grad_over_V, " ≥ ", c, " → ", C1 ? "CUMPLE ✓" : "FALLA ✗")
println("C2: V''/V  = ", val_d2V / val_V, " ≤ -", cp, " → ", C2 ? "CUMPLE ✓" : "FALLA ✗")
println("Conjecture satisfecha: ", (C1 || C2) ? "SÍ ✓" : "NO ✗  ← mínimo dS no permitido")

# ── Barrido fuera del punto crítico ──────
println("\n=== GRADIENTE FUERA DE phi0 (barrido) ===")
println("phi\t\t|∇V|/V\t\tC1 cumple?")
for delta in [-1.0, -0.5, -0.2, -0.1, 0.1, 0.2, 0.5, 1.0]
    phi_test = phi0 + delta
    v   = V_eff(phi_test)
    gvv = abs(dV(phi_test)) / v
    println(round(phi_test, digits=2), "\t\t",
            round(gvv, sigdigits=4), "\t\t",
            gvv >= c ? "SÍ" : "no")
end

# ── Escala de energía ─────────────────────
println("\n=== ESCALA DE ENERGÍA (Mpl = 1) ===")
println("V(phi0) = ", val_V, " Mpl^4")
println("  Constante cosmológica observada: ~1e-122 Mpl^4")
println("  Escala GUT^4:                   ~1e-12  Mpl^4")
println("  → V está entre escalas EW y GUT, NO es CC-like (diferencia: ~", round(log10(val_V / 1e-122), digits=0), " órdenes de magnitud)")
