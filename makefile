show-matrices:
	@julia -e 'println("=== matriz soberana ==="); a = [1 0; 0 1]; println(a)'

solve-sudoku:
	@julia -e 'N, K = 25, 5; sol = zeros(Int, N, N); [sol[i,j] = 1 + (K * ((i-1) % K) + floor(Int, (i-1) / K) + (j-1)) % N for i in 1:N, j in 1:N]; println("🔮 Matriz Soberana (25x25) Real:"); for i in 1:N, j in 1:N print(rpad(sol[i,j], 3)); j % 5 == 0 && j < 25 && print("| "); j == 25 && (println(); i % 5 == 0 && i < 25 && println("-"^84)) end'

push:
	@git add .
	@git commit -m "Sincronización automática de Matriz Soberana 25x25"
	@git push
	@echo "[ok] Proyecto sincronizado con éxito."
