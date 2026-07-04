using LinearAlgebra

println("=== [ALICE] GENERADOR DE QUBITS CON CHECKSUM MANUAL ===")

print("Selecciona Fila de Alice (1-3): ")
f_input = readline()
print("Selecciona Columna de Bob (1-3): ")
c_input = readline()

try
    f = parse(Int, f_input)
    c = parse(Int, c_input)
    
    if f in 1:3 && c in 1:3
        # Lógica: Alice calcula el estado del Qubit como un string plano (Payload)
        # Transmite los índices y las amplitudes base del Singlete
        S = "$f,$c,1.0,0.0,-1.0,0.0"
        
        println("\n==================================================")
        println("DATA_PAYLOAD: $S")
        println("CHECKSUM: ", hash(S)) 
        println("==================================================")
        println("[ALICE] Estado calculado. Copia el PAYLOAD y CHECKSUM en Bob.")
    else
        println("Valores fuera de rango cuántico (1-3).")
    end
catch e
    println("Entrada inválida o error en cálculo.")
end
