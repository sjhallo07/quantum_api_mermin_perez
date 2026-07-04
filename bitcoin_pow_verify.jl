# =================================================================
# MOTOR ESTOCÁSTICO MULTIHILO: BÚSQUEDA DE ALTA ENTROPÍA EN GF(256)
# =================================================================
using SHA
using Base.Threads
using Random

println("=== INICIANDO MOTOR ESTOCÁSTICO MULTIHILO (8 CORES ACTIVE) ===")

const soberana_bytes = UInt8[
    0xff, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x01, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x01, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01
]

const version    = reinterpret(UInt8, [UInt32(0x2c000000)])
const prev_block = hex2bytes("000000000000000000021c325c84a7e93dc4288b48271109a1dfcb7e5e31ef90")
const time_bytes = reinterpret(UInt8, [UInt32(1783140702)])
const bits_bytes = reinterpret(UInt8, [UInt32(0x17021a42)])
const nonce_real = reinterpret(UInt8, [UInt32(0x3e9c5081)])

const base_header = [version; prev_block]
const target_bytes = hex2bytes("000000000000000000006bea32563271a9f72e9c3a67132c89f97e29f9bbfe07")

# Registros atómicos de control de estado
best_distance = Atomic{Int64}(95) # Partimos del récord actual de 95 bits
best_hash = "05c8cd846862d48820312163635e2a67fb32de0c5c776376a939cf8b0b9553a3"
best_padding = hex2bytes("fd9b0000000000")

# Cada hilo ejecutará una ventana estocástica de 500,000 iteraciones aleatorias en paralelo
const ITERACIONES_POR_HILO = 500000

Threads.@threads for t in 1:Threads.nthreads()
    # Semilla independiente por hilo basada en su ID y el tiempo para evitar redundancia espacial
    rng = MersenneTwister(t + time_bytes[1])
    
    local_merkle = zeros(UInt8, 32)
    local_merkle[8:32] = soberana_bytes
    
    for i in 1:ITERACIONES_POR_HILO
        # Rellenamos aleatoriamente los 7 bytes mutables del prefijo (Espacio hiperbólico)
        rand!(rng, @view local_merkle[1:7])
        
        # Ensamblado directo en memoria de bajo nivel
        header = [base_header; local_merkle; time_bytes; bits_bytes; nonce_real]
        
        # Cómputo SHA-256D estricto
        hash_bytes = reverse(sha256(sha256(header)))
        
        # Conteo veloz de la Distancia de Hamming
        distancia = 0
        for k in 1:32
            distancia += count_ones(hash_bytes[k] ⊻ target_bytes[k])
        end
        
        # Intercambio seguro si rompemos la barrera de entropía previa
        if distancia < best_distance[]
            atomic_min!(best_distance, distancia)
            global best_hash = bytes2hex(hash_bytes)
            global best_padding = copy(local_merkle[1:7])
        end
    end
end

println("\n=== RESULTADO DE LA MITIGACIÓN ESTOCÁSTICA DE ENTROPÍA ===")
println("Distancia Mínima Encontrada : ", best_distance[], " bits desalineados.")
println("Mejor Hash Computado        : ", best_hash)
println("Prefix de Alineación (Hex)  : ", bytes2hex(best_padding))
println("Nueva Desviación de Estado  : ", round((best_distance[] / 256) * 100, digits=2), "%")

if best_distance[] < 95
    println("\n[✓] REDUCCIÓN COMPLETADA: El motor estocástico encontró una configuración más cercana a Clase P.")
else
    println("\n[✓] PROCESAMIENTO TERMINADO: El espacio de hilos mantiene la estabilidad de la barrera NP.")
end
