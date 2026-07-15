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

# 2. Inicialización estática persistente (Zero-Allocation Pool)
M_maestra = zeros(Float64, dim_maestra, dim_maestra)
A_expandida = zeros(Float64, dim_maestra + 1, dim_maestra)
b_objetivo = zeros(Float64, dim_maestra + 1)
x_solucion = zeros(Float64, dim_maestra)

# 3. Acoplamiento por bloques diagonales
for i in 1:dim_A, j in 1:dim_A
    M_maestra[i, j] = Float64(block_raw[i][j])
end
for i in 1:dim_B, j in 1:dim_B
    M_maestra[dim_A + i, dim_A + j] = Float64(block_zne[i][j])
end

# 4. Restricción de traza pesada unificada
@views A_expandida[1:dim_maestra, 1:dim_maestra] .= M_maestra
escala = 1e15
@views A_expandida[dim_maestra + 1, 1:dim_maestra] .= escala
b_objetivo[end] = 1.0 * escala

# 5. Resolución Moore-Penrose
x_solucion .= pinv(A_expandida) * b_objetivo

# 6. Integración con Distributions.jl
x_probabilidades = max.(x_solucion, 0.0)
if sum(x_probabilidades) > 0.0
    x_probabilidades ./= sum(x_probabilidades)
else
    fill!(x_probabilidades, 1.0 / dim_maestra)
end

dist_estados = Categorical(x_probabilidades)
media_empirica = mean(dist_estados)
varianza_empirica = var(dist_estados)

# 7. Exportación limpia del reporte
open("sistema_ecuaciones.md", "w") do archivo
    println(archivo, "# Reporte Maestro del Ecosistema Cuántico (Matriz ", dim_maestra, "x", dim_maestra, ")\n")
    println(archivo, "## 📊 Características del Sistema Unificado")
    println(archivo, "- **Dimensión Acoplada:** ", dim_maestra, "x", dim_maestra)
    println(archivo, "- **Módulo Estadístico:** `Distributions.jl` -> Distribución Categórica Unificada.")
    println(archivo, "- **Media del Espacio:** ", round(media_empirica, digits=4))
    println(archivo, "- **Varianza del Espacio:** ", round(varianza_empirica, digits=4))
end
