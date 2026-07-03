module QuantumEngine

using LinearAlgebra

export SimulationState, evolve!, apply_weinberg_perturbation!, get_observables

mutable struct SimulationState
    psi::Vector{ComplexF64}
    dx::Float64
    dt::Float64
    Hamiltonian::Matrix{ComplexF64}
    propagator::Matrix{ComplexF64}
end

# Constructor del Engine (Configuración inicial)
function SimulationState(N::Int, L::Float64, dt::Float64)
    dx = L / (N - 1)
    x = range(-L/2, L/2, length=N)
    psi = exp.(-(x.^2) ./ 0.5) .* exp.(1im * 5.0 .* x)
    psi ./= sqrt(sum(abs2.(psi)) * dx)
    
    # Crank-Nicolson matrices
    alpha = 1im * dt / (2 * dx^2)
    A = diagm(0 => (1 .+ 2 .* alpha) .* ones(N), 1 => -alpha .* ones(N-1), -1 => -alpha .* ones(N-1))
    B = diagm(0 => (2 .- (1 .+ 2 .* alpha)) .* ones(N), 1 => alpha .* ones(N-1), -1 => alpha .* ones(N-1))
    
    # Boundary conditions
    A[1, :] .= 0; A[1, 1] = 1.0; A[N, :] .= 0; A[N, N] = 1.0
    B[1, :] .= 0; B[N, :] .= 0
    
    return SimulationState(psi, dx, dt, A, B)
end

# Ejecución de un paso (evolución física)
function evolve!(s::SimulationState)
    rhs = s.Hamiltonian \ (s.propagator * s.psi)
    s.psi .= rhs
end

# Inyección de Perturbación (Operador Weinberg / Ataque)
function apply_weinberg_perturbation!(s::SimulationState, epsilon::Float64)
    # Aplicar operador no unitario
    s.psi .*= sqrt(1 - epsilon^2)
    # Renormalización forzada para mantener la física unitaria
    s.psi ./= norm(s.psi)
end

# Métricas
function get_observables(s::SimulationState)
    norma = sqrt(sum(abs2.(s.psi)) * s.dx)
    return norma
end

end
