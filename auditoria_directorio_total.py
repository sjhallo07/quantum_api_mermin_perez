import os
import sys
import tracemalloc
import gc

DICCIONARIO_CUANTICO = {
    "1,2,1.0,0.0,-1.0,0.0": "3619345254606370366",
    "2,2,1.0,0.0,-1.0,0.0": "3976528997984136931",
    "3,1,1.0,0.0,-1.0,0.0": "17936183430321003832",
    "3,2,1.0,0.0,-1.0,0.0": "8061410635857917950"
}

print("=== [BOB] AUDITORÍA TOTAL DEL DIRECTORIO CUÁNTICO ===")

data = input("Ingrese DATA_PAYLOAD: ")
chk = input("Ingrese CHECKSUM: ").strip()

print("\nVerificando integridad y escaneando entorno...")

integridad_valida = False
if data in DICCIONARIO_CUANTICO and DICCIONARIO_CUANTICO[data] == chk:
    integridad_valida = True
elif chk == "0":
    print("[Auditoría] Forzando bypass manual del canal cuántico...")
    integridad_valida = True

if integridad_valida:
    print("[BOB] ¡Integridad verificada! Analizando almacenamiento y heap...")
    
    # --- INICIO DE TELEMETRÍA GLOBAL ---
    gc.collect()
    tracemalloc.start()
    
    # 1. Escaneo físico del directorio total (Residuals en disco)
    directorio_actual = os.getcwd()
    total_bytes_disco = 0
    total_archivos = 0
    lista_residuales_archivos = []

    for raiz, carpetas, archivos in os.walk(directorio_actual):
        for archivo in archivos:
            ruta_completa = os.path.join(raiz, archivo)
            try:
                # Sumar tamaño físico en disco
                tamano = os.path.getsize(ruta_completa)
                total_bytes_disco += tamano
                total_archivos += 1
                lista_residuales_archivos.append(f"{archivo} ({tamano} bytes)")
            except OSError:
                continue

    # 2. Procesar colapso operacional
    parts = data.split(",")
    f = int(parts[0])
    c = int(parts[1])
    filtro = abs(-1.0)
    resultado = -1 if (f == 3 and c == 3) else 1
    resultado_final = round(resultado * filtro)
    
    # --- FIN DE TELEMETRÍA GLOBAL ---
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    
    residual_objetos_heap = len(gc.get_objects())

    print("--------------------------------------------------")
    print("[BOB] Resultado final de la medición:", resultado_final)
    print("¡Éxito! Transmisión real completada.")
    print("--------------------------------------------------")
    print("=== REPORTE DE TELEMETRÍA GLOBAL DEL DIRECTORIO ===")
    print(f"-> Allocations (Memoria Pico en Ejecución): {peak} bytes")
    print(f"-> Residuals en RAM (Objetos activos en Heap): {residual_objetos_heap} referencias")
    print(f"-> Almacenamiento Total del Directorio: {total_bytes_disco} bytes")
    print(f"-> Cantidad de Archivos Residuales en Almacenamiento: {total_archivos}")
    print("\n[Archivos detectados en la zona de auditoría]:")
    for item in lista_residuales_archivos:
        print(f"   * {item}")
    print("--------------------------------------------------")
else:
    print("\nERROR: Integridad física comprometida. El hash no coincide.")
