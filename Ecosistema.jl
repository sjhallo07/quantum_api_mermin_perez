module Ecosistema
    using LinearAlgebra
    using Distributions
    
    export IDENTIDAD_8X8, PAULI_X, PAULI_Z, OPERADOR_ESPIN, ESTABILIZADOR_AV, ESTABILIZADOR_BP, GL, DISTRIBUCION_BASE, METRICA_SOBERANA_5D, DENSIDAD_4X4
    
    # Base Maestro
    const IDENTIDAD_8X8 = Matrix{Float64}(I, 8, 8)
    const GL = 9
    const DISTRIBUCION_BASE = Wishart(GL, IDENTIDAD_8X8)
    
    # Operadores
    const I2 = Matrix{Float64}(I, 2, 2)
    const X2 = Float64[0 1; 1 0]
    const Z2 = Float64[1 0; 0 -1]
    const PAULI_X = kron(X2, kron(X2, X2))
    const PAULI_Z = kron(Z2, kron(Z2, Z2))
    const OPERADOR_ESPIN = kron(I2, Z2)
    const ESTABILIZADOR_AV = kron(X2, X2)
    const ESTABILIZADOR_BP = kron(Z2, Z2)
    
    # Métricas de Aprendizaje (Previamente dispersas)
    const METRICA_SOBERANA_5D = Float64[-1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]
    const DENSIDAD_4X4 = Float64[0.25 0.35 0.26 0.251; 0.35 0.25 0.35 0.26; 0.26 0.35 0.25 0.35; 0.251 0.26 0.35 0.25]

# --- INTEGRACIÓN AUTOMÁTICA DE ARCHIVOS DEL ROOT ---
using JSON

export CARGAR_FASE_II_JSON, EJECUTAR_TELEMETRIA_ROOT

# Conexión directa con qre_phase_ii.json
function CARGAR_FASE_II_JSON()
    if isfile("qre_phase_ii.json")
            return JSON.parsefile("qre_phase_ii.json")
                else
        println("[-] Alerta: qre_phase_ii.json no encontrado.")
                return nothing
    end
end

# Wrapper unificado para invocar los scripts del root desde el ecosistema
function EJECUTAR_TELEMETRIA_ROOT(script::String)
    archivos_validos = [
        # --- Núcleo Mermin-Peres ---
        "procesador_documentos.jl", "mermin_peres.jl", "mermin_peres_8d_puro.jl", "mermin_peres_real.jl", "alice_bob_matrices.jl",
                # --- Criptografía, PoW y Validadores ---
        "bitcoin_pow_verify.jl", "minero_ramanujan.jl", "pow_miner.jl", "sellar_matriz.jl", "sellar_qre.jl", "detector_integridad.jl",
                # --- Simulaciones de Cuerdas y Relativistas ---
        "polyakov_action.jl", "polchinski_real.jl", "polchinski_breach.jl", "mapeador_fisico.jl",
                # --- Aprendizaje y Orquestación ---
        "meta_learning_tep.jl", "integrar_aprendizaje_8d.jl", "orquestador_quantum_engine.jl", "p_vs_np_simulation.jl",
                # --- Telemetría Previa ---
        "test_learning.jl", "validar_calculo.jl", "verificador_nonce.jl", "verificar_qre.jl", "verificar_target_real.jl"
            ]
                
                    if script in archivos_validos && isfile(script)
                            println("[+] Ejecutando componente indexado en Root: ", script)
                                    println("--- INICIO DE EJECUCIÓN ---")
        include(script)
                println("--- FIN DE EJECUCIÓN ---")
    else
        println("[-] Error: El componente '", script, "' no está indexado o no existe en el root.")
            end
end

    export MATRIZ_MITIGADA_ZNE, CARGAR_MATRIZ_MITIGADA
        
            # Función nativa acoplada para inyectar la matriz limpia en cualquier script
                function CARGAR_MATRIZ_MITIGADA()
                        if isfile("matrices_output.json")
                                    raw = JSON.parsefile("matrices_output.json")
                                                datos_raw = raw["matriz_mitigada_clean"]
                                                            # Re-convertir el vector de vectores JSON a una Matrix flotante nativa de Julia
            return hcat(datos_raw...)' |> Matrix{Float64}
                    else
            println("[-] Error: matrices_output.json ausente.")
            return nothing
        end
    end

    export CARGAR_HAMILTONIANO_META, CARGAR_DISIPACION_META
        
            function CARGAR_HAMILTONIANO_META()
                    if isfile("matriz_instagram_106x106.json")
                                raw = JSON.parsefile("matriz_instagram_106x106.json")
                                            return hcat(raw["H_efectivo"]...)' |> Matrix{Float64}
                                                    else
            println("[-] Error: archivo de Meta ausente.")
                        return nothing
        end
    end

    function CARGAR_DISIPACION_META()
            if isfile("matriz_instagram_106x106.json")
                        raw = JSON.parsefile("matriz_instagram_106x106.json")
                                    return hcat(raw["Gamma_disipacion"]...)' |> Matrix{Float64}
                                            else
            return nothing
        end
    end
\nend # Fin del módulo unificado expandido
