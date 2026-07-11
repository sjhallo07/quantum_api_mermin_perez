import sys
import math

# Métrica Soberana 5D definida matemáticamente
MATRIZ_SOBERANA_5D = [
   [-1.0,  0.0,  0.0,  0.0,  0.0],
   [ 0.0,  1.0,  0.0,  0.0,  0.0],
   [ 0.0,  0.0,  1.0,  0.0,  0.0],
   [ 0.0,  0.0,  0.0,  1.0,  0.0],
   [ 0.0,  0.0,  0.0,  0.0,  1.0]
]

# COMUNICACIÓN INMEDIATA: Lee las líneas directamente del flujo de la consola (sys.stdin)
lineas = sys.stdin.readlines()

if not lineas:
    print("Error: No se recibió ningún flujo de datos desde Julia.")
    sys.exit(1)

# Conversión a números flotantes
vector_recibido = [float(linea.strip()) for linea in lineas if linea.strip()]
print(f"Script B (Pipe Directo): Vector recibido -> {vector_recibido}")

# Cálculos algebraicos
norma_estandar = math.sqrt(sum(x**2 for x in vector_recibido))
print(f"Script B: La norma estándar es -> {norma_estandar}")

m_por_v = [sum(MATRIZ_SOBERANA_5D[i][j] * vector_recibido[j] for j in range(5)) for i in range(5)]
intervalo_cuadrado = sum(vector_recibido[i] * m_por_v[i] for i in range(5))
print(f"Script B: El intervalo invariante (s²) es -> {intervalo_cuadrado}")
