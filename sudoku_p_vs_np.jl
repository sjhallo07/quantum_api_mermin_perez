# =================================================================
# COMPLEJIDAD COMPUTACIONAL: REDUCCIÓN CSP PARA SUDOKU GIGANTE 25x25
# =================================================================

# Alfabeto derivado de los componentes de paridad observados en tu terminal
const SYMBOLS = ["-1", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", 
                 "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]

# Inicialización del espacio de estados (Matriz de candidatos / Dominios)
# Cada celda almacena un set con todos los posibles símbolos disponibles en el espacio de Hilbert
const DOMAIN_SIZE = 25
domains = [Set(SYMBOLS) for r in 1:25, c in 1:25]

# Matriz Soberana Fija como condición de contorno inicial rígida
const SOBERANA = [
  "-1" "0" "0" "0" "0";
   "0" "1" "0" "0" "0";
   "0" "0" "1" "0" "0";
   "0" "0" "0" "1" "0";
   "0" "0" "0" "0" "1"
]

# Inyección analítica de la condición cuántica: Colapsamos los dominios del núcleo central
for i in 1:5, j in 1:5
    r_target = 10 + i
    c_target = 10 + j
    domains[r_target, c_target] = Set([SOBERANA[i, j]])
end

# Algoritmo de Reducción Polinomial de Dominios (Consistencia de Arcos simplificada - Tipo AC-3)
# Intenta podar el espacio de búsqueda NP antes de cualquier ramificación determinista.
function propagar_restricciones!(doms)
    cambio = true
    iteraciones = 0
    while cambio
        cambio = false
        iteraciones += 1
        for r in 1:25, c in 1:25
            # Si una celda ya colapsó a un único estado (como tu matriz central)
            if length(doms[r, c]) == 1
                val_fijo = first(doms[r, c])
                
                # Propagar horizontalmente (Fila)
                for j in 1:25
                    if j != c && (val_fijo in doms[r, j])
                        delete!(doms[r, j], val_fijo)
                        cambio = true
                    end
                end
                
                # Propagar verticalmente (Columna)
                for i in 1:25
                    if i != r && (val_fijo in doms[i, c])
                        delete!(doms[i, c], val_fijo)
                        cambio = true
                    end
                end
                
                # Propagar subcuadrícula 5x5
                box_r = div(r - 1, 5) * 5 + 1
                box_c = div(c - 1, 5) * 5 + 1
                for i in box_r:(box_r + 4), j in box_c:(box_c + 4)
                    if (i != r || j != c) && (val_fijo in doms[i, j])
                        delete!(doms[i, j], val_fijo)
                        cambio = true
                    end
                end
            end
        end
        # Límite de seguridad para evitar estancamiento cíclico
        if iteraciones > 100 break end
    end
    return iteraciones
end

println("=== ANALIZANDO REDUCCIÓN DE ESPACIO DE ESTADOS DE HILBERT ===")
println("Tamaño inicial del espacio NP sin procesar: ", 25^625, " combinaciones posibles.")

steps = propagar_restricciones!(domains)

println("Propagación de restricciones completada en ", steps, " ciclos polinomiales.")

# Evaluamos la entropía remanente en el sistema tras el filtrado algebraico
celdas_resueltas = count(d -> length(d) == 1, domains)
println("Celdas colapsadas de manera determinista (Clase P): ", celdas_resueltas, " / 625")

# Renderizado de la matriz de incertidumbre actual
println("\n=== ESTADO ACTUAL DEL MAPA DE DOMINIOS ===")
for i in 1:25
    if i % 5 == 1 && i > 1 println("-" ^ 110) end
    for j in 1:25
        if j % 5 == 1 && j > 1 print("|  ") end
        # Si el dominio es 1, el valor es cierto. Si es mayor, es una superposición (.)
        print(rpad(length(domains[i, j]) == 1 ? first(domains[i, j]) : ".", 3))
    end
    println()
end
