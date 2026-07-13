using .Ecosistema
include("soberania_absoluta.jl")
using LinearAlgebra
using Printf

    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  1.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]


# --- INYECCIÓN GLOBAL 8D (Evita truncamiento de q6, q7, q8) ---
    0.110  0.030  0.050  0.020  0.050  0.040  0.030  0.030;
    0.030  0.130  0.060  0.020  0.060  0.050  0.040  0.040;
    0.050  0.060  0.150  0.030  0.080  0.060  0.050  0.050;
    0.020  0.020  0.030  0.100  0.030  0.030  0.020  0.020;
    0.050  0.060  0.080  0.030  0.160  0.060  0.050  0.050;
    0.040  0.050  0.060  0.030  0.060  0.120  0.040  0.040;
    0.030  0.040  0.050  0.020  0.050  0.040  0.110  0.030;
    0.030  0.040  0.050  0.020  0.050  0.040  0.030  0.120
]
    0.2500  0.3500  0.2600  0.2510;
    0.3500  0.2500  0.3500  0.2600;
    0.2600  0.3500  0.2500  0.3500;
    0.2510  0.2600  0.3500  0.2500
]

const TARGET_DELTA = 0.332838          
const WEINBERG_INICIAL = 0.44856123    

const BUFFER_PSI_INICIAL = [0.0, 1/sqrt(2), -1/sqrt(2), 0.0]
const BUFFER_PSI_ATAQUE  = zeros(4)
const BUFFER_PSI_FINAL   = zeros(4)

function evaluar_tep_soberano(weinberg_coupling)
    factor_soberano = abs(Ecosistema.METRICA_SOBERANA_5D[1,1])
    
    BUFFER_PSI_ATAQUE[1] = BUFFER_PSI_INICIAL[1] * factor_soberano
    BUFFER_PSI_ATAQUE[2] = BUFFER_PSI_INICIAL[2] * factor_soberano
    BUFFER_PSI_ATAQUE[3] = BUFFER_PSI_INICIAL[3] * weinberg_coupling
    BUFFER_PSI_ATAQUE[4] = BUFFER_PSI_INICIAL[4] * weinberg_coupling

    sum_sq = 0.0
    for i in 1:4
        @inbounds sum_sq += BUFFER_PSI_ATAQUE[i]^2
    end
    norma_tras_ataque = sqrt(sum_sq)

    for i in 1:4
        @inbounds BUFFER_PSI_FINAL[i] = BUFFER_PSI_ATAQUE[i] / norma_tras_ataque
    end

    val_B_inicial = (BUFFER_PSI_INICIAL[2]^2) + (BUFFER_PSI_INICIAL[4]^2)
    val_B_final   = (BUFFER_PSI_FINAL[2]^2)   + (BUFFER_PSI_FINAL[4]^2)

    return abs(val_B_final - val_B_inicial)
end

function ejecutar_rsi_learning()
    lr = 0.1
    max_epocas = 50
    opt_coupling = WEINBERG_INICIAL

    @time begin
        for epoca in 1:max_epocas
            delta_actual = evaluar_tep_soberano(opt_coupling)
            loss = (delta_actual - TARGET_DELTA)^2

            if isnan(loss) || isinf(loss) || delta_actual > 1.0
                break
            end

            h = 1e-5
            delta_plus = evaluar_tep_soberano(opt_coupling + h)
            loss_plus = (delta_plus - TARGET_DELTA)^2
            gradiente = (loss_plus - loss) / h

            opt_coupling -= lr * gradiente
            opt_coupling = max(0.0, min(1.0, opt_coupling))

            if loss < 1e-8
                println("[RSI SUCCESS] Convergencia alcanzada.")
                break
            end
        end
    end
end

println("======================================================================")
println("--- PASADA 1: Con sobrecarga de compilación JIT ---")
println("======================================================================")
ejecutar_rsi_learning()

println("\n======================================================================")
println("--- PASADA 2: Métricas nativas del motor en caliente (0-ALLOC) ---")
println("======================================================================")
ejecutar_rsi_learning()
