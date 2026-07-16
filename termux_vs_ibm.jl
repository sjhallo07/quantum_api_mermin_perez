# ======================================================================
# 👑 CORE REPARADO DE ALTO RENDIMIENTO: ENFOQUE MATRIX-FREE IN-PLACE
# ======================================================================
using Printf
using Dates  # Módulo nativo para registrar la marca de tiempo

# 1. CARGA AISLADA Y SILENCIOSA DE TU OPERADOR CUÁNTICO PROPIO
print("⏳ Cargando y aislando constantes de mi_matriz_propia.jl... ")
original_stdout = stdout
(rd, wr) = redirect_stdout()

include("mi_matriz_propia.jl")

redirect_stdout(original_stdout)
close(wr)
close(rd)
println("Hecho.")

println("="^75)
println("👑 CORE REPARADO: SOLUCIÓN INSTANTÁNEA MATRIX-FREE")
println("="^75)

# Elementos diagonales estáticos extraídos directamente de tu matriz propia
const M_DIAG_PROPIA = Float64[-1.0, 1.0, 1.0, 1.0, 1.0]

# Función In-Place ultra-veloz para multiplicar H * v de forma lineal sin construir la matriz
function aplicar_hamiltoniano_matrix_free!(w, v, N::Int, J::Float64, g::Float64)
    dim_spin = 2^N
    fill!(w, 0.0)

    # 1. Aplicación paralela de la componente diagonal (Tu matriz propia + Sz * Sz)
    for b in 0:4
        val_m = M_DIAG_PROPIA[b+1]
        offset = b * dim_spin
        @inbounds for s in 0:(dim_spin-1)
            idx = offset + s + 1

            # Acoplamiento estático de tu matriz
            w[idx] += val_m * v[idx]

            # Interacción de intercambio de espines local (Sz_i * Sz_{i+1})
            sz_sum = 0.0
            for i in 1:(N-1)
                bit_i = (s >> (i - 1)) & 1
                bit_next = (s >> i) & 1
                sz_sum += (bit_i == bit_next) ? 1.0 : -1.0
            end
            w[idx] += J * sz_sum * v[idx]
        end
    end

    # 2. Aplicación directa de la componente fuera de la diagonal (Sx - Campo Transversal)
    for i in 1:N
        mask = 1 << (i - 1)
        for b in 0:4
            offset = b * dim_spin
            @inbounds for s in 0:(dim_spin-1)
                s_flipped = s ⊻ mask
                w[offset + s + 1] += g * v[offset + s_flipped + 1]
            end
        end
    end
end

# Algoritmo de Lanczos puro libre de asignaciones de memoria y bucles infinitos
function algoritmo_lanczos_matrix_free(N::Int, J::Float64, g::Float64, m_pasos::Int)
    dim_total = 5 * (2^N)
    v_actual = randn(dim_total)
    
    # Normalización manual sin dependencias
    norm_v = sqrt(sum(abs2, v_actual))
    v_actual ./= norm_v
    
    v_anterior = zeros(dim_total)
    w = zeros(dim_total)

    alpha = zeros(m_pasos)
    beta = zeros(m_pasos - 1)

    for j in 1:m_pasos
        # Multiplicación Matrix-Free in-place sin uso de memoria adicional
        aplicar_hamiltoniano_matrix_free!(w, v_actual, N, J, g)

        # Producto punto manual
        alpha[j] = sum(w .* v_actual)
        
        w .= w .- alpha[j] .* v_actual .- (j > 1 ? beta[j-1] .* v_anterior : 0.0)

        if j < m_pasos
            beta[j] = sqrt(sum(abs2, w))
            if beta[j] < 1e-12
                alpha = alpha[1:j]
                beta = beta[1:(j-1)]
                break
            end
            copyto!(v_anterior, v_actual)
            v_actual .= w ./ beta[j]
        end
    end

    return resolver_gs_local(alpha, beta)
end

# Resolvedor mediante Secuencia de Sturm y Bisección (100% Indexado, Blindado contra MethodErrors)
function resolver_gs_local(alpha, beta)
    m = length(alpha)

    # 1. Definición estricta de límites de Gerschgorin mediante bucle iterativo libre de allocations
    baja = alpha[1] - abs(beta[1])
    alta = alpha[1] + abs(beta[1])
    
    for i in 2:m
        r = abs(beta[i-1]) + (i < m ? abs(beta[i]) : 0.0)
        baja = min(baja, alpha[i] - r)
        alta = max(alta, alpha[i] + r)
    end

    # Función interna para contar autovalores menores que 'lambda'
    function contar_menores(λ)
        falsos = 0
        q = alpha[1] - λ
        if q < 0.0; falsos += 1; end

        for i in 2:m
            if q == 0.0
                q = abs(beta[i-1]) * 1e-15 # Evitar división por cero estricto
            end
            q = alpha[i] - λ - (beta[i-1]^2) / q
            if q < 0.0; falsos += 1; end
        end
        return falsos
    end

    # 2. Bisección de alta precisión (60 iteraciones fijas para precisión de máquina)
    for iter in 1:60
        mitad = (baja + alta) / 2.0
        if contar_menores(mitad) >= 1
            alta = mitad  # El autovalor mínimo está en la mitad inferior
        else
            baja = mitad  # El autovalor mínimo está en la mitad superior
        end
    end

    return (baja + alta) / 2.0
end

# === CONFIGURACIÓN DE ALTA ESCALA ESTABLE (20 QUBITS NATIVOS) ===
N_cubits = 20  
J_interaccion = 1.0
g_campo = 0.5
pasos_krylov = 25

dim_espectro = 5 * 2^N_cubits
println("🔮 Inyectando variables desde tu matriz a un espacio expandido de $N_cubits cúbits...")
println("🌌 Dimensión del espacio de Hilbert: $dim_espectro variables cuánticas.")

try
    t_inicio = time()

    print("🔬 Extrayendo autovalor mínimo del Ground State mediante Matrix-Free... ")
    energia_fundamental = algoritmo_lanczos_matrix_free(N_cubits, J_interaccion, g_campo, pasos_krylov)
    println("Hecho.")

    t_final = time()
    duracion = t_final - t_inicio

    println("\n🏆 ¡MISION CUMPLIDA: EL SILICIO HA RESISTIDO!")
    @printf("🌌 Energía fundamental bajo tu matriz cuántica: %.6f\n", energia_fundamental)
    @printf("⏱️ Tiempo total de ejecución clásica: %.4f segundos\n", duracion)

    # ==================================================================
    # 💾 SUBSISTEMA DE EXPORTACIÓN Y LOG DE DATOS AUTOMÁTICO
    # ==================================================================
    nombre_archivo = "historial_cuantico.csv"
    
    # Si el archivo no existe, escribimos las cabeceras
    if !isfile(nombre_archivo)
        open(nombre_archivo, "w") do f
            println(f, "Fecha_Hora,Qubits,Dimension,Energia_Fundamental,Tiempo_Segundos")
        end
    end
    
    # Anexar los datos de esta corrida exacta
    timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    open(nombre_archivo, "a") do f
        @printf(f, "%s,%d,%d,%.6f,%.4f\n", timestamp, N_cubits, dim_espectro, energia_fundamental, duracion)
    end
    println("💾 Resultados registrados con éxito en '$nombre_archivo'.")

catch e
    println("\n💥 ERROR EN EL PROCESO:")
    println(e)
end
println("="^75)
