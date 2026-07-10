using LinearAlgebra

# 1. Definición de las Métricas Soberanas 5D
const MATRIZ_A_5D = Float64[-1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]

# 2. Vectores de Estado
vector_inicial = [2.0, 3.0, 1.0, 0.0, 4.0]
println("[Script A] Estado Inicial Colapsado: ", vector_inicial)

# 3. Operación de Ida en el Servidor A
vector_resultado = MATRIZ_A_5D * vector_inicial

# 4. Creación de Canales de Memoria Puros (RAM del Kernel)
pipe_ida = Pipe()
pipe_vuelta = Pipe()

# Código inline para el Nodo B (Procesa exactamente 5 líneas y cierra para evitar deadlocks)
codigo_nodo_b = """
using LinearAlgebra
M_B = [-1.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0; 0.0 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0 1.0]
v_recibido = Float64[]
for i in 1:5
    push!(v_recibido, parse(Float64, readline(stdin)))
end
v_respuesta = M_B * v_recibido
for x in v_respuesta
    println(stdout, x)
end
"""

# 5. Lanzamiento asíncrono del Proceso B entrelazando las tuberías en memoria viva
proceso_b = run(pipeline(`julia -e $codigo_nodo_b`, stdin=pipe_ida, stdout=pipe_vuelta), wait=false)

# Cerrar los extremos no utilizados en el proceso padre para que el flujo sea unidireccional
close(pipe_ida.reader)
close(pipe_vuelta.writer)

# Escritura asíncrona en el canal de ida hacia B
@async begin
    for valor in vector_resultado
        println(pipe_ida, valor)
    end
    close(pipe_ida) # Notificar fin de transmisión (EOF) a B
end

# 6. Operación de Vuelta: El script A lee la respuesta de B línea por línea
vector_regreso = Float64[]
for i in 1:5
    linea = readline(pipe_vuelta)
    push!(vector_regreso, parse(Float64, strip(linea)))
end

println("\n[Script A] Vector devuelto por el Nodo B: ", vector_regreso)
println("[Script A] Verificación de la Norma del Ciclo: ", norm(vector_regreso))
