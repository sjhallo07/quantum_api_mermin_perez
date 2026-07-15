all:
	@echo "⚛️  [CORE] Inicializando núcleo del Ecosistema ZeroAlloc..."
	@julia orquestador_quantum_engine.jl

pipeline:
	@echo "🚀 [IPC 5D] Ejecutando transferencia de matrices y vectores en memoria..."
	@julia run_quantum_pipeline.jl
	@echo "\n📊 [RSI] Sincronizando flujo de actualización y telemetría de matrices..."
	@julia workflow_rsi_update.jl

ver:
	@echo "👁️  [RENDER] Extrayendo y renderizando estructura de la matriz..."
	@julia actualizar_y_renderizar.jl
	@cat sistema_ecuaciones.md

actualizar:
	@echo "⚙️  [UPDATE] Sincronizando engine_specs.json con la escala del hardware..."
	@julia -e 'using JSON; specs = JSON.parsefile(engine_specs.json); println(Matriz
git-sync:
	@echo "📂 [GIT] Indexando cambios locales y purgando residuos en la nube..."
	@git add -A
	@git commit -m "Optimize: Integracion total del ecosistema de matrices y distributions" || true
	@git push origin main
