#!/bin/bash

# ====================================================================
# SCRIPT DE INCIO MAESTRO: AUTOMATIZACIÓN DE ENTORNO QRE V4
# ====================================================================

echo "=================================================================="
echo " 🌐 INICIALIZANDO ENTORNO INTEGRADO QRE ENGINE V4 "
echo "=================================================================="

# 1. Verificar e instalar dependencias base del sistema si faltan
echo "[1/4] Verificando paquetes esenciales del sistema..."
if ! command -v julia &> /dev/null; then
    echo "     -> Instalando Julia runtime..."
    apt update && apt install julia -y
fi

if ! command -v nc &> /dev/null; then
    echo "     -> Instalando Netcat network utility..."
    apt update && apt install netcat-openbsd -y
fi

# 2. Purgar sockets huérfanos para prevenir bloqueos EADDRINUSE
echo -e "\n[2/4] Liberando el puerto 9090 ante posibles bloqueos..."
pkill -f julia || true
pkill -f nc || true
sleep 1

# 3. Lanzar el Servidor API Cuántico con el Cerebro de Meta-Learning
echo -e "\n[3/4] Encendiendo el QRE Engine en background..."
cd /tmp
julia /tmp/api_server.jl &

echo "     -> Esperando estabilización del buffer de la JIT cache..."
sleep 3

# 4. Control de Salud del Canal TCP (Health-Check Pulse)
echo -e "\n[4/4] Ejecutando ráfaga de diagnóstico de salud de red..."
RESP_PING=$(echo "PING" | nc 127.0.0.1 9090 || echo "OFFLINE")

if [ "$RESP_PING" == "PONG" ]; then
    echo -e "\n=================================================================="
    echo " ✅ SISTEMA ACTIVO AL 100%: Puerto 9090 respondiendo de forma sana."
    echo "    Usa 'make pipeline' para procesar jobs o 'make stress-api'."
    echo "=================================================================="
else
    echo -e "\n❌ ERROR CRÍTICO: El motor cuántico no respondió al pulso PING."
    exit 1
fi
