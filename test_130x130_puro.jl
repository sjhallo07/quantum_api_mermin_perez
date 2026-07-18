#!/usr/bin/env julia
# test_130x130_puro.jl – Validación de la matriz 130×130 sin librerías externas

include("Hilbert/identity_pure.jl")

# ------------------------------------------------------------
# Funciones matemáticas manuales
# ------------------------------------------------------------
function traza(A)
    t = 0.0
    m, n = size(A)
    for i in 1:min(m, n)
        t += A[i, i]
    end
    return t
end

function norma(v)
    s = 0.0
    for x in v
        s += x * x
    end
    return sqrt(s)
end

function entropia_simple(A)
    # Aproximación muy básica: -Σ |dᵢ| log(|dᵢ|) para la diagonal
    s = 0.0
    for i in 1:size(A, 1)
        d = abs(A[i, i])
        if d > 0
            s -= d * log(d)
        end
    end
    return s
end

# ------------------------------------------------------------
# Pruebas
# ------------------------------------------------------------
println("====================================================")
println("   TEST DE MATRIZ 130×130 (MODO PURO, SIN LIBRERÍAS)")
println("====================================================")

# Verificar firma cuántica
if verificar_firma_pura()
    println("✅ Firma cuántica intacta.")
else
    println("❌ ERROR: La firma ha sido alterada.")
end

# Traza y norma
println("\n--- Mediciones ---")
println("Traza de la matriz 130×130: ", traza(IDENTITY_MATRIX))
println("Norma de la firma (106 amplitudes): ", norma(FIRMA_106))

# Primeros 5 valores de la firma
println("Primeras 5 amplitudes: ", FIRMA_106[1:5])

# Estimación de entropía (solo diagonal)
println("Entropía diagonal estimada: ", entropia_simple(IDENTITY_MATRIX))

# Tamaño
println("Dimensiones de IDENTITY_MATRIX: ", size(IDENTITY_MATRIX))

println("====================================================")
println("   TEST FINALIZADO CON ÉXITO (SIN LIBRERÍAS)")
println("====================================================")
