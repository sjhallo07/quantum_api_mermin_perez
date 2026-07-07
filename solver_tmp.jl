
    using SHA
    using Base.Threads

    const prefix = hex2bytes("00000020000000000000000078930100254bae07e098fe6d9c477624d4d7a1c8b931ee175eb1be73989670aa00666bb7d01bd7eaf684b36661130a28712e5fb6dba2ec300697486a421a0217")
    const target = parse(BigInt, "00000000ffff0000000000000000000000000000000000000000000000000000", base=16)
    
    found_nonce = Atomic{Int64}(-1)
    found_done = Atomic{Bool}(false)
    
    # Paralelismo nativo multihilo en hilos reales de CPU
    Threads.@threads for t in 0:7
        if found_done[] break end
        chunk = 0xFFFFFFFF ÷ 8
        nonce_start = t * chunk + rand(1:100000)
        nonce_end = (t + 1) * chunk
        
        for nonce in nonce_start:nonce_end
            if found_done[] break end
            
            # Ensamblado ultrarrápido en memoria de bajo nivel
            header = Vector{UInt8}(undef, 80)
            copyto!(header, 1, prefix, 1, 76)
            header[77] = unsigned(nonce & 0xFF)
            header[78] = unsigned((nonce >> 8) & 0xFF)
            header[79] = unsigned((nonce >> 16) & 0xFF)
            header[80] = unsigned((nonce >> 24) & 0xFF)
            
            hash_val = sha256(sha256(header))
            
            # Evaluación veloz convirtiendo a BigInt Big-Endian
            hash_int = zero(BigInt)
            for b in hash_val
                hash_int = (hash_int << 8) + b
            end
            
            if hash_int < target
                atomic_xchg!(found_nonce, nonce)
                atomic_xchg!(found_done, true)
                break
            end
        end
    end
    println(found_nonce[])
    