using SHA
datos = read("qre_validation_core.json", String)
hash_actual = bytes2hex(sha256(datos))
open("qre_validation.seal", "w") do f; write(f, hash_actual); end
println("✅ Firma Soberana generada para QRE: $hash_actual")
