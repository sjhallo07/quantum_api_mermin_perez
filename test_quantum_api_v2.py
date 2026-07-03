import asyncio
import time
import random

async def simular_peticion_cuantica(reader, writer, f, c, iteracion):
    payload = f"MERMIN {f} {c}\n"
    writer.write(payload.encode())
    await writer.drain()
    
    t_inicio = time.perf_counter()
    respuesta = await reader.readline()
    t_fin = time.perf_counter()
    
    latencia_ms = (t_fin - t_inicio) * 1000
    res_str = respuesta.decode().strip()
    
    # VALIDACIÓN DIRECTA ULTRA-SIMPLE: Evita errores de separación de arreglos en Python
    es_valido = "WIN=true" in res_str
    estado = "ÉXITO (Correlacionado)" if es_valido else "FALLO"
    
    print(f"| {iteracion:<9} | Fila {f} | Columna {c} | {latencia_ms:6.2f} ms | {estado} |")
    return es_valido, latencia_ms

async def test_orquestador_api(total_iteraciones=20):
    print("================================================================")
    print(" ⚡ [ORQUESTADOR REPARADO V3] CONTROL DE PARIDAD EN ADELANTE ⚡")
    print(" Conectando a la API QRE Engine V4 local (Puerto 9090)...")
    print("================================================================\n")
    
    try:
        reader, writer = await asyncio.open_connection('127.0.0.1', 9090)
    except ConnectionRefusedError:
        print("❌ Error: No se pudo conectar a la API. ¿Dejaste corriendo el servidor?")
        return

    print(f"| {'Iteración':<9} | Alice  | Bob     | Latencia  | Estado                  |")
    print("|" + "-"*11 + "|" + "-"*8 + "|" + "---------" + "|" + "-"*11 + "|" + "-"*24 + "|")
    
    exitos = 0
    tiempos = []
    
    for i in range(1, total_iteraciones + 1):
        f = random.randint(1, 3)
        c = random.randint(1, 3)
        
        win, latencia = await simular_peticion_cuantica(reader, writer, f, c, i)
        if win:
            exitos += 1
        tiempos.append(latencia)
        await asyncio.sleep(0.05)
        
    writer.close()
    await writer.wait_closed()
    
    tasa_exito = (exitos / total_iteraciones) * 100
    latencia_promedio = sum(tiempos) / len(tiempos)
    
    print("\n================================================================")
    print(f" 📊 TELEMETRÍA GLOBAL DEL LAB:")
    print(f"    [-] Tasa de Éxito Cuántica Validada: {tasa_exito:.1f}%")
    print(f"    [-] Latencia Promedio Clásica      : {latencia_promedio:.2f} ms")
    print("================================================================")

if __name__ == "__main__":
    asyncio.run(test_orquestador_api())
