import subprocess
import json

def renderizar_sudoku(grid):
    print("\n--- Sudoku 25x25 Resuelto ---")
    for i in range(25):
        if i % 5 == 0 and i != 0:
            print("-" * 75)
        fila = []
        for j in range(25):
            if j % 5 == 0 and j != 0:
                fila.append("|")
            val = grid[i][j]
            fila.append(str(val).rjust(2) if val != 0 else ".")
        print(" ".join(fila))

# 1. Crear tablero inicial (25x25, todo 0 salvo algunas pistas)
# Puedes cambiar los valores aquí para ver cómo Alice resuelve diferentes configuraciones
tablero = [[0 for _ in range(25)] for _ in range(25)]
tablero[0][0] = 5
tablero[12][12] = 25
tablero[24][24] = 1

# 2. Iniciar Alice como subproceso
# Si tienes problemas con el PATH, sustituye 'julia' por la ruta completa (ej. '/usr/bin/julia')
process = subprocess.Popen(
    ['julia', 'alice.jl'],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    text=True
)

# 3. Enviar datos a Alice
print("[BOB] Enviando tablero a Alice...")
process.stdin.write(json.dumps(tablero) + "\n")
process.stdin.flush()

# 4. Leer respuesta de Alice
line = process.stdout.readline()
if line:
    resultado = json.loads(line)
    renderizar_sudoku(resultado)
    print("\n[BOB] ¡Resolución completada!")
else:
    print("[BOB] Error: Alice no respondió.")

# 5. Cerrar proceso
process.kill()
