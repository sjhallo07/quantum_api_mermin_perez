# =====================================================================
# API MATRICIAL PURA: CORRECCIÓN DE ESCALA DE PUREZA ASINTÓTICA
# =====================================================================
module ApiMatricial

using LinearAlgebra
using ..Ecosistema

export inicializar_operadores_pauli, proyectar_sistema_algebraico!

function inicializar_operadores_pauli()
    I2 = [1.0+0.0im 0.0; 0.0 1.0]
    X  = [0.0+0.0im 1.0; 1.0 0.0]
    Y  = [0.0 -1.0im; 1.0im 0.0]
    Z  = [1.0+0.0im 0.0; 0.0 -1.0]
    return I2, X, Y, Z
end

function proyectar_sistema_algebraico!(engine::EnginePool)
    dim_actual = size(engine.M_sistema, 1)
    println("[API Matricial] Sustituyendo álgebra. Proyectando matriz cuántica de ", dim_actual, "x", dim_actual)
    
    # Sincronización estricta: Nos aseguramos de que el estado esté normalizado antes del producto
    traza_actual = tr(engine.M_sistema)
    if real(traza_actual) > 1.0001
        engine.M_sistema ./= traza_actual
    end
    
    # Cálculo de la pureza en el espacio físico correcto
    pureza = real(tr(engine.M_sistema * engine.M_sistema))
    
    println("-> Coherencia matricial extraída. Pureza real del estado: ", pureza)
    return pureza
end

end # module
