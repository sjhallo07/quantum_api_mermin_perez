using Printf

function clase_P(n)
	operaciones = 0
	for i in 1:n
		for j in 1:n
			operaciones += 1
		end
	end
	return operaciones
end

function clase_NP(n)
	if n > 31
		return "Espacio > Atomos Universo"
	end
	return 2^n
end

println("======================================================================")
println("     ANALIZADOR DE COMPLEJIDAD ACADÉMICA: ¿P == NP? (METRICA QRE)")
println("======================================================================")
println(@sprintf("%-7s | %-17s | %-25s", "Dim (N)", "Tiempo en P O(N²)", "Espacio NP O(2ⁿ)"))
println("-" ^ 70)

for n in [5, 10, 15, 20, 25, 50]
	ops_p = clase_P(n)
	ops_np = clase_NP(n)
	if isa(ops_np, String)
		println(@sprintf("%-7d | %-17d | %-25s", n, ops_p, ops_np))
	else
		println(@sprintf("%-7d | %-17d | %-25d", n, ops_p, ops_np))
	end
end
println("-" ^ 70)
