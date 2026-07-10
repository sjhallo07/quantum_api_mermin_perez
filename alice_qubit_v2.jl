using SHA

println("=== [ALICE] GENERADOR DE QUBITS SOBERANO V2 ===")

print("Selecciona Fila de Alice (1-3): ")
f_input = readline()
print("Selecciona Columna de Bob (1-3): ")
c_input = readline()

try
    f = parse(Int, f_input)
    c = parse(Int, c_input)

    if f in 1:3 && c in 1:3
        # Generación del Payload
        S = "$f,$c,1.0,0.0,-1.0,0.0"

        # Cálculo de hash criptográfico universal (SHA-256)
        chk = bytes2hex(sha256(S))

        println("\n==================================================")
        println("DATA_PAYLOAD: $S")
        println("CHECKSUM: $chk")
        println("==================================================")
        println("[ALICE] Estado calculado bajo protocolo SHA-256.")
        println("Copia el PAYLOAD y CHECKSUM en Bob.")
    else
        println("Valores fuera de rango cuántico (1-3).")
    end
catch e
    println("Entrada inválida o error en cálculo.")
end
