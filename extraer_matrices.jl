include("Ecosistema.jl")
using .Ecosistema
using JSON # Asegúrate de tener el paquete JSON instalado en tu entorno de Julia

println("=== EXTRACCIÓN DE ESTRUCTURAS DE DATOS (MATRICES) ===")

datos_matrices = Dict{String, Any}()

for nombre in names(Ecosistema, all=true)
    if nombre in [:eval, :include, :Ecosistema]
        continue
    end
    
    val = getfield(Ecosistema, nombre)
    
    if typeof(val) <: AbstractArray
        println("> Guardando matriz: $nombre...")
        # Guardamos el nombre y el arreglo numérico
        datos_matrices[string(nombre)] = val
    end
end

# Escribimos todas las matrices en un archivo JSON constante
open("matrices_output.json", "w") do f
    JSON.print(f, datos_matrices)
end
println("¡Archivo matrices_output.json generado con éxito!")
