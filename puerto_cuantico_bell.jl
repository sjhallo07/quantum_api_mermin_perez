using LinearAlgebra

println("=============================================================")
println("🌌   SISTEMA DE DIRECCIONAMIENTO POR PUERTO MATRICIAL UNICO   ")
println("=============================================================")

# 1. TU MATRIZ (El Emisor - Tu huella de estado 5D)
const MATRIZ_EMISORA_5D = Float64[
    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  1.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

# 2. LA MATRIZ DEL RECEPTOR (El Puerto de Destino)
# Creamos una combinación única de fases invertidas y desplazamientos diagonales
# para asegurar que tenga una firma irrepetible que sirva como dirección.
const MATRIZ_RECEPTOR_UNICA = Float64[
     0.5  0.0  0.0  0.0  0.0;
     0.0 -1.0  0.0  0.0  0.0;
     0.0  0.0  1.5  0.0  0.0;
     0.0  0.0  0.0 -2.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

try
    println("[Julia] Sintonizando emisor con los parámetros del puerto receptor...")
    
    # INTERACCIÓN ALGEBRAICA: Proyección cruzada de ambas matrices únicas
    operador_puerto = MATRIZ_EMISORA_5D * MATRIZ_RECEPTOR_UNICA
    
    # Extracción de las propiedades únicas del canal entrelazado
    firma_traza = tr(operador_puerto)
    determinante_canal = det(operador_puerto)
    
    # Extraemos los Autovalores (Eigenvalues) que demuestran la unicidad matemática del puerto
    autovalores = eigenvalues = eigen(operador_puerto).values
    
    println("\n[Julia] --- INTERACCIÓN DE MATRICES COMPLETADA ---")
    println("-> Matriz de Acoplamiento Resultante (5x5):")
    display(operador_puerto)
    
    println("\n-> Dirección del Puerto (Traza Invariante): ", firma_traza)
    println("-> Densidad del Canal (Determinante): ", round(determinante_canal, digits=4))
    println("-> Espectro de Autovalores Únicos (Huella Digital):")
    for (i, val) in enumerate(autovalores)
        println("   λ_$i = ", round(val, digits=2))
    end
    
    println("\n✅ [Julia] El cálculo ha sido fijado con éxito en el puerto cuántico.")

catch e
    println("\n⚠️ [FALLBACK ACTIVADO] Entorno Julia no disponible o interrumpido: $e")
    println("[Fallback] Delegando el cálculo de dirección al motor algebraico de Python...")
    
    # Formateamos las matrices para transmitirlas al intérprete secundario de Python
    emisor_str = join(vec(MATRIZ_EMISORA_5D), ", ")
    receptor_str = join(vec(MATRIZ_RECEPTOR_UNICA), ", ")
    
    python_code = """
import numpy as np
try:
    A = np.array([$emisor_str]).reshape(5, 5)
    B = np.array([$receptor_str]).reshape(5, 5)
    
    # Operación de puerto equivalente en Python
    operador = np.dot(A, B)
    traza = np.trace(operador)
    determinante = np.linalg.det(operador)
    autovalores = np.linalg.eigvals(operador)
    
    print('\\n[Python Fallback] --- INTERACCIÓN DE MATRICES COMPLETADA ---')
    print('-> Matriz de Acoplamiento:\\n', operador)
    print(f'-> Dirección del Puerto (Traza): {traza}')
    print(f'-> Densidad del Canal (Determinante): {determinante:.4f}')
    print('-> Espectro de Autovalores Únicos (Huella Digital):')
    for i, val in enumerate(autovalores):
        print(f'   λ_{i+1} = {val:.2f}')
    print('\\n✅ [Python Fallback] Dirección y cálculo completados con éxito.')
except Exception as ex:
    print(f'❌ Error crítico de infraestructura en el fallback de Python: {ex}')
"""
    run(`python3 -c $python_code`)
end
