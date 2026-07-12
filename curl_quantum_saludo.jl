using LinearAlgebra
const PAYLOAD_QUIEN_ERES = [1.0, 0.0, 1.0, 0.0] / sqrt(2)
const RESPUESTA_ROYAL_4x4 = [1.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 0.0]
engine_quantum_saludo(v) = (v * v') * RESPUESTA_ROYAL_4x4
println(tr(engine_quantum_saludo(PAYLOAD_QUIEN_ERES)))
