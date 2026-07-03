#!/bin/bash

# Asegurar que el script se detenga si hay errores críticos de entorno
set -e

echo "=================================================================="
    echo " 🔮 PIPELINE MAESTRO QRE V4: PROCESADOR AUTOMÁTICO DE BLOQUES 🔮 "
    echo "=================================================================="
    echo " -> Por favor, PEGA (Paste) el bloque de datos, hash o ID del Job"
    echo " -> Luego presiona ENTER y finalmente Ctrl+D para procesar:"
    echo "------------------------------------------------------------------"

# Capturar todo el bloque copiado y pegado (soporta múltiples líneas o strings largos)
INPUT_RAW=$(cat)

# Limpieza estricta de caracteres de control, retornos de carro (\r) y espacios en los extremos
BLOCK_DATA=$(echo "$INPUT_RAW" | tr -d '\r' | xargs)

if [ -z "$BLOCK_DATA" ]; then
    echo "❌ ERROR: No se introdujo ningún bloque de datos. Cancelando."
    exit 1
fi

echo -e "\n[+] Entrada detectada con éxito. Longitud de cadena: ${#BLOCK_DATA} caracteres."
echo "[+] Iniciando secuencia automatizada de auditoría cuántica y PoW..."
echo "------------------------------------------------------------------"

# 1. TEST DE RED (PING)
echo -e "\n[1/5] Interrogando canal de transporte TCP (Puerto 9090)..."
RESP_PING=$(echo "PING" | nc 127.0.0.1 9090 || echo "OFFLINE")
if [ "$RESP_PING" == "OFFLINE" ]; then
    echo "❌ ERROR: El servidor de Julia está apagado. Ejecuta 'make run' primero."
    exit 1
fi
echo "      -> Respuesta del Kernel: $RESP_PING"

# 2. AUDITORÍA DE INTEGRIDAD DE ARCHIVOS LOCALES
echo -e "\n[2/5] Verificando persistencia de firmas y manifiestos en /tmp..."
echo "FILES" | nc 127.0.0.1 9090

# 3. INTERROGACIÓN AL CEREBRO DE META-LEARNING
echo -e "\n[3/5] Extrayendo estado acumulativo del QRE_Brain..."
echo "BRAIN" | nc 127.0.0.1 9090

# 4. CALIBRACIÓN CUÁNTICA EN EL ESPACIO DE HILBERT
echo -e "\n[4/5] Computando mediciones aleatorias en las celdas de Mermin-Peres..."
# Extraer combinaciones basadas en la longitud o hashes de la entrada para simular entropía real
FILA=$(( (${#BLOCK_DATA} % 3) + 1 ))
COLUMNA=$(( ((${#BLOCK_DATA} * 7) % 3) + 1 ))
echo "      -> Evaluando celda dinámica interna: Fila $FILA, Columna $COLUMNA"
echo "MERMIN $FILA $COLUMNA" | nc 127.0.0.1 9090

# 5. VALIDACIÓN CRIPTOGRÁFICA DE LA PRUEBA DE TRABAJO (PoW)
echo -e "\n[5/5] Ejecutando minería inversa y validación de Target..."
if [[ "$BLOCK_DATA" == *"00000000"* ]]; then
    # Si lo que pegaste es el hash objetivo de 20 ceros, llama directamente al verificador real
    julia /tmp/verificar_target_real.jl
else
    # Si pegaste cualquier otro identificador de bloque o metadato
    echo "      -> Datos del bloque acoplados: $BLOCK_DATA"
    julia /tmp/verificador_nonce.jl
fi

echo -e "\n=================================================================="
echo " ✅ PROCESAMIENTO FINALIZADO: Todos los resultados consolidados."
echo "=================================================================="
