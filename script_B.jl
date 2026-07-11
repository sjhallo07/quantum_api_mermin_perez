using LinearAlgebra

println("=== [SCRIPT B] - BOB PROCESANDO ===")
const canal_ida = "/tmp/canal_ida"
const canal_vuelta = "/tmp/canal_vuelta"

if !isfile(canal_ida)
    error("❌ El archivo /tmp/canal_ida no existe. Ejecuta primero script_A.jl")
end

lineas_recibidas = open(readlines, canal_ida, "r")
vector_recibido = [parse(Float64, strip(l)) for l in lineas_recibidas]
matriz_alice = reshape(vector_recibido, (5, 5))

# Matriz base local de Bob
const MATRIZ_BOB_5D = Float64[
     1.0  0.0  0.0  0.0  0.0;
     0.0 -1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0 -1.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

resultado_operacion = matriz_alice * MATRIZ_BOB_5D
traza_final = tr(resultado_operacion)

println("\n[Bob] Firma cuántica calculada: $traza_final")

# Bob genera una respuesta matricial dinámica basada en el resultado obtenido
# Si es negativo, invierte los signos de su matriz para estabilizar el canal de vuelta
matriz_respuesta = traza_final < 0 ? MATRIZ_BOB_5D * -1.0 : MATRIZ_BOB_5D

println("[Bob] Enviando matriz de respuesta de vuelta a Alice...")
open(canal_vuelta, "w") do archivo
    for elemento in matriz_respuesta
        println(archivo, elemento)
    end
end
println("[Bob] Proceso terminado.")
