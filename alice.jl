# ============================================================
# alice.jl
# PROTOCOLO DE COMUNICACIÓN ALICE → BOB
# Basado en De Branges (1968) y Hilbert (1912)
# ============================================================

using LinearAlgebra, QuadGK, Plots

# ------------------------------------------------------------
# 1. DEFINICIÓN DE BOB (Receptor)
# ------------------------------------------------------------
mutable struct Bob
    E::Function          # Función generadora del espacio H(E)
    A::Function          # Parte real de E (real en eje real)
    B::Function          # Parte imaginaria de E (real en eje real)
    
    function Bob(E::Function)
        A(z) = real(E(z))
        B(z) = -imag(E(z))  # E = A - iB
        return new(E, A, B)
    end
end

# ------------------------------------------------------------
# 2. MÉTODOS DE BOB
# ------------------------------------------------------------

# 2.1 Núcleo reproductor K(w,z) (Teorema 19 de De Branges)
function kernel(bob::Bob, w, z)
    A, B = bob.A, bob.B
    return (B(z) * A(w) - A(z) * B(w)) / (π * (z - conj(w)))
end

# 2.2 Norma de F en H(E) (integración numérica)
function norm(bob::Bob, F::Function; a=-50, b=50, N=1000)
    integrand(t) = abs(F(t) / bob.E(t))^2
    return sqrt(QuadGK.quadgk(integrand, a, b)[1])
end

# 2.3 Evaluación de F(w) con el núcleo reproductor (Teorema 19)
function evaluate(bob::Bob, F::Function, w::Complex)
    K(t) = kernel(bob, w, t)
    integrand(t) = F(t) * conj(K(t))
    return QuadGK.quadgk(integrand, -50, 50)[1]
end

# 2.4 Test de periodicidad (invarianza traslacional, Teorema 48)
function test_translation(bob::Bob, w::Complex, h::Real)
    z = 1.0 + 0.5im
    K1 = kernel(bob, w, z)
    K2 = kernel(bob, w + h, z + h)
    return abs(K1 - K2)
end

# 2.5 Método "recibir": acepta función o número
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
    resultado = receive(bob, calc)
    return resultado
end

# ------------------------------------------------------------
# 4. CONFIGURACIÓN: Espacio de Paley-Wiener (periódico)
#    E(z) = e^{-iz}
# ------------------------------------------------------------
E(z) = exp(-im * z)
bob = Bob(E)

# ------------------------------------------------------------
# 5. PRUEBAS: Alice envía varios cálculos a Bob
# ------------------------------------------------------------
println("=== PROTOCOLO ALICE → BOB ACTIVADO ===\n")

# Prueba 1: Función constante
F1(z) = 1
result1 = Alice(bob, F1)
println("Alice envía F1(z)=1:")
println("  Norma = ", result1.norm)
println("  Evaluación en w=1+i : ", result1.eval)

# Prueba 2: Número (se convierte a función constante)
result2 = Alice(bob, 2.5)
println("\nAlice envía el número 2.5:")
println("  Norma = ", result2.norm)
println("  Evaluación en w=1+i : ", result2.eval)

# Prueba 3: Función z
F3(z) = z
result3 = Alice(bob, F3)
println("\nAlice envía F3(z)=z:")
println("  Norma = ", result3.norm)
println("  Evaluación en w=1+i : ", result3.eval)

# Prueba 4: Periodicidad (invarianza no-local)
w = 1.0 + 1.0im
h = 0.5
diff = test_translation(bob, w, h)
println("\nTest de periodicidad con w=$w, h=$h:")
println("  |K(w+h, z+h) - K(w, z)| = $diff")
if diff < 1e-12
    println("  ✅ Invarianza bajo traslación verificada.")
else
    println("  ❌ Falló.")
end

# ------------------------------------------------------------
# 6. GRÁFICA DE LA FUNCIÓN DE FASE φ(x) = arg(E(x))
# ------------------------------------------------------------
fase(x) = angle(E(x))
x_vals = range(-10, 10, length=300)
plot(x_vals, fase.(x_vals),
     title="Función de Fase φ(x) para el espacio de Paley-Wiener",
     xlabel="x", ylabel="φ(x)",
     legend=false,
     linewidth=2)
display(plot!())

println("\n=== COMUNICACIÓN ALICE → BOB COMPLETADA ===")
# EOF
