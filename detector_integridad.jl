using SHA
hash_oficial = strip(read("results.seal", String))
datos = read("results.json", String)
hash_actual = bytes2hex(sha256(datos))
if hash_actual == hash_oficial
    println("✅ INTEGRIDAD VERIFICADA: Datos originales.")
else
    println("❌ ALERTA: ¡Datos alterados!")
end
