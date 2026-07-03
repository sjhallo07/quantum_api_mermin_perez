# Función para generar e imprimir el estado cuántico de N qubits
function generar_qubits_zero(n_qubits)
    # El espacio de Hilbert tiene una dimensión de 2^N estados posibles
    dimension = 2^n_qubits
    
    # Inicializar el registro en el estado fundamental |00...0>
    registro = zeros(ComplexF64, dimension)
    registro[1] = 1.0 + 0.0im  # Probabilidad del 100% en el estado inicial
    
    println("\n=== REGISTRO CUÁNTICO GENERADO (N = ", n_qubits, " Qubits) ===")
    println("Dimensión del Espacio de Hilbert: ", dimension, " estados.")
    println("Vector de estado cuántico base:")
    for i in 1:dimension
        # Convertir el índice a formato binario para visualizar los qubits
        bitstring = string(i-1, base=2, pad=n_qubits)
        println("  |", bitstring, "⟩ : ", round(registro[i], digits=2))
    end
end

# Función para generar un par de Qubits entrelazados (Estado de Bell / GHZ)
function generar_qubits_entrelazados()
    # Estado |ψ⟩ = (|00⟩ + |11⟩) / √2
    val = 1.0 / sqrt(2)
    par_bell = [complex(val, 0.0), 0.0im, 0.0im, complex(val, 0.0)]
    
    println("\n=== QUBITS MÁXIMAMENTE ENTLAZADOS (Par de Bell / GHZ) ===")
    println("  |00⟩ : ", round(real(par_bell[1]), digits=4))
    println("  |01⟩ : ", round(real(par_bell[2]), digits=4))
    println("  |10⟩ : ", round(real(par_bell[3]), digits=4))
    println("  |11⟩ : ", round(real(par_bell[4]), digits=4))
end

# Ejecutar la generación
generar_qubits_zero(3)  # Genera un registro limpio de 3 qubits
generar_qubits_entrelazados()  # Genera el entrelazamiento base del QRE
