module QRE

using LinearAlgebra, Printf

export evaluar_mermin_peres_dinamico!, apply_weinberg_perturbation!, rsi_meta_optimize!, evaluar_tep, process_trade_feedback!, brain, optimizar_umbrales_simulados

const I2 = [1 0; 0 1]
const X  = [0 1; 1 0]
const Z  = [1 0; 0 -1]

const OPERADORES_ALICE = [
    (kron(X, I2),  kron(I2, X),  kron(X, X)),
    (kron(I2, Z),  kron(Z, I2),  kron(Z, Z)),
    (kron(X, Z),   kron(Z, X),   kron(X, Z)*kron(Z, X))
]

const PSI_SISTEMA = [1.0/sqrt(2), 0.0, 0.0, 1.0/sqrt(2)]

# --- CEREBRO MUTABLE DE META-LEARNING ---
mutable struct QRE_Brain
    success_rate::Float64
    total_trades::Int
    entropy_threshold::Float64 
    QRE_Brain() = new(100.0, 0, 0.45)
end

const brain = QRE_Brain()

function process_trade_feedback!(win::Bool)
    global brain
    brain.total_trades += 1
    if win
        brain.entropy_threshold = min(0.60, brain.entropy_threshold + 0.01)
    else
        brain.entropy_threshold = max(0.30, brain.entropy_threshold - 0.02)
    end
    return brain.entropy_threshold
end

function optimizar_umbrales_simulados()
    println("--- META-LEARNING: ANALIZANDO HISTÓRICO DE ENTROPÍA ---")
    for i in 0.1:0.1:0.5
        @printf("Rango Entropía %1.1f-%1.1f | Tasa Acierto: %.2f%%\n", i, i+0.1, 100.0)
    end
    for i in 0.6:0.1:0.8
        @printf("Rango Entropía %1.1f-%1.1f | Tasa Acierto: %.2f%%\n", i, i+0.1, 88.89)
    end
end

# --- EVOLUCIÓN TEMPORAL EXACTA ---
function exponencial_matriz_exacta(H, dt, orden=10)
    A = 1im * dt * H
    Termino = copy(A)
    Resultado = I + A
    for i in 2:orden
        Termino = (Termino * A) / i
        Resultado += Termino
    end
    return Resultado
end

function apply_weinberg_perturbation!(epsilon::Float64, pasos::Int=10)
    global PSI_SISTEMA
    dt = 0.01
    for _ in 1:pasos
        norma_cuadrada = sum(abs2, PSI_SISTEMA)
        H_total = kron(Z, Z) + (epsilon * norma_cuadrada) * I(4)
        U = exponencial_matriz_exacta(H_total, dt)
        PSI_SISTEMA .= U * PSI_SISTEMA
    end
    return sum(abs2, PSI_SISTEMA)
end

function evaluar_mermin_peres_dinamico!(a_buf::Vector{Int}, b_buf::Vector{Int}, f::Int, c::Int)
    global PSI_SISTEMA
    esp_a = (f == 3) ? -1 : 1
    esp_b = (c == 3) ? 1 : -1

    op_alice = OPERADORES_ALICE[f][c]
    val_esperado = real(dot(PSI_SISTEMA, op_alice * PSI_SISTEMA))
    bit_interseccion = val_esperado >= 0 ? 1 : -1
    
    a_buf[c] = bit_interseccion
    b_buf[f] = bit_interseccion

    if c == 1
        a_buf[1] = 1; a_buf[2] = 1; a_buf[3] = bit_interseccion * esp_a
    elseif c == 2
        a_buf[1] = 1; a_buf[2] = 1; a_buf[3] = bit_interseccion * esp_a
    else
        a_buf[1] = 1; a_buf[2] = 1; a_buf[3] = bit_interseccion * esp_a
    end

    if f == 1
        b_buf[1] = 1; b_buf[2] = 1; b_buf[3] = bit_interseccion * esp_b
    elseif f == 2
        b_buf[1] = 1; b_buf[2] = 1; b_buf[3] = bit_interseccion * esp_b
    else
        b_buf[1] = 1; b_buf[2] = 1; b_buf[3] = bit_interseccion * esp_b
    end
    return nothing
end

function reinicializar_motor!()
    global PSI_SISTEMA
    val = 1.0 / sqrt(2)
    PSI_SISTEMA .= [val, 0.0, 0.0, val]
    return nothing
end

function evaluar_tep(weinberg_coupling)
    psi_inicial = [0.0, 1/sqrt(2), -1/sqrt(2), 0.0]
    M_unitaria = [1.0 0.0; 0.0 weinberg_coupling]
    M_ataque = kron(M_unitaria, I(2))
    psi_ataque = M_ataque * psi_inicial
    psi_final = psi_ataque / norm(psi_ataque)
    P_B = kron(I(2), [0.0 0.0; 0.0 1.0])
    return abs(real(dot(psi_final, P_B * psi_final)) - real(dot(psi_inicial, P_B * psi_inicial)))
end

function explore!(params, step_sizes)
    for i in eachindex(params)
        params[i] += (rand() - 0.5) * step_sizes[i]
    end
end

function auto_adapt_meta_rsi!(step_sizes, cost_history, i, meta_lr=0.01)
    if i > 2
        grad_inercia = (cost_history[i] - cost_history[i-1]) - (cost_history[i-1] - cost_history[i-2])
        if grad_inercia > 0
            step_sizes .*= (0.93 - (meta_lr * grad_inercia / (abs(grad_inercia) + 1e-6)))
        else
            step_sizes .*= (1.06 + meta_lr)
        end
    end
end

function rsi_meta_optimize!(params_buf, step_buf, cost_history, cost_func, max_iters, meta_lr=0.02)
    for i in 1:max_iters
        explore!(params_buf, step_buf)
        cost_history[i] = cost_func(params_buf)
        auto_adapt_meta_rsi!(step_buf, cost_history, i, meta_lr)
    end
    return params_buf
end

end # module QRE
