using Sockets, Printf

function find_valid_key()
    println("🔍 Iniciando búsqueda de resonancia 5D...")
    
    # Probamos 1000 variaciones basadas en tu semilla original
    for i in 0:1000
        # Generamos una semilla basada en el iterador
        seed = @sprintf("%016x", 0x8e8591b5c4e84428 + i)
        
        try
            client = connect("/tmp/quantum_kernel.sock")
            write(client, seed * "\n")
            response = readline(client)
            close(client)
            
            if occursin("5D_GRANTED", response)
                println("✅ ¡LLAVE ENCONTRADA! Resonancia lograda con semilla: $seed")
                return seed
            end
        catch e
            # El servidor podría estar ocupado
        end
    end
    println("❌ No se encontró resonancia en este rango de 1000 iteraciones.")
end

find_valid_key()
