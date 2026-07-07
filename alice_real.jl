using LinearAlgebra

if length(ARGS) < 1
    println("ERROR: Debes pasar el PID de Bob como argumento.")
    exit(1)
end

pid_bob = parse(Int, ARGS[1])

println("=== [ALICE] CONFIGURANDO EMISOR CUÁNTICO REAL ===")
println("Disparando colapso cuántico directo al PID $pid_bob a través de SIGURG...")

# Disparamos la señal 23 nativa
run(`kill -23 $pid_bob`)

println("[ALICE] Onda cuántica inyectada con éxito en la Terminal 2.")
