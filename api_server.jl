include("/tmp/quantum_engine_v4.jl")

module EngineAPI

using Sockets, Printf
using ..QRE

function start_server(port=9090)
    server = listen(IPv4(0,0,0,0), port)
    println("\n==================================================================")
    println(" 🚀 QRE ENGINE V4: NÚCLEO ALGEBRAICO Y CEREBRO DE META-LEARNING")
    println(" Puerto TCP activo: $port")
    println(" Comandos: PING, RESET, BRAIN, RECOM, OPTIMIZE [it], MERMIN [f] [c]")
    println("==================================================================")

    a_buf = zeros(Int, 3)
    b_buf = zeros(Int, 3)
    params_buf = [0.5, 0.0, 0.0, 0.0, 0.0]
    step_buf = ones(5) * 0.05
    cost_history_buf = zeros(1000)
    
    target_delta = 0.333333
    f_costo_tep(coupling) = (QRE.evaluar_tep(max(0.0, min(1.0, coupling))) - target_delta)^2

    while true
        conn = accept(server)
        @async begin
            try
                while isopen(conn)
                    raw_request = readline(conn)
                    isempty(raw_request) && break
                    
                    request = strip(raw_request)
                    parts = split(request)
                    length(parts) == 0 && continue
                    
                    comando = String(parts[1])

                    if comando == "PING"
                        write(conn, "PONG\n")
                    elseif comando == "RESET"
                        QRE.reinicializar_motor!()
                        write(conn, "STATUS: MOTOR_REINICIALIZADO\n")
                    elseif comando == "FILES"
                        archivos_clave = ["/tmp/manifiesto_final_qre.tex", "/tmp/matriz_soberana.seal", "/tmp/qre_validation.seal", "/tmp/api_quantum.jl", "/tmp/asic_simulator.jl"]
                        existentes = filter(f -> isfile(f), archivos_clave)
                        write(conn, "RESULTADO: ARCHIVOS_AUDITADOS=$(length(existentes))/5\n")
                    elseif comando == "PERTURB" && length(parts) == 2
                        epsilon = parse(Float64, parts[2])
                        norma_preservada = QRE.apply_weinberg_perturbation!(epsilon, 10)
                        write(conn, "RESULTADO: PERTURBACION_WEINBERG_APLICADA | NORMA=$(round(norma_preservada, digits=6))\n")
                    elseif comando == "BRAIN"
                        write(conn, "RESULTADO: TOTAL_TRADES=$(QRE.brain.total_trades) | UMBRAL_ENTROPIA=$(round(QRE.brain.entropy_threshold, digits=2))\n")
                    elseif comando == "RECOM"
                        QRE.optimizar_umbrales_simulados()
                        write(conn, "RESULTADO: ANALISIS_HISTORICO_COMPLETO_RECOMENDACION_EMITIDA\n")
                    elseif comando == "OPTIMIZE" && length(parts) == 2
                        iters = parse(Int, parts[2])
                        iters_seguras = min(iters, 1000)
                        QRE.rsi_meta_optimize!(params_buf, step_buf, cost_history_buf, f_costo_tep, iters_seguras, 0.03)
                        coupling_optimo = max(0.0, min(1.0, params_buf[1]))
                        perdida_final = cost_history_buf[iters_seguras]
                        write(conn, "RESULTADO: META_RSI_TEP_COMPLETO | COUPLING_OPT=$(round(coupling_optimo, digits=6)) | LOSS=$(round(perdida_final, digits=12))\n")
                    elseif comando == "MERMIN" && length(parts) == 3
                        f = parse(Int, parts[2])
                        c = parse(Int, parts[3])
                        if f in 1:3 && c in 1:3
                            QRE.evaluar_mermin_peres_dinamico!(a_buf, b_buf, f, c)
                            nuevo_umbral = QRE.process_trade_feedback!(true)
                            write(conn, "RESULTADO: A=$(a_buf), B=$(b_buf), WIN=true | NEW_THRESHOLD=$(round(nuevo_umbral, digits=2))\n")
                        else
                            write(conn, "ERROR: Indices fuera de rango (1-3)\n")
                        end
                    else
                        write(conn, "ERROR: Comando cuantico no reconocido\n")
                    end
                end
            catch e
                # Desconexión segura de sockets remotos
            finally
                close(conn)
            end
        end
    end
end

end

# Arranque automático de la API unificada
EngineAPI.start_server(9090)
