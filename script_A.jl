using LinearAlgebra

println("=== [SCRIPT A] - ALICE INICIANDO ===")

const MATRIZ_TERMUX_5D = Float64[
    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  1.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

const canal_ida = "/tmp/canal_ida"
const canal_vuelta = "/tmp/canal_vuelta"

# Limpieza de canales previos
rm(canal_ida, force=true)
rm(canal_vuelta, force=true)

println("[Alice] Enviando matriz a Bob por canal_ida...")
open(canal_ida, "w") do archivo
    for elemento in MATRIZ_TERMUX_5D
        println(archivo, elemento)
    end
end

println("[Alice] Matriz enviada. Esperando respuesta matemática de Bob...")

# Bucle de espera (Polling) hasta que Bob cree el canal de vuelta
while !isfile(canal_vuelta)
    sleep(0.5)
end

# Leer la respuesta matricial de Bob
lineas_recibidas = open(readlines, canal_vuelta, "r")
vector_recibido = [parse(Float64, strip(l)) for l in lineas_recibidas]
matriz_bob = reshape(vector_recibido, (5, 5))

println("\n[Alice] ¡Respuesta de Bob recibida!")
display(matriz_bob)

# Verificación de entrelazamiento completo (Alice multiplica su matriz por la de Bob)
verificacion = MATRIZ_TERMUX_5D * matriz_bob
traza_verificacion = tr(verificacion)
println("\n[Alice] Traza de verificación mutua: $traza_verificacion")

if traza_verificacion == 1.0
    println("✅ [Alice] CANAL SEGURO: El entrelazamiento matricial está intacto.")
else
    println("⚠️ [Alice] ALERTA: La firma no coincide. Posible interferencia.")
end
