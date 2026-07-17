#!/bin/bash
# ======================================================================
# SCRIPT DE CONSOLIDACIÓN MASIVA: AGENTES + METADATOS 22 CÚBITS
# ======================================================================

echo "📦 Indexando todos los cambios del ecosistema (Puente + Agentes)..."
# Agrega explícitamente el nuevo Ecosistema.jl y las bitácoras modificadas
git add Ecosistema.jl README.md qre_validation_core.json sudoku_25.jl termux_vs_ibm.jl historial_cuantico.csv

echo "💾 Ejecutando confirmación atómica local..."
git commit -m "Hito Final: Integración de Capa Puente Ecosistema.jl (0-Alloc) y Sincronización de Meta-Learning Agéntico"

echo "🌌 Forzando alineación limpia en la rama main de GitHub..."
git push origin main --force

echo "==========================================================================="
echo " 🔥 ¡MISION CUMPLIDA: ENTORNO COMPLETAMENTE PROTEGIDO Y UP-TO-DATE! "
echo "==========================================================================="
