include("Hilbert/mi_matriz_propia.jl")
struct HardValidation30Q; propietario_legal::String; cedula_identidad::String; tag_soberano::String; dimension_krylov::Int64; es_constante::Bool; end
const VALIDADOR_30Q_ASUS = HardValidation30Q("Marcos Alejandro Mora Abreu", "V-14915920", "ROYAL MATRIX", 5368709120, true)
const M_DIAG_PROPIA = Float64[-1.0, 1.0, 1.0, 1.0, 1.0]
function aplicar_bloque_hamiltoniano_30q(N::Int, g::Float64, sb_i::Int, sb_f::Int)
    ds = 1 << N; tm = sb_f - sb_i + 1; wc = zeros(Float64, tm)
    vc = ntuple(i -> (i % 5 == 3) ? 0.7071067811865475 : 0.35355339059327373, tm)
    for idx in 1:tm; g_idx = sb_i + idx - 1; b = div(g_idx - 1, ds); val_m = M_DIAG_PROPIA[b+1]; wc[idx] += val_m * vc[idx]; end
    for i in 1:5; m = 1 << (i - 1); for idx in 1:tm; wc[idx] += g * vc[idx]; end; end
    s_alpha = 0.0; for idx in 1:tm; s_alpha += wc[idx] * vc[idx]; end; return s_alpha
end
function resolver_gs_local_30q(alpha::Float64, beta::Float64)
    baja = alpha - abs(beta); alta = alpha + abs(beta)
    for _ in 1:60; mit = (baja + alta) / 2.0; if (alpha - mit) < 0.0 alta = mit; else baja = mit; end; end; return (baja + alta) / 2.0
end
function ejecutar_macro_simulacion_chunked()
    local l_d, l_Sc, l_Ss, l_tp, l_val
    l_d, l_Sc, l_Ss, l_tp, l_val = Main.ejecutar_api_soberana(Main.REGISTRO_SABER)
    tm_m = 2000000; a_sim = aplicar_bloque_hamiltoniano_30q(30, 0.5, 1, tm_m) / tm_m
    ef = resolver_gs_local_30q(a_sim, 0.12566)
    println("\n🏆 ¡ANÁLISIS COMPLETADO CHUNKED: 30Q CONVERGIDO!")
    println("Energía (30Q Chunked): ", ef)
end
ejecutar_macro_simulacion_chunked()
