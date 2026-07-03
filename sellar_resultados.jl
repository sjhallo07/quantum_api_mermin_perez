using SHA
datos = read("results.json", String)
hash_actual = bytes2hex(sha256(datos))
open("results.seal", "w") do f; write(f, hash_actual); end
println("✅ Sello creado con hash: $hash_actual")
