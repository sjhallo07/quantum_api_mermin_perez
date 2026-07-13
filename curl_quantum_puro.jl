include("soberania_absoluta.jl")
using LinearAlgebra
const RHO_CANAL = [0.25 0.35 0.26 0.251; 0.35 0.25 0.35 0.26; 0.26 0.35 0.25 0.35; 0.251 0.26 0.35 0.25]
const OPERADOR_PUERTO = kron([0.0 1.0; 1.0 0.0], [0.0 1.0; 1.0 0.0])
const AMPLITUD_BASE = tr(RHO_CANAL * OPERADOR_PUERTO)
curl_quantum_calc(v) = tr((v * v') * RHO_CANAL) * AMPLITUD_BASE
println(curl_quantum_calc([0.0, 1/sqrt(2), -1/sqrt(2), 0.0]))
