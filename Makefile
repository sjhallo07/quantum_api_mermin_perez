run:
	@pkill -f julia || true
	@echo "🚀 Inicializando QRE API Server en el puerto 9090..."
	@julia /tmp/api_server.jl &

kill:
	@echo "🧹 Liberando puerto 9090 y matando instancias..."
	@pkill -f julia

test-mermin:
	@echo "🔮 Medición interactiva de celdas..."
	@echo "MERMIN 1 1" | nc 127.0.0.1 9090

test-brain:
	@echo "🧠 Verificando el estado del Cerebro..."
	@echo "BRAIN" | nc 127.0.0.1 9090

test-optimize:
	@echo "📐 Calibrando Puente TEP con Meta-RSI..."
	@echo "OPTIMIZE 500" | nc 127.0.0.1 9090

stress-api:
	@echo "⚡ Ejecutando ráfagas masivas asíncronas..."
	@python3 /tmp/test_quantum_api_v2.py

pipeline:
	@/tmp/qre_pipeline.sh
