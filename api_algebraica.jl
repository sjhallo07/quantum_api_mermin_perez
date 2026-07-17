module ApiMatricial

using LinearAlgebra
using JSON

export proyectar_sistema_algebraico!

# Eliminamos el import problemático y dejamos que acepte cualquier estructura de motor
function proyectar_sistema_algebraico!(engine::Any)
    println("-> [API] Analizando consistencia matricial...")
    # Cálculo in-place de la pureza cuántica
    pureza = real(tr(engine.M_sistema * engine.M_sistema))
    println("-> [API] Pureza espectral calculada: ", pureza)
    return pureza
end

end
