include("soberania_absoluta.jl")
using LinearAlgebra
using SparseArrays
using Printf

println("="^75)
println("📱 TERMUX QUANTUM v2: GRADIENTE ANALÍTICO + ROMPE-MESETAS")
println("="^75)

function construir_operadores_coo(N::Int)
    dim = 2^N
    H_C_diagonal = zeros(Float64, dim)
    for i in 1:N
        j = (i == N) ? 1 : i + 1
        for idx in 0:(dim-1)
            bit_i = (idx >> (N - i)) & 1
            bit_j = (idx >> (N - j)) & 1
            spin_i = bit_i == 0 ? 1.0 : -1.0
            spin_j = bit_j == 0 ? 1.0 : -1.0
            H_C_diagonal[idx + 1] += spin_i * spin_j
        end
    end
    return H_C_diagonal
end

function simular_qaoa_eficiente(gamma, beta, H_C_diag, N)
    dim = 2^N
    psi = ones(ComplexF64, dim) / sqrt(dim)
    psi = psi .* exp.(-im * gamma .* H_C_diag)
    for i in 1:N
        sh = 1 << (N - i)
        for idx in 0:(dim-1)
            if (idx & sh) == 0
                idx1 = idx + 1
                idx2 = idx + sh + 1
                a = psi[idx1]
                b = psi[idx2]
                psi[idx1] = cos(beta)*a - im*sin(beta)*b
                psi[idx2] = -im*sin(beta)*a + cos(beta)*b
            end
        end
    end
    return real(sum(conj(psi) .* H_C_diag .* psi))
end

N_cubits = 10  
H_C_diag = construir_operadores_coo(N_cubits)

# Inicialización fija fuera del punto crítico de la meseta
gamma = 0.1 
beta = 0.5  

println("🔮 Optimizando circuito cuántico rompiendo la simetría...")
t_inicio = time()

pasos = 25
learning_rate = 0.15

for paso in 1:pasos
    global gamma, beta
    E_actual = simular_qaoa_eficiente(gamma, beta, H_C_diag, N_cubits)
    
    shift = π / 2
    d_gamma = (simular_qaoa_eficiente(gamma + shift, beta, H_C_diag, N_cubits) - 
               simular_qaoa_eficiente(gamma - shift, beta, H_C_diag, N_cubits)) / 2.0
               
    d_beta  = (simular_qaoa_eficiente(gamma, beta + shift, H_C_diag, N_cubits) - 
               simular_qaoa_eficiente(gamma, beta - shift, H_C_diag, N_cubits)) / 2.0
    
    # --- MECANISMO ROMPE-MESETAS ---
    # Si el gradiente es peligrosamente cercano a cero, inyectamos una pequeña perturbación cuántica
    if abs(d_gamma) < 1e-5 && abs(d_beta) < 1e-5
        d_gamma += (rand() - 0.5) * 0.2
        d_beta += (rand() - 0.5) * 0.2
    end
    
    gamma -= learning_rate * d_gamma
    beta  -= learning_rate * d_beta
    
    if paso % 5 == 0 || paso == 1
        @printf("⚙️ Iteración %02d | Energía Cuántica: %.6f | Ajuste Real [γ: %.4f, β: %.4f]\n", 
                paso, E_actual, d_gamma, d_beta)
    end
end

duracion = time() - t_inicio
println("\n🏆 RETO TERMUX COMPLETADO CON ÉXITO")
@printf("⏱️ Tiempo de cómputo en tu móvil: %.4f segundos\n", duracion)
@printf("📐 Ángulos finales optimizados: γ = %.4f, β = %.4f\n", gamma, beta)
println("="^75)
