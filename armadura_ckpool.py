#!/usr/bin/env python3
"""
ARMADURA HÍBRIDA QUANTUM STRATUM – INFRAESTRUCTURA DE ALTA VELOCIDAD
=====================================================================
Python maneja el protocolo de red y delega la fuerza bruta criptográfica a Julia.
Satura el procesador de forma nativa a nivel de código de máquina para batir el pool.
"""
import socket, json, hashlib, struct, random, time, subprocess, sys
from binascii import hexlify, unhexlify

POOL_HOST = "solo.ckpool.org"
POOL_PORT = 3333
WALLET    = "15nyNkzAAFw22Lz154VR7h8szZ3Ghdmi5m"
WORKER    = "armadura_real"
PASSWORD  = "x"

def double_sha256(data):
    return hashlib.sha256(hashlib.sha256(data).digest()).digest()

def generar_extranonce2_cuantico(size_bytes):
    matriz_plana = bytes([
        0xff, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x01, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x01, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01
    ])
    hash_matriz = hashlib.sha256(matriz_plana).digest()
    return hexlify(hash_matriz[:size_bytes]).decode('ascii')

def compute_merkle_root(coinb1, coinb2, extra1, extra2, branches):
    coinbase = coinb1 + extra1 + extra2 + coinb2
    coinbase_hash = double_sha256(unhexlify(coinbase))
    root = coinbase_hash
    for branch in branches:
        root = double_sha256(root + unhexlify(branch))
    return hexlify(root).decode('ascii')

class StratumClient:
    def __init__(self, host, port):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((host, port))
        self.extra1 = None
        self.extra2_size = 0
        self.difficulty = 10000
        self.job = None

    def send(self, msg):
        self.sock.sendall((json.dumps(msg) + "\n").encode())

    def recv(self):
        data = b""
        while True:
            chunk = self.sock.recv(1)
            if not chunk: break
            data += chunk
            if chunk == b"\n":
                return json.loads(data.decode().strip())
        return None

    def subscribe(self):
        self.send({"id": 1, "method": "mining.subscribe", "params": ["armor/1.0", "EthereumStratum/1.0.0"]})
        resp = self.recv()
        self.extra1 = resp['result'][1]
        self.extra2_size = resp['result'][2]

    def authorize(self):
        self.send({"id": 2, "method": "mining.authorize", "params": [WALLET + "." + WORKER, PASSWORD]})

    def wait_for_job_and_difficulty(self):
        got_job = False
        got_diff = False
        while not (got_job and got_diff):
            msg = self.recv()
            if msg is None: continue
            method = msg.get("method")
            if method == "mining.notify":
                self.job = msg["params"]
                got_job = True
            elif method == "mining.set_difficulty":
                self.difficulty = msg["params"][0]
                got_diff = True
            elif msg.get("id") == 2 and msg.get("result") == True:
                print("✅ Autorizado.")
        print(f"📊 Dificultad asignada por el pool: {self.difficulty}")

# ------------------------------------------------------------------------------
# GENERACIÓN DINÁMICA DEL SOLVER EN JULIA (MÁXIMO RENDIMIENTO NATIVO)
# ------------------------------------------------------------------------------
def invocar_solver_julia(header_prefix_hex, target_hex):
    julia_code = f"""
    using SHA
    using Base.Threads

    const prefix = hex2bytes("{header_prefix_hex}")
    const target = parse(BigInt, "{target_hex}", base=16)
    
    found_nonce = Atomic{{Int64}}(-1)
    found_done = Atomic{{Bool}}(false)
    
    # Paralelismo nativo multihilo en hilos reales de CPU
    Threads.@threads for t in 0:7
        if found_done[] break end
        chunk = 0xFFFFFFFF ÷ 8
        nonce_start = t * chunk + rand(1:100000)
        nonce_end = (t + 1) * chunk
        
        for nonce in nonce_start:nonce_end
            if found_done[] break end
            
            # Ensamblado ultrarrápido en memoria de bajo nivel
            header = Vector{{UInt8}}(undef, 80)
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
    """
    
    # Escribimos el script temporal de Julia para ejecución directa
    with open("solver_tmp.jl", "w") as f:
        f.write(julia_code)
        
    # Invocamos a Julia forzando el uso de todos los hilos en paralelo real
    res = subprocess.check_output(["julia", "-t", "auto", "solver_tmp.jl"])
    return int(res.decode().strip())

def main():
    print("=" * 60)
    print("👑 ARMAZÓN HÍBRIDO PYTHON-JULIA (BARRERA DE TIEMPO ROTA)")
    print("=" * 60)
    
    client = StratumClient(POOL_HOST, POOL_PORT)
    client.subscribe()
    client.authorize()
    client.wait_for_job_and_difficulty()
    
    job = client.job
    job_id, prevhash, coinb1, coinb2, merkle_branch, version, nbits_hex, ntime_hex = job[0:8]
    
    extranonce2 = generar_extranonce2_cuantico(client.extra2_size)
    print(f"🧬 Extranonce2 generado desde Matriz Soberana: {extranonce2}")
    
    merkle_root_hex = compute_merkle_root(coinb1, coinb2, client.extra1, extranonce2, merkle_branch)
    merkle_root_le = unhexlify(merkle_root_hex)[::-1]
    
    ver_int   = int(version, 16) if isinstance(version, str) else version
    ntime_int = int(ntime_hex, 16) if isinstance(ntime_hex, str) else ntime_hex
    
    header_prefix = (
        struct.pack("<I", ver_int) +
        unhexlify(prevhash)[::-1] +
        merkle_root_le +
        struct.pack("<I", ntime_int) +
        unhexlify(nbits_hex)[::-1]
    )
    
    # Forzamos Target D1 de paridad rápida
    target_hex = "00000000ffff0000000000000000000000000000000000000000000000000000"
    header_prefix_hex = hexlify(header_prefix).decode()
    
    print("⛏️  Transfiriendo espacio lineal a Julia Solver nativo (8 Cores)...")
    start = time.time()
    nonce = invocar_solver_julia(header_prefix_hex, target_hex)
    elapsed = time.time() - start
    
    if nonce == -1:
        print("❌ Reintentando con el siguiente bloque asignado...")
        client.sock.close()
        return
        
    print(f"✅ Nonce colapsado por Julia: {nonce} (0x{nonce:08x}) en {elapsed:.2f} segundos")
    
    # Submit inmediato a CKPool
    payload = {
        "id": 4,
        "method": "mining.submit",
        "params": [WALLET + "." + WORKER, job_id, extranonce2, ntime_hex, format(nonce, '08x')]
    }
    
    print("📤 Transmitiendo paquete de paridad al pool...")
    client.send(payload)
    
    response = client.recv()
    print(f"📥 Confirmación de CKPool: {response}")
    client.sock.close()
    print("🔌 Canal de comunicación cerrado limpiamente.")

if __name__ == "__main__":
    main()
