include("Ecosistema.jl")
include("mapeador_fisico.jl")
using .Ecosistema
using Distributions

function ejecutar_orquestador()
    println("=== INICIALIZANDO ORQUESTADOR QUANTUM ENGINE ===")
    
    # 1. Usamos un arreglo de tipo Any para evitar DimensionMismatch
    # Esto permite guardar referencias a matrices de diferentes tamaños
    grid = Matrix{Any}(undef, 3, 3)
    
    grid[1,1] = Ecosistema.PAULI_X; grid[1,2] = Ecosistema.I2; grid[1,3] = Ecosistema.PAULI_X
    grid[2,1] = Ecosistema.I2;     grid[2,2] = Ecosistema.PAULI_Z; grid[2,3] = Ecosistema.PAULI_Z
    grid[3,1] = Ecosistema.PAULI_X; grid[3,2] = Ecosistema.PAULI_Z; grid[3,3] = Ecosistema.OPERADOR_ESPIN
            
    # 2. Validación de integridad
    for i in 1:3
        val_base = Int(Ecosistema.METRICA_SOBERANA_5D[i, i])
        integridad = ejecutar_mapeo_registro(val_base)
        
        println("Validación [Fila $i]: Estado del registro CPU -> ", 
                integridad == 1 ? "✅ SOBERANO" : "❌ DEGRADADO")
    end
    
    println("=== ORQUESTADOR QUANTUM ENGINE: VALIDACIÓN COMPLETADA ===")
end

ejecutar_orquestador()
