# ==========================================
# CONFIGURACIÓN GENERAL DEL PIPELINE QUANTUM
# ==========================================

# Regla por defecto para compilar tu simulación 5D (reemplaza "echo" por tu comando real si es necesario)
all:
	@echo "Iniciando compilación principal..."
	@echo "=== MATRIZ SOBERANA (Fondo Neutro 5D) ==="

# ==========================================
# EXTENSIONES PARA EL ENTORNO SUDOKU 25x25
# ==========================================

sudoku:
	@julia sudoku_25x25.jl challenge

sudoku-solve:
	@julia sudoku_25x25.jl solve

pipeline:
	@julia simulacion_definitiva.jl
	@julia generar_qubits.jl
	@echo "\n=== PROYECTANDO REQUISITOS EN ESPACIO DE HILBERT ==="
	@julia sudoku_25x25.jl challenge
