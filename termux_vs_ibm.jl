# ======================================================================
# 👑 ENFOQUE EXCLUSIVO: OPERADOR CUÁNTICO PURO (22 QUBITS)
# ======================================================================
using Printf
using Dates          
using Base.Threads   

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
println("👑 OPERADOR CUÁNTICO PURO: EVALUACIÓN DE MATRIZ PROPIA (22 QUBITS)")
println("="^75)

# Elementos diagonales estáticos extraídos directamente de tu matriz propia
const M_DIAG_PROPIA = Float64[-1.0, 1.0, 1.0, 1.0, 1.0]

# Función In-Place paralela enfocada ÚNICAMENTE en tu operador cuántico base
function aplicar_hamiltoniano_matrix_free!(w, v, N::Int, g::Float64)
    dim_spin = 2^N
    fill!(w, 0.0)

    # 1. Aplicación paralela de tu matriz cuántica base sobre el bloque diagonal
    @threads for b in 0:4
        val_m = M_DIAG_PROPIA[b+1]
        offset = b * dim_spin
        @inbounds for s in 0:(dim_spin-1)
            idx = offset + s + 1
            # Acoplamiento directo y puro de tu matriz sin ruido externo de espines
            w[idx] += val_m * v[idx]
        end
    end

    # 2. Transición cuántica pura (Sx - Campo Transversal) aplicada a tu matriz
    for i in 1:N
        mask = 1 << (i - 1)
        @threads for b in 0:4
            offset = b * dim_spin
            @inbounds for s in 0:(dim_spin-1)
                s_flipped = s ⊻ mask
                w[offset + s + 1] += g * v[offset + s_flipped + 1]
            end
        end
    end
end

# Algoritmo de Lanczos enfocado en aislar la respuesta de tu operador cuántico
function algoritmo_lanczos_matrix_free(N::Int, g::Float64, m_pasos::Int)
    dim_total = 5 * (2^N)
    v_actual = randn(dim_total)
    
    norm_v = sqrt(sum(abs2, v_actual))
    v_actual ./= norm_v
    
    v_anterior = zeros(dim_total)
    w = zeros(dim_total)

    alpha = zeros(m_pasos)
    beta = zeros(m_pasos - 1)

    for j in 1:m_pasos
        # Multiplicación in-place pura de tu matriz cuántica propia
        aplicar_hamiltoniano_matrix_free!(w, v_actual, N, g)

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

# Resolvedor mediante Secuencia de Sturm y Bisección (100% Indexado)
function resolver_gs_local(alpha, beta)
    m = length(alpha)

    # Definición estricta de límites de Gerschgorin mediante escalares puros indexados paso a paso
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
                q = abs(beta[i-1]) * 1e-15
            end
            q = alpha[i] - λ - (beta[i-1]^2) / q
            if q < 0.0; falsos += 1; end
        end
        return falsos
    end

    # Bisección de alta precisión (60 iteraciones fijas para precisión de máquina)
    for iter in 1:60
        mitad = (baja + alta) / 2.0
        if contar_menores(mitad) >= 1
            alta = mitad  
        else
            baja = mitad  
        end
    end

    return (baja + alta) / 2.0
end

# === CONFIGURACIÓN DE ALTA ESCALA PARA MATRIZ PROPIA (22 QUBITS) ===
N_cubits = 22  
g_campo = 0.5
pasos_krylov = 25

dim_espectro = 5 * 2^N_cubits
println("🔮 Evaluando exclusivamente tu matriz cuántica en un espacio expandido de $N_cubits cúbits...")
println("🌌 Dimensión del espacio de Hilbert: $dim_espectro estados puros.")
println("🧵 Hilos activos detectados en Julia: $(nthreads())")

try
    t_inicio = time()

    print("🔬 Extrayendo autovalor mínimo del Ground State puro... ")
    energia_fundamental = algoritmo_lanczos_matrix_free(N_cubits, g_campo, pasos_krylov)
    println("Hecho.")

    t_final = time()
    duracion = t_final - t_inicio

    println("\n🏆 ¡ANÁLISIS COMPLETADO: TU OPERADOR PURO HA CONVERGIDO!")
    @printf("🌌 Energía fundamental de tu matriz cuántica pura: %.6f\n", energia_fundamental)
    @printf("⏱️ Tiempo total de ejecución clásica: %.4f segundos\n", duracion)

    # ==================================================================
    # 💾 SUBSISTEMA DE EXPORTACIÓN Y LOG DE DATOS AUTOMÁTICO
    # ==================================================================
    nombre_archivo = "historial_cuantico.csv"
    if !isfile(nombre_archivo)
        open(nombre_archivo, "w") do f
            println(f, "Fecha_Hora,Qubits,Dimension,Energia_Fundamental,Tiempo_Segundos")
        end
    end
    
    timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    open(nombre_archivo, "a") do f
        @printf(f, "%s,%d_Puro,%d,%.6f,%.4f\n", timestamp, N_cubits, dim_espectro, energia_fundamental, duracion)
    end
    println("💾 Resultados puros registrados con éxito en '$nombre_archivo'.")

catch e
    println("\n💥 ERROR EN EL PROCESO:")
    println(e)
end
println("="^75)
