println("=== [ALICE] CONFIGURANDO EMISOR ANÓNIMO ===")
println("Intentando acoplarse al Fondo Neutro en /tmp/puente_cuantico.lock...")

# Alice intenta abrir el mismo archivo y pide un bloqueo. 
# Como Bob lo tiene retenido, el Kernel congela a Alice aquí en 0% CPU hasta que Bob lo suelte.
lock_file = open("/tmp/puente_cuantico.lock", "w")
ccall(:flock, Cint, (Cint, Cint), fd(lock_file), 2) 

println("[ALICE] ¡Conexión cuántica establecida! Onda inyectada con éxito.")
close(lock_file)
