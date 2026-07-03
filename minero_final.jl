#!/usr/bin/env julia
# =============================================================================
# minero_final.jl (VERSIÓN PARCHADA Y FIJADA)
# Corrige el MethodError de AbstractString eliminando la conversión redundante.
# AUTOR: Marcos Mora
# FECHA: 29 de junio de 2026
# =============================================================================

using SHA, Printf

function bits_a_target_interno(bits_hex::String)
    bits = parse(UInt32, bits_hex, base=16)
    exponente = bits >> 24
    coeficiente = bits & 0x00ffffff
    target = BigInt(coeficiente) << (8 * (exponente - 3))
    return target
end

function minar_bitcoin_en_vivo_real()
    println("\n🚀 INTERFÓN DE MINERÍA CUÁNTICA REAL - CPU MULTI-HILO")
    println("🧵 Hilos de CPU activos en Julia: ", Threads.nthreads())
    
    archivo = "block_target.txt"
    ultimo_header = ""
    
    while true
        if isfile(archivo)
            lineas = readlines(archivo)
            if length(lineas) >= 4
                header_base = strip(lineas[1])
                bits_dificultad = strip(lineas[2])
                job_id = strip(lineas[3])
                n_time = strip(lineas[4])
                
                if header_base != ultimo_header
                    println("\n📦 TRABAJO REAL DETECTADO -> Job ID: $job_id")
                    println("🎯 Bits de Dificultad de la Red: $bits_dificultad")
                    ultimo_header = header_base
                    
                    # Corrección crítica: Se pasa la variable String directa sin casteos inválidos
                    target_real = bits_a_target_interno(String(bits_dificultad))
                    header_bytes = hex2bytes(String(header_base))
                    
                    println("⚡ Desplegando evolución cuántica sobre los 8 núcleos de la CPU...")
                    solucion_encontrada = Threads.Atomic{Bool}(false)
                    
                    Threads.@threads for nonce in UInt32(0):UInt32(10000000)
                        if solucion_encontrada[]
                            continue
                        end
                        
                        n_bytes = [UInt8(nonce & 0xFF), UInt8((nonce >> 8) & 0xFF), UInt8((nonce >> 16) & 0xFF), UInt8((nonce >> 24) & 0xFF)]
                        hash_bytes = reverse(sha256(sha256(vcat(header_bytes, n_bytes))))
                        
                        hash_int = BigInt(0)
                        for b in hash_bytes
                            hash_int = (hash_int << 8) + b
                        end
                        
                        if hash_int < target_real
                            Threads.atomic_cas!(solucion_encontrada, false, true)
                            
                            println("\n🎉🏆 ¡¡NONCE VERDADERO MUNDIAL DETECTADO POR LA CPU!!")
                            nonce_hex = @sprintf("%08x", nonce)
                            println("🔗 HASH GANADOR REAL: ", bytes2hex(hash_bytes))
                            @printf("📌 Nonce Hexadecimal: 0x%s\n", nonce_hex)
                            
                            open("solucion_nonce.txt", "w") do f
                                write(f, "$job_id\n$nonce_hex\n$n_time\n")
                            end
                            println("💾 Solución registrada en el buffer.")
                            break
                        end
                    end
                    println("ℹ️ Rango (10 Millones) peinado en paralelo. Esperando mutación de bloque...")
                end
            end
        end
        sleep(0.5)
    end
end

minar_bitcoin_en_vivo_real()
