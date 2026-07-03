using LinearAlgebra

function simular_schrodinger()
    # --- Parámetros de Simulación ---
    L = 20.0       
    N = 400        
    dx = L / (N - 1)
    dt = 0.01      
    steps = 500    
    x = range(-L/2, L/2, length=N)

    # --- Estado Inicial ---
    k0 = 5.0
    sigma = 1.0
    psi = exp.(-(x.^2) ./ (2*sigma^2)) .* exp.(1im * k0 .* x)
    psi ./= sqrt(sum(abs2.(psi)) * dx)

    # --- Operadores ---
    alpha = 1im * dt / (2 * dx^2)
    main_diag = (1 .+ 2 .* alpha) .* ones(ComplexF64, N)
    off_diag = -alpha .* ones(ComplexF64, N-1)

    A = diagm(0 => main_diag, 1 => off_diag, -1 => off_diag)
    B = diagm(0 => 2 .- main_diag, 1 => -off_diag, -1 => -off_diag)

    # Condiciones de frontera
    A[1, :] .= 0; A[1, 1] = 1.0
    A[N, :] .= 0; A[N, N] = 1.0
    B[1, :] .= 0; B[N, :] .= 0

    # --- Ciclo de Evolución ---
    println("Iniciando simulación numérica (Julia Optimizado)...")
    for i in 1:steps
        rhs = B * psi
        psi = A \ rhs
    end

    # --- Resultados ---
    prob_total = sum(abs2.(psi)) * dx
    println("Simulación terminada.")
    println("Probabilidad total (debe ser ≈ 1.0): ", round(prob_total, digits=6))
    return psi
end

# Ejecutar
simular_schrodinger()
