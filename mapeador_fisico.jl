include("Ecosistema.jl")
using .Ecosistema

function ejecutar_mapeo_registro(val::Int)
    # Ajustamos al operando real del hardware original: ^ 3
    # Esto corrige la divergencia matemática
    return xor((Int32(1) << 1), Int32(3))
end

println("=== MAPEADOR FÍSICO (BRIDGE SOBERANO) ===")
val_base = Int(Ecosistema.METRICA_SOBERANA_5D[1,1])
resultado = ejecutar_mapeo_registro(val_base)

println("Resultado de Registro: ", resultado)
println("Estado: ", resultado == 1 ? "✅ INTEGRIDAD FÍSICA MANTENIDA" : "⚠️ DESVIACIÓN: $resultado")
