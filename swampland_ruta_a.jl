include("soberania_absoluta.jl")
# ==========================================
# swampland_ruta_a.jl  —  QRE/TEP  Ruta A
# beta < 0: V''(phi_min) < 0 → satisface C2
# Combina con gamma != 0 (Ruta A+B opcional)
# ==========================================

using LinearAlgebra

println("╔══════════════════════════════════════════╗")
println("║   swampland_ruta_a.jl  —  QRE/TEP RA    ║")
println("╚══════════════════════════════════════════╝")

const phi0      = 2.0
const epsilon   = 0.1
const V0        = 0.000999902774902772
const Lambda_cc = 5.750000000002444e-9
const c_sw      = 0.6
const h_step    = 1e-7

# ── Potencial Ruta A: beta libre, gamma=0 ──
# V_A(φ) = V0·e^{-√2·φ} + Λcc + ε·β·(φ−φ0)²
# Con β < 0: la curvatura se invierte en phi0
V_A(phi, bet)   = V0*exp(-sqrt(2)*phi) + Lambda_cc +
                  epsilon * bet * (phi - phi0)^2
dV_A(phi, bet)  = (V_A(phi+h_step,bet) - V_A(phi-h_step,bet)) / (2h_step)
d2V_A(phi, bet) = (V_A(phi+h_step,bet) - 2V_A(phi,bet) + V_A(phi-h_step,bet)) / h_step^2

# Potencial Ruta A+B: beta < 0, gamma != 0
V_AB(phi, bet, gam)   = V0*exp(-sqrt(2)*phi) + Lambda_cc +
                         epsilon*(bet*(phi-phi0)^2 + gam*(phi-phi0)^3)
dV_AB(phi, bet, gam)  = (V_AB(phi+h_step,bet,gam) - V_AB(phi-h_step,bet,gam)) / (2h_step)
d2V_AB(phi, bet, gam) = (V_AB(phi+h_step,bet,gam) - 2V_AB(phi,bet,gam) +
                          V_AB(phi-h_step,bet,gam)) / h_step^2

# ── Analítica: V''(phi) con beta libre ────
# V''(phi) = 2V0·e^{-√2·phi} + 2·epsilon·beta
# En phi0: V''(phi0) = 0.0001182 + 2·epsilon·beta
# Para C2: V''(phi0)/V(phi0) ≤ -0.6
# → 2·epsilon·beta ≤ -0.6·V(phi0) - 0.0001182
# → beta ≤ (-0.6·V(phi0) - 0.0001182) / (2·epsilon)
V_phi0      = V0*exp(-sqrt(2)*phi0) + Lambda_cc
beta_C2_min = (-c_sw * V_phi0 - 2*V0*exp(-sqrt(2)*phi0)) / (2*epsilon)

println("\n── UMBRAL ANALÍTICO DE β PARA C2 ─────────")
println("  V(phi0)            = $(round(V_phi0, sigdigits=6))")
println("  β_min para C2      = $(round(beta_C2_min, sigdigits=6))")
println("  (necesitamos β ≤ β_min para que V''/V ≤ -0.6)")

