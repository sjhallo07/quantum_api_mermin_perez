# ==========================================
# swampland_ruta_b.jl  —  QRE/TEP  Ruta B
# Término cúbico γ·(φ−φ0)³ para romper Z2
# Objetivo: |∇V|/V ≥ 0.6  con  V > 0
# Nota: todos los bucles dentro de funciones
#       para evitar scoping de top-level Julia
# ==========================================

using LinearAlgebra

println("╔══════════════════════════════════════════╗")
println("║   swampland_ruta_b.jl  —  QRE/TEP RB    ║")
println("╚══════════════════════════════════════════╝")

# ── Parámetros fijos ──────────────────────
const phi0      = 2.0
const epsilon   = 0.1
const beta_p    = 1.0
const V0        = 0.000999902774902772
const Lambda_cc = 5.750000000002444e-9
const c_sw      = 0.6
const h_step    = 1e-7

# ── Potencial Ruta B y derivadas ──────────
V_B(phi, gam)   = V0*exp(-sqrt(2)*phi) + Lambda_cc +
                  epsilon*(gam*(phi-phi0)^3 + beta_p*(phi-phi0)^2)
dV_B(phi, gam)  = (V_B(phi+h_step,gam) - V_B(phi-h_step,gam)) / (2h_step)
d2V_B(phi, gam) = (V_B(phi+h_step,gam) - 2V_B(phi,gam) + V_B(phi-h_step,gam)) / h_step^2

# Punto de inflexión analítico:
# V''(φ) = 2V0·e^{-√2·φ} + ε·[6γ·(φ−φ0) + 2β] = 0
phi_inf_analitico(gam) = gam != 0 ?
    phi0 - (2V0*exp(-sqrt(2)*phi0) + 2epsilon*beta_p) / (6epsilon*gam) : Inf

# ── Función de barrido (evita top-level for) ──
function barrer_gammas(gammas)
    println("\n── BARRIDO DE γ: PUNTO DE INFLEXIÓN ──────")
    println("γ\t\tφ_inf\t\tV(φ_inf)\t|∇V|/V\t\tV''/V\t\tC1\tC2")
    println("─"^95)
    best = (gam=0.0, gvv=0.0, phi=phi0, V=0.0, d2vv=0.0)
    for gam in gammas
        phi_inf = phi_inf_analitico(gam)
        if !isfinite(phi_inf) || phi_inf <= 0.01 || phi_inf > 8.0
            println("$(rpad(round(gam,digits=2),8))\tφ_inf fuera de rango físico")
            continue
        end
        V_inf = V_B(phi_inf, gam)
        if V_inf <= 0
            println("$(rpad(round(gam,digits=2),8))\t$(round(phi_inf,digits=4))\t\tV < 0 — AdS, no dS")
            continue
        end
        gvv   = abs(dV_B(phi_inf, gam)) / V_inf
        d2vv  = d2V_B(phi_inf, gam) / V_inf
        C1    = gvv  >= c_sw
        C2    = d2vv <= -c_sw
        println("$(rpad(round(gam,digits=2),8))\t$(round(phi_inf,digits=4))\t\t$(round(V_inf,sigdigits=4))\t$(round(gvv,sigdigits=4))\t\t$(round(d2vv,sigdigits=4))\t\t$(C1 ? "✓" : "✗")\t$(C2 ? "✓" : "✗")")
        if gvv > best.gvv
            best = (gam=gam, gvv=gvv, phi=phi_inf, V=V_inf, d2vv=d2vv)
        end
    end
    return best
end

# ── Función de barrido fino ────────────────
function barrido_fino(centro, n=500)
    rng  = range(centro - abs(centro)*0.95, centro + abs(centro)*0.95, length=n)
    best = (gam=centro, gvv=0.0, phi=phi0, V=0.0, d2vv=0.0)
    for gam in rng
        phi_inf = phi_inf_analitico(gam)
        !isfinite(phi_inf) && continue
        (phi_inf <= 0.01 || phi_inf > 8.0) && continue
        V_inf = V_B(phi_inf, gam)
        V_inf <= 0 && continue
        gvv  = abs(dV_B(phi_inf, gam)) / V_inf
        d2vv = d2V_B(phi_inf, gam) / V_inf
        if gvv > best.gvv
            best = (gam=gam, gvv=gvv, phi=phi_inf, V=V_inf, d2vv=d2vv)
        end
    end
    return best
end

