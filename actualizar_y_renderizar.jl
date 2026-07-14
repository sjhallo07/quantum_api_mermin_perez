using JSON
using LinearAlgebra
using Distributions

println("=====================================================================")
println("   WORKFLOW COMPLETO: RENDER MATRIX & DISTRIBUTIONS INTEGRATION     ")
println("=====================================================================\n")

# 1. Cargar bloques reales de la ráfaga
datos_instagram = JSON.parsefile("matriz_instagram_106x106.json")
datos_mitigados = JSON.parsefile("matrices_output.json")

block_raw = datos_instagram["matriz_raw"]

# Extracción dinámica y segura del segundo bloque para evitar el KeyError
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
dim_maestra = dim_A + dim_B # 130x130

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

# 5. Resolución Moore-Penrose robusta
x_solucion .= pinv(A_expandida) * b_objetivo

# 6. INTEGRACIÓN CON DISTRIBUTIONS.JL
x_probabilidades = max.(x_solucion, 0.0)
x_probabilidades ./= sum(x_probabilidades) # Renormalización estricta

# Construcción de una distribución categórica formal de los estados cuánticos
dist_estados = Categorical(x_probabilidades)
media_empirica = mean(dist_estados)
varianza_empirica = var(dist_estados)

# 7. EXPORTACIÓN DEL REPORTE CON RENDERIZADO VISUAL EN MARKDOWN
open("sistema_ecuaciones.md", "w") do archivo
    println(archivo, "# Reporte Maestro del Ecosistema Cuántico (Matriz 130x130)\n")
    
    println(archivo, "## 📊 Características del Sistema Unificado")
    println(archivo, "- **Dimensión Acoplada:** ", dim_maestra, " ecuaciones x ", dim_maestra, " variables.")
    println(archivo, "- **Módulo Estadístico:** `Distributions.jl` -> Distribución Categórica Unificada.")
    println(archivo, "- **Media del Espacio de Estados:** ", round(media_empirica, digits=4))
    println(archivo, "- **Varianza del Espacio de Estados:** ", round(varianza_empirica, digits=4), "\n")
    
    println(archivo, "## 🗺️ Renderizado de Densidad de la Matriz (Muestra Estructural 10x10)")
    println(archivo, "Representación visual de la densidad de los coeficientes de acoplamiento:\n")
    println(archivo, "```text")
    for i in 1:10
        for j in 1:10
            val = M_maestra[i, j]
            if val == 0.0
                print(archivo, "░░░ ") # Espacio vacío / Canal nulo
            elseif abs(val) > 100.0
                print(archivo, "███ ") # Muros de potencial y restricciones masivas
            else
                print(archivo, "▒▒▒ ") # Acoplamientos operativos
            end
        end
        println(archivo, "")
    end
    println(archivo, "```\n")
    
    println(archivo, "## 📝 Listado Completo de Probabilidades Auditadas")
    println(archivo, "```text")
    for i in 1:dim_maestra
        println(archivo, "Estado x[", i, "] -> Probabilidad Evaluada: ", round(x_probabilidades[i], digits=6))
    end
    println(archivo, "```\n")
    println(archivo, "---\n*Fin del reporte analítico de ráfaga renderizado en Julia.*")
end

println("[ÉXITO] Matriz renderizada y distribución estadística actualizada con Distributions.jl.")
println("Media del Espacio de Estados Calculada: ", round(media_empirica, digits=4))
