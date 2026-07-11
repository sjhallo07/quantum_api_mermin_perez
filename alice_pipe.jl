using JSON
using LinearAlgebra

println("[ALICE] Pipeline activo. Esperando órdenes...")

while true
    # Abrir para lectura (bloqueante)
    open("solicitud", "r") do pipe
        data_raw = read(pipe, String)
        if !isempty(data_raw)
            input_data = JSON.parse(data_raw)
            
            # Cálculo Algebraico
            M = Matrix(reduce(vcat, transpose.(input_data["matriz"])))
            v = input_data["vector"]
            res = M * v
            
            # Escribir respuesta en la tubería
            open("respuesta", "w") do out
                write(out, JSON.json(res))
            end
            println("[ALICE] Cálculo realizado y enviado.")
        end
    end
end
