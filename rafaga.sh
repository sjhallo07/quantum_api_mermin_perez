#!/bin/bash

# Archivo de salida para consolidar las métricas de la ráfaga
LOG_FILE="rafaga_test.log"

echo "==========================================================" > $LOG_FILE
echo "   REPORTE DE RÁFAGA: AUDITORÍA TOTAL DE ARCHIVOS JULIA   " >> $LOG_FILE
echo "   Fecha y Hora: $(date)                                 " >> $LOG_FILE
echo "==========================================================" >> $LOG_FILE
echo "" >> $LOG_FILE

echo "🚀 Iniciando ráfaga de pruebas en el repositorio..."
echo "📊 Los resultados se guardarán en: $LOG_FILE"
echo "----------------------------------------------------------"

# Contador de archivos procesados
total=0
exitosos=0
fallidos=0

# LISTA MAESTRA DE EXCLUSIÓN: Filtra orquestadores, tuberías y validadores del motor
OMITIR="run_quantum_pipeline.jl pipeline.jl orquestador.jl qre_pipeline.sh rafaga.sh test_conexion_engine.jl auditar_soberania.jl"

# Iterar sobre cada archivo .jl en el directorio actual
for script in *.jl; do
    # Validar si el archivo existe físicamente en el directorio
    [ -e "$script" ] || continue
    
    # Comprobar si está dentro de la brana de exclusión
    if echo "$OMITIR" | grep -q "$script"; then
        echo "⏭️  Omitiendo operador maestro: $script"
        continue
    fi

    total=$((total + 1))
    echo -n "⏳ Probando [$total] -> $script ... "

    # Captura del tiempo inicial de la CPU
    start_time=$(date +%s.%N)
    
    # Ejecuta Julia limitando el tiempo máximo a 10 segundos para evitar fugas de memoria
    timeout 10 julia "$script" > /dev/null 2>&1
    status=$?
    
    # Captura del tiempo final
    end_time=$(date +%s.%N)
    execution_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.0")

    # Análisis algebraico de la respuesta del hardware
    if [ $status -eq 0 ]; then
        echo "✅ ÉXITO (${execution_time:0:5}s)"
        echo "[✅ OK] $script - Tiempo: ${execution_time:0:5}s" >> $LOG_FILE
        exitosos=$((exitosos + 1))
    elif [ $status -eq 124 ]; then
        echo "⏳ TIMEOUT (Excedió 10s)"
        echo "[⏳ TIMEOUT] $script - El script se colgó (Bucle infinito o Servidor de escucha)" >> $LOG_FILE
        fallidos=$((fallidos + 1))
    else
        echo "❌ FALLÓ"
        echo "[❌ ERROR] $script - Código de salida: $status" >> $LOG_FILE
        fallidos=$((fallidos + 1))
    fi
done

# Generación del sumario final de telemetría en el log
echo "" >> $LOG_FILE
echo "==========================================================" >> $LOG_FILE
echo "                    RESUMEN DE TELEMETRÍA                  " >> $LOG_FILE
echo "  Total de archivos analizados: $total" >> $LOG_FILE
echo "  Scripts estables (Éxito): $exitosos" >> $LOG_FILE
echo "  Scripts inestables (Fallo/Timeout): $fallidos" >> $LOG_FILE
echo "==========================================================" >> $LOG_FILE

echo "----------------------------------------------------------"
echo "🏁 ¡Ráfaga completada!"
echo "📈 Resumen: $exitosos estables, $fallidos fallidos de un total de $total."
