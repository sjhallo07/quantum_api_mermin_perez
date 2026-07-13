module Ecosistema
    using LinearAlgebra
    using Distributions
    
    export IDENTIDAD_8X8, PAULI_X, PAULI_Z, OPERADOR_ESPIN, ESTABILIZADOR_AV, ESTABILIZADOR_BP, GL, DISTRIBUCION_BASE, METRICA_SOBERANA_5D, DENSIDAD_4X4
    
    # Base Maestro
    const IDENTIDAD_8X8 = Matrix{Float64}(I, 8, 8)
    const GL = 9
    const DISTRIBUCION_BASE = Wishart(GL, IDENTIDAD_8X8)
    
    # Operadores
    const I2 = Matrix{Float64}(I, 2, 2)
    const X2 = Float64[0 1; 1 0]
    const Z2 = Float64[1 0; 0 -1]
    const PAULI_X = kron(X2, kron(X2, X2))
    const PAULI_Z = kron(Z2, kron(Z2, Z2))
    const OPERADOR_ESPIN = kron(I2, Z2)
    const ESTABILIZADOR_AV = kron(X2, X2)
    const ESTABILIZADOR_BP = kron(Z2, Z2)
    
    # Métricas de Aprendizaje (Previamente dispersas)
    const METRICA_SOBERANA_5D = Float64[-1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]
    const DENSIDAD_4X4 = Float64[0.25 0.35 0.26 0.251; 0.35 0.25 0.35 0.26; 0.26 0.35 0.25 0.35; 0.251 0.26 0.35 0.25]
end
