using LinearAlgebra
using Distributions
using Optim
using Printf
using Dates

# Enlazamos el núcleo sellado inmutable
include("soberania_absoluta.jl")

const Fs = 100.0
const N = 128

"""
Función de Costo (Loss Function) para Optim.jl:
Calcula la potencia espectral del ruido fuera de la banda del cerebro (>30 Hz).
El optimizador buscará los vectores que reduzcan este número a cero.
"""
function funcion_perdida_ruido(fases_prueba::Vector{Float64})
    serie_raw = Vector{Float64}(undef, N)
    
    # Inyectamos las fases de prueba en el muestreo matricial
    for t in 1:N
        rho_instantanea = SoberaniaCuantica.muestrear_matriz_real()
        # Modulamos la pureza con la fase que Optim.jl está buscando
        serie_raw[t] = real(tr(rho_instantanea^2)) * cos(fases_prueba[1] * t)
    end
    
    serie_raw .-= (sum(serie_raw) / N)
    
    ruido_total = 0.0
    for k in 0:(div(N, 2) - 1)
        freq = (k * Fs) / N
        if freq > 30.0 # Si es ruido del teléfono ARM
            re = 0.0
            for n in 0:(N - 1)
                re += serie_raw[n + 1] * cos(2.0 * pi * k * n / N)
            end
            ruido_total += re^2 
        end
    end
    return ruido_total
end

# --- BUCLE DE EJECUCIÓN CONTINUA (SEGUNDO PLANO) ---
println("=== INICIANDO DEMONIO DE RED NEURO-CUÁNTICA OPTIMIZADA ===")

while true
    time_now = Dates.format(Dates.now(), "dd-mm-yyyy HH:MM:SS")
    
    # Optim.jl arranca la búsqueda inteligente con una suposición inicial de fase [0.1]
    resultado_busqueda = optimize(funcion_perdida_ruido, [0.1], NelderMead())
    fase_optima = Optim.minimizer(resultado_busqueda)[1]
    eficiencia = Optim.minimum(resultado_busqueda)
    
    # Volvemos a medir con la fase óptima encontrada para reportar la sintonía limpia
    serie_sintonizada = Vector{Float64}(undef, N)
    for t in 1:N
        # CORRECCIÓN: método en minúsculas estrictas para evitar el crash del demonio
        rho_instantanea = SoberaniaCuantica.muestrear_matriz_real()
        serie_sintonizada[t] = real(tr(rho_instantanea^2)) * cos(fase_optima * t)
    end
    serie_sintonizada .-= (sum(serie_sintonizada) / N)
    
    # Imprimimos la telemetría formateada al log
    println("---------------------------------------------------------------------")
    println("LOG TIMING: $time_now | Fase de Sintonía Óptima: $(round(fase_optima, digits=4))")
    println("Residuo de Ruido ARM Filtrado: $(round(eficiencia, digits=6))")
    println("---------------------------------------------------------------------")
    
    for k in 0:(div(N, 2) - 1)
        freq = (k * Fs) / N
        if freq >= 4.0 && freq <= 30.0
            re = 0.0
            for n in 0:(N - 1)
                re += serie_sintonizada[n + 1] * cos(2.0 * pi * k * n / N)
            end
            potencia = sqrt(re^2) / N
            
            if potencia > 0.0005
                tipo_onda = freq < 8.0 ? "🔴 THETA" : (freq < 12.0 ? "🟢 ALFA" : "🔵 BETA")
                @printf("  [%s] %5.2f Hz -> Potencia Espectral Sintonizada: %.6f\n", tipo_onda, freq, potencia)
            end
        end
    end
    flush(stdout) # Fuerza a escribir en el archivo de log inmediatamente
    sleep(5.0)    # Pausa de 5 segundos entre escaneos continuos del entorno
end
