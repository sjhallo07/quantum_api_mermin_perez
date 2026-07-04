all: ping

ping:
	@curl -s -X POST http://127.0.0.1:9090 -d "PING"
	@echo ""

test:
	@curl -s -X POST http://127.0.0.1:9090 -d "MERMIN_TEST"
	@echo ""