# ── Función: barrido de beta ───────────────
function barrer_beta(betas)
    println("\n── BARRIDO DE β (Ruta A, gamma=0) ───────")
    println("β\t\tφ_min\t\tV(φ_min)\t|∇V|/V\t\tV''/V\t\tC1\tC2\tdS")
    println("─"^105)
    resultados = []
    for bet in betas
        # localizar mínimo o punto de operación
        phi_sc  = collect(range(0.01, 6.0, length=100_000))
        # Con beta < 0 puede no haber mínimo: buscar donde V > 0
        V_vals  = V_A.(phi_sc, bet)
        dV_vals = abs.(dV_A.(phi_sc, bet))
        # Filtrar phi donde V > 0
        mask    = V_vals .> 0
        if !any(mask)
            println("$(round(bet,sigdigits=4))\t\tV ≤ 0 en todo el rango")
            continue
        end
        phi_valid = phi_sc[mask]
        # Punto de menor gradiente con V > 0
        dV_valid  = dV_vals[mask]
        phi_op    = phi_valid[argmin(dV_valid)]
        V_op      = V_A(phi_op, bet)
        gvv       = abs(dV_A(phi_op, bet)) / V_op
        d2vv      = d2V_A(phi_op, bet) / V_op
        C1 = gvv  >= c_sw
        C2 = d2vv <= -c_sw
        dS = C1 || C2
        println("$(rpad(round(bet,sigdigits=4),8))\t$(round(phi_op,sigdigits=5))\t\t$(round(V_op,sigdigits=4))\t$(round(gvv,sigdigits=4))\t\t$(round(d2vv,sigdigits=4))\t\t$(C1 ? "✓" : "✗")\t$(C2 ? "✓" : "✗")\t$(dS ? "✓" : "✗")")
        push!(resultados, (bet=bet, phi=phi_op, V=V_op, gvv=gvv, d2vv=d2vv, C1=C1, C2=C2))
    end
    return resultados
end

# ── Función: análisis detallado beta óptimo ─
function analisis_beta(bet_opt)
    println("\n── ANÁLISIS DETALLADO  β = $(round(bet_opt, sigdigits=5)) ────")

    phi_sc = collect(range(0.01, 6.0, length=300_000))
    V_vals = V_A.(phi_sc, bet_opt)

    # Región V > 0
    mask_pos = V_vals .> 0
    any(mask_pos) || (println("  V ≤ 0 en todo el rango"); return)

    phi_pos  = phi_sc[mask_pos]
    phi_min_V= phi_pos[1]
    phi_max_V= phi_pos[end]
    println("  Región V > 0: φ ∈ [$(round(phi_min_V,sigdigits=4)), $(round(phi_max_V,sigdigits=4))] Mpl")

    # Perfil
    println("\n  Perfil V_A(φ):")
    println("  φ\t\tV_A\t\t|∇V|/V\t\tV''/V\t\tC1\tC2")
    puntos_eval = filter(p -> p > phi_min_V && p < phi_max_V,
                         [phi_min_V+0.01, 1.5, 2.0, 2.5, 3.0, 3.5, phi_max_V-0.01])
    for pev in puntos_eval
        Vp   = V_A(pev, bet_opt)
        Vp  <= 0 && continue
        gvp  = abs(dV_A(pev, bet_opt)) / Vp
        d2p  = d2V_A(pev, bet_opt) / Vp
        println("  $(rpad(round(pev,digits=3),8))\t$(round(Vp,sigdigits=4))\t$(round(gvp,sigdigits=4))\t\t$(round(d2p,sigdigits=4))\t\t$(gvp>=c_sw ? "✓" : "✗")\t$(d2p<=-c_sw ? "✓" : "✗")")
    end

    # Verificar C2 globalmente en región V > 0
    c2_global = all(d2V_A(p, bet_opt)/V_A(p,bet_opt) <= -c_sw
                    for p in phi_pos[1:100:end])
    c1_global = all(abs(dV_A(p,bet_opt))/V_A(p,bet_opt) >= c_sw
                    for p in phi_pos[1:100:end])
    println("\n  C2 global en toda región V>0: $(c2_global ? "✓" : "✗")")
    println("  C1 global en toda región V>0: $(c1_global ? "✓" : "✗")")
    println("  dS global: $((c1_global||c2_global) ? "SATISFECHA ✓" : "parcial ✗")")
end

