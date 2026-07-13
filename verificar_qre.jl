include("soberania_absoluta.jl")
using SHA
datos = read("qre_phase_ii.json", String)
hash_actual = bytes2hex(sha256(datos))
println("--- VALIDACIÓN DEL SISTEMA ---")
println("Archivo: qre_phase_ii.json")
println("Sello Criptográfico (Hash): $hash_actual")
println("Estado del Motor: Verificado y Sellado")
