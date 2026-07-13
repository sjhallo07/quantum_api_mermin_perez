include("Ecosistema.jl")
include("mapeador_fisico.jl")
using .Ecosistema

function ejecutar_prueba_stress()
    println("=== PRUEBA DE ESTRÉS: ACTUALIZACIÓN DE MATRIZ ===")
    
    # 1. Grid de referencia
    grid = Matrix{Any}(undef, 3, 3)
    grid[1,1] = Ecosistema.PAULI_X
    
    # 2. Definir una nueva matriz para actualizar (ejemplo: Z2)
    println("Estado inicial celda (1,1): ", typeof(grid[1,1]))
    
    # 3. Ciclo de Actualización
    nuevos_valores = [Ecosistema.Z2, Ecosistema.X2, Ecosistema.I2]
    
    for (idx, mat) in enumerate(nuevos_valores)
        # Actualización in-place
        grid[1,1] = mat
        
        # Validación inmediata mediante Mapeador
        val_test = Int(Ecosistema.METRICA_SOBERANA_5D[1,1])
        res = ejecutar_mapeo_registro(val_test)
        
        println("Actualización #$idx -> Nueva Matriz: ", typeof(mat), " | Integridad: ", res == 1 ? "✅" : "❌")
    end
    
    println("=== PRUEBA FINALIZADA: SISTEMA ESTABLE ===")
end

ejecutar_prueba_stress()
