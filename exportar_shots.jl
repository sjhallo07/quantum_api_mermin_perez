using JSON
using LinearAlgebra
using Distributions

# 1. Cargar bloques reales de la ráfaga
datos_instagram = JSON.parsefile("matriz_instagram_106x106.json")
datos_mitigados = JSON.parsefile("matrices_output.json")

block_raw = datos_instagram["matriz_raw"]

global block_zne = Any[]
if haskey(datos_mitigados, "matriz_mitigada")
    global block_zne = datos_mitigados["matriz_mitigada"]
elseif haskey(datos_mitigados, "matriz")
    global block_zne = datos_mitigados["matriz"]
else
    for (k, v) in datos_mitigados
        if typeof(v) <: AbstractVector
            global block_zne = v
            break
        end
    end
end

dim_A = length(block_raw)
dim_B = length(block_zne)
dim_maestra = dim_A + dim_B 

# 2. Inicialización estática y resolución
M_maestra = zeros(Float64, dim_maestra, dim_maestra)
A_expandida = zeros(Float64, dim_maestra + 1, dim_maestra)
b_objetivo = zeros(Float64, dim_maestra + 1)
x_solucion = zeros(Float64, dim_maestra)

for i in 1:dim_A, j in 1:dim_A
    M_maestra[i, j] = Float64(block_raw[i][j])
end
for i in 1:dim_B, j in 1:dim_B
    M_maestra[dim_A + i, dim_A + j] = Float64(block_zne[i][j])
end

@views A_expandida[1:dim_maestra, 1:dim_maestra] .= M_maestra
escala = 1e15
@views A_expandida[dim_maestra + 1, 1:dim_maestra] .= escala
b_objetivo[end] = 1.0 * escala

x_solucion .= pinv(A_expandida) * b_objetivo
x_probabilidades = max.(x_solucion, 0.0)
x_probabilidades ./= sum(x_probabilidades)

# 3. Simulación de Medición de 7 Qubits (1000 Shots)
dist_estados = Categorical(x_probabilidades)
num_shots = 1000
muestreo_disparos = rand(dist_estados, num_shots)

frecuencias = zeros(Int, dim_maestra)
for disparo in muestreo_disparos
    frecuencias[disparo] += 1
end

# 4. Empaquetar y exportar a formato JSON cuántico
conteo_binario = Dict{String, Int}()
for i in 1:dim_maestra
    if frecuencias[i] > 0
        binario_str = string(i - 1, base=2, pad=7)
        qubits_visibles = string("|", join(split(binario_str, ""), "-"), "⟩")
        conteo_binario[qubits_visibles] = frecuencias[i]
    end
end

open("conteo_shots_quantum.json", "w") do f
    JSON.print(f, conteo_binario, 2)
end

println("\n====================================================")
println(" ¡CONTEO BINARIO GUARDADO EN 'conteo_shots_quantum.json'! ")
println(" Total de configuraciones de bits activas: ", length(conteo_binario))
println("====================================================")
