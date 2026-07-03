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

push:
	@echo "📦 Sincronizando repositorio con GitHub..."
	@git add /tmp/*.jl /tmp/*.py /tmp/Makefile /tmp/README.md
	@git commit -m "Docs: Actualización completa del README.md con la guía de Termux" || true
	@git push origin main

start:
	@chmod +x /tmp/start_qre.sh
	@/tmp/start_qre.sh

view-qubits:
	@julia -e 'println("\n" * "="^60 * "\n 🔮 REGISTRO QRE (BELL / GHZ)\n" * "="^60); ψ = [1/sqrt(2), 0.0, 0.0, 1/sqrt(2)]; estados = ["|00⟩", "|01⟩", "|10⟩", "|11⟩"]; println("| Estado | Amplitud Compleja   | Probabilidad de Colapso |"); println("|--------|---------------------|-------------------------|"); for i in 1:4; prob = round(abs2(ψ[i]) * 100, digits=2); amp = string(round(real(ψ[i]), digits=4)) * " + " * string(round(imag(ψ[i]), digits=4)) * "im"; println("| " * rpad(estados[i], 6) * " | " * rpad(amp, 19) * " | " * rpad(string(prob) * "%", 23) * " |") end; println("="^60)'

show-matrices:
	@julia -e 'println("=== MATRIZ SOBERANA ==="); A = [1 0; 0 1]; println(A)'
