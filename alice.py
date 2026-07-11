import time
import random

# Definimos algunas transformaciones (Compuertas)
# X: [[0,1],[1,0]], Z: [[1,0],[0,-1]], I: [[1,0],[0,1]]
transformaciones = [
    [[0, 1], [1, 0]], 
    [[1, 0], [0, -1]], 
    [[1, 0], [0, 1]]
]

def aplicar_transformacion(estado, matriz):
    return [sum(m * e for m, e in zip(fila, estado)) % 2 for fila in matriz]

print("[ALICE] Iniciando sesión dinámica...")

# Alice elige una matriz al azar
matriz_elegida = random.choice(transformaciones)
nuevo_estado = aplicar_transformacion([1, 0], matriz_elegida)

# Mapeo simple de resultados a coordenadas
if nuevo_estado == [0, 1]: comando = "1,1"
elif nuevo_estado == [1, 0]: comando = "3,3"
else: comando = "2,2"

with open("canal.txt", "a") as f:
    f.write(f"{comando}\n")
    f.flush()
    print(f"[ALICE] Decisión tomada: {comando}")