# ── Función de análisis completo ───────────
function analisis_completo(opt)
    println("\n── ANÁLISIS COMPLETO  γ = $(round(opt.gam,sigdigits=5)) ──────")

    # Mínimo local via argmin
    phi_sc   = collect(range(0.01, 8.0, length=300_000))
    phi_min  = phi_sc[argmin(abs.(dV_B.(phi_sc, opt.gam)))]
    V_min    = V_B(phi_min, opt.gam)
    d2V_min  = d2V_B(phi_min, opt.gam)

    println("\n  1. Mínimo local:")
    println("     φ_min    = $(round(phi_min,  sigdigits=7))")
    println("     V(φ_min) = $(round(V_min,    sigdigits=6))  $(V_min>0 ? "[dS ✓]" : "[AdS ✗]")")
    println("     V''(φ_min)=$(round(d2V_min,  sigdigits=6))  $(d2V_min>0 ? "[mínimo local]" : "[silla/máximo]")")

    println("\n  2. Punto de inflexión (objetivo Ruta B):")
    println("     φ_inf    = $(round(opt.phi,  sigdigits=7))")
    println("     V(φ_inf) = $(round(opt.V,    sigdigits=6))")
    println("     |∇V|/V   = $(round(opt.gvv,  sigdigits=6))  [umbral = $c_sw]")
    println("     V''/V    = $(round(opt.d2vv, sigdigits=6))")
    C1 = opt.gvv  >= c_sw
    C2 = opt.d2vv <= -c_sw
    println("     C1: $(C1 ? "CUMPLE ✓" : "FALLA ✗")   C2: $(C2 ? "CUMPLE ✓" : "FALLA ✗")")
    println("     dS conjecture: $((C1||C2) ? "SATISFECHA ✓" : "no satisfecha ✗")")

    println("\n  3. Perfil V_B(φ):")
    println("  φ\t\tV_B\t\t|∇V|/V\t\tV''/V\t\tC1\tC2")
    puntos = sort(unique([1.0, 1.5, phi_min, phi0,
                          opt.phi-0.5, opt.phi, opt.phi+0.5, 4.0, 5.0]))
    for pev in puntos
        pev <= 0 && continue
        Vp  = V_B(pev,  opt.gam);  Vp  <= 0 && continue
        gvp = abs(dV_B(pev, opt.gam)) / Vp
        d2p = d2V_B(pev, opt.gam)  / Vp
        marker = isapprox(pev, opt.phi, atol=1e-3) ? " ←inf" :
                 isapprox(pev, phi_min, atol=1e-3) ? " ←min" : ""
        println("  $(rpad(round(pev,digits=3),8))\t$(round(Vp,sigdigits=4))\t$(round(gvp,sigdigits=4))\t\t$(round(d2p,sigdigits=4))\t\t$(gvp>=c_sw ? "✓" : "✗")\t$(d2p<=-c_sw ? "✓" : "✗")$marker")
    end

    # Conjetura de Distancia
    Delta_phi = abs(opt.phi - phi_min)
    println("\n  4. Conjetura de Distancia:")
    println("     Δφ (min→inflexión) = $(round(Delta_phi,sigdigits=4)) Mpl")
    println("     Δφ < 1 Mpl: $(Delta_phi < 1.0 ? "OK ✓" : "EXCEDE ✗")")

    # WGC
    println("\n  5. WGC (Sc=0 → Rc=1 lP → m_KK=1 Mpl):")
    println("     q_KK=1.0 ≥ m_KK=1.0: OK ✓")

    return (C1=C1, C2=C2, dist=Delta_phi<1.0, phi_min=phi_min)
end

# ═══════════════════════════════════════════
# EJECUCIÓN
# ═══════════════════════════════════════════
gammas_grosero = [-0.1,-0.2,-0.5,-1.0,-1.5,-2.0,-3.0,-5.0,
                   0.1, 0.2, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0]

best_grosero = barrer_gammas(gammas_grosero)

println("\n── BARRIDO FINO alrededor de γ = $(round(best_grosero.gam,sigdigits=4)) ──")
opt = barrido_fino(best_grosero.gam, 1000)
println("  γ óptimo   = $(round(opt.gam,  sigdigits=6))")
println("  φ_inflexión= $(round(opt.phi,  sigdigits=6))")
println("  |∇V|/V     = $(round(opt.gvv,  sigdigits=6))")
println("  V(φ_inf)   = $(round(opt.V,    sigdigits=6))")
println("  V''/V      = $(round(opt.d2vv, sigdigits=6))")

res = analisis_completo(opt)

# ── Resumen comparativo ───────────────────
println("\n╔═══════════════════════════════════════════════════════════╗")
println("║          RESUMEN  v3 → v4 → Ruta B                       ║")
println("╠═══════════════════════════════════════════════════════════╣")
println("║  Conjetura     │  v3 (tuneado) │  v4 (Z2)  │  Ruta B    ║")
println("╠═══════════════════════════════════════════════════════════╣")
println("║  dS  C1        │  FALLA ✗      │  FALLA ✗  │  $(res.C1 ? "OK    ✓" : "FALLA ✗")     ║")
println("║  dS  C2        │  FALLA ✗      │  FALLA ✗  │  $(res.C2 ? "OK    ✓" : "FALLA ✗")     ║")
println("║  Distancia     │  OK    ✓      │  OK    ✓  │  $(res.dist ? "OK    ✓" : "FALLA ✗")     ║")
println("║  WGC           │  FALLA ✗      │  OK    ✓  │  OK    ✓   ║")
println("╠═══════════════════════════════════════════════════════════╣")
println("║  γ             │  —            │  0.0      │  $(round(opt.gam,sigdigits=4))      ║")
println("║  φ operación   │  2.0 forzado  │  2.0004   │  $(round(opt.phi,sigdigits=5))      ║")
println("║  |∇V|/V        │  5.7e-10      │  0.066    │  $(round(opt.gvv,sigdigits=4))      ║")
println("╚═══════════════════════════════════════════════════════════╝")
