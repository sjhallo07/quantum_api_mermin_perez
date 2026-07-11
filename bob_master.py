import time
import requests

# Monitoreamos el mismo endpoint GET
URL_CANAL = "https://httpbin.org"

print("=============================================================")
print("🤖   BOB - RECEPTOR NATIVO PARAMS (SIN PUERTOS)        🤖")
print("=============================================================")
print("[Bob] Escuchando variaciones en los parámetros de la URL...")
print("Frecuencia de sintonía: 2.0s (Presiona Ctrl+C para salir)\n")

ultima_traza = 0.0

while True:
    try:
        r = requests.get(URL_CANAL, timeout=5)
        
        if r.status_code == 200:
            respuesta_json = r.json()
            
            # Buscamos los datos dentro de la clave 'args' -> 'matriz' que genera httpbin
            args = respuesta_json.get("args", {})
            matriz_str = args.get("matriz")
            
            if matriz_str:
                # Convertimos el texto de la URL de vuelta a números flotantes
                datos = [float(x) for x in matriz_str.split(",")]
                
                # 1. Reconstruir la matriz de 5x5
                matriz_acoplamiento = []
                for i in range(0, len(datos), 5):
                    matriz_acoplamiento.append(datos[i:i+5])
                
                # 2. Calcular la traza
                traza_actual = sum(matriz_acoplamiento[i][i] for i in range(5))
                
                if traza_actual != ultima_traza and traza_actual != 0.0:
                    print("\n" + "="*60)
                    print("⚠️ [Puerto] ¡Interacción de estado detectada vía parámetros web!")
                    print("="*60)
                    print("Matriz de Acoplamiento Procesada (5x5):")
                    for fila in matriz_acoplamiento:
                        print("  ", [round(x, 2) for x in fila])
                    
                    print(f"\n-> Firma de Dirección (Traza Invariante): {traza_actual:.2f}")
                    
                    if traza_actual < 0:
                        print("\n🤖 [ACCIÓN MASTER ROYAL] -> !!! EJECUTAR ORDEN EN ESTE DISPOSITIVO !!!")
                    else:
                        print("\n🛑 [ACCIÓN MASTER ROYAL] -> !!! DETENER TODOS LOS PROCESOS !!!")
                    
                    print("="*60 + "\n")
                    ultima_traza = traza_actual
                    
    except Exception as e:
        pass
        
    time.sleep(2.0)
