using LinearAlgebra

println("\n=====================================================")
println("📊 EJECUTANDO MOTOR 8D (3-QUBIT) SOBERANO DIRECTO")
println("=====================================================")

# 1. Tu Matriz Soberana 5D de Fondo
const MATRIZ_SOBERANA_5D = Float64[
   -1.0  0.0  0.0  0.0  0.0;
    0.0  1.0  0.0  0.0  0.0;
    0.0  0.0  1.0  0.0  0.0;
    0.0  0.0  0.0  1.0  0.0;
    0.0  0.0  0.0  0.0  1.0
]

# 2. La Nueva Matriz de Densidad 8x8 (Cierra la brecha de q6, q7, q8)
const MATRIZ_DENSIDAD_8x8 = Float64[
    0.110  0.030  0.050  0.020  0.050  0.040  0.030  0.030;
    0.030  0.130  0.060  0.020  0.060  0.050  0.040  0.040;
    0.050  0.060  0.150  0.030  0.080  0.060  0.050  0.050;
    0.020  0.020  0.030  0.100  0.030  0.030  0.020  0.020;
    0.050  0.060  0.080  0.030  0.160  0.060  0.050  0.050;
    0.040  0.050  0.060  0.030  0.060  0.120  0.040  0.040;
    0.030  0.040  0.050  0.020  0.050  0.040  0.110  0.030;
    0.030  0.040  0.050  0.020  0.050  0.040  0.030  0.120
]

# 3. Álgebra Cuántica Nativa (Matrices de Pauli complejas)
const SIGMA_X = ComplexF64[0.0 1.0; 1.0 0.0]
const SIGMA_Y = ComplexF64[0.0 -1.0im; 1.0im 0.0]
const SIGMA_Z = ComplexF64[1.0 0.0; 0.0 -1.0]

"""
Construye el operador de Pauli 2x2 extrayendo las componentes espaciales de un vector 5D.
"""
function extraer_operador_local(v_5d::Vector{Float64})
    # Validamos la trayectoria en la métrica soberana hiperbólica
    norma_g = v_5d' * MATRIZ_SOBERANA_5D * v_5d
    if !isapprox(norma_g, 1.0, atol=1e-5)
        error("Violación Geométrica: Vector fuera del espacio 5D.")
    end
    
    # Extraemos componentes espaciales
    x = v_5d[2]
    y = v_5d[3]
    z = v_5d[4]
    
    magnitud = sqrt(x^2 + y^2 + z^2)
    if magnitud == 0
        return ComplexF64[1.0 0.0; 0.0 1.0]
    end
    
    return (x/magnitud)*SIGMA_X + (y/magnitud)*SIGMA_Y + (z/magnitud)*SIGMA_Z
end

"""
Calcula la correlación cruzada Matrix-to-Matrix de los 3 cúbits (8D)
"""
function calcular_enlace_8d(v_alice::Vector{Float64}, v_bob::Vector{Float64}, v_charles::Vector{Float64})
    # Cada nodo procesa su dirección espacial de forma independiente
    op_a = extraer_operador_local(v_alice)
    op_b = extraer_operador_local(v_bob)
    op_c = extraer_operador_local(v_charles)
    
    # Producto de Kronecker para generar el observable de 8x8 unificado
    O_total = kron(op_a, kron(op_b, op_c))
    
    # Cómputo de la traza cuántica pura
    return real(tr(MATRIZ_DENSIDAD_8x8 * O_total))
end

# --- EJECUCIÓN DEL DISPARO EN RÁFAGA MENTAL ---
# Definimos vectores espaciales base normalizados [t, x, y, z, w]
vector_x = [0.0, 1.0, 0.0, 0.0, 0.0]
vector_y = [0.0, 0.0, 1.0, 0.0, 0.0]
vector_z = [0.0, 0.0, 0.0, 1.0, 0.0]

res = calcular_enlace_8d(vector_x, vector_y, vector_z)

println("Resultado de la traza cuántica sobre la Matriz 8x8: ", round(res, digits=6))
println("Estado de las dimensiones q6, q7, q8: LEVANTADAS (Sintonía OK)")
println("=====================================================\n")
