#!/bin/bash

# 1. Definir el puerto que usa tu API cuántica (según el server.log es el 8080)
PUERTO=8080

echo "[RAFAGA] Iniciando ráfaga de pruebas en paralelo..."
echo "[RAFAGA] Verificando disponibilidad del puerto $PUERTO..."

# 2. Comprobar si el puerto ya está en uso utilizando ss o lsof
if ss -tuln | grep -q ":$PUERTO "; then
    echo "[ALERT] ¡El puerto $PUERTO ya está ocupado por otro proceso!"
    echo "[ALERT] Intentando liberar el puerto de forma segura..."
    
    # Busca el ID del proceso (PID) que ocupa el puerto y lo detiene
    PID_OCUPADO=$(ss -lptn "sport = :$PUERTO" | grep -oP 'pid=\K\d+')
    
    if [ ! -z "$PID_OCUPADO" ]; then
        echo "[ALERT] Matando proceso antiguo con PID: $PID_OCUPADO"
        kill -9 $PID_OCUPADO
        sleep 1
    else
        echo "[ERROR] No se pudo identificar el PID. Intente cambiar el puerto en server.log."
        exit 1
    fi
else
    echo "[OK] El puerto $PUERTO está libre."
fi

# 3. Lanzar el pipeline cuántico de Julia en segundo plano de forma segura
echo "[RAFAGA] Lanzando demonio cuántico en segundo plano..."
julia run_quantum_pipeline.jl > server.log 2>&1 &

# Guardamos el PID del nuevo proceso por si queremos auditarlo luego
echo $! > .quantum_pid
echo "[RAFAGA] Proceso lanzado con éxito. PID actual: $(cat .quantum_pid)"