# ── Función: Ruta A+B combinada ────────────
function ruta_AB(bet, gam)
    println("\n── RUTA A+B  β=$(round(bet,sigdigits=4))  γ=$(round(gam,sigdigits=4)) ──")
    phi_sc = collect(range(0.01, 6.0, length=200_000))
    V_vals = V_AB.(phi_sc, bet, gam)
    mask   = V_vals .> 0
    !any(mask) && (println("  V ≤ 0 en todo el rango"); return)
    phi_pos = phi_sc[mask]

    # Punto de mínimo gradiente en V > 0
    dV_min_idx = argmin(abs.(dV_AB.(phi_pos, bet, gam)))
    phi_op = phi_pos[dV_min_idx]

    println("  φ operación = $(round(phi_op, sigdigits=5))")
    println("  φ ∈ [$(round(phi_pos[1],sigdigits=4)), $(round(phi_pos[end],sigdigits=4))] Mpl  (V > 0)")
    println("\n  Perfil:")
    println("  φ\t\tV_AB\t\t|∇V|/V\t\tV''/V\t\tC1\tC2")
    puntos = filter(p -> p > phi_pos[1] && p < phi_pos[end],
                    [phi_pos[1]+0.01, 1.5, 2.0, phi_op, 2.5, 3.0])
    for pev in sort(unique(puntos))
        Vp  = V_AB(pev, bet, gam);  Vp <= 0 && continue
        gvp = abs(dV_AB(pev, bet, gam)) / Vp
        d2p = d2V_AB(pev, bet, gam) / Vp
        marker = isapprox(pev, phi_op, atol=5e-3) ? " ←op" : ""
        println("  $(rpad(round(pev,digits=3),8))\t$(round(Vp,sigdigits=4))\t$(round(gvp,sigdigits=4))\t\t$(round(d2p,sigdigits=4))\t\t$(gvp>=c_sw ? "✓" : "✗")\t$(d2p<=-c_sw ? "✓" : "✗")$marker")
    end
    c2_g = all(d2V_AB(p,bet,gam)/V_AB(p,bet,gam) <= -c_sw for p in phi_pos[1:200:end])
    c1_g = all(abs(dV_AB(p,bet,gam))/V_AB(p,bet,gam) >= c_sw for p in phi_pos[1:200:end])
    println("  C1 global: $(c1_g ? "✓" : "✗")   C2 global: $(c2_g ? "✓" : "✗")")
    println("  dS global: $((c1_g||c2_g) ? "SATISFECHA ✓" : "no satisfecha ✗")")
end

# ══════════════════════════════════════════
# EJECUCIÓN
# ══════════════════════════════════════════

# Barrido grueso de β
betas_grueso = [1.0, 0.5, 0.1, 0.0, -0.1, -0.5, -1.0,
                -2.0, -3.0, -5.0, -10.0, -20.0, -50.0]
res = barrer_beta(betas_grueso)

# Beta analítico mínimo para C2
println("\n── β ANALÍTICO PARA C2 ───────────────────")
println("  β_min = $(round(beta_C2_min, sigdigits=6))")
analisis_beta(beta_C2_min * 1.5)   # 50% por debajo del umbral

# Ruta A+B combinada: β < 0 del umbral + γ de Ruta B
println("\n── RUTA A+B COMBINADA ────────────────────")
ruta_AB(beta_C2_min * 1.5, -9.75)

# Resumen final
println("\n╔═══════════════════════════════════════════════════════════════╗")
println("║       RESUMEN  v3 → v4 → RB → RA → RA+B                     ║")
println("╠═══════════════════════════════════════════════════════════════╣")
println("║  Conjetura  │ v3      │ v4      │ Ruta B  │ Ruta A │ Ruta A+B║")
println("╠═══════════════════════════════════════════════════════════════╣")
println("║  dS (C1∨C2) │ FALLA ✗ │ FALLA ✗ │ parcial │ ?      │ ?       ║")
println("║  Distancia  │ OK ✓    │ OK ✓    │ OK ✓    │ ?      │ ?       ║")
println("║  WGC        │ FALLA ✗ │ OK ✓    │ OK ✓    │ OK ✓   │ OK ✓    ║")
println("╠═══════════════════════════════════════════════════════════════╣")
println("║  Nota: Ruta A elimina el mínimo dS → potencial sin fondo     ║")
println("║  Ruta A+B: C2 en min + C1 en rodamiento → más físico         ║")
println("╚═══════════════════════════════════════════════════════════════╝")
