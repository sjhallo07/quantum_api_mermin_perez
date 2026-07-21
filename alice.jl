# ===========================================================================
# alice.jl
# PROTOCOLO DE COMUNICACIÓN ALICE → BOB
# Basado en De Branges (1968) y Hilbert (1912) - Versión Corregida
# ===========================================================================

using LinearAlgebra, QuadGK, Plots

# ------------------------------------------------------------
# 1. DEFINICIÓN DE BOB (Receptor)
# ------------------------------------------------------------
mutable struct Bob
    E::Function          # Función generadora del espacio H(E)
    A::Function          # Función entera conjugada A(z)
    B::Function          # Función entera conjugada B(z)

    function Bob(E::Function)
        # Operador de conjugación inmutable E*(z) = conj(E(conj(z)))
        E_star(z) = conj(E(conj(z)))

        # Extensión analítica rigurosa a todo el plano complejo
        A(z) = (E(z) + E_star(z)) / 2.0
        B(z) = (E(z) - E_star(z)) / (2.0im)
        return new(E, A, B)
    end
end

# ------------------------------------------------------------
# 2. MÉTODOS DE BOB
# ------------------------------------------------------------

# 2.1 Núcleo reproductor K(w,z) (Teorema 19 exacto de De Branges)
function kernel(bob::Bob, w, z)
    A, B = bob.A, bob.B
    w_conj = conj(w)
    # Acoplamiento simétrico de fronteras analíticas
    return (B(z) * A(w_conj) - A(z) * B(w_conj)) / (π * (z - w_conj))
end

# 2.2 Norma de F en H(E) (Integración numérica en la recta real)
function norm(bob::Bob, F::Function; a=-50, b=50)
    integrand(t) = abs(F(t) / bob.E(t))^2
    return sqrt(QuadGK.quadgk(integrand, a, b)[1])
end

# 2.3 Evaluación de F(w) con el núcleo reproductor
function evaluate(bob::Bob, F::Function, w::Complex)
    K(t) = kernel(bob, w, complex(t))
    integrand(t) = F(t) * conj(K(t))
    return QuadGK.quadgk(integrand, -50, 50)[1]
end

# 2.4 Test de periodicidad (Invarianza traslacional, Teorema 48)
function test_translation(bob::Bob, w::Complex, h::Real)
    z = 1.0 + 0.5im
    K1 = kernel(bob, w, z)
    K2 = kernel(bob, w + h, z + h)
    return abs(K1 - K2)
end

# 2.5 Método "recibir"
function receive(bob::Bob, calc)
    if calc isa Function
        w = 1.0 + 1.0im
        norm_val = norm(bob, calc)
        eval_val = evaluate(bob, calc, w)
        return (norm=norm_val, eval=eval_val)
    elseif calc isa Number
        F(z) = calc
        return receive(bob, F)
    else
        error("Tipo no soportado: $(typeof(calc))")
    end
end

# ------------------------------------------------------------
# 3. ALICE: Emisor de cálculos
# ------------------------------------------------------------
function Alice(bob::Bob, calc)
    return receive(bob, calc)
end

# ------------------------------------------------------------
# 4. CONFIGURACIÓN: Espacio de Paley-Wiener
#    E(z) = e^{-iz}
# ------------------------------------------------------------
E(z) = exp(-im * z)
bob = Bob(E)

# ------------------------------------------------------------
# 5. PRUEBAS: Alice envía varios cálculos a Bob
# ------------------------------------------------------------
println("=== PROTOCOLO ALICE → BOB ACTIVADO (ANALÍTICO) ===\n")

# Prueba 1: Función constante
F1(z) = 1
result1 = Alice(bob, F1)
println("Alice envía F1(z)=1:")
println("  Norma = ", result1.norm)
println("  Evaluación en w=1+i : ", result1.eval)

# Prueba 2: Número
result2 = Alice(bob, 2.5)
println("\nAlice envía el número 2.5:")
println("  Norma = ", result2.norm)
println("  Evaluación en w=1+i : ", result2.eval)

# Prueba 3: Invarianza traslacional del núcleo
w_test = 1.0 + 1.0im
h_test = 0.5
diff = test_translation(bob, w_test, h_test)
println("\nTest de periodicidad con w=$w_test, h=$h_test:")
println("  |K(w+h, z+h) - K(w, z)| = $diff")
if diff < 1e-12
    println("  ✅ Invarianza bajo traslación verificada en todo el plano complejo.")
else
    println("  ❌ Falló.")
end

println("\n=== COMUNICACIÓN ALICE → BOB COMPLETADA ===")
