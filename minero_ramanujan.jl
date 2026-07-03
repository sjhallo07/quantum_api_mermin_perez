using JSON
using SHA # Asegúrate de tenerlo instalado, o usa hash() de Base

# Función de trabajo: Busca un nonce que cumpla una dificultad
function encontrar_nonce(datos_base, dificultad)
    nonce = 0
    objetivo = "0"^dificultad
    
    # Empezamos a trabajar
    while true
        # Creamos un hash del dato + nonce
        intento = string(datos_base, nonce)
        hash_resultado = bytes2hex(sha256(intento))
        
        # Verificamos si cumple la dificultad
        if startswith(hash_resultado, objetivo)
            return nonce, hash_resultado
        end
        nonce += 1
    end
end

# Ejecución
datos = "Ramanujan_Omega_Breach"
dificultad = 4 # Nivel de dificultad (0000...)
inicio = time()
nonce, resultado_hash = encontrar_nonce(datos, dificultad)
fin = time()

# Guardar resultados reales
datos_finales = Dict(
    "tiempo" => fin - inicio,
    "nonce" => nonce,
    "hash_final" => resultado_hash,
    "dificultad" => dificultad,
    "resultado" => "Validado"
)

open("results.json", "w") do f
    JSON.print(f, datos_finales)
end
println("✅ Minería completada. Nonce: $nonce, Tiempo: $(fin-inicio)s")
