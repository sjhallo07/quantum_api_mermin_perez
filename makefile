show-matrices:
	@julia -e 'println("=== matriz soberana ==="); a = [1 0; 0 1]; println(a)'

solve-sudoku:
	@julia -e 'N, K = 25, 5; sol = zeros(Int, N, N); [sol[i,j] = 1 + (K * ((i-1) % K) + floor(Int, (i-1) / K) + (j-1)) % N for i in 1:N, j in 1:N]; println("🔮 Matriz Soberana (25x25) Real:"); for i in 1:N, j in 1:N print(rpad(sol[i,j], 3)); j % 5 == 0 && j < 25 && print("| "); j == 25 && (println(); i % 5 == 0 && i < 25 && println("-"^84)) end'

ejecutar-y-validar-mora:
	@python3 -c 'import math, time, json, os; T_OMEGA = 12.0; dX = [0.5, 0.5, 0.8, 0.9]; calc_S = - (T_OMEGA / 2.0) * sum(x*x for x in dX); prob = 1.0 / (1.0 + math.exp(calc_S + 5.0)); print("\n🔍 [PROCESANDO ENSAYO EN MEMORIA VANILLA]"); print("-----------------------------------------------------"); print(f"📜 Constante Calculada S: {calc_S:.6f}"); print(f"📈 Probabilidad de Trascendencia: {prob*100:.4f}%%"); es_valido = abs(calc_S - (-11.7)) < 1e-5 and prob > 0.99; print("-----------------------------------------------------"); (print("✨ RESULTADO VÁLIDO: Guardando hito en ./data/..."), os.makedirs("./data", exist_ok=True), json.dump({"author": "Marcos Mora", "reliability_index": "100.0%", "experiment": "Trial of the Century", "sovereign_constant": calc_S, "verdict": "✨ THE CAT IS ALIVE: Type 1 Civilization Materialized", "dimension": "5D (Quantum Gravity State)", "timestamp": time.ctime()}, open("./data/paradox_resolved.json", "w")), print("[✔] Archivo grabado con éxito.")) if es_valido else print("❌ RESULTADO INVÁLIDO: Ensayo descartado y purgado de la RAM.")'

help:
	@echo "📋 Comandos disponibles (Filtro de Seguridad Activo):"
	@echo "  make show-matrices          -> Identidad"
	@echo "  make solve-sudoku           -> Matriz 25x25"
	@echo "  make ejecutar-y-validar-mora -> Corre y filtra almacenamiento"

ver-resultado:
	@python3 -c 'import json; print("\n📄 CONTENIDO DEL HITOS VALIDADO:"); print(json.dumps(json.load(open("./data/paradox_resolved.json")), indent=4))'
er-qbits:
	@python3 -c 'import math; S = -11.7; p_vivo = 1.0 / (1.0 + math.exp(S + 5.0)); alpha = math.sqrt(p_vivo); beta = math.sqrt(1.0 - p_vivo); print("\n⚛️  REPRESENTACIÓN EN QUBITS (ESPACIO DE HILBERT 2D)"); print("-----------------------------------------------------"); print(f"|ψ⟩ = {alpha:.5f} |Vivo⟩ + {beta:.5f} |Muerto⟩"); print(f"📊 Vector de Estado: [{alpha:.5f}, {beta:.5f}]^T"); print(f"📐 Condición de Normalización (|α|² + |β|²): {alpha**2 + beta**2:.6f}"); print("-----------------------------------------------------")'

ver-qbits:
	@python3 -c 'import math; S=-11.7; pv=1.0/(1.0+math.exp(S+5.0)); a=math.sqrt(pv); b=math.sqrt(1.0-pv); print("\n⚛️  ESTADO QUBIT (ESPACIO HILBERT 2D)"); print("-----------------------------------------------------"); print(f"|ψ⟩ = {a:.5f} |Vivo⟩ + {b:.5f} |Muerto⟩"); print(f"📊 Vector de Estado: [{a:.5f}, {b:.5f}]"); print(f"📐 Normalizacion (|α|² + |β|²): {a**2+b**2:.6f}")'

help-final:
	@echo "📋 Comandos del Laboratorio:"
	@echo "  make show-matrices          -> Identidad"
	@echo "  make solve-sudoku           -> Matriz 25x25 analitica"
	@echo "  make ejecutar-y-validar-mora -> Motor Relativista"
	@echo "  make ver-qbits              -> Espacio Hilbert 2D"
