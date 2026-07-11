import json

def enviar_calculo(matriz, vector):
    payload = json.dumps({"matriz": matriz, "vector": vector})
    
    # Enviar orden a la tubería
    with open("solicitud", "w") as f:
        f.write(payload)
    
    # Leer respuesta desde la tubería
    with open("respuesta", "r") as f:
        resultado = json.load(f)
    
    return resultado

# Ejecución
print("[BOB] Enviando cálculo por tubería...")
res = enviar_calculo([[3, 3], [8, 3]], [6, 6])
print(f"[BOB] Resultado recibido: {res}")
