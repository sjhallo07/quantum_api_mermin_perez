using LinearAlgebra
using Printf

println("="^75)
println("🔬 DEBATE DE HARDWARE: CALIBRACIÓN CON TU MATRIZ + RUIDO DE LORENZ")
println("="^75)

# Tu matriz exacta inyectada para transformar las amplitudes de control
const MATRIZ_TERMUX_5D = Float64[
    -1.0  0.0  0.0  0.0  0.0;
     0.0  1.0  0.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  1.0  0.0  0.0;
     0.0  0.0  0.0  0.0  1.0
]

# Ecuaciones dinámicas de Lorenz con paso controlado para evitar infinitos
function paso_lorenz(x, y, z, dt)
    sigma = 10.0
    rho = 28.0
    beta = 8.0/3.0
    
    dx = sigma * (y - x) * dt
    dy = (x * (rho - z) - y) * dt
    dz = (x * y - beta * z) * dt
    
    return x + dx, y + dy, z + dz
end

function simular_pulso_con_ruido(intento_voltaje::Float64, intensidad_ruido::Float64)
    # Usamos tu matriz para transformar el vector de amplitudes físicas
    vector_control = [intento_voltaje, 0.1, -0.05, 0.0, 0.2]
    vector_transformado = MATRIZ_TERMUX_5D * vector_control
    
    # Amplitud escalar limpia
    amplitud_física = norm(vector_transformado) 
    
    ψ = ComplexF64[1.0, 0.0]
    σ_x = ComplexF64[0 1; 1 0]
    σ_z = ComplexF64[1 0; 0 -1]
    
    # Inicialización del atractor caótico
    lx, ly, lz = 1.0, 1.0, 1.0
    dt = 0.001  # Paso ultra-pequeño para estabilizar el sistema físico
    pasos = 200
    
    for paso in 1:pasos
        lx, ly, lz = paso_lorenz(lx, ly, lz, dt)
        
        # El ruido de Lorenz modula la señal de microondas sin romper el límite numérico
        ruido_amplitud = lx * intensidad_ruido
        ruido_fase = lz * intensidad_ruido
        
        # Hamiltoniano cuántico dinámico afectado por el entorno caótico
        H = ((amplitud_física + ruido_amplitud) * σ_x + ruido_fase * σ_z) / 2.0
        
        # Evolución cuántica paso a paso
        U = exp(-im * H * dt * 2π)
        ψ = U * ψ
    end
    
    return abs(ψ[2])^2  # Probabilidad exacta de excitación del estado |1⟩
end

# === CONFIGURACIÓN DEL CRIÓSTATO ===
voltaje_base = 0.1250          # Tu voltaje de sintonización anterior
nivel_ruido_criostato = 0.05   # Intensidad del ruido caótico de fondo

println("📡 Inyectando pulso modulado por tu matriz a través de las fluctuaciones de Lorenz...")
prob = simular_pulso_con_ruido(voltaje_base, nivel_ruido_criostato)

@printf("🎯 Probabilidad resultante bajo ruido caótico: %.6f%%\n", prob * 100)
println("="^75)
