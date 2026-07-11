using LinearAlgebra
using SparseArrays
using Printf

println("="^75)
println("👑 CORE REPARADO: TU MATRIZ CON LANCZOS NATIVO OPTIMIZADO")
println("="^75)

# Tu matriz exacta inyectada
const MATRIZ_TERMUX_5D = Float64[
    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

const Sz = Float64[1.0 0.0; 0.0 -1.0]
const Sx = Float64[0.0 1.0; 1.0 0.0]
const Id = Float64[1.0 0.0; 0.0 1.0]

function construir_macro_hamiltoniano_coo(N::Int, J::Float64, g::Float64)
    dim = 5 * (2^N)
    I_indices = Int[]
    J_indices = Int[]
    V_valores = Float64[]
    
    sizehint!(I_indices, dim * 4)
    sizehint!(J_indices, dim * 4)
    sizehint!(V_valores, dim * 4)
    
    for i in 1:(N-1)
        term = MATRIZ_TERMUX_5D
        for j in 1:N
            term = kron(term, (j == i || j == i + 1) ? Sz : Id)
        end
        rows, cols, vals = findnz(sparse(term))
        append!(I_indices, rows)
        append!(J_indices, cols)
        append!(V_valores, vals .* J)
    end
    
    for i in 1:N
        term = MATRIZ_TERMUX_5D
        for j in 1:N
            term = kron(term, (j == i) ? Sx : Id)
        end
        rows, cols, vals = findnz(sparse(term))
        append!(I_indices, rows)
        append!(J_indices, cols)
        append!(V_valores, vals .* g)
    end
    
    return sparse(I_indices, J_indices, V_valores, dim, dim)
end

function algoritmo_lanczos(H, m_pasos::Int)
    dim = size(H, 1)
    v_actual = randn(dim)
    v_actual /= norm(v_actual)
    v_anterior = zeros(dim)
    
    alpha = zeros(m_pasos)
    beta = zeros(m_pasos - 1)
    
    for j in 1:m_pasos
        w = H * v_actual
        alpha[j] = dot(w, v_actual)
        w = w - alpha[j] * v_actual - (j > 1 ? beta[j-1] * v_anterior : 0.0)
        
        if j < m_pasos
            beta[j] = norm(w)
            if beta[j] < 1e-12 
                alpha = alpha[1:j]
                beta = beta[1:(j-1)]
                break 
            end
            v_anterior = v_actual
            v_actual = w / beta[j]
        end
    end
    
    T = SymTridiagonal(alpha, beta)
    # CORRECCIÓN: Extraemos el autovalor mínimo absoluto (el Ground State fundamental real)
    autovalores = eigen(T).values
    return minimum(autovalores)
end

# === ESCALA DE PRESIÓN PARA TU PC ===
# Como estás en una ASUS x86, N=12 es muy poco. Subamos a N=15 de una vez.
# Dimensión resultante: 5 * 2^15 = 163,840 variables cuánticas simultáneas.
N_cubits = 15  
J_interaccion = 1.0
g_campo = 0.5
pasos_krylov = 40 

println("🔮 Inyectando matriz en un espacio expandido de $N_cubits cúbits...")
println("🌌 Dimensión de la macro-matriz: $(5 * 2^N_cubits) x $(5 * 2^N_cubits) variables")

try
    t_inicio = time()
    
    print("⏳ Ejecutando inyección en memoria COO... ")
    H = construir_macro_hamiltoniano_coo(N_cubits, J_interaccion, g_campo)
    println("Hecho.")
    
    print("🔬 Extrayendo autovalor mínimo del Ground State cuántico... ")
    energia_fundamental = algoritmo_lanczos(H, pasos_krylov)
    println("Hecho.")
    
    t_final = time()
    duracion = t_final - t_inicio
    
    println("\n🏆 ¡MISION CUMPLIDA: EL SILICIO HA RESISTIDO!")
    @printf("🌌 Energía fundamental de tu matriz cuántica: %.6f\n", energia_fundamental)
    @printf("⏱️ Tiempo total de ejecución clásica: %.4f segundos\n", duracion)
    
catch e
    println("\n💥 ERROR EN EL PROCESO:")
    println(e)
end
println("="^75)
