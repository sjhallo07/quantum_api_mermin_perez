using Sockets, JSON, SHA, Printf, Random, Base.Threads

const POOL_HOST = "solo.ckpool.org"
const POOL_PORT = 3333
const WALLET    = "15nyNkzAAFw22Lz154VR7h8szZ3Ghdmi5m"
const WORKER    = "sovereign_chamberlain"
const PASSWORD  = "x"

const SHARE_TARGET = parse(BigInt, "0x00000000FFFF0000000000000000000000000000000000000000000000000000")

function double_sha256(data::Vector{UInt8})
    sha256(sha256(data))
end

function compute_merkle_root(coinb1, coinb2, extranonce1, extranonce2, merkle_branch)
    coinbase = coinb1 * extranonce1 * extranonce2 * coinb2
    coinbase_hash = double_sha256(hex2bytes(coinbase))
    root = coinbase_hash
    for branch in merkle_branch
        root = double_sha256(vcat(root, hex2bytes(branch)))
    end
    return bytes2hex(root)
end

function find_nonce_classic(header_prefix::Vector{UInt8}, target::BigInt)
    n = Threads.nthreads()
    found = Ref{UInt32}(0)
    done = Ref{Bool}(false)
    iter = cld(0x100000000, n)
    @threads for i in 1:n
        start = (i-1)*iter
        stop = min(start + iter - 1, 0xFFFFFFFF)
        for nonce in start:stop
            done[] && break
            header = [header_prefix; reinterpret(UInt8, [hton(UInt32(nonce))])]
            hash_int = parse(BigInt, bytes2hex(double_sha256(header)), base=16)
            if hash_int < target
                found[] = nonce
                done[] = true
                break
            end
        end
    end
    return found[]
end

function main()
    println("="^60)
    println("👑 CHAMBELÁN DEL ENVÍO – Share de Dificultad 1")
    println("="^60)
    println("Pool: $POOL_HOST:$POOL_PORT")
    println("Wallet: $WALLET")
    println("Hilos: $(Threads.nthreads())")
    println()

    sock = connect(POOL_HOST, POOL_PORT)

    write(sock, "{\"id\": 1, \"method\": \"mining.subscribe\", \"params\": []}\n")
    resp = JSON.parse(readline(sock))
    extranonce1 = resp["result"][2]
    extranonce2_size = resp["result"][3]
    println("📬 Suscrito. extranonce1 = $extranonce1, tamaño extranonce2 = $extranonce2_size")

    worker_auth = WALLET * "." * WORKER
    write(sock, "{\"id\": 2, \"method\": \"mining.authorize\", \"params\": [\"$worker_auth\", \"$PASSWORD\"]}\n")
    println("📨 Autorización enviada. Esperando confirmación...")

    authorized = false
    job = nothing
    while !authorized || job === nothing
        msg = readline(sock)
        parsed = JSON.parse(msg)
        if get(parsed, "id", nothing) == 2 && get(parsed, "result", nothing) == true
            authorized = true
            println("✅ Autorizado.")
        elseif get(parsed, "method", "") == "mining.set_difficulty"
            println("⚙️ Dificultad asignada: $(parsed["params"][1])")
        elseif get(parsed, "method", "") == "mining.notify"
            job = parsed["params"]
            println("🔔 Trabajo recibido: ID $(job[1])")
        end
    end

    job_id = job[1]
    prevhash = job[2]
    coinb1 = job[3]
    coinb2 = job[4]
    merkle_branch = job[5]
    version_hex = job[6]
    nbits_hex = job[7]
    ntime_hex = job[8]

    extranonce2 = string(rand(UInt32), base=16, pad=2*extranonce2_size)
    merkle_root_hex = compute_merkle_root(coinb1, coinb2, extranonce1, extranonce2, merkle_branch)
    merkle_root_le = reverse(hex2bytes(merkle_root_hex))
    version_int = parse(Int, version_hex, base=16)
    ntime_int = parse(Int, ntime_hex, base=16)

    header_prefix = vcat(
        reinterpret(UInt8, [hton(UInt32(version_int))]),
        reverse(hex2bytes(prevhash)),
        merkle_root_le,
        reinterpret(UInt8, [hton(UInt32(ntime_int))]),
        hex2bytes(nbits_hex)[end:-1:1]
    )
    @assert length(header_prefix) == 76

    println("⛏️  Buscando nonce (fuerza bruta clásica, dif=1)...")
    start_t = time()
    nonce = find_nonce_classic(header_prefix, SHARE_TARGET)
    elapsed = time() - start_t
    println("✅ Nonce encontrado: $nonce (en $elapsed segundos)")

    msg_submit = "{\"id\": 4, \"method\": \"mining.submit\", \"params\": [\"$worker_auth\", \"$job_id\", \"$extranonce2\", \"$ntime_hex\", \"$(string(nonce, base=16, pad=8))\"]}\n"
    write(sock, msg_submit)
    println("📤 Submit enviado. Aguardando respuesta exclusiva...")

    while true
        msg = readline(sock)
        parsed = JSON.parse(msg)
        if get(parsed, "id", nothing) == 4
            if get(parsed, "result", nothing) == true
                println("🎉 ¡Share aceptado! Vuestra cuenta ya está activa.")
                println("   Verificad en: http://solo.ckpool.org/users/$WALLET")
            else
                println("⚠️ Share rechazado. Error: ", get(parsed, "error", "desconocido"))
            end
            break
        else
            method = get(parsed, "method", "")
            if method == "mining.notify"
                println("   (Recibido nuevo trabajo, ignorando... ID: $(parsed["params"][1]))")
            elseif method == "mining.set_difficulty"
                println("   (Recibida nueva dificultad: $(parsed["params"][1]))")
            else
                println("   (Mensaje no relacionado con el submit)")
            end
        end
    end

    close(sock)
end

main()
