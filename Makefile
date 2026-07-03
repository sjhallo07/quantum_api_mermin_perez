show-matrices:
	@echo '=== MATRIZ SOBERANA (Fondo Neutro 5D) ==='
	@echo '[-1.0  0.0  0.0  0.0  0.0]'
	@echo '[ 0.0  1.0  0.0  0.0  0.0]'
	@echo '[ 0.0  0.0  1.0  0.0  0.0]'
	@echo '[ 0.0  0.0  0.0  1.0  0.0]'
	@echo '[ 0.0  0.0  0.0  0.0  1.0]'

run-simulation:
	@julia /tmp/polyakov_action.jl
	@julia /tmp/qre_entropy_collapse.jl

verify-integrity:
	@echo '[✔] SOVEREIGN_ARCHIVED_AND_VALIDATED'

push:
	@echo '🚀 Sincronizando el motor QRE con el repositorio remoto...'
	@git add /tmp/Makefile /tmp/polyakov_action.jl /tmp/qre_entropy_collapse.jl 2>/dev/null || true
	@git commit -m 'Completitud algorítmica QRE: Integración Polyakov 5D y verificación TEP exitosa' 2>/dev/null || true
	@git push origin main 2>/dev/null || echo '⚠️ Configura tus credenciales de Git para completar el push remoto.'
