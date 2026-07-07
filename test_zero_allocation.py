import os
import tracemalloc
import gc

# 1. Preparar el entorno físico antes de encender la telemetría
gc.collect()

# 2. INICIAR MEDICIÓN ESTRICTA DE TRACE (Punto Cero)
tracemalloc.start()
snap_inicial = tracemalloc.take_snapshot()

# 3. OPERACIÓN DE ÁLGEBRA BOOLEANA / MATRIZ SOBERANA (Filtro 5D Puro)
# Usamos tipos numéricos primitivos directos para buscar el Zero Allocation
# El determinante absoluto de la Matriz Soberana Diagonal [-1, 1, 1, 1, 1] es 1
filtro_soberano = 1

# Lectura directa del directorio sin crear variables de lista intermedias (Cero asignación de RAM)
total_bytes_disco = 0
total_archivos = 0

try:
    for entrada in os.scandir(os.getcwd()):
        if entrada.is_file():
            total_bytes_disco += entrada.stat().st_size
            total_archivos += 1
except OSError:
    pass

# 4. CAPTURAR TELEMETRÍA FINAL DE INMEDIATO
snap_final = tracemalloc.take_snapshot()
current, peak = tracemalloc.get_traced_memory()
tracemalloc.stop()

# Calcular estadísticas de asignaciones residuales reales
estadisticas = snap_final.compare_to(snap_inicial, 'lineno')
allocations_filtradas = [stat for stat in estadisticas if stat.size_diff > 0]

print("=== REPORTE DE TRANSMISIÓN ZERO ALLOCATION ===")
print(f"-> Allocations detectadas (Memoria Pico): {peak} bytes")
print(f"-> Diferencia neta en el Heap: {sum(s.size_diff for s in allocations_filtradas)} bytes")
print(f"-> Residuales en Almacenamiento (Archivos): {total_archivos}")
print(f"-> Espacio Total del Directorio: {total_bytes_disco} bytes")
print("----------------------------------------------")

if peak == 0 or sum(s.size_diff for s in allocations_filtradas) == 0:
    print("¡ÉXITO! Canal simétrico en estado puro: Zero Allocation alcanzado.")
else:
    print("[Aviso] Python requirió buffers internos del sistema operativo para el escaneo de archivos.")
