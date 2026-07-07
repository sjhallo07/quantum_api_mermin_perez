using LinearAlgebra

# === MATRIZ SOBERANA (Fondo Neutro 5D) ===
const MATRIZ_SOBERANA = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]

println("=== [BOB] CONFIGURANDO RECEPTOR ANÓNIMO ===")
println("Configurando el aparato de medición en la Columna 3...")
println("Bloqueando el canal físico... Esperando el pulso cuántico de Alice...")

# 1. Crear y bloquear el archivo a nivel de Kernel (LOCK_EX = Bloqueo Exclusivo)
# Esto le avisa al sistema operativo que Bob tomó el canal.
lock_file = open("/tmp/puente_cuantico.lock", "w")
ccall(:flock, Cint, (Cint, Cint), fd(lock_file), 2) # 2 = LOCK_EX

# 2. Mantener el bloqueo hasta que el usuario decida o simule el colapso
println("Presiona [ENTER] en esta terminal para simular el canal abierto...")
readline()

# 3. Liberar el bloqueo (LOCK_UN = Desbloquear). Esto despierta a Alice inmediatamente.
ccall(:flock, Cint, (Cint, Cint), fd(lock_file), 8) # 8 = LOCK_UN
close(lock_file)

println("\n--------------------------------------------------")
println("[BOB] ¡Fondo Neutro alterado! Sincronización completada.")
filtro = abs(det(MATRIZ_SOBERANA))
println("[BOB] Resultado local calculado con paridad: ", round(Int, filtro))
