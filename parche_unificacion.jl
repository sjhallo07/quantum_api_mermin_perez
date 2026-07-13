using LinearAlgebra

println("\n=====================================================")
println("🔄 PARCHEANDO PIPELINE DE APRENDIZAJE: META_LEARNING_TEP.JL -> 8D")
println("=====================================================")

path_file = "meta_learning_tep.jl"

if isfile(path_file)
    lineas = readlines(path_file)
    
    open(path_file, "w") do io
        for linea in lineas
            if occursin("const MATRIZ_DENSIDAD_4x4", linea)
                println(io, linea)
                println(io, "\n# --- INYECCIÓN GLOBAL 8D (Evita truncamiento de q6, q7, q8) ---")
                println(io, "const MATRIZ_DENSIDAD_8x8 = Float64[")
                println(io, "    0.110  0.030  0.050  0.020  0.050  0.040  0.030  0.030;")
                println(io, "    0.030  0.130  0.060  0.020  0.060  0.050  0.040  0.040;")
                println(io, "    0.050  0.060  0.150  0.030  0.080  0.060  0.050  0.050;")
                println(io, "    0.020  0.020  0.030  0.100  0.030  0.030  0.020  0.020;")
                println(io, "    0.050  0.060  0.080  0.030  0.160  0.060  0.050  0.050;")
                println(io, "    0.040  0.050  0.060  0.030  0.060  0.120  0.040  0.040;")
                println(io, "    0.030  0.040  0.050  0.020  0.050  0.040  0.110  0.030;")
                println(io, "    0.030  0.040  0.050  0.020  0.050  0.040  0.030  0.120")
                println(io, "]")
            else
                println(io, linea)
            end
        end
    end
    println("✅ ARCHIVO META_LEARNING_TEP.JL ACTUALIZADO CON ÉXITO.")
else
    println("❌ Error: No se encontró meta_learning_tep.jl.")
end
println("=====================================================\n")
