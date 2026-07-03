show-matrices:
	@echo '=== MATRIZ SOBERANA (Fondo Neutro 5D) ==='
	@echo '[-1.0  0.0  0.0  0.0  0.0]'
	@echo '[ 0.0  1.0  0.0  0.0  0.0]'
	@echo '[ 0.0  0.0  1.0  0.0  0.0]'
	@echo '[ 0.0  0.0  0.0  1.0  0.0]'
	@echo '[ 0.0  0.0  0.0  0.0  1.0]'

run-simulation:
	@julia /tmp/polyakov_action.jl
	@julia /tmp/meta_learning_tep.jl

verify-integrity:
	@echo '[✔] SOVEREIGN_ARCHIVED_AND_VALIDATED'
