using LinearAlgebra

function ejecutar_simulacion()
    # --- 1. Definición del sistema ---
    N = 400
    L = 20.0
    dx = L / (N - 1)
    dt = 0.01
    steps = 500

    # Inicialización
    x = range(-L/2, L/2, length=N)
    psi = exp.(-(x.^2) ./ 0.5) .* exp.(1im * 5.0 .* x)
    psi ./= sqrt(sum(abs2.(psi)) * dx)

    # Matrices (Crank-Nicolson)
    alpha = 1im * dt / (2 * dx^2)
    A = diagm(0 => (1 .+ 2 .* alpha) .* ones(N), 1 => -alpha .* ones(N-1), -1 => -alpha .* ones(N-1))
    B = diagm(0 => (2 .- (1 .+ 2 .* alpha)) .* ones(N), 1 => alpha .* ones(N-1), -1 => alpha .* ones(N-1))

    # Fronteras
    A[1, :] .= 0; A[1, 1] = 1.0; A[N, :] .= 0; A[N, N] = 1.0
    B[1, :] .= 0; B[N, :] .= 0

    # --- 2. Ejecución ---
    println("Iniciando simulación...")

    for i in 1:steps
        # Evolución física normal
        rhs = B * psi
        psi = A \ rhs
        
        # Inyección de perturbación en el paso 250
        if i == 250
            epsilon = 0.1
            psi .*= sqrt(1 - epsilon^2)
            psi ./= norm(psi)
            println("Perturbación aplicada en el paso 250")
        end
    end

    # --- 3. Resultados ---
    norma_final = sqrt(sum(abs2.(psi)) * dx)
    println("Simulación completada.")
    println("Norma final del sistema: ", round(norma_final, digits=6))
end

# Llamamos a la función para ejecutar
ejecutar_simulacion()
