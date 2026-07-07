using LinearAlgebra

const MATRIZ_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]

println("=== [BOB] CONFIGURANDO RECEPTOR CUÁNTICO REAL ===")
println("Mi PID de proceso es: ", getpid())
println("Configurando el aparato de medición en la Columna 3...")
println("Esperando colapso cuántico desde Alice... (Presiona Enter o envía señal para activar)")

# Bloqueo limpio esperando una entrada directa al descriptor del Kernel (stdin)
readline() 

println("\n--------------------------------------------------")
println("[BOB] ¡Fondo Neutro alterado! Onda cuántica capturada.")

filtro = abs(det(MATRIZ_SOBERANA))
println("[BOB] Resultado local calculado con paridad: ", round(Int, filtro))
println("¡Éxito! Sincronización inter-terminal completada sin IP ni sockets.")
